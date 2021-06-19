//
//  DevisAsset.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 13/07/2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kDevisAssetReferenceBasePrefix  = "DAS"
let kDevisAssetReferenceLength      = kReferenceDefaultLength
//
// An service DevisAsset
public final class DevisAsset: AdoptedPivot, Auditable {
public static var auditID = HistoryDataType.devisasset.rawValue

  public static let name  = "devisasset"
  public typealias Left   = Devis
  public typealias Right  = Asset
  public static var leftIDKey: LeftIDKey        = \.devisID
  public static var rightIDKey: RightIDKey      = \.assetID
  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  
  /// ServiceAsset's unique identifier.
  public var id: ObjectID?
  /// A potention planning day title
  public var label: String?
  /// Related service id
  public var devisID: Devis.ID
  /// ID of the  asset linked
  public var assetID: Asset.ID
  /// quantity of the given asset
  public var quantity: Int
  /// origin link ServiceAsset.ID
  public var saLink: ServiceAsset.ID
  /// initial configured quantity of the given asset
  public var initialQuantity: Int
  /// origin service link
  public var serviceID: Service.ID?
  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `ServiceAsset`.
  public init(devis: Devis.ID, asset: Asset.ID, label: String? = nil, saLink: ServiceAsset.ID,
              initialQuantity: Int, serviceID: Service.ID? = nil, quantity: Int = 1, createdAt : Date = Date(),
              updatedAt: Date? = nil, deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id               = id
    self.label            = label
    self.devisID          = devis
    self.assetID          = asset
    self.quantity         = quantity
    self.saLink           = saLink
    self.serviceID        = serviceID
    self.initialQuantity  = initialQuantity
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


/// Allows `DevisAsset` to be used as a Fluent migration.
extension DevisAsset: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    let saTable = AdoptedDatabase.create(DevisAsset.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.label)
      builder.field(for: \.devisID)
      builder.field(for: \.saLink)
      builder.field(for: \.quantity)
      builder.field(for: \.assetID)
      builder.field(for: \.serviceID)
      builder.field(for: \.initialQuantity)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.reference(from: \DevisAsset.assetID,
                        to: \Asset.id,
                        onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \DevisAsset.saLink,
                        to: \ServiceAsset.id,
                        onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \DevisAsset.serviceID,
                        to: \Service.id,
                        onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \DevisAsset.devisID,
                        to: \Devis.id,
                        onUpdate: .noAction, onDelete: .setNull)
    }
    if type(of: conn) == PostgreSQLConnection.self {
      // Only for Post GreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(DevisAsset.name)_id_seq RESTART WITH 10000").all()
    }
    return saTable

  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(DevisAsset.self, on: conn)
  }
}

/// Allows `DevisAsset` to be used as a dynamic parameter in route definitions.
extension DevisAsset: Parameter { }

