//
//  UserUpdateController.swift
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
public class UserUpdateController {
  
  public init() { }
    
}

/// - MARK - USER UPDATE CONTROLLER
extension UserUpdateController {
  
  /// Update an user using User.Update
  public func updateUser(_ req: Request) throws -> Future<User.ShortPublicResponse> {
    // decode request parameter (u/:id)
    return try req.parameters.next(User.self).flatMap
      { uToUpdate -> Future<User.ShortPublicResponse> in
        let _ = try UserController.same(user: uToUpdate, for: req)
        
        return try req.content.decode(User.Update.self).flatMap({ (uRequest) -> Future<User.ShortPublicResponse> in
          guard try uRequest.id == uToUpdate.requireID() else {
            throw Abort(HTTPResponseStatus.forbidden)
          }
          if let log = uRequest.login {
            uToUpdate.login = log
            print("Login updated to \(log)")
          }
          if let uk = uRequest.staff {
            uToUpdate.staff = uk
            print("User kind updated to \(uk)")
          }
          if let state = uRequest.state {
            uToUpdate.state = state
            print("User state updated to \(state)")
          }
          
          // ...ALTER TABLE user ADD avatar TEXT;
          if let img = uRequest.avatar {
            try self.savePicture(img, for: uToUpdate)
          }
          return uToUpdate.save(on: req).flatMap({ req.future($0.shortResponse()) })
        })
        
    }
  }
  
  /// Update an user using User.Update details on user mains
  public func updateDetails(_ req: Request) throws -> Future<User.ShortPublicResponse> {
    // decode request parameter (u/:id)
    let userAuth = try UserController.logged(req)
    return try req.content.decode(User.Update.self).flatMap({ (uRequest) -> EventLoopFuture<User.ShortPublicResponse> in
      guard try uRequest.id == userAuth.requireID() else {
        throw Abort(HTTPResponseStatus.forbidden)
      }
      if let log = uRequest.login {
        userAuth.login = log
        print("Login updated to \(log)")
      }
      if let uk = uRequest.staff {
        userAuth.staff = uk
        print("User kind updated to \(uk)")
      }
      if let state = uRequest.state {
        userAuth.state = state
        print("User state updated to \(state)")
      }
      
      // ...ALTER TABLE user ADD avatar TEXT;
      if let img = uRequest.avatar {
        try self.savePicture(img, for: userAuth)
      }
      return userAuth.save(on: req).flatMap({ req.future($0.shortResponse()) })
    })
  }
  
  /// Update an user profile using the User.Update struct
  /// Can update the avatar image and other in one shot
  public func updateProfile(_ req: Request) throws -> Future<User.ShortPublicResponse> {
    // decode request parameter (u/:id)
    let userAuth = try UserController.logged(req)
    return try req.content.decode(User.Update.self)
      .flatMap({ (uRequest) -> EventLoopFuture<User.ShortPublicResponse> in
      guard try uRequest.id == userAuth.requireID() else {
        throw Abort(HTTPResponseStatus.forbidden)
      }
      if let log = uRequest.login {
        userAuth.login = log
        print("Login updated to \(log)")
      }
      if let uk = uRequest.staff {
        userAuth.staff = uk
        print("User kind updated to \(uk)")
      }
      if let state = uRequest.state {
        userAuth.state = state
        print("User state updated to \(state)")
      }
      
      // ...ALTER TABLE user ADD avatar TEXT;
      if let img = uRequest.avatar {
        try self.savePicture(img, for: userAuth)
      }
      return userAuth.save(on: req).flatMap({ req.future($0.shortResponse()) })
    })
  }
  
  private func savePicture(_ img: File, for user: User) throws {
    let home:URL = URL(fileURLWithPath: Config.rootUpdloadedFiles, isDirectory: true)
    let subLoggedUserPath = user.ref + Config.APIWEP.profilePictureWEP
    var path =
      home.appendingPathComponent(Config.rootUpdloadedImagesFiles, isDirectory: true)
        .appendingPathComponent(subLoggedUserPath, isDirectory: true)
    path.appendPathComponent(img.filename.hash.description + "_" + img.filename + "." + (img.ext ?? ".png"), isDirectory: false)
    // TODO Catch
    try FileManager.default.createDirectory(at: path.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
    // TODO Catch
    try img.data.write(to: path) // save picture on disk
    user.avatar = path.absoluteString // save picture on user
  }
  
  /// Update User's Profile Picture
  public func updateProfilePicture(_ req: Vapor.Request) throws -> Future<User.ShortPublicResponse>  {
    // fetch auth'd user
    let userAuth = try req.requireAuthenticated(User.self)
    
      return try req.content.decode(User.Update.self)
        .flatMap{ (uRequest) in
        guard try uRequest.id == userAuth.requireID() else {
          throw Abort(HTTPResponseStatus.forbidden)
        }
        if let img = uRequest.avatar {
          try self.savePicture(img, for: userAuth)
          return userAuth.save(on: req)
            .map({ $0.shortResponse() })
        } else {
          throw Abort(HTTPResponseStatus.notAcceptable)
        }
      }
  }
  
  /// Update my logins informations.
  public func updateLogins(_ req: Request) throws -> Future<User.FullPublicResponse> {
    // fetch auth'd user
    let _ = try req.requireAuthenticated(User.self)
    throw Abort(HTTPResponseStatus.notImplemented)
  }
  
  
  /// Delete the given user.
  public func delete(_ req: Request) throws -> Future<User.FullPublicResponse> {
    // fetch auth'd user
    let _ = try req.requireAuthenticated(User.self)
    throw Abort(HTTPResponseStatus.notImplemented)
  }
  

}

/// - MARK - USERS ROUTES
extension UserUpdateController: RouteCollection {
  public func boot(router: Router) throws {

    // bearer / token auth protected routes
    let bearer = router.grouped(User.tokenAuthMiddleware())
    
    /**
     ** Logged User end point api spec - 1
     */
    let accoundGroup = bearer.grouped(Config.APIWEP.accountWEP)
    accoundGroup.delete(use: delete(_:))
    accoundGroup.post(use: updateDetails(_:)) // update my personnal informations
    accoundGroup.post(use: updateLogins(_:)) // update my personnal logins information
    accoundGroup.post(use: updateProfile(_:)) // update my personnal logins information
    accoundGroup.post(use: updateProfilePicture(_:)) // update my personnal logins information

    accoundGroup.delete(use: delete(_:)) // delete my account
  }
  
  
}
