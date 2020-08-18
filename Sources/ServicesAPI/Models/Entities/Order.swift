//
//  Order.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 18/11/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kOrderReferenceBasePrefix  = "ORD"
let kOrderReferenceLength      = kReferenceDefaultLength

// An service Order
public final class Order: AdoptedModel, Auditable {
public static var auditID = HistoryDataType.order.rawValue

  public static let name = "order"
  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  /// Order's unique identifier.
  public var id: ObjectID?
  /// Order's unique réference.
  public var ref: String
  /// Order's unique slug réference.
  public var slugOrder: String
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
  public init(client: User.ID, organization: Organization.ID, slug: String? = nil,
              billing: Date? = nil, orgARef: String? = nil, orgBRef: String? = nil,
              createdAt : Date = Date(), updatedAt: Date? = nil,
              deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id               = id
    self.ref              = Utils.newRef(kOrderReferenceBasePrefix, size: kOrderReferenceLength)
    let formatSlug    = createdAt.description
      .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).replacingOccurrences(of: "0000", with: "")
      .replacingOccurrences(of: " ", with: "-").replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: "\\", with: "-")
    self.slugOrder = slug == nil ? formatSlug + "-" + self.ref : slug!
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
    let oTable = AdoptedDatabase.create(Order.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.slugOrder)
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
      builder.unique(on: \.slugOrder)
      builder.reference(from: \Order.clientID, to: \User.id, onUpdate: .noAction, onDelete: .noAction)
    builder.reference(from: \Order.organizationID, to: \Organization.id, onUpdate: .noAction, onDelete: .noAction)

    }
    if type(of: conn) == PostgreSQLConnection.self {
      // Only for Post GreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(Order.name)_id_seq RESTART WITH 5000").all()
    }
    return oTable

  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Order.self, on: conn)
  }
}

/// Allows `Order` to be used as a dynamic parameter in route definitions.
extension Order: Parameter { }

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
