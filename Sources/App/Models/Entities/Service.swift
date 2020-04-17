//
//  Service.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 13/11/2019.
//

import Foundation
import Vapor
import FluentSQLite

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
public enum BillingPlan: Int, Codable,  SQLiteDataConvertible, ReflectionDecodable, CaseIterable {
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
public enum ServiceTarget: Int, Codable,  SQLiteDataConvertible, CaseIterable {
  case everyOne         = 0 // Every one are targeted
  case client           = 1 // b2c : tous consomateur
  case user             = 2 // b2cb : utilisateurs liés à l'organisation
  case famous            = 3 // b2cb : pour les clients privilègiés de la plateforme
  case business           = 4 // b2b : pour les entreprises
  
  public var textual: String {
    switch self {
      case .everyOne:
        return "Tous visiteur"
      case .client:
        return "Utilisateurs"
      case .user:
        return "Clients Organisation"
      case .famous:
        return "Clients H Gamme"
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

extension Int {
  var billing: BillingPlan {
    return BillingPlan(rawValue: self) ?? BillingPlan.defaultValue
  }
  var target: ServiceTarget {
    return ServiceTarget(rawValue: self) ?? ServiceTarget.defaultValue
  }
}

// An industry Service
final public class Service: Servable, AdoptedModel {
  static public var createdAtKey: TimestampKey? { return \.createdAt }
  static public var updatedAtKey: TimestampKey? { return \.updatedAt }
  static public var deletedAtKey: TimestampKey? { return \.deletedAt }
  public static let name = "service"
  /// Service's unique identifier.
  public var id: ObjectID?
  /// Service's unique réference.
  public var ref: String?
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
              organization: Organization.ID, author: User.ID,
              parent: Service.ID? = nil, orgServiceRef: String? = nil,
              state: ObjectStatus = ObjectStatus.defaultValue,
              pricing: Int = 0, disponibility: Int = 0, reliability: Int = 0,
              ownership: Int = 0, perishability: Int = 0, variability: Int = 0,
              inseparability: Int = 0, intengibility: Int = 0, nobillable: Bool = false,
              negotiable: Bool = false, locationID: Place.ID? = nil, geoPerimeter: Int = 1,
              openOn: Date = Date(), endOn: Date? = nil,
              createdAt : Date = Date(), updatedAt: Date? = nil,
              deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id         = id
    self.ref        = Utils.newRef(kServiceReferenceBasePrefix, size: kServiceReferenceLength)
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
  }
  
}


/// Allows `Service` to be used as a Fluent migration.
extension Service: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(Service.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
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
      builder.field(for: \.locationID)
      builder.field(for: \.geoPerimeter)
      builder.field(for: \.openOn)
      builder.field(for: \.endOn)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.reference(from: \Service.authorID, to: \User.id, onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \Service.parentID, to: \Service.id, onUpdate: .noAction, onDelete: .setNull)
      builder.reference(from: \Service.industryID, to: \Industry.id, onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \Service.organizationID, to: \Organization.id, onUpdate: .noAction, onDelete: .cascade)
      builder.reference(from: \Service.locationID, to: \Place.id, onUpdate: .noAction, onDelete: .setNull)
    }
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

  /// TODO: Complet in next Version to retrieve parent tree
  func parentList(req: Request) {
    var qry =
    """
    WITH RECURSIVE serv
    AS (SELECT sv.*, (sv."id"::text) as chainkey, 0 as indent
    FROM service as sv
    WHERE sv.id = \(self.id!)
    UNION ALL
    SELECT  ss.*,
    (CAST(s.chainkey AS text) || CAST(ss.id AS text) ) as chainkey, s.indent + 1 as indent
    FROM service as ss
    INNER JOIN serv as s ON ss."id" = s."parentID"
    )
    SELECT *
    FROM serv
    WHERE indent != 0
    ORDER BY chainkey ASC
  """
    
  }
}

/// Allows `Service` to be used as a dynamic parameter in route definitions.
extension Service: Parameter {
  
}

/// Seed for service
struct SeedService: Migration {
  typealias Database = AdoptedDatabase
  
