//
//  CRUDAsset.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 22/03/2020.
//

import Foundation
import Vapor
import Fluent

/// Allows `Asset` to be encoded to and decoded from HTTP messages.
extension Asset: Content { }

/// Allows `Schedule` to be encoded to and decoded from HTTP messages.

public extension Asset {
  
  func fullResponse(author: User.ShortPublicResponse,
                    organization: Organization.MidPublicResponse,
                    sasset: ServiceAsset? = nil,
                    forServices: [Service.ShortPublicResponse] = [],
                    forOrganizations: [Organization.ShortPublicResponse] = [],
                    forUsers: [User.ShortPublicResponse] = []) -> FullPublicResponse
  {
    return FullPublicResponse(id: self.id!, ref: self.ref, title: self.title, id_link: sasset?.id!, quantity: sasset?.quantity, label: sasset?.label, serviceID: sasset?.serviceID, orderID: sasset?.orderID, author: author, organization: organization , duplicated: nil, description: self.description, status: self.status, fromDate: self.fromDate, toDate: self.toDate, cost: self.cost, redeemCode: self.redeemCode, redeem: self.redeem, percent: self.percent, orderExceed: self.orderExceed, orderBelow: self.orderBelow, forServices: forServices, forOrganizations: forOrganizations, forUsers: forUsers, toEveryService: self.toEveryService, createdAt: self.createdAt, updatedAt: self.updatedAt, deletedAt: self.deletedAt, errors: nil, succes: nil)
    
  }
  
  static func fullResponse(ass: Asset, author: User.ShortPublicResponse,
                           organization: Organization.MidPublicResponse,
                           sasset: ServiceAsset? = nil,
                           forServices: [Service.ShortPublicResponse] = [],
                           forOrganizations: [Organization.ShortPublicResponse] = [],
                           forUsers: [User.ShortPublicResponse] = []) -> FullPublicResponse {
    return ass.fullResponse(author: author,  organization: organization, sasset: sasset, forServices: forServices, forOrganizations: forOrganizations, forUsers: forUsers)
  }
  
  func shortResponse(_ sasset: ServiceAsset? = nil) -> ShortPublicResponse
  {
    return ShortPublicResponse(id: self.id!, ref: self.ref, title: self.title, id_link: sasset?.id!, quantity: sasset?.quantity, label: sasset?.label, serviceID: sasset?.serviceID, orderID: sasset?.orderID, authorID: self.authorID, organizationID: self.organizationID, duplicatedID: self.duplicatedID, description: self.description, status: self.status, fromDate: self.fromDate, toDate: self.toDate, cost: self.cost, redeemCode: self.redeemCode, redeem: self.redeem, percent: self.percent, orderExceed: self.orderExceed, orderBelow: self.orderBelow, forServices: self.forServices, forOrganizations: self.forOrganizations, forUsers: self.forUsers, toEveryService: self.toEveryService, createdAt: self.createdAt, updatedAt: self.updatedAt)
  }
  
  static func shortResponse(ass: Asset, _ sasset: ServiceAsset? = nil) -> ShortPublicResponse {
    return ass.shortResponse(sasset)
  }
  
  struct LinkServiceAsset: Content  {
    /// author of the asset
    public var authorID: User.ID
    /// author of the asset
    public var orderID: Order.ID?
    // asset attached service id
    public var serviceID: Service.ID?
    // Asset unique ID
    public var assetID: Asset.ID?
    // Label
    public var label: String?
  }
  
  struct UpdateLinkServiceAsset: Content  {
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
  
  struct ShortLinkServiceAssetResponse: Content  {
    /// author of the asset
    public var author: User
    // asset attached service
    public var service: Service
    // Asset unique ID
    public var asset : Asset.ShortPublicResponse
    // Label
    public var label: String?
  }

  struct FullLinkServiceAssetResponse: Content  {
    /// author of the asset
    public var author: User
    // asset attached service
    public var service: Service
    // Asset unique ID
    public var asset : Asset.FullPublicResponse
    // Label
    public var label: String?
  }

  struct CreateAsset: Content  {
    // asset attached service id
    public var serviceID: Service.ID?
    /// A potention planning day title
    public var title: String?
    /// author of the asset
    public var authorID: User.ID
    /// Related organization ID
    public var organizationID: Organization.ID
    /// ID of the duplicated asset
    public var duplicatedID: Asset.ID?
    /// Asset description.
    public var description: String
    public var status: ObjectStatus.RawValue
    /// date where this asset is taking in action
    public var fromDate: Date
    public var toDate: Date?
    // Cost by adding this asset, could be negatif
    public var cost: Double
    /// The code if this is redeem
    public var redeemCode: String?
    // Determine if this a redeem
    public var redeem: Bool
    // Determine if the cost is a percent value
    public var percent: Bool
    /// Code reedem if so to add it from the order summit
    /// Condition to valide to apply reedem
    public var orderExceed: Double?
    public var orderBelow: Double?
    public var forServices: [Service.ID]
    public var forOrganizations: [Organization.ID]
    public var forUsers: [User.ID]
    public var toEveryService: Bool
  }
  
