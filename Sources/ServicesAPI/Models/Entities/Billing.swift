//
//  Billing.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 07/12/2019.
//

import Foundation
import Vapor
import Fluent

public final class Billing: AdoptedPivot {
  public static let name = "billing"
  /// See `Model`.
  public typealias Left = Contract
  public typealias Right = Order
  public static var leftIDKey: LeftIDKey = \.contractID
  public static var rightIDKey: RightIDKey = \.orderID
  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }

  /// Billing's unique identifier.
  public var id: ObjectID?

  /// Contract id
  public var contractID: Contract.ID
  /// Order  ID
  public var orderID: Order.ID

  /// Created date.
  public var createdAt: Date?
  /// Updated date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?

  
}
