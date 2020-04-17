//
//  Config.swift
//  App
//
//  Created by Jacques Charles NJANDA MBIADA on 04/12/2019.
//

import Foundation
import Vapor


// Public transversals
let kVersionsBasePath       = "versions"
let kVersionRelativePath       = "version"

// 0 BASE ADM ENDPOINT
let kAdministrationBasePath       = "adm"

// 1 USER ENDPOINT
let kUserBasePath             = "u"
let kProfileBasePath          = "p"
let kUsersRegisterPath        = "signup"
let kUsersSignUpPath          = "signup"
let kAccountBasePath          = "account"
let kUsersLoginBasePath       = "login"
let kUsersLookupBasePath      = "lookup"
let kUsersLogoutBasePath      = "logout"
let kUsersBasePath            = "users"

// 2 SECTOR ENDPOINT
let kSectorsBasePath          = "sectors"
let kSectorRelativePath       = "sector"

// 3 INDUSTRY ENDPOINT
let kIndustriesBasePath         = "industries"
let kIndustryRelativePath       = "industry"

// 4 ORGANIZATION ENDPOINT
let kOrganizationsBasePath      = "organizations"
let kOrganizationReelativePath  = "organization"

// 5 SERVICES ENDPOINT
let kServicesBasePath         = "services"
let kServiceRelativePath      = "service"

// 6 ORDER ENDPOINT
let kOrdersBasePath           = "orders"
let kOrderRelativePath        = "order"

// 7 ORDERITEM ENDPOINT
let kOItemsBasePath           = "oitems"
let kOItemRelativePath        = "oitem"

// 8 USERORGANIZATION ENDPOINT
let kUOrgssBasePath           = "uorgs"
let kUOrgelativePath          = "uorg"

// 9 PLANNING ENDPOINT
let kActivitiesBasePath         = "activities"
let kActivityRelativePath       = "activity"

// 10 SCHEDULE ENDPOINT
let kSchedulesBasePath        = "schedules"
let kSchedulelativePath       = "schedule"

// 15 PAIEMENT
let kCheckoutBasePath         = "checkout"
let kBasketBasePath           = "basket"
let kDevisBasePath           = "devis"

let kDefaultDataBasePostgresURL       = ""
let kDefaultDataBasePostgresPort      = 5432
let kDefaultDataBasePostgresBasename  = "services"
let kDefaultDataBasePostgreHostname   = "localhost"
let kDefaultDataBasePostgreUser       = "bbservices"
let kDefaultDataBasePostgrePassword   = "Service2019PostgresSQL"
/// Default domaine url website and API
let kDefaultBaseDomaineURL            = "http://localhost:8080"
let kDefaultAPIVersion                = ""
let kDefaultBaseDomaineAPIURL         = kDefaultBaseDomaineURL + "/api/" + kDefaultAPIVersion

let kDefaultBBUserPassword            = "myo\\v/nPa$5word"
let kBBMainUserIdentifier                   = 7
let kBBMainOrganizationIdentifier           = 27
extension Config {

  public struct Static {
    
    static var bbMainUserID           = kBBMainUserIdentifier
    static var bbMainOrgID        = kBBMainOrganizationIdentifier
    private static let _baseUrl       = Environment.get("BASE_DOMAINE_URL")
    static var baseUrl : String {
      if let url = _baseUrl {
        return url
      } else {
        return kDefaultBaseDomaineURL
      }
    }
    /****
     * Data base configuration
     ***/
    /// Postgress database full url
    static var dbPsgURL : String {
      if let url = Environment.get("DATABASE_URL") {
        return url
      } else {
        return kDefaultDataBasePostgresURL
      }
    }
    /// Postgress database port
    static var dbPsgPort : Int {
      if let port = Environment.get("DATABASE_PORT") {
        return Int(port) ?? kDefaultDataBasePostgresPort
      } else {
        return kDefaultDataBasePostgresPort
      }
    }
    /// Postgress database base
    static var dbPsgBasename : String {
      if let dbname = Environment.get("DATABASE_BASENAME") {
        return dbname
      } else {
        return kDefaultDataBasePostgresBasename
      }
    }
    /// Postgress database hostname
    static var dbPsgHostname : String {
      if let hostname = Environment.get("DATABASE_HOSTNAME") {
        return hostname
      } else {
        return kDefaultDataBasePostgreHostname
      }
    }
    /// Postgress database user name
    static var dbPsgUser : String {
      if let user = Environment.get("DATABASE_USERNAME") {
        return user
      } else {
        return kDefaultDataBasePostgreUser
      }
    }
    /// Postgress database user password
    static var dbPsgPassword : String {
      if let pswd = Environment.get("DATABASE_PASSWORD") {
        return pswd
      } else {
        return kDefaultDataBasePostgrePassword
      }
    }
  }
}
