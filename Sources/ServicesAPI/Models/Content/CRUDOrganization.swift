//
//  CRUDOrganization.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 30/12/2019.
//

import Foundation
import Vapor
import Fluent


extension Organization : Content { }

/// Allows `Organization` to be encoded to and decoded from HTTP messages.
public extension Organization {
  
  func fullResponse(sect: Sector, uorg: UserOrganization? = nil, parent: Organization.ShortPublicResponse? = nil) -> FullPublicResponse
  {
    let org = self
    let id = org.id, createdAt = org.createdAt
    var ur:Organization.UserRolePublicResponse?
    if let uo = uorg, let iduo = uo.id {
      ur = Organization.UserRolePublicResponse(id: iduo, role: uo.role, userID: uo.userID, organizationID: uo.organizationID, createdAt: uo.createdAt, updatedAt: uo.updatedAt)
    }
    
    return Organization.FullPublicResponse(id: id, userRole: ur, shortLabel: org.shortLabel, legalName: org.legalName, ref: kOrganizationReferenceBasePrefix + org.ref , organizationRef: org.organizationRef, slogan: org.slogan, kind: org.okind, state: org.state, money: org.money, parentID: org.parentID, parent: parent, sector: Sector.ShortPublicResponse(id: sect.id, kind: sect.skind, citi: sect.citi, scian: sect.scian, nace: sect.nace, title: sect.title, updatedAt: sect.updatedAt), sectorID: sect.id!, brand: org.brand, denomination: org.denomination, size: org.osize, juridicForm: org.juridicForm, publicPart: org.publicPart, status: org.status, description: org.description, siret: org.siret, tva: org.tva, siren: org.siren, apetCode: org.apetCode, apetLabel: org.apetLabel, nafCode: org.nafCode, nafLabel: org.nafLabel, capital: org.capital, market: org.market, marketValue: org.marketValue, insurance: org.insurance, insuranceName: org.insuranceName, activityStartedAt: org.activityStartedAt, activityEndedAt: org.activityEndedAt, createdAt: createdAt, updatedAt: org.updatedAt)
  }
  
  static func fullResponse(org: Organization, sect: Sector, uorg: UserOrganization? = nil, parent: Organization.ShortPublicResponse? = nil) -> FullPublicResponse {
    return org.fullResponse(sect: sect, uorg: uorg, parent: parent)
  }
  
  func midResponse(sect: Sector, uorg: UserOrganization? = nil, parent: Organization.ShortPublicResponse? = nil) -> MidPublicResponse {
    let org = self
    let id = org.id, createdAt = org.createdAt
    var ur:Organization.UserRolePublicResponse?
    if let uo = uorg, let iduo = uo.id {
      ur = Organization.UserRolePublicResponse(id: iduo, role: uo.role, userID: uo.userID, organizationID: uo.organizationID, createdAt: uo.createdAt, updatedAt: uo.updatedAt)
    }
    return Organization.MidPublicResponse(id: id, userRole: ur, shortLabel: org.shortLabel, legalName: org.legalName, ref: kOrganizationReferenceBasePrefix + org.ref, kind: org.okind, state: org.state, money: org.money, parentID: org.parentID, parent: parent, sector: Sector.ShortPublicResponse(id: sect.id, kind: sect.skind, citi: sect.citi, scian: sect.scian, nace: sect.nace, title: sect.title, updatedAt: sect.updatedAt), sectorID: sect.id!, brand: org.brand, denomination: org.denomination, size: org.osize, juridicForm: org.juridicForm, description: org.description, siret: org.siret, activityStartedAt: org.activityStartedAt, activityEndedAt: org.activityEndedAt, createdAt: createdAt, updatedAt: org.updatedAt)
  }

  func shortResponse() -> Organization.ShortPublicResponse {
    return Organization.ShortPublicResponse(id: self.id, shortLabel: self.shortLabel, legalName: self.legalName, ref: self.ref, kind: self.okind, money: self.money, sectorID: self.sectorID, parentID: self.parentID, size: self.osize, createdAt: self.createdAt, updatedAt: self.updatedAt, errors: nil, succes: nil)
  }
  static func midResponse(org: Organization, sect: Sector, uorg: UserOrganization? = nil, parent: Organization? = nil) -> MidPublicResponse {
    return org.midResponse(sect: sect, uorg: uorg, parent: parent?.shortResponse())
  }
  
