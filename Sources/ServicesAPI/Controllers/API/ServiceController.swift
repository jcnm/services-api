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
import Paginator
//import SwifQL
//import SwifQLVapor

/// - MARK - CREATE Service
public final class ServiceController {
  
  public init() { }

  public func create(_ req: Request) throws -> Future<Service.ShortPublicResponse> {
    let user = try UserController.logged(req)
    let logger = try req.make(Logger.self)
    logger.info("Service create initiated by \(user.id!) (\(user.login))")
    let serviceCS = try req.content.decode(Service.CreateService.self)
    return serviceCS.flatMap { (scs) -> Future<Service.ShortPublicResponse> in
      logger.info("Service content decoded \(scs.shortLabel)")
      let giventAuthor = scs.userID
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
                    nobillable: freeServ, negotiable: negServ, locationID: scs.location, geoPerimeter: scs.activityPerimeter ?? 1,
                    openOn: servStart, endOn: servEnd, createdAt: Date(), updatedAt: nil, deletedAt: nil, id: nil)
          return service.save(on: req).map { (serv) -> Service.ShortPublicResponse in
            return serv.shortResponse()
          }
      }
    }
  }
}

/// - MARK - UPDATE Service
extension ServiceController {
  public func update(_ req: Request) throws -> Future<Service> {
    let _ = try UserController.logged(req)
    
    return try req.parameters.next(Service.self).flatMap
      { serToUpdate -> Future<Service> in
        // decode request content
        return try req.content.decode(Service.self).flatMap
          { serv -> Future<Service> in
            // verify that the service is well sharped
            guard try serv.requireID() == serToUpdate.requireID() else {
              throw Abort(HTTPResponseStatus.badRequest)
            }
            
            serToUpdate.label         = serv.label
            serToUpdate.billing       = serv.billing
            serToUpdate.price         = serv.price
            serToUpdate.shortLabel    = serv.shortLabel
            serToUpdate.industryID    = serv.industryID
            serToUpdate.parentID      = serv.parentID
            serToUpdate.description   = serv.description
            serToUpdate.authorID      = serv.authorID
            serToUpdate.geoPerimeter  = serv.geoPerimeter
            serToUpdate.disponibility = serv.disponibility
            
            serToUpdate.updatedAt     = Date()
            
            return serToUpdate.update(on: req)
        }
    }
  }
}

/// - MARK - GET  Service
extension ServiceController {
  
