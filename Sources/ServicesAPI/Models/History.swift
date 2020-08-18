//
//  History.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 18/11/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kHistoryReferenceBasePrefix  = "HST"
let kHistoryReferenceLength = 8

public enum HistoryDataType: Int, Codable { // Placing by order of object susceptible to be updated
  case unknown              = 0 // not a table (NaT)
  case user                 = 1
  case service              = 2
  case contact              = 3
  case score                = 4
  case contract             = 5
  case activity             = 6
  case schedule             = 7
  case devis                = 8
  case order                = 9
  case orderitem            = 10
  case usertoken            = 11
  case grouprights          = 12 // NaT
  case userrights           = 13 // NaT
  case orgrights            = 14 // NaT
  case apprights            = 15 // NaT
  case organization         = 16
  case organizationcontact  = 17 // NaT
  case place                = 18
  case placecontact         = 19 // NaT
  case servicescore         = 20
  case asset                = 21
  case serviceasset         = 22
  case billing              = 23
  case bankcard             = 24
  case partner              = 25
  case channel              = 26 // NaT
  case application          = 27 // NaT
  case payment              = 28
  case version              = 29
  case industry             = 30
  case sector               = 31
  case currency             = 32
  case userorganization     = 33
  case devisasset           = 35
  case assetorder           = 36

  public static var defaultValue: HistoryDataType {
    return .unknown
  }
  public static var defaultRaw: HistoryDataType.RawValue {
    return defaultValue.rawValue
  }
}

public enum HistoryOperationType: Int, Codable {
  case backup     = 0   // Doing nothing, just back-uping it
  case create     = 1   // creating the data
  case rfield     = 2   // reading field(s) or all object
  case rstate     = 3
  case ufield     = 7   // updating field(s) or all object
  case ulogic     = 8   // ex. update member of a team/ adding asset into a service
  case delete     = 10  // deleting the object
  case erasing    = 15  // erasing the object from the data base

  public static var defaultValue: HistoryOperationType {
    return .backup
  }
  public static var defaultRaw: HistoryOperationType.RawValue {
    return defaultValue.rawValue
  }
}

// A service Histoy audit trail table
public final class History: AdoptedModel { 
  public static let name = "history"
  
  static public var createdAtKey: TimestampKey? { return \.createdAt }
  static public var deletedAtKey: TimestampKey? { return \.deletedAt }
  /// History's unique identifier.
  public var id: ObjectID?
  /// History's unique slug réference.
  public var slugHist: String
  /// History's objectid réference.
  public var objectID: ObjectID
  /// History's unique réference.
  public var ref: String
  /// History operation type.
  public var operationKind: PaymentMethod.RawValue
  /// data type Ref
  public var dataType: HistoryDataType.RawValue
  /// Author  ID of this audit trail
  public var authorID: User.ID
  /// the raw data with applyed diff change
  public var rawData: Data?
  /// Create date.
  public var createdAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `Payment`.
  public init(user: User.ID, objectID: ObjectID, data: Data,
              slug: String? = nil, operationKind: HistoryOperationType = .defaultValue,
              dataType: HistoryDataType = .defaultValue, createdAt : Date = Date(),
              deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id             = id
    self.rawData        = data
    self.ref            = Utils.newRef(kHistoryReferenceBasePrefix, size: kHistoryReferenceLength)
    self.objectID       = objectID
    self.slugHist       = slug == nil ? Utils.newRef(kHistoryReferenceBasePrefix, size: kHistoryReferenceLength * 2) : slug!
    self.authorID       = user
    self.operationKind  = operationKind.rawValue
    self.dataType       = dataType.rawValue
    self.createdAt      = createdAt
    self.deletedAt      = deletedAt
  }
}

/// Allows `History` to be used as a Fluent migration.
extension History: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    let pTable = AdoptedDatabase.create(History.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.slugHist)
      builder.field(for: \.objectID)
      builder.field(for: \.operationKind)
      builder.field(for: \.authorID)
      builder.field(for: \.dataType)
      builder.field(for: \.rawData)
      builder.field(for: \.createdAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.unique(on: \.slugHist)
      builder.reference(from: \History.authorID, to: \User.id, onUpdate: .noAction, onDelete: .noAction)
    }

    if type(of: conn) == PostgreSQLConnection.self {
      // Only for Post GreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(History.name)_id_seq RESTART WITH 500").all()
      _ = conn.raw("REVOKE ALL ON TABLE \(History.name) FROM public").all()
      _ = conn.raw("GRANT SELECT, INSERT ON TABLE \(History.name) TO public").all()
      _ = conn.raw("GRANT USAGE ON SEQUENCE \(History.name)_id_seq TO public").all()
    }
    return pTable
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(History.self, on: conn)
  }
}

/// Allows `History` to be used as a dynamic parameter in route definitions.
extension History: Parameter { }
