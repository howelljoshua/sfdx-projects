/* 
*
* Apex Test Data Factory for generating necessary objects in test classes.
*
* 11/29/2018    Michael Steptoe (Sleek)
*/
@IsTest
public class AQCMU_TestDataFactory {
    
    /*  
    * Creates a list of User records that have not been inserted
    *  
    * @param count an Integer for the number of records to create
    * @param profileName a String of the profile name to associate to the users
    * @return a List of User records that have not been inserted
    */
    public static List<User> createUsers(Integer count, String profileName) {
        List<User> users = new List<User>();
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id;
        
        for(Integer i = 0; i < count; i++){
            users.add(
                new User(
                    Username = 'test.user' + i + '@testuser.com',
                    Email = 'test.user' + i + '@testuser.com',
                    FirstName = 'Test',
                    LastName = 'User ' + i,
                    Alias = 'tUser' + i,
                    ProfileId = profileId,
                    TimeZoneSidKey = 'America/Phoenix',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US'
                )
            );
        }
        
        return users;
    }

    /*  
    * Creates a list of Account records that have not been inserted
    *  
    * @param count an Integer for the number of records to create
    * @param accountType a String of the type of accounts to create
    * @param recordTypeDevName a String of the record type developer name for the records
    * @return a List of Account records that have not been inserted
    */
    public static List<Account> createAccounts(Integer count, String accountType, String recordTypeDevName){
        List<Account> accounts = new List<Account>();
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
        
        for(Integer i = 0; i < count; i++){
            accounts.add(
                new Account(
                    Name = 'TEST Account ' + i,
                    AQB__AccountStatus__c = 'Active',
                    AQB__AccountType__c = accountType,
                    RecordTypeId = recordTypeId
                )
            );
        }
        
        return accounts;
    }
    
    /*  
    * Creates a list of Contact records
    *  
    * @param count an Integer for the number of records to create
    * @param accts a List of Accounts to associate the Contacts created to
    * @param startAge an Integer for the age of the Contacts. Default 50 if <= 0 is provided
    * @return a List of Contact records that have not been inserted
    */
    public static List<Contact> createContacts(Integer count, List<Account> accts, Integer startAge){
        List<Contact> contacts = new List<Contact>();
        Integer modByAcct = accts.size();
        Integer defaultAge = startAge < 1 ? 50 : startAge;

        for(Integer i = 0; i < count; i++){
            if(defaultAge < 100){
                defaultAge++;
            }
            contacts.add(
                new Contact(
                    FirstName = 'Test',
                    LastName = 'Contact ' + i,
                    Email = 'test.contact' + i + '@testcontact.com',
                    AccountId = accts.get(Math.mod(i, modByAcct)).Id,
                    Birthdate = Date.today().addDays(-1) - Math.round(365.2425 * defaultAge)
                )
            );
        }
        
        return contacts;
    }
    
    /*  
    * Creates a list of Prospect Ratings records that have not been inserted
    *  
    * @param count an Integer for the number of records to create
    * @param accts a List of Accounts to associate the Prospect Ratings created to
    * @param recordTypeDevName a String of the record type developer name for the records
    * @return a List of Prospect_Rating__c records that have not been inserted
    */
    public static List<Prospect_Rating__c> createProspectRatings(Integer count, List<Account> accts, String recordTypeDevName){
        List<Prospect_Rating__c> prospectRatings = new List<Prospect_Rating__c>();
        Id recordTypeId = Schema.SObjectType.Prospect_Rating__c.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
        Integer modByAcct = accts.size();
        
        if(modByAcct > 0){
            for(Integer i = 0; i < count; i++){
                Prospect_Rating__c prospectRating = new Prospect_Rating__c(
                    Account__c = accts.get(Math.mod(i, modByAcct)).Id,
                    recordTypeId = RecordTypeId,
                    Start_Date__c = Date.today() - 7
                );
                
                if(recordTypeDevName == AQCMU_Util.CAPACITY_RATING_RECORD_TYPE_DEV_NAME){
                    prospectRating.Capacity_Rating__c = '$10,000-24,999';
                }
                else if(recordTypeDevName == AQCMU_Util.CAMPAIGN_TARGET_RECORD_TYPE_DEV_NAME) {
                    prospectRating.Campaign_Target__c = 1000;
                }
                prospectRatings.add(prospectRating);
            }
        }
        
        return prospectRatings;
    }
    
