//
//  ServiceAsset.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 17/03/2020.
//

import Foundation
import Vapor
import FluentSQLite

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
  static public var createdAtKey: TimestampKey? { return \.createdAt }
  static public var updatedAtKey: TimestampKey? { return \.updatedAt }
  static public var deletedAtKey: TimestampKey? { return \.deletedAt }
  
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

/// Seed for ServiceAsset
struct SeedServiceAsset: Migration {
  typealias Database = AdoptedDatabase

  static func prepare(on connection: AdoptedConnection) -> Future<Void> {
    
    // For ServiceAsset 1
    let sass1 = ServiceAsset(service: 7, asset: 1, quantity: 2)
    let sass2 = ServiceAsset(service: 7, asset: 4, quantity: 1)
    let sass3 = ServiceAsset(service: 7, asset: 5, quantity: 23)
    let sass4 = ServiceAsset(service: 6, asset: 2, quantity: 6)
    let sass5 = ServiceAsset(service: 6, asset: 3, quantity: 7)
    let sass6 = ServiceAsset(service: 8, asset: 6, quantity: 8)
    let sass7 = ServiceAsset(service: 8, asset: 2, quantity: 9)
    let sass8 = ServiceAsset(service: 1, asset: 7, quantity: 7)
    let sass9 = ServiceAsset(service: 1, asset: 5, quantity: 1)
    let sass10 = ServiceAsset(service: 1, asset: 1, quantity: 5)
    let sass11 = ServiceAsset(service: 1, asset: 8, quantity: 2)
    let sass12 = ServiceAsset(service: 2, asset: 10, quantity: 7)
    let sass13 = ServiceAsset(service: 9, asset: 2, quantity: 8)
    let sass14 = ServiceAsset(service: 9, asset: 7, quantity: 1)
    let sass15 = ServiceAsset(service: 9, asset: 5, quantity: 6)
    let sass16 = ServiceAsset(service: 9, asset: 10, quantity: 10)
    let sass17 = ServiceAsset(service: 3, asset: 9, quantity: 1)
    let sass18 = ServiceAsset(service: 3, asset: 6, quantity: 2)

    _ = sass1.save(on: connection).catch({ (e) in
      print("ERROR SERVICE ASSET LINK 1 ----------")
      print(e)
    }).transform(to: ())
    _ = sass2.save(on: connection).catch({ (e) in
      print("ERROR SERVICE ASSET LINK 2 ----------")
      print(e)
    }).transform(to: ())
    _ = sass3.save(on: connection).catch({ (e) in
       print("ERROR SERVICE ASSET LINK 3 ----------")
       print(e)
     }).transform(to: ())
    _ = sass4.save(on: connection).transform(to: ())
    _ = sass5.save(on: connection).transform(to: ())
    _ = sass6.save(on: connection).transform(to: ())
    _ = sass7.save(on: connection).transform(to: ())
    _ = sass8.save(on: connection).transform(to: ())
    _ = sass9.save(on: connection).transform(to: ())
    _ = sass10.save(on: connection).transform(to: ())
    _ = sass11.save(on: connection).transform(to: ())
    _ = sass12.save(on: connection).transform(to: ())
    _ = sass13.save(on: connection).transform(to: ())
    _ = sass14.save(on: connection).transform(to: ())
    _ = sass15.save(on: connection).transform(to: ())
    _ = sass16.save(on: connection).transform(to: ())
    _ = sass17.save(on: connection).transform(to: ())
    _ = sass18.save(on: connection).transform(to: ())

    return .done(on: connection)
  }
  
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    return .done(on: connection)
  }
}

