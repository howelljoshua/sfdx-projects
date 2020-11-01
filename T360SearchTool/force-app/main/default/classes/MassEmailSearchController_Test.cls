/*
 *  Mass Email Search Controller TEST CLASS for MassEmailSearch VisualForcepage Controller and GenerateCSV class
 *  Author: Josh Howell  10/2018
 *  Updated 2/5/19 -- to include additional search parameters for Advance ID -- JH
 *  Update 3/1/19 -- to accomodate new search methods and events -- JH
 *  Update 3/25/19 to test new functionality for regDate, regStatus, noShow -- JH
 *  Test Coverage --  MassEmailSearchController -- covers at 93%
 *  Test Coverage --  MassEmailGenerateCSV -- covers at 87%
 */


@isTest

public class MassEmailSearchController_Test {

    public static testMethod void testController(){
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        String commaSepEmails = '';
        String spaceSepEmails = '';
        String returnSepEmails = '';
        String commaSepAdvIds = '';
        String spaceSepAdvIds = '';
        String returnSepAdvIds = ''; 
        String commaSepCardIds = '';
        String spaceSepCardIds = '';
        String returnSepCardIds = '';  
        String commaSepSFIds = '';
        String spaceSepSFIds = '';
        String returnSepSFIds = '';  
        
        For (Integer i=0; i<101; i++){
            Account a = new Account();
            a.Name = 'Household Account ' + i; 
            a.Type = 'Household';
            a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
            accountList.add(a);
        }
        insert accountList;
        
        for(Account a: accountList){
           Contact c = new Contact(); 
           c.AccountId = a.id;
           c.FirstName = 'First';
           c.LastName = 'Last' + accountList.indexOf(a);                    
           c.AQB__ContactExternalID__c = ( '10000' + accountList.indexOf(a) );
           c.AQB__Type__c = 'Alumni';
           c.AQB__SecondaryType__c = 'Parent'; 
           c.Card_ID__c = ('811909' + accountList.indexOf(a) );
           contactList.add(c);
        }
        insert contactList;


        for(Contact c : contactList){
           c.Email = c.FirstName + c.LastName + '@fakeemail.com';
           commaSepEmails = commaSepEmails + c.Email +',';
           spaceSepEmails = spaceSepEmails + c.Email +' ';
           returnSepEmails = returnSepEmails + c.Email + '\n';
           commaSepAdvIds = commaSepAdvIds + c.AQB__ContactExternalID__c + ',';
           spaceSepAdvIds = spaceSepAdvIds + c.AQB__ContactExternalID__c + ' ';
           returnSepAdvIds = returnSepAdvIds + c.AQB__ContactExternalID__c + '\n';
           commaSepCardIds = commaSepCardIds + c.Card_ID__c + ',';
           spaceSepCardIds = spaceSepCardIds + c.Card_ID__c + ' ';
           returnSepCardIds = returnSepCardIds + c.Card_ID__c + '\n';            
           commaSepSFIds = commaSepSFIds + c.Id + ',';
           spaceSepSFIds = spaceSepSFIds + c.Id + ' ';
           returnSepSFIds = returnSepSFIds + c.Id + '\n';                  
            
        }   
        update contactList;
 

        Campaign camp = new Campaign();    
        camp.Name = 'My Saved Campaign';
        camp.RecordTypeId=Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Contact Communication List').getRecordTypeId();
        camp.IsActive = TRUE;   
        insert camp;
        
        AQB__Event__c event = new AQB__Event__c();
        event.Name = 'My Saved Event';
        event.RecordTypeId = Schema.SObjectType.AQB__Event__c.getRecordTypeInfosByName().get('Institutional Event').getRecordTypeId();
        event.AQB__Status__c = 'Planned';
        event.AQB__StartDateandTime__c = Datetime.now();
        event.AQB__StopDateandTime__c = Datetime.now().addDays(7);
        insert event;        
        
        

    System.Test.startTest();
        
    MassEmailSearchController mesc = new MassEmailSearchController();  
        
    mesc.getSearchTypes();
        
    mesc.searchType = 'Email';
        mesc.input = commaSepEmails;
        mesc.search();

        mesc.input = spaceSepEmails;
        mesc.search();        
        
        mesc.input = returnSepEmails;
        mesc.search();   

        
        Mesc.campOrEventName = 'New Campaign 2019';
        mesc.createCampaign();
   
        
    mesc.searchType = 'AID';
        mesc.input = commaSepAdvIds;
        mesc.search();

        mesc.input = spaceSepAdvIds;
        mesc.search();        
        
        mesc.input = returnSepAdvIds;
        mesc.search();   
        
        mesc.campaignPage();
        mesc.loadCampaigns();
        mesc.getCampaigns();
        mesc.selectedCampaign = 'My Saved Campaign';
        mesc.updateCampaign();


    mesc.searchType = 'CID';
        mesc.input = commaSepCardIds;
        mesc.search();

        mesc.input = spaceSepCardIds;
        mesc.search();        
        
        mesc.input = returnSepCardIds;
        mesc.search();

        mesc.campOrEventName = 'New Event 2019';
        mesc.createEvent();
        
        
    mesc.searchType = '';
        mesc.input = commaSepSFIds;
        mesc.search();
        
        mesc.input = spaceSepSFIds;
        mesc.search();        
        
        mesc.input = returnSepSFIds;
        mesc.search();
                
        mesc.eventPage();
        mesc.loadEvents();
        mesc.getEvents();
        mesc.getRegStatuses();
        mesc.selectedEvent = 'My Saved Event';
        mesc.regDate = System.Date.Today();
        mesc.regStatus = 'Registered';
        mesc.noShow = TRUE;
        mesc.updateEvent();


        
        mesc.beginning();
        mesc.next();
        mesc.previous();
        mesc.last();
        mesc.getDisableNext();
        mesc.getDisablePrevious();
        mesc.resultsHasValues(); 
        
        
        mesc.createCSV();   
        
        
        
        
        
        
        
        
    System.Test.stopTest();          
    }
}