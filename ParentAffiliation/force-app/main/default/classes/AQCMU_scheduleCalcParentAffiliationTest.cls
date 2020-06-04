/* 
*
* Apex Test for AQCMU_scheduleCalcParentAffiliation. Runs a full batch of records.
*
* 12/07/2018    Michael Steptoe (Sleek)
*/
@isTest
private class AQCMU_scheduleCalcParentAffiliationTest {
    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    @testSetup
    static void setup(){
        AQB__LLEducationalInstitution__c educationalInstituion = new AQB__LLEducationalInstitution__c (Name = AQCMU_Util.EDUCATIONAL_INSTITUTE_NAME);
        insert educationalInstituion;
        
        List<AQB__LLContactRole__c> contactRoles = AQCMU_TestDataFactory.createAllLLContactRoles();
        insert contactRoles;

        List<AQB__LLStudentInterestType__c> sits = AQCMU_TestDataFactory.createAllLLStudentInterestTypes();
        insert sits;
    }

    @isTest
    static void testScheduledJob() {
        
        Integer count = 100;
        Integer existingCount = 50;

        List<Account> accounts = AQCMU_TestDataFactory.createAccounts(count, 'Household', 'Household');
        insert accounts;

        List<Contact> contacts = AQCMU_TestDataFactory.createContacts(count * 2, accounts, -1);
        insert contacts;
        contacts = [
            SELECT Id, LastName, AQB__Full_Name__c
            FROM Contact
        ];
        Map<Id, Contact> contactMap = new Map<Id, Contact>(contacts);
        
        List<AQB__Education__c> educationRecords = AQCMU_TestDataFactory.createEducationRecords(count, 'NonInstitutional', contacts, AQCMU_Util.EDUCATIONAL_INSTITUTE_NAME, 'Transfer');
        insert educationRecords;
        educationRecords = [
            SELECT AQB__Contact__c,  AQB__Contact__r.LastName, Name, Primary_School__c, Status__c, AQB__EntryClassYear__c, AQB__GraduationYear__c,
            AQB__Department__c, AQB__DegreeLevel__c, AQB__Institution__c
            FROM AQB__Education__c
        ];
        // System.debug('AQCMU_scheduleCalcParentAffiliationTest.test -> educationRecords:' + educationRecords);

        for(AQB__Education__c educationRecord : educationRecords){
            contactMap.get(educationRecord.AQB__Contact__c).AQB__EducationLink__c = educationRecord.Id;
        }
        update contacts;

        List<AQB__RelationshipContact__c> relationshipContacts = AQCMU_TestDataFactory.createRelationshipContacts(count, contacts, 'Child', 'Parent');
        insert relationshipContacts;
        relationshipContacts = [
            SELECT AQB__Contact__c, AQB__RelatedName__c, AQB__Contact__r.LastName, AQB__relatedContact__c
            FROM AQB__RelationshipContact__c
            WHERE AQB__RelatedContactRole__r.Name in ('Child','Stepchild','Stepdaughter','Stepson','Ward')
        ];

        // System.debug('AQCMU_scheduleCalcParentAffiliationTest.test -> relationshipContacts: ' + relationshipContacts);
        
        List<Parent_Affiliation__c> parentAffilations = AQCMU_CalcParentAffiliationTest.createParentAffiliations(existingCount, relationshipContacts);
        insert parentAffilations;
        // System.debug('AQCMU_scheduleCalcParentAffiliationTest.test -> parentAffilations: ' + parentAffilations);

        List<AQB__StudentInterest__c> studentInterests = AQCMU_TestDataFactory.createStudentInterests(count, contacts, educationRecords, 'Sport');
        insert studentInterests;


        Test.startTest();
        AQCMU_scheduleCalcParentAffiliation scheduleCalc = new AQCMU_scheduleCalcParentAffiliation();

        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, scheduleCalc);  

        // Verify the scheduled job has not run yet.
        List<Parent_Affiliation__c> lpa = [SELECT Id FROM Parent_Affiliation__c];
        System.assertEquals(existingCount, lpa.size(), 'Additional or no Parent Affiliations exist before job has run');
		
        // Must manually call execute for this to work
        scheduleCalc.execute(null);
        
        // Stopping the test will run the job synchronously
        Test.stopTest();
        
        // Now that the scheduled job has executed,
        // check that the new Parent Affiliations were created
        lpa = [SELECT Id FROM Parent_Affiliation__c];

        System.debug('AQCMU_scheduleCalcParentAffiliationTest.testScheduledJob -> lpa.size(): ' + lpa.size());
        System.assertEquals(count, lpa.size(), 'Parent Affiliations were not created');
    }
}