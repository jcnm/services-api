//
//  Score.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 16/03/2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kScoreReferenceBasePrefix  = "SCO"
let kScoreReferenceLength = kReferenceDefaultLength
//

// An service Score
final public class Score: AdoptedModel {
  public static let name = "score"
  static public var createdAtKey: TimestampKey? { return \.createdAt }
  static public var updatedAtKey: TimestampKey? { return \.updatedAt }
  static public var deletedAtKey: TimestampKey? { return \.deletedAt }
  
  /// Score's unique identifier.
  public var id: ObjectID?
  /// Score's unique réference.
  public var ref: String
  /// author of the score
  public var authorID: User.ID
  /// Service ID
  public var serviceID: Service.ID // a score is for services
  /// Order ID
  public var orderID: Order.ID? // Or order
  /// Nine notation criteria
  public var general: Int
  public var status: ObjectStatus.RawValue
  public var intengibility: Int?
  public var inseparability: Int?
  public var variability: Int?
  public var perishability: Int?
  public var ownership: Int?
  public var reliability: Int?
  public var disponibility: Int?
  public var pricing: Int?
  
  public var comment: String?
  
  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `Asset`.
  public init(author: User.ID, general: Int, service: Service.ID, order: Order.ID? = nil,
              comment: String? = nil, intengibility: Int? = nil, inseparability: Int? = nil,
              variability: Int? = nil, perishability: Int? = nil, ownership: Int? = nil,
              reliability: Int? = nil, disponibility: Int? = nil, pricing: Int? = nil, state: ObjectStatus,
              createdAt : Date = Date(), updatedAt: Date? = nil, deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id               = id
    self.ref              = Utils.newRef(kScoreReferenceBasePrefix, size: kScoreReferenceLength)
    self.general          = general
    self.status           = state.rawValue
    self.intengibility    = intengibility
    self.authorID         = author
    self.serviceID        = service
    self.orderID          = order
    self.inseparability   = inseparability
    self.variability      = variability
    self.perishability    = perishability
    self.ownership        = ownership
    self.reliability      = reliability
    self.variability      = disponibility
    self.pricing          = pricing
    self.comment          = comment
    self.createdAt        = createdAt
    self.updatedAt        = updatedAt
    self.deletedAt        = deletedAt
  }
  
  public static func duration(startT: Time, endT: Time) -> TimeInterval {
    if let sh = startT.hours , let sm = startT.minutes, let eh = endT.hours , let em = endT.minutes  {
      let hInM = (eh - sh) * 60
      let mins = (em - sm)
      return TimeInterval(hInM + mins)
    }
    return 0
  }
}

/// Allows `Score` to be used as a Fluent migration.
extension Score: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(Score.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.authorID)
      builder.field(for: \.serviceID)
      builder.field(for: \.orderID)
      builder.field(for: \.general)
      builder.field(for: \.status)
      builder.field(for: \.intengibility)
      builder.field(for: \.inseparability)
      builder.field(for: \.variability)
      builder.field(for: \.perishability)
      builder.field(for: \.ownership)
      builder.field(for: \.reliability)
      builder.field(for: \.disponibility)
      builder.field(for: \.pricing)
      builder.field(for: \.comment)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.reference(from: \Score.authorID,
                        to: \User.id,
                        onUpdate: .noAction, onDelete: .setDefault)
      builder.reference(from: \Score.orderID,
                        to: \Order.id,
                        onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \Score.serviceID,
                        to: \Service.id,
                        onUpdate: .noAction, onDelete: .setNull)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Score.self, on: conn)
  }
}
 
/// Allows `Score` to be used as a dynamic parameter in route definitions.
extension Score: Parameter { }

/// Seed for Score
struct SeedScore: Migration {
  typealias Database = AdoptedDatabase
  
