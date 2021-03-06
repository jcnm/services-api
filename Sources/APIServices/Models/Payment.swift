//
//  Payment.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 18/11/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kPaymentReferenceBasePrefix  = "PYT"
let kPaymentReferenceLength = 3

public enum PaymentMethod: Int, Codable {
  case card     = 0
  case bank     = 1
  case paypal   = 2
  case amazon   = 3
  case check    = 4
  case balance  = 6
  case account  = 7
  
  public static var defaultValue: PaymentMethod {
    return .card
  }
  public static var defaultRaw: PaymentMethod.RawValue {
    return defaultValue.rawValue
  }
}

// A service Payment
public final class Payment: AdoptedModel, Auditable {
public static var auditID = HistoryDataType.payment.rawValue

  public static let name = "payment"
  
  static public var createdAtKey: TimestampKey? { return \.createdAt }
  static public var updatedAtKey: TimestampKey? { return \.updatedAt }
  static public var deletedAtKey: TimestampKey? { return \.deletedAt }
  /// Order's unique identifier.
  public var id: ObjectID?
  /// Schedule's unique réference.
  public var ref: String
  /// Payment's unique slug réference.
  public var slugPayment: String
  /// Schedule's unique réference.
  public var method: PaymentMethod.RawValue
  /// Organization Ref
  public var organizationRef: String?
  /// Organization  ID
  public var organizationID: Organization.ID
  /// Online methods
  ///
  public var token: String?
  public var tokenURL: String?
  
  /// Card methods
  ///
  public var cardID: BankCard.ID?
  /// User who signed the payement ID
  public var authorID: User.ID
  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `Payment`.
  public init(user: User.ID, organization: Organization.ID,
              card: BankCard.ID? = nil,  method: PaymentMethod = .defaultValue,
              slug: String? = nil, token: String? = nil, tokenURL: String? = nil,
              createdAt : Date = Date(), updatedAt: Date? = nil,
              deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id         = id
    self.ref        = Utils.newRef(kPaymentReferenceBasePrefix, size: kPaymentReferenceLength)
    let formatSlug  = createdAt.description
      .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).replacingOccurrences(of: "0000", with: "")
      .replacingOccurrences(of: " ", with: "-").replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: "\\", with: "-")
    self.slugPayment    = slug == nil ? formatSlug + "-" + self.ref : slug!
    self.organizationID = organization
    self.authorID     = user
    self.method       = method.rawValue
    self.updatedAt    = updatedAt
    self.deletedAt    = deletedAt
    self.createdAt    = createdAt
  }
}

/// Allows `OrderItem` to be used as a Fluent migration.
extension Payment: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    let pTable = AdoptedDatabase.create(Payment.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.slugPayment)
      builder.field(for: \.method)
      builder.field(for: \.authorID)
      builder.field(for: \.organizationRef)
      builder.field(for: \.organizationID)
      builder.field(for: \.cardID)
      builder.field(for: \.token)
      builder.field(for: \.tokenURL)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.unique(on: \.slugPayment)
      builder.reference(from: \Payment.organizationID, to: \Organization.id, onUpdate: .noAction, onDelete: .setNull)
      builder.reference(from: \Payment.cardID, to: \BankCard.id, onUpdate: .noAction, onDelete: .noAction)
    }

    if type(of: conn) == PostgreSQLConnection.self {
      // Only for Post GreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(Payment.name)_id_seq RESTART WITH 500").all()
    }
    return pTable
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Payment.self, on: conn)
  }
}

/// Allows `OrderItem` to be used as a dynamic parameter in route definitions.
extension Payment: Parameter { }
