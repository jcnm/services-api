//
//  WebsiteUserController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 26/11/2019.
//

import Foundation
import Vapor
import Fluent
import Authentication
import Leaf
import Paginator

let kWebUserDetailEditBasePath        = "details/edit"
/// - MARK - ROUTER Website
final class WebsiteUserController {
  var userControl: UserController = UserController()
  
  
  public static func fillMetaProfilEdition(_ meta: inout PageMeta) {
    meta.namedData["gender"] = []
    for bp in DayOfWeek.allCases {
      meta.namedData["scheduleDow"]!.append(LabeledValue<String>(label: String(bp.rawValue), value: bp.textual))
    }
    meta.namedData["scheduleState"] = []
    for st in ObjectStatus.allCases {
      meta.namedData["scheduleState"]!.append(LabeledValue<String>(label: String(st.rawValue), value: st.textual))
    }
  }

  /// Sign up handler
  func signUpHandler(_ req: Request) throws -> Future<View> {
    let logger = try req.make(Logger.self)
    do {
      let user = try? WebsiteController.loggedFullUserInfos(req)
      if let u = user {
        return u.flatMap { (uFPR) -> EventLoopFuture<View> in
          return try req.view().render(kUsersSignUpPath, ["user": uFPR])
        }
      }
      // If no user logged return an empty contexte
      return try req.view().render(kUsersSignUpPath)
    } catch let err {
      let log = try req.make(Logger.self)
      log.error(err.localizedDescription)
      throw err
    }
  }
  
  /// Sign up post handler
  func signUpPostHandler(_ req: Request) throws -> Future<View>  {
    let logger = try req.make(Logger.self)
    let u = try userControl.create(req)
    return u.flatMap{ user -> Future<View> in
      logger.info("User retrieved !!!")
      let ret = try req.view().render(kUsersSignUpPath, ["user": user])
      return ret
      
    }.catchFlatMap { (err ) -> Future<View> in
      print(err)
      let u = User(login: "", email: "", passwordHash: "")
      let user: Future<User.FullPublicResponse>
      switch err {
        case is Abort:
          user = u.fullResponse(req, [LabeledValue<String>(label: "20", value: "Les mots de passe ne correspondent pas")])
        case is ValidationError:
          user = u.fullResponse(req, [LabeledValue<String>(label: "30", value: "Format de donnée incorrect")])
        default:
          user = u.fullResponse(req, [LabeledValue<String>(label: "1", value: "Une erreur inconnue est survenue")])
      }
      return user.flatMap { (uFPR) -> Future<View> in
        let ret = try req.view().render(kUsersSignUpPath, ["user": uFPR])
        return ret
      }
    }
  }
  
  func loginHandler(_ req: Request) throws -> Future<View>  {
    let user = try? WebsiteController.loggedFullUserInfos(req)
    let log = try req.make(Logger.self)
      if let u = user {
        return u.flatMap { (uFPR) -> EventLoopFuture<View> in
          return try req.view().render(kUsersLoginBasePath,["user": uFPR])
        }.catch { (err) in
          log.error(err.localizedDescription)

        }
      }
      let ret = try req.view().render(kUsersLoginBasePath)
      return ret
  }
  
  func loginPostHandler(_ req: Request) throws -> Future<Response> {
    let logger = try req.make(Logger.self)
    let usr = try? UserController.logged(req)
    logger.info("Does this user is logged ? \(usr)")
    do {
      print(req)
      let ret = try userControl.login(req)
      let r = ret.map{ (ur) -> Response in
        logger.info("Redirection to /account")
        let res = req.redirect(to:  "/" + kAccountBasePath)
        return res
      }
      return r
    }
  }
  
  func logoutHandler(_ req: Request) throws -> Future<Response>  {
    try req.unauthenticateSession(User.self)
    try req.destroySession()
    return req.future(req.redirect(to:  "/"))
  }

