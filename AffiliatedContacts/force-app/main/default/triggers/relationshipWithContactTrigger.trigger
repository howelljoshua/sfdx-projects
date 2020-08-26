/**================================================================      
 * Appirio, Inc
 * @description : T-741024 Trigger for AQB__RelationshipContact__c
 * @date: 11 Oct 2018 
 * @author: Divyanshi Sharma (Appirio)
 *
 * Date Modified      Modified By               Description of the update
*==================================================================*/
trigger relationshipWithContactTrigger on AQB__RelationshipContact__c (before insert, before update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            relationshipWithContactTriggerHandler.onBeforeInsert(trigger.new);
        }else if (trigger.isUpdate){
            relationshipWithContactTriggerHandler.onBeforeUpdate(trigger.new,trigger.oldMap);
        }
    }
}