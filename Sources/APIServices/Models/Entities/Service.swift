//
//  Service.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 13/11/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

let kServiceReferenceBasePrefix  = "SER"
let kServiceReferenceLength = kReferenceDefaultLength

/**
 * BillingPlan defines how
 *  direct           = 0 // Direct payement
 *  hourly          = 1 // Factured by hour
 *  weekly         = 2 // Factured every week
 *  fortnightly    = 3  // Bimensual every 15 day
 *  bimonthly    = 4 // Every month
 *  quarterly     = 5 // Every three months "semestrial"
 *  annual        = 6 // Par an
 *  biennial   = 7 // Tous les deux an
 *  triennieal   = 8 // Tous les trois ans
 *  quinquennial   = 9 // Tous les cinqs ans
 *  decennial       = 10 // Tous les 10 ans
 *  centennial      = 100 // Tous les 100 ans
 *
 * */
public enum BillingPlan: Int, Codable, ReflectionDecodable, CaseIterable {
  public static func reflectDecoded() throws -> (BillingPlan, BillingPlan) {
    return (direct, centennial)
  }
  case direct           = 0 // Direct payement
  case hourly           = 1 // Factured by hour
  case dayly            = 2 // Factured every day
  case weekly           = 3 // Factured every week
  case fortnightly      = 4  // Bimensual every 15 day
  case mensual          = 5 // Every month
  case quarterly        = 6 // Every three months "trimestrial"
  case semestrial       = 7 // Every six months "semestrial"
  case annual           = 8 // Par an
  case biennial         = 9 // Tous les deux an
  case triennieal       = 10 // Tous les trois ans
  case quinquennial     = 15 // Tous les cinqs ans
  case decennial        = 20 // Tous les 10 ans
  case centennial       = 100 // Tous les 100 ans
  
  public var textual: String {
    switch self {
      case .direct:
        return "facturé une fois à vie"
      case .hourly:
        return "facturé par heure"
      case .dayly:
        return "facturé par jour"
      case .weekly:
        return "facturé par semaine"
      case .fortnightly:
        return "facturé tous les deux (2) semaines"
      case .mensual:
        return "facturé par mois"
      case .quarterly:
        return "facturé par trimestre"
      case .semestrial:
        return "facturé par semestre"
      case .annual:
        return "facturé par an"
      case .biennial:
        return "facturé tous les deux (2) ans"
      case .triennieal:
        return "facturé tous les trois (3) ans"
      case .quinquennial:
        return "facturé tous les cinq (5) ans"
      case .decennial:
        return "facturé par décade"
      case .centennial:
        return "facturé par centenaire"
    }
    
  }
  
  public static func has(value: Int, status: ObjectStatus) -> Bool {
    let res = value & status.rawValue
    return res == status.rawValue
  }
  
  public func into(value: Int) -> Bool {
    let res = value & self.rawValue
    return res == self.rawValue
  }
  public static var defaultValue : BillingPlan {
    return .direct
  }
  
  public static var defaultRaw : BillingPlan.RawValue {
    return defaultValue.rawValue
  }
}
/**
 * ServiceTarget defines how
 
 *
 * */
public enum ServiceTarget: Int, Codable, CaseIterable {
  case everyOne         = 1 // Every one are targeted
  case client           = 2 // b2c : tous consomateur
  case user             = 3 // b2cb : utilisateurs liés à l'organisation
  case famous           = 4 // b2bc : pour les clients privilègiés de la plateforme
  case business         = 5 // b2b : pour les entreprises
  
  public var textual: String {
    switch self {
      case .everyOne:
        return "Tous"
      case .client:
        return "Utilisateurs"
      case .user:
        return "Clients"
      case .famous:
        return "Prestige"
      case .business:
        return "Entreprises"
    }
    
  }
  
  public static var defaultValue : ServiceTarget {
    return .client
  }
  
  public static var defaultRaw : ServiceTarget.RawValue {
    return defaultValue.rawValue
  }
}

public extension Int {
  var billing: BillingPlan {
    return BillingPlan(rawValue: self) ?? BillingPlan.defaultValue
  }
  var target: ServiceTarget {
    return ServiceTarget(rawValue: self) ?? ServiceTarget.defaultValue
  }
}

