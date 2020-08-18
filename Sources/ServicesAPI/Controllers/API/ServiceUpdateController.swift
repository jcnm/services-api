//
//  ServiceUpdateController.swift
//
//
//  Created by Jacques Charles NJANDA MBIADA on 14/07/2020.
//

import Foundation
import Vapor
import Fluent
import Authentication
//import SwifQL
//import SwifQLVapor

/// - MARK - UPDATE Service
extension ServiceController {
  
  public func update(_ req: Request) throws -> Future<Service> {
    let _ = try UserController.logged(req)
    
    return try req.parameters.next(Service.self).flatMap
      { serToUpdate -> Future<Service> in
        // decode request content
        return try req.content.decode(Service.self).flatMap
          { serv -> Future<Service> in
            // verify that the service is well sharped
            guard try serv.requireID() == serToUpdate.requireID() else {
              throw Abort(HTTPResponseStatus.badRequest)
            }
            
            serToUpdate.label         = serv.label
            serToUpdate.billing       = serv.billing
            serToUpdate.price         = serv.price
            serToUpdate.shortLabel    = serv.shortLabel
            serToUpdate.industryID    = serv.industryID
            serToUpdate.parentID      = serv.parentID
            serToUpdate.description   = serv.description
            serToUpdate.authorID      = serv.authorID
            serToUpdate.geoPerimeter  = serv.geoPerimeter
            serToUpdate.disponibility = serv.disponibility
            
            serToUpdate.updatedAt     = Date()
            
            return serToUpdate.updateOverload(on: req)
        }
    }
  }
}
