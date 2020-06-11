//
//  UserToken.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 11/11/2019.
//

import Authentication
import Crypto
import FluentPostgreSQL
import Vapor

// 60 sec * 60  = 1h * 48h = 2 jours
let oneWeekInterval = TimeInterval(60 * 60 * 24 * 7)
let oneDayInterval = TimeInterval(60 * 60 * 24 )
let halfDayInterval = TimeInterval(60 * 60 * 12)
let sixHoursInterval = TimeInterval(60 * 60 * 6)
let fourHoursInterval = TimeInterval(60 * 60 * 4)
let oneHourInterval = TimeInterval(60 * 60 )
let halHourInterval = TimeInterval(60 * 30)
let tenMinuteInterval = TimeInterval(60 * 10)
let oneMinuteInterval = TimeInterval(60)
let tenSecInterval = TimeInterval(10)
let kExpirationTokenDurationInMinute = oneMinuteInterval // halfDayInterval

/// An ephermal authentication token that identifies a registered user.
public final class UserToken: AdoptedModel {
  public static let name = "utoken"
  
  /// See `Model`.
  static public var deletedAtKey: TimestampKey? { return \.expiresOn }
  
  /// UserToken's unique identifier.
  public var id: ObjectID?
  
  /// Unique token string.
  public var token: String
  
  /// Reference to user that owns this token.
  public var user: User.ID
  
  /// Expiration date. Token will no longer be valid after this point.
  public var expiresOn: Date?
  
  /// Creates a new `UserToken`.
  public init(id: ObjectID? = nil, token: String, userID: User.ID) {
    self.id = id
    self.token = token
    // set token to expire after 48 hours
    self.expiresOn = Date.init(timeInterval: kExpirationTokenDurationInMinute, since: .init())
    self.user = userID
  }
  
  /// Creates a new `UserToken` for a given user.
  static public func create(userID: User.ID) throws -> UserToken {
    // generate a random 64-bit (best at 128 and more), base64-encoded string.
    let token = try CryptoRandom().generateData(count: 64).base64EncodedString()
    // init a new `UserToken` from that string.
    return .init(token: token, userID: userID)
  }
  
}

public extension UserToken {
  /// Fluent relation to the user that owns this token.
  var userID: Parent<UserToken, User> {
    return parent(\.user)
  }
}

/// Allows this model to be used as a TokenAuthenticatable's token.
extension UserToken: Token {
  /// See `Token`.
  public typealias UserType = User
  
  /// See `Token`.
  public static var tokenKey: WritableKeyPath<UserToken, String> {
    return \.token
  }
  
  /// See `Token`.
  public static var userIDKey: WritableKeyPath<UserToken, User.ID> {
    return \.user
  }
}

/// Allows `UserToken` to be used as a Fluent migration.
extension UserToken: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    let utTable =  AdoptedDatabase.create(UserToken.self, on: conn) { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.token)
      builder.field(for: \.user)
      builder.field(for: \.expiresOn)
      builder.reference(from: \.user, to: \User.id)
      
    }

    if type(of: conn) == PostgreSQLConnection.self {
      // Only for Post GreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(UserToken.name)_id_seq RESTART WITH 50").all()
    }
    return utTable
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(UserToken.self, on: conn)
  }
}

/// Allows `UserToken` to be used as a dynamic parameter in route definitions.
extension UserToken: Parameter { }