    /*  
    * Creates a Campaign record that has not been inserted
    *  
    * @param name an String for the name of the Campaign
    * @return a Campaign that has not been inserted
    */
    public static Campaign createCampaign(String name) {
        return new Campaign(
            Name = name
        );
    }

    /*  
    * Creates a list of Gift records that have not been inserted
    *  
    * @param count an Integer for the number of records to create
    * @param accts a List of Accounts to associate the Gift records created to
    * @param recordTypeDevName a String of the record type developer name for the records
    * @return a List of AQB__Gift__c records that have not been inserted
    */
    public static List<AQB__Gift__c> createGifts(Integer count, List<Account> accts, String recordTypeDevName){
        
        List<AQB__Gift__c> gifts = new List<AQB__Gift__c>();
        Id recordTypeId = Schema.SObjectType.AQB__Gift__c.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
        Integer modByAcct = accts.size();
        
        for(Integer i = 0; i < count; i++){
            gifts.add(
                new AQB__Gift__c(
                    AQB__Account__c = accts.get(Math.mod(i, modByAcct)).Id,
                    AQB__Date__c = Date.today(),
                    RecordTypeId = recordTypeId
                )
            );
        }
        
        return gifts;
    }
    
    /*  
    * Creates a list of Transaction records that have not been inserted
    *  
    * @param count an Integer for the number of records to create
    * @param accts a List of Accounts to associate the Transaction records created to
    * @param recordTypeDevName a String of the record type developer name for the records
    * @return a List of AQB__Transaction__c records that have not been inserted
    */
    public static List<AQB__Transaction__c> createTransactions(Integer count, Campaign camp, List<AQB__Gift__c> gifts){
        
        List<AQB__Transaction__c> transactions = new List<AQB__Transaction__c>();
        Integer modByGifts = gifts.size();
        
        for(Integer i = 0; i < count; i++){
            AQB__Gift__c gift = gifts.get(Math.mod(i, modByGifts));
            transactions.add(
                new AQB__Transaction__c(
                    AQB__Gift__c = gifts.get(Math.mod(i, modByGifts)).Id,
                    AQB__Account__c = gift.AQB__Account__c,
                    AQB__CampaignAppeal__c = camp.Id,
                    AQB__Date__c = gift.AQB__Date__c,
                    AQB__Posted__c = true,
                    AQB__Type__c = 'Payment',
                    AQB__Amount__c = 1000
                )
            );
        }
        
        return transactions;
    }
    
    /*  
    * Creates a list of Opportunity records that have not been inserted
    *  
    * @param count an Integer for the number of records to create
    * @param accts a List of Accounts to associate the Opportunity records created to
    * @param recordTypeDevName a String of the record type developer name for the records
    * @return a List of Opportunity records that have not been inserted
    */
    public static List<Opportunity> createOpportunities(Integer count, List<Account> accts, List<User> users, String stage, String recordTypeDevName) {
        
        List<Opportunity> opps = new List<Opportunity>();
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
        Integer modByAcct = accts.size();
        Integer modByUsers = users.size();
        
        for(Integer i = 0; i < count; i++){
            opps.add(
                new Opportunity(
                    Name = 'Test Opportunity ' + i,
                    AccountId = accts.get(Math.mod(i, modByAcct)).Id,
                    OwnerId = users.get(Math.mod(i, modByUsers)).Id,
                    StageName = stage,
                    CloseDate = Date.today().addDays(30),
                    RecordTypeId = recordTypeId
                )
            );
        }
        
        return opps;
    }
    
    /*  
    * Creates a list of Relationship Management Team records that have not been inserted
    *  
    * @param count an Integer for the number of records to create
    * @param accts a List of Account records to associate the Relationship Management Team records created to
    * @param users a List of User records to associate the Relationship Management Team records created to
    * @param userRoles a List of String for the roles of the Relationship Management Team records
    * @return a List of AQB__PMTeam__c records that have not been inserted
    */
    public static List<AQB__PMTeam__c> createPMTeams(Integer count, List<Account> accts, List<User> users, List<String> userRoles) {
        
        List<AQB__PMTeam__c> teams = new List<AQB__PMTeam__c>();
        Integer modByAcct = accts.size();
        Integer modByUsers = users.size();
        Integer modByUserRoles = userRoles.size();
        
        for(Integer i = 0; i < count; i++){
            teams.add(
                new AQB__PMTeam__c(
                    AQB__Account__c = accts.get(Math.mod(i, modByAcct)).Id,
                    AQB__User__c = users.get(Math.mod(i, modByUsers)).Id,
                    AQB__StartDate__c = System.today(),
                    AQB__EndDate__c = System.today().addDays(7),
                    AQB__Role__c = userRoles.get(Math.mod(i, modByUserRoles))
                )
            );
        }
        
        return teams;
    }

