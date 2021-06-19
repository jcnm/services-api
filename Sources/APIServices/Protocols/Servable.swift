//
//  Servable.swift
//  App
//
//  Created by Jacques Charles NJANDA MBIADA on 01/12/2019.
//

import Foundation
import Fluent
import Vapor

public protocol Servable {
  var label : String {get set}
  var shortLabel : String {get set}
  var price : Float? {get set}
  var billing: BillingPlan.RawValue {get set}
  var description: String {get set}
  var industryID: Industry.ID {get set}
  var organizationID: Organization.ID {get set}
}
