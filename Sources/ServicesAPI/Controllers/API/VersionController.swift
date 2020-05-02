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
public final class VersionController {
  
  public init() { }

  /// Creates a version.
  public func create(_ req: Request) throws -> Future<Version> {
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
              throw Abort(HTTPResponseStatus.custom(code: HTTPResponseStatus.badRequest.code, reasonPhrase: "Unable to create this Version Id:\(v.id) v\(v.major).\(v.minor).\(v.patch), it's already registerd."))
            } else {
              return vers.create(on: req)
            }
        }
    }
  }
  
  /// get a version.
  public func show(_ req: Request) throws -> Future<Version> {
    // decode request content
    return try req.parameters.next(Version.self).flatMap
      { vers -> Future<Version> in
        return req.future(vers)
    }
  }
  
  /// get a version.
  public func list(_ req: Request) throws -> Future<[Version]> {
    // decode request content
    return Version.query(on: req).all()
  }

}


/// - MARK - VERSIONS ROUTES
extension VersionController: RouteCollection {
  public func boot(router: Router) throws {
    /*************************** PUBLIC SECTION *************************
     ***
     *******************************************************************/
    /** Public user end point api spec */
    // Creation of a new version
    
    router.post(Config.APIWEP.versionsWEP, use: create)
    router.get(Config.APIWEP.versionsWEP, use: list)
    router.get(Config.APIWEP.versionsWEP, Version.parameter, use: show)
    
    //    let bearer = router.grouped(User.tokenAuthMiddleware())
    //    bearer.post(kVersionsBasePath, use: create)
    
  }
}

