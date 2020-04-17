//
//  WebsiteController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 26/11/2019.
//
    
import Foundation
import Vapor
import FluentSQLite
import Authentication
import Leaf
import Paginator

let kWebBasePath        = ""
/// - MARK - ROUTER Website
final class WebsiteController {
  
  var userControl: UserController = UserController()
  
  public static func loggedFullUserInfos(_ req: Request) throws -> Future<User.FullLoggedResponse> {
    let u = try UserController.logged(req)
    return loggedFullUserInfos(req, of: u)
  }
  
  public static func loggedFullUserInfos(_ req: Request, of: User) -> Future<User.FullLoggedResponse> {
       let authTokens = try? of.authTokens.query(on: req).all()
    if let authToks = authTokens {
      return authToks.flatMap { (tokens: [User.TokenType])  in
         guard tokens.count > 0 else {
           throw Abort(.unauthorized)
         }
         let token = tokens.last!
         return of.fullLoggedResponse(req, token)
       }
    }
    return req.future(User.FullLoggedResponse.skeletonObject())
  }

  /// Index page
  func indexHandler(_ req: Request) throws -> Future<View> {
    let (meta, sers) = try ServiceController.indexList(req)
    return sers.flatMap(to: View.self) { paginatorServices in
      do {
        //          userInfos.merge(try services.userInfo()) { (k1, k2) -> Any in return k2 }
        if let usr = try? WebsiteController.loggedFullUserInfos(req) {
          return usr.flatMap{ u -> Future<View> in
              let page = Page<Service.FullPublicResponse>(meta: meta, collection: paginatorServices, user: u)
            print(page)
              return try req.view().render("index", page, userInfo: try paginatorServices.userInfo())
          }
        } else {
          let page = Page<Service.FullPublicResponse>(meta: meta, collection: paginatorServices, user: nil)
          print(page)
          return try req.view().render("index", page, userInfo: try paginatorServices.userInfo())
        }
      }
    }
  }
  
}


/// - MARK - WEBSITE ROUTES
extension WebsiteController: RouteCollection {
  func boot(router: Router) throws {
    /*************************** PUBLIC SECTION *************************
     ***
     *******************************************************************/
    /** Public user end point api spec */
    // Creation of a new version
    
    let authSessionRouter = router.grouped(User.authSessionsMiddleware())
    authSessionRouter.get(kWebBasePath, use: indexHandler)
    
    //    let bearer = router.grouped(User.tokenAuthMiddleware())
    //    bearer.post(kVersionsBasePath, use: create)
    
  }
}




