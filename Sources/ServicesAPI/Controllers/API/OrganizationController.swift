//
//  OrganizationController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 16/11/2019.
//

import Foundation
import Vapor
import Fluent
import Authentication
import CoreFoundation
import Paginator

/// - MARK - CREATE Sector
public final class OrganizationController {
  
  let partnerController = PartnerController( )
  
  public init() { }
  
  public func create(_ req: Request) throws -> Future<Organization.FullPublicResponse> {
    let _       = try UserController.logged(req)
    // decode request content
    let re      = try req.content.decode(Organization.CreateOrganization.self)
    let logger  = try  req.make(Logger.self)
    logger.debug("CreateOrganization recupéré")
    return re.flatMap { (oc) -> Future<Organization.FullPublicResponse> in
      let uId         = oc.userID
      print(oc)
      print(req.http.headers)
      let user        = User.find(uId, on: req)
      let sector      = Sector.find(oc.sectorID, on: req)
      let parent      = oc.parentID == nil ? nil : Organization.find(oc.parentID!, on: req)
      let fixedTva    = oc.tva ?? ""
      let tva         = fixedTva.isEmpty ? nil : fixedTva
      let fixedcTva   = oc.communityTVA ?? ""
      let ctva        = fixedcTva.isEmpty ? nil : fixedcTva
      let rcsFixed    = oc.rcs ?? ""
      let rcs         = rcsFixed.isEmpty ? nil : rcsFixed
      //        let orgRefFixed   = oc.organizationRef ?? ""
      //        let orgRef        = orgRefFixed.isEmpty ? nil : orgRefFixed
      let fixedBrand  = oc.brand ?? ""
      let brand       = fixedBrand.isEmpty ? nil : fixedBrand
      let fixedSigle  = oc.sigle ?? ""
      let sigle       = fixedSigle.isEmpty ? nil : fixedSigle
      let fixedjuridicCatCode   = oc.juridicCatCode ?? 0
      let juridicCatCode        = fixedjuridicCatCode == 0 ? nil : fixedjuridicCatCode
      let fixedparentID         = oc.parentID ?? 0
      let parentID              = fixedparentID == 0 ? nil : fixedparentID
      let fixedjuridicCatLabel  = oc.juridicCatLabel ?? ""
      let juridicCatLabel       = fixedjuridicCatLabel.isEmpty ? nil : fixedjuridicCatLabel
      let fixedpublicPart       = oc.sigle ?? ""
      let publicPart            = fixedpublicPart.isEmpty ? nil : fixedpublicPart
      let fixedinsurance        = oc.insurance ?? ""
      let insurance             = fixedinsurance.isEmpty ? nil : fixedinsurance
      let fixedinsuranceName    = oc.insuranceName ?? ""
      let insuranceName         = fixedinsuranceName.isEmpty ? nil : fixedinsuranceName
      let fixedcapital          = oc.capital ?? ""
      let capital               = fixedcapital.isEmpty ? nil : fixedcapital
      let fixedmarket           = oc.market ?? ""
      let market                = fixedmarket.isEmpty ? nil : fixedmarket
      let fixednafCode          = oc.nafCode ?? ""
      let nafCode               = fixednafCode.isEmpty ? nil : fixednafCode
      let fixednafLabel         = oc.nafLabel ?? ""
      let nafLabel              = fixednafLabel.isEmpty ? nil : fixednafLabel
      let fixedmarketValue      = oc.marketValue ?? ""
      let marketValue           = fixedmarketValue.isEmpty ? nil : fixedmarketValue
      let fixedslogan           = oc.slogan ?? ""
      let slogan                = fixedslogan.isEmpty ? nil : fixedslogan
      let fixedStatus           = oc.status ?? ""
      let status                = fixedStatus.isEmpty ? nil : fixedStatus
      
      let dateForm              = DateFormatter()
      dateForm.dateFormat       = "yyyy-MM-dd"
      let activityStartedAt     = dateForm.date(from: oc.activityStartedAt ?? "")
      let activityEndedAt       = dateForm.date(from: oc.activityEndedAt ?? "")
      let siret = oc.siret == "00000000000000" ? nil : oc.siret
      let siren = siret == nil ? nil : String(oc.siret.prefix(9))
      let orga = Organization(label: oc.legalName, slogan: slogan, description: oc.description, sector: oc.sectorID, kind: juridicCatCode, currency: oc.currencyID, state: ObjectStatus.await, size: oc.size, parent: parentID, shortLabel: oc.shortLabel, organizationRef: nil, siren: siren, siret: siret, tva: tva, communityTVA: ctva, activityStartedAt: activityStartedAt, activityEndedAt: activityEndedAt, brand: brand, sigle: sigle, orgGender: oc.juridicForm, juridicCatCode: juridicCatCode, juridicCatLabel: juridicCatLabel, publicPart: publicPart, insurance: insurance, insuranceName: insuranceName, nafCode: nafCode, nafLabel: nafLabel, capital: capital, market: market, marketValue: marketValue, status: status, rcs: rcs)
      
      return user.and(sector).flatMap { (u, sect) -> Future<Organization.FullPublicResponse> in
        guard let sec = sect else {
          print("@@@@@@@@@@@@Unknown sector")
          throw Abort(HTTPResponseStatus.badRequest)
        }
        return req.transaction(on: .psql) { (conn) -> Future<Organization.FullPublicResponse>  in
          /// Save the organization
          return orga.create(on: req).flatMap { (org) -> Future<Organization.FullPublicResponse> in
            logger.debug("@@@@@@@@@@@@Organization saved with succes")
            print(org)
            let currency = org.currency.get(on: req)
            let uog = UserOrganization(organization: org.id!, user: uId, role: oc.userRole)
            print(uog)
            /// Save the relation between the orgnization and the user
            return uog.create(on: req).and(currency).flatMap {
              (uo, curr) -> Future<Organization.FullPublicResponse> in
              print("What about User Pivoted to Organization")
              print(uo)
              if let op = parent {
                return op.flatMap { (orgp) -> Future<Organization.FullPublicResponse> in
                  if let part = orgp { // build response with parent
                    return req.future(org.fullResponse(sect: sec, currency: curr, uorg: uo, parent: part.shortResponse()))
                  } else {
                    return req.future(org.fullResponse(sect: sec, currency: curr, uorg: uo, parent: nil))
                  }
                }
              }
              return req.future(org.fullResponse(sect: sec, currency: curr, uorg: uo, parent: nil))
            }
          }}
      }
    }
  }
}

