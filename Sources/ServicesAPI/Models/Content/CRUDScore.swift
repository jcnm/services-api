//
//  CRUDScore.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 25/02/2020.
//

import Foundation
import Vapor
import Fluent



/// Allows `Score` to be encoded to and decoded from HTTP messages.
extension Score: Content { }

/// Allows `Score` to be encoded to and decoded from HTTP messages.

public extension Score {
  func shortResponse(user: User) -> ShortPublicResponse {
    return ShortPublicResponse(id: self.id!, ref: self.ref, status: self.status, author: user.shortResponse(), orderID: self.orderID, serviceID: self.serviceID, general: self.general, intengibility: self.intengibility, inseparability: self.inseparability, variability: self.variability, perishability: self.perishability, ownership: self.ownership, reliability: self.reliability, disponibility: self.disponibility, pricing: self.pricing, createdAt: self.createdAt, updatedAt: self.updatedAt)
  }
  
  static func shortResponse(score: Score, user: User)
    -> ShortPublicResponse { score.shortResponse(user: user) }
  
  func midResponse(user: User) -> MidPublicResponse {
    return MidPublicResponse(id: self.id!, ref: self.ref, status: self.status, author: user.shortResponse(), orderID: self.orderID, serviceID: self.serviceID, general: self.general, intengibility: self.intengibility, inseparability: self.inseparability, variability: self.variability, perishability: self.perishability, ownership: self.ownership, reliability: self.reliability, disponibility: self.disponibility, pricing: self.pricing, comment: self.comment, createdAt: self.createdAt, updatedAt: self.updatedAt)
  }
  
  static func midResponse(score: Score, user: User)
    -> MidPublicResponse { score.midResponse(user: user) }
  
  struct LinkServiceScore: Content  {
    /// author of the asset
    public var authorID: User.ID
    // asset attached service id
    public var serviceID: Service.ID
    // Asset unique ID
    public var assetID: Asset.ID?
    // Label
    public var label: String?
  }
  
  struct UpdateLinkServiceScore: Content  {
    public var id: ServiceAsset.ID
    /// author of the asset
    public var authorID: User.ID
    // asset attached service id
    public var serviceID: Service.ID
    // Asset unique ID
    public var assetID: Asset.ID?
    // Label
    public var label: String?
  }
  
  struct ShortLinkServiceScoreResponse: Content  {
    /// author of the asset
    public var author:          User
    // asset attached service
    public var orderID:         Order?
    // Score unique ID
    public var score :          Score.ShortPublicResponse
    // Label
    public var label:           String?
  }
  
  struct FullLinkServiceScoreResponse: Content  {
    /// author of the asset
    public var author:        User.FullPublicResponse
    // asset attached service
    public var service:       Service.FullPublicResponse
    // Asset unique ID
    public var score :        Score.FullPublicResponse
    // Label
    public var label:         String?
  }
  
  struct CreateScore: Content  {
    // service's unique id
    public var serviceID:       Service.ID
    public var orderID:         Order.ID?
    public var authorID:        User.ID
    /// Nine notation criteria
    public var general:         Int
    public var intengibility:   Int?
    public var inseparability:  Int?
    public var variability:     Int?
    public var perishability:   Int?
    public var ownership:       Int?
    public var reliability:     Int?
    public var disponibility:   Int?
    public var pricing:         Int?
    
    public var comment:         String?
  }
  
  struct UpdateScore: Content {
    /// Activity's unique identifier.
    public var id:              Score.ID
    public var serviceID:       Service.ID
    public var orderID:         Order.ID?
    public var authorID:        User.ID
    /// Nine notation criteria
    public var general:         Int
    public var intengibility:   Int?
    public var inseparability:  Int?
    public var variability:     Int?
    public var perishability:   Int?
    public var ownership:       Int?
    public var reliability:     Int?
    public var disponibility:   Int?
    public var pricing:         Int?
    
    public var comment:         String?
  }
  
  struct ShortPublicResponse: Content {
    /// Activity's unique identifier.
    public var id:                Activity.ID
    /// Activity's unique réference.
    public var ref:               String?
    public var status:            ObjectStatus.RawValue
    public var author:            User.ShortPublicResponse
    public var orderID:           Order.ID?
    public var serviceID:         Service.ID?
    /// Nine notation criteria
    public var general:           Int
    public var intengibility:     Int?
    public var inseparability:    Int?
    public var variability:       Int?
    public var perishability:     Int?
    public var ownership:         Int?
    public var reliability:       Int?
    public var disponibility:     Int?
    public var pricing:           Int?
    
    /// Create date.
    public var createdAt:         Date?
    /// Update date.
    public var updatedAt:         Date?
  }
  
  struct MidPublicResponse: Content {
    /// Activity's unique identifier.
    public var id:                Activity.ID
    /// Activity's unique réference.
    public var ref:               String?
    public var status:            ObjectStatus.RawValue
    public var author:            User.ShortPublicResponse
    public var orderID:           Order.ID?
    public var serviceID:         Service.ID
    /// Nine notation criteria
    public var general:           Int
    public var intengibility:     Int?
    public var inseparability:    Int?
    public var variability:       Int?
    public var perishability:     Int?
    public var ownership:         Int?
    public var reliability:       Int?
    public var disponibility:     Int?
    public var pricing:           Int?
    public var comment:           String?
    /// Create date.
    public var createdAt:         Date?
    /// Update date.
    public var updatedAt:         Date?
    /// Deleted date.
    public var deletedAt:         Date?
    
    /// Errors  codes and messages
    public var errors:            [String: String]?
    /// Successes codes and messages
    public var succes:            [String: String]?
  }
  
  struct FullPublicResponse: Content {
    /// Activity's unique identifier.
    public var id:                Activity.ID
    /// Activity's unique réference.
    public var ref:               String?
    public var status:            ObjectStatus.RawValue
    public var author:            User.ShortPublicResponse
    public var order:             Order?
    public var service:           Service.ShortPublicResponse
    /// Nine notation criteria
    public var general:           Int
    public var intengibility:     Int?
    public var inseparability:    Int?
    public var variability:       Int?
    public var perishability:     Int?
    public var ownership:         Int?
    public var reliability:       Int?
    public var disponibility:     Int?
    public var pricing:           Int?
    public var comment:           String?
    /// Create date.
    public var createdAt:         Date?
    /// Update date.
    public var updatedAt:         Date?
    /// Deleted date.
    public var deletedAt:         Date?
    
    /// Errors  codes and messages
    public var errors:            [String: String]?
    /// Successes codes and messages
    public var succes:            [String: String]?
  }
}


