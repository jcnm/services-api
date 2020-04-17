//
//  WebsiteOrganizationController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 05/01/2020.
//

import Foundation
import Vapor
import FluentSQLite
import Authentication
import Leaf
import Paginator

/// - MARK - ROUTER Website
final class WebsiteOrganizationController {
  
  var userControl: UserController = UserController()
  var orgControl: OrganizationController = OrganizationController()
  
  public static func fillMetaOrgEdition(_ meta: inout PageMeta) {
    meta.namedData["organizationGender"] = []
    for og in OrganizationGender.allCases {
      meta.namedData["organizationGender"]!.append(LabeledValue<String>(label: String(og.rawValue), value: og.textual()))
    }
    meta.namedData["roles"] = []
    for rol in RoleKind.allCases {
      meta.namedData["roles"]!.append(LabeledValue<String>(label: String(rol.rawValue), value: rol.textual))
    }
    
  }
  
  
  func accountOrganizationsList(_ req: Request) throws -> Future<View>  {
    let usr = try req.requireAuthenticated(User.self)
    let logger = try  req.make(Logger.self)
    let (meta, orgs) = try orgControl.organizationsOf(user: usr, req: req)
    var urls = UrlWebsite()
    let client = req.http.url
    print("\(client) \(req.http.url.absoluteString)")
    urls.params = meta.params
    urls.root = "/account/organizations"
    urls.endUrl = "organizations"
    urls.origin = req.http.url.absoluteString
    urls.breadcrumb["data"] = []
    urls.breadcrumb["data"]!.append(NamedEmail(label:"/account", value: "Compte"))
    urls.breadcrumb["data"]!.append(NamedEmail(label: "", value: "Liste de mes organisations"))
    
    let user = WebsiteController.loggedFullUserInfos(req, of: usr)
    return user.flatMap{ u -> Future<View> in
      let sectors = Sector.query(on: req).all().map{ return $0.map{return NamedEmail(label: String($0.id!), value: "\($0.title) - (\($0.nace) \($0.scian ?? "") \($0.citi ?? ""))")} }
      var context = Page<Organization.FullPublicResponse>(meta: meta, url: urls, collection: nil, user: u)
      let currens = Currency.query(on: req).all()
      return orgs.flatMap { (op) -> Future<View> in
        context.collection = op
        
        return sectors.and(currens).flatMap{ (dt, currencies) -> Future<View> in
          do {
            //      userInfos.merge([:]) { (k1, k2) -> Any in return k2 }
            context.meta!.namedData["sectors"] = dt
            WebsiteOrganizationController.fillMetaOrgEdition( &context.meta! )
            context.meta!.namedData["currencies"] = []
            for cur in currencies {
              context.meta!.namedData["currencies"]!.append(LabeledValue<String>(label: String(cur.code) , value: "\(cur.code) (\(cur.symbol)1 = US$\(cur.usd))"))
            }
            
            //
            //            print("Print context \(context)")
            let ret = try req.view().render("users/account_organizations", context, userInfo: try op.userInfo())
            return ret
          } catch let err {
            let log = try req.make(Logger.self)
            log.error(err.localizedDescription)
            throw err
          }
        }
      }
    }
  }
  
  func accountOrganizationNew(_ req: Request) throws -> Future<View>  {
    let logger = try  req.make(Logger.self)
    print(req)
    print("Trying to create new Organization")
    let usr = try req.requireAuthenticated(User.self)
    let user = WebsiteController.loggedFullUserInfos(req, of: usr)
    let re = try self.orgControl.create(req)
    
    return user.flatMap { u ->  Future<View> in
      re.flatMap { (orgFR) -> EventLoopFuture<View> in
        var urls = UrlWebsite()
        var meta = PageMeta(req)
        let client = req.http.url
        print("\(client) \(req.http.url.absoluteString)")
        urls.root = "/account/organizations"
        urls.endUrl = "organization"
        urls.origin = req.http.url.absoluteString
        urls.breadcrumb["data"] = []
        urls.breadcrumb["data"]!.append(NamedEmail(label:"/account", value: "Compte"))
        urls.breadcrumb["data"]!.append(NamedEmail(label: "/account/organizations", value: "Organisations"))
        urls.breadcrumb["data"]!.append(NamedEmail(label: "", value: orgFR.label))
        
        let context = Page<Organization.FullPublicResponse>(meta: meta, url: urls, collection: nil, user: u, data: orgFR)
        
        return try req.view().render("/users/account_organization", context)
      }
    }
  }
  
  
  func accountOrganizationAddMember(_ req: Request) throws -> Future<Response>  {
    let usr = try req.requireAuthenticated(User.self)
    let logger = try  req.make(Logger.self)
    let uorole = try orgControl.addMember(req)
    
    return uorole.map { (uo) throws -> Response in
      let ret = req.redirect(to: "/account/organizations/\(uo.organizationID)")
      return ret
    }
    
  }
  
