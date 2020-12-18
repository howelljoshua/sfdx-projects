/**
* @author Mathew Ruff, Sierra-Cedar
* @date 10/17/18
*
* Trigger Handler Logic for AQB_PMTeam__c
*/
public class PMTeamTriggerHandler implements ITriggerHandler {
// You can set this static boolean from apex in this namespace if you want to bypass this trigger
    public static Boolean disable = false;

    public Boolean isDisabled() {
        Boolean isDisabled = false;
        if (disable) isDisabled = true;

        return isDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {
        List<AQB__PMTeam__c> newSObjects = (List<AQB__PMTeam__c>) newItems;

        PMTeamService.validateTeamMembers(newSObjects);
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, AQB__PMTeam__c> newMap = (Map<Id, AQB__PMTeam__c>) newItems;
        Map<Id, AQB__PMTeam__c> oldMap = (Map<Id, AQB__PMTeam__c>) oldItems;

        PMTeamService.validateTeamMembers(newMap.values());
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
        Map<Id, AQB__PMTeam__c> oldMap = (Map<Id, AQB__PMTeam__c>) oldItems;
    }

    public void afterInsert(Map<Id, SObject> newItems) {
        Map<Id, AQB__PMTeam__c> newMap = (Map<Id, AQB__PMTeam__c>) newItems;

        PMTeamService.setAccountOwner(newMap.values(), null);
        PMTeamService.createMajorGiftOpportunities(newMap.values());
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, AQB__PMTeam__c> newMap = (Map<Id, AQB__PMTeam__c>) newItems;
        Map<Id, AQB__PMTeam__c> oldMap = (Map<Id, AQB__PMTeam__c>) oldItems;

        PMTeamService.setAccountOwner(newMap.values(), oldMap);
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
        Map<Id, AQB__PMTeam__c> oldMap = (Map<Id, AQB__PMTeam__c>) oldItems;
    }

    public void afterUndelete(Map<Id, SObject> oldItems) {
        Map<Id, AQB__PMTeam__c> oldMap = (Map<Id, AQB__PMTeam__c>) oldItems;
    }
}