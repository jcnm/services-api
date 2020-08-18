//
//  Devis.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 22/12/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kDevisReferenceBasePrefix  = "DEV"
let kDevisReferenceLength      = kReferenceDefaultLength

// A services `Devis`
public final class Devis:     AdoptedModel, Auditable {
  public static var auditID     = HistoryDataType.devis.rawValue
  public static let name      = "devis"
  
  /// Devis's unique identifier.
  public var id:          ObjectID?
  /// user ID who initiated Contract.
  public var authorID:    User.ID
  /// organization ID.
  public var organizationID:  Organization.ID
  /// Devis's unique slug réference.
  public var slugDevis:   String
  /// Devis's unique réference into the organization whom create the schedule.
  public var orgDevisARef: String?
  /// Devis's unique réference into the organization whom validate the devis if different.
  public var orgDevisBRef: String?
  /// Devis attached Service
  public var serviceID:   Service.ID
  /// Devis attached Schedulle
  public var scheduleID:   Schedule.ID?
  /// Devis attached activity planning
  public var activityID:   Activity.ID?
  /// Service fees
  public var serviceFeePercent: Int?
  /// Gov TVA  fees
  public var TVAPercent: Int?
  /// Devis Label Ref
  public var label:       String
  /// Devis  commentExchange
  public var comment:       String?
  /// Devis's unique réference.
  public var ref:         String
  /// Devis's  statut.
  public var status:      ObjectStatus.RawValue
  /// Devis's  draft.
  public var draft:       Int // zero mens not a draft, otherwise, incremente draft iteration
  /// Contract's unique réference into the organization whom emit the Contract.
  public var orgASigned:  Bool
  /// Contract's unique réference into the organization whom validate the Contract.
  public var orgBSigned:  Bool
  /// user ID who signed the Contract.
  public var orgASignator: User.ID?
  /// user ID who signed the Contract.
  public var orgBSignator: User.ID?
  /// user ID who closed the Contract.
  public var closedAuthorID: User.ID?
  // Submit new computed price
  public var price: Double

  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  public init(author: User.ID, organization: Organization.ID, label: String, service: Service.ID,
              status: ObjectStatus, price: Double, draft: Int = 1, slug: String? = nil,
              orgASigned: Bool = false, orgBSigned: Bool = false,
              orgASignator: User.ID? = nil, orgBSignator: User.ID? = nil,
              closedAuthorID: User.ID? = nil,
              createdAt : Date = Date(), updatedAt: Date = Date(),
              deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id             = id
    self.ref            = Utils.newRef(kDevisReferenceBasePrefix, size: kDevisReferenceLength)
    let wellformSlug    = "\(label)\(createdAt.description)".lowercased()
      .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      .replacingOccurrences(of: " ", with: "-").replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: "\\", with: "-")
    self.slugDevis      = slug == nil ? wellformSlug + "-" + self.ref : slug!
    self.authorID       = author
    self.price          = price
    self.organizationID = organization
    self.label          = label
    self.serviceID      = service
    self.status         = status.rawValue
    self.draft          = draft
    self.orgASigned     = orgASigned
    self.orgBSigned     = orgBSigned
    self.orgASignator   = orgASignator
    self.orgBSignator   = orgBSignator
    self.closedAuthorID = closedAuthorID
    self.createdAt      = createdAt
    self.updatedAt      = updatedAt
    self.deletedAt      = deletedAt
  }
}

/// Allows `Devis` to be used as a Fluent migration.
extension Devis: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    let dTable = AdoptedDatabase.create(Devis.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.slugDevis)
      builder.field(for: \.authorID)
      builder.field(for: \.price)
      builder.field(for: \.organizationID)
      builder.field(for: \.serviceID)
      builder.field(for: \.scheduleID)
      builder.field(for: \.activityID)
      builder.field(for: \.serviceFeePercent)
      builder.field(for: \.TVAPercent)
      builder.field(for: \.orgDevisARef)
      builder.field(for: \.orgDevisBRef)
      builder.field(for: \.label)
      builder.field(for: \.comment)
      builder.field(for: \.orgASigned)
      builder.field(for: \.orgBSigned)
      builder.field(for: \.orgASignator)
      builder.field(for: \.orgBSignator)
      builder.field(for: \.closedAuthorID)
      builder.field(for: \.status)
      builder.field(for: \.draft)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.unique(on: \.slugDevis)
      builder.reference(from: \Devis.serviceID, to: \Service.id, onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \Devis.organizationID, to: \Organization.id, onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \Devis.authorID, to: \User.id, onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \Devis.scheduleID, to: \Schedule.id, onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \Devis.activityID, to: \Activity.id, onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \Devis.orgASignator, to: \User.id, onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \Devis.orgBSignator, to: \User.id, onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \Devis.closedAuthorID, to: \User.id, onUpdate: .noAction, onDelete: .noAction)
    }
    if type(of: conn) == PostgreSQLConnection.self {
      // Only for Post GreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(Devis.name)_id_seq RESTART WITH 5000").all()
    }
    return dTable
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Devis.self, on: conn)
  }
}

public extension Devis {
  /// Fluent relation to the organization devis.
  var organization: Parent<Devis, Organization> {
    return parent(\.organizationID)
  }
  var service: Parent<Devis, Service> {
    return parent(\.serviceID)
  }
  /// Parent relation author.
  var author: Parent<Devis, User> {
    return parent(\.authorID)
  }
  /// Parent relation author.
  var aSignator: Parent<Devis, User>? {
    return parent(\.orgASignator)
  }
  /// Parent relation author.
  var bSignator: Parent<Devis, User>? {
    return parent(\.orgBSignator)
  }
  /// Parent relation author.
  var closer: Parent<Devis, User>? {
    return parent(\.closedAuthorID)
  }
  /// Parent relation activity.
  var activity: Parent<Devis, Activity>? {
    return parent(\.activityID)
  }
  /// Parent relation schedule.
  var schedule: Parent<Devis, Schedule>? {
    return parent(\.scheduleID)
  }
  
  var assets: Siblings<Devis, Asset, DevisAsset> {
    return siblings()
  }

}

/// Allows `Devis` to be used as a dynamic parameter in route definitions.
extension Devis: Parameter { }
