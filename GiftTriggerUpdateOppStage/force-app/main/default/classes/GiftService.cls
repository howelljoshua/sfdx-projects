/**
* @author Mathew Ruff, Sierra-Cedar
* @date 10/30/18
*
* Handles logic for the Trigger Handler on the AQB__Gift__c Object.
*/
public class GiftService {
    // Gift Record Types
    public static final String PLEDGE = 'Pledge';
    public static final String GIFT = 'Gift';
    public static final String GRANT = 'Grant';
    public static final String MATCHING = 'Matching Gift';
    public static final String PLANNED = 'Planned Gift';

    public static Map<String, RecordTypeInfo> giftRTInfosMap {
        get {
            if (giftRTInfosMap == null) {
                giftRTInfosMap = AQB__Gift__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
            }

            return giftRTInfosMap;
        }

        set;
    }

    private static Set<Id> pledgeGiftGrantMatchingRTIds {
        get {
            if (pledgeGiftGrantMatchingRTIds == null) {
                pledgeGiftGrantMatchingRTIds = new Set<Id>{
                    giftRTInfosMap.get(PLEDGE).getRecordTypeId(),
                    giftRTInfosMap.get(GIFT).getRecordTypeId(),
                    giftRTInfosMap.get(GRANT).getRecordTypeId(),
                    giftRTInfosMap.get(MATCHING).getRecordTypeId(),
                    giftRTInfosMap.get(PLANNED).getRecordTypeId()
                };
            }

            return pledgeGiftGrantMatchingRTIds;
        }

        set;
    }

    /**
     * Sets related Opportunities Stage to Accepted when the Gift is created.
     *
     * @param newGifts, the Trigger.new List of AQB__Gift__c records.
     */
    public static void setOpportunitiesToAccepted(List<AQB__Gift__c> newGifts, Map<Id, AQB__Gift__c> oldMap) {
        List<AQB__Gift__c> giftsToProcess = new List<AQB__Gift__c>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

        for (AQB__Gift__c gift : newGifts) {
            if (String.isNotBlank(gift.AQB__CreditedOpportunity__c) && (oldMap == null || String.isBlank(oldMap.get(gift.Id).AQB__CreditedOpportunity__c))) {
                giftsToProcess.add(gift);
            }
        }

        for (AQB__Gift__c gift : [
            SELECT AQB__Date__c, AQB__CreditedOpportunity__c, AQB__CreditedOpportunity__r.StageName,
                AQB__CreditedOpportunity__r.RecordTypeId
            FROM AQB__Gift__c
            WHERE Id IN :giftsToProcess
            AND RecordTypeId IN :pledgeGiftGrantMatchingRTIds
        ]) {
            if (gift.AQB__CreditedOpportunity__r.StageName != OpportunityService.ACCEPTED
                && OpportunityService.majorLifeEstateRTIds.contains(gift.AQB__CreditedOpportunity__r.RecordTypeId)
            ) {
                opportunitiesToUpdate.add(new Opportunity(
                    Id = gift.AQB__CreditedOpportunity__c,
                    StageName = OpportunityService.ACCEPTED,
                    CloseDate = gift.AQB__Date__c
                ));
            }
        }

        if (!opportunitiesToUpdate.isEmpty()) {
            OpportunityService.disableAcceptedStage = false;
            update opportunitiesToUpdate;
        }
    }

    /**
     * Checks the Funding Complete box on related Opportunities if all Transactions are paid.
     *
     * @param newGifts, a Trigger.new value of AQB__Gift__c records to check.
     * @param oldMap, a Trigger.oldMap value of AQB__Gift__c records to compare against.
     */
    public static void setOpportunitiesFundingComplete(List<AQB__Gift__c> newGifts, Map<Id, AQB__Gift__c> oldMap) {
        Set<Id> oppIds = new Set<Id>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

        for (AQB__Gift__c gift : newGifts) {
            // Only run check if the Payments have changed
            if (oldMap.get(gift.Id).AQB__RollUpPayments__c != gift.AQB__RollUpPayments__c
                && !String.isBlank(gift.AQB__CreditedOpportunity__c)
            ) {
                oppIds.add(gift.AQB__CreditedOpportunity__c);
            }
        }

        if (!oppIds.isEmpty()) {
            for (Opportunity opp : [
                SELECT Id, Amount, (
                    SELECT AQB__RollUpPayments__c
                    FROM AQB__COGifts__r
                    WHERE RecordTypeId IN :pledgeGiftGrantMatchingRTIds
                )
                FROM Opportunity
                WHERE Id IN :oppIds
                AND RecordTypeId IN :OpportunityService.majorLifeEstateRTIds
            ]) {
                Decimal totalPayments = 0;

                for (AQB__Gift__c gift : opp.AQB__COGifts__r) {
                    totalPayments += gift.AQB__RollUpPayments__c;
                }

                if (totalPayments >= opp.Amount) {
                    opp.AQB__FundingComplete__c = true;
                    opportunitiesToUpdate.add(opp);
                }
            }

            if (!opportunitiesToUpdate.isEmpty()) {
                update opportunitiesToUpdate;
            }
        }
    }
}