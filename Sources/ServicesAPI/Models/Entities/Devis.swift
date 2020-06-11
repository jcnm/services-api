//
//  Devis.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 22/12/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kDevisReferenceBasePrefix  = "DEV"
let kDevisReferenceLength      = kReferenceDefaultLength

// A services `Devis`
public final class Devis:     AdoptedModel {
  public static let name      = "devis"

  /// Devis's unique identifier.
  public var id:         ObjectID?
  /// Devis attached Order
  public var serviceID:  Service.ID
  /// Devis Label Ref
  public var label:      String
  /// Devis's unique réference.
  public var ref:        String
  /// Devis's  statut.
  public var status:     ObjectStatus.RawValue
  /// Devis's  draft.
  public var draft:      Int // zero mens not a draft, otherwise, incremente draft iteration
  /// Contract's unique réference into the organization whom emit the Contract.
  public var orgASigned: Bool
  /// Contract's unique réference into the organization whom validate the Contract.
  public var orgBSigned: Bool

  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?

  public init(label: String, service: Service.ID,
              status: ObjectStatus, draft: Int = 1,
              orgASigned: Bool = false, orgBSigned: Bool = false,
              createdAt : Date = Date(), updatedAt: Date = Date(),
              deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id         = id
    self.ref        = Utils.newRef(kDevisReferenceBasePrefix, size: kDevisReferenceLength)
    self.label      = label
    self.serviceID  = service
    self.status     = status.rawValue
    self.draft      = draft
    self.orgASigned = orgASigned
    self.orgBSigned = orgBSigned
    self.createdAt  = createdAt
    self.updatedAt  = updatedAt
    self.deletedAt  = deletedAt
  }
}


/// Allows `Devis` to be used as a Fluent migration.
extension Devis: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    let dTable = AdoptedDatabase.create(Devis.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.serviceID)
      builder.field(for: \.label)
      builder.field(for: \.orgASigned)
      builder.field(for: \.orgBSigned)
      builder.field(for: \.status)
      builder.field(for: \.draft)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.reference(from: \Devis.serviceID, to: \Service.id, onUpdate: .noAction, onDelete: .noAction)
      
    }
    if type(of: conn) == PostgreSQLConnection.self {
      // Only for Post GreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(Devis.name)_id_seq RESTART WITH 5000").all()
    }
    return dTable

  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Devis.self, on: conn)
  }
}


/// Allows `Devis` to be used as a dynamic parameter in route definitions.
extension Devis: Parameter { }
