public without sharing class KeyContactsTriggerHandler {
    
    public static void populateManagers(list<AQB__KeyContact__c> recs) {
    set<Id> coaSet = new set<Id>();
        for (AQB__KeyContact__c kc : recs){
            coaSet.add(kc.AQB__RelatedChartofAccountItem__c);
        }
        System.debug('coaSet has: ' + coaSet);

        List<AQB__LLChartOfAccounts__c> coaToUpdate = [SELECT Id, Business_Manager__c, Stewardship_Manager__c, Impact_Manager__c
                                                        FROM AQB__LLChartOfAccounts__c
                                                        WHERE Id IN :coaSet];
        System.debug('coaToUpdate after the query has: ' + coaToUpdate);

        List<AQB__KeyContact__c> allKeyCons = [SELECT Id, AQB__RelatedChartofAccountItem__c, AQB__Role__c, AQB__EndDate__c, AQB__StartDate__c
                                            FROM AQB__KeyContact__c
                                            WHERE AQB__RelatedChartofAccountItem__c IN : coaSet
                                            AND AQB__EndDate__c = NULL 
                                            AND AQB__Role__c IN ('Business Manager', 'Stewardship Manager', 'Impact Manager') ];
        System.debug('allKeyCons after the query has: ' + allKeyCons);


        for (AQB__LLCHartOfAccounts__c coa : coaToUpdate){
            Date newestBiz = date.newinstance(1900, 1, 1);
            Date newestStew = date.newinstance(1900, 1, 1);
            Date newestImp = date.newinstance(1900, 1, 1);
            for(AQB__KeyContact__c k : allKeyCons){
                if(k.AQB__Role__c == 'Business Manager'){
                    if(k.AQB__StartDate__c > newestBiz) {
                        newestBiz = k.AQB__StartDate__c;
                        coa.Business_Manager__c = k.Id;
                    }
                }
                if(k.AQB__Role__c == 'Stewardship Manager'){
                    if(k.AQB__StartDate__c > newestStew) {
                        newestStew = k.AQB__StartDate__c;
                        coa.Stewardship_Manager__c = k.Id;
                    }                    
                }
                if(k.AQB__Role__c == 'Impact Manager'){
                    if(k.AQB__StartDate__c > newestImp) {
                        newestImp = k.AQB__StartDate__c;
                        coa.Impact_Manager__c = k.Id;
                    }                   
                }
            }
        } 
    update coaToUpdate; 
    }
}