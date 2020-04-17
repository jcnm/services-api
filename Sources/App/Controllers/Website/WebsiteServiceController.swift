//
//  WebsiteServiceController.swift
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
final class WebsiteServiceController {
  let userControl: UserController         = UserController()
  let serviceControl: ServiceController      = ServiceController()
  
  public static func fillMetaServEdition(_ meta: inout PageMeta) {
    meta.namedData["serviceBillingPlan"] = []
    for bp in BillingPlan.allCases {
      meta.namedData["serviceBillingPlan"]!.append(LabeledValue<String>(label: String(bp.rawValue), value: bp.textual))
    }
    meta.namedData["serviceTarget"] = []
    for st in ServiceTarget.allCases {
      meta.namedData["serviceTarget"]!.append(LabeledValue<String>(label: String(st.rawValue), value: st.textual))
    }
  }
  
  func serviceList(_ req: Request) throws -> Future<View>  {
    let usr = try req.requireAuthenticated(User.self)
    let (meta, servs) = try ServiceController.list(req)
    var urls = UrlWebsite()
    urls.params = meta.params
    urls.root = "/services"
    urls.endUrl = "services"
    urls.breadcrumb["data"] = []
    if meta.params.count > 1 {
      urls.breadcrumb["data"]!.append(NamedEmail(label: "/services", value: "Services"))
    }
    if let qstr = meta.params[kNavigationQuery] {
      urls.breadcrumb["data"]!.append(NamedEmail(label: "/services?q=\(qstr)", value: "Recherche \(qstr)"))
    }
    
    if meta.params.count > 1 {
      urls.breadcrumb["data"]!.append(NamedEmail(label: "", value: "Liste filtré"))
    } else {
      urls.breadcrumb["data"]!.append(NamedEmail(label: "", value: "Liste des services"))
    }

    let user = WebsiteController.loggedFullUserInfos(req, of: usr)
    return user.flatMap{ u -> Future<View> in
      var context = Page<Service.FullPublicResponse>(meta: meta, url: urls, collection: nil, user: u)
      return servs.flatMap { (op) -> Future<View> in
        context.collection = op
        do {
          //      userInfos.merge([:]) { (k1, k2) -> Any in return k2 }
          WebsiteOrganizationController.fillMetaOrgEdition( &context.meta! )
          fillMetaBaseInfo( &context.meta! )

          //
          let ret = try req.view().render("services", context, userInfo: try op.userInfo())
          return ret
        } catch let err {
          let log = try req.make(Logger.self)
          log.error(err.localizedDescription)
          throw err
        }
      }
    }
  }
  
