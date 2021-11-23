trigger IntegrationMessageTrigger on Integration_Message__c (before Insert,After Insert,After Update) {
    
    IntegrationMessageTriggerHandler Handler = new IntegrationMessageTriggerHandler();
    
    if(Trigger.isInsert && Trigger.isAfter){
        system.debug('In INSERT----');
        Handler.OnAfterInsert(Trigger.new);  
    }else if(Trigger.isUpdate && Trigger.isAfter){
        system.debug('InBefore Isert-----');
        Handler.OnAfterInsert(Trigger.new);  
    }

}