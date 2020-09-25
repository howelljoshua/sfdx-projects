/* *
 * Created by cnolan011 on 10/7/19.
 */
@isTest
public class CMU_UpdateGivingTotalsTest {

    static final String SCHOOL_TEPPER = CMU_TransactionTestFactory.SCHOOL_TEPPER;
    static final String SCHOOL_ENGINEERING = CMU_TransactionTestFactory.SCHOOL_ENGINEERING;
    static final String SCHOOL_COMPUTER_SCIENCE = CMU_TransactionTestFactory.SCHOOL_COMPUTER_SCIENCE;
    static final String SCHOOL_SCIENCE = CMU_TransactionTestFactory.SCHOOL_SCIENCE;
    static final String SCHOOL_DIETRICH = CMU_TransactionTestFactory.SCHOOL_DIETRICH;
    static final String SCHOOL_LIBRARY = CMU_TransactionTestFactory.SCHOOL_LIBRARY;
    static final String SCHOOL_HEINZ = CMU_TransactionTestFactory.SCHOOL_HEINZ;
    static final String SCHOOL_CFA = CMU_TransactionTestFactory.SCHOOL_CFA;

    static final Decimal DEFAULT_GIFT_AMOUNT = CMU_TransactionTestFactory.DEFAULT_GIFT_AMOUNT;

    @isTest
    static void scheduling() {
        Test.startTest();
        System.schedule('Load Data', '0 0 0 15 3 ? 2022', new CMU_UpdateGivingTotalsSchedule());
        Test.stopTest();
    }

    @isTest
    static void createsGivingTotalRecordForAccount() {
        Account testAccount = CMU_AccountTestFactory.builder()
                .addTransaction(SCHOOL_TEPPER)
                .build();

        testAccount = loadAccount(testAccount.Id);

        System.assert(testAccount.Giving_Totals__c == null);

        runTest();

        testAccount = loadAccount(testAccount.Id);
        System.assert(testAccount.Giving_Totals__c != null);
    }

    @isTest
    static void updatesAccountWithExistingGivingTotalRecord() {
        Account testAccount = CMU_AccountTestFactory.builder()
                .givingTotal()
                .addTransaction(SCHOOL_TEPPER)
                .build();

        testAccount = loadAccount(testAccount.Id);
        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(testAccount.Giving_Totals__c != null);
        System.assert(givingTotals != null);

        runTest();

        testAccount = loadAccount(testAccount.Id);
        givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(testAccount.Giving_Totals__c != null);
        System.assert(givingTotals != null);
    }

