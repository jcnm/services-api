//
//  Utils.swift
//  App
//
//  Created by Jacques Charles NJANDA MBIADA on 22/12/2019.
//

import Foundation
import Vapor
import Fluent
import Crypto
//
public let kReferenceDefaultLength = 5

public struct Utils {
  
  public static func newRef(_ prefix: String, size: Int = kReferenceDefaultLength, on: Date? = Date()) -> String {
    do {
      let ref = try CryptoRandom().generateData(count: size).hexEncodedString()
      let pref = "";
//      if let d = on {
//        let df = DateFormatter()
//        df.dateFormat = "yyyyMMdd"
//        pref = "\(prefix)\(df.string(from: d))"
//      } else {
//        pref = prefix
//      }
      return "\(pref)\(ref)"
    } catch let err {
      let log = PrintLogger()
      log.error("Unable to generate an unique reference: \(err)")
      return "N/A"
    }
  }
  
}