/// - MARK - UPDATE Organization
extension OrganizationController {
  
  public func update(_ req: Request) throws -> Future<Organization> {
    let _ = try UserController.logged(req)
    return try req.parameters.next(Organization.self).flatMap
      { orgToUpdate -> Future<Organization> in
        // decode request content
        return try req.content.decode(Organization.self).flatMap
          { org -> Future<Organization> in
            // verify that the sector is well sharped
            guard org.id == orgToUpdate.id else {
              fatalError("Organization to updated differs")
            }
            orgToUpdate.okind         = org.okind
            orgToUpdate.legalName     = org.legalName
            orgToUpdate.slogan        = org.slogan
            orgToUpdate.state         = org.state
            orgToUpdate.shortLabel    = org.shortLabel
            orgToUpdate.currencyID    = org.currencyID
            orgToUpdate.sectorID      = org.sectorID
            orgToUpdate.parentID      = org.parentID
            orgToUpdate.description   = org.description
            orgToUpdate.updatedAt     = Date()
            orgToUpdate.summary       = org.description.resume()
            return orgToUpdate.update(on: req)
        }
    }
  }
  
  public func addMember(_ req: Request) throws -> Future<Organization.UserRoleMemberPublicResponse>  {
    _ = try req.requireAuthenticated(User.self)
    let logger = try  req.make(Logger.self)
    let org = try req.parameters.next(Organization.self)
    let re = try req.content.decode(Organization.UserNewRole.self)
    return re.flatMap { (nuo) ->  Future<Organization.UserRoleMemberPublicResponse> in
      let uId = nuo.memberID
      logger.info("Adding new member ")
      let user = User.find(uId, on: req)
      return user.flatMap{ u -> Future<Organization.UserRoleMemberPublicResponse> in
        guard let realUsr = u else {
          throw Abort(HTTPResponseStatus.badRequest)
        }
        let dateForm = DateFormatter()
        dateForm.dateFormat = "yyyy-MM-dd"
        return org.flatMap { (o) throws -> Future<Organization.UserRoleMemberPublicResponse> in
          guard o.id! == nuo.organizationID else {
            throw Abort(HTTPResponseStatus.badRequest)
          }
          let uor = UserOrganization(organization: nuo.organizationID, user: nuo.memberID, role: nuo.memberRole)
          /// Save the organization
          return uor.save(on: req).map { (uo) -> Organization.UserRoleMemberPublicResponse in
            print("@@@@@@@@@@@@UserOrganization saved with succes")
            print(uo)
            
            return Organization.UserRoleMemberPublicResponse(id: uo.organizationID, role: uo.role, user: realUsr.shortResponse(), organizationID: o.id!, createdAt: uo.createdAt, updatedAt: uo.updatedAt, errors: nil, succes: nil)
          }
        }
      }
    }
  }
}

