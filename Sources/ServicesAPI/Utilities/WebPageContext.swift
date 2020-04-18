//
//  WebPageContext.swift
//  App
//
//  Created by Jacques Charles NJANDA MBIADA on 01/12/2019.
//

import Foundation
import Vapor
import Fluent
import Paginator

public let kDefaultPaginatorLimit      = 2
public let kDefaultPaginatorOffset     = 0
public let kDefaultPaginatorPage       = 1
public let kDefaultPaginatorDirection  = "desc"
public let kDefaultQueryString         = ""

public let kPaginatorLimitQuery        = "limit"
public let kPaginatorOffsetQuery       = "offset"
public let kPaginatorPageQuery         = "p"
public let kPaginatorDirectionQuery    = "order"


public let kDefaultNavigationLimit     = 2
public let kDefaultNavigationOffset    = 0
public let kDefaultNavigationPage      = 1
public let kDefaultNavigationDirection = "null"

public let kNavigationOrgQuery         = "org"
public let kNavigationScheduleQuery    = "schedule"
public let kNavigationUserQuery        = "usr"
public let kNavigationServiceQuery     = "service"
public let kNavigationLimitQuery       = "limit"
public let kNavigationOffsetQuery      = "offset"
public let kNavigationPageQuery        = "p"
public let kNavigationDirectionQuery   = "o"
public let kNavigationSectorQuery      = "sec"
public let kNavigationIndustryQuery    = "i"
public let kNavigationRoleQuery        = "role"
public let kNavigationSizeQuery        = "size"
public let kNavigationKindQuery        = "kind"
public let kNavigationStateQuery       = "s"
public let kNavigationMoneyQuery       = "devise"
public let kNavigationJuridicQuery     = "t"
public let kNavigationCreatedQuery     = "c"
public let kNavigationUpdatedQuery     = "u"
public let kNavigationDeletedQuery     = "d"
public let kNavigationActivityStartQuery   = "sstart"
public let kNavigationActivityEndQuery     = "send"
public let kNavigationQuery                = "q"

public struct UrlWebsite : Content {
  var base        = Config.Static.baseUrl
  var origin      = ""
  var endUrl      = ""
  var main        = ""
  var object      = ""
  var root        = ""
  var breadcrumb: [String:[NamedEmail]] = [:]
  var params: [String:String]           = [:]
}

public struct Page<P: Codable>: Content {
  var meta:PageMeta?                  = nil
  var url:UrlWebsite?                 = nil
  var collection: OffsetPaginator<P>? = nil
  var user: User.FullLoggedResponse?  = nil
  var data: P?                        = nil
}

public struct PageMeta : Content {
  var limit:        Int               = kDefaultPaginatorLimit
  var offset:       Int               = kDefaultPaginatorOffset
  var page:         Int               = kDefaultPaginatorPage
  var direction:    String            = kDefaultPaginatorDirection
  // Services
  var pricing:      Int               = -1
  var priceLess:    Int               = -1
  var priceUpper:   Int               = -1
  var billing:      Int               = -1
  var target:       Int               = -1
  var negociable:   Int               = -1
  var free:         Int               = -1
  
  // Organizations
  var upper:    Int                   = 0
  var total:    Int                   = 0
  var count:    Int                   = 0
  var sector:   Int                   = -1
  var role:     Int                   = -1
  var size:     Int                   = -1
  var organization:     Int           = -1
  var industry: Int                   = -1
  var service:  Int                   = -1
  var schedule:  Int                  = -1
  var user:     Int                   = -1
  var kind:     Int                   = -1
  var status:   Int                   = -1
  var parent:   Int                   = -1
  var owner:   Int                    = -1
  var q:        String                = kDefaultQueryString 
  var namedData:  [String:[NamedEmail]] = [:]
  var params:     [String:String]       = [:]
  
