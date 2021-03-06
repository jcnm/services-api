//
//  User.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 11/11/2019.
//

import Foundation
import Authentication
//import FluentPostgreSQL
import FluentPostgreSQL
import Vapor

let kUserReferenceBasePrefix  = "USR"
let kUserReferenceLength      = kReferenceDefaultLength

/** Account Type using &#x60;UserKind&#x60;
 with these values:
 * 0 : **Services user**
 * 1 : **analyst**
 * 2 : **moderator**
 * 3 : **financial**
 * 4 : **manager**
 * 5 : **admin**
 * 8 : **bbrother**  */

public enum StaffUserRole: Int, Codable, Comparable, ReflectionDecodable {
  public static func reflectDecoded() throws -> (StaffUserRole, StaffUserRole) {
    return (user, bbrother)
  }
  
  public static func < (lhs: StaffUserRole, rhs: StaffUserRole) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
  
  case user       = 0
  case analyst    = 1
  case moderator  = 2
  case financial  = 3
  case manager    = 4
  case admin      = 5 // manager of manager
  case bbrother   = 8 // a tiny of us (one or two persons)
  
  public static var defaultValue : StaffUserRole {
    return .user
  }
  public static var defaultRaw : StaffUserRole.RawValue {
    return defaultValue.rawValue
  }
  
  public static var min : StaffUserRole.RawValue {
    return StaffUserRole.user.rawValue
  }
  public static var max : StaffUserRole.RawValue {
    return StaffUserRole.bbrother.rawValue
  }
  
  public var isNotStaff: Bool { return self == .user }
  public var isAnalyst: Bool { return self == .analyst }
  public var isModerator: Bool { return self == .moderator }
  public var isFinancial: Bool { return self == .financial }
  public var isManager: Bool { return self == .manager }
  public var isAdministrator: Bool { return self == .admin }
  public var isBigBrother: Bool { return self == .bbrother }
  
}

extension Int {
  var staff: StaffUserRole {
    return StaffUserRole(rawValue: self) ?? StaffUserRole.defaultValue
  }
  
}
/// A registered user, capable of owning todo items.
public final class User:  AdoptedModel, Auditable {
  public static var auditID = HistoryDataType.user.rawValue
  public static let name = "user"
  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  /// Can be `nil` if the object has not been saved yet.
  public var id: User.ID?
  /// User's unique réference.
  public var ref: String
  /// User's unique réference into the organization.
  public var orgUserRef: String?  
  /** Usual login name */
  public var login: String
  /** User primary e-mail **/
  public var email: String
  /** User old e-mail when needed to change **/
  public var oldEmail: String?
  /** User new e-mail when needed to change **/
  public var newEmail: String?
  public var emailChangeDate: Date?
  public var emailChangeToken: String?
  /// BCrypt hash of the user's password.
  public var passwordHash: String
  /// old BCrypt hash of the user's password.
  public var oldPasswordHash: String?
  /// new BCrypt hash of the user's password.
  public var newPasswordHash: String?
  public var passwordChangeDate: Date?
  public var passwordChangeToken: String?
  /** User avatar uri */
  public var avatar: AbsolutePath?
  /** User staff status */
  public var staff: StaffUserRole.RawValue
  /// User state if staging, online etc
  public var state: ObjectStatus.RawValue
  //  /// User role
  //  public var role: UserRole
  /// Associated profil
  public var profileID: Contact.ID
  /// main organization for this user
  public var mainOrganizationID: Organization.ID?
  /** Creation date */
  public var createdAt: Date?
  /** Updated date */
  public var updatedAt: Date?
  /** Deleted date */
  public var deletedAt: Date?
  
  /// Creates a new `User`.
  public init(login: String, email: String, passwordHash: String,
              profile: Contact.ID, staff: StaffUserRole = .defaultValue,
              state: ObjectStatus = .defaultValue, avatar: String? = nil,
              orgUserRef: String? = nil, createdAt : Date = Date(),
              updatedAt: Date? = nil, deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id = id
    self.ref   = Utils.newRef(kUserReferenceBasePrefix, size: kUserReferenceLength)
    self.login = login
    self.email = email
    self.passwordHash = passwordHash
    self.avatar = avatar
    self.staff = staff.rawValue
    self.state = state.rawValue
    self.orgUserRef = orgUserRef
    self.profileID    = profile
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.deletedAt = deletedAt
  }
}

