public class CMU_UpdateGivingTotalsBatch implements Database.Batchable<SObject> {

    public static final String BATCH_CODE = 'UpdateGivingTotals';

    private final Integer fiscalYear;
    private final List<AQB__Membership__c> memberships;
    private final Date processDate;

    private final Map<String, String> schools = new Map<String, String> {
            'Tepper School of Business' => '_Tepper__c',
            'College of Fine Arts' => '_Fine_Arts__c',
            'Heinz College' => '_Heinz__c',
            'University Libraries' => '_Libraries__c',
            'Dietrich College' => '_Dietrich__c',
            'Mellon College of Science' => '_Mellon__c',
            'School of Computer Science' => '_Computer_Science__c',
            'College of Engineering' => '_Engineering__c'
    };

    public static Date getDefaultProcessDate() {
        return Date.today().addDays(-[SELECT Days__c FROM Giving_Totals_Settings__mdt].Days__c.intValue());
    }

    public static Integer getDefaultFiscalYear() {
        return Integer.valueOf([SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name);
    }

    public CMU_UpdateGivingTotalsBatch() {
        this(getDefaultProcessDate(), getDefaultFiscalYear());
    }

    public CMU_UpdateGivingTotalsBatch(Date processDate, Integer fiscalYear) {
        this.processDate = processDate;
        this.fiscalYear = fiscalYear;
        
        this.memberships = [ 
            SELECT Id, AQB__Contact__c, AQB__Contact__r.AccountId, AQB__StartDate__c
            FROM AQB__Membership__c
            WHERE AQB__AffiliatedOrganization__r.Name = 'Order of the May Exception'
            ORDER BY AQB__Contact__r.AccountId, AQB__StartDate__c
        ];         
        
//changed the field back to Contact__c       
        /*        
        this.memberships = [ 
            SELECT Id, AQB__ContactId__c, AQB__ContactId__r.AccountId, AQB__StartDate__c
            FROM AQB__Membership__c
            WHERE AQB__AffiliatedOrganization__r.Name = 'Order of the May Exception'
            ORDER BY AQB__ContactId__r.AccountId, AQB__StartDate__c
        ]; 
        */
        
        
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        /* prepGivingTotals(bc, [SELECT Id FROM Account WHERE Id IN (SELECT AQB__Account__c FROM AQB__Gift__c WHERE LastModifiedDate>:processDate)]); */
        String query = '' +
            'SELECT  Account.Id,(' +
                'SELECT  Id, Account__c, Total_Years_Giving__c, Lifetime_Cash__c, Lifetime_Commitment__c, Cash_Giving_Total_CFY__c, ' +
                '        Lifetime_Commitment_Fine_Arts__c, Lifetime_Commitment_Engineering__c, Lifetime_Commitment_Tepper__c, Lifetime_Commitment_Computer_Science__c, ' +
                '        Lifetime_Commitment_Dietrich__c, Lifetime_Commitment_Mellon__c, Lifetime_Commitment_Libraries__c, Lifetime_Commitment_Heinz__c, ' +
                '        Last_Gift_Amount_Tepper__c, Last_Gift_Amount_Engineering__c, Last_Gift_Amount_Computer_Science__c, Last_Gift_Amount_Mellon__c, ' +
                '        Last_Gift_Amount_Dietrich__c, Last_Gift_Amount_Libraries__c, Last_Gift_Amount_Heinz__c, Last_Gift_Amount_Fine_Arts__c, ' +
                '        Last_Gift_Tepper__c, Last_Gift_Engineering__c, Last_Gift_Computer_Science__c, Last_Gift_Mellon__c, ' +
                '        Last_Gift_Dietrich__c, Last_Gift_Libraries__c, Last_Gift_Heinz__c, Last_Gift_Fine_Arts__c, ' +
                '        Last_Gift_Date_Tepper__c, Last_Gift_Date_Engineering__c, Last_Gift_Date_Computer_Science__c, Last_Gift_Date_Mellon__c, ' +
                '        Last_Gift_Date_Dietrich__c, Last_Gift_Date_Libraries__c, Last_Gift_Date_Heinz__c, Last_Gift_Date_Fine_Arts__c, ' +
                '        Planned_Giver__c ' +
                'FROM    Giving_Totals__r ' +
                ') ' +
            'FROM    Account ' +
            'WHERE   Giving_Totals__c <> NULL ';

        if (this.processDate != null) {
            query += '' +
                    'AND Id IN (' +
                    '   SELECT  AQB__Account__c ' +
                    '   FROM    AQB__Gift__c ' +
                    '   WHERE   LastModifiedDate>:processDate ' +
                    ')';
        }
        Database.QueryLocator resultSet = Database.getQueryLocator(query);
        return resultSet;
    }

    public void execute(Database.BatchableContext context, List<Account> accounts) {
        Id jobId = context.getJobId();

        Map<Id, List<AQB__Transaction__c>> transactionsByAccountId = getTransactionMap(accounts);
        List<Giving_Totals__c> givingTotals = new List<Giving_Totals__c>();

        for (Account act: accounts) {
            List<AQB__Transaction__c> actTrans = transactionsByAccountId.get(act.Id);

            yearsOfGiving(act.Giving_Totals__r, actTrans);
            lifeTimeCashCommitTotals(act.Giving_Totals__r, actTrans);

            givingTotals.add(act.Giving_Totals__r);
        }

        CMU_Util.updatePartial(jobId, givingTotals);
    }

    public void finish(Database.BatchableContext context) {
        CMU_Util.sendJobEmail(context.getJobId(), BATCH_CODE);
    }

    private Map<Id, List<AQB__Transaction__c>> getTransactionMap(List<Account> accounts) {
        Map<Id, List<AQB__Transaction__c>> result = new Map<Id, List<AQB__Transaction__c>>();

        for (Account account : accounts) {
            result.put(account.Id, new List<AQB__Transaction__c>());
        }

        for (AQB__Transaction__c tran : [
                SELECT  Id, AQB__Gift__c, AQB__Account__c, AQB__OriginatingGift__r.AQB__Account__c, AQB__OriginatingGift__r.AQB__Date__c,
                        AQB__DonorDate__c, AQB__Amount__c, AQB__DateDue__c, AQB__Balance__c, AQB__ChartofAccounts__r.AQB__SchoolUnit__c,
                        AQB__Type__c, AQB__PledgePayment__c, Transaction_Fiscal_Year__c, Fiscal_Year__c, Chart_of_Accounts_School_Text__c,
                        AQB__Gift__r.AQB__RollUpMatchingGiftPaymentsMade__c, AQB__Gift__r.AQB__Matched__c,
                        AQB__Account__r.Contacts__c, Reporting_Donor__c, AQB__Gift__r.AQB__Instrument__c, AQB__Gift__r.AQB__Account__r.Contact_Count__c
                FROM    AQB__Transaction__c
                WHERE   AQB__Type__c IN ('Pledge', 'Payment','Soft Credit','Pledge Soft Credit') AND AQB__Voided__c = NULL AND AQB__Amount__c <> 0 AND AQB__Account__c IN :accounts
        ])  {

            result.get(tran.AQB__Account__c).add(tran);
        }

        return result;
    }

    private void lifeTimeCashCommitTotals(Giving_Totals__c givingTotalRecord, List<AQB__Transaction__c> acctTrans) {
        LastLargestGifts lastLargestGifts = new LastLargestGifts();
        FiscalYearTotals fyTotals = new FiscalYearTotals(fiscalYear);
        PledgeInfo pledgeInfo = new PledgeInfo();
        PlannedGiving plannedGiving = new PlannedGiving();

        for (AQB__Transaction__c trans : acctTrans) {
            pledgeInfo.calculate(trans);
            fyTotals.calculate(trans);
            lastLargestGifts.calculate(trans);

            /* totalSchools */
            if(schools.containsKey(trans.Chart_of_Accounts_School_Text__c)) {
                schoolTotals(givingTotalRecord, trans);
            }
            if(plannedGiving.plannedGiver == false) {
                plannedGiving.calculate(trans);
            }
        }

        fyTotals.finalize(givingTotalRecord);
        pledgeInfo.finalize(givingTotalRecord);
        lastLargestGifts.finalize(givingTotalRecord);
        plannedGiving.finalize(givingTotalRecord);
    }

    private void yearsOfGiving(Giving_Totals__c givingTotalRecord, List<AQB__Transaction__c> acctTrans) {
        Integer consecQualYear = fiscalYear-1;
        Integer conTemp = consecQualYear;
        Integer preQualYear = consecQualYear-1;
        Integer preTemp = preQualYear;

        Integer consecutive = 0;
        Integer previous = 0;

        Set<Integer> setOfGivingFiscalYears = new Set<Integer>();
        Set<String> yearsOfGiving = new Set<String>();

        /* Memberships */
        Integer fiscalYear;
        for(AQB__Membership__c membership : memberships) { 
            if (givingTotalRecord.Account__c == membership.AQB__ContactId__r.AccountId) {

                if (membership.AQB__StartDate__c.month() > 6) {
                    fiscalYear = membership.AQB__StartDate__c.addYears(+1).year();
                }
                else {
                    fiscalYear = membership.AQB__StartDate__c.year();
                }
            }
            setOfGivingFiscalYears.add(fiscalYear);
            yearsOfGiving.add(String.valueOf(fiscalYear));
        }

        for(AQB__Transaction__c trans : acctTrans) {
            if ((trans.AQB__Type__c == 'Pledge' && trans.AQB__PledgePayment__c == true && (trans.Transaction_Fiscal_Year__c).trim() != '' && (trans.Transaction_Fiscal_Year__c) != null)
                    || trans.AQB__Type__c == 'Payment' || trans.AQB__Type__c == 'Soft Credit' || trans.AQB__Type__c == 'Pledge Soft Credit') {
                if (trans.AQB__Amount__c > 0) {
                    yearsOfGiving.add(trans.Transaction_Fiscal_Year__c);
                }
                if (trans.Transaction_Fiscal_Year__c != null && trans.Transaction_Fiscal_Year__c.isNumeric()) {
                    setOfGivingFiscalYears.add(Integer.valueOf(trans.Transaction_Fiscal_Year__c));
                }
            }
        }

        while (setOfGivingFiscalYears.contains(conTemp)) {
            consecutive++;
            conTemp--;
        }

        while (setOfGivingFiscalYears.contains(preTemp)) {
            previous++;
            preTemp--;
        }

        givingTotalRecord.Total_Years_Giving__c = yearsOfGiving.size();
        givingTotalRecord.Consecutive_Years_of_Giving__c = consecutive;
        givingTotalRecord.Consecutive_Previous_Years_of_Giving__c = previous;
    }

    private void schoolTotals(Giving_Totals__c givingTotalRecord, AQB__Transaction__c trans) {
        String schoolBase = schools.get(trans.Chart_of_Accounts_School_Text__c);

        if ((trans.AQB__Type__c == 'Pledge' && trans.AQB__PledgePayment__c <> true)
                || trans.AQB__Type__c == 'Payment' || trans.AQB__Type__c == 'Soft Credit' || trans.AQB__Type__c == 'Pledge Soft Credit') {
            if (trans.AQB__Amount__c <> 0 && (trans.AQB__OriginatingGift__r.AQB__Date__c >= (Date)givingTotalRecord.get('Last_Gift_Date' + schoolBase) || ((Date)givingTotalRecord.get('Last_Gift_Date' + schoolBase) == null))) {

                if (trans.AQB__Gift__r.Id == (Id)givingTotalRecord.get('Last_Gift' + schoolBase)) {
                    Double gtTotalGiftAmount = (Double)givingTotalRecord.get('Last_Gift_Amount' + schoolBase) + trans.AQB__Amount__c;
                    givingTotalRecord.put('Last_Gift_Amount'+schoolBase, gtTotalGiftAmount);
                }
                else {
                    givingTotalRecord.put('Last_Gift_Date' + schoolBase, trans.AQB__OriginatingGift__r.AQB__Date__c);
                    givingTotalRecord.put('Last_Gift_Amount' + schoolBase, trans.AQB__Amount__c);
                    givingTotalRecord.put('Last_Gift' + schoolBase, trans.AQB__Gift__c);
                }
            }
            Double gtLiftTimeCommitment = (Double)givingTotalRecord.get('Lifetime_Commitment' + schoolBase)+trans.AQB__Amount__c;
            givingTotalRecord.put('Lifetime_Commitment' + schoolBase, gtLiftTimeCommitment);
        }
    }

    class FiscalYearTotals {
        Integer fiscalYear;
        Decimal fiscalYearTotalc;
        Decimal fiscalYearTotal1;
        Decimal fiscalYearTotal2;
        Decimal fiscalYearTotal3;
        Decimal fiscalYearTotal4;
        Decimal fiscalYearTotal5;
        Decimal lifetimeCash;
        Decimal lifetimeCommit;
        Decimal lifetimeReportingDonorCommit;

        public FiscalYearTotals(Integer fiscalYear) {
            this.fiscalYear = fiscalYear;
            fiscalYearTotalc = 0.00;
            fiscalYearTotal1 = 0.00;
            fiscalYearTotal2 = 0.00;
            fiscalYearTotal3 = 0.00;
            fiscalYearTotal4 = 0.00;
            fiscalYearTotal5 = 0.00;
            lifetimeCash = 0.00;
            lifetimeCommit = 0.00;
            lifetimeReportingDonorCommit = 0.00;
        }

        public void calculate(AQB__Transaction__c trans) {
            if(trans.AQB__Amount__c <> 0) {
                /* COMMIT */
                if ((trans.AQB__Type__c == 'Pledge' && trans.AQB__PledgePayment__c <> true) || trans.AQB__Type__c == 'Payment' || trans.AQB__Type__c == 'Soft Credit' || trans.AQB__Type__c == 'Pledge Soft Credit') {
                    lifetimeCommit += trans.AQB__Amount__c;

                    if (trans.Reporting_Donor__c == trans.AQB__Account__c) {
                        lifetimeReportingDonorCommit += trans.AQB__Amount__c;
                        if (trans.AQB__Gift__r.AQB__RollUpMatchingGiftPaymentsMade__c <> null && trans.AQB__Gift__r.AQB__Matched__c) {
                            lifetimeReportingDonorCommit += trans.AQB__Gift__r.AQB__RollUpMatchingGiftPaymentsMade__c;
                        }
                    }
                }

                /* CASH */
                if ((trans.AQB__Type__c == 'Pledge' && trans.AQB__PledgePayment__c == true) || trans.AQB__Type__c == 'Payment' || trans.AQB__Type__c == 'Soft Credit' || trans.AQB__Type__c == 'Pledge Soft Credit') {
                    lifetimeCash += trans.AQB__Amount__c;
                    if (trans.AQB__Gift__r.AQB__RollUpMatchingGiftPaymentsMade__c <> null) {
                        lifetimeCash += trans.AQB__Gift__r.AQB__RollUpMatchingGiftPaymentsMade__c;
                    }
                }

                /* cashGivingTotalsByFiscalYears */
                if ((trans.AQB__Type__c == 'Pledge' && trans.AQB__PledgePayment__c == true) || (trans.AQB__Type__c == 'Payment' || trans.AQB__Type__c == 'Soft Credit')) {

                    if (trans.Fiscal_Year__c == String.valueOf(fiscalYear)) {
                        fiscalYearTotalc += trans.AQB__Amount__c;
                    }
                    else if (trans.Fiscal_Year__c == String.valueOf(fiscalYear - 1)) {
                        fiscalYearTotal1 += trans.AQB__Amount__c;
                    }
                    else if (trans.Fiscal_Year__c == String.valueOf(fiscalYear - 2)) {
                        fiscalYearTotal2 += trans.AQB__Amount__c;
                    }
                    else if (trans.Fiscal_Year__c == String.valueOf(fiscalYear - 3)) {
                        fiscalYearTotal3 += trans.AQB__Amount__c;
                    }
                    else if (trans.Fiscal_Year__c == String.valueOf(fiscalYear - 4)) {
                        fiscalYearTotal4 += trans.AQB__Amount__c;
                    }
                    else if (trans.Fiscal_Year__c == String.valueOf(fiscalYear - 5)) {
                        fiscalYearTotal5 += trans.AQB__Amount__c;
                    }
                }
            }
        }

        public void finalize(Giving_Totals__c givingTotalRecord) {
            /* cashGivingTotalsByFiscalYears */
            givingTotalRecord.Cash_Giving_Total_CFY__c = fiscalYearTotalc;
            givingTotalRecord.Cash_Giving_Total_P1__c  = fiscalYearTotal1;
            givingTotalRecord.Cash_Giving_Total_P2__c  = fiscalYearTotal2;
            givingTotalRecord.Cash_Giving_Total_P3__c  = fiscalYearTotal3;
            givingTotalRecord.Cash_Giving_Total_P4__c  = fiscalYearTotal4;
            givingTotalRecord.Cash_Giving_Total_P5__c  = fiscalYearTotal5;
            /* cashGivingTotalsByFiscalYears */
            givingTotalRecord.Lifetime_Cash__c = lifetimeCash;
            givingTotalRecord.Lifetime_Commitment__c = lifetimeCommit;
            givingTotalRecord.Lifetime_Reporting_Donor_Commitment__c = lifetimeReportingDonorCommit;
        }
    }

    class LastLargestGifts {
        Date startDate = Date.today().addYears(-200);

        Id transLastGiftId;
        Date transLastGiftDate;
        Decimal transLastGiftAmount;

        Id transLargestGiftId;
        Date transLargestGiftDate;
        Decimal transLargestGiftAmount;

        public LastLargestGifts() {
            transLastGiftDate = startDate;
            transLastGiftAmount = 0.0;
            transLargestGiftDate = startDate;
            transLargestGiftAmount = 0.0;
        }

        public void calculate(AQB__Transaction__c trans) {
            if ((trans.AQB__Type__c == 'Pledge' && trans.AQB__PledgePayment__c == true) || (trans.AQB__Type__c == 'Payment' || trans.AQB__Type__c == 'soft credit' || trans.AQB__Type__c == 'pledge soft credit')) {
                if (trans.AQB__Amount__c > transLargestGiftAmount) {
                    transLargestGiftId = trans.AQB__Gift__c;
                    transLargestGiftDate = trans.AQB__DonorDate__c;
                    transLargestGiftAmount = trans.AQB__Amount__c;
                }
                if (trans.AQB__DonorDate__c > transLastGiftDate) {
                    transLastGiftId = trans.AQB__Gift__c;
                    transLastGiftDate = trans.AQB__DonorDate__c;
                    transLastGiftAmount = trans.AQB__Amount__c;
                }
            }
        }

        public void finalize(Giving_Totals__c givingTotalRecord) {
            /* Last & Largest Gifts */
            if(transLargestGiftDate == startDate) {
                transLargestGiftId = null;
                transLargestGiftDate = null;
                transLargestGiftAmount = 0.0;
            }

            if(transLastGiftDate == startDate) {
                transLastGiftId = null;
                transLastGiftDate = null;
                transLastGiftAmount = 0.0;
            }

            givingTotalRecord.Last_Gift__c = transLastGiftId;
            givingTotalRecord.Last_Gift_Date__c = transLastGiftDate;
            givingTotalRecord.Last_Gift_Amount__c = transLargestGiftAmount;

            givingTotalRecord.Largest_Gift__c = transLargestGiftId;
            givingTotalRecord.Largest_Gift_Date__c = transLargestGiftDate;
            givingTotalRecord.Largest_Gift_Amount__c = transLargestGiftAmount;
        }
    }

    class PledgeInfo {
        Date todaysDate;
        Date dueDate;
        Double outStandingPledgeBalance_v;

        public PledgeInfo() {
            todaysDate = Date.today();
            dueDate = Date.today().addYears(1000);
            outStandingPledgeBalance_v = 0.0;
        }

        public void calculate(AQB__Transaction__c trans) {

            if(trans.AQB__Type__c == 'Pledge' && !trans.AQB__PledgePayment__c && trans.AQB__Balance__c > 0) {
                outStandingPledgeBalance_v += trans.AQB__Balance__c;
            }

            if(trans.AQB__Amount__c > 0 && trans.AQB__Type__c == 'Pledge' && trans.AQB__Balance__c > 0 && (trans.AQB__DateDue__c < dueDate && trans.AQB__DateDue__c >= todaysDate)) {
                dueDate = trans.AQB__DateDue__c;
            }

        }

        public void finalize(Giving_Totals__c givingTotalRecord) {
            givingTotalRecord.Outstanding_Pledge_Balances__c = outStandingPledgeBalance_v;
            givingTotalRecord.Next_Pledge_Payment_Due_Date__c = dueDate;
        }
    }

    class PlannedGiving {
        boolean plannedGiver;

        public PlannedGiving() {
            plannedGiver = false;
        }

        public void calculate(AQB__Transaction__c trans) {
            if(trans.AQB__Gift__r.AQB__Instrument__c != null ) {
                plannedGiver = true;
            }
        }

        public void finalize(Giving_Totals__c givingTotalRecord) {
            givingTotalRecord.Planned_Giver__c = plannedGiver;
        }
    }
}