  struct CreateOrganization: Content  {
    /// User's unique identifier.
    public var userID: User.ID
    /// Organization connected user's role.
    public var userRole: RoleKind
    /// CEO given denomination name as short as possible.
    public var denomination: String?
    /// short cut name.
    public var shortLabel: String
    /// full name for this sector.
    public var legalName: String
    /// Organization kind.
    public var kind: OrganizationKind
    /// Organization's description.
    public var description: String
    /// Organization's description.
    public var currency: String
    /// Organization sector id.
    public var sectorID: Sector.ID
    /// Organization size type.
    public var size: OrganizationSize
    /// Organization juridic for type.
    public var juridicForm: OrganizationGender
    /// Organization Parent Organization.ID.
    public var parentID: Organization.ID?
    /// Organization slogan.
    public var slogan: String?
    /// Submitted brand if you are working throught a brand licence.
    public var brand: String?
    /// Organization juridic for type.
    public var publicPart: String?
    /// Organization status redaction for some form of organization this is required.
    public var status: String?
    /// Organization siret number.
    public var siret: String
    /// Organization tva number.
    public var tva: String?
    
    /// Organization rcs number.
    public var rcs: String?
    /// Organization APET code.
    public var apetCode: String?
    /// Organization APET label.
    public var apetLabel: String?
    /// Organization NAF code.
    public var nafCode: String?
    /// Organization NAF label.
    public var nafLabel: String?
    /// Organization NAF label.
    public var capital: String?
    /// Organization Market registration
    public var market: String?
    /// Organization Market value
    public var marketValue: String?
    /// Organization assurance number
    public var insurance: String?
    /// Organization assurance number
    public var insuranceName: String?
    /// activity begin date.
    public var activityStartedAt: String?
    /// activity ended date.
    public var activityEndedAt: String?
    /// Create date.
    public var amountRange: String?

  }
  
  struct UserNewRole: Content  {
    /// Organization's unique identifier.
    public var organizationID: UserOrganization.ID
    /// Given role
    public var memberRole: RoleKind
    /// User's unique identifier.
    public var memberID: User.ID
  }
  
  struct UserRolePublicResponse: Content  {
    /// Organization's unique identifier.
    public var id: UserOrganization.ID?
    /// Given role
    public var role: RoleKind.RawValue
    /// User's details
    public var userID: User.ID
    /// Organization's details
    public var organizationID: Organization.ID
    /// Created date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
    /// Errors  codes and messages
    public var errors: [String: String]?
    /// Successes codes and messages
    public var succes: [String: String]?
  }

  struct UserRoleMemberPublicResponse: Content  {
    /// Organization's unique identifier.
    public var id: UserOrganization.ID?
    /// Given role
    public var role: RoleKind.RawValue
    /// User's details
    public var user: User.ShortPublicResponse
    /// Organization's details
    public var organizationID: Organization.ID
    /// Organization's details
    public var organization: Organization.ShortPublicResponse?
    /// Created date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
    /// Errors  codes and messages
    public var errors: [String: String]?
    /// Successes codes and messages
    public var succes: [String: String]?
  }
  
  struct ShortPublicResponse: Content  {
    /// Organization's unique identifier.
    public var id: Organization.ID?
    /// short cut name.
    public var shortLabel: String
    /// full name for this organization.
    public var legalName: String
    /// full référence for this organization.
    public var ref: String
    /// Organization kind.
    public var kind: OrganizationKind.RawValue
    /// Organization's description.
    public var money: String
    /// Reference to sector
    public var sectorID: Sector.ID
    /// Organization Parent Organization.ID.
    public var parentID: Organization.ID?
    /// Organization size
    public var size: OrganizationSize.RawValue
    /// Created date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
    /// Errors  codes and messages
    public var errors: [String: String]?
    /// Successes codes and messages
    public var succes: [String: String]?
  }
  
