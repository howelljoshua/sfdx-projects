/**
* @author Mathew Ruff, Sierra-Cedar
* @date 10/17/18
*
* Runs logic on Opportunity Records.
*
*
* CLASS UPDATED ON 9/16/19 by J.HOWELL (Promoted to Production on 10/29/19)
* Added checks in the ValidateStageName method for IP Opps moving from Disc_Qual or HostedVisit to PropInDev  --- JDH 9/16/2019
*
* Added checks in the ValidateStageName method for IP Opps moving from Disc_Qual, HostedVisit or PropInDev to ProposalOutstanding  -- JDH 9/16/2019 
*
* Added new method to check Opportunities and related Opportunity Component records for required fields before moving Stage to
* 'Proposal In Development'. Adds an Error message to those that do not have the required fields populated -- JDH 9/16/2019
*
* Added New Method to validate required fields are filled out on the Opportunity when moving to the Solicitation Stage -- JDH 9/16/2019
*/
public class OpportunityService {
    // Set by automation, Only allow Opportunities to move to Accepted by automation.
    public static Boolean disableAcceptedStage = true;

    // Opportunity StageNames
    public static final String DISCOVERY = 'Discovery';
    public static final String QUALIFICATION = 'Qualification';
    public static final String CULTIVATION = 'Cultivation';
    public static final String ANTICIPATED_SOLICITATION = 'Anticipated Solicitation';
    public static final String SOLICITATION = 'Solicitation';
    public static final String ACCEPTED = 'Accepted';
    public static final String DISCOVERY_QUALIFICATION = 'Discovery & Qualification';
    public static final String HOSTED_VISIT = 'Hosted Visit';
    public static final String PROPOSAL_IN_DEVELOPMENT = 'Proposal In Development';
    public static final String PROPOSAL_OUTSTANDING = 'Proposal Outstanding';
    public static final String NEGOTIATION_REVIEW = 'Negotiation/Review';
    
    // Opportunity Record Types
    public static final String MAJOR = 'Major Gift';
    public static final String ESTATE = 'Estate Gift';
    public static final String LIFE_INCOME = 'Life Income Gift';
    public static final String GIFT_IP = 'Gift(IP)';
    public static Set<String> ipRecordTypes = new Set<String>{'Career_Recruiting', 'CMU_Real_Estate', 'CMU_Spin_Off_Acquisition', 'CMU_Spin_Off_Investment', 'Economic_Development', 'Executive_Education', 'Gift_IP', 'Licensing', 'Other_unfunded_agreement','Sponsored_Research_Agreements', 'Subcontract_Out'};      

    // Prospect Rating Record Types
    public static final String DISQUALIFIED = 'Disqualified';
    public static final String CAPACITY = 'Capacity Rating';

    public static Map<String, RecordTypeInfo> oppRTInfosMap {
        get {
            if (oppRTInfosMap == null) {
                oppRTInfosMap = Opportunity.getSObjectType().getDescribe().getRecordTypeInfosByName();
            }

            return oppRTInfosMap;
        }

        set;
    }

    public static Set<Id> majorLifeEstateRTIds {
        get {
            if (majorLifeEstateRTIds == null) {
                majorLifeEstateRTIds = new Set<Id>{
                    oppRTInfosMap.get(MAJOR).getRecordTypeId(),
                    oppRTInfosMap.get(ESTATE).getRecordTypeId(),
                    oppRTInfosMap.get(LIFE_INCOME).getRecordTypeId()
                };
            }

            return majorLifeEstateRTIds;
        }

        set;
    }

    public static Set<Id> lifeEstateRTIds {
        get {
            if (lifeEstateRTIds == null) {
                lifeEstateRTIds = new Set<Id>{
                    oppRTInfosMap.get(ESTATE).getRecordTypeId(),
                    oppRTInfosMap.get(LIFE_INCOME).getRecordTypeId()
                };
            }

            return lifeEstateRTIds;
        }

        set;
    }

    private static Map<String, RecordTypeInfo> prosRatingRTInfosMap {
        get {
            if (prosRatingRTInfosMap == null) {
                prosRatingRTInfosMap = Prospect_Rating__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
            }

            return prosRatingRTInfosMap;
        }

        set;
    }

    private static String qualificationQueueId {
        get {
            if (qualificationQueueId == null) {
                qualificationQueueId = '';

                List<Group> qualificationGroupList = new List<Group>([
                    SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Qualification_Queue'
                ]);

                if (!qualificationGroupList.isEmpty()) {
                    qualificationQueueId = qualificationGroupList[0].Id;
                }
            }

            return qualificationQueueId;
        }

        set;
    }

    private static Set<Id> qualificationQueueMemberIds {
        get {
            if (qualificationQueueMemberIds == null) {
                qualificationQueueMemberIds = new Set<Id>();

                if (!String.isBlank(qualificationQueueId)) {
                    for (GroupMember member : [
                        SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :qualificationQueueId
                    ]) {
                        qualificationQueueMemberIds.add(member.UserOrGroupId);
                    }
                }
            }

            return qualificationQueueMemberIds;
        }

        set;
    }

