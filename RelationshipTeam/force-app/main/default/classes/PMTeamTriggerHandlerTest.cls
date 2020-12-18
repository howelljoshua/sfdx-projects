/**
* @author Mathew Ruff, Sierra-Cedar
* @date 11/7/18
*
* Unit Tests for PMTeamTriggerHandler.cls
*/
@IsTest
private class PMTeamTriggerHandlerTest {
    @TestSetup
    static void setUpTest() {
        Campaign majorGiftsCampaign = TestDataFactory.createTestCampaign('Major Gifts Conversion Campaign');
        insert majorGiftsCampaign;
    }

    @IsTest
    static void testDuplicateProspectManager() {
        // Arrange
        User testExistingUser = TestDataFactory.createTestUserCustomName('Existing', 'eOtherUser', 'UA Prospect Manager');
        insert testExistingUser;

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

        AQB__PMTeam__c testExistingProspectManager = new AQB__PMTeam__c(
            AQB__Account__c = testAccount.Id,
            AQB__User__c = testExistingUser.Id,
            AQB__Role__c = PMTeamService.PROSPECT_MANAGER
        );
        insert testExistingProspectManager;

        // Act 
        Test.startTest();
        System.runAs(testUser) {
            AQB__PMTeam__c testDuplicateProspectManager = new AQB__PMTeam__c(
                AQB__Account__c = testAccount.Id,
                AQB__User__c = testUser.Id,
                AQB__Role__c = PMTeamService.PROSPECT_MANAGER
            );

            try {
                insert testDuplicateProspectManager;
            } catch (Exception e) {
                // Assert
                System.assert(e.getMessage().contains('The Relationship Management Team can only have one active'));
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testDuplicateTempProspectManager() {
        // Arrange
        User testExistingUser = TestDataFactory.createTestUserCustomName('Existing', 'eOtherUser', 'UA Prospect Manager');
        insert testExistingUser;

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

        AQB__PMTeam__c testExistingProspectManager = new AQB__PMTeam__c(
            AQB__Account__c = testAccount.Id,
            AQB__User__c = testExistingUser.Id,
            AQB__Role__c = PMTeamService.TEMP_MANAGER
        );
        insert testExistingProspectManager;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            AQB__PMTeam__c testDuplicateProspectManager = new AQB__PMTeam__c(
                AQB__Account__c = testAccount.Id,
                AQB__User__c = testUser.Id,
                AQB__Role__c = PMTeamService.TEMP_MANAGER
            );

            try {
                insert testDuplicateProspectManager;
            } catch (Exception e) {
                // Assert
                System.assert(e.getMessage().contains('The Relationship Management Team can only have one active'));
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testDuplicateGivingAdvisor() {
        // Arrange
        User testExistingUser = TestDataFactory.createTestUserCustomName('Existing', 'eOtherUser', 'UA Prospect Manager');
        insert testExistingUser;

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

        AQB__PMTeam__c testExistingProspectManager = new AQB__PMTeam__c(
            AQB__Account__c = testAccount.Id,
            AQB__User__c = testExistingUser.Id,
            AQB__Role__c = PMTeamService.GIVING_ADVISOR
        );
        insert testExistingProspectManager;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            AQB__PMTeam__c testDuplicateProspectManager = new AQB__PMTeam__c(
                AQB__Account__c = testAccount.Id,
                AQB__User__c = testUser.Id,
                AQB__Role__c = PMTeamService.GIVING_ADVISOR
            );

            try {
                insert testDuplicateProspectManager;
            } catch (Exception e) {
                // Assert
                System.assert(e.getMessage().contains('The Relationship Management Team can only have one active'));
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testDuplicateManagement() {
        // Arrange
        User testExistingUser = TestDataFactory.createTestUserCustomName('Existing', 'eOtherUser', 'UA Prospect Manager');
        insert testExistingUser;

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

        AQB__PMTeam__c testExistingProspectManager = new AQB__PMTeam__c(
            AQB__Account__c = testAccount.Id,
            AQB__User__c = testExistingUser.Id,
            AQB__Role__c = PMTeamService.PROSPECT_MANAGER
        );
        insert testExistingProspectManager;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            AQB__PMTeam__c testDuplicateProspectManager = new AQB__PMTeam__c(
                AQB__Account__c = testAccount.Id,
                AQB__User__c = testUser.Id,
                AQB__Role__c = PMTeamService.TEMP_MANAGER
            );

            try {
                insert testDuplicateProspectManager;
            } catch (Exception e) {
                // Assert
                System.assert(e.getMessage().contains('You cannot have an active'));
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testDuplicateGivingAdvisorWhenAlreadyManager() {
        // Arrange
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

        AQB__PMTeam__c testExistingProspectManager = new AQB__PMTeam__c(
            AQB__Account__c = testAccount.Id,
            AQB__User__c = testUser.Id,
            AQB__Role__c = PMTeamService.PROSPECT_MANAGER
        );
        insert testExistingProspectManager;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            AQB__PMTeam__c testDuplicateProspectManager = new AQB__PMTeam__c(
                AQB__Account__c = testAccount.Id,
                AQB__User__c = testUser.Id,
                AQB__Role__c = PMTeamService.GIVING_ADVISOR
            );

            try {
                insert testDuplicateProspectManager;
            } catch (Exception e) {
                // Assert
                System.assert(e.getMessage().contains('A user cannot be both the'));
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testDuplicateGivingAdvisorWhenAlreadyTempManager() {
        // Arrange
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

        AQB__PMTeam__c testExistingProspectManager = new AQB__PMTeam__c(
            AQB__Account__c = testAccount.Id,
            AQB__User__c = testUser.Id,
            AQB__Role__c = PMTeamService.TEMP_MANAGER
        );
        insert testExistingProspectManager;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            AQB__PMTeam__c testDuplicateProspectManager = new AQB__PMTeam__c(
                AQB__Account__c = testAccount.Id,
                AQB__User__c = testUser.Id,
                AQB__Role__c = PMTeamService.GIVING_ADVISOR
            );

            try {
                insert testDuplicateProspectManager;
            } catch (Exception e) {
                // Assert
                System.assert(e.getMessage().contains('A user cannot be both the'));
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testDuplicateSecondaryPartnerWhenAlreadyManager() {
        // Arrange
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

        AQB__PMTeam__c testExistingProspectManager = new AQB__PMTeam__c(
            AQB__Account__c = testAccount.Id,
            AQB__User__c = testUser.Id,
            AQB__Role__c = PMTeamService.PROSPECT_MANAGER
        );
        insert testExistingProspectManager;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            AQB__PMTeam__c testDuplicateProspectManager = new AQB__PMTeam__c(
                AQB__Account__c = testAccount.Id,
                AQB__User__c = testUser.Id,
                AQB__Role__c = PMTeamService.SECONDARY_PARTNER
            );

            try {
                insert testDuplicateProspectManager;
            } catch (Exception e) {
                // Assert
                System.assert(e.getMessage().contains('A user cannot be both the'));
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testAccountOwnerUpdate() {
        // Arrange
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

        AQB__PMTeam__c testProspectManager = new AQB__PMTeam__c(
            AQB__Account__c = testAccount.Id,
            AQB__User__c = testUser.Id,
            AQB__Role__c = PMTeamService.PROSPECT_MANAGER
        );

        // Act
        Test.startTest();
        System.assertNotEquals(testUser.Id, testAccount.OwnerId);
        insert testProspectManager;
        Test.stopTest();

        // Assert
        Account assertAccount = [SELECT OwnerId FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(testUser.Id, assertAccount.OwnerId);
    }

    @IsTest
    static void testUpdate() {
        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        AQB__PMTeam__c testProspectManager;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            Account testAccount = TestDataFactory.createTestAccount('Household');
            insert testAccount;

            Contact testContact = TestDataFactory.createTestContact();
            testContact.AccountId = testAccount.Id;
            insert testContact;

            // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
            testAccount.AQB__PrimaryContact__c = testContact.Id;
            update testAccount;

            testProspectManager = new AQB__PMTeam__c(
                AQB__Account__c = testAccount.Id,
                AQB__User__c = testUser.Id,
                AQB__Role__c = PMTeamService.PROSPECT_MANAGER
            );
            insert testProspectManager;

            update testProspectManager;
        }
        Test.stopTest();

        // Assert
        System.assertEquals(PMTeamService.PROSPECT_MANAGER, [SELECT AQB__Role__c FROM AQB__PMTeam__c WHERE Id = :testProspectManager.Id].AQB__Role__c);
    }

    @IsTest
    static void testDelete() {
        User testUser = TestDataFactory.createTestUser('UA Prospect Manager');
        insert testUser;

        // Act
        Test.startTest();
        System.runAs(testUser) {
            Account testAccount = TestDataFactory.createTestAccount('Household');
            insert testAccount;

            Contact testContact = TestDataFactory.createTestContact();
            testContact.AccountId = testAccount.Id;
            insert testContact;

            // NOTE: Must set the Primary Contact AFTER inserting the Contact for the Oppty Naming to work.
            testAccount.AQB__PrimaryContact__c = testContact.Id;
            update testAccount;

            AQB__PMTeam__c testProspectManager = new AQB__PMTeam__c(
                AQB__Account__c = testAccount.Id,
                AQB__User__c = testUser.Id,
                AQB__Role__c = PMTeamService.PROSPECT_MANAGER
            );
            insert testProspectManager;

            delete testProspectManager;
        }
        Test.stopTest();

        // Assert
        System.assertEquals(0, [SELECT AQB__Role__c FROM AQB__PMTeam__c].size(), 'PM Team Member should have been deleted.');
    }
}