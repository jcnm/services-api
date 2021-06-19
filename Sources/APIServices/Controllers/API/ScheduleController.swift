//
//  ScheduleController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 25/02/2020.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication
import Paginator

/// - MARK - CREATE Service
public final class ScheduleController {
  
  public init() { }

  public func create(_ req: Request) throws -> Future<Schedule.FullPublicResponse> {
    let user = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Schedule creation initiated by \(user.id!) (\(user.login))")
    // TODO CHECK CREATION RIGHT for user
    // decode request content
    return try req.content.decode(Schedule.CreateSchedule.self).flatMap
      { sche -> Future<Schedule.FullPublicResponse> in
        logger.info("Schedule creation information got for service ID : \(sche.serviceID)")
        let schedule = Schedule(label: sche.label, owner: sche.ownerID, service: sche.serviceID, state: ObjectStatus.defaultValue, orgRefA: sche.orgScheduleARef)
        return schedule.create(on: req)
          .flatMap { (sch) -> Future<Schedule.FullPublicResponse> in
          let serv = sch.service.get(on: req)
            return serv.map { (service) -> Schedule.FullPublicResponse in
                        logger.info("Schedule saved for serviceID : \(sch.serviceID) - Owner ID: \(sch.ownerID) (\(user.login))")
              return sch.fullResponse(user: user.shortResponse(), service: service.shortResponse())

            }
        }
    }
  }
}

/// - MARK - UPDATE Service
extension ScheduleController {
  public func update(_ req: Request) throws -> Future<Schedule.MidPublicResponse> {
    let user = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Schedule update initiated by \(user.id!) (\(user.login))")
    return try req.parameters.next(Schedule.self).flatMap
      { schToUpdate -> Future<Schedule.MidPublicResponse> in
        logger.info("Schedule to update decoded. Schedule \(schToUpdate.id!) (\(String(describing: schToUpdate.label)))")
        // decode request content
        return try req.content.decode(Schedule.UpdateSchedule.self).flatMap
          { uSch -> Future<Schedule.MidPublicResponse> in
            logger.info("Schedule to update values decoded. as \(uSch.id!) (\(String(describing: uSch.label)))")

            // verify that the service is well sharped
            guard try uSch.id == schToUpdate.requireID() else {
              throw Abort(HTTPResponseStatus.badRequest)
            }
            schToUpdate.label       = uSch.label
            schToUpdate.state     = uSch.state
            schToUpdate.ownerID       = uSch.ownerID
            schToUpdate.orgScheduleARef  = uSch.orgScheduleARef
            schToUpdate.orgScheduleBRef  = uSch.orgScheduleBRef
            schToUpdate.serviceID    = uSch.serviceID
            schToUpdate.description = uSch.description
            schToUpdate.updatedAt = Date()
            
            return schToUpdate.update(on: req).map { (sch) -> (Schedule.MidPublicResponse) in
              let midResp = sch.midResponse(user: user.shortResponse())
              logger.info("Schedule updated as mid format : {\(midResp)}")
              return midResp
            }
        }
    }
  }
}

/// - MARK - GET  Service
extension ScheduleController {
  
  /**
   *
   */
  public func show(_ req: Request) throws -> Future<Schedule.FullPublicResponse> {
    let user = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Schedule show initiated by \(user.id!) (\(user.login))")
    return try req.parameters.next(Schedule.self).flatMap
      { sche -> Future<Schedule.FullPublicResponse> in
        
        let serv = sche.service.get(on: req)
        let owner = sche.owner.get(on: req)
        return serv.and(owner).flatMap { (serv, usr) -> Future<Schedule.FullPublicResponse> in
          logger.info("Schedule informations retrieves - service ID \(serv.id!) and owner ID \(usr.id!) (\(usr.login))")
          var fullResp = sche.fullResponse(user: user.shortResponse(), service: serv.shortResponse())
          return try sche.activities.query(on: req).all().map { (actis) -> Schedule.FullPublicResponse in
            logger.debug("Setting activities (\(actis.count)) for the schedule \(sche.id!) \(String(describing: sche.label))")
            fullResp.activities = actis
            return fullResp
          }
        }
    }
  }
  
  /**
   *
   */
  public func scheduleOfActivity(_ req: Request) throws -> Future<Schedule> {
    let _ = try UserController.logged(req)
    return try req.parameters.next(Activity.self).flatMap
      { act -> Future<Schedule> in
        guard try act.requireID() != 0 else {
          throw Abort(HTTPResponseStatus.badRequest)
        }
        return act.schedule.get(on: req)
    }
  }
  
