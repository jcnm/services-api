//
//  CRUDSchedule.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 05/01/2020.
//

import Foundation
import Vapor
import Fluent



/// Allows `Schedule` to be encoded to and decoded from HTTP messages.
extension Schedule: Content { }


/// Allows `Schedule` to be encoded to and decoded from HTTP messages.

public extension Schedule {
  
  
  func fullResponse(user: User.ShortPublicResponse, service: Service.ShortPublicResponse) -> FullPublicResponse
  {
    return FullPublicResponse(id: self.id!, ref: self.ref, orgScheduleARef: self.orgScheduleARef, orgScheduleBRef: self.orgScheduleBRef, label: self.label, service: service, owner: user, state: self.state, description: self.description, activities: nil, orders: nil, createdAt: self.createdAt, updatedAt: self.updatedAt, deletedAt: self.deletedAt, errors: nil, succes: nil)
  }
  
  static func fullResponse(sch: Schedule, user: User.ShortPublicResponse, service: Service.ShortPublicResponse) -> FullPublicResponse {
    return sch.fullResponse(user: user, service: service)
  }
  
  func midResponse() -> Schedule.MidPublicResponse
  {
    return Schedule.MidPublicResponse(id: self.id!, ref: self.ref, orgScheduleARef: self.orgScheduleARef, orgScheduleBRef: self.orgScheduleBRef, label: self.label, serviceID: self.serviceID, ownerID: self.ownerID, state: self.state, description: self.description, activities: nil, createdAt: self.createdAt, updatedAt: self.updatedAt, deletedAt: self.deletedAt, errors: nil, succes: nil)
  }
  
  static func midResponse(sch: Schedule) -> MidPublicResponse {
    return sch.midResponse()
  }
  
  func shortResponse() -> ShortPublicResponse
  {
    return ShortPublicResponse(id: self.id, ref: self.ref, orgScheduleARef: self.orgScheduleARef, orgScheduleBRef: self.orgScheduleBRef, label: self.label, serviceID: self.serviceID, ownerID: self.ownerID, state: self.state, description: self.description, updatedAt: self.updatedAt, errors: nil, succes: nil)
  }
  
  static func shortResponse(sch: Schedule) -> ShortPublicResponse {
    return sch.shortResponse()
  }
  
  struct CreateSchedule: Content  {
    /// user's unique identifier.
    public var ownerID: User.ID
    /// service's unique id.
    public var serviceID: Service.ID
    public var label: String
    public var orgScheduleARef: String?
    public var description: String?
  }
  
  struct UpdateSchedule : Content {
    /// Schedule's unique identifier.
    public var id: Schedule.ID?
    /// Schedule's unique réference into the organization whom create the schedule.
    public var orgScheduleARef: String?
    /// Schedule's unique réference into the organization whom validate the schedule.
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
  }
  
  
  struct ShortPublicResponse : Content {
    /// Schedule's unique identifier.
    public var id: Schedule.ID?
    /// Schedule's unique réference.
    public var ref: String
    /// Schedule's unique réference into the organization whom create the schedule.
    public var orgScheduleARef: String?
    /// Schedule's unique réference into the organization whom validate the schedule.
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
    /// Update date.
    public var updatedAt: Date?
    public var errors: [String: String]?
    /// Successes codes and messages
    public var succes: [String: String]?
  }
  
  
  struct MidPublicResponse : Content {
    /// Schedule's unique identifier.
    public var id: Schedule.ID
    /// Schedule's unique réference.
    public var ref: String
    /// Schedule's unique réference into the organization whom create the schedule.
    public var orgScheduleARef: String?
    /// Schedule's unique réference into the organization whom validate the schedule.
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
    /// Planning list
    public var activities: [Activity]?
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
  
  struct FullPublicResponse : Content {
    /// Schedule's unique identifier.
    public var id: Schedule.ID
    /// Schedule's unique réference.
    public var ref: String
    /// Schedule's unique réference into the organization whom create the schedule.
    public var orgScheduleARef: String?
    /// Schedule's unique réference into the organization whom validate the schedule.
    public var orgScheduleBRef: String?
    /// A potention planning day title
    public var label: String?
    /// Date time in the morning of the begining of work
    public var service: Service.ShortPublicResponse
    /// Schedule definition author
    public var owner: User.ShortPublicResponse
    /// State of the schedule (validated by the responsable of the service)
    public var state: ObjectStatus.RawValue
    /// Schedule description
    public var description: String
    /// Planning list
    public var activities: [Activity]?
    /// Planning list
    public var orders: [Order]?
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


