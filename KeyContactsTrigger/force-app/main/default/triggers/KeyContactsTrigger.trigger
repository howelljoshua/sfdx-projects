trigger KeyContactsTrigger on AQB__KeyContact__c (before insert, after insert, before update, after update, before delete, after delete){

    if(Trigger.isBefore){
        if(Trigger.isInsert){
        }
        if(Trigger.isUpdate){
        }
        if(Trigger.isDelete){
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            KeyContactsTriggerHandler.populateManagers(Trigger.new);
        }
        if(Trigger.isUpdate){
            KeyContactsTriggerHandler.populateManagers(Trigger.new);
        }
        if(Trigger.isDelete){
            KeyContactsTriggerHandler.populateManagers(Trigger.old);
        }
    }
}