//
//  CRUDContact.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 30/12/2019.
//

import Foundation
import Vapor
import Fluent


/// Allows `User` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allows `UserToken` to be encoded to and decoded from HTTP messages.
extension UserToken: Content { }

// MARK: Content for public usage
public extension User {
  
  
  func fullLoggedResponse(_ req: Vapor.Request, _ token: UserToken? = nil,  _ err: [NamedURI]? = nil) -> Future<User.FullLoggedResponse> {
    
    let uresp = self.profile.get(on: req).map { p in
      return User.FullLoggedResponse(id: self.id!, profile: p, login: self.login, email: self.email, ref: self.ref, avatar: self.avatar, staff: self.staff, state: self.state, token: token?.token ?? "", expiresOn: token?.expiresOn, createdAt: self.createdAt, updatedAt: self.updatedAt, deletedAt: self.deletedAt, errors: err)
    }
    return uresp
  }
  
  func fullResponse(_ req: Vapor.Request, _ err: [NamedURI]? = nil) -> Future<User.FullPublicResponse> {
    
    let uresp = self.profile.get(on: req).map { p in
      return User.FullPublicResponse(id: self.id!, profile: p, login: self.login, email: self.email, ref: self.ref, avatar: self.avatar, staff: self.staff, state: self.state, createdAt: self.createdAt, updatedAt: self.updatedAt, deletedAt: self.deletedAt, errors: err)
    }
    return uresp
  }
  
  func shortResponse() -> User.ShortPublicResponse {
    return User.ShortPublicResponse(id: self.id!, login: self.login, ref: self.ref, avatar: self.avatar, staff: self.staff, createdAt: self.createdAt)
  }
  
  func infos() -> [AnyHashable : Codable] {
    return ["id": self.id ?? "0", "login": login, "email": self.email, "ref": self.ref, "state": self.state, "staff": self.staff, "avatar": self.avatar ?? "", "updated": self.updatedAt ?? ""]
  }
  
  /// Data required to log a user.
  struct Login: Content {
    public static let defaultContentType: MediaType = .multipart
    /// Does the user should be memorized for long term. yes/no, on/off; / true/false
    public var memorize: Bool?
    /// User's login name.
    public var login: String?
    /// User's email address.
    public var email: String
    /// User's desired password.
    public var password: String
  }
  
  /// Data required to log a user.
  struct Logout: Content {
    /// Does the user should be memorized for long term. yes/no, on/off; / true/false
    public var id: User.ID
    /// User's login name.
    public var login: String?
    /// User's email address.
    public var msg: String?
    /// User's desired password.
    public var code: String?
  }
  
  /// Data required to create a user.
  struct Create: Content {
    public static let defaultContentType: MediaType = .urlEncodedForm
    /// User's login name.
    public var login: String?
    /// Does the user should be directly authentificated. yes/no, on/off; / true/false
    public var authentificate: String?
    /// User's email address.
    public var email: String
    /// User's potential avatar /// Not yet supported
    //      public var avatar: File?
    /// User's kind by default unkown if not indicated
    public var staff: StaffUserRole.RawValue?
    /// User's desired password.
    public var password: String
    /// User's password repeated to ensure they typed it correctly.
    public var verifyPassword: String
  }
  
  /// Public representation of email object association.
  struct AddEmail: Content {
    public var id: User.ID
    public var profileID: Contact.ID
    
    public var emailLabel: String
    public var emailValue: String?
    
  }
  
  /// Public representation of email object association.
  struct AddURI: Content {
    public var id: User.ID
    public var profileID: Contact.ID
    
    public var urlLabel: String
    public var urlValue: String?
  }
  
  /// Public representation of social object association.
  struct AddSocial: Content {
    public var id: User.ID
    public var profileID: Contact.ID
    
    public var urlLabel: String
    public var urlValue: String?
  }
  
  /// Public representation of phone number object association.
  struct AddPhone: Content {
    public var id: User.ID
    public var profileID: Contact.ID
    
    public var phoneLabel: String
    public var phoneValue: String?
  }
  
