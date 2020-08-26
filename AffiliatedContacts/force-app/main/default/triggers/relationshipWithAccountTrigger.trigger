/**================================================================      
 * Appirio, Inc
 * @description : T-741024 Trigger for AQB__RelationshipAccount__c
 * @date: 11 Oct 2018 
 * @author: Divyanshi Sharma (Appirio)
 *
 * Date Modified      Modified By               Description of the update
*==================================================================*/
trigger relationshipWithAccountTrigger on AQB__RelationshipAccount__c (before insert, before update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            relationshipWithAccountTriggerHandler.onBeforeInsert(trigger.new);
        }else if (trigger.isUpdate){
            relationshipWithAccountTriggerHandler.onBeforeUpdate(trigger.new,trigger.oldMap);
        }
    }
}