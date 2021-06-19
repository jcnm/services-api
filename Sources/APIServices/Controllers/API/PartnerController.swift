//
//  PartnerController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 01/05/2020.
//

import Foundation
import Crypto
import Vapor
import Fluent
import FluentSQL
import Authentication

/// - MARK - CREATE AND GET Partner(S)
public final class PartnerController {
  
  public init() { }
  
  /// Creates a version.
  public func create(_ req: Request) throws -> Future<Partner> {
    // decode request content
    return try req.content.decode(Partner.self).flatMap
      { part -> Future<Partner> in
        return Partner.query(on: req)
          .filter(\.bearerToken == part.bearerToken)
          .filter(\.name == part.name)
          .filter(\.mainUrl == part.mainUrl )
          .filter(\.referedAppName == part.referedAppName)
          .first().flatMap { (pBase) -> EventLoopFuture<Partner> in
            if let p = pBase {
              throw Abort(HTTPResponseStatus.custom(code: HTTPResponseStatus.badRequest.code, reasonPhrase: "Unable to create this Partner ID: \(String(describing: p.id)) \(p.name). It's already registered."))
            } else {
              return part.create(on: req)
            }
        }
    }
  }
  
  /// get a version.
  public func show(_ req: Request) throws -> Future<Partner> {
    // decode request content
    return try req.parameters.next(Partner.self).flatMap
      { part -> Future<Partner> in
        return req.future(part)
    }
  }
  
  /// get a version.
  public func update(_ req: Request) throws -> Future<Version> {
    // decode request content
    return try req.parameters.next(Version.self).flatMap
      { vers -> Future<Version> in
        return req.future(vers)
    }
  }
  
  /// get a version.
  public func delete(_ req: Request) throws -> Future<Partner> {
    // decode request content
    return try req.parameters.next(Partner.self).flatMap
      { vers -> Future<Partner> in
        return req.future(vers)
    }
  }
  
  /// get a version.
  public func list(_ req: Request) throws -> Future<[Partner]> {
    // decode request content
    return Partner.query(on: req).all()
  }
  
  /// get a version.
  public func search(_ req: Request, _ q: String? = nil) -> Future<Partner?> {
    var qStr: String = ""
    qStr = q ?? ""
    if let partStr = try? req.query.get(String.self, at: Config.SearchEngine.paramsPartnerQuery) {
      qStr = partStr
    }
    print("String quering : \(qStr)")
    if qStr.isEmpty {
      return req.future(nil)
    }
    print("Searching a partner for : \(qStr)")
    let part = Partner.query(on: req)
      .group(.or) {
        $0.filter(\.name, .equal,               qStr)
          .filter(\.ref,  .ilike,               qStr) }
      .group(.or) {
        $0.filter(\.deletedAt, .equal,          nil)
          .filter(\.deletedAt, .greaterThan,  Date()) }
//    .range(lower: 0, upper: 1)
    // decode request content
    return part.first()
  }
}

/// - MARK - GET  Relative to Partener
extension OrganizationController {
  
 
}


/// - MARK - Partner ROUTES
extension PartnerController: RouteCollection {
  public func boot(router: Router) throws {
    /*************************** PUBLIC SECTION *************************
     ***
     *******************************************************************/
    /** Public partner end point api spec */
    // Creation of a new Partner
    let bearer                = router.grouped(User.tokenAuthMiddleware())
    let partnerRoute          = bearer.grouped(Config.APIWEP.partnersWEP)
    partnerRoute.post(use: create)
    partnerRoute.get(use: list)
    partnerRoute.get(Partner.parameter, use: show)
    partnerRoute.post(String.parameter, use: show)
    // Organization SIRET
    partnerRoute.get(Config.APIWEP.partnersWEP, String.parameter, use: list)

  }
}

