//
//  WebsiteScheduleController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 25/02/2020.
//

import Foundation
import Vapor
import FluentSQLite
import Authentication
import Leaf
import Paginator

/// - MARK - ROUTER Website
final class WebsiteScheduleController {
  var userControl: UserController = UserController()
  let scheduleControl = ScheduleController()
  let activityControl = ActivityController()
  
  public static func fillMetaScheduleEdition(_ meta: inout PageMeta) {
    meta.namedData["scheduleDow"] = []
    for bp in DayOfWeek.allCases {
      meta.namedData["scheduleDow"]!.append(LabeledValue<String>(label: String(bp.rawValue), value: bp.textual))
    }
    meta.namedData["scheduleState"] = []
    for st in ObjectStatus.allCases {
      meta.namedData["scheduleState"]!.append(LabeledValue<String>(label: String(st.rawValue), value: st.textual))
    }
  }
  
  func accountScheduleList(_ req: Request) throws -> Future<View>  {
    let usr = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Schedule list initiated by \(usr.id!) (\(usr.login))")
    
    let (meta, servs) = try ScheduleController.list(req, of: usr)
    var urls = UrlWebsite()
    urls.root = "/account/schedules"
    urls.endUrl = "schedules"
    urls.breadcrumb["data"] = []
    urls.breadcrumb["data"]!.append(NamedEmail(label:"/account", value: "Compte"))
    urls.breadcrumb["data"]!.append(NamedEmail(label:urls.root, value: "Planings"))
    urls.breadcrumb["data"]!.append(NamedEmail(label: "", value: "Liste mes plannings"))
    
    urls.params = meta.params
    let user = WebsiteController.loggedFullUserInfos(req, of: usr)
    return user.flatMap{ u -> Future<View> in
      return servs.flatMap { (op) -> Future<View> in
        var context = Page<Schedule.FullPublicResponse>(meta: meta, url: urls, collection: op, user: u)
          WebsiteOrganizationController.fillMetaOrgEdition( &context.meta! )
          //
          let ret = try req.view().render("users/account_schedules", context, userInfo: try op.userInfo())
          return ret
      }
    }
  }
  
  func accountScheduleShow(_ req: Request) throws -> Future<View>  {
    let user = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Activity Creation from schedule website controler initiated by \(user.id!) (\(user.login))")
    logger.debug("Activity Creation from from url [\(req.http.urlString)]")
    let userInfos = WebsiteController.loggedFullUserInfos(req, of: user)
    
    var urls = UrlWebsite()
    let schedule = try scheduleControl.show(req)
    urls.root = "/account/schedules"
    urls.endUrl = "schedule"
    urls.breadcrumb["data"] = []
    urls.breadcrumb["data"]!.append(NamedEmail(label:"/account", value: "Compte"))
    urls.breadcrumb["data"]!.append(NamedEmail(label:urls.root, value: "Plannings"))
    return userInfos.flatMap{ usr -> Future<View> in
      return schedule.flatMap { (sched) -> Future<View> in
        logger.info("Schedule retrieving succed \(sched.label ?? "Planning \(sched.ref)"))")
        urls.breadcrumb["data"]!.append(NamedEmail(label: "", value: sched.label ?? "Planning \(sched.ref)"))
        let context = Page<Schedule.FullPublicResponse>(meta: nil, url: urls, collection: nil, user: usr, data: sched)
        return try req.view().render("users/account_schedule", context)
        
      }
    }
  }

  func accountScheduleNew(_ req: Request) throws -> Future<Response>  {
    let user = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Schedule creation initiated by \(user.id!) (\(user.login))")
    // Call the API controller
    let schedule = try scheduleControl.create(req)
    return schedule.map{ sch -> Response in
      logger.info("Schedule creation succed \(String(describing: sch.label)))")
      let ret = req.redirect(to: "/account/services/\(sch.serviceID)")
      return ret
    }
  }
  
  func accountScheduleEdit(_ req: Request) throws -> Future<Response>  {
    let user = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Schedule edition initiated by \(user.id!) (\(user.login))")
    // Call the API controller
    let schedule = try scheduleControl.update(req)
    return schedule.map{ sch -> Response in
      logger.info("Schedule edition succed \(String(describing: sch.label)))")
      let ret = req.redirect(to: "/account/services/\(sch.serviceID)")
      return ret
    }
  }
  
  func accountScheduleDelete(_ req: Request) throws -> Future<View>  {
    
    let ret = try req.view().render("users/account_organizations" )
    return ret
    
    
  }
}

