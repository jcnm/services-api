//
//  Extra.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 11/11/2019.
//

import Foundation
import Crypto
import FluentPostgreSQL
import Vapor
import AppKit
//import Fuzi
import SwiftSoup

public typealias  ObjectID        = Int
public typealias  AbsolutePath    = String
public typealias  Time            = String

public extension Time {
  var hours: Int? {
    if self.isEmpty || !self.contains(":") { return nil }
    return Int(String(self.split(separator: ":").first!))
  }
  var minutes: Int? {
    if self.isEmpty || !self.contains(":") { return nil }
    return Int(String(self.split(separator: ":").last!))
  }
}

//public typealias  AdoptedModel    = SQLiteModel
//public typealias  AdoptedPivot    = SQLitePivot
//public typealias  AdoptedConnection = SQLiteConnection
//public typealias  AdoptedDatabase   = SQLiteDatabase
//public typealias  AdoptedDirection  = SQLiteDirection
public typealias  AdoptedModel    = PostgreSQLModel
public typealias  AdoptedPivot    = PostgreSQLPivot
public typealias  AdoptedConnection = PostgreSQLConnection
public typealias  AdoptedDatabase   = PostgreSQLDatabase
public typealias  AdoptedDirection  = PostgreSQLDirection

public typealias Tuple<F, S>    = (F, S)
//public typealias StringTuple    = Tuple<String, String> // Not yet exportable to objc and not codable decodable
public typealias NamedEmail     = LabeledValue<String>
public typealias NamedURI       = LabeledValue<String>

public let kCollectionDescriptionContentSize = 254

public func fillMetaBaseInfo(_ meta: inout PageMeta) {
  meta.namedData["status"] = []
  for os in ObjectStatus.allCases {
    meta.namedData["status"]!.append(LabeledValue<String>(label: String(os.rawValue), value: os.textual))
  }
}

/** Channel type  *
 1 : **Partner** channel api caller*
 2 : **Rescue** rescue channel api caller*
 4 : **Authority** authority channel api caller*
 8 : **Official** official channel api caller*/
public enum ChannelKind: Int, Codable {
  case developer   = 1 //
  case partener = 2 //
  case authority  = 4 //
  case official  = 8 //
}

/**
 *
 ObjectStatus defines object status of a given object.
 stash      = 0 // Object is submetted but not yet evaluated
 online     = 1 //
 await      = 2 // Awaiting confirmation from an other
 review     = 4 // Online and was reviewed
 rejected   = 6 // Offline because rejected
 signaled   = 10
 offline    = 12
 * */

public enum ObjectStatus: Int, Codable, ReflectionDecodable, CaseIterable, RawRepresentable {
  public static func reflectDecoded() throws -> (ObjectStatus, ObjectStatus) {
    (stash, offline)
  }
  
  
  case stash      = 0 // Object is submetted but not yet evaluated
  case online     = 1 //
  case await      = 2 // Picked by a moderator for review
  case review     = 4 // In reviewing
  case rejected   = 6 // Offline because rejected
  case signaled   = 10
  case offline    = 12
  
  public static func has(value: Int, status: ObjectStatus) -> Bool {
    let res = value & status.rawValue
    return res == status.rawValue
  }
  
  public func into(value: Int) -> Bool {
    let res = value & self.rawValue
    return res == self.rawValue
  }
  
  public static var defaultValue: ObjectStatus {
    return .stash
  }
  
  public static var defaultRaw: ObjectStatus.RawValue {
    return defaultValue.rawValue
  }
  
  public var textual: String {
    switch self {
      case .stash:
        return "Mise en attente"
      case .online:
        return "En ligne"
      case .await:
        return "En attente d'analyse"
      case .review:
        return "En revue"
      case .rejected:
        return "Rejeté"
      case .signaled:
        return "Signalé"
      case .offline:
        return "Hors ligne"
    }
  }

}

extension ObjectStatus: Equatable {
  
}

public extension Int {
  var status: ObjectStatus {
    return ObjectStatus(rawValue: self) ?? ObjectStatus.defaultValue
  }
}

