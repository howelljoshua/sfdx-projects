/**
* @author Mathew Ruff, Sierra-Cedar
* @date 10/30/18
*
* Trigger Handler logic for AQB__Gift__c
*/
public class GiftTriggerHandler implements ITriggerHandler {
    // You can set this static boolean from apex in this namespace if you want to bypass this trigger
    public static Boolean disable = false;

    public Boolean isDisabled() {
        Boolean isDisabled = false;
        if (disable) isDisabled = true;

        return isDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {
        List<AQB__Gift__c> newSObjects = (List<AQB__Gift__c>) newItems;
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, AQB__Gift__c> newMap = (Map<Id, AQB__Gift__c>) newItems;
        Map<Id, AQB__Gift__c> oldMap = (Map<Id, AQB__Gift__c>) oldItems;
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
        Map<Id, AQB__Gift__c> oldMap = (Map<Id, AQB__Gift__c>) oldItems;
    }

    public void afterInsert(Map<Id, SObject> newItems) {
        Map<Id, AQB__Gift__c> newMap = (Map<Id, AQB__Gift__c>) newItems;

        GiftService.setOpportunitiesToAccepted(newMap.values(), null);
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, AQB__Gift__c> newMap = (Map<Id, AQB__Gift__c>) newItems;
        Map<Id, AQB__Gift__c> oldMap = (Map<Id, AQB__Gift__c>) oldItems;

        GiftService.setOpportunitiesFundingComplete(newMap.values(), oldMap);
        GiftService.setOpportunitiesToAccepted(newMap.values(), oldMap);
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
        Map<Id, AQB__Gift__c> oldMap = (Map<Id, AQB__Gift__c>) oldItems;
    }

    public void afterUndelete(Map<Id, SObject> oldItems) {
        Map<Id, AQB__Gift__c> oldMap = (Map<Id, AQB__Gift__c>) oldItems;
    }
}