//
//  CRUDIndustry.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 30/12/2019.
//

import Foundation
import Vapor
import Fluent

/// Allows `Industry` to be encoded to and decoded from HTTP messages.
public extension Industry {
  
  func fullResponse(sect: Sector.ShortPublicResponse, parent: Industry.ShortPublicResponse? = nil) ->  Industry.FullPublicResponse
   {
    return Industry.FullPublicResponse(id: self.id, parent: parent, citi: self.citi, scian: self.scian, nace: self.nace, title: self.title, description: self.description, sector: sect, createdAt: self.createdAt, updatedAt: self.updatedAt, deletedAt: self.deletedAt)
   }

   func shortResponse() ->  Industry.ShortPublicResponse {
    return Industry.ShortPublicResponse(id: self.id, citi: self.citi, scian: self.scian, nace: self.nace, title: self.title, sectorID: self.sectorID, updatedAt: self.updatedAt)
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
    /// Updated date.
    public var updatedAt: Date?
  }
  
  /// Public full representation of an industry data.
  struct FullPublicResponse: Content {
    /// Industry's unique identifier.
    public var id: ObjectID?
    /// Unique Parent Industry.ID.
    public var parent: Industry.ShortPublicResponse?
    /// Unique CITI CODE string.
    public var citi: String?
    /// Unique SCIAN CODE string.
    public var scian: String?
    /// Unique NACE CODE string.
    public var nace: String
    /// Industry's title string.
    public var title: String
    /// Industry's description.
    public var description: String?
    /// Reference to sector parent
    public var sector: Sector.ShortPublicResponse
    /// Created date.
    public var createdAt: Date?
    /// Updated date.
    public var updatedAt: Date?
    /// Deleted date.
    public var deletedAt: Date?
  }
  
}