    /**
     * Validates and sends an error when specific StageName values are changed from one to another.
     *
     * @param newOpps, a List of Opportunity Records to check.
     * @param oldMap, a Map with the value of Trigger.oldMap.
     */
    public static void validateStageName(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        List<Opportunity> discoveryToAnticipatedSolicitationOpptys = new List<Opportunity>();
        List<Opportunity> discoveryToSolicitationOpptys = new List<Opportunity>();
        List<Opportunity> cultivationToSolicitationOpptys = new List<Opportunity>();
        List<Opportunity> cultivationOpptys = new List<Opportunity>();
        List<Opportunity> anticipatedSolicitationOpptys = new List<Opportunity>();
        List<Opportunity> solicitationOpptys = new List<Opportunity>();
        List<Opportunity> propInDevOpptys = new List<Opportunity>();
        List<Opportunity> propOutstandingOpptys = new List<Opportunity>();

        for (Opportunity opp : newOpps) {
            if (oldMap.get(opp.Id).StageName == DISCOVERY && opp.StageName == CULTIVATION
                && majorLifeEstateRTIds.contains(opp.RecordTypeId)
            ) {
                cultivationOpptys.add(opp);
            } else if (oldMap.get(opp.Id).StageName == DISCOVERY && opp.StageName == ANTICIPATED_SOLICITATION
                && majorLifeEstateRTIds.contains(opp.RecordTypeId)
            ) {
                discoveryToAnticipatedSolicitationOpptys.add(opp);
            } else if (oldMap.get(opp.Id).StageName == DISCOVERY && opp.StageName == SOLICITATION
                && majorLifeEstateRTIds.contains(opp.RecordTypeId)
            ) {
                discoveryToSolicitationOpptys.add(opp);
            } else if (oldMap.get(opp.Id).StageName == CULTIVATION && opp.StageName == SOLICITATION
                && majorLifeEstateRTIds.contains(opp.RecordTypeId)
            ) {
                cultivationToSolicitationOpptys.add(opp);
            } else if (oldMap.get(opp.Id).StageName == CULTIVATION && opp.StageName == ANTICIPATED_SOLICITATION
                && majorLifeEstateRTIds.contains(opp.RecordTypeId)
            ) {
                anticipatedSolicitationOpptys.add(opp);

               
// Check for IP Opps moving from Disc_Qual or HostedVisit to PropInDev  --- added JDH 9/16/2019                 
                
            } else if (oldMap.get(opp.Id).StageName != PROPOSAL_IN_DEVELOPMENT && opp.StageName == PROPOSAL_IN_DEVELOPMENT
            ) {
                propInDevOpptys.add(opp); 
                  System.debug('added your opportunity to the PropInDev list');
          
// Check for IP Opps moving to 'Proposal Outstanding'  -- added JDH 9/16/2019        
       
            } else if (oldMap.get(opp.Id).StageName != PROPOSAL_OUTSTANDING && opp.StageName == PROPOSAL_OUTSTANDING
            ) {
                propOutstandingOpptys.add(opp); 
                  System.debug('added your opportunity to the PropOutstanding list');
//end--jdh
                
                
                
                
            } else if (oldMap.get(opp.Id).StageName == ANTICIPATED_SOLICITATION && opp.StageName == SOLICITATION
                && majorLifeEstateRTIds.contains(opp.RecordTypeId)
            ) {
                solicitationOpptys.add(opp);
            } else if (oldMap.get(opp.Id).StageName != ACCEPTED && opp.StageName == ACCEPTED
                && lifeEstateRTIds.contains(opp.RecordTypeId)
                && (opp.Date_of_Verbal_Confirmation__c == null && opp.Date_of_Full_Documentation__c == null)
                && disableAcceptedStage
            ) {
                opp.addError(
                    'The opportunity must have documentation before it can be moved to the accepted stage. ' +
                    'Please provide a date of either Verbal or Fully Documented. If you do not have either one ' +
                    'of these, the Opportunity will only move into the Accepted stage when Gift Administration ' +
                    'books the commitment. If so, please select the appropriate stage other than Accepted in ' +
                    'order to save.'
                );
            } else if (oldMap.get(opp.Id).StageName != ACCEPTED && opp.StageName == ACCEPTED
                // (opp.RecordTypeId == oppRTInfosMap.get(MAJOR).getRecordTypeId())  Changed this line to the one below to include the GIFT(IP) record TYpe for Institutional Partnerships
                && (opp.RecordTypeId == oppRTInfosMap.get(MAJOR).getRecordTypeId() || opp.RecordTypeId == oppRTInfosMap.get(GIFT_IP).getRecordTypeId())
                && disableAcceptedStage
                && !FeatureManagement.checkPermission('Opportunity_Accept')
            ) {
                opp.addError(
                    'The opportunity is automatically moved into the Accepted stage when Gift Administration books ' +
                    'the commitment. Please select the appropriate stage other than Accepted in order to save.'
                );
            }
            /**
             * Prevents a user from setting the Opportunity StageName to "Disqualified". This ONLY happens through automation
             * when the related Case is approved, and we only want to show this error when updating an Opportunity outside of
             * that process and the User doing so is NOT in the Qualification Group Queue.
             */
            else if (oldMap.get(opp.Id).StageName != DISQUALIFIED && opp.StageName == DISQUALIFIED
                && !qualificationQueueMemberIds.contains(UserInfo.getUserId())
                && majorLifeEstateRTIds.contains(opp.RecordTypeId)
            ) { // Major Gift, Life Income, and Estate Opportunities Only
                opp.addError(
                    'In order to move into the disqualification stage, you must receive approval first. ' +
                    'Please select a reason for disqualification in the "Disqualification Reason" field and ' +
                    'then save the record. Do not move the opportunity to Disqualification stage on your own. ' +
                    'This happens automatically after and if you have received approval.'
                );
            }
        }

        if (!discoveryToAnticipatedSolicitationOpptys.isEmpty()) {
            validateDiscoveryToAnticipatedSolicitation(discoveryToAnticipatedSolicitationOpptys);
        }

        if (!discoveryToSolicitationOpptys.isEmpty()) {
            validateDiscoveryToSolicitation(discoveryToSolicitationOpptys);
        }

        if (!cultivationOpptys.isEmpty()) {
            validateCultivation(cultivationOpptys);
        }

        if (!cultivationToSolicitationOpptys.isEmpty()) {
            validateCultivationToSolicitation(cultivationToSolicitationOpptys);
        }

        if (!anticipatedSolicitationOpptys.isEmpty()) {
            validateAnticipatedSolicitation(anticipatedSolicitationOpptys);
        }
        
         if (!propInDevOpptys.isEmpty()) {
            validateProposalInDevelopment(propInDevOpptys);
        }
        

        if (!solicitationOpptys.isEmpty()) {
            validateSolicitation(solicitationOpptys);
        }
        
         if (!propOutstandingOpptys.isEmpty()) {
            validateProposalOutstanding(propOutstandingOpptys);
        }        
        
        
    }

    /**
     * Populates the Power of Attorney field on Opportunity if the field is blank and the Opportunity has
     * related OpportunityContactRole records.
     *
     * @param newOpps, the List of new Opportunities to check.
     */
    public static void populatePowerOfAttorney(List<Opportunity> newOpps) {
        Map<Id, List<OpportunityContactRole>> contactRoleMap = new Map<Id, List<OpportunityContactRole>>();

        for (OpportunityContactRole role : [
            SELECT Role, Contact.Name, OpportunityId
            FROM OpportunityContactRole
            WHERE OpportunityId IN :newOpps
        ]) {
            if (!contactRoleMap.containsKey(role.OpportunityId)) {
                contactRoleMap.put(role.OpportunityId, new List<OpportunityContactRole>{role});
            } else {
                contactRoleMap.get(role.OpportunityId).add(role);
            }
        }

        for (Opportunity opp : newOpps) {
            if (String.isBlank(opp.Power_of_Attorney__c) && contactRoleMap.containsKey(opp.Id)) {
                for (OpportunityContactRole role : contactRoleMap.get(opp.Id)) {
                    if (role.Role == 'Power of Attorney') {
                        opp.Power_of_Attorney__c = role.Contact.Name;
                        break;
                    }
                }
            }
        }
    }

    /**
     * Runs automation on Opportunities that move to the Accepted Stage, specific to Life Income and Estate
     * Opportunities for now.
     *
     * @param newOpps, the List of Trigger.new records to check.
     * @param oldMap, the Map of Trigger.oldMap records to compare against.
     */
    public static void acceptedStageAutomation(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        for (Opportunity opp : newOpps) {
            if (oldMap.get(opp.Id).StageName != ACCEPTED && opp.StageName == ACCEPTED) {
                // Life Income and Estate Opportunities Only.
                if (lifeEstateRTIds.contains(opp.RecordTypeId)) {
                    if (opp.Date_of_Full_Documentation__c != null) {
                        opp.CloseDate = opp.Date_of_Full_Documentation__c;
                    } else if (opp.Date_of_Verbal_Confirmation__c != null) {
                        opp.CloseDate = opp.Date_of_Verbal_Confirmation__c;
                    }
                }

                // Estate Opportunities Only
                if (opp.RecordTypeId == oppRTInfosMap.get(ESTATE).getRecordTypeId()
                    && opp.Settlement_Status__c == 'Full Distribution'
                ) {
                    opp.AQB__FundingComplete__c = true;
                }
            }
        }
    }

