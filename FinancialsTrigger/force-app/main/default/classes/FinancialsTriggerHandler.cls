public without sharing class FinancialsTriggerHandler {

    public static void findMostRecentFinancials(List<AQB__Financials__c> recs ){
    Set<Id> coaSet = new Set<Id>(); 
 
        for(AQB__Financials__c f : recs){
            coaSet.add(f.AQB__ChartofAccountsItem__c);
        }

        List<AQB__LLChartOfAccounts__c> coaToUpdate = [SELECT Id, Most_Recent_Financials__c
                                                       FROM AQB__LLChartOfAccounts__c
                                                       WHERE Id IN :coaSet];


        List<AQB__Financials__c> allFins = [SELECT Id, AQB__DateEvaluated__c, AQB__ChartofAccountsItem__c  
                                            FROM AQB__Financials__c
                                            WHERE AQB__ChartOfAccountsItem__c IN :coaSet];

                                            
        for(AQB__LLChartofAccounts__c ca : coaToUpdate){
            Date newest = date.newinstance(1900, 1, 1);
            for(AQB__Financials__c fin : allFins){
                if (fin.AQB__ChartOfAccountsItem__c == ca.Id){
                    if(fin.AQB__DateEvaluated__c > newest){
                        newest = fin.AQB__DateEvaluated__c;
                        ca.Most_Recent_Financials__c = fin.Id;
                    }
                }
            }
        }
        update coaToUpdate;
    }
}