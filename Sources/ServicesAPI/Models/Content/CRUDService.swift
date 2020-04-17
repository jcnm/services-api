//
//  CRUDService.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 05/01/2020.
//

import Foundation
import Vapor
import Fluent
import Paginator

/// Allows `Service` to be encoded to and decoded from HTTP messages.
extension Service: Content { }


/// Allows `Schedule` to be encoded to and decoded from HTTP messages.

public extension Service {
  
  func fullResponse(ind: Industry.ShortPublicResponse, user: User.ShortPublicResponse, org: Organization.ShortPublicResponse, parent: Service.ShortPublicResponse? = nil, place: Place? = nil) -> FullPublicResponse
  {
    let price = nil == self.price ? nil : String(format: "%.2f", self.price!)
    return FullPublicResponse(id: self.id, label: self.label, ref: self.ref!, orgServiceRef: self.orgServiceRef, state: self.status, billing: self.billing, target: self.target, description: self.description, shortLabel: self.shortLabel, price: price, intengibility: self.intengibility, inseparability: self.inseparability, variability: self.variability, perishability: self.perishability, ownership: self.ownership, reliability: self.reliability, disponibility: self.disponibility, pricing: self.pricing, unbelliable: self.nobillable, negociable: self.negotiable, location: place, geoPerimeter: self.geoPerimeter, openOn: self.openOn, endOn: self.endOn, parent: parent, author: user, industry: ind, organization: org, scores: nil, createdAt: self.createdAt, updatedAt: self.updatedAt, deletedAt: self.deletedAt, errors: nil, succes: nil)
  }
  
  static func fullResponse(serv: Service, ind: Industry.ShortPublicResponse, user: User.ShortPublicResponse, org: Organization.ShortPublicResponse, parent: Service.ShortPublicResponse? = nil) -> FullPublicResponse {
    return serv.fullResponse(ind: ind, user: user, org: org, parent: parent)
  }
  
  
  func midResponse(ind: Industry.ShortPublicResponse, user: User.ShortPublicResponse,
                   org: Organization.ShortPublicResponse, place: Place? = nil) -> MidPublicResponse
  {
    let price = nil == self.price ? nil : String(format: "%.2f", self.price!)
    return MidPublicResponse(id: self.id, label: self.label, ref: self.ref!, orgServiceRef: self.orgServiceRef, state: self.status, billing: self.billing, target: self.target, description: self.description, shortLabel: self.shortLabel, price: price, intengibility: self.intengibility, inseparability: self.inseparability, variability: self.variability, perishability: self.perishability, ownership: self.ownership, reliability: self.reliability, disponibility: self.disponibility, pricing: self.pricing, unbelliable: self.nobillable, negociable: self.negotiable, location: place, geoPerimeter: self.geoPerimeter, openOn: self.openOn, endOn: self.endOn, parentID: self.parentID, author: user, industry: ind, organization: org, createdAt: self.createdAt, updatedAt: self.updatedAt, errors: nil, succes: nil)
  }
  
  static func midResponse(serv: Service, ind: Industry.ShortPublicResponse, user: User.ShortPublicResponse, org: Organization.ShortPublicResponse, parent: ShortPublicResponse? = nil) -> MidPublicResponse {
    return serv.midResponse(ind: ind, user: user, org: org)
  }
  

  func shortResponse() -> ShortPublicResponse {
    let price = nil == self.price ? nil : String(format: "%.2f", self.price!)
    return ShortPublicResponse(id: self.id, label: self.label, ref: self.ref!, state: self.status, billing: self.billing, target: self.target, description: self.description, shortLabel: self.shortLabel, price: price, authorID: self.authorID, industryID: self.industryID, organizationID: self.organizationID, updatedAt: self.updatedAt)
  }
  
  static func shortResponse(serv: Service) -> ShortPublicResponse {
    return serv.shortResponse()
  }

  struct CreateService: Content  {
    /// Organization's unique identifier.
    public var userID: User.ID
    /// Organization connected id.
    public var organizationID: Organization.ID
    public var label: String
    /// short cut name.
    public var shortLabel: String
    /// Organization size type.
    public var orgServiceRef: String?
    /// Billing mode.
    public var billingMode: BillingPlan
    /// Unbillable Services.
    public var freeService: String? // bool
    /// negociable.
    public var negociablePrice: String? // bool
    /// Service price
    public var price: String 
    /// Organization kind.
    public var target: ServiceTarget
    /// Service Parent Service ID.
    public var parentID: Service.ID?
    /// Service industry ID.
    public var industryID: Industry.ID 
    /// Organization's description.
    public var description: String
    /// location.
    public var location: Place.ID?
    /// activity perimeter.
    public var activityPerimeter: Int?
    /// activity begin date.
    public var serviceOpenedAt: String?
    /// activity ended date.
    public var serviceEndedAt: String?
  }

