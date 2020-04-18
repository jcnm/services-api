//
//  Config.swift
//  App
//
//  Created by Jacques Charles NJANDA MBIADA on 04/12/2019.
//

import Foundation
import Vapor


// Public transversals
public let kVersionsBasePath       = "versions"
public let kVersionRelativePath       = "version"

// 0 BASE ADM ENDPOINT
public let kAdministrationBasePath       = "adm"

// 1 USER ENDPOINT
public let kUserBasePath             = "u"
public let kProfileBasePath          = "p"
public let kUsersRegisterPath        = "signup"
public let kUsersSignUpPath          = "signup"
public let kAccountBasePath          = "account"
public let kUsersLoginBasePath       = "login"
public let kUsersLookupBasePath      = "lookup"
public let kUsersLogoutBasePath      = "logout"
public let kUsersBasePath            = "users"

// 2 SECTOR ENDPOINT
public let kSectorsBasePath          = "sectors"
public let kSectorRelativePath       = "sector"

// 3 INDUSTRY ENDPOINT
public let kIndustriesBasePath         = "industries"
public let kIndustryRelativePath       = "industry"

// 4 ORGANIZATION ENDPOINT
public let kOrganizationsBasePath      = "organizations"
public let kOrganizationReelativePath  = "organization"

// 5 SERVICES ENDPOINT
public let kServicesBasePath         = "services"
public let kServiceRelativePath      = "service"

// 6 ORDER ENDPOINT
public let kOrdersBasePath           = "orders"
public let kOrderRelativePath        = "order"

// 7 ORDERITEM ENDPOINT
public let kOItemsBasePath           = "oitems"
public let kOItemRelativePath        = "oitem"

// 8 USERORGANIZATION ENDPOINT
public let kUOrgssBasePath           = "uorgs"
public let kUOrgelativePath          = "uorg"

// 9 PLANNING ENDPOINT
public let kActivitiesBasePath         = "activities"
public let kActivityRelativePath       = "activity"

// 10 SCHEDULE ENDPOINT
public let kSchedulesBasePath        = "schedules"
public let kSchedulelativePath       = "schedule"

// 15 PAIEMENT
public let kCheckoutBasePath         = "checkout"
public let kBasketBasePath           = "basket"
public let kDevisBasePath           = "devis"

public let kDefaultDataBasePostgresURL       = ""
public let kDefaultDataBasePostgresPort      = 5432
public let kDefaultDataBasePostgresBasename  = "services"
public let kDefaultDataBasePostgreHostname   = "localhost"
public let kDefaultDataBasePostgreUser       = "bbservices"
public let kDefaultDataBasePostgrePassword   = "Service2019PostgresSQL"
/// Default domaine url website and API
public let kDefaultBaseDomaineURL            = "http://localhost:8080"
public let kDefaultAPIVersion                = ""
public let kDefaultBaseDomaineAPIURL         = kDefaultBaseDomaineURL + "/api/" + kDefaultAPIVersion

public let kDefaultBBUserPassword            = "myo\\v/nPa$5word"
public let kBBMainUserIdentifier                   = 7
public let kBBMainOrganizationIdentifier           = 27

public extension Config {
  struct Static {
    public static var bbMainUserID           = kBBMainUserIdentifier
    public static var bbMainOrgID        = kBBMainOrganizationIdentifier
    private static let _baseUrl       = Environment.get("BASE_DOMAINE_URL")
    public static var baseUrl : String {
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
    public static var dbPsgURL : String {
      if let url = Environment.get("DATABASE_URL") {
        return url
      } else {
        return kDefaultDataBasePostgresURL
      }
    }
    /// Postgress database port
    public static var dbPsgPort : Int {
      if let port = Environment.get("DATABASE_PORT") {
        return Int(port) ?? kDefaultDataBasePostgresPort
      } else {
        return kDefaultDataBasePostgresPort
      }
    }
    /// Postgress database base
    public static var dbPsgBasename : String {
      if let dbname = Environment.get("DATABASE_BASENAME") {
        return dbname
      } else {
        return kDefaultDataBasePostgresBasename
      }
    }
    /// Postgress database hostname
    public static var dbPsgHostname : String {
      if let hostname = Environment.get("DATABASE_HOSTNAME") {
        return hostname
      } else {
        return kDefaultDataBasePostgreHostname
      }
    }
    /// Postgress database user name
    public static var dbPsgUser : String {
      if let user = Environment.get("DATABASE_USERNAME") {
        return user
      } else {
        return kDefaultDataBasePostgreUser
      }
    }
    /// Postgress database user password
    public static var dbPsgPassword : String {
      if let pswd = Environment.get("DATABASE_PASSWORD") {
        return pswd
      } else {
        return kDefaultDataBasePostgrePassword
      }
    }
  }
}
