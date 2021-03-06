/**
* @author Mathew Ruff, Sierra-Cedar
* @date 10/17/18
*
* Handles Trigger Logic for Opportunity Records.
*/
public class OpportunityTriggerHandler implements ITriggerHandler {
    // You can set this static boolean from apex in this namespace if you want to bypass this trigger
    public static Boolean disable = false;

    public Boolean isDisabled() {
        Boolean isDisabled = false;
        if (disable) isDisabled = true;

        return isDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {
        List<Opportunity> newSObjects = (List<Opportunity>) newItems;

        OpportunityService.setOwnerToTeamLead(newSObjects);
        OpportunityService.populateSpouseInfo(newSObjects);
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Opportunity> newMap = (Map<Id, Opportunity>) newItems;
        Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) oldItems;

        OpportunityService.validateStageName(newMap.values(), oldMap);
        OpportunityService.setOwnerToTeamLead(newMap.values());
        OpportunityService.populateSpouseInfo(newMap.values());
        OpportunityService.populatePowerOfAttorney(newMap.values());
        OpportunityService.acceptedStageAutomation(newMap.values(), oldMap);
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
        Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) oldItems;
    }

    public void afterInsert(Map<Id, SObject> newItems) {
        Map<Id, Opportunity> newMap = (Map<Id, Opportunity>) newItems;
        OpportunityService.createQualificationCaseInsert(newMap.values());
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Opportunity> newMap = (Map<Id, Opportunity>) newItems;
        Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) oldItems;
        
        OpportunityService.createProspectRatings(newMap.values(), oldMap);
        OpportunityService.createQualificationCase(newMap.values(), oldMap);
        OpportunityService.setRelatedPMTeamEndDates(newMap.values(), oldMap);
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
        Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) oldItems;
        
        GoalTracker_OpportunitiesUtility.doWhat(oldMap.values());
    }

    public void afterUndelete(Map<Id, SObject> oldItems) {
        Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) oldItems;
    }
}