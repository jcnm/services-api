//
//  Activity.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 18/11/2019.
//

import Foundation
import Vapor
import FluentSQLite

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
  
  var textual: String {
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


extension Int {
  var dow: DayOfWeek {
    return DayOfWeek(rawValue: self) ?? DayOfWeek.defaultValue
  }
  
}

// An service Planning
final public class Activity: AdoptedModel {
  public static let name = "activity"
  static public var createdAtKey: TimestampKey? { return \.createdAt }
  static public var updatedAtKey: TimestampKey? { return \.updatedAt }
  static public var deletedAtKey: TimestampKey? { return \.deletedAt }
  
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
    return AdoptedDatabase.create(Activity.self, on: conn)
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

/// Seed for planning
struct SeedActivity: Migration {
  typealias Database = AdoptedDatabase
  
  static func prepare(on connection: AdoptedConnection) -> Future<Void> {
    
    // For Schedule 1
    let acti1 = Activity(start: "10:10", duration: 180, dow: .monday, schedule: 1)
    let acti2 = Activity(start: "8:30", duration: 240, dow: .tuesday, schedule: 1)
    let acti3 = Activity(start: "8:30", duration: 240, dow: .wednesday, schedule: 1, title: "Some morning activity")
    let acti4 = Activity(start: "14:30", duration: 180, dow: .wednesday, schedule: 1, title: "Some afternoon activity")
    let acti5 = Activity(start: "9:30", duration: 180, dow: .thursday, schedule: 1)
    let acti6 = Activity(start: "14:00", duration: 240, dow: .thursday, schedule: 1, title: "Evening act")
    let acti7 = Activity(start: "8:30", duration: 240, dow: .friday, schedule: 1, title: "Morning Act")
    let acti8 = Activity(start: "15:00", duration: 120, dow: .friday, schedule: 1, title: "Afternoon Act")
    
    _ = acti1.create(on: connection).catch({ (e) in
      print("ERROR ACTIVITY 1 ----------")
      print(e)
    }).transform(to: ())
    _ = acti2.create(on: connection).catch({ (e) in
      print("ERROR ACTIVITY2 ----------")
      print(e)
    }).transform(to: ())
    _ = acti3.create(on: connection).transform(to: ())
    _ = acti4.create(on: connection).transform(to: ())
    _ = acti5.create(on: connection).transform(to: ())
    _ = acti6.create(on: connection).transform(to: ())
    _ = acti7.create(on: connection).transform(to: ())
    _ = acti8.create(on: connection).transform(to: ())
    
    // For Schedule 2
    let acti9 = Activity(start: "9:00", duration: 180, dow: .monday, schedule: 2, title: "activity 1")
    let acti10 = Activity(start: "9:00", duration: 240, dow: .tuesday, schedule: 2, title: "activity 2")
    let acti11 = Activity(start: "4:00", duration: 120, dow: .wednesday, schedule: 2, title: "activity 3")
    let acti12 = Activity(start: "10:00", duration: 120, dow: .wednesday, schedule: 2)
    let acti13 = Activity(start: "17:30", duration: 120, dow: .wednesday, schedule: 2, title: "This sunset activity 1")
    let acti14 = Activity(start: "21:30", duration: 120, dow: .wednesday, schedule: 2, title: "Some evening act 1")
    let acti15 = Activity(start: "9:30", duration: 180, dow: .thursday, schedule: 2, title: "Activity 4")
    let acti16 = Activity(start: "17:00", duration: 240, dow: .thursday, schedule: 2, title: "Evening activity 1")
    let acti17 = Activity(start: "8:30", duration: 240, dow: .friday, schedule: 2, title: "Morning Activity")
    let acti18 = Activity(start: "15:00", duration: 120, dow: .friday, schedule: 2, title: "Afternoon Activ")
    
    _ = acti9.create(on: connection).catch({ (e) in
      print("ERROR ACTIVITY 9 ----------")
      print(e)
    }).transform(to: ())
    _ = acti10.create(on: connection).catch({ (e) in
      print("ERROR ACTIVITY 10 ----------")
      print(e)
    }).transform(to: ())
    _ = acti11.create(on: connection).transform(to: ())
    _ = acti12.create(on: connection).transform(to: ())
    _ = acti13.create(on: connection).transform(to: ())
    _ = acti14.create(on: connection).transform(to: ())
    _ = acti15.create(on: connection).transform(to: ())
    _ = acti16.create(on: connection).transform(to: ())
    _ = acti17.create(on: connection).transform(to: ())
    _ = acti18.create(on: connection).transform(to: ())
    
    // For Schedule 3
    let acti19 = Activity(start: "9:00", duration: 180, dow: .monday, schedule:     3)
    let acti20 = Activity(start: "9:30", duration: 240, dow: .tuesday, schedule:    3)
    let acti21 = Activity(start: "2:00", duration: 320, dow: .wednesday, schedule:  3, title: "This sunrise activity 2")
    let acti22 = Activity(start: "10:30", duration: 60, dow: .wednesday, schedule: 3)
    let acti23 = Activity(start: "17:00", duration: 120, dow: .wednesday, schedule: 3, title: "This sunset activity 2")
    let acti24 = Activity(start: "21:00", duration: 120, dow: .wednesday, schedule: 3, title: "Some evening act 2")
    let acti25 = Activity(start: "8:30", duration: 180, dow: .thursday, schedule:   3)
    let acti26 = Activity(start: "17:00", duration: 240, dow: .thursday, schedule:  3, title: "Evening activity")
    let acti27 = Activity(start: "8:00", duration: 240, dow: .friday, schedule:     3 )
    let acti28 = Activity(start: "15:00", duration: 120, dow: .friday, schedule:    3, title: "Afternoon Activ")
    
    _ = acti19.create(on: connection).catch({ (e) in
      print("ERROR ACTIVITY 19 ----------")
      print(e)
    }).transform(to: ())
    _ = acti20.create(on: connection).catch({ (e) in
      print("ERROR ACTIVITY 20 ----------")
      print(e)
    }).transform(to: ())
    _ = acti21.create(on: connection).transform(to: ())
    _ = acti22.create(on: connection).transform(to: ())
    _ = acti23.create(on: connection).transform(to: ())
    _ = acti24.create(on: connection).transform(to: ())
    _ = acti25.create(on: connection).transform(to: ())
    _ = acti26.create(on: connection).transform(to: ())
    _ = acti27.create(on: connection).transform(to: ())
    _ = acti28.create(on: connection).transform(to: ())
    
    // For Schedule 4
    let acti29 = Activity(start: "10:00", duration: 180, dow: .monday, schedule:     4)
    let acti30 = Activity(start: "9:00", duration: 240, dow: .tuesday, schedule:    4)
    let acti31 = Activity(start: "5:30", duration: 120, dow: .wednesday, schedule:  4)
    let acti32 = Activity(start: "10:00", duration: 120, dow: .wednesday, schedule: 4)
    let acti33 = Activity(start: "17:00", duration: 120, dow: .wednesday, schedule: 4 )
    let acti34 = Activity(start: "21:50", duration: 120, dow: .wednesday, schedule: 4, title: "Evening ")
    let acti35 = Activity(start: "8:00", duration: 240, dow: .thursday, schedule:   4)
    let acti36 = Activity(start: "16:00", duration: 240, dow: .thursday, schedule:  4)
    let acti37 = Activity(start: "8:00", duration: 240, dow: .friday, schedule:     4)
    let acti38 = Activity(start: "15:00", duration: 180, dow: .friday, schedule:    4, title: "Afternoon")
    
    _ = acti29.create(on: connection).catch({ (e) in
      print("ERROR ACTIVITY 29 ----------")
      print(e)
    }).transform(to: ())
    _ = acti30.create(on: connection).catch({ (e) in
      print("ERROR ACTIVITY 30 ----------")
      print(e)
    }).transform(to: ())
    _ = acti31.create(on: connection).transform(to: ())
    _ = acti32.create(on: connection).transform(to: ())
    _ = acti33.create(on: connection).transform(to: ())
    _ = acti34.create(on: connection).transform(to: ())
    _ = acti35.create(on: connection).transform(to: ())
    _ = acti36.create(on: connection).transform(to: ())
    _ = acti37.create(on: connection).transform(to: ())
    _ = acti38.create(on: connection).transform(to: ())
    
    // For Schedule 5
    let acti39 = Activity(start: "9:00", duration: 180, dow: .monday, schedule:     5)
    let acti40 = Activity(start: "9:30", duration: 240, dow: .tuesday, schedule:    5)
    let acti41 = Activity(start: "4:30", duration: 120, dow: .wednesday, schedule:  5)
    let acti42 = Activity(start: "10:30", duration: 120, dow: .wednesday, schedule: 5)
    let acti43 = Activity(start: "17:30", duration: 120, dow: .wednesday, schedule: 5, title: "This sunset activity")
    let acti44 = Activity(start: "21:30", duration: 120, dow: .wednesday, schedule: 5, title: "Some evening act")
    let acti45 = Activity(start: "9:30", duration: 180, dow: .thursday, schedule:   5)
    let acti46 = Activity(start: "17:00", duration: 240, dow: .thursday, schedule:  5, title: "Evening activity")
    let acti47 = Activity(start: "8:30", duration: 240, dow: .friday, schedule:     5, title: "Morning Activity")
    let acti48 = Activity(start: "15:00", duration: 120, dow: .friday, schedule:    5, title: "Afternoon Activ")
    
    _ = acti39.create(on: connection).catch({ (e) in
      print("ERROR ACTIVITY 39 ----------")
      print(e)
    }).transform(to: ())
    _ = acti40.create(on: connection).catch({ (e) in
      print("ERROR ACTIVITY 40 ----------")
      print(e)
    }).transform(to: ())
    _ = acti41.create(on: connection).transform(to: ())
    _ = acti42.create(on: connection).transform(to: ())
    _ = acti43.create(on: connection).transform(to: ())
    _ = acti44.create(on: connection).transform(to: ())
    _ = acti45.create(on: connection).transform(to: ())
    _ = acti46.create(on: connection).transform(to: ())
    _ = acti47.create(on: connection).transform(to: ())
    _ = acti48.create(on: connection).transform(to: ())
    
    // For Schedule 6
    let acti49 = Activity(start: "8:00", duration: 180, dow: .monday, schedule:     6)
    let acti50 = Activity(start: "9:00", duration: 240, dow: .tuesday, schedule:    6, title: "Opening")
    let acti51 = Activity(start: "3:30", duration: 120, dow: .wednesday, schedule:  6, title: "Sunrise activity")
    let acti52 = Activity(start: "9:30", duration: 120, dow: .wednesday, schedule: 6)
    let acti53 = Activity(start: "16:00", duration: 120, dow: .wednesday, schedule: 6, title: "Sunset activity")
    let acti54 = Activity(start: "21:30", duration: 120, dow: .wednesday, schedule: 6, title: "Some evening transit")
    let acti55 = Activity(start: "8:30", duration: 180, dow: .thursday, schedule:   6)
    let acti56 = Activity(start: "16:00", duration: 260, dow: .thursday, schedule:  6, title: "Evening closure")
    let acti57 = Activity(start: "8:30", duration: 240, dow: .friday, schedule:     6, title: "Morning Opening")
    let acti58 = Activity(start: "15:00", duration: 120, dow: .friday, schedule:    6, title: "Afternoon Activ")
    
    _ = acti49.create(on: connection).catch({ (e) in
      print("ERROR ACTIVITY 49 ----------")
      print(e)
    }).transform(to: ())
    _ = acti50.create(on: connection).catch({ (e) in
      print("ERROR ACTIVITY 50 ----------")
      print(e)
    }).transform(to: ())
    _ = acti51.create(on: connection).transform(to: ())
    _ = acti52.create(on: connection).transform(to: ())
    _ = acti53.create(on: connection).transform(to: ())
    _ = acti54.create(on: connection).transform(to: ())
    _ = acti55.create(on: connection).transform(to: ())
    _ = acti56.create(on: connection).transform(to: ())
    _ = acti57.create(on: connection).transform(to: ())
    _ = acti58.create(on: connection).transform(to: ())
    
    // For Schedule 7 --
    let acti99 = Activity(start: "9:00", duration: 180, dow: .monday, schedule:     7)
    let acti100 = Activity(start: "13:30", duration: 240, dow: .monday, schedule:   7)
    let acti101 = Activity(start: "2:30", duration: 120, dow: .tuesday, schedule:   7, title: "Night activity")
    let acti102 = Activity(start: "14:30", duration: 180, dow: .tuesday, schedule:  7, title: "Afternoon activity")
    let acti103 = Activity(start: "5:30", duration: 100, dow: .wednesday, schedule: 7, title: "Morning activity")
    let acti104 = Activity(start: "10:30", duration: 180, dow: .wednesday, schedule: 7, title: "Activity of afternoon")
    let acti105 = Activity(start: "18:30", duration: 240, dow: .wednesday, schedule: 7)
    let acti106 = Activity(start: "17:00", duration: 240, dow: .thursday, schedule: 7, title: "Evening ")
    let acti107 = Activity(start: "8:30", duration: 240, dow: .thursday, schedule: 7, title: "This monrning Act")
    let acti108 = Activity(start: "15:00", duration: 120, dow: .friday, schedule: 7, title: "Afternoon Activ")
    let acti109 = Activity(start: "19:30", duration: 80, dow: .friday, schedule: 7)
    let acti110 = Activity(start: "22:30", duration: 100, dow: .friday, schedule: 7, title: "Fermeture de livraison")
    let acti111 = Activity(start: "8:30", duration: 220, dow: .saturday, schedule: 7, title: "Comptabilité")
    let acti112 = Activity(start: "15:00", duration: 120, dow: .saturday, schedule: 7, title: "Afternoon Closure")
    
    _ = acti99.create(on: connection).catch({ (e) in
      print("ERROR ACTIVITY 99 ----------")
      print(e)
    }).transform(to: ())
    _ = acti100.create(on: connection).transform(to: ())
    _ = acti101.create(on: connection).transform(to: ())
    _ = acti102.create(on: connection).transform(to: ())
    _ = acti103.create(on: connection).transform(to: ())
    _ = acti104.create(on: connection).transform(to: ())
    _ = acti105.create(on: connection).transform(to: ())
    _ = acti106.create(on: connection).transform(to: ())
    _ = acti107.create(on: connection).transform(to: ())
    _ = acti108.create(on: connection).transform(to: ())
    _ = acti109.create(on: connection).transform(to: ())
    _ = acti110.create(on: connection).transform(to: ())
    _ = acti111.create(on: connection).transform(to: ())
    _ = acti112.create(on: connection).transform(to: ())
    
    // For Schedule 8
    
    return .done(on: connection)
  }
  
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    return .done(on: connection)
  }
}

