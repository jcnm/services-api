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
  
  public init() { }

  public func create(_ req: Request) throws -> Future<Organization.FullPublicResponse> {
    let _ = try UserController.logged(req)
    
    // decode request content
    let re = try req.content.decode(Organization.CreateOrganization.self, using: JSONDecoder.custom(dates: JSONDecoder.DateDecodingStrategy.millisecondsSince1970, data: JSONDecoder.DataDecodingStrategy.deferredToData, floats: JSONDecoder.NonConformingFloatDecodingStrategy.throw))
    print("CreateOrganization recupéré")
    print(re)
    return re.flatMap { (oc) -> Future<Organization.FullPublicResponse> in
      let uId = oc.userID
      print(oc)
      print("#################@")
      let user = User.find(uId, on: req)
      let sector = Sector.find(oc.sectorID, on: req)
      let parent = oc.parentID == nil ? nil : Organization.find(oc.parentID!, on: req)
      return user.and(sector).flatMap { (u, sect) -> Future<Organization.FullPublicResponse> in
        let dateForm = DateFormatter()
        dateForm.dateFormat = "yyyy-MM-dd"
        guard let sec = sect else {
          print("@@@@@@@@@@@@Unknown sector")
          throw Abort(HTTPResponseStatus.badRequest)
        }
        let orga = Organization(label: oc.label, slogan: oc.slogan, description: oc.description, sector: oc.sectorID, kind: oc.kind, money: oc.currency, state: ObjectStatus.defaultValue, size: oc.size, parent: oc.parentID == 0 ? nil : oc.parentID, shortLabel: oc.shortLabel, organizationRef: nil, siren: nil, siret: oc.siret, tva: oc.tva, activityStartedAt: dateForm.date(from: oc.activityStartedAt ?? ""), activityEndedAt: dateForm.date(from: oc.activityEndedAt ?? ""), brand: oc.brand, denomination: oc.denomination, orgGender: oc.form, publicPart: oc.publicPart, insurance: oc.insurance, insuranceName: oc.insuranceName, apetCode: oc.apetCode, apetLabel: oc.apetLabel, nafCode: oc.nafCode, nafLabel: oc.nafLabel, capital: oc.capital, market: oc.market, marketValue: oc.marketValue, status: oc.status, rcs: oc.rcs)
        /// Save the organization
        return orga.save(on: req).flatMap { (org) -> Future<Organization.FullPublicResponse> in
          print("@@@@@@@@@@@@Organization saved with succes")
          print(org)
          let uog = UserOrganization(organization: org.id!, user: uId, role: oc.userRole)
          print("What about UserOrganization")
          print(uog)
          /// Save the relation between the orgnization and the user
          return uog.save(on: req).flatMap {
            (uo) -> Future<Organization.FullPublicResponse> in
            print("What about User Pivoted to Organization")
            print(uo)
            if let op = parent {
              return op.flatMap { (orgp) -> Future<Organization.FullPublicResponse> in
                if let part = orgp { // build response with parent
                  return req.future(org.fullResponse(sect: sec, uorg: uo, parent: part.shortResponse()))
                } else {
                  return req.future(org.fullResponse(sect: sec, uorg: uo, parent: nil))
                }
              }
              
            }
            return req.future(org.fullResponse(sect: sec, uorg: uo, parent: nil))
          }
        }
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
            
            orgToUpdate.okind = org.okind
            orgToUpdate.label = org.label
            orgToUpdate.slogan = org.slogan
            orgToUpdate.state = org.state
            orgToUpdate.shortLabel = org.shortLabel
            orgToUpdate.money = org.money
            orgToUpdate.sectorID = org.sectorID
            orgToUpdate.parentID = org.parentID
            orgToUpdate.description = org.description
            orgToUpdate.updatedAt = Date()
            
            return orgToUpdate.update(on: req)
        }
    }
  }
  
  public func addMember(_ req: Request) throws -> Future<Organization.UserRoleMemberPublicResponse>  {
    let usr = try req.requireAuthenticated(User.self)
    let logger = try  req.make(Logger.self)
    let org = try req.parameters.next(Organization.self)
    let re = try req.content.decode(Organization.UserNewRole.self)
    return re.flatMap { (nuo) ->  Future<Organization.UserRoleMemberPublicResponse> in
      let uId = nuo.memberID
      print(nuo)
      print("#################@")
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
      let members = try orga.members.query(on: req).alsoDecode(UserOrganization.self).all()
      let services = try orga.services.query(on: req).all()
      let children = try orga.organizations.query(on: req)
        .join(\Sector.id, to: \Organization.sectorID)
        .alsoDecode(Sector.self).all()
      let parent = orga.parent?.get(on: req)
      let sector = orga.sector.get(on: req)
      return sector.and(members).and(services)
        .flatMap { (sec_mems, servs) -> Future<Organization.FullPublicResponse> in
          let (sec, uuos) = sec_mems
          var orgFull = Organization.fullResponse(org: orga, sect: sec, uorg: nil, parent: nil)
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
            orgFull.members!.append(Organization.UserRoleMemberPublicResponse(id: uo.id, role: uo.role, user: User.ShortPublicResponse(id: usr.id!, login: usr.login, ref:usr.ref, avatar: usr.avatar, staff: usr.staff, createdAt: usr.createdAt), organizationID: uo.organizationID, createdAt: uo.createdAt, updatedAt: uo.updatedAt))
          }
          
          _ = children.map { (orgsecs) -> Void in
            orgFull.children = []
            for (m_org, m_sec) in orgsecs {
              orgFull.children!.append(Organization.midResponse(org: m_org, sect: m_sec, uorg: nil, parent: orga))
            }
          }
          _ = parent?.map{ (m_org) -> Void in
            let orgspr = Organization.ShortPublicResponse(id: m_org.id, shortLabel: m_org.shortLabel, label: m_org.label, ref: m_org.ref, kind: m_org.okind, money: m_org.money, sectorID: m_org.sectorID, parentID: m_org.parentID, size: m_org.osize, createdAt: m_org.createdAt, updatedAt: m_org.updatedAt)
            orgFull.parent = orgspr
          }
          return req.future(orgFull)
      }
    }
  }
  
  
  public func organizationsOf(user: User, req: Request) throws
    -> (PageMeta, Future<OffsetPaginator<Organization.FullPublicResponse>>) {
      guard try user.requireID() != 0 else {
        throw Abort(HTTPResponseStatus.badRequest)
      }
      var meta = PageMeta(req)
      //          let qryNav = meta.apply(, from: req)
      var query = try user.organizations.query(on: req)
        //      .join(\Organization.id, to: \Organization.parentID)
        //            .groupBy(\Organization.id)
        .join(\Sector.id, to: \Organization.sectorID)
        //            .join(\UserOrganization.organizationID, to: \Organization.id)
        .alsoDecode(UserOrganization.self)
        .alsoDecode(Sector.self)
      
      
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
      let trans = try qry.transform(on: req)
      { (obj) ->
        Organization.FullPublicResponse in
        let org         = obj.0.0
        let uorg        = obj.0.1
        let sect        = obj.1
        
        let ofpr = Organization.fullResponse(org: org, sect: sect, uorg: uorg)
        return ofpr
      }
      let pag = try trans.paginate(for: req, type: OffsetPaginator<Organization.FullPublicResponse>.self)
      return (meta, pag)
  }
  
  /// Getting organizations of a given user through /users/userID/organizations
  //  public func organizationOfUser(_ req: Request) throws ->
  //    Future<OffsetPaginator<Organization.FullPublicResponse>> {
  //      let user = try UserController.logged(req)
  //      let pag = try req.parameters.next(User.self).map({ (user: $0, req: req) }).flatMap(OrganizationController.organizationsOf)
  //      return pag
  //   }
  
  /// Getting organization child of a given organization through /organizations/orgaID/organizations
  public func organizationOfOrg(_ req: Request) throws ->
    Future<OffsetPaginator<Organization.FullPublicResponse>> {
      return try req.parameters.next(Organization.self).flatMap
        { org -> Future<OffsetPaginator<Organization.FullPublicResponse>> in
          guard try org.requireID() != 0 else {
            throw Abort(HTTPResponseStatus.badRequest)
          }
          var meta = PageMeta()
          meta.config(from: req)
          var qry = try org.organizations.query(on: req)
            .join(\Sector.id, to: \Organization.sectorID)
            .filter(\Organization.parentID == org.id)
            .alsoDecode(Sector.self)
          if meta.size != 0 {
            qry = qry.filter(\Organization.osize == meta.size)
          }
          if meta.sector != 0 {
            qry = qry.filter(\Organization.sectorID == meta.sector)
          }
          
          let trans = try qry.transform(on: req)
          { (obj:(Organization, Sector)) -> Organization.FullPublicResponse in
            let org         = obj.0
            let sect        = obj.1
            return Organization.fullResponse(org: org, sect: sect, uorg: nil, parent: nil)
          }
          return try trans.paginate(for: req, type: OffsetPaginator<Organization.FullPublicResponse>.self)
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