/// - MARK - GET  Organization
extension OrganizationController {
  
  public func show(_ req: Request) throws -> Future<Organization.FullPublicResponse> {
    let u = try UserController.logged(req)
    let org = try req.parameters.next(Organization.self)
    return org.flatMap { (orga) -> Future<Organization.FullPublicResponse> in
      //        let industries = Industry.query(on: req).filter(\Industry.sectorID, .equal, orga.sectorID).all()
      let currency   = orga.currency.get(on: req)
      let members     = try orga.members.query(on: req).alsoDecode(UserOrganization.self).all()
      let services    = try orga.services.query(on: req).all()
      let children    = try orga.organizations.query(on: req)
        .join(\Sector.id, to: \Organization.sectorID).alsoDecode(Sector.self)
        .join(\Currency.id, to: \Organization.currencyID)
        .alsoDecode(Currency.self).all()
       
      let parent  = orga.parent?.get(on: req)
      let sector  = orga.sector.get(on: req)
      return sector.and(currency).and(members).and(services)
        .flatMap { (sec_mems, servs) -> Future<Organization.FullPublicResponse> in
          let (seccur, uuos) = sec_mems
          let (sec, cur)      = seccur
          var orgFull     = Organization.fullResponse(org: orga, sect: sec, currency: cur, uorg: nil, parent: nil)
          orgFull.members = []
          if !servs.isEmpty {
            orgFull.services = []
            for serv in servs {
              orgFull.services!.append(serv.shortResponse())
            }
            print( "----------------- services---------------")
          }
          
          for (usr, uo) in uuos {
            if (u.id == usr.id) {
              orgFull.userRole = Organization.UserRolePublicResponse(id: uo.id, role: uo.role, userID: uo.userID, organizationID:  uo.organizationID, createdAt: uo.createdAt, updatedAt: uo.updatedAt)
            }
            orgFull.members!.append(Organization.UserRoleMemberPublicResponse(id: uo.id, role: uo.role, user: User.ShortPublicResponse(id: usr.id!, profileID: usr.profileID, login: usr.login, email: usr.email, ref:usr.ref, avatar: usr.avatar, staff: usr.staff, createdAt: usr.createdAt!), organizationID: uo.organizationID, createdAt: uo.createdAt, updatedAt: uo.updatedAt))
          }
          
          _ = children.map { (orgsecs) -> Void in
            orgFull.children = []
            for ((m_org, m_sec), m_curr) in orgsecs {
              orgFull.children!.append(Organization.midResponse(org: m_org, sect: m_sec, currency: m_curr, uorg: nil, parent: orga.shortResponse()))
            }
          }
          _ = parent?.map{ (m_org) -> Void in
            let orgspr = Organization.ShortPublicResponse(id: m_org.id, shortLabel: m_org.shortLabel, legalName: m_org.legalName, ref: m_org.ref, logo: m_org.logo ?? "", kind: m_org.okind, currencyID: m_org.currencyID, sectorID: m_org.sectorID, parentID: m_org.parentID, size: m_org.osize, createdAt: m_org.createdAt, updatedAt: m_org.updatedAt)
            orgFull.parent = orgspr
          }
          return req.future(orgFull)
      }
    }
  }
  
  
  public func organizationsOf(user: User, req: Request) throws
    -> (PageMeta, Future<OffsetPaginator<Organization.MidPublicResponse>>) {
      guard try user.requireID() != 0 else {
        throw Abort(HTTPResponseStatus.unauthorized)
      }
      let meta = PageMeta(req)
      //          let qryNav = meta.apply(, from: req)
      var query = try user.organizations.query(on: req)
        //      .join(\Organization.id, to: \Organization.parentID)
        //            .groupBy(\Organization.id)
        .join(\Sector.id, to: \Organization.sectorID)
        //            .join(\UserOrganization.organizationID, to: \Organization.id)
        .alsoDecode(UserOrganization.self)
        .alsoDecode(Sector.self)
      .join(\Currency.id, to: \Organization.currencyID)
      .alsoDecode(Currency.self)

      
      //            .orderBy(\Organization.id, .null)
      if meta.size != -1 {
        query = query.filter(\Organization.osize == meta.size)
      }
      if meta.role != -1 {
        query = query.filter(\UserOrganization.role == meta.role)
      }
      if meta.sector != -1 {
        query = query.filter(\Organization.sectorID == meta.sector)
      }
      if meta.status != -1 {
        query = query.filter(\Organization.state == meta.status)
      }
      
      let qry = query //meta.apply(query, from: req)
      let trans = qry.transform(on: req)
      { (obj) ->
        Future<Organization.MidPublicResponse> in
        let org         = obj.0.0.0
        let uorg        = obj.0.0.1
        let sect        = obj.0.1
        let curr        = obj.1
        let ofpr = org.midResponse(sect: sect, currency: curr, uorg: uorg, parent: nil)
        return req.future(ofpr)
//        let promise = req.eventLoop.newPromise(Organization.MidPublicResponse.self)
//        DispatchQueue.global().async {
//
//          promise.succeed(result: ofpr)
//        }
//        return promise.futureResult
      }
      let pag = try trans.paginate(for: req, type: OffsetPaginator<Organization.MidPublicResponse>.self)
      return (meta, pag)
  }
  
