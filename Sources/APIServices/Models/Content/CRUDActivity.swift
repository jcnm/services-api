//
//  CRUDActivity.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 25/02/2020.
//

import Foundation
import Vapor
import Fluent




/// Allows `Activity` to be encoded to and decoded from HTTP messages.
extension Activity: Content { }

/// Allows `Schedule` to be encoded to and decoded from HTTP messages.
public extension Activity {
  
  func fullResponse(schedule: Schedule.ShortPublicResponse) -> FullPublicResponse
  {
    return FullPublicResponse(id: self.id!, ref: self.ref, title: self.title, dow: self.dow, startAt: self.startAt, duration: self.duration, cost: self.cost, factor: self.factor,  schedule: schedule, fromDate: self.fromDate, toDate: self.toDate, createdAt: self.createdAt, updatedAt: self.updatedAt, deletedAt: self.deletedAt, errors: nil, succes: nil)
  }
  
  static func fullResponse(act: Activity, schedule: Schedule.ShortPublicResponse) -> FullPublicResponse {
    return act.fullResponse(schedule: schedule)
  }
  
  func shortResponse() -> ShortPublicResponse
  {
    return ShortPublicResponse(id: self.id, ref: self.ref, title: self.title, dow: self.dow, startAt: self.startAt, duration: self.duration, cost: self.cost, factor: self.factor, scheduleID: self.scheduleID, fromDate: self.fromDate, toDate: self.toDate, createdAt: self.createdAt, updatedAt: self.updatedAt)
  }
  
  static func shortResponse(sch: Activity) -> ShortPublicResponse {
    return sch.shortResponse()
  }
  
  struct CreateActivity: Content  {
    // schedule's unique id
    public var scheduleID: Schedule.ID
    /// The day of the week in raw value
    public var dow: DayOfWeek
    public var title: String?
    // If the cost of this activity is more expensif than the usual
    public var cost: Int?
    // Due to the time does the law applys a special cost factor ?
    public var factor: Double?
    public var startAt: Time
    public var endAt: Time
    /// Could be startDate and endDate but choosen from - to
    public var fromDate: String?
    public var toDate: String?
  }
  
  struct UpdateActivity : Content {
    /// Activity's unique identifier.
    public var id: Activity.ID
    /// A potention activity day title
    public var title: String?
    /// The day of the week in raw value
    public var dow: DayOfWeek.RawValue
    /// Date time in the morning of the begining of work
    public var startAt: Time
    /// Number of minutes its take from the date begining time.
    public var duration: TimeInterval
    // If the cost of this activity is more expensif than the usual
    public var cost: Int
    // Due to the time does the law applys a special cost factor ?
    public var factor: Double
    /// Activity's schedule.
    public var scheduleID: Schedule.ID
    /// Could be startDate and endDate but choosen from - to
    public var fromDate: String
    public var toDate: String?
  }
  
  struct ShortPublicResponse : Content {
    /// Activity's unique identifier.
    public var id: Activity.ID?
    /// Activity's unique réference.
    public var ref: String?
    /// A potention activity day title
    public var title: String?
    /// The day of the week in raw value
    public var dow: DayOfWeek.RawValue
    /// Date time in the morning of the begining of work
    public var startAt: Time
    /// Number of minutes its take from the date begining time.
    public var duration: TimeInterval
    // If the cost of this activity is more expensif than the usual
    public var cost: Int
    // Due to the time does the law applys a special cost factor ?
    public var factor: Double
    /// Activity's schedule.
    public var scheduleID: Schedule.ID
    /// Could be startDate and endDate but choosen from - to
    public var fromDate: Date
    public var toDate: Date?
    /// Create date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
    
  }
  
  struct FullPublicResponse : Content {
    /// Activity's unique identifier.
    public var id: Activity.ID
    /// Activity's unique réference.
    public var ref: String?
    /// A potention activity day title
    public var title: String?
    /// The day of the week in raw value
    public var dow: DayOfWeek.RawValue
    /// Date time in the morning of the begining of work
    public var startAt: Time
    /// Number of minutes its take from the date begining time.
    public var duration: TimeInterval
    // If the cost of this activity is more expensif than the usual
    public var cost: Int
    // Due to the time does the law applys a special cost factor ?
    public var factor: Double
    /// Activity's schedule.
    public var schedule: Schedule.ShortPublicResponse
    /// Could be startDate and endDate but choosen from - to
    public var fromDate: Date
    public var toDate: Date?
    /// Create date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
    /// Deleted date.
    public var deletedAt: Date?
    
    /// Errors  codes and messages
    public var errors: [String: String]?
    /// Successes codes and messages
    public var succes: [String: String]?
  }
}


