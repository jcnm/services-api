//
//  CRUDPlace.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 17/04/2020.
//

import Foundation
import Vapor
import Fluent


extension Place: Content {}

/// Allows `Place` to be encoded to and decoded from HTTP messages.
public extension Place {
  /// Public full representation of an industry data.
  struct FullPublicResponse: Content {
    /// Industry's unique identifier.
    public var id: ObjectID?
    /// Unique CITI CODE string.
    public var citi: String?
    /// Unique SCIAN CODE string.
    public var scian: String?
    /// Unique NACE CODE string.
    public var nace: String
    /// Industry's title string.
    public var title: String
    /// Industry's description.
    public var description: String
    /// Reference to sector parent
    public var sector: Sector
    /// Create date.
    public var createdAt: Date?
    /// Update date.
    public var updatedAt: Date?
    /// Deleted date.
    public var deletedAt: Date?
  }
  
  /// Public full representation of an industry data.
  struct ShortPublicResponse: Content {
    /// Industry's unique identifier.
    public var id: ObjectID?
    /// Unique CITI CODE string.
    public var citi: String?
    /// Unique SCIAN CODE string.
    public var scian: String?
    /// Unique NACE CODE string.
    public var nace: String
    /// Industry's title string.
    public var title: String
    /// Reference to sector parent
    public var sectorID: Sector.ID
    /// Update date.
    public var updatedAt: Date?
  }
}