    /*  
    * Creates a list of Contact Role records that have not been inserted
    *  
    * @return a List of AQB__LLContactRole__c records that have not been inserted
    */
    public static List<AQB__LLContactRole__c> createAllLLContactRoles(){
        List<AQB__LLContactRole__c> contactRoles = new List<AQB__LLContactRole__c>();
        contactRoles.Add(new AQB__LLContactRole__c(Name='Parent'));
        contactRoles.Add(new AQB__LLContactRole__c(Name='Child'));
        contactRoles.Add(new AQB__LLContactRole__c(Name='Ward'));
        contactRoles.Add(new AQB__LLContactRole__c(Name='Stepparent'));
        contactRoles.Add(new AQB__LLContactRole__c(Name='Guardian'));
        contactRoles.Add(new AQB__LLContactRole__c(Name='Stepchild'));
        contactRoles.Add(new AQB__LLContactRole__c(Name='Deceased Spouse'));
        contactRoles.Add(new AQB__LLContactRole__c(Name='Surviving Spouse'));
        return contactRoles;
    }

    /*  
    * Creates a list of Relationship Contact records that have not been inserted
    *  
    * @param count an Integer for the number of records to create
    * @param accts a List of Contact records to associate the Relationship Contact records created to
    * @param contactRoleStr0 a String for the name of the Contact Role for the records
    * @param contactRoleStr1 a String for the name of the Related Contact Role for the records
    * @return a List of AQB__RelationshipContact__c records that have not been inserted
    */
    public static List<AQB__RelationshipContact__c> createRelationshipContacts(Integer count, List<Contact> contacts, String contactRoleStr0, String contactRoleStr1){
        List<AQB__RelationshipContact__c> relationshipContacts = new List<AQB__RelationshipContact__c>();
        Integer modByContact = contacts.size();
        
        Id contactRoleId0 = [SELECT Id FROM AQB__LLContactRole__c where Name = :contactRoleStr0].Id;
        Id contactRoleId1 = [SELECT Id FROM AQB__LLContactRole__c where Name = :contactRoleStr1].Id;

        for(Integer i = 0; i < count; i++){
            Id contactId0 = contacts.get(Math.mod(i, modByContact)).Id;
            Id contactId1 = contacts.get(Math.mod(i + count, modByContact)).Id;
            
            relationshipContacts.add(
                new AQB__RelationshipContact__c(
                    AQB__Contact__c = contactId0,
                    AQB__RelatedContact__c = contactId1,
                    AQB__ContactRole__c = contactRoleId0,
                    AQB__RelatedContactRole__c = contactRoleId1
                )
            );

            // Trigger will create inverse record
            /* relationshipContacts.add(
                new AQB__RelationshipContact__c(
                    AQB__Contact__c = contactId1,
                    AQB__RelatedContact__c = contactId0,
                    AQB__ContactRole__c = contactRoleId1,
                    AQB__RelatedContactRole__c = contactRoleId0
                )
            ); */
        }
        
        return relationshipContacts;
    }

    /*  
    * Creates a list of Student Interest Types records that have not been inserted
    *  
    * @return a List of AQB__LLStudentInterestType__c records that have not been inserted
    */
    public static List<AQB__LLStudentInterestType__c> createAllLLStudentInterestTypes(){
        List<AQB__LLStudentInterestType__c> studentInterestTypes = new List<AQB__LLStudentInterestType__c>();
        studentInterestTypes.Add(new AQB__LLStudentInterestType__c(AQB__InterestGroup__c='Cultural'));
        studentInterestTypes.Add(new AQB__LLStudentInterestType__c(AQB__InterestGroup__c='Greek'));
        studentInterestTypes.Add(new AQB__LLStudentInterestType__c(AQB__InterestGroup__c='Other'));
        studentInterestTypes.Add(new AQB__LLStudentInterestType__c(AQB__InterestGroup__c='Professional'));
        studentInterestTypes.Add(new AQB__LLStudentInterestType__c(AQB__InterestGroup__c='Tepper'));
        studentInterestTypes.Add(new AQB__LLStudentInterestType__c(AQB__InterestGroup__c='Volunteer Activity'));
        studentInterestTypes.Add(new AQB__LLStudentInterestType__c(AQB__InterestGroup__c='Sport'));
        return studentInterestTypes;
    }

