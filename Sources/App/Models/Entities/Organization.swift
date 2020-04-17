//
//  Organization.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 15/11/2019.
//


import Foundation
import Vapor
import FluentPostgreSQL

let kOrganizationReferenceBasePrefix  = "ORG"
let kOrganizationReferenceLength      = kReferenceDefaultLength

/**
 *1 : Non profit organization
 2 : Aid service
 3 : Educative structure
 4 : Smal profit entity
 5 : Gov administration
 6 : High profit structure:
 */
public enum OrganizationKind: Int, Codable, RawRepresentable, CaseIterable {
  
  case noprofit     = 0 //
  case aid          = 1 //
  case educative    = 2 //
  case associative  = 3 // small bussiness
  case informative  = 4 //
  case pureprofit   = 8 //
  
  public static var defaultValue: OrganizationKind {
    return .pureprofit
  }
  
  public static var defaultRaw: OrganizationKind.RawValue {
    return defaultValue.rawValue
  }
}

/**
 *1
 */
public enum OrganizationSize: Int, Codable, ReflectionDecodable, RawRepresentable, CaseIterable {
  
  public static func reflectDecoded() throws -> (OrganizationSize, OrganizationSize) {
    return (eti, network)
  }
  
  case division = 1 // Subdivision of an organization /// Pas besoin d'informations légales
  case eti   // independant worker / auto entrepreneur  /// Pas besoin de certaines informations légales
  case tpe   // très petite entreprise
  case pe  // small bussiness entre 10 salariés et 49 salariés avec soit un chiffre d'affaires inférieur à 10 millions d'euros par an, soit un total bilan inférieur à 10 millions d'euros.  
  case me // entre 50 salariés et 250 salariés avec soit un chiffre d'affaires inférieur à 50 millions d'euros par an, soit un total bilan inférieur à 43 millions d'euros
  case ge       // plus de 250 salariés et à la fois un chiffre d'affaires supérieur ou égal à 50 millions d'euros par an et un total bilan supérieur ou égal à 43 millions d'euros
  case group       // plus de 250 salariés et à la fois un chiffre d'affaires supérieur ou égal à 50 millions d'euros par an et un total bilan supérieur ou égal à 43 millions d'euros
  case holding       // Holding de plusieurs entreprises de différentes tailles d'une même structure
  case network       // Réseau d'entreprise indépendante
  
  public static var defaultValue: OrganizationSize {
    return .eti
  }
  
  public static var defaultRaw: OrganizationSize.RawValue {
    return defaultValue.rawValue
  }
}


public enum OrganizationGender: Int, RawRepresentable, Codable, CaseIterable {
  /*
   UK / Ireland / Commonwealth
   Charitable incorporated organisation (CIO)Community interest company (CIC)Industrial and provident society (IPS)
   Limited company (Ltd.) by guaranteeby sharesproprietarypublicUnlimited company
   United States
   Benefit corporationC corporationLimited liability company (LLC) Low-profit LLCSeries LLCLimited liability limited partnership (LLLP)S corporationDelaware corporation / statutory trust - Massachusetts business trust - Nevada corporation
   */
  