    @isTest
    static void lifetimeCommitmentAmountsWithGivingToAllSchoolsTest() {
        Date givingDate = Date.today().addYears(-1);

        Account testAccount = CMU_AccountTestFactory.builder()
                .addTransaction(SCHOOL_COMPUTER_SCIENCE, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate, 'AQB__Gift__r.AQB__Date__c' => givingDate,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT),
                        'AQB__Type__c' => 'Pledge', 'AQB__PledgePayment__c' => false
                })
                .addTransaction(SCHOOL_ENGINEERING, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate, 'AQB__Gift__r.AQB__Date__c' => givingDate,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 2),
                        'AQB__Type__c' => 'Pledge', 'AQB__PledgePayment__c' => false
                })
                .addTransaction(SCHOOL_SCIENCE, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate, 'AQB__Gift__r.AQB__Date__c' => givingDate,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 3),
                        'AQB__Type__c' => 'Pledge', 'AQB__PledgePayment__c' => false
                })
                .addTransaction(SCHOOL_TEPPER, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate, 'AQB__Gift__r.AQB__Date__c' => givingDate,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 4),
                        'AQB__Type__c' => 'Pledge', 'AQB__PledgePayment__c' => false
                })
                .addTransaction(SCHOOL_DIETRICH, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate, 'AQB__Gift__r.AQB__Date__c' => givingDate,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 5),
                        'AQB__Type__c' => 'Pledge', 'AQB__PledgePayment__c' => false
                })
                .addTransaction(SCHOOL_LIBRARY, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate, 'AQB__Gift__r.AQB__Date__c' => givingDate,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 6),
                        'AQB__Type__c' => 'Pledge', 'AQB__PledgePayment__c' => false
                })
                .addTransaction(SCHOOL_HEINZ, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate, 'AQB__Gift__r.AQB__Date__c' => givingDate,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 7),
                        'AQB__Type__c' => 'Pledge', 'AQB__PledgePayment__c' => false
                })
                .addTransaction(SCHOOL_CFA, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate, 'AQB__Gift__r.AQB__Date__c' => givingDate,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 8),
                        'AQB__Type__c' => 'Pledge', 'AQB__PledgePayment__c' => false
                })
                .build();

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);

        runTest();

        givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(givingTotals != null);
        System.assert(givingTotals.Lifetime_Commitment_Computer_Science__c == (1 * DEFAULT_GIFT_AMOUNT));
        System.assert(givingTotals.Lifetime_Commitment_Engineering__c == (2 * DEFAULT_GIFT_AMOUNT));
        System.assert(givingTotals.Lifetime_Commitment_Mellon__c == (3 * DEFAULT_GIFT_AMOUNT));
        System.assert(givingTotals.Lifetime_Commitment_Tepper__c == (4 * DEFAULT_GIFT_AMOUNT));
        System.assert(givingTotals.Lifetime_Commitment_Dietrich__c == (5 * DEFAULT_GIFT_AMOUNT));
        System.assert(givingTotals.Lifetime_Commitment_Libraries__c == (6 * DEFAULT_GIFT_AMOUNT));
        System.assert(givingTotals.Lifetime_Commitment_Heinz__c == (7 * DEFAULT_GIFT_AMOUNT));
        System.assert(givingTotals.Lifetime_Commitment_Fine_Arts__c == (8 * DEFAULT_GIFT_AMOUNT));

        System.assert(givingTotals.Lifetime_Commitment__c == (36 * DEFAULT_GIFT_AMOUNT));
    }

    @isTest
    static void lifetimeCommitmentAmountsWithGivingToSomeSchools() {
        Date largestGiftDate = Date.today() - 15;

        Account testAccount = CMU_AccountTestFactory.builder()
                .addTransaction(SCHOOL_COMPUTER_SCIENCE, new Map<String, Object>{
                        'AQB__DonorDate__c' => largestGiftDate,
                        'AQB__Gift__r.AQB__Date__c' => largestGiftDate,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => false
                })
                .addTransaction(SCHOOL_ENGINEERING, new Map<String, Object>{
                        'AQB__DonorDate__c' => largestGiftDate,
                        'AQB__Gift__r.AQB__Date__c' => largestGiftDate,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 2),
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => false
                })
                .build();

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);

        runTest();

        givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(givingTotals != null);
        System.assert(givingTotals.Lifetime_Commitment_Computer_Science__c == (1 * DEFAULT_GIFT_AMOUNT));
        System.assert(givingTotals.Lifetime_Commitment_Engineering__c == (2 * DEFAULT_GIFT_AMOUNT));

        System.assert(givingTotals.Lifetime_Commitment_Mellon__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Tepper__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Dietrich__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Libraries__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Heinz__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Fine_Arts__c == 0);

        System.assert(givingTotals.Lifetime_Commitment__c == (3 * DEFAULT_GIFT_AMOUNT));
    }

    @isTest
    static void lifetimeCommitmentAmountsWithGivingToNoSchools() {
        Account testAccount = CMU_AccountTestFactory.create();

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);

        runTest();

        givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(givingTotals == null);
    }

    @isTest
    static void cashNonSchoolGiving() {
        Date givingDate = Date.today();

        Account testAccount = CMU_AccountTestFactory.builder()
                .addTransaction(null, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate,
                        'AQB__Gift__r.AQB__Date__c' => givingDate,
                        'AQB__DocumentedLegalDate__c' => givingDate,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1)
                })
                .build();

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);

        runTest();

        givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(givingTotals != null);
        System.assert(givingTotals.Cash_Giving_Total_P1__c == 0);
        System.assert(givingTotals.Cash_Giving_Total_P2__c == 0);
        System.assert(givingTotals.Cash_Giving_Total_P3__c == 0);
        System.assert(givingTotals.Cash_Giving_Total_P4__c == 0);
        System.assert(givingTotals.Cash_Giving_Total_P5__c == 0);

        System.assert(givingTotals.Lifetime_Commitment_Computer_Science__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Engineering__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Mellon__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Tepper__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Dietrich__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Libraries__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Heinz__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Fine_Arts__c == 0);

        System.assert(givingTotals.Lifetime_Commitment__c == 0);
        System.assert(givingTotals.Cash_Giving_Total_CFY__c == (DEFAULT_GIFT_AMOUNT * 1));
    }

    @isTest
    static void lifeTimeCashWithMatchingGift() {
        Date givingDate = Date.today();

        Account testAccount = CMU_AccountTestFactory.create();
        Account matchAccount = CMU_AccountTestFactory.builder()
                .field('Name', 'Match Company')
                .build();

        AQB__Transaction__c matchTransaction = CMU_TransactionTestFactory.builder()
                .account(matchAccount.Id)
                .fields(new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate,
                        'AQB__Gift__r.AQB__Date__c' => givingDate,
                        'AQB__DocumentedLegalDate__c' => givingDate,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 2)
                })
                .build();

        AQB__Transaction__c originalTransaction = CMU_TransactionTestFactory.builder()
                .account(testAccount.Id)
                .fields(new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate, 'AQB__Gift__r.AQB__Date__c' => givingDate,
                        'AQB__DocumentedLegalDate__c' => givingDate,
                        'AQB__Type__c' => 'Pledge', 'AQB__PledgePayment__c' => true,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__Gift__r.AQB__IncludeUnconditionalPledgeInTotal__c' => true,
                        'AQB__Gift__r.AQB__IncludeMatchDueInTotal__c' => false,
                        'AQB__Gift__r.AQB__IncludeMatchPaidInTotal__c' => true,
                        'AQB__Gift__r.AQB__Matched__c' => true,
                        'AQB__Gift__r.AQB__MatchLink__c' => matchTransaction.AQB__Gift__c
                })
                .build();

        AQB__MatchLink__c matchLink = new AQB__MatchLink__c(
                AQB__MatchedGift__c = originalTransaction.AQB__Gift__c,
                AQB__MatchingGift__c = matchTransaction.AQB__Gift__c,
                AQB__MatchPaymentsMade__c = (DEFAULT_GIFT_AMOUNT * 2)
        );
        insert matchLink;

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);

        runTest();

        givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(givingTotals != null);
        System.assertEquals((DEFAULT_GIFT_AMOUNT * 3), givingTotals.Lifetime_Cash__c);
    }

    @isTest
    static void commitmentNonSchoolGiving() {
        Date givingDate = Date.today();

        Account testAccount = CMU_AccountTestFactory.builder()
                .addTransaction(null, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate,
                        'AQB__Gift__r.AQB__Date__c' => givingDate,
                        'AQB__DocumentedLegalDate__c' => givingDate,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => false,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1)
                })
                .build();

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);

        runTest();

        givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(givingTotals != null);
        System.assert(givingTotals.Cash_Giving_Total_P1__c == 0);
        System.assert(givingTotals.Cash_Giving_Total_P2__c == 0);
        System.assert(givingTotals.Cash_Giving_Total_P3__c == 0);
        System.assert(givingTotals.Cash_Giving_Total_P4__c == 0);
        System.assert(givingTotals.Cash_Giving_Total_P5__c == 0);

        System.assert(givingTotals.Lifetime_Commitment_Computer_Science__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Engineering__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Mellon__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Tepper__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Dietrich__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Libraries__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Heinz__c == 0);
        System.assert(givingTotals.Lifetime_Commitment_Fine_Arts__c == 0);

        System.assert(givingTotals.Lifetime_Commitment__c == (DEFAULT_GIFT_AMOUNT * 1));
        System.assert(givingTotals.Cash_Giving_Total_CFY__c == 0);
    }
    @isTest
    static void largestGiftTest() {
        Date largestGiftDate = Date.today() - 15;

        Account testAccount = CMU_AccountTestFactory.builder()
                .addTransaction(SCHOOL_TEPPER, new Map<String, Object>{
                        'AQB__DonorDate__c' => largestGiftDate,
                        'AQB__Gift__r.AQB__Date__c' => largestGiftDate,
                        'AQB__DocumentedLegalDate__c' => largestGiftDate,
                        'AQB__Gift__r.AQB__IncludeUnconditionalPledgeInTotal__c' => true,
                        'AQB__Gift__r.AQB__IncludeMatchDueInTotal__c' => false,
                        'AQB__Gift__r.AQB__IncludeMatchPaidInTotal__c' => false,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true
                })
                .build();

        /*Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);*/

        runTest();

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(givingTotals != null);
        System.assert(givingTotals.Largest_Gift_Date__c == largestGiftDate);
    }

    /*@isTest
    static void oldModifyDate() {
        Date largestGiftDate = Date.today() - 15;

        Account testAccount = CMU_AccountTestFactory.builder()
                .addTransaction(SCHOOL_TEPPER, new Map<String, Object>{
                        'AQB__DonorDate__c' => largestGiftDate,
                        'AQB__Gift__r.AQB__Date__c' => largestGiftDate,
                        'AQB__DocumentedLegalDate__c' => largestGiftDate,
                        'AQB__Gift__r.AQB__IncludeUnconditionalPledgeInTotal__c' => true,
                        'AQB__Gift__r.AQB__IncludeMatchDueInTotal__c' => false,
                        'AQB__Gift__r.AQB__IncludeMatchPaidInTotal__c' => false,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true
                })
                .build();

        runTest();

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);

        System.assertEquals(null, givingTotals);
        //System.assertEquals(largestGiftDate, givingTotals.Largest_Gift_Date__c);
    }*/

    @isTest
    static void lastGiftDateTest() {
        Account testAccount = CMU_AccountTestFactory.create();
        Date giftDate = Date.today().addDays(-30);
        Date lastGiftDate = Date.today().addDays(-15);

        AQB__Transaction__c trans1 = CMU_TransactionTestFactory.builder()
                .account(testAccount.Id)
                .school(SCHOOL_TEPPER)
                .fields(new Map<String, Object>{
                        'AQB__DonorDate__c' => giftDate,
                        'AQB__DocumentedLegalDate__c' => giftDate,
                        'AQB__Gift__r.AQB__Date__c' => giftDate,
                        'AQB__Gift__r.AQB__IncludeUnconditionalPledgeInTotal__c' => true,
                        'AQB__Gift__r.AQB__IncludeMatchDueInTotal__c' => false,
                        'AQB__Gift__r.AQB__IncludeMatchPaidInTotal__c' => false,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true
                })
                .build();

        AQB__Transaction__c trans3 = CMU_TransactionTestFactory.builder()
                .account(testAccount.Id)
                .school(SCHOOL_TEPPER)
                .fields(new Map<String, Object>{
                        'AQB__DonorDate__c' => lastGiftDate.addDays(1),
                        'AQB__DocumentedLegalDate__c' => lastGiftDate.addDays(1),
                        'AQB__Gift__c' => trans1.AQB__Gift__c,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true
                })
                .build();

        AQB__Transaction__c trans2 = CMU_TransactionTestFactory.builder()
                .account(testAccount.Id)
                .fields(new Map<String, Object>{
                        'AQB__DonorDate__c' => lastGiftDate,
                        'AQB__DocumentedLegalDate__c' => lastGiftDate,
                        'AQB__Gift__r.AQB__Date__c' => lastGiftDate,
                        'AQB__Gift__r.AQB__IncludeUnconditionalPledgeInTotal__c' => true,
                        'AQB__Gift__r.AQB__IncludeMatchDueInTotal__c' => false,
                        'AQB__Gift__r.AQB__IncludeMatchPaidInTotal__c' => false,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true
                })
                .build();

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);

        runTest();

        givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(givingTotals != null);
        System.assert(givingTotals.Last_Gift_Date__c == trans3.AQB__DonorDate__c);
    }

    @isTest
    static void lastGiftTest() {
        Account testAccount = CMU_AccountTestFactory.create();
        Date giftDate = Date.today().addDays(-30);
        Date lastGiftDate = Date.today().addDays(-15);

        AQB__Transaction__c trans1 = CMU_TransactionTestFactory.builder()
                .account(testAccount.Id)
                .school(SCHOOL_TEPPER)
                .fields(new Map<String, Object>{
                        'AQB__DonorDate__c' => giftDate,
                        'AQB__DocumentedLegalDate__c' => giftDate,
                        'AQB__Gift__r.AQB__Date__c' => giftDate,
                        'AQB__Gift__r.AQB__IncludeUnconditionalPledgeInTotal__c' => true,
                        'AQB__Gift__r.AQB__IncludeMatchDueInTotal__c' => false,
                        'AQB__Gift__r.AQB__IncludeMatchPaidInTotal__c' => false,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true
                })
                .build();

        AQB__Transaction__c trans3 = CMU_TransactionTestFactory.builder()
                .account(testAccount.Id)
                .school(SCHOOL_TEPPER)
                .fields(new Map<String, Object>{
                        'AQB__DonorDate__c' => lastGiftDate.addDays(1),
                        'AQB__DocumentedLegalDate__c' => lastGiftDate.addDays(1),
                        'AQB__Gift__c' => trans1.AQB__Gift__c,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true
                })
                .build();

        AQB__Transaction__c trans2 = CMU_TransactionTestFactory.builder()
                .account(testAccount.Id)
                .fields(new Map<String, Object>{
                        'AQB__DonorDate__c' => lastGiftDate,
                        'AQB__DocumentedLegalDate__c' => lastGiftDate,
                        'AQB__Gift__r.AQB__Date__c' => lastGiftDate,
                        'AQB__Gift__r.AQB__IncludeUnconditionalPledgeInTotal__c' => true,
                        'AQB__Gift__r.AQB__IncludeMatchDueInTotal__c' => false,
                        'AQB__Gift__r.AQB__IncludeMatchPaidInTotal__c' => false,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true
                })
                .build();

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);

        runTest();

        givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(givingTotals != null);
        System.assert(givingTotals.Last_Gift__c == trans3.AQB__Gift__c);
    }

    @isTest
    static void lastSchoolGiftTest() {
        Date giftDate = Date.today().addDays(-30);
        Date lastGiftDate = Date.today().addDays(-15);

        Account testAccount = CMU_AccountTestFactory.create();

        AQB__Transaction__c trans1 = CMU_TransactionTestFactory.builder()
                .account(testAccount.Id)
                .school(SCHOOL_TEPPER)
                .fields(new Map<String, Object>{
                        'AQB__DonorDate__c' => giftDate,
                        'AQB__Gift__r.AQB__Date__c' => giftDate,
                        'AQB__Gift__r.AQB__IncludeUnconditionalPledgeInTotal__c' => true,
                        'AQB__Gift__r.AQB__IncludeMatchDueInTotal__c' => false,
                        'AQB__Gift__r.AQB__IncludeMatchPaidInTotal__c' => false,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => false
                })
                .build();

        AQB__Transaction__c trans3 = CMU_TransactionTestFactory.builder()
                .account(testAccount.Id)
                .school(SCHOOL_TEPPER)
                .fields(new Map<String, Object>{
                        'AQB__DonorDate__c' => lastGiftDate.addDays(1),
                        'AQB__Gift__c' => trans1.AQB__Gift__c,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => false
                })
                .build();

        AQB__Transaction__c trans2 = CMU_TransactionTestFactory.builder()
                .account(testAccount.Id)
                .fields(new Map<String, Object>{
                        'AQB__DonorDate__c' => lastGiftDate,
                        'AQB__Gift__r.AQB__Date__c' => lastGiftDate,
                        'AQB__Gift__r.AQB__IncludeUnconditionalPledgeInTotal__c' => true,
                        'AQB__Gift__r.AQB__IncludeMatchDueInTotal__c' => false,
                        'AQB__Gift__r.AQB__IncludeMatchPaidInTotal__c' => false,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => false
                })
                .build();

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);

        runTest();

        givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(givingTotals != null);
        System.assert(givingTotals.Last_Gift_Tepper__c == trans3.AQB__Gift__c);
    }

    @isTest
    static void outstandingPledgeBalanceTest() {
        Date pledgeDate = Date.today() - 15;

        Account testAccount = CMU_AccountTestFactory.builder()
                .addTransaction(SCHOOL_TEPPER, new Map<String, Object>{
                        'AQB__DonorDate__c' => pledgeDate,
                        'AQB__Gift__r.AQB__Date__c' => pledgeDate,
                        'AQB__DocumentedLegalDate__c' => pledgeDate,
                        'AQB__Gift__r.AQB__IncludeUnconditionalPledgeInTotal__c' => true,
                        'AQB__Gift__r.AQB__IncludeMatchDueInTotal__c' => false,
                        'AQB__Gift__r.AQB__IncludeMatchPaidInTotal__c' => false,
                        'AQB__Type__c' => 'Pledge', 'AQB__PledgePayment__c' => false,
                        'AQB__Balance__c' => DEFAULT_GIFT_AMOUNT
                })
                .build();

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);

        runTest();

        givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(givingTotals != null);
        System.assert(givingTotals.Outstanding_Pledge_Balances__c == DEFAULT_GIFT_AMOUNT);
    }

    @isTest
    static void cashGivingTotalByFiscalYearTest() {
        Date givingDate = Date.today();
        Date givingDate3 = Date.today().addYears(-3);
        Date givingDate4 = Date.today().addYears(-4);
        Date givingDate9 = Date.today().addYears(-9);

        Account testAccount = CMU_AccountTestFactory.builder()
                .addTransaction(SCHOOL_ENGINEERING, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate,
                        'AQB__Gift__r.AQB__Date__c' => givingDate,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__DocumentedLegalDate__c' => givingDate
                })
                .addTransaction(SCHOOL_COMPUTER_SCIENCE, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate3,
                        'AQB__Gift__r.AQB__Date__c' => givingDate3,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__DocumentedLegalDate__c' => givingDate3
                })
                .addTransaction(SCHOOL_DIETRICH, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate4,
                        'AQB__Gift__r.AQB__Date__c' => givingDate4,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__DocumentedLegalDate__c' => givingDate4
                })
                .addTransaction(SCHOOL_SCIENCE, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate3,
                        'AQB__Gift__r.AQB__Date__c' => givingDate3,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__DocumentedLegalDate__c' => givingDate3
                })
                .addTransaction(SCHOOL_COMPUTER_SCIENCE, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate9,
                        'AQB__Gift__r.AQB__Date__c' => givingDate9,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__DocumentedLegalDate__c' => givingDate9
                })
                .build();

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);

        runTest();

        givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals != null);
        System.assert(givingTotals.Cash_Giving_Total_CFY__c == (DEFAULT_GIFT_AMOUNT * 1));
        System.assert(givingTotals.Cash_Giving_Total_P3__c == (DEFAULT_GIFT_AMOUNT * 2));
        System.assert(givingTotals.Cash_Giving_Total_P4__c == (DEFAULT_GIFT_AMOUNT * 1));
    }

    @isTest
    static void nextPledgePaymentDueTest() {
        Date givingDate = Date.today();
        Date givingDate1 = Date.today().addYears(-1);
        Date givingDate2 = Date.today().addYears(-2);

        Account testAccount = CMU_AccountTestFactory.builder()
                .addTransaction(SCHOOL_ENGINEERING, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate, 'AQB__Gift__r.AQB__Date__c' => givingDate,
                        'AQB__Type__c' => 'Pledge', 'AQB__PledgePayment__c' => false, 'AQB__Balance__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1), 'AQB__DocumentedLegalDate__c' => givingDate, 'AQB__DateDue__c' => givingDate.addYears(2).addMonths(3).addDays(14)
                })
                .addTransaction(SCHOOL_COMPUTER_SCIENCE, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate1, 'AQB__Gift__r.AQB__Date__c' => givingDate1,
                        'AQB__Type__c' => 'Pledge', 'AQB__PledgePayment__c' => false, 'AQB__Balance__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1), 'AQB__DocumentedLegalDate__c' => givingDate, 'AQB__DateDue__c' => givingDate.addYears(1).addMonths(3).addDays(14)
                })
                .addTransaction(SCHOOL_DIETRICH, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate2, 'AQB__Gift__r.AQB__Date__c' => givingDate2,
                        'AQB__Type__c' => 'Pledge', 'AQB__PledgePayment__c' => false, 'AQB__Balance__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1), 'AQB__DocumentedLegalDate__c' => givingDate, 'AQB__DateDue__c' => givingDate.addYears(1).addMonths(2).addDays(14)
                })
                .build();

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);

        runTest();

        givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals != null);
        System.assert(givingTotals.Next_Pledge_Payment_Due_Date__c == (givingDate.addYears(1).addMonths(2).addDays(14)));
    }

    @isTest
    static void totalYearsOfGivingTest() {
        Date givingDate = Date.today();
        Date givingDate1 = Date.today().addYears(-1);
        Date givingDate2 = Date.today().addYears(-2);
        Date givingDate3 = Date.today().addYears(-3);
        Date givingDate4 = Date.today().addYears(-4);

        Account testAccount = CMU_AccountTestFactory.builder()
                .addTransaction(SCHOOL_ENGINEERING, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate,
                        'AQB__Gift__r.AQB__Date__c' => givingDate,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__Balance__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__DocumentedLegalDate__c' => givingDate,
                        'AQB__Date__c' => givingDate
                })
                .addTransaction(SCHOOL_COMPUTER_SCIENCE, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate1,
                        'AQB__Gift__r.AQB__Date__c' => givingDate1,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__Balance__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__DocumentedLegalDate__c' => givingDate1,
                        'AQB__Date__c' => givingDate1
                })
                .addTransaction(SCHOOL_DIETRICH, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate2,
                        'AQB__Gift__r.AQB__Date__c' => givingDate2,
                        'AQB__Type__c' => 'Soft Credit',
                        'AQB__PledgePayment__c' => false,
                        'AQB__Balance__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__DocumentedLegalDate__c' => givingDate2,
                        'AQB__Date__c' => givingDate2
                })
                .addTransaction(SCHOOL_DIETRICH, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate2,
                        'AQB__Gift__r.AQB__Date__c' => givingDate2,
                        'AQB__Type__c' => 'Soft Credit',
                        'AQB__PledgePayment__c' => false,
                        'AQB__Balance__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__DocumentedLegalDate__c' => givingDate2,
                        'AQB__Date__c' => givingDate2
                })
                .addTransaction(SCHOOL_DIETRICH, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate3,
                        'AQB__Gift__r.AQB__Date__c' => givingDate3,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => false,
                        'AQB__Balance__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__DocumentedLegalDate__c' => givingDate3,
                        'AQB__Date__c' => givingDate3
                })
                .addTransaction(SCHOOL_DIETRICH, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate4,
                        'AQB__Gift__r.AQB__Date__c' => givingDate4,
                        'AQB__Type__c' => 'Soft Credit',
                        'AQB__PledgePayment__c' => false,
                        'AQB__Balance__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 1),
                        'AQB__DocumentedLegalDate__c' => givingDate4,
                        'AQB__Date__c' => givingDate4
                })
                .build();

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);

        runTest();

        givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals != null);
        System.assert(givingTotals.Total_Years_Giving__c == 4);
    }


    @isTest
    static void consecutiveYearsOfGiving() {
        Date givingDate1 = Date.today();
        Date givingDate2 = Date.today().addYears(-1);
        Date givingDate3 = Date.today().addYears(-2);
        Date givingDate4 = Date.today().addYears(-3);
        Date givingDate5 = Date.today().addYears(-4);
        Date givingDate6 = Date.today().addYears(-5);
        Date givingDate7 = Date.today().addYears(-6);
        Date givingDate8 = Date.today().addYears(-7);

        Account testAccount = CMU_AccountTestFactory.builder()
                .addTransaction(SCHOOL_COMPUTER_SCIENCE, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate1,
                        'AQB__Gift__r.AQB__Date__c' => givingDate1,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT),
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__DocumentedLegalDate__c' => givingDate1,
                        'AQB__Date__c' => givingDate1
                })
                .addTransaction(SCHOOL_ENGINEERING, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate2,
                        'AQB__Gift__r.AQB__Date__c' => givingDate2,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 2),
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__DocumentedLegalDate__c' => givingDate2,
                        'AQB__Date__c' => givingDate2
                })
                .addTransaction(SCHOOL_SCIENCE, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate3,
                        'AQB__Gift__r.AQB__Date__c' => givingDate3,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 3),
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__DocumentedLegalDate__c' => givingDate3,
                        'AQB__Date__c' => givingDate3
                })
                .addTransaction(SCHOOL_TEPPER, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate4,
                        'AQB__Gift__r.AQB__Date__c' => givingDate4,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 4),
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__DocumentedLegalDate__c' => givingDate4,
                        'AQB__Date__c' => givingDate4
                })
                .addTransaction(SCHOOL_DIETRICH, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate5,
                        'AQB__Gift__r.AQB__Date__c' => givingDate5,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 5),
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__DocumentedLegalDate__c' => givingDate5,
                        'AQB__Date__c' => givingDate5
                })
                .addTransaction(SCHOOL_LIBRARY, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate6,
                        'AQB__Gift__r.AQB__Date__c' => givingDate6,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 6),
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__DocumentedLegalDate__c' => givingDate6,
                        'AQB__Date__c' => givingDate6
                })
                .addTransaction(SCHOOL_HEINZ, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate7,
                        'AQB__Gift__r.AQB__Date__c' => givingDate7,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 7),
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__DocumentedLegalDate__c' => givingDate7,
                        'AQB__Date__c' => givingDate7
                })
                .addTransaction(SCHOOL_CFA, new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate8,
                        'AQB__Gift__r.AQB__Date__c' => givingDate8,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 8),
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__DocumentedLegalDate__c' => givingDate8,
                        'AQB__Date__c' => givingDate8
                })
                .build();

        /*  **************  */
        Contact testContact = new Contact(LastName = 'Order', FirstName = 'May');
        testContact.AccountId = testAccount.id;

        insert testContact;
        Account OrderOfTheMayAccount = new Account(name = 'Order of the May Exception');
        insert OrderOfTheMayAccount;

        AQB__Membership__c membership1 = new AQB__Membership__c(/*AQB__Contact__c*/AQB__ContactId__c = testContact.Id, AQB__AffiliatedOrganization__c = OrderOfTheMayAccount.Id);
        AQB__Membership__c membership2 = new AQB__Membership__c(/*AQB__Contact__c*/AQB__ContactId__c = testContact.Id, AQB__AffiliatedOrganization__c = OrderOfTheMayAccount.Id);

        Date givingDate9 = Date.today().addYears(-8);
        Integer startYear = givingDate9.year() - 1;
        Integer stopYear = givingDate9.year();

        if (givingDate9.month() > 6) {
            startYear = givingDate9.year(); stopYear = givingDate9.year() + 1;
        }

        membership1.AQB__StartDate__c = Date.newInstance(startYear, 7, 1);
        membership1.AQB__StopDate__c = Date.newInstance(stopYear, 6, 30);
        insert membership1;

        membership2.AQB__StartDate__c = Date.newInstance(stopYear - 1, 5, 1);
        membership2.AQB__StopDate__c = Date.newInstance(stopYear - 1, 6, 30);
        insert membership2;

        membership1 = loadMembership(membership1.Id);
        membership2 = loadMembership(membership2.Id);
        /*  **************  */

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);

        runTest();

        givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(givingTotals != null);
        System.assertEquals(9, givingTotals.Consecutive_Years_of_Giving__c);
        System.assertEquals(8, givingTotals.Consecutive_Previous_Years_of_Giving__c);
    }

    @isTest
    static void accountWithNullGivingTotalLink() {
        Date giftDate = Date.today();

        Account testAccount = CMU_AccountTestFactory.builder()
                .addTransaction(SCHOOL_TEPPER, new Map<String, Object>{
                        'AQB__DonorDate__c' => giftDate,
                        'AQB__Gift__r.AQB__Date__c' => giftDate,
                        'AQB__DocumentedLegalDate__c' => giftDate,
                        'AQB__Gift__r.AQB__IncludeUnconditionalPledgeInTotal__c' => true,
                        'AQB__Gift__r.AQB__IncludeMatchDueInTotal__c' => false,
                        'AQB__Gift__r.AQB__IncludeMatchPaidInTotal__c' => false,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true
                })
                .build();

        Giving_Totals__c gt = new Giving_Totals__c(Account__c = testAccount.Id);
        insert gt;

        testAccount = loadAccount(testAccount.Id);

        System.assertEquals(null, testAccount.Giving_Totals__c);
        System.assertEquals(1, [SELECT COUNT() FROM Giving_Totals__c WHERE Account__c = :testAccount.Id]);

        runTest();

        testAccount = loadAccount(testAccount.Id);

        System.assertNotEquals(null, testAccount.Giving_Totals__c);
        System.assertEquals(1, [SELECT COUNT() FROM Giving_Totals__c WHERE Account__c = :testAccount.Id]);
    }

    @isTest
    static void accountWithMultipleGivingTotalRecords() {
        Date giftDate = Date.today();

        Account testAccount = CMU_AccountTestFactory.builder()
                .givingTotal()
                .addTransaction(SCHOOL_TEPPER, new Map<String, Object>{
                        'AQB__DonorDate__c' => giftDate,
                        'AQB__Gift__r.AQB__Date__c' => giftDate,
                        'AQB__DocumentedLegalDate__c' => giftDate,
                        'AQB__Gift__r.AQB__IncludeUnconditionalPledgeInTotal__c' => true,
                        'AQB__Gift__r.AQB__IncludeMatchDueInTotal__c' => false,
                        'AQB__Gift__r.AQB__IncludeMatchPaidInTotal__c' => false,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true
                })
                .build();

        Giving_Totals__c gt = new Giving_Totals__c(Account__c = testAccount.Id);
        insert gt;

        testAccount = loadAccount(testAccount.Id);

        System.assertNotEquals(null, testAccount.Giving_Totals__c);
        System.assertEquals(2, [SELECT COUNT() FROM Giving_Totals__c WHERE Account__c = :testAccount.Id]);

        runTest();

        testAccount = loadAccount(testAccount.Id);

        System.assertNotEquals(null, testAccount.Giving_Totals__c);
        System.assertEquals(1, [SELECT COUNT() FROM Giving_Totals__c WHERE Account__c = :testAccount.Id]);
    }


    @isTest
    static void plannedGiver() {
        Date giftDate = Date.today().addDays(-5);

        Account testAccount = CMU_AccountTestFactory.builder()
                .addTransaction(SCHOOL_TEPPER, new Map<String, Object>{
                        'AQB__DonorDate__c' => giftDate,
                        'AQB__Gift__r.AQB__Date__c' => giftDate,
                        'AQB__DocumentedLegalDate__c' => giftDate,
                        'AQB__Gift__r.AQB__IncludeUnconditionalPledgeInTotal__c' => true,
                        'AQB__Gift__r.AQB__IncludeMatchDueInTotal__c' => false,
                        'AQB__Gift__r.AQB__IncludeMatchPaidInTotal__c' => false,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__Gift__r.AQB__Instrument__c' => 'Bequest'
                })
                .build();

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);

        runTest();

        givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(givingTotals != null);
        System.assert(givingTotals.Planned_Giver__c == true);
    }

    @isTest
    static void whenAccountHasNoGivingTotalsRecord() {
        Date giftDate = Date.today().addDays(-5);

        Account testAccount = CMU_AccountTestFactory.builder()
                .addTransaction(SCHOOL_TEPPER, new Map<String, Object>{
                        'AQB__DonorDate__c' => giftDate,
                        'AQB__Gift__r.AQB__Date__c' => giftDate,
                        'AQB__DocumentedLegalDate__c' => giftDate,
                        'AQB__Gift__r.AQB__IncludeUnconditionalPledgeInTotal__c' => true,
                        'AQB__Gift__r.AQB__IncludeMatchDueInTotal__c' => false,
                        'AQB__Gift__r.AQB__IncludeMatchPaidInTotal__c' => false,
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => true,
                        'AQB__Gift__r.AQB__Instrument__c' => 'Bequest'
                })
                .build();

        /*Giving_Totals__c givingTotals; = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);*/

        runTest();

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(givingTotals != null);
        System.assert(givingTotals.Planned_Giver__c == true);
    }

    /* lifetimeReportingDonorCommit */
    @isTest
    static void lifetimeReportingDonorCommitTotal() {

        Account testAccount = CMU_AccountTestFactory.create();
        Account matchAccount = CMU_AccountTestFactory.builder()
                .field('Name', 'Match Company')
                .build();

        Date givingDate = Date.today();
        Date largestGiftDate = givingDate - 15;

        AQB__Transaction__c matchTransaction = CMU_TransactionTestFactory.builder()
                .account(matchAccount.Id)
                .school(SCHOOL_ENGINEERING)
                .fields(new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate, 'AQB__Gift__r.AQB__Date__c' => givingDate, 'AQB__DocumentedLegalDate__c' => givingDate,
                        'AQB__Type__c' => 'Pledge', 'AQB__PledgePayment__c' => true,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 2)
                })
                .build();

        CMU_TransactionTestFactory.builder()
                .account(testAccount.Id)
                .school(SCHOOL_COMPUTER_SCIENCE)
                .fields(new Map<String, Object>{
                'AQB__DonorDate__c' => largestGiftDate,
                'AQB__Gift__r.AQB__Date__c' => largestGiftDate,
                'AQB__Type__c' => 'Pledge',
                'AQB__PledgePayment__c' => false
        });

        AQB__Transaction__c baseTransaction = CMU_TransactionTestFactory.builder()
                .account(testAccount.Id)
                .school(SCHOOL_ENGINEERING)
                .fields(new Map<String, Object>{
                        'AQB__DonorDate__c' => givingDate,
                        'AQB__Gift__r.AQB__Date__c' => givingDate,
                        'AQB__Amount__c' => (DEFAULT_GIFT_AMOUNT * 2),
                        'AQB__Type__c' => 'Pledge',
                        'AQB__PledgePayment__c' => false,
                        'Reporting_Donor__c' => testAccount.Id,
                        'AQB__Gift__r.AQB__IncludeUnconditionalPledgeInTotal__c' => true,
                        'AQB__Gift__r.AQB__IncludeMatchDueInTotal__c' => false,
                        'AQB__Gift__r.AQB__IncludeMatchPaidInTotal__c' => true,
                        'AQB__Gift__r.AQB__Matched__c' => true,
                        'AQB__Gift__r.AQB__MatchLink__c' => matchTransaction.AQB__Gift__c
                })
                .build();

        AQB__MatchLink__c matchLink = new AQB__MatchLink__c(
                AQB__MatchedGift__c = baseTransaction.AQB__Gift__c,
                AQB__MatchingGift__c = matchTransaction.AQB__Gift__c,
                AQB__MatchPaymentsMade__c = (DEFAULT_GIFT_AMOUNT * 2)
        );

        insert matchLink;

        Giving_Totals__c givingTotals = loadGivingTotals(testAccount.Id);
        System.assert(givingTotals == null);

        runTest(null, 2021);

        givingTotals = loadGivingTotals(testAccount.Id);

        System.assert(givingTotals != null);
        System.assert(givingTotals.Lifetime_Reporting_Donor_Commitment__c == (4 * DEFAULT_GIFT_AMOUNT));
    }

    static void runTest() {
        Test.startTest();
        Database.executeBatch(new CMU_GivingTotalsCleanUpBatch(), 200);
        Test.stopTest();
    }

    static void runTest(Date processDate, Integer fiscalYear) {
        Test.startTest();
        Database.executeBatch(new CMU_GivingTotalsCleanUpBatch(processDate,fiscalYear), 200);
        Test.stopTest();
    }

    static Account loadAccount(Id accountId) {
        return [SELECT Giving_Totals__c FROM Account WHERE Id = :accountId];
    }

    static Giving_Totals__c loadGivingTotals(Id accountId) {
        List<Giving_Totals__c> givingTotals = [
                SELECT
                        Cash_Giving_Total_CFY__c,
                        Cash_Giving_Total_P1__c,
                        Cash_Giving_Total_P2__c,
                        Cash_Giving_Total_P3__c,
                        Cash_Giving_Total_P4__c,
                        Cash_Giving_Total_P5__c,

                        Last_Gift_Amount__c,
                        Last_Gift_Date__c,
                        Largest_Gift_Date__c,
                        Largest_Gift_Amount__c,
                        Last_Gift__c,
                        Largest_Gift__c,
                        Lifetime_Cash__c,
                        Total_Years_Giving__c,
                        Consecutive_Years_of_Giving__c,
                        Consecutive_Previous_Years_of_Giving__c,
                        Outstanding_Pledge_Balances__c,
                        Next_Pledge_Payment_Due_Date__c,
                        Lifetime_Commitment__c,

                        Lifetime_Commitment_Fine_Arts__c,
                        Lifetime_Commitment_Engineering__c,
                        Lifetime_Commitment_Tepper__c,
                        Lifetime_Commitment_Computer_Science__c,
                        Lifetime_Commitment_Dietrich__c,
                        Lifetime_Commitment_Mellon__c,
                        Lifetime_Commitment_Libraries__c,
                        Lifetime_Commitment_Heinz__c,

                        Last_Gift_Amount_Tepper__c,
                        Last_Gift_Amount_Engineering__c,
                        Last_Gift_Amount_Computer_Science__c,
                        Last_Gift_Amount_Mellon__c,
                        Last_Gift_Amount_Dietrich__c,
                        Last_Gift_Amount_Libraries__c,
                        Last_Gift_Amount_Heinz__c,
                        Last_Gift_Amount_Fine_Arts__c,

                        Last_Gift_Tepper__c,
                        Last_Gift_Engineering__c,
                        Last_Gift_Computer_Science__c,
                        Last_Gift_Mellon__c,
                        Last_Gift_Dietrich__c,
                        Last_Gift_Libraries__c,
                        Last_Gift_Heinz__c,
                        Last_Gift_Fine_Arts__c,

                        Last_Gift_Date_Tepper__c,
                        Last_Gift_Date_Engineering__c,
                        Last_Gift_Date_Computer_Science__c,
                        Last_Gift_Date_Mellon__c,
                        Last_Gift_Date_Dietrich__c,
                        Last_Gift_Date_Libraries__c,
                        Last_Gift_Date_Heinz__c,
                        Last_Gift_Date_Fine_Arts__c,
                        Lifetime_Reporting_Donor_Commitment__c,
                        Planned_Giver__c

                FROM Giving_Totals__c
                WHERE Account__c = :accountId
        ];

        if (givingTotals.isEmpty()) {
            return null;
        } else {
            return givingTotals[0];
        }
    }

    static AQB__Membership__c loadMembership(Id membershipId) {
        AQB__Membership__c membership = [
                SELECT Id, /*AQB__Contact__c,*/AQB__ContactId__c, /*AQB__Contact__r.*/AQB__ContactId__r.AccountId, AQB__StartDate__c, AQB__StopDate__c
                FROM AQB__Membership__c
                WHERE AQB__AffiliatedOrganization__r.Name = 'Order of the May Exception' AND Id = :membershipId
                ORDER BY /*AQB__Contact__r.*/AQB__ContactId__r.AccountId, AQB__StartDate__c
        ];
        return membership;
    }
}