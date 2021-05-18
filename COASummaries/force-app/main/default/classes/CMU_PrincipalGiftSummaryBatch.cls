public with sharing class CMU_PrincipalGiftSummaryBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM AQB__LLChartOfAccounts__c';
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext bc, List<AQB__LLChartOfAccounts__c> records){
        List<AQB__Transaction__c> transactions = new List<AQB__Transaction__c>();

        List<AQB__LLChartOfAccounts__c>  coaTransList =  [SELECT Id, (SELECT Id FROM AQB__Transactions2__r LIMIT 1)
                                                         FROM AQB__LLChartOfAccounts__c];

        For(AQB__LLChartOfAccounts__c coa : coaTransList){

        }



    }    



    global void finish(Database.BatchableContext bc){
        // post-processing
    }        
}