  /// les entreprises individuelles
  case freelance = 1, ei = 2
  /// Entreprise Individuelle à Responsabilité Limitée (EIRL)
  case eirl
  /// Etablissement Public Industriel et Commercial (EPIC)
  case epic
  /// Société Civile (SC)
  case sc
  /// Société Coopérative d’Intérêt Collectif (SCIC)
  case scic
  /// Sociétés Commandite Simple (SCS)
  case scs
  /// Société Civile pouvant être Immobilières (SCI)
  case sci
  /// Société Civile pouvant être Professionnelle (SCP)
  case scp
  /// Société Coopérative et Participative
  case scop
  /// Société Civile pouvant être de Moyen (SCM)
  case scm
  ///  Société Nationalisée (SN)
  case sn
  ///  Société en Nom Collectif (SNC)
  case snc
  /// Exploitation agricole à Responsabilité Limitée (EARL)
  case earl
  /// Société à Responsabilité Limitée (SARL)
  case sarl
  /// Entreprise Unipersonnelle à Responsabilité Limitée (EURL)
  case eurl
  /// Société par Actions Simplifiée (SAS)
  case sas
  /// Société par Actions Simplifiée Unipersonnelle (SASU)
  case sasu
  /// Société Anonyme (SA)
  case sa
  /// Groupement  d'Intérêt Economique
  case gie
  // Union Europeen
  /// Societas Etrangère (SE) / Socété Européenne
  case se
  /// Societas Cooperativa Europeene (SCE)
  case sce
  /// Societas Privata Europeene (SPE)
  case spe
  /// Societas Unius Personae Europeene (SUP)
  case sup
  /// Groupement Européen d'Intérêt Economique (GEIE)
  case geie
  /// European Economic Interest Grouping (EEIG = GEIE)
  case eeig
  
  public func textual() -> String {
    switch self {
      case .freelance :
        return "Auto Entrepreneur (Micro-Entreprise)"
      case .ei :
        return "Entreprise Individuel (EI)"
      case .eirl:
        return "Entreprise Individuelle à Responsabilité Limitée (EIRL)"
      case .epic:
        return "Etablissement Public Industriel et Commercial (EPIC)"
      case .sc :
        return "Société Civile (SC)"
      case .scic:
        return "Société Coopérative d’Intérêt Collectif (SCIC)"
      case .scs:
        return "Sociétés Commandite Simple (SCS)"
      case .sci :
        return "Société Civile pouvant être Immobilières (SCI)"
      case .scp:
        return "Société Civile pouvant être Professionnelle (SCP)"
      case .scop:
        return "Société Coopérative et Participative"
      case .scm :
        return "Société Civile pouvant être de Moyen (SCM)"
      case .sn:
        return "Société Nationalisée (SN)"
      case .snc:
        return "Société en Nom Collectif (SNC)"
      case .earl :
        return "Exploitation agricole à Responsabilité Limitée (EARL)"
      case .sarl:
        return "Société à Responsabilité Limitée (SARL)"
      case .eurl:
        return "Entreprise Unipersonnelle à Responsabilité Limitée (EURL)"
      case .sas :
        return "Société par Actions Simplifiée (SAS)"
      case .sasu:
        return "Société par Actions Simplifiée Unipersonnelle (SASU)"
      case .sa:
        return "Société Anonyme (SA)"
      case .gie :
        return "Groupement  d'Intérêt Economique"
      case .se:
        return "Societas Etrangère / Socété Européenne (SE)"
      case .sce:
        return "Societas Cooperativa Europeene (SCE)"
      case .spe :
        return "Societas Privata Europeene (SPE)"
      case .sup:
        return "Societas Unius Personae Europeene (SUP)"
      case .geie:
        return "Groupement Européen d'Intérêt Economique (GEIE)"
      default:
        return "European Economic Interest Grouping (EEIG = GEIE)"
    }
  }
  
  public static var defaultValue: OrganizationGender {
    return .freelance
  }
  
  public static var defaultRaw: OrganizationGender.RawValue {
    return defaultValue.rawValue
  }
}


extension Int {
  var osize : OrganizationSize {
    return OrganizationSize(rawValue: self) ?? OrganizationSize.defaultValue
  }
  
  var okind : OrganizationKind {
    return OrganizationKind(rawValue: self) ?? OrganizationKind.defaultValue
  }
  
  var ogender : OrganizationGender {
    return OrganizationGender(rawValue: self) ?? OrganizationGender.defaultValue
  }
  
}

