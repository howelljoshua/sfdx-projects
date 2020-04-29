@isTest

// you have received a change #1
// you got change #2 from home laptop

public with sharing class FinancialsTriggerHandler_Test {

        
    public static testMethod void FinancialTriggerHandler_Testmethod() {
        //create and insert a Chart of Accounts for setup
        List<AQB__LLChartofAccounts__c> coaList = new List<AQB__LLChartofAccounts__c>();
        AQB__LLChartofAccounts__c coa = new AQB__LLChartOfAccounts__c();
        coa.Name = 'testCOA1';
        coa.AQB__Active__c = TRUE;
        coaList.add(coa);
        insert coaList;


        //create and insert 2 financials on the coa for setup
        List<AQB__Financials__c> finList = new List<AQB__Financials__c>();

        AQB__Financials__c fin1 = new AQB__Financials__c();
        fin1.AQB__ChartofAccountsItem__c = coa.Id;
        fin1.AQB__DateEvaluated__c = date.today()-60;
        fin1.AQB__MarketValue__c = 100000;
        finList.add(fin1);

        AQB__Financials__c fin2 = new AQB__Financials__c();
        fin2.AQB__ChartofAccountsItem__c = coa.Id;
        fin2.AQB__DateEvaluated__c = date.today()-120;
        fin2.AQB__MarketValue__c = 75000;
        finList.add(fin2);

        insert finList;



        Test.startTest();
        //Create and insert a new Financials record that is newer than the existing 2
        
        AQB__Financials__c fin3 = new AQB__Financials__c();
        fin3.AQB__ChartofAccountsItem__c = coa.Id;
        fin3.AQB__DateEvaluated__c = date.today()-30;
        fin3.AQB__MarketValue__c = 150000;
        
        insert fin3;
        System.debug('financial record value after insert: ' + fin3.AQB__MarketValue__c );

        //Update the FInancials record
        fin3.AQB__MarketValue__c = 175000;
        update fin3;
        System.debug('financial record value after update: ' + fin3.AQB__MarketValue__c );

        //Delete the Financial record
        delete fin3;
        System.debug('financial record deleted');

        Test.stopTest();

    }


       
        public static testMethod void FinancialTriggerHandlers_BulkTestmethod() {
        //create and insert 201 Chart of Accounts for setup
        List<AQB__LLChartofAccounts__c> coaList = new List<AQB__LLChartofAccounts__c>();
        for(Integer i=0; i<202; i++){            
            AQB__LLChartofAccounts__c coa = new AQB__LLChartOfAccounts__c();
            coa.Name = 'testCOA'+i;
            coa.AQB__Active__c = TRUE;
            coaList.add(coa);               
        }
        insert coaList; 


        //create and insert 2 financials for each COA (402) for setup
        List<AQB__Financials__c> finList = new List<AQB__Financials__c>();
        for(AQB__LLChartOfAccounts__c c : coaList){

            AQB__Financials__c fin1 = new AQB__Financials__c();
            fin1.AQB__ChartofAccountsItem__c = c.Id;
            fin1.AQB__DateEvaluated__c = date.today()-60;
            fin1.AQB__MarketValue__c = 100000;
            finList.add(fin1);
    
            AQB__Financials__c fin2 = new AQB__Financials__c();
            fin2.AQB__ChartofAccountsItem__c = c.Id;
            fin2.AQB__DateEvaluated__c = date.today()-120;
            fin2.AQB__MarketValue__c = 75000;
            finList.add(fin2);
        }
        insert finList;



        Test.startTest();

        //Create and insert anew Financials record for each coa
        List<AQB__Financials__c> finAddList = new List<AQB__Financials__c>();
        for(AQB__LLChartOfAccounts__c c : coaList){

            AQB__Financials__c fin3 = new AQB__Financials__c();
            fin3.AQB__ChartofAccountsItem__c = c.Id;
            fin3.AQB__DateEvaluated__c = date.today()-30;
            fin3.AQB__MarketValue__c = 150000;
            finAddList.add(fin3);
        }
        insert finAddList;

        //Update the 201 FInancials record by adding 1 day to the DateEval field
        for(AQB__Financials__c f : finAddList) {
            f.AQB__MarketValue__c = 175000;
        }
        update finAddList;


        //Delete all 201 Financial records
        delete finAddList;

        Test.stopTest();
    }
}