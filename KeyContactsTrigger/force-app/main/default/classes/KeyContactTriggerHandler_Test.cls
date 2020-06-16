@isTest

public without sharing class KeyContactTriggerHandler_Test {


    public static TestMethod void singleTest_PopulateManagers() {
    
        //create Contact
        List<Contact> cons = new List<Contact>();
        Contact con1 = new Contact(lastname = 'test1');
        cons.add(con1);
        Contact con2 = new Contact(lastname = 'test2');
        cons.add(con2);
        Contact con3 = new Contact(lastname = 'test3');
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
        kc3.AQB__Role__c = 'Stewarship Manager';
        kc3.AQB__StartDate__c = date.today()-3650;
        kcs.add(kc3); 

        insert kcs;

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

        //update old managers
        List<AQB__KeyContact__c> updatekcs = new List<AQB__KeyContact__c>();

        kc1.AQB__StartDate__c = date.today();
        updatekcs.add(kc1);

        kc2.AQB__StartDate__c = date.today();
        updatekcs.add(kc2);

        kc3.AQB__StartDate__c = date.today();
        updatekcs.add(kc3);

        update updatekcs;
        
        //delete managers
        List<AQB__KeyContact__c> deletekcs = new List<AQB__KeyContact__c>();
        deletekcs.add(kc1);
        deletekcs.add(kc2);
        deletekcs.add(kc3);
        delete deletekcs;
    }
}