extension Whitelist {
  public static func services() throws -> Whitelist {
    return try Whitelist.none()
          .addTags(
              "a", "b", "blockquote", "br", "caption", "cite", "code", "col",
              "colgroup", "dd", "div", "dl", "dt", "em", "h1", "h2", "h3", "h4", "h5", "h6",
              "i", "img", "li", "ol", "p", "pre", "q", "small", "span", "strike", "strong",
              "sub", "sup", "table", "tbody", "td", "tfoot", "th", "thead", "tr", "u",
              "ul", "iframe")
          .addAttributes("a", "href", "title")
          .addAttributes("blockquote", "cite")
          .addAttributes("col", "span", "width")
          .addAttributes("colgroup", "span", "width")
          .addAttributes("img", "align", "alt", "height", "src", "title", "width")
          .addAttributes("ol", "start", "type")
          .addAttributes("q", "cite")
          .addAttributes("table", "summary", "width")
          .addAttributes("td", "abbr", "axis", "colspan", "rowspan", "width")
          .addAttributes(
              "th", "abbr", "axis", "colspan", "rowspan", "scope",
              "width")
          .addAttributes("ul", "type")
          .addAttributes("iframe", "frameborder", "src", "width", "height" )

          .addProtocols("a", "href", "ftp", "http", "https", "mailto")
          .addProtocols("blockquote", "cite", "http", "https")
          .addProtocols("cite", "cite", "http", "https")
          .addProtocols("img", "src", "data", "http", "https")
          .addProtocols("q", "cite", "http", "https")
//          .addProtocols("iframe", "src", "https")
          .addEnforcedAttribute("a", "rel", "nofollow")
  }

}

extension String {
/// Trim using Fuzi lib
//  var htmlToString: String {
//    let doc = try? HTMLDocument(string: self, encoding: String.Encoding.utf8)
//    let nodes = doc?.root?.childNodes(ofTypes: [.Element, .Text])
//    let str = nodes?.reduce("", { (res, xnode) -> String in
//      return "\(res) \(xnode.stringValue)"
//    })
//    return str ?? ""
//  }
//="0" src="//www.youtube.com/embed/BSeX7nTsqmw" width="640" height="360" class="note-video-clip"
var sanitizedHtml: String {
  if let wList = try? Whitelist.services() {
    let cleanHTML = try? SwiftSoup.clean(self, wList)
    return cleanHTML ?? ""
  }
  return ""
}

var trimHTMLTags: String {
  guard let doc: Document = try? SwiftSoup.parse(self) else { return "" } // parse html
  guard let txt = try? doc.text() else { return "" }
  return txt
}
  
}

extension String {
  // Won't work http://www.openradar.me/34021573
  ///https://forums.developer.apple.com/thread/115405
//    public func trimHTMLTags() -> String? {
//        guard let htmlStringData = self.data(using: String.Encoding.utf8) else {
//            return nil
//        }
//        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
//        .documentType: NSAttributedString.DocumentType.html,
//        .characterEncoding: String.Encoding.utf8.rawValue ]
//
//      if let attributedString = NSAttributedString(html: htmlStringData, options: options, documentAttributes: nil) {
//        return attributedString.string
//      }
//      return nil
//    }
}

extension String {

  public func resume(limitChar: Int = kCollectionDescriptionContentSize) -> String {
    guard !self.isEmpty else {
      return "N/A"
    }
    if self.count < (limitChar * 2) - limitChar/2 {
      return self
    }
    let strPrefix = String(self.trimHTMLTags.prefix(limitChar))
    var descr: String? = strPrefix 
    
    if let d = descr {
      if d.contains(".") {
        var descList = d.split(separator: ".",  omittingEmptySubsequences: true)
        if descList.count > 1 {
          descList = descList.dropLast()
        }
        descr = descList.joined(separator: ". ")
      } else {
        let descList = d.split(separator: " ",  omittingEmptySubsequences: true).dropLast()
        descr = (descList.joined(separator: " "))
      }
      if self.count > descr!.count { return "\(descr!)…" }
      return descr!
    }
    return "N/A"
  }

}
/**
 AccessRight defines access right to a given echo.
 
 None - 0 - No right on this (only accessible by the owner)
 Read - 1 - Readable by the defined visibility users
 Write - 2 - targeted users can response to this
 Search - 4 - can appear on research
 Share - 8 - Targeted users can share this*/

public enum AccessRight: Int, Codable, ReflectionDecodable {
  public static func reflectDecoded() throws -> (AccessRight, AccessRight) {
    return (owner, share)
  }
  
  case owner  = 0 // Only accessible by the owner
  case read   = 1 // Readable by the defined visibility users
  case write  = 2 // targeted users can response to this
  case search = 4 // can appear on research
  case share  = 8 // targeted users can share this
  
  public static func defaultValue() -> AccessRight {
    return .owner
  }
  
