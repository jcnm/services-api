//
//  Contact.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 07/12/2019.
//

import Foundation
import Vapor
import Fluent

public enum ContactKind: Codable  {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Key.self)
    let rawValue = try container.decode(Int.self, forKey: .rawValue)
    
    switch rawValue {
    case 0:
        self = .association
    case 1:
        let gender = try container.decode(PersonGender.self, forKey: .associatedValue)
        self = .person(gender)
    case 2:
        let org = try container.decode(OrganizationGender.self, forKey: .associatedValue)
        self = .organization(org)
    default:
        throw CodingError.unknownValue
    }

  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .association :
            try container.encode(0, forKey: .rawValue)
        case .person(let gender):
            try container.encode(1, forKey: .rawValue)
            try container.encode(gender, forKey: .associatedValue)
        case .organization(let gender):
            try container.encode(2, forKey: .rawValue)
            try container.encode(gender, forKey: .associatedValue)
        }
  }
  
  enum Key: CodingKey {
      case rawValue
      case associatedValue
  }
  
  enum CodingError: Error {
      case unknownValue
  }

  case association
  case person(PersonGender)
  case organization(OrganizationGender)
  
  public static var defaultValue: ContactKind {
    return .person(.defaultValue)
  }
  
//
//  public static var defaultRaw: ContactKind.RawValue {
//    return defaultValue.rawValue
//  }
}

extension ContactKind: ReflectionDecodable {
  public static func reflectDecoded() throws -> (ContactKind, ContactKind) {
    (ContactKind.defaultValue, ContactKind.association)
  }
  
  public static func reflectDecodedIsLeft(_ item: ContactKind) throws -> Bool {
    switch item {
      case .person(.unknown) :
      return true
      default:
      return false
    }
  }
}

public enum PersonGender: Int, Codable, RawRepresentable, CaseIterable {
  case unknown    = 0 //
  case female     = 1 //
  case male       = 2 // Homme
  case hermaphrodite  = 3
  case transgenre     = 4
  case other          = 5

  public static var defaultValue: PersonGender {
    return .unknown
  }
  
  public static var defaultRaw: PersonGender.RawValue {
    return defaultValue.rawValue
  }
  
  public var textual: String {
    switch self {
      case .unknown:
        return "inconnue"
      case .female:
        return "femme"
      case .male:
        return "homme"
      case .hermaphrodite:
        return "hermaphrodite"
      case .transgenre:
        return "transe"
      case .other:
        return "autre"
    }
  }

}

public typealias PhoneNumber = String
//public struct phoneNumber: Content {
//  var number: String
//}
public typealias EmailAddress = String
//public struct emailAddress: Content {
//  var email:String
//}

public final class Contact: AdoptedModel {
  /** The identifier is unique among contacts on the device. It can be saved and used for fetching contacts next application launch. */
  public static let name = "contact"
  public var createdAtKey: TimestampKey? { return \.createdAt }
  public var updatedAtKey: TimestampKey? { return \.updatedAt }
  public var deletedAtKey: TimestampKey? { return \.deletedAt }
  
  /* General information */
  // Contact uniq identifier
  public var id: ObjectID?
  public var note: String?
  public var imageData: Data?
  public var thumbnailImageData: Data?
  public var imageDataAvailable: Bool
  
  // direct contact informations
  public var emailAddresses: [NamedEmail]?
  public var urlAddresses: [NamedURI]?
  public var socialProfiles: [NamedURI]?
  public var phoneNumbers: [NamedURI]?
  public var places: [Place]?
  public var instantMessageAddresses: [NamedEmail]?
  
  // VCard presentation
  public var ckind: ContactKind
  public var givenName: String?
  public var familyName: String?
  public var middleName: String?
  public var namePrefix: String?
  public var nameSuffix: String?
  // Compleement of presentation information
  public var previousFamilyName: String?
  public var nickname: String?
  
  // Entreprise contact information
  public var departmentName: String?
  public var jobTitle: String? // jobFunction
  /** The Gregorian birthday. */
  public var birthday: Date?
  /** Other Gregorian dates (anniversaries, etc). */
  public var dates: [LabeledValue<String>]?
  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  public init(givenName: String?, familyName: String?, nickname: String? = nil, ckind: ContactKind = .defaultValue, middleName: String? = nil, namePrefix: String? = nil, nameSuffix: String? = nil,  previousFamilyName: String? = nil, imageData: Data? = nil, thumbnailImageData: Data? = nil, imageDataAvailable: Bool = false, note: String? = nil, phoneNumbers: [NamedURI]? = nil, emailAddresses: [NamedEmail]? = nil, urlAddresses: [NamedURI]? = nil, socialProfiles: [NamedURI]? = nil, instantMessageAddresses: [NamedEmail]? = nil, places: [Place]? = nil, departmentName: String? = nil, jobTitle: String? = nil, birthday: Date? = nil,
       dates: [LabeledValue<String>]? = nil,
       createdAt: Date? = Date(), updatedAt: Date? = nil, deletedAt: Date? = nil, id: ObjectID? = nil) {
    self.id             = id
    self.note           = note
    self.ckind          = ckind
    self.givenName      = givenName
    self.familyName     = familyName
    self.middleName     = middleName
    self.namePrefix     = namePrefix
    self.nameSuffix     = nameSuffix
    self.previousFamilyName = previousFamilyName
    self.nickname       = nickname
    self.imageData      = imageData
    self.thumbnailImageData = thumbnailImageData
    self.imageDataAvailable = imageDataAvailable
    self.phoneNumbers   = phoneNumbers
    self.emailAddresses = emailAddresses
    self.places         = places
    self.urlAddresses   = urlAddresses
    self.socialProfiles = socialProfiles
    self.instantMessageAddresses = instantMessageAddresses
    self.departmentName = departmentName
    self.jobTitle       = jobTitle
    self.birthday       = birthday
    
    self.dates          = dates
    self.createdAt      = createdAt
    self.updatedAt      = updatedAt
    self.deletedAt      = deletedAt
  }
}


/// Allows `Contact` to be used as a dynamic parameter in route definitions.
extension Contact: Parameter { }

extension Contact: Content {}


public extension Contact {
  // this Contact's related organization link
  public var organizations: Siblings<Contact, Organization, ContactOrganization> {
    return siblings()
  }
}

/// Allows `Contact` to be used as a Fluent migration.
extension Contact: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(Contact.self, on: conn)
    {
      builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ckind)
      builder.field(for: \.namePrefix)
      builder.field(for: \.givenName)
      builder.field(for: \.middleName)
      builder.field(for: \.familyName)
      builder.field(for: \.nickname)
      builder.field(for: \.previousFamilyName)
      builder.field(for: \.nameSuffix)
      
      builder.field(for: \.departmentName)
      builder.field(for: \.jobTitle)
      
      builder.field(for: \.note)
      builder.field(for: \.imageData)
      builder.field(for: \.thumbnailImageData)
      builder.field(for: \.imageDataAvailable)
      builder.field(for: \.phoneNumbers)
      builder.field(for: \.emailAddresses)
      builder.field(for: \.places)
      builder.field(for: \.urlAddresses)
      builder.field(for: \.instantMessageAddresses)
      builder.field(for: \.socialProfiles)
      builder.field(for: \.birthday)
      builder.field(for: \.dates)
      
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Contact.self, on: conn)
  }
}

