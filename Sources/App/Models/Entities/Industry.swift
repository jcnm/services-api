//
//  Industry.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 13/11/2019.
//

import Foundation
import Vapor
import FluentSQLite

let kIndustryReferenceBasePrefix  = "IND"
let kIndustryReferenceLength      = kReferenceDefaultLength

// An industry activity
final public class Industry: Industrial, AdoptedModel {
  static public var createdAtKey: TimestampKey? { return \.createdAt }
  static public var updatedAtKey: TimestampKey? { return \.updatedAt }
  static public var deletedAtKey: TimestampKey? { return \.deletedAt }
  public static let name = "industry"
  /// Industry's unique identifier.
  public var id: ObjectID?
  /// Organization's unique réference .
  public var ref: String
  /// Organization's unique réference into the organization.
  public var organizationRef: String?
  /// Unique Parent Industry.ID.
  public var parentID: Industry.ID?
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
  public var sectorID: Sector.ID
  /// Created date.
  public var createdAt: Date?
  /// Updated date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  
  /// Creates a new `Industry`.
  public init(nace: String, title: String, description: String, sectorID: Sector.ID, parentID: Industry.ID?, scian: String?, citi: String?, createdAt : Date = Date(), updatedAt: Date? = nil, deletedAt : Date? = nil, id: ObjectID? = nil) {
    self.id = id
    self.ref        = Utils.newRef(kIndustryReferenceBasePrefix, size: kIndustryReferenceLength)
    self.parentID = parentID
    self.citi = citi
    self.scian = scian
    self.nace = nace
    self.title = title
    self.sectorID = sectorID
    self.description = description
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.deletedAt = deletedAt
  }
  
  func response() -> Industry.ShortPublicResponse {
    let resp = Industry.ShortPublicResponse(
      id: self.id, citi: self.citi, scian: self.scian,  nace: self.nace,
      title: self.title, sectorID: self.sectorID, updatedAt: self.updatedAt)
    return resp
  }
  
  func fullResponse(_ req: Vapor.Request) throws -> Industry.FullPublicResponse {
    var parent: Industry.ShortPublicResponse? = nil
    if let p = self.parent {
      parent = try p.get(on: req).wait().response()
    }
    let fullResp = Industry.FullPublicResponse(
      id: self.id, parent: parent, citi: self.citi, scian: self.scian,
      nace: self.nace, title: self.title, description: self.description,
      sector: try self.sector.get(on: req).wait().response(), createdAt: self.createdAt,
      updatedAt: self.updatedAt, deletedAt: self.deletedAt)
    return  fullResp
  }
}

/// Allows `Industry` to be used as a Fluent migration.
extension Industry: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    return AdoptedDatabase.create(Industry.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.citi)
      builder.field(for: \.scian)
      builder.field(for: \.nace)
      builder.field(for: \.title)
      builder.field(for: \.description)
      builder.field(for: \.parentID)
      builder.field(for: \.sectorID)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.reference(from: \Industry.parentID, to: \Industry.id, onUpdate: .noAction, onDelete: .noAction)
    }
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(Industry.self, on: conn)
  }
}

extension Industry: Content {}

public extension Industry {
  /// Fluent relation to the sector that is relative to this industry.
  var sector: Parent<Industry, Sector> {
    return parent(\.sectorID)
  }
  /// Parent relation between two industries.
  var parent: Parent<Industry, Industry>? {
    return parent(\.parentID)
  }
  /// this industry's related services
  var services: Children<Industry, Service> {
    return children(\.industryID)
  }
  
}

/// Allows `Industry` to be used as a dynamic parameter in route definitions.
extension Industry: Parameter { }


struct SeedIndustry: Migration {
  typealias Database = AdoptedDatabase
  
