//
//  Utils.swift
//  App
//
//  Created by Jacques Charles NJANDA MBIADA on 22/12/2019.
//

import Foundation
import Vapor
import Fluent
import Crypto
//
public let kReferenceDefaultLength = 5


func serviceFeePercent(for price: Int) -> Int {
  if price < 1500 {
    return 1500
  }
  return 2200
}

public struct Utils {
  
  public static func newRef(_ prefix: String, size: Int = kReferenceDefaultLength, on: Date? = Date()) -> String {
    do {
      let ref = try CryptoRandom().generateData(count: size).hexEncodedString()
      let pref = "";
//      if let d = on {
//        let df = DateFormatter()
//        df.dateFormat = "yyyyMMdd"
//        pref = "\(prefix)\(df.string(from: d))"
//      } else {
//        pref = prefix
//      }
      return "\(pref)\(ref)"
    } catch let err {
      let log = PrintLogger()
      log.error("Unable to generate an unique reference: \(err)")
      return "N/A"
    }
  }
  
}

public struct PageMeta : Content {
  public var limit:        Int               = Config.SearchEngine.Default.limit
  public var offset:       Int               = Config.SearchEngine.Default.offset
  public var page:         Int               = Config.SearchEngine.Default.page
  public var direction:    String            = Config.SearchEngine.Default.direction
  // Services
  public var pricing:      Int               = Config.SearchEngine.Default.nullable
  public var priceLess:    Int               = Config.SearchEngine.Default.nullable
  public var priceUpper:   Int               = Config.SearchEngine.Default.nullable
  public var billing:      Int               = Config.SearchEngine.Default.nullable
  public var target:       Int               = Config.SearchEngine.Default.nullable
  public var negociable:   Int               = Config.SearchEngine.Default.nullable
  public var free:         Int               = Config.SearchEngine.Default.nullable
  
  // Organizations
  public var upper:    Int                   = Config.SearchEngine.Default.nonullable
  public var total:    Int                   = Config.SearchEngine.Default.nonullable
  public var count:    Int                   = Config.SearchEngine.Default.nonullable
  public var sector:   Int                   = Config.SearchEngine.Default.nullable
  public var role:     Int                   = Config.SearchEngine.Default.nullable
  public var size:     Int                   = Config.SearchEngine.Default.nullable
  public var organization:     Int           = Config.SearchEngine.Default.nullable
  public var industry: Int                   = Config.SearchEngine.Default.nullable
  public var service:  Int                   = Config.SearchEngine.Default.nullable
  public var schedule:  Int                  = Config.SearchEngine.Default.nullable
  public var user:     Int                   = Config.SearchEngine.Default.nullable
  public var kind:     Int                   = Config.SearchEngine.Default.nullable
  public var status:   Int                   = Config.SearchEngine.Default.nullable
  public var parent:   Int                   = Config.SearchEngine.Default.nullable
  public var owner:   Int                    = Config.SearchEngine.Default.nullable
  public var q:        String                = Config.SearchEngine.Default.queryString
  public var namedData:  [String:[NamedEmail]] = [:]
  public var params:     [String:String]       = [:]

