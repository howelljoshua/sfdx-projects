/*
* Created By: Shivani Bhatia(Appirio)
* Created On: 
* Description: Test class for UpdateAlumniPreferenceController
*/

@isTest
public without sharing class UpdateAlumniPreferenceControllerTest {
    Public static Contact con{get;set;}
    Public static Contact testContact1{get;set;}
    Public static Marketing_Preference__c mpf{get;set;}
    Public static user portalUser{get;set;}
    Public static user guestuser{get;set;}
    
    static{
        con = new Contact();      
        testContact1  = new Contact();
        mpf = new Marketing_Preference__c();
        portalUser = new User();
        guestuser = new User();
    }
    @TestSetup
    public static void createTestData(){
        User owner = TestDataUtil.createUser('System Administrator', false);
        owner.UserRoleId = [SELECT Id 
                            FROM UserRole 
                            WHERE PortalType = 'None' 
                            LIMIT 1].Id;
        insert owner;
        System.runAs(owner){
            //Create user with guestusertype
            guestUser = TestDataUtil.createUser('Guest',false);
            insert guestUser;
            
            //Create Account
            Account testAccount1 = new Account(); 
            testAccount1 = TestDataUtil.getTestAccount(false);
            Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
            testAccount1.RecordTypeId = devRecordTypeId;
            testAccount1.BillingCity = 'test';
            testAccount1.BillingCountry = 'india';
            testAccount1.Preferred_Region_1__c = 'AZ - Phoenix';
            insert testAccount1;
            
            //create con contact associated with Account
            con.LastName = 'TtEest';
            con.AccountId = testAccount1.id;
            
            con.MailingStreet = 'abc';
            con.MailingCity = 'jaipur';
            con.MailingCountry = 'India';
            con.MailingState= 'Goa';
            con.MailingPostalCode = '321';
            insert con;
            con.Email = 'test@gmail.com';
            update con;
            
            //Create Marketing Preference
            Marketing_Preference__c mp1 = new Marketing_Preference__c();
            mp1.Contact__c= con.Id;
            mp1.AB_Tech_Alumni__c = true;
            mp1.Active__c = true;
            insert mp1;
            
            //Create user with portaluser
            String profileid =[SELECT Id FROM Profile where Name = 'CMU Alumni Community User'].id;
            portalUser = TestDataUtil.createPortalUser(profileid,con.id,false);
            insert portalUser; 
            List<PermissionSet> ps = new List<PermissionSet>();
            ps = [SELECT ID From PermissionSet WHERE Name = 'Marketing_Preference_Settings'];
            PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = portalUser.id, PermissionSetId = ps[0].Id);
            insert psa;
            //Creating marketing pref
            mpf =TestDataUtil.createPreferenceRecord(false,con.id);
            mpf.Preferred_Region_2__c = 'AZ - Phoenix';
            mpf.Preferred_Region_3__c = 'AZ - Phoenix';
            insert mpf;
        }
        
        
    }
    //method to fullfill condition for guestuser 
    @isTest
    public static void UpdateAlumniPreferenceControllerTestmethodone(){
        createTestData();
       // System.runAs(guestuser){
            Contact con1 = [SELECT Id ,email,Account.BillingCity,Public_GUID__c FROM Contact  WHERE AccountID != Null LIMIT 1];
            System.runAs(portalUser){
            UpdateAlumniPreferenceController.getAllFieldsNew(con1.Public_GUID__c);
            }
            Set<String> mpAllFields = UpdateAlumniPreferenceController.getAllFields();
            String commaSepratedFields = '';
            for(String fieldName : mpAllFields){
                if(commaSepratedFields == null || commaSepratedFields == ''){
                    commaSepratedFields = fieldName;
                }else{
                    commaSepratedFields = commaSepratedFields + ', ' + fieldName;
                }
            } 
            
            Marketing_Preference__c oldMP = database.query('select ' + commaSepratedFields + ' from ' + 'Marketing_Preference__c LIMIT 1');
            System.runAs(guestuser){
            UpdateAlumniPreferenceController.getRegionValues();
            UpdateAlumniPreferenceController.getAllFieldsNew(con1.Public_GUID__c);
            UpdateAlumniPreferenceController.updatePrefNew(oldMP);
            UpdateAlumniPreferenceController.AlumniPreferenceWrapperClass wrapper1=
                UpdateAlumniPreferenceController.getAlumniPreference(con1.Public_GUID__c);
            
            //asserts
            System.assertEquals(wrapper1.conId, con1.id);
            System.assertEquals(wrapper1.accId, con1.AccountId);
            System.assertEquals(wrapper1.conEmail, con1.Email);
            
            //calling method to full fill if condition at if(conList.isEmpty()) 
            UpdateAlumniPreferenceController.AlumniPreferenceWrapperClass wrapper2=
                UpdateAlumniPreferenceController.getAlumniPreference('fakepublicguidc');
            System.assertEquals(wrapper2.errorMessage , System.Label.ContactMissingError);
            
            //calling method to full fill else condition of  if(!String.isBlank(guid))
            UpdateAlumniPreferenceController.AlumniPreferenceWrapperClass wrapper3=
                UpdateAlumniPreferenceController.getAlumniPreference(' ');
            System.assertEquals(wrapper3.errorMessage , System.Label.ContactMissingError);
        }
    }
    //method to fullfill condition for without guestuser 
    @isTest
    public static void UpdateAlumniPreferenceControllerTestmethodtwo(){
        //createTestData();
        //System.runAs(portalUser){
        //
        //Create Account
            Account testAccount1 = new Account(); 
            testAccount1 = TestDataUtil.getTestAccount(false);
            testAccount1.BillingCity = 'test';
            testAccount1.BillingCountry = 'india';
            testAccount1.Preferred_Region_1__c = 'AZ - Phoenix';
            insert testAccount1;
            
            //create con contact associated with Account
            con.LastName = 'TtEest';
            con.AccountId = testAccount1.id;
            con.MailingStreet = 'abc';
            con.MailingCity = 'jaipur';
            con.MailingCountry = 'India';
            con.MailingState= 'Goa';
            con.MailingPostalCode = '321';
            insert con;
            con.Email = 'test@gmail.com';
            update con;
            
        
        Test.startTest();    
            List<Contact> conList = [SELECT Id, Name, Email, accountId, account.BillingAddress, account.Preferred_Region_1__c,account.Preferred_Region_2__c, account.Preferred_Region_3__c
                                     ,Public_GUID__c FROM Contact];
            UpdateAlumniPreferenceController.getAlumniPreference(conList[0].Public_GUID__c);
            Map<String, Schema.FieldSet> FsMap = Schema.SObjectType.Marketing_Preference__c.fieldSets.getMap();
            for(String s : FsMap.keyset())
            {
                UpdateAlumniPreferenceController.getFieldSetMember(s); 
            }
            
            //UpdateAlumniPreferenceController.getStatesAndCountries();
            
            UpdateAlumniPreferenceController.updateAlumniBio(con.email,con.email,con.id,con.AccountId);
            List<Case> caselist = [SELECT ID,COntactID,AccountID FROM Case WHERE AccountId =: con.AccountId AND COntactID = :con.id];
            //System.assertEquals(caselist.size(), 1);
            //delete caselist;
            UpdateAlumniPreferenceController.updateAlumniAddress(con.OtherStreet,con.OtherCity,con.OtherState,con.OtherCountry,con.OtherPostalCode,
                                                                 con.OtherStreet,con.OtherCity,con.OtherState,con.OtherCountry,con.OtherPostalCode,
                                                                 con.id,con.AccountId,'Home');
            List<Case> caselist1 = [SELECT ID,COntactID,AccountID FROM Case WHERE AccountId =: con.AccountId AND COntactID = :con.id];
            //System.assertEquals(caselist1.size(), 2);   
        Test.stopTest();
        //}
    }
        @isTest
    public static void checkUpdatePreference() {
                User owner = TestDataUtil.createUser('System Administrator', false);
        owner.UserRoleId = [SELECT Id 
                            FROM UserRole 
                            WHERE PortalType = 'None' 
                            LIMIT 1].Id;
        insert owner;
        System.runAs(owner){
      Contact con = [SELECT Id
                          FROM Contact
                          LIMIT 1];
            Marketing_Preference__c oldPref = [SELECT Id, Active__C, AB_Tech_Alumni__c, Contact__C
                                           FROM Marketing_Preference__c
                                              WHERE Active__c = true limit 1];
            
            Marketing_Preference__c mp2 = new Marketing_Preference__c();
            mp2.Contact__c= con.Id;
            mp2.AB_Tech_Alumni__c = true;
            insert mp2;
            
            UpdateAlumniPreferenceController.getClonedRecord('' + con.Id, null, new Marketing_Preference__c());
            UpdateAlumniPreferenceController.getClonedRecord('' + con.Id, mp2.Id, new Marketing_Preference__c());
            
            //String str = UpdateAlumniPreferenceController.getClonedRecord(con.Id, oldPref.Id, mp2);
            
        }
    }
}