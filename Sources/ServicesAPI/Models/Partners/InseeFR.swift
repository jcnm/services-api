//
//  InseeFR.swift
//  ServicesAPI
//
//  Created by Jacques Charles NJANDA MBIADA on 01/05/2020.
//

import Foundation
import Fluent
import Vapor
import Crypto
/*
 
 {
   "header": {
     "statut": 200,
     "message": "OK"
   },
   "uniteLegale": {
     "siren: String  = ""
     "statutDiffusionUniteLegale: String  = ""
     "dateCreationUniteLegale: String  = ""
     "sigleUniteLegale: String  = ""
     "sexeUniteLegale: String?  = ""
     "prenom1UniteLegale: String?  = ""
     "prenom2UniteLegale: String?  = ""
     "prenom3UniteLegale: String?  = ""
     "prenom4UniteLegale: String?  = ""
     "prenomUsuelUniteLegale: String?  = ""
     "pseudonymeUniteLegale: String?  = ""
     "identifiantAssociationUniteLegale: String?  = ""
     "trancheEffectifsUniteLegale: String  = ""
     "anneeEffectifsUniteLegale: String  = ""
     "dateDernierTraitementUniteLegale": "2019-06-24T14:03:44",
     "nombrePeriodesUniteLegale": 3,
     "categorieEntreprise: String  = ""
     "anneeCategorieEntreprise: String  = ""
     "periodesUniteLegale": [
       {
         "dateFin: String?  = ""
         "dateDebut: String  = ""
         "etatAdministratifUniteLegale: String  = ""
         "changementEtatAdministratifUniteLegale": false,
         "nomUniteLegale: String?  = ""
         "changementNomUniteLegale": false,
         "nomUsageUniteLegale: String?  = ""
         "changementNomUsageUniteLegale": false,
         "denominationUniteLegale: String  = ""
         "changementDenominationUniteLegale": false,
         "denominationUsuelle1UniteLegale: String?  = ""
         "denominationUsuelle2UniteLegale: String?  = ""
         "denominationUsuelle3UniteLegale: String?  = ""
         "changementDenominationUsuelleUniteLegale": false,
         "categorieJuridiqueUniteLegale: String  = ""
         "changementCategorieJuridiqueUniteLegale": true,
         "activitePrincipaleUniteLegale: String  = ""
         "nomenclatureActivitePrincipaleUniteLegale: String  = ""
         "changementActivitePrincipaleUniteLegale": false,
         "nicSiegeUniteLegale: String  = ""
         "changementNicSiegeUniteLegale": true,
         "economieSocialeSolidaireUniteLegale: String  = ""
         "changementEconomieSocialeSolidaireUniteLegale": true,
         "caractereEmployeurUniteLegale: String  = ""
         "changementCaractereEmployeurUniteLegale": false
       },
       {
         "dateFin: String  = ""
         "dateDebut: String  = ""
         "etatAdministratifUniteLegale: String  = ""
         "changementEtatAdministratifUniteLegale": false,
         "nomUniteLegale: String?  = ""
         "changementNomUniteLegale": false,
         "nomUsageUniteLegale: String?  = ""
         "changementNomUsageUniteLegale": false,
         "denominationUniteLegale: String  = ""
         "changementDenominationUniteLegale": false,
         "denominationUsuelle1UniteLegale: String?  = ""
         "denominationUsuelle2UniteLegale: String?  = ""
         "denominationUsuelle3UniteLegale: String?  = ""
         "changementDenominationUsuelleUniteLegale": false,
         "categorieJuridiqueUniteLegale: String  = ""
         "changementCategorieJuridiqueUniteLegale": false,
         "activitePrincipaleUniteLegale: String  = ""
         "nomenclatureActivitePrincipaleUniteLegale: String  = ""
         "changementActivitePrincipaleUniteLegale": false,
         "nicSiegeUniteLegale: String  = ""
         "changementNicSiegeUniteLegale": false,
         "economieSocialeSolidaireUniteLegale: String?  = ""
         "changementEconomieSocialeSolidaireUniteLegale": false,
         "caractereEmployeurUniteLegale: String  = ""
         "changementCaractereEmployeurUniteLegale": true
       },
       {
         "dateFin: String  = ""
         "dateDebut: String  = ""
         "etatAdministratifUniteLegale: String  = ""
         "changementEtatAdministratifUniteLegale": false,
         "nomUniteLegale: String?  = ""
         "changementNomUniteLegale": false,
         "nomUsageUniteLegale: String?  = ""
         "changementNomUsageUniteLegale": false,
         "denominationUniteLegale: String  = ""
         "changementDenominationUniteLegale": false,
         "denominationUsuelle1UniteLegale: String?  = ""
         "denominationUsuelle2UniteLegale: String?  = ""
         "denominationUsuelle3UniteLegale: String?  = ""
         "changementDenominationUsuelleUniteLegale": false,
         "categorieJuridiqueUniteLegale: String  = ""
         "changementCategorieJuridiqueUniteLegale": false,
         "activitePrincipaleUniteLegale: String  = ""
         "nomenclatureActivitePrincipaleUniteLegale: String  = ""
         "changementActivitePrincipaleUniteLegale": false,
         "nicSiegeUniteLegale: String  = ""
         "changementNicSiegeUniteLegale": false,
         "economieSocialeSolidaireUniteLegale: String?  = ""
         "changementEconomieSocialeSolidaireUniteLegale": false,
         "caractereEmployeurUniteLegale: String  = ""
         "changementCaractereEmployeurUniteLegale": false
       }
     ]
   }
 }
  
 {
   "header": {
     public var statut: Int = 200
     public var message: String = ""
   },
   "uniteLegale": {
     public var siren: String  = ""
     public var statutDiffusionUniteLegale: String  = ""
     public var dateCreationUniteLegale: String  = ""
     public var sigleUniteLegale: String? = nil
     public var sexeUniteLegale: String  = ""
     public var prenom1UniteLegale: String  = ""
     public var prenom2UniteLegale: String  = ""
     public var prenom3UniteLegale: String? = nil
     public var prenom4UniteLegale: String? = nil
     public var prenomUsuelUniteLegale: String  = ""
     public var pseudonymeUniteLegale: String? = nil
     public var identifiantAssociationUniteLegale: String? = nil
     public var trancheEffectifsUniteLegale: String? = nil
     public var anneeEffectifsUniteLegale: String? = nil
     public var dateDernierTraitementUniteLegale: String = ""
     public var nombrePeriodesUniteLegale": 3,
     public var categorieEntreprise: String? = nil
     public var anneeCategorieEntreprise: String? = nil
     public var periodesUniteLegale": [
       {
         public var dateFin: String? = nil
         public var dateDebut: String  = ""
         public var etatAdministratifUniteLegale: String  = ""
         public var changementEtatAdministratifUniteLegale: Bool  = true
         public var nomUniteLegale: String  = ""
         public var changementNomUniteLegale: Bool  = false
         public var nomUsageUniteLegale: String? = nil
         public var changementNomUsageUniteLegale: Bool  = false
         public var denominationUniteLegale: String? = nil
         public var changementDenominationUniteLegale: Bool  = false
         public var denominationUsuelle1UniteLegale: String? = nil
         public var denominationUsuelle2UniteLegale: String? = nil
         public var denominationUsuelle3UniteLegale: String? = nil
         public var changementDenominationUsuelleUniteLegale: Bool  = false
         public var categorieJuridiqueUniteLegale: String  = ""
         public var changementCategorieJuridiqueUniteLegale: Bool  = false
         public var activitePrincipaleUniteLegale: String  = ""
         public var nomenclatureActivitePrincipaleUniteLegale: String  = ""
         public var changementActivitePrincipaleUniteLegale: Bool  = false
         public var nicSiegeUniteLegale: String  = ""
         public var changementNicSiegeUniteLegale: Bool  = false
         public var economieSocialeSolidaireUniteLegale: String? = nil
         public var changementEconomieSocialeSolidaireUniteLegale: Bool  = false
         public var caractereEmployeurUniteLegale: String  = ""
         public var changementCaractereEmployeurUniteLegale": false
       },
       {
         "dateFin: String  = ""
         "dateDebut: String  = ""
         "etatAdministratifUniteLegale: String  = ""
         "changementEtatAdministratifUniteLegale: Bool  = false
         "nomUniteLegale: String  = ""
         "changementNomUniteLegale: Bool  = true
         "nomUsageUniteLegale: String? = nil
         "changementNomUsageUniteLegale: Bool  = false
         "denominationUniteLegale: String? = nil
         "changementDenominationUniteLegale: Bool  = false
         "denominationUsuelle1UniteLegale: String? = nil
         "denominationUsuelle2UniteLegale: String? = nil
         "denominationUsuelle3UniteLegale: String? = nil
         "changementDenominationUsuelleUniteLegale: Bool  = false
         "categorieJuridiqueUniteLegale: String  = ""
         "changementCategorieJuridiqueUniteLegale: Bool  = false
         "activitePrincipaleUniteLegale: String  = ""
         "nomenclatureActivitePrincipaleUniteLegale: String  = ""
         "changementActivitePrincipaleUniteLegale: Bool  = true
         "nicSiegeUniteLegale: String  = ""
         "changementNicSiegeUniteLegale: Bool  = true
         "economieSocialeSolidaireUniteLegale: String? = nil
         "changementEconomieSocialeSolidaireUniteLegale: Bool  = false
         "caractereEmployeurUniteLegale: String  = ""
         "changementCaractereEmployeurUniteLegale": true
       },
       {
         "dateFin: String  = ""
         "dateDebut: String  = ""
         "etatAdministratifUniteLegale: String  = ""
         "changementEtatAdministratifUniteLegale: Bool  = false
         "nomUniteLegale: String? = nil
         "changementNomUniteLegale: Bool  = false
         "nomUsageUniteLegale: String? = nil
         "changementNomUsageUniteLegale: Bool  = false
         "denominationUniteLegale: String? = nil
         "changementDenominationUniteLegale: Bool  = false
         "denominationUsuelle1UniteLegale: String? = nil
         "denominationUsuelle2UniteLegale: String? = nil
         "denominationUsuelle3UniteLegale: String? = nil
         "changementDenominationUsuelleUniteLegale: Bool  = false
         "categorieJuridiqueUniteLegale: String  = ""
         "changementCategorieJuridiqueUniteLegale: Bool  = false
         "activitePrincipaleUniteLegale: String? = nil
         "nomenclatureActivitePrincipaleUniteLegale: String? = nil
         "changementActivitePrincipaleUniteLegale: Bool  = false
         "nicSiegeUniteLegale: String? = nil
         "changementNicSiegeUniteLegale: Bool  = false
         "economieSocialeSolidaireUniteLegale: String? = nil
         "changementEconomieSocialeSolidaireUniteLegale: Bool  = false
         "caractereEmployeurUniteLegale: String? = nil
         "changementCaractereEmployeurUniteLegale": false
       }
     ]
   }
 }
 
 
 --- SIRET
 
 {
   "header": {
     "statut": 200,
     "message": "ok"
   },
   "etablissement": {
     public var siren: String  = ""
     public var nic: String  = ""
     public var siret: String  = ""
     public var statutDiffusionEtablissement: String  = ""
     public var dateCreationEtablissement: String  = ""
     public var trancheEffectifsEtablissement: String? = nil
     public var anneeEffectifsEtablissement: String? = nil
     public var activitePrincipaleRegistreMetiersEtablissement: String? = nil
     public var dateDernierTraitementEtablissement: String = ""
     public var etablissementSiege: Bool  = true
     public var nombrePeriodesEtablissement": 3,
     public var uniteLegale": {} ,
     "adresseEtablissement":  {},
     "adresse2Etablissement":  {},
     "periodesEtablissement": []
   }
 }**/


