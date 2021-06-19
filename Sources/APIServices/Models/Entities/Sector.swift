//
//  Sector.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 12/11/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kSectorReferenceBasePrefix  = "SEC"
let kSectorReferenceLength = 2

public enum SectorKind: Int, Codable, ReflectionDecodable {
  public static func reflectDecoded() throws -> (SectorKind, SectorKind) {
    return (primary, ternary)  }
  
  case multiple   = 0
  case primary    = 1
  case secondary  = 2
  case ternary    = 3
  
  public static var defaultValue: SectorKind {
    return .multiple
  }
  
  public static var defaultRaw: SectorKind.RawValue {
    return defaultValue.rawValue
  }
}

public extension Int {
  var skind: SectorKind {
    return SectorKind(rawValue: self) ?? SectorKind.defaultValue
  }
  
}

// A sector on indistry activity
final public class Sector: Industrial, AdoptedModel, Auditable {
public static var auditID = HistoryDataType.sector.rawValue

  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  public static let name = "sector"
  
  /// Sector's unique identifier.
  public var id: ObjectID?
  /// Schedule's unique réference.
  public var ref: String?
  /// Sector's unique identifier.
  public var skind: SectorKind.RawValue
  /// Unique CITI CODE string.
  public var citi: String?
  /// Unique SCIAN CODE string.
  public var scian: String?
  /// Unique NACE CODE string.
  public var nace: String
  /// Sector title string.
  public var title: String
  /// sector's description.
  public var description: String
  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `Sector`.
  public init(nace: String, title: String, description: String, kind: SectorKind = SectorKind.defaultValue, scian: String?, citi: String?, createdAt : Date = Date(), updatedAt: Date? = nil, deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id     = id
    self.ref    = Utils.newRef(kSectorReferenceBasePrefix, size: kSectorReferenceLength)
    self.citi   = scian
    self.scian  = scian
    self.nace   = nace
    self.skind   = kind.rawValue
    self.title  = title
    self.description = description
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.deletedAt = deletedAt
  }
  
  func response() throws -> Sector.ShortPublicResponse {
    let resp = Sector.ShortPublicResponse(
      id: self.id, kind: self.skind, citi: self.citi, scian: self.scian,
      nace: self.nace, title: self.title, updatedAt: self.updatedAt)
    return resp
  }
  
  func fullResponse(_ req: Vapor.Request) throws -> Sector.FullPublicResponse {
    let fullResp = Sector.FullPublicResponse(
      id: self.id, kind: self.skind, citi: self.citi, scian: self.scian,
      nace: self.nace, title: self.title, description: self.description,
      createdAt: self.createdAt, updatedAt: self.updatedAt, deletedAt: self.deletedAt)
    return  fullResp
  }
  
}


/// Allows `Sector` to be used as a Fluent migration.
extension Sector: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(Sector.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.citi)
      builder.field(for: \.scian)
      builder.field(for: \.nace)
      builder.field(for: \.skind)
      builder.field(for: \.title)
      builder.field(for: \.description)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.citi)
      builder.unique(on: \.scian)
      builder.unique(on: \.nace)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Sector.self, on: conn)
  }
}

extension Sector : Content {}
/// Allows `Sector` to be encoded to and decoded from HTTP messages.
public extension Sector {
  
  /// Public full representation of an industry data.
  struct FullPublicResponse: Content {
    /// Sector's unique identifier.
    public var id: ObjectID?
    /// Sector's unique identifier.
    public var kind: SectorKind.RawValue
    /// Unique CITI CODE string.
    public var citi: String?
    /// Unique SCIAN CODE string.
    public var scian: String?
    /// Unique NACE CODE string.
    public var nace: String
    /// Industry's title string.
    public var title: String
    /// Industry's description.
    public var description: String
    /// Create date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
    /// Deleted date.
    public var deletedAt: Date?
  }
  
  /// Public full representation of an industry data.
  struct ShortPublicResponse: Content {
    /// Sector's unique identifier.
    public var id: ObjectID?
    /// Sector's unique identifier.
    public var kind: SectorKind.RawValue
    /// Unique CITI CODE string.
    public var citi: String?
    /// Unique SCIAN CODE string.
    public var scian: String?
    /// Unique NACE CODE string.
    public var nace: String
    /// Industry's title string.
    public var title: String
    /// Update date.
    public var updatedAt: Date?
  }
  
}

/// Allows `Sector` to be used as a dynamic parameter in route definitions.
extension Sector: Parameter { }

extension Sector {
  // this Sector's related industries
  public var industries: Children<Sector, Industry> {
    return children(\.sectorID)
  }
  // this Sector's related organizations
  public var organizations: Children<Sector, Organization> {
    return children(\.sectorID)
  }
}