  public func avgScores(_ req: Request, serviceID: Service.ID) -> EventLoopFuture<Service.ScoreAverage?> {
    let query = """
    SELECT count("general") tGeneral, count(intengibility) tIntengibility, count(inseparability) tInseparability, count(variability) tVariability, count(perishability) tPerishability, count(ownership) tOwnership, count(reliability) tReliability, count(disponibility) tDisponibility, count(pricing) tPricing,
    ROUND(avg("general"), 2) as aGeneral, ROUND(avg(intengibility), 2) as aIntengibility, ROUND(avg(inseparability), 2) aInseparability, ROUND(avg(variability), 2) aVariability, ROUND(avg(perishability), 2) aPerishability, ROUND(avg(ownership), 2) aOwnership, ROUND(avg(reliability), 2) aReliability, ROUND(avg(disponibility), 2) aDisponibility, ROUND(avg(pricing), 2) as aPricing
    FROM score
    WHERE ("score"."deletedAt" IS NULL OR "score"."deletedAt" > NOW()) AND "serviceID" = \(serviceID);
    """
    let res = req.withNewConnection(to: .psql) { (dbConnect) -> EventLoopFuture<Service.ScoreAverage?> in
      dbConnect.raw( query ).first(decoding: Service.ScoreAverage.self)
    }
    return res
    
  }
  /**
   *
   */
  public func serviceFullResponseTree(req: Request, _ serviceID: Service.ID) throws -> Future<[Service.FullPublicResponse]> {
    
    let logger = try req.make(Logger.self)
    logger.debug("Getting Service from parameter \(serviceID)")
    let query = """
    WITH RECURSIVE recServ
    AS (SELECT DISTINCT sv.*, ("sv". "id"::text) as pidentkey
    FROM service sv
    WHERE ("sv"."deletedAt" IS NULL OR "sv"."deletedAt" > NOW()) AND "sv".id = \(serviceID)
    UNION ALL
    SELECT DISTINCT ssv.*,
    (CAST(rsv.pidentkey AS text) || CAST(ssv.id AS text) ) as pidentkey
    FROM service ssv -- seconde service
    INNER JOIN recServ as rsv -- recursive service
    ON ssv."id" = rsv."parentID"
    )
    SELECT *
    FROM recServ
    ORDER BY pidentkey ASC
    """
    
    let res = req.withNewConnection(to: .psql) { $0.raw(query).all(decoding: Service.self) }
    
    return res.flatMap { (services) -> Future<[Service.FullPublicResponse]> in
      /// Create service of assets list
      var serviceDico: [Service.ID: (Service, [Asset.ShortPublicResponse])] = [:]
      let mutServices = services
//      let firstSv = mutServices.removeFirst()
      let idents = mutServices.reduce(into: []) { (result: inout [String], service) in
        result.append("\(service.id!)") ; serviceDico[service.id!] = (service, []) }
//      idents.append("\(firstSv.id!)")
      let strIdents = idents.joined(separator: ",")
      let qAssets = """
      SELECT DISTINCT sa.id id_link, sa.label, sa."orderID", sa."serviceID", sa.quantity, a.*
      FROM serviceasset sa
      INNER JOIN asset a ON sa."assetID" = a.id
      WHERE (sa."deletedAt" IS NULL OR sa."deletedAt" > NOW())
      AND (a."toDate" > NOW() OR a."toDate" IS NULL) AND (a."fromDate" < NOW())
      AND sa."serviceID" IN (\(strIdents)) AND sa."orderID" IS NULL
      """
//      serviceDico[firstSv.id!] = (firstSv, [])
      let assets = req.withNewConnection(to: .psql) { $0.raw(qAssets).all(decoding: Asset.ShortPublicResponse.self) }
      
      return assets.flatMap { (rawAss) -> Future<[Service.FullPublicResponse]> in
        rawAss.reduce((), { (_, servass) -> Void in
          serviceDico[servass.serviceID!]!.1.append(servass) })
        
        var sFPR = [Future<Service.FullPublicResponse>]()
        
        let sortedDictionary = serviceDico.sorted() { $0.value.0.pidentkey! <= $1.value.0.pidentkey! }
        for (_, servAsset) in sortedDictionary {
          let (serv, assets) = servAsset
          logger.error("\n\n\n$$$$$$$$$$$$$$$$$$Processing service \(serv.label) === \(serv.id!) ")

          let parent    = serv.parent?.get(on: req)
          let orga      = serv.organization.get(on: req)
          let author    = serv.author.get(on: req)
          let industry  = serv.industry.get(on: req)
          let children  = try serv.services.query(on: req).all()
          let schedule  = try serv.schedules.query(on: req).all()
          //        let assets    = try serv.assets.query(on: req).all()
          let scores    = try serv.scores.query(on: req) /// And then navigate between comments...
            .join(\User.id, to: \Score.authorID)
            .filter(\Score.comment != nil)
            .alsoDecode(User.self)
          let trans     = try scores.transform(on: req)
          { (s, u) -> Score.MidPublicResponse in s.midResponse(user: u) }
          
          let servScorePagine  = try trans.paginate(for: req, type: OffsetPaginator<Score.MidPublicResponse>.self)
          let fpres = children.flatMap { (servs) -> Future<Service.FullPublicResponse> in
            logger.debug("Getting Service children count \(servs.count)")
            
            let scoresStats = self.avgScores(req, serviceID: serv.id!)
            return schedule.and(scoresStats).flatMap { (scheds, scsts) -> Future<Service.FullPublicResponse> in
              logger.debug("Getting Service schedule count \(scheds.count)")
              return industry.and(orga).and(author).flatMap { (indorg, auth) -> Future<Service.FullPublicResponse> in
                let (ind, org) = indorg
                logger.debug("Getting industry \(ind.id!) \(ind.title)")
                logger.debug("Getting organization \(org.id!) \(org.label)")
                logger.debug("Getting service author \(auth.id!) \(auth.login)")
                return servScorePagine.flatMap { sss -> Future<Service.FullPublicResponse> in
                  var retRes = Service.fullResponse(serv: serv, ind: ind.shortResponse(), user: auth.shortResponse(), org: org.shortResponse(), parent: nil)
                  retRes.scoreAverage = scsts
                  retRes.assets = assets
                  retRes.scores = sss

                  if let pare = parent {
                    _ = pare.map { (par) -> Void in
                      logger.debug("Linking given parent  \(par.id!) \(par.label)")
                      retRes.parent = par.shortResponse()
                    }
                  }
                  retRes.children = []
                  for ser in servs {
                    logger.debug("Linking child \(ser.id!) \(ser.label)")
                    retRes.children!.append(ser.shortResponse())
                  }
                  
                  let lschd = try scheds.map { (scd: Schedule) -> Future<Schedule.MidPublicResponse> in
                    logger.debug("Linking schedule \(scd.id!) \(String(describing: scd.label))")
                    var scdFR = scd.midResponse()
                    return try scd.activities.query(on: req).all().map { (actis) -> Schedule.MidPublicResponse in
                      logger.debug("Linking activities count(\(actis.count)) for the schedule \(scd.id!) \(String(describing: scd.label))")
                      scdFR.activities = actis
                      return scdFR
                    }
                  }
                  
                  return lschd.flatten(on: req).map{ (schs) -> Service.FullPublicResponse in
                    retRes.schedules = schs
                    logger.info("Linking schedules to the retrieving service \(retRes.label) ")
                    logger.warning("\n$$$$$$$$$$$$$$$$$$$$$$@@@@@@@@@@@@@@ Full service \(retRes.label) processed")

                    return retRes
                  }
                }
              }
            }
          }
          sFPR.append(fpres)
        }
        return sFPR.flatten(on: req)
      }
    }
  }
  
