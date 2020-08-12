/**================================================================
* Appirio, Inc
* @description Test Class for OpportunityHandler 
* @date: 12 Oct 2018
* @author: Divyanshi Sharma (Appirio)
*
* Date Modified      Modified By            Description of the update
* CLASS HEADER COMMENTS - OpptyTMHandlerTest.cls
* 12 Oct 2018        Divyanshi Sharma        T-741212, Created new test class for OpptyTMHandler
* 26 Nov 2018        Deepanshu Soni          Increased coverage from 60 to 88 of OpportunityHandler
*==================================================================*/
//T-744903
//Update @isTest(seeAllData = true) to @isTest(seeAllData = false)
@isTest(seeAllData = false)
private class OpptyTMHandlerTest {
    static testMethod void testFollowRecord() {
        
    //Profile
    Profile testProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    
    //Insert User
    User testUser1 = new User(Alias = 'standt1', Email='stdUser0@testingorg.com', 
    EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = testProfile.Id, 
    TimeZoneSidKey='America/Los_Angeles', UserName='stdUser0@testingorg.com');
    
    User testUser2 = new User(Alias = 'standt2', Email='stdUser2@testingorg.com', 
    EmailEncodingKey='UTF-8', LastName='Test2', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = testProfile.Id, 
    TimeZoneSidKey='America/Los_Angeles', UserName='stdUser2@testingorg.com');
    insert new List<User>{testUser1, testUser2};
    
    Id corpTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Corporation').getRecordTypeId();
    Id orgTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId(); 
    
    List<Account> accList = new List<Account>();   
    //Create Account
    Account accRecord = new Account();
    accRecord.RecordTypeId=corpTypeId;
    accRecord.Name = 'test Account';
    accList.add(accRecord);
    
    Account accRecord2 = new Account();
    accRecord2.RecordTypeId=orgTypeId;
    accRecord2.Name = 'test Account2';
    accList.add(accRecord2);
    
    Account accRecord1 = new Account();
    accRecord1.Name = 'test Account 1';
    insert accRecord1;
    
    insert accList;
    OpportunityHandler.emailHelpDesk(accList);
    //Insert Account Team Members
    
    AQB__PMTeam__c abqPMRecord = new AQB__PMTeam__c();
    abqPMRecord.AQB__Account__c = accList.get(0).Id;
    abqPMRecord.AQB__Role__c = 'Contract Officer';
    abqPMRecord.AQB__User__c = testUser1.Id;
    insert abqPMRecord;
    
    AQB__PMTeam__c abqPMRecord2 = new AQB__PMTeam__c();
    abqPMRecord2.AQB__Account__c = accList.get(1).Id;
    abqPMRecord2.AQB__Role__c = 'Contract Officer';
    abqPMRecord2.AQB__User__c = testUser2.Id;
    insert abqPMRecord2;
    
    //Create Contact
    Contact conRecord = new Contact();
    conRecord.LastName = 'test Contact record';
    conRecord.AccountId = accList.get(0).Id;
    insert conRecord;
    
    //Create Internal Internal_Consortium__c
    Internal_Consortium__c consortium = new Internal_Consortium__c();
    consortium.Consortium__c = accList.get(0).Id;
    consortium.Name = 'Test Consortium';
    insert consortium;
    
    Internal_Consortium__c consortium2 = new Internal_Consortium__c();
    consortium2.Consortium__c = accList.get(1).Id;
    consortium2.Opportunity_Total__c = 1;
    consortium2.Name = 'Test2 Consortium';
    insert consortium2;
    
    List<Opportunity> opptyList= new List<Opportunity>();
    Id OpportunitySponsorTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Sponsored Research Agreements').getRecordTypeId();
    //Create Opportunity 
    Opportunity oppRecord = new Opportunity();
    oppRecord.RecordTypeId = OpportunitySponsorTypeId;
    oppRecord.Prime_Sponsor__c = accList.get(1).Id;
    oppRecord.Private__c = true;
// Field Deleted I-352919  oppRecord.Direct_Sponsor__c=accRecord1.Id;
    oppRecord.Opportunity_Sub_type__c='RPS';
    oppRecord.AccountId = accList.get(0).Id;
    oppRecord.Name = 'test Opportunity';
    oppRecord.StageName = 'Prospecting';
    oppRecord.Amount=100;
    oppRecord.Opportunity_Sub_type__c = 'Master - Funded';
    oppRecord.CloseDate = Date.newInstance(2019,7,23);
    oppRecord.Consortium__c=consortium.Id;
    opptyList.add(oppRecord);
    //insert oppRecord;
    
    Id OpportunityCareerTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Career/Recruiting').getRecordTypeId();
    //Create Opportunity 
    Opportunity oppRecord2 = new Opportunity();
    oppRecord2.RecordTypeId = OpportunityCareerTypeId;
   // oppRecord2.Prime_Sponsor__c = accList.get(1).Id;
    oppRecord2.Private__c = true;
// Field Deleted I-352919  oppRecord.Direct_Sponsor__c=accRecord1.Id;
    oppRecord2.AccountId = accList.get(0).Id;
    oppRecord2.Name = 'test Opportunity';
    oppRecord2.StageName = 'Prospecting';
    oppRecord2.Amount=100;
    oppRecord2.Opportunity_Sub_type__c = 'Fee based';
    oppRecord2.CloseDate = Date.newInstance(2019,7,23);
    oppRecord2.Consortium__c=consortium2.Id;
    opptyList.add(oppRecord2);
    //insert oppRecord2;
    
    insert opptyList;
    
    Test.startTest();
    opptyList.get(0).Private__c = false;
    //oppRecord.Prime_Sponsor__c = accRecord1.id;
    update oppRecord;
    
    opptyList.get(0).Private__c = true;
    update oppRecord;
    
    consortium2.Opportunity_Total__c = 2;
    update consortium2;
    
    oppRecord.Amount=10;
    update oppRecord;
    //Insert User
    User testUser = new User(Alias = 'standt', Email='stdUser01@testingorg.com', 
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = testProfile.Id, 
    TimeZoneSidKey='America/Los_Angeles', UserName='stdUser01@testingorg.com');
    insert testUser;
     
     List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
    //Create Opportunity Team Members
    OpportunityTeamMember opptyTeamMember = new OpportunityTeamMember();
    opptyTeamMember.OpportunityId = oppRecord.Id;
    opptyTeamMember.UserId = testUser.Id;
    otmList.add(opptyTeamMember);
    insert otmList;
    
    delete abqPMRecord;
    Test.stopTest();
    //Assert
    
    Opportunity assertOpportunity = [SELECT Id,Consortium__c FROM Opportunity WHERE Id = :oppRecord.Id];
    System.assertEquals(consortium.Id, assertOpportunity.Consortium__c, 'The Opportunity consortium should have been set to the consortium the Test consortium.');
    
    List<OpportunityTeamMember> assertOpportunityTeamMembers =[SELECT id,UserId from OpportunityTeamMember WHERE OpportunityId=: assertOpportunity.Id];
    System.assert(assertOpportunityTeamMembers.size() > 1, 'The Opportunity TeamMember should have been set to the User testUser.');
    
    }

}