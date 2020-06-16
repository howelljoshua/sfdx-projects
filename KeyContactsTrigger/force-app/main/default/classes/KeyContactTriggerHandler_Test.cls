@isTest

public without sharing class KeyContactTriggerHandler_Test {


    public static TestMethod void singleTest_PopulateManagers() {
    
        //create Contact
        List<Contact> cons = new List<Contact>();
        Contact con1 = new Contact(LastName = 'One', FirstName = 'Test');
        cons.add(con1);
        Contact con2 = new Contact(LastName = 'Two', FirstName = 'Test');
        cons.add(con2);
        Contact con3 = new Contact(LastName = 'Three', FirstName = 'Test');
        cons.add(con3);
        insert cons;

        //create Chart of Accounts
        List<AQB__LLChartOfAccounts__c> coas = new List<AQB__LLChartOfAccounts__c>();
        AQB__LLChartofAccounts__c coa1 = new AQB__LLChartOfAccounts__c();
        coa1.Name = 'testCOA1';
        coa1.AQB__Active__c = TRUE;
        coas.add(coa1);
        insert coas;

        //create one of each Manager Key Contact
        List<AQB__KeyContact__c> kcs = new List<AQB__KeyContact__c>();

        AQB__KeyContact__c kc1 = new AQB__KeyContact__c();
        kc1.AQB__RelatedChartofAccountItem__c = coa1.Id;
        kc1.AQB__Contact__c = con1.Id;
        kc1.AQB__Role__c = 'Business Manager';
        kc1.AQB__StartDate__c = date.today()-3650;
        kcs.add(kc1);

        AQB__KeyContact__c kc2 = new AQB__KeyContact__c();
        kc2.AQB__RelatedChartofAccountItem__c = coa1.Id;
        kc2.AQB__Contact__c = con2.Id;
        kc2.AQB__Role__c = 'Impact Manager';
        kc2.AQB__StartDate__c = date.today()-3650;
        kcs.add(kc2);  
        
        AQB__KeyContact__c kc3 = new AQB__KeyContact__c();
        kc3.AQB__RelatedChartofAccountItem__c = coa1.Id;
        kc3.AQB__Contact__c = con3.Id;
        kc3.AQB__Role__c = 'Stewardship Manager';
        kc3.AQB__StartDate__c = date.today()-3650;
        kcs.add(kc3); 

        insert kcs;

        //Test#1 - Query for chart of Accounts and check that Biz Mgr is Contact 1
        AQB__LLChartOfAccounts__c queryCOA  = [SELECT Id, Business_Manager__c, Business_Manager_Name__c
                                              FROM AQB__LLChartOfAccounts__c
                                              WHERE Name = 'TestCOA1'];
        System.assertEquals(queryCOA.Business_Manager_Name__c, 'One, Test');



        //add new managers
        List<AQB__KeyContact__c> newkcs = new List<AQB__KeyContact__c>();

        AQB__KeyContact__c kc4 = new AQB__KeyContact__c();
        kc4.AQB__RelatedChartofAccountItem__c = coa1.Id;
        kc4.AQB__Contact__c = con3.Id;
        kc4.AQB__Role__c = 'Business Manager';
        kc4.AQB__StartDate__c = date.today()-30;
        newkcs.add(kc4);

        AQB__KeyContact__c kc5 = new AQB__KeyContact__c();
        kc5.AQB__RelatedChartofAccountItem__c = coa1.Id;
        kc5.AQB__Contact__c = con2.Id;
        kc5.AQB__Role__c = 'Impact Manager';
        kc5.AQB__StartDate__c = date.today()-30;
        newkcs.add(kc5);

        AQB__KeyContact__c kc6 = new AQB__KeyContact__c();
        kc6.AQB__RelatedChartofAccountItem__c = coa1.Id;
        kc6.AQB__Contact__c = con1.Id;
        kc6.AQB__Role__c = 'Stewardship Manager';
        kc6.AQB__StartDate__c = date.today()-30;
        newkcs.add(kc6);

        insert newkcs;

        //Test#2 - Query for chart of Accounts and check that Biz Mgr was changed to Contact 3
        AQB__LLChartOfAccounts__c queryCOA2  = [SELECT Id, Business_Manager__c, Business_Manager_Name__c
                                               FROM AQB__LLChartOfAccounts__c
                                               WHERE Name = 'TestCOA1'];
        System.assertEquals(queryCOA2.Business_Manager_Name__c, 'Three, Test');


        //update old managers
        List<AQB__KeyContact__c> updatekcs = new List<AQB__KeyContact__c>();

        kc1.AQB__StartDate__c = date.today();
        updatekcs.add(kc1);

        kc2.AQB__StartDate__c = date.today();
        updatekcs.add(kc2);

        kc3.AQB__StartDate__c = date.today();
        updatekcs.add(kc3);

        update updatekcs;


        //Test#3 - Query for chart of Accounts and check that Biz Mgr changed back to Contact 1 after updating the dates
        AQB__LLChartOfAccounts__c queryCOA3  = [SELECT Id, Business_Manager__c, Business_Manager_Name__c
                                              FROM AQB__LLChartOfAccounts__c
                                              WHERE Name = 'TestCOA1'];
        System.assertEquals(queryCOA3.Business_Manager_Name__c, 'One, Test');
        

        
        //delete managers
        List<AQB__KeyContact__c> deletekcs = new List<AQB__KeyContact__c>();
        deletekcs.add(kc1);
        deletekcs.add(kc2);
        deletekcs.add(kc3);
        delete deletekcs;

        //Test#4 - Query for chart of Accounts and check that Biz Mgr was changed to Contact 3 after deleting KC1
        AQB__LLChartOfAccounts__c queryCOA4  = [SELECT Id, Business_Manager__c, Business_Manager_Name__c
                                               FROM AQB__LLChartOfAccounts__c
                                               WHERE Name = 'TestCOA1'];
        System.assertEquals(queryCOA4.Business_Manager_Name__c, 'Three, Test');
    }





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





    public static TestMethod void bulkTest_PopulateManagers() {

        //create contacts
        List<Contact> cons = new List<Contact>();
        for(Integer i=0; i<100; i++){
            Contact con = new Contact(LastName = 'con'+i , FirstName = 'Test');
            cons.add(con);
        }
        insert cons;


        //create Chart of Accounts
        List<AQB__LLChartOfAccounts__c> coas = new List<AQB__LLChartOfAccounts__c>();        
        AQB__LLChartOfAccounts__c coa = new AQB__LLChartOfAccounts__c();
        coas.add(coa);
        insert coas;

        //create KeyContacts, 
        List<AQB__KeyContact__c> kcs = new List<AQB__KeyContact__c>();

        for(Integer i=0; i<100; i++){
            AQB__KeyContact__c kc1 = new AQB__KeyContact__c();
            kc1.AQB__RelatedChartofAccountItem__c = coa.Id;
            kc1.AQB__Contact__c = cons[i].Id;
            kc1.AQB__Role__c = 'Business Manager';
            kc1.AQB__StartDate__c = date.today()-(i*10);
            kcs.add(kc1);
        }
        for(Integer i=0; i<100; i++){
            AQB__KeyContact__c kc2 = new AQB__KeyContact__c();
            kc2.AQB__RelatedChartofAccountItem__c = coa.Id;
            kc2.AQB__Contact__c = cons[i].Id;
            kc2.AQB__Role__c = 'Impact Manager';
            kc2.AQB__StartDate__c = date.today()-(i*10);
            kcs.add(kc2);
        }
        for(Integer i=0; i<100; i++){
            AQB__KeyContact__c kc3 = new AQB__KeyContact__c();
            kc3.AQB__RelatedChartofAccountItem__c = coa.Id;
            kc3.AQB__Contact__c = cons[i].Id;
            kc3.AQB__Role__c = 'Stewardship Manager';
            kc3.AQB__StartDate__c = date.today()-(i*10);
            kcs.add(kc3);
        }
        insert kcs;

        



        
        
    }

}