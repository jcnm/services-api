//
//  Schedule.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 18/11/2019.
//

import Foundation
import FluentPostgreSQL
import Vapor
import Random
import Crypto

let kScheduleReferenceBasePrefix  = "CAL"
let kScheduleReferenceLength = 3
// An service Schedule to attache plannings on
public final class Schedule: AdoptedModel {
  public static let name = "schedule"
  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  /// Schedule's unique identifier.
  public var id: ObjectID?
  /// Schedule's unique réference.
  public var ref: String
  /// Schedule's unique réference into the organization whom create the schedule.
  public var orgScheduleARef: String?
  /// Schedule's unique réference into the organization whom validate the schedule if different.
  public var orgScheduleBRef: String?
  /// A potention planning day title
  public var label: String?
  /// Date time in the morning of the begining of work
  public var serviceID: Service.ID
  /// Schedule definition author
  public var ownerID: User.ID
  /// State of the schedule (validated by the responsable of the service)
  public var state: ObjectStatus.RawValue
  /// Schedule description
  public var description: String
  
  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `Service`.
  public init(label: String, owner: User.ID, service: Service.ID, state: ObjectStatus,
              orgRefA: String? = nil, orgRefB: String? = nil, description: String = "",
              createdAt: Date = Date(), updatedAt: Date? = nil,
              deletedAt: Date? = nil, id: ObjectID? = nil) {
    self.id         = id
    self.ref        = Utils.newRef(kScheduleReferenceBasePrefix, size: kScheduleReferenceLength)
    self.label      = label
    self.ownerID    = owner
    self.serviceID  = service
    self.state      = state.rawValue
    self.orgScheduleARef = orgRefA
    self.orgScheduleBRef = orgRefB
    self.description  = description
    self.createdAt    = createdAt
    self.updatedAt    = updatedAt
    self.deletedAt    = deletedAt
  }
  
  
}

/// Allows `Schedule` to be used as a Fluent migration.
extension Schedule: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    let sTable = AdoptedDatabase.create(Schedule.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.label)
      builder.field(for: \.orgScheduleARef)
      builder.field(for: \.orgScheduleBRef)
      builder.field(for: \.state)
      builder.field(for: \.serviceID)
      builder.field(for: \.ownerID)
      builder.field(for: \.description)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.unique(on: \.orgScheduleARef)
      //      builder.unique(on: \.orgScheduleARef) // Cause to not save the seed
      //      builder.unique(on: \.orgScheduleBRef)
      builder.reference(from: \Schedule.serviceID, to: \Service.id, onUpdate: .noAction, onDelete: .cascade)
      builder.reference(from: \Schedule.ownerID, to: \User.id, onUpdate: .noAction, onDelete: .noAction)
    }
    if type(of: conn) == PostgreSQLConnection.self {
      // Only for Post GreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(Schedule.name)_id_seq RESTART WITH 5000").all()
    }
    return sTable

  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Schedule.self, on: conn)
  }
}


public extension Schedule {
  // this Schedule's related service parent
  var service: Parent<Schedule, Service> {
    return parent(\.serviceID)
  }
  
  // this Schedule's related service parent
  var owner: Parent<Schedule, User> {
    return parent(\.ownerID)
  }
  
  /// Fluent relation to schedules items of this command .
  var activities: Children<Schedule, Activity> {
    return children(\.scheduleID)
  }
  /// this schedule's related order link (return all the order made for this schedul)
  var orders: Siblings<Schedule, Order, OrderItem> {
    return siblings()
  }
  
}

/// Allows `Schedule` to be used as a dynamic parameter in route definitions.
extension Schedule: Parameter { }

