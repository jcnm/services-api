//
//  Currency.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 13/03/2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kCurrencyReferenceBasePrefix  = "CUR"
let kCurrencyReferenceLength = 3

public final class Currency : AdoptedModel, Auditable {
  public static var auditID = HistoryDataType.currency.rawValue

  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  public static let name = "currency"
  /// Currency  uniq object ID
  public var id       : ObjectID?
  public var ref      : String
  public var code     : String
  public var symbol   : String
  public var name     : String
  public var usd      : String

  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?

  public static var defaultValue: Currency {
    return Currency(code: "EUR", name: "Euro", symbol: "€", usd: "1.09")
  }
  
  public static var defaultRawValue: String {
    return Currency.defaultValue.code
  }
  
  public var rawValue: String {
    return self.code
  }

  convenience init() {
    self.init(code: "EUR", name: "Euro", symbol: "€", usd: "1.09")
  }
  
  public init(code: String, name:String, symbol: String, usd: String, createdAt : Date = Date(), updatedAt: Date? = nil,
  deletedAt : Date?   = nil, id: ObjectID? = nil) {
    self.id           = id
    self.ref          = Utils.newRef(kCurrencyReferenceBasePrefix, size: kCurrencyReferenceLength)
    self.code         = code
    self.name         = name
    self.symbol       = symbol
    self.usd          = usd
    self.createdAt    = createdAt
    self.updatedAt    = updatedAt
    self.deletedAt    = deletedAt
  }

  public func basics() -> [NamedEmail]{
    return [NamedEmail(label: "Euro", value: "100")]
  }
}

/// Allows `OrderItem` to be used as a Fluent migration.
extension Currency: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    let cTable = AdoptedDatabase.create(Currency.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.code)
      builder.field(for: \.name)
      builder.field(for: \.symbol)
      builder.field(for: \.usd)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.unique(on: \.code)
    }
    if type(of: conn) == PostgreSQLConnection.self {
      // Only for PostGreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(Currency.name)_id_seq RESTART WITH 1000").run()
    }
    return cTable
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Currency.self, on: conn)
  }
}

/// Allows `Currency` to be used as a dynamic parameter in route definitions.
extension Currency: Parameter { }