///
/// Part of schedule to manage Activities
extension WebsiteScheduleController {
  
  func accountScheduleActivityCreation(_ req: Request) throws -> Future<Response>  {
    let user = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Activity Creation from schedule website controler initiated by \(user.id!) (\(user.login))")
    logger.debug("Activity Creation from from url [\(req.http.urlString)]")
    return try req.parameters.next(Schedule.self).flatMap { [self] sch -> Future<Response> in
      let activity = try self.activityControl.create(req)
      return activity.map{ act -> Response in
        logger.info("Activity created with success \(act.id!) (\(String(describing: act.title)))")
        let ret = req.redirect(to: "/account/services/\(sch.serviceID)")
        return ret
      }.catch { (err) in
        logger.error("Activity creation failed - user \(user.login) (\(err))")
      }
    }
  }
  
  func accountScheduleActivityEdition(_ req: Request) throws -> Future<Response>  {
    let user = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Activity Update from schedule website controler initiated by \(user.id!) (\(user.login))")
    logger.debug("Activity Update from from url [\(req.http.urlString)]")
    return try req.parameters.next(Schedule.self).flatMap { [self] sch -> Future<Response> in
      let activity = try self.activityControl.update(req)
      logger.info("ActivityController update called \(activity) on schedule \(sch.id!)")
      return activity.map{ act -> Response in
        logger.info("Activity updated with success \(act.id!) (\(String(describing: act.title)))")
        let ret = req.redirect(to: "/account/services/\(sch.serviceID)")
        return ret
      }
    }.catch({ (err) in
      logger.error("Activity edition failed - user \(user.login) (\(err))")
    })
  }
  
  func accountScheduleActivitySuppression(_ req: Request) throws -> Future<Response>  {
    let user = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Activity Delete from schedule website controler initiated by \(user.id!) (\(user.login))")
    logger.debug("Activity Delete from from url [\(req.http.urlString)]")
    return try req.parameters.next(Schedule.self).flatMap { [self] sch -> Future<Response> in
      let activity = try self.activityControl.delete(req)
      logger.info("ActivityController delete called \(activity) on schedule \(sch.id!)")
      return activity.map{ act -> Response in
        logger.info("Activity deleted with success \(act.id!) (\(String(describing: act.title)))")
        let ret = req.redirect(to: "/account/services/\(sch.serviceID)")
        return ret
      }
    }.catch({ (err) in
      logger.error("Activity suppression failed - user \(user.login) (\(err))")
    })
  }
  
}


/// - MARK - WEBSITE USER DASHBOARD ROUTES
extension WebsiteScheduleController: RouteCollection {
  func boot(router: Router) throws {
    /*************************** PUBLIC SECTION *************************
     ***
     *******************************************************************/
    /** Public user end point api spec */
    // Creation of a new version
    
    let authSessionRouter = router.grouped(User.authSessionsMiddleware())
    
    /// Schedules account
    /// get related account schedule list
    authSessionRouter.get(kAccountBasePath, "schedules", use: accountScheduleList)
    // Show schedules details
    authSessionRouter.get(kAccountBasePath, "schedules", Schedule.parameter, use: accountScheduleShow)
    authSessionRouter.post(kAccountBasePath, "schedules", use: accountScheduleNew)
    authSessionRouter.patch(kAccountBasePath, "schedules", Schedule.parameter, use: accountScheduleEdit)
    //    authSessionRouter.patch(kAccountBasePath, "services", Service.parameter, "schedules", Schedule.parameter, use: accountScheduleEdit)
    authSessionRouter.delete(kAccountBasePath, "schedules", Schedule.parameter, use: accountScheduleShow)
    // Create activity in a given schedules
    authSessionRouter.post(kAccountBasePath, "schedules", Schedule.parameter, use: accountScheduleActivityCreation)
    //    authSessionRouter.get(kAccountBasePath, "schedules", Schedule.parameter, "activities", use: accountScheduleActivityList)
    //    authSessionRouter.get(kAccountBasePath, "schedules", Schedule.parameter, "activities", Activity.parameter, use: accountScheduleActivity)
    authSessionRouter.post(kAccountBasePath, "schedules", Schedule.parameter, "activities", Activity.parameter, "edit", use: accountScheduleActivityEdition)
    authSessionRouter.post(kAccountBasePath, "schedules", Schedule.parameter, "activities", Activity.parameter, "delete", use: accountScheduleActivitySuppression)
    
  }
}




