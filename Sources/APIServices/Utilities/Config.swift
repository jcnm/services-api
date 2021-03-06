//
//  Config.swift
//  App
//
//  Created by Jacques Charles NJANDA MBIADA on 04/12/2019.
//

import Foundation
import Vapor

fileprivate let kDefaultDataBasePostgresURL           = ""
fileprivate let kDefaultDataBasePostgresPort          = 5432
fileprivate let kDefaultDataBasePostgresBasename      = "services"
fileprivate let kDefaultDataBasePostgreHostname       = "localhost"
fileprivate let kDefaultDataBasePostgreUser           = "bbservices"
fileprivate let kDefaultDataBasePostgrePassword       = "Service2019PostgresSQL"
/// Default domaine url website and API
fileprivate let kDefaultBaseDomaineURL                = "http://localhost:8080"
fileprivate let kDefaultAPIVersion                    = ""
    
fileprivate let kDefaultBBUserPassword                = "myo\\v/nPa$5word"
fileprivate let kDefaultBBMainUserIdentifier          = 7
fileprivate let kDefaultBBMainOrganizationIdentifier  = 27

public extension Config {
  // Public transversals
  static let bbMainUserID                     = Int(Environment.get("BB_MAIN_USER_IDENT") ?? String(kDefaultBBMainUserIdentifier))!
  static let bbMainOrgID                      = Int(Environment.get("BB_MAIN_ORGA_IDENT") ?? String(kDefaultBBMainOrganizationIdentifier))!
  static let bbUserPWD                        = Environment.get("BB_USER_PASSWORD") ?? kDefaultBBUserPassword
  static let cacheURL                         = Environment.get("BASE_CACHE_URL") ?? ""
  static let baseUrl                          = Environment.get("BASE_DOMAINE_URL") ?? kDefaultBaseDomaineURL
  static let apiVersion                       = Int(Environment.get("API_VERSION") ?? String(kDefaultAPIVersion))
  static let rootUpdloadedFiles               = "uploads/"
  static let rootUpdloadedImagesFiles         = "imgs/"
  static let rootUpdloadedDocumentsFiles      = "docs/"
  static let rootUpdloadedConfigsFiles        = "configs/"
  static let dbPsgURL: String                 = Environment.get("DATABASE_URL") ?? kDefaultDataBasePostgresURL
  /// Postgress database port
  static let dbPsgPort: Int                   = Int(Environment.get("DATABASE_PORT") ?? "") ?? kDefaultDataBasePostgresPort
  /// Postgress database base
  static let dbPsgBasename: String            = Environment.get("DATABASE_BASENAME") ?? kDefaultDataBasePostgresBasename
  /// Postgress database hostname
  static let dbPsgHostname: String            = Environment.get("DATABASE_HOSTNAME") ?? kDefaultDataBasePostgreHostname
  /// Postgress database user name
  static let dbPsgUser : String               = Environment.get("DATABASE_USERNAME") ?? kDefaultDataBasePostgreUser
  /// Postgress database user password
  static let dbPsgPassword : String           = Environment.get("DATABASE_PASSWORD") ?? kDefaultDataBasePostgrePassword

  struct SearchEngine {
    struct Default {
      public static let nonullable                = 0
      public static let nullable                  = -1
      public static let offset                    = 0
      public static let page                      = 1
      public static let limit                     = 2
      public static let queryString               = ""
      public static let direction                 = "null"
    }
    
    public static let paramsPartnerQuery          = "part"
    public static let paramsOrganizationQuery     = "org"
    public static let paramsScheduleQuery         = "sche"
    public static let paramsUserQuery             = "usr"
    public static let paramsServiceQuery          = "serv"
    public static let paramsLimitQuery            = "lim"
    public static let paramsOffsetQuery           = "off"
    public static let paramsPageQuery             = "p"
    public static let paramsDirectionQuery        = "o"
    public static let paramsSectorQuery           = "sec"
    public static let paramsIndustryQuery         = "i"
    public static let paramsRoleQuery             = "role"
    public static let paramsSizeQuery             = "size"
    public static let paramsKindQuery             = "kind"
    public static let paramsStateQuery            = "s"
    public static let paramsMoneyQuery            = "dev"
    public static let paramsJuridicQuery          = "t"
    public static let paramsCreatedQuery          = "c"
    public static let paramsUpdatedQuery          = "up"
    public static let paramsDeletedQuery          = "del"
    public static let paramsActivityStartQuery    = "ss"
    public static let paramsActivityEndQuery      = "se"
    public static let paramsQuery                 = "q"

  }
  struct APIWEP {
    public static let organizationsWEP  = "organizations"
    public static let freeWEP           = "free"
    public static let newWEP            = "new"
    public static let addWEP            = "add"
    public static let showWEP           = "show"
    public static let readWEP           = "read"
    public static let createWEP         = "create"
    public static let editWEP           = "edit"
    public static let updateWEP         = "update"
    public static let deleteWEP         = "delete"
    public static let revokeWEP         = "revoke"
    public static let signupWEP         = "signup"
    public static let loginWEP          = "login"
    public static let accountWEP        = "account"
    public static let lookupWEP         = "lookup"
    public static let logoutWEP         = "logout"
    public static let passwordWEP       = "pswd"

    public static let admWEP            = "adm"
    public static let uorgsWEP          = "uorgs"
    public static let devisWEP          = "devis"
    public static let rightsWEP         = "rights"
    public static let teamsWEP          = "teams"
    public static let teamWEP           = "team"
    public static let basketsWEP        = "baskets"
    public static let basketWEP         = "basket"
    public static let checkoutWEP       = "checkouts"
    public static let schedulesWEP      = "schedules"
    public static let activitiesWEP     = "activities"
    public static let membersWEP        = "members"
    public static let disruptionsWEP    = "disruptions"
    public static let oitemsWEP         = "oitems"
    public static let ordersWEP         = "orders"
    public static let servicesWEP       = "services"
    public static let versionsWEP       = "versions"
    public static let partnersWEP       = "partners"
    public static let usersWEP          = "users"
    public static let sectorsWEP        = "services"
    public static let industriesWEP     = "orders"
    public static let assetsWEP         = "assets"
    public static let scoresWEP         = "scores"
    public static let commentsWEP       = "comments"
    public static let feedbacksWEP      = "fbs"
    public static let paymentsWEP       = "payments"
    public static let cardsWEP          = "cards"
    public static let detailsWEP        = "details"
    public static let helpsWEP          = "help"
    public static let cguWEP            = "cgu"
    public static let parametersWEP     = "parameters"
    public static let contractsWEP      = "contracts"
    public static let currenciesWEP     = "currencies"
    public static let contactWEP        = "contact"
    public static let placesWEP         = "places"
    public static let billingsWEP       = "billings"
    public static let loginsWEP         = "logins"
    public static let aboutWEP          = "about"
    public static let legalesWEP        = "legales"
    public static let userWEP           = "u"
    public static let profilesWEP       = "profiles"
    public static let profilePictureWEP = "pp"
  }
  
}
