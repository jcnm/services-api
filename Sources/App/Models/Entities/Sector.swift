//
//  Sector.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 12/11/2019.
//

import Foundation
import Vapor
import FluentSQLite

let kSectorReferenceBasePrefix  = "SEC"
let kSectorReferenceLength = 2

public enum SectorKind: Int, Codable, ReflectionDecodable {
  public static func reflectDecoded() throws -> (SectorKind, SectorKind) {
    return (primary, ternary)  }
  
  case multiple   = 0
  case primary    = 1
  case secondary  = 2
  case ternary    = 3
  
  public static var defaultValue: SectorKind {
    return .multiple
  }
  
  public static var defaultRaw: SectorKind.RawValue {
    return defaultValue.rawValue
  }
}

extension Int {
  var skind: SectorKind {
    return SectorKind(rawValue: self) ?? SectorKind.defaultValue
  }
  
}

// A sector on indistry activity
final public class Sector: Industrial, AdoptedModel {
  static public var createdAtKey: TimestampKey? { return \.createdAt }
  static public var updatedAtKey: TimestampKey? { return \.updatedAt }
  static public var deletedAtKey: TimestampKey? { return \.deletedAt }
  public static let name = "sector"
  
  /// Sector's unique identifier.
  public var id: ObjectID?
  /// Schedule's unique réference.
  public var ref: String?
  /// Sector's unique identifier.
  public var skind: SectorKind.RawValue
  /// Unique CITI CODE string.
  public var citi: String?
  /// Unique SCIAN CODE string.
  public var scian: String?
  /// Unique NACE CODE string.
  public var nace: String
  /// Sector title string.
  public var title: String
  /// sector's description.
  public var description: String
  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `Sector`.
  public init(nace: String, title: String, description: String, kind: SectorKind = SectorKind.defaultValue, scian: String?, citi: String?, createdAt : Date = Date(), updatedAt: Date? = nil, deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id     = id
    self.ref    = Utils.newRef(kSectorReferenceBasePrefix, size: kSectorReferenceLength)
    self.citi   = scian
    self.scian  = scian
    self.nace   = nace
    self.skind   = kind.rawValue
    self.title  = title
    self.description = description
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.deletedAt = deletedAt
  }
  
  func response() throws -> Sector.ShortPublicResponse {
    let resp = Sector.ShortPublicResponse(
      id: self.id, kind: self.skind, citi: self.citi, scian: self.scian,
      nace: self.nace, title: self.title, updatedAt: self.updatedAt)
    return resp
  }
  
  func fullResponse(_ req: Vapor.Request) throws -> Sector.FullPublicResponse {
    let fullResp = Sector.FullPublicResponse(
      id: self.id, kind: self.skind, citi: self.citi, scian: self.scian,
      nace: self.nace, title: self.title, description: self.description,
      createdAt: self.createdAt, updatedAt: self.updatedAt, deletedAt: self.deletedAt)
    return  fullResp
  }
  
}


/// Allows `Sector` to be used as a Fluent migration.
extension Sector: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(Sector.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.citi)
      builder.field(for: \.scian)
      builder.field(for: \.nace)
      builder.field(for: \.skind)
      builder.field(for: \.title)
      builder.field(for: \.description)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.citi)
      builder.unique(on: \.scian)
      builder.unique(on: \.nace)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Sector.self, on: conn)
  }
}

extension Sector : Content {}
/// Allows `Sector` to be encoded to and decoded from HTTP messages.
public extension Sector {
  
  /// Public full representation of an industry data.
  struct FullPublicResponse: Content {
    /// Sector's unique identifier.
    public var id: ObjectID?
    /// Sector's unique identifier.
    public var kind: SectorKind.RawValue
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
    /// Create date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
    /// Deleted date.
    public var deletedAt: Date?
  }
  
  /// Public full representation of an industry data.
  struct ShortPublicResponse: Content {
    /// Sector's unique identifier.
    public var id: ObjectID?
    /// Sector's unique identifier.
    public var kind: SectorKind.RawValue
    /// Unique CITI CODE string.
    public var citi: String?
    /// Unique SCIAN CODE string.
    public var scian: String?
    /// Unique NACE CODE string.
    public var nace: String
    /// Industry's title string.
    public var title: String
    /// Update date.
    public var updatedAt: Date?
  }
  
}