  public mutating func config(from req: Request) {
    do {
      let logger    = try req.make(Logger.self)
      
      if let q    = try? req.query.get(String.self, at: kNavigationQuery) {
        self.q = q
        logger.info("Filter q given for the query : \(self.q)")
        self.params[kNavigationQuery] = q
      }
      if let sta    = try? req.query.get(Int.self, at: kNavigationStateQuery) {
        self.status = sta
        logger.info("Filter status given for the query : \(self.status)")
        self.params[kNavigationStateQuery] = String(sta)
      }
      if let sch    = try? req.query.get(Int.self, at: kNavigationScheduleQuery) {
        self.schedule   = sch
        logger.info("Filter schedule given for the query : \(self.schedule)")
        self.params[kNavigationScheduleQuery] = String(sch)
      }
      if let org    = try? req.query.get(Int.self, at: kNavigationOrgQuery) {
        self.organization   = org
        logger.info("Filter organization given for the query : \(self.organization)")
        self.params[kNavigationOrgQuery] = String(org)
      }
      if let usr    = try? req.query.get(Int.self, at: kNavigationUserQuery) {
        self.user   = usr
        logger.info("Filter user given for the query : \(self.user)")
        self.params[kNavigationUserQuery] = String(usr)
      }
      if let serv     = try? req.query.get(Int.self, at: kNavigationServiceQuery) {
        self.service  = serv
        logger.info("Filter service given for the query : \(self.service)")
        self.params[kNavigationServiceQuery] = String(serv)
      }
      if let lim      = try? req.query.get(Int.self, at: kNavigationLimitQuery) {
        self.limit    = lim
        logger.info("Filter limit given for the query : \(self.limit)")
        self.params[kNavigationLimitQuery] = String(lim)
      }
      if let role     = try? req.query.get(Int.self, at: kNavigationRoleQuery) {
        self.role     = role
        logger.info("Filter role given for the query : \(self.role)")
        self.params[kNavigationRoleQuery] = String(role)
      }
      if let size     = try? req.query.get(Int.self, at: kNavigationSizeQuery) {
        self.size     = size
        logger.info("Filter size given for the query : \(self.size)")
        self.params[kNavigationSizeQuery] = String(size)
      }
      if let ind        = try? req.query.get(Int.self, at: kNavigationIndustryQuery) {
        self.industry   = ind
        logger.info("Filter industry given for the query : \(self.industry)")
        self.params[kNavigationIndustryQuery] = String(ind)
      }
      if let sec      = try? req.query.get(Int.self, at: kNavigationSectorQuery) {
        self.sector   = sec
        logger.info("Filter sector given for the query : \(self.sector)")
        self.params[kNavigationSectorQuery] = String(sec)
      }
      if let cursor   = try? req.query.get(Int.self, at: kNavigationOffsetQuery) {
        self.offset   = cursor
        logger.info("Filter cursor/offset for the query : \(self.offset)")
        self.params[kNavigationOffsetQuery] = String(cursor)
      }
      if let ord      = try? req.query.get(String.self, at: kNavigationDirectionQuery).uppercased() {
        self.params[kNavigationDirectionQuery] = ord
        if ["ASC", "DESC"].contains(ord.uppercased()) {
          self.direction = ord.uppercased()
          logger.info("Filter direction given for the order query : \(ord)")
        } else {
          logger.warning("Bad direction given for the order query : \(ord)")
        }
      }
      if let pg   = try? req.query.get(Int.self, at: kNavigationPageQuery) {
        self.params[kNavigationPageQuery] = String(pg)
        self.page = pg
        if pg >= 1 {
          self.offset = (pg - 1) * self.limit
          self.upper  = self.limit + self.offset - 1
        } else {
          self.offset = kDefaultNavigationOffset
          self.upper  = self.offset
        }
        logger.info("Filter cursor/offset for the query : \(self.offset)")
      } else { // Set page anyway from limits
        self.page = Int((Double(offset) / Double(limit)).rounded(.up))
        self.page = self.page < 1 ? 1 : self.page
      }
      self.params[kNavigationPageQuery] = String(self.page)
    } catch _ {
      fatalError("Some error happen during filtering creation for : \(req)")
    }
  }
  
