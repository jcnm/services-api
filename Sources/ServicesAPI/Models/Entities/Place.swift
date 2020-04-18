//
//  Place.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 09/12/2019.
//

import Foundation
import Fluent
import Vapor

let kPlaceReferenceBasePrefix  = "PLA"
let kPlaceReferenceLength      = kReferenceDefaultLength

/**
 House
 Street
 Alley
 Place
 Avenue
 Boulevard
 Road
 NBHood
 Town
 City
 State
 Country
 Continent
 Ocean
 */
public enum PlaceKind: Int, Codable, CaseIterable {
  case house
  case alley
  case villa
  case domaine
  case place
  case street
  case avenue
  case boulevard
  case road
  case monument
  case forest
  case nbhood
  case town
  case city
  case country
  case continent
  case ocean

public static var defaultValue: PlaceKind {
  return .street
}

public static var defaultRaw: PlaceKind.RawValue {
  return defaultValue.rawValue
}
}

public final class Place: AdoptedModel {
  /** The identifier is unique among contacts on the device. It can be saved and used for fetching contacts next application launch. */
  public static let name = "place"
  public var createdAtKey: TimestampKey? { return \.createdAt }
  public var updatedAtKey: TimestampKey? { return \.updatedAt }
  public var deletedAtKey: TimestampKey? { return \.deletedAt }
  
  /// Can be `nil` if the object has not been saved yet.
  public var id: User.ID?
  /// Place's unique réference.
  public var ref: String?
  /// Label or title of tha place
  var label: String?
  /// Street kind (house, avenue, etc)
  var kind: PlaceKind.RawValue
  var number: String
  /** multi-street address is delimited with carriage returns “\n” */
  var street: String
  /// City of the place
  var city: String
  /// State of this place
  var state: String?
  /// Postal ou zip code of this place
  var postalCode: String
  /// Country's place
  var country: String
  /// Country ISO
  var isoCountryCode: String?
  /// Sub Locality of this place
  var subLocality: String?
  /// For administrative area : sub administrative area
  var subAdministrativeArea: String?
  /// Position lon lat double
  var position: [Double]?
  
  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  public init(label: String?, number: String, kind: PlaceKind, street: String, city: String, state: String?, postalCode: String, country: String, position: [Double] = [], subLocality: String? = nil, subAdministrativeArea: String? = nil, createdAt: Date? = Date(), updatedAt:Date? = nil, deletedAt: Date? = nil, id: ObjectID? = nil) {
    self.label    = label
    self.id       = id
    self.ref      = Utils.newRef(kPlaceReferenceBasePrefix, size: kPlaceReferenceLength)
    self.number   = number
    self.kind     = kind.rawValue
    self.street   = street
    self.city     = city
    self.state    = state
    self.postalCode = postalCode
    self.country    = country
    self.isoCountryCode = String(country.prefix(2))
    self.subLocality    = subLocality
    self.subAdministrativeArea = subAdministrativeArea
    self.createdAt  = createdAt
    self.updatedAt  = updatedAt
    self.deletedAt  = deletedAt
    self.position   = position
  }
}

extension Place: Reflectable { }
/// TODO Complete with full init
extension Place: ReflectionDecodable {
  public static func reflectDecoded() throws -> (Place, Place) {
    return (Place(label: nil, number: "", kind: .street, street: "", city: "", state: "", postalCode: "", country: ""),
            Place(label: nil, number: "42", kind: .street, street: "==verity street", city: "city", state: "state", postalCode: "424242", country: "yes"))
  }
  
  public static func reflectDecodedIsLeft(_ item: Place) throws -> Bool {
    return (item.number == "" && item.kind.place == .street && item.city == "" && item.postalCode == "" && item.country == "" )
  }
  
  
}

/// Allows `Industry` to be used as a Fluent migration.
extension Place: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(Place.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.label)
      builder.field(for: \.number)
      builder.field(for: \.kind)
      builder.field(for: \.street)
      builder.field(for: \.city)
      builder.field(for: \.state)
      builder.field(for: \.postalCode)
      builder.field(for: \.country)
      
      builder.field(for: \.position)
      builder.field(for: \.isoCountryCode)
      builder.field(for: \.subAdministrativeArea)
      builder.field(for: \.subLocality)
      
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Contact.self, on: conn)
  }
}

/// Allows `Place` to be used as a dynamic parameter in route definitions.
extension Place: Parameter { }