struct HeaderResponse: Content {
  var code: Int = 200
  var message: String = ""
}

/**
*/

public struct SireneEtablissementPeriodeUL: Content {
  public var dateFin: String? = nil  
  public var dateDebut: String = ""
  public var etatAdministratifUniteLegale: String = ""
  public var changementEtatAdministratifUniteLegale: Bool = true
  public var nomUniteLegale: String = ""
  public var changementNomUniteLegale: Bool = false
  public var nomUsageUniteLegale: String? = nil
  public var changementNomUsageUniteLegale: Bool = false
  public var denominationUniteLegale: String? = nil
  public var changementDenominationUniteLegale: Bool = false
  public var denominationUsuelle1UniteLegale: String? = nil
  public var denominationUsuelle2UniteLegale: String? = nil
  public var denominationUsuelle3UniteLegale: String? = nil
  public var changementDenominationUsuelleUniteLegale: Bool = false
  public var categorieJuridiqueUniteLegale: String = ""
  public var changementCategorieJuridiqueUniteLegale: Bool = false
  public var activitePrincipaleUniteLegale: String = ""
  public var nomenclatureActivitePrincipaleUniteLegale: String = ""
  public var changementActivitePrincipaleUniteLegale: Bool = false
  public var nicSiegeUniteLegale: String = ""
  public var changementNicSiegeUniteLegale: Bool = false
  public var economieSocialeSolidaireUniteLegale: String? = nil
  public var changementEconomieSocialeSolidaireUniteLegale: Bool = false
  public var caractereEmployeurUniteLegale: String = ""
  public var changementCaractereEmployeurUniteLegale: Bool = false
}

public struct SireneUL: Content {
  public var siren: String  = ""
  public var statutDiffusionUniteLegale: String                     = ""
  public var dateCreationUniteLegale: String                        = ""
  public var sigleUniteLegale: String?                              = nil
  public var sexeUniteLegale: String                                = ""
  public var prenom1UniteLegale: String                             = ""
  public var prenom2UniteLegale: String                             = ""
  public var prenom3UniteLegale: String?                            = nil
  public var prenom4UniteLegale: String?                            = nil
  public var prenomUsuelUniteLegale: String                         = ""
  public var pseudonymeUniteLegale: String?                         = nil
  public var identifiantAssociationUniteLegale: String?             = nil
  public var trancheEffectifsUniteLegale: String?                   = nil
  public var anneeEffectifsUniteLegale: String?                     = nil
  public var dateDernierTraitementUniteLegale: String               = ""
  public var nombrePeriodesUniteLegale: String                      = ""
  public var categorieEntreprise: String?                           = nil
  public var anneeCategorieEntreprise: String?                      = nil
  public var periodesUniteLegale: [ SireneEtablissementPeriodeUL ]  = []
}

final class Siren: Content {
  var header: HeaderResponse
  var uniteLegal: SireneEtablissement
  
}

struct SireneEtablissementUL: Content {
  public var etatAdministratifUniteLegale: String           = ""
  public var statutDiffusionUniteLegale: String             = ""
  public var dateCreationUniteLegale: String                = ""
  public var categorieJuridiqueUniteLegale: String          = ""
  public var denominationUniteLegale: String?               = ""
  public var sigleUniteLegale: String?                      = ""
  public var denominationUsuelle1UniteLegale: String?       = ""
  public var denominationUsuelle2UniteLegale: String?       = ""
  public var denominationUsuelle3UniteLegale: String?       = ""
  public var sexeUniteLegale: String                        = ""
  public var nomUniteLegale: String                         = ""
  public var nomUsageUniteLegale: String?                   = ""
  public var prenom1UniteLegale: String                     = ""
  public var prenom2UniteLegale: String                     = ""
  public var prenom3UniteLegale: String?                    = ""
  public var prenom4UniteLegale: String?                    = ""
  public var prenomUsuelUniteLegale: String                     = ""
  public var pseudonymeUniteLegale: String?                     = ""
  public var activitePrincipaleUniteLegale: String              = ""
  public var nomenclatureActivitePrincipaleUniteLegale: String  = ""
  public var identifiantAssociationUniteLegale: String?     = ""
  public var economieSocialeSolidaireUniteLegale: String?   = ""
  public var caractereEmployeurUniteLegale: String          = ""
  public var trancheEffectifsUniteLegale: String?           = ""
  public var anneeEffectifsUniteLegale: String?             = ""
  public var nicSiegeUniteLegale: String                    = ""
  public var dateDernierTraitementUniteLegale: Date         = Date()
  public var categorieEntreprise: String?                   = ""
  public var anneeCategorieEntreprise: String               = ""

}
struct SireneAdresseEtablissement: Content {
        