// An industry activity
final public class Organization: AdoptedModel {
  static public var createdAtKey: TimestampKey? { return \.createdAt }
  static public var updatedAtKey: TimestampKey? { return \.updatedAt }
  static public var deletedAtKey: TimestampKey? { return \.deletedAt }
  public static let name = "organization"
  /// Organization's unique identifier.
  public var id: ObjectID?
  /// Organization's unique réference .
  public var ref: String
  /// Organization's unique réference into the organization.
  public var organizationRef: String?
  /// Organization Parent Organization.ID.
  public var parentID: Organization.ID?
  /// Reference to sector
  public var sectorID: Sector.ID
  /// Submitted brand if you are working throught a brand licence.
  public var brand: String?
  /// CEO given denomination name as short as possible.
  public var denomination: String?
  /// full name for this organization could be a initials, abbreviation etc.
  public var shortLabel: String
  /// full label name for this organization (raison social).
  public var label: String
  /// Organization's slogan.
  public var slogan: String?
  /// Organization kind.
  public var okind: OrganizationKind.RawValue
  /// Organization's title string.
  public var state: ObjectStatus.RawValue
  /// Organization size type.
  public var osize: OrganizationSize.RawValue
  /// Organization juridic for type.
  public var form: OrganizationGender.RawValue
  /// Organization juridic for type.
  public var publicPart: String?
  /// Organization's currency.
  public var money: String
  /// Organization status redaction for some form of organization this is required.
  public var status: String?
  /// Organization's description.
  public var description: String
  /// Organization siret number.
  public var siret: String?
  /// Organization tva number.
  public var tva: String?
  /// Organization siren number.
  public var siren: String?
  /// Organization siren number.
  public var rcs: String?
  /// Organization APET code.
  public var apetCode: String?
  /// Organization APET label.
  public var apetLabel: String?
  /// Organization NAF code.
  public var nafCode: String?
  /// Organization NAF label.
  public var nafLabel: String?
  /// Organization Market registration
  public var market: String?
  /// Organization Market value
  public var marketValue: String?
  /// Organization NAF label.
  public var capital: String?
  /// Organization assurance number
  public var insurance: String?
  /// Organization assurance number
  public var insuranceName: String?
  /// activity begin date.
  public var activityStartedAt: Date?
  /// activity ended date.
  public var activityEndedAt: Date?
  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  /// Creates a new `Organization`.
  public init(label: String, slogan: String?, description: String,
              sector: Sector.ID, kind: OrganizationKind, money: String,
              state: ObjectStatus, size: OrganizationSize = OrganizationSize.pe,
              parent: Organization.ID?, shortLabel: String,
              organizationRef: String? = nil, siren: String? = nil, siret:  String? = nil,
              tva:  String? = nil, activityStartedAt: Date? = nil,
              activityEndedAt: Date? = nil,
              brand: String? = nil, denomination: String? = nil,
              orgGender:  OrganizationGender = OrganizationGender.defaultValue,
              publicPart: String? = nil, insurance: String? = nil,
              insuranceName: String? = nil, apetCode: String? = nil,
              apetLabel: String? = nil, nafCode: String? = nil, nafLabel: String? = nil,
              capital:  String? = nil, market: String? = nil, marketValue: String? = nil,
              status: String? = nil, rcs: String? = nil,
              createdAt: Date = Date(), updatedAt: Date? = nil, deletedAt: Date? = nil,
              id: ObjectID? = nil) {
    self.id         = id
    self.ref        = Utils.newRef(kOrganizationReferenceBasePrefix, size: kOrganizationReferenceLength)
    self.organizationRef  = organizationRef
    self.parentID         = parent
    self.label            = label
    self.shortLabel       = shortLabel
    self.slogan           = slogan
    self.money            = money
    self.state            = state.rawValue
    self.okind            = kind.rawValue
    self.osize            = size.rawValue
    self.sectorID         = sector
    self.description      = description
    self.siren            = siren
    self.siret            = siret
    self.tva              = tva
    self.createdAt        = createdAt
    self.updatedAt        = updatedAt
    self.deletedAt        = deletedAt
    self.form             = orgGender.rawValue
  }
}

