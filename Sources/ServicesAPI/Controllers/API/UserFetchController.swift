//
//  UserFetchController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 09/06/2020.
//

import Foundation
import Crypto
import Vapor
import Fluent
import FluentPostgreSQL
import Authentication
import CoreFoundation

/// - MARK - USERS ACCOUNT FETCHING
public class UserFetchController {
  
  public init() { }
  
  /// Show the authentificated user's full information.
  public func account(_ req: Request) throws -> Future<User.FullPublicResponse> {
    return try self.showAccoundAPI(req)
  }
  
  /**
   * returns full information of the given `User`
   */
  public func showAccoundAPI(_ req: Request) throws -> Future<User.FullPublicResponse> {
    // fetch auth'd user
    let uAuth = try req.requireAuthenticated(User.self)
    let logger = try  req.make(Logger.self)
    logger.info("##WEP GET /account/orders ## Listing orders of logged user \(uAuth.login)")
    return try show(req, for: uAuth)
  }
  /**
   * returns full information of the given `User`
   */
  public func show(_ req: Request, for designedUser: User) throws -> Future<User.FullPublicResponse> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEF GET .../\(designedUser.id!) ## Return full information of the given user \(designedUser.login)")
    return designedUser.fullResponse(req)
  }
  
  /**
   * User's profile throught /users/:id/profile
   */
  public func profileAccountAPI(_ req: Request) throws -> Future<Contact> {
    let uAuth = try UserController.logged(req)
    let logger = try  req.make(Logger.self)
    logger.info("##WEP GET /account/profile ## Return \(uAuth.login)'s profile")
    return uAuth.profile.get(on: req)
  }
  
  /**
   * list of `Service` for the logged user
   */
  public func servicesAccountAPI(_ req: Request) throws -> Future<[Service]> {
    let uAuth = try UserController.logged(req)
    let logger = try  req.make(Logger.self)
    logger.info("##WEP GET /account/services ## Listing service of logged user \(uAuth.login)")
    return try services(req, for: uAuth)
  }
  /**
   * list of `Service` for the given user
   */
  public func services(_ req: Request, for designedUser: User) throws -> Future<[Service]>  {
    let logger = try  req.make(Logger.self)
    logger.info("##WEF GET .../\(designedUser.id!)/services ## Listing services of user \(designedUser.login)")
    var filter = FilterNavigation<Service>()
    // let meta = PageMeta(req)
    let rFilter = try filter.apply(designedUser.services.query(on: req), from: req)
    return rFilter.all()
  }
  
  /**
   * list of `Order` for the logged user
   */
  public func ordersAccountAPI(_ req: Request) throws -> Future<[Order]> {
    let uAuth = try UserController.logged(req)
    let logger = try  req.make(Logger.self)
    logger.info("##WEP GET /account/orders ## Listing orders of logged user \(uAuth.login)")
    return try orders(req, for: uAuth)
  }
  /**
   * list of `Order` for the given user
   */
  public func orders(_ req: Request, for designedUser: User) throws -> Future<[Order]> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEF GET .../\(designedUser.id!)/orders ## Listing orders of user \(designedUser.login)")
    var filter = FilterNavigation<Order>()
    return try filter.apply(designedUser.orders.query(on: req), from: req).all()
  }
  
  /**
   * list of `Organization` for the logged user
   */
  public func organizationsAccountAPI(_ req: Request) throws -> Future<[Organization]> {
    let uAuth = try UserController.logged(req)
    let logger = try  req.make(Logger.self)
    logger.info("##WEP GET /account/organizations ## Listing organizations of logged user \(uAuth.login)")
    return try organizations(req, for: uAuth)
  }
  /**
   * list of `Organization` for the given user
   */
  public func organizations(_ req: Request, for designedUser: User) throws -> Future<[Organization]> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEF GET .../\(designedUser.id!)/organizations ## Listing organizations of user \(designedUser.login)")
    var filter = FilterNavigation<Organization>()
    return try filter.apply(designedUser.organizations.query(on: req), from: req).all()
  }
  
  /**
   * list of `Schedule` for the logged user
   */
  public func schedulesAccountAPI(_ req: Request) throws -> Future<[Schedule]> {
    let uAuth = try UserController.logged(req)
    let logger = try  req.make(Logger.self)
    logger.info("##WEP GET /account/schedules ## Listing schedules of logged user \(uAuth.login)")
    return try schedules(req, for: uAuth)
  }
  /**
   * list of `Schedule` for the given user
   */
  public func schedules(_ req: Request, for designedUser: User) throws -> Future<[Schedule]> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEF GET .../\(designedUser.id!)/schedules ## Listing schedules of user \(designedUser.login)")
    var filter = FilterNavigation<Schedule>()
    return try filter.apply(designedUser.schedules.query(on: req), from: req).all()
  }
  
  /**
   * list of `Asset` for the logged user
   */
  public func assetsAccountAPI(_ req: Request) throws -> Future<[Asset]> {
    let uAuth = try UserController.logged(req)
    let logger = try  req.make(Logger.self)
    logger.info("##WEP GET /account/assets ## Listing assets of logged user \(uAuth.login)")
    return try assets(req, for: uAuth)
  }
  /**
   * list of `Asset` for the given user
   */
  public func assets(_ req: Request, for designedUser: User) throws -> Future<[Asset]> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEF GET .../\(designedUser.id!)/assets ## Listing assets of user \(designedUser.login)")
    var filter = FilterNavigation<Asset>()
    return try filter.apply(designedUser.assets.query(on: req), from: req).all()
  }
