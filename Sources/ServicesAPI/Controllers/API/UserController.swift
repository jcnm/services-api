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

let kRootPathForProfilPicture = "public/u/"
let kFinalPatchProfilPicture = "/pp"

/// - MARK - CREATE AND AUTHENTICATE USERS
public final class UserController {
  
  public init() { }

  public static func logged(_ req: Request) throws -> User {
    let logger = try  req.make(Logger.self)
    logger.info("@@@\n@@@\n@@@\n@@@\n@@@\n@@@ Query came (\(req.http.headers.firstValue(name: HTTPHeaderName.referer)) (req.http.channel!.remoteAddress :  \(req.http.channel!.remoteAddress))\n@@@@\n@@@@\n@@@\n@@@")
    // fetch auth'd user
    let user = try req.requireAuthenticated(User.self)
    guard try user.requireID() != 0 else {
      throw Abort(HTTPResponseStatus.unauthorized)
    }
    return user
  }
  
  public static func checkLoginRelated(_ req: Request, _ specifiedUser: User) throws -> User {
    // fetch auth'd user
    let user = try logged(req)
    guard try specifiedUser.requireID() == user.requireID() else {
      throw Abort(HTTPResponseStatus.forbidden)
    }
    return user
  }
  
  /// Logs a user in, returning a token for accessing protected endpoints.
  public func login(_ req: Request, _ signers: [(Request) throws -> Future<User.FullLoggedResponse>] = []) throws -> Future<User.FullLoggedResponse> {
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
  
  
  /// Logs a user in, returning a token for accessing protected endpoints.
  public func loginAPI(_ req: Request) throws -> Future<User.FullLoggedResponse> {
    return try login(req)
  }
  

  
  /// Logs a user in, returning a token for accessing protected endpoints.
  public func loginBasic(_ req: Request) throws -> Future<User.FullLoggedResponse> {
    // get user auth'd by basic auth middleware
    let user = try UserController.logged(req)
    
    let logger = try req.make(Logger.self)
    logger.info("\(String(describing: user.id)) - \"\(String(describing: user.login))\" is connected for a token")
    // create new token for this user
    let token = try UserToken.create(userID: user.requireID())
    logger.info("\(String(describing: user.id)) - \"\(String(describing: user.login))\" has a new token witch expire on \(String(describing: token.expiresOn))")
    // TODO expire the rest of token
    // save and return token
    return token.save(on: req).flatMap { tok in // Log the saving token
      logger.info("\(String(describing: user.id)) - \"\(String(describing: user.login))\" token \"\(String(describing: token.id))\" for user \"\(token.user)\" saved")
      return user.fullLoggedResponse(req, tok)
    }
    
  }
  
  /// Creates a new user.
  public func create(_ req: Request) throws -> Future<User.FullPublicResponse> {
    // decode request content
    return try req.content.decode(User.Create.self)
      .flatMap { cuser -> Future<User> in
        // verify that passwords match
        guard cuser.password == cuser.verifyPassword else {
          throw Abort(.badRequest, reason: "passwords missmatch")
        }
        
        let hash = try BCrypt.hash(cuser.password)
        let logNick = cuser.login ?? String(cuser.email.split(separator: "@").first!).replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "_")
        let cont = Contact(givenName: "", familyName: "")
        cont.nickname = logNick
        cont.ckind = .defaultValue
        return cont.create(on: req).flatMap { (contact) -> Future<User> in
          let u = User(login: logNick, email: cuser.email, passwordHash: hash, profile: nil, staff: cuser.staff?.staff ?? StaffUserRole.user, state: .defaultValue)
          u.profileID = contact.id
          try u.validate()
          return u.create(on:req)
        }
    }.catchMap({ (error) -> (User) in
      if let err = error as? PostgreSQLError {
        let log = try req.make(Logger.self)
        log.error("Error identifier : " + err.identifier)
        log.error("Error causes : " + err.possibleCauses.debugDescription)
        log.error("Error reason : " + err.reason)
        log.error("Error fullIdentifier : " + err.fullIdentifier)
        
        log.error(err.localizedDescription)
        let skeleton = User(login: "", email: "", passwordHash: "")
        return skeleton
      }
      else {
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
  
}

/// - MARK - USER UPDATE CONTROLLER
extension UserController {
  /// Update an user using User.Update
  public func updateUser(_ req: Request) throws -> Future<User.ShortPublicResponse> {
    // decode request parameter (u/:id)
    return try req.parameters.next(User.self).flatMap
      { uToUpdate -> Future<User.ShortPublicResponse> in
        let _ = try UserController.checkLoginRelated(req, uToUpdate)
        
        return try req.content.decode(User.Update.self).flatMap({ (uRequest) -> Future<User.ShortPublicResponse> in
          guard try uRequest.id == uToUpdate.requireID() else {
            throw Abort(HTTPResponseStatus.forbidden)
          }
          if let log = uRequest.login {
            uToUpdate.login = log
            print("Login updated to \(log)")
          }
          if let uk = uRequest.staff {
            uToUpdate.staff = uk
            print("User kind updated to \(uk)")
          }
          if let state = uRequest.state {
            uToUpdate.state = state
            print("User state updated to \(state)")
          }
          
          // ...ALTER TABLE user ADD avatar TEXT;
          if let img = uRequest.avatar {
            try self.savePicture(img, uToUpdate)
          }
          return uToUpdate.save(on: req).flatMap({ req.future($0.shortResponse()) })
        })
        
    }
  }
  
  /// Update an user using User.Update
  public func update(_ req: Request) throws -> Future<User.ShortPublicResponse> {
    // decode request parameter (u/:id)
    let u = try UserController.logged(req)
    return try req.content.decode(User.Update.self).flatMap({ (uRequest) -> EventLoopFuture<User.ShortPublicResponse> in
      guard try uRequest.id == u.requireID() else {
        throw Abort(HTTPResponseStatus.forbidden)
      }
      if let log = uRequest.login {
        u.login = log
        print("Login updated to \(log)")
      }
      if let uk = uRequest.staff {
        u.staff = uk
        print("User kind updated to \(uk)")
      }
      if let state = uRequest.state {
        u.state = state
        print("User state updated to \(state)")
      }
      
      // ...ALTER TABLE user ADD avatar TEXT;
      if let img = uRequest.avatar {
        try self.savePicture(img, u)
      }
      return u.save(on: req).flatMap({ req.future($0.shortResponse()) })
    })
  }
  
  private func savePicture(_ img: File, _ user: User) throws {
    let home:URL = URL(fileURLWithPath: kRootPathForProfilPicture, isDirectory: true)
    let subLoggedUserPath = user.login + kFinalPatchProfilPicture
    var path = home.appendingPathComponent(subLoggedUserPath)
    path.appendPathComponent(img.filename.hash.description + "." + (img.ext ?? ".png"), isDirectory: false)
    // TODO Catch
    try FileManager.default.createDirectory(at: path.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
    // TODO Catch
    try img.data.write(to: path) // save picture on disk
    user.avatar = path.absoluteString // save picture on user
  }
  
  /// Create User Profile Picture
  public func updateProfileVcard(_ req: Vapor.Request) throws -> Future<String> {
    // fetch auth'd user
    let userAuth = try req.requireAuthenticated(User.self)
    print(req.debugDescription)
    return try req.parameters.next(User.self).flatMap{ uToUpdate -> Future<String> in
      guard try uToUpdate.requireID() == userAuth.requireID() else {
        throw Abort(HTTPResponseStatus.forbidden)
      }
      return try req.content.decode(User.Update.self).flatMap{ (uRequest) in
        guard try uRequest.id == uToUpdate.requireID() else {
          throw Abort(HTTPResponseStatus.forbidden)
        }
        if let img = uRequest.avatar {
          try self.savePicture(img, uToUpdate)
          return uToUpdate.save(on: req).map({ $0.avatar! })
        } else {
          throw Abort(HTTPResponseStatus.notAcceptable)
        }
      }
    }
    
  }
  
}


let kLookUpNavigationLimit     = 2
let kLookUpNavigationOffset    = 0
let kLookUpNavigationPage      = 1
let kLookUpNavigationDirection = "null"

let kLookUpLimitQuery     = "limit"
let kLookUpOffsetQuery    = "offset"
let kLookUpPageQuery      = "p"
let kLookUpDirectionQuery = "order"
let kSearchQuery = "q"

/// - MARK - GET USER INFOS
extension UserController {
  /// List all users.
  public func list(_ req: Request) throws -> Future<[User.ShortPublicResponse]> {
    let user = try req.requireAuthenticated(User.self)
    var meta = PageMeta()
    meta.config(from: req)
    guard user.id != nil else {
      throw Abort(HTTPResponseStatus.unauthorized)
    }
    //    let users = User.query(on: req).join(\Profile.id, to: \User.id).alsoDecode(Profile.self).all()
    //    return users.flatMap({(uar) -> EventLoopFuture<[User.Response]> in
    //      let uresp = uar.compactMap({ (u) -> Future<User.Response> in
    //        return u.0.response(req, with: u.1)
    //      }).flatten(on: req)
    //      return uresp
    //    })
    var filter = FilterNavigation<User.ShortPublicResponse>()
    
    let users = filter.apply(User.query(on: req), from: req).all()
    return users.flatMap({(u) -> Future<[User.ShortPublicResponse]> in
      return u.compactMap({ req.future($0.shortResponse())}).flatten(on: req)
    })
  }
  
  public func lookupAssociated(_ req: Request, of: User? = nil) throws -> Future<[User.QuickSearch]> {
    let logger = try  req.make(Logger.self)
    logger.info(req.http.debugDescription)
    let user = try UserController.logged(req)
    logger.info("Getting User search initiated by \(user.id!) (\(user.login))")
    var meta = PageMeta(req) 
    var qry = ""
    if let qsrch = try? req.query.get(String.self, at: kSearchQuery) {
      qry = "%"+qsrch+"%"
    }
    if qry.isEmpty {
      return req.future([])
    }
    if user.staff.staff.isAdministrator || user.staff.staff.isBigBrother {
          let usersBuild = User.query(on: req)
        .join(\Contact.id, to: \User.profileID).alsoDecode(Contact.self)
        .group(.or) {
        $0.filter(\User.login,        .ilike, qry)
          .filter(\User.email,        .ilike, qry)
          .filter(\User.orgUserRef,   .ilike, qry)
          .filter(\User.ref,          .ilike, qry)
          .filter(\Contact.nickname,  .ilike, qry)
          .filter(\Contact.givenName, .ilike, qry)
          .filter(\Contact.familyName,      .ilike, qry)
          .filter(\Contact.departmentName,  .ilike, qry)
          .filter(\Contact.jobTitle,        .ilike, qry)
          .filter(\Contact.middleName,      .ilike, qry)
      }
      logger.debug("Getting User search from an administrator (\(user.staff.staff.isAdministrator)")

      return usersBuild.all().flatMap({(usrs: [(User, Contact)]) -> Future<[User.QuickSearch]> in
        return usrs.compactMap({
          req.future(User.QuickSearch(id: $0.0.id!, login: $0.0.login, ref: $0.0.ref, avatar: $0.0.avatar ?? "http://localhost:8080/imgs/profil.png", kind: $0.1.ckind, givenName: $0.1.givenName, familyName: $0.1.familyName, nickname: $0.1.nickname, jobTitle: $0.1.jobTitle, departmentName: $0.1.departmentName) )}).flatten(on: req)
      })
    }
    let query = """
    SELECT DISTINCT "user"."id", "user"."login", "user"."ref", "user"."email", "user"."orgUserRef", "user"."ref", "contact"."nickname",
    "contact"."givenName", "contact"."familyName", "contact"."departmentName", "contact"."jobTitle", "contact"."middleName",
    "contact"."note", "contact"."previousFamilyName"
    FROM "user"
    INNER JOIN "contact" ON "user"."profileID" = "contact"."id"
    LEFT JOIN "uorganization" ON "user"."id" = "uorganization"."userID"
    INNER JOIN "organization" ON "organization"."id" = "uorganization"."organizationID"
    LIMIT \(meta.limit) OFFSET \(meta.offset)
    WHERE ("uorganization"."organizationID"
    IN
    (
    SELECT DISTINCT "uorganization"."organizationID"
    FROM "uorganization"
    WHERE "uorganization"."userID" = \(user.id!))
    )
    AND (
    "user"."login"                    ILIKE '\(qry)'
    OR "user"."email"                 ILIKE '\(qry)'
    OR "user"."orgUserRef"            ILIKE '\(qry)'
    OR "user"."ref"                   ILIKE '\(qry)'
    OR "contact"."nickname"           ILIKE '\(qry)'
    OR "contact"."givenName"          ILIKE '\(qry)'
    OR "contact"."familyName"         ILIKE '\(qry)'
    OR "contact"."departmentName"     ILIKE '\(qry)'
    OR "contact"."jobTitle"           ILIKE '\(qry)'
    OR "contact"."middleName"         ILIKE '\(qry)'
    OR "contact"."note"               ILIKE '\(qry)'
    OR "contact"."previousFamilyName" ILIKE '\(qry)'
    OR "organization"."label"         ILIKE '\(qry)'
    OR "organization"."slogan"        ILIKE '\(qry)'
    OR "organization"."shortLabel"    ILIKE '\(qry)'
    )
    """
    return req.withNewConnection(to: .psql) { $0.raw( query ).all(decoding: User.QuickSearch.self) }
    
  }
  
  /**
   * list of `Order` for the logged user
   */
  public func ordersForLoggedUser(_ req: Request) throws -> Future<[Order]> {
    let uAuth = try UserController.logged(req)
    var filter = FilterNavigation<Order>()
    return try filter.apply(uAuth.orders.query(on: req), from: req).all()
  }
  
  /**
   * list of `Order` for the given user
   */
  public func ordersForUser(_ req: Request) throws -> Future<[Order]> {
    let _ = try UserController.logged(req)
    // decode request parameter (u/:id)
    return try req.parameters.next(User.self).flatMap
      { designedUser -> Future<[Order]> in
        var filter = FilterNavigation<Order>()
        return try filter.apply(designedUser.orders.query(on: req), from: req).all()
    }
  }
  
  /**
   * list of `Service` for the logged user
   */
  public func servicesForLoggedUser(_ req: Request) throws -> Future<[Service]> {
    let uAuth = try UserController.logged(req)
    var filter = FilterNavigation<Service>()
    return try filter.apply(uAuth.services.query(on: req), from: req).all()
  }
  
  /**
   * list of `Service` for the given user
   */
  public func servicesForUser(_ req: Request) throws -> Future<[Service]> {
    let _ = try UserController.logged(req)
    // decode request parameter (u/:id)
    return try req.parameters.next(User.self).flatMap
      { designedUser -> Future<[Service]> in
        var filter = FilterNavigation<Service>()
        return try filter.apply(designedUser.services.query(on: req), from: req).all()
    }
  }
  
  /// Show an user.
  public func show(_ req: Request) throws -> Future<User.FullPublicResponse> {
    // fetch auth'd user
    let _ = try req.requireAuthenticated(User.self)
    
    // decode request parameter (users/:id)
    do {
      guard let userID = req.parameters.values.first else {
        throw Abort(HTTPResponseStatus.badRequest)
      }
      // If the given id is zero then return the current authenticated user
      if userID.value == "0" { //|| userID.value.last == "!" {
        return try self.account(req)
      } else {
        let resp = try req.parameters.next(User.self)
        return resp.flatMap { u -> Future<User.FullPublicResponse> in
          return u.fullResponse(req)
        }
      }
    } catch let err {
      print("*************************")
      print("\n\n\nError info : \(err)")
      throw err
    }
  }
  
  /// Show the authentificated user.
  public func account(_ req: Request) throws -> Future<User.FullPublicResponse> {
    // fetch auth'd user
    let u = try req.requireAuthenticated(User.self)
    return u.fullResponse(req)
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
    router.post(kUsersRegisterPath, use: create)
    // basic / password auth protected routes
    let basic = router.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
    // bearer / token auth protected routes
    
    let bearer = router.grouped(User.tokenAuthMiddleware())
    basic.post(kUsersLoginBasePath, use: loginAPI)
    bearer.get(kUsersLookupBasePath, kUsersBasePath, use: { try self.lookupAssociated($0) })
    
    /**
     ** Logged User end point api spec - 1
     */
    let accoundGroup = bearer.grouped(kAccountBasePath)
    accoundGroup.get(use: account)
    accoundGroup.patch(kAccountBasePath, use: update) // update account
    //    accoundGroup.patch(kProfileBasePath, use: updateProfile) // update profile accound
    
    let userLoggedGroup = bearer.grouped(kUserBasePath)
    userLoggedGroup.get(User.parameter, use: show)
    
  }
  
  
}