  /**
   *
   */
  public func list(_ req: Request) throws ->
    Future<OffsetPaginator<Schedule.FullPublicResponse>> {
    return try ScheduleController.list(req).1
  }
  
  /**
   * List Service for Leaf Views
   *
   */
  public func accountRelativeList(_ req: Request) throws -> Future<OffsetPaginator<Schedule.FullPublicResponse>> {
    let uAutth = try UserController.logged(req)
      return try ScheduleController.list(req, of: uAutth).1
  }

  /**
   *
   */
  public static func list(_ req: Request, of user: User? = nil) throws ->
    (PageMeta, Future<OffsetPaginator<Schedule.FullPublicResponse>>) {
    var qry: QueryBuilder<AdoptedDatabase, Schedule>;
    let logger = try req.make(Logger.self)
    var meta = PageMeta()
    meta.config(from: req)
    logger.debug("Schedule retrieving meta configured with : {\(meta)}")

    if let usr = user {
      logger.debug("Schedule retrieving of USER \(usr.id!) (\(usr.login))")
      qry = try usr.schedules.query(on: req)
      .join(\Service.id, to: \Schedule.serviceID, method: .default)
    } else {
      logger.debug("Schedule retrieving of on base data")
      qry = Schedule.query(on: req)
        .join(\User.id, to: \Schedule.ownerID, method: .default)
      .join(\Service.id, to: \Schedule.serviceID, method: .default)
      .filter(\Schedule.state == ObjectStatus.online.rawValue)
    }
    //    .alsoDecode(Service.self)

    if meta.service != -1 {
      qry = qry.filter(\Schedule.serviceID == meta.service)
      logger.debug("Schedule retrieving - apply service filter with value : Schedule.serviceID == {\(meta.service)}")
    }
    logger.info("Schedule retrieving filtering with configured meta")

    if let usr = user {
      let trans = try qry.alsoDecode(Service.self)
        .transform(on: req, { (obj: (Schedule, Service)) -> Schedule.FullPublicResponse in
        let schedule = obj.0
        let service = obj.1
        let publicResp = schedule.fullResponse(user: usr.shortResponse(), service: service.shortResponse())
        logger.info("Schedule retrieving query well transforming to \(publicResp)")
        return publicResp
      })
      logger.info("Schedule retrieving - returning pagination and meta ")
      return try (meta, trans.paginate(for: req, type: OffsetPaginator<Schedule.FullPublicResponse>.self))
    } else {
      
      let trans = try qry
        .alsoDecode(User.self)
      .alsoDecode(Service.self)
        .transform(on: req, { (obj: ((Schedule, User), Service)) -> Schedule.FullPublicResponse in
      let schedule = obj.0.0
      let user    = obj.0.1
      let service = obj.1
      let publicResp = schedule.fullResponse(user: user.shortResponse(), service: service.shortResponse())
        return publicResp
    })
    return try (meta, trans.paginate(for: req, type: OffsetPaginator<Schedule.FullPublicResponse>.self))
    }
  }
}

/// - MARK - DELETE Service
extension ScheduleController {
  public func delete(_ req: Request) throws -> Future<Schedule> {
    let uAutth = try UserController.logged(req)
    // decode request parameter
    return try req.parameters.next(Schedule.self).flatMap
      { schdToUpdate -> Future<Schedule> in
        guard try uAutth.requireID() == schdToUpdate.ownerID else {
          throw Abort(HTTPResponseStatus.forbidden)
        }
        schdToUpdate.deletedAt   = Date()
        schdToUpdate.state       = ObjectStatus.offline.rawValue
        // TODO Update historic trace
        return schdToUpdate.update(on: req)
    }
  }
}


extension ScheduleController: RouteCollection {
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
    let scheduleGroup      = bearer.grouped(Config.APIWEP.schedulesWEP)
    let scheduleAccountGroup      = bearer.grouped(Config.APIWEP.accountWEP, Config.APIWEP.schedulesWEP)
    scheduleGroup.get(use: list)
    scheduleAccountGroup.get(use: accountRelativeList)
    scheduleGroup.get(Schedule.parameter, Config.APIWEP.industriesWEP, use: scheduleOfActivity)
    scheduleGroup.post(use: create)
    scheduleGroup.get(Schedule.parameter, use: show)
    scheduleGroup.patch(Schedule.parameter, use: update)
    scheduleGroup.delete(Schedule.parameter, use: delete)
  }
  
  
}
