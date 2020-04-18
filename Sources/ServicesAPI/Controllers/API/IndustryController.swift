//
//  IndustryController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 14/11/2019.
//

import Foundation
import Vapor
import Fluent
import Authentication
import CoreFoundation
import Paginator

/// - MARK - CREATE Industry
public final class IndustryController {
  
  public static func checkAttributs(_ indus: Industrial) throws -> Bool {
    
    if let citi = indus.citi {
      // verify that nace and nace has between 1 up to 6 characters max
      guard !citi.isEmpty && 1...6 ~= citi.count else {
        throw Abort(.badRequest, reason: "CITI code should be filled with 1 to 6 characters.")
      }
    }
    
    if let scian = indus.scian {
      // verify that scian has  between 1 up to 6 characters max
      guard !scian.isEmpty && 1...6 ~= scian.count else {
        throw Abort(.badRequest, reason: "SCIAN code should be filled with 1 to 6 characters.")
      }
    }
    
    // verify that nace and nace has  between 1 up to 8 characters max
    guard !indus.nace.isEmpty && 1...8 ~= indus.nace.count else {
      throw Abort(.badRequest, reason: "NACE code should be filled with 1 to 8 characters.")
    }
    
    // verify that nace has 2 characters max
    guard !indus.title.isEmpty && !indus.description.isEmpty else {
      throw Abort(.badRequest, reason: "Title or description cannot be empties.")
    }
    
    // verify that nace and nace has 2 characters max
    guard indus.description.count > 16 else {
      throw Abort(.badRequest, reason: "Fill description with at less 16 characters.")
    }
    
    return true
  }
  
  public func create(_ req: Request) throws -> Future<Industry> {
    let _ = try UserController.logged(req)
    
    // decode request content
    return try req.content.decode(Industry.self).flatMap
      { (indus: Industry) -> Future<Industry> in
        
        // verify that the sector is well sharped
        guard try IndustryController.checkAttributs(indus) else {
          fatalError("Should never be executed, since condition throws or succed")
        }
        return Industry(nace: indus.nace, title: indus.title, description: indus.description, sectorID: indus.sectorID , parentID: indus.parentID, scian: indus.scian, citi: indus.citi).create(on: req)
    }
  }
  
}

/// - MARK - UPDATE Industry
extension IndustryController {
  
  public func update(_ req: Request) throws -> Future<Industry> {
    let _ = try UserController.logged(req)
    
    return try req.parameters.next(Industry.self).flatMap
      { indusToUpdate -> Future<Industry> in
        // decode request content
        return try req.content.decode(Industry.self).flatMap
          { (indus: Industry) -> Future<Industry> in
            // verify that the industry is well sharped
            guard try IndustryController.checkAttributs(indus) else {
              throw Abort(HTTPResponseStatus.badRequest)
            }
            let logger = try req.make(Logger.self)
            
            if let parent = indus.parentID {
              indusToUpdate.parentID  = parent
              logger.info("\(String(describing: indusToUpdate.id)) - got parent updated to \"\(String(describing: indusToUpdate.parentID))\"")
            }
            indusToUpdate.sectorID  = indus.sectorID
            indusToUpdate.title   = indus.title
            indusToUpdate.citi    = indus.citi
            indusToUpdate.nace    = indus.nace
            indusToUpdate.scian   = indus.scian
            indusToUpdate.description = indus.description
            indusToUpdate.updatedAt   = Date()
            return indusToUpdate.update(on: req)
        }
    }
  }
}

/// - MARK - GET  Industry
extension IndustryController {
  
  /**
   *
   */
  public func show(_ req: Request) throws -> Future<Industry.ShortPublicResponse> {
    let _ = try UserController.logged(req)
    return try req.parameters.next(Industry.self).flatMap
      { industry -> Future<Industry.ShortPublicResponse> in
        return req.future(industry.response())
    }
  }
  
  /**
   *
   */
  public func sectorOfIndustry(_ req: Request) throws -> Future<Sector> {
    
    let _ = try UserController.logged(req)
    return try req.parameters.next(Industry.self).flatMap
      { indus -> Future<Sector> in
        guard try indus.requireID() != 0 else {
          throw Abort(HTTPResponseStatus.badRequest)
        }
        return indus.sector.get(on: req)
    }
  }
  
  /**
   *
   */
  public func list(_ req: Request) throws -> Future<OffsetPaginator<Industry>> {
    let _ = try UserController.logged(req)
    
    let filter = Industry.query(on: req)
    return try filter.paginate(for: req, type: OffsetPaginator<Industry>.self)
  }
  
}


/// - MARK - DELETE Industry
extension IndustryController {
  /**
   *
   */
  public func delete(_ req: Request) throws -> Future<Industry> {
    let _ = try UserController.logged(req)
    // decode request parameter
    return try req.parameters.next(Industry.self).flatMap
      { indusToUpdate -> Future<Industry> in
        guard try IndustryController.checkAttributs(indusToUpdate) else {
          fatalError("This industry has bad properties definition")
        }
        indusToUpdate.deletedAt   = Date()
        // TODO Update historic trace
        return indusToUpdate.update(on: req)
    }
  }
}