  /// Public representation of place object association.
  struct AddPlace: Content {
    public var id: User.ID
    public var profileID: Contact.ID
    /// Place's unique réference.
    public var ref: String?
    /// Label or title of tha place
    public var label: String?
    /// Street kind (house, avenue, etc)
    public var kind: PlaceKind.RawValue?
    public var number: String
    /** multi-street address is delimited with carriage returns “\n” */
    public var street: String
    /// City of the place
    public var city: String
    /// State of this place
    public var state: String?
    /// Postal ou zip code of this place
    public var postalCode: String
    /// Country's place
    public var country: String
    /// Country ISO
    public var isoCountryCode: String?
    /// Sub Locality of this place
    public var subLocality: String?
    /// For administrative area : sub administrative area
    public var subAdministrativeArea: String?
    /// Position lon lat double
    public var position: [Double]?
    
    /// Create date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
    /// Deleted date.
  }
  
  /// Data required to update  a password for a logged user.
  struct UpdatePassword: Content {
    public var id: User.ID?
    /// User's old password.
    public var oldPassword: String?
    /// User's old password.
    public var token: String?
    /// User's desired new password.
    public var newPassword: String
    /// User's password repeated to ensure they typed it correctly.
    public var verifyPassword: String
  }
  
  /// Data required to reset a user's password.
  struct ResetPassword: Content {
    public var email: String
    /// User's old password.
    public var oldPassword: String?
    /// User's old password.
    public var token: String?
  }

  struct UpdateEmail: Content {
    public var id: User.ID
    public var token: String?
    public var login: String?
    /// User's email.
    public var oldemail: String
    public var email: String
    public var verifyEmail: String
  }
  
  /// Public common representation update profile.
  struct UpdateProfile: Content {
    public var id: User.ID
    public var profileID: Contact.ID
    /// Family name
    public var familyName: String?
    public var givenName: String?
    public var middleName: String?
    public var namePrefix: String?
    public var nameSuffix: String?
    public var previousFamilyName: String?
    public var nickname: String?
    public var departmentName: String?
    public var jobTitle: String?
    
    // direct contact informations
    public var emailAddresses: [NamedEmail]?
    public var urlAddresses: [NamedURI]?
    public var socialProfiles: [NamedURI]?
    public var phoneNumbers: [NamedURI]?
    public var places: [Place]?
    
    
    // VCard presentation
    public var ckind: ContactKind
    
    /** The Gregorian birthday. */
    public var birthday: Date?
    /** Other Gregorian dates (anniversaries, etc). */
    public var dates: [LabeledValue<String>]?
  }
  
  /// Public common representation update of a picture data.
  struct UpdateAvatar: Content {
    public var id: User.ID
    
    // Profile avatar update
    public var avatar: File
  }
  
  /// Public common representation update of user data.
  struct Update: Content {
    public var id: User.ID
    public var login: String?
    public var state: ObjectStatus.RawValue?
    public var staff: StaffUserRole.RawValue?
    
    // Profile section
    public var avatar: File?
    public var familyName: String?
    public var givenName: String?
    public var middleName: String?
    public var note: String?
    public var namePrefix: String?
    public var nameSuffix: String?
    public var previousFamilyName: String?
    public var nickname: String?
    public var departmentName: String?
    public var jobTitle: String?
    
    // direct contact informations
    public var emailAddresses: [NamedEmail]?
    public var urlAddresses: [NamedURI]?
    public var socialProfiles: [NamedURI]?
    public var phoneNumbers: [NamedURI]?
    public var places: [Place]?
    public var instantMessageAddresses: [NamedEmail]?
  }
  
  /// Public common representation update of user data.
  struct UpdateLogins: Content {
    public var id: User.ID
    public var login: String?
    public var state: ObjectStatus.RawValue?
    public var staff: StaffUserRole.RawValue?
    
  }
  
  struct SearchField {
    public static var login = \User.login
    //     public var kind: ContactKind?
    public static var givenName = \Contact.givenName
    public static var familyName = \Contact.familyName
    public static var nickname = \Contact.nickname
    public static var middleName = \Contact.middleName
    public static var jobTitle = \Contact.jobTitle
    public static var departmentName  = \Contact.departmentName
    /// User's email address.
    public static var email = \User.email
    /// User's unique réference.
    public static var ref = \User.ref
    /// User's unique réference into the organization.
    public static var orgUserRef = \User.orgUserRef
    public static var staff = \User.staff
    /** Channel used to sign this user &#x60;Channel&#x60;  */
    public static var state = \User.state
    /** Created date */
    public static var createdAt = \User.createdAt
    /** Updated date */
    public static var updatedAt = \User.updatedAt
    
  }
  
