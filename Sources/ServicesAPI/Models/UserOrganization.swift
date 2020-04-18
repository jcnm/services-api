//
//  UserOrganization.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 15/11/2019.
//

import Foundation
import Authentication
import Crypto
import FluentPostgreSQL
import Vapor

let kUOReferenceBasePrefix  = "UOR"
let kUOReferenceLength = 3

public enum RoleKind: Int, Codable, ReflectionDecodable, CaseIterable  {
  public static func reflectDecoded() throws -> (RoleKind, RoleKind) {
    return (unknown, director)
    
  }
  
  case unknown     = 0
  case follow     = 1
  case client     = 2
  case collab     = 3
  case financial  = 7
  case manager    = 8
  case director   = 10
  case admin      = 11
  case executive  = 12
  case cto        = 15
  case cpo        = 17
  case cmo        = 19
  case cco        = 21
  case cdo        = 23
  case coo        = 25
  case cfo        = 27
  case ceo        = 32

  public var stringRaw: String {
    switch self {
      case .unknown:
        return "Rôle Inconnue"
      case .follow:
        return "Intéressé"
      case .client:
        return "Client"
      case .collab:
        return "Collaborateur"
      case .financial:
        return "Finance"
      case .manager:
        return "Gestionnaire"
      case .director:
        return "Directeur"
      case .admin:
        return "Administrateur"
      case .executive:
        return "Exécutif"
      case .cto:
        return "CTO"
      case .cpo:
        return "CPO"
      case .cmo:
        return "CTO"
      case .cco:
        return "CEO"
      case .cdo:
        return "CTO"
      case .coo:
        return "CEO"
      case .cfo:
        return "CTO"
      case .ceo:
        return "CEO"
    }
  }
  
  public var textual: String {
    switch self {
      case .unknown:
        return "Rôle Inconnue dans l'organisation"
      case .follow:
        return "Intéressé par les activités de l'organisation"
      case .client:
        return "Client de l'organisation"
      case .collab:
        return "Collaborateur de l'organisation"
      case .financial:
        return "Poste de finance dans l'organisation"
      case .manager:
        return "Poste de gestionnaire dans l'organisation"
      case .director:
        return "Directeur dans l'organisation"
      case .admin:
        return "Poste administratif dans l'organisation"
      case .executive:
        return "Exécutif dans l'organisation"
      case .cto:
        return "Chief Technology Officer (CTO) de l'organisation"
      case .cpo:
        return "Chief Product Officer (CPO) de l'organisation"
      case .cmo:
        return "Chief Marketing Officer (CMO) de l'organisation"
      case .cco:
        return "Chief Communitcations Officer (CCO) de l'organisation"
      case .cdo:
        return "Chief Data Officer (CDO) de l'organisation"
      case .coo:
        return "Chief Operational Officer (COO) de l'organisation"
      case .cfo:
        return "Chief Financial Officer (CFO) de l'organisation"
      case .ceo:
        return "Chief Executive Officer (CEO) de l'organisation"
    }
  }
  
  
  public static var defaultValue: RoleKind {
    return .unknown
  }
  
  public static var defaultRaw: RoleKind.RawValue {
    return defaultValue.rawValue
  }
}

extension Int {
  var orole: RoleKind {
    return RoleKind(rawValue: self) ?? RoleKind.defaultValue
  }
}

/// A relation between organization and user.
public final class UserOrganization : AdoptedPivot {
  /// See `Model`.
  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  public static let name = "uorganization"
  public typealias Left = User
  public typealias Right = Organization
  public static var leftIDKey: LeftIDKey = \.userID
  public static var rightIDKey: RightIDKey = \.organizationID
  
  /// UserOrganization's unique identifier.
  public var id: ObjectID?
  /// UserOrganization's unique réference.
  public var ref: String?
  /// Organization linked.
  public var organizationID: Organization.ID
  /// User linked.
  public var userID: User.ID
  /// Given role
  public var role: RoleKind.RawValue
  /// Created date.
  public var createdAt: Date?
  /// Updated date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `UserOrganization`.
  public init(organization: Organization.ID, user: User.ID, role: RoleKind = .defaultValue,
              createdAt: Date? = Date(), updatedAt: Date? = nil, deletedAt: Date? = nil, id: ObjectID? = nil) {
    self.id             = id
    self.ref            = Utils.newRef(kUOReferenceBasePrefix, size: kUOReferenceLength)
    self.organizationID = organization
    self.userID         = user
    self.role           = role.rawValue
    self.createdAt      = createdAt
    self.updatedAt      = updatedAt
    self.deletedAt      = deletedAt
  }
}

public extension UserOrganization {
  /// Fluent relation to the user that is linked.
  public var user: Parent<UserOrganization, User> {
    return parent(\.userID)
  }
  /// Fluent relation to the organization that owns this token.
  public var organization: Parent<UserOrganization, Organization> {
    return parent(\.organizationID)
  }
}


extension UserOrganization : ModifiablePivot {
  public convenience init(_ left: UserOrganization.Left, _ right: UserOrganization.Right) throws {
    self.init(organization: try right.requireID(), user: try left.requireID(), role: RoleKind.defaultValue)
  }
}


/// Allows `UserToken` to be used as a Fluent migration.
extension UserOrganization: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(UserOrganization.self, on: conn) { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.userID)
      builder.field(for: \.organizationID)
      builder.field(for: \.role)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.reference(from: \.userID, to: \User.id)
      builder.reference(from: \.organizationID, to: \Organization.id)
    }
  }
  
  public static func revert(on conn: Database.Connection) -> Future<Void> {
    return Database.delete(UserOrganization.self, on: conn)
  }
}
/// Allows `UserOrganization` to be used as a dynamic parameter in route definitions.
extension UserOrganization: Parameter { }
