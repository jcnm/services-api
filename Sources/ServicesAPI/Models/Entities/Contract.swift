//
//  Contract.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 22/12/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kContractReferenceBasePrefix  = "CTR"
let kContractReferenceLength      = kReferenceDefaultLength

// A services contract
public final class Contract: AdoptedModel {
  public static let name = "contract"

  /// Contract's unique identifier.
  public var id: ObjectID?
  /// Contract attached Order
  public var orderID: Order.ID
  /// Contract Label Ref
  public var label: String
  /// Contract's unique réference.
  public var ref: String
  /// Contract's unique réference into the organization whom emit the Contract.
  public var orgContractARef: String?
  /// Contract's unique réference into the organization whom validate the Contract.
  public var orgContractBRef: String?
  /// Contract's unique public key.
  public var contractPublicKey: String?
  /// Contract's unique private key.
  public var contractPrivateKey: String?
  
  /// Contract's object
  public var object: String
  /// Contract's execution modality
  public var execution: String
  /// Contract's duration modality
  public var duration: String
  /// Contract's payment modality
  public var payment: String
  /// Contract's cost modality
  public var endContract: String
  /// Contract's litige modality
  public var litige: String
  /// Contract's lang modality
  public var lang: String
  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?

  public init(label: String, order: Order.ID, object: String,
              execution: String, duration: String, payment: String,
              endContract: String, litige: String, lang: String,
              createdAt : Date = Date(), updatedAt: Date? = nil,
              deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id         = id
    self.ref        = Utils.newRef(kContractReferenceBasePrefix, size: kContractReferenceLength)
    self.orderID    = order
    self.label      = label
    self.object     = object
    self.execution  = execution
    self.duration   = duration
    self.payment    = payment
    self.endContract  = endContract
    self.litige       = litige
    self.lang         = lang
    self.createdAt    = createdAt
    self.updatedAt    = updatedAt
    self.deletedAt    = deletedAt
    
  }
}


/// Allows `Contract` to be used as a Fluent migration.
extension Contract: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(Contract.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.orderID)
      builder.field(for: \.label)
      builder.field(for: \.orgContractARef)
      builder.field(for: \.orgContractBRef)
      builder.field(for: \.contractPublicKey)
      builder.field(for: \.contractPrivateKey)
      builder.field(for: \.object)
      builder.field(for: \.execution)
      builder.field(for: \.duration)
      builder.field(for: \.payment)
      builder.field(for: \.endContract)
      builder.field(for: \.litige)
      builder.field(for: \.lang)
      
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.reference(from: \Contract.orderID, to: \Order.id, onUpdate: .noAction, onDelete: .noAction)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Contract.self, on: conn)
  }
}

/// Allows `Contract` to be used as a dynamic parameter in route definitions.
extension Contract: Parameter { }