  struct UpdateAsset : Content {
    public var id: Asset.ID
    // asset attached service id
    public var serviceID: Service.ID?
    /// A potention planning day title
    public var title: String?
    /// author of the asset
    public var authorID: User.ID
    /// Related organization ID
    public var organizationID: Organization.ID
    /// ID of the duplicated asset
    public var duplicatedID: Asset.ID?
    /// Asset description.
    public var description: String
    public var status: ObjectStatus.RawValue
    /// date where this asset is taking in action
    public var fromDate: Date
    public var toDate: Date?
    // Cost by adding this asset, could be negatif
    public var cost: Double
    /// The code if this is redeem
    public var redeemCode: String?
    // Determine if this a redeem
    public var redeem: Bool
    // Determine if the cost is a percent value
    public var percent: Bool
    /// Code reedem if so to add it from the order summit
    /// Condition to valide to apply reedem
    public var orderExceed: Double?
    public var orderBelow: Double?
    public var forServices: [Service.ID]
    public var forOrganizations: [Organization.ID]
    public var forUsers: [User.ID]
    public var toEveryService: Bool
  }
  
  struct ShortPublicResponse : Content {
    /// Asset's unique identifier.
    public var id: Asset.ID
    /// Asset's unique réference.
    public var ref: String
    /// A potention planning day title
    public var title: String?
    /// Service Asset's unique identifier.
    public var id_link: ServiceAsset.ID?
    /// Quantity of asset.
    public var quantity: Int?
    /// ServiceAsset's unique réference.
    public var label: String?
    /// Related service id
    public var serviceID: Service.ID?
    /// ID of the  asset linked
    public var orderID: Asset.ID?
    /// author of the asset
    public var authorID: User.ID
    /// Related organization ID
    public var organizationID: Organization.ID
    /// ID of the duplicated asset
    public var duplicatedID: Asset.ID?
    /// Asset description.
    public var description: String
    public var status: ObjectStatus.RawValue
    /// date where this asset is taking in action
    public var fromDate: Date
    public var toDate: Date?
    // Cost by adding this asset, could be negatif
    public var cost: Double
    /// The code if this is redeem
    public var redeemCode: String?
    // Determine if this a redeem
    public var redeem: Bool
    // Determine if the cost is a percent value
    public var percent: Bool
    /// Code reedem if so to add it from the order summit
    /// Condition to valide to apply reedem
    public var orderExceed: Double?
    public var orderBelow: Double?
    public var forServices: [Service.ID]
    public var forOrganizations: [Organization.ID]
    public var forUsers: [User.ID]
    public var toEveryService: Bool
    /// Create date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
  }
  
  struct FullPublicResponse : Content {
    /// Asset's unique identifier.
    public var id: Asset.ID
    /// Asset's unique réference.
    public var ref: String
    /// A potention planning day title
    public var title: String?
    /// Service Asset's unique identifier.
    public var id_link: ServiceAsset.ID?
    /// Quantity of asset.
    public var quantity: Int?
    /// ServiceAsset's unique réference.
    public var label: String?
    /// Related service id
    public var serviceID: Service.ID?
    /// ID of the  asset linked
    public var orderID: Asset.ID?
    /// Asset's unique réference.
    /// author of the asset
    public var author: User.ShortPublicResponse
    /// Related organization ID
    public var organization: Organization.MidPublicResponse
    /// ID of the duplicated asset
    public var duplicated: Asset.ShortPublicResponse?
    /// Asset description.
    public var description: String
    public var status: ObjectStatus.RawValue
    /// date where this asset is taking in action
    public var fromDate: Date
    public var toDate: Date?
    // Cost by adding this asset, could be negatif
    public var cost: Double
    /// The code if this is redeem
    public var redeemCode: String?
    // Determine if this a redeem
    public var redeem: Bool
    // Determine if the cost is a percent value
    public var percent: Bool
    /// Code reedem if so to add it from the order summit
    /// Condition to valide to apply reedem
    public var orderExceed: Double?
    public var orderBelow: Double?
    public var forServices: [Service.ShortPublicResponse]
    public var forOrganizations: [Organization.ShortPublicResponse]
    public var forUsers: [User.ShortPublicResponse]
    public var toEveryService: Bool
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


