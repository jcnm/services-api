//
//  ActivityController.swift
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
final class ActivityController {
  
  public func create(_ req: Request) throws -> Future<Activity.ShortPublicResponse> {
    let user = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Activity creation initiated by \(user.id!) (\(user.login))")
    // TODO CHECK CREATION RIGHT for user
    // decode request content
    return try req.content.decode(Activity.CreateActivity.self).flatMap
      { actCrea -> Future<Activity.ShortPublicResponse> in
        logger.info("Activity creation information gotten for schedule ID : \(actCrea.scheduleID)")
        let cost    = actCrea.cost ?? 1
        let fact    = actCrea.factor ?? 1
        let dateForm = DateFormatter()
        dateForm.dateFormat = "yyyy-MM-dd"

        let from    = actCrea.fromDate ?? ""
        let to      = actCrea.toDate ?? ""
        let actFrom = dateForm.date(from: from) ?? Date()
        let actTo = dateForm.date(from: to)

        return
          Activity(start: actCrea.startAt,
          duration: Activity.duration(startT: actCrea.startAt, endT: actCrea.endAt),
          dow: actCrea.dow, schedule: actCrea.scheduleID, fromDate: actFrom, toDate: actTo,
          title: actCrea.title, cost: cost, factor: fact)
            .create(on: req).map { (act) -> Activity.ShortPublicResponse in
                    logger.info("Activity saved for scheduleID : \(act.scheduleID) - new activity : \(act.id!)")
                    return act.shortResponse()
        }
    }
  }
}

/// - MARK - UPDATE Service
extension ActivityController {
  public func update(_ req: Request) throws -> Future<Activity.ShortPublicResponse> {
    let user = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Activity update initiated by \(user.id!) (\(user.login))")
    return try req.parameters.next(Activity.self).flatMap
      { actToUpdate -> Future<Activity.ShortPublicResponse> in
        logger.info("Activity to update decoded. Schedule \(actToUpdate.id!) (for schedule\(String(describing: actToUpdate.scheduleID)))")
        // decode request content
        return try req.content.decode(Activity.UpdateActivity.self).flatMap
          { uAct -> Future<Activity.ShortPublicResponse> in
            logger.info("Activity to update values decoded. as \(uAct.id) ")
            
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
              logger.info("Activity updated. see short format : {\(resp)}")
              return resp
            }
        }
    }
  }
}

/// - MARK - GET  Service
extension ActivityController {
  
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
        return serv.and(owner).map { (serv, usr) -> (Schedule.FullPublicResponse) in
          logger.info("Schedule informations retrieves - service ID \(serv.id!) and owner ID \(usr.id!) (\(usr.login))")
          return sche.fullResponse(user: usr.shortResponse(), service: serv.shortResponse())
        }
    }
  }
  
  
  /**
   *
   */
  public func list(_ req: Request) throws -> Future<OffsetPaginator<Service.FullPublicResponse>> {
    return try ServiceController.list(req).1
  }
  
  /**
   * List Service for Leaf Views
   *
   */
  public static func list(_ req: Request) throws -> (PageMeta, Future<OffsetPaginator<Activity.FullPublicResponse>>) {
    var meta = PageMeta()
    meta.config(from: req)
    let user = try UserController.logged(req)

    let logger = try req.make(Logger.self)
    logger.info("Activity listing initiated by \(user.id!) (\(user.login))")
    var qry = Activity.query(on: req)
      .join(\Schedule.id, to: \Service.industryID, method: .default)
      .alsoDecode(Schedule.self)
    logger.info("Activity listing querying ")
    
    if meta.schedule != -1 {
      qry = qry.filter(\Activity.scheduleID == meta.schedule)
      logger.debug("Activity listing filtering on schedule ID \(meta.schedule) ")
    }
    
    let trans = try qry
      .transform(on: req){ (obj: (Activity, Schedule)) -> Activity.FullPublicResponse in
        let activity = obj.0
        let schedule    = obj.1
        let publicResp = activity.fullResponse(schedule: schedule.shortResponse())
        logger.debug("Activity listing transformed to  {\(publicResp)}")
        return publicResp
    }
    let page = try trans.paginate(for: req, type: OffsetPaginator<Activity.FullPublicResponse>.self)
    logger.info("Activity listing returned ")
    return (meta, page)
    
  }
  
}

/// - MARK - DELETE Service
extension ActivityController {
  public func delete(_ req: Request) throws -> Future<Activity> {
    let uAuth = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Activity listing initiated by \(uAuth.id!) (\(uAuth.login))")
    // decode request parameter
    return try req.parameters.next(Activity.self).flatMap
      { actToUpdate -> Future<Activity> in
        actToUpdate.deletedAt   = Date()
        // TODO Update historic trace
        return actToUpdate.update(on: req)
    }
  }
}


extension ActivityController: RouteCollection {
  func boot(router: Router) throws {
    
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
    let activitiesGroup      = bearer.grouped(kActivitiesBasePath)
    activitiesGroup.get(use: list)
    activitiesGroup.post(use: create)
    activitiesGroup.get(Activity.parameter, use: show)
    activitiesGroup.patch(Activity.parameter, use: update)
    activitiesGroup.delete(Activity.parameter, use: delete)
  }
  
  
}
