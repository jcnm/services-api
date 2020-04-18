//
//  Version.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 23/11/2019.
//

import Foundation
import FluentPostgreSQL
import Vapor
import Crypto

/// A model to represent api backend version to every one.
public final class Version: AdoptedModel {
  public static let name = "version"
 
  /// UserToken's unique identifier.
  public var id: ObjectID?
  /// Version name.
  public var module: String
  /// Sem Version Core.
  public var major: Int
  public var minor: Int
  public var patch: Int
  /// Sem Version Core.
  public var build: Int?
  public var release: String?
  public var changelog: String?
  public var versionHash : String
  /// Created date.
  public var createdAt: Date
  /// Updated date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?

  /// Creates a new `UserToken`.
  public init(module: String, major: Int, minor: Int,
              patch: Int = 0, build: Int? = nil, release:String? = nil,
              changelog: String? = nil, createdAt: Date = Date(),
              updatedAt:Date? = nil, deletedAt: Date? = nil, id: ObjectID? = nil) {
    self.id       = id
    self.module   = module
    self.major    = major
    self.minor    = minor
    self.patch    = patch
    self.build    = build
    self.release  = release
    self.changelog = changelog
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.deletedAt = deletedAt
    do {
      self.versionHash = try CryptoRandom().generateData(count: 16).hexEncodedString(uppercase: false)
    } catch {
      self.versionHash = "\(major)\(minor)\(patch)\(String(describing: build))"
    }
  }
  
}
/// Allows `Version` to be used as a Fluent migration.
extension Version: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(Version.self, on: conn) { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.versionHash)
      builder.field(for: \.module)
      builder.field(for: \.major)
      builder.field(for: \.minor)
      builder.field(for: \.patch)
      builder.field(for: \.build)
      builder.field(for: \.release)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.versionHash)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Version.self, on: conn)
  }
}

/// Allows `Version` to be encoded to and decoded from HTTP messages.
extension Version: Content { }

/// Allows `Version` to be used as a dynamic parameter in route definitions.
extension Version: Parameter { }
