/**
* @author Mathew Ruff, Sierra-Cedar
* @date 10/17/18
*
* Apex Unit tests for OpportunityTriggerHandler.cls
*/
@IsTest(IsParallel=false)
private class OpportunityTriggerHandlerTest {
    public static final Id EVENT_RECORD_TYPE_ID = Schema.SObjectType.AQB__ActivityReport__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();

    @TestSetup
    static void setUpTest() {
        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        testUser.FirstName = 'Queue';
        testUser.LastName = 'Manager';
        testUser.Email = 'queue.manager@nomail.com';
        testUser.Alias = 'queueMan';
        testUser.Username = 'queue.manager@nomail.com.test';
        insert testUser;

        GroupMember testMember = new GroupMember(
            UserOrGroupId = testUser.Id,
            GroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Qualification_Queue'].Id
        );
        insert testMember;
    }

    @IsTest
    private static void testQualificationCreationNegative() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.MAJOR);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        insert testOpportunity;

        Prospect_Rating__c testRating = TestDataFactory.createTestProspectRating(testAccount.Id, 'Capacity Rating');
        testRating.End_Date__c = System.today() - 25;
        insert testRating;

        OpportunityTeamMember testLeadMember = TestDataFactory.createTestOpptyTeamMember(testOpportunity.Id, testUser.Id, 'Team Leader');
        insert testLeadMember;

        // Act
        Test.startTest();
        try {
            AQB__ActivityReport__c testCultivationReport = new AQB__ActivityReport__c(
                AQB__Opportunity__c = testOpportunity.Id,
                AQB__Account__c = testAccount.Id,
                AQB__ReportStatus__c = 'Final',
                AQB__Date__c = System.today().addDays(-30),
                AQB__Type__c = 'Visit In'
            );
            insert testCultivationReport;

            testOpportunity.StageName = OpportunityService.CULTIVATION;
            update testOpportunity;
        } catch(Exception e) {
            System.assert(
                e.getMessage().contains('You must enter an Activity Report in this Discovery stage before moving on to Cultivation'),
                'The User should have gotten an error when trying to move the StageName to \'Cultivation\'.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void testQualificationCreationPositive() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.MAJOR);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        insert testOpportunity;

        AQB__ActivityReport__c testReport = new AQB__ActivityReport__c(
            RecordTypeId = EVENT_RECORD_TYPE_ID,
            AQB__Opportunity__c = testOpportunity.Id,
            AQB__Account__c = testAccount.Id,
            AQB__ReportStatus__c = 'Final',
            AQB__Subject__c = 'Test',
            AQB__Objective__c = 'Test',
            AQB__Date__c = System.today().addDays(-30),
            AQB__StartDateTime__c = System.today().addDays(-30),
            AQB__EndDateTime__c = System.today().addDays(-30),
            AQB__Type__c = 'Visit In'
        );
        insert testReport;

        Prospect_Rating__c testRating = TestDataFactory.createTestProspectRating(testAccount.Id, 'Capacity Rating');
        testRating.End_Date__c = System.today() - 25;
        insert testRating;

        OpportunityTeamMember testLeadMember = TestDataFactory.createTestOpptyTeamMember(testOpportunity.Id, testUser.Id, 'Team Leader');
        insert testLeadMember;

        // Act
        Test.startTest();
        testOpportunity.StageName = OpportunityService.CULTIVATION;
        update testOpportunity;
        Test.stopTest();

        // Assert
        User assertUser = [SELECT Id FROM User WHERE Username = 'test.user@nomail.com.testing'];
        Prospect_Rating__c assertRating = [SELECT Qualification_Credit__c FROM Prospect_Rating__c WHERE Start_Date__c = TODAY];
        System.assertEquals(assertUser.Id, assertRating.Qualification_Credit__c,
            'The Qualification Credit on the Prospect Rating should have been set to the Test Leader\'s Id.');
    }

    @IsTest
    private static void testErrorOnDisqualification() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.MAJOR);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        insert testOpportunity;

        Prospect_Rating__c testRating = TestDataFactory.createTestProspectRating(testAccount.Id, 'Qualification');
        testRating.End_Date__c = System.today() - 25;
        insert testRating;

        OpportunityTeamMember testLeadMember = TestDataFactory.createTestOpptyTeamMember(testOpportunity.Id, testUser.Id, 'Team Leader');
        insert testLeadMember;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            try {
                testOpportunity.StageName = 'Disqualified';
                update testOpportunity;
            } catch(Exception e) {
                System.assert(
                    e.getMessage().contains('In order to move into the disqualification stage, you must receive approval first.'),
                    'The User should have gotten an error when trying to move the StageName to \'Disqualified\'.'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void testQualificationCaseCreation() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.MAJOR);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        insert testOpportunity;

        Prospect_Rating__c testRating = TestDataFactory.createTestProspectRating(testAccount.Id, 'Qualification');
        testRating.End_Date__c = System.today() - 25;
        insert testRating;

        OpportunityTeamMember testLeadMember = TestDataFactory.createTestOpptyTeamMember(testOpportunity.Id, testUser.Id, 'Team Leader');
        insert testLeadMember;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            testOpportunity.Disqualification__c = 'Angry with the University';
            testOpportunity.Disqualification_Reason_Detail__c = 'Other Reasons outlined here.';
            update testOpportunity;
        }
        Test.stopTest();

        // Assert
        List<Case> casesToAssert = [SELECT Subject FROM Case WHERE Opportunity__c = :testOpportunity.Id];
        System.assert(casesToAssert.size() == 1, 'One Case should have been created.');
        System.assertEquals('Disqualification Request', casesToAssert[0].Subject,
            'The Subject should have been set to \'Disqualification Request\'.');
    }

    @IsTest
    static void testValidationToCultivationNegative() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.MAJOR);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        insert testOpportunity;

        AQB__ActivityReport__c testReport = new AQB__ActivityReport__c(
            RecordTypeId = EVENT_RECORD_TYPE_ID,
            AQB__Opportunity__c = testOpportunity.Id,
            AQB__Account__c = testAccount.Id,
            AQB__ReportStatus__c = 'Final',
            AQB__Subject__c = 'Test',
            AQB__Objective__c = 'Test',
            AQB__Date__c = System.today().addDays(-30),
            AQB__StartDateTime__c = System.today().addDays(-30),
            AQB__EndDateTime__c = System.today().addDays(-30),
            AQB__Type__c = 'Visit In'
        );
        insert testReport;

        testOpportunity.StageName = OpportunityService.CULTIVATION;
        update testOpportunity;

        Prospect_Rating__c testRating = TestDataFactory.createTestProspectRating(testAccount.Id, 'Qualification');
        testRating.End_Date__c = System.today() - 25;
        insert testRating;

        Test.startTest();
        OpportunityTeamMember testLeadMember = TestDataFactory.createTestOpptyTeamMember(testOpportunity.Id, testUser.Id, 'Team Leader');
        insert testLeadMember;

        // Act
        System.runAs(testUser) {
            try {
                testOpportunity.StageName = OpportunityService.ANTICIPATED_SOLICITATION;
                update testOpportunity;
            } catch(Exception e) {
                System.assert(
                    e.getMessage().contains('In order to advance to the Anticipated Solicitation stage'),
                    'The Trigger should have hit the addError message for not filling out the proper fields.'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testValidationToCultivationPositive() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.MAJOR);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        insert testOpportunity;

        AQB__ActivityReport__c testReport = new AQB__ActivityReport__c(
            RecordTypeId = EVENT_RECORD_TYPE_ID,
            AQB__Opportunity__c = testOpportunity.Id,
            AQB__Account__c = testAccount.Id,
            AQB__ReportStatus__c = 'Final',
            AQB__Subject__c = 'Test',
            AQB__Objective__c = 'Test',
            AQB__Date__c = System.today().addDays(-30),
            AQB__StartDateTime__c = System.today().addDays(-30),
            AQB__EndDateTime__c = System.today().addDays(-30),
            AQB__Type__c = 'Visit In'
        );
        insert testReport;

        testOpportunity.StageName = OpportunityService.CULTIVATION;
        update testOpportunity;

        Prospect_Rating__c testRating = TestDataFactory.createTestProspectRating(testAccount.Id, 'Qualification');
        testRating.End_Date__c = System.today() - 25;
        insert testRating;

        Test.startTest();
        OpportunityTeamMember testLeadMember = TestDataFactory.createTestOpptyTeamMember(testOpportunity.Id, testUser.Id, 'Team Leader');
        insert testLeadMember;

        // Act
        System.runAs(testUser) {
            try {
                AQB__OpportunityComponent__c testComponent = new AQB__OpportunityComponent__c(
                    School__c = 'University Libraries',
                    AQB__Opportunity__c = testOpportunity.Id
                );
                insert testComponent;

                testOpportunity.StageName = OpportunityService.ANTICIPATED_SOLICITATION;
                testOpportunity.Amount = 5000;
                testOpportunity.Anticipated_Amount__c = 500;
                testOpportunity.Ask_Date__c = Date.today().addDays(1);
                update testOpportunity;
            } catch(Exception e) {
                System.debug('ERROR during test: ' + e.getMessage());
            }
        }
        Test.stopTest();

        // Assert
        System.assertEquals(
            OpportunityService.ANTICIPATED_SOLICITATION,
            [SELECT StageName FROM Opportunity WHERE Id = :testOpportunity.Id].StageName,
            'The Opportunity should have been successfully changed to Anticipated Solicitation Stage.'
        );
    }

    @IsTest
    static void testValidationToSolicitationPositive() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.MAJOR);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        testOpportunity.Amount = 500;
        testOpportunity.Anticipated_Amount__c = 500;
        testOpportunity.Ask_Date__c = Date.today().addDays(5);
        testOpportunity.CloseDate = Date.today().addYears(1);
        insert testOpportunity;

        OpportunityTeamMember testLeadMember = TestDataFactory.createTestOpptyTeamMember(testOpportunity.Id, testUser.Id, 'Team Leader');
        insert testLeadMember;

        Prospect_Rating__c testRating = TestDataFactory.createTestProspectRating(testAccount.Id, 'Qualification');
        testRating.End_Date__c = System.today() - 25;
        insert testRating;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            try {
                AQB__OpportunityComponent__c testComponent = new AQB__OpportunityComponent__c(
                    School__c = 'University Libraries',
                    Account_Type__c = 'Expendable',
                    Account_Sub_Type__c = 'Emerging Opportunities',
                    AQB__Opportunity__c = testOpportunity.Id
                );
                insert testComponent;

                AQB__ActivityReport__c testReport = new AQB__ActivityReport__c(
                    RecordTypeId = EVENT_RECORD_TYPE_ID,
                    AQB__Opportunity__c = testOpportunity.Id,
                    AQB__Account__c = testAccount.Id,
                    AQB__ReportStatus__c = 'Final',
                    AQB__Subject__c = 'Test',
                    AQB__Objective__c = 'Test',
                    AQB__Date__c = System.today().addDays(-30),
                    AQB__StartDateTime__c = System.today().addDays(-30),
                    AQB__EndDateTime__c = System.today().addDays(-30),
                    AQB__Type__c = 'Visit In'
                );
                insert testReport;

                testOpportunity.StageName = OpportunityService.ANTICIPATED_SOLICITATION;
                update testOpportunity;

                AQB__ActivityReportParticipant__c testParticipant = new AQB__ActivityReportParticipant__c(
                    AQB__ActivityReport__c = testReport.Id,
                    AQB__User__c = testUser.Id
                );
                insert testParticipant;

                testOpportunity.StageName = 'Solicitation';
                testOpportunity.CloseDate = Date.today().addDays(30);
                testOpportunity.Ask_Date__c = Date.today();
                update testOpportunity;
            } catch(Exception e) {
                System.debug('ERROR during test: ' + e.getMessage());
            }
        }
        Test.stopTest();

        // Assert
        System.assertEquals(
            'Solicitation',
            [SELECT StageName FROM Opportunity WHERE Id = :testOpportunity.Id].StageName,
            'The Opportunity should have been successfully changed to Solicitation Stage.'
        );
    }

    @IsTest
    private static void testDelete() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.MAJOR);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        insert testOpportunity;

        Prospect_Rating__c testRating = TestDataFactory.createTestProspectRating(testAccount.Id, 'Qualification');
        testRating.End_Date__c = System.today() - 25;
        insert testRating;

        OpportunityTeamMember testLeadMember = TestDataFactory.createTestOpptyTeamMember(testOpportunity.Id, testUser.Id, 'Team Leader');
        insert testLeadMember;

        // Act
        Test.startTest();
        delete testOpportunity;
        Test.stopTest();

        // Assert
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());
    }

    @IsTest
    static void testRejectQualification() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = [SELECT Id FROM User WHERE Alias = 'queueMan' LIMIT 1];

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.MAJOR);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.Disqualification__c = 'Angry with the University';
        testOpportunity.Disqualification_Reason_Detail__c = 'Some longer reason';
        testOpportunity.OwnerId = testUser.Id;
        insert testOpportunity;

        Case testCase = new Case(
            Subject = 'Disqualification Request',
            RecordTypeId = Case.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Qualification').getRecordTypeId(),
            Opportunity__c = testOpportunity.Id
        );
        insert testCase;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            testCase.Disqualification_Result__c = 'Rejected';
            update testCase;
        }
        Test.stopTest();

        // Assert
        Opportunity assertOpportunity = [SELECT Disqualification__c, Disqualification_Reason_Detail__c, StageName FROM Opportunity WHERE Id = :testOpportunity.Id];
        System.assertNotEquals('Disqualified', assertOpportunity.StageName, 'The Opportunity StageName should NOT have changed');
        System.assert(String.isBlank(assertOpportunity.Disqualification__c), 'Disqualification should have been cleared.');
        System.assert(String.isBlank(assertOpportunity.Disqualification_Reason_Detail__c), 'Disqualification Reason Detail should have been cleared.');
    }

    @IsTest
    static void testApprovedQualification() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = [SELECT Id FROM User WHERE Alias = 'queueMan' LIMIT 1];

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.MAJOR);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.Disqualification__c = 'Angry with the University';
        testOpportunity.Disqualification_Reason_Detail__c = 'Some longer reason';
        testOpportunity.OwnerId = testUser.Id;
        insert testOpportunity;

        OpportunityTeamMember testLeadMember = TestDataFactory.createTestOpptyTeamMember(testOpportunity.Id, testUser.Id, 'Team Leader');
        insert testLeadMember;

        Case testCase = new Case(
            Subject = 'Disqualification Request',
            RecordTypeId = Case.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Qualification').getRecordTypeId(),
            Opportunity__c = testOpportunity.Id
        );
        insert testCase;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            testCase.Disqualification_Result__c = 'Approved';
            update testCase;
        }
        Test.stopTest();

        // Assert
        Opportunity assertOpportunity = [SELECT Disqualification__c, Disqualification_Reason_Detail__c, StageName, AccountId FROM Opportunity WHERE Id = :testOpportunity.Id];
        System.assertEquals('Disqualified', assertOpportunity.StageName, 'The Opportunity StageName should have changed to \'Disqualified\'.');
        System.assert(!String.isBlank(assertOpportunity.Disqualification__c), 'Disqualification should NOT have been cleared.');
        System.assert(!String.isBlank(assertOpportunity.Disqualification_Reason_Detail__c), 'Disqualification Reason Detail should NOT have been cleared.');

        User assertUser = [SELECT Id FROM User WHERE Alias = 'queueMan'];
        List<Prospect_Rating__c> assertRatings = [SELECT End_Date__c FROM Prospect_Rating__c];
        System.assertEquals(1, assertRatings.size(), 'We should have 1 Prospect Rating created.');
        System.assertEquals(null, assertRatings[0].End_Date__c,
            'The Qualification Credit on the Prospect Rating should be null, meaning an Active rating..');
    }

    @IsTest
    static void testSpouseFieldsCopy() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = [SELECT Id FROM User WHERE Alias = 'queueMan' LIMIT 1];

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Contact testContact2 = TestDataFactory.createTestContact();
        testContact2.FirstName = 'Spouse';
        testContact2.Email = 'spouse.contact@nomail.com';
        testContact2.AccountId = testAccount.Id;
        testContact2.Birthdate = Date.newInstance(Date.today().addYears(-34).year(), 1, 1);
        testContact2.AQB__Deceased__c = true;
        testContact2.AQB__DateofDeath__c = Date.today().addDays(-56);
        insert testContact2;

        AQB__RelationshipContact__c testRelationshipContact = new AQB__RelationshipContact__c(
            AQB__Contact__c = testContact2.Id,
            AQB__relatedContact__c = testContact.Id
            // AQB__Relationship__c = 'Spouse/Partner'
        );
        insert testRelationshipContact;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.LIFE_INCOME);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.Disqualification__c = 'Angry with the University';
        testOpportunity.Disqualification_Reason_Detail__c = 'Some longer reason';
        testOpportunity.OwnerId = testUser.Id;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            insert testOpportunity;
        }
        Test.stopTest();

        // Assert
        Opportunity assertOpportunity = [SELECT Spouse_Age__c, Spouse_Deceased__c, Spouse_Deceased_Date__c FROM Opportunity WHERE Id = :testOpportunity.Id];
        // System.assertEquals(true, assertOpportunity.Spouse_Deceased__c);
        // System.assertEquals(Date.today().addDays(-56), assertOpportunity.Spouse_Deceased_Date__c);
    }

    @IsTest
    private static void testEstateMoveToAcceptedStageNegative() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.ESTATE);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        insert testOpportunity;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            try {
                testOpportunity.StageName = OpportunityService.ACCEPTED;
                update testOpportunity;
            } catch (Exception e) {
                System.assert(
                    e.getMessage().contains('The opportunity must have documentation before it can be moved to the accepted stage.'),
                    'The update should have failed due to the Opportunity not having Full Documentation or Verbal dates populated.'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void testEstateMoveToAcceptedStagePositive() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.ESTATE);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        testOpportunity.Date_of_Verbal_Confirmation__c = Date.today().addDays(-5);
        testOpportunity.Settlement_Status__c = 'Full Distribution';
        insert testOpportunity;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            testOpportunity.StageName = OpportunityService.ACCEPTED;
            update testOpportunity;
        }
        Test.stopTest();

        // Assert
        Opportunity assertOpportunity = [SELECT StageName, CloseDate, AQB__FundingComplete__c FROM Opportunity WHERE Id = :testOpportunity.Id];
        System.assertEquals(OpportunityService.ACCEPTED, assertOpportunity.StageName, 'Stage should have been automatically updated to \'Accepted\'.');
        System.assertEquals(Date.today().addDays(-5), assertOpportunity.CloseDate, 'CloseDate should have been automatically updated to today minus 5 days.');
        System.assertEquals(true, assertOpportunity.AQB__FundingComplete__c, 'Funding Complete checkbox should have been automatically checked when Settlement Status on the Estate Opportunity was set to \'Full Distribution\'.');
    }

    @IsTest
    static void testValidationCultivationToSolicitationStageNegative() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        OpportunityTriggerHandler.disable = true;
        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.MAJOR);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        insert testOpportunity;

        AQB__ActivityReport__c testReport = new AQB__ActivityReport__c(
            RecordTypeId = EVENT_RECORD_TYPE_ID,
            AQB__Opportunity__c = testOpportunity.Id,
            AQB__Account__c = testAccount.Id,
            AQB__ReportStatus__c = 'Final',
            AQB__Subject__c = 'Test',
            AQB__Objective__c = 'Test',
            AQB__Date__c = System.today().addDays(-30),
            AQB__StartDateTime__c = System.today().addDays(-30),
            AQB__EndDateTime__c = System.today().addDays(-30),
            AQB__Type__c = 'Visit In'
        );
        insert testReport;

        testOpportunity.StageName = OpportunityService.CULTIVATION;
        update testOpportunity;

        Prospect_Rating__c testRating = TestDataFactory.createTestProspectRating(testAccount.Id, 'Qualification');
        testRating.End_Date__c = System.today() - 25;
        insert testRating;

        OpportunityTeamMember testLeadMember = TestDataFactory.createTestOpptyTeamMember(testOpportunity.Id, testUser.Id, 'Team Leader');
        insert testLeadMember;

        AQB__OpportunityComponent__c testComponent = new AQB__OpportunityComponent__c(
            AQB__Opportunity__c = testOpportunity.Id,
            School__c = 'University Libraries',
            Account_Type__c = 'Undesignated'
        );
        insert testComponent;
        OpportunityTriggerHandler.disable = false;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            try {
                testOpportunity.StageName = OpportunityService.SOLICITATION;
                update testOpportunity;
            } catch(Exception e) {
                System.assert(
                    e.getMessage().contains('In order to save the Opportunity in the Solicitation stage a member of the opportunity'),
                    'The Trigger should have hit the addError message for not filling out the proper fields.'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testValidationDiscoveryToAnticipatedSolicitationStageNegative() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.MAJOR);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        insert testOpportunity;

        Prospect_Rating__c testRating = TestDataFactory.createTestProspectRating(testAccount.Id, 'Qualification');
        testRating.End_Date__c = System.today() - 25;
        insert testRating;

        OpportunityTeamMember testLeadMember = TestDataFactory.createTestOpptyTeamMember(testOpportunity.Id, testUser.Id, 'Team Leader');
        insert testLeadMember;

        Test.startTest();
        AQB__OpportunityComponent__c testComponent = new AQB__OpportunityComponent__c(
            AQB__Opportunity__c = testOpportunity.Id,
            School__c = 'University Libraries',
            Account_Type__c = 'Undesignated'
        );
        insert testComponent;

        AQB__ActivityReport__c testReport = new AQB__ActivityReport__c(
            RecordTypeId = EVENT_RECORD_TYPE_ID,
            AQB__Opportunity__c = testOpportunity.Id,
            AQB__Account__c = testAccount.Id,
            AQB__ReportStatus__c = 'Final',
            AQB__Subject__c = 'Test',
            AQB__Objective__c = 'Test',
            AQB__Date__c = System.today().addDays(-30),
            AQB__StartDateTime__c = System.today().addDays(-30),
            AQB__EndDateTime__c = System.today().addDays(-30),
            AQB__Type__c = 'Visit In'
        );
        insert testReport;

        // Act
        System.runAs(testUser) {
            try {
                testOpportunity.StageName = OpportunityService.ANTICIPATED_SOLICITATION;
                update testOpportunity;
            } catch(Exception e) {
                System.assert(
                    e.getMessage().contains('In order to save the opportunity in the Anticipated Solicitation stage you must'),
                    'The Trigger should have hit the addError message for not filling out the proper fields.'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testValidationDiscoveryToAnticipatedSolicitationStagePositive() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.MAJOR);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        testOpportunity.Amount = 500;
        testOpportunity.Anticipated_Amount__c = 500;
        testOpportunity.Ask_Date__c = Date.today().addDays(5);
        testOpportunity.CloseDate = Date.today().addYears(1);
        insert testOpportunity;

        OpportunityTeamMember testLeadMember = TestDataFactory.createTestOpptyTeamMember(testOpportunity.Id, testUser.Id, 'Team Leader');
        insert testLeadMember;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            AQB__OpportunityComponent__c testComponent = new AQB__OpportunityComponent__c(
                AQB__Opportunity__c = testOpportunity.Id,
                School__c = 'University Libraries',
                Account_Type__c = 'Undesignated'
            );
            insert testComponent;

            AQB__ActivityReport__c testReport = new AQB__ActivityReport__c(
                RecordTypeId = EVENT_RECORD_TYPE_ID,
                AQB__Opportunity__c = testOpportunity.Id,
                AQB__Account__c = testAccount.Id,
                AQB__ReportStatus__c = 'Final',
                AQB__Subject__c = 'Test',
                AQB__Objective__c = 'Test',
                AQB__Date__c = System.today().addDays(-30),
                AQB__StartDateTime__c = System.today().addDays(-30),
                AQB__EndDateTime__c = System.today().addDays(-30),
                AQB__Type__c = 'Visit In'
            );
            insert testReport;

            testOpportunity.StageName = OpportunityService.ANTICIPATED_SOLICITATION;
            update testOpportunity;
        }
        Test.stopTest();

        // Assert
        List<Prospect_Rating__c> assertRatings = [SELECT Id FROM Prospect_Rating__c WHERE Account__c = :testAccount.Id];
        System.assertEquals(1, assertRatings.size(), 'A new Prospect Rating should have been created for the test Account.');
    }

    @IsTest
    static void testValidationDiscoveryToSolicitationStageNegative() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.MAJOR);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        insert testOpportunity;

        Prospect_Rating__c testRating = TestDataFactory.createTestProspectRating(testAccount.Id, 'Qualification');
        testRating.End_Date__c = System.today() - 25;
        insert testRating;

        Test.startTest();
        OpportunityTeamMember testLeadMember = TestDataFactory.createTestOpptyTeamMember(testOpportunity.Id, testUser.Id, 'Team Leader');
        insert testLeadMember;

        AQB__OpportunityComponent__c testComponent = new AQB__OpportunityComponent__c(
            AQB__Opportunity__c = testOpportunity.Id,
            School__c = 'University Libraries',
            Account_Type__c = 'Undesignated'
        );
        insert testComponent;

        AQB__ActivityReport__c testReport = new AQB__ActivityReport__c(
            RecordTypeId = EVENT_RECORD_TYPE_ID,
            AQB__Opportunity__c = testOpportunity.Id,
            AQB__Account__c = testAccount.Id,
            AQB__ReportStatus__c = 'Final',
            AQB__Subject__c = 'Test',
            AQB__Objective__c = 'Test',
            AQB__Date__c = System.today().addDays(-30),
            AQB__StartDateTime__c = System.today().addDays(-30),
            AQB__EndDateTime__c = System.today().addDays(-30),
            AQB__Type__c = 'Visit In'
        );
        insert testReport;

        // Act
        System.runAs(testUser) {
            try {
                testOpportunity.StageName = OpportunityService.SOLICITATION;
                update testOpportunity;
            } catch(Exception e) {
                System.assert(
                    e.getMessage().contains('In order to save the Opportunity in the Solicitation stage a member of the opportunity'),
                    'The Trigger should have hit the addError message for not filling out the proper fields.'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testValidationDiscoveryToSolicitationStagePositive() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.MAJOR);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        testOpportunity.Amount = 500;
        testOpportunity.Anticipated_Amount__c = 500;
        testOpportunity.Ask_Date__c = Date.today().addDays(-5);
        testOpportunity.CloseDate = Date.today().addDays(100);
        insert testOpportunity;

        OpportunityTeamMember testLeadMember = TestDataFactory.createTestOpptyTeamMember(testOpportunity.Id, testUser.Id, 'Team Leader');
        insert testLeadMember;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            AQB__OpportunityComponent__c testComponent = new AQB__OpportunityComponent__c(
                AQB__Opportunity__c = testOpportunity.Id,
                School__c = 'University Libraries',
                Account_Type__c = 'Undesignated',
                Account_Sub_Type__c = 'Student Support'
            );
            insert testComponent;

            AQB__ActivityReport__c testReport = new AQB__ActivityReport__c(
                RecordTypeId = EVENT_RECORD_TYPE_ID,
                AQB__Opportunity__c = testOpportunity.Id,
                AQB__Account__c = testAccount.Id,
                AQB__ReportStatus__c = 'Final',
                AQB__Subject__c = 'Test',
                AQB__Objective__c = 'Test',
                AQB__Date__c = System.today().addDays(-30),
                AQB__StartDateTime__c = System.today().addDays(-30),
                AQB__EndDateTime__c = System.today().addDays(-30),
                AQB__Type__c = 'Visit In'
            );
            insert testReport;

            AQB__ActivityReportParticipant__c testParticipant = new AQB__ActivityReportParticipant__c(
                AQB__ActivityReport__c = testReport.Id,
                AQB__User__c = testUser.Id
            );
            insert testParticipant;

            testOpportunity.StageName = OpportunityService.SOLICITATION;
            update testOpportunity;
        }
        Test.stopTest();

        // Assert
        List<Prospect_Rating__c> assertRatings = [SELECT Id FROM Prospect_Rating__c WHERE Account__c = :testAccount.Id];
        System.assertEquals(1, assertRatings.size(), 'A new Prospect Rating should have been created for the test Account.');
    }
    
    
    
    
    
    
    
    
    
    
    
    @IsTest
    static void ipProposalStages() {
        // Arrange
        AGNum__c agn = new AGNum__c(Name='LastAGNum', AGNumber__c=1);
        insert agn;

        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        Contact testContact = TestDataFactory.createTestContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;

        // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
        testAccount.AQB__PrimaryContact__c = testContact.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity(OpportunityService.DISCOVERY, OpportunityService.MAJOR);
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        testOpportunity.Amount = 500;
        testOpportunity.Anticipated_Amount__c = 500;
        //testOpportunity.Ask_Date__c = Date.today().addDays(5);
        testOpportunity.CloseDate = Date.today().addYears(1);
        insert testOpportunity;

        OpportunityTeamMember testLeadMember = TestDataFactory.createTestOpptyTeamMember(testOpportunity.Id, testUser.Id, 'Team Leader');
        insert testLeadMember;

        // Act
        //Test.startTest();
        System.runAs(testUser) {
            AQB__OpportunityComponent__c testComponent = new AQB__OpportunityComponent__c(
                AQB__Opportunity__c = testOpportunity.Id);
            insert testComponent;

            AQB__ActivityReport__c testReport = new AQB__ActivityReport__c(
                RecordTypeId = EVENT_RECORD_TYPE_ID,
                AQB__Opportunity__c = testOpportunity.Id,
                AQB__Account__c = testAccount.Id,
                AQB__ReportStatus__c = 'Final',
                AQB__Subject__c = 'Test',
                AQB__Objective__c = 'Test',
                AQB__Date__c = System.today().addDays(-30),
                AQB__StartDateTime__c = System.today().addDays(-30),
                AQB__EndDateTime__c = System.today().addDays(-30),
                AQB__Type__c = 'Visit In'
            );
            insert testReport;
		//Test.stopTest();



		Test.startTest();            
            //NEGATIVE TEST for Moving to Prop In Dev...(no school on Opp Comp, no ask date)
            try{
                testOpportunity.StageName = OpportunityService.PROPOSAL_IN_DEVELOPMENT;
                update testOpportunity;
            } catch(Exception e) {
                System.assert(
                    e.getMessage().contains('In order to advance to the Proposal In Development stage'),
                    'Validation Fired Correctly.'
                );
            }

            
            //POSITIVE TEST for Moving to Prop In Dev...(added school to OppComp, added Ask Date to Opp)
            testComponent.School__c = 'University Libraries';
            update testComponent;
            testOpportunity.StageName = OpportunityService.PROPOSAL_IN_DEVELOPMENT;
            testOpportunity.Ask_Date__c = Date.today().addDays(5);
            update testOpportunity;
		//Test.stopTest();            
            


		//Test.startTest();            
            //NEGATIVE TEST for Moving to Prop Out...(no Account Type/Subtype on OppComp, Bad Dates)
            try{
                testOpportunity.StageName = OpportunityService.PROPOSAL_OUTSTANDING;
                update testOpportunity;
            } catch(Exception e) {
                System.assert(
                    e.getMessage().contains('In order to save the Opportunity in the Proposal Outstanding stage'),
                    'Validation Fired Correctly.'
                );
            }


            //POSITIVE TEST for Moving to Prop Outs...(added  Acct Type + Sub Type on OppComp, updated dates)
            testComponent.Account_Type__c = 'Unknown';
            testComponent.Account_Sub_type__c = 'Unknown';
            update testComponent;
            testOpportunity.StageName = OpportunityService.PROPOSAL_IN_DEVELOPMENT;
            testOpportunity.Ask_Date__c = Date.today().addDays(-5);
            testOpportunity.CloseDate = Date.today().addDays(60);
            update testOpportunity;            
        Test.stopTest();
        }

        
    
        

        // Assert
       // List<Prospect_Rating__c> assertRatings = [SELECT Id FROM Prospect_Rating__c WHERE Account__c = :testAccount.Id];
       // System.assertEquals(1, assertRatings.size(), 'A new Prospect Rating should have been created for the test Account.');
    }    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}