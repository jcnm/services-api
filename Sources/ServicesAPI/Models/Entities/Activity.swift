//
//  Activity.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 18/11/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kPlanningReferenceBasePrefix  = "ACT"
let kPlanningReferenceLength = kReferenceDefaultLength

public enum DayOfWeek: Int, Codable, CaseIterable, ReflectionDecodable {
  public static func reflectDecoded() throws -> (DayOfWeek, DayOfWeek) {
    return (monday, sunday)
    
  }
  
  /// First day of the week
  case monday           = 1
  case tuesday          = 2
  case wednesday        = 3
  case thursday         = 4
  case friday           = 5
  
  case saturday         = 6
  /// Last day of the week
  case sunday           = 0
  
  public static func has(value: Int, status: ObjectStatus) -> Bool {
    let res = value & status.rawValue
    return res == status.rawValue
  }
  
  public static func midweek() -> DayOfWeek {
    return .thursday
  }
  
  public static func first() -> DayOfWeek {
    return .monday
  }
  
  public static func last() -> DayOfWeek {
    return .sunday
  }
  
  public static var defaultValue: DayOfWeek {
    return .monday
  }
  
  public static var defaultRaw: DayOfWeek.RawValue {
    return defaultValue.rawValue
  }
  
  public var textual: String {
    switch self {
      case .monday :
      return "Lundi"
      case .tuesday :
      return "Mardi"
      case .wednesday :
      return "Mercredi"
      case .thursday :
      return "Jeudi"
      case .friday :
      return "Vendredi"
      case .saturday :
      return "Samedi"
      case .sunday :
      return "Dimanche"
    }
  }
  
  public var next: DayOfWeek {
    switch self {
      case .monday:
        return .tuesday
      case .tuesday:
        return .wednesday
      case .wednesday:
        return .thursday
      case .thursday:
        return .friday
      case .friday:
        return .saturday
      case .saturday:
        return .sunday
      case .sunday:
        return .monday
    }
  }
}


public extension Int {
  var dow: DayOfWeek {
    return DayOfWeek(rawValue: self) ?? DayOfWeek.defaultValue
  }
  
}

// An service Planning
public final class Activity: AdoptedModel {
  public static let name = "activity"
  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  
  /// Planning's unique identifier.
  public var id: ObjectID?
  /// Planning's unique réference.
  public var ref: String?
  /// A potention planning day title
  public var title: String?
  /// The day of the week in raw value
  public var dow: DayOfWeek.RawValue
  /// Related schedule ID
  public var scheduleID: Schedule.ID
  /// Date time in the morning of the begining of work
  public var startAt: Time
  /// Number of minutes its take from the date begining time.
  public var duration: TimeInterval
  /// Could be startDate and endDate but choosen from - to
  public var fromDate: Date
  public var toDate: Date?
  // If the cost of this activity is more expensif than the usual
  public var cost: Int
  // Due to the time does the law applys a special cost factor ?
  public var factor: Double
  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  
  /// Creates a new `Activity`.
  public init(start: Time, duration: TimeInterval,
              dow: DayOfWeek, schedule: Schedule.ID,
              fromDate: Date = Date(), toDate: Date? = nil, title: String? = nil,
              cost: Int = 0, factor: Double = 1, createdAt : Date = Date(),
              updatedAt: Date? = nil, deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id                 = id
    self.ref          = Utils.newRef(kPlanningReferenceBasePrefix, size: kPlanningReferenceLength)
    self.title        = title
    self.dow          = dow.rawValue
    self.cost         = cost
    self.factor       = factor
    self.scheduleID   = schedule
    self.startAt      = start
    self.duration     = duration
    self.fromDate     = fromDate
    self.toDate       = toDate
    self.createdAt    = createdAt
    self.updatedAt    = updatedAt
    self.deletedAt    = deletedAt
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


/// Allows `Activity` to be used as a Fluent migration.
extension Activity: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    let aTable = AdoptedDatabase.create(Activity.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.title)
      builder.field(for: \.dow)
      builder.field(for: \.cost)
      builder.field(for: \.factor)
      builder.field(for: \.scheduleID)
      builder.field(for: \.startAt)
      builder.field(for: \.duration)
      builder.field(for: \.fromDate)
      builder.field(for: \.toDate)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.reference(from: \Activity.scheduleID, to: \Schedule.id, onUpdate: .noAction, onDelete: .cascade)
    }
    if type(of: conn) == PostgreSQLConnection.self {
      // Only for Post GreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(Activity.name)_id_seq RESTART WITH 10000").all()
    }
    return aTable

  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Activity.self, on: conn)
  }
}

public extension Activity {
  /// Fluent relation to the schedule that is relative to the planning.
  var schedule: Parent<Activity, Schedule> {
    return parent(\.scheduleID)
  }
  
}

/// Allows `Activity` to be used as a dynamic parameter in route definitions.
extension Activity: Parameter { }