// An industry Service
public final class Service: Servable, AdoptedModel, Auditable {
public static var auditID = HistoryDataType.service.rawValue

  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  public static let name = "service"
  /// Service's unique identifier.
  public var id: ObjectID?
  /// Service's unique réference.
  public var ref: String
  /// Service's unique slug réference.
  public var slug: String
  /// Service's unique réference into the organization.
  public var orgServiceRef: String?
  /// Short label service
  public var shortLabel: String
  /// Service label (full name of service)
  public var label: String
  /// Billing plan by default direct : one shot
  public var billing: BillingPlan.RawValue
  /// service target  by default client b2b
  public var target: ServiceTarget.RawValue
  /// State of the service (validated by the responsable / owner of the organization)
  public var status: ObjectStatus.RawValue
  /// description of the industry
  public var description: String
  /// summary from the description given
  public var summary: String?
  /// Attached Industry.
  public var industryID: Industry.ID
  /// Attached organization.
  public var organizationID: Organization.ID
  /// Service Parent Service.ID
  public var parentID: Service.ID?
  /// Service definition's author ID
  public var authorID: User.ID
  /// Service Price
  public var price: Float?
  /// Organization's intengibility score
  public var intengibility: Int
  /// Organization's intengibility score
  public var inseparability: Int
  /// Organization's variaability score
  public var variability: Int
  /// Organization's perishability score
  public var perishability: Int
  /// Organization's ownership score
  public var ownership: Int
  /// Organization's reliability score
  public var reliability: Int
  /// Organization's disponibility score
  public var disponibility: Int
  /// Organization's pricing score
  public var pricing: Int
  /// Unbillable Services.
  public var nobillable: Bool // bool
  /// negotiable.
  public var negotiable: Bool // bool
  /// location full string.
  public var address: String?
  /// location.
  public var locationID: Place.ID?
  /// activity perimeter in kilometer.
  public var geoPerimeter: Int
  /// activity begin date.
  public var openOn: Date
  /// activity end date.
  public var endOn: Date?
  /// Created date.
  public var createdAt: Date?
  /// Updated date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  public var pidentkey: String?
  /// Creates a new `Service`.
  public init(label: String, billing: BillingPlan, description: String,
              industry: Industry.ID, price: Float?, shortLabel: String,
              organization: Organization.ID, author: User.ID, slug: String? = nil,
              parent: Service.ID? = nil, orgServiceRef: String? = nil,
              state: ObjectStatus = ObjectStatus.defaultValue,
              pricing: Int = 0, disponibility: Int = 0, reliability: Int = 0,
              ownership: Int = 0, perishability: Int = 0, variability: Int = 0,
              inseparability: Int = 0, intengibility: Int = 0, nobillable: Bool = false,
              negotiable: Bool = false, address: String? = nil, locationID: Place.ID? = nil, geoPerimeter: Int = 1,
              openOn: Date = Date(), endOn: Date? = nil,
              createdAt : Date = Date(), updatedAt: Date? = nil,
              deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id         = id
    self.ref        = Utils.newRef(kServiceReferenceBasePrefix, size: kServiceReferenceLength)
    let formatSlug  = label.lowercased()
      .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      .replacingOccurrences(of: " ", with: "-").replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: "\\", with: "-")
    self.slug       = slug == nil ? formatSlug + "-" + self.ref : slug!
    self.orgServiceRef = orgServiceRef
    self.parentID   = parent
    self.label      = label
    self.authorID   = author
    self.shortLabel = shortLabel
    self.price      = price
    self.billing    = billing.rawValue
    self.organizationID   = organization
    self.industryID       = industry
    self.description      = description
    self.createdAt        = createdAt
    self.updatedAt        = updatedAt
    self.deletedAt        = deletedAt
    self.target           = ServiceTarget.defaultValue.rawValue
    self.intengibility  = intengibility
    self.inseparability = inseparability
    self.variability    = variability
    self.perishability  = perishability
    self.ownership      = ownership
    self.reliability    = reliability
    self.disponibility  = disponibility
    self.pricing        = pricing
    self.status         = state.rawValue
    self.nobillable    = nobillable
    self.negotiable     = negotiable
    self.locationID     = locationID
    self.geoPerimeter   = geoPerimeter
    self.openOn         = openOn
    self.endOn          = endOn
    self.summary        = description.resume()
    self.address        = address
  }
  
}

/// Allows `Service` to be used as a Fluent migration.
extension Service: Migration {
  public func saveOverload(on conn: DatabaseConnectable) -> EventLoopFuture<Service> {
    let created = self.id == nil
    return self.save(on: conn).flatMap { (serv) -> Future<Service> in
      let user = try UserController.logged(conn as! Request)
      let entry = History(user: user.id!, objectID: serv.id!, data: self.description.convertToData(), slug: "\(serv.slug)-\(Utils.newRef(kServiceReferenceBasePrefix, size: kServiceReferenceLength))", operationKind: (created ? HistoryOperationType.create : HistoryOperationType.ufield), dataType: HistoryDataType.service, createdAt: Date(), deletedAt: nil)
      return entry.create(on: conn).map { _ -> Service in
        return serv
      }
    }
  }
  
