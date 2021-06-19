//
//  OrganizationContact.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 10/07/2020.
//

import Foundation
import Authentication
import Crypto
import FluentPostgreSQL
import Vapor

let kOCReferenceBasePrefix  = "ORC"
let kOCReferenceLength = 3


/// A relation between organization and user.
public final class OrganizationContact : AdoptedPivot, Auditable {
  public static var auditID = HistoryDataType.organizationcontact.rawValue
  
  /// See `Model`.
  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  public static let name                    = "ocontact"
  public typealias  Left                    = Contact
  public typealias  Right                   = Organization
  public static var leftIDKey: LeftIDKey    = \.contactID
  public static var rightIDKey: RightIDKey  = \.organizationID
  
  /// OrganizationContact's unique identifier.
  public var id: ObjectID?
  /// OrganizationContact's unique réference.
  public var ref: String
  /// A le nom associé à ce contact
  public var label: String
  /// Organization linked.
  public var organizationID: Organization.ID
  /// User linked.
  public var contactID: Contact.ID
  /// Created date.
  public var createdAt: Date?
  /// Updated date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `OrganizationContact`.
  public init(label: String, organization: Organization.ID, contact: Contact.ID,
              createdAt: Date? = Date(), updatedAt: Date? = nil, deletedAt: Date? = nil, id: ObjectID? = nil) {
    self.id             = id
    self.ref            = Utils.newRef(kUOReferenceBasePrefix, size: kUOReferenceLength)
    self.label          = label
    self.organizationID = organization
    self.contactID      = contact
    self.createdAt      = createdAt
    self.updatedAt      = updatedAt
    self.deletedAt      = deletedAt
  }
}

public extension OrganizationContact {
  /// Fluent relation to the user that is linked.
  var contact: Parent<OrganizationContact, Contact> {
    return parent(\.contactID)
  }
  /// Fluent relation to the organization that owns this token.
  var organization: Parent<OrganizationContact, Organization> {
    return parent(\.organizationID)
  }
}


extension OrganizationContact : ModifiablePivot {
  public convenience init(_ left: OrganizationContact.Left, _ right: OrganizationContact.Right) throws {
    self.init(label: "", organization: try right.requireID(), contact: try left.requireID())
  }
}


/// Allows `OrganizationContact` to be used as a Fluent migration.
extension OrganizationContact: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    let uoTable = AdoptedDatabase.create(OrganizationContact.self, on: conn) { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.label)
      builder.field(for: \.contactID)
      builder.field(for: \.organizationID)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.reference(from: \.contactID, to: \Contact.id)
      builder.reference(from: \.organizationID, to: \Organization.id)
    }
    
    if type(of: conn) == PostgreSQLConnection.self {
      // Only for Post GreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(OrganizationContact.name)_id_seq RESTART WITH 500").all()
    }
    return uoTable
  }
  
  public static func revert(on conn: Database.Connection) -> Future<Void> {
    return Database.delete(UserOrganization.self, on: conn)
  }
}
/// Allows `OrganizationContact` to be used as a dynamic parameter in route definitions.
extension OrganizationContact: Parameter { }
