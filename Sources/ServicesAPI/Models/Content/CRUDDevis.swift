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
  /// Public common representation create
  struct Create: Content {
    public var serviceID: Service.ID?
    public var appliedSchedule: Schedule.ID?
    public var percentTVA: Double
    public var orgDevisARef: String?
    public var readed: String
    public var acceptCGUCGV: String

    // Profile section
    public var quantity: [Int: Int]?
    public var idLink:  [Int: ServiceAsset.ID]?
    public var idAsset: [Int: Asset.ID]?
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
  public var id:          ObjectID?
  /// user ID who initiated Contract.
  public var authorID:    User.ID
  /// Devis's unique slug réference.
  public var slugDevis:   String
  /// Devis's unique réference into the organization whom create the schedule.
  public var orgDevisARef: String?
  /// Devis's unique réference into the organization whom validate the devis if different.
  public var orgDevisBRef: String?
  /// Devis attached Service
  public var serviceID:   Service.ID
  /// Devis attached Schedulle
  public var scheduleID:   Schedule.ID?
  /// Devis attached activity planning
  public var activityID:   Activity.ID?
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
  /// Contract's unique réference into the organization whom emit the Contract.
  public var orgASigned:  Bool
  /// Contract's unique réference into the organization whom validate the Contract.
  public var orgBSigned:  Bool
  /// user ID who closed the Contract.
  public var closedAuthorID: User.ID?
  
  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?
  }
  
  /// Public representation of user data.
  struct FullPublicResponse: Content {
    /// Devis's unique identifier.
    public var id:          ObjectID?
    /// user  who initiated Contract.
    public var author:    User.ShortPublicResponse
    /// Devis's unique slug réference.
    public var slugDevis:   String
    /// Devis's unique réference into the organization whom create the schedule.
    public var orgDevisARef: String?
    /// Devis's unique réference into the organization whom validate the devis if different.
    public var orgDevisBRef: String?
    /// Devis attached Service
    public var service:   Service
    /// Devis attached Schedulle
    public var schedule:   Schedule.ShortPublicResponse?
    /// Devis attached activity planning
    public var activity:   Activity.ShortPublicResponse?
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
    /// Devis full commentExchange Ref
    public var comment:       String

    /// Create date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
    /// Deleted date.
    public var deletedAt: Date?

  }

}