    /**
     * Filters through Opportunities for those that need Qualification Prospect Rating records created.
     *
     * @param newOpps, a List of new Opportunity records.
     * @param oldMap, the Trigger.oldMap of Opportunity records.
     */
    public static void createProspectRatings(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        List<Opportunity> oppsToCreateQualificationsFor = new List<Opportunity>();
        List<Opportunity> oppsToCreateCapacityFor = new List<Opportunity>();
        List<Opportunity> oppsToCreateCapacityForUpdateExisting = new List<Opportunity>();

        for (Opportunity opp : newOpps) {
            if (opp.StageName == CULTIVATION && oldMap.get(opp.Id).StageName == DISCOVERY) {
                oppsToCreateQualificationsFor.add(opp);
            } else if (opp.StageName == DISQUALIFIED && oldMap.get(opp.Id).StageName != DISQUALIFIED) {
                oppsToCreateQualificationsFor.add(opp);
                oppsToCreateCapacityForUpdateExisting.add(opp);
            }
        }

        if (!oppsToCreateQualificationsFor.isEmpty()) {
            generateAndInsertNewQualificationRatings(oppsToCreateQualificationsFor);
        }

        if (!oppsToCreateCapacityFor.isEmpty()) {
            generateAndInsertNewCapacityRatings(oppsToCreateCapacityFor, false);
        }

        if (!oppsToCreateCapacityForUpdateExisting.isEmpty()) {
            generateAndInsertNewCapacityRatings(oppsToCreateCapacityForUpdateExisting, true);
        }
    }

    /**
     * Creates related Qualification records for Opportunities if none exist.
     *
     * @param oppsToProcess, a List of Opportunity records to process.
     * @param updateExisting, tells the method whether or not to update Existing Records if found instead or creating new ones.
     */
    private static void generateAndInsertNewQualificationRatings(List<Opportunity> oppsToProcess) {
        List<Prospect_Rating__c> prospectRatingsToInsert = new List<Prospect_Rating__c>();
        Map<Id, List<Prospect_Rating__c>> existingProspectRatings = getExistingProspectRatingsMap(oppsToProcess, QUALIFICATION);
        Map<Id, Id> opportunityTeamLeadsMap = getOpportunityTeamLeadMap(oppsToProcess);

        for (Opportunity opp : oppsToProcess) {
            if (!String.isBlank(opp.AccountId)
                && !existingProspectRatings.containsKey(opp.AccountId)
                && opportunityTeamLeadsMap.containsKey(opp.Id)
            ) {
                prospectRatingsToInsert.add(new Prospect_Rating__c(
                    RecordTypeId = prosRatingRTInfosMap.get(QUALIFICATION).getRecordTypeId(),
                    Account__c = opp.AccountId,
                    Start_Date__c = Date.today(),
                    Qualification_Credit__c = opportunityTeamLeadsMap.get(opp.Id)
                ));
            }
        }

        if (!prospectRatingsToInsert.isEmpty()) {
            insert prospectRatingsToInsert;
        }
    }

    /**
     * Creates related Capacity records for Opportunities if none exist.
     *
     * @param oppsToProcess, a List of Opportunity records to process.
     */
    private static void generateAndInsertNewCapacityRatings(List<Opportunity> oppsToProcess, Boolean updateExisting) {
        List<Prospect_Rating__c> prospectRatingsToInsert = new List<Prospect_Rating__c>();
        List<Prospect_Rating__c> prospectRatingsToUpdate = new List<Prospect_Rating__c>();
        Map<Id, Id> opportunityTeamLeadsMap = getOpportunityTeamLeadMap(oppsToProcess);
        Map<Id, List<Prospect_Rating__c>> existingProspectRatings = getExistingProspectRatingsMap(oppsToProcess, CAPACITY);

        for (Opportunity opp : oppsToProcess) {
            if (!updateExisting
                && !String.isBlank(opp.AccountId)
                && !existingProspectRatings.containsKey(opp.AccountId)
                && opportunityTeamLeadsMap.containsKey(opp.Id)
            ) {
                prospectRatingsToInsert.add(new Prospect_Rating__c(
                    RecordTypeId = prosRatingRTInfosMap.get(CAPACITY).getRecordTypeId(),
                    Account__c = opp.AccountId,
                    End_Date__c = Date.today(),
                    Qualification_Credit__c = opportunityTeamLeadsMap.get(opp.Id)
                ));
            } else if (updateExisting
                && !String.isBlank(opp.AccountId)
                && existingProspectRatings.containsKey(opp.AccountId)
                && opportunityTeamLeadsMap.containsKey(opp.Id)
            ) {
                for (Prospect_Rating__c prospectRating : existingProspectRatings.get(opp.AccountId)) {
                    prospectRating.End_Date__c = Date.today();
                    prospectRating.Qualification_Credit__c = opportunityTeamLeadsMap.get(opp.Id);
                    prospectRatingsToUpdate.add(prospectRating);
                }
            }
        }

        if (!prospectRatingsToUpdate.isEmpty()) {
            update prospectRatingsToUpdate;
        }

        if (!prospectRatingsToInsert.isEmpty()) {
            insert prospectRatingsToInsert;
        }
    }

    /**
     * Gets a Map of Opportunity Team Leader Ids for each Opportunity passed in.
     *
     * @param opps, the List of Opportunity records to retrieve Leaders for.
     * @return opportunityTeamLeadMap
     */
    private static Map<Id, Id> getOpportunityTeamLeadMap(List<Opportunity> newOpps) {
        Map<Id, Id> opportunityTeamLeadMap = new Map<Id, Id>();

        // Michael Steptoe (Sleek) Edit 04/02/19: Order by End date and ensure Team Leader is active or most recent if none are active
        for (OpportunityTeamMember member : [
            SELECT UserId, OpportunityId, AQB__EndDate__c
            FROM OpportunityTeamMember
            WHERE OpportunityId IN :newOpps
            AND TeamMemberRole = 'Team Leader'
            ORDER BY AQB__EndDate__c DESC NULLS FIRST
        ]) {
            if(opportunityTeamLeadMap.get(member.OpportunityId) == null || member.AQB__EndDate__c == null){
                opportunityTeamLeadMap.put(member.OpportunityId, member.UserId);
            }
        }

        return opportunityTeamLeadMap;
    }

