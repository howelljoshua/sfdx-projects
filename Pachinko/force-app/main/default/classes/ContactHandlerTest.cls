/**
 * Created by lucasd on 6/24/2019.
 */
@isTest
global class ContactHandlerTest {

    global static testMethod void testMarketingPrefs(){
        Account a = new Account();
        a.Name = 'Account '+ 1;
        a.Type = 'Household';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        system.debug('Account record type up top -> ' + Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());
        insert a;

        Account a2 = new Account();
        a2.Name = 'Account '+ 1;
        a2.Type = 'Organization';
        a2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        insert a2;

        Contact c = new Contact();
        c.FirstName = 'test';
        c.LastName = 'contact';
        c.Account = a;
        c.AQB__DoNotContact__c = true;
        insert c;

        Contact c2 = new Contact();
        c2.FirstName = 'test';
        c2.LastName = 'contact2';
        c2.AccountId = a.Id;
        c2.AQB__DoNotSolicit__c = true;
        insert c2;

        Contact c3 = new Contact();
        c3.FirstName = 'test';
        c3.LastName = 'contact2';
        c3.Account = a2;
        insert c3;

        Contact c4 = new Contact();
        c4.FirstName = 'test';
        c4.LastName = 'contact2';
        c4.AccountId = a.Id;
        insert c4;

        AQB__Education__c edu = new AQB__Education__c();
        edu.AQB__CONTACT__c = c4.Id;
        edu.AQB__SCHOOL__c = 'Tepper School of Business';
        edu.AFFILIATED_SCHOOL__c = 'Tepper School of Business';
        edu.Status__c = 'Completed';
        insert edu;

        c4.AQB__EducationLink__c = edu.Id;
        update c4;

        Contact c5 = new Contact();
        c5.FirstName = 'test';
        c5.LastName = 'contact2';
        c5.AccountId = a.Id;
        c5.AQB__Type__c = 'Past Parent';
        insert c5;

        Contact c6 = new Contact();
        c6.FirstName = 'test';
        c6.LastName = 'contact2';
        c6.AccountId = a.Id;
        c6.AQB__Type__c = 'Student';
        insert c6;

        AQB__Education__c edu2 = new AQB__Education__c();
        edu2.AQB__CONTACT__c = c6.Id;
        edu2.AQB__SCHOOL__c = 'Heinz College';
        edu2.AFFILIATED_SCHOOL__c = 'Heinz College';
        edu2.Status__c = 'Completed';
        insert edu2;

        c6.AQB__EducationLink__c = edu2.Id;
        update c6;
        
    }

    global static testMethod void testCommunityUserUpdate(){
        Test.enableChangeDataCapture();
        SVNSUMMITS_TestUtil.createUsers(1, 'CMU Alumni Community User');

        Contact c = [SELECT Id, AQB__Type__c from Contact limit 1];
        c.AQB__Type__c = 'Alumni';
        update c;
        Test.getEventBus().deliver();

    }

}