  func accountDetailsEdit(_ req: Request) throws -> Future<View>  {
    let user = try WebsiteController.loggedFullUserInfos(req)
    let logger = try req.make(Logger.self)
    logger.info("Trying to auth user from session")
    var urls = UrlWebsite()
    urls.root = "/account/details"
    urls.endUrl = "details"
    urls.breadcrumb["data"] = []
    urls.breadcrumb["data"]!.append(NamedEmail(label:"/account", value: "Compte"))
    urls.breadcrumb["data"]!.append(NamedEmail(label:urls.root, value: "Details"))
    urls.breadcrumb["data"]!.append(NamedEmail(label: "", value: "Mise à jour"))

    return user.flatMap{ u -> Future<View> in
      do {
        switch req.http.method {
          case .POST:
            logger.info("Trying to post profil")
            return try View.decode(from: req)
          case .GET:
            //      userInfos.merge([:]) { (k1, k2) -> Any in return k2 }
            /// Quick fix SOLUTION
            /// TODO ADD Datepicker
            var meta = PageMeta()
            let context = Page<User.FullPublicResponse>(meta: meta, url: urls, collection: nil, user: u, data: nil)
            let ret = try req.view().render("users/account_details_edit", context )
            return ret
          default:
            return try View.decode(from: req)
        }
      } catch let err {
        let log = try req.make(Logger.self)
        log.error(err.localizedDescription)
        throw err
      }
    }
  }
//
//  public static func updatePersonProfile(contact: inout Contact.CreateContact) {
//
//  }
//
  func accountDetailsEditPerson(_ req: Request) throws -> Future<Response>  {
    let user = try WebsiteController.loggedFullUserInfos(req)
    let logger = try req.make(Logger.self)
    logger.info("Trying to auth user from session")
    return user.flatMap{ u -> Future<Response> in
      do {
        switch req.http.method {
          case .POST: 
            logger.info("Trying to post profil")
            let re = try req.content.decode(Contact.CreateContact.self)
            logger.info("CreateContact recupéré")

            return re.flatMap{ (contact: Contact.CreateContact) -> Future<Response> in
              guard let pkindRaw = Int(contact.places_kind),
                let pkind = PlaceKind(rawValue: pkindRaw),
                let genre = Int(contact.gender) else {
                fatalError()
              }
              let dateForm = DateFormatter()
              dateForm.dateFormat = "yyyy-MM-dd"
              let imageDataAvailable = false
              if imageDataAvailable {
                // imageData treatement
              }
              // Inner function
              let updatePlace = { (_ splace: Place?) -> Future<Response> in
                guard let place = splace else {
                  return req.future(req.redirect(to:  "/" + kAccountBasePath))
                }

                place.label = contact.places_label
                place.city = contact.places_city
                place.country = contact.places_country
                place.postalCode = contact.places_postalCode
                place.state = contact.places_state
                place.street = contact.places_street
                place.updatedAt = Date()
                
                logger.info("Place du contact recupéré")
                print(place)
                let contact = Contact(givenName: contact.givenName, familyName: contact.familyName, nickname: contact.nickname, ckind:   ContactKind.person(PersonGender(rawValue: genre) ?? PersonGender.defaultValue), middleName: contact.middleName, namePrefix: contact.namePrefix, nameSuffix: contact.nameSuffix, previousFamilyName: contact.previousFamilyName, imageData: nil, thumbnailImageData: nil, imageDataAvailable: imageDataAvailable, note: contact.note?.isEmpty ?? false ? nil : contact.note, phoneNumbers: contact.phoneNumbers_value?.isEmpty ?? false ? nil : [NamedURI(label: contact.phoneNumbers_label ?? "", value: contact.phoneNumbers_value ?? "")], emailAddresses:  contact.emailAddresses_value?.isEmpty ?? false ? nil : [NamedEmail(label: contact.emailAddresses_label ?? "", value: contact.emailAddresses_value ?? "")], urlAddresses:  contact.urlAddresses_value?.isEmpty ?? false ? nil : [NamedURI(label: contact.urlAddresses_label ?? "", value: contact.urlAddresses_value ?? "")], socialProfiles: nil, instantMessageAddresses: nil, places: [place], departmentName: contact.departmentName, jobTitle: contact.jobTitle, birthday: dateForm.date(from: contact.birthday), dates: nil, createdAt: contact.createdAt, updatedAt: nil, deletedAt: nil, id: contact.profileID)

                 return contact.save(on: req)
                  .map { (_) -> Response in
                  return req.redirect(to:  "/" + kAccountBasePath)
                }
              }
              
              if let pid = Place.ID(contact.places_id ?? "") {
                logger.info("Created Place \(pid)")
                return Place.find(pid, on: req).flatMap(updatePlace)
              }
              
              let place = Place(label: contact.places_label, number: contact.places_number, kind: pkind, street: contact.places_street, city: contact.places_city, state: contact.places_state, postalCode: contact.places_postalCode, country: contact.places_country, id: Place.ID(contact.places_id ?? ""))

              return place.save(on: req).flatMap(updatePlace)

            }
          default:
            return req.future(req.redirect(to: "/" + kAccountBasePath))
        }
      }
    }
  }

}


/// - MARK - WEBSITE ROUTES
extension WebsiteUserController: RouteCollection {
  func boot(router: Router) throws {
    /*************************** PUBLIC SECTION *************************
     ***
     *******************************************************************/
    /** Public user end point api spec */
    // Creation of a new version
    
    let authSessionRouter = router.grouped(User.authSessionsMiddleware())

    /// Signin Login Logout
    authSessionRouter.get(kUsersSignUpPath, use: signUpHandler)
    authSessionRouter.post(kUsersSignUpPath, use: signUpPostHandler)
    ///
    authSessionRouter.get(kUsersLoginBasePath, use: loginHandler)
    authSessionRouter.post(kUsersLoginBasePath, use: loginPostHandler)
    
    authSessionRouter.get("logout", use: logoutHandler)

    /// Edit account profil
    authSessionRouter.get(kAccountBasePath, "details", "edit", use: accountDetailsEdit)
    authSessionRouter.post(kAccountBasePath, "details", "edit", "person", use: accountDetailsEditPerson)
    authSessionRouter.get(kAccountBasePath, "users", use: { try self.userControl.lookupAssociated($0) })
    //    let bearer = router.grouped(User.tokenAuthMiddleware())
    //    bearer.post(kVersionsBasePath, use: create)
    
  }
}




