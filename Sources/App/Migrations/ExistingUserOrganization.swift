//
//  ExistingUserOrganization.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 30/03/2020.
//


import Foundation
import Vapor
import FluentPostgreSQL


struct ExistingUserOrganization: Migration {
  typealias Database = AdoptedDatabase
  
  static func prepare(on connection: AdoptedConnection) -> Future<Void> {

    let uo1 = UserOrganization(organization: Config.Static.bbMainOrgID - 10, user: Config.Static.bbMainUserID, role: RoleKind.ceo, id: 1)
    let uo2 = UserOrganization(organization: Config.Static.bbMainOrgID - 7, user: Config.Static.bbMainUserID, role: RoleKind.ceo, id: 2)
    let uo3 = UserOrganization(organization: Config.Static.bbMainOrgID, user: Config.Static.bbMainUserID, role: RoleKind.ceo, id: 3)

    _ = uo1.create(on: connection).catch({ (e) in
      print("ERROR User Organization 1 ----------")
      print(e)
    }).transform(to: ())
    _ = uo2.create(on: connection).catch({ (e) in
      print("ERROR User Organization 2 ----------")
      print(e)
    }).transform(to: ())
    _ = uo3.create(on: connection).transform(to: ())
    return .done(on: connection)
  }
  
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    _ = UserOrganization.query(on: connection).filter(\UserOrganization.id == 1).delete()
    _ = UserOrganization.query(on: connection).filter(\UserOrganization.id == 2).delete()
    _ = UserOrganization.query(on: connection).filter(\UserOrganization.id == 3).delete()
    return .done(on: connection)
  }
}

