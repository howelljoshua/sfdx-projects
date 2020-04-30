@isTest

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
        //assert #1 - query for a COA, check that the "most recent financials date" = today-60 days
        AQB__LLChartofAccounts__c testCOA1 = [SELECT Id, Most_Recent_Financials_Date__c, 
                                            Most_Recent_Financials__r.AQB__DateEvaluated__c,
                                            Most_Recent_Financials__r.AQB__MarketValue__c
                                            FROM AQB__LLChartofAccounts__c
                                            WHERE Name = 'testCOA1'];

        System.assertEquals(testCOA1.Most_Recent_Financials_Date__c, date.today()-60);                              

        //assert #2 - make sure the "market value" of the related "most recent fin" is 100000
        System.assertEquals(testCOA1.Most_Recent_Financials__r.AQB__MarketValue__c, 100000);






        //Create and insert a new Financials record that is newer than the existing 2        
        AQB__Financials__c fin3 = new AQB__Financials__c();
        fin3.AQB__ChartofAccountsItem__c = coa.Id;
        fin3.AQB__DateEvaluated__c = date.today()-30;
        fin3.AQB__MarketValue__c = 150000;
        
        insert fin3;
        System.debug('financial record value after insert: ' + fin3.AQB__MarketValue__c );

        //assert #3 - query for a COA again, check that the "most recent financials date" is now = today-30 days
        AQB__LLChartofAccounts__c testCOA2 = [SELECT Id, Most_Recent_Financials_Date__c, 
                                            Most_Recent_Financials__r.AQB__DateEvaluated__c,
                                            Most_Recent_Financials__r.AQB__MarketValue__c
                                            FROM AQB__LLChartofAccounts__c
                                            WHERE Name = 'testCOA1'];

        System.assertEquals(testCOA2.Most_Recent_Financials_Date__c, date.today()-30);                              

        //assert #4 - make sure the "market value" of the related "most recent fin" is now 150000
        System.assertEquals(testCOA2.Most_Recent_Financials__r.AQB__MarketValue__c, 150000);






        //Update the Financials record
        fin3.AQB__MarketValue__c = 175000;
        update fin3;
        System.debug('financial record value after update: ' + fin3.AQB__MarketValue__c );

        //assert #5 - query for a COA again, check that the "most recent financials date" is still = today-30 days
        AQB__LLChartofAccounts__c testCOA3 = [SELECT Id, Most_Recent_Financials_Date__c, 
                                            Most_Recent_Financials__r.AQB__DateEvaluated__c,
                                            Most_Recent_Financials__r.AQB__MarketValue__c
                                            FROM AQB__LLChartofAccounts__c
                                            WHERE Name = 'testCOA1'];

        System.assertEquals(testCOA3.Most_Recent_Financials_Date__c, date.today()-30);                              

        //assert #6 - make sure the "market value" of the related "most recent fin" is now 175000
        System.assertEquals(testCOA3.Most_Recent_Financials__r.AQB__MarketValue__c, 175000);
        



        //Delete the Financial record
        delete fin3;
        System.debug('financial record deleted');

        //assert #7 - query for a COA, check that the "most recent financials date" is back to = today-60 days
        AQB__LLChartofAccounts__c testCOA4 = [SELECT Id, Most_Recent_Financials_Date__c, 
                                            Most_Recent_Financials__r.AQB__DateEvaluated__c,
                                            Most_Recent_Financials__r.AQB__MarketValue__c
                                            FROM AQB__LLChartofAccounts__c
                                            WHERE Name = 'testCOA1'];

        System.assertEquals(testCOA4.Most_Recent_Financials_Date__c, date.today()-60);                              

        //assert #8 - make sure the "market value" of the related "most recent fin" is back to 100000
        System.assertEquals(testCOA4.Most_Recent_Financials__r.AQB__MarketValue__c, 100000);

        Test.stopTest();

    }






    ////////////////////////////////////BULK TESTMETHOD//////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////


       
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

        //assert #1 - query for a COA, check that the "most recent financials date" = today-60 days
        AQB__LLChartofAccounts__c testCOA5 = [SELECT Id, Most_Recent_Financials_Date__c, 
                                                Most_Recent_Financials__r.AQB__DateEvaluated__c,
                                                Most_Recent_Financials__r.AQB__MarketValue__c
                                                FROM AQB__LLChartofAccounts__c
                                                WHERE Name = 'testCOA101'];

        System.assertEquals(testCOA5.Most_Recent_Financials_Date__c, date.today()-60);                              

        //assert #2 - make sure the "market value" of the related "most recent fin" is 100000
        System.assertEquals(testCOA5.Most_Recent_Financials__r.AQB__MarketValue__c, 100000);







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

        //assert #3 - query for a COA again, check that the "most recent financials date" is now = today-30 days
        AQB__LLChartofAccounts__c testCOA6 = [SELECT Id, Most_Recent_Financials_Date__c, 
                                                Most_Recent_Financials__r.AQB__DateEvaluated__c,
                                                Most_Recent_Financials__r.AQB__MarketValue__c
                                                FROM AQB__LLChartofAccounts__c
                                                WHERE Name = 'testCOA101'];

        System.assertEquals(testCOA6.Most_Recent_Financials_Date__c, date.today()-30);                              

        //assert #4 - make sure the "market value" of the related "most recent fin" is now 150000
        System.assertEquals(testCOA6.Most_Recent_Financials__r.AQB__MarketValue__c, 150000);




        

        //Update the 201 FInancials record by adding 1 day to the DateEval field
        for(AQB__Financials__c f : finAddList) {
            f.AQB__MarketValue__c = 175000;
        }
        update finAddList;


        //assert #5 - query for a COA again, check that the "most recent financials date" is still = today-30 days
        AQB__LLChartofAccounts__c testCOA7 = [SELECT Id, Most_Recent_Financials_Date__c, 
                                              Most_Recent_Financials__r.AQB__DateEvaluated__c,
                                              Most_Recent_Financials__r.AQB__MarketValue__c
                                              FROM AQB__LLChartofAccounts__c
                                              WHERE Name = 'testCOA101'];

        System.assertEquals(testCOA7.Most_Recent_Financials_Date__c, date.today()-30);                              

        //assert #6 - make sure the "market value" of the related "most recent fin" is now 175000
        System.assertEquals(testCOA7.Most_Recent_Financials__r.AQB__MarketValue__c, 175000);









        //Delete all 201 Financial records
        delete finAddList;



        //assert #7 - query for a COA, check that the "most recent financials date" is back to = today-60 days
        AQB__LLChartofAccounts__c testCOA8 = [SELECT Id, Most_Recent_Financials_Date__c, 
                                            Most_Recent_Financials__r.AQB__DateEvaluated__c,
                                            Most_Recent_Financials__r.AQB__MarketValue__c
                                            FROM AQB__LLChartofAccounts__c
                                            WHERE Name = 'testCOA101'];

        System.assertEquals(testCOA8.Most_Recent_Financials_Date__c, date.today()-60);                              

        //assert #8 - make sure the "market value" of the related "most recent fin" is back to 100000
        System.assertEquals(testCOA8.Most_Recent_Financials__r.AQB__MarketValue__c, 100000);


        Test.stopTest();
    }
}