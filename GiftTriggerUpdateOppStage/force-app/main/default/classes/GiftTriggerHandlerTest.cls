/**
* @author Mathew Ruff, Sierra-Cedar
* @date 10/30/18
*
* Unit Tests for GiftTriggerHandler.cls
*/
@IsTest
private class GiftTriggerHandlerTest {
    @IsTest
    static void testMoveOpportunityToAccepted() {
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

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity('Discovery', 'Major Gift');
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        insert testOpportunity;

        AQB__Gift__c testGift = new AQB__Gift__c(
            AQB__Account__c = testAccount.Id,
            AQB__Date__c = Date.today(),
            AQB__CreditedOpportunity__c = testOpportunity.Id,
            RecordTypeId = GiftService.giftRTInfosMap.get(GiftService.PLEDGE).getRecordTypeId()
        );

        // Act
        Test.startTest();
        insert testGift;
        Test.stopTest();

        // Assert
        System.assertEquals(
            OpportunityService.ACCEPTED,
            [SELECT StageName FROM Opportunity WHERE Id = :testOpportunity.Id].StageName,
            'StageName of Opportunity should have been updated to \'Accepted\'.'
        );
    }

    @IsTest
    static void testMoveOpportunityToAcceptedAfterLinkingGift() {
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

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity('Discovery', 'Major Gift');
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        insert testOpportunity;

        AQB__Gift__c testGift = new AQB__Gift__c(
            AQB__Account__c = testAccount.Id,
            AQB__Date__c = Date.today(),
            RecordTypeId = GiftService.giftRTInfosMap.get(GiftService.PLEDGE).getRecordTypeId()
        );
        insert testGift;

        // Act
        Test.startTest();
        testGift.AQB__CreditedOpportunity__c = testOpportunity.Id;
        update testGift;
        Test.stopTest();

        // Assert
        System.assertEquals(
            OpportunityService.ACCEPTED,
            [SELECT StageName FROM Opportunity WHERE Id = :testOpportunity.Id].StageName,
            'StageName of Opportunity should have been updated to \'Accepted\'.'
        );
    }

    @IsTest
    static void testFlagOpportunityFundingComplete() {
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

        Opportunity testOpportunity = TestDataFactory.createTestOpportunity('Discovery', 'Major Gift');
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.OwnerId = testUser.Id;
        testOpportunity.Amount = 5000;
        insert testOpportunity;

        Campaign testCampaign = TestDataFactory.createTestCampaign('Test Campaign');
        insert testCampaign;

        AQB__Gift__c testPledge = new AQB__Gift__c(
            AQB__Account__c = testAccount.Id,
            AQB__Date__c = Date.today(),
            AQB__CreditedOpportunity__c = testOpportunity.Id,
            RecordTypeId = GiftService.giftRTInfosMap.get(GiftService.PLEDGE).getRecordTypeId()
        );
        insert testPledge;

        AQB__Transaction__c testTransaction1 = new AQB__Transaction__c(
            AQB__Amount__c = 200,
            AQB__CreditedOpportunity__c = testOpportunity.Id,
            AQB__Gift__c = testPledge.Id,
            AQB__Account__c = testAccount.Id,
            AQB__Date__c = Date.today(),
            AQB__CampaignAppeal__c = testCampaign.Id,
            AQB__Type__c = 'Payment'
        );
        insert testTransaction1;

        AQB__Gift__c testGift = new AQB__Gift__c(
            AQB__Account__c = testAccount.Id,
            AQB__Date__c = Date.today(),
            AQB__CreditedOpportunity__c = testOpportunity.Id,
            RecordTypeId = GiftService.giftRTInfosMap.get(GiftService.GIFT).getRecordTypeId()
        );
        insert testGift;

        AQB__Transaction__c testTransaction2 = new AQB__Transaction__c(
            AQB__Amount__c = 4800,
            AQB__CreditedOpportunity__c = testOpportunity.Id,
            AQB__Gift__c = testGift.Id,
            AQB__Account__c = testAccount.Id,
            AQB__Date__c = Date.today(),
            AQB__CampaignAppeal__c = testCampaign.Id,
            AQB__Type__c = 'Payment'
        );

        // Act
        Test.startTest();
        // Insert remaining amount in a transaction, should flag the Opportunity.
        insert testTransaction2;
        Test.stopTest();

        // Assert
        System.assertEquals(
            true,
            [SELECT AQB__FundingComplete__c FROM Opportunity WHERE Id = :testOpportunity.Id].AQB__FundingComplete__c,
            'Funding Complete should have been checked on the Opportunity.'
        );
    }

    @IsTest
    static void testUpdate() {
        // Arrange
        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        AQB__Gift__c testGift = new AQB__Gift__c(
            AQB__Account__c = testAccount.Id,
            AQB__Date__c = Date.today(),
            RecordTypeId = GiftService.giftRTInfosMap.get(GiftService.PLEDGE).getRecordTypeId()
        );
        insert testGift;

        // Act
        Test.startTest();
        testGift.AQB__Date__c = Date.today().addDays(-20);
        update testGift;
        Test.stopTest();

        // Assert
        System.assertEquals(Date.today().addDays(-20), [SELECT AQB__Date__c FROM AQB__Gift__c WHERE Id = :testGift.Id].AQB__Date__c);
    }

    @IsTest
    static void testDelete() {
        // Arrange
        Account testAccount = TestDataFactory.createTestAccount('Household');
        insert testAccount;

        AQB__Gift__c testGift = new AQB__Gift__c(
            AQB__Account__c = testAccount.Id,
            AQB__Date__c = Date.today(),
            RecordTypeId = GiftService.giftRTInfosMap.get(GiftService.PLEDGE).getRecordTypeId()
        );
        insert testGift;

        // Act 
        Test.startTest();
        delete testGift;
        Test.stopTest();

        // Assert
        System.assertEquals(0, [SELECT Id FROM AQB__Gift__c].size());
    }
}