  /**
   
   */
  public func serviceFullResponse(req: Request, serv: Service) throws -> Future<Service.FullPublicResponse> {
    
    let logger = try req.make(Logger.self)
    logger.debug("Getting Service from parameter \(serv.id!):\(serv.label)")
    let parent    = serv.parent?.get(on: req)
    let orga      = serv.organization.get(on: req)
    let author    = serv.author.get(on: req)
    let industry  = serv.industry.get(on: req)
    let children  = try serv.services.query(on: req).all()
    let schedule  = try serv.schedules.query(on: req).all()
    let assets    = try serv.assets.query(on: req)
      .filter(\ServiceAsset.serviceID == serv.id!)
      .alsoDecode(ServiceAsset.self)
      .all().map({ list in list.map{ $0.0.shortResponse($0.1) }})
    let scores    = try serv.scores.query(on: req) /// And then navigate between comments...
      .join(\User.id, to: \Score.authorID)
      .filter(\Score.comment != nil)
      .alsoDecode(User.self)
    let trans     = try scores.transform(on: req)
    { (s, u) -> Score.MidPublicResponse in s.midResponse(user: u) }
    
    let servScorePagine  = try trans.paginate(for: req, type: OffsetPaginator<Score.MidPublicResponse>.self)
    return children.flatMap { (servs) -> Future<Service.FullPublicResponse> in
      logger.debug("Getting Service children count \(servs.count)")
      
      let scoresStats = self.avgScores(req, serviceID: serv.id!)
      return schedule.and(scoresStats).flatMap { (scheds, scsts) -> Future<Service.FullPublicResponse> in
        logger.debug("Getting Service schedule count \(scheds.count)")
        return industry.and(orga).and(author).flatMap { (indorg, auth) -> Future<Service.FullPublicResponse> in
          let (ind, org) = indorg
          logger.debug("Getting industry \(ind.id!) \(ind.title)")
          logger.debug("Getting organization \(org.id!) \(org.label)")
          logger.debug("Getting service author \(auth.id!) \(auth.login)")
          return assets.and(servScorePagine).flatMap { (sass, sss) -> Future<Service.FullPublicResponse> in
            var retRes = Service.fullResponse(serv: serv, ind: ind.shortResponse(), user: auth.shortResponse(), org: org.shortResponse(), parent: nil)
            retRes.scoreAverage = scsts
            retRes.assets = sass
            retRes.scores = sss
            logger.debug("Linking assets count(\(sass.count)), scores struct(\(String(describing: sss.metaData()?.total))) for the service \(serv.id!) \(String(describing: serv.label))")
            if let pare = parent {
              _ = pare.map { (par) -> Void in
                logger.debug("Linking given parent  \(par.id!) \(par.label)")
                retRes.parent = par.shortResponse()
              }
            }
            retRes.children = []
            for ser in servs {
              logger.debug("Linking child \(ser.id!) \(ser.label)")
              retRes.children!.append(ser.shortResponse())
            }
            
            let lschd = try scheds.map { (scd: Schedule) -> Future<Schedule.MidPublicResponse> in
              logger.debug("Linking schedule \(scd.id!) \(String(describing: scd.label))")
              var scdFR = scd.midResponse()
              return try scd.activities.query(on: req).all().map { (actis) -> Schedule.MidPublicResponse in
                logger.debug("Linking activities count(\(actis.count)) for the schedule \(scd.id!) \(String(describing: scd.label))")
                scdFR.activities = actis
                return scdFR
              }
            }
            
            return lschd.flatten(on: req).map{ (schs) -> Service.FullPublicResponse in
              retRes.schedules = schs
              logger.info("Linking schedules to the retrieving service")
              return retRes
            }
          }
        }
      }
    }
    
  }
  /**
   *
   */
  public func show(_ req: Request, _ serviceID: Service.ID? = nil)
    throws -> (PageMeta, Future<Service.FullPublicResponse>) {
      let uAuth = try UserController.logged(req)
      let logger = try  req.make(Logger.self)
      logger.info("Getting Service initiated by \(uAuth.id!) (\(uAuth.login))")
      let meta = PageMeta(req)
      if let id = serviceID {
        let sop = Service.find(id, on: req)
        return (meta, sop.flatMap { (evps) -> Future<Service.FullPublicResponse> in
          guard let serv = evps else {
            throw Abort(HTTPResponseStatus.badRequest)
          }
          return try self.serviceFullResponse(req: req, serv: serv)
        })
      }
      let serv = try req.parameters.next(Service.self)
      return (meta,
              serv.flatMap { serv -> Future<Service.FullPublicResponse> in
                return try self.serviceFullResponse(req: req, serv: serv)})
      
  }
  
