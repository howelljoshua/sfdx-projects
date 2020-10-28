public with sharing class HRISMatchUp {

    public static void matchUp(List<SPARCS_Proposal__c> props) {
        Map<SPARCS_Proposal__c, String> investigators = new Map<SPARCS_Proposal__c,String>();
        Map<SPARCS_Proposal__c, String> researchers = new Map<SPARCS_Proposal__c,String>();

        for (SPARCS_Proposal__c prop : props) {
            if(prop.Principal_Investigator_Employee_ID__c != NULL){
                investigators.put(prop, prop.Principal_Investigator_Employee_ID__c);
            }
            if(prop.Research_Coordinator_Employee_ID__c != NULL){
                researchers.put(prop, prop.Research_Coordinator_Employee_ID__c);
            }
        }
        
        List<AQB__AlternateID__c> invResults =  [SELECT Id, AQB__ContactReferenced__c, AQB__NonuniqueAlternateId__c	
                                                FROM AQB__AlternateID__c
                                                WHERE AQB__NonuniqueAlternateId__c IN : investigators.values()
                                                AND AQB__Type__c = 'HRIS ID'
                                                AND AQB__AlternateID__c LIKE '%HRI%' ];

        List<AQB__AlternateID__c> resResults =  [SELECT Id, AQB__ContactReferenced__c, AQB__NonuniqueAlternateId__c	
                                                FROM AQB__AlternateID__c
                                                WHERE AQB__NonuniqueAlternateId__c IN : researchers.values()
                                                AND AQB__Type__c = 'HRIS ID'
                                                AND AQB__AlternateID__c LIKE '%HRI%' ];                                       

        for(AQB__AlternateID__c altId : invResults){
            for(SPARCS_Proposal__c sp : investigators.keyset() ){
                if(altId.AQB__NonuniqueAlternateId__c == sp.Principal_Investigator_Employee_ID__c){            
                    sp.Principal_Investigator__c = altId.AQB__ContactReferenced__c;
                }
            }
        }

        for(AQB__AlternateID__c altId : resResults){
            for(SPARCS_Proposal__c sp : researchers.keyset() ){
                if(altId.AQB__NonuniqueAlternateId__c == sp.Research_Coordinator_Employee_ID__c){
                    sp.Research_Coordinator__c = altId.AQB__ContactReferenced__c;
                }
            }
        }
    }
}