  public func createOverload(on conn: DatabaseConnectable) -> EventLoopFuture<Service> {
    return self.create(on: conn).flatMap { (serv) -> Future<Service> in
      let user = try UserController.logged(conn as! Request)
      let entry = History(user: user.id!, objectID: serv.id!, data: self.description.convertToData(), slug: "\(serv.slug)-\(Utils.newRef(kServiceReferenceBasePrefix, size: kServiceReferenceLength))", operationKind: HistoryOperationType.create, dataType: HistoryDataType.service, createdAt: Date(), deletedAt: nil)
      return entry.create(on: conn).map { _ -> Service in
        return serv
      }
    }
  }
  
  public func updateOverload(on conn: DatabaseConnectable) -> EventLoopFuture<Service> {
    return self.update(on: conn).flatMap { (serv) -> Future<Service> in
      let user = try UserController.logged(conn as! Request)
      let entry = History(user: user.id!, objectID: serv.id!, data: self.description.convertToData(), slug: "\(serv.slug)-\(Utils.newRef(kServiceReferenceBasePrefix, size: kServiceReferenceLength))", operationKind: HistoryOperationType.ufield, dataType: HistoryDataType.service, createdAt: Date(), deletedAt: nil)
      return entry.create(on: conn).map { _ -> Service in
        return serv
      }
    }
  }

  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    let sTable = AdoptedDatabase.create(Service.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.slug)
      builder.field(for: \.orgServiceRef)
      builder.field(for: \.label)
      builder.field(for: \.status)
      builder.field(for: \.authorID)
      builder.field(for: \.shortLabel)
      builder.field(for: \.parentID)
      builder.field(for: \.price)
      builder.field(for: \.industryID)
      builder.field(for: \.organizationID)
      builder.field(for: \.billing)
      builder.field(for: \.target)
      builder.field(for: \.description)
      builder.field(for: \.summary)
      builder.field(for: \.intengibility)
      builder.field(for: \.inseparability)
      builder.field(for: \.variability)
      builder.field(for: \.perishability)
      builder.field(for: \.ownership)
      builder.field(for: \.reliability)
      builder.field(for: \.disponibility)
      builder.field(for: \.pricing)
      builder.field(for: \.nobillable)
      builder.field(for: \.negotiable)
      builder.field(for: \.address)
      builder.field(for: \.locationID)
      builder.field(for: \.geoPerimeter)
      builder.field(for: \.openOn)
      builder.field(for: \.endOn)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.unique(on: \.slug)
      builder.reference(from: \Service.authorID, to: \User.id, onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \Service.parentID, to: \Service.id, onUpdate: .noAction, onDelete: .setNull)
      builder.reference(from: \Service.industryID, to: \Industry.id, onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \Service.organizationID, to: \Organization.id, onUpdate: .noAction, onDelete: .cascade)
      builder.reference(from: \Service.locationID, to: \Place.id, onUpdate: .noAction, onDelete: .setNull)
    }
    if type(of: conn) == PostgreSQLConnection.self {
      // Only for Post GreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(Service.name)_id_seq RESTART WITH 5000").all()
    }
    return sTable

  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Service.self, on: conn)
  }
}

public extension Service {
  /// Fluent relation to the industry that is relative to the service.
  var industry: Parent<Service, Industry> {
    return parent(\.industryID)
  }
  /// Fluent relation to the organization that is relative to the service.
  var organization: Parent<Service, Organization> {
    return parent(\.organizationID)
  }
  /// Parent relation between two services.
  var parent: Parent<Service, Service>? {
    return parent(\.parentID)
  }
  /// Cheldren of this services.
  var services: Children<Service, Service> {
    return children(\.parentID)
  }
  /// Schedules of this services.
  var schedules: Children<Service, Schedule> {
    return children(\.serviceID)
  }
  
  /// User relation between this service.
  var author: Parent<Service, User> {
    return parent(\.authorID)
  }
  
  var assets: Siblings<Service, Asset, ServiceAsset> {
    // Controle to add
    return siblings()
  }
  
  var scores: Children<Service, Score> {
    return children(\Score.serviceID)
  }
 
  var devis: Children<Service, Devis> {
    return children(\Devis.serviceID)
  }
  
}

/// Allows `Service` to be used as a dynamic parameter in route definitions.
extension Service: Parameter {
  
}
