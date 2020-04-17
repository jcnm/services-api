//
//  VersionController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 23/11/2019.
//

import Foundation
import Crypto
import Vapor
import Fluent
import Authentication

/// - MARK - CREATE AND GET VERSION(S)
final class VersionController {
  
  /// Creates a version.
  func create(_ req: Request) throws -> Future<Version> {
    // decode request content
    return try req.content.decode(Version.self).flatMap
      { vers -> Future<Version> in
        return Version.query(on: req)
          .filter(\.major == vers.major)
          .filter(\.minor == vers.minor)
          .filter(\.release == vers.release)
          .filter(\.module == vers.module)
          .filter(\.patch == vers.patch)
          .first().flatMap { (vBase) -> EventLoopFuture<Version> in
            if let v = vBase {
              return v.create(on: req)
            } else {
              throw Abort(HTTPResponseStatus.custom(code: HTTPResponseStatus.badRequest.code, reasonPhrase: "Unable to create this Version."))
            }
        }
    }
  }
  
  /// get a version.
  func show(_ req: Request) throws -> Future<Version> {
    // decode request content
    return try req.parameters.next(Version.self).flatMap
      { vers -> Future<Version> in
        return req.future(vers)
    }
  }
  
  /// get a version.
  func list(_ req: Request) throws -> Future<[Version]> {
    // decode request content
    return Version.query(on: req).all()
  }

}


/// - MARK - VERSIONS ROUTES
extension VersionController: RouteCollection {
  func boot(router: Router) throws {
    /*************************** PUBLIC SECTION *************************
     ***
     *******************************************************************/
    /** Public user end point api spec */
    // Creation of a new version
    
    router.post(kVersionsBasePath, use: create)
    router.get(kVersionsBasePath, use: list)
    router.get(kVersionsBasePath, Version.parameter, use: show)
    
    //    let bearer = router.grouped(User.tokenAuthMiddleware())
    //    bearer.post(kVersionsBasePath, use: create)
    
  }
}


struct SeedVersion: Migration {
  typealias Database = AdoptedDatabase
  
  static func prepare(on connection: AdoptedConnection) -> Future<Void> {
    let vers = Version(module: "Services API V1", major: 0, minor: 1, patch: 0, build: 2, release: "Alpha-Alpla")
    let vers1 = Version(module: "Services API V1", major: 0, minor: 1, patch: 0, build: 4, release: "Alpha-Alpla")
    let vers2 = Version(module: "Services API V1", major: 0, minor: 1, patch: 0, build: 1, release: "Alpha")
    
    _ = vers.save(on: connection).transform(to: ())
    _ = vers1.save(on: connection).transform(to: ())
    return vers2.save(on: connection).transform(to: ())
  }
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    return .done(on: connection)
  }
}

