//
//  ServiceAsset.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 17/03/2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kServiceAssetReferenceBasePrefix  = "SAS"
let kServiceAssetReferenceLength = kReferenceDefaultLength
//
// An service ServiceAsset
public final class ServiceAsset: AdoptedPivot {
  public static let name = "serviceasset"
  public typealias Left = Service
  public typealias Right = Asset
  public static var leftIDKey: LeftIDKey = \.serviceID
  public static var rightIDKey: RightIDKey = \.assetID
  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  
  /// ServiceAsset's unique identifier.
  public var id: ObjectID?
  /// A potention planning day title
  public var label: String?
  /// order of the asset linked
  public var orderID: Order.ID?
  /// Related service id
  public var serviceID: Service.ID
  /// ID of the  asset linked
  public var assetID: Asset.ID
  /// quantity of the given asset
  public var quantity: Int

  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `ServiceAsset`.
  public init(service: Service.ID, asset: Asset.ID, label: String? = nil, quantity: Int = 1, order: Order.ID? = nil,
              createdAt : Date = Date(), updatedAt: Date? = nil, deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id               = id
    self.label            = label
    self.serviceID        = service
    self.orderID         = order
    self.assetID         = asset
    self.quantity        = quantity

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


/// Allows `ServiceAsset` to be used as a Fluent migration.
extension ServiceAsset: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(ServiceAsset.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.label)
      builder.field(for: \.orderID)
      builder.field(for: \.serviceID)
      builder.field(for: \.quantity)
      builder.field(for: \.assetID)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.reference(from: \ServiceAsset.assetID,
                        to: \Asset.id,
                        onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \ServiceAsset.orderID,
                        to: \Order.id,
                        onUpdate: .noAction, onDelete: .setNull)
      builder.reference(from: \ServiceAsset.serviceID,
                        to: \Service.id,
                        onUpdate: .noAction, onDelete: .setNull)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(ServiceAsset.self, on: conn)
  }
}

public extension ServiceAsset {
  /// Fluent relation to the schedule that is relative to the planning.
//  var schedule: Parent<ServiceAsset, Schedule> {
//    return parent(\.scheduleID)
//  }
  
}

/// Allows `ServiceAsset` to be used as a dynamic parameter in route definitions.
extension ServiceAsset: Parameter { }