    /**
     * Gets a Map of Opportunity Team Member Ids, used for checking if a Member of the Team did something.
     *
     * @param newOpps, a List of Opportunity records to get Members for.
     * @return opportunityTeamMemberIdsMap, a Map of OpportunityId => Set of Member User Ids.
     */
    private static Map<Id, Set<Id>> getOpportunityTeamMemberIdsMap(List<Opportunity> newOpps) {
        Map<Id, Set<Id>> opportunityTeamMemberIdsMap = new Map<Id, Set<Id>>();

        for (OpportunityTeamMember member : [
            SELECT UserId, OpportunityId
            FROM OpportunityTeamMember
            WHERE OpportunityId IN :newOpps
            AND AQB__EndDate__c = NULL
        ]) {
            if (!opportunityTeamMemberIdsMap.containsKey(member.OpportunityId)) {
                opportunityTeamMemberIdsMap.put(member.OpportunityId, new Set<Id>{member.UserId});
            } else {
                opportunityTeamMemberIdsMap.get(member.OpportunityId).add(member.UserId);
            }
        }

        return opportunityTeamMemberIdsMap;
    }

    /**
     * Create a Qualification Case when a user sets the Disqualification Reason on the Opportunity and assigns it to
     * the Qualification Queue.
     *
     * @param newOpps, a List of Opportunity records to check.
     * @param oldMap, a Map with the value of Trigger.oldMap.
     */
    public static void createQualificationCase(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        List<Case> casesToInsert = new List<Case>();
        Map<Id, Id> opportunityTeamLeadsMap = getOpportunityTeamLeadMap(newOpps);

        for (Opportunity opp : newOpps) {
            if (opp.Disqualification__c != oldMap.get(opp.Id).Disqualification__c
                && !String.isEmpty(opp.Disqualification__c)
            ) {
                // Create qualification Case here.
                casesToInsert.add(new Case(
                    RecordTypeId = CaseService.caseRTInfosMap.get('Qualification').getRecordTypeId(),
                    OwnerId = qualificationQueueId,
                    AccountId = opp.AccountId,
                    Opportunity__c = opp.Id,
                    Subject = 'Disqualification Request',
                    Description = (String.isBlank(opp.Disqualification_Reason_Detail__c)) ? opp.Disqualification__c : opp.Disqualification__c + '\n\n' + opp.Disqualification_Reason_Detail__c,
                    Active_Opportunity_Team_Leader__c = (opportunityTeamLeadsMap.containsKey(opp.Id)) ? opportunityTeamLeadsMap.get(opp.Id) : null
                ));
            }
        }

        if (!casesToInsert.isEmpty()) {
            insert casesToInsert;
        }
    }
    
    /**
     * Create a Qualification Case when a user sets the Disqualification Reason when inserting an Opportunity and assigns it to
     * the Qualification Queue.
     *
     * @param newOpps, a List of Opportunity records to check.
     */
    public static void createQualificationCaseInsert(List<Opportunity> newOpps) {
        List<Case> casesToInsert = new List<Case>();
        Map<Id, Id> opportunityTeamLeadsMap = getOpportunityTeamLeadMap(newOpps);

        for (Opportunity opp : newOpps) {
            if (!String.isEmpty(opp.Disqualification__c))
             {
                // Create qualification Case here.
                casesToInsert.add(new Case(
                    RecordTypeId = CaseService.caseRTInfosMap.get('Qualification').getRecordTypeId(),
                    OwnerId = qualificationQueueId,
                    AccountId = opp.AccountId,
                    Opportunity__c = opp.Id,
                    Subject = 'Disqualification Request',
                    Description = (String.isBlank(opp.Disqualification_Reason_Detail__c)) ? opp.Disqualification__c : opp.Disqualification__c + '\n\n' + opp.Disqualification_Reason_Detail__c,
                    Active_Opportunity_Team_Leader__c = (opportunityTeamLeadsMap.containsKey(opp.Id)) ? opportunityTeamLeadsMap.get(opp.Id) : null
                ));
            }
        }

        if (!casesToInsert.isEmpty()) {
            insert casesToInsert;
        }
    }

    /**
     * Sets the End Date on related Account PMTeam Members to today when the Opportunity is set to Disqualified.
     *
     * @param newOpps, the List of newly updated Opportunities.
     * @param oldMap, a Map of Trigger.oldMap values to compare against.
     */
    public static void setRelatedPMTeamEndDates(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        List<AQB__PMTeam__c> membersToUpdate = new List<AQB__PMTeam__c>();

        for (Opportunity opp : newOpps) {
            if (opp.StageName == DISQUALIFIED && oldMap.get(opp.Id).StageName != DISQUALIFIED) {
                if (!String.isBlank(opp.AccountId)) {
                    accountIds.add(opp.AccountId);
                }
            }
        }

        for (AQB__PMTeam__c member : [
            SELECT Id
            FROM AQB__PMTeam__c
            WHERE AQB__Account__c IN :accountIds
            AND AQB__Active__c = TRUE
        ]) {
            member.AQB__EndDate__c = Date.today();
            membersToUpdate.add(member);
        }

        if (!membersToUpdate.isEmpty()) {
            update membersToUpdate;
        }
    }

    /**
     * Validates Opportunities moving from Discovery to Cultivation stage.
     *
     * @param newOpps, a List of new Opportunity records to check.
     */
    private static void validateCultivation(List<Opportunity> newOpps) {
        Map<Id, List<AQB__ActivityReport__c>> activityReportMap = new Map<Id, List<AQB__ActivityReport__c>>();

        for (AQB__ActivityReport__c report : [
            SELECT AQB__Date__c, CreatedById, AQB__Opportunity__c
            FROM AQB__ActivityReport__c
            WHERE AQB__ReportStatus__c = 'Final'
            AND AQB__Type__c IN ('Visit in', 'Visit out', 'Phone Cultivation', 'Mail Cultivation', 'Virtual Visit')
            AND AQB__Date__c = LAST_N_DAYS:60
            AND AQB__Opportunity__c IN :newOpps
        ]) {
            if (!activityReportMap.containsKey(report.AQB__Opportunity__c)) {
                activityReportMap.put(report.AQB__Opportunity__c, new List<AQB__ActivityReport__c>{report});
            } else {
                activityReportMap.get(report.AQB__Opportunity__c).add(report);
            }
        }

        for (Opportunity opp : newOpps) {
            if (!activityReportMap.containsKey(opp.Id) || (activityReportMap.containsKey(opp.Id) && activityReportMap.get(opp.Id).size() == 0)) {
                opp.addError(
                    'You must enter an Activity Report in this Discovery stage before moving on to Cultivation ' +
                    'Stage. Enter and save a final Activity report (type must be Visit in, Visit out or Phone ' +
                    'Cultivation, Date in the last 60 days, Report Status must be Final) on either the account ' +
                    'or the opportunity, then return to the Opportunity and save in the Cultivation stage.'
                );
            }
        }
    }

