//
//  DevisFetchController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 14/07/2020.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication
import Paginator


/// - MARK - FETCHING  Devis
extension DevisController {
  
  /**
   *
   */
  public func showAPI(_ req: Request) throws -> Future<Devis.FullPublicResponse> {
    let user = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("##WEP POST /devis/:id ## Devis show initiated by \(user.id!) (\(user.login))")
    let devisID = try req.parameters.next(Devis.ID.self)
    return try devis(req, id: devisID).map
      { devs -> Devis.FullPublicResponse in
        logger.info("Devis informations retrieves - service ID \(devs.id) \(devs.label)")
        return devs
    }
  }
  
  public func devis(_ req: Request, id: Service.ID?, slug: String? = nil) throws -> Future<Devis.FullPublicResponse>  {
    let devis = Devis.query(on: req)
      .filter((nil != id ? \Devis.id == id! : \Devis.slugDevis == slug!))
      .join(\User.id, to: \Devis.authorID)
      .alsoDecode(User.self)
      .join(\Organization.id, to: \Devis.organizationID)
      .alsoDecode(Organization.self)
      .join(\Service.id, to: \Devis.serviceID)
      .alsoDecode(Service.self)
      .first()
    
    return devis.flatMap{ devis -> Future<Devis.FullPublicResponse> in
      guard let devisDest = devis else {
        throw Abort(HTTPResponseStatus.badRequest)
      }
      
      let (((dev, auth), org), serv) = devisDest
      
      
      let qAssets = """
      SELECT DISTINCT da."id" devis_link, da."saLink" id_link, da."label", da."devisID",  da."serviceID", da."quantity", da."initialQuantity", a.*
      FROM devisasset da
      INNER JOIN asset a ON da."assetID" = a.id
      WHERE (da."deletedAt" IS NULL OR da."deletedAt" > NOW())
      AND (a."toDate" > NOW() OR a."toDate" IS NULL) AND (a."fromDate" < NOW())
      AND da."devisID" = \(dev.id!)
      """
      
      let assets = req.withNewConnection(to: .psql) { $0.raw(qAssets).all(decoding: Asset.Response.ShortPublic.self) }
      
      let schedF      = dev.schedule?.query(on: req)
                        .join(\User.id, to: \Schedule.ownerID).alsoDecode(User.self).first()
      let activF      = dev.activity?.get(on: req)
      let aSignF      = dev.aSignator?.get(on: req)
      let bSignF      = dev.bSignator?.get(on: req)
      let closedF     = dev.closer?.get(on: req)
      let services    = try self.serviceController.serviceFullResponseTree(req: req, serv.id!)
      let orgaSs      = serv.organization.get(on: req)
      var fprDevis    = dev.fullResponse(auth: auth.shortResponse(), org: org.shortResponse(), serv: nil, servs: [], sch: nil, act: nil, signatora: nil, signatorb: nil, closed: nil)
      return services.flatMap { fprservices->  Future<Devis.FullPublicResponse> in
        fprDevis.services = fprservices
        fprDevis.service  = fprservices.first
        return orgaSs.flatMap{ orgss -> Future<Devis.FullPublicResponse> in
          fprDevis.organizationSs = orgss.shortResponse()
          return assets.flatMap{ assts -> Future<Devis.FullPublicResponse> in
            fprDevis.assets = assts
            func retriveSchedule(_ pair: (Schedule, User)?) throws -> Future<Schedule.MidPublicResponse>? {
              guard let (schd, usr) = pair else {
                return nil
               }
              var  sched = schd.midResponse(user: usr.shortResponse())
              let fActs = try schd.activities.query(on: req).all()
              return fActs.map { (acts) -> (Schedule.MidPublicResponse) in
                sched.activities = acts
                return sched
              }
            }
            _ = aSignF?.map({ (usrasf) -> Void in
              fprDevis.orgASignator = usrasf.shortResponse()
            })
            _ = bSignF?.map({ (usrbsf) -> Void in
              fprDevis.orgBSignator = usrbsf.shortResponse()
            })
            _ = closedF?.map({ (usrclo) -> Void in
              fprDevis.closedAuthorID = usrclo.shortResponse()
            })

            if let actvF = activF {
              return actvF.flatMap { (act) -> Future<Devis.FullPublicResponse> in
                let sch = act.schedule.query(on: req)
                  .join(\User.id, to: \Schedule.ownerID).alsoDecode(User.self).first()
                return sch.flatMap { (pairsch) -> Future<Devis.FullPublicResponse> in
                  return (try retriveSchedule(pairsch)?.map({ (midSched) -> Devis.FullPublicResponse in
                    fprDevis.schedule = midSched
                    // Do the other stuffs here
                    return fprDevis
                  })) ?? req.future(fprDevis)
                }
              }
            } else if let schF = schedF {
              return schF.flatMap({ (pairsch) -> Future<Devis.FullPublicResponse> in
                return (try retriveSchedule(pairsch)?.map({ (midSched) -> Devis.FullPublicResponse in
                  fprDevis.schedule = midSched
                  // Do the other stuffs here
                  return fprDevis
                })) ?? req.future(fprDevis)
              })
            } else {
              return req.future(fprDevis)
            }
            
          }
        }
        
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

