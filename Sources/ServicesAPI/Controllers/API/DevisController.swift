//
//  DevisController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 14/07/2020.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication
import Paginator

/// - MARK - CREATE Devis
public final class DevisController {
  var serviceController = ServiceController()
  
  public init() { }
  
  /// Creates a new devis API end point.
  public func createAPI(_ req: Request) throws -> Future<Devis.FullPublicResponse> {
    let user = try UserController.logged(req)
    let logger = try  req.make(Logger.self)
    logger.info("##API POST /devis ## Devis creation >>>")
    // decode request content
    return try req.content.decode(Devis.Create.self)
      .flatMap { cdevis -> Future<Devis.FullPublicResponse> in
        return try self.create(req, devis: cdevis, with: user)
    }
    
  }
  
  public func create(_ req: Request, devis: Devis.Create, with cuser: User) throws -> Future<Devis.FullPublicResponse> {
    let logger = try req.make(Logger.self)
    logger.info("++API Function ../ Devis creation initiated by \(cuser.id!) (\(cuser.login))")
    // TODO CHECK if this user hqs right to create devis for this organization
    // decode request content
    let cDevis = devis
    logger.info("Devis creation for service ID : \(cDevis.serviceID)")
    let orgaB  = Organization.find(cDevis.organizationID, on: req)
    let service  = Service.find(cDevis.serviceID, on: req)
    return service.and(orgaB).flatMap { (serv, orgb) -> EventLoopFuture<Devis.FullPublicResponse > in
      guard let ss = serv, let org = orgb else {
        throw Abort(HTTPResponseStatus.badRequest)
      }
      
      let orgaA = ss.organization.get(on: req)
      
      let label = cDevis.label.isEmpty ? "\(org.ref)" : cDevis.label
      let devis = Devis(author: cuser.id!, organization: cDevis.organizationID, label: label, service: cDevis.serviceID, status: ObjectStatus.defaultValue, price: cDevis.price, draft: 1)
      devis.scheduleID        = cDevis.appliedSchedule
      devis.activityID        = cDevis.appliedActivity
      devis.comment           = cDevis.comment
      devis.serviceFeePercent = serviceFeePercent(for: Int(ss.price! * 100.0)) // To compute
      devis.TVAPercent        = Int(cDevis.percentTVA * 100)
      devis.orgDevisARef      = cDevis.orgDevisARef
      devis.organizationID    = cDevis.organizationID
      return req.transaction(on: .psql) { (conn) -> Future<Devis.FullPublicResponse>  in
      return devis.create(on: req).flatMap
        { (dev) -> Future<Devis.FullPublicResponse> in
        _         = cDevis.idAsset.map { (sassLink, id) -> Future<DevisAsset> in
          return DevisAsset(devis: dev.id!, asset: id, saLink: sassLink,
                            initialQuantity: cDevis.initialQuantity[sassLink]!,
                            serviceID: cDevis.attachedService[sassLink]!,
                            quantity: cDevis.quantity[sassLink] ?? 0).create(on:req).catch { (err) in
            logger.error("Error creating devis \(dev.id!) - \(err.localizedDescription)")
          }
        }
        let ffullDevis          = try self.devis(req, id: dev.id!, slug: nil)
        return ffullDevis.and(orgaA).map { (dvis, org) -> (Devis.FullPublicResponse) in
          var fdevis            = dvis
          fdevis.organizationSs = org.shortResponse()
          return fdevis
          }
        }
      }
    }
  }
}

/// - MARK - UPDATE Devis
extension DevisController {
  public func update(_ req: Request) throws -> Future<Activity.ShortPublicResponse> {
    let user = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Devis update initiated by \(user.id!) (\(user.login))")
    return try req.parameters.next(Activity.self).flatMap
      { actToUpdate -> Future<Activity.ShortPublicResponse> in
        logger.info("Devis to update decoded. Schedule \(actToUpdate.id!) (for schedule\(String(describing: actToUpdate.scheduleID)))")
        // decode request content
        return try req.content.decode(Activity.UpdateActivity.self).flatMap
          { uAct -> Future<Activity.ShortPublicResponse> in
            logger.info("Devis to update values decoded. as \(uAct.id) ")
            
            // verify that the service is well sharped
            guard try uAct.id == actToUpdate.requireID() else {
              throw Abort(HTTPResponseStatus.badRequest)
            }
            let dateForm = DateFormatter()
            dateForm.dateFormat = "yyyy-MM-dd"
            let actStart = dateForm.date(from: uAct.fromDate)
            let actEnd = dateForm.date(from: uAct.toDate ?? "")
            
            actToUpdate.cost      = uAct.cost
            actToUpdate.dow       = uAct.dow
            actToUpdate.duration  = uAct.duration
            actToUpdate.factor    = uAct.factor
            actToUpdate.fromDate  = actStart ?? actToUpdate.fromDate
            actToUpdate.toDate    = actEnd
            actToUpdate.startAt   = uAct.startAt
            actToUpdate.title     = uAct.title
            actToUpdate.scheduleID  = uAct.scheduleID
            
            actToUpdate.updatedAt = Date()
            
            return actToUpdate.update(on: req).map { (act) -> (Activity.ShortPublicResponse) in
              let resp = act.shortResponse()
              logger.info("Devis updated. see short format : {\(resp)}")
              return resp
            }
        }
    }
  }
}
/// - MARK - DELETE Devis
extension DevisController {
  public func delete(_ req: Request) throws -> Future<Activity> {
    let uAuth = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Devis listing initiated by \(uAuth.id!) (\(uAuth.login))")
    // decode request parameter
    return try req.parameters.next(Activity.self).flatMap
      { actToUpdate -> Future<Activity> in
        actToUpdate.deletedAt   = Date()
        // TODO Update historic trace
        return actToUpdate.update(on: req)
    }
  }
}


extension DevisController: RouteCollection {
  public func boot(router: Router) throws {
    
    /*************************** LOGGED USER SECTION *******************
     ***
     ***
     ***
     *******************************************************************/
    
    // bearer / token auth protected routes
    let bearer = router.grouped(User.tokenAuthMiddleware())
    
    /**
     ** Logged User activity Sector - 2
     */
    let activitiesGroup      = bearer.grouped(Config.APIWEP.devisWEP)
    activitiesGroup.get(use: list)
    activitiesGroup.post(use: createAPI(_:))
    activitiesGroup.get(String.parameter, use: showAPI(_:))
    activitiesGroup.patch(String.parameter, use: update)
    activitiesGroup.delete(String.parameter, use: delete)
  }
  
  
}