  struct MidPublicResponse : Content {
    /// Organization's unique identifier.
    public var id: Organization.ID?
    /// Organization connected user's role.
    public var userRole: Organization.UserRolePublicResponse?
    /// short cut name.
    public var shortLabel: String
    /// full name for this organization.
    public var legalName: String
    /// full référence for this organization.
    public var ref: String
    /// Organization kind.
    public var kind: OrganizationKind.RawValue
    /// Organization's title string.
    public var state: ObjectStatus.RawValue
    /// Organization's description.
    public var money: String
    /// Organization Parent Organization.ID.
    public var parentID: Organization.ID?
    /// Organization Parent object.
    public var parent: Organization.ShortPublicResponse?
    /// Reference to sector
    public var sector: Sector.ShortPublicResponse
    /// Organization siret number.
    public var sectorID: Sector.ID
    /// Submitted brand if you are working throught a brand licence.
    public var brand: String?
    /// CEO given denomination name as short as possible.
    public var denomination: String?
    /// Organization size type.
    public var size: OrganizationSize.RawValue
    /// Organization juridic for type. /// organizationGender
    public var juridicForm: OrganizationGender.RawValue
    /// Organization's description.
    public var description: String
    /// Organization siret number.
    public var siret: String?
    /// Organization tva number.
    public var tva: String?
    /// Organization Market value
    public var marketValue: String?
    /// activity begin date.
    public var activityStartedAt: Date?
    /// activity ended date.
    public var activityEndedAt: Date?
    /// Create date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
    /// Errors  codes and messages
    public var errors: [String: String]?
    /// Successes codes and messages
    public var succes: [String: String]?
  }
  
  struct FullPublicResponse : Content {
    /// Organization's unique identifier.
    public var id: Organization.ID?
    /// Organization connected user's role.
    public var userRole: Organization.UserRolePublicResponse?
    /// Organization connected members.
    public var members: [Organization.UserRoleMemberPublicResponse]?
    /// Organization connected members.
    public var services: [Service.ShortPublicResponse]?
    /// Organization connected members.
    public var contacts: [Contact.FullPersonPublicResponse]?
    /// Organization connected members.
    public var children: [Organization.MidPublicResponse]?
    /// short cut name.
    public var shortLabel: String
    /// full name for this sector.
    public var legalName: String
    /// full référence for this organization.
    public var ref: String
    /// Organization's unique réference into the organization.
    public var organizationRef: String?
    /// Organization slogan.
    public var slogan: String?
    /// Organization kind.
    public var kind: OrganizationKind.RawValue
    /// Organization's title string.
    public var state: ObjectStatus.RawValue
    /// Organization's description.
    public var money: String
    /// Organization Parent Organization.ID.
    public var parentID: Organization.ID?
    /// Organization Parent object.
    public var parent: Organization.ShortPublicResponse?
    /// Reference to sector
    public var sector: Sector.ShortPublicResponse
    /// Organization siret number.
    public var sectorID: Sector.ID
    /// Submitted brand if you are working throught a brand licence.
    public var brand: String?
    /// CEO given denomination name as short as possible.
    public var denomination: String?
    /// Organization size type.
    public var size: OrganizationSize.RawValue
    /// Organization juridic for type. /// organizationGender
    public var juridicForm: OrganizationGender.RawValue
    /// Organization juridic for type.
    public var publicPart: String?
    /// Organization status redaction for some form of organization this is required.
    public var status: String?
    /// Organization's description.
    public var description: String
    /// Organization siret number.
    public var siret: String?
    /// Organization tva number.
    public var tva: String?
    /// Organization siren number.
    public var siren: String?
    /// Organization APET code.
    public var apetCode: String?
    /// Organization APET label.
    public var apetLabel: String?
    /// Organization NAF code.
    public var nafCode: String?
    /// Organization NAF label.
    public var nafLabel: String?
    /// Organization NAF label.
    public var capital: String?
    /// Organization Market registration
    public var market: String?
    /// Organization Market value
    public var marketValue: String?
    /// Organization assurance number
    public var insurance: String?
    /// Organization assurance number
    public var insuranceName: String?
    /// activity begin date.
    public var activityStartedAt: Date?
    /// activity ended date.
    public var activityEndedAt: Date?
    /// Create date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
    /// Errors  codes and messages
    public var errors: [String: String]?
    /// Successes codes and messages
    public var succes: [String: String]?
  }
}
