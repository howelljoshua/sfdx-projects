/**
* Created by Anand on 3/7/2019.
*/

trigger CMU_UserTrigger on User (before insert, before update, after insert, after update, after delete) {
    if(trigger.isAfter){
        if(trigger.isInsert) {
            CMU_UserTriggerHandler.addUserToTepperGroup(trigger.new);
            //CMU_UserTriggerHandler.sendVerificationEmail(Trigger.new);
            List<String> uIds = new List<String>();
            for(User u : Trigger.new){
                uIds.add(u.Id);
            }
            CMU_UserTriggerHandler.updateContactUser(uIds);
        }
        if(trigger.isUpdate){
            CMU_UserTriggerHandler.trackUserFieldUpdates(trigger.oldMap,trigger.newMap);
            CMU_UserTriggerHandler.updateSendVerificationEmail(trigger.oldMap, trigger.newMap);
        }
    }
    if(trigger.isBefore){
        if(trigger.isUpdate){
            
        }
    }
}