/**
* @author Mathew Ruff, Sierra-Cedar
* @date 10/17/18
*
* Runs logic on AQB__PMTeam__c Records.
*/
public class PMTeamService {
    public static final String PROSPECT_MANAGER = Label.Prospect_Manager;
    public static final String TEMP_MANAGER = Label.Temporary_Prospect_Manager;
    public static final String GIVING_ADVISOR = Label.Planned_Giving_Advisor;
    public static final String SECONDARY_PARTNER = Label.Secondary_Partner;

    private static Map<String, RecordTypeInfo> accountRTInfosMap {
        get {
            if (accountRTInfosMap == null) {
                accountRTInfosMap = Account.getSObjectType().getDescribe().getRecordTypeInfosByName();
            }

            return accountRTInfosMap;
        }

        set;
    }

    private static Map<String, RecordTypeInfo> oppRTInfosMap {
        get {
            if (oppRTInfosMap == null) {
                oppRTInfosMap = Opportunity.getSObjectType().getDescribe().getRecordTypeInfosByName();
            }

            return oppRTInfosMap;
        }

        set;
    }

    private static String majorGiftsCampaignId {
        get {
            if (majorGiftsCampaignId == null) {
                List<Campaign> majorCampaigns = [SELECT Id FROM Campaign WHERE Name = 'Major Gifts Conversion Campaign' AND IsActive = TRUE];

                if (!majorCampaigns.isEmpty()) {
                    majorGiftsCampaignId = majorCampaigns[0].Id;
                } else {
                    majorGiftsCampaignId = '';
                }
            }

            return majorGiftsCampaignId;
        }

        set;
    }

    private static String researchPMLeaderRoleId {
        get {
            if (researchPMLeaderRoleId == null) {
                List<User> users = [SELECT Id FROM User WHERE UserRole.DeveloperName = 'Research_Prospect_Management_Leader'];
                if (!users.isEmpty()) {
                    researchPMLeaderRoleId = users[0].Id;
                } else {
                    researchPMLeaderRoleId = '';
                }
            }

            return researchPMLeaderRoleId;
        }

        set;
    }