    /**
     * Validates a jump from Discovery Stage to Anticipated Solicitation Stage.
     *
     * @param newOpps, the List of Opportunities to check.
     */
    private static void validateDiscoveryToAnticipatedSolicitation(List<Opportunity> newOpps) {
        List<Prospect_Rating__c> prospectRatingsToInsert = new List<Prospect_Rating__c>();
        Map<Id, List<AQB__ActivityReport__c>> activityReportsMap = new Map<Id, List<AQB__ActivityReport__c>>();
        Map<Id, Id> opportunityTeamLeadsMap = getOpportunityTeamLeadMap(newOpps);
        Map<Id, List<AQB__OpportunityComponent__c>> askAmountsMap = getAskAmountsMap(newOpps);
        Map<Id, List<Prospect_Rating__c>> existingProspectRatingsMap = getExistingProspectRatingsMap(newOpps, QUALIFICATION);

        for (AQB__ActivityReport__c report : [
            SELECT AQB__Date__c, CreatedById, AQB__Opportunity__c
            FROM AQB__ActivityReport__c
            WHERE AQB__ReportStatus__c = 'Final'
            AND AQB__Type__c IN ('Visit in', 'Visit out', 'Phone Cultivation')
            AND AQB__Opportunity__c IN :newOpps
        ]) {
            if (!activityReportsMap.containsKey(report.AQB__Opportunity__c)) {
                activityReportsMap.put(report.AQB__Opportunity__c, new List<AQB__ActivityReport__c>{report});
            } else {
                activityReportsMap.get(report.AQB__Opportunity__c).add(report);
            }
        }

        for (Opportunity opp: newOpps) {
            Boolean isValid = true;

            if (opp.Amount == 0) isValid = false;
            if (opp.Anticipated_Amount__c <= 0) isValid = false;
            if (opp.Ask_Date__c <= Date.today()) isValid = false;
            if (opp.CloseDate >= Date.today().addYears(3) || opp.CloseDate < Date.today()) isValid = false;
            if (askAmountsMap.containsKey(opp.Id)) {
                for (AQB__OpportunityComponent__c component : askAmountsMap.get(opp.Id)) {
                    if (String.isBlank(component.School__c)) isValid = false;
                }
            } else {
                isValid = false;
            }

            Boolean foundReport = false;

            if (activityReportsMap.containsKey(opp.Id)) {
                for (AQB__ActivityReport__c report : activityReportsMap.get(opp.Id)) {
                    if (report.AQB__Date__c >= Date.today().addDays(-60) && report.AQB__Date__c <= Date.today()) {
                        foundReport = true;
                    }
                }
            }

            if (!foundReport) isValid = false;

            if (!isValid) {
                opp.addError(
                    'In order to save the opportunity in the Anticipated Solicitation stage you must have ' +
                    'an Activity Report submitted in the last 60 days on either the Account or Opportunity, ' +
                    'with a Report Status of Final, and Type must be Visit in, Visit out, or Phone Cultivation. ' +
                    'You must also have an Ask date (in the future), Amount, Anticipated Amount, Close date ' +
                    'within 3 years filled in and School selected on the Opportunity Component.'
                );
            } else {
                if (!existingProspectRatingsMap.containsKey(opp.AccountId) && opportunityTeamLeadsMap.containsKey(opp.Id)) {
                    prospectRatingsToInsert.add(new Prospect_Rating__c(
                        RecordTypeId = prosRatingRTInfosMap.get(QUALIFICATION).getRecordTypeId(),
                        Account__c = opp.AccountId,
                        Start_Date__c = Date.today(),
                        Qualification_Credit__c = opportunityTeamLeadsMap.get(opp.Id)
                    ));
                }
            }
        }

        if (!prospectRatingsToInsert.isEmpty()) {
            insert prospectRatingsToInsert;
        }
    }