/// Allows `Sector` to be used as a dynamic parameter in route definitions.
extension Sector: Parameter { }

extension Sector {
  // this Sector's related industries
  var industries: Children<Sector, Industry> {
    return children(\.sectorID)
  }
  // this Sector's related organizations
  var organizations: Children<Sector, Organization> {
    return children(\.sectorID)
  }
}

struct SeedSector: Migration {
  typealias Database = AdoptedDatabase
  
  static func prepare(on connection: AdoptedConnection) -> Future<Void> {

    let sect1 = Sector(nace: "A", title: "AGRICULTURE, CHASSE, SYLVICULTURE", description: "Ce secteur comprend les établissements dont l'activité principale est la culture agricole, l'élevage, la récolte du bois, la prise de poissons et d'autres animaux dans leur habitat naturel et l'offre de services connexes de soutien.\nSont exclus de ce secteur les établissements dont l'activité principale est la recherche agricole ou les services vétérinaires", kind: SectorKind.primary, scian: nil, citi: "A")
    _ = sect1.save(on: connection).transform(to: ())
    
    let sect2 = Sector(nace: "01", title: "AGRICULTURE, CHASSE, SYLVICULTURE", description: "", kind: SectorKind.primary, scian: nil, citi: "01")
    _ = sect2.save(on: connection).transform(to: ())
    
    let sect3 = Sector(nace: "2", title: "SYLVICULTURE, EXPLOITATION FORESTIÈRE, SERVICES ANNEXES", description: "Ce secteur comprend les établissements dont l'activité principale est l'extraction de substances minérales d'origine naturelle.\nIl peut s'agir de solides comme le charbon et les minerais de liquides comme le pétrole brut; de gaz, notamment le gaz naturel.\nLe terme extraction minière est utilisé au sens large de façon à englober l'exploitation de carrières, l'exploitation de puits, la concentration du minerai (par exemple, concassage, criblage, lavage, flottation) et les autres préparations généralement faites à la mine ou dans le cadre de l'activité minière.\nSont compris dans ce secteur les établissements qui font de l'exploration minérale, de l'aménagement de biens miniers et de l'exploitation minière, de même que les établissements qui se livrent à des activités similaires en vertu d'ententes contractuelles ou contre rémunération.", kind: SectorKind.primary, scian: nil, citi: nil)
    _ = sect3.save(on: connection).transform(to: ())
    
    let sect4 = Sector(nace: "B", title: "PÊCHE, AQUACULTURE, SERVICES ANNEXES", description: "Ce secteur comprend les établissements dont l'activité principale est la culture agricole, l'élevage, la récolte du bois, la prise de poissons et d'autres animaux dans leur habitat naturel et l'offre de services connexes de soutien.\nSont exclus de ce secteur les établissements dont l'activité principale est la recherche agricole ou les services vétérinaires.", kind: SectorKind.primary, scian: nil, citi: "B")
    _ = sect4.save(on: connection).transform(to: ())
    
    let sect5 = Sector(nace: "5", title: "PÊCHE, AQUACULTURE, SERVICES ANNEXES", description: "", kind: SectorKind.primary, scian: nil, citi: "5")
    _ = sect5.save(on: connection).transform(to: ())
    
    let sect6 = Sector(nace: "C", title: "INDUSTRIES EXTRACTIVES", description: "Ce secteur comprend les établissements dont l'activité principale est l'extraction de substances minérales d'origine naturelle. Il peut s'agir de solides comme le charbon et les minerais de liquides comme le pétrole brut; de gaz, notamment le gaz naturel.\nLe terme extraction minière est utilisé au sens large de façon à englober l'exploitation de carrières, l'exploitation de puits, la concentration du minerai (par exemple, concassage, criblage, lavage, flottation) et les autres préparations généralement faites à la mine ou dans le cadre de l'activité minière.\nSont compris dans ce secteur les établissements qui font de l'exploration minérale, de l'aménagement de biens miniers et de l'exploitation minière, de même que les établissements qui se livrent à des activités similaires en vertu d'ententes contractuelles ou contre rémunération.", kind: SectorKind.primary, scian: nil, citi: "C")
    _ = sect6.save(on: connection).transform(to: ())
    
    let sect7 = Sector(nace: "10", title: "EXTRACTION DE HOUILLE, DE LIGNITE ET DE TOURBE", description: "", kind: SectorKind.primary, scian: nil, citi: "10")
    _ = sect7.save(on: connection).transform(to: ())
    
    let sect8 = Sector(nace: "11", title: "EXTRACTION D'HYDROCARBURES ; SERVICES ANNEXES", description: "", kind: SectorKind.primary, scian: nil, citi: "11")
    _ = sect8.save(on: connection).transform(to: ())
    
    let sect9 = Sector(nace: "12", title: "EXTRACTION DE MINERAIS D'URANIUM", description: "", kind: SectorKind.primary, scian: nil, citi: "12")
    _ = sect9.save(on: connection).transform(to: ())
    
    let sect10 = Sector(nace: "CB", title: "EXTRACTION DE PRODUITS NON ÉNERGÉTIQUES", description: "", kind: SectorKind.primary, scian: nil, citi: "nil")
    _ = sect10.save(on: connection).transform(to: ())
    
    let sect11 = Sector(nace: "13", title: "EXTRACTION DE MINERAIS MÉTALLIQUES", description: "", kind: SectorKind.primary, scian: nil, citi: "13")
    _ = sect11.save(on: connection).transform(to: ())
    
    let sect12 = Sector(nace: "14", title: "AUTRES INDUSTRIES EXTRACTIVES", description: "", kind: SectorKind.primary, scian: nil, citi: "14")
    _ = sect12.save(on: connection).transform(to: ())
    
    let sect13 = Sector(nace: "D", title: "INDUSTRIE MANUFACTURIÈRE", description: "", kind: SectorKind.primary, scian: nil, citi: "D")
    _ = sect13.save(on: connection).transform(to: ())
    
    let sect14 = Sector(nace: "DA", title: "INDUSTRIES AGRICOLES ET ALIMENTAIRES", description: "", kind: SectorKind.primary, scian: nil, citi: nil)
    _ = sect14.save(on: connection).transform(to: ())
    
    let sect15 = Sector(nace: "15", title: "INDUSTRIES ALIMENTAIRES", description: "", kind: SectorKind.secondary, scian: nil, citi: "15")
    _ = sect15.save(on: connection).transform(to: ())
    
    let sect16 = Sector(nace: "16", title: "INDUSTRIE DU TABAC", description: "", kind: SectorKind.secondary, scian: nil, citi: "16")
    _ = sect16.save(on: connection).transform(to: ())
    
    let sect17 = Sector(nace: "DB", title: " INDUSTRIE TEXTILE ET HABILLEMENT", description: "", kind: SectorKind.secondary, scian: nil, citi: "nil")
    _ = sect17.save(on: connection).transform(to: ())
    
    let sect18 = Sector(nace: "17", title: "INDUSTRIE TEXTILE", description: "", kind: SectorKind.secondary, scian: nil, citi: "17")
    _ = sect18.save(on: connection).transform(to: ())
    
    let sect19 = Sector(nace: "18", title: "INDUSTRIE DE L'HABILLEMENT ET DES FOURRURES", description: "", kind: SectorKind.secondary, scian: nil, citi: "19")
    _ = sect19.save(on: connection).transform(to: ())
    
    let sect20 = Sector(nace: "DC", title: "INDUSTRIE DU CUIR ET DE LA CHAUSSURE", description: "", kind: SectorKind.secondary, scian: nil, citi: "nil")
    _ = sect20.save(on: connection).transform(to: ())
    
    let sect21 = Sector(nace: "19", title: "INDUSTRIE DU CUIR ET DE LA CHAUSSURE", description: "", kind: SectorKind.secondary, scian: nil, citi: "19")
    _ = sect21.save(on: connection).transform(to: ())
    
    let sect22 = Sector(nace: "DD", title: "TRAVAIL DU BOIS ET FABRICATION D'ARTICLES EN BOIS", description: "", kind: SectorKind.secondary, scian: nil, citi: "nil")
    _ = sect22.save(on: connection).transform(to: ())
    
    let sect23 = Sector(nace: "20", title: "TRAVAIL DU BOIS ET FABRICATION D'ARTICLES EN BOIS", description: "", kind: SectorKind.secondary, scian: nil, citi: "20")
    _ = sect23.save(on: connection).transform(to: ())
    
    let sect24 = Sector(nace: "DE", title: "INDUSTRIE DU PAPIER ET DU CARTON ; ÉDITION ET IMPRIMERIE", description: "", kind: SectorKind.secondary, scian: nil, citi: "nil")
    _ = sect24.save(on: connection).transform(to: ())
    
    let sect25 = Sector(nace: "21", title: "INDUSTRIE DU PAPIER ET DU CARTON", description: "", kind: SectorKind.secondary, scian: nil, citi: "21")
    _ = sect25.save(on: connection).transform(to: ())
    
    let sect26 = Sector(nace: "22", title: "ÉDITION, IMPRIMERIE, REPRODUCTION", description: "", kind: SectorKind.secondary, scian: nil, citi: "22")
    _ = sect26.save(on: connection).transform(to: ())
    
    let sect27 = Sector(nace: "DF", title: "COKÉFACTION, RAFFINAGE, INDUSTRIES NUCLÉAIRES", description: "", kind: SectorKind.secondary, scian: nil, citi: "nil")
    _ = sect27.save(on: connection).transform(to: ())
    
    let sect28 = Sector(nace: "", title: "COKÉFACTION, RAFFINAGE, INDUSTRIES NUCLÉAIRES", description: "", kind: SectorKind.secondary, scian: nil, citi: "23")
    _ = sect28.save(on: connection).transform(to: ())
    
    let sect29 = Sector(nace: "DS", title: "INDUSTRIE CHIMIQUE", description: "", kind: SectorKind.secondary, scian: nil, citi: "nil")
    _ = sect29.save(on: connection).transform(to: ())
    
    let sect30 = Sector(nace: "24", title: "INDUSTRIE CHIMIQUE", description: "", kind: SectorKind.secondary, scian: nil, citi: "24")
    _ = sect30.save(on: connection).transform(to: ())
    
    let sect31 = Sector(nace: "DH", title: "INDUSTRIE DU CAOUTCHOUC ET DES PLASTIQUES", description: "", kind: SectorKind.secondary, scian: nil, citi: "nil")
    _ = sect31.save(on: connection).transform(to: ())
    
    let sect32 = Sector(nace: "25", title: "INDUSTRIE DU CAOUTCHOUC ET DES PLASTIQUES", description: "", kind: SectorKind.secondary, scian: nil, citi: "25")
    _ = sect32.save(on: connection).transform(to: ())
    
    let sect33 = Sector(nace: "DI", title: "FABRICATION D'AUTRES PRODUITS MINÉRAUX NON MÉTALLIQUES", description: "", kind: SectorKind.secondary, scian: nil, citi: "nil")
    _ = sect33.save(on: connection).transform(to: ())
    
    let sect34 = Sector(nace: "26", title: "FABRICATION D'AUTRES PRODUITS MINÉRAUX NON MÉTALLIQUES", description: "", kind: SectorKind.secondary, scian: nil, citi: "26")
    _ = sect34.save(on: connection).transform(to: ())
    
    let sect35 = Sector(nace: "DJ", title: "MÉTALLURGIE ET TRAVAIL DES MÉTAUX", description: "", kind: SectorKind.secondary, scian: nil, citi: "nil")
    _ = sect35.save(on: connection).transform(to: ())
    
    let sect36 = Sector(nace: "", title: "MÉTALLURGIE", description: "", kind: SectorKind.secondary, scian: nil, citi: "27")
    _ = sect36.save(on: connection).transform(to: ())
    
    let sect37 = Sector(nace: "28", title: "TRAVAIL DES MÉTAUX", description: "", kind: SectorKind.secondary, scian: nil, citi: "28")
    _ = sect37.save(on: connection).transform(to: ())
    
    let sect38 = Sector(nace: "DK", title: "FABRICATION DE MACHINES ET ÉQUIPEMENTS", description: "", kind: SectorKind.secondary, scian: nil, citi: "nil")
    _ = sect38.save(on: connection).transform(to: ())
    
    let sect39 = Sector(nace: "29", title: "FABRICATION DE MACHINES ET D'ÉQUIPEMENTS", description: "", kind: SectorKind.secondary, scian: nil, citi: "29")
    _ = sect39.save(on: connection).transform(to: ())
    
    let sect40 = Sector(nace: "DL", title: "FABRICATION D'ÉQUIPEMENTS ÉLECTRIQUES ET ÉLECTRONIQUES", description: "", kind: SectorKind.secondary, scian: nil, citi: "nil")
    _ = sect40.save(on: connection).transform(to: ())
    
    let sect41 = Sector(nace: "30", title: "FABRICATION DE MACHINES DE BUREAU ET DE MATÉRIEL INFORMATIQUE", description: "", kind: SectorKind.secondary, scian: nil, citi: "30")
    _ = sect41.save(on: connection).transform(to: ())
    
    let sect42 = Sector(nace: "31", title: "FABRICATION DE MACHINES ET APPAREILS ÉLECTRIQUES", description: "", kind: SectorKind.secondary, scian: nil, citi: "31")
    _ = sect42.save(on: connection).transform(to: ())
    
    let sect43 = Sector(nace: "32", title: "FABRICATION D'ÉQUIPEMENTS DE RADIO, TÉLÉVISION ET COMMUNICATION", description: "", kind: SectorKind.secondary, scian: nil, citi: "32")
    _ = sect43.save(on: connection).transform(to: ())
    
    let sect44 = Sector(nace: "33", title: "FABRICATION D'INSTRUMENTS MÉDICAUX, DE PRÉCISION, D'OPTIQUE ET D'HORLOGERIE", description: "", kind: SectorKind.secondary, scian: nil, citi: "33")
    _ = sect44.save(on: connection).transform(to: ())
    
    let sect45 = Sector(nace: "DM", title: "FABRICATION DE MATÉRIEL DE TRANSPORT", description: "", kind: SectorKind.secondary, scian: nil, citi: "nil")
    _ = sect45.save(on: connection).transform(to: ())
    
    let sect46 = Sector(nace: "34", title: "INDUSTRIE AUTOMOBILE", description: "", kind: SectorKind.secondary, scian: nil, citi: "34")
    _ = sect46.save(on: connection).transform(to: ())
    
    let sect47 = Sector(nace: "35", title: "FABRICATION D'AUTRES MATÉRIELS DE TRANSPORT", description: "", kind: SectorKind.secondary, scian: nil, citi: "35")
    _ = sect47.save(on: connection).transform(to: ())
    
    let sect48 = Sector(nace: "DN", title: "AUTRES INDUSTRIES MANUFACTURIÈRES", description: "", kind: SectorKind.secondary, scian: nil, citi: "nil")
    _ = sect48.save(on: connection).transform(to: ())
    
    let sect49 = Sector(nace: "36", title: "FABRICATION DE MEUBLES ; INDUSTRIES DIVERSES", description: "", kind: SectorKind.secondary, scian: nil, citi: "36")
    _ = sect49.save(on: connection).transform(to: ())
    
    let sect50 = Sector(nace: "37", title: "RÉCUPÉRATION", description: "", kind: SectorKind.secondary, scian: nil, citi: "37")
    _ = sect50.save(on: connection).transform(to: ())
    
    let sect51 = Sector(nace: "E", title: "PRODUCTION ET DISTRIBUTION D'ÉLECTRICITÉ, DE GAZ ET D'EAU", description: "", kind: SectorKind.secondary, scian: nil, citi: "E")
    _ = sect51.save(on: connection).transform(to: ())
    
    let sect52 = Sector(nace: "EA", title: "PRODUCTION ET DISTRIBUTION D'ÉLECTRICITÉ, DE GAZ ET D'EAU", description: "", kind: SectorKind.secondary, scian: nil, citi: "nil")
    _ = sect52.save(on: connection).transform(to: ())
    
    let sect53 = Sector(nace: "40", title: "PRODUCTION ET DISTRIBUTION D'ÉLECTRICITÉ, DE GAZ ET DE CHALEUR", description: "", kind: SectorKind.secondary, scian: nil, citi: "40")
    _ = sect53.save(on: connection).transform(to: ())
    
    let sect54 = Sector(nace: "41", title: "CAPTAGE, TRAITEMENT ET DISTRIBUTION D'EAU", description: "", kind: SectorKind.secondary, scian: nil, citi: "41")
    _ = sect54.save(on: connection).transform(to: ())
    
    let sect55 = Sector(nace: "F", title: "CONSTRUCTION", description: "", kind: SectorKind.secondary, scian: nil, citi: "F")
    _ = sect55.save(on: connection).transform(to: ())
    
    let sect56 = Sector(nace: "FA", title: "CONSTRUCTION", description: "", kind: SectorKind.secondary, scian: nil, citi: "nil")
    _ = sect56.save(on: connection).transform(to: ())
    
    let sect57 = Sector(nace: "45", title: "CONSTRUCTION", description: "", kind: SectorKind.secondary, scian: nil, citi: "45")
    _ = sect57.save(on: connection).transform(to: ())
    
    let sect58 = Sector(nace: "G", title: "COMMERCE ; RÉPARATIONS AUTOMOBILE ET D'ARTICLES DOMESTIQUES", description: "", kind: SectorKind.secondary, scian: nil, citi: "G")
    _ = sect58.save(on: connection).transform(to: ())
    
    let sect59 = Sector(nace: "GA", title: "COMMERCE ; RÉPARATIONS AUTOMOBILE ET D'ARTICLES DOMESTIQUES", description: "", kind: SectorKind.ternary, scian: nil, citi: "nil")
    _ = sect59.save(on: connection).transform(to: ())
    
    let sect60 = Sector(nace: "50", title: "COMMERCE ET RÉPARATION AUTOMOBILE", description: "", kind: SectorKind.ternary, scian: nil, citi: "50")
    _ = sect60.save(on: connection).transform(to: ())
    
    let sect61 = Sector(nace: "51", title: "COMMERCE DE GROS ET INTERMÉDIAIRES DU COMMERCE", description: "", kind: SectorKind.ternary, scian: nil, citi: "51")
    _ = sect61.save(on: connection).transform(to: ())
    
    let sect62 = Sector(nace: "52", title: "COMMERCE DE DÉTAIL ET RÉPARATION D'ARTICLES DOMESTIQUES", description: "", kind: SectorKind.primary, scian: nil, citi: "52")
    _ = sect62.save(on: connection).transform(to: ())
    
    let sect63 = Sector(nace: "H", title: "HÔTELS ET RESTAURANTS", description: "", kind: SectorKind.ternary, scian: nil, citi: "H")
    _ = sect63.save(on: connection).transform(to: ())
    
    let sect64 = Sector(nace: "HA", title: "HÔTELS ET RESTAURANTS", description: "", kind: SectorKind.ternary, scian: nil, citi: "HA")
    _ = sect64.save(on: connection).transform(to: ())
    
    let sect65 = Sector(nace: "55", title: "HÔTELS ET RESTAURANTS", description: "", kind: SectorKind.ternary, scian: nil, citi: "55")
    _ = sect65.save(on: connection).transform(to: ())
    
    let sect66 = Sector(nace: "I", title: "TRANSPORTS ET COMMUNICATIONS", description: "", kind: SectorKind.ternary, scian: nil, citi: "I")
    _ = sect66.save(on: connection).transform(to: connection)
    
    let sect67 = Sector(nace: "IA", title: "TRANSPORTS ET COMMUNICATIONS", description: "", kind: SectorKind.ternary, scian: nil, citi: "IA")
    _ = sect67.save(on: connection).transform(to: ())
    
    let sect68 = Sector(nace: "60", title: "TRANSPORTS TERRESTRES", description: "", kind: SectorKind.ternary, scian: nil, citi: "60")
    _ = sect68.save(on: connection).transform(to: ())
    
    let sect69 = Sector(nace: "61", title: "TRANSPORTS PAR EAU", description: "", kind: SectorKind.ternary, scian: nil, citi: "61")
    _ = sect69.save(on: connection).transform(to: ())
    
    let sect70 = Sector(nace: "62", title: "TRANSPORTS AÉRIENS", description: "", kind: SectorKind.ternary, scian: nil, citi: "62")
    _ = sect70.save(on: connection).transform(to: ())
    
    let sect71 = Sector(nace: "63", title: "SERVICES AUXILIAIRES DES TRANSPORTS", description: "", kind: SectorKind.ternary, scian: nil, citi: "63")
    _ = sect71.save(on: connection).transform(to: ())
    
    let sect72 = Sector(nace: "64", title: "POSTES ET TÉLÉCOMMUNICATIONS", description: "", kind: SectorKind.ternary, scian: nil, citi: "64")
    _ = sect72.save(on: connection).transform(to: ())
    
    let sect73 = Sector(nace: "J", title: "ACTIVITÉS FINANCIÈRES", description: "", kind: SectorKind.ternary, scian: nil, citi: "J")
    _ = sect73.save(on: connection).transform(to: ())
    
    let sect74 = Sector(nace: "JA", title: "ACTIVITÉS FINANCIÈRES", description: "", kind: SectorKind.ternary, scian: nil, citi: "JA")
    _ = sect74.save(on: connection).transform(to: ())
    
    let sect75 = Sector(nace: "65", title: "INTERMÉDIATION FINANCIÈRE", description: "", kind: SectorKind.ternary, scian: nil, citi: "65")
    _ = sect75.save(on: connection).transform(to: ())
    
    let sect76 = Sector(nace: "66", title: "ASSURANCE", description: "", kind: SectorKind.ternary, scian: nil, citi: "66")
    _ = sect76.save(on: connection).transform(to: ())
    
    let sect77 = Sector(nace: "67", title: "AUXILIAIRES FINANCIERS ET D'ASSURANCE", description: "", kind: SectorKind.ternary, scian: nil, citi: "67")
    _ = sect77.save(on: connection).transform(to: ())
    
    let sect78 = Sector(nace: "K", title: "IMMOBILIER, LOCATIONS ET SERVICES AUX ENTREPRISES", description: "", kind: SectorKind.ternary, scian: nil, citi: "K")
    _ = sect78.save(on: connection).transform(to: ())
    
    let sect79 = Sector(nace: "KA", title: "IMMOBILIER, LOCATIONS ET SERVICES AUX ENTREPRISES", description: "", kind: SectorKind.ternary, scian: nil, citi: "KA")
    _ = sect79.save(on: connection).transform(to: ())
    
    let sect80 = Sector(nace: "70", title: "ACTIVITÉS IMMOBILIÈRES", description: "", kind: SectorKind.ternary, scian: nil, citi: "70")
    _ = sect80.save(on: connection).transform(to: ())
    
    let sect81 = Sector(nace: "71", title: "LOCATION SANS OPÉRATEUR", description: "", kind: SectorKind.ternary, scian: nil, citi: "71")
    _ = sect81.save(on: connection).transform(to: ())
    
    let sect82 = Sector(nace: "72", title: "ACTIVITÉS INFORMATIQUES", description: "", kind: SectorKind.ternary, scian: nil, citi: "72")
    _ = sect82.save(on: connection).transform(to: ())
    
    let sect83 = Sector(nace: "73", title: "RECHERCHE ET DÉVELOPPEMENT", description: "", kind: SectorKind.ternary, scian: nil, citi: "73")
    _ = sect83.save(on: connection).transform(to: ())
    
    let sect84 = Sector(nace: "74", title: "SERVICES FOURNIS PRINCIPALEMENT AUX ENTREPRISES", description: "", kind: SectorKind.ternary, scian: nil, citi: "74")
    _ = sect84.save(on: connection).transform(to: ())
    
    let sect85 = Sector(nace: "L", title: "ADMINISTRATION PUBLIQUE", description: "", kind: SectorKind.ternary, scian: nil, citi: "L")
    _ = sect85.save(on: connection).transform(to: ())
    

    let sect86 = Sector(nace: "75", title: "ADMINISTRATION PUBLIQUE", description: "", kind: SectorKind.ternary, scian: nil, citi: "75")
    _ = sect86.save(on: connection).transform(to: ())
    
    let sect87 = Sector(nace: "M", title: "ÉDUCATION", description: "", kind: SectorKind.ternary, scian: nil, citi: "M")
    _ = sect87.save(on: connection).transform(to: ())
    
    let sect88 = Sector(nace: "MA", title: "ÉDUCATION", description: "", kind: SectorKind.ternary, scian: nil, citi: "MA")
    _ = sect88.save(on: connection).transform(to: ())
    
    let sect89 = Sector(nace: "80", title: "ÉDUCATION", description: "", kind: SectorKind.ternary, scian: nil, citi: "80")
    _ = sect89.save(on: connection).transform(to: ())
    
    let sect90 = Sector(nace: "N", title: "SANTÉ ET ACTION SOCIALE", description: "", kind: SectorKind.ternary, scian: nil, citi: "N")
    _ = sect90.save(on: connection).transform(to: ())
    
    let sect91 = Sector(nace: "85", title: "SANTÉ ET ACTION SOCIALE", description: "", kind: SectorKind.ternary, scian: nil, citi: "85")
    _ = sect91.save(on: connection).transform(to: ())
    
    let sect92 = Sector(nace: "O", title: "SERVICES COLLECTIFS, SOCIAUX ET PERSONNELS", description: "", kind: SectorKind.ternary, scian: nil, citi: "O")
    _ = sect92.save(on: connection).transform(to: ())
    
    let sect93 = Sector(nace: "OA", title: "SERVICES COLLECTIFS, SOCIAUX ET PERSONNELS", description: "", kind: SectorKind.ternary, scian: nil, citi: "nil")
    _ = sect93.save(on: connection).transform(to: ())
    
    let sect94 = Sector(nace: "90", title: "ASSAINISSEM ENT, VOIRIE ET GESTION DES DÉCHETS", description: "", kind: SectorKind.ternary, scian: nil, citi: "90")
    _ = sect94.save(on: connection).transform(to: ())
    
    let sect95 = Sector(nace: "91", title: "ACTIVITÉS ASSOCIATIVES", description: "", kind: SectorKind.ternary, scian: nil, citi: "91")
    _ = sect95.save(on: connection).transform(to: ())
    
    let sect96 = Sector(nace: "92", title: "ACTIVITÉS RÉCRÉATIVES, CULTURELLES ET SPORTIVES", description: "", kind: SectorKind.ternary, scian: nil, citi: "92")
    _ = sect96.save(on: connection).transform(to: ())
    
    let sect97 = Sector(nace: "93", title: "SERVICES PERSONNELS", description: "", kind: SectorKind.ternary, scian: nil, citi: "93")
    _ = sect97.save(on: connection).transform(to: ())
    
    let sect98 = Sector(nace: "P", title: "ACTIVITÉS DES MÉNAGES", description: "", kind: SectorKind.ternary, scian: nil, citi: "P")
    _ = sect98.save(on: connection).transform(to: ())
    
    let sect99 = Sector(nace: "PA", title: "ACTIVITÉS DES MÉNAGES", description: "", kind: SectorKind.ternary, scian: nil, citi: "nil")
    _ = sect99.save(on: connection).transform(to: ())
    
    let sect100 = Sector(nace: "95", title: "ACTIVITÉS DES MÉNAGES EN TANT QU'EMPLOYEUR DE PERSONNEL DOMESTIQUE", description: "", kind: SectorKind.ternary, scian: nil, citi: "95")
    _ = sect100.save(on: connection).transform(to: ())
    
    let sect101 = Sector(nace: "", title: "ACTIVITÉS INDIFFÉRENCIÉES DES MÉNAGES EN TANT QUE PRODUCTEURS DE BIENS POUR USAGE PROPRE", description: "", kind: SectorKind.primary, scian: nil, citi: "15")
    _ = sect101.save(on: connection).transform(to: ())
    
    let sect102 = Sector(nace: "", title: "ACTIVITÉS INDIFFÉRENCIÉES DES MÉNAGES EN TANT QUE PRODUCTEURS DE SERVICES POUR USAGE PROPRE", description: "", kind: SectorKind.primary, scian: nil, citi: "15")
    _ = sect102.save(on: connection).transform(to: ())
    
    let sect103 = Sector(nace: "", title: "ACTIVITÉS EXTRA-TERRITORIALES", description: "", kind: SectorKind.primary, scian: nil, citi: "15")
    _ = sect103.save(on: connection).transform(to: ())
    
    let sect104 = Sector(nace: "", title: "ACTIVITÉS EXTRA-TERRITORIALES", description: "", kind: SectorKind.primary, scian: nil, citi: "15")
    _ = sect104.save(on: connection).transform(to: ())
    
    let sect105 = Sector(nace: "", title: "ACTIVITÉS EXTRA-TERRITORIALES", description: "", kind: SectorKind.primary, scian: nil, citi: "15")
    _ = sect105.save(on: connection).transform(to: ())

    return .done(on: connection)
  }
  
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    return .done(on: connection)
  }
}

