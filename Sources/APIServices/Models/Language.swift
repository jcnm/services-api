//
//  Language.swift
//  
//
//  Created by J. Charles NJANDA M. on 19/08/2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kLanguageReferenceBasePrefix  = "LNG"
let kLanguageReferenceLength = 3

public final class Language : AdoptedModel, Auditable {
  public static var auditID = HistoryDataType.language.rawValue

  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  public static let name = "language"
  /// Language  uniq object ID
  public var id       : ObjectID?
  public var ref      : String
  public var code     : String
  public var iso      : String
  public var name     : String
  public var intl     : String

  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?

  public static var defaultValue: Language {
    return Language(code: "", name: "Francais", iso: "fra", intl: "Fr-fr")
  }
  
  public static var defaultRawValue: String {
    return Language.defaultValue.intl
  }
  
  public var rawValue: String {
    return self.intl
  }

  convenience init() {
    self.init(code: "", name: "Francais", iso: "fra", intl: "Fr-fr")
  }
  
  public init(code: String, name:String, iso: String, intl: String, createdAt : Date = Date(), updatedAt: Date? = nil,
  deletedAt : Date?   = nil, id: ObjectID? = nil) {
    self.id           = id
    self.ref          = Utils.newRef(kLanguageReferenceBasePrefix, size: kLanguageReferenceLength)
    self.code         = code
    self.name         = name
    self.iso          = iso
    self.intl         = intl
    self.createdAt    = createdAt
    self.updatedAt    = updatedAt
    self.deletedAt    = deletedAt
  }
}

/// Allows `Language` to be used as a Fluent migration.
extension Language: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    let cTable = AdoptedDatabase.create(Language.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.code)
      builder.field(for: \.name)
      builder.field(for: \.iso)
      builder.field(for: \.intl)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.unique(on: \.intl)
    }
    if type(of: conn) == PostgreSQLConnection.self {
      // Only for PostGreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(Language.name)_id_seq RESTART WITH 100").run()
    }
    return cTable
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Language.self, on: conn)
  }
}

/// Allows `Language` to be used as a dynamic parameter in route definitions.
extension Language: Parameter { }
