////
////  ServiceScore.swift
////  services
////
////  Created by Jacques Charles NJANDA MBIADA on 04/02/2019.
////
//
//import Foundation
//import Vapor
//import Fluent
//
//let kServiceScoreReferenceBasePrefix  = "SSC"
//let kServiceScoreReferenceLength = kReferenceDefaultLength
//
//public final class ServiceScore: AdoptedPivot, Auditable {
//public static var auditID = HistoryDataType.servicescore.rawValue
//  public static let name = "servicescore"
//  /// See `ModelPivot`.
//  public typealias Left = Score
//  public typealias Right = Service
//  public static var leftIDKey: LeftIDKey = \.scoreID
//  public static var rightIDKey: RightIDKey = \.serviceID
//  public static var createdAtKey: TimestampKey? { return \.createdAt }
//  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
//  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
//
//  /// ServiceScore's unique identifier.
//  public var id: ObjectID?
//  /// ServiceScore's unique réference.
//  public var ref: String
//  /// User id
//  public var authorID: User.ID
//  /// Score ID
//  public var scoreID: Score.ID
//  /// Service ID
//  public var serviceID: Service.ID
//  /// Order ID
//  public var orderID: Order.ID?
//  /// Created date.
//  public var createdAt: Date?
//  /// Updated date.
//  public var updatedAt: Date?
//  /// Deleted date.
//  public var deletedAt: Date?
//  
//  public init(author: User.ID, service: Service.ID, score: Score.ID, order: Order.ID? = nil,
//              createdAt : Date = Date(), updatedAt: Date? = nil, deletedAt : Date? = nil,
//              id: ObjectID? = nil) {
//    self.id               = id
//    self.ref              = Utils.newRef(kServiceScoreReferenceBasePrefix, size: kServiceScoreReferenceLength)
//    self.authorID         = author
//    self.serviceID        = service
//    self.scoreID          = score
//
//    self.createdAt        = createdAt
//    self.updatedAt        = updatedAt
//    self.deletedAt        = deletedAt
//
//
//}
//}
//
///// Allows `ServiceScore` to be used as a Fluent migration.
//extension ServiceScore: Migration {
//  /// See `Migration`.
//  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
//    return AdoptedDatabase.create(ServiceScore.self, on: conn)
//    { builder in
//      builder.field(for: \.id, isIdentifier: true)
//      builder.field(for: \.ref)
//      builder.field(for: \.serviceID)
//      builder.field(for: \.authorID)
//      builder.field(for: \.scoreID)
//      builder.field(for: \.createdAt)
//      builder.field(for: \.updatedAt)
//      builder.field(for: \.deletedAt)
//      builder.unique(on: \.id)
//      builder.unique(on: \.ref)
//      builder.reference(from: \ServiceScore.scoreID,
//                        to: \Score.id,
//                        onUpdate: .noAction, onDelete: .noAction)
//      builder.reference(from: \ServiceScore.authorID,
//                        to: \User.id,
//                        onUpdate: .noAction, onDelete: .setDefault)
//      builder.reference(from: \ServiceScore.serviceID,
//                        to: \Service.id,
//                        onUpdate: .noAction, onDelete: .setNull)
//    }
//  }
//  
//  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
//    return Database.delete(ServiceScore.self, on: conn)
//  }
//}
//
///// Allows `ServiceScore` to be used as a dynamic parameter in route definitions.
//extension ServiceScore: Parameter { }
//
///// Seed for ServiceAsset
//struct SeedServiceScore: Migration {
//  typealias Database = AdoptedDatabase
//
//  static func prepare(on connection: AdoptedConnection) -> Future<Void> {
//    
//    // For ServiceScore 1
//    let ssco1 = ServiceScore(author: 2, service: 1, score: 2)
//    let ssco2 = ServiceScore(author: 2, service: 1, score: 2)
//    let ssco3 = ServiceScore(author: 2, service: 1, score: 2)
//
//    _ = ssco1.save(on: connection).catch({ (e) in
//      print("ERROR SERVICE SCORE 1 ----------")
//      print(e)
//    }).transform(to: ())
//    
//    return .done(on: connection)
//  }
//  
//  static func revert(on connection: AdoptedConnection) -> Future<Void> {
//    return .done(on: connection)
//  }
//}
//