  public mutating func config(from req: Request) {
    do {
      let logger    = try req.make(Logger.self)
      
      if let q    = try? req.query.get(String.self, at: Config.SearchEngine.paramsQuery) {
        self.q = q
        logger.info("Filter q given for the query : \(self.q)")
        self.params[Config.SearchEngine.paramsQuery] = q
      }
      if let sta    = try? req.query.get(Int.self, at: Config.SearchEngine.paramsStateQuery) {
        self.status = sta
        logger.info("Filter status given for the query : \(self.status)")
        self.params[Config.SearchEngine.paramsStateQuery] = String(sta)
      }
      if let sch    = try? req.query.get(Int.self, at: Config.SearchEngine.paramsScheduleQuery) {
        self.schedule   = sch
        logger.info("Filter schedule given for the query : \(self.schedule)")
        self.params[Config.SearchEngine.paramsScheduleQuery] = String(sch)
      }
      if let org    = try? req.query.get(Int.self, at: Config.SearchEngine.paramsOrganizationQuery) {
        self.organization   = org
        logger.info("Filter organization given for the query : \(self.organization)")
        self.params[Config.SearchEngine.paramsOrganizationQuery] = String(org)
      }
      if let usr    = try? req.query.get(Int.self, at: Config.SearchEngine.paramsUserQuery) {
        self.user   = usr
        logger.info("Filter user given for the query : \(self.user)")
        self.params[Config.SearchEngine.paramsUserQuery] = String(usr)
      }
      if let serv     = try? req.query.get(Int.self, at: Config.SearchEngine.paramsServiceQuery) {
        self.service  = serv
        logger.info("Filter service given for the query : \(self.service)")
        self.params[Config.SearchEngine.paramsServiceQuery] = String(serv)
      }
      if let lim      = try? req.query.get(Int.self, at: Config.SearchEngine.paramsLimitQuery) {
        self.limit    = lim
        logger.info("Filter limit given for the query : \(self.limit)")
        self.params[Config.SearchEngine.paramsLimitQuery] = String(lim)
      }
      if let role     = try? req.query.get(Int.self, at: Config.SearchEngine.paramsRoleQuery) {
        self.role     = role
        logger.info("Filter role given for the query : \(self.role)")
        self.params[Config.SearchEngine.paramsRoleQuery] = String(role)
      }
      if let size     = try? req.query.get(Int.self, at: Config.SearchEngine.paramsSizeQuery) {
        self.size     = size
        logger.info("Filter size given for the query : \(self.size)")
        self.params[Config.SearchEngine.paramsSizeQuery] = String(size)
      }
      if let ind        = try? req.query.get(Int.self, at: Config.SearchEngine.paramsIndustryQuery) {
        self.industry   = ind
        logger.info("Filter industry given for the query : \(self.industry)")
        self.params[Config.SearchEngine.paramsIndustryQuery] = String(ind)
      }
      if let sec      = try? req.query.get(Int.self, at: Config.SearchEngine.paramsSectorQuery) {
        self.sector   = sec
        logger.info("Filter sector given for the query : \(self.sector)")
        self.params[Config.SearchEngine.paramsSectorQuery] = String(sec)
      }
      if let cursor   = try? req.query.get(Int.self, at: Config.SearchEngine.paramsOffsetQuery) {
        self.offset   = cursor
        logger.info("Filter cursor/offset for the query : \(self.offset)")
        self.params[Config.SearchEngine.paramsOffsetQuery] = String(cursor)
      }
      if let ord      = try? req.query.get(String.self, at: Config.SearchEngine.paramsDirectionQuery).uppercased() {
        self.params[Config.SearchEngine.paramsDirectionQuery] = ord
        if ["ASC", "DESC"].contains(ord.uppercased()) {
          self.direction = ord.uppercased()
          logger.info("Filter direction given for the order query : \(ord)")
        } else {
          logger.warning("Bad direction given for the order query : \(ord)")
        }
      }
      if let pg   = try? req.query.get(Int.self, at: Config.SearchEngine.paramsPageQuery) {
        self.params[Config.SearchEngine.paramsPageQuery] = String(pg)
        self.page = pg
        if pg >= 1 && self.offset != Config.SearchEngine.Default.offset {
          self.offset = (pg - 1) * self.limit
          self.upper  = self.limit + self.offset - 1
        } else { 
          self.upper  = self.offset
        }
        logger.info("Filter cursor/offset for the query : \(self.offset)")
      } else { // Set page anyway from limits
        self.page = Int((Double(offset) / Double(limit)).rounded(.up))
        self.page = self.page < 1 ? 1 : self.page
      }
      self.params[Config.SearchEngine.paramsPageQuery] = String(self.page)
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
  
  public init(_ req: Request? =  nil){
    if let r = req {
      self.config(from: r)
    }
  }
  
  public init(limit: Int, offset: Int, order: String, page: Int) {
    self.direction = order
    self.limit    = limit
    self.offset   = offset
    self.page     = page
  }
  
  public mutating func apply<B: AdoptedDatabase , M: AdoptedModel>(_ builder : QueryBuilder<B , M>, from req: Request) -> QueryBuilder<B, M> {
    self.config(from: req)
    let logger = PrintLogger()
    logger.info("Retrieved \(M.self) with — direction: \(direction), limit: \(limit), offset: \(offset)")
    return builder.range(offset..<(offset + limit))
  }
}


public struct FilterNavigation<Obj: Content>: Content {
  public var collection: [Obj]            = []
  //  var metas: PaginatorMeta
  //    public func metaData() { return self.metas }
  
  public var limit:Int                   = Config.SearchEngine.Default.limit
  public var offset: Int                 = Config.SearchEngine.Default.offset
  public var page: Int                   = Config.SearchEngine.Default.page
  public var direction: String           = Config.SearchEngine.Default.direction
  public var upper: Int                  = 0
  public var total: Int                  = 0
  public var count: Int                  = 0
  
  public mutating func config(from req: Request) {
    do {
      let logger = try req.make(Logger.self)
      if let lim = try? req.query.get(Int.self, at: Config.SearchEngine.paramsLimitQuery) {
        self.limit = lim
        logger.info("Filter limit given for the query : \(self.limit)")
      }
      if let cursor = try? req.query.get(Int.self, at: Config.SearchEngine.paramsOffsetQuery) {
        self.offset = cursor
        logger.info("Filter cursor/offset for the query : \(self.offset)")
      }
      if let ord = try? req.query.get(String.self, at: Config.SearchEngine.paramsDirectionQuery).uppercased() {
        
        if ["ASC", "DESC"].contains(ord.uppercased()) {
          self.direction = ord.uppercased()
          logger.info("Filter direction given for the order query : \(ord)")
        } else {
          logger.warning("Bad direction given for the order query : \(ord)")
        }
      }
      if let pg = try? req.query.get(Int.self, at: Config.SearchEngine.paramsPageQuery) {
        self.page = pg
        if pg >= 1 {
          self.offset = (pg - 1) * self.limit
          self.upper = self.limit + self.offset - 1
        } else {
          self.offset = Config.SearchEngine.Default.offset
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
  
  public init(){}
  
  public init(limit: Int, offset: Int, order: String, page: Int) {
    self.direction = order
    self.limit    = limit
    self.offset   = offset
    self.page     = page
  }
  
  public mutating func apply<B: AdoptedDatabase , M: AdoptedModel>(_ builder : QueryBuilder<B , M>, from req: Request) -> QueryBuilder<B, M> {
    self.config(from: req)
    let logger = PrintLogger()
    logger.info("Retrieved \(M.self) with — direction: \(direction), limit: \(limit), offset: \(offset)")
    return builder
      .groupBy(\M.id)
      .sort(\M.id, FilterNavigation.direction(from: self.direction))
      .range(offset..<(offset + limit))
  }
}