  public static func defaultRaw() -> AccessRight.RawValue {
    return defaultValue().rawValue
  }
}

/**
 *
 VisibilityPolicy defines visibility policy of a a given object.
 
 Private - 0 - No right to the given echo except if a given authorized list is not empty, set the object as hidden on search engine
 Enclosed - 1 - Visible to enclosed people
 Related - 2 - Visiblle only to my relations
 Opened - 4 - Searchable and access on requests if permited by the accessRight
 Public - 8 - Visible by every one and exposable if permited by the accessRight
 default: 8
 maximum: 16
 */
public enum VisibilityPolicy: Int, Codable, ReflectionDecodable {
  public static func reflectDecoded() throws -> (VisibilityPolicy, VisibilityPolicy) {
    return (enclose, open)
  }
  
  // No right to the given echo except if a given authorized list is not empty,
  // set the object as hidden on search engine
  case `private`    = 0
  case enclose      = 1 // Visible to enclosed people (near the data)
  case relate       = 2 // Visiblle only to my relations
  // Searchable and access on requests if permited by the accessRight
  case open         = 4
  // By every one and exposable if permited by the accessRight
  case visible      = 8 // by default - Visible
  
  public static var defaultValue: VisibilityPolicy {
    return .private
  }
  
  public static var defaultRaw: VisibilityPolicy.RawValue {
    return defaultValue.rawValue
  }
}


public struct LabeledValue<V: Content> : Content {
  public var label: String
  public var value: V
  
  public init(label: String, value: V) {
    self.label = label
    self.value = value
  }
}


extension LabeledValue: ReflectionDecodable, AnyReflectionDecodable where V == String {
  public static func reflectDecoded() throws -> (LabeledValue<V>, LabeledValue<V>) {
    return (LabeledValue<V>(label: "label", value: "value"), LabeledValue<V>(label: "value", value: "label"))
  }
  
  public static func reflectDecodedIsLeft(_ item: LabeledValue<V>) throws -> Bool {
    return item.label.hashValue == ("label").hashValue && item.value.hashValue == "value".hashValue
  }
}

//// Relfextion for named value with string and int
//extension NamedValue: ReflectionDecodable, AnyReflectionDecodable where V: IntegerLiteralType {
//    public static func reflectDecoded() throws -> (NamedValue<V>, NamedValue<V>) {
//        return (NamedValue<V>(name: "name", value: 1), NamedValue<V>(name: "value", value: 0))
//    }
//
//    public static func reflectDecodedIsLeft(_ item: NamedValue<V>) throws -> Bool {
//        return item.name == "name" && item.value == 1
//    }
//}

public struct Device: Codable, ReflectionDecodable {
  public static func reflectDecoded() throws -> (Device, Device) {
    return (Device(deviceName: "Unknow", deviceBrand: "NoBrand", deviceVersion: "Alpha", deviceKind: .mobile, deviceLocale: "N/A", systemVersion: nil, systemName: "n/a"),
            Device(deviceName: "", deviceBrand: String(), deviceVersion: String(), deviceKind: .desktop, deviceLocale: String(), systemVersion: "n/a", systemName: nil))
  }
  
  public static func reflectDecodedIsLeft(_ item: Device) throws -> Bool {
    return item.deviceKind == .mobile && item.systemVersion == nil
  }
  
  public var deviceName: String
  public var deviceBrand: String
  public var deviceVersion: String
  public var deviceKind: DeviceKind
  /** Locale field provide the user system language */
  public var deviceLocale: String
  /** Operating system version,  *&lt;VERSION_ID&gt;*|*&lt;BUILD&gt;* */
  public var systemVersion: String?
  /** Operating system name (i.e *Windows*, *Debian*, *OS X*, *iOS*, etc.) */
  public var systemName: String?
  
  public enum DeviceKind : String, Codable, ReflectionDecodable {
    public static func reflectDecoded() throws -> (Device.DeviceKind, Device.DeviceKind) {
      return (.mobile, .browser)
    }
    case mobile, browser, desktop
  }
}

public extension Int {
  var place: PlaceKind {
    return PlaceKind(rawValue: self) ?? PlaceKind.defaultValue
  }
}

public class TrackedObject {
  /// Can be `nil` if the object has not been saved yet.
  public var id: ObjectID?
  /** Creation date */
  public var createdAt: Date = Date()
}

public class EditableObject: TrackedObject {
  /** Updated date */
  public var updatedAt: Date = Date()
}

extension Date: Content {
  
}