extension User : Validatable {
  /// See `Validatable`.
  public static func validations() throws -> Validations<User> {
    // define validations
    var validations = Validations(User.self)
    try validations.add(\.staff, .range(StaffUserRole.defaultValue.rawValue...StaffUserRole.admin.rawValue) || .range(StaffUserRole.admin.rawValue...StaffUserRole.bbrother.rawValue))
    //    try validations.add(\User.avatar, .url)
    try validations.add(\.login, .count(3...) && .ascii)
    try validations.add(\.email, .count(6...254) && .email)
    return validations
  }
  
}

/// Allows users to be verified by basic / password auth middleware.
extension User: PasswordAuthenticatable {
  /// See `PasswordAuthenticatable`.
  public static var usernameKey: WritableKeyPath<User, String> {
    return \.email
  }
  
  /// See `PasswordAuthenticatable`.
  public static var passwordKey: WritableKeyPath<User, String> {
    return \.passwordHash
  }
}

/// Allows users to be verified by bearer / token auth middleware.
extension User: TokenAuthenticatable { /// See `TokenAuthenticatable`.
  public typealias TokenType = UserToken
}

/// Allows `User` to be used as a Fluent migration.
extension User: Migration { /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    let uTable = AdoptedDatabase.create(User.self, on: conn) { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.orgUserRef)
      builder.field(for: \.login )
      builder.field(for: \.email)
      builder.field(for: \.oldEmail)
      builder.field(for: \.newEmail)
      builder.field(for: \.emailChangeToken)
      builder.field(for: \.emailChangeDate)
      builder.field(for: \.state)
      builder.field(for: \.passwordHash)
      builder.field(for: \.oldPasswordHash)
      builder.field(for: \.newPasswordHash)
      builder.field(for: \.passwordChangeToken)
      builder.field(for: \.passwordChangeDate)
      builder.field(for: \.staff)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.field(for: \.profileID)
      builder.field(for: \.avatar)
      builder.field(for: \.mainOrganizationID)
      builder.unique(on: \.login)
      builder.unique(on: \.email)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.unique(on: \.passwordChangeToken)
      builder.unique(on: \.emailChangeToken)
      builder.reference(from: \User.profileID, to: \Contact.id, onUpdate: .noAction, onDelete: .noAction)
      
    }
    if type(of: conn) == PostgreSQLConnection.self {
      // Only for Post GreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(User.name)_id_seq RESTART WITH 1000").all()
    }
    return uTable
    
  }
  
  public static func revert(on conn: Database.Connection) -> Future<Void> {
    return Database.delete(User.self, on: conn)
  }
}

public extension User {
  // this user's related organization link
  var organizations: Siblings<User, Organization, UserOrganization> {
    return siblings()
  }
  // this user's related order link
  var orders: Children<User, Order> {
    return children(\.clientID)
  }
  // this user's related services link
  var services: Children<User, Service> {
    return children(\Service.authorID)
  }
  // this user's related schedules link
  var schedules: Children<User, Schedule> {
    return children(\Schedule.ownerID)
  }
  // this user's related profile link
  var profile: Parent<User, Contact> {
    return parent(\.profileID)
  }
  // this user's related assets link
  var assets: Children<User, Asset> {
    return children(\Asset.authorID)
  }
  // this user's related scores link
  var scores: Children<User, Score> {
    return children(\Score.authorID)
  }
  // this user's related scores link
  var comments: Children<User, Score> {
    return children(\Score.authorID)
  }
  /// Every place I created
  var places: Children<User, Place> {
    return children(\Place.authorID)
  }
  /// Every devis I created
  var devis: Children<User, Devis> {
    return children(\Devis.authorID)
  }
  /// Every devis I signed
  var receivedSignedDevis: Children<User, Devis> {
    return children(\Devis.orgBSignator)
  }
  /// Every devis I signed
  var emittedSignedDevis: Children<User, Devis> {
    return children(\Devis.orgASignator)
  }
}

/// Administrative operation
public extension User {
  func isStaffUser() -> Bool {
    return !self.staff.staff.isNotStaff
  }
  
  func isStaffAnalyst() -> Bool {
    return self.staff.staff.isAnalyst
  }
  func isStaffModerator() -> Bool {
    return self.staff.staff.isModerator
  }
  func isStaffManager() -> Bool {
    return self.staff.staff.isManager
  }
  func isStaffAdministrator() -> Bool {
    return self.staff.staff.isAdministrator
  }
  func isStaffFinancial() -> Bool {
    return self.staff.staff.isFinancial
  }
  func isBigBrother() -> Bool {
    return self.staff.staff.isBigBrother
  }
}

/// Allows `User` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }

