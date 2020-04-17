//
//  ExistingContact.swift
//  services
//
//  Created by Jacques Charles NJANDA MBIADA on 30/03/2020.
//


import Foundation
import Vapor
import FluentPostgreSQL
import Authentication


struct ExistingContact: Migration {
  typealias Database = AdoptedDatabase
  
  static func prepare(on connection: AdoptedConnection) -> Future<Void> {
      
      let cont2 = Contact(givenName: "Jacques Charles", familyName: "NJANDA MBIADA", nickname: "jcnm", urlAddresses: [], places: [], jobTitle: "Lead Developer", birthday: Date(rfc1123: "Sun, 06 Nov 1994 08:49:37 GMT"), id: 2)
      cont2.urlAddresses?.append(NamedURI(label: "corp", value: "https://sylorion.com"))
      cont2.phoneNumbers?.append(NamedURI(label: "work", value: "+33123578654"))
      cont2.places?.append(Place(label: "To complet", number: "95", kind: .street, street: "Du capitaine guynemer", city: "Courbevoie", state: "Ile de france", postalCode: "92400", country: "France"))
      
      let cont3 = Contact(givenName: "Some one ", familyName: "Simple counter", emailAddresses: [], id: 3)
      cont3.emailAddresses?.append(NamedEmail(label: "work", value: "jcnm@services.cm"))

      _ = cont2.create(on: connection).transform(to: ())
      _ = cont3.create(on: connection).transform(to: ())
    
    return .done(on: connection)
  }
  
  static func revert(on connection: AdoptedConnection) -> Future<Void> {
    let _ = Contact.query(on: connection).filter(\Contact.id == 2).delete()
    let _ = Contact.query(on: connection).filter(\Contact.id == 3).delete()
    return .done(on: connection)
  }
}