    /**
     * Checks Opportunities and related Opportunity Component records for required fields before moving Stage to
     * Anticipated Solicitation. Adds an Error message to those that do not have the required fields populated.
     *
     * @param newOpps, a List of Opportunity records to check.
     */
    private static void validateAnticipatedSolicitation(List<Opportunity> newOpps) {
        Map<Id, List<AQB__OpportunityComponent__c>> askAmountsMap = getAskAmountsMap(newOpps);

        for (Opportunity opp : newOpps) {
            Boolean isValid = true;

            if (opp.Amount == 0) isValid = false;
            if (opp.Anticipated_Amount__c <= 0 || opp.Anticipated_Amount__c == null) isValid = false;
            if (opp.Ask_Date__c <= Date.today() || opp.Ask_Date__c == null) isValid = false;
            if (opp.CloseDate >= Date.today().addYears(3) || opp.CloseDate < Date.today()) isValid = false;

            if (askAmountsMap.containsKey(opp.Id)) {
                for (AQB__OpportunityComponent__c component : askAmountsMap.get(opp.Id)) {
                    if (String.isBlank(component.School__c)) isValid = false;
                }
            } else {
                isValid = false;
            }

            if (!isValid) {
                opp.addError(
                    'In order to advance to the Anticipated Solicitation stage, please fill in the Amount, ' +
                    'Anticipated Amount, Ask Date (greater than today), and the Close Date (within 3 years of today) ' +
                    'on the Opportunity. You must also enter data in School on the Opportunity Component.'
                );
            }
        }
    }

    
    
    
    
    
    
    
    /**
     * METHOD ADDED 9/16/2019  --  JDH
     * Checks Opportunities and related Opportunity Component records for required fields before moving Stage to
     * 'Proposal In Development'. Adds an Error message to those that do not have the required fields populated.
     *
     * @param newOpps, a List of Opportunity records to check.
     */
    private static void validateProposalInDevelopment(List<Opportunity> newOpps) {
        Map<Id, List<AQB__OpportunityComponent__c>> askAmountsMap = getAskAmountsMap(newOpps);

        for (Opportunity opp : newOpps) {
            Boolean isValid = true;
      
            if (opp.Amount == 0) isValid = false;
            if (opp.Anticipated_Amount__c <= 0 || opp.Anticipated_Amount__c == null) isValid = false;
            if (opp.Ask_Date__c <= Date.today() || opp.Ask_Date__c == null) isValid = false;
            if (opp.CloseDate >= Date.today().addYears(3) || opp.CloseDate < Date.today()) isValid = false;
            
            if (askAmountsMap.containsKey(opp.Id)) {
                for (AQB__OpportunityComponent__c component : askAmountsMap.get(opp.Id)) {
                    if (String.isBlank(component.School__c)) isValid = false;
                }
            } else {
                isValid = false;
            }
            
            if (!isValid) {
                opp.addError(
                    'In order to advance to the Proposal In Development stage, please fill in the Amount, ' +
                    'Anticipated Amount, Ask Date (greater than today), and the Close Date (within 3 years of today) ' +
                    'on the Opportunity. You must also enter data in School on the Opportunity Component.'
                );
            } 
        }
    }




    
    /**
     * Validates a skip from Discovery Stage to Solicitation.
     *
     * @param newOpps, a List of new Opportunity records to check.
     */
    private static void validateDiscoveryToSolicitation(List<Opportunity> newOpps) {
        List<Prospect_Rating__c> prospectRatingsToInsert = new List<Prospect_Rating__c>();
        Map<Id, List<AQB__ActivityReport__c>> activityReportsMap = new Map<Id, List<AQB__ActivityReport__c>>();
        Map<Id, Id> opportunityTeamLeadsMap = getOpportunityTeamLeadMap(newOpps);
        Map<Id, Set<Id>> opptyTeamIdsMap = getOpportunityTeamMemberIdsMap(newOpps);
        Map<Id, List<AQB__OpportunityComponent__c>> askAmountsMap = getAskAmountsMap(newOpps);
        Map<Id, List<Prospect_Rating__c>> existingProspectRatingsMap = getExistingProspectRatingsMap(newOpps, QUALIFICATION);
        Map<Id, Set<Id>> activityReportParticipantUserIdsMap = new Map<Id, Set<Id>>();

        for (AQB__ActivityReport__c report : [
            SELECT AQB__Date__c, CreatedById, AQB__Opportunity__c,
                (SELECT AQB__ActivityReport__c, AQB__User__c FROM AQB__Activity_Report_Participants__r)
            FROM AQB__ActivityReport__c
            WHERE AQB__ReportStatus__c = 'Final'
            AND AQB__Opportunity__c IN :newOpps
        ]) {
            for (AQB__ActivityReportParticipant__c participant : report.AQB__Activity_Report_Participants__r) {
                if (!activityReportParticipantUserIdsMap.containsKey(participant.AQB__ActivityReport__c)) {
                    activityReportParticipantUserIdsMap.put(participant.AQB__ActivityReport__c, new Set<Id>{participant.AQB__User__c});
                } else {
                    activityReportParticipantUserIdsMap.get(participant.AQB__ActivityReport__c).add(participant.AQB__User__c);
                }
            }

            if (!activityReportsMap.containsKey(report.AQB__Opportunity__c)) {
                activityReportsMap.put(report.AQB__Opportunity__c, new List<AQB__ActivityReport__c>{report});
            } else {
                activityReportsMap.get(report.AQB__Opportunity__c).add(report);
            }
        }

        for (Opportunity opp: newOpps) {
            Boolean isValid = true;

            if (opp.Anticipated_Amount__c  <= 0) isValid = false;
            if (opp.Ask_Date__c > Date.today()) isValid = false;
            if (opp.CloseDate > Date.today().addYears(1) || opp.CloseDate < Date.today()) isValid = false;

            if (askAmountsMap.containsKey(opp.Id)) {
                for (AQB__OpportunityComponent__c component : askAmountsMap.get(opp.Id)) {
                    if (String.isBlank(component.School__c) || String.isBlank(component.Account_Type__c) || String.isBlank(component.Account_Sub_Type__c)) {
                        isValid = false;
                    }
                }
            } else {
                isValid = false;
            }

            Boolean matchingUserFound = false;

            if (opptyTeamIdsMap.containsKey(opp.Id)) {
                Boolean foundReport = false;

                if (activityReportsMap.containsKey(opp.Id)) {
                    for (AQB__ActivityReport__c report : activityReportsMap.get(opp.Id)) {
                        if (report.AQB__Date__c >= Date.today().addDays(-60) && report.AQB__Date__c <= Date.today()) {
                            foundReport = true;

                            if (!matchingUserFound && activityReportParticipantUserIdsMap.containsKey(report.Id)) {
                                for (Id participantId : activityReportParticipantUserIdsMap.get(report.Id)) {
                                    if (opptyTeamIdsMap.get(opp.Id).contains(participantId)) {
                                        matchingUserFound = true;
                                    } else if (opportunityTeamLeadsMap.containsKey(opp.Id) && opportunityTeamLeadsMap.get(opp.Id) == participantId) {
                                        matchingUserFound = true;
                                    }
                                }
                            }
                        }
                    }
                }

                if (!foundReport) isValid = false;
            } else {
                isValid = false;
            }

            if (!matchingUserFound) {
                isValid = false;
            }

            if (!isValid) {
                opp.addError(
                    'In order to save the Opportunity in the Solicitation stage a member of the opportunity ' +
                    'team must have an Activity Report submitted (Report status of Final) in the last 60 days. ' +
                    'And they must fill in the Ask date (in the past), Amount, Anticipated Amount, and Close ' +
                    'Date (within 12 months) on the Opportunity, and the School, Account Type, and Account Subtype ' +
                    'fields on the Opportunity Component.'
                );
            } else {
                if (!existingProspectRatingsMap.containsKey(opp.AccountId) && opportunityTeamLeadsMap.containsKey(opp.Id)) {
                    prospectRatingsToInsert.add(new Prospect_Rating__c(
                        RecordTypeId = prosRatingRTInfosMap.get(QUALIFICATION).getRecordTypeId(),
                        Account__c = opp.AccountId,
                        Start_Date__c = Date.today(),
                        Qualification_Credit__c = opportunityTeamLeadsMap.get(opp.Id)
                    ));
                }
            }
        }

        if (!prospectRatingsToInsert.isEmpty()) {
            insert prospectRatingsToInsert;
        }
    }

    /**
     * Validates an Opportunity moving from Cultivation to Solicitation.
     *
     * @param newOpps, the List of Opportunity records to check.
     */
    private static void validateCultivationToSolicitation(List<Opportunity> newOpps) {
        Map<Id, Set<Id>> opptyTeamIdsMap = getOpportunityTeamMemberIdsMap(newOpps);
        Map<Id, List<AQB__OpportunityComponent__c>> askAmountsMap = getAskAmountsMap(newOpps);
        Map<Id, List<AQB__ActivityReport__c>> activityReportsMap = new Map<Id, List<AQB__ActivityReport__c>>();
        Map<Id, Id> opportunityTeamLeadsMap = getOpportunityTeamLeadMap(newOpps);
        Map<Id, Set<Id>> activityReportParticipantUserIdsMap = new Map<Id, Set<Id>>();

        for (AQB__ActivityReport__c report : [
            SELECT AQB__Date__c, CreatedById, AQB__Opportunity__c,
                (SELECT AQB__ActivityReport__c, AQB__User__c FROM AQB__Activity_Report_Participants__r)
            FROM AQB__ActivityReport__c
            WHERE AQB__ReportStatus__c = 'Final'
            AND AQB__Opportunity__c IN :newOpps
        ]) {
            for (AQB__ActivityReportParticipant__c participant : report.AQB__Activity_Report_Participants__r) {
                if (!activityReportParticipantUserIdsMap.containsKey(participant.AQB__ActivityReport__c)) {
                    activityReportParticipantUserIdsMap.put(participant.AQB__ActivityReport__c, new Set<Id>{participant.AQB__User__c});
                } else {
                    activityReportParticipantUserIdsMap.get(participant.AQB__ActivityReport__c).add(participant.AQB__User__c);
                }
            }

            if (!activityReportsMap.containsKey(report.AQB__Opportunity__c)) {
                activityReportsMap.put(report.AQB__Opportunity__c, new List<AQB__ActivityReport__c>{report});
            } else {
                activityReportsMap.get(report.AQB__Opportunity__c).add(report);
            }
        }

        for (Opportunity opp : newOpps) {
            Boolean isValid = true;

            if (opp.Ask_Date__c >= Date.today()) isValid = false;
            if (opp.Amount <= 0) isValid = false;
            if (opp.Anticipated_Amount__c <= 0) isValid = false;
            if (opp.CloseDate > Date.today().addYears(1) || opp.CloseDate < Date.today()) isValid = false;

            if (askAmountsMap.containsKey(opp.Id)) {
                for (AQB__OpportunityComponent__c component : askAmountsMap.get(opp.Id)) {
                    if (String.isBlank(component.School__c)
                        || String.isBlank(component.Account_Type__c)
                        || String.isBlank(component.Account_Sub_Type__c)
                    ) {
                        isValid = false;
                    }
                }
            } else {
                isValid = false;
            }

            Boolean matchingUserFound = false;

            if (opptyTeamIdsMap.containsKey(opp.Id)) {
                Boolean foundReport = false;

                if (activityReportsMap.containsKey(opp.Id)) {
                    for (AQB__ActivityReport__c report : activityReportsMap.get(opp.Id)) {
                        if (report.AQB__Date__c >= Date.today().addDays(-60) && report.AQB__Date__c <= Date.today()) {
                            foundReport = true;

                            if (!matchingUserFound && activityReportParticipantUserIdsMap.containsKey(report.Id)) {
                                for (Id participantId : activityReportParticipantUserIdsMap.get(report.Id)) {
                                    if (opptyTeamIdsMap.get(opp.Id).contains(participantId)) {
                                        matchingUserFound = true;
                                    } else if (opportunityTeamLeadsMap.containsKey(opp.Id) && opportunityTeamLeadsMap.get(opp.Id) == participantId) {
                                        matchingUserFound = true;
                                    }
                                }
                            }
                        }
                    }
                }

                if (!foundReport) isValid = false;
            } else {
                isValid = false;
            }

            if (!matchingUserFound) {
                isValid = false;
            }

            if (!isValid) {
                opp.addError(
                    'In order to save the Opportunity in the Solicitation stage a member of the opportunity ' +
                    'team must have an Activity Report submitted (Report status of Final) in the last 60 days. ' +
                    'And they must fill in the Ask date (in the past), Amount, Anticipated Amount, and Close ' +
                    'Date (within 12 months) on the Opportunity, and the School, Account Type, and Account Subtype ' +
                    'fields on the Opportunity Component.'
                );
            }
        }
    }
    
    
    
    

