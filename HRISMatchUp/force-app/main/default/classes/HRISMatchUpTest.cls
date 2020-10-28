@isTest

public with sharing class HRISMatchUpTest {

    public static TestMethod void HRISMatchUp_SingleTest() {

        //create 2 accounts
        List<Account> acctList = new List<Account>();
        Account acct1 = new Account();
        acct1.Name = 'sample1';
        acctList.add(acct1);

        Account acct2 = new Account();
        acct2.Name = 'sample2';
        acctList.add(acct2);

        insert acctList;

        //create 2 contacts
        List<Contact> conList = new List<Contact>();
        Contact con1 =  new Contact();        
        con1.Account = acct1;
        con1.lastName = acct1.Name;
        conList.add(con1);

        Contact con2 =  new Contact();        
        con2.Account = acct2;
        con2.lastName = acct2.Name;
        conList.add(con2);

        insert conList;

        //create 2 HRIS Ids
        List<AQB__AlternateId__c> altIdsList =  new List<AQB__AlternateId__c>();
        AQB__AlternateId__c altId1 = new AQB__AlternateId__c();
        altId1.AQB__ContactReferenced__c = con1.Id;
        altId1.AQB__Type__c = 'HRIS ID';
        altId1.AQB__NonuniqueAlternateId__c = '00000';
        altId1.AQB__AlternateID__c = '0000000000HRI00000';
        altIdsList.add(altId1);

        AQB__AlternateId__c altId2 = new AQB__AlternateId__c();
        altId2.AQB__ContactReferenced__c = con2.Id;
        altId2.AQB__Type__c = 'HRIS ID';
        altId2.AQB__NonuniqueAlternateId__c = '00001';
        altId2.AQB__AlternateID__c = '0000000000HRI00001';   
        altIdsList.add(altId2);

        insert altIdsList; 

        //create a proposal
        SPARCS_Proposal__c sp = new SPARCS_Proposal__c();
        sp.Name = 'SampleProp';
        sp.Principal_Investigator_Employee_ID__c = '00000';
        sp.Research_Coordinator_Employee_ID__c = '00001';      
        
        Test.StartTest();

            //INSERT TEST......................................................
            insert sp;
            sp = [SELECT Id, Principal_Investigator__c, Research_Coordinator__c 
                  FROM SPARCS_Proposal__c WHERE Id = :sp.Id];     
            System.AssertEquals(sp.Principal_Investigator__c, con1.Id);     
            System.AssertEquals(sp.Research_Coordinator__c, con2.Id);

            //EDIT TEST........................................................
            sp.Principal_Investigator_Employee_ID__c = '00001';
            sp.Research_Coordinator_Employee_ID__c = '00000';   
            update sp;
            sp = [SELECT Id, Principal_Investigator__c, Research_Coordinator__c 
                 FROM SPARCS_Proposal__c WHERE Id = :sp.Id];

            System.AssertEquals(sp.Principal_Investigator__c, con2.Id);
            System.AssertEquals(sp.Research_Coordinator__c, con1.Id);            

        Test.stopTest();
    }




    public static TestMethod void HRISMatchup_BulkTest() {

        List<Contact> conList = new List<Contact>();

        for (Integer i=0; i<201; i++){
            Contact con =  new Contact();        
            //con.Account = acctList[i];
            con.lastName = 'test'+i;
            conList.add(con); 
        }
        insert conList;


        Test.startTest();

            List<AQB__AlternateId__c> altIdsList =  new List<AQB__AlternateId__c>();
            List<SPARCS_Proposal__c> spList = new List<SPARCS_Proposal__c>();

            for (Contact c : conList){
                AQB__AlternateId__c altId = new AQB__AlternateId__c();
                altId.AQB__ContactReferenced__c = c.Id;
                altId.AQB__Type__c = 'HRIS ID';
                altId.AQB__NonuniqueAlternateId__c = '000' + c.LastName;
                altId.AQB__AlternateID__c = '0000000000HRI' + c.LastName;
                altIdsList.add(altId);    


                SPARCS_Proposal__c sp = new SPARCS_Proposal__c();
                sp.Name = 'SampleProp' + c.LastName;
                sp.Principal_Investigator_Employee_ID__c = '000' + c.LastName;
                spList.add(sp);
            }
            insert altIdsList;
            insert spList;

        Test.StopTest();
    }
}