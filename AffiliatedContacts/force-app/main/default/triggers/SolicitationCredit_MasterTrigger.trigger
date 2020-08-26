trigger SolicitationCredit_MasterTrigger on AQB__Solicitation_Credit__c (before insert,after insert,before update,after update,before delete,after delete, after undelete) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert){
            GoalTracker_SolicitationCreditsUtility.syncUserContact(Trigger.new); 
        }        
        if (Trigger.isUpdate){
            GoalTracker_SolicitationCreditsUtility.syncUserContact(Trigger.new);
        } 
        if (Trigger.isDelete){
        }
    }
    if (Trigger.IsAfter) {   
        if (Trigger.isInsert) {
        }   
        if (Trigger.isUpdate) {
        }
        if (Trigger.isDelete) {
            GoalTracker_SolicitationCreditsUtility.doWhat(Trigger.old); 
        } 
        if (Trigger.isUndelete) {    
        } 
    }
}