//
//  ExistingService.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 30/03/2020.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

struct ExistingService: Migration {
  typealias Database = AdoptedDatabase
  
  static func prepare(on connection: AdoptedConnection) -> Future<Void> {
    
    let serv5 = Service(label: "Website CLient Services", billing: BillingPlan.direct, description: "Mise à disposition d'une interface client afin d'accéder à la plateforme de référencement de service inter-entreprise. Ce service est ouvert à tout individu physique gérant une activité professionnel assimilable à une offre de service.", industry: 644, price: 0.0, shortLabel: "Interface Services", organization: Config.Static.bbMainOrgID, author: Config.Static.bbMainUserID, state: .online, id: 5)
    serv5.intengibility     = 100
    serv5.pricing           = 990
    serv5.disponibility     = 900
    serv5.reliability       = 900
    serv5.ownership         = 1000
    serv5.reliability       = 900
    serv5.perishability     = 0
    serv5.inseparability    = 1000
    serv5.negotiable        = false
    serv5.nobillable        = true
    // 644
    let serv6 = Service(label: "Référencement de services pour indépendant", billing: BillingPlan.annual, description: "Offre de mise à disposition des services sur la plateforme pour les indépendants fournissant des prestations de service.", industry: 44, price: 99.90, shortLabel: "Service des indépendants", organization: Config.Static.bbMainOrgID, author: Config.Static.bbMainUserID, state: .online, id: 6)
    serv6.intengibility     = 100
    serv6.pricing           = 900
    serv6.disponibility     = 990
    serv6.reliability       = 900
    serv6.ownership         = 900
    serv6.reliability       = 1000
    serv6.perishability     = 0
    serv6.inseparability    = 1000
    serv6.negotiable        = false
    serv6.nobillable        = false
    
    let serv7 = Service(label: "Référencement de services pour TPME", billing: BillingPlan.annual, description: "Offre de mise à disposition des services sur la plateforme pour les très petite et moyenne entreprises fournissant des prestations de service.", industry: 44, price: 999.99, shortLabel: "Service des TPME", organization: Config.Static.bbMainOrgID, author: Config.Static.bbMainUserID, parent: 6, state: .online, id: 7)
    serv6.intengibility     = 100
    serv6.pricing           = 940
    serv6.disponibility     = 990
    serv6.reliability       = 900
    serv6.ownership         = 900
    serv6.reliability       = 1000
    serv6.perishability     = 165
    serv6.inseparability    = 1000
    serv6.negotiable        = false
    serv6.nobillable        = false
    
    let serv8 = Service(label: "Référencement de services pour entreprise", billing: BillingPlan.mensual, description: "Offre de mise à disposition des services sur la plateforme pour les grandes entreprises fournissant des prestations de service.", industry: 44, price: 99.99, shortLabel: "Service des entreprise", organization: Config.Static.bbMainOrgID, author: Config.Static.bbMainUserID, parent: 7, state: .online, id: 8)
    serv6.intengibility     = 100
    serv6.pricing           = 860
    serv6.disponibility     = 990
    serv6.reliability       = 900
    serv6.ownership         = 500
    serv6.reliability       = 1000
    serv6.perishability     = 350
    serv6.inseparability    = 1000
    serv6.negotiable        = false
    serv6.nobillable        = false
    
    let serv9 = Service(label: "Référencement de services pour grand groupe multinational", billing: BillingPlan.mensual, description: "Offre de mise à disposition des services sur la plateforme pour les grands groupes multinationaux fournissant des prestations de service.", industry: 44, price: 499.99, shortLabel: "Service des grands groupes", organization: Config.Static.bbMainOrgID, author: Config.Static.bbMainUserID, parent: 8, state: .online, id: 9)
    serv6.intengibility     = 100
    serv6.pricing           = 800
    serv6.disponibility     = 1000
    serv6.reliability       = 900
    serv6.ownership         = 200
    serv6.reliability       = 1000
    serv6.perishability     = 0
    serv6.inseparability    = 1000
    serv6.negotiable        = false
    serv6.nobillable        = false
    
    _ = serv5.create(on: connection).catch({ (e) in
      print("ERROR SERVICE 5 ----------")
      print(e)
    }).transform(to: ())
    _ = serv6.create(on: connection).catch({ (e) in
      print("ERROR SERVICE 6 ----------")
      print(e)
    }).transform(to: ())
    _ = serv7.create(on: connection).transform(to: ())
    _ = serv8.create(on: connection).transform(to: ())
    _ = serv9.create(on: connection).transform(to: ())

    return .done(on: connection)
  }
  
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    let _ = Service.query(on: connection).filter(\Service.id == 5).delete()
    let _ = Service.query(on: connection).filter(\Service.id == 6).delete()
    let _ = Service.query(on: connection).filter(\Service.id == 7).delete()
    let _ = Service.query(on: connection).filter(\Service.id == 8).delete()
    let _ = Service.query(on: connection).filter(\Service.id == 9).delete()
    return .done(on: connection)
  }
}

