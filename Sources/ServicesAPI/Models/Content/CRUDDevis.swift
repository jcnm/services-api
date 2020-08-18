//
//  CRUDDevis.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 30/12/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

/// Allows `Devis` to be encoded to and decoded from HTTP messages.
extension Devis: Content { }

// MARK: Content for public usage
public extension Devis {
  
  func shortResponse(service: Service.ShortPublicResponse?, organization: Organization.ShortPublicResponse ) -> Devis.ShortPublicResponse {
    return ShortPublicResponse(id: self.id!, authorID: self.authorID, organizationSs: nil, organizationClient: organization, organizationID: self.organizationID, slugDevis: self.slugDevis, orgDevisARef: self.orgDevisARef, orgDevisBRef: self.orgDevisBRef, service: service, serviceID: self.serviceID, scheduleID: self.scheduleID, activityID: self.activityID, assets: nil, discount: nil, serviceFeePercent: self.serviceFeePercent, TVAPercent: self.TVAPercent, price: self.price, label: self.label, comment: self.comment, ref: self.ref, status: self.status, draft: self.draft, orgASigned: self.orgASigned, orgBSigned: self.orgBSigned, closedAuthorID: self.closedAuthorID, createdAt: self.createdAt!, updatedAt: self.updatedAt, deletedAt: self.deletedAt)
  }
  
  func fullResponse(auth: User.ShortPublicResponse, org: Organization.ShortPublicResponse, serv: Service.FullPublicResponse?,
                           servs: [Service.FullPublicResponse], sch: Schedule.MidPublicResponse?, act: Activity.ShortPublicResponse?,
                           signatora: User.ShortPublicResponse?, signatorb: User.ShortPublicResponse?, closed: User.ShortPublicResponse?) -> Devis.FullPublicResponse {
    return FullPublicResponse(id: self.id!, author: auth, slugDevis: self.slugDevis, organizationClient: org, orgDevisARef: self.orgDevisARef, orgDevisBRef: self.orgDevisBRef, service: serv , services: servs, schedule: sch, activity: act, serviceFeePercent: self.serviceFeePercent, TVAPercent: self.TVAPercent, price: self.price, label: self.label, comment: self.comment,  ref: self.ref, status: self.status, draft: self.draft, orgASigned: self.orgASigned, orgBSigned: self.orgBSigned, orgASignator: signatora, orgBSignator: signatorb, closedAuthorID: closed, createdAt: self.createdAt, updatedAt: self.updatedAt, deletedAt: self.deletedAt)
  }

  /// Public common representation create
  struct Create: Content {
    public var serviceID: Service.ID
    public var organizationID: Organization.ID
    public var appliedSchedule: Schedule.ID?
    public var appliedActivity: Activity.ID?
    public var percentTVA: Double
    public var orgDevisARef: String?
    public var readed: OnOff
    public var acceptCGUCGV: OnOff
    public var label: String
    // Submit the devis with comment specification
    public var comment: String?
    // Submit new computed price
    public var price: Double

    // Profile section -> TODO rename quantities
    public var quantity: [ServiceAsset.ID: Int]
    public var idLink:  [ServiceAsset.ID: ServiceAsset.ID]
    public var idAsset:  [ServiceAsset.ID: Asset.ID]
    public var initialQuantity:  [ServiceAsset.ID: Int]
    public var attachedService:  [ServiceAsset.ID: Service.ID]

  }
  
  /// Public common representation update of user data.
  struct Update: Content {
    public var id: Devis.ID
    public var label: String?
  }

  struct SearchDevisField {
    public static var login = \User.login
    //     public var kind: ContactKind?
    public static var givenName = \Contact.givenName
    public static var familyName = \Contact.familyName
    public static var nickname = \Contact.nickname
    public static var middleName = \Contact.middleName
    public static var jobTitle = \Contact.jobTitle
    public static var departmentName  = \Contact.departmentName
    /// User's email address.
    public static var email = \User.email
    /// User's unique réference.
    public static var ref = \Devis.ref
    /// User's unique réference into the organization.
    public static var orgARef = \Devis.orgDevisARef
    public static var draft = \Devis.draft
    /** Channel used to sign this user &#x60;Channel&#x60;  */
    public static var aCloser = \Devis.closedAuthorID
    /** Created date */
    public static var createdAt = \Devis.createdAt
    /** Updated date */
    public static var updatedAt = \Devis.updatedAt
  }
  
