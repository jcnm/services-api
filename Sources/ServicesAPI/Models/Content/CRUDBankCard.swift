//
//  CRUDBankCard.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 17/04/2020.
//

import Foundation
import Vapor
import Fluent

/// Allows `BankCard` to be encoded to and decoded from HTTP messages.
extension BankCard: Content { }
