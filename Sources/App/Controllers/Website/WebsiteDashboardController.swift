//
//  WebsiteDashboardController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 26/11/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication
import Leaf
import Paginator
import Validation

let kWebUserDashboardBasePath        = kAccountBasePath
/// - MARK - ROUTER Website
final class WebsiteDashboardController {
  var userControl: UserController = UserController()

  func checkoutHandler(_ req: Request) throws -> Future<View>  {
    print("Login by session - checkoupHandler")
    print(req)
    let ses = try req.session()
    print("Actual SESSION")
    print(ses.data)
    print(try req.hasSession())
    print("Trying to auth user from session")
    let user = try WebsiteController.loggedFullUserInfos(req)
    return user.flatMap{ u -> Future<View> in
      let context = Page<OrderItem>(meta: nil, collection: nil, user: u)
      do {
        //      userInfos.merge([:]) { (k1, k2) -> Any in return k2 }
        let ret = try req.view().render("checkout", context)
        return ret
      } catch let err {
        let log = try req.make(Logger.self)
        log.error(err.localizedDescription)
        throw err
      }
    }
  }
  
  /// Dashoard of connected users
  func account(_ req: Request) throws -> Future<View>  {
    print(try req.hasSession())
    print("Trying to auth user from session")
    let logger = try req.make(Logger.self)
    var urls = UrlWebsite()
    urls.root = "/account"
    urls.endUrl = "/"
    let user = try WebsiteController.loggedFullUserInfos(req)
    return user.flatMap{ u -> Future<View> in
      let context = Page<Organization.FullPublicResponse>(meta: nil, url: urls, collection: nil, user: u)
      do {
        //      userInfos.merge([:]) { (k1, k2) -> Any in return k2 }
        let ret = try req.view().render("users/account", context)
        return ret
      } catch let err {
        let log = try req.make(Logger.self)
        log.error(err.localizedDescription)
        throw err
      }
    }
  }
  
  func accountDetails(_ req: Request) throws -> Future<View>  {
    let user = try WebsiteController.loggedFullUserInfos(req)
    let logger = try req.make(Logger.self)
    var urls = UrlWebsite()
    urls.root = "/account/details"
    urls.endUrl = "details"
    return user.flatMap{ u -> Future<View> in
      logger.info("Account details initiated by \(u.id) (\(u.login))")
      let context = Page<Organization.FullPublicResponse>(meta: nil, url: urls, collection: nil, user:         u)
      do {
        //      userInfos.merge([:]) { (k1, k2) -> Any in return k2 }
        let ret = try req.view().render("users/account_details", context)
        return ret
      } catch let err {
        let log = try req.make(Logger.self)
        log.error(err.localizedDescription)
        throw err
      }
    }
  }
  
  func accountParams(_ req: Request) throws -> Future<View>  {
    print(try req.hasSession())
    print("Trying to auth user from session")
    //    var meta = PageMeta()
    let logger = try req.make(Logger.self)
    var urls = UrlWebsite()
    urls.root = "/account/details"
    urls.endUrl = "details"
    urls.breadcrumb["data"] = []
    urls.breadcrumb["data"]!.append(NamedEmail(label:"/account", value: "Compte"))
    urls.breadcrumb["data"]!.append(NamedEmail(label:"", value: "Details"))

    let user = try WebsiteController.loggedFullUserInfos(req)
    return user.flatMap{ u -> Future<View> in
      let context = Page<Organization.FullPublicResponse>(meta: nil, url: urls, collection: nil, user:         u)
      do {
        //      userInfos.merge([:]) { (k1, k2) -> Any in return k2 }
        let ret = try req.view().render("users/account_params", context)
        return ret
      } catch let err {
        let log = try req.make(Logger.self)
        log.error(err.localizedDescription)
        throw err
      }
    }
  }
}


/// - MARK - WEBSITE  DASHBOARD ROUTES
extension WebsiteDashboardController: RouteCollection {
  func boot(router: Router) throws {
    /*************************** PUBLIC SECTION *************************
     ***
     *******************************************************************/
    /** Public user end point api spec */
    // Creation of a new version
    
    let authSessionRouter = router.grouped(User.authSessionsMiddleware())
    
    authSessionRouter.get("checkout", use: checkoutHandler)

    /// Dashboard account page
    authSessionRouter.get(kAccountBasePath, "", use: account)
    
    /// Details account page
    authSessionRouter.get(kAccountBasePath, "details", use: accountDetails)
    /// Parameters account page
    authSessionRouter.get(kAccountBasePath, "params", use: accountParams)
    
    //    let bearer = router.grouped(User.tokenAuthMiddleware())
    //    bearer.post(kVersionsBasePath, use: create)
    
  }
}