    /**
     * Validates required fields are filled out on the Opportunity when moving to the Solicitation Stage.
     *
     * @param newOpps, a List of Opportunity records to check.
     */
    private static void validateSolicitation(List<Opportunity> newOpps) {
        Map<Id, Id> opportunityTeamLeadsMap = getOpportunityTeamLeadMap(newOpps);
        Map<Id, Set<Id>> opportunityTeamMemberIdsMap = getOpportunityTeamMemberIdsMap(newOpps);
        Map<Id, List<AQB__OpportunityComponent__c>> askAmountsMap = getAskAmountsMap(newOpps);
        Map<Id, List<AQB__ActivityReport__c>> activityReportsMap = new Map<Id, List<AQB__ActivityReport__c>>();
        Map<Id, Set<Id>> activityReportParticipantUserIdsMap = new Map<Id, Set<Id>>();

        for (AQB__ActivityReport__c report : [
            SELECT AQB__Date__c, CreatedById, AQB__Opportunity__c,
                (SELECT AQB__ActivityReport__c, AQB__User__c FROM AQB__Activity_Report_Participants__r)
            FROM AQB__ActivityReport__c
            WHERE AQB__ReportStatus__c = 'Final'
            AND AQB__Opportunity__c IN :newOpps
        ]) {
            for (AQB__ActivityReportParticipant__c participant : report.AQB__Activity_Report_Participants__r) {
                if (!activityReportParticipantUserIdsMap.containsKey(participant.AQB__ActivityReport__c)) {
                    activityReportParticipantUserIdsMap.put(participant.AQB__ActivityReport__c, new Set<Id>{participant.AQB__User__c});
                } else {
                    activityReportParticipantUserIdsMap.get(participant.AQB__ActivityReport__c).add(participant.AQB__User__c);
                }
            }

            if (!activityReportsMap.containsKey(report.AQB__Opportunity__c)) {
                activityReportsMap.put(report.AQB__Opportunity__c, new List<AQB__ActivityReport__c>{report});
            } else {
                activityReportsMap.get(report.AQB__Opportunity__c).add(report);
            }
        }

        for (Opportunity opp : newOpps) {
            Boolean isValid = true;

            if (opp.Ask_Date__c > Date.today()) isValid = false;
            if (opp.CloseDate >= Date.today().addYears(1) || opp.CloseDate <= Date.today()) isValid = false;

            if (askAmountsMap.containsKey(opp.Id)) {
                for (AQB__OpportunityComponent__c component : askAmountsMap.get(opp.Id)) {
                    if (String.isBlank(component.Account_Type__c) || String.isBlank(component.Account_Sub_Type__c)) {
                        isValid = false;
                    }
                }
            } else {
                isValid = false;
            }

            Boolean matchingUserFound = false;

            if (opportunityTeamMemberIdsMap.containsKey(opp.Id)) {
                Boolean foundReport = false;

                if (activityReportsMap.containsKey(opp.Id)) {
                    for (AQB__ActivityReport__c report : activityReportsMap.get(opp.Id)) {
                        if (report.AQB__Date__c >= Date.today().addDays(-60) && report.AQB__Date__c <= Date.today()) {
                            foundReport = true;

                            if (!matchingUserFound && activityReportParticipantUserIdsMap.containsKey(report.Id)) {
                                for (Id participantId : activityReportParticipantUserIdsMap.get(report.Id)) {
                                    if (opportunityTeamMemberIdsMap.get(opp.Id).contains(participantId)) {
                                        matchingUserFound = true;
                                    } else if (opportunityTeamLeadsMap.containsKey(opp.Id) && opportunityTeamLeadsMap.get(opp.Id) == participantId) {
                                        matchingUserFound = true;
                                    }
                                }
                            }
                        }
                    }
                }

                if (!foundReport) isValid = false;
            } else {
                isValid = false;
            }

            if (!matchingUserFound) {
                isValid = false;
            }

            if (!isValid) {
                opp.addError(
                    'In order to save the Opportunity in the Solicitation stage a member of the opportunity ' +
                    'team must have an Activity Report submitted (Report status of Final) in the last 60 days. ' +
                    'And they must also have filled in the Ask date (in the past) and Close Date (within 12 months) ' +
                    'on the Opportunity, and the Account Type and Account Subtype fields on the Opportunity Component.'
                );
            }
        }
    }

   
    
    
    
    
    /**
     * NEW METHOD ADDED 9/16/2019 --- JDH
     * Validates required fields are filled out on the Opportunity when moving to the Proposal Outstanding Stage.
     *
     * @param newOpps, a List of Opportunity records to check.
     */
    private static void validateProposalOutstanding(List<Opportunity> newOpps) {
        Map<Id, Id> opportunityTeamLeadsMap = getOpportunityTeamLeadMap(newOpps);
        Map<Id, Set<Id>> opportunityTeamMemberIdsMap = getOpportunityTeamMemberIdsMap(newOpps);
        Map<Id, List<AQB__OpportunityComponent__c>> askAmountsMap = getAskAmountsMap(newOpps);


        for (Opportunity opp : newOpps) {
            Boolean isValid = true;

            if (opp.Ask_Date__c > Date.today()) isValid = false;
            
            if (opp.CloseDate >= Date.today().addYears(1) || opp.CloseDate <= Date.today()) isValid = false;

            if (askAmountsMap.containsKey(opp.Id)) {
                for (AQB__OpportunityComponent__c component : askAmountsMap.get(opp.Id)) {
                    if (String.isBlank(component.Account_Type__c) || String.isBlank(component.Account_Sub_Type__c) || String.isBlank(component.Department__c) ) {
                        isValid = false;
                    }
                }
            } else {
                isValid = false;
            }

            if (!isValid) {
                opp.addError(
                    'In order to save the Opportunity in the Proposal Outstanding stage  ' +
                    'you must have an Ask date (in the past) and Close Date (within 12 months) ' +
                    'on the Opportunity, and the Department, Account Type, and Account Subtype fields on the Opportunity Component.'
                );
            }
        }
    }    
    
  
    
    
    
    
    
    
    /**
     * Populates Spouse Information on the Opportunity based upon the Account's Primary Contact's Related Spouse info.
     *
     * @param newOpps, a Trigger.new List of Opportunity records to use.
     */
    public static void populateSpouseInfo(List<Opportunity> newOpps) {
        Map<Id, Opportunity> accountToOppMap = new Map<Id, Opportunity>();
        Map<Id, Opportunity> primaryContactToOppMap = new Map<Id, Opportunity>();

        for (Opportunity opp : newOpps) {
            if (!String.isBlank(opp.AccountId)
                && lifeEstateRTIds.contains(opp.RecordTypeId)
            ) {
                accountToOppMap.put(opp.AccountId, opp);
            }
        }

        if (!accountToOppMap.isEmpty()) {
            for (Account acc : [
                SELECT AQB__PrimaryContact__c
                FROM Account
                WHERE Id IN :accountToOppMap.keySet()
            ]) {
                if (accountToOppMap.containsKey(acc.Id)) {
                    primaryContactToOppMap.put(acc.AQB__PrimaryContact__c, accountToOppMap.get(acc.Id));
                }
            }

            for (Contact c : [
                SELECT
                    (
                        SELECT AQB__RelatedName__c, AQB__Relationship__c, AQB__Contact__r.AQB__Age__c,
                            AQB__Contact__r.AQB__Deceased__c, AQB__Contact__r.AQB__DateofDeath__c
                        FROM AQB__RelContact_Relationships__r
                        WHERE AQB__Relationship__c = 'Spouse/Domestic Partner'
                        AND AQB__EndDate__c = NULL
                    )
                FROM Contact
                WHERE Id IN :primaryContactToOppMap.keySet()
            ]) {
                for (AQB__RelationshipContact__c relationship : c.AQB__RelContact_Relationships__r) {
                    if (primaryContactToOppMap.containsKey(c.Id)) {
                        Opportunity opp = primaryContactToOppMap.get(c.Id);

                        if (opp.Spouse_Age__c == null && relationship.AQB__Contact__r.AQB__Age__c != null) {
                            opp.Spouse_Age__c = relationship.AQB__Contact__r.AQB__Age__c;
                        }

                        if (opp.Spouse_Deceased__c != relationship.AQB__Contact__r.AQB__Deceased__c) {
                            opp.Spouse_Deceased__c = relationship.AQB__Contact__r.AQB__Deceased__c;
                        }

                        if (opp.Spouse_Deceased_Date__c == null && relationship.AQB__Contact__r.AQB__DateofDeath__c != null) {
                            opp.Spouse_Deceased_Date__c = relationship.AQB__Contact__r.AQB__DateofDeath__c;
                        }
                    }
                }
            }
        }
    }