  public var complementAdresse2Etablissement: String?       = nil
  public var numeroVoie2Etablissement: String?              = nil
  public var indiceRepetition2Etablissement: String?        = nil
  public var typeVoie2Etablissement: String?                = nil
  public var libelleVoie2Etablissement: String?             = nil
  public var codePostal2Etablissement: String?              = nil
  public var libelleCommune2Etablissement: String?          = nil
  public var libelleCommuneEtranger2Etablissement: String?  = nil
  public var distributionSpeciale2Etablissement: String?    = nil
  public var codeCommune2Etablissement: String?             = nil
  public var codeCedex2Etablissement: String?               = nil
  public var libelleCedex2Etablissement: String?            = nil
  public var codePaysEtranger2Etablissement: String?        = nil
  public var libellePaysEtranger2Etablissement: String?     = nil
}
struct SirenePeriodeEtablissement: Content {
  public var dateFin: String?     = nil
  public var dateDebut: String    = ""
  public var etatAdministratifEtablissement: String           = ""
  public var changementEtatAdministratifEtablissement: Bool   = true
  public var enseigne1Etablissement: String?            = nil
  public var enseigne2Etablissement: String?            = nil
  public var enseigne3Etablissement: String?            = nil
  public var changementEnseigneEtablissement: Bool      = false
  public var denominationUsuelleEtablissement: String?  = nil
  public var changementDenominationUsuelleEtablissement: Bool  = false
  public var activitePrincipaleEtablissement: String  = ""
  public var nomenclatureActivitePrincipaleEtablissement: String  = ""
  public var changementActivitePrincipaleEtablissement: Bool  = false
  public var caractereEmployeurEtablissement: String  = ""
  public var changementCaractereEmployeurEtablissement: Bool = false

}

struct SireneEtablissement: Content {
       
  public var siren: String  = ""
  public var nic: String  = ""
  public var siret: String  = ""
  public var statutDiffusionEtablissement: String  = ""
  public var dateCreationEtablissement: String  = ""
  public var trancheEffectifsEtablissement: String? = nil
  public var anneeEffectifsEtablissement: String? = nil
  public var activitePrincipaleRegistreMetiersEtablissement: String? = nil
  public var dateDernierTraitementEtablissement: String = ""
  public var etablissementSiege: Bool  = true
  public var nombrePeriodesEtablissement: String = ""
  public var adresseEtablissement : SireneEtablissementPeriodeUL  = SireneEtablissementPeriodeUL()
  public var adresse2Etablissement: SireneAdresseEtablissement    = SireneAdresseEtablissement()
  public var periodesEtablissement: [SirenePeriodeEtablissement]  = []

}

final class Siret: Content {
  
  var header: HeaderResponse
  var etablissement: SireneEtablissement
  
}
