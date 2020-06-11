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
public final class Score: AdoptedModel {
  public static let name = "score"
  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  
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
    let sTable = AdoptedDatabase.create(Score.self, on: conn)
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
    if type(of: conn) == PostgreSQLConnection.self {
      // Only for Post GreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(Score.name)_id_seq RESTART WITH 10000").all()
    }
    return sTable

  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Score.self, on: conn)
  }
}
 
/// Allows `Score` to be used as a dynamic parameter in route definitions.
extension Score: Parameter { }