  /**
   *
   */
  public func industryOfService(_ req: Request) throws -> Future<Industry> {
    
    let _ = try UserController.logged(req)
    return try req.parameters.next(Service.self).flatMap
      { serv -> Future<Industry> in
        guard try serv.requireID() != 0 else {
          throw Abort(HTTPResponseStatus.badRequest)
        }
        return serv.industry.get(on: req)
    }
  }
  
  /**
   *
   */
  public func list(_ req: Request) throws -> Future<OffsetPaginator<Service.FullPublicResponse>> {
    return try ServiceController.list(req).1
  }
  
  /**
   *
   */
  public func accountRelativeList(_ req: Request) throws -> Future<OffsetPaginator<Service.FullPublicResponse>> {
    let uAutth = try UserController.logged(req)
    let logger = try  req.make(Logger.self)
    logger.info("Getting Services initiated by user \(uAutth.id!) (\(uAutth.login))")
    return try ServiceController.list(req, of: uAutth).1
  }
  
  /**
   * List Service for Leaf Views
   *
   */
  
  public static func indexList(_ req: Request) throws -> (PageMeta, Future<OffsetPaginator<Service.FullPublicResponse>>) {
    let logger = try  req.make(Logger.self)
    let meta = PageMeta(req)
    var qry: QueryBuilder<AdoptedDatabase, Service>
    let uAutth = try? req.requireAuthenticated(User.self)
    if let u = uAutth {
      logger.info("Getting Index Full Service list ... initiated by user \(u.id!) (\(u.login))")
      
    } else {
      logger.info("Getting Index Full Services list ...  initiated anonymous user \(req.http.remotePeer.description) (\(String(describing: req.http.remotePeer.hostname)))")
    }
    /// TODO FIXME request notation scores average and count for every service retrieved
//
//    let qStr = """
//  SELECT *
//  FROM "service"
//  INNER JOIN "user" ON "service"."authorID" = "user"."id"
//  INNER JOIN "industry" ON "service"."industryID" = "industry"."id"
//  INNER JOIN "organization" ON "service"."organizationID" = "organization"."id"
//  LEFT OUTER JOIN
//  (SELECT sc."serviceID" service_id, count("general") tGeneral, count(intengibility) tIntengibility,
//   count(inseparability) tInseparability, count(variability) tVariability,
//   count(perishability) tPerishability, count(ownership) tOwnership,
//   count(reliability) tReliability, count(disponibility) tDisponibility,
//   count(pricing) tPricing,
//   ROUND(avg("general"), 2) as aGeneral, ROUND(avg(intengibility), 2) as aIntengibility,
//   ROUND(avg(inseparability), 2) aInseparability, ROUND(avg(variability), 2) aVariability,
//   ROUND(avg(perishability), 2) aPerishability, ROUND(avg(ownership), 2) aOwnership,
//   ROUND(avg(reliability), 2) aReliability, ROUND(avg(disponibility), 2) aDisponibility,
//   ROUND(avg(pricing), 2) as aPricing
//     FROM score sc
//     WHERE ("sc"."deletedAt" IS NULL OR "sc"."deletedAt" > NOW())
//     GROUP BY service_id
//    ) st ON st.service_id = "service".id
//  WHERE ("service"."deletedAt" IS NULL OR "service"."deletedAt" > NOW() )
//    AND "organization"."id" = \(Config.Static.bbMainOrgID)
//    AND ("service"."status" = \(ObjectStatus.online.rawValue) OR "service"."status" = \(ObjectStatus.review.rawValue))
//    ORDER BY aGeneral \(meta.direction)
//    LIMIT \(meta.limit) OFFSET \(meta.offset)
//"""
//
//    let res = req.withNewConnection(to: .psql) { (dCon) -> EventLoopFuture<[(Service, User, Industry)]> in
//      let sqlQ = dCon.raw(qStr)
//      let query = sqlQ.all(decoding: Service.self, User.self, Industry.self)
//      return query
//    }
//    let subScore = SwifQL
//      .select("score.serviceID" => "service_id",
//              Fn.count("score.general") => "tGeneral",
//              Fn.count("score.intengibility") => "tIntengibility",
//              Fn.count("score.inseparability") => "tInseparability", Fn.count("score.variability") => "tVariability",
//              Fn.count("score.perishability") => "tPerishability", Fn.count("score.ownership") => "tOwnership",
//              Fn.count("score.reliability") => "tReliability", Fn.count("score.disponibility") => "tDisponibility",
//              Fn.count("score.pricing") => "tPricing",
//              Fn.round(Fn.avg("general"), 2) => "aGeneral", Fn.round(Fn.avg("score.intengibility"), 2) => "aIntengibility",
//              Fn.round(Fn.avg("score.inseparability"), 2) => "aInseparability", Fn.round(Fn.avg("score.variability"), 2) => "aVariability",
//              Fn.round(Fn.avg("score.perishability"), 2) => "aPerishability", Fn.round(Fn.avg("score.ownership"), 2) => "aOwnership",
//              Fn.round(Fn.avg("score.reliability"), 2) => "aReliability", Fn.round(Fn.avg("score.disponibility"), 2) => "aDisponibility",
//              Fn.round(Fn.avg("score.pricing"), 2) => "aPricing"
//              )
//      .from(Score.table)
//      .where(\Score.deletedAt == nil || \Score.deletedAt > Fn.now())
//      .groupBy("service_id")
//
//    let realQuery = SwifQL.select(Service.table.*).from(Service.table)
//      .join(.inner, User.table, on: "service.authorID = user.id")
//      .join(.inner, Industry.table, on: "service.industryID = industry.id")
//      .join(.inner, Organization.table, on: "service.organizationID = organization.id")
//      .join(.leftOuter, |subScore| => "st", on: "st.service_id = service.id")
//      .where(|\Service.deletedAt == nil || \Service.deletedAt > Fn.now()|
//        && |\Service.status == ObjectStatus.online.rawValue || \Service.status == ObjectStatus.review.rawValue|
//        && \Organization.id == Config.Static.bbMainOrgID)
//      .orderBy(.asc("aGeneral"))
//      .limit(meta.limit)
//      .offset(meta.offset)
//
//    logger.error("--------------------")
//    logger.error(realQuery.description)
//    logger.error("--------------------")
//
//    let sqlRaw = realQuery.execute(on: req, as: .psql)
////    req.newConnection(to: .psql).flatMap { (conn) -> EventLoopFuture<Void> in
////
////      realQuery.execute(on: conn).all(decoding: <#T##Decodable.Protocol#>, <#T##b: Decodable.Protocol##Decodable.Protocol#>, <#T##c: Decodable.Protocol##Decodable.Protocol#>)
////    }
//
    qry = Service.query(on: req)
      .join(\User.id, to: \Service.authorID, method: .default)
      .join(\Industry.id, to: \Service.industryID, method: .default)
      .join(\Organization.id, to: \Service.organizationID, method: .default)
      .filter(\Organization.id == Config.bbMainOrgID)
      .group(.or) {
        $0.filter(\Service.status == ObjectStatus.online.rawValue)
        $0.filter(\Service.status == ObjectStatus.review.rawValue)
        //          .filter(\Organization.id == Config.Static.bbMainOrgID)
        //          .filter(\Organization.id == Config.Static.bbMainOrgID)
    }
    
    logger.info("Getting Index Services applaying filters")
    if meta.size != -1 {
      qry = qry.filter(\Organization.osize == meta.size)
    }
    
    let trans = try qry
      .alsoDecode(User.self)
      .alsoDecode(Industry.self)
      .alsoDecode(Organization.self)
      .transform(on: req){ (obj: ((((Service, User), Industry), Organization))) -> Service.FullPublicResponse in
        let service = obj.0.0.0
        let user    = obj.0.0.1
        let industry = obj.0.1
        let organization = obj.1
        let publicResp = Service.fullResponse(serv: service, ind: industry.shortResponse(), user: user.shortResponse(), org: organization.shortResponse())
        logger.info("Getting Services applaying transformation to get \n{\(publicResp.id!), \(publicResp.label)}\n\n ")
        return publicResp
    }
    
    return try (meta, trans.paginate(for: req, type: OffsetPaginator<Service.FullPublicResponse>.self))
  }
  
  
  /**
   * List Service for Leaf Views
   *
   */
  