/// Allows `Organization` to be used as a Fluent migration.
extension Organization: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(Organization.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.organizationRef)
      builder.field(for: \.parentID)
      builder.field(for: \.sectorID)
      builder.field(for: \.brand)
      builder.field(for: \.denomination)
      builder.field(for: \.shortLabel)
      builder.field(for: \.label)
      builder.field(for: \.slogan)
      builder.field(for: \.okind)
      builder.field(for: \.state)
      builder.field(for: \.osize)
      builder.field(for: \.form)
      builder.field(for: \.publicPart)
      builder.field(for: \.money)
      builder.field(for: \.status)
      builder.field(for: \.description)
      builder.field(for: \.siret)
      builder.field(for: \.tva)
      builder.field(for: \.siren)
      builder.field(for: \.rcs)
      builder.field(for: \.apetCode)
      builder.field(for: \.apetLabel)
      builder.field(for: \.nafCode)
      builder.field(for: \.nafLabel)
      builder.field(for: \.market)
      builder.field(for: \.marketValue)
      builder.field(for: \.capital)
      builder.field(for: \.insurance)
      builder.field(for: \.insuranceName)
      builder.field(for: \.activityStartedAt)
      builder.field(for: \.activityEndedAt)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.unique(on: \.organizationRef)
      builder.unique(on: \.tva)
      builder.unique(on: \.siret)
      builder.unique(on: \.siren)
      builder.reference(from: \Organization.parentID,
                        to: \Organization.id,
                        onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \Organization.sectorID,
                        to: \Sector.id,
                        onUpdate: .noAction, onDelete: .noAction)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Organization.self, on: conn)
  }
}

public extension Organization {
  /// Fluent relation to the sector that is relative to this organization.
  var sector: Parent<Organization, Sector> {
    return parent(\.sectorID)
  }
  /// Fluent relation to the services that is relative to this organization.
  var services: Children<Organization, Service> {
    return children(\.organizationID)
  }
  
  /// Parent relation between two organization.
  var parent: Parent<Organization, Organization>? {
    return parent(\.parentID)
  }
  
  // this user's related sub organization relations
  var organizations: Children<Organization, Organization> {
    return children(\.parentID)
  }
  
  /// this organization's related users link
  var members: Siblings<Organization, User, UserOrganization> {
    // Controle to add
    return siblings()
  }
  
  /// this organization's related users link
  var contacts: Siblings<Organization, Contact, ContactOrganization> {
    // Controle to add
    return siblings()
  }
}

/// Allows `Organization` to be used as a dynamic parameter in route definitions.
extension Organization: Parameter { }

struct SeedOrganization: Migration {
  typealias Database = AdoptedDatabase
  