  func serviceShow(_ req: Request) throws -> Future<View>  {
    print(try req.hasSession())
    let user = try WebsiteController.loggedFullUserInfos(req)
    let logger = try  req.make(Logger.self)
    var urls = UrlWebsite()
    let (meta, service) = try self.serviceControl.show(req)
    urls.root = "/services"
    urls.endUrl = "service"
    urls.breadcrumb["data"] = []
    urls.breadcrumb["data"]!.append(NamedEmail(label:urls.root, value: "Services"))
    return user.flatMap{ usr -> Future<View> in
      logger.info("Showing Service initiated by \(usr.id) (\(usr.login))")
      return service.flatMap { (serv) -> Future<View> in
        urls.breadcrumb["data"]!.append(NamedEmail(label: "", value: serv.label))
        var context = Page<Service.FullPublicResponse>(meta: meta, url: urls, collection: nil, user: usr, data: serv)
        fillMetaBaseInfo( &context.meta! )

        logger.info("Showing Service context \(context)")
        return try req.view().render("service", context)
      }
    }
  }

  
  func devisView(_ req: Request) throws -> Future<View>  {
    let user = try WebsiteController.loggedFullUserInfos(req)
    let logger = try  req.make(Logger.self)
    let verb = req.http.method
    struct AddBasket: Content {
      let serviceID: Service.ID
    }
    
    switch verb {
      case .POST:
        
        let idServ = try? req.content.decode(AddBasket.self)
        return idServ!.flatMap({ (elfBask) -> EventLoopFuture<View> in

          var cook = HTTPCookieValue(string: "\(elfBask.serviceID)", expires: Date().addingTimeInterval(60 * 60 * 5), isSecure: false, isHTTPOnly: false, sameSite: nil)
          var urls = UrlWebsite()
          let services = try self.serviceControl.serviceFullResponseTree(req: req, elfBask.serviceID)
          let meta = PageMeta(req)
          urls.root = "/devis"
           urls.endUrl = "devis"
           urls.breadcrumb["data"] = []
           urls.breadcrumb["data"]!.append(NamedEmail(label:urls.root, value: "Devis"))
           return user.flatMap{ usr -> Future<View> in
             logger.info("Showing Service initiated by \(usr.id) (\(usr.login))")
             return services.flatMap { (servs) -> Future<View> in
              urls.breadcrumb["data"]!.append(NamedEmail(label: "", value: "Devis pour \(servs.first?.label)"))
              var context = Page<[Service.FullPublicResponse]>(meta: meta, url: urls, collection: nil, user: usr, data: servs )
               fillMetaBaseInfo( &context.meta! )
              let ck = req.http.cookies["services-devis-service-id"]
              if let c = ck, !c.string.components(separatedBy: ",").contains(cook.string) {
                cook.string = "\(c.string),\(cook.string)"
              }
              context.meta?.namedData["services_devis"] = [NamedEmail(label: "services-devis-service-id", value: cook.string)]

              let v = try req.view().render("pre_devis", context)
              return v

             }
           }

//          let cook = Cookie(name: "your_cookie_name",
//              value: elfBask.serviceID,
//              expires: Date().addingTimeInterval(60 * 60 * 5), // 5 hours
//              secure: true, httpOnly: true )
        })
      
      case .GET:
        print(req.http.body)
      return try req.view().render("basket")
      default:
      return try req.view().render("basket")
    }
   }

}

/**
 Service Controller for member dashboard logged users
 */
extension WebsiteServiceController {
  
  func accountServiceList(_ req: Request) throws -> Future<View>  {
    let usr = try req.requireAuthenticated(User.self)
    let (meta, servs) = try ServiceController.list(req, of: usr)
    var urls = UrlWebsite()
    urls.params = meta.params
    urls.root = "/account/services"
    urls.endUrl = "services"
    urls.breadcrumb["data"] = []
    urls.breadcrumb["data"]!.append(NamedEmail(label:"/account", value: "Compte"))
    urls.breadcrumb["data"]!.append(NamedEmail(label: "", value: "Liste mes services"))
    
    let user = WebsiteController.loggedFullUserInfos(req, of: usr)
    return user.flatMap{ u -> Future<View> in
      var context = Page<Service.FullPublicResponse>(meta: meta, url: urls, collection: nil, user: u)
      return servs.flatMap { (op) -> Future<View> in
        context.collection = op
        do {
          //      userInfos.merge([:]) { (k1, k2) -> Any in return k2 }
          WebsiteOrganizationController.fillMetaOrgEdition( &context.meta! )
          fillMetaBaseInfo( &context.meta! )
          //
          let ret = try req.view().render("users/account_services", context, userInfo: try op.userInfo())
          return ret
        } catch let err {
          let log = try req.make(Logger.self)
          log.error(err.localizedDescription)
          throw err
        }
      }
    }
  }
  
  func accountServiceNew(_ req: Request) throws -> Future<Response>  {
    let user = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Service creation initiated by \(user.id!) (\(user.login))")
    let service = try serviceControl.create(req)
    return service.map{ serv -> Response in
      logger.info("Service creation succed \(String(describing: serv.label)))")
      let ret = req.redirect(to: "/account/organizations/\(serv.organizationID)")
      return ret
    }
    
  }
  
