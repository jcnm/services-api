//
//  Organization.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 15/11/2019.
//


import Foundation
import Vapor
import FluentPostgreSQL

let kOrganizationReferenceBasePrefix  = "SO"
let kOrganizationReferenceLength      = kReferenceDefaultLength

public enum OrganizationKind: Int, Codable, RawRepresentable, CaseIterable {
//  10  Entrepreneur individuel
//  21  Indivision
//  22  Société créée de fait
//  23  Société en participation
//  24  Fiducie
//  27  Paroisse hors zone concordataire
//  29  Autre groupement de droit privé non doté de la personnalité morale
//  31  Personne morale de droit étranger, immatriculée au RCS (registre du commerce et des sociétés)
//  32  Personne morale de droit étranger, non immatriculée au RCS
//  41  Etablissement public ou régie à caractère industriel ou commercial
//  51  Société coopérative commerciale particulière
//  52  Société en nom collectif
//  53  Société en commandite
//  54  Société à responsabilité limitée (SARL)
//  55  Société anonyme à conseil d'administration
//  56  Société anonyme à directoire
//  57  Société par actions simplifiée
//  58  Société européenne
//  61  Caisse d'épargne et de prévoyance
//  62  Groupement d'intérêt économique
//  63  Société coopérative agricole
//  64  Société d'assurance mutuelle
//  65  Société civile
//  69  Autre personne morale de droit privé inscrite au registre du commerce et des sociétés
//  71  Administration de l'état
//  72  Collectivité territoriale
//  73  Etablissement public administratif
//  74  Autre personne morale de droit public administratif
//  81  Organisme gérant un régime de protection sociale à adhésion obligatoire
//  82  Organisme mutualiste
//  83  Comité d'entreprise
//  84  Organisme professionnel
//  85  Organisme de retraite à adhésion non obligatoire
//  91  Syndicat de propriétaires
//  92  Association loi 1901 ou assimilé
//  93  Fondation
//  99  Autre personne morale de droit privé
//
//  case tbd                            = 0 //
//  // 1. Entrepreneur individuel
//  case individual                     = 10 //
//  // 2. Groupement de droit privé non doté de la personnalité morale
//  case unmoralyPrivateGroup           = 20 //
//  // 3. Personne morale de droit étranger
//  case foreign                        = 30 //
//  // 4. Personne morale de droit public soumise au droit commercial
//  case publicNCommercial              = 40
//  // 5. Société commerciale
//  case commercial                     = 50 //
//  // 6. Compagnie registration Office // immatriculée au Registre du Commerce et des Sociétés
//  case otherRCO                       = 60
//  // 7. Personne morale et organisme soumis au droit administratif
//  case administrative                 = 70
//  // 8. Organisme privé spécialisé
//  case privateSpecial                 = 80
//  // 9. Groupement de droit privé
//  case privateGroup                   = 90
  
  case nc       = 0 // Not Concerned by a jurudic status
  /// les entreprises individuelles
  case ei       = 10
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

