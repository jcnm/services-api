//
//  UserFeaturesController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 09/06/2020.
//

import Foundation
import Crypto
import Vapor
import Fluent
import FluentPostgreSQL
import Authentication
import CoreFoundation

/// - MARK - CREATE AND AUTHENTICATE USERS
public class UserFeaturesController {
  
  public init() { }
}

/// - MARK - EXTRA FEATRES USER
extension UserFeaturesController {
  
  
}

/// - MARK - USERS ROUTES
extension UserFeaturesController: RouteCollection {
  public func boot(router: Router) throws {
    /*************************** PUBLIC SECTION *************************
     ***
     *******************************************************************/
    /** Public user end point api spec */
    // Creation of a new user
        // bearer / token auth protected routes
    let bearer = router.grouped(User.tokenAuthMiddleware())
  }
  
  
}
