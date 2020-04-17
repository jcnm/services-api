//
//  ExistingOrganization.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 30/03/2020.
//


import Foundation
import Vapor
import FluentPostgreSQL


struct ExistingOrganization: Migration {
  typealias Database = AdoptedDatabase
  
  static func prepare(on connection: AdoptedConnection) -> Future<Void> {

    let org1 = Organization(label: "Sylorion SAS", slogan: "Opus cum pietate et ardore", description: "Sylorion est spécialisée dans la prestation de service dans le domaine des technologies de l'information, du manageriat, finance et du sécrétariat. Elle est la société éditrice de <strong>services</strong>, la plate forme en ligne qui permet de mettre en relation les sociétés de prestation de service.", sector: 84, kind: OrganizationKind.pureprofit, money: "EUR", state: ObjectStatus.await, parent: nil, shortLabel: "Sylorion", id: Config.Static.bbMainOrgID - 10)

    let org2 = Organization(label: "Sylorion African Union", slogan: "Opus cum pietate et ardore", description: "Filliale pour la région afrique sub-sahareenne de Sylorion.", sector: 84, kind: OrganizationKind.pureprofit, money: "XAF", state: ObjectStatus.defaultValue, parent: Config.Static.bbMainOrgID - 10, shortLabel: "Sylorion AU", id: Config.Static.bbMainOrgID - 7)
    
    let org4 = Organization(label: "Sylorion Europeen Union", slogan: "Opus cum pietate et ardore", description: "Filliale pour la région de l'union européen de Sylorion Inc.", sector: 84, kind: OrganizationKind.pureprofit, money: "XAF", state: ObjectStatus.defaultValue, parent: Config.Static.bbMainOrgID - 10, shortLabel: "Sylorion EU", id: Config.Static.bbMainOrgID - 6)

    let org3 = Organization(label: "Services SAS", slogan: "Accelerated certified oaths", description: "Services est une organisation qui permet de mettre en relation des entreprises entres elles à travers les services rendus. C'est une plateforme de mise en relation et d'accélération de contractualisation de service B2B B2C.", sector: 84, kind: OrganizationKind.pureprofit, money: "EUR", state: ObjectStatus.online, parent: Config.Static.bbMainOrgID - 10, shortLabel: "Services", id: Config.Static.bbMainOrgID)

    _ = org1.create(on: connection).transform(to: ())
    _ = org2.create(on: connection).transform(to: ())
    _ = org3.create(on: connection).transform(to: ())
    _ = org4.create(on: connection).transform(to: ())

    return .done(on: connection)
  }
  
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    _ = Organization.query(on: connection).filter(\Organization.id == Config.Static.bbMainOrgID - 10).delete()
    _ = Organization.query(on: connection).filter(\Organization.id == Config.Static.bbMainOrgID - 7).delete()
    _ = Organization.query(on: connection).filter(\Organization.id == Config.Static.bbMainOrgID - 6).delete()
    _ = Organization.query(on: connection).filter(\Organization.id == Config.Static.bbMainOrgID).delete()
    return .done(on: connection)
  }
}

