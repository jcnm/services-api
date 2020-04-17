//
//  ExistingUser.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 30/03/2020.
//


import Foundation
import Vapor
import FluentPostgreSQL
import Authentication


struct ExistingUser: Migration {
  typealias Database = AdoptedDatabase
  
  static func prepare(on connection: AdoptedConnection) -> Future<Void> {
    let bbPwd: String
    if let pwd = Environment.get("SERVICE_BBUSER_PWD") {
      bbPwd = pwd
    } else {
      bbPwd = kDefaultBBUserPassword
    }
    do {
      let hash = try BCrypt.hash(bbPwd)
      let user7 = User(login: "jcnm", email: "jcnm@sylorion.com", passwordHash: hash, profile: 2, staff: .bbrother, state: .online, avatar: nil, id: Config.Static.bbMainUserID)
      let user9 = User(login: "jcharles", email: "jcnm@services.cm", passwordHash: hash, profile: 3, staff: .bbrother, state: .online, avatar: nil, id: Config.Static.bbMainUserID + 2)
      
      _ = user7.create(on: connection).catch({ (e) in
        print("ERROR User  \(Config.Static.bbMainUserID) ----------")
        print(e)
      }).transform(to: ())
      _ = user9.create(on: connection).catch({ (e) in
        print("ERROR User  \(Config.Static.bbMainUserID + 2) ----------")
        print(e)
      }).transform(to: ())
    } catch let e as CryptoError {
      let logger = PrintLogger()
      logger.info("Unable tu crete the seed user X salted password failed - \(e.identifier) : \(e.reason)")
      
    } catch let e {
      let logger = PrintLogger()
      logger.info("Unable tu crete the seed user - \(e)")
    }
    return .done(on: connection)
  }
  
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    _ = User.query(on: connection).filter(\User.id == Config.Static.bbMainUserID).delete()
    _ = User.query(on: connection).filter(\User.id == Config.Static.bbMainUserID + 2).delete()
    
    return .done(on: connection)
  }
}