    /**
     * Sets the OwnerId of the Opportunity to the Opportunity Team Leader if not already.
     *
     * @param newOpps, a List of Trigger.new Opportunity records to check.
     */
    public static void setOwnerToTeamLead(List<Opportunity> newOpps) {
        Map<Id, Id> opportunityTeamLeadsMap = getOpportunityTeamLeadMap(newOpps);

        for (Opportunity opp : newOpps) {
            if (opportunityTeamLeadsMap.containsKey(opp.Id)
                && opp.OwnerId != opportunityTeamLeadsMap.get(opp.Id)
            ) {
                opp.OwnerId = opportunityTeamLeadsMap.get(opp.Id);
            }
        }
    }

    /**
     * Retrieves a Map of Opportunity Component records for the given Opportunities.
     *
     * @param newOpps, a List of Opportunity records to use to grab related records.
     * @return a Map of records found, Opportunity Id => List of Opportunity Components found.
     */
    private static Map<Id, List<AQB__OpportunityComponent__c>> getAskAmountsMap(List<Opportunity> newOpps) {
        Map<Id, List<AQB__OpportunityComponent__c>> askAmountsMap = new Map<Id, List<AQB__OpportunityComponent__c>>();

        for (AQB__OpportunityComponent__c component : [
            SELECT AQB__Opportunity__c, Account_Type__c, Account_Sub_Type__c, School__c, Department__c
            FROM AQB__OpportunityComponent__c
            WHERE AQB__Opportunity__c IN :newOpps
        ]) {
            if (!askAmountsMap.containsKey(component.AQB__Opportunity__c)) {
                askAmountsMap.put(component.AQB__Opportunity__c, new List<AQB__OpportunityComponent__c>{component});
            } else {
                askAmountsMap.get(component.AQB__Opportunity__c).add(component);
            }
        }

        return askAmountsMap;
    }

    /**
     * Retrieves existing Prospect Rating records for the given Opportunity and Record Type.
     *
     * @param newOpps, the List of Opportunities to grab related records for.
     * @param recordType, the Record Type name to filter Prospect Rating records.
     * @return a Map of records, Opportunity Id => List of Prospect Ratings found.
     */
    private static Map<Id, List<Prospect_Rating__c>> getExistingProspectRatingsMap(List<Opportunity> newOpps, String recordType) {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, List<Prospect_Rating__c>> existingProspectRatingsMap = new Map<Id, List<Prospect_Rating__c>>();

        for (Opportunity opp : newOpps) {
            if (!String.isBlank(opp.AccountId)) {
                accountIds.add(opp.AccountId);
            }
        }

        for (Prospect_Rating__c rating : [
            SELECT Id, Account__c
            FROM Prospect_Rating__c
            WHERE Account__c IN :accountIds
            AND RecordTypeId = :prosRatingRTInfosMap.get(recordType).getRecordTypeId()
            AND Active__c = TRUE
        ]) {
            if (!existingProspectRatingsMap.containsKey(rating.Account__c)) {
                existingProspectRatingsMap.put(rating.Account__c, new List<Prospect_Rating__c>{rating});
            } else {
                existingProspectRatingsMap.get(rating.Account__c).add(rating);
            }
        }

        return existingProspectRatingsMap;
    }
}