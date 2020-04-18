//
//  Industry.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 13/11/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kIndustryReferenceBasePrefix  = "IND"
let kIndustryReferenceLength      = kReferenceDefaultLength

// An industry activity
final public class Industry: Industrial, AdoptedModel {
  static public var createdAtKey: TimestampKey? { return \.createdAt }
  static public var updatedAtKey: TimestampKey? { return \.updatedAt }
  static public var deletedAtKey: TimestampKey? { return \.deletedAt }
  public static let name = "industry"
  /// Industry's unique identifier.
  public var id: ObjectID?
  /// Organization's unique réference .
  public var ref: String
  /// Organization's unique réference into the organization.
  public var organizationRef: String?
  /// Unique Parent Industry.ID.
  public var parentID: Industry.ID?
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
  /// Reference to sector parent
  public var sectorID: Sector.ID
  /// Created date.
  public var createdAt: Date?
  /// Updated date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `Industry`.
  public init(nace: String, title: String, description: String, sectorID: Sector.ID, parentID: Industry.ID?, scian: String?, citi: String?, createdAt : Date = Date(), updatedAt: Date? = nil, deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id = id
    self.ref        = Utils.newRef(kIndustryReferenceBasePrefix, size: kIndustryReferenceLength)
    self.parentID = parentID
    self.citi = citi
    self.scian = scian
    self.nace = nace
    self.title = title
    self.sectorID = sectorID
    self.description = description
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.deletedAt = deletedAt
  }
}

/// Allows `Industry` to be used as a Fluent migration.
extension Industry: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(Industry.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.citi)
      builder.field(for: \.scian)
      builder.field(for: \.nace)
      builder.field(for: \.title)
      builder.field(for: \.description)
      builder.field(for: \.parentID)
      builder.field(for: \.sectorID)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.reference(from: \Industry.parentID, to: \Industry.id, onUpdate: .noAction, onDelete: .noAction)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Industry.self, on: conn)
  }
}

extension Industry: Content {}

public extension Industry {
  /// Fluent relation to the sector that is relative to this industry.
  var sector: Parent<Industry, Sector> {
    return parent(\.sectorID)
  }
  /// Parent relation between two industries.
  var parent: Parent<Industry, Industry>? {
    return parent(\.parentID)
  }
  /// this industry's related services
  var services: Children<Industry, Service> {
    return children(\.industryID)
  }
  
}

/// Allows `Industry` to be used as a dynamic parameter in route definitions.
extension Industry: Parameter { }
