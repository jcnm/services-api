//
//  ExistingScore.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 30/03/2020.
//


import Foundation
import Vapor
import FluentPostgreSQL


struct ExistingScore: Migration {
  typealias Database = AdoptedDatabase
  
  static func prepare(on connection: AdoptedConnection) -> Future<Void> {
    
    let sc1 = Score(author: Config.Static.bbMainUserID, general: 230, service: 6, comment: "Chérie 🤐 j’ai dit avoir appelé pas que j’appelle depuis 😰😰😱", state: ObjectStatus.online)
    sc1.pricing = 800
    sc1.perishability = 300

    let sc2 = Score(author: Config.Static.bbMainUserID - 2, general: 730, service: 7, comment: " ❤️❤️ A.  Bon c’est pas fini 🤩🤩 😉 🔥🔥 J’ai appelé sur une fois makou iechhh", state: ObjectStatus.online)
    sc2.pricing = 560
    sc2.reliability = 200

    let sc3 = Score(author: Config.Static.bbMainUserID - 3, general: 730, service: 6, comment: "J’ai appelé sur une 😱😱 fois makou iechhh", state: ObjectStatus.online)
    sc3.pricing = 608
    sc3.reliability = 950

    let sc4 = Score(author: Config.Static.bbMainUserID, general: 930, service: 7, comment: "Man you should have asked for help 🤔😔", state: ObjectStatus.online)
    sc4.pricing = 880
    sc4.perishability = 510

    let sc5 = Score(author: 5, general: 630, service: 5, comment: "Longue, trop longue vacances D'accord bien reçu merci 🙂(l)", state: ObjectStatus.online)
    sc5.pricing = 480
    sc5.perishability = 680
    sc5.disponibility = 42
    let sc6 = Score(author: 3, general: 800, service: 5, comment: "S’il te plaît d’eux 😭😢😤😭😭😢😢😢😩😩😩😩", state: ObjectStatus.online)
    sc6.pricing = 780
    sc6.perishability = 260

    let sc7 = Score(author: Config.Static.bbMainUserID, general: 820, service: 7, comment: "Bonne année 2020 Nina 😘", state: ObjectStatus.online)
    sc7.pricing = 680
    sc7.perishability = 950

    _ = sc1.create(on: connection).catch({ (e) in
      print("ERROR User Organization 1 ----------")
      print(e)
    }).transform(to: ())
    _ = sc2.create(on: connection).catch({ (e) in
      print("ERROR User Organization 2 ----------")
      print(e)
    }).transform(to: ())
    _ = sc3.create(on: connection).transform(to: ())
    _ = sc4.create(on: connection).transform(to: ())
    _ = sc5.create(on: connection).transform(to: ())
    _ = sc6.create(on: connection).transform(to: ())
    _ = sc7.create(on: connection).transform(to: ())
    return .done(on: connection)
  }
  
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    _ = UserOrganization.query(on: connection).filter(\UserOrganization.id == 1).delete()
    _ = UserOrganization.query(on: connection).filter(\UserOrganization.id == 2).delete()
    _ = UserOrganization.query(on: connection).filter(\UserOrganization.id == 3).delete()
    return .done(on: connection)
  }
}