    /**
     * Validates new PM Team Members based on business requirements and adds errors.
     *
     * @param newMembers, the Trigger.new value of new records.
     */
    public static void validateTeamMembers(List<AQB__PMTeam__c> newMembers) {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Map<String, Id>> existingRoleToIdMap = new Map<Id, Map<String, Id>>();

        for (AQB__PMTeam__c newMember : newMembers) {
            if (!String.isBlank(newMember.AQB__Account__c) && newMember.AQB__EndDate__c == null) {
                accountIds.add(newMember.AQB__Account__c);
            }
        }

        for (Account a : [
            SELECT (
                SELECT AQB__Role__c, AQB__EndDate__c, AQB__StartDate__c, AQB__User__c, AQB__Account__c
                FROM AQB__Prospect_Management_Team__r
                WHERE AQB__EndDate__c = NULL
            )
            FROM Account
            WHERE Id IN :accountIds
        ]) {
            for (AQB__PMTeam__c existingMember : a.AQB__Prospect_Management_Team__r) {
                if (Trigger.isUpdate && new Map<Id, AQB__PMTeam__c>(newMembers).keySet().contains(existingMember.Id)) {
                    continue;
                }

                if (!existingRoleToIdMap.containsKey(existingMember.AQB__Account__c)) {
                    existingRoleToIdMap.put(existingMember.AQB__Account__c, new Map<String, Id>{existingMember.AQB__Role__c => existingMember.AQB__User__c});
                } else {
                    existingRoleToIdMap.get(existingMember.AQB__Account__c).put(existingMember.AQB__Role__c, existingMember.AQB__User__c);
                }
            }
        }

        for (AQB__PMTeam__c newMember : newMembers) {
            if (!String.isBlank(newMember.AQB__Account__c)
                && newMember.AQB__EndDate__c == null
                && existingRoleToIdMap.containsKey(newMember.AQB__Account__c)
            ) {
                Boolean pMLead = false, tempLead = false, givingAdvisor = false, secondaryPartner = false;

                if (newMember.AQB__Role__c == PROSPECT_MANAGER) {
                    pmLead = true;
                } else if (newMember.AQB__Role__c == TEMP_MANAGER) {
                    tempLead = true;
                } else if (newMember.AQB__Role__c == GIVING_ADVISOR) {
                    givingAdvisor = true;
                } else if (newMember.AQB__Role__c == SECONDARY_PARTNER) {
                    secondaryPartner = true;
                }

                // The RMT can only have one active Prospect Manager at a time
                if (pmLead && existingRoleToIdMap.get(newMember.AQB__Account__c).containsKey(PROSPECT_MANAGER)) {
                    newMember.addError(
                        'The Relationship Management Team can only have one active ' + PROSPECT_MANAGER + ' at a ' +
                        'time, please adjust the end date so that there is only one active.'
                    );
                }

                // The RMT can only have one active Temporary Prospect Manager at a time.
                if (tempLead && existingRoleToIdMap.get(newMember.AQB__Account__c).containsKey(TEMP_MANAGER)) {
                    newMember.addError(
                        'The Relationship Management Team can only have one active ' + TEMP_MANAGER + ' at a ' +
                        'time, please adjust the end date so that there is only one active.'
                    );
                }

                // The RMT can only have one active Planned Giving Advisor at a time.
                if (givingAdvisor && existingRoleToIdMap.get(newMember.AQB__Account__c).containsKey(GIVING_ADVISOR)) {
                    newMember.addError(
                        'The Relationship Management Team can only have one active ' + GIVING_ADVISOR + ' at a ' +
                        'time, please adjust the end date so that there is only one active.'
                    );
                }

                //  You cannot have an active Prospect Manager and a Temporary Prospect Manager at the same time.
                if ((pmLead && existingRoleToIdMap.get(newMember.AQB__Account__c).containsKey(TEMP_MANAGER))
                    || (tempLead && existingRoleToIdMap.get(newMember.AQB__Account__c).containsKey(PROSPECT_MANAGER))
                ) {
                    newMember.addError(
                        'You cannot have an active ' + PROSPECT_MANAGER + ' and a ' + TEMP_MANAGER + ' at the same ' +
                        'time. Please adjust the end date so only one is active.'
                    );
                }

                // You can have an active Prospect Manager and Planned Giving Advisor at the same time but they cannot be the same user.
                if ((pMLead && existingRoleToIdMap.get(newMember.AQB__Account__c).containsKey(GIVING_ADVISOR)
                        && newMember.AQB__User__c == existingRoleToIdMap.get(newMember.AQB__Account__c).get(GIVING_ADVISOR))
                    || (givingAdvisor && existingRoleToIdMap.get(newMember.AQB__Account__c).containsKey(PROSPECT_MANAGER)
                        && newMember.AQB__User__c == existingRoleToIdMap.get(newMember.AQB__Account__c).get(PROSPECT_MANAGER))
                ) {
                    newMember.addError(
                        'A user cannot be both the ' + GIVING_ADVISOR + ' and ' + PROSPECT_MANAGER + ', please ' +
                        'adjust the user so they only appear in one active role at a time.'
                    );
                }

                // You can have an active Temporary Prospect Manager and Planned Giving Advisor at the same time but they cannot be the same user.
                if ((tempLead && existingRoleToIdMap.get(newMember.AQB__Account__c).containsKey(GIVING_ADVISOR)
                        && newMember.AQB__User__c == existingRoleToIdMap.get(newMember.AQB__Account__c).get(GIVING_ADVISOR))
                    || (givingAdvisor && existingRoleToIdMap.get(newMember.AQB__Account__c).containsKey(TEMP_MANAGER)
                        && newMember.AQB__User__c == existingRoleToIdMap.get(newMember.AQB__Account__c).get(TEMP_MANAGER))
                ) {
                    newMember.addError(
                        'A user cannot be both the ' + GIVING_ADVISOR + ' and ' + TEMP_MANAGER + ', please ' +
                        'adjust the user so they only appear in one active role at a time.'
                    );
                }

                // You can have an active Prospect Manager and Secondary Partner at the same time, but they cannot be the same user.
                if ((pMLead && existingRoleToIdMap.get(newMember.AQB__Account__c).containsKey(SECONDARY_PARTNER)
                        && newMember.AQB__User__c == existingRoleToIdMap.get(newMember.AQB__Account__c).get(SECONDARY_PARTNER))
                    || (secondaryPartner && existingRoleToIdMap.get(newMember.AQB__Account__c).containsKey(PROSPECT_MANAGER)
                        && newMember.AQB__User__c == existingRoleToIdMap.get(newMember.AQB__Account__c).get(PROSPECT_MANAGER))
                ) {
                    newMember.addError(
                        'A user cannot be both the ' + PROSPECT_MANAGER + ' and ' + SECONDARY_PARTNER + ', please ' +
                        'adjust the user so they only appear in one active role at a time.'
                    );
                }
            }
        }
    }

