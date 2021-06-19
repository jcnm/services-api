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

/// - MARK - USER UPDATE CONTROLLER
extension UserController {
  /// Update an user using User.Update
  public func updateUser(_ req: Request) throws -> Future<User.ShortPublicResponse> {
    // decode request parameter (u/:id)
    return try req.parameters.next(User.self).flatMap
      { uToUpdate -> Future<User.ShortPublicResponse> in
        let _ = try UserController.authUserIs(user: uToUpdate, for: req)
        
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
            try self.setAndSavePicture(img, for: uToUpdate)
          }
          return uToUpdate.save(on: req).flatMap({ req.future($0.shortResponse()) })
        })
    }
  }
  
  /// Update an user using User.Update details on user mains
  public func updateDetailsAPI(_ req: Request)
    throws -> Future<User.ShortPublicResponse> {
      // decode request parameter (u/:id)
      let userAuth = try UserController.logged(req)
      return try updateDetails(req, for: userAuth)
  }
  
  /// Update an user using User.Update details on user mains
  public func updateDetails(_ req: Request, for designedUser: User)
    throws -> Future<User.ShortPublicResponse> {
      
      return try req.content.decode(User.Update.self)
        .flatMap { (uRequest) -> EventLoopFuture<User.ShortPublicResponse> in
          guard try uRequest.id == designedUser.requireID() else {
            throw Abort(HTTPResponseStatus.forbidden)
          }
          // Check details of the user
          if let log = uRequest.login {
            designedUser.login = log
            print("Login updated to \(log)")
          }
          
          if let uk = uRequest.staff {
            designedUser.staff = uk
            print("User kind updated to \(uk)")
          }
          if let state = uRequest.state {
            designedUser.state = state
            print("User state updated to \(state)")
          }
          
          // ...ALTER TABLE user ADD avatar TEXT;
          if let img = uRequest.avatar {
            try self.setAndSavePicture(img, for: designedUser)
          }
          return designedUser.save(on: req).flatMap({ req.future($0.shortResponse()) })
      }
  }
  
  /// Updating an user profile using the User.Update struct
  /// Can update the avatar image and other in one shot
  public func updateProfileAPI(_ req: Request) throws -> Future<User.ShortPublicResponse> {
    // decode request parameter (u/:id)
    let userAuth = try UserController.logged(req)
    return try updateProfile(req, for: userAuth)
  }
  
  public func updateProfile(_ req: Request, for designedUser: User)
    throws -> Future<User.ShortPublicResponse> {
      // decode request parameter (u/:id)
      let userAuth = try UserController.logged(req)
      return try req.content.decode(User.Update.self)
        .flatMap({ (uRequest) -> EventLoopFuture<User.ShortPublicResponse> in
          guard try uRequest.id == userAuth.requireID() else {
            throw Abort(HTTPResponseStatus.forbidden)
          }
          return designedUser.profile.get(on: req)
            .flatMap { (profile) -> Future<User.ShortPublicResponse>in
              // ...ALTER TABLE user ADD avatar TEXT;
              if let img = uRequest.avatar {
                try self.setAndSavePicture(img, for: designedUser)
              }
              if let family = uRequest.familyName {
                profile.familyName = family
              }
              if let given = uRequest.givenName {
                profile.givenName = given
              }
              if let suffix = uRequest.nameSuffix {
                profile.nameSuffix = suffix
              }
              if let middle = uRequest.middleName {
                profile.middleName = middle
              }
              if let nickname = uRequest.nickname {
                profile.nickname = nickname
              }
              if let prefix = uRequest.namePrefix {
                profile.namePrefix = prefix
              }
              if let jobTitle = uRequest.jobTitle {
                profile.jobTitle = jobTitle
              }
              if let previousfn = uRequest.previousFamilyName {
                profile.previousFamilyName = previousfn
              }
              if let departmentName = uRequest.departmentName {
                profile.departmentName = departmentName
              }
              if let note = uRequest.note {
                profile.note = note
              }
              return userAuth.save(on: req).flatMap({ req.future($0.shortResponse()) })
          }
        })
  }
  
  private func setAndSavePicture(_ img: File, for designedUser: User) throws {
    let home:URL = URL(fileURLWithPath: Config.rootUpdloadedFiles, isDirectory: true)
    let subLoggedUserPath = designedUser.ref + Config.APIWEP.profilePictureWEP
    var path =
      home.appendingPathComponent(Config.rootUpdloadedImagesFiles, isDirectory: true)
        .appendingPathComponent(subLoggedUserPath, isDirectory: true)
    path.appendPathComponent(img.filename.hash.description + "_" + img.filename + "." + (img.ext ?? ".png"), isDirectory: false)
    // TODO Catch
    try FileManager.default.createDirectory(at: path.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
    // TODO Catch
    try img.data.write(to: path) // save picture on disk
    designedUser.avatar = path.absoluteString // save picture on user
  }
  
  /// Update User's Profile Picture
  public func updatePPAPI(_ req: Vapor.Request) throws -> Future<User.ShortPublicResponse>  {
    let logger = try  req.make(Logger.self)
    logger.info("##WEP PATCH /account/pp ## User profil picture adding ")
    // fetch auth'd user
    let userAuth = try req.requireAuthenticated(User.self)
    return try updateProfilePicture(req, for: userAuth)
  }
  
  /// Update User's Profile Picture
  public func updateProfilePicture(_ req: Vapor.Request, for designedUser: User)
    throws -> Future<User.ShortPublicResponse>  {
      // fetch auth'd user
      let userAuth = try req.requireAuthenticated(User.self)
      return try req.content.decode(User.Update.self)
        .flatMap { (uRequest) in
          guard try uRequest.id == userAuth.requireID() else {
            throw Abort(HTTPResponseStatus.forbidden)
          }
          if let img = uRequest.avatar {
            try self.setAndSavePicture(img, for: userAuth)
            return userAuth.save(on: req)
              .map({ $0.shortResponse() })
          } else {
            throw Abort(HTTPResponseStatus.notAcceptable)
          }
      }
  }
  
  /// Update  logins informations.
  public func updateLoginsAPI(_ req: Request) throws -> Future<User.ShortPublicResponse> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEP PATCH /account/login ## User login ")
    // fetch auth'd user
    let userAuth = try UserController.logged(req)
    return try updateLogins(req, for: userAuth)
  }
  
  /// Update  logins informations.
  public func updateLogins(_ req: Request, for designedUser: User)
    throws -> Future<User.ShortPublicResponse> {
      let logger = try  req.make(Logger.self)
      logger.info("##WEF .../login ## User updating login \(designedUser.login)")
      // decode request parameter (u/:id)
      return try req.content.decode(User.UpdateEmail.self)
        .flatMap { (uRequest) -> EventLoopFuture<User.ShortPublicResponse> in
          guard try uRequest.id == designedUser.requireID() else {
            throw Abort(HTTPResponseStatus.forbidden)
          }
          guard uRequest.email != uRequest.oldemail else {
            throw Abort(HTTPResponseStatus.badRequest)
          }
          guard uRequest.oldemail == designedUser.email else {
            throw Abort(HTTPResponseStatus.badRequest)
          }
          
          designedUser.newEmail = uRequest.email
          designedUser.emailChangeToken = Utils.newRef(kUserReferenceBasePrefix, size: kReferenceDefaultLength * 4)
          designedUser.emailChangeDate  = Date()
          // TODO Add back logic here
          // 0. send email to the old one to indicate the change. and a link to cancel change.
          // 1. Send email to the new email for validation
          // 2. On validation of that email,
          // 2.1 unvalidate every token and connexion to this account
          // 2.2 switch the old email to the new email
          // 3. send confirmation email to the new email
          return designedUser.save(on: req)
            .flatMap { req.future($0.shortResponse()) }
      }
  }
  
  /// Update password informations.
  public func updatePasswordAPI(_ req: Request) throws -> Future<User.ShortPublicResponse> {
    let logger = try  req.make(Logger.self)
    logger.info("##WEP PATCH /account/pswd ## User password update ")
    // fetch auth'd user
    let userAuth = try UserController.logged(req)
    return try updatePassword(req, for: userAuth)
  }
  
  /// Update password informations.
  public func updatePassword(_ req: Request, for designedUser: User)
    throws -> Future<User.ShortPublicResponse> {
      let logger = try  req.make(Logger.self)
      logger.info("##WEF .../pswd ## User updating login \(designedUser.login)")
      // decode request parameter (u/:id)
      return try req.content.decode(User.UpdatePassword.self)
        .flatMap({ (uRequest) -> EventLoopFuture<User.ShortPublicResponse> in
          guard try uRequest.id == designedUser.requireID() else {
            throw Abort(HTTPResponseStatus.forbidden)
          }
          let hashNew = try BCrypt.hash(uRequest.newPassword)
          let hashVerifyNew = try BCrypt.hash(uRequest.verifyPassword)
          
          if let old = uRequest.oldPassword { // intenteded
            let hashOld = try BCrypt.hash(old)
            
            guard hashOld == designedUser.passwordHash else { // if the accredited person
              throw Abort(HTTPResponseStatus.badRequest)
            }
            
            guard hashNew == designedUser.oldPasswordHash else { // Same password than last one
              throw Abort(HTTPResponseStatus.badRequest)
            }
            guard hashVerifyNew == hashNew else { // if he doesnt miss tiping pswd
              throw Abort(HTTPResponseStatus.badRequest)
            }
            designedUser.oldPasswordHash = hashOld
          } else { // reseting password
            guard let token = uRequest.token, token == designedUser.passwordChangeToken else {
              throw Abort(HTTPResponseStatus.badRequest)
            }
            // If one hour passed... fail
            guard let dChePswd = designedUser.passwordChangeDate, dChePswd.addingTimeInterval(60*60) < Date() else {
              throw Abort(HTTPResponseStatus.badRequest)
            }
            guard hashVerifyNew == hashNew else {
              throw Abort(HTTPResponseStatus.badRequest)
            }
          }
          
          designedUser.passwordHash = hashNew // then save
          designedUser.passwordChangeDate = nil
          designedUser.passwordChangeToken = nil
          
          return designedUser.save(on: req)
            .flatMap { req.future($0.shortResponse()) }
          
        })
  }
  
  
  /// reset password informations.
  public func resetPasswordAPI(_ req: Request)
    throws -> Future<User.ShortPublicResponse> {
      let logger = try  req.make(Logger.self)
      logger.info("##WEP /revoke/pswd ## User reseting password")
      // decode request parameter (u/:id)
      return try req.content.decode(User.ResetPassword.self)
        .flatMap { (uRequest) -> EventLoopFuture<User.ShortPublicResponse> in
          return User.query(on: req)
            .filter(\.email == uRequest.email)
            .first().flatMap { (user) -> Future<User.ShortPublicResponse> in
              guard let designedUser = user else {
                throw Abort(HTTPResponseStatus.badRequest)
              }
              designedUser.passwordChangeToken  = Utils.newRef(kUserReferenceBasePrefix, size: kReferenceDefaultLength * 4)
              designedUser.passwordChangeDate   = Date()
              // 1. send email to the right person to reset password
              
              return designedUser.save(on: req)
                .flatMap { req.future($0.shortResponse()) }
          }
          
      }
  }
  
  /// Verify accunt email  informations.
  public func verifyEmailAPI(_ req: Request)
    throws -> Future<User.ShortPublicResponse> {
      let logger = try  req.make(Logger.self)
      logger.info("##WEP /account/add ## User verify email")
      // decode request parameter (u/:id)
      let token = try req.parameters.next(String.self)
      return User.query(on: req).filter(\.emailChangeToken == token)
        .first().flatMap { (user) -> Future<User.ShortPublicResponse> in
          guard let designedUser = user else {
            throw Abort(HTTPResponseStatus.badRequest)
          }
          
          designedUser.emailChangeToken  = nil
          designedUser.passwordChangeDate = nil
          // 1. send email to the right person to reset password
          if let email = designedUser.newEmail {
            designedUser.oldEmail = designedUser.email
            designedUser.email = email
            designedUser.newEmail = nil
          }
          return designedUser.save(on: req)
            .flatMap { req.future($0.shortResponse()) }
      }
  }
  
  /// Delete the given user.
  public func delete(_ req: Request) throws -> Future<User.FullPublicResponse> {
    // fetch auth'd user
    let _ = try req.requireAuthenticated(User.self)
    throw Abort(HTTPResponseStatus.notImplemented)
  }
  
}