  /// Public representation of user data.
  struct QuickSearch: Content {
    /// Devis's unique identifier.
    public var id:          ObjectID?
    /// user ID who initiated Contract.
    public var authorRef:    String
    /// Devis's unique slug réference.
    public var slugDevis:   String
    /// Devis's unique réference into the organization whom create the schedule.
    public var orgDevisARef: String?
    /// Devis's unique réference into the organization whom validate the devis if different.
    public var orgDevisBRef: String?
    /// Devis attached Service
    public var serviceRef:   String
    /// Devis attached Schedulle
    public var scheduleRef:   String?
    /// Devis attached activity planning
    public var activityRef:   String?
    /// Service fees
    public var serviceFeePercent: Int
    /// Gov TVA  fees
    public var TVAPercent: Int
    /// Devis Label Ref
    public var label:       String
    /// Devis's unique réference.
    public var ref:         String
    /// Devis's  statut.
    public var status:      ObjectStatus.RawValue
    /// Devis's  draft.
    public var draft:       Int // zero mens not a draft, otherwise, incremente draft iteration
  }
  
  /// Public representation of user data.
  struct ShortPublicResponse: Content {
  /// Devis's unique identifier.
  public var id:          ObjectID
  /// user ID who initiated Contract.
  public var authorID:    User.ID
  /// organization A . // service definer //can be fin in service.organization
  public var organizationSs:  Organization.ShortPublicResponse?
  /// organization B . // client definer
  public var organizationClient:  Organization.ShortPublicResponse
  /// organization ID.
  public var organizationID:  Organization.ID
  /// Devis's unique slug réference.
  public var slugDevis:   String
  /// Devis's unique réference into the organization whom create the schedule.
  public var orgDevisARef: String?
  /// Devis's unique réference into the organization whom validate the devis if different.
  public var orgDevisBRef: String?
  /// Devis attached Service
    public var service:   Service.ShortPublicResponse?
  /// Devis attached Service ID
    public var serviceID:   Service.ID?
  /// Devis attached Schedulle
  public var scheduleID:   Schedule.ID?
  /// Devis attached activity planning
  public var activityID:   Activity.ID?
  public var assets: [Asset.Response.ShortPublic]?
  public var discount: Asset.Response.ShortPublic?
  /// Service fees
  public var serviceFeePercent: Int?
  /// Gov TVA  fees
  public var TVAPercent: Int?
  /// Computed Price
  public var price: Double
  /// Devis Label Ref
  public var label:       String
  /// Devis  commentExchange
  public var comment:       String?
    /// Devis's unique réference.
  public var ref:         String
  /// Devis's  statut.
  public var status:      ObjectStatus.RawValue
  /// Devis's  draft.
  public var draft:       Int // zero mens not a draft, otherwise, incremente draft iteration
  /// Contract's unique réference into the organization whom emit the Contract.
  public var orgASigned:  Bool
  /// Contract's unique réference into the organization whom validate the Contract.
  public var orgBSigned:  Bool
  /// user ID who closed the Contract.
  public var closedAuthorID: User.ID?
  
  /// Create date.
  public var createdAt: Date
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  }
  
  /// Public representation of user data.
  struct FullPublicResponse: Content {
    /// Devis's unique identifier.
    public var id:          ObjectID
    /// user  who initiated Contract.
    public var author:    User.ShortPublicResponse
    /// Devis's unique slug réference.
    public var slugDevis:   String
    /// organization A . // service definer //can be fin in service.organization
    public var organizationSs:  Organization.ShortPublicResponse?
    /// organization B . // client definer
    public var organizationClient:  Organization.ShortPublicResponse
    /// Devis's unique réference into the organization whom create the schedule.
    public var orgDevisARef: String?
    /// Devis's unique réference into the organization whom validate the devis if different.
    public var orgDevisBRef: String?
    /// Devis attached Service
    public var service:   Service.FullPublicResponse?
    /// Devis attached Service
    public var services:   [Service.FullPublicResponse]
    /// Devis attached Schedulle
    public var schedule:   Schedule.MidPublicResponse?
    /// Devis attached activity planning
    public var activity:   Activity.ShortPublicResponse?
    public var assets: [Asset.Response.ShortPublic]?
    public var discount: Asset.Response.ShortPublic?
    /// Service fees
    public var serviceFeePercent: Int?
    /// Gov TVA  fees
    public var TVAPercent: Int?
    /// Computed price
    public var price: Double
    /// Devis Label Ref
    public var label:       String
    /// Devis  commentExchange
    public var comment:       String?
    /// Devis's unique réference.
    public var ref:         String
    /// Devis's  statut.
    public var status:      ObjectStatus.RawValue
    /// Devis's  draft.
    public var draft:       Int // zero means not a draft, otherwise, incremente draft iteration
    /// Contract's unique réference into the organization whom emit the Contract.
    public var orgASigned:  Bool
    /// Contract's unique réference into the organization whom validate the Contract.
    public var orgBSigned:  Bool
    /// user ID who signed the Contract.
    public var orgASignator: User.ShortPublicResponse?
    /// user ID who signed the Contract.
    public var orgBSignator: User.ShortPublicResponse?
    /// user ID who closed the Contract.
    public var closedAuthorID: User.ShortPublicResponse?

    /// Create date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
    /// Deleted date.
    public var deletedAt: Date?

  }

}