//
//  /**
//   * list of `Activity` for the logged user
//   */
//  public func activitiesAccountAPI(_ req: Request) throws -> Future<[Activity]> {
//    let uAuth = try UserController.logged(req)
//    let logger = try  req.make(Logger.self)
//    logger.info("##WEP GET /account/activities ## Listing activities of logged user \(uAuth.login)")
//    return try activities(req, for: uAuth)
//  }
//  /**
//   * list of `Activity` for the given user
//   */
//  public func activities(_ req: Request, for designedUser: User) throws -> Future<[Activity]> {
//    let logger = try  req.make(Logger.self)
//    logger.info("##WEF GET .../\(designedUser.id!)/activities ## Listing activities of user \(designedUser.login)")
//    var filter = FilterNavigation<Asset>()
//    return try filter.apply(designedUser.activities.query(on: req), from: req).all()
//  }

  /**
   * list of `Score` for the logged user
   */
  public func scoresAccountAPI(_ req: Request) throws -> Future<[Score]> {
    let uAuth = try UserController.logged(req)
    let logger = try  req.make(Logger.self)
    logger.info("##WEP GET /account/scores ## Listing scores of logged user \(uAuth.login)")
    return try scores(req, for: uAuth)
  }
  /**
   * list of `Score` for the given user
   */
  public func scores(_ req: Request, for designedUser: User) throws -> Future<[Score]> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEF GET .../\(designedUser.id!)/scores ## Listing scores of user \(designedUser.login)")
    var filter = FilterNavigation<Asset>()
    return try filter.apply(designedUser.scores.query(on: req), from: req).all()
  }

  /// Show the authentificated user.
  public func delete(_ req: Request) throws -> Future<User.FullPublicResponse> {
    // fetch auth'd user
    let _ = try req.requireAuthenticated(User.self)
    throw Abort(HTTPResponseStatus.notImplemented)
  }
}

/// - MARK - USERS ENDPOINT FETCHING
extension UserFetchController {
  
  /// List all users.
  public func list(_ req: Request) throws -> Future<[User.ShortPublicResponse]> {
    var filter = FilterNavigation<User.ShortPublicResponse>()
    let users = filter.apply(User.query(on: req), from: req).all()
    return users.flatMap({(u) -> Future<[User.ShortPublicResponse]> in
      return u.compactMap({ req.future($0.shortResponse())}).flatten(on: req)
    })
  }
  ///returns full information of the given `User` throught /users/:id
  public func showAPI(_ req: Request) throws -> Future<User.FullPublicResponse> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEP GET /users/:id ## Listing services of a given user")
    // decode request parameter (users/:id)
    do {
      return try req.parameters.next(User.self)
        .flatMap { targetedUser -> Future<User.FullPublicResponse> in
          return try self.show(req, for: targetedUser)
        }
      } catch let err {
      print("*************************")
      print("\n\n\nError info : \(err)")
      throw err
    }
  }
  /// User's profile throught /users/:id/profile
  public func profileAPI(_ req: Request) throws -> Future<Contact> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEP /users/:id/profil ## Returns profile of a given user")
    // decode request parameter (/users/:id)
    return try req.parameters.next(User.self)
      .flatMap { targetedUser in
        return targetedUser.profile.get(on: req)
    }
  }
  /// User's services listing throught /users/:id/services
  public func servicesAPI(_ req: Request) throws -> Future<[Service]> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEP /users/:id/services ## Listing services of a given user")
    // decode request parameter (/users/:id)
    return try req.parameters.next(User.self)
      .flatMap { targetedUser in
        return try self.services(req, for: targetedUser)
    }
  }
  /// User's orders listing throught /users/:id/orders
  public func ordersAPI(_ req: Request) throws -> Future<[Service]> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEP /users/:id/orders ## Listing orders of a given user")
    // decode request parameter (/users/:id)
    return try req.parameters.next(User.self)
      .flatMap { targetedUser in
        return try self.services(req, for: targetedUser)
    }
  }
  /// User's organizations listing throught /users/:id/organizations
  public func organizationsAPI(_ req: Request) throws -> Future<[Organization]> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEP /users/:id/organizations ## Listing organizations of a given user")
    // decode request parameter (/users/:id)
    return try req.parameters.next(User.self)
      .flatMap { targetedUser in
        return try self.organizations(req, for: targetedUser)
    }
  }
  /// User's schedules listing throught /users/:id/schedules
  public func schedulesAPI(_ req: Request) throws -> Future<[Schedule]> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEP /users/:id/schedules ## Listing schedules of a given user")
    // decode request parameter (/users/:id)
    return try req.parameters.next(User.self)
      .flatMap { targetedUser in
        return try self.schedules(req, for: targetedUser)
    }
  }
  /// User's assets listing throught /users/:id/assets
  public func assetsAPI(_ req: Request) throws -> Future<[Asset]> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEP /users/:id/assets ## Listing schedules of a given user")
    // decode request parameter (/users/:id)
    return try req.parameters.next(User.self)
      .flatMap { targetedUser in
        return try self.assets(req, for: targetedUser)
    }
  }

  /// User's scores listing throught /users/:id/scores
  public func scoresAPI(_ req: Request) throws -> Future<[Score]> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEP /users/:id/scores ## Listing scores of a given user")
    // decode request parameter (/users/:id)
    return try req.parameters.next(User.self)
      .flatMap { targetedUser in
        return try self.scores(req, for: targetedUser)
    }
  }


}

