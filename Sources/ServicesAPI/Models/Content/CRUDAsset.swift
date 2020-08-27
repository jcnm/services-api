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

/// Allows `ServiceAsset` to be encoded to and decoded from HTTP messages.
extension ServiceAsset: Content { }

/// Allows `Asset` to be encoded to and decoded from HTTP messages.
public extension Asset {
  
  func fullResponse(author: User.ShortPublicResponse,
                    organization: Organization.ShortPublicResponse,
                    sasset: ServiceAsset? = nil,
                    serv: Service.ShortPublicResponse? = nil,
                    ord: Order?,
                    forServices: [Service.ShortPublicResponse] = [],
                    forOrganizations: [Organization.ShortPublicResponse] = [],
                    forUsers: [User.ShortPublicResponse] = []) -> Response.FullPublic
  {
    return Response.FullPublic(id: self.id!, ref: self.ref, oref: self.oref, author: author, organization: organization,title: self.title, slug: self.slugAsset, id_link: sasset?.id, quantity: sasset?.quantity, initialQuantity: nil, label: sasset?.label, service: serv,  duplicated: self.duplicatedID, description: self.description, status: self.status, fromDate: self.fromDate, toDate: self.toDate, cost: self.cost, stock: self.stock, kind: self.kind, unit: APIController.unitMeasures[self.unitID], tva: self.tva, redeemCode: self.redeemCode, redeem: self.redeem, percent: self.percent, orderExceed: self.orderExceed, orderBelow: self.orderBelow, forServices: forServices, forOrganizations: forOrganizations, forUsers: forUsers, toEveryService: self.toEveryService, createdAt: self.createdAt, updatedAt: self.updatedAt, deletedAt: self.deletedAt, errors: nil, succes: nil)
  }
  
  
  func fullResponse(author: User.ShortPublicResponse,
                    organization: Organization.ShortPublicResponse,
                    dasset: DevisAsset? = nil,
                    serv: Service.ShortPublicResponse? = nil,
                    ord: Order?,
                    forServices: [Service.ShortPublicResponse] = [],
                    forOrganizations: [Organization.ShortPublicResponse] = [],
                    forUsers: [User.ShortPublicResponse] = []) -> Response.FullPublic
  {
    return Response.FullPublic(id: self.id!, ref: self.ref, oref: self.oref, author: author, organization: organization,title: self.title, slug: self.slugAsset, id_link: dasset?.id, quantity: dasset?.quantity, initialQuantity: dasset?.initialQuantity, label: dasset?.label, service: serv,  duplicated: self.duplicatedID, description: self.description, status: self.status, fromDate: self.fromDate, toDate: self.toDate, cost: self.cost,  stock: self.stock, kind: self.kind, unit: APIController.unitMeasures[self.unitID], tva: self.tva, redeemCode: self.redeemCode, redeem: self.redeem, percent: self.percent, orderExceed: self.orderExceed, orderBelow: self.orderBelow, forServices: forServices, forOrganizations: forOrganizations, forUsers: forUsers, toEveryService: self.toEveryService, createdAt: self.createdAt, updatedAt: self.updatedAt, deletedAt: self.deletedAt, errors: nil, succes: nil)
  }
  
  static func fullResponse(ass: Asset, author: User.ShortPublicResponse,
                           organization: Organization.ShortPublicResponse,
                           sasset: ServiceAsset? = nil,
                           serv: Service.ShortPublicResponse? = nil,
                           ord: Order?,
                           forServices: [Service.ShortPublicResponse] = [],
                           forOrganizations: [Organization.ShortPublicResponse] = [],
                           forUsers: [User.ShortPublicResponse] = []) -> Response.FullPublic {
    return ass.fullResponse(author: author,  organization: organization, sasset: sasset,
                            serv: serv, ord: ord, forServices: forServices,
                            forOrganizations: forOrganizations, forUsers: forUsers)
  }

  func shortResponse(_ sasset: ServiceAsset? = nil) -> Response.ShortPublic
  {
    return Response.ShortPublic(id: self.id!, ref: self.ref, oref: self.oref, title: self.title, slug: self.slugAsset, id_link: sasset?.id!, quantity: sasset?.quantity, label: sasset?.label, serviceID: sasset?.serviceID, authorID: self.authorID, organizationID: self.organizationID, duplicatedID: self.duplicatedID, description: self.description, status: self.status, fromDate: self.fromDate, toDate: self.toDate, cost: self.cost,
                                 stock: self.stock, kind: self.kind, unit: APIController.unitMeasures[self.unitID], tva: self.tva, redeemCode: self.redeemCode, redeem: self.redeem, percent: self.percent, orderExceed: self.orderExceed, orderBelow: self.orderBelow, forServices: self.forServices, forOrganizations: self.forOrganizations, forUsers: self.forUsers, toEveryService: self.toEveryService, createdAt: self.createdAt, updatedAt: self.updatedAt)
  }
  
