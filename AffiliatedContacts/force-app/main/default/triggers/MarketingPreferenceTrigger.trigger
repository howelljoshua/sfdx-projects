trigger MarketingPreferenceTrigger on Marketing_Preference__c (after insert) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
          MarketingPreferenceTriggerHandler.onAfterInsert(Trigger.new);
        }
    }
}