//
//  Order.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 18/11/2019.
//

import Foundation
import Vapor
import FluentSQLite


// An service Order
final public class Order: AdoptedModel {
  public static let name = "order"
  static public var createdAtKey: TimestampKey? { return \.createdAt }
  static public var updatedAtKey: TimestampKey? { return \.updatedAt }
  static public var deletedAtKey: TimestampKey? { return \.deletedAt }
  /// Order's unique identifier.
  public var id: ObjectID?
  /// Order's unique réference.
  public var ref: String?
  /// Order's unique réference into the organization A requiring services.
  public var organizationARef: String?
  /// Order's unique réference into the organization B validating services.
  public var organizationBRef: String?
  /// date of contracting  payment requiere
  public var billingDeadLine: Date?
  /// Order made by client/author  ID
  public var clientID: User.ID
  /// Order organization  ID
  public var organizationID: Organization.ID

  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `Order`.
  public init(client: User.ID, organization: Organization.ID, billing: Date? = nil, orgARef: String? = nil, orgBRef: String? = nil, createdAt : Date = Date(), updatedAt: Date? = nil,
              deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id               = id
    self.billingDeadLine  = billing
    self.clientID         = client
    self.organizationID       = organization
    self.organizationARef     = orgARef
    self.organizationBRef     = orgBRef
    self.createdAt            = createdAt
    self.updatedAt            = updatedAt
    self.deletedAt            = deletedAt
  }
}


/// Allows `Order` to be used as a Fluent migration.
extension Order: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(Order.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.billingDeadLine)
      builder.field(for: \.ref)
      builder.field(for: \.organizationARef)
      builder.field(for: \.organizationBRef)
      builder.field(for: \.organizationID)
      builder.field(for: \.clientID)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.unique(on: \.organizationARef)
      builder.unique(on: \.organizationBRef)
      builder.reference(from: \Order.clientID, to: \User.id, onUpdate: .noAction, onDelete: .noAction)
    builder.reference(from: \Order.organizationID, to: \Organization.id, onUpdate: .noAction, onDelete: .noAction)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Order.self, on: conn)
  }
}

public extension Order {
  /// Fluent relation to the client user who is ordering this command .
  var client: Parent<Order, User> {
    return parent(\.clientID)
  }
  
  /// this order's related schedules link
  var schedules: Siblings<Order, Schedule, OrderItem> {
    return siblings()
  }
  
  /// this order's related schedules link
  var items: Children<Order, OrderItem> {
    return children(\OrderItem.orderID)
  }
}


/// Allows `Order` to be encoded to and decoded from HTTP messages.
extension Order: Content { }

/// Allows `Order` to be used as a dynamic parameter in route definitions.
extension Order: Parameter { }

/// Seed for Order
struct SeedOrder: Migration {
  typealias Database = AdoptedDatabase
  
  static func prepare(on connection: AdoptedConnection) -> Future<Void> {
    let order1 = Order(client: 7, organization: 3)
    let order2 = Order(client: 7, organization: 27)
    
    _ = order1.save(on: connection).catch({ (e) in
      print("ERROR ORD----------")
      print(e)
    }).transform(to: ())
    _ = order2.save(on: connection).transform(to: ())
//    if #available(OSX 10.15, *) {
//      let order2 = Order(client: 5, billing: Date().advanced(by: 500000), createdAt: Date().advanced(by: 100000), updatedAt: Date().advanced(by: 100000))
//      let order3 = Order(client: 2, billing: Date().advanced(by: 500000), createdAt: Date().advanced(by: 100000), updatedAt: Date().advanced(by: 100000))
//      let order4 = Order(client: 4, billing: Date().advanced(by: 500000), createdAt: Date().advanced(by: 100000), updatedAt: Date().advanced(by: 100000))
//      let order5 = Order(client: 7, billing: Date().advanced(by: 500000), createdAt: Date().advanced(by: 100000), updatedAt: Date().advanced(by: 100000))
//      let order6 = Order(client: 3, billing: Date().advanced(by: 100000), createdAt: Date().advanced(by: 100000), updatedAt: Date().advanced(by: 100000))
//      let order7 = Order(client: 5, billing: Date().advanced(by: 400000), createdAt: Date().advanced(by: 100000), updatedAt: Date().advanced(by: 100000))
//      let order8 = Order(client: 4, billing: Date().advanced(by: 700000))
//    _ = order2.save(on: connection).transform(to: ())
//    _ = order3.save(on: connection).transform(to: ())
//    _ = order4.save(on: connection).transform(to: ())
//    _ = order5.save(on: connection).transform(to: ())
//    _ = order6.save(on: connection).transform(to: ())
//    _ = order7.save(on: connection).transform(to: ())
//    _ = order8.save(on: connection).transform(to: ())
//    } else
    
      let order3 = Order(client: 5, organization: 3, billing: Date())
      let order4 = Order(client: 2, organization: 5, billing: Date())
//      let order4 = Order(client: 2, billing: Date())
//      let order5 = Order(client: 2, billing: Date())
//      let order6 = Order(client: 3, billing: Date())
//      let order7 = Order(client: 5, billing: Date())
//      let order8 = Order(client: 4, billing: Date())
    _ = order3.save(on: connection).transform(to: ())
    _ = order4.save(on: connection).transform(to: ())
//    _ = order4.save(on: connection).transform(to: ())
//    _ = order5.save(on: connection).transform(to: ())
//    _ = order6.save(on: connection).transform(to: ())
//    _ = order7.save(on: connection).transform(to: ())
//    _ = order8.save(on: connection).transform(to: ())
    
    return .done(on: connection)
  }
  
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    return .done(on: connection)
  }
}

