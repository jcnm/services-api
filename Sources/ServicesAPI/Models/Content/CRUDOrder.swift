//
//  CRUDOrder.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 17/04/2020.
//

import Foundation
import Vapor
import Fluent


/// Allows `Order` to be encoded to and decoded from HTTP messages.
extension Order: Content { }

/// Allows `OrderItem` to be encoded to and decoded from HTTP messages.
extension OrderItem: Content { }
