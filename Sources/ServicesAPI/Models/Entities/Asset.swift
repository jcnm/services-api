//
//  Asset.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 16/03/2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kAssetReferenceBasePrefix  = "ASS"
let kAssetReferenceLength = kReferenceDefaultLength
//

// An service Asset
public final class Asset: AdoptedModel {
  public let name = "asset"
  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  
  /// Asset's unique identifier.
  public var id: ObjectID?
  /// Asset's unique réference.
  public var ref: String
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
  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `Asset`.
  public init(author: User.ID, organization: Organization.ID, description: String, state: ObjectStatus,
               cost: Double, fromDate: Date = Date(), toDate: Date? = nil, title: String? = nil, redeem: Bool = false,
              duplicated: Asset.ID? = nil, redeemCode: String? = nil,
              percent: Bool = false, toEveryService: Bool = false, forUsers: [User.ID] = [],
              forOrganizations: [Organization.ID] = [], forServices: [Service.ID],
              orderExceed: Double? = nil, orderBelow: Double? = nil,
              createdAt : Date = Date(), updatedAt: Date? = nil, deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id               = id
    self.ref              = Utils.newRef(kServiceAssetReferenceBasePrefix, size: kServiceAssetReferenceLength)
    self.title            = title
    self.status           = state.rawValue
    self.organizationID   = organization
    self.authorID         = author
    self.description      = description
    self.redeem           = redeem
    self.redeemCode       = redeemCode
    self.duplicatedID     = duplicated
    self.cost             = cost
    self.fromDate         = fromDate
    self.toDate           = toDate
    self.percent          = percent
    self.toEveryService   = toEveryService
    self.forOrganizations = forOrganizations
    self.forUsers         = forUsers
    self.forServices      = forServices
    self.orderBelow       = orderBelow
    self.orderExceed      = orderExceed
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

/// Allows `Asset` to be used as a Fluent migration.
extension Asset: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(Asset.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.title)
      builder.field(for: \.status)
      builder.field(for: \.cost)
      builder.field(for: \.organizationID)
      builder.field(for: \.authorID)
      builder.field(for: \.description)
      builder.field(for: \.redeem)
      builder.field(for: \.redeemCode)
      builder.field(for: \.duplicatedID)
      builder.field(for: \.fromDate)
      builder.field(for: \.toDate)
      builder.field(for: \.percent)
      builder.field(for: \.toEveryService)
      builder.field(for: \.forOrganizations)
      builder.field(for: \.forUsers)
      builder.field(for: \.forServices)
      builder.field(for: \.orderExceed)
      builder.field(for: \.orderBelow)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.reference(from: \Asset.organizationID,
                        to: \Organization.id,
                        onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \Asset.authorID,
                        to: \User.id,
                        onUpdate: .noAction, onDelete: .setDefault)
      builder.reference(from: \Asset.duplicatedID,
                        to: \Asset.id,
                        onUpdate: .noAction, onDelete: .setNull)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Asset.self, on: conn)
  }
}

public extension Asset {
  /// Fluent relation to the servuces siblings
  var services: Siblings<Asset, Service, ServiceAsset> {
    // Controle to add
    return siblings()
  }
    
    func organizations(req: Request) -> Future<[Organization]>? {
      if self.forOrganizations.isEmpty {
        return nil
      }
      let query = """
      SELECT DISTINCT "organization"."*"
      FROM "organization"
      WHERE ("organization"."id"
      IN (\(forOrganizations.reduce("", { (res, val) -> String in
      "\(val)\(res.isEmpty ? "" : ", \(res)" )"
      }))))
      """
      return req.withNewConnection(to: .psql) { $0.raw( query ).all(decoding: Organization.self) }
    }
  
  func users(req: Request) -> Future<[User]>? {
    if self.forUsers.isEmpty {
      return nil
    }
    let query = """
    SELECT DISTINCT "user"."*"
    FROM "user"
    WHERE ("user"."id"
    IN (\(forUsers.reduce("", { (res, val) -> String in
    "\(val)\(res.isEmpty ? "" : ", \(res)" )"
    }))))
    """
    return req.withNewConnection(to: .psql) { $0.raw( query ).all(decoding: User.self) }
  }
  
  func services(req: Request) -> Future<[Service]>? {
    if self.forServices.isEmpty {
      return nil
    }
    let query = """
    SELECT DISTINCT "service"."*"
    FROM "service"
    WHERE ("service"."id"
    IN (\(forServices.reduce("", { (res, val) -> String in
    "\(val)\(res.isEmpty ? "" : ", \(res)" )"
    }))))
    """
    return req.withNewConnection(to: .psql) { $0.raw( query ).all(decoding: Service.self) }
  }
  }

/// Allows `ServiceAsset` to be used as a dynamic parameter in route definitions.
extension Asset: Parameter { }