  /// Getting organizations of a given user through /users/userID/organizations
  //  public func organizationOfUser(_ req: Request) throws ->
  //    Future<OffsetPaginator<Organization.FullPublicResponse>> {
  //      let user = try UserController.logged(req)
  //      let pag = try req.parameters.next(User.self).map({ (user: $0, req: req) }).flatMap(OrganizationController.organizationsOf)
  //      return pag
  //   }
  
  /// Getting organization's childs of a given organization through /organizations/orgaID/organizations
  public func organizationsOfOrg(_ req: Request) throws ->
    Future<OffsetPaginator<Organization.MidPublicResponse>> {
      return try req.parameters.next(Organization.self).flatMap
        { org -> Future<OffsetPaginator<Organization.MidPublicResponse>> in
          guard try org.requireID() != 0 else {
            throw Abort(HTTPResponseStatus.badRequest)
          }
          var meta = PageMeta()
          meta.config(from: req)
          var qry = try org.organizations.query(on: req)
            .filter(\Organization.parentID == org.id)
            .join(\Sector.id, to: \Organization.sectorID)
            .alsoDecode(Sector.self)
          .join(\Currency.id, to: \Organization.currencyID)
          .alsoDecode(Currency.self)
          if meta.size != 0 {
            qry = qry.filter(\Organization.osize == meta.size)
          }
          if meta.sector != 0 {
            qry = qry.filter(\Organization.sectorID == meta.sector)
          }
          
          let trans = try qry.transform(on: req)
          { (obj) -> Organization.MidPublicResponse in
            let org         = obj.0.0
            
            let sect        = obj.0.1
            let curr        = obj.1
            return org.midResponse(sect: sect, currency: curr, uorg: nil, parent: nil)
          }
          return try trans.paginate(for: req, type: OffsetPaginator<Organization.MidPublicResponse>.self)
      }
  }
  