    /*  
    * Creates a list of Student Interest records that have not been inserted
    *  
    * @param count an Integer for the number of records to create
    * @param contacts a List of Contact records to associate the Student Interest records created to
    * @param educationRecords a List of Education records to associate the Student Interest records created to
    * @param studentInterestType a String of the student interest type for the records
    * @return a List of AQB__StudentInterest__c records that have not been inserted
    */
    public static List<AQB__StudentInterest__c> createStudentInterests(Integer count, List<Contact> contacts, List<AQB__Education__c> educationRecords, String studentInterestType){
        List<AQB__StudentInterest__c> studentInterests = new List<AQB__StudentInterest__c>();
        Integer modByContact = contacts.size();
        
        Id interestTypeId = [SELECT Id FROM AQB__LLStudentInterestType__c where AQB__InterestGroup__c = :studentInterestType].Id;

        for(Integer i = 0; i < count; i++){
            studentInterests.add(
                new AQB__StudentInterest__c(
                    Contact__c = contacts.get(Math.mod(i, modByContact)).Id,
                    AQB__InterestType__c = interestTypeId,
                    AQB__EducationLink__c = educationRecords[i].Id
                )
            );
        }
        
        return studentInterests;
    }

    /*  
    * Creates a list of Education records that have not been inserted
    *  
    * @param count an Integer for the number of records to create
    * @param recordTypeDevName a String of the record type developer name for the records
    * @param contacts a List of Contacts records to associate the Education records created to
    * @param institute a String of the name of Educational Institute
    * @param status a String of the status for the records
    * @return a List of AQB__Education__c records that have not been inserted
    */
    public static List<AQB__Education__c> createEducationRecords(Integer count, String recordTypeDevName, List<Contact> contacts, String institute, String status){
        List<AQB__Education__c> educations = new List<AQB__Education__c>();
        Integer modByContact = contacts.size();

        Id recordTypeId = Schema.SObjectType.AQB__Education__c.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
        Id instituteId = null;

        if(!String.isBlank(institute)){
            instituteId = [SELECT Id FROM AQB__LLEducationalInstitution__c where Name = :institute][0].Id;
        }

        for(Integer i = 0; i < count; i++){
            educations.add(
                new AQB__Education__c(
                    RecordTypeId = recordTypeId,
                    AQB__Contact__c = contacts.get(Math.mod(i, modByContact)).Id,
                    AQB__Institution__c = instituteId,
                    Status__c = status,
                    AQB__School__c = 'Heinz College',
                    AQB__PreferredYear__c = '2018',
                    AQB__EntryClassYear__c = '2016',
                    AQB__GraduationYear__c = '2020',
                    AQB__DegreeLevel__c = 'Undergraduate'
                    // AQB__Department__c = '',
                )
            );
        }
        
        return educations;
    }

    /*  
    * Creates a list of Volunteer Position records that have not been inserted
    *  
    * @param count an Integer for the number of records to create
    * @param recordTypeDevName a String of the record type developer name for the records
    * @param contacts a List of Contact records to associate the Volunteer Position records created to
    * @param affiliatedOrgs a List of Account records to associate the Volunteer Position records created to
    * @return a List of AQB__VolunteerPosition__c records that have not been inserted
    */
    public static List<AQB__VolunteerPosition__c> createVolunteerPositionRecords(Integer count, String recordTypeDevName, List<Contact> contacts, List<Account> affiliatedOrgs){
        List<AQB__VolunteerPosition__c> educations = new List<AQB__VolunteerPosition__c>();
        Integer modByContact = contacts.size();
        Integer modByAffilatedOrg = affiliatedOrgs.size();

        Id recordTypeId = Schema.SObjectType.AQB__VolunteerPosition__c.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();

        for(Integer i = 0; i < count; i++){
            educations.add(
                new AQB__VolunteerPosition__c(
                    RecordTypeId = recordTypeId,
                    AQB__Contact__c = contacts.get(Math.mod(i, modByContact)).Id,
                    AQB__AffiliatedOrganization__c = affiliatedOrgs.get(Math.mod(i, modByAffilatedOrg)).Id,
                    AQB__StartDate__c = System.today().addDays(-7)
                )
            );
        }
        
        return educations;
    }
}