  static func prepare(on connection: AdoptedConnection) -> Future<Void> {
    
    let indus1 = Industry(nace: "01", title: "Culture", description:"Comprend les établissements, tels les fermes, vergers, plantations, serres et pépinières, dont l'activité principale est la culture agricole, la culture de plantes, de plantes grimpantes, d'arbres et de leurs semences (à l'exception des établissements qui se consacrent à la foresterie). Les facteurs d'intrant, notamment la qualité des terres, les conditions climatiques, le type de matériel, la quantité et le type de main-d'oeuvre requis, ont été pris en considération dans la définition des classes. En règle générale, le processus de production arrive à terme lorsque le produit brut ou le produit cultivé est prÍt à Ítre mis sur le marché, c'est-à-dire lorsqu'il atteint le point de première vente ou de fixation des prix. Les établissements inclus dans ces classes peuvent utiliser des méthodes de cultures agricoles traditionnelles, employer des intrants agricoles modifiés ou améliorés, ou utiliser des méthodes de cultures agricoles biologiques. Un établissement est rangé dans ce sous-secteur si 50 % ou plus de sa production agricole est constituée de cultures agricole. Les établissements dont 50 % ou plus des activités se rapportent aux cultures agricoles, mais pour qui aucun produit ou famille de produits ne représente 50 % de la production, sont considérés comme des fermes de culture mixte sont rangés dans la classe 11199. Toutes les autres cultures agricoles, sauf les établissements pour qui les plantes oléagineuses et les céréales constituent 50 % ou plus de la production; ces derniers se retrouvent à la rubrique 111190 Autres cultures céréalières", sectorID: 2, parentID: nil, scian: nil, citi: "1")
    
    let indus2 = Industry(nace: "1", title: "Culture de céréales ; cultures industrielles", description: "Ce groupe comprend les établissements dont l'activité principale est la culture de céréales et de plantes oléagineuses. Les établissements dont l'activité principale est la production de semences sont rangés dans la classe de la culture appropriée.", sectorID: 2, parentID: 1, scian: nil, citi: "1")
    
    let indus3 = Industry(nace: "2", title: "Culture de légumes, horticulture, pépinières", description: "", sectorID: 2, parentID: 1, scian: nil, citi: "2")
    
    let indus4 = Industry(nace: "3", title: "Culture de fruits", description: "", sectorID: 2, parentID: 1, scian: nil, citi: "3")
    
    let indus5 = Industry(nace: "2", title: "Elevage", description: "Ce sous-secteur comprend les établissements, comme les ranchs, les fermes et les parcs d'engraissement, dont l'activité principale est l'élevage, la production de produits d'origine animale et l'engraissement des animaux. Les facteurs d'intrant, notamment la qualité des p‚turages, les b‚timents spécialisés, le type de matériel, la quantité et le type de main-d'oeuvre requis, ont été pris en considération dans la définition des classes. Un établissement est rangé dans ce sous-secteur si 50 % ou plus de sa production est l'élevage d'animaux ou l'aquaculture. Les établissements dont 50 % ou plus des activités se rapportent à l'élevage d'animaux ou l'aquaculture, mais dont aucun produit ou famille de produits ne représente 50 % de la production, sont considérés comme des fermes d'élevage mixte et figurent à la rubrique 11299 Tous les autres types d'élevage", sectorID: 2, parentID: nil, scian: nil, citi: "2")
        
    let indus6 = Industry(nace: "1", title: "Elevage de bovins", description: "Ce groupe comprend les établissements dont l'activité principale est l'élevage, la traite et l'engraissement de bovins.", sectorID: 1, parentID: 5, scian: nil, citi: "1")
    
    let indus7 = Industry(nace: "2", title: "Elevage d'ovins, caprins et équidés", description: "", sectorID: 2, parentID: 5, scian: nil, citi: nil)
    
    let indus8 = Industry(nace: "3", title: "Elevage de porcins", description: "Ce groupe comprend les établissements dont l'activité principale est l'élevage de porcs", sectorID: 2, parentID: 5, scian: nil, citi: "2")
    
    let indus9 = Industry(nace: "3", title: "Culture et élevage associés", description: "", sectorID: 2, parentID: nil, scian: nil, citi: "3")

    let indus10 = Industry(nace: "0", title: "Culture et élevage associés", description: "", sectorID: 2, parentID: 9, scian: nil, citi: nil)
    
    let indus11 = Industry(nace: "4", title: "Services annexes à l'agriculture et aménagement des paysages", description: "", sectorID: 2, parentID: nil, scian: nil, citi: "4")
    
    let indus12 = Industry(nace: "1", title: "Services annexes à la culture", description: "", sectorID: 2, parentID: 11, scian: nil, citi: nil)
    
    let indus14 = Industry(nace: "2", title: "Services annexes à l'élevage", description: "", sectorID: 2, parentID: 11, scian: nil, citi: nil)
    
    let indus15 = Industry(nace: "5", title: "Chasse", description: "", sectorID: 2, parentID: nil, scian: nil, citi: "5")
    
    let indus16 = Industry(nace: "0", title: "Chasse", description: "", sectorID: 2, parentID: 15, scian: nil, citi: nil)
    
    let indus17 = Industry(nace: "0", title: "Sylviculture, exploitation forestière, services annexes", description: "ce sous-secteur consiste à extraire la houille qui est une roche carbonée sédimentaire qui s'est formée.", sectorID: 3, parentID: nil, scian: nil, citi: nil)
    
    let indus18 = Industry(nace: "1", title: "Sylviculture, exploitation forestière", description: "", sectorID: 3, parentID: 17, scian: nil, citi: nil)
    
    let indus19 = Industry(nace: "2", title: "Services forestiers", description: "", sectorID: 3, parentID: 17, scian: nil, citi: nil)
    
    let indus20 = Industry(nace: "0", title: "pêche, aquaculture, services annexes", description: "Ce sous-secteur comprend les établissements dont l'activité principale est la prise de poissons et d'autres animaux sauvages dans leur habitat naturel. Ces établissements sont tributaires d'une disponibilité continue des ressources naturelles. La capture du poisson est l'activité économique prédominante de ce sous-secteur et nécessite généralement des bateaux spécialisés qui, compte tenu de leur taille, de leur configuration et de leur équipement, ne sont adaptés à aucun autre type d'activité, notamment le transport. La chasse et le piégeage nécessitent le recours à une large gamme de procédés de production et sont rangés dans le même sous-secteur que la pêche en raison des similitudes qui existent sur le plan de la disponibilité des ressources et des contraintes imposées, comme les exigences de conservation et le maintien adéquat de l'habitat.", sectorID: 5, parentID: nil, scian: nil, citi: nil)
    
    let indus21 = Industry(nace: "1", title: "pêche", description: "", sectorID: 5, parentID: 20, scian: nil, citi: "1")
    
    let indus22 = Industry(nace: "2", title: "Pisciculture, aquaculture", description: "", sectorID: 5, parentID: 20, scian: nil, citi: "2")
    
    let indus23 = Industry(nace: "1", title: "Extraction et agglomération de la houille", description: "ce sous-secteur consiste à extraire la tourbe qui est une matière organique fossile formée par accumulation sur de longues périodes", sectorID: 7, parentID: nil, scian: nil, citi: "14")
    
    let indus24 = Industry(nace: "0", title: "Extraction et agglomération de la houille", description: "", sectorID: 7, parentID: 23, scian: nil, citi: nil)
    
    let indus25 = Industry(nace: "2", title: "Extraction et agglomération du lignite", description: "ce sous-secteur consiste à extraire le lignite qui est un combustible fossile non renouvelable qui, lors de sa combustion et ce au même titre que le pétrole ou le gaz naturel d'extraction, rejette du dioxyde de carbone. La teneur en soufre du lignite dépend fortement de l'origine du gisement", sectorID:7 , parentID: nil, scian: nil, citi: "2")
    
    let indus26 = Industry(nace: "0", title: "Extraction et agglomération du lignite", description: "", sectorID: 7, parentID: 25, scian: nil, citi: nil)
    
    let indus27 = Industry(nace: "3", title: "Extraction et agglomération de la tourbe", description: "", sectorID: 7, parentID: nil, scian: nil, citi: "3")
    
    let indus28 = Industry(nace: "0", title: "Extraction et agglomération de la tourbe", description: "", sectorID: 7, parentID: 27, scian: nil, citi: nil)

    let indus29 = Industry(nace: "1", title: "Extraction d'hydrocarbures", description: "", sectorID: 8, parentID: nil, scian: nil, citi: "1")
    
    let indus30 = Industry(nace: "0", title: "Extraction d'hydrocarbures", description: "", sectorID: 8, parentID: 29, scian: nil, citi: nil)
    
    let indus31 = Industry(nace: "2", title: "Services annexes à l'extraction d'hydrocarbures", description: "", sectorID: 8, parentID: nil, scian: nil, citi: "2")
    
    let indus32 = Industry(nace: "0", title: "Services annexes à l'extraction d'hydrocarbures", description: "", sectorID: 8, parentID: 31, scian: nil, citi: nil)

    let indus33 = Industry(nace: "0", title: "Extraction de minerais d'uranium", description: "", sectorID: 9, parentID: nil, scian: nil, citi: nil)
    
    let indus34 = Industry(nace: "0", title: "Extraction de minerais d'uranium", description: "", sectorID: 9, parentID: 33, scian: nil, citi: nil)
    
    let indus35 = Industry(nace: "1",title: "Extraction de minerais de fer", description: "", sectorID: 11, parentID: nil, scian: nil, citi: "1")
    
    let indus36 = Industry(nace: "0", title: "Extraction de minerais de fer", description: "", sectorID: 11, parentID: 35, scian: nil, citi: nil)
    
    let indus37 = Industry(nace: "2", title: "Extraction de minerais de métaux non ferreux", description: "", sectorID: 11, parentID: nil, scian: nil, citi: "2")
    
    let indus38 = Industry(nace: "0", title: "Extraction de minerais de métaux non ferreux", description: "", sectorID: 11, parentID: 37, scian: nil, citi: nil)
    
    let indus40 = Industry(nace: "1", title: "Extraction de pierres", description: "", sectorID: 12, parentID: nil, scian: nil, citi: "1")
    
    let indus41 = Industry(nace: "1", title: "Extraction de pierres ornementales et de construction", description: "", sectorID: 12, parentID: 41, scian: nil, citi: nil)
    
    let indus42 = Industry(nace: "2", title: "Extraction de calcaire industriel, de gypse et de craie", description: "", sectorID: 12, parentID: 41, scian: nil, citi: nil)
    
    let indus43 = Industry(nace: "3", title: "Extraction d'ardoise", description: "", sectorID: 12, parentID: 41, scian: nil, citi: nil)
    
    let indus44 = Industry(nace: "2", title: "Extraction de sables et d'argiles", description: "", sectorID: 12, parentID: nil, scian: nil, citi: nil)
    
    let indus45 = Industry(nace: "1", title: "Production de sables et de granulats", description: "", sectorID: 12, parentID: 44, scian: nil, citi: nil)
    
    let indus46 = Industry(nace: "2", title: "Extraction d'argiles et de kaolin", description: "", sectorID: 12, parentID: 44, scian: nil, citi: nil)
    
    let indus47 = Industry(nace: "3", title: "Extraction de minéraux pour l'industrie chimique et d'engrais naturels", description: "", sectorID: 12, parentID: nil, scian: nil, citi: "2")
    
    let indus48 = Industry(nace: "0", title: "Extraction de minéraux pour l'industrie chimique et d'engrais naturels", description: "", sectorID: 12, parentID: 47, scian: nil, citi: "1")
    
    let indus49 = Industry(nace: "4", title: "Production de sel", description: "", sectorID: 12, parentID: nil, scian: nil, citi: nil)
    
    let indus50 = Industry(nace: "0", title: "Production de sel", description: "", sectorID: 12, parentID: 49, scian: nil, citi: "2")
    
    let indus51 = Industry(nace: "5", title: "Activités extractives n.c.a.", description: "", sectorID: 12, parentID: nil, scian: nil, citi: nil)
    _ = indus1.save(on: connection).transform(to: ())
    _ = indus2.save(on: connection).transform(to: ())
    _ = indus3.save(on: connection).transform(to: ())
    _ = indus4.save(on: connection).transform(to: ())
    _ = indus5.save(on: connection).transform(to: ())
    _ = indus6.save(on: connection).transform(to: ())
    _ = indus7.save(on: connection).transform(to: ())
    _ = indus8.save(on: connection).transform(to: ())
    _ = indus9.save(on: connection).transform(to: ())
    _ = indus10.save(on: connection).transform(to: ())
    _ = indus11.save(on: connection).transform(to: ())
    _ = indus12.save(on: connection).transform(to: ())
    _ = indus14.save(on: connection).transform(to: ())
    _ = indus15.save(on: connection).transform(to: ())
    _ = indus16.save(on: connection).transform(to: ())
    _ = indus17.save(on: connection).transform(to: ())
    _ = indus18.save(on: connection).transform(to: ())
    _ = indus19.save(on: connection).transform(to: ())
    _ = indus20.save(on: connection).transform(to: ())
    _ = indus21.save(on: connection).transform(to: ())
    _ = indus22.save(on: connection).transform(to: ())
    _ = indus23.save(on: connection).transform(to: ())
    _ = indus24.save(on: connection).transform(to: ())
    _ = indus25.save(on: connection).transform(to: ())
    _ = indus26.save(on: connection).transform(to: ())
    _ = indus27.save(on: connection).transform(to: ())
    _ = indus28.save(on: connection).transform(to: ())
    _ = indus29.save(on: connection).transform(to: ())
    _ = indus30.save(on: connection).transform(to: ())
    _ = indus31.save(on: connection).transform(to: ())
    _ = indus32.save(on: connection).transform(to: ())
    _ = indus33.save(on: connection).transform(to: ())
    _ = indus34.save(on: connection).transform(to: ())
    _ = indus35.save(on: connection).transform(to: ())
    _ = indus36.save(on: connection).transform(to: ())
    _ = indus37.save(on: connection).transform(to: ())
    _ = indus38.save(on: connection).transform(to: ())
    _ = indus40.save(on: connection).transform(to: ())
    _ = indus41.save(on: connection).transform(to: ())
    _ = indus42.save(on: connection).transform(to: ())
    _ = indus43.save(on: connection).transform(to: ())
    _ = indus44.save(on: connection).transform(to: ())
    _ = indus45.save(on: connection).transform(to: ())
    _ = indus46.save(on: connection).transform(to: ())
    _ = indus47.save(on: connection).transform(to: ())
    _ = indus48.save(on: connection).transform(to: ())
    _ = indus49.save(on: connection).transform(to: ())
    _ = indus50.save(on: connection).transform(to: ())
    _ = indus51.save(on: connection).transform(to: ())
    
//    let indus52 = Industry(nace: "0", title: "Activités extractives n.c.a. ",description: "", sectorID: 12, parentID: 50,scian: nil, citi: "9")
//    _ = indus52.save(on: connection).transform(to: ())
//    let indus53 = Industry(nace: "1", title: "Industrie des viandes ",description: "", sectorID: 15, parentID: nil,scian: nil, citi: "1")
//    _ = indus53.save(on: connection).transform(to: ())
//    
//    let indus54 = Industry(nace: "1", title: "Production de viandes de boucherie ",description: "", sectorID: 15, parentID: 53,scian: nil, citi: "1")
//    _ = indus54.save(on: connection).transform(to: ())
//    
//    let indus55 = Industry(nace: "2", title: "Production de viandes de volailles ",description: "", sectorID: 15, parentID: 53,scian: nil, citi: nil)
//    _ = indus55.save(on: connection).transform(to: ())
//    
//    let indus56 = Industry(nace: "3", title: "Préparation de produits à base de viandes ",description: "", sectorID: 15, parentID: 53,scian: nil, citi: nil)
//    _ = indus56.save(on: connection).transform(to: ())
//
//    let indus57 = Industry(nace: "2", title: "Industrie du poisson",description: "", sectorID: 15, parentID: nil,scian: nil, citi: nil)
//    _ = indus57.save(on: connection).transform(to: ())
//
//    let indus58 = Industry(nace: "0", title: "Industrie du poisson",description: "", sectorID: 15, parentID: 57,scian: nil, citi: nil)
//    _ = indus58.save(on: connection).transform(to: ())
//
//    let indus59 = Industry(nace: "3", title: "Industrie des fruits et légumes",description: "", sectorID: 15, parentID: nil,scian: nil, citi: "3")
//    _ = indus59.save(on: connection).transform(to: ())
//
//    let indus60 = Industry(nace: "1", title: "Transformation et conservation de pommes de terre ",description: "", sectorID: 15, parentID: 59,scian: nil, citi: "3")
//    _ = indus60.save(on: connection).transform(to: ())
//
//    let indus61 = Industry(nace: "2", title: "Préparation de jus de fruits et légumes",description: "", sectorID: 15, parentID: 59,scian: nil, citi: nil)
//    _ = indus61.save(on: connection).transform(to: ())
//
//    let indus62 = Industry(nace: "3", title: "Transformation et conservation de fruits et légumes n.c.a.",description: "", sectorID: 15, parentID: 359,scian: nil, citi: nil)
//    _ = indus62.save(on: connection).transform(to: ())
//
//    let indus63 = Industry(nace: "4", title: "Industrie des corps gras",description: "", sectorID: 15, parentID: nil,scian: nil, citi: nil)
//    _ = indus63.save(on: connection).transform(to: ())
//
//    let indus64 = Industry(nace: "1", title: "Fabrication d'huiles et graisses brutes",description: "", sectorID: 15, parentID: 63,scian: nil, citi: "4")
//    _ = indus64.save(on: connection).transform(to: ())
//
//    let indus65 = Industry(nace: "2", title: "Fabrication d'huiles et graisses raffinées",description: "", sectorID: 15, parentID: 63,scian: nil, citi: nil)
//    _ = indus65.save(on: connection).transform(to: ())
//
//    let indus66 = Industry(nace: "3", title: "Fabrication de margarine",description: "", sectorID: 15, parentID: 63,scian: nil, citi: nil)
//    _ = indus66.save(on: connection).transform(to: ())
//
//    let indus67 = Industry(nace: "5", title: "Industrie laitière ",description: "", sectorID: 15, parentID: nil,scian: nil, citi: "2")
//    _ = indus67.save(on: connection).transform(to: ())
//
//    let indus68 = Industry(nace: "0", title: "Fabrication de produits laitiers",description: "", sectorID: 15, parentID: 63,scian: nil, citi: nil)
//    _ = indus68.save(on: connection).transform(to: ())
//
//    let indus69 = Industry(nace: "2", title: "Fabrication de places et sorbets",description: "", sectorID: 15, parentID: 63,scian: nil, citi: "")
//    _ = indus69.save(on: connection).transform(to: ())
//
//    let indus70 = Industry(nace: "6", title: " Travail des grains ; fabrication de produits amylacés",    description: "", sectorID: 15, parentID: nil,scian: nil, citi: "3")
//    _ = indus70.save(on: connection).transform(to: ())
//
//    let indus71 = Industry(nace: "6", title: "Travail des grains",description: "", sectorID: 15, parentID: 70,scian: nil, citi: "1")
//    _ = indus71.save(on: connection).transform(to: ())
//
//    let indus72 = Industry(nace: "2", title: "Fabrication de produits amylacés",    description: "", sectorID: 15, parentID: 70,scian: nil, citi: "2")
//    _ = indus72.save(on: connection).transform(to: ())
//
//    let indus73 = Industry(nace: "7", title: "Fabrication d'aliments pour animaux",description: "", sectorID: 15, parentID: nil,scian: nil, citi: nil)
//    _ = indus73.save(on: connection).transform(to: ())
//
//    let indus74 = Industry(nace: "1", title: "Fabrication d'aliments pour animaux de ferme",description: "", sectorID: 15, parentID: 73,scian: nil, citi: "3")
//    _ = indus74.save(on: connection).transform(to: ())
//
//    let indus75 = Industry(nace: "2", title: "Fabrication d'aliments pour animaux de compagnie",description: "", sectorID: 15, parentID: 73,scian: nil, citi: nil)
//    _ = indus75.save(on: connection).transform(to: ())
//
//    let indus76 = Industry(nace: "8", title: "Autres industries alimentaires",description: "", sectorID: 15, parentID: nil,scian: nil, citi: "4")
//    _ = indus76.save(on: connection).transform(to: ())
//
//    let indus77 = Industry(nace: "1", title: "Fabrication de pain et de pâtisserie fraîche",description: "", sectorID: 15, parentID: 76,scian: nil, citi: "1")
//    _ = indus77.save(on: connection).transform(to: ())
//
//    let indus78 = Industry(nace: "2", title: "Biscotterie, biscuiterie, pâtisserie de conservation",description: "", sectorID: 15, parentID: 76,scian: nil, citi: "1")
//    _ = indus78.save(on: connection).transform(to: ())
//
//    let indus79 = Industry(nace: "3", title: "Fabrication de sucre",description: "", sectorID: 15, parentID: 76,scian: nil, citi: "2")
//    _ = indus79.save(on: connection).transform(to: ())
//
//    let indus80 = Industry(nace: "4", title: "Chocolaterie, confiserie",description: "", sectorID: 15, parentID: 76,scian: nil, citi: "3")
//    _ = indus80.save(on: connection).transform(to: ())
//
//    let indus81 = Industry(nace: "5", title: "Fabrication de pâtes alimentaires",description: "", sectorID: 15, parentID: 76,scian: nil, citi: "4")
//    _ = indus81.save(on: connection).transform(to: ())
//
//    let indus82 = Industry(nace: "6", title: "Transformation du thé et du café",description: "", sectorID: 15, parentID: 76,scian: nil, citi: "9")
//    _ = indus82.save(on: connection).transform(to: ())
//
//    let indus83 = Industry(nace: "7", title: "Fabrication de condiments et assaisonnements",description: "", sectorID: 15, parentID: 76,scian: nil, citi: nil)
//    _ = indus83.save(on: connection).transform(to: ())
//
//    let indus84 = Industry(nace: "8", title: "Fabrication d'aliments adaptés à l'enfant et diététiques",description: "", sectorID: 15, parentID: 76,scian: nil, citi: nil)
//    _ = indus84.save(on: connection).transform(to: ())
//
//    let indus85 = Industry(nace: "9", title: "Industries",description: "", sectorID: 15, parentID: 76,scian: nil, citi: nil)
//    _ = indus85.save(on: connection).transform(to: ())
//
//    let indus86 = Industry(nace: "9", title: "Industrie des boissons",    description: "", sectorID: 15, parentID: nil,scian: nil, citi: "5")
//    _ = indus86.save(on: connection).transform(to: ())
//
//    let indus87 = Industry(nace: "1", title: "Production de boissons alcooliques distillées",description: "", sectorID: 15, parentID: 86,scian: nil, citi: "1")
//    _ = indus87.save(on: connection).transform(to: ())
//
//    let indus88 = Industry(nace: "2", title: "Production d'alcool éthylique de fermentation",description: "", sectorID: 15, parentID: 86,scian: nil, citi: nil)
//    _ = indus88.save(on: connection).transform(to: ())
//
//    let indus89 = Industry(nace: "3", title: "Production de vin",description: "", sectorID: 15, parentID: 86,scian: nil, citi: "2")
//    _ = indus89.save(on: connection).transform(to: ())
//
//    let indus90 = Industry(nace: "4", title: "Cidrerie",description: "", sectorID: 15, parentID: 86,scian: nil, citi: nil)
//    _ = indus90.save(on: connection).transform(to: ())
//
//    let indus91 = Industry(nace: "5", title: "Production d'autres boissons fermentées",description: "", sectorID: 15, parentID: 86,scian: nil, citi: nil)
//    _ = indus91.save(on: connection).transform(to: ())
//    let indus92 = Industry(nace: "6", title: "Brasserie",description: "", sectorID: 15, parentID: 86,scian: nil, citi: "3")
//    _ = indus92.save(on: connection).transform(to: ())
//
//    let indus93 = Industry(nace: "7", title: "Malterie",description: "", sectorID: 15, parentID: 86,scian: nil, citi: nil)
//    _ = indus93.save(on: connection).transform(to: ())
//
//    let indus94 = Industry(nace: "8", title: "Industrie des eaux et des boissons rafraîchissantes",description: "", sectorID: 15, parentID: 86,scian: nil, citi: "4")
//    _ = indus94.save(on: connection).transform(to: ())
//
//    let indus95 = Industry(nace: "0", title: "Industrie du tabac",description: "", sectorID: 16, parentID: nil,scian: nil, citi: nil)
//    _ = indus95.save(on: connection).transform(to: ())
//
//    let indus96 = Industry(nace: "0", title: "Industrie du tabac",description: "", sectorID: 16, parentID: nil,scian: nil, citi: nil)
//    _ = indus96.save(on: connection).transform(to: ())
//
//    let indus97 = Industry(nace: "1", title: "Filature",description: "", sectorID: 18, parentID: nil,scian: nil, citi: "1")
//    _ = indus97.save(on: connection).transform(to: ())
//
//    let indus98 = Industry(nace: "1", title: "Filature de l'industrie cotonnière", description: "", sectorID: 18, parentID: 97, scian: nil, citi: "1")
//    _ = indus98.save(on: connection).transform(to: ())
//
//    let indus99 = Industry(nace: "2", title: "Filature de l'industrie lainière-cycle cardé", description: "", sectorID: 18, parentID: 97, scian: nil, citi: nil)
//    _ = indus99.save(on: connection).transform(to: ())
//
//    let indus100 = Industry(nace: "3", title: "Préparation et filature de l'industrie lainière-cycle peigné", description: "", sectorID: 18, parentID: 97, scian: nil, citi: nil)
//    _ = indus100.save(on: connection).transform(to: ())
//
//        let indus101 = Industry(nace: "4", title: "Préparation et filature du lin", description: "", sectorID: 18, parentID: 97, scian: nil, citi: nil)
//        _ = indus101.save(on: connection).transform(to: ())
//
//        let indus102 = Industry(nace: "5", title: "Moulinage et texturation de la soie et des textiles artificiels ou synthétiques", description: "", sectorID: 18, parentID: 97, scian: nil, citi: nil)
//        _ = indus102.save(on: connection).transform(to: ())
//
//        let indus103 = Industry(nace: "6", title: "Fabrication de fils à coudre", description: "", sectorID: 18, parentID: 97, scian: nil, citi: nil)
//        _ = indus103.save(on: connection).transform(to: ())
//
//        let indus104 = Industry(nace: "7", title: "Préparation et filature d'autres fibres", description: "", sectorID: 18, parentID: 97, scian: nil, citi: nil)
//        _ = indus104.save(on: connection).transform(to: ())
//
//        let indus105 = Industry(nace: "2", title: "Tissage",description: "", sectorID: 18, parentID: nil,  scian: nil, citi: nil)
//         _ = indus105.save(on: connection).transform(to: ())
//        let indus106 = Industry(nace: "1", title: "Tissage de l'industrie cotonnière",  description: "", sectorID: 18, parentID: 105,  scian: nil, citi: nil)
//         _ = indus106.save(on: connection).transform(to: ())
//
//        let indus107 = Industry(nace: "2", title: "Tissage de l'industrie lainière-cycle cardé", description: "", sectorID: 18, parentID: 105, scian: nil, citi: nil)
//         _ = indus107.save(on: connection).transform(to: ())
//
//        let indus108 = Industry(nace: "3", title: "Tissage de l'industrie lainière-cycle peigné", description: "", sectorID: 18, parentID: 105, scian: nil, citi: nil)
//         _ = indus108.save(on: connection).transform(to: ())
//
//        let indus109 = Industry(nace: "4", title: "Tissage de soieries", description: "", sectorID: 18, parentID: 105, scian: nil, citi: nil)
//         _ = indus109.save(on: connection).transform(to: ())
//
//        let indus110 = Industry(nace: "5", title: "Tissage d'autres textiles", description: "", sectorID: 18, parentID: 105, scian: nil, citi: nil)
//         _ = indus110.save(on: connection).transform(to: ())
//
//        let indus111 = Industry(nace: "3", title: "Ennoblissement textile", description: "", sectorID: 18, parentID: nil, scian: nil, citi: nil)
//         _ = indus111.save(on: connection).transform(to: ())
//
//        let indus112 = Industry(nace: "0", title: "Ennoblissement textile", description: "", sectorID: 18, parentID: 111, scian: nil, citi: nil)
//         _ = indus112.save(on: connection).transform(to: ())
//        let indus113 = Industry(nace: "4", title: "Fabrication d'articles textiles", description: "", sectorID: 18, parentID: nil, scian: nil, citi: "2")
//         _ = indus113.save(on: connection).transform(to: ())
//
//        let indus114 = Industry(nace: "0", title: "Fabrication d'articles textiles", description: "", sectorID: 18, parentID: 113, scian: nil, citi: "2")
//         _ = indus114.save(on: connection).transform(to: ())
//
//        let indus115 = Industry(nace: "5", title: "Autres industries textiles", description: "", sectorID: 18, parentID: nil,scian: nil, citi: nil)
//         _ = indus115.save(on: connection).transform(to: ())
//
//        let indus116 = Industry(nace: "1", title: "Fabrication de tapis et moquettes", description: "", sectorID: 18, parentID: 116, scian: nil, citi: "2")
//         _ = indus116.save(on: connection).transform(to: ())
//
//        let indus117 = Industry(nace: "2", title: "Ficellerie, corderie, fabrication de filets", description: "", sectorID: 18, parentID: 116, scian: nil, citi: "3")
//         _ = indus117.save(on: connection).transform(to: ())
//
//        let indus118 = Industry(nace: "3", title: "Fabrication de non-tissés", description: "", sectorID: 18, parentID: 116, scian: nil, citi: "9")
//         _ = indus118.save(on: connection).transform(to: ())
//
//        let indus119 = Industry(nace: "4", title: "Industries textiles n.c.a.", description: "", sectorID: 18, parentID: 116, scian: nil, citi: nil)
//         _ = indus119.save(on: connection).transform(to: ())
//        let indus120 = Industry(nace: "6", title: "Fabrication d'étoffes à maille", description: "", sectorID: 18, parentID: nil, scian: nil, citi: "3")
//         _ = indus120.save(on: connection).transform(to: ())
//
//        let indus121 = Industry(nace: "0", title: "Fabrication d'étoffes à maille", description: "", sectorID: 18, parentID: 120, scian: nil, citi: nil)
//         _ = indus121.save(on: connection).transform(to: ())
//
//        let indus122 = Industry(nace: "7", title: "Fabrication d'articles à maille", description: "", sectorID: 18, parentID: nil, scian: nil, citi: "7")
//         _ = indus122.save(on: connection).transform(to: ())
//
//        let indus123 = Industry(nace: "1", title: "Fabrication de bas et chaussettes", description: "", sectorID: 18, parentID: 122, scian: nil, citi: "1")
//         _ = indus123.save(on: connection).transform(to: ())
//
//        let indus124 = Industry(nace: "18", title: "Fabrication de pull-overs et articles similaires", description: "", sectorID: 18, parentID: 122, scian: nil, citi: "2")
//         _ = indus124.save(on: connection).transform(to: ())
//
//        let indus125 = Industry(nace: "1", title: "Fabrication de vêtements en cuir", description: "", sectorID: 19, parentID: nil, scian: nil, citi: "1")
//         _ = indus125.save(on: connection).transform(to: ())
//
//        let indus126 = Industry(nace: "0", title: "Fabrication de vêtements en cuir", description: "", sectorID: 19, parentID: 125, scian: nil, citi: nil)
//         _ = indus126.save(on: connection).transform(to: ())
//        let indus127 = Industry(nace: "2", title: "Fabrication de vêtements en textile", description: "", sectorID: 19, parentID: nil, scian: nil, citi: nil)
//         _ = indus127.save(on: connection).transform(to: ())
//
//        let indus128 = Industry(nace: "1", title: "Fabrication de vêtements de travail", description: "", sectorID: 19, parentID: 127, scian: nil, citi: nil)
//         _ = indus128.save(on: connection).transform(to: ())
//
//        let indus129 = Industry(nace: "2", title: "Fabrication de vêtements de dessus", description: "", sectorID: 19, parentID: 127, scian: nil, citi: nil)
//         _ = indus129.save(on: connection).transform(to: ())
//
//        let indus130 = Industry(nace: "3", title: "Fabrication de vêtements de dessous", description: "", sectorID: 19, parentID: 127, scian: nil, citi: nil)
//         _ = indus130.save(on: connection).transform(to: ())
//
//        let indus131 = Industry(nace: "4", title: "Fabrication d'autres vêtements et accessoires", description: "", sectorID: 19, parentID: 127, scian: nil, citi: nil)
//         _ = indus131.save(on: connection).transform(to: ())
//
//        let indus132 = Industry(nace: "3", title: "Industrie des fourrures", description: "", sectorID: 19, parentID: nil, scian: nil, citi: "2")
//         _ = indus132.save(on: connection).transform(to: ())
//
//        let indus133 = Industry(nace: "0", title: "Industrie des fourrures", description: "", sectorID: 19, parentID: 132, scian: nil, citi: nil)
//         _ = indus133.save(on: connection).transform(to: ())
//        let indus134 = Industry(nace: "1", title: "Apprêt et tannage des cuirs", description: "", sectorID: 21, parentID: nil, scian: nil, citi: "1")
//         _ = indus134.save(on: connection).transform(to: ())
//
//        let indus135 = Industry(nace: "0", title: "Apprêt et tannage des cuirs", description: "", sectorID: 21, parentID: 134, scian: nil, citi: "1")
//         _ = indus135.save(on: connection).transform(to: ())
//
//        let indus136 = Industry(nace: "2", title: "Fabrication", description: "", sectorID: 21, parentID: nil, scian: nil, citi: nil)
//         _ = indus136.save(on: connection).transform(to: ())
//
//        let indus137 = Industry(nace: "0", title: "Fabrication", description: "", sectorID: 21, parentID: 136, scian: nil, citi: "2")
//         _ = indus137.save(on: connection).transform(to: ())
//
//        let indus138 = Industry(nace: "3", title: "Fabrication de chaussures", description: "", sectorID: 21, parentID: nil, scian: nil, citi: "2")
//         _ = indus138.save(on: connection).transform(to: ())
//
//        let indus139 = Industry(nace: "0", title: "Fabrication de chaussures", description: "", sectorID: 21, parentID: 138, scian: nil, citi: nil)
//         _ = indus139.save(on: connection).transform(to: ())
//
//        let indus140 = Industry(nace: "1", title: "Sciage, rabotage, imprégnation du bois", description: "", sectorID: 23, parentID: nil, scian: nil, citi: "1")
//         _ = indus140.save(on: connection).transform(to: ())
//        let indus141 = Industry(nace: "0", title: "Sciage, rabotage, imprégnation du bois", description: "", sectorID: 23, parentID: 140, scian: nil, citi: nil)
//         _ = indus141.save(on: connection).transform(to: ())
//
//        let indus142 = Industry(nace: "2", title: "Fabrication de panneaux de bois", description: "", sectorID: 23, parentID: nil, scian: nil, citi: "2")
//         _ = indus142.save(on: connection).transform(to: ())
//
//        let indus143 = Industry(nace: "0", title: "Fabrication de panneaux de bois", description: "", sectorID: 23, parentID: 142, scian: nil, citi: "2")
//         _ = indus143.save(on: connection).transform(to: ())
//
//        let indus144 = Industry(nace: "3", title: "Fabrication de charpentes et de menuiseries", description: "", sectorID: 23, parentID: nil, scian: nil, citi: nil)
//         _ = indus144.save(on: connection).transform(to: ())
//
//        let indus145 = Industry(nace: "0", title: "Fabrication de charpentes et de menuiseries", description: "", sectorID: 23, parentID: 144, scian: nil, citi: "1")
//         _ = indus145.save(on: connection).transform(to: ())
//
//        let indus146 = Industry(nace: "4", title: "Fabrication d'emballages en bois", description: "", sectorID: 23, parentID: nil, scian: nil, citi: nil)
//         _ = indus146.save(on: connection).transform(to: ())
//
//        let indus147 = Industry(nace: "0", title: "Fabrication d'emballages en bois", description: "", sectorID: 23, parentID: 146, scian: nil, citi: "3")
//         _ = indus147.save(on: connection).transform(to: ())
//        let indus148 = Industry(nace: "5", title: "Fabrication d'objets divers en bois, liège ou vannerie", description: "", sectorID: 23, parentID: nil, scian: nil, citi: nil)
//         _ = indus148.save(on: connection).transform(to: ())
//
//        let indus149 = Industry(nace: "1", title: "Fabrication d'emballages en bois", description: "", sectorID: 23, parentID: 148, scian: nil, citi: "9")
//         _ = indus149.save(on: connection).transform(to: ())
//
//        let indus150 = Industry(nace: "2", title: "Fabrication d'objets en liège, vannerie ou sparterie", description: "", sectorID: 23, parentID: 148, scian: nil, citi: nil)
//         _ = indus150.save(on: connection).transform(to: ())
//
//        let indus151 = Industry(nace: "1", title: "Fabrication de pâte à papier, de papier et de carton", description: "", sectorID: 25, parentID: nil, scian: nil, citi: nil)
//         _ = indus151.save(on: connection).transform(to: ())
//
//        let indus152 = Industry(nace: "1", title: "Fabrication de pâte à papier", description: "", sectorID: 25, parentID: 151, scian: nil, citi: "1")
//         _ = indus152.save(on: connection).transform(to: ())
//
//        let indus153 = Industry(nace: "2", title: "Fabrication de papier et de carton", description: "", sectorID: 25, parentID: 151, scian: nil, citi: nil)
//         _ = indus153.save(on: connection).transform(to: ())
//        let indus154 = Industry(nace: "2", title: "Fabrication d'articles en papier ou en carton", description: "", sectorID: 25, parentID: nil, scian: nil, citi: nil)
//         _ = indus154.save(on: connection).transform(to: ())
//
//        let indus155 = Industry(nace: "1", title: "Fabrication de carton ondulé et d'emballages en papier ou en carton", description: "", sectorID: 25, parentID: 154, scian: nil, citi: "2")
//         _ = indus155.save(on: connection).transform(to: ())
//
//        let indus156 = Industry(nace: "2", title: "Fabrication d'articles en papier à usage sanitaire ou domestique", description: "", sectorID: 25, parentID: 154, scian: nil, citi: "9")
//         _ = indus156.save(on: connection).transform(to: ())
//
//        let indus157 = Industry(nace: "3", title: "Fabrication d'articles de papeterie", description: "", sectorID: 25, parentID: 154, scian: nil, citi: nil)
//         _ = indus157.save(on: connection).transform(to: ())
//
//        let indus158 = Industry(nace: "4", title: "Fabrication de papiers peints", description: "", sectorID: 25, parentID: 154, scian: nil, citi: nil)
//         _ = indus158.save(on: connection).transform(to: ())
//
//        let indus159 = Industry(nace: "5", title: "Fabrication d'autres articles en papier ou en carton", description: "", sectorID: 25, parentID: 154, scian: nil, citi: nil)
//         _ = indus159.save(on: connection).transform(to: ())
//
//        let indus160 = Industry(nace: "1", title: "Édition", description: "", sectorID: 26, parentID: nil, scian: nil, citi: "1")
//         _ = indus160.save(on: connection).transform(to: ())
//
//        let indus161 = Industry(nace: "1", title: "Édition de livres", description: "", sectorID: 26, parentID: 160, scian: nil, citi: "1")
//        _ = indus161.save(on: connection).transform(to: ())
//
//        let indus162 = Industry(nace: "2", title: "Édition de journaux", description: "", sectorID: 26, parentID: 160, scian: nil, citi: "2")
//         _ = indus162.save(on: connection).transform(to: ())
//
//        let indus163 = Industry(nace: "3", title: "Édition de revues et périodiques", description: "", sectorID: 26, parentID: 160, scian: nil, citi: nil)
//         _ = indus163.save(on: connection).transform(to: ())
//
//        let indus164 = Industry(nace: "4", title: "Édition d'enregistrements sonores", description: "", sectorID: 26, parentID: 160, scian: nil, citi: "3")
//         _ = indus164.save(on: connection).transform(to: ())
//
//        let indus165 = Industry(nace: "5", title: "Autres activités d'édition", description: "", sectorID: 26, parentID: 160, scian: nil, citi: "9")
//         _ = indus165.save(on: connection).transform(to: ())
//
//        let indus166 = Industry(nace: "2", title: "Imprimerie", description: "", sectorID: 26, parentID: nil, scian: nil, citi: "2")
//         _ = indus166.save(on: connection).transform(to: ())
//
//        let indus167 = Industry(nace: "1", title: "Imprimerie de journaux", description: "", sectorID: 26, parentID: 166, scian: nil, citi: "1")
//         _ = indus167.save(on: connection).transform(to: ())
//        let indus168 = Industry(nace: "2", title: "Autre imprimerie (labeur)", description: "", sectorID: 26, parentID: 166, scian: nil, citi: nil)
//         _ = indus168.save(on: connection).transform(to: ())
//
//        let indus169 = Industry(nace: "3", title: "Reliure", description: "", sectorID: 26, parentID: 166, scian: nil, citi: "2")
//         _ = indus169.save(on: connection).transform(to: ())
//
//        let indus170 = Industry(nace: "4", title: "Activités de pré-presse", description: "", sectorID: 26, parentID: 166, scian: nil, citi: nil)
//         _ = indus170.save(on: connection).transform(to: ())
//
//        let indus171 = Industry(nace: "5", title: "Activités graphiques auxiliaires", description: "", sectorID: 26, parentID: 166, scian: nil, citi: nil)
//         _ = indus171.save(on: connection).transform(to: ())
//
//        let indus172 = Industry(nace: "1", title: "Cokéfaction", description: "", sectorID: 28, parentID: nil, scian: nil, citi: "1")
//         _ = indus172.save(on: connection).transform(to: ())
//
//        let indus173 = Industry(nace: "0", title: "Cokéfaction", description: "", sectorID: 28, parentID: 171, scian: nil, citi: nil)
//         _ = indus173.save(on: connection).transform(to: ())
//
//        let indus174 = Industry(nace: "2", title: "Raffinage de pétrole", description: "", sectorID: 28, parentID: nil, scian: nil, citi: "2")
//         _ = indus174.save(on: connection).transform(to: ())
//        let indus175 = Industry(nace: "0", title: "Raffinage de pétrole", description: "", sectorID: 28, parentID: 174, scian: nil, citi: nil)
//         _ = indus175.save(on: connection).transform(to: ())
//
//        let indus176 = Industry(nace: "3", title: "Élaboration et transformation de matières nucléaires", description: "", sectorID: 28, parentID: nil, scian: nil, citi: "3")
//         _ = indus176.save(on: connection).transform(to: ())
//
//        let indus177 = Industry(nace: "0", title: "Élaboration et transformation de matières nucléaires", description: "", sectorID: 28, parentID: 176, scian: nil, citi: nil)
//         _ = indus177.save(on: connection).transform(to: ())
//
//        let indus178 = Industry(nace: "1", title: "Industrie chimique de base", description: "", sectorID: 30, parentID: nil, scian: nil, citi: "1")
//         _ = indus178.save(on: connection).transform(to: ())
//
//        let indus179 = Industry(nace: "1", title: "Fabrication de gaz industriels", description: "", sectorID: 30, parentID: 178, scian: nil, citi: nil)
//         _ = indus179.save(on: connection).transform(to: ())
//
//        let indus180 = Industry(nace: "2", title: "Fabrication de colorants et de pigments", description: "", sectorID: 30, parentID: 178, scian: nil, citi: nil)
//         _ = indus180.save(on: connection).transform(to: ())
//        let indus181 = Industry(nace: "3", title: "Fabrication d'autres produits chimiques inorganiques de base", description: "", sectorID: 30, parentID: 178, scian: nil, citi: nil)
//         _ = indus181.save(on: connection).transform(to: ())
//
//        let indus182 = Industry(nace: "4", title: "Fabrication d'autres produits chimiques organiques de base", description: "", sectorID: 30, parentID: 178, scian: nil, citi: nil)
//         _ = indus182.save(on: connection).transform(to: ())
//
//        let indus183 = Industry(nace: "5", title: "Fabrication de produits azotés et d'engrais", description: "", sectorID: 30, parentID: 178, scian: nil, citi: "2")
//         _ = indus183.save(on: connection).transform(to: ())
//
//        let indus184 = Industry(nace: "6", title: "Fabrication de matières plastiques de base", description: "", sectorID: 30, parentID: 178, scian: nil, citi: "3")
//         _ = indus184.save(on: connection).transform(to: ())
//
//        let indus185 = Industry(nace: "7", title: "Fabrication de caoutchouc synthétique", description: "", sectorID: 30, parentID: 178, scian: nil, citi: nil)
//         _ = indus185.save(on: connection).transform(to: ())
//
//        let indus186 = Industry(nace: "2", title: "Fabrication de produits agrochimiques", description: "", sectorID: 30, parentID: nil, scian: nil, citi: "2")
//         _ = indus186.save(on: connection).transform(to: ())
//
//        let indus187 = Industry(nace: "0", title: "Fabrication de produits agrochimiques", description: "", sectorID: 30, parentID: 186, scian: nil, citi: "1")
//         _ = indus187.save(on: connection).transform(to: ())
//        let indus188 = Industry(nace: "3", title: "Fabrication de peintures et vernis", description: "", sectorID: 30, parentID: nil, scian: nil, citi: nil)
//         _ = indus188.save(on: connection).transform(to: ())
//
//        let indus189 = Industry(nace: "0", title: "Fabrication de peintures et vernis", description: "", sectorID: 30, parentID: 188, scian: nil, citi: "2")
//         _ = indus189.save(on: connection).transform(to: ())
//
//        let indus190 = Industry(nace: "4", title: "Industrie pharmaceutique", description: "", sectorID: 30, parentID: nil, scian: nil, citi: nil)
//         _ = indus190.save(on: connection).transform(to: ())
//
//        let indus191 = Industry(nace: "1", title: "Fabrication de préparations pharmaceutiques de base", description: "", sectorID: 30, parentID: 190, scian: nil, citi: "3")
//         _ = indus191.save(on: connection).transform(to: ())
//
//        let indus192 = Industry(nace: "2", title: "Fabrication de préparations pharmaceutiques", description: "", sectorID: 30, parentID: 190, scian: nil, citi: nil)
//         _ = indus192.save(on: connection).transform(to: ())
//
//        let indus193 = Industry(nace: "5", title: "Fabrication de savons, de parfums et de produits d'entretien", description: "", sectorID: 30, parentID: nil, scian: nil, citi: nil)
//         _ = indus193.save(on: connection).transform(to: ())
//        let indus194 = Industry(nace: "1", title: "Fabrication de produits explosifs", description: "", sectorID: 30, parentID: 193, scian: nil, citi: "9")
//         _ = indus194.save(on: connection).transform(to: ())
//
//        let indus195 = Industry(nace: "2", title: "Fabrication de colles et gélatines", description: "", sectorID: 30, parentID: 193, scian: nil, citi: nil)
//         _ = indus195.save(on: connection).transform(to: ())
//
//        let indus196 = Industry(nace: "3", title: "Fabrication d'huiles essentielles", description: "", sectorID: 30, parentID:193 , scian: nil, citi: nil)
//         _ = indus196.save(on: connection).transform(to: ())
//
//        let indus197 = Industry(nace: "4", title: "Fabrication de produits chimiques pour la photographie", description: "", sectorID: 30, parentID: 193, scian: nil, citi: nil)
//         _ = indus197.save(on: connection).transform(to: ())
//
//        let indus198 = Industry(nace: "5", title: "Fabrication de supports de données", description: "", sectorID:30 , parentID: 193, scian: nil, citi: nil)
//         _ = indus198.save(on: connection).transform(to: ())
//
//        let indus199 = Industry(nace: "6", title: "Fabrication de produits chimiques à usage industriel", description: "", sectorID: 30, parentID: 193, scian: nil, citi: nil)
//         _ = indus199.save(on: connection).transform(to: ())
//
//        let indus200 = Industry(nace: "7", title: "Fabrication de fibres artificielles ou synthétiques", description: "", sectorID: 30, parentID: nil, scian: nil, citi: "3")
//         _ = indus200.save(on: connection).transform(to: ())
//        let indus201 = Industry(nace: "0", title: "Fabrication de fibres artificielles ou synthétiques", description: "", sectorID: 30, parentID: 200, scian: nil, citi: nil)
//         _ = indus201.save(on: connection).transform(to: ())
//
//        let indus202 = Industry(nace: "1", title: "Industrie du caoutchouc", description: "", sectorID: 32, parentID: nil, scian: nil, citi: "1")
//         _ = indus202.save(on: connection).transform(to: ())
//
//        let indus203 = Industry(nace: "1", title: "Fabrication de pneumatiques", description: "", sectorID: 32, parentID: 202, scian: nil, citi: "1")
//         _ = indus203.save(on: connection).transform(to: ())
//
//        let indus204 = Industry(nace: "0", title: "Rechapage de pneumatiques", description: "", sectorID: 32, parentID: 202, scian: nil, citi: nil)
//         _ = indus204.save(on: connection).transform(to: ())
//
//        let indus205 = Industry(nace: "3", title: "Fabrication d'autres articles en caoutchouc", description: "", sectorID: 32, parentID: 202, scian: nil, citi: "9")
//         _ = indus205.save(on: connection).transform(to: ())
//
//        let indus206 = Industry(nace: "2", title: "Transformation des matières plastiques", description: "", sectorID: 32, parentID: nil, scian: nil, citi: "2")
//         _ = indus206.save(on: connection).transform(to: ())
//        let indus207 = Industry(nace: "1", title: "Fabrication de plaques, feuilles, tubes et profilés en matières plastiques", description: "", sectorID: 32, parentID: 206, scian: nil, citi: nil)
//         _ = indus207.save(on: connection).transform(to: ())
//
//        let indus208 = Industry(nace: "2", title: "Fabrication d'emballages en matières plastiques", description: "", sectorID: 32, parentID: 206, scian: nil, citi: nil)
//         _ = indus208.save(on: connection).transform(to: ())
//
//        let indus = Industry(nace: "3", title: "Fabrication d'éléments en matières plastiques pour la construction", description: "", sectorID: 32, parentID: 206, scian: nil, citi: nil)
//         _ = indus.save(on: connection).transform(to: ())
//
//        let indus209 = Industry(nace: "4", title: "Fabrication d'autres articles en matières plastiques", description: "", sectorID: 32, parentID: 206, scian: nil, citi: nil)
//         _ = indus209.save(on: connection).transform(to: ())
//
//        let indus210 = Industry(nace: "1", title: "Fabrication de verre et d'articles en verre", description: "", sectorID: 34, parentID: nil, scian: nil, citi: "1")
//         _ = indus210.save(on: connection).transform(to: ())
//
//        let indus211 = Industry(nace: "1", title: "Fabrication de verre plat", description: "", sectorID: 34, parentID: 210, scian: nil, citi: nil)
//         _ = indus211.save(on: connection).transform(to: ())
//
//        let indus212 = Industry(nace: "2", title: "Façonnage et transformation du verre plat", description: "", sectorID: 34, parentID: 210, scian: nil, citi: nil)
//         _ = indus212.save(on: connection).transform(to: ())
//        let indus213 = Industry(nace: "3", title: "Fabrication de verre creux", description: "", sectorID: 34, parentID: 210, scian: nil, citi: nil)
//         _ = indus213.save(on: connection).transform(to: ())
//
//        let indus214 = Industry(nace: "4", title: "Fabrication de fibres de verre", description: "", sectorID: 34, parentID: 210, scian: nil, citi: nil)
//         _ = indus214.save(on: connection).transform(to: ())
//
//        let indus215 = Industry(nace: "5", title: "Fabrication et façonnage d'autres articles en verre", description: "", sectorID: 34, parentID: 210, scian: nil, citi: nil)
//         _ = indus215.save(on: connection).transform(to: ())
//
//        let indus216 = Industry(nace: "2", title: "Fabrication de produits céramiques", description: "", sectorID: 34, parentID: nil, scian: nil, citi: "2")
//         _ = indus216.save(on: connection).transform(to: ())
//
//        let indus13 = Industry(nace: "1", title: "Fabrication d'articles céramiques à usage domestique ou ornemental", description: "", sectorID: 34, parentID: 216, scian: nil, citi: "1")
//         _ = indus13.save(on: connection).transform(to: ())
//
//        let indus217 = Industry(nace: "2", title: "Fabrication d'appareils sanitaires en céramique", description: "", sectorID: 34, parentID: 216, scian: nil, citi: nil)
//         _ = indus217.save(on: connection).transform(to: ())
//
//        let indus218 = Industry(nace: "3", title: "Fabrication d'isolateurs et pièces isolantes en céramique", description: "", sectorID:34 , parentID: 216,scian: nil, citi: nil)
//         _ = indus218.save(on: connection).transform(to: ())
//
//        let indus219 = Industry(nace: "4", title: "Fabrication d'autres produits céramiques à usage technique", description: "", sectorID: 34, parentID: 216,scian: nil, citi: nil)
//         _ = indus219.save(on: connection).transform(to: ())
//
//        let indus220 = Industry(nace: "5", title: "Fabrication d'autres produits céramiques", description: "", sectorID: 34, parentID: 216, scian: nil, citi: nil)
//         _ = indus220.save(on: connection).transform(to: ())
//
//        let indus221 = Industry(nace: "6", title: "Fabrication de produits céramiques réfractaires", description: "", sectorID: 34, parentID: 216, scian: nil, citi: "2")
//         _ = indus221.save(on: connection).transform(to: ())
//
//        let indus222 = Industry(nace: "3", title: "Fabrication de carreaux en céramique", description: "", sectorID: 34, parentID: nil, scian: nil, citi: nil)
//         _ = indus222.save(on: connection).transform(to: ())
//
//        let indus223 = Industry(nace: "0", title: "Fabrication de carreaux en céramique", description: "", sectorID: 34, parentID: 222, scian: nil, citi: "3")
//         _ = indus223.save(on: connection).transform(to: ())
//
//        let indus224 = Industry(nace: "4", title: "Fabrication de tuiles et briques en terre cuite", description: "", sectorID: 34, parentID: nil, scian: nil, citi: nil)
//         _ = indus224.save(on: connection).transform(to: ())
//
//        let indus225 = Industry(nace: "5", title: "Fabrication de ciment, chaux et plâtre", description: "", sectorID: 34, parentID: nil, scian: nil, citi: nil)
//         _ = indus225.save(on: connection).transform(to: ())
//        let indus226 = Industry(nace: "1", title: "Fabrication de ciment", description: "", sectorID: 34, parentID: 225, scian: nil, citi: "4")
//         _ = indus226.save(on: connection).transform(to: ())
//
//        let indus227 = Industry(nace: "2", title: "Fabrication chaud", description: "", sectorID: 34, parentID: 225, scian: nil, citi: nil)
//         _ = indus227.save(on: connection).transform(to: ())
//
//        let indus228 = Industry(nace: "3", title: "Fabrication de plâtre", description: "", sectorID: 34, parentID: 225, scian: nil, citi: nil)
//         _ = indus228.save(on: connection).transform(to: ())
//
//        let indus229 = Industry(nace: "6", title: "Fabrication d'ouvrages en béton ou en plâtre", description: "", sectorID: 34, parentID: nil, scian: nil, citi: nil)
//         _ = indus229.save(on: connection).transform(to: ())
//
//        let indus230 = Industry(nace: "1", title: "Fabrication d'éléments en béton pour la construction", description: "", sectorID: 34, parentID: 229, scian: nil, citi: "5")
//         _ = indus230.save(on: connection).transform(to: ())
//
//        let indus231 = Industry(nace: "2", title: "Fabrication d'éléments en plâtre pour la construction", description: "", sectorID: 34, parentID: 229, scian: nil, citi: nil)
//         _ = indus231.save(on: connection).transform(to: ())
//        let indus232 = Industry(nace: "3", title: "Fabrication de béton prêt à l'emploi", description: "", sectorID: 34, parentID: 229, scian: nil, citi: nil)
//         _ = indus232.save(on: connection).transform(to: ())
//
//        let indus233 = Industry(nace: "4", title: "Fabrication de mortiers et bétons secs", description: "", sectorID: 34, parentID: 229, scian: nil, citi: nil)
//        _ = indus233.save(on: connection).transform(to: ())
//
//        let indus234 = Industry(nace: "5", title: "Fabrication d'ouvrages en fibre-ciment", description: "", sectorID: 34, parentID: 229, scian: nil, citi: nil)
//         _ = indus234.save(on: connection).transform(to: ())
//        let indus235 = Industry(nace: "6", title: "Fabrication d'autres ouvrages en béton ou en plâtre", description: "", sectorID: 34, parentID: 229, scian: nil, citi: nil)
//         _ = indus235.save(on: connection).transform(to: ())
//
//        let indus236 = Industry(nace: "7", title: "Taille, façonnage et finissage de pierres ornementales et de construction", description: "", sectorID: 34, parentID: nil, scian: nil, citi: nil)
//         _ = indus236.save(on: connection).transform(to: ())
//
//        let indus237 = Industry(nace: "0", title: "Taille, façonnage et finissage de pierres ornementales et de construction", description: "", sectorID: 34, parentID: 236, scian: nil, citi: "6")
//         _ = indus237.save(on: connection).transform(to: ())
//
//        let indus238 = Industry(nace: "8", title: "Fabrication de produits minéraux divers", description: "", sectorID: 34, parentID: nil, scian: nil, citi: nil)
//         _ = indus238.save(on: connection).transform(to: ())
//
//        let indus239 = Industry(nace: "1", title: "Fabrication de produits abrasifs", description: "", sectorID: 34, parentID: nil, scian: nil, citi: "9")
//         _ = indus239.save(on: connection).transform(to: ())
//
//        let indus240 = Industry(nace: "2", title: "Fabrication de produits minéraux non métalliques n.c.a.", description: "", sectorID: 34, parentID: 239, scian: nil, citi: nil)
//         _ = indus240.save(on: connection).transform(to: ())
//
//        let indus241 = Industry(nace: "1", title: "Sidérurgie", description: "", sectorID: 36, parentID: nil, scian: nil, citi: "1")
//         _ = indus241.save(on: connection).transform(to: ())
//
//        let indus242 = Industry(nace: "0", title: "Sidérurgie", description: "", sectorID: 36, parentID: 241, scian: nil, citi: "")
//         _ = indus242.save(on: connection).transform(to: ())
//
//        let indus243 = Industry(nace: "2", title: "Fabrication de tubes", description: "", sectorID: 36, parentID: nil, scian: nil, citi: nil)
//         _ = indus243.save(on: connection).transform(to: ())
//
//        let indus244 = Industry(nace: "1", title: "Fabrication de tubes en fonte", description: "", sectorID: 36, parentID: 243, scian: nil, citi: nil)
//         _ = indus244.save(on: connection).transform(to: ())
//
//        let indus245 = Industry(nace: "2", title: "Fabrication de tubes en acier", description: "", sectorID: 36, parentID: 243, scian: nil, citi: "")
//         _ = indus245.save(on: connection).transform(to: ())
//
//        let indus246 = Industry(nace: "3", title: "Autres opérations de première transformation de l'acier", description: "", sectorID: 36, parentID: 243, scian: nil, citi: nil)
//         _ = indus246.save(on: connection).transform(to: ())
//
//        let indus247 = Industry(nace: "1", title: "Étirage à froid", description: "", sectorID: 36, parentID: 243, scian: nil, citi: nil)
//         _ = indus247.save(on: connection).transform(to: ())
//
//        let indus248 = Industry(nace: "2", title: "Laminage à froid de feuillards", description: "", sectorID: 36, parentID: nil, scian: nil, citi: nil)
//         _ = indus248.save(on: connection).transform(to: ())
//
//        let indus249 = Industry(nace: "3", title: "Profilage à froid par formage ou pliage", description: "", sectorID: 36, parentID: 248, scian: nil, citi: nil)
//         _ = indus249.save(on: connection).transform(to: ())
//
//        let indus250 = Industry(nace: "4", title: "Tréfilage à froid", description: "", sectorID: 36, parentID: 248, scian: nil, citi: nil)
//         _ = indus250.save(on: connection).transform(to: ())
//
//        let indus251 = Industry(nace: "4", title: "Production de métaux non ferreux", description: "", sectorID: 36, parentID: nil, scian: nil, citi: "2")
//         _ = indus251.save(on: connection).transform(to: ())
//
//        let indus252 = Industry(nace: "1", title: "production des métaux précieux", description: "", sectorID: 36, parentID: 251, scian: nil, citi: nil)
//         _ = indus252.save(on: connection).transform(to: ())
//        let indus253 = Industry(nace: "2", title: "Métallurgie de l'aluminium", description: "", sectorID: 36, parentID: 251, scian: nil, citi: nil)
//         _ = indus253.save(on: connection).transform(to: ())
//
//        let indus254 = Industry(nace: "3", title: "Métallurgie du plomb, du zinc ou de l'étain", description: "", sectorID: 36, parentID: 251, scian: nil, citi: nil)
//         _ = indus254.save(on: connection).transform(to: ())
//
//        let indus255 = Industry(nace: "4", title: "Métallurgie du cuivre", description: "", sectorID: 36, parentID: 251, scian: nil, citi: "")
//         _ = indus255.save(on: connection).transform(to: ())
//
//        let indus256 = Industry(nace: "4", title: "Métallurgie des autres métaux non ferreux", description: "", sectorID: 36, parentID: 251, scian: nil, citi: nil)
//         _ = indus256.save(on: connection).transform(to: ())
//
//        let indus257 = Industry(nace: "1", title: "Fonderie", description: "", sectorID: 36, parentID: nil, scian: nil, citi: "3")
//         _ = indus257.save(on: connection).transform(to: ())
//
//        let indus258 = Industry(nace: "2", title: "Fonderie de fonte", description: "", sectorID: 36, parentID: 257, scian: nil, citi: "1")
//         _ = indus258.save(on: connection).transform(to: ())
//        let indus259 = Industry(nace: "3", title: "Fonderie d'acier", description: "", sectorID: 36, parentID: 257, scian: nil, citi: nil)
//         _ = indus259.save(on: connection).transform(to: ())
//
//        let indus260 = Industry(nace: "4", title: "Fonderie de métaux légers", description: "", sectorID: 36, parentID: 257, scian: nil, citi: "2")
//         _ = indus260.save(on: connection).transform(to: ())
//
//        let indus261 = Industry(nace: "5", title: "Fonderie d'autres métaux non ferreux", description: "", sectorID: 36, parentID: 257, scian: nil, citi: nil)
//         _ = indus261.save(on: connection).transform(to: ())
//
//        let indus262 = Industry(nace: "5", title: "Fonderie", description: "", sectorID: 36, parentID: nil, scian: nil, citi: "3")
//         _ = indus262.save(on: connection).transform(to: ())
//
//        let indus263 = Industry(nace: "1", title: "Fonderie de fonte", description: "", sectorID: 36, parentID: 262, scian: nil, citi: "1")
//         _ = indus263.save(on: connection).transform(to: ())
//
//        let indus264 = Industry(nace: "2", title: "Fonderie d'acier", description: "", sectorID: 36, parentID: 262, scian: nil, citi: nil)
//         _ = indus264.save(on: connection).transform(to: ())
//
//        let indus265 = Industry(nace: "3", title: "Fonderie de métaux légers", description: "", sectorID: 36, parentID: 262, scian: nil, citi: "2")
//         _ = indus265.save(on: connection).transform(to: ())
//
//
//        let indus266 = Industry(nace: "4", title: "Fonderie d'autres métaux non ferreux", description: "", sectorID: 36, parentID: 262, scian: nil, citi: nil)
//         _ = indus266.save(on: connection).transform(to: ())
//
//        let indus267 = Industry(nace: "1", title: "Fabrication d'éléments en métal pour la construction ", description: "", sectorID: 37, parentID: nil, scian: nil, citi: "1")
//         _ = indus267.save(on: connection).transform(to: ())
//
//        let indus268 = Industry(nace: "1", title: "Fabrication de constructions métalliques ", description: "", sectorID: 37, parentID: 267, scian: nil, citi: "1")
//         _ = indus268.save(on: connection).transform(to: ())
//
//        let indus269 = Industry(nace: "2", title: "Fabrication de menuiseries et fermetures métalliques ", description: "", sectorID: 37, parentID: 267, scian: nil, citi: nil)
//         _ = indus269.save(on: connection).transform(to: ())
//        let indus270 = Industry(nace: "2", title: "Fabrication de réservoirs métalliques et de chaudières pour le chauffage central ", description: "", sectorID: 37, parentID: nil, scian: nil, citi: "2")
//         _ = indus270.save(on: connection).transform(to: ())
//
//        let indus271 = Industry(nace: "1", title: "Fabrication de réservoirs, citernes et conteneurs métalliques ", description: "", sectorID: 37, parentID: 270, scian: nil, citi: "2")
//         _ = indus271.save(on: connection).transform(to: ())
//
//        let indus272 = Industry(nace: "2", title: "Fabrication de radiateurs et de chaudières pour le chauffage central ", description: "", sectorID: 37, parentID: 270, scian: nil, citi: nil)
//         _ = indus272.save(on: connection).transform(to: ())
//
//        let indus273 = Industry(nace: "3", title: "Chaudronnerie", description: "", sectorID: 37, parentID: nil, scian: nil, citi: nil)
//         _ = indus273.save(on: connection).transform(to: ())
//
//
//        let indus274 = Industry(nace: "4", title: "Forge, emboutissage, estampage ; métallurgie des poudres ", description: "", sectorID: 37, parentID: nil, scian: nil, citi: "9")
//         _ = indus274.save(on: connection).transform(to: ())
//
//        let indus275 = Industry(nace: "0", title: "Forge, emboutissage, estampage ; métallurgie des poudres ", description: "", sectorID: 37, parentID: 274, scian: nil, citi: "1")
//         _ = indus275.save(on: connection).transform(to: ())
//
//        let indus276 = Industry(nace: "5", title: "Traitement des métaux ; mécanique générale ", description: "", sectorID: 37, parentID: nil, scian: nil, citi: nil)
//         _ = indus276.save(on: connection).transform(to: ())
//
//        let indus277 = Industry(nace: "1", title: "Traitement et revêtement des métaux ", description: "", sectorID:37 , parentID: 276, scian: nil, citi: "2")
//         _ = indus277.save(on: connection).transform(to: ())
//
//        let indus278 = Industry(nace: "2", title: "Opérations de mécanique générale ", description: "", sectorID: 37, parentID: 276, scian: nil, citi: nil)
//         _ = indus278.save(on: connection).transform(to: ())
//
//        let indus279 = Industry(nace: "6", title: "Fabrication de coutellerie, d'outillage et de quincaillerie ", description: "", sectorID: 37, parentID: nil, scian: nil, citi: nil)
//         _ = indus279.save(on: connection).transform(to: ())
//
//        let indus280 = Industry(nace: "1", title: "Fabrication de coutellerie ", description: "", sectorID: 37, parentID: 279, scian: nil, citi: "3")
//         _ = indus280.save(on: connection).transform(to: ())
//        let indus281 = Industry(nace: "2", title: "Fabrication d'outillage ", description: "", sectorID: 37, parentID: 279, scian: nil, citi: nil)
//         _ = indus281.save(on: connection).transform(to: ())
//
//        let indus282 = Industry(nace: "3", title: "Fabrication de serrures et de ferrures ", description: "", sectorID: 37, parentID: 279, scian: nil, citi: nil)
//         _ = indus282.save(on: connection).transform(to: ())
//
//        let indus283 = Industry(nace: "7", title: "Fabrication d'autres ouvrages en métaux ", description: "", sectorID: 37, parentID: nil, scian: nil, citi: nil)
//         _ = indus283.save(on: connection).transform(to: ())
//
//        let indus284 = Industry(nace: "1", title: "Fabrication de fûts et emballages métalliques similaires ", description: "", sectorID: 37, parentID: 283, scian: nil, citi: "9")
//         _ = indus284.save(on: connection).transform(to: ())
//
//        let indus285 = Industry(nace: "2", title: "Fabrication d'emballages métalliques légers ", description: "", sectorID: 37, parentID: 283, scian: nil, citi: nil)
//         _ = indus285.save(on: connection).transform(to: ())
//
//        let indus286 = Industry(nace: "3", title: "Fabrication d'articles en fils métalliques ", description: "", sectorID: 37, parentID: 283, scian: nil, citi: nil)
//         _ = indus286.save(on: connection).transform(to: ())
//
//        let indus287 = Industry(nace: "4", title: "Visserie et boulonnerie ; fabrication de chaînes et de ressorts ", description: "", sectorID: 37, parentID: 283, scian: nil, citi: nil)
//         _ = indus287.save(on: connection).transform(to: ())
//
//
//        let indus288 = Industry(nace: "5", title: "Fabrication d'ouvrages divers en métaux ", description: "", sectorID: 37, parentID: 283, scian: nil, citi: nil)
//         _ = indus288.save(on: connection).transform(to: ())
//
//        let indus289 = Industry(nace: "1", title: "Fabrication d'équipements mécaniques ", description: "", sectorID: 37, parentID: nil, scian: nil, citi: "1")
//         _ = indus289.save(on: connection).transform(to: ())
//
//        let indus290 = Industry(nace: "1", title: "Fabrication de moteurs et turbines ", description: "", sectorID: 37, parentID: 289, scian: nil, citi: "1")
//         _ = indus290.save(on: connection).transform(to: ())
//
//        let indus291 = Industry(nace: "2", title: "Fabrication de pompes, compresseurs et systèmes hydrauliques ", description: "", sectorID: 37, parentID: 289, scian: nil, citi: "2")
//         _ = indus291.save(on: connection).transform(to: ())
//
//        let indus292 = Industry(nace: "3", title: "Fabrication d'articles de robinetterie ", description: "", sectorID: 37, parentID: 289, scian: nil, citi: nil)
//         _ = indus292.save(on: connection).transform(to: ())
//
//        let indus293 = Industry(nace: "4", title: "Fabrication d'engrenages et d'organes mécaniques de transmission ", description: "", sectorID: 37, parentID: 289, scian: nil, citi: "3")
//         _ = indus293.save(on: connection).transform(to: ())
//        let indus294 = Industry(nace: "2", title: "Fabrication de machines d'usage général ", description: "", sectorID: 37, parentID: nil, scian: nil, citi: nil)
//         _ = indus294.save(on: connection).transform(to: ())
//
//        let indus295 = Industry(nace: "1", title: "Fabrication de fours et brûleurs ", description: "", sectorID: 37, parentID: 294, scian: nil, citi: "4")
//         _ = indus295.save(on: connection).transform(to: ())
//
//        let indus296 = Industry(nace: "2", title: "Fabrication de matériel de levage et de manutention ", description: "", sectorID: 37, parentID: 294, scian: nil, citi: "5")
//         _ = indus296.save(on: connection).transform(to: ())
//
//        let indus297 = Industry(nace: "3", title: "Fabrication d'équipements aérauliques et frigorifiques industriels ", description: "", sectorID: 37, parentID: 294, scian: nil, citi: "9")
//         _ = indus297.save(on: connection).transform(to: ())
//
//        let indus298 = Industry(nace: "4", title: "Fabrication d'autres machines d'usage général ", description: "", sectorID: 37, parentID: 294, scian: nil, citi: nil)
//         _ = indus298.save(on: connection).transform(to: ())
//
//        let indus299 = Industry(nace: "3", title: "Fabrication de machines agricoles ", description: "", sectorID: 37, parentID: nil, scian: nil, citi: "2")
//         _ = indus299.save(on: connection).transform(to: ())
//
//        let indus300 = Industry(nace: "1", title: "Fabrication de tracteurs agricoles ", description: "", sectorID: 37, parentID: 299, scian: nil, citi: "1")
//         _ = indus300.save(on: connection).transform(to: ())
//
//        let indus301 = Industry(nace: "2", title: "Fabrication d'autres machines agricoles ", description: "", sectorID: 37, parentID: 299, scian: nil, citi: nil)
//         _ = indus301.save(on: connection).transform(to: ())
//
//        let indus302 = Industry(nace: "4", title: "Fabrication de machines-outils ", description: "", sectorID: 37, parentID: nil, scian: nil, citi: nil)
//         _ = indus302.save(on: connection).transform(to: ())
//
//        let indus303 = Industry(nace: "2", title: "Fabrication de machines-outils à métaux ", description: "", sectorID: 37, parentID: 302, scian: nil, citi: "2")
//         _ = indus303.save(on: connection).transform(to: ())
//
//        let indus304 = Industry(nace: "1", title: "Fabrication de machines-outils portatives à moteur incorporé  ", description: "", sectorID: 37, parentID: 302, scian: nil, citi: nil)
//         _ = indus304.save(on: connection).transform(to: ())
//
//        let indus305 = Industry(nace: "3", title: "Fabrication d'autres machines-outils n.c.a", description: "", sectorID: 37, parentID: 302, scian: nil, citi: nil)
//         _ = indus305.save(on: connection).transform(to: ())
//
//        let indus306 = Industry(nace: "5", title: "Fabrication d'autres machines d'usage spécifique ", description: "", sectorID: 37, parentID: nil, scian: nil, citi: nil)
//         _ = indus306.save(on: connection).transform(to: ())
//
//        let indus307 = Industry(nace: "1", title: "Fabrication de machines pour la métallurgie ", description: "", sectorID: 37, parentID: 306, scian: nil, citi: "3")
//         _ = indus307.save(on: connection).transform(to: ())
//
//
//        let indus308 = Industry(nace: "2", title: "Fabrication de machines pour l'extraction ou la construction ", description: "", sectorID: 37, parentID: 306, scian: nil, citi: "4")
//         _ = indus308.save(on: connection).transform(to: ())
//
//        let indus309 = Industry(nace: "3", title: "Fabrication de machines pour l'industrie agroalimentaire ", description: "", sectorID: 37, parentID: 306, scian: nil, citi: "5")
//         _ = indus309.save(on: connection).transform(to: ())
//
//        let indus310 = Industry(nace: "4", title: "Fabrication de machines pour les industries textiles ", description: "", sectorID: 37, parentID: 306, scian: nil, citi: "6")
//         _ = indus310.save(on: connection).transform(to: ())
//
//        let indus311 = Industry(nace: "5", title: "Fabrication de machines pour les industries du papier et du carton ", description: "", sectorID: 37, parentID: 306, scian: nil, citi: "9")
//         _ = indus311.save(on: connection).transform(to: ())
//
//        let indus312 = Industry(nace: "6", title: "Fabrication de machines diverses d'usage spécifique ", description: "", sectorID: 37, parentID: 306, scian: nil, citi: nil)
//         _ = indus312.save(on: connection).transform(to: ())
//
//        let indus313 = Industry(nace: "6", title: "Fabrication d'armes et de munitions ", description: "", sectorID: 37, parentID: nil, scian: nil, citi: nil)
//         _ = indus313.save(on: connection).transform(to: ())
//
//        let indus314 = Industry(nace: "0", title: "Fabrication d'armes et de munitions  ", description: "", sectorID: 37, parentID: 313, scian: nil, citi: "7")
//         _ = indus314.save(on: connection).transform(to: ())
//        let indus315 = Industry(nace: "7", title: "Fabrication d'appareils domestiques ", description: "", sectorID: 37, parentID: nil, scian: nil, citi: "3")
//         _ = indus315.save(on: connection).transform(to: ())
//
//        let indus316 = Industry(nace: "1", title: "Fabrication d'appareils électroménagers ", description: "", sectorID: 37, parentID: 315, scian: nil, citi: "")
//         _ = indus316.save(on: connection).transform(to: ())
//
//        let indus317 = Industry(nace: "2", title: "Fabrication d'appareils ménagers non électriques ", description: "", sectorID: 37, parentID: 315, scian: nil, citi: nil)
//         _ = indus317.save(on: connection).transform(to: ())
//
//        let indus318 = Industry(nace: "0", title: "Fabrication de machines de bureau et de matériel informatique ", description: "", sectorID: 41, parentID: nil, scian: nil, citi: nil)
//         _ = indus318.save(on: connection).transform(to: ())
//
//        let indus319 = Industry(nace: "1", title: "Fabrication de machines de bureau ", description: "", sectorID: 41, parentID: 318, scian: nil, citi: nil)
//         _ = indus319.save(on: connection).transform(to: ())
//
//        let indus320 = Industry(nace: "2", title: "Fabrication d'ordinateurs et d'autres équipements informatiques ", description: "", sectorID: 41, parentID: 318, scian: nil, citi: nil)
//         _ = indus320.save(on: connection).transform(to: ())
//        let indus321 = Industry(nace: "1", title: "Fabrication de moteurs, génératrices et transformateurs électriques ", description: "", sectorID: 42, parentID: nil, scian: nil, citi: "1")
//         _ = indus321.save(on: connection).transform(to: ())
//
//        let indus322 = Industry(nace: "0", title: "Fabrication de moteurs, génératrices et transformateurs  électriques ", description: "", sectorID: 42, parentID: 321, scian: nil, citi: nil)
//         _ = indus322.save(on: connection).transform(to: ())
//
//        let indus323 = Industry(nace: "2", title: "Fabrication de matériel de distribution et de commande électrique ", description: "", sectorID: 42, parentID: nil, scian: nil, citi: "2")
//         _ = indus323.save(on: connection).transform(to: ())
//
//        let indus324 = Industry(nace: "0", title: "Fabrication de matériel de distribution et de commande électrique ", description: "", sectorID: 42, parentID: 323, scian: nil, citi: nil)
//         _ = indus324.save(on: connection).transform(to: ())
//
//        let indus325 = Industry(nace: "3", title: "Fabrication de fils et câbles isolés ", description: "", sectorID: 42, parentID: nil, scian: nil, citi: "3")
//         _ = indus325.save(on: connection).transform(to: ())
//
//        let indus326 = Industry(nace: "0", title: "Fabrication de fils et câbles isolés ", description: "", sectorID: 42, parentID: 325, scian: nil, citi: nil)
//         _ = indus326.save(on: connection).transform(to: ())
//
//        let indus327 = Industry(nace: "4", title: "Fabrication d'accumulateurs et de piles électriques ", description: "", sectorID: 42, parentID: nil, scian: nil, citi: "4")
//         _ = indus327.save(on: connection).transform(to: ())
//        let indus328 = Industry(nace: "0", title: "Fabrication d'accumulateurs et de piles électriques ", description: "", sectorID: 42, parentID: 327, scian: nil, citi: nil)
//         _ = indus328.save(on: connection).transform(to: ())
//
//        let indus329 = Industry(nace: "5", title: "Fabrication de lampes et d'appareils d'éclairage ", description: "", sectorID: 42, parentID: nil, scian: nil, citi: "5")
//         _ = indus329.save(on: connection).transform(to: ())
//
//        let indus330 = Industry(nace: "0", title: "Fabrication de lampes et d'appareils d'éclairage ", description: "", sectorID: 42, parentID: 329, scian: nil, citi: nil)
//         _ = indus330.save(on: connection).transform(to: ())
//
//        let indus331 = Industry(nace: "6", title: "Fabrication d'autres matériels électriques ", description: "", sectorID: 42, parentID: nil, scian: nil, citi: "6")
//         _ = indus331.save(on: connection).transform(to: ())
//
//        let indus332 = Industry(nace: "1", title: "Fabrication de matériels électriques pour moteurs et véhicules ", description: "", sectorID: 42, parentID: 331, scian: nil, citi: nil)
//         _ = indus332.save(on: connection).transform(to: ())
//
//        let indus333 = Industry(nace: "2", title: "Fabrication de matériels électriques sauf pour moteurs et véhicules  ", description: "", sectorID: 42, parentID: 331, scian: nil, citi: nil)
//         _ = indus333.save(on: connection).transform(to: ())
//
//        let indus334 = Industry(nace: "1", title: "Fabrication de composants électroniques ", description: "", sectorID: 43, parentID: nil, scian: nil, citi: "1")
//         _ = indus334.save(on: connection).transform(to: ())
//        let indus335 = Industry(nace: "0", title: "Fabrication de composants électroniques ", description: "", sectorID: 43, parentID: 334, scian: nil, citi: nil)
//         _ = indus335.save(on: connection).transform(to: ())
//
//        let indus336 = Industry(nace: "2", title: "Fabrication d'appareils d'émission et de transmission ", description: "", sectorID: 43, parentID: nil, scian: nil, citi: "2")
//         _ = indus336.save(on: connection).transform(to: ())
//
//        let indus337 = Industry(nace: "0", title: "Fabrication d'appareils d'émission et de transmission ", description: "", sectorID: 43, parentID: 336, scian: nil, citi: nil)
//         _ = indus337.save(on: connection).transform(to: ())
//
//        let indus338 = Industry(nace: "3", title: "Fabrication d'appareils de réception, enregistrement ou reproduction du son et de l'image ", description: "", sectorID: 43, parentID: nil, scian: nil, citi: "3")
//         _ = indus338.save(on: connection).transform(to: ())
//
//        let indus339 = Industry(nace: "0", title: "Fabrication d'appareils de réception, enregistrement ou reproduction du son et de l'image", description: "", sectorID: 43, parentID: 338, scian: nil, citi: "")
//         _ = indus339.save(on: connection).transform(to: ())
//
//        let indus340 = Industry(nace: "1", title: "Fabrication de matériel médico-chirurgical et d'orthopédie ", description: "", sectorID: 44, parentID: nil, scian: nil, citi: "1")
//         _ = indus340.save(on: connection).transform(to: ())
//
//        let indus341 = Industry(nace: "0", title: "Fabrication de matériel médico-chirurgical et d'orthopédie ", description: "", sectorID: 44, parentID: 340, scian: nil, citi: "1")
//         _ = indus341.save(on: connection).transform(to: ())
//        let indus342 = Industry(nace: "2", title: "Fabrication d'instruments de mesure et de contrôle ", description: "", sectorID: 44, parentID: nil, scian: nil, citi: nil)
//         _ = indus342.save(on: connection).transform(to: ())
//
//        let indus343 = Industry(nace: "0", title: "Fabrication d'instruments de mesure et de contrôle ", description: "", sectorID: 44, parentID: 342, scian: nil, citi: "2")
//         _ = indus343.save(on: connection).transform(to: ())
//
//        let indus344 = Industry(nace: "3", title: "Fabrication d'équipements de contrôle des processus  industriels ", description: "", sectorID: 44, parentID: nil, scian: nil, citi: "3")
//         _ = indus344.save(on: connection).transform(to: ())
//        let indus345 = Industry(nace: "0", title: "Fabrication d'équipements de contrôle des processus  industriels ", description: "", sectorID: 44, parentID: 344, scian: nil, citi: "3")
//         _ = indus345.save(on: connection).transform(to: ())
//
//        let indus346 = Industry(nace: "4", title: "Fabrication de matériels optique et photographique ", description: "", sectorID: 44, parentID: nil, scian: nil, citi: "2")
//         _ = indus346.save(on: connection).transform(to: ())
//
//        let indus347 = Industry(nace: "0", title: "Fabrication de matériels optique et photographique ", description: "", sectorID: 44, parentID: 346, scian: nil, citi: nil)
//         _ = indus347.save(on: connection).transform(to: ())
//
//        let indus348 = Industry(nace: "5", title: "Horlogerie ", description: "", sectorID: 44, parentID: nil, scian: nil, citi: "3")
//         _ = indus348.save(on: connection).transform(to: ())
//
//        let indus349 = Industry(nace: "0", title: "Horlogerie ", description: "", sectorID: 44, parentID: 348, scian: nil, citi: nil)
//         _ = indus349.save(on: connection).transform(to: ())
//
//        let indus350 = Industry(nace: "1", title: "Construction de véhicules automobiles ", description: "", sectorID: 46, parentID: nil, scian: nil, citi: "1")
//         _ = indus350.save(on: connection).transform(to: ())
//
//        let indus351 = Industry(nace: "0", title: "Construction de véhicules automobiles ", description: "", sectorID: 46, parentID: 350, scian: nil, citi: nil)
//         _ = indus351.save(on: connection).transform(to: ())
//        let indus352 = Industry(nace: "2", title: "Fabrication de carrosseries et remorques ", description: "", sectorID: 46, parentID: nil, scian: nil, citi: "2")
//         _ = indus352.save(on: connection).transform(to: ())
//
//        let indus353 = Industry(nace: "0", title: "Fabrication de carrosseries et remorques ", description: "", sectorID: 46, parentID: 352, scian: nil, citi: nil)
//         _ = indus353.save(on: connection).transform(to: ())
//
//        let indus354 = Industry(nace: "3", title: "Fabrication d'équipements automobiles ", description: "", sectorID: 46, parentID: nil, scian: nil, citi: "3")
//         _ = indus354.save(on: connection).transform(to: ())
//
//        let indus355 = Industry(nace: "0", title: "Fabrication d'équipements automobiles ", description: "", sectorID: 46, parentID: 354, scian: nil, citi: nil)
//         _ = indus355.save(on: connection).transform(to: ())
//
//        let indus356 = Industry(nace: "1", title: "Construction navale ", description: "", sectorID: 47, parentID: nil, scian: nil, citi: "1")
//         _ = indus356.save(on: connection).transform(to: ())
//
//        let indus357 = Industry(nace: "1", title: "Construction et réparation de navires ", description: "", sectorID: 47, parentID: 356, scian: nil, citi: "1")
//         _ = indus357.save(on: connection).transform(to: ())
//
//        let indus358 = Industry(nace: "2", title: "Construction de matériel ferroviaire roulant ", description: "", sectorID: 47, parentID: nil, scian: nil, citi: "2")
//         _ = indus358.save(on: connection).transform(to: ())
//        let indus359 = Industry(nace: "0", title: "Construction de matériel ferroviaire roulant ", description: "", sectorID: 47, parentID: 358, scian: nil, citi: nil)
//         _ = indus359.save(on: connection).transform(to: ())
//
//        let indus360 = Industry(nace: "3", title: "Construction aéronautique et spatiale ", description: "", sectorID: 47, parentID: nil, scian: nil, citi: "3")
//         _ = indus360.save(on: connection).transform(to: ())
//
//        let indus361 = Industry(nace: "0", title: "Construction aéronautique et spatiale ", description: "", sectorID: 47, parentID: 360, scian: nil, citi: nil)
//         _ = indus361.save(on: connection).transform(to: ())
//
//        let indus362 = Industry(nace: "4", title: "Fabrication de motocycles et de bicyclettes ", description: "", sectorID: 47, parentID: nil, scian: nil, citi: "4")
//         _ = indus362.save(on: connection).transform(to: ())
//
//        let indus363 = Industry(nace: "1", title: "Fabrication de motocycles ", description: "", sectorID: 47, parentID: 362, scian: nil, citi: "1")
//         _ = indus363.save(on: connection).transform(to: ())
//
//        let indus364 = Industry(nace: "2", title: "Fabrication de bicyclettes ", description: "", sectorID: 47, parentID: 362, scian: nil, citi: "2")
//         _ = indus364.save(on: connection).transform(to: ())
//        let indus365 = Industry(nace: "3", title: "Fabrication de véhicules pour invalides ", description: "", sectorID: 47, parentID: 362, scian: nil, citi: nil)
//         _ = indus365.save(on: connection).transform(to: ())
//
//        let indus366 = Industry(nace: "5", title: "Fabrication de matériels de transport n.c.a. ", description: "", sectorID: 47, parentID: 362, scian: nil, citi: nil)
//         _ = indus366.save(on: connection).transform(to: ())
//
//        let indus367 = Industry(nace: "0", title: "Fabrication de matériels de transport n.c.a. ", description: "", sectorID: 47, parentID: 366, scian: nil, citi: "9")
//         _ = indus367.save(on: connection).transform(to: ())
//
//        let indus368 = Industry(nace: "1", title: "Fabrication de meubles ", description: "", sectorID: 49, parentID: nil, scian: nil, citi: "1")
//         _ = indus368.save(on: connection).transform(to: ())
//
//        let indus369 = Industry(nace: "1", title: "Fabrication de sièges ", description: "", sectorID: 49, parentID: 368, scian: nil, citi: nil)
//         _ = indus369.save(on: connection).transform(to: ())
//
//        let indus370 = Industry(nace: "2", title: "Fabrication de meubles de bureau et de magasin ", description: "", sectorID: 49, parentID: 368, scian: nil, citi: nil)
//         _ = indus370.save(on: connection).transform(to: ())
//
//        let indus371 = Industry(nace: "3", title: "Fabrication de meubles de cuisine ", description: "", sectorID: 49, parentID: 368, scian: nil, citi: nil)
//         _ = indus371.save(on: connection).transform(to: ())
//        let indus372 = Industry(nace: "4", title: "Fabrication d'autres meubles ", description: "", sectorID: 49, parentID: 368, scian: nil, citi: nil)
//         _ = indus372.save(on: connection).transform(to: ())
//
//        let indus373 = Industry(nace: "1", title: "Fabrication de matelas ", description: "", sectorID: 49, parentID: 368, scian: nil, citi: nil)
//         _ = indus373.save(on: connection).transform(to: ())
//
//        let indus374 = Industry(nace: "2", title: "Bijouterie", description: "", sectorID: 49, parentID: nil, scian: nil, citi: "9")
//         _ = indus374.save(on: connection).transform(to: ())
//
//        let indus375 = Industry(nace: "1", title: "Fabrication de monnaies ", description: "", sectorID: 49, parentID: 374, scian: nil, citi: "1")
//         _ = indus375.save(on: connection).transform(to: ())
//
//        let indus376 = Industry(nace: "2", title: "Bijouterie, joaillerie, orfèvrerie ", description: "", sectorID: 49, parentID: 374, scian: nil, citi: nil)
//         _ = indus376.save(on: connection).transform(to: ())
//
//        let indus377 = Industry(nace: "3", title: "Fabrication d'instruments de musique ", description: "", sectorID: 49, parentID: nil, scian: nil, citi: nil)
//         _ = indus377.save(on: connection).transform(to: ())
//
//        let indus378 = Industry(nace: "0", title: "Fabrication d'instruments de musique ", description: "", sectorID: 49, parentID: 377, scian: nil, citi: "2")
//         _ = indus378.save(on: connection).transform(to: ())
//        let indus379 = Industry(nace: "4", title: "Fabrication d'articles de sport ", description: "", sectorID: 49, parentID: nil, scian: nil, citi: nil)
//         _ = indus379.save(on: connection).transform(to: ())
//
//        let indus380 = Industry(nace: "0", title: "Fabrication d'articles de sport ", description: "", sectorID: 49, parentID: 379, scian: nil, citi: "3")
//         _ = indus380.save(on: connection).transform(to: ())
//
//        let indus381 = Industry(nace: "5", title: "Fabrication de jeux et jouets ", description: "", sectorID: 49, parentID: nil, scian: nil, citi: nil)
//         _ = indus381.save(on: connection).transform(to: ())
//
//        let indus382 = Industry(nace: "0", title: "Fabrication de jeux et jouets ", description: "", sectorID: 49, parentID: 381, scian: nil, citi: "4")
//         _ = indus382.save(on: connection).transform(to: ())
//
//        let indus383 = Industry(nace: "6", title: "Autres industries diverses ", description: "", sectorID: 49, parentID: nil, scian: nil, citi: nil)
//         _ = indus383.save(on: connection).transform(to: ())
//
//        let indus384 = Industry(nace: "1", title: "Bijouterie fantaisie ", description: "", sectorID: 49, parentID: 383, scian: nil, citi: "9")
//         _ = indus384.save(on: connection).transform(to: ())
//
//        let indus385 = Industry(nace: "2", title: "Industrie de la brosserie ", description: "", sectorID: 49, parentID: 383, scian: nil, citi: nil)
//         _ = indus385.save(on: connection).transform(to: ())
//        let indus386 = Industry(nace: "3", title: "Autres activités manufacturières n.c.a", description: "", sectorID: 49, parentID: 383, scian: nil, citi: nil)
//         _ = indus386.save(on: connection).transform(to: ())
//
//        let indus387 = Industry(nace: "1", title: "Récupération de matières métalliques recyclables ", description: "", sectorID: 50, parentID: nil, scian: nil, citi: "1")
//         _ = indus387.save(on: connection).transform(to: ())
//
//        let indus388 = Industry(nace: "0", title: "Récupération de matières métalliques recyclables ", description: "", sectorID: 50, parentID: 387, scian: nil, citi: nil)
//         _ = indus388.save(on: connection).transform(to: ())
//
//        let indus389 = Industry(nace: "2", title: "Récupération de matières non métalliques recyclables ", description: "", sectorID: 50, parentID: nil, scian: nil, citi: "2")
//         _ = indus389.save(on: connection).transform(to: ())
//
//        let indus390 = Industry(nace: "0", title: "Récupération de matières non métalliques recyclables ", description: "", sectorID: 50, parentID: 389, scian: nil, citi: nil)
//         _ = indus390.save(on: connection).transform(to: ())
//
//        let indus391 = Industry(nace: "1", title: "Production et distribution d'électricité ", description: "", sectorID: 53, parentID: nil, scian: nil, citi: "1")
//         _ = indus391.save(on: connection).transform(to: ())
//
//        let indus392 = Industry(nace: "1", title: "Production d'électricité ", description: "", sectorID: 53, parentID: 391, scian: nil, citi: nil)
//         _ = indus392.save(on: connection).transform(to: ())
//
//        let indus393 = Industry(nace: "0", title: "", description: "", sectorID: 53, parentID: 391, scian: nil, citi: nil)
//         _ = indus393.save(on: connection).transform(to: ())
//
//        let indus394 = Industry(nace: "2", title: "Transport d'électricité ", description: "", sectorID: 53, parentID: 391, scian: nil, citi: "2")
//         _ = indus394.save(on: connection).transform(to: ())
//
//        let indus395 = Industry(nace: "3", title: "Distribution et commerce d'électricité ", description: "", sectorID: 53, parentID: 391, scian: nil, citi: nil)
//         _ = indus395.save(on: connection).transform(to: ())
//
//        let indus396 = Industry(nace: "2", title: "Production et distribution de combustibles gazeux ", description: "", sectorID: 53, parentID: nil, scian: nil, citi: "2")
//         _ = indus396.save(on: connection).transform(to: ())
//
//        let indus397 = Industry(nace: "1", title: "Production de gaz manufacturé ", description: "", sectorID: 53, parentID: 396, scian: nil, citi: nil)
//         _ = indus397.save(on: connection).transform(to: ())
//
//        let indus398 = Industry(nace: "2", title: "Distribution de combustibles gazeux ", description: "", sectorID: 53, parentID: 396, scian: nil, citi: nil)
//         _ = indus398.save(on: connection).transform(to: ())
//
//        let indus399 = Industry(nace: "3", title: "Production et distribution de chaleur ", description: "", sectorID: 53, parentID: nil, scian: nil, citi: "3")
//         _ = indus399.save(on: connection).transform(to: ())
//        let indus400 = Industry(nace: "0", title: "Production et distribution de chaleur ", description: "", sectorID: 53, parentID: 399, scian: nil, citi: nil)
//         _ = indus400.save(on: connection).transform(to: ())
//
//        let indus401 = Industry(nace: "0", title: "Captage, traitement et distribution d'eau ", description: "", sectorID: 54, parentID: nil, scian: nil, citi: nil)
//         _ = indus401.save(on: connection).transform(to: ())
//
//        let indus402 = Industry(nace: "1", title: "Préparation des sites ", description: "", sectorID: 57, parentID: nil, scian: nil, citi: "1")
//         _ = indus402.save(on: connection).transform(to: ())
//
//        let indus403 = Industry(nace: "1", title: "Démolition et terrassements ", description: "", sectorID: 57, parentID: 402, scian: nil, citi: nil)
//         _ = indus403.save(on: connection).transform(to: ())
//
//        let indus404 = Industry(nace: "2", title: "Forages et sondages ", description: "", sectorID: 57, parentID: 402, scian: nil, citi: nil)
//         _ = indus404.save(on: connection).transform(to: ())
//
//        let indus405 = Industry(nace: "2", title: "Construction d'ouvrages de bâtiment ou de génie civil ", description: "", sectorID: 57, parentID: nil, scian: nil, citi: "2")
//         _ = indus405.save(on: connection).transform(to: ())
//
//        let indus406 = Industry(nace: "1", title: "Travaux de construction ", description: "", sectorID: 57, parentID: 405, scian: nil, citi: nil)
//         _ = indus406.save(on: connection).transform(to: ())
//        let indus407 = Industry(nace: "2", title: "Réalisation de charpentes et de couvertures ", description: "", sectorID: 57, parentID: 405, scian: nil, citi: nil)
//         _ = indus407.save(on: connection).transform(to: ())
//
//        let indus408 = Industry(nace: "3", title: "Construction de chaussées et de sols sportifs ", description: "", sectorID: 57, parentID: 405, scian: nil, citi: nil)
//         _ = indus408.save(on: connection).transform(to: ())
//
//        let indus409 = Industry(nace: "4", title: "Travaux maritimes et fluviaux ", description: "", sectorID: 57, parentID: 405, scian: nil, citi: nil)
//         _ = indus409.save(on: connection).transform(to: ())
//
//        let indus410 = Industry(nace: "5", title: "Autres travaux de construction ", description: "", sectorID: 57, parentID: 405, scian: nil, citi: nil)
//         _ = indus410.save(on: connection).transform(to: ())
//
//        let indus411 = Industry(nace: "3", title: "Travaux d'installation  ", description: "", sectorID: 57, parentID: nil, scian: nil, citi: "3")
//         _ = indus411.save(on: connection).transform(to: ())
//
//        let indus412 = Industry(nace: "1", title: "Travaux d'installation électrique ", description: "", sectorID: 57, parentID: 411, scian: nil, citi: nil)
//         _ = indus412.save(on: connection).transform(to: ())
//
//        let indus413 = Industry(nace: "2", title: "Travaux d'isolation ", description: "", sectorID: 57, parentID: 411, scian: nil, citi: nil)
//         _ = indus413.save(on: connection).transform(to: ())
//        let indus414 = Industry(nace: "3", title: "Plomberie", description: "", sectorID:57 , parentID: 411, scian: nil, citi: nil)
//         _ = indus414.save(on: connection).transform(to: ())
//
//        let indus415 = Industry(nace: "4", title: "Autres travaux d'installation ", description: "", sectorID: 47, parentID: 411, scian: nil, citi: nil)
//         _ = indus415.save(on: connection).transform(to: ())
//
//        let indus416 = Industry(nace: "4", title: "Travaux de finition ", description: "", sectorID: 47, parentID: nil, scian: nil, citi: "4")
//         _ = indus416.save(on: connection).transform(to: ())
//        let indus417 = Industry(nace: "1", title: "Plâtrerie", description: "", sectorID: 47, parentID: 416, scian: nil, citi: nil)
//         _ = indus417.save(on: connection).transform(to: ())
//
//        let indus418 = Industry(nace: "2", title: "Menuiserie", description: "", sectorID: 47, parentID: 416, scian: nil, citi: nil)
//         _ = indus418.save(on: connection).transform(to: ())
//
//        let indus419 = Industry(nace: "0", title: "Revêtement des sols et des murs ", description: "", sectorID: 47, parentID: 416, scian: nil, citi: nil)
//         _ = indus419.save(on: connection).transform(to: ())
//
//        let indus420 = Industry(nace: "4", title: "Peinture et vitrerie ", description: "", sectorID: 47, parentID: 416, scian: nil, citi: nil)
//         _ = indus420.save(on: connection).transform(to: ())
//
//        let indus421 = Industry(nace: "0", title: "Autres travaux de finition ", description: "", sectorID: 47, parentID: 416, scian: nil, citi: nil)
//         _ = indus421.save(on: connection).transform(to: ())
//
//        let indus422 = Industry(nace: "5", title: "Location avec opérateur de matériel de construction ", description: "", sectorID: 47, parentID: nil, scian: nil, citi: "5")
//         _ = indus422.save(on: connection).transform(to: ())
//
//        let indus423 = Industry(nace: "0", title: "Location avec opérateur de matériel de construction ", description: "", sectorID: 47, parentID: 422, scian: nil, citi: nil)
//         _ = indus423.save(on: connection).transform(to: ())
//
//        let indus424 = Industry(nace: "1", title: "Commerce de véhicules automobiles ", description: "", sectorID: 60, parentID: nil, scian: nil, citi: "1")
//         _ = indus424.save(on: connection).transform(to: ())
//        let indus425 = Industry(nace: "0", title: "Commerce de véhicules automobiles ", description: "", sectorID: 60, parentID: 424, scian: nil, citi: nil)
//         _ = indus425.save(on: connection).transform(to: ())
//
//        let indus426 = Industry(nace: "2", title: "Entretien et réparation de véhicules automobiles ", description: "", sectorID: 60, parentID: nil, scian: nil, citi: "2")
//         _ = indus426.save(on: connection).transform(to: ())
//
//        let indus427 = Industry(nace: "0", title: "Entretien et réparation de véhicules automobiles ", description: "", sectorID: 60, parentID: 426, scian: nil, citi: nil)
//         _ = indus427.save(on: connection).transform(to: ())
//
//        let indus428 = Industry(nace: "3", title: "Commerce d'équipements automobiles ", description: "", sectorID: 60, parentID: nil, scian: nil, citi: "3")
//         _ = indus428.save(on: connection).transform(to: ())
//
//        let indus429 = Industry(nace: "0", title: "Commerce d'équipements automobiles ", description: "", sectorID: 60, parentID: 428, scian: nil, citi: nil)
//         _ = indus429.save(on: connection).transform(to: ())
//
//        let indus430 = Industry(nace: "4", title: "Commerce et réparation de motocycles ", description: "", sectorID: 60, parentID: nil, scian: nil, citi: "4")
//         _ = indus430.save(on: connection).transform(to: ())
//        let indus431 = Industry(nace: "0", title: "Commerce et réparation de motocycles ", description: "", sectorID: 60, parentID: 430, scian: nil, citi: nil)
//         _ = indus431.save(on: connection).transform(to: ())
//
//        let indus432 = Industry(nace: "5", title: "Commerce de détail de carburants ", description: "", sectorID: 60, parentID: nil, scian: nil, citi: "5")
//         _ = indus432.save(on: connection).transform(to: ())
//
//        let indus433 = Industry(nace: "0", title: "Commerce de détail de carburants ", description: "", sectorID: 60, parentID: 432, scian: nil, citi: nil)
//         _ = indus433.save(on: connection).transform(to: ())
//
//        let indus434 = Industry(nace: "1", title: "Intermédiaires du commerce de gros ", description: "", sectorID: 61, parentID: nil, scian: nil, citi: "1")
//         _ = indus434.save(on: connection).transform(to: ())
//
//        let indus435 = Industry(nace: "1", title: "Intermédiaires du commerce en matières premières agricoles, animaux vivants, matières premières textiles et demi-produits ", description: "", sectorID: 61, parentID: 434, scian: nil, citi: nil)
//         _ = indus435.save(on: connection).transform(to: ())
//
//        let indus436 = Industry(nace: "2", title: "Intermédiaires du commerce en combustibles, métaux, minéraux et produits chimique ", description: "", sectorID: 60, parentID: 435, scian: nil, citi: nil)
//         _ = indus436.save(on: connection).transform(to: ())
//
//        let indus437 = Industry(nace: "3", title: "Intermédiaires du commerce en bois et matériaux de construction  ", description: "", sectorID: 61, parentID: 435, scian: nil, citi: nil)
//         _ = indus437.save(on: connection).transform(to: ())
//        let indus438 = Industry(nace: "4", title: "Intermédiaires du commerce en machines, équipements industriels, navires et avions ", description: "", sectorID: 61, parentID: 435, scian: nil, citi: nil)
//         _ = indus438.save(on: connection).transform(to: ())
//
//        let indus439 = Industry(nace: "5", title: "Intermédiaires du commerce en meubles, articles de ménage et quincaillerie ", description: "", sectorID: 61, parentID: 435, scian: nil, citi: nil)
//         _ = indus439.save(on: connection).transform(to: ())
//
//        let indus440 = Industry(nace: "6", title: "Intermédiaires du commerce en textiles, habillement, chaussures et articles en cuir ", description: "", sectorID: 61, parentID: 435, scian: nil, citi: nil)
//         _ = indus440.save(on: connection).transform(to: ())
//
//        let indus441 = Industry(nace: "7", title: "Intermédiaires du commerce en denrées, boissons et tabac ", description: "", sectorID: 61, parentID: 435, scian: nil, citi: nil)
//         _ = indus441.save(on: connection).transform(to: ())
//
//        let indus442 = Industry(nace: "8", title: "Autres intermédiaires spécialisés du commerce ", description: "", sectorID: 61, parentID: 435, scian: nil, citi: nil)
//         _ = indus442.save(on: connection).transform(to: ())
//
//        let indus443 = Industry(nace: "9", title: "Intermédiaires du commerce en produits divers ", description: "", sectorID: 61, parentID: 435, scian: nil, citi: nil)
//         _ = indus443.save(on: connection).transform(to: ())
//
//        let indus444 = Industry(nace: "2", title: "Commerce de gros de produits agricoles bruts ", description: "", sectorID: 61, parentID: nil, scian: nil, citi: "2")
//         _ = indus444.save(on: connection).transform(to: ())
//        let indus445 = Industry(nace: "1", title: "Commerce de gros de céréales et aliments pour le bétail ", description: "", sectorID: 61, parentID: 444, scian: nil, citi: "1")
//         _ = indus445.save(on: connection).transform(to: ())
//
//        let indus446 = Industry(nace: "2", title: "Commerce de gros de fleurs et plantes ", description: "", sectorID: 61, parentID: 444, scian: nil, citi: nil)
//         _ = indus446.save(on: connection).transform(to: ())
//
//        let indus447 = Industry(nace: "3", title: "Commerce de gros d'animaux vivants ", description: "", sectorID: 61, parentID: 444, scian: nil, citi: nil)
//         _ = indus447.save(on: connection).transform(to: ())
//
//        let indus448 = Industry(nace: "4", title: "Commerce de gros de cuirs et peaux ", description: "", sectorID: 61, parentID: 444, scian: nil, citi: nil)
//         _ = indus448.save(on: connection).transform(to: ())
//
//        let indus449 = Industry(nace: "5", title: "Commerce de gros de tabac non manufacturé ", description: "", sectorID: 61, parentID: 444, scian: nil, citi: nil)
//         _ = indus449.save(on: connection).transform(to: ())
//
//        let indus450 = Industry(nace: "3", title: "Commerce de gros de produits alimentaires ", description: "", sectorID: 61, parentID: nil, scian: nil, citi: nil)
//         _ = indus450.save(on: connection).transform(to: ())
//
//        let indus451 = Industry(nace: "1", title: "Commerce de gros de fruits et légumes ", description: "", sectorID: 61, parentID: 450, scian: nil, citi: "2")
//         _ = indus451.save(on: connection).transform(to: ())
//        let indus452 = Industry(nace: "2", title: "Commerce de gros de viandes ", description: "", sectorID: 61, parentID: 450, scian: nil, citi: nil)
//         _ = indus452.save(on: connection).transform(to: ())
//
//        let indus453 = Industry(nace: "3", title: "Commerce de gros de produits laitiers, oeufs, huiles ", description: "", sectorID: 61, parentID: 450, scian: nil, citi: nil)
//         _ = indus453.save(on: connection).transform(to: ())
//
//        let indus454 = Industry(nace: "4", title: "Commerce de gros de boissons ", description: "", sectorID: 61, parentID: 450, scian: nil, citi: nil)
//         _ = indus454.save(on: connection).transform(to: ())
//
//        let indus455 = Industry(nace: "5", title: "Commerce de gros de tabac ", description: "", sectorID: 61, parentID: 450, scian: nil, citi: nil)
//         _ = indus455.save(on: connection).transform(to: ())
//
//        let indus456 = Industry(nace: "6", title: "Commerce de gros  de sucre, chocolat et confiserie ", description: "", sectorID: 61, parentID: 450, scian: nil, citi: nil)
//         _ = indus456.save(on: connection).transform(to: ())
//
//        let indus457 = Industry(nace: "7", title: "Commerce de gros de café, thé, cacao et épices ", description: "", sectorID: 61, parentID: 450, scian: nil, citi: nil)
//         _ = indus457.save(on: connection).transform(to: ())
//        let indus458 = Industry(nace: "8", title: "Autres commerces de gros alimentaires spécialisés ", description: "", sectorID: 61, parentID: 450, scian: nil, citi: nil)
//         _ = indus458.save(on: connection).transform(to: ())
//
//        let indus459 = Industry(nace: "9", title: "Commerce de gros non spécialisé de denrées, boissons et tabac ", description: "", sectorID: 61, parentID: 450, scian: nil, citi: nil)
//         _ = indus459.save(on: connection).transform(to: ())
//
//        let indus460 = Industry(nace: "4", title: "Commerce de gros de biens de consommation non alimentaires ", description: "", sectorID: 61, parentID: nil, scian: nil, citi: "3")
//         _ = indus460.save(on: connection).transform(to: ())
//
//        let indus461 = Industry(nace: "1", title: "Commerce de gros de textiles ", description: "", sectorID: 61, parentID: 460, scian: nil, citi: "1")
//         _ = indus461.save(on: connection).transform(to: ())
//
//        let indus462 = Industry(nace: "2", title: "Commerce de gros d'habillement et de chaussures ", description: "", sectorID: 61, parentID: 460, scian: nil, citi: nil)
//         _ = indus462.save(on: connection).transform(to: ())
//
//        let indus463 = Industry(nace: "3", title: "Commerce de gros d'appareils électroménagers et de radios et télévisions ", description: "", sectorID: 61, parentID: 460, scian: nil, citi: "9")
//         _ = indus463.save(on: connection).transform(to: ())
//
//        let indus464 = Industry(nace: "4", title: "Commerce de gros de céramique, verrerie et produits d'entretien ", description: "", sectorID: 61, parentID: 460, scian: nil, citi: nil)
//         _ = indus464.save(on: connection).transform(to: ())
//        let indus465 = Industry(nace: "5", title: "Commerce de gros de parfumerie et de produits de beauté ", description: "", sectorID: 61, parentID: 460, scian: nil, citi: nil)
//         _ = indus465.save(on: connection).transform(to: ())
//
//        let indus466 = Industry(nace: "6", title: "Commerce de gros de produits pharmaceutiques ", description: "", sectorID: 61, parentID: 460, scian: nil, citi: nil)
//         _ = indus466.save(on: connection).transform(to: ())
//
//        let indus467 = Industry(nace: "7", title: "Commerce de gros de biens de consommation non alimentaires divers ", description: "", sectorID: 61, parentID: 460, scian: nil, citi: nil)
//         _ = indus467.save(on: connection).transform(to: ())
//
//        let indus468 = Industry(nace: "5", title: "Commerce de gros de produits intermédiaires non agricoles ", description: "", sectorID: 61, parentID: nil, scian: nil, citi: "4")
//         _ = indus468.save(on: connection).transform(to: ())
//
//        let indus469 = Industry(nace: "1", title: "Commerce de gros de combustibles ", description: "", sectorID: 61, parentID: 468, scian: nil, citi: "1")
//         _ = indus469.save(on: connection).transform(to: ())
//
//        let indus470 = Industry(nace: "2", title: "Commerce de gros de minerais et métaux ", description: "", sectorID: 61, parentID: 468, scian: nil, citi: "2")
//         _ = indus470.save(on: connection).transform(to: ())
//
//        let indus471 = Industry(nace: "3", title: "Commerce de gros de bois et de matériaux de construction ", description: "", sectorID: 61, parentID: 468, scian: nil, citi: "3")
//         _ = indus471.save(on: connection).transform(to: ())
//        let indus472 = Industry(nace: "4", title: "Commerce de gros de quincaillerie et fournitures pour plomberie et chauffage ", description: "", sectorID: 61, parentID: 468, scian: nil, citi: nil)
//         _ = indus472.save(on: connection).transform(to: ())
//
//        let indus473 = Industry(nace: "5", title: "Commerce de gros de produits chimiques ", description: "", sectorID: 61, parentID: 468, scian: nil, citi: "9")
//         _ = indus473.save(on: connection).transform(to: ())
//
//        let indus474 = Industry(nace: "6", title: "Commerce de gros d'autres produits intermédiaires ", description: "", sectorID: 61, parentID: 468, scian: nil, citi: nil)
//         _ = indus474.save(on: connection).transform(to: ())
//
//        let indus475 = Industry(nace: "7", title: "Commerce de gros de déchets et débris ", description: "", sectorID: 61, parentID: 468, scian: nil, citi: nil)
//         _ = indus475.save(on: connection).transform(to: ())
//
//        let indus476 = Industry(nace: "8", title: "Commerce de gros d'équipements industriels ", description: "", sectorID: 61, parentID: nil, scian: nil, citi: "5")
//         _ = indus476.save(on: connection).transform(to: ())
//
//        let indus477 = Industry(nace: "8", title: "Commerce de gros d'ordinateurs, d'équipements informatiques périphériques et de progiciels ", description: "", sectorID: 61, parentID: 476, scian: nil, citi: "1")
//         _ = indus477.save(on: connection).transform(to: ())
//
//        let indus478 = Industry(nace: "6", title: "Commerce de gros de composants et d'autres équipements électroniques ", description: "", sectorID: 61, parentID: 476, scian: nil, citi: "2")
//         _ = indus478.save(on: connection).transform(to: ())
//        let indus479 = Industry(nace: "1", title: "Commerce de gros de machines-outils  ", description: "", sectorID: 61, parentID: 476, scian: nil, citi: "9")
//         _ = indus479.save(on: connection).transform(to: ())
//
//        let indus480 = Industry(nace: "2", title: "Commerce de gros de machines pour l'extraction, la construction et le génie civil ", description: "", sectorID: 61, parentID: 476, scian: nil, citi: nil)
//         _ = indus480.save(on: connection).transform(to: ())
//
//        let indus481 = Industry(nace: "3", title: "Commerce de gros de machines pour l'industrie textile et l'habillement ", description: "", sectorID: 61, parentID: 476, scian: nil, citi: nil)
//         _ = indus481.save(on: connection).transform(to: ())
//        let indus482 = Industry(nace: "5", title: "Commerce de gros d'autres machines et équipements de bureau ", description: "", sectorID: 61, parentID: 476, scian: nil, citi: nil)
//         _ = indus482.save(on: connection).transform(to: ())
//
//        let indus483 = Industry(nace: "7", title: "Commerce de gros d'autres machines utilisées dans l'industrie, le commerce ", description: "", sectorID: 61, parentID: 476, scian: nil, citi: nil)
//         _ = indus483.save(on: connection).transform(to: ())
//
//        let indus484 = Industry(nace: "8", title: "Commerce de gros de matériel agricole ", description: "", sectorID: 61, parentID: 476, scian: nil, citi: "")
//         _ = indus484.save(on: connection).transform(to: ())
//
//        let indus485 = Industry(nace: "9", title: "Autres commerces de gros ", description: "", sectorID: 61, parentID: nil, scian: nil, citi: "9")
//         _ = indus485.save(on: connection).transform(to: ())
//
//        let indus486 = Industry(nace: "0", title: "Autres commerces de gros ", description: "", sectorID: 61, parentID: 485, scian: nil, citi: nil)
//         _ = indus486.save(on: connection).transform(to: ())
//
//        let indus487 = Industry(nace: "1", title: "Commerce de détail en magasin non spécialisé ", description: "", sectorID: 62, parentID: nil, scian: nil, citi: "1")
//         _ = indus487.save(on: connection).transform(to: ())
//
//        let indus488 = Industry(nace: "1", title: "Commerce de détail en magasin non spécialisé à prédominance alimentaire ", description: "", sectorID: 62, parentID: 487, scian: nil, citi: "1")
//         _ = indus488.save(on: connection).transform(to: ())
//        let indus489 = Industry(nace: "2", title: "Commerce de détail en magasin non spécialisé sans prédominance alimentaire ", description: "", sectorID: 62, parentID: 487, scian: nil, citi: "9")
//         _ = indus489.save(on: connection).transform(to: ())
//
//        let indus490 = Industry(nace: "2", title: "Commerce de détail alimentaire en magasin spécialisé ", description: "", sectorID: 62, parentID: nil, scian: nil, citi: "2")
//         _ = indus490.save(on: connection).transform(to: ())
//
//        let indus491 = Industry(nace: "1", title: "Commerce de détail de fruits et légumes ", description: "", sectorID: 62, parentID: 490, scian: nil, citi: nil)
//         _ = indus491.save(on: connection).transform(to: ())
//
//        let indus492 = Industry(nace: "2", title: "Commerce de détail de viandes et produits à base de viande ", description: "", sectorID: 62, parentID: 490, scian: nil, citi: nil)
//         _ = indus492.save(on: connection).transform(to: ())
//
//        let indus493 = Industry(nace: "3", title: "Commerce de détail de poissons, crustacés et mollusques ", description: "", sectorID: 62, parentID: 490, scian: nil, citi: nil)
//         _ = indus493.save(on: connection).transform(to: ())
//
//        let indus494 = Industry(nace: "4", title: "Commerce de détail de pain, pâtisserie et confiserie ", description: "", sectorID: 62, parentID: 490, scian: nil, citi: nil)
//         _ = indus494.save(on: connection).transform(to: ())
//
//        let indus495 = Industry(nace: "5", title: "Commerce de détail de boissons ", description: "", sectorID: 62, parentID: 490, scian: nil, citi: nil)
//         _ = indus495.save(on: connection).transform(to: ())
//        let indus496 = Industry(nace: "6", title: "Commerce de détail de tabac ", description: "", sectorID: 62, parentID: 490, scian: nil, citi: "")
//         _ = indus496.save(on: connection).transform(to: ())
//
//        let indus497 = Industry(nace: "7", title: "Autres commerces de détail alimentaires en magasin spécialisé ", description: "", sectorID: 62, parentID: 490, scian: nil, citi: nil)
//         _ = indus497.save(on: connection).transform(to: ())
//
//        let indus498 = Industry(nace: "3", title: "Commerce de détail de produits pharmaceutiques et de parfumerie ", description: "", sectorID: 62, parentID: nil, scian: nil, citi: "3")
//         _ = indus498.save(on: connection).transform(to: ())
//
//        let indus499 = Industry(nace: "1", title: "Commerce de détail de produits pharmaceutiques ", description: "", sectorID: 62, parentID: 498, scian: nil, citi: "1")
//         _ = indus499.save(on: connection).transform(to: ())
//
//        let indus500 = Industry(nace: "2", title: "Commerce de détail d'articles médicaux et orthopédiques ", description: "", sectorID: 62, parentID: 498, scian: nil, citi: nil)
//         _ = indus500.save(on: connection).transform(to: ())
//
//        let indus501 = Industry(nace: "3", title: "Commerce de détail de parfumerie et de produits de beauté ", description: "", sectorID: 62, parentID: 498, scian: nil, citi: nil)
//         _ = indus501.save(on: connection).transform(to: ())
//        let indus502 = Industry(nace: "4", title: "Autres commerces de détail en magasin spécialisé ", description: "", sectorID: 62, parentID: nil, scian: nil, citi: nil)
//         _ = indus502.save(on: connection).transform(to: ())
//
//        let indus503 = Industry(nace: "1", title: "Commerce de détail de textiles ", description: "", sectorID: 62, parentID: 502, scian: nil, citi: "2")
//         _ = indus503.save(on: connection).transform(to: ())
//
//        let indus504 = Industry(nace: "2", title: "Commerce de détail d'habillement ", description: "", sectorID: 62, parentID: 502, scian: nil, citi: nil)
//         _ = indus504.save(on: connection).transform(to: ())
//
//        let indus505 = Industry(nace: "3", title: "52.43  Commerce de détail de chaussures et d'articles en cuir ", description: "", sectorID: 62, parentID: 502, scian: nil, citi: nil)
//         _ = indus505.save(on: connection).transform(to: ())
//
//        let indus506 = Industry(nace: "4", title: "Commerce de détail de meubles et d'équipements du foyer ", description: "", sectorID: 62, parentID: 502, scian: nil, citi: "3")
//         _ = indus506.save(on: connection).transform(to: ())
//
//        let indus507 = Industry(nace: "5", title: "Commerce de détail d'appareils électroménagers, de radio et de télévision ", description: "", sectorID: 62, parentID: 502, scian: nil, citi: nil)
//         _ = indus507.save(on: connection).transform(to: ())
//
//        let indus508 = Industry(nace: "6", title: "Commerce de détail de quincaillerie, peintures et verres ", description: "", sectorID: 62, parentID: 502, scian: nil, citi: "4")
//         _ = indus508.save(on: connection).transform(to: ())
//        let indus509 = Industry(nace: "7", title: "Commerce de détail de livres, journaux et papeterie ", description: "", sectorID: 62, parentID: 502, scian: nil, citi: "9")
//         _ = indus509.save(on: connection).transform(to: ())
//
//        let indus510 = Industry(nace: "8", title: "Commerces de détail spécialisés divers ", description: "", sectorID: 62, parentID: 502, scian: nil, citi: nil)
//         _ = indus510.save(on: connection).transform(to: ())
//
//        let indus511 = Industry(nace: "5", title: "Commerce de détail de biens d'occasion ", description: "", sectorID: 62, parentID: nil, scian: nil, citi: "4")
//         _ = indus511.save(on: connection).transform(to: ())
//
//        let indus512 = Industry(nace: "0", title: "Commerce de détail de biens d'occasion ", description: "", sectorID: 62, parentID: 511, scian: nil, citi: nil)
//         _ = indus512.save(on: connection).transform(to: ())
//
//        let indus513 = Industry(nace: "6", title: "Commerce de détail hors ", description: "", sectorID: 62, parentID: nil, scian: nil, citi: "5")
//         _ = indus513.save(on: connection).transform(to: ())
//
//        let indus514 = Industry(nace: "1", title: "Vente par correspondance ", description: "", sectorID: 62, parentID: 513, scian: nil, citi: "1")
//         _ = indus514.save(on: connection).transform(to: ())
//
//        let indus515 = Industry(nace: "2", title: "Commerce de détail sur éventaires et marchés ", description: "", sectorID: 62, parentID: 513, scian: nil, citi: "2")
//         _ = indus515.save(on: connection).transform(to: ())
//        let indus516 = Industry(nace: "3", title: "Autres commerces de détail hors magasin ", description: "", sectorID: 62, parentID: 513, scian: nil, citi: "9")
//         _ = indus516.save(on: connection).transform(to: ())
//
//        let indus517 = Industry(nace: "0", title: "Réparation d'articles personnels et domestiques ", description: "", sectorID: 62, parentID: nil, scian: nil, citi: "6")
//         _ = indus517.save(on: connection).transform(to: ())
//
//        let indus518 = Industry(nace: "1", title: "Réparation de chaussures et d'articles en cuir ", description: "", sectorID: 62, parentID: 517, scian: nil, citi: nil)
//         _ = indus518.save(on: connection).transform(to: ())
//
//        let indus519 = Industry(nace: "0", title: "Réparation d'appareils électriques à usage domestique ", description: "", sectorID: 62, parentID: 517, scian: nil, citi: nil)
//         _ = indus519.save(on: connection).transform(to: ())
//
//        let indus520 = Industry(nace: "0", title: "Réparation de montres, horloges et bijoux ", description: "", sectorID: 62, parentID: 517, scian: nil, citi: nil)
//         _ = indus520.save(on: connection).transform(to: ())
//
//        let indus521 = Industry(nace: "4", title: "Réparation d'articles personnels et domestiques n.c.a. ", description: "", sectorID: 62, parentID: 517, scian: nil, citi: nil)
//         _ = indus521.save(on: connection).transform(to: ())
//
//        let indus522 = Industry(nace: "1", title: "Hôtels", description: "", sectorID: 65, parentID: nil, scian: nil, citi: "1")
//         _ = indus522.save(on: connection).transform(to: ())
//
//        let indus523 = Industry(nace: "0", title: "Hôtels", description: "", sectorID: 65, parentID: 522, scian: nil, citi: nil)
//         _ = indus523.save(on: connection).transform(to: ())
//
//        let indus524 = Industry(nace: "0", title: "Autres moyens d'hébergement de courte durée ", description: "", sectorID: 65, parentID: nil, scian: nil, citi: "")
//         _ = indus524.save(on: connection).transform(to: ())
//        let indus525 = Industry(nace: "1", title: "Auberges de jeunesse et refuges ", description: "", sectorID: 65, parentID: 524, scian: nil, citi: nil)
//         _ = indus525.save(on: connection).transform(to: ())
//
//        let indus526 = Industry(nace: "2", title: "Exploitation de terrains de camping ", description: "", sectorID: 65, parentID: 524, scian: nil, citi: nil)
//         _ = indus526.save(on: connection).transform(to: ())
//
//        let indus527 = Industry(nace: "3", title: "Moyens d'hébergement divers ", description: "", sectorID: 65, parentID: 524, scian: nil, citi: nil)
//         _ = indus527.save(on: connection).transform(to: ())
//
//        let indus528 = Industry(nace: "3", title: "Restaurants", description: "", sectorID: 65, parentID: nil, scian: nil, citi: "2")
//         _ = indus528.save(on: connection).transform(to: ())
//
//        let indus529 = Industry(nace: "0", title: "Restaurants", description: "", sectorID: 65, parentID: 528, scian: nil, citi: nil)
//         _ = indus529.save(on: connection).transform(to: ())
//
//        let indus530 = Industry(nace: "4", title: "Cafés ", description: "", sectorID: 65, parentID: nil, scian: nil, citi: "4")
//         _ = indus530.save(on: connection).transform(to: ())
//        let indus531 = Industry(nace: "0", title: "Cafés ", description: "", sectorID: 65, parentID: 530, scian: nil, citi: nil)
//         _ = indus531.save(on: connection).transform(to: ())
//
//        let indus532 = Industry(nace: "5", title: "Cantines et traiteurs ", description: "", sectorID: 65, parentID: nil, scian: nil, citi: "5")
//         _ = indus532.save(on: connection).transform(to: ())
//
//        let indus533 = Industry(nace: "1", title: "Cantines et restaurants d'entreprises ", description: "", sectorID: 65, parentID: 532, scian: nil, citi: nil)
//         _ = indus533.save(on: connection).transform(to: ())
//
//        let indus534 = Industry(nace: "2", title: "Traiteurs ", description: "", sectorID: 65, parentID: 532, scian: nil, citi: nil)
//         _ = indus534.save(on: connection).transform(to: ())
//
//        let indus535 = Industry(nace: "1", title: "Transports ferroviaires ", description: "", sectorID: 65, parentID: nil, scian: nil, citi: "1")
//         _ = indus535.save(on: connection).transform(to: ())
//
//        let indus536 = Industry(nace: "0", title: "Transports ferroviaires ", description: "", sectorID: 65, parentID: 535, scian: nil, citi: nil)
//         _ = indus536.save(on: connection).transform(to: ())
//
//        let indus537 = Industry(nace: "2", title: "Transports urbains et routiers ", description: "", sectorID: 65, parentID: nil, scian: nil, citi: "2")
//         _ = indus537.save(on: connection).transform(to: ())
//        let indus538 = Industry(nace: "0", title: "Transports réguliers de voyageurs ", description: "", sectorID: 65, parentID: 537, scian: nil, citi: "1")
//         _ = indus538.save(on: connection).transform(to: ())
//
//        let indus539 = Industry(nace: "2", title: "Transport de voyageurs par taxis ", description: "", sectorID: 65, parentID: 537, scian: nil, citi: "2")
//         _ = indus539.save(on: connection).transform(to: ())
//
//        let indus540 = Industry(nace: "3", title: "Autres transports routiers de voyageurs ", description: "", sectorID: 65, parentID: 537, scian: nil, citi: nil)
//         _ = indus540.save(on: connection).transform(to: ())
//
//        let indus541 = Industry(nace: "4", title: "Transports routiers de marchandises ", description: "", sectorID: 65, parentID: 537, scian: nil, citi: "3")
//         _ = indus541.save(on: connection).transform(to: ())
//
//        let indus542 = Industry(nace: "3", title: "Transports par conduites ", description: "", sectorID: 65, parentID: nil, scian: nil, citi: "3")
//         _ = indus542.save(on: connection).transform(to: ())
//
//        let indus543 = Industry(nace: "0", title: "Transports par conduites ", description: "", sectorID: 65, parentID: 542, scian: nil, citi: nil)
//         _ = indus543.save(on: connection).transform(to: ())
//
//        let indus544 = Industry(nace: "1", title: "Transports maritimes et côtiers ", description: "", sectorID: 69, parentID: nil, scian: nil, citi: "1")
//         _ = indus544.save(on: connection).transform(to: ())
//        let indus545 = Industry(nace: "0", title: "Transports maritimes et côtiers ", description: "", sectorID: 69, parentID: 544, scian: nil, citi: nil)
//         _ = indus545.save(on: connection).transform(to: ())
//
//        let indus546 = Industry(nace: "2", title: "Transports fluviaux ", description: "", sectorID: 69, parentID: nil, scian: nil, citi: "2")
//         _ = indus546.save(on: connection).transform(to: ())
//
//        let indus547 = Industry(nace: "0", title: "Transports fluviaux ", description: "", sectorID: 69, parentID: 546, scian: nil, citi: nil)
//         _ = indus547.save(on: connection).transform(to: ())
//
//        let indus548 = Industry(nace: "1", title: "Transports aériens réguliers ", description: "", sectorID: 70, parentID: nil, scian: nil, citi: "1")
//         _ = indus548.save(on: connection).transform(to: ())
//
//        let indus549 = Industry(nace: "0", title: "Transports aériens réguliers ", description: "", sectorID: 70, parentID: 548, scian: nil, citi: nil)
//         _ = indus549.save(on: connection).transform(to: ())
//
//        let indus550 = Industry(nace: "2", title: "Transports aériens non réguliers ", description: "", sectorID: 70, parentID: nil, scian: nil, citi: "2")
//         _ = indus550.save(on: connection).transform(to: ())
//
//        let indus551 = Industry(nace: "0", title: "Transports aériens non réguliers ", description: "", sectorID: 70, parentID: 550, scian: nil, citi: nil)
//         _ = indus551.save(on: connection).transform(to: ())
//        let indus552 = Industry(nace: "3", title: "Transports spatiaux ", description: "", sectorID: 70, parentID: nil, scian: nil, citi: nil)
//         _ = indus552.save(on: connection).transform(to: ())
//
//        let indus553 = Industry(nace: "0", title: "Transports spatiaux ", description: "", sectorID: 70, parentID: 552, scian: nil, citi: nil)
//         _ = indus553.save(on: connection).transform(to: ())
//
//        let indus554 = Industry(nace: "1", title: "Manutention et entreposage ", description: "", sectorID: 71, parentID: nil, scian: nil, citi: "1")
//         _ = indus554.save(on: connection).transform(to: ())
//
//        let indus555 = Industry(nace: "1", title: "Manutention", description: "", sectorID: 71, parentID: 554, scian: nil, citi: "1")
//         _ = indus555.save(on: connection).transform(to: ())
//
//        let indus556 = Industry(nace: "2", title: "Entreposage", description: "", sectorID: 71, parentID: 554, scian: nil, citi: "2")
//         _ = indus556.save(on: connection).transform(to: ())
//
//        let indus557 = Industry(nace: "2", title: "Gestion d'infrastructures de transports ", description: "", sectorID: 71, parentID: nil, scian: nil, citi: nil)
//         _ = indus557.save(on: connection).transform(to: ())
//        let indus558 = Industry(nace: "1", title: "Gestion d'infrastructures de transports terrestres ", description: "", sectorID: 71, parentID: 557, scian: nil, citi: "3")
//         _ = indus558.save(on: connection).transform(to: ())
//
//        let indus559 = Industry(nace: "2", title: "Services portuaires, maritimes et fluviaux ", description: "", sectorID: 71, parentID: 557, scian: nil, citi: nil)
//         _ = indus559.save(on: connection).transform(to: ())
//
//        let indus560 = Industry(nace: "3", title: "Services aéroportuaires ", description: "", sectorID: 71, parentID: 557, scian: nil, citi: nil)
//         _ = indus560.save(on: connection).transform(to: ())
//
//        let indus561 = Industry(nace: "3", title: "Agences de voyages ", description: "", sectorID: 71, parentID: nil, scian: nil, citi: nil)
//         _ = indus561.save(on: connection).transform(to: ())
//
//        let indus562 = Industry(nace: "0", title: "Agences de voyages ", description: "", sectorID: 71, parentID: 561, scian: nil, citi: "4")
//         _ = indus562.save(on: connection).transform(to: ())
//
//        let indus563 = Industry(nace: "4", title: "Organisation du transport de fret ", description: "", sectorID: 71, parentID: nil, scian: nil, citi: nil)
//         _ = indus563.save(on: connection).transform(to: ())
//
//        let indus564 = Industry(nace: "0", title: "Organisation du transport de fret ", description: "", sectorID: 71, parentID: 563, scian: nil, citi: "9")
//         _ = indus564.save(on: connection).transform(to: ())
//        let indus565 = Industry(nace: "1", title: "Activités de poste et de courrier ", description: "", sectorID: 72, parentID: nil, scian: nil, citi: "1")
//         _ = indus565.save(on: connection).transform(to: ())
//
//        let indus566 = Industry(nace: "1", title: "Postes nationales ", description: "", sectorID: 72, parentID: 565, scian: nil, citi: "1")
//         _ = indus566.save(on: connection).transform(to: ())
//
//        let indus567 = Industry(nace: "2", title: "Autres activités de courrier ", description: "", sectorID: 72, parentID: 565, scian: nil, citi: "2")
//         _ = indus567.save(on: connection).transform(to: ())
//
//        let indus568 = Industry(nace: "2", title: "Télécommunications", description: "", sectorID: 72, parentID: nil, scian: nil, citi: "2")
//         _ = indus568.save(on: connection).transform(to: ())
//
//        let indus569 = Industry(nace: "0", title: "Télécommunications", description: "", sectorID: 72, parentID: 568, scian: nil, citi: nil)
//         _ = indus569.save(on: connection).transform(to: ())
//
//        let indus570 = Industry(nace: "0", title: "Intermédiation monétaire ", description: "", sectorID: 75, parentID: nil, scian: nil, citi: "1")
//         _ = indus570.save(on: connection).transform(to: ())
//
//        let indus571 = Industry(nace: "1", title: "Intermédiation monétaire ", description: "", sectorID: 75, parentID: nil, scian: nil, citi: "1")
//         _ = indus571.save(on: connection).transform(to: ())
//        let indus572 = Industry(nace: "1", title: "Banque centrale ", description: "", sectorID: 75, parentID:571 , scian: nil, citi: "1")
//         _ = indus572.save(on: connection).transform(to: ())
//
//        let indus573 = Industry(nace: "2", title: "Autres intermédiations monétaires ", description: "", sectorID: 75, parentID: 571, scian: nil, citi: "9")
//         _ = indus573.save(on: connection).transform(to: ())
//
//        let indus574 = Industry(nace: "2", title: "Autres intermédiations financières ", description: "", sectorID: 75, parentID: nil, scian: nil, citi: "9")
//         _ = indus574.save(on: connection).transform(to: ())
//
//        let indus575 = Industry(nace: "1", title: "Crédit bail ", description: "", sectorID: 75, parentID: 574, scian: nil, citi: "1")
//         _ = indus575.save(on: connection).transform(to: ())
//
//        let indus576 = Industry(nace: "2", title: "Distribution de crédit ", description: "", sectorID: 75, parentID: 574, scian: nil, citi: "2")
//         _ = indus576.save(on: connection).transform(to: ())
//
//        let indus577 = Industry(nace: "3", title: "Autres intermédiations financières n.c.a", description: "", sectorID: 75, parentID: 574, scian: nil, citi: "9")
//         _ = indus577.save(on: connection).transform(to: ())
//
//        let indus578 = Industry(nace: "0", title: "Assurance ", description: "", sectorID: 76, parentID: nil, scian: nil, citi: nil)
//         _ = indus578.save(on: connection).transform(to: ())
//        let indus579 = Industry(nace: "1", title: "Assurance-vie et capitalisation ", description: "", sectorID: 76, parentID: 578, scian: nil, citi: "1")
//         _ = indus579.save(on: connection).transform(to: ())
//
//        let indus580 = Industry(nace: "2", title: "Caisses de retraite ", description: "", sectorID: 76, parentID: 578, scian: nil, citi: "2")
//         _ = indus580.save(on: connection).transform(to: ())
//
//        let indus581 = Industry(nace: "3", title: "Autres assurances ", description: "", sectorID: 76, parentID: 578, scian: nil, citi: "3")
//         _ = indus581.save(on: connection).transform(to: ())
//
//
//        let indus582 = Industry(nace: "1", title: "Auxiliaires financiers ", description: "", sectorID: 77, parentID: nil, scian: nil, citi: "1")
//         _ = indus582.save(on: connection).transform(to: ())
//
//        let indus583 = Industry(nace: "1", title: "Administration de marchés financiers ", description: "", sectorID: 77, parentID: 582, scian: nil, citi: "1")
//         _ = indus583.save(on: connection).transform(to: ())
//
//        let indus584 = Industry(nace: "2", title: "Gestion de portefeuilles ", description: "", sectorID: 77, parentID: 582, scian: nil, citi: "2")
//         _ = indus584.save(on: connection).transform(to: ())
//
//        let indus585 = Industry(nace: "3", title: "Autres auxiliaires financiers ", description: "", sectorID: 77, parentID: 582, scian: nil, citi: "9")
//         _ = indus585.save(on: connection).transform(to: ())
//
//        let indus586 = Industry(nace: "2", title: "Auxiliaires d'assurance ", description: "", sectorID: 77, parentID: nil, scian: nil, citi: "2")
//         _ = indus586.save(on: connection).transform(to: ())
//
//        let indus587 = Industry(nace: "0", title: "Auxiliaires d'assurance ", description: "", sectorID: 77, parentID: 586, scian: nil, citi: nil)
//         _ = indus587.save(on: connection).transform(to: ())
//
//        let indus588 = Industry(nace: "1", title: "Activités immobilières pour compte propre ", description: "", sectorID: 80, parentID: nil, scian: nil, citi: "1")
//         _ = indus588.save(on: connection).transform(to: ())
//        let indus589 = Industry(nace: "1", title: "Promotion immobilière", description: "", sectorID: 80, parentID: 588, scian: nil, citi: nil)
//         _ = indus589.save(on: connection).transform(to: ())
//
//        let indus590 = Industry(nace: "2", title: "Marchands de biens immobiliers ", description: "", sectorID: 80, parentID: 588, scian: nil, citi: nil)
//         _ = indus590.save(on: connection).transform(to: ())
//
//        let indus591 = Industry(nace: "2", title: "Location de biens immobiliers ", description: "", sectorID: 80, parentID: 588, scian: nil, citi: nil)
//         _ = indus591.save(on: connection).transform(to: ())
//
//        let indus592 = Industry(nace: "0", title: "Location de biens immobiliers ", description: "", sectorID: 80, parentID: nil, scian: nil, citi: nil)
//         _ = indus592.save(on: connection).transform(to: ())
//
//        let indus593 = Industry(nace: "3", title: "Activités immobilières pour compte de tiers ", description: "", sectorID: 80, parentID: nil, scian: nil, citi: "2")
//         _ = indus593.save(on: connection).transform(to: ())
//
//        let indus594 = Industry(nace: "1", title: "Agences immobilières ", description: "", sectorID: 80, parentID: 593, scian: nil, citi: nil)
//         _ = indus594.save(on: connection).transform(to: ())
//
//        let indus595 = Industry(nace: "2", title: "Administration d'immeubles ", description: "", sectorID: 80, parentID: 593, scian: nil, citi: nil)
//         _ = indus595.save(on: connection).transform(to: ())
//        let indus596 = Industry(nace: "1", title: "Location de véhicules automobiles", description: "", sectorID: 81, parentID: nil, scian: nil, citi: "1")
//         _ = indus596.save(on: connection).transform(to: ())
//
//        let indus597 = Industry(nace: "0", title: "Location de véhicules automobiles", description: "", sectorID: 81, parentID: 596, scian: nil, citi: "1")
//         _ = indus597.save(on: connection).transform(to: ())
//
//        let indus598 = Industry(nace: "2", title: "Location d'autres matériels de transport", description: "", sectorID: 81, parentID: nil, scian: nil, citi: nil)
//         _ = indus598.save(on: connection).transform(to: ())
//
//        let indus599 = Industry(nace: "1", title: "Location d'autres matériels de transport terrestre", description: "", sectorID: 81, parentID: 598, scian: nil, citi: " nil")
//         _ = indus599.save(on: connection).transform(to: ())
//
//        let indus600 = Industry(nace: "2", title: "Location de matériels de transport par eau", description: "", sectorID: 81, parentID: 598, scian: nil, citi: "2")
//         _ = indus600.save(on: connection).transform(to: ())
//
//        let indus601 = Industry(nace: "3", title: "Location de matériels de transport aérien", description: "", sectorID: 81, parentID: 598, scian: nil, citi: "3")
//         _ = indus601.save(on: connection).transform(to: ())
//        let indus602 = Industry(nace: "3", title: "Location de machines et équipements", description: "", sectorID: 81, parentID: nil, scian: nil, citi: "2")
//         _ = indus602.save(on: connection).transform(to: ())
//        let indus603 = Industry(nace: "1", title: "Location de matériel agricole", description: "", sectorID: 81, parentID: 602, scian: nil, citi: "1")
//         _ = indus603.save(on: connection).transform(to: ())
//
//        let indus604 = Industry(nace: "2", title: "Location de machines et équipements pour la construction", description: "", sectorID: 81, parentID: 602, scian: nil, citi: "2")
//         _ = indus604.save(on: connection).transform(to: ())
//
//        let indus605 = Industry(nace: "3", title: "Location de machines de bureau et de matériel informatique", description: "", sectorID: 81, parentID: 603, scian: nil, citi: "3")
//         _ = indus605.save(on: connection).transform(to: ())
//
//        let indus606 = Industry(nace: "4", title: "Location de machines et équipements divers", description: "", sectorID: 81, parentID: 603, scian: nil, citi: "9")
//         _ = indus606.save(on: connection).transform(to: ())
//
//        let indus607 = Industry(nace: "4", title: "Location de biens personnels et domestiques", description: "", sectorID: 81, parentID: nil, scian: nil, citi: "3")
//         _ = indus607.save(on: connection).transform(to: ())
//
//        let indus608 = Industry(nace: "0", title: "Location de biens personnels et domestiques", description: "", sectorID: 81, parentID: 607, scian: nil, citi: nil)
//         _ = indus608.save(on: connection).transform(to: ())
//        let indus609 = Industry(nace: "1", title: "Conseil en systèmes informatiques", description: "", sectorID: 82, parentID: nil, scian: nil, citi: "1")
//         _ = indus609.save(on: connection).transform(to: ())
//
//        let indus610 = Industry(nace: "0", title: "Conseil en systèmes informatiques", description: "", sectorID: 82, parentID: 609, scian: nil, citi: nil)
//         _ = indus610.save(on: connection).transform(to: ())
//
//        let indus611 = Industry(nace: "2", title: "Réalisation de logiciels", description: "", sectorID: 82, parentID: nil, scian: nil, citi: "2")
//         _ = indus611.save(on: connection).transform(to: ())
//
//        let indus612 = Industry(nace: "1", title: "Edition de logiciels (non personnalisés)", description: "", sectorID: 82, parentID: 611, scian: nil, citi: "1")
//         _ = indus612.save(on: connection).transform(to: ())
//
//        let indus613 = Industry(nace: "2", title: "Autres activités de réalisation de logiciels", description: "", sectorID: 82, parentID: 611, scian: nil, citi: "9")
//         _ = indus613.save(on: connection).transform(to: ())
//
//        let indus614 = Industry(nace: "3", title: "Traitement de données", description: "", sectorID: 82, parentID: nil, scian: nil, citi: "3")
//         _ = indus614.save(on: connection).transform(to: ())
//
//        let indus615 = Industry(nace: "0", title: "Traitement de données", description: "", sectorID: 82, parentID: 614, scian: nil, citi: nil)
//         _ = indus615.save(on: connection).transform(to: ())
//        let indus616 = Industry(nace: "4", title: "Activités de banques de données", description: "", sectorID: 82, parentID: nil, scian: nil, citi: "4")
//         _ = indus616.save(on: connection).transform(to: ())
//
//        let indus617 = Industry(nace: "0", title: "Activités de banques de données", description: "", sectorID: 82, parentID: 616, scian: nil, citi: " nil")
//         _ = indus617.save(on: connection).transform(to: ())
//
//        let indus618 = Industry(nace: "5", title: "Entretien et réparation de machines de bureau et de matériel informatique", description: "", sectorID: 82, parentID: nil, scian: nil, citi: "5")
//         _ = indus618.save(on: connection).transform(to: ())
//
//        let indus619 = Industry(nace: "0", title: "Entretien et réparation de machines de bureau et de matériel informatique", description: "", sectorID: 82, parentID: 618, scian: nil, citi: nil)
//         _ = indus619.save(on: connection).transform(to: ())
//
//        let indus620 = Industry(nace: "6", title: "Autres activités rattachées à l'informatique", description: "", sectorID: 82, parentID: nil, scian: nil, citi: "9")
//         _ = indus620.save(on: connection).transform(to: ())
//
//        let indus621 = Industry(nace: "0", title: "Autres activités rattachées à l'informatique", description: "", sectorID: 82, parentID: 620, scian: nil, citi: nil)
//         _ = indus621.save(on: connection).transform(to: ())
//
//        let indus622 = Industry(nace: "1", title: "Recherche -développement en sciences physiques et naturelles", description: "", sectorID: 83, parentID: nil, scian: nil, citi: "1")
//         _ = indus622.save(on: connection).transform(to: ())
//
//        let indus623 = Industry(nace: "0", title: "Recherche -développement en sciences physiques et naturelles", description: "", sectorID: 83, parentID: 622, scian: nil, citi: nil)
//         _ = indus623.save(on: connection).transform(to: ())
//
//        let indus624 = Industry(nace: "2", title: "Recherche -développement en sciences humaines et sociales", description: "", sectorID: 83, parentID: nil, scian: nil, citi: "2")
//         _ = indus624.save(on: connection).transform(to: ())
//        let indus625 = Industry(nace: "0", title: "Recherche -développement en sciences humaines et sociales", description: "", sectorID: 83, parentID: 624, scian: nil, citi: nil)
//         _ = indus625.save(on: connection).transform(to: ())
//
//        let indus626 = Industry(nace: "1", title: "Activités juridiques, comptables et de conseil de gestion", description: "", sectorID: 84, parentID: nil, scian: nil, citi: "1")
//         _ = indus626.save(on: connection).transform(to: ())
//
//        let indus627 = Industry(nace: "1", title: "Activités juridiques", description: "", sectorID: 84, parentID: 656, scian: nil, citi: "1")
//         _ = indus627.save(on: connection).transform(to: ())
//
//        let indus628 = Industry(nace: "2", title: "Activités comptables", description: "", sectorID: 84, parentID: 656, scian: nil, citi: "2")
//         _ = indus628.save(on: connection).transform(to: ())
//
//        let indus629 = Industry(nace: "3", title: "Études de marché et sondages", description: "", sectorID: 84, parentID: 656, scian: nil, citi: "3")
//         _ = indus629.save(on: connection).transform(to: ())
//
//        let indus630 = Industry(nace: "4", title: "Conseil pour les affaires et la gestion", description: "", sectorID: 84, parentID: 656, scian: nil, citi: "4")
//         _ = indus630.save(on: connection).transform(to: ())
//        let indus631 = Industry(nace: "5", title: "Administration d'entreprises", description: "", sectorID: 84, parentID: 656,scian: nil, citi: nil)
//         _ = indus631.save(on: connection).transform(to: ())
//
//        let indus632 = Industry(nace: "2", title: " Activités d'architecture et d'ingénierie", description : "", sectorID: 84, parentID: nil,scian: nil, citi: "2")
//         _ = indus632.save(on: connection).transform(to: ())
//
//        let indus633 = Industry(nace: "0", title: "Activités d'architecture et d'ingénierie", description : "", sectorID: 84, parentID: 632,scian: nil, citi: nil)
//         _ = indus633.save(on: connection).transform(to: ())
//
//        let indus634 = Industry(nace: "3", title: "Activités de contrôle et analyses techniques", description: "", sectorID: 84, parentID: nil, scian: nil, citi: nil)
//         _ = indus634.save(on: connection).transform(to: ())
//
//        let indus635 = Industry(nace: "0", title: "Activités de contrôle et analyses techniques", description: "", sectorID: 84, parentID: 634, scian: nil, citi: "2")
//         _ = indus635.save(on: connection).transform(to: ())
//
//        let indus636 = Industry(nace: "4", title: "Publicité", description: "", sectorID: 84, parentID: nil, scian: nil, citi: "3")
//         _ = indus636.save(on: connection).transform(to: ())
//
//        let indus637 = Industry(nace: "0", title: "Publicité", description: "", sectorID: 84, parentID: 636, scian: nil, citi: nil)
//         _ = indus637.save(on: connection).transform(to: ())
//        let indus638 = Industry(nace: "5", title: "Sélection et fourniture de personnel", description: "", sectorID: 84, parentID: nil, scian: nil, citi: "9")
//         _ = indus638.save(on: connection).transform(to: ())
//
//        let indus639 = Industry(nace: "0", title: "Sélection et fourniture de personnel", description: "", sectorID: 84, parentID: 638, scian: nil, citi: "1")
//         _ = indus639.save(on: connection).transform(to: ())
//
//        let indus640 = Industry(nace: "6", title: "Enquêtes et sécurité", description: "", sectorID: 84, parentID: nil, scian: nil, citi: nil)
//         _ = indus640.save(on: connection).transform(to: ())
//
//        let indus641 = Industry(nace: "0", title: "Enquêtes et sécurité", description: "", sectorID: 84, parentID: 640, scian: nil, citi: "2")
//         _ = indus641.save(on: connection).transform(to: ())
//
//        let indus642 = Industry(nace: "7", title: "Activités de nettoyage", description: "", sectorID: 84, parentID: nil, scian: nil, citi: nil)
//         _ = indus642.save(on: connection).transform(to: ())
//
//        let indus643 = Industry(nace: "0", title: "Activités de nettoyage", description: "", sectorID: 84, parentID: 642, scian: nil, citi: "3")
//         _ = indus643.save(on: connection).transform(to: ())
//
//        let indus644 = Industry(nace: "8", title: "Services divers fournis principalement aux entreprises", description: "", sectorID: 84, parentID: nil, scian: nil, citi: nil)
//         _ = indus644.save(on: connection).transform(to: ())
//        let indus645 = Industry(nace: "1", title: "Activités photographiques", description: "", sectorID: 84, parentID: 644, scian: nil, citi: "4")
//         _ = indus645.save(on: connection).transform(to: ())
//
//        let indus646 = Industry(nace: "2", title: "Conditionnement à façon", description: "", sectorID: 84, parentID: 644, scian: nil, citi: "5")
//         _ = indus646.save(on: connection).transform(to: ())
//
//        let indus647 = Industry(nace: "5", title: "Secrétariat, traduction et routage", description: "", sectorID: 84, parentID: 644, scian: nil, citi: "9")
//         _ = indus647.save(on: connection).transform(to: ())
//
//        let indus648 = Industry(nace: "6", title: "Centres d'appel", description: "", sectorID: 84, parentID: 644, scian: nil, citi: nil)
//         _ = indus648.save(on: connection).transform(to: ())
//
//        let indus649 = Industry(nace: "7", title: "Autres services aux entreprises n.c.a.", description: "", sectorID: 84, parentID: 644, scian: nil, citi: nil)
//         _ = indus649.save(on: connection).transform(to: ())
//
//        let indus650 = Industry(nace: "1", title: "Administration générale, économique et sociale", description: "", sectorID: 87, parentID: nil, scian: nil, citi: "1")
//         _ = indus650.save(on: connection).transform(to: ())
//
//        let indus651 = Industry(nace: "1", title: "Administration publique générale", description: "", sectorID: 87, parentID: 650, scian: nil, citi: "1")
//         _ = indus651.save(on: connection).transform(to: ())
//        let indus652 = Industry(nace: "2", title: "Tutelle des activi tés sociales", description: "", sectorID: 87, parentID: 650, scian: nil, citi: "2")
//         _ = indus652.save(on: connection).transform(to: ())
//
//        let indus653 = Industry(nace: "0", title: "Tutelle des activités économiques", description: "", sectorID: 87, parentID: 650, scian: nil, citi: "3")
//         _ = indus653.save(on: connection).transform(to: ())
//
//        let indus654 = Industry(nace: "4", title: "Activités de soutien aux administrations", description: "", sectorID: 87, parentID: 650, scian: nil, citi: "4")
//         _ = indus654.save(on: connection).transform(to: ())
//
//        let indus655 = Industry(nace: "2", title: "Services de prérogative publique", description: "", sectorID: 87, parentID: nil, scian: nil, citi: "2")
//         _ = indus655.save(on: connection).transform(to: ())
//
//        let indus656 = Industry(nace: "1", title: "Affaires étrangères", description: "", sectorID: 87, parentID: 655, scian: nil, citi: "1")
//         _ = indus656.save(on: connection).transform(to: ())
//
//        let indus657 = Industry(nace: "2", title: "Défense", description: "", sectorID: 87, parentID: 655, scian: nil, citi: "2")
//         _ = indus657.save(on: connection).transform(to: ())
//        let indus658 = Industry(nace: "3", title: "Justice", description: "", sectorID: 87, parentID: 655, scian: nil, citi: "3")
//         _ = indus658.save(on: connection).transform(to: ())
//
//        let indus659 = Industry(nace: "4", title: "Police", description: "", sectorID: 87, parentID: 655, scian: nil, citi: nil)
//         _ = indus659.save(on: connection).transform(to: ())
//
//        let indus660 = Industry(nace: "5", title: "Protection civile", description: "", sectorID: 87, parentID: 655, scian: nil, citi: nil)
//         _ = indus660.save(on: connection).transform(to: ())
//
//        let indus661 = Industry(nace: "3", title: "Sécurité sociale obligatoire", description: "", sectorID: 87, parentID: nil, scian: nil, citi: "3")
//         _ = indus661.save(on: connection).transform(to: ())
//
//        let indus662 = Industry(nace: "0", title: "Sécurité sociale obligatoire", description: "", sectorID: 87, parentID: 661, scian: nil, citi: nil)
//         _ = indus662.save(on: connection).transform(to: ())
//
//        let indus663 = Industry(nace: "1", title: "Enseignement primaire", description: "", sectorID: 89, parentID: nil, scian: nil, citi: "1")
//         _ = indus663.save(on: connection).transform(to: ())
//
//        let indus664 = Industry(nace: "0", title: "Enseignement primaire", description: "", sectorID: 89, parentID: 663, scian: nil, citi: nil)
//         _ = indus664.save(on: connection).transform(to: ())
//        let indus665 = Industry(nace: "2", title: "Enseignement secondaire", description: "", sectorID: 89, parentID: nil, scian: nil, citi: "2")
//         _ = indus665.save(on: connection).transform(to: ())
//
//        let indus666 = Industry(nace: "1", title: "Enseignement secondaire général", description: "", sectorID: 89, parentID: 665, scian: nil, citi: "1")
//         _ = indus666.save(on: connection).transform(to: ())
//
//        let indus667 = Industry(nace: "2", title: "Enseignement secondaire technique ou professionnel", description: "", sectorID: 89, parentID: 665, scian: nil, citi: "2")
//         _ = indus667.save(on: connection).transform(to: ())
//
//        let indus668 = Industry(nace: "3", title: "Enseignement supérieur", description: "", sectorID: 89, parentID: nil, scian: nil, citi: "3")
//         _ = indus668.save(on: connection).transform(to: ())
//
//        let indus669 = Industry(nace: "0", title: "Enseignement supérieur", description: "", sectorID: 89, parentID: 668, scian: nil, citi: nil)
//         _ = indus669.save(on: connection).transform(to: ())
//
//        let indus670 = Industry(nace: "4", title: "Formation permanente et autres activités d'enseignement", description: "", sectorID: 89, parentID: nil, scian: nil, citi: "9")
//         _ = indus670.save(on: connection).transform(to: ())
//
//        let indus671 = Industry(nace: "1", title: "Écoles de conduite", description: "", sectorID: 89, parentID: 670, scian: nil, citi: nil)
//         _ = indus671.save(on: connection).transform(to: ())
//        let indus672 = Industry(nace: "2", title: "Formation permanente et enseignements divers", description: "", sectorID: 89, parentID: 670, scian: nil, citi: nil)
//         _ = indus672.save(on: connection).transform(to: ())
//
//        let indus673 = Industry(nace: "1", title: "Activités pour la santé humaine", description: "", sectorID: 91, parentID: nil, scian: nil, citi: "1")
//         _ = indus673.save(on: connection).transform(to: ())
//
//        let indus674 = Industry(nace: "1", title: "Activités hospitalières", description: "", sectorID: 91, parentID: 673, scian: nil, citi: "1")
//         _ = indus674.save(on: connection).transform(to: ())
//
//        let indus675 = Industry(nace: "2", title: "Pratique médicale", description: "", sectorID: 91, parentID: 673, scian: nil, citi: "2")
//         _ = indus675.save(on: connection).transform(to: ())
//
//        let indus676 = Industry(nace: "3", title: "Pratique dentaire", description: "", sectorID: 91, parentID: 673, scian: nil, citi: nil)
//         _ = indus676.save(on: connection).transform(to: ())
//
//        let indus677 = Industry(nace: "4", title: "Autres activités pour la santé humaine", description: "", sectorID: 91, parentID: 673, scian: nil, citi: "9")
//         _ = indus677.save(on: connection).transform(to: ())
//
//        let indus678 = Industry(nace: "2", title: "Activités vétérinaires", description: "", sectorID: 91, parentID: nil, scian: nil, citi: "2")
//         _ = indus678.save(on: connection).transform(to: ())
//        let indus679 = Industry(nace: "0", title: "Activités vétérinaires", description: "", sectorID: 91, parentID: 678, scian: nil, citi: nil)
//         _ = indus679.save(on: connection).transform(to: ())
//
//        let indus680 = Industry(nace: "3", title: "Action sociale", description: "", sectorID: 91, parentID: nil, scian: nil, citi: "3")
//         _ = indus680.save(on: connection).transform(to: ())
//
//        let indus681 = Industry(nace: "1", title: "Action sociale avec hébergement", description: "", sectorID: 91, parentID: 680, scian: nil, citi: "1")
//         _ = indus681.save(on: connection).transform(to: ())
//
//        let indus682 = Industry(nace: "2", title: "Action sociale sans hébergement", description: "", sectorID: 91, parentID: 680, scian: nil, citi: "2")
//         _ = indus682.save(on: connection).transform(to: ())
//
//        let indus683 = Industry(nace: "0", title: "Assainissement, voirie et gestion des déchets", description: "", sectorID: 94, parentID: nil, scian: nil, citi: nil)
//         _ = indus683.save(on: connection).transform(to: ())
//
//        let indus684 = Industry(nace: "1", title: "Collecte et traitement des autres déchets", description: "", sectorID: 94, parentID: 683, scian: nil, citi: nil)
//         _ = indus684.save(on: connection).transform(to: ())
//
//        let indus685 = Industry(nace: "2", title: "Collecte et traitement des autres déchets", description: "", sectorID: 94, parentID: 693, scian: nil, citi: nil)
//         _ = indus685.save(on: connection).transform(to: ())
//
//        let indus686 = Industry(nace: "3", title: "Autres travaux d’assainissement et de voirie", description: "", sectorID: 94, parentID: 693, scian: nil, citi: nil)
//         _ = indus686.save(on: connection).transform(to: ())
//
//        let indus687 = Industry(nace: "1", title: "Organisations économiques", description: "", sectorID: 95, parentID: nil, scian: nil, citi: "1")
//         _ = indus687.save(on: connection).transform(to: ())
//
//        let indus688 = Industry(nace: "1", title: "Organisations patronales et consulaires", description: "", sectorID: 95, parentID: 687, scian: nil, citi: "1")
//         _ = indus688.save(on: connection).transform(to: ())
//        let indus689 = Industry(nace: "2", title: "Organisations professionnelles", description: "", sectorID: 95, parentID: 687, scian: nil, citi: "2")
//         _ = indus689.save(on: connection).transform(to: ())
//
//        let indus690 = Industry(nace: "2", title: "Syndicats de salariés", description: "", sectorID: 95, parentID: nil, scian: nil, citi: "2")
//         _ = indus690.save(on: connection).transform(to: ())
//
//        let indus691 = Industry(nace: "0", title: "Syndicats de salariés", description: "", sectorID: 95, parentID: 690, scian: nil, citi: nil)
//         _ = indus691.save(on: connection).transform(to: ())
//
//        let indus692 = Industry(nace: "3", title: "Autres organisations associatives", description: "", sectorID: 95, parentID: nil, scian: nil, citi: "9")
//         _ = indus692.save(on: connection).transform(to: ())
//
//        let indus693 = Industry(nace: "1", title: "Organisations religieuses", description: "", sectorID: 95, parentID: 692, scian: nil, citi: "1")
//         _ = indus693.save(on: connection).transform(to: ())
//
//        let indus694 = Industry(nace: "2", title: "Organisations politiques", description: "", sectorID: 95, parentID: 692, scian: nil, citi: "2")
//         _ = indus694.save(on: connection).transform(to: ())
//
//        let indus695 = Industry(nace: "3", title: "Organisations associatives n.c.a.", description: "", sectorID: 95, parentID: 692, scian: nil, citi: "9")
//         _ = indus695.save(on: connection).transform(to: ())
//        let indus696 = Industry(nace: "1", title: "Activités cinématographiques et vidéo", description: "", sectorID: 96, parentID: nil, scian: nil, citi: "1")
//         _ = indus696.save(on: connection).transform(to: ())
//
//        let indus697 = Industry(nace: "1", title: "Production de films", description: "", sectorID: 96, parentID: 696, scian: nil, citi: "1")
//         _ = indus697.save(on: connection).transform(to: ())
//
//        let indus698 = Industry(nace: "2", title: "Distribution de films", description: "", sectorID: 96, parentID: 696, scian: nil, citi: nil)
//         _ = indus698.save(on: connection).transform(to: ())
//
//        let indus699 = Industry(nace: "3", title: "Projection de films cinématographiques", description: "", sectorID: 96, parentID: 696, scian: nil, citi: "2")
//         _ = indus699.save(on: connection).transform(to: ())
//
//        let indus700 = Industry(nace: "2", title: "Activités de radio et de télévision", description: "", sectorID: 96, parentID: nil, scian: nil, citi: nil)
//         _ = indus700.save(on: connection).transform(to: ())
//
//        let indus701 = Industry(nace: "0", title: "Activités de radio et de télévision", description: "", sectorID: 96, parentID: 700, scian: nil, citi: "3")
//         _ = indus701.save(on: connection).transform(to: ())
//        let indus702 = Industry(nace: "3", title: "Autres activités artistiques et de spectacle", description: "", sectorID: 96, parentID: nil, scian: nil, citi: nil)
//         _ = indus702.save(on: connection).transform(to: ())
//
//        let indus703 = Industry(nace: "1", title: "Art dramatique et musique ", description: "", sectorID: 96, parentID: 702, scian: nil, citi: "4")
//         _ = indus703.save(on: connection).transform(to: ())
//
//        let indus704 = Industry(nace: "2", title: "Gestion de salles de spectacle", description: "", sectorID: 96, parentID: 702, scian: nil, citi: nil)
//         _ = indus704.save(on: connection).transform(to: ())
//
//        let indus705 = Industry(nace: "3", title: "Manèges forains et parc d'attraction", description: "", sectorID: 96, parentID: 702, scian: nil, citi: "9")
//         _ = indus705.save(on: connection).transform(to: ())
//
//        let indus706 = Industry(nace: "4", title: "Activités divers es du spectacle", description: "", sectorID: 96, parentID: 702, scian: nil, citi: nil)
//         _ = indus706.save(on: connection).transform(to: ())
//
//        let indus707 = Industry(nace: "4", title: "Agences de presse", description: "", sectorID: 96, parentID: nil, scian: nil, citi: "2")
//         _ = indus707.save(on: connection).transform(to: ())
//
//        let indus708 = Industry(nace: "0", title: "Agences de presse", description: "", sectorID: 96, parentID: 707, scian: nil, citi: nil)
//         _ = indus708.save(on: connection).transform(to: ())
//        let indus709 = Industry(nace: "5", title: "Autres activités culturelles", description: "", sectorID: 96, parentID: nil, scian: nil, citi: "3")
//         _ = indus709.save(on: connection).transform(to: ())
//
//        let indus710 = Industry(nace: "1", title: "Gestion des bibliothèques", description: "", sectorID: 96, parentID: 709, scian: nil, citi: "1")
//         _ = indus710.save(on: connection).transform(to: ())
//
//        let indus711 = Industry(nace: "2", title: "Gestion du patrimoine culturel", description: "", sectorID: 96, parentID: 709, scian: nil, citi: "2")
//         _ = indus711.save(on: connection).transform(to: ())
//
//        let indus712 = Industry(nace: "3", title: "Gestion du patrimoine naturel", description: "", sectorID: 96, parentID: 709, scian: nil, citi: "3")
//         _ = indus712.save(on: connection).transform(to: ())
//
//        let indus713 = Industry(nace: "6", title: "Activités liées au sport", description: "", sectorID: 96, parentID: nil, scian: nil, citi: "3")
//         _ = indus713.save(on: connection).transform(to: ())
//
//        let indus714 = Industry(nace: "1", title: "Gestion d'installation sportives ", description: "", sectorID: 96, parentID: 713, scian: nil, citi: "1")
//         _ = indus714.save(on: connection).transform(to: ())
//
//        let indus715 = Industry(nace: "2", title: "Autres activités sportives", description: "", sectorID: 96, parentID: 713, scian: nil, citi: nil)
//         _ = indus715.save(on: connection).transform(to: ())
//        let indus716 = Industry(nace: "7", title: "Activités récréatives", description: "", sectorID: 96, parentID: nil, scian: nil, citi: nil)
//         _ = indus716.save(on: connection).transform(to: ())
//
//        let indus717 = Industry(nace: "1", title: "Jeux de hasard et d'argent", description: "", sectorID: 96, parentID: 716, scian: nil, citi: "9")
//         _ = indus717.save(on: connection).transform(to: ())
//
//        let indus718 = Industry(nace: "2", title: "Autres activités récréatives", description: "", sectorID: 96, parentID: 716, scian: nil, citi: nil)
//         _ = indus718.save(on: connection).transform(to: ())
//
//        let indus719 = Industry(nace: "0", title: "Services personnels", description: "", sectorID: 97, parentID: nil, scian: nil, citi: nil)
//         _ = indus719.save(on: connection).transform(to: ())
//
//        let indus720 = Industry(nace: "1", title: "Blanchisserie - teinturerie", description: "", sectorID: 97, parentID: 719, scian: nil, citi: "1")
//         _ = indus720.save(on: connection).transform(to: ())
//
//        let indus721 = Industry(nace: "2", title: "Coiffure et soins de beauté", description: "", sectorID: 97, parentID: 719, scian: nil, citi: "2")
//         _ = indus721.save(on: connection).transform(to: ())
//
//        let indus722 = Industry(nace: "3", title: "Services funéraires", description: "3", sectorID: 97, parentID: 719, scian: nil, citi: "")
//         _ = indus722.save(on: connection).transform(to: ())
//
//        let indus723 = Industry(nace: "4", title: "Entretien corporel", description: "", sectorID: 97, parentID: 719, scian: nil, citi: "4")
//         _ = indus723.save(on: connection).transform(to: ())
//
//        let indus724 = Industry(nace: "5", title: "Autres services personnels", description: "", sectorID: 97, parentID: 719, scian: nil, citi: nil)
//         _ = indus724.save(on: connection).transform(to: ())
//        let indus725 = Industry(nace: "0", title: "Activités des ménages en tant qu'employeur de personnel domestique", description: "", sectorID: 100, parentID: nil, scian: nil, citi: nil)
//         _ = indus725.save(on: connection).transform(to: ())
//
//        let indus726 = Industry(nace: "0", title: "Activités des ménages en tant qu'employeur de personnel domestique", description: "", sectorID: 100, parentID: 725, scian: nil, citi: nil)
//         _ = indus726.save(on: connection).transform(to: ())
//
//        let indus727 = Industry(nace: "0", title: "Activités indifférenciées des ménages en tant que producteurs de biens pour usage propre", description: "", sectorID: 101, parentID: nil, scian: nil, citi: nil)
//         _ = indus727.save(on: connection).transform(to: ())
//
//        let indus728 = Industry(nace: "0", title: "Activités indifférenciées des ménages en tant que producteurs de biens pour usage propre", description: "", sectorID: 101, parentID: 727, scian: nil, citi: nil)
//         _ = indus728.save(on: connection).transform(to: ())
//
//        let indus729 = Industry(nace: "0", title: "Activités indifférenciées des ménages en tant que producteurs de services pour usage propre", description: "", sectorID: 102, parentID: nil, scian: nil, citi: nil)
//         _ = indus729.save(on: connection).transform(to: ())
//
//        let indus730 = Industry(nace: "0", title: "Activités indifférenciées des ménages en tant que producteurs de services pour usage propre", description: "", sectorID: 102, parentID: 729, scian: nil, citi: nil)
//         _ = indus730.save(on: connection).transform(to: ())
//
//        let indus731 = Industry(nace: "0", title: "Activités extra-territoriales", description: "", sectorID: 103, parentID: nil, scian: nil, citi: nil)
//        _ = indus731.save(on: connection).transform(to: ())
//
//        let indus732 = Industry(nace: "0", title: "Activités extra-territoriales",
//                          description: "", sectorID: 103, parentID: 731,
//                          scian: nil, citi: " nil")
//        _ = indus732.save(on: connection).transform(to: ())
    
    return .done(on: connection)
  }
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    return .done(on: connection)
  }
}

