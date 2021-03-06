//
//  APIController.swift
//  
//
//  Created by Jacques Charles NJANDA MBIADA on 16/11/2019.
//

import Foundation
import Vapor
import Fluent
import Authentication
import CoreFoundation
import Paginator

/// - MARK - CREATE Sector
public final class APIController {
  static var unitMeasures:[UnitMeasure.ID: UnitMeasure] = [:]
  static var currencies:[Currency.ID:Currency] = [:]
  static var languages:[Language.ID: Language] = [:]

  let partnerController = PartnerController( )
  
  static public func loadCurrencies(_ loop: Container) {
    let req = Request(using: loop)
    let q = Currency.query(on: req)
    q.all().whenSuccess { (currencies) in
      for e in currencies {
        self.currencies[e.id!] = e
      }
    }
  }
  
  static public func loadLanguages(_ loop: Container) {
    let req = Request(using: loop)
    let q = Language.query(on: req)
    q.all().whenSuccess { (languages) in
      for e in languages {
        self.languages[e.id!] = e
      }
    }
  }
  
  static public func loadUnitMeasure(_ loop: Container) {
    let req = Request(using: loop)
    let q = UnitMeasure.query(on: req)
    q.all().whenSuccess { (umeasure) in
      for e in umeasure {
        self.unitMeasures[e.id!] = e
      }
    }
  }

  public init() { }
  
}
/// - MARK - GET  Relative to Partener
extension APIController {
  
  public func inseeFRSirene(_ req: Request, partner: String? = nil) throws -> Future<Sirene> {
    let qPartnerStr: String
    let logger = try  req.make(Logger.self)
    if let p      = partner { qPartnerStr = p } else { qPartnerStr = try req.parameters.next(String.self) }
    let qStr      = try req.parameters.next(String.self)
    guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: qStr)) else {
      let sirHeader = HeaderResponse(statut: 400, message: "Le numero Sirene est mal formé.")
      let sir = Sirene(header: sirHeader)
      return req.future(sir)
    }
    // Create constante siretCountChar and defaultSiretValue
    guard qStr.count == 14 && qStr != "00000000000000" else {
      let sir = Sirene.def
      logger.debug("Default sirene returned")
      return req.future(sir)
    }
    let partner   = partnerController.search(req, qPartnerStr)
    logger.debug("API Controller target \(qStr) searched partener : \(qPartnerStr)")
    
    return partner.flatMap { (part) -> EventLoopFuture<Sirene> in
      let client = try req.client()
      if let p = part {
        let fullUrl = "\(p.mainUrl)\(p.endPointAPI)\(p.asPathParam ? "" : (p.paramQueryName != nil ? "\(p.paramQueryName!)=" : "q="))\(qStr)"
        logger.debug("New client query at: \(fullUrl)")
        let response =
          client.get(fullUrl,
                     headers: HTTPHeaders([("Accept", "application/json"),("Authorization", "Bearer \(p.bearerToken)")]))
          { q in logger.debug("Nothing done before running request to \(fullUrl)") }
        return response.flatMap { (resp) -> EventLoopFuture<Sirene> in
          logger.debug("Returning client response: \(fullUrl)")
          return try resp.content.decode(Sirene.self).flatMap( { (sir) -> EventLoopFuture<Sirene> in
            guard sir.header.statut == 200 else { // If featching siret fail, return the actual response
              return req.future(sir)
            }
            let endClasseURL = "\(p.mainUrl)metadonnees/nomenclatures/v1/codes/nafr2/sousClasse/"
            let endCJURL     = "\(p.mainUrl)metadonnees/nomenclatures/v1/codes/cj/n3/"
            var scAttr: String = sir.uniteLegale?.periodesUniteLegale.first?.activitePrincipaleUniteLegale ?? ""
            var cjAttr: String = sir.uniteLegale?.periodesUniteLegale.first?.categorieJuridiqueUniteLegale ?? ""
            if let siret = sir.etablissement {
              scAttr = siret.uniteLegale.activitePrincipaleUniteLegale
              cjAttr = siret.uniteLegale.categorieJuridiqueUniteLegale
            }
            let classeResp =
              client.get(endClasseURL + scAttr,
                         headers: HTTPHeaders([("Accept", "application/json"),
                                               ("Authorization", "Bearer \(p.bearerToken)")]))
              { q in
                logger.debug("Before running +++++classeResp+++++ request")
                logger.debug(q.http.description); print(q.content)}
            let catJuriResp =
              client.get(endCJURL + cjAttr,
                         headers: HTTPHeaders([("Accept", "application/json"),
                                               ("Authorization", "Bearer \(p.bearerToken)")])){ q in
                                                print("Before running =====catJuriResp===== request")
                                                print(q.http); print(q.content)}
            return classeResp.and(catJuriResp).flatMap { (classResp, catResp) -> EventLoopFuture<Sirene> in
              let (sclassFut, cjFut) =
                try (classResp.content.decode(SireneNomemclature.self), catResp.content.decode(SireneNomemclature.self))
              
              return sclassFut.and(cjFut).map { (sclass, cj) -> Sirene in
                print(sclass); print(cj)
                sir.nomCatJuridiqueN3 = cj.intitule
                sir.nomRev2NAF        = sclass.intitule
                return sir
              }
            }
          })
        }.catchMap { (err) -> Sirene in
          print("enable to read data correctly due to server inert request")
          print(err)
          return Sirene(header: HeaderResponse(statut: 500, message: "Impossible de joindre le partener"))
        }
      } else {
        throw Abort(HTTPResponseStatus.noContent)
      }
    }
  }
  
  public func dataOfPartner<T: Content>(_ req: Request, partner: String? = nil ) throws -> Future<T> {
    let qPartnerStr: String
    if let p      = partner { qPartnerStr = p } else { qPartnerStr = try req.parameters.next(String.self) }
    let qStr      = try req.parameters.next(String.self)
    let partner   = partnerController.search(req, qPartnerStr)
    let logger    = try req.make(Logger.self)
    logger.debug("API Controller target \(qStr) searched partener : \(qPartnerStr)")
    
    return partner.flatMap { (part) -> EventLoopFuture<T> in
      let client = try req.client()
      if let p = part {
        let fullUrl = "\(p.mainUrl)\(p.endPointAPI)\(p.asPathParam ? "" : (p.paramQueryName != nil ? "\(p.paramQueryName!)=" : "q="))\(qStr)"
        logger.debug("New client query at: \(fullUrl)")
        let response =
          client.get(fullUrl,
                     headers: HTTPHeaders([("Accept", "application/json"),("Authorization", "Bearer \(p.bearerToken)")]))
          { q in
            print("Before running request")
            print(q.http);
            print(q.content)
        }
        return response.flatMap { (resp) -> EventLoopFuture<T> in
          logger.debug("Returning client response: \(fullUrl)")
          print(resp.content)
          return try resp.content.decode(T.self)
          
        }
      } else {
        throw Abort(HTTPResponseStatus.noContent)
      }
    }
  }
}

extension APIController: RouteCollection {
  public func boot(router: Router) throws {
    
    /*************************** LOGGED USER SECTION *******************
     ***
     ***
     ***
     *******************************************************************/
    
    // bearer / token auth protected routes
    //    let bearer            = router.grouped(User.tokenAuthMiddleware())
    //    let partnerGroup      = bearer.grouped(Config.APIWEP.partnersWEP)
    
    //    bearer.get(Config.APIWEP.partnersWEP, String.parameter, use: list)
    
  }
}