  static func prepare(on connection: AdoptedConnection) -> Future<Void> {
    let serv = Service(label: "Simple Alterned Service", billing: BillingPlan.direct, description: "mais s'est aussi adapté à la bureautique informatique, sans que son contenu n'en soit modifié. Il a été popularisé dans les années 1960 grâce à la vente de feuilles Letraset contenant des passages du Lorem Ipsum, et, plus récemment, par son inclusion dans des applications de mise en page de texte, comme Aldus PageMaker", industry: 2, price: 0.0, shortLabel: "Simple AS", organization: 3, author: 4, state: .online)
    
    let serv1 = Service(label: "Mid Game", billing: BillingPlan.mensual, description: "Le Lorem Ipsum ainsi obtenu ne contient aucune répétition, ni ne contient des mots farfelus, ou des touches d'humour", industry: 1, price: 19.99, shortLabel: "Mid Game", organization: 3, author: 5, parent: 7)
    serv1.intengibility  = 445
    serv1.pricing        = 1000
    serv1.disponibility  = 90
    serv1.reliability    = 220
    serv1.ownership      = 300
    serv1.status = ObjectStatus.await.rawValue
    serv1.negotiable = true
    let serv2 = Service(label: "Haute gamme", billing: BillingPlan.mensual, description: "Inscrivez-vous dès aujourd'hui pour réserver votre place et être tenu(e) informé(e) de la publication de l'agenda. L'AWS Summit Paris revient avec toujours plus de sessions, de témoignages clients et d'innovations !", industry: 1, price: 39.99, shortLabel: "HG", organization: 3, author: 3, parent: 2)
    serv2.negotiable = true
    
    let serv3 = Service(label: "Haute gamme Gold", billing: BillingPlan.mensual, description: "Du texte. Du texte.' est qu'il posséde une distribution de lettres plus ou moins normale, et en tout cas comparable avec celle du français standard", industry: 1, price: 59.99, shortLabel: "HDG", organization: 5, author: Config.Static.bbMainUserID, parent: 5, state: .online)
    let serv4 = Service(label: "Solar service install", billing: BillingPlan.mensual, description: "Plusieurs variations de Lorem Ipsum peuvent être trouvées ici ou là, mais la majeure partie d'entre elles a été altérée par l'addition d'humour ou de mots aléatoires qui ne ressemblent pas une seconde à du texte standard", industry: 3, price: 59.99, shortLabel: "2SI", organization: 3, author: 5)
    let serv5 = Service(label: "Some other Service", billing: BillingPlan.hourly, description: "De nombreuses suites logicielles de mise en page ou éditeurs de sites Web ont fait du Lorem Ipsum leur faux texte par défaut, et une recherche pour 'Lorem Ipsum' vous conduira vers de nombreux sites qui n'en sont encore qu'à leur phase de construction.", industry: 3, price: 0.99, shortLabel: "2SI", organization: 5, author: 3, parent: 7, orgServiceRef: "1AFF23")
    serv5.status  = ObjectStatus.online.rawValue
    let serv6     = Service(label: "means Amendment 1", billing: BillingPlan.hourly, description: "Throughout the development of MISRA C, the main focus has been to address vulnerabilities in the C language, particularly for use in embedded systems, and primarily targeted at safety-related applications. MISRA C particularly applies to freestanding applications, which use a sub-set of the C Standard Library. \nOne of the great successes of MISRA C has been its adoption across many industries, and in environments where safety-criticality is less of a concern, but where data-security is more of an issue.", industry: 3, price: 2.99, shortLabel: "Amendment One", organization: 9, author: 5, orgServiceRef: "23-54AA4")
    serv6.status      = ObjectStatus.offline.rawValue
    serv6.negotiable  = true
    
    let serv7         = Service(label: "Coverage classifcation", billing: BillingPlan.annual, description: "There have been discussions as to the applicability of MISRA C for secure applications. The MISRA C \nWorking Group have listened to those concerns, and have compiled this Addendum to document the coverage of MISRA C against CERT C.", industry: 3, price: 0.99, shortLabel: "Coverage", organization: 9, author: 5, parent: 7, orgServiceRef: "1AFF23")
    serv7.status      = ObjectStatus.rejected.rawValue
    let serv8 = Service(label: "Où vous renseigner", billing: BillingPlan.biennial, description: "Les programmes d’études sont offerts dans un réseau de 2 444 écoles publiques (formation des jeunes du primaire et du secondaire), 199 centres de formation professionnelle et 208 centres d’éducation des adultes. Ces établissements sont regroupés au sein de 60 commissions scolaires francophones et de 9 anglophones, selon un découpage territorial, ainsi que de 3 commissions scolaires à statut particulier.", industry: 3, price: 99.99, shortLabel: "renseigner", organization: 7, author: 6, parent: 7)
    serv8.endOn     = Date(timeInterval: 1000000, since: Date())
    
    let serv9       = Service(label: "Les établissements et programmes d’enseignement collégial", billing: BillingPlan.semestrial, description: "", industry: 3, price: 32.99, shortLabel: "collégial", organization: 3, author: 5, orgServiceRef: "1AFF23")
    let serv10      = Service(label: "Choisir un établissement d'enseignement et un programme d'études", billing: BillingPlan.direct, description: "'est-à-dire un établissement reconnu par le ministère de l'Éducation et de l'Enseignement supérieur ou un autre ministère québécois, afin de pouvoir présenter une demande de sélection temporaire pour études et un permis d'études du gouvernement fédéral. De nombreuses suites logicielles de mise en page ou éditeurs de sites Web ont fait du Lorem Ipsum leur faux texte par défaut, et une recherche pour 'Lorem Ipsum' vous conduira vers de nombreux sites qui n'en sont encore qu'à leur phase de construction.", industry: 3, price: 45.99, shortLabel: "programme d'études", organization: 3, author: 5, orgServiceRef: "340001")
    serv10.intengibility  = 349
    serv10.pricing        = 865
    serv10.disponibility  = 990
    serv10.reliability    = 867
    serv10.ownership      = 688
    serv10.negotiable     = true
    
    _ = serv.save(on: connection).catch({ (e) in
      print("ERROR SERVICE 0 ----------")
      print(e)
    }).transform(to: ())
    _ = serv1.save(on: connection).catch({ (e) in
      print("ERROR SERVICE 1 ----------")
      print(e)
    }).transform(to: ())
    _ = serv2.create(on: connection).transform(to: ())
    _ = serv3.create(on: connection).transform(to: ())
    _ = serv4.create(on: connection).transform(to: ())
    _ = serv5.create(on: connection).transform(to: ())
    _ = serv6.create(on: connection).transform(to: ())
    _ = serv7.create(on: connection).transform(to: ())
    _ = serv8.create(on: connection).transform(to: ())
    _ = serv9.create(on: connection).catch({ (e) in
      print("ERROR SERVICE 9 ----------")
      print(e)
    }).transform(to: ())
    _ = serv10.save(on: connection).catch({ (e) in
      print("ERROR SERVICE 10 ----------")
      print(e)
    }).transform(to: ())
    
    return .done(on: connection)
  }
  
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    return .done(on: connection)
  }
}