  func accountOrganizationUpdate(_ req: Request) throws -> Future<View>  {
    let verb = req.http.method
    let logger = try  req.make(Logger.self)
    
    let ret = try req.view().render("users/account_organizations" )
    return ret
    
  }
  
  func accountOrganizationDelete(_ req: Request) throws -> Future<View>  {
    let logger = try  req.make(Logger.self)
    
    let ret = try req.view().render("users/account_organizations" )
    return ret
    
    
  }
  
  func accountOrganizationShow(_ req: Request) throws -> Future<View>  {
    let logger = try  req.make(Logger.self)
    print(try req.hasSession())
    print("Showin a full organization profile description")
    
    let verb = req.http.method
    var urls = UrlWebsite()
    urls.root = "/account/organizations"
    urls.endUrl = "organization"
    urls.breadcrumb["data"] = []
    urls.breadcrumb["data"]!.append(NamedEmail(label:"/account", value: "Compte"))
    urls.breadcrumb["data"]!.append(NamedEmail(label:urls.root, value: "Organisations"))
    let user = try WebsiteController.loggedFullUserInfos(req)
    let orgFR = try orgControl.show(req)          // Controller call
    return user.flatMap { u -> Future<View> in
      return orgFR.flatMap{(orga) -> Future<View> in
        urls.breadcrumb["data"]!.append(NamedEmail(label: "", value: orga.label))
        var meta = PageMeta(req)
        WebsiteOrganizationController.fillMetaOrgEdition(&meta)
        WebsiteServiceController.fillMetaServEdition(&meta)
        let currens = Currency.query(on: req).all()
        let indus = Industry.query(on: req)
        return indus
          .filter(\Industry.sectorID == orga.sectorID)
          .all().and(currens).flatMap{ (industries, currencies) -> Future<View> in
            meta.namedData["industries"] = []
            for ind in industries {
              meta.namedData["industries"]!.append(LabeledValue<String>(label: String(ind.id!), value: ind.title))
            }
            meta.namedData["currencies"] = []
            for cur in currencies {
              meta.namedData["currencies"]!.append(LabeledValue<String>(label: String(cur.code) , value: "\(cur.code) (\(cur.symbol)1 = US$\(cur.usd))"))
            }
            
            let context = Page<Organization.FullPublicResponse>(meta: meta, url:  urls, collection: nil, user: u, data: orga)
            return try req.view().render("users/account_organization", context)
        }
      }
    }
  }
}


/// - MARK - WEBSITE  Organizations ROUTES
extension WebsiteOrganizationController: RouteCollection {
  func boot(router: Router) throws {
    /*************************** PUBLIC SECTION *************************
     ***
     *******************************************************************/
    /** Public user end point api spec */
    // Creation of a new version
    
    let authSessionRouter = router.grouped(User.authSessionsMiddleware())
    let accountOrganizationRouter = authSessionRouter.grouped(kAccountBasePath, kOrganizationsBasePath)
    //    let organizationRouter = authSessionRouter.grouped(kOrganizationsBasePath)
    
    /// Organizations account
    accountOrganizationRouter.get(use: accountOrganizationsList)
    accountOrganizationRouter.get(Organization.parameter, use: accountOrganizationShow)
    accountOrganizationRouter.post("new", use: accountOrganizationNew)
    accountOrganizationRouter.post(Organization.parameter, "edit", use: accountOrganizationUpdate)
    accountOrganizationRouter.get(Organization.parameter, "delete", use: accountOrganizationDelete)
    accountOrganizationRouter.post(Organization.parameter, "members", use: accountOrganizationAddMember)
    
    
  }
}