  static func prepare(on connection: AdoptedConnection) -> Future<Void> {

    let org3 = Organization(label: "UnitedHealth Group", slogan: "Think different", description: "UnitedHealth Group, Inc. (UNH) is the largest health care services company in the world, serving over 50 million individuals in the United States as of late 2018 and 5 million in Brazil. The company provides a wide range of health care products and services, such as health maintenance organizations (HMOs), point of service plans (POS), preferred provider organizations (PPOs), and managed fee-for-service programs.", sector: 14, kind: OrganizationKind.aid, money: "EUR", state: ObjectStatus.defaultValue, parent: nil, shortLabel: "UH Group", id: 3)

    let org5 = Organization(label: "Thermo Fisher Scientific", slogan: "", description: "Apple est créée le 1er avril 1976 dans le garage de la maison d'enfance de Steve Jobs à Los Altos en Californie par Steve Jobs, Steve Wozniak et Ronald Wayne13, puis constituée sous forme de société le 3 janvier 1977 à l'origine sous le nom d'Apple Computer, mais pour ses 30 ans et pour refléter la diversification de ses produits, le mot « computer » est retiré le 9 janvier 200714.", sector: 45, kind: OrganizationKind.aid, money: "EUR", state: ObjectStatus.defaultValue, parent: nil, shortLabel: "Thermo FS", id: 5)
    
    let org7 = Organization(label: "CVS Health", slogan: "health insurance", description: "The size of the company gives Aetna significant competitive advantages, such as the ability to scale its fixed costs, maintain underwriting expertise and gain greater pricing leverage. Aetna also has solid operations within the group market niche, which positions the company well in one of the most profitable health insurance segments", sector: 19, kind: OrganizationKind.aid, money: "USD", state: ObjectStatus.defaultValue, size: OrganizationSize.group, parent: nil, shortLabel: "CVS H", id: 7)
    
    let org8 = Organization(label: "De Finibus Bonorum et Malorum", slogan: "Section 1.10.32 du \"De Finibus Bonorum et Malorum\" de Ciceron (45 av. J.-C.)", description: "Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?", sector: 5, kind: OrganizationKind.defaultValue, money: "EUR", state: ObjectStatus.defaultValue, size: OrganizationSize.defaultValue, parent: 3, shortLabel: "De FBM", id: 8)
    
    let org9 = Organization(label: "Nam libero tempore", slogan: "Traduction de H. Rackham (1914)", description: "In a free hour, when our power of choice is untrammelled and when nothing prevents our being able to do what we like best, every pleasure is to be welcomed and every pain avoided. But in certain circumstances and owing to the claims of duty or the obligations of business it will frequently occur that pleasures have to be repudiated and annoyances accepted. The wise man therefore always holds in these matters to this principle of selection: he rejects pleasures to secure other greater pleasures, or else he endures pains to avoid worse pains.", sector: 4, kind: OrganizationKind.noprofit, money: "USD", state: ObjectStatus.defaultValue, parent: 3, shortLabel: "NLT", id: 9)
    
    let org10 = Organization(label: "Vapor Tutorials", slogan: "How to Create Parent-Child Relations in Vapor 3", description: "For 4 and 5, the formula is the same, except at 5, we use the owner helper we created above to retrieve the owner of the post, and then return that \nThanks for reading! Happy coding in Vapor 3!.", sector: 6, kind: OrganizationKind.defaultValue, money: "EUR", state: ObjectStatus.defaultValue, size: OrganizationSize.group, parent: nil, shortLabel: "Vap Tut", id: 10)
    
    let org12 = Organization(label: "Vapor Documentation", slogan: "Auto-generated documentation from code comments.", description: "This is a very is a very simple setup: the User class has a username property, and the Post class has a title and userID property. This userID property will be needed to attach a user to each post that is created in the database.", sector: 49, kind: OrganizationKind.aid, money: "USD", state: ObjectStatus.defaultValue, size: OrganizationSize.me, parent: 10, shortLabel: "Vap Doc", id: 12)
    
    let org13 = Organization(label: "Deploying to Heroku", slogan: "Deploying to Heroku with Postgres in Vapor 2.0", description: "This tutorial will cover how to create parent-child relations in Vapor 3.\nParent-Child relations are useful for when one of your model \"owns\" multiple objects in another model. The classic example for this is a forum website: A User object has many posts, but each post belongs to only 1 user.", sector: 5, kind: OrganizationKind.defaultValue, money: "EUR", state: ObjectStatus.defaultValue, size: OrganizationSize.defaultValue, parent: 12, shortLabel: "Dep Heroku", id: 13)
    
    _ = org3.create(on: connection).transform(to: ())
    _ = org5.create(on: connection).transform(to: ())
    _ = org7.create(on: connection).transform(to: ())
    _ = org8.create(on: connection).transform(to: ())
    _ = org9.create(on: connection).transform(to: ())
    _ = org10.create(on: connection).transform(to: ())
    _ = org12.create(on: connection).transform(to: ())
    _ = org13.create(on: connection).transform(to: ())
    return .done(on: connection)
  }
  
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    
    return .done(on: connection)
  }
}