  func accountServiceUpdate(_ req: Request) throws -> Future<View>  {
    let user = try WebsiteController.loggedFullUserInfos(req)
    let logger = try  req.make(Logger.self)
    var urls = UrlWebsite()
    let (meta, service) = try self.serviceControl.show(req)
    urls.root = "/account/services"
    urls.endUrl = "service"
    urls.breadcrumb["data"] = []
    urls.breadcrumb["data"]!.append(NamedEmail(label:"/account", value: "Compte"))
    urls.breadcrumb["data"]!.append(NamedEmail(label:urls.root, value: "Services"))
    return user.flatMap{ usr -> Future<View> in
      
      logger.info("Showing Service initiated by \(usr.id) (\(usr.login))")
      return service.flatMap { (serv) -> Future<View> in
        urls.breadcrumb["data"]!.append(NamedEmail(label: urls.root + "/\(serv.id!)", value: serv.label))
        
        urls.breadcrumb["data"]!.append(NamedEmail(label: "", value: "Mise à jour"))
        var context = Page<Service.FullPublicResponse>(meta: meta, url: urls, collection: nil, user: usr, data: serv)
         WebsiteOrganizationController.fillMetaOrgEdition( &context.meta! )
        fillMetaBaseInfo( &context.meta! )

        logger.info("Showing Service context \(context)")
        return try req.view().render("users/account_service", context)
      }
    }
  }
  
  func accountServiceDelete(_ req: Request) throws -> Future<View>  {
    
    let ret = try req.view().render("users/account_organizations" )
    return ret
    
    
  }
  
  func accountServiceShow(_ req: Request) throws -> Future<View>  {
    print(try req.hasSession())
    let user = try WebsiteController.loggedFullUserInfos(req)
    let logger = try  req.make(Logger.self)
    var urls = UrlWebsite()
    let (meta, service) = try self.serviceControl.show(req)
    urls.root = "/account/services"
    urls.endUrl = "service"
    urls.breadcrumb["data"] = []
    urls.breadcrumb["data"]!.append(NamedEmail(label:"/account", value: "Compte"))
    urls.breadcrumb["data"]!.append(NamedEmail(label:urls.root, value: "Services"))
    return user.flatMap{ usr -> Future<View> in
      logger.info("Showing Service initiated by \(usr.id) (\(usr.login))")
      return service.flatMap { (serv) -> Future<View> in
        urls.breadcrumb["data"]!.append(NamedEmail(label: "", value: serv.label))
        var context = Page<Service.FullPublicResponse>(meta: meta, url: urls, collection: nil, user: usr, data: serv)
        WebsiteOrganizationController.fillMetaOrgEdition( &context.meta! )
        fillMetaBaseInfo( &context.meta! )

        logger.info("Showing Service context \(context)")
        return try req.view().render("users/account_service", context)
      }
    }
  }

}

/// - MARK - WEBSITE USER DASHBOARD ROUTES
extension WebsiteServiceController: RouteCollection {
  func boot(router: Router) throws {
    /*************************** PUBLIC SECTION *************************
     ***
     *******************************************************************/
    /** Public user end point api spec */
    // Creation of a new version
    
    let authSessionRouter     = router.grouped(User.authSessionsMiddleware())
    let accountGroup          = authSessionRouter.grouped(kAccountBasePath)
    let servicesGroup         = authSessionRouter.grouped(kServicesBasePath)
    let servicesAccountGroup  = accountGroup.grouped(kServicesBasePath)

    /// Service account
    servicesAccountGroup.get(use: accountServiceList)
    servicesAccountGroup.post(use: accountServiceNew)
    servicesAccountGroup.get(Service.parameter, use: accountServiceShow)
    servicesAccountGroup.post(Service.parameter, "edit", use: accountServiceUpdate)
    servicesAccountGroup.get(Service.parameter, "edit", use: accountServiceUpdate)
    servicesAccountGroup.get(Service.parameter, "delete", use: accountServiceDelete)
    /// Service
    servicesGroup.get(use: serviceList)
    servicesGroup.get(Service.parameter, use: serviceShow)
    
    /// Global
    authSessionRouter.get(kDevisBasePath, use: devisView)
    authSessionRouter.post(kDevisBasePath, use: devisView)

  }
}