  public static func direction(from order: String) -> AdoptedDirection {
    switch order {
      case "ASC":
        return .ascending
      case "DESC":
        return .descending
      default:
        return .null
    }
  }
  
  init(_ req: Request? =  nil){
    if let r = req {
      self.config(from: r)
    }
  }
  
  init(limit: Int, offset: Int, order: String, page: Int) {
    self.direction = order
    self.limit    = limit
    self.offset   = offset
    self.page     = page
  }
  
  mutating public func apply<B: AdoptedDatabase , M: AdoptedModel>(_ builder : QueryBuilder<B , M>, from req: Request) -> QueryBuilder<B, M> {
    self.config(from: req)
    let logger = PrintLogger()
    logger.info("Retrieved \(M.self) with — direction: \(direction), limit: \(limit), offset: \(offset)")
    return builder.range(offset..<(offset + limit))
  }
}

public struct FilterNavigation<Obj: Content>: Content {
  var collection: [Obj]            = []
  //  var metas: PaginatorMeta
  //    public func metaData() { return self.metas }
  
  var limit:Int                   = kDefaultPaginatorLimit
  var offset: Int                 = kDefaultPaginatorOffset
  var page: Int                   = kDefaultPaginatorPage
  var direction: String           = kDefaultPaginatorDirection
  var upper: Int                  = 0
  var total: Int                  = 0
  var count: Int                  = 0
  
  mutating public func config(from req: Request) {
    do {
      let logger = try req.make(Logger.self)
      if let lim = try? req.query.get(Int.self, at: kNavigationLimitQuery) {
        self.limit = lim
        logger.info("Filter limit given for the query : \(self.limit)")
      }
      if let cursor = try? req.query.get(Int.self, at: kNavigationOffsetQuery) {
        self.offset = cursor
        logger.info("Filter cursor/offset for the query : \(self.offset)")
      }
      if let ord = try? req.query.get(String.self, at: kNavigationDirectionQuery).uppercased() {
        
        if ["ASC", "DESC"].contains(ord.uppercased()) {
          self.direction = ord.uppercased()
          logger.info("Filter direction given for the order query : \(ord)")
        } else {
          logger.warning("Bad direction given for the order query : \(ord)")
        }
      }
      if let pg = try? req.query.get(Int.self, at: kNavigationPageQuery) {
        self.page = pg
        if pg >= 1 {
          self.offset = (pg - 1) * self.limit
          self.upper = self.limit + self.offset - 1
        } else {
          self.offset = kDefaultNavigationOffset
          self.upper = self.offset
        }
        logger.info("Filter cursor/offset for the query : \(self.offset)")
      } else { // Set page anyway from limits
        self.page = Int((Double(offset) / Double(limit)).rounded(.up))
        self.page = self.page < 1 ? 1 : self.page
      }
      
    } catch _ {
      fatalError("Some error happen during filtering creation for : \(req)")
    }
  }
  
  public static func direction(from order: String) -> AdoptedDirection {
    switch order {
      case "ASC":
        return .ascending
      case "DESC":
        return .descending
      default:
        return .null
    }
  }
  
  init(){}
  
  public init(limit: Int, offset: Int, order: String, page: Int) {
    self.direction = order
    self.limit    = limit
    self.offset   = offset
    self.page     = page
  }
  
  mutating public func apply<B: AdoptedDatabase , M: AdoptedModel>(_ builder : QueryBuilder<B , M>, from req: Request) -> QueryBuilder<B, M> {
    self.config(from: req)
    let logger = PrintLogger()
    logger.info("Retrieved \(M.self) with — direction: \(direction), limit: \(limit), offset: \(offset)")
    return builder
      .groupBy(\M.id)
      .sort(\M.id, FilterNavigation.direction(from: self.direction))
      .range(offset..<(offset + limit))
  }
}
