//
//  CRUDContact.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 30/12/2019.
//

import Foundation
import Vapor
import Fluent

/// Allows `Contact` to be encoded to and decoded from HTTP messages.
public extension Contact {
  /// Public full representation of an contact data.
  struct CreateContact: Content {
    public static let defaultContentType: MediaType = .multipart
    // Contact uniq identifier
    public var userID: User.ID
    public var profileID: Contact.ID?
    public var gender: String
    public var note: String?
    
    // direct contact informations
    public var emailAddresses_label: String?
    public var urlAddresses_label: String?
    public var phoneNumbers_label: String?
    public var emailAddresses_value: String?
    public var urlAddresses_value: String?
    public var phoneNumbers_value: String?
    
    // VCard presentation
    public var givenName: String
    public var familyName: String
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
    var birthday: String
    /// Pour les informations d'adresse
    var places_id: String?
    /// Pour les informations d'adresse
    var places_label: String?
    /// Street kind (house, avenue, etc)
    var places_kind: String
    var places_number: String
    /** multi-street address is delimited with carriage returns “\n” */
    var places_street: String
    /// City of the place
    var places_city: String
    /// State of this place
    var places_state: String?
    /// Postal ou zip code of this place
    var places_postalCode: String
    /// Country's place
    var places_country: String
    /// Country ISO
    var places_isoCountryCode: String?
    /// Sub Locality of this place
    var places_subLocality: String?
    /// For administrative area : sub administrative area
    var places_subAdministrativeArea: String?
    /// Position lon lat double
    var places_position: [Double]?
    /// Create date.
    var createdAt: Date? 
  }
  
  /// Public full representation of an contact data.
  struct FullPersonPublicResponse: Content {
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
    var birthday: Date?
    /** Other Gregorian dates (anniversaries, etc). */
    var dates: [LabeledValue<String>]?
    /// Create date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
  }
  
  /// Public full representation of an contact data.
  struct ShortPersonPublicResponse: Content {
    // Contact uniq identifier
    public var id: ObjectID?
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
    // Compleement of presentation information
    public var nickname: String?
    
    // Entreprise contact information
    public var departmentName: String?
    public var jobTitle: String? // jobFunction
    /** The Gregorian birthday. */
    var birthday: Date?
    /** Other Gregorian dates (anniversaries, etc). */
    var dates: [LabeledValue<String>]?
    /// Create date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
  }
}