  public func list(_ req: Request) throws -> Future<OffsetPaginator<Organization>> {
    let _ = try UserController.logged(req)
    let filter = Organization.query(on: req)
    return try filter.paginate(for: req, type: OffsetPaginator<Organization>.self)
    
  }
  
}

/// - MARK - DELETE Organization
extension OrganizationController {
  public func delete(_ req: Request) throws -> Future<Organization> {
    let _ = try UserController.logged(req)
    // decode request parameter
    return try req.parameters.next(Organization.self).flatMap
      { orgToUpdate -> Future<Organization> in
        
        orgToUpdate.deletedAt   = Date()
        // TODO Update historic trace
        return orgToUpdate.update(on: req)
    }
  }
}

/// - MARK - GET  Relative to Organization
extension OrganizationController {
  
  public func sectorOfOrganization(_ req: Request) throws -> Future<Sector> {
    let _ = try UserController.logged(req)
    return try req.parameters.next(Organization.self).flatMap
      { orga -> Future<Sector> in
        guard try orga.requireID() != 0 else {
          throw Abort(HTTPResponseStatus.badRequest)
        }
        return orga.sector.get(on: req)
    }
  }
  
  public func membersOfOrganization(_ req: Request) throws -> Future<OffsetPaginator<User.ShortPublicResponse>> {
    let authU = try UserController.logged(req)
    return try authU.organizations.query(on: req).all().flatMap { (orgas) -> Future<OffsetPaginator<User.ShortPublicResponse>> in
      return try req.parameters.next(Organization.self).flatMap
        { orga -> Future<OffsetPaginator<User.ShortPublicResponse>> in
          guard try orga.requireID() != 0 else {
            throw Abort(HTTPResponseStatus.badRequest)
          }
          guard orgas.contains(where: { $0.id == orga.id }) else {
            throw Abort(HTTPResponseStatus.unauthorized)
          }
          let filter = try orga.members.query(on: req).transform(on: req, {$0.shortResponse()})
          return try filter.paginate(for: req, type: OffsetPaginator<User.ShortPublicResponse>.self)
          
      }
    }
  }
  
}

extension OrganizationController: RouteCollection {
  public func boot(router: Router) throws {
    
    /*************************** LOGGED USER SECTION *******************
     ***
     ***
     ***
     *******************************************************************/
    
    // bearer / token auth protected routes
    let bearer = router.grouped(User.tokenAuthMiddleware())
    let orgaGroup      = bearer.grouped(Config.APIWEP.organizationsWEP)
    
    /**
     ** Logged User  activity Organization - 4
     */
    orgaGroup.get(use: list)
    orgaGroup.post(use: create)
    orgaGroup.get(Organization.parameter, use: show)
    orgaGroup.patch(Organization.parameter, use: update)
    orgaGroup.patch(Organization.parameter, Config.APIWEP.sectorsWEP, use: sectorOfOrganization)
    orgaGroup.post(Organization.parameter, Config.APIWEP.membersWEP, use: addMember)
    
  }
}
