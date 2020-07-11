//
//  UserController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 11/11/2019.
//

import Foundation
import Crypto
import Vapor
import Fluent
import FluentPostgreSQL
import Authentication
import CoreFoundation

/// - MARK - CREATE AND AUTHENTICATE USERS
public final class UserController {
  
  public init() { }
  /// Fetch logged user throw if it can't
  public static func logged(_ req: Request) throws -> User {
    let logger = try  req.make(Logger.self)
    logger.info("===Origin :\(String(describing: req.http.headers.firstValue(name: HTTPHeaderName.referer))) \n Client IP: \(String(describing: req.http.channel!.remoteAddress))")
    // fetch auth'd user
    let user = try? req.requireAuthenticated(User.self)
    guard let usr = user else {
      if try req.hasSession() { try req.destroySession() }
      throw Abort(HTTPResponseStatus.unauthorized)
    }
    return usr
  }
  
  /// Check that access is the same user
  public static func authUserIs(user: User, for req: Request) throws -> Bool {
    // fetch auth'd user
    let uAuth = try UserController.logged(req)
    guard try user.requireID() == uAuth.requireID() else {
      return false
    }
    return true
  }
   
   /// Logs a user in, returning a token for accessing protected endpoints.
   public func loginAPI(_ req: Request) throws ->
     Future<User.FullLoggedResponse> {
       let logger = try  req.make(Logger.self)
       logger.info("##WEP POST /login ## User log in >>>")
       return try login(req)
   }
  
  /// Logs a user in, returning a token for accessing protected endpoints.
  public func login(_ req: Request, _ signers: [(Request) throws -> Future<User.FullLoggedResponse>] = []) throws -> Future<User.FullLoggedResponse> {
    let logger = try req.make(Logger.self)
    logger.info("##WEF POST /login ## Login lokup strategy.")
    if !signers.isEmpty {
      for fn in signers {
        let logUser = try? fn(req)
        if let fullUser = logUser {
          return fullUser
        }
      }
    }
    return try loginBasic(req)
  }
  
  /// Logs a user in, returntry ing a token for accessing protected endpoints.
  public func logoutAPI(_ req: Request) throws ->
    Future<User.Logout> {
      let uAuth = try UserController.logged(req)
      let logger = try  req.make(Logger.self)
      logger.info("##WEP POST /logout ## User log out \(uAuth.login) >>>")
      return try uAuth.authTokens.query(on: req).all()
        .map { (utokens) ->User.Logout in
          utokens.forEach { (utoken) in
            utoken.expiresOn = Date()
            _ = utoken.update(on: req)
          }
          logger.info("##WEP POST /logout ## User \(uAuth.login), was logged out.")
          return User.Logout(id: uAuth.id!, login: uAuth.login, msg: "Logged well done", code: "101")
      }
  }
  
  
  /// Logs a user in, returning a token for accessing protected endpoints.
  public func loginBasic(_ req: Request) throws -> Future<User.FullLoggedResponse> {
    // get user auth'd by basic auth middleware
    let uAuth = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("##WEF POST /login ## Basic login succeed for \(uAuth.login)")
    logger.info("Creation token for user \(uAuth.id!)")
    // create new token for this user
    let token = try UserToken.create(userID: uAuth.requireID())
    logger.info("\(uAuth.id!) - \"\(uAuth.login)\" has a new token witch expire on \(String(describing: token.expiresOn))")
    // TODO expire the rest of token
    // save and return token
    return token.save(on: req).flatMap { tok in // Log the saving token
      logger.info("\(uAuth.id!) - \"\(uAuth.login)\" token \"\(token.id!)\" for user \"\(token.user)\" saved")
      return uAuth.fullLoggedResponse(req, tok)
    }
  }
  
  /// Creates a new user.
  public func createAPI(_ req: Request) throws -> Future<User.FullPublicResponse> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEP POST /signup ## User creation >>>")
    // decode request content
    return try req.content.decode(User.Create.self)
      .flatMap { cuser -> Future<User> in
        return try self.create(req, with: cuser)
    }.catchMap({ (error) -> (User) in
      if let err = error as? PostgreSQLError {
        let log = try req.make(Logger.self)
        log.error("Error identifier : " + err.identifier)
        log.error("Error causes : " + err.possibleCauses.debugDescription)
        log.error("Error reason : " + err.reason)
        log.error("Error fullIdentifier : " + err.fullIdentifier)
        
        log.error(err.localizedDescription)
        let skeleton = User(login: "", email: "", passwordHash: "", profile: 0)
        return skeleton
      } else {
        let log = try req.make(Logger.self)
        log.error("Error identifier : " + error.localizedDescription)
        
        log.error(error.localizedDescription)
        throw error
      }
    }).flatMap({ (u) in
      if u.login.isEmpty
        &&  u.passwordHash.isEmpty && u.email.isEmpty {
        let res = u.fullResponse(req, [LabeledValue<String>(label: "10", value: "Impossible de créer l'utilisateur renseigné")])
        return res
      }
      return u.fullResponse(req)
    })
    
  }
  /// Creates a new user.
  public func create(_ req: Request, with cuser: User.Create) throws -> Future<User> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEF POST /signup ## User creating \(cuser.login ?? cuser.email)")
    // verify that passwords match
    guard cuser.password == cuser.verifyPassword else {
      throw Abort(.badRequest, reason: "passwords missmatch")
    }
    let hash = try BCrypt.hash(cuser.password)
    let logNick = cuser.login ?? String(cuser.email.split(separator: "@").first!)
      .replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "_")
    let cont = Contact(givenName: "", familyName: "")
    cont.nickname = logNick
    cont.ckind = .person(.unknown)
    /// WARNING TODO : GENIRIC this .psql
    return req.transaction(on: .psql) { (conn) -> Future<User>  in
    return cont.create(on: req)
      .flatMap { (contact) -> Future<User> in
        let u = User(login: logNick, email: cuser.email, passwordHash: hash, profile: cont.id!, staff: cuser.staff?.staff ?? StaffUserRole.user, state: .defaultValue)
        u.profileID = contact.id!
        u.newEmail = u.email
        u.emailChangeToken = Utils.newRef(kUserReferenceBasePrefix, size: kReferenceDefaultLength * 4)
        u.emailChangeDate  = Date().addingTimeInterval(60*60*24*28) // 30 days to activate
        try u.validate()
        return u.create(on:req)
    }
    }
  }
}

/// - MARK - USERS ROUTES
extension UserController: RouteCollection {
  public func boot(router: Router) throws {
    /*************************** PUBLIC SECTION *************************
     ***
     *******************************************************************/
    /** Public user end point api spec */
    // Creation of a new user
    router.post(Config.APIWEP.signupWEP, use: createAPI(_:))
    
    /*************************** LOGGED SECTION *************************
     ***
     *******************************************************************/
    /** Public user end point api spec */
    // Creation of a new user
    // basic / password auth protected routes
    let basic = router.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
    // bearer / token auth protected routes
    let bearer = router.grouped(User.tokenAuthMiddleware())
    /// Login user used basic information at least
    basic.post(Config.APIWEP.loginWEP, use: loginAPI(_:))
    bearer.get(Config.APIWEP.logoutWEP, use: logoutAPI(_:))
  }
}
