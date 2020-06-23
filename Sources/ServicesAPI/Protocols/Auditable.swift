//
//  Auditable.swift
//  App
//
//  Created by Jacques Charles NJANDA MBIADA on 17/06/2020.
//

import Foundation
import Fluent
import Vapor

public protocol Auditable: Content {
  static var auditID : HistoryDataType.RawValue {get set}

}