  func shortResponse(_ dasset: DevisAsset) -> Response.ShortPublic
  {
    return Response.ShortPublic(id: self.id!, ref: self.ref, oref: self.oref, title: self.title, slug: self.slugAsset, id_link: nil, devis_link: dasset.id!, quantity: dasset.quantity, initialQuantity: dasset.initialQuantity, label: dasset.label, serviceID: nil, devisID: dasset.devisID, authorID: self.authorID, organizationID: self.organizationID, duplicatedID: self.duplicatedID, description: self.description, status: self.status, fromDate: self.fromDate, toDate: self.toDate, cost: self.cost, stock: self.stock, kind: self.kind, unit: APIController.unitMeasures[self.unitID], tva: self.tva, redeemCode: self.redeemCode, redeem: self.redeem, percent: self.percent, orderExceed: self.orderExceed, orderBelow: self.orderBelow, forServices: self.forServices, forOrganizations: self.forOrganizations, forUsers: self.forUsers, toEveryService: self.toEveryService, createdAt: self.createdAt, updatedAt: self.updatedAt)
  }

  static func shortResponse(ass: Asset, _ sasset: ServiceAsset? = nil ) -> Response.ShortPublic {
    return ass.shortResponse(sasset)
  }
  
  struct Create {
    struct LinkService: Content {
      /// author of the asset
      public var authorID: User.ID
      // asset attached service id
      public var serviceID: Service.ID
      // Asset unique ID
      public var assetID: Asset.ID
      // Label
      public var label: String?
    }
    struct LinkDevis: Content {
      /// author of the asset
      public var authorID: User.ID
      // asset attached devis id
      public var devisID: Devis.ID
      // Asset unique ID
      public var assetID: Asset.ID
      // Label
      public var label: String?
    }
    struct LinkOrder: Content   {
      /// author of the asset
      public var authorID: User.ID
      /// author of the asset
      public var orderID: Order.ID
      // Asset unique ID
      public var assetID: Asset.ID?
      // Label
      public var label: String?
    }
    
    struct Entry: Content  {
      // asset attached service id
      public var serviceID: Service.ID?
      /// A potention planning day title
      public var label: String?
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
  }
  
  struct Update{
    struct Entry: Content  {
      public var assetID: Asset.ID?
      /// A potention planning day title
      public var label: String?
      /// author of the asset
      public var authorID: User.ID
      /// Related organization ID
      public var organizationID: Organization.ID
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
    
    struct ForUser: Content  {
      public var assetID: Asset.ID?
      /// A potention planning day title
      public let user: User.ID
    }
    
    struct ForOrganization: Content  {
      public var assetID: Asset.ID?
      /// A potention planning day title
      public let organization: Organization.ID
    }
  }
  
  struct Response: Content {
    public struct ShortPublic: Content {
      /// Asset's unique identifier.
      public var id: Asset.ID
      /// Asset's unique réference.
      public var ref: String
      /// Asset's unique réference across organization owner.
      public var oref: String?
      /// A potention planning day title
      public var title: String?
      /// acces slug
      public var slug: String
      /// Service Asset's unique identifier.
      public var id_link: ServiceAsset.ID?
      /// Service Asset's unique identifier.
      public var devis_link: DevisAsset.ID?
      /// Quantity of asset.
      public var quantity: Int?
      /// Quantity of asset.
      public var initialQuantity: Int?
      /// ServiceAsset's unique réference.
      public var label: String?
      /// Related service id
      public var serviceID: Service.ID?
      /// ID of the  order linked
      public var orderID: Order.ID?
      /// ID of the  devis linked
      public var devisID: Devis.ID?
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
      // Available stock of this present asset
      public var stock: Int
      // What sort of asset is this
      public var kind: Int
      // What unit is used here (iso unit)
      public var unit: UnitMeasure?
      // Sepecifique tva fator 100 18.2 = 1820
      public var tva: Int?
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
    
    public struct FullPublic : Content {
      /// Asset's unique identifier.
      public var id: Asset.ID
      /// Asset's unique réference.
      public var ref: String
      /// Asset's unique réference across organization owner.
      public var oref: String?
      /// author of the asset
      public var author: User.ShortPublicResponse
      /// Related organization original organization ID
      public var organization: Organization.ShortPublicResponse
      /// A potention planning day title
      public var title: String?
      /// acces slug
      public var slug: String
      /// Service Asset's unique identifier.
      public var id_link: ServiceAsset.ID?
      /// Service Asset's unique identifier.
      public var devis_link: DevisAsset.ID?
      /// Quantity of asset.
      public var quantity: Int?
      /// Quantity of asset.
      public var initialQuantity: Int?
      /// ServiceAsset's unique réference.
      public var label: String?
      /// Related service id
      public var service: Service.ShortPublicResponse?
      /// ID of the duplicated asset
      public var duplicated: Asset.ID?
      /// Asset description.
      public var description: String
      public var status: ObjectStatus.RawValue
      /// date where this asset is taking in action
      public var fromDate: Date
      public var toDate: Date?
      // Cost by adding this asset, could be negatif
      public var cost: Double
      // Available stock of this present asset
      public var stock: Int
      // What sort of asset is this
      public var kind: Int
      // What unit is used here (iso unit)
      public var unit: UnitMeasure?
      // Sepecifique tva fator 100 18.2 = 1820
      public var tva: Int?
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
}