  public var textual: String {
    switch self {
      case .nc :
        return "Non Concernée"
      case .ei :
        return "Entreprise Individuel (EI, Micro-Entreprise)"
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

  public static var defaultValue: OrganizationKind {
    return .nc
  }
  
  public static var defaultRaw: OrganizationKind.RawValue {
    return defaultValue.rawValue
  }

}

/**
 *
 */
public enum OrganizationSize: Int, Codable, ReflectionDecodable, RawRepresentable, CaseIterable {
  
  public static func reflectDecoded() throws -> (OrganizationSize, OrganizationSize) {
    return (eti, holding)
  }
  /// These are note entreprise
  case division     = 1
  /// These are micro entreprise
  case eti          = 10 // independant worker / auto entrepreneur  /// Pas besoin de certaines informations légales
  /// These are small entreprise 10 - 49 employees
  case pe           = 20  // small bussiness entre 10 salariés et 49 salariés avec soit un chiffre d'affaires inférieur à 10 millions d'euros par an, soit un total bilan inférieur à 10 millions d'euros.
  case me           = 30 // entre 50 salariés et 250 salariés avec soit un chiffre d'affaires inférieur à 50 millions d'euros par an, soit un total bilan inférieur à 43 millions d'euros
  case ge           = 50       // plus de 249 salariés et à la fois un chiffre d'affaires supérieur ou égal à 50 millions d'euros par an et un total bilan supérieur ou égal à 43 millions d'euros
  case holding      = 70       // Holding de plusieurs entreprises de différentes tailles d'une même structure
    
  public static var defaultValue: OrganizationSize {
    return .eti
  }
  
  public static var defaultRaw: OrganizationSize.RawValue {
    return defaultValue.rawValue
  }
  
  public var textual: String {
    switch self {
      case .division :
        return "Division d'une organisation"
      case .eti:
        return "Organisation Individuelle"
      case .pe:
        return "Organisation Petite"
      case .me :
        return "Organisation Moyenne"
      case .ge:
        return "Organisation de Grande taille"
      case .holding :
        return "Pilote d'Entreprises (Holding)"
    }
  }
}

public extension Int {
  var osize : OrganizationSize {
    return OrganizationSize(rawValue: self) ?? OrganizationSize.defaultValue
  }
  
  var okind : OrganizationKind {
    return OrganizationKind(rawValue: self) ?? OrganizationKind.defaultValue
  }
  
//  var ogender : OrganizationGender {
//    return OrganizationGender.jCatCode(self)
//  }
  
}

public typealias OrganizationJuridic = Int
// An industry activity
public final class Organization: AdoptedModel, Auditable {
public static var auditID = HistoryDataType.organization.rawValue

  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  public static let name = "organization"
  /// Organization's unique identifier.
  public var id: ObjectID?
  /// Organization's unique réference .
  public var ref: String
  /// Organization's unique slug réference.
  public var slugOrg: String
  /// User id.
//  public var authorID: User.ID
  /** Organization's logo */
  public var logo: AbsolutePath?
  /** Organization's background background */
  public var background: AbsolutePath?
  /** Organization's background wallpaper */
  public var wallpaper: AbsolutePath?
  /// Organization's unique réference into the organization.
  public var organizationRef: String?
  /// Organization Parent Organization.ID.
  public var parentID: Organization.ID?
  /// Reference to sector
  public var sectorID: Sector.ID
  /// Submitted brand if you are working throught a brand licence.
  public var brand: String?
  /// CEO given denomination name as short as possible.
  public var sigle: String?
  /// full name for this organization could be a initials, abbreviation etc.
  public var shortLabel: String
  /// full legal name name for this organization (raison social).
  public var legalName: String
  /// Organization's slogan.
  public var slogan: String?
  /// Organization's title string.
  public var state: ObjectStatus.RawValue
  /// Organization kind.
  public var okind: Int?
  /// Organization size type.
  public var osize: OrganizationSize.RawValue
  /// Organization juridic for type.
  public var juridicForm: OrganizationJuridic
  /// Organization juridic for type.
  public var juridicCatLabel: String?
  /// Organization juridic for type.
  public var juridicCatCode: Int?
  /// Organization juridic for type.
  public var publicPart: String?
  /// Organization's currency.
  public var currencyID: Currency.ID
  /// Organization status redaction for some form of organization this is required.
  public var status: String?
  /// Organization's description.
  public var description: String
  /// summary from the description given
  public var summary: String?
  /// Organization siret number.
  public var siret: String?
  /// Organization tva number.
  public var tva: String?
  /// Organization communityTVA
  public var communityTVA: String?
  /// Organization siren number.
  public var siren: String?
  /// Organization siren number.
  public var rcs: String?
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
  public init(label: String,  slug: String? = nil, slogan: String?, description: String,
              sector: Sector.ID, kind: Int?, currency: Currency.ID,
              state: ObjectStatus, size: OrganizationSize = OrganizationSize.pe,
              parent: Organization.ID?, shortLabel: String,
              organizationRef: String? = nil, siren: String? = nil, siret:  String? = nil,
              tva:  String? = nil, communityTVA: String? = nil, activityStartedAt: Date? = nil,
              activityEndedAt: Date? = nil,
              brand: String? = nil, sigle: String? = nil,
              orgGender:  OrganizationJuridic = 0, juridicCatCode: Int? = nil,
              juridicCatLabel: String? = nil, publicPart: String? = nil, insurance: String? = nil,
              insuranceName: String? = nil, nafCode: String? = nil,
              nafLabel: String? = nil, capital:  String? = nil, market: String? = nil,
              marketValue: String? = nil, status: String? = nil, rcs: String? = nil,
              logo: String? = nil, background: String? = nil, wallpaper: String? = nil,
              createdAt: Date = Date(), updatedAt: Date? = nil, deletedAt: Date? = nil,
              id: ObjectID? = nil) {
    self.id         = id
    self.ref        = Utils.newRef(kOrganizationReferenceBasePrefix, size: kOrganizationReferenceLength)
    let formatSlug  = "\(label) \(slogan ?? "") \(nafLabel ?? "") \(juridicCatLabel ?? "")"
      .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      .replacingOccurrences(of: " ", with: "-")
      .replacingOccurrences(of: "/", with: "-")
      .replacingOccurrences(of: "\\", with: "-")
    self.slugOrg    = slug == nil ? formatSlug + "-"  + self.ref : slug!
    self.organizationRef  = organizationRef
    self.parentID         = parent
    self.legalName        = label
    self.shortLabel       = shortLabel
    self.slogan           = slogan
    self.currencyID       = currency
    self.state            = state.rawValue
    self.okind            = kind
    self.osize            = size.rawValue
    self.sectorID         = sector
    self.description      = description
    self.siren            = siren
    self.siret            = siret
    self.tva              = tva
    self.communityTVA      = communityTVA
    self.createdAt        = createdAt
    self.updatedAt        = updatedAt
    self.deletedAt        = deletedAt
    self.juridicForm      = orgGender
    self.juridicCatLabel  = juridicCatLabel
    self.juridicCatCode   = juridicCatCode
    self.sigle            = sigle
    self.nafCode          = nafCode
    self.nafLabel         = nafLabel
    self.insurance        = insurance
    self.insuranceName    = insuranceName
    self.summary          = description.resume()
    self.logo             = logo
    self.background       = background
    self.wallpaper        = wallpaper
  }
}

/// Allows `Organization` to be used as a Fluent migration.
extension Organization: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    let oTable = AdoptedDatabase.create(Organization.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.slugOrg)
      builder.field(for: \.organizationRef)
      builder.field(for: \.parentID)
      builder.field(for: \.sectorID)
      builder.field(for: \.brand)
      builder.field(for: \.sigle)
      builder.field(for: \.shortLabel)
      builder.field(for: \.legalName)
      builder.field(for: \.slogan)
      builder.field(for: \.logo)
      builder.field(for: \.background)
      builder.field(for: \.wallpaper)
      builder.field(for: \.okind)
      builder.field(for: \.state)
      builder.field(for: \.osize)
      builder.field(for: \.juridicForm)
      builder.field(for: \.juridicCatCode)
      builder.field(for: \.juridicCatLabel)
      builder.field(for: \.publicPart)
      builder.field(for: \.currencyID)
      builder.field(for: \.status)
      builder.field(for: \.description)
      builder.field(for: \.summary)
      builder.field(for: \.siret)
      builder.field(for: \.tva)
      builder.field(for: \.communityTVA)
      builder.field(for: \.siren)
      builder.field(for: \.rcs)
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
      builder.unique(on: \.tva)
      builder.unique(on: \.communityTVA)
      builder.unique(on: \.siret)
      builder.unique(on: \.siren)
      builder.unique(on: \.slugOrg)
      builder.reference(from: \Organization.parentID,
                        to: \Organization.id,
                        onUpdate: .noAction, onDelete: .noAction)
      builder.reference(from: \Organization.sectorID,
                        to: \Sector.id,
                        onUpdate: .noAction, onDelete: .noAction)

    }
    if type(of: conn) == PostgreSQLConnection.self {
      // Only for Post GreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(Organization.name)_id_seq RESTART WITH 5000").all()
    }
    return oTable

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
  /// Fluent relation to the currency that is relative to this organization.
  var currency: Parent<Organization, Currency> {
    return parent(\.currencyID)
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