/// - MARK - USER LOOK UP
extension UserFetchController {
  
  public func lookupUsers(_ req: Request, of: User? = nil) throws -> Future<[User.QuickSearch]> {
    let logger = try  req.make(Logger.self)
    logger.info(req.http.debugDescription)
    let user = try UserController.logged(req)
    logger.info("Getting User search initiated by \(user.id!) (\(user.login))")
    let meta = PageMeta(req)
    var qry = ""
    if let qsrch = try? req.query.get(String.self, at: Config.SearchEngine.paramsQuery) {
      qry = "%"+qsrch+"%"
    }
    if qry.isEmpty {
      return req.future([])
    }
    if user.staff.staff.isAdministrator || user.staff.staff.isBigBrother {
      let usersBuild = User.query(on: req)
        .join(\Contact.id, to: \User.profileID).alsoDecode(Contact.self)
        .group(.or) {
          $0.filter(User.SearchField.login,        .ilike, qry)
            .filter(User.SearchField.email,        .ilike, qry)
            .filter(User.SearchField.orgUserRef,   .ilike, qry)
            .filter(User.SearchField.ref,          .ilike, qry)
            .filter(User.SearchField.nickname,  .ilike, qry)
            .filter(User.SearchField.givenName, .ilike, qry)
            .filter(User.SearchField.familyName,      .ilike, qry)
            .filter(User.SearchField.departmentName,  .ilike, qry)
            .filter(User.SearchField.jobTitle,        .ilike, qry)
            .filter(User.SearchField.middleName,      .ilike, qry)
      }
      .group(.or){
        $0.filter(\User.deletedAt, .equal, nil)
          .filter(\User.deletedAt, .greaterThan, Date())
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
    AND
    ( "user"."deletedAt" IS NULL OR "user"."deletedAt" > NOW() )
    """
    return req.withNewConnection(to: .psql) { $0.raw( query ).all(decoding: User.QuickSearch.self) }
    
  }
  
}

/// - MARK - USERS ROUTES
extension UserFetchController: RouteCollection {
  public func boot(router: Router) throws {
    // bearer / token auth protected routes
    let bearer = router.grouped(User.tokenAuthMiddleware())
    /**
     ** Logged User end point api spec - 1
     */
    let accoundGroup = bearer.grouped(Config.APIWEP.accountWEP)
    accoundGroup.get(use: account(_:)) // The logged user account's informations
    accoundGroup.get(Config.APIWEP.showWEP, use: showAccoundAPI(_:)) // Logged user information
    accoundGroup.get(Config.APIWEP.profilesWEP, use: profileAccountAPI(_:)) // My profiles
    accoundGroup.get(Config.APIWEP.servicesWEP, use: servicesAccountAPI(_:)) // Attached Services
    accoundGroup.get(Config.APIWEP.ordersWEP, use:  ordersAccountAPI(_:)) // Every order passed (could be multiple by contract)
    accoundGroup.get(Config.APIWEP.organizationsWEP, use: organizationsAccountAPI(_:)) // Attached organzation even as a client
    accoundGroup.get(Config.APIWEP.schedulesWEP, use:  schedulesAccountAPI(_:)) // Schedule I programmed
    accoundGroup.get(Config.APIWEP.assetsWEP, use:  assetsAccountAPI(_:)) // Assets I configured
//    accoundGroup.get(Config.APIWEP.activitiesWEP, use:  delete(_:)) // Activities I configured
    accoundGroup.get(Config.APIWEP.placesWEP, use: delete(_:)) // Places I submited
    accoundGroup.get(Config.APIWEP.devisWEP, use:  delete(_:)) // Every devis passed
    accoundGroup.get(Config.APIWEP.contractsWEP, use: delete(_:)) // Every contract signed
    accoundGroup.get(Config.APIWEP.billingsWEP, use:  delete(_:)) // Programmed and already passed billing
    accoundGroup.get(Config.APIWEP.cardsWEP, use:  delete(_:))  //
    accoundGroup.get(Config.APIWEP.teamsWEP, use: delete(_:)) // Attached teams (organizations where I work)
    accoundGroup.get(Config.APIWEP.paymentsWEP, use:  delete(_:)) // Registered payment method
    accoundGroup.get(Config.APIWEP.loginsWEP, use:  delete(_:)) // Log in history
    accoundGroup.get(Config.APIWEP.scoresWEP, use:  scoresAccountAPI(_:)) // Every notation I made
    accoundGroup.get(Config.APIWEP.commentsWEP, use:  scoresAccountAPI(_:)) // Every comment I made
    accoundGroup.get(Config.APIWEP.feedbacksWEP, use:  delete(_:)) // Every feed back I made
    
    let lookupGroup   = accoundGroup.grouped(Config.APIWEP.lookupWEP)
    lookupGroup.get(Config.APIWEP.usersWEP, use: { try self.lookupUsers($0) })  // lookup users through logged user scope
    lookupGroup.get(Config.APIWEP.organizationsWEP, use: delete(_:)) // lookup organizations through logged user scope
    lookupGroup.get(Config.APIWEP.servicesWEP, use: delete(_:)) // lookup services through logged user scope
    lookupGroup.get(Config.APIWEP.schedulesWEP, use: delete(_:)) // lookup schedules through logged user scope
    lookupGroup.get(Config.APIWEP.placesWEP, use: delete(_:)) // lookup places through logged user scope
    lookupGroup.get(Config.APIWEP.activitiesWEP, use: delete(_:)) // lookup activities through logged user scope
    lookupGroup.get(Config.APIWEP.ordersWEP, use: delete(_:)) // lookup orders through logged user scope
    
    let usersGroup = bearer.grouped(Config.APIWEP.usersWEP)
    usersGroup.get(use: list(_:)) // The user list
    usersGroup.get(User.parameter, use: showAPI(_:)) // get user's informations
    usersGroup.get(User.parameter, Config.APIWEP.profilesWEP, use: profileAPI(_:)) // A profile
    usersGroup.get(User.parameter, Config.APIWEP.servicesWEP, use: servicesAPI(_:))
    usersGroup.get(User.parameter, Config.APIWEP.ordersWEP, use:  ordersAPI(_:)) // Every order passed (could be multiple by contract)
    usersGroup.get(User.parameter, Config.APIWEP.organizationsWEP, use:  organizationsAPI(_:)) // Attached organzation even as a client
    usersGroup.get(User.parameter, Config.APIWEP.schedulesWEP, use:  schedulesAPI(_:)) // Schedule I programmed
    usersGroup.get(User.parameter, Config.APIWEP.assetsWEP, use:  assetsAPI(_:)) // Assets configured
//    usersGroup.get(User.parameter, Config.APIWEP.activitiesWEP, use:  delete(_:)) // Activities configured
    
    usersGroup.get(User.parameter, Config.APIWEP.placesWEP, use: delete(_:)) // Places submited
    usersGroup.get(User.parameter, Config.APIWEP.devisWEP, use:  delete(_:)) // Every devis passed
    usersGroup.get(User.parameter, Config.APIWEP.contractsWEP, use: delete(_:)) // Every contract signed
    usersGroup.get(User.parameter, Config.APIWEP.billingsWEP, use:  delete(_:)) // Programmed and already passed billing
    usersGroup.get(User.parameter, Config.APIWEP.cardsWEP, use:  delete(_:))  //
    usersGroup.get(User.parameter, Config.APIWEP.teamsWEP, use: delete(_:)) // Attached teams (organizations where I work)
    usersGroup.get(User.parameter, Config.APIWEP.paymentsWEP, use:  delete(_:)) // Registered payment method
    usersGroup.get(User.parameter, Config.APIWEP.loginsWEP, use:  delete(_:)) // Log in history
    usersGroup.get(User.parameter, Config.APIWEP.scoresWEP, use:  scoresAPI(_:)) // Every notation I made
    usersGroup.get(User.parameter, Config.APIWEP.commentsWEP, use:  scoresAPI(_:)) // Every comment I made
    usersGroup.get(User.parameter, Config.APIWEP.feedbacksWEP, use:  delete(_:)) // Every feed back I made
    
  }
  
  
}
