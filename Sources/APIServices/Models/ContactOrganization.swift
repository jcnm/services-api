//
//  ContactOrganization.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 07/12/2019.
//

import Foundation
import Fluent
import Vapor

/// A relation between organization and user.
public final class ContactOrganization : AdoptedPivot , Auditable {
public static var auditID = HistoryDataType.organizationcontact.rawValue

  /// See `Model`.
  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  public static let name = "corganization"
  public typealias Left = Contact
  public typealias Right = Organization
  public static var leftIDKey: LeftIDKey = \.contactID
  public static var rightIDKey: RightIDKey = \.organizationID
  
  /// ContactOrganization's unique identifier.
  public var id: ObjectID?
  /// Organization linked.
  public var organizationID: Organization.ID
  /// Contact linked.
  public var contactID: Contact.ID
  /// Given role
  public var label: String
  /// Created date.
  public var createdAt: Date?
  /// Updated date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  

}


public extension ContactOrganization {
  /// Fluent relation to the contact that is linked.
  var contact: Parent<ContactOrganization, Contact> {
    return parent(\.contactID)
  }
  /// Fluent relation to the organization that owns this token.
  var organization: Parent<ContactOrganization, Organization> {
    return parent(\.organizationID)
  }
}

