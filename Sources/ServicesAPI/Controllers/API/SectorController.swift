//
//  SectorController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 12/11/2019.
//

import Foundation
import Vapor
import Fluent
import Authentication

/// - MARK - CREATE Sector
public final class SectorController {
  
  public func create(_ req: Request) throws -> Future<Sector> {
    let _ = try UserController.logged(req)
    
    // decode request content
    return try req.content.decode(Sector.self).flatMap
      { sect -> Future<Sector> in
        
        // verify that the sector is well sharped
        guard try IndustryController.checkAttributs(sect) else {
          throw Abort(HTTPResponseStatus.badRequest)
        }
        let sec = Sector(nace: sect.nace, title: sect.title, description: sect.description, kind: sect.skind.skind, scian: sect.scian, citi: sect.citi)
          
          return sec.create(on: req)
    }
  }
  
}

/// - MARK - UPDATE Sector
extension SectorController {
  
  public func update(_ req: Request) throws -> Future<Sector> {
    let _ = try UserController.logged(req)
    
    return try req.parameters.next(Sector.self).flatMap
      { secToUpdate -> Future<Sector> in
        // decode request content
        return try req.content.decode(Sector.self).flatMap
          { (sect: Sector) -> Future<Sector> in
            // verify that the sector is well sharped
            guard try IndustryController.checkAttributs(sect) && sect.id == secToUpdate.id else {
              throw Abort(HTTPResponseStatus.badRequest)
            }
            
            secToUpdate.skind = sect.skind
            secToUpdate.title = sect.title
            secToUpdate.citi = sect.citi
            secToUpdate.scian = sect.scian
            secToUpdate.nace = sect.nace
            secToUpdate.description = sect.description
            secToUpdate.updatedAt = Date()
            
            return secToUpdate.update(on: req)
        }
    }
  }
}

/// - MARK - GET  Sector
extension SectorController {
  
  public func show(_ req: Request) throws -> Future<Sector> {
    let _ = try UserController.logged(req)
    return try req.parameters.next(Sector.self).flatMap
      { sector -> Future<Sector> in
        return req.future(sector)
    }
  }
  
  public func industriesOfSector(_ req: Request) throws -> Future<[Industry]> {
    
    let _ = try UserController.logged(req)
    return try req.parameters.next(Sector.self).flatMap
      { sect -> Future<[Industry]> in
        var filter = FilterNavigation<Industry>()
        return try filter.apply(sect.industries.query(on: req), from: req)
          .all()
    }
  }

  public func list(_ req: Request) throws -> Future<[Sector]> {
    let _ = try UserController.logged(req)
    
    var filter = FilterNavigation<Sector>()
    return filter.apply(Sector.query(on: req), from: req).all()
  }
  
}


/// - MARK - DELETE Sector
extension SectorController {
  public func delete(_ req: Request) throws -> Future<Sector> {
    let _ = try UserController.logged(req)
    // decode request parameter
    return try req.parameters.next(Sector.self).flatMap
      { secToUpdate -> Future<Sector> in
        guard try IndustryController.checkAttributs(secToUpdate) else {
          throw Abort(HTTPResponseStatus.badRequest)
        }
        secToUpdate.deletedAt   = Date()
        // TODO Update historic trace
        return secToUpdate.update(on: req)
    }
  }
}

extension SectorController: RouteCollection {
  public func boot(router: Router) throws {
      
    /*************************** LOGGED USER SECTION *******************
     ***
     ***
     ***
     *******************************************************************/
    
    // bearer / token auth protected routes
    let bearer = router.grouped(User.tokenAuthMiddleware())
    
    /**
     ** Logged User activity Sector - 2
     */
    let sectorGroup      = bearer.grouped(kSectorsBasePath)
    sectorGroup.get(use: list)
    sectorGroup.get(Sector.parameter, kIndustriesBasePath, use: industriesOfSector)
    sectorGroup.post(use: create)
    sectorGroup.get(Sector.parameter, use: show)
    sectorGroup.patch(Sector.parameter, use: update)
  }
  
  
}