  struct UpdateService : Content {
    /// Service's unique identifier.
    public var id: Service.ID?
    /// location attached place.
    public var locationID: Place.ID
    /// Service Parent Service
    public var parentID: Service.ID?
    /// Service definition's author
    public var authorID: User.ID
    /// Attached Industry.
    public var industryID: Industry.ID
    /// Attached organization.
    public var organizationID: Organization.ID
    /// Service label (full name of service)
    public var label: String
    /// Service unique reference
    public var ref: String
    /// Service organization reference
    public var orgServiceRef: String?
    /// State of the service (validated by the responsable / owner of the organization)
    public var state: ObjectStatus.RawValue
    /// Billing plan by default direct : one shot
    public var billing: BillingPlan.RawValue
    public var target: ServiceTarget.RawValue
    /// description of the industry
    public var description: String
    /// Short label service
    public var shortLabel: String
    /// Service Price
    public var price: String?
    /// Organization's intengibility score
    public var intengibility: Int?
    /// Organization's intengibility score
    public var inseparability: Int?
    /// Organization's variaability score
    public var variability: Int?
    /// Organization's perishability score
    public var perishability: Int?
    /// Organization's ownership score
    public var ownership: Int?
    /// Organization's reliability score
    public var reliability: Int?
    /// Organization's disponibility score
    public var disponibility: Int?
    /// Organization's pricing score
    public var pricing: Int?
    /// Unbillable Services.
    public var unbelliable: Bool // bool
    /// negociable.
    public var negociable: Bool // bool
    /// activity perimeter in kilometer.
    public var geoPerimeter: Int
    /// activity begin date.
    public var openOn: Date
    /// activity end date.
    public var endOn: Date?
    /// Create date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
    /// Errors  codes and messages
    public var errors: [String: String]?
    /// Successes codes and messages
    public var succes: [String: String]?
  }
  
  struct ScoreAverage: Content {
      /// Score count
    public var tgeneral: Int?
    /// Organization's intengibility score
    public var tintengibility: Int?
    /// Organization's intengibility score
    public var tinseparability: Int?
    /// Organization's variability score
    public var tvariability: Int?
    /// Organization's perishability score
    public var tperishability: Int?
    /// Organization's ownership score
    public var townership: Int?
    /// Organization's reliability score
    public var treliability: Int?
    /// Organization's disponibility score
    public var tdisponibility: Int?
    /// Organization's pricing score
    public var tpricing: Int?
    
    public var ageneral: Double?
    /// Organization's intengibility score
    public var aintengibility: Double?
    /// Organization's intengibility score
    public var ainseparability: Double?
    /// Organization's variability score
    public var avariability: Double?
    /// Organization's perishability score
    public var aperishability: Double?
    /// Organization's ownership score
    public var aownership: Double?
    /// Organization's reliability score
    public var areliability: Double?
    /// Organization's disponibility score
    public var adisponibility: Double?
    /// Organization's pricing score
    public var apricing: Double?

  }
  

  struct ShortPublicResponse : Content {
    /// Service's unique identifier.
    public var id: ObjectID?
    /// Service label (full name of service)
    public var label: String
    /// Service unique reference
    public var ref: String
    /// Service organization reference
    public var orgServiceRef: String?
    /// State of the service (validated by the responsable / owner of the organization)
    public var state: ObjectStatus.RawValue
    /// Billing plan by default direct : one shot
    public var billing: BillingPlan.RawValue
    public var target: ServiceTarget.RawValue
    public var scoreAverage: ScoreAverage?
    /// description of the industry
    public var description: String
    /// Short label service
    public var shortLabel: String
    /// Service Price
    public var price: String?
    /// Service definition's author
    public var authorID: User.ID
    /// Attached Industry.
    public var industryID: Industry.ID
    /// Attached organization.
    public var organizationID: Organization.ID
    /// Update date.
    public var updatedAt: Date?
    /// Errors  codes and messages
    public var errors: [String: String]?
    /// Successes codes and messages
    public var succes: [String: String]?
  }
 
