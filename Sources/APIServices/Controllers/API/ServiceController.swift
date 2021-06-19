
//
//  ServiceController.swift
//
//
//  Created by Jacques Charles NJANDA MBIADA on 16/11/2019.
//

import Foundation
import Vapor
import Fluent
import Authentication
//import SwifQL
//import SwifQLVapor

/// - MARK - CREATE Service
public final class ServiceController {
  
  public init() { }

  public func create(_ req: Request) throws -> Future<Service.ShortPublicResponse> {
    let user = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Service create initiated by \(user.id!) (\(user.login))")
    print(req.http.headers)
    print(req.http.body)
    let serviceCS = try req.content.decode(Service.CreateService.self)
    return serviceCS.flatMap { (scs) -> Future<Service.ShortPublicResponse> in
      logger.info("Service content decoded \(scs.shortLabel)")
      let giventAuthor = scs.userID
      print(scs)
      // XXXX
      // TODO: Control upon connected user and right to create a service for the giventAuthor
      // TODO control if connected user has right to create service on this organization
      
      return User.find(giventAuthor, on: req)
        .flatMap{ usr -> Future<Service.ShortPublicResponse> in
          let dateForm = DateFormatter()
          dateForm.dateFormat = "yyyy-MM-dd"
          let servStart = dateForm.date(from: scs.serviceOpenedAt ?? "") ?? Date()
          let servEnd = dateForm.date(from: scs.serviceEndedAt ?? "")
          let freeServ = nil != scs.freeService ? (scs.freeService! == "on" ? true : false) : false
          let negServ = nil != scs.freeService ? (scs.freeService! == "on" ? true : false) : false
          let service =
            Service(label: scs.label, billing: scs.billingMode, description: scs.description, industry: scs.industryID, price: Float(scs.price + ".99"), shortLabel: scs.shortLabel, organization: scs.organizationID, author: scs.userID, parent: scs.parentID, orgServiceRef: scs.orgServiceRef,
                    nobillable: freeServ, negotiable: negServ, address: scs.address, locationID: nil, geoPerimeter: scs.activityPerimeter ?? 1,
                    openOn: servStart, endOn: servEnd, createdAt: Date(), updatedAt: nil, deletedAt: nil, id: nil)
          return service.createOverload(on: req).map { (serv) -> Service.ShortPublicResponse in
            return serv.shortResponse()
          }
      }
    }
  }
}


/// - MARK - DELETE Service
extension ServiceController {
  public func delete(_ req: Request) throws -> Future<Service> {
    let uAuth = try UserController.logged(req)
    let logger = try  req.make(Logger.self)
    logger.info("Deleting Service initiated by \(uAuth.id!) (\(uAuth.login))")
    // decode request parameter
    return try req.parameters.next(Service.self).flatMap
      { servToUpdate -> Future<Service> in
        guard try uAuth.requireID() == servToUpdate.authorID else {
          throw Abort(HTTPResponseStatus.forbidden)
        }
        
        servToUpdate.deletedAt  = Date()
        servToUpdate.status     = ObjectStatus.offline.rawValue
        // TODO Update historic trace
        return servToUpdate.update(on: req).catch { (err) in
          logger.info("Deleting Service \(servToUpdate.id!) failed ")
          logger.error("Deleting Service ERROR {\(err)}")
        }
    }.do{ (serv) in
      _ = try? serv.schedules.query(on: req).all()
        .map { schedules -> (Void) in
          let delDate             = Date()
          _ = schedules.map { (schd) -> Void in
            schd.deletedAt    = delDate
            schd.state        = ObjectStatus.offline.rawValue
            schd.update(on: req).do{ (sch) in
              logger.error("Deleting Schedule {\(sch.id!)} attached to the service  {\(sch.serviceID)} succeded")
            }.catch { (err) in
              logger.info("Deleting Schedules attached to the service \(serv.id!) in error")
              logger.error("Deleting Schedules attached to the service ERROR {\(err)}")
            }
          }
      }.catch { (err) in
        logger.info("Deleting Schedules attached to the service \(serv.id!) in error")
        logger.error("Deleting Schedules attached to the service ERROR {\(err)}")
      }
      
    }
  }
  
}

/// - MARK - WEBSITE USER DASHBOARD ROUTES
extension ServiceController: RouteCollection {
  public func boot(router: Router) throws {
    /*************************** PUBLIC SECTION *************************
     ***
     *******************************************************************/
    /** Public user end point api spec */
    // Creation of a new version
    
    let bearer                = router.grouped(User.tokenAuthMiddleware())
    let accountGroup          = bearer.grouped(Config.APIWEP.accountWEP)
    let servicesGroup         = bearer.grouped(Config.APIWEP.servicesWEP)
    let servicesAccountGroup  = accountGroup.grouped(Config.APIWEP.servicesWEP)

//    servicesGroup.get(use: list)
    servicesGroup.get(use: mainAPI)
    servicesAccountGroup.get(use: accountRelativeList)
    servicesAccountGroup.post(use: create)
    servicesAccountGroup.get(String.parameter, use: { try self.show($0).1 } )
    servicesAccountGroup.patch(Service.parameter, use: update)
    servicesAccountGroup.patch(Service.parameter, Config.APIWEP.industriesWEP, use: industryOfService)
    
  }
}
