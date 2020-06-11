//
//  BankCard.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 22/12/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kBCardReferenceBasePrefix  = "BKD"
let kBCardReferenceLength = 3

///
///The card brand or network. Typically used in the response. The possible values are:
public enum BCardKind: Int, Codable, CaseIterable {
  case visa         = 0 //. Visa card.
  case mastercard   = 1 //. MasterCard card.
  case discover     = 2 //. Discover card.
  case amex         = 3 //. American Express card.
  case solo         = 4 //. Solo debit card.
  case jcb          = 5 //. Japan Credit Bureau card.
  case star         = 6 //. Military Star card.
  case delta        = 7 //. Delta Airlines card.
  case cbswitch     = 8  //. Switch credit card.
  case maestro      = 9 //. Maestro credit card.
  case cb_nationale = 10   //. Carte Bancaire (CB) credit card.
  case configoga    = 11   //. Configoga credit card.
  case confidis     = 12   //. Confidis credit card.
  case electron     = 13   //. Visa Electron credit card.
  case cetelem      = 14   //. Cetelem credit card.
  case china_union_pay  = 15 //. China union pay credit card.
  
  public static var defaultValue: BCardKind {
    return .visa
  }
  
  public static var defaultRaw: BCardKind.RawValue {
    return defaultValue.rawValue
  }
}

// A services BankCard
public final class BankCard: AdoptedModel {
  public static let name = "bankcard"
  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  /// Bank Card uniq object ID
  public var id: ObjectID?
  /// Unique référence of this object
  public var ref: String
  /// Organization owner ID
  public var organizationID: Organization.ID
  /// User / Organization 's Label Ref
  public var label: String
  /// Bank Card type
  public var ctype: BCardKind.RawValue
  /// Owner name
  public var nameOwner: String
  /// Nickname Owner
  public var nicknameOwner: String
  /// Currency  of the card
  public var currency: Currency.ID
  /// Card number
  public var number: String
  /// Expiration date in forme : ^[0-9]{4}-(0[1-9]|1[0-2])$
  public var expiry: String
  /// The three- or four-digit security code of the card.
  /// Also known as the CVV, CVC, CVN, CVE, or CID.
  public var securityCode: String
  /// re-usable indication (true = reusable, false one use)
  public var reusable: Bool = false
  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `BankCard`.
  public init(label: String, organization: Organization.ID,
              name: String, givenName: String, number: String,
              expiry: String, securityCode: String, reusable: Bool = false,
              ckind: BCardKind = .defaultValue,
              currency: Currency.ID,
              createdAt : Date = Date(), updatedAt: Date? = nil,
              deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id         = id
    self.ref        = Utils.newRef(kBCardReferenceBasePrefix, size: kBCardReferenceLength)
    self.organizationID = organization
    self.label        = label
    self.ctype       = ckind.rawValue
    self.nameOwner     = name
    self.nicknameOwner = givenName
    self.currency     = currency 
    self.number       = number
    self.expiry       = expiry
    self.securityCode = securityCode
    self.reusable     = reusable
    self.updatedAt    = updatedAt
    self.deletedAt    = deletedAt
    self.createdAt    = createdAt
  }
}

/// Allows `OrderItem` to be used as a Fluent migration.
extension BankCard: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    let bcTable = AdoptedDatabase.create(BankCard.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.ctype)
      builder.field(for: \.label)
      builder.field(for: \.currency)
      builder.field(for: \.organizationID)
      builder.field(for: \.nameOwner)
      builder.field(for: \.nicknameOwner)
      builder.field(for: \.number)
      builder.field(for: \.expiry)
      builder.field(for: \.reusable)
      builder.field(for: \.securityCode)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.reference(from: \BankCard.organizationID, to: \Organization.id, onUpdate: .noAction, onDelete: .noAction)

    }
    if type(of: conn) == PostgreSQLConnection.self {
      // Only for Post GreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(BankCard.name)_id_seq RESTART WITH 1000").all()
    }
    return bcTable

  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(BankCard.self, on: conn)
  }
}

/// Allows `BankCard` to be used as a dynamic parameter in route definitions.
extension BankCard: Parameter { }
