//
//  Partner.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 30/04/2020.
//

import Foundation
import FluentPostgreSQL
import Vapor
import Crypto

let kPartnerReferenceBasePrefix  = "PAR"
let kPartnerReferenceLength = 3

/// A model to represent api backend version to every one.
public final class Partner: AdoptedModel {
  public static let name = "partner"
  
  /// UserToken's unique identifier.
  public var id: ObjectID?
  /// Version name.
  public var name: String
  public var ref: String
  /// Sem Version Core.
  public var mainUrl: String
  public var versionAPI: String
  public var bearerToken: String
  public var endPointAPI : String
  public var description: String
  public var lastAPIUpdate: String
  public var referedAppName: String
  // confuguration
  public var asPathParam : Bool
  public var paramQueryName: String?
  public var hooksPointAPI: String?
  // Presta
  public var providerName : String
  public var providerWebsite: String?
  public var providerEmail: String?
  public var providerNumber: String?

  /// Created date.
  public var createdAt: Date
  /// Updated date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `UserToken`.
  public init(mainUrl: String, endPointAPI:String, versionAPI: String, bearerToken: String,
              name: String, description: String, lastAPIUpdate: String, referedAppName: String,
    asPathParam: Bool = true, paramQueryName: String? = nil, hooksPointAPI: String? = nil,
    providerName: String = "", providerWebsite: String? = nil, providerEmail: String? = nil, providerNumber: String? = nil,
    createdAt: Date = Date(), updatedAt:Date? = nil, deletedAt: Date? = nil, id: ObjectID? = nil) {
    self.id             = id
    self.ref            = Utils.newRef(kPartnerReferenceBasePrefix, size: kPartnerReferenceLength)
    self.name           = name
    self.mainUrl        = mainUrl
    self.endPointAPI    = endPointAPI
    self.versionAPI     = versionAPI
    self.bearerToken    = bearerToken
    self.description    = description
    self.lastAPIUpdate  = lastAPIUpdate
    self.referedAppName = referedAppName
    self.asPathParam    = asPathParam
    self.paramQueryName = paramQueryName
    self.hooksPointAPI  = hooksPointAPI
    self.providerName   = providerName
    self.providerWebsite = providerWebsite
    self.providerEmail  = providerEmail
    self.providerNumber = providerNumber
    self.createdAt      = createdAt
    self.updatedAt      = updatedAt
    self.deletedAt      = deletedAt
    
  }
  
}
/// Allows `Version` to be used as a Fluent migration.
extension Partner: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(Partner.self, on: conn) { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.name)
      builder.field(for: \.mainUrl)
      builder.field(for: \.endPointAPI)
      builder.field(for: \.versionAPI)
      builder.field(for: \.bearerToken)
      builder.field(for: \.description)
      builder.field(for: \.lastAPIUpdate)
      builder.field(for: \.referedAppName)
      builder.field(for: \.asPathParam)
      builder.field(for: \.paramQueryName)
      builder.field(for: \.hooksPointAPI)
      builder.field(for: \.providerName)
      builder.field(for: \.providerWebsite)
      builder.field(for: \.providerEmail)
      builder.field(for: \.providerNumber)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Partner.self, on: conn)
  }
}

/// Allows `Version` to be encoded to and decoded from HTTP messages.
extension Partner: Content { }

/// Allows `Version` to be used as a dynamic parameter in route definitions.
extension Partner: Parameter { }
