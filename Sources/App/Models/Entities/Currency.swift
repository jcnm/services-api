//
//  Currency.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 13/03/2020.
//

import Foundation
import Vapor
import FluentSQLite

let kCurrencyReferenceBasePrefix  = "CUR"
let kCurrencyReferenceLength = 3

public final class Currency : AdoptedModel  {
  static public var createdAtKey: TimestampKey? { return \.createdAt }
  static public var updatedAtKey: TimestampKey? { return \.updatedAt }
  static public var deletedAtKey: TimestampKey? { return \.deletedAt }
  public static let name = "currency"
  /// Currency  uniq object ID
  public var id: ObjectID?
  public var ref: String
  public var code: String
  public var symbol: String
  public var usd: String

  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?

  public static var defaultValue: Currency {
    return Currency(code: "EUR", symbol: "€", usd: "1.09")
  }
  
  public static var defaultRawValue: String {
    return Currency.defaultValue.code
  }
  
  public var rawValue: String {
    return self.code
  }

  convenience init() {
    self.init(code: "EUR", symbol: "€", usd: "1.09")
  }
  
  init(code: String, symbol: String, usd: String, createdAt : Date = Date(), updatedAt: Date? = nil,
  deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id         = id
    self.ref        = Utils.newRef(kCurrencyReferenceBasePrefix, size: kCurrencyReferenceLength)
    self.code   = code
    self.symbol = symbol
    self.usd    = usd
    self.createdAt    = createdAt
    self.updatedAt    = updatedAt
    self.deletedAt    = deletedAt
  }

}

/// Allows `OrderItem` to be used as a Fluent migration.
extension Currency: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(Currency.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.code)
      builder.field(for: \.symbol)
      builder.field(for: \.usd)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.unique(on: \.code)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Currency.self, on: conn)
  }
}

/// Allows `Currency` to be encoded to and decoded from HTTP messages.
extension Currency: Content { }

/// Allows `Currency` to be used as a dynamic parameter in route definitions.
extension Currency: Parameter { }

/// Seed for BankCard
struct SeedCurrency: Migration {
  typealias Database = AdoptedDatabase
  
  static func prepare(on connection: AdoptedConnection) -> Future<Void> {
    let cur1 = Currency(code: "EUR", symbol: "€", usd: "1.09")
    let cur2 = Currency(code: "USD", symbol: "$", usd: "1.00")
    let cur3 = Currency(code: "BGP", symbol: "£", usd: "1.29")
    let cur4 = Currency(code: "JPY", symbol: "¥", usd: "0.01")
    let cur5 = Currency(code: "CAD", symbol: "$", usd: "0.75")

    _ = cur1.save(on: connection).catch({ (e) in
      print("ERROR CURRENCY----------")
      print(e)
    }).transform(to: ())
    _ = cur2.save(on: connection).catch({ (e) in
      print("ERROR CURRENCY----------")
      print(e)
    }).transform(to: ())
    _ = cur3.save(on: connection).catch({ (e) in
      print("ERROR CURRENCY----------")
      print(e)
    }).transform(to: ())
    _ = cur4.save(on: connection).catch({ (e) in
      print("ERROR CURRENCY----------")
      print(e)
    }).transform(to: ())
    _ = cur5.save(on: connection).catch({ (e) in
      print("ERROR CURRENCY----------")
      print(e)
    }).transform(to: ())

    return .done(on: connection)
    
  }
  
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    return .done(on: connection)
  }
}