  static func prepare(on connection: AdoptedConnection) -> Future<Void> {
    
    // For Score 1
    let sco1 = Score(author: 2, general: 660, service: 2, comment: nil, intengibility: nil, inseparability: nil, variability: nil, perishability: nil, ownership: 330, reliability: nil, disponibility: nil, pricing: 260, state: .online, createdAt: Date(), updatedAt: nil, deletedAt: nil, id: nil)
    
    let sco2 = Score(author: 5, general: 190, service: 2, comment: "Excellent service", intengibility: nil, inseparability: nil, variability: nil, perishability: nil, ownership: nil, reliability: nil, disponibility: nil, pricing: nil, state: .online, createdAt: Date(), updatedAt: nil, deletedAt: nil, id: nil)
    
    let sco3 = Score(author: 3, general: 700, service: 2, comment: "Hello", intengibility: 700, inseparability: 800, variability: 500, perishability: nil, ownership: 800, reliability: nil, disponibility: nil, pricing: 600, state: .online, createdAt: Date(), updatedAt: nil, deletedAt: nil, id: nil)
    
    let sco4 = Score(author: 6, general: 957, service: 2, comment: nil, intengibility: nil, inseparability: nil, variability: nil, perishability: nil, ownership: 360, reliability: nil, disponibility: nil, pricing: 1000, state: .online, createdAt: Date(), updatedAt: nil, deletedAt: nil, id: nil)
    
    let sco5 = Score(author: 8, general: 507, service: 7, comment: nil, intengibility: nil, inseparability: nil, variability: nil, perishability: nil, ownership: 435, reliability: nil, disponibility: nil, pricing: 500, state: .online, createdAt: Date(), updatedAt: nil, deletedAt: nil, id: nil)
    
    let sco6 = Score(author: 6, general: 700, service: 8, comment: nil, intengibility: nil, inseparability: nil, variability: nil, perishability: nil, ownership: 999, reliability: nil, disponibility: nil, pricing: nil, state: .online, createdAt: Date(), updatedAt: nil, deletedAt: nil, id: nil)
    
    let sco7 = Score(author: 8, general: 127, service: 4, comment: nil, intengibility: nil, inseparability: nil, variability: 456, perishability: nil, ownership: 900, reliability: nil, disponibility: 543, pricing: 459, state: .online, createdAt: Date(), updatedAt: nil, deletedAt: nil, id: nil)
    
    let sco8 = Score(author: 5, general: 700, service: 7, comment: nil, intengibility: 900, inseparability: 340, variability: 230, perishability: 300, ownership: 540, reliability: nil, disponibility: 120, pricing: nil, state: .online, createdAt: Date(), updatedAt: nil, deletedAt: nil, id: nil)
    
    let sco9 = Score(author: 3, general: 567, service: 2, comment: "Hello", intengibility: 704, inseparability: 808, variability: 565, perishability: nil, ownership: 688, reliability: nil, disponibility: nil, pricing: 766, state: .online, createdAt: Date(), updatedAt: nil, deletedAt: nil, id: nil)
    
    let sco10 = Score(author: 6, general: 957, service: 5, comment: nil, intengibility: nil, inseparability: nil, variability: nil, perishability: 640, ownership: 360, reliability: nil, disponibility: 545, pricing: 1000, state: .online, createdAt: Date(), updatedAt: nil, deletedAt: nil, id: nil)
    
    let sco11 = Score(author: 6, general: 357, service: 7, comment: "Nous verrons plus tard", intengibility: 400, inseparability: nil, variability: nil, perishability: 200, ownership: 435, reliability: nil, disponibility: 558, pricing: 700, state: .online, createdAt: Date(), updatedAt: nil, deletedAt: nil, id: nil)
    
    let sco12 = Score(author: 3, general: 700, service: 8, comment: "A voir hihihi", intengibility: nil, inseparability: 455, variability: nil, perishability: nil, ownership: 999, reliability: nil, disponibility: nil, pricing: 560, state: .online, createdAt: Date(), updatedAt: nil, deletedAt: nil, id: nil)
    
    let sco13 = Score(author: 8, general: 627, service: 5, comment: nil, intengibility: nil, inseparability: 550, variability: 456, perishability: nil, ownership: 900, reliability: nil, disponibility: 543, pricing: 459, state: .online, createdAt: Date(), updatedAt: nil, deletedAt: nil, id: nil)
    
    let sco14 = Score(author: 3, general: 640, service: 7, comment: nil, intengibility: 900, inseparability: 340, variability: 230, perishability: 300, ownership: 540, reliability: nil, disponibility: 220, pricing: nil, state: .online, createdAt: Date(), updatedAt: nil, deletedAt: nil, id: nil)

    _ = sco1.save(on: connection).catch({ (e) in
      print("ERROR SCORE 1 ----------")
      print(e)
    }).transform(to: ())
    _ = sco2.save(on: connection).catch({ (e) in
      print("ERROR SCORE 2 ----------")
      print(e)
    }).transform(to: ())
    _ = sco3.save(on: connection).catch({ (e) in
      print("ERROR SCORE 3 ----------")
      print(e)
    }).transform(to: ())
    
    _ = sco4.save(on: connection).catch({ (e) in
      print("ERROR SCORE 4 ----------")
      print(e)
    }).transform(to: ())
    
    _ = sco5.create(on: connection).transform(to: ())
    _ = sco6.create(on: connection).transform(to: ())
    _ = sco7.create(on: connection).transform(to: ())
    _ = sco8.create(on: connection).transform(to: ())
    _ = sco9.create(on: connection).transform(to: ())
    _ = sco10.create(on: connection).transform(to: ())
    _ = sco11.create(on: connection).transform(to: ())
    _ = sco12.create(on: connection).transform(to: ())
    _ = sco13.create(on: connection).transform(to: ())
    _ = sco14.create(on: connection).transform(to: ())
    return .done(on: connection)
  }
  
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    return .done(on: connection)
  }
}