    /**
     * Creates Major Gift Opportunities when PM Prospect Managers are created, only for Household Account Record Types.
     *
     * @param newMembers, a List of Trigger.new records to check.
     */
    public static void createMajorGiftOpportunities(List<AQB__PMTeam__c> newMembers) {
        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        Map<Id, Id> accountRecordTypeIdMap = new Map<Id, Id>();
        Set<Id> accountIds = new Set<Id>();

        for (AQB__PMTeam__c newMember : newMembers) {
            if (!String.isBlank(newMember.AQB__Account__c)) {
                accountIds.add(newMember.AQB__Account__c);
            }
        }

        for (Account a : [SELECT RecordTypeId FROM Account WHERE Id IN :accountIds]) {
            accountRecordTypeIdMap.put(a.Id, a.RecordTypeId);
        }

        for (AQB__PMTeam__c newMember : newMembers) {
            if (!String.isBlank(newMember.AQB__Account__c)
                && accountRecordTypeIdMap.containsKey(newMember.AQB__Account__c)
                && accountRecordTypeIdMap.get(newMember.AQB__Account__c) == accountRTInfosMap.get('Household').getRecordTypeId()
                && newMember.AQB__Role__c == PROSPECT_MANAGER && newMember.AQB__Active__c
            ) {
                opportunitiesToInsert.add(createGiftOppty(newMember.AQB__User__c, newMember.AQB__Account__c));
            }
        }

        if (!opportunitiesToInsert.isEmpty()) {
            insert opportunitiesToInsert;

            List<OpportunityTeamMember> membersToInsert = new List<OpportunityTeamMember>();

            for (Opportunity oppty : opportunitiesToInsert) {
                membersToInsert.add(new OpportunityTeamMember(
                    OpportunityId = oppty.Id,
                    UserId = oppty.OwnerId,
                    TeamMemberRole = 'Team Leader'
                ));
            }

            if (!membersToInsert.isEmpty()) {
                insert membersToInsert;
            }
        }
    }

    /**
     * Creates a new Major Gift Opportunity.
     *
     * @param ownerId, the Owner to assign.
     * @param accountId, the Account to assign.
     * @return the new Opportunity.
     */
    public static Opportunity createGiftOppty(Id ownerId, Id accountId) {
        return new Opportunity(
            Name = 'Major Gifts Opportunity', // Temporary Name, should be overwritten before insert.
            Amount = 0,
            OwnerId = ownerId,
            AccountId = accountId,
            StageName = 'Discovery',
            CloseDate = Date.newInstance(2100, 01, 01),
            RecordTypeId = oppRTInfosMap.get('Major Gift').getRecordTypeId(),
            CampaignId = (!String.isBlank(majorGiftsCampaignId)) ? majorGiftsCampaignId : null
        );
    }

    /**
     * Sets the Owner Id on the related Account to the Prospect Manager if the new member is one.
     *
     * @param newMembers, the Trigger.new values to check.
     */
    public static void setAccountOwner(List<AQB__PMTeam__c> newMembers, Map<Id, AQB__PMTeam__c> oldMap) {
        Map<Id, Account> accountsToUpdateMap = new Map<Id, Account>();

        for (AQB__PMTeam__c newMember : newMembers) {
            if (!String.isBlank(newMember.AQB__Account__c) && !String.isBlank(newMember.AQB__User__c)) {
                if (newMember.AQB__EndDate__c == null) {
                    if (newMember.AQB__Role__c == PROSPECT_MANAGER) {
                        accountsToUpdateMap.put(newMember.AQB__Account__c, new Account(Id = newMember.AQB__Account__c, OwnerId = newMember.AQB__User__c));
                    } else if (newMember.AQB__Role__c == TEMP_MANAGER) {
                        if (!String.isBlank(researchPMLeaderRoleId)) {
                            accountsToUpdateMap.put(newMember.AQB__Account__c, new Account(Id = newMember.AQB__Account__c, OwnerId = researchPMLeaderRoleId));
                        }
                    }
                } else if (oldMap != null
                    && newMember.AQB__Role__c == PROSPECT_MANAGER
                    && (newMember.AQB__EndDate__c != null && oldMap.get(newMember.Id).AQB__EndDate__c == null)
                ) {
                    if (!String.isBlank(researchPMLeaderRoleId)) {
                        accountsToUpdateMap.put(newMember.AQB__Account__c, new Account(Id = newMember.AQB__Account__c, OwnerId = researchPMLeaderRoleId));
                    }
                }
            }
        }

        if (!accountsToUpdateMap.isEmpty()) {
            update accountsToUpdateMap.values();
        }
    }
}