  struct MidPublicResponse : Content {
    /// Service's unique identifier.
    public var id: Service.ID?
    /// Service label (full name of service)
    public var label: String
    /// Service unique reference
    public var ref: String
    public var scoreAvg: ScoreAverage?
    /// Service organization reference
    public var orgServiceRef: String?
    /// State of the service (validated by the responsable / owner of the organization)
    public var state: ObjectStatus.RawValue
    /// Billing plan by default direct : one shot
    public var billing: BillingPlan.RawValue
    public var target: ServiceTarget.RawValue
    public var scoreAverage: ScoreAverage?
    /// description of the industry
    public var description: String
    /// Short label service
    public var shortLabel: String
    /// Service Price
    public var price: String?
    /// Organization's intengibility score
    public var intengibility: Int?
    /// Organization's intengibility score
    public var inseparability: Int?
    /// Organization's variability score
    public var variability: Int?
    /// Organization's perishability score
    public var perishability: Int?
    /// Organization's ownership score
    public var ownership: Int?
    /// Organization's reliability score
    public var reliability: Int?
    /// Organization's disponibility score
    public var disponibility: Int?
    /// Organization's pricing score
    public var pricing: Int?
    /// Unbillable Services.
    public var unbelliable: Bool // bool
    /// negociable.
    public var negociable: Bool // bool
    /// location.
    public var location: Place?
    /// activity perimeter in kilometer.
    public var geoPerimeter: Int
    /// activity begin date.
    public var openOn: Date
    /// activity end date.
    public var endOn: Date?
    /// Service Parent Service
    public var parentID: Service.ID?
    /// Service definition's author
    public var author: User.ShortPublicResponse
    /// Attached Industry.
    public var industry: Industry.ShortPublicResponse
    /// Attached organization.
    public var organization: Organization.ShortPublicResponse
    public var children: [Service.ID]?
    public var schedules: [Schedule.ID]?
    public var assets: [Asset.ShortPublicResponse]?
    public var scores: OffsetPaginator<Score.MidPublicResponse>?
    /// Create date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
    /// Errors  codes and messages
    public var errors: [String: String]?
    /// Successes codes and messages
    public var succes: [String: String]?
  }


struct FullPublicResponse : Content {
  /// Service's unique identifier.
  public var id: Service.ID?
  /// Service label (full name of service)
  public var label: String
  /// Service unique reference
  public var ref: String
  /// Service organization reference
  public var orgServiceRef: String?
  /// State of the service (validated by the responsable / owner of the organization)
  public var state: ObjectStatus.RawValue
  /// Billing plan by default direct : one shot
  public var billing: BillingPlan.RawValue
  public var target: ServiceTarget.RawValue
  public var scoreAverage: ScoreAverage?
  /// description of the industry
  public var description: String
  /// Short label service
  public var shortLabel: String
  /// Service Price
  public var price: String?
  /// Organization's intengibility score
  public var intengibility: Int?
  /// Organization's intengibility score
  public var inseparability: Int?
  /// Organization's variability score
  public var variability: Int?
  /// Organization's perishability score
  public var perishability: Int?
  /// Organization's ownership score
  public var ownership: Int?
  /// Organization's reliability score
  public var reliability: Int?
  /// Organization's disponibility score
  public var disponibility: Int?
  /// Organization's pricing score
  public var pricing: Int?
  /// Unbillable Services.
  public var unbelliable: Bool // bool
  /// negociable.
  public var negociable: Bool // bool
  /// location.
  public var location: Place?
  /// activity perimeter in kilometer.
  public var geoPerimeter: Int
  /// activity begin date.
  public var openOn: Date
  /// activity end date.
  public var endOn: Date?
  /// Service Parent Service
  public var parent: Service.ShortPublicResponse?
  /// Service definition's author
  public var author: User.ShortPublicResponse
  /// Attached Industry.
  public var industry: Industry.ShortPublicResponse
  /// Attached organization.
  public var organization: Organization.ShortPublicResponse
  public var children: [Service.ShortPublicResponse]?
  public var schedules: [Schedule.MidPublicResponse]?
  public var assets: [Asset.ShortPublicResponse]?
  public var scores: OffsetPaginator<Score.MidPublicResponse>?
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


