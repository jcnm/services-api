//
//  OrderItem.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 18/11/2019.
//

import Foundation
import Vapor
import FluentSQLite

let kOrderItemReferenceBasePrefix   = "OI"
let kOrderItemReferenceLength       = kReferenceDefaultLength

// A service OrderItem
final public class OrderItem: AdoptedPivot {
  public typealias Left = Schedule
  public typealias Right = Order
  public static var leftIDKey: LeftIDKey = \.scheduleID
  public static var rightIDKey: RightIDKey = \.orderID
  
  static public var createdAtKey: TimestampKey? { return \.createdAt }
  static public var updatedAtKey: TimestampKey? { return \.updatedAt }
  static public var deletedAtKey: TimestampKey? { return \.deletedAt }
  public static let name = "orderitem"
  /// OrderItem's unique identifier.
  public var id: ObjectID?
  /// OrderItem's unique réference.
  public var ref: String
  /// Schedule id
  public var scheduleID: Schedule.ID
  /// Order  ID
  public var orderID: Order.ID
  /// Quantity of this schedule
  public var quantity: Int = 1

  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `OrderItem`.
  public init(order: Order.ID, schedule: Schedule.ID, quantity: Int = 1,
              createdAt : Date = Date(), updatedAt: Date? = nil,
              deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id           = id
    self.ref          = Utils.newRef(kOrderItemReferenceBasePrefix, size: kOrderItemReferenceLength)
    self.scheduleID   = schedule
    self.orderID      = order
    self.quantity     = quantity
    self.updatedAt    = updatedAt
    self.deletedAt    = deletedAt
    self.createdAt    = createdAt
  }
}


/// Allows `OrderItem` to be used as a Fluent migration.
extension OrderItem: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(OrderItem.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.orderID)
      builder.field(for: \.ref)
      builder.field(for: \.scheduleID)
      builder.field(for: \.quantity)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.reference(from: \OrderItem.scheduleID, to: \Schedule.id, onUpdate: .noAction, onDelete: .setNull)
      builder.reference(from: \OrderItem.orderID, to: \Order.id, onUpdate: .noAction, onDelete: .setNull)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(OrderItem.self, on: conn)
  }
}

extension OrderItem : ModifiablePivot {
  public convenience init(_ left: OrderItem.Left, _ right: OrderItem.Right) throws {
    self.init(order: try left.requireID(), schedule: try right.requireID())
  }
}

/// Allows `OrderItem` to be encoded to and decoded from HTTP messages.
extension OrderItem: Content { }

/// Allows `OrderItem` to be used as a dynamic parameter in route definitions.
extension OrderItem: Parameter { }

/// Seed for OrderItem
struct SeedOrderItem: Migration {
  typealias Database = AdoptedDatabase
  
  static func prepare(on connection: AdoptedConnection) -> Future<Void> {
    let oitem   = OrderItem(order: 1, schedule: 1)
    let oitem1  = OrderItem(order: 1, schedule: 4)
    let oitem2  = OrderItem(order: 2, schedule: 2)
    let oitem3  = OrderItem(order: 3, schedule: 3)
    let oitem4  = OrderItem(order: 7, schedule: 4)
    
    _ = oitem.save(on: connection).catch({ (e) in
      print("ERROR OITEM 1----------")
      print(e)
    }).transform(to: ())
    _ = oitem1.save(on: connection).catch({ (e) in
      print("ERROR OITEM 2----------")
      print(e)
    }).transform(to: ())
    _ = oitem2.save(on: connection).transform(to: ())
    _ = oitem3.save(on: connection).transform(to: ())
    _ = oitem4.save(on: connection).transform(to: ())
    return .done(on: connection)
  }
  
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    return .done(on: connection)
  }
}