  public static func list(_ req: Request, of loggedUser: User? = nil) throws -> (PageMeta, Future<OffsetPaginator<Service.FullPublicResponse>>) {
    let logger = try  req.make(Logger.self)
    var meta = PageMeta()
    meta.config(from: req)
    var qry: QueryBuilder<AdoptedDatabase, Service>
    if let user = loggedUser {
      logger.info("Getting Full Services list attached to user \(user.id!) (\(user.login))")
      qry = try user.services.query(on: req)
        .join(\Industry.id, to: \Service.industryID, method: .default)
        .join(\Organization.id, to: \Service.organizationID, method: .default)
      
    } else {
      let uAutth = try UserController.logged(req)
      logger.info("Getting Full Services list initiated by user \(uAutth.id!) (\(uAutth.login))")
      qry = Service.query(on: req)
        .join(\User.id, to: \Service.authorID, method: .default)
        .join(\Industry.id, to: \Service.industryID, method: .default)
        .join(\Organization.id, to: \Service.organizationID, method: .default)
        .filter(\Service.status == ObjectStatus.online.rawValue)
    }
    
    
    
    logger.info("Getting Services applaying filters")
    if meta.size != -1 {
      qry = qry.filter(\Organization.osize == meta.size)
    }
    if meta.organization != -1 {
      qry = qry.filter(\Service.organizationID == meta.organization)
    }
    if meta.status  != -1 {
      qry = qry.filter(\Service.status == meta.status)
    }
    if meta.sector != -1 {
      qry = qry.filter(\Organization.sectorID == meta.sector)
    }
    if meta.industry != -1 {
      qry = qry.filter(\Service.industryID == meta.industry)
    }
    if meta.q != Config.SearchEngine.Default.queryString {
      let sqr = "%\(meta.q)%"
      qry = qry.group(.or) {
        $0.filter(\Service.label,           .ilike, sqr)
          .filter(\Service.shortLabel,      .ilike, sqr)
          .filter(\Service.description,     .ilike, sqr)
          .filter(\Service.ref,             .ilike, sqr)
          //          .filter(\User.login,            .ilike, sqr)
          //          .filter(\User.email,            .ilike, sqr)
          .filter(\Industry.title,          .ilike, sqr)
          .filter(\Industry.nace,           .ilike, sqr)
          .filter(\Industry.citi,           .ilike, sqr)
          .filter(\Industry.scian,          .ilike, sqr)
          .filter(\Industry.ref,            .ilike, sqr)
      }
    }
    
    if let user = loggedUser {
      let trans =
        try qry
          .alsoDecode(Industry.self)
          .alsoDecode(Organization.self)
          .transform(on: req){ (obj: ((Service, Industry), Organization))
            -> Service.FullPublicResponse in
            let service = obj.0.0
            let industry = obj.0.1
            let organization = obj.1
            var publicResp =  Service.fullResponse(serv: service, ind: industry.shortResponse(), user: user.shortResponse(), org: organization.shortResponse())
            _ = try service.assets.query(on: req).join(\ServiceAsset.assetID, to: \Asset.id)
            
            .filter(\ServiceAsset.serviceID == service.id!)
              .alsoDecode(ServiceAsset.self).all().map({ list in publicResp.assets = list.map{ $0.0.shortResponse($0.1) }})// .all()//.map {  }
            
            logger.info("Getting Services applaying transformation to get \n{\(publicResp.id!), \(publicResp.label)}\n\n ")
            return publicResp
      }
      return try (meta, trans.paginate(for: req, type: OffsetPaginator<Service.FullPublicResponse>.self))
    } else {
      let trans = try qry
        .alsoDecode(User.self)
        .alsoDecode(Industry.self)
        .alsoDecode(Organization.self)
        .transform(on: req){ (obj: ((((Service, User), Industry), Organization))) -> Service.FullPublicResponse in
          let service = obj.0.0.0
          let user    = obj.0.0.1
          let industry = obj.0.1
          let organization = obj.1
          let publicResp = Service.fullResponse(serv: service, ind: industry.shortResponse(), user: user.shortResponse(), org: organization.shortResponse())
          logger.info("Getting Services applaying transformation to get \n{\(publicResp.id!), \(publicResp.label)}\n\n ")
          return publicResp
      }
      
      return try (meta, trans.paginate(for: req, type: OffsetPaginator<Service.FullPublicResponse>.self))
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

    servicesGroup.get(use: list)
    servicesAccountGroup.get(use: accountRelativeList)
    servicesAccountGroup.post(use: create)
    servicesAccountGroup.get(Service.parameter, use: { try self.show($0).1 } )
    servicesAccountGroup.patch(Service.parameter, use: update)
    servicesAccountGroup.patch(Service.parameter, Config.APIWEP.industriesWEP, use: industryOfService)
    
  }
}
