//
//  CRUDPlace.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 17/04/2020.
//

import Foundation
import Vapor
import Fluent


extension Place: Content {}

/// Allows `Place` to be encoded to and decoded from HTTP messages.
public extension Place {
  
  /// Public common way to create place
  struct CreatePlace: Content {
    public var id: Place.ID
    
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
    
  }

  
  /// Public full representation of an industry data.
  struct FullPublicResponse: Content {
    /// Industry's unique identifier.
    public var id: ObjectID?
    /// Unique CITI CODE string.
    public var citi: String?
    /// Unique SCIAN CODE string.
    public var scian: String?
    /// Unique NACE CODE string.
    public var nace: String
    /// Industry's title string.
    public var title: String
    /// Industry's description.
    public var description: String
    /// Reference to sector parent
    public var sector: Sector
    /// Create date.
    public var createdAt: Date
    /// Update date.
    public var updatedAt: Date?
    /// Deleted date.
    public var deletedAt: Date?
  }
  
  /// Public full representation of an industry data.
  struct ShortPublicResponse: Content {
    /// Industry's unique identifier.
    public var id: ObjectID?
    /// Unique CITI CODE string.
    public var citi: String?
    /// Unique SCIAN CODE string.
    public var scian: String?
    /// Unique NACE CODE string.
    public var nace: String
    /// Industry's title string.
    public var title: String
    /// Reference to sector parent
    public var sectorID: Sector.ID
    /// Update date.
    public var updatedAt: Date?
  }
}

