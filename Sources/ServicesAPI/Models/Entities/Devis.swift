//
//  Devis.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 22/12/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kDevisReferenceBasePrefix  = "`DEV`"
let kDevisReferenceLength      = kReferenceDefaultLength

// A services `Devis`
public final class Devis: AdoptedModel {
  public static let name = "devis"

  /// Devis's unique identifier.
  public var id: ObjectID?
  /// Devis attached Order
  public var orderID: Order.ID
  /// Devis Label Ref
  public var label: String
  /// Devis's unique réference.
  public var ref: String
  /// Devis's unique réference into the organization whom emit the Devis.
  public var orgDevisARef: String?
  /// Devis's unique réference into the organization whom validate the Devis.
  public var orgDevisBRef: String?
  /// Devis's unique public key.
  public var DevisPublicKey: String?
  /// Devis's unique private key.
  public var DevisPrivateKey: String?
  
  /// Devis's object
  public var object: String
  /// Devis's execution modality
  public var execution: String
  /// Devis's duration modality
  public var duration: String
  /// Devis's payment modality
  public var payment: String
  /// Devis's cost modality
  public var endDevis: String
  /// Devis's litige modality
  public var litige: String
  /// Devis's lang modality
  public var lang: String
  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?

  public init(label: String, order: Order.ID, object: String,
              execution: String, duration: String, payment: String,
              endDevis: String, litige: String, lang: String,
              createdAt : Date = Date(), updatedAt: Date = Date(),
              deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id         = id
    self.ref        = Utils.newRef(kDevisReferenceBasePrefix, size: kDevisReferenceLength)
    self.orderID    = order
    self.label      = label
    self.object     = object
    self.execution  = execution
    self.duration   = duration
    self.payment    = payment
    self.endDevis  = endDevis
    self.litige       = litige
    self.lang         = lang
    self.createdAt    = createdAt
    self.updatedAt    = updatedAt
    self.deletedAt    = deletedAt
    
  }
}


/// Allows `Devis` to be used as a Fluent migration.
extension Devis: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(Devis.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.orderID)
      builder.field(for: \.label)
      builder.field(for: \.orgDevisARef)
      builder.field(for: \.orgDevisBRef)
      builder.field(for: \.DevisPublicKey)
      builder.field(for: \.DevisPrivateKey)
      builder.field(for: \.object)
      builder.field(for: \.execution)
      builder.field(for: \.duration)
      builder.field(for: \.payment)
      builder.field(for: \.endDevis)
      builder.field(for: \.litige)
      builder.field(for: \.lang)
      
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.reference(from: \Devis.orderID, to: \Order.id, onUpdate: .noAction, onDelete: .noAction)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Devis.self, on: conn)
  }
}


/// Allows `Devis` to be used as a dynamic parameter in route definitions.
extension Devis: Parameter { }