  /// Public representation of user data.
  struct QuickSearch: Content {
    /// User's unique identifier. Not optional since we only return users that exist in the DB.
    public var id: User.ID
    /// User's login name.
    public var login: String
    public var ref: String
    /** User avatar uri */
    public var avatar: AbsolutePath?
    public var kind: ContactKind?
    public var givenName: String?
    public var familyName: String?
    public var nickname: String?
    public var jobTitle: String?
    public var departmentName: String?
    /** Created date */
  }
  
  /// Public representation of user data.
  struct ShortPublicResponse: Content {
    /// User's unique identifier. Not optional since we only return users that exist in the DB.
    public var id: User.ID?
    /// User's login name.
    public var login: String?
    public var ref: String
    /** User avatar uri */
    public var avatar: AbsolutePath?
    public var staff: StaffUserRole.RawValue?
    /** Created date */
    public var createdAt: Date?
    /// Errors  codes and messages
    public var errors: [NamedURI]?
    /// Successes codes and messages
    public var succes: [NamedURI]?
  }
  
  /// Public representation of user data.
  struct FullPublicResponse: Content {
    /// User's unique identifier. Not optional since we only return users that exist in the DB.
    public var id: User.ID
    /// User's attached profile.
    public var profile: Contact?
    /// User's login name.
    public var login: String
    /// User's email address.
    public var email: String
    /// User's unique réference.
    public var ref: String
    /// User's unique réference into the organization.
    public var orgUserRef: String?
    /** User avatar uri */
    public var avatar: AbsolutePath?
    public var staff: StaffUserRole.RawValue?
    /** Channel used to sign this user &#x60;Channel&#x60;  */
    public var state: ObjectStatus.RawValue
    /** Created date */
    public var createdAt: Date?
    /** Updated date */
    public var updatedAt: Date?
    /** Updated date */
    public var deletedAt: Date?
    /// Errors  codes and messages
    public var errors: [NamedURI]?
    /// Successes codes and messages
    public var succes: [NamedURI]?
    
    func toShortPublicResponse() -> User.ShortPublicResponse {
      User.ShortPublicResponse(id: self.id, login: self.login, ref: self.ref, avatar: self.avatar, staff: self.staff, createdAt: self.createdAt, errors: self.errors, succes: self.succes)
    }
  }
  
  /// Public representation of user data.
  struct FullLoggedResponse: Content {
    /// User's unique identifier. Not optional since we only return users that exist in the DB.
    public var id: User.ID
    /// User's attached profile.
    public var profile: Contact?
    /// User's login name.
    public var login: String
    /// User's email address.
    public var email: String
    /// User's unique réference.
    public var ref: String
    /// User's unique réference into the organization.
    public var orgUserRef: String?
    /** User avatar uri */
    public var avatar: AbsolutePath?
    public var staff: StaffUserRole.RawValue
    /** Channel used to sign this user &#x60;Channel&#x60;  */
    public var state: ObjectStatus.RawValue
    /// Unique token string.
    public var token: String?
    /// Expiration date. Token will no longer be valid after this point.
    public var expiresOn: Date?
    /** Created date */
    public var createdAt: Date?
    /** Updated date */
    public var updatedAt: Date?
    /** Updated date */
    public var deletedAt: Date?
    /// Errors  codes and messages
    public var errors: [NamedURI]?
    /// Successes codes and messages
    public var succes: [NamedURI]?
    
    public static func skeletonObject() -> Self {
      return Self.init(id: 0, profile: nil, login: "", email: "", ref: "", orgUserRef: nil, avatar: nil, staff: StaffUserRole.defaultRaw, state: 0, token: nil, expiresOn: nil, createdAt: nil, updatedAt: nil, deletedAt: nil, errors: nil, succes: nil)
    }
    
    public func toShortPublicResponse() -> User.ShortPublicResponse {
      User.ShortPublicResponse(id: self.id, login: self.login, ref: self.ref, avatar: self.avatar, staff: self.staff, createdAt: self.createdAt, errors: self.errors, succes: self.succes)
    }
    
  }
}
