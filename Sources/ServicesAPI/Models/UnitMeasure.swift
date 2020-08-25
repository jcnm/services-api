//
//  UnitMeasure.swift
//  
//
//  Created by J. Charles NJANDA M. on 19/08/2020.
//

import Foundation
import Vapor
import FluentPostgreSQL


public indirect enum BaseUnit: Int, Codable, Equatable, ReflectionDecodable {
  public static func reflectDecoded() throws -> (BaseUnit, BaseUnit) {
    return (unknown, candela)
  }

  case unknown
  case base
  case meter
  case second
  case gram
  case radian
  case kelvin  //
  case coulomb  //
  case candela  //

//  case sqrt(of: BaseUnit)
//  case power(of: BaseUnit, exp: Int)
//  case factor(of: BaseUnit, by: BaseUnit)
//  case division(of: BaseUnit, over: BaseUnit)
  public static var defaultValue : BaseUnit {
    return .unknown
  }
}

public enum KindQuantity: Int, Codable, Comparable, ReflectionDecodable {
  public static func reflectDecoded() throws -> (KindQuantity, KindQuantity) {
    return (unknown, signalTransmissionRate)
  }
  
  public static func < (lhs: KindQuantity, rhs: KindQuantity) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
  
  case unknown
  case number
  case length
  case time
  case mass
  case planeAngle
  case temperature  // K   K  K  °C   Cel   CEL   yes  •   cel(1 K)
  case electricCharge  //
  case luminosityIntensity  //
  case amontOfSubstance // mol   mol   MOL   yes  6.0221367   10*23
  case solidAngle // sr   sr   SR   yes  1   rad2
  case frequency // Hz   Hz   HZ   yes  1   s-1
  case force // N   N   N   yes  1   kg.m/s2
  case pressure // Pa   Pa   PAL   yes  1   N/m2
  case energy //J   J   J   yes  1   N.m
  case power // W   W   W   yes  1   J/s
  case electricCurrent // A   A   A   yes  1   C/s
  case electricPotential //V   V   V   yes  1   J/C
  case electricCapacitance //F   F   F   yes  1   C/V
  case electricResistance   //Ω   Ohm   OHM   yes  1   V/A
  case electricConductance   //S   S   SIE   yes  1   Ohm-1
  case magneticFluxDensity
  case inductance    //
  case illuminance
  case radioactivity
  case energyDose
  case volume    //
  case area
  case acceleration
  case acidity
  case massConcentration
  case level
  case amountOfInformation
  case signalTransmissionRate
  case currency
  public static var defaultValue : KindQuantity {
    return .unknown
  }
  public static var defaultRaw : KindQuantity.RawValue {
    return defaultValue.rawValue
  }
}

let kUnitMeasureReferenceBasePrefix  = "UNIT"
let kUnitMeasureReferenceLength = 3

public final class UnitMeasure : AdoptedModel, Auditable {
  public static var auditID = HistoryDataType.unit.rawValue

  public static var createdAtKey: TimestampKey? { return \.createdAt }
  public static var updatedAtKey: TimestampKey? { return \.updatedAt }
  public static var deletedAtKey: TimestampKey? { return \.deletedAt }
  public static let name = "unit"
  /// Currency  uniq object ID
  public var id             : ObjectID?
  public var ref            : String
  public var base           : BaseUnit?
  public var kind           : KindQuantity
  public var definition     : Double?
  public var symbol         : String
  public var metric         : String?
  public var name           : String

  /// Create date.
  public var createdAt: Date?
  /// Update date.
  public var updatedAt: Date?
  /// Deleted date.
  public var deletedAt: Date?

  public static var defaultValue: UnitMeasure {
    return UnitMeasure(base: BaseUnit.meter, name: "Meter", kind: KindQuantity.length, symbol: "m", metric: "m")
  }

  convenience init() {
    self.init(base: BaseUnit.gram, name: "Gram", kind: KindQuantity.volume, symbol: "g", metric: "g")
  }
  
  public init(base: BaseUnit, name:String, kind: KindQuantity, symbol: String, metric: String?,
              definition: Double? = nil, createdAt : Date = Date(), updatedAt: Date? = nil,
  deletedAt : Date?   = nil, id: ObjectID? = nil) {
    self.id           = id
    self.ref          = Utils.newRef(kUnitMeasureReferenceBasePrefix, size: kUnitMeasureReferenceLength)
    self.base         = base
    self.name         = name
    self.symbol       = symbol
    self.kind         = kind
    self.createdAt    = createdAt
    self.updatedAt    = updatedAt
    self.deletedAt    = deletedAt
  }
}

/// Allows `UnitMeasure` to be used as a Fluent migration.
extension UnitMeasure: Migration {
  /// See `Migration`.
  public static func prepare(on conn: AdoptedConnection) -> Future<Void> {
    let cTable = AdoptedDatabase.create(UnitMeasure.self, on: conn)
    { builder in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ref)
      builder.field(for: \.base)
      builder.field(for: \.kind)
      builder.field(for: \.symbol)
      builder.field(for: \.name)
      builder.field(for: \.metric)
      builder.field(for: \.definition)
      builder.field(for: \.createdAt)
      builder.field(for: \.updatedAt)
      builder.field(for: \.deletedAt)
      builder.unique(on: \.id)
      builder.unique(on: \.ref)
      builder.unique(on: \.name)
    }
    if type(of: conn) == PostgreSQLConnection.self {
      // Only for PostGreSQL DATABASE
      _ = conn.raw("ALTER SEQUENCE \(UnitMeasure.name)_id_seq RESTART WITH 100").run()
    }
    return cTable
  }
  
  public static func revert(on conn: AdoptedConnection) -> Future<Void> {
    return Database.delete(UnitMeasure.self, on: conn)
  }
}

/// Allows `UnitMeasure` to be used as a dynamic parameter in route definitions.
extension UnitMeasure: Parameter { }
