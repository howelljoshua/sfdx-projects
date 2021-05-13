trigger CMU_TransactionTrigger on AQB__Transaction__c (before insert,after insert,before update,after update,before delete,after delete) {

    if (Trigger.isBefore) {      
        if (Trigger.isInsert) {        
        }       
        if (Trigger.isUpdate) {   
        }            
        if (Trigger.isDelete) {
        }
    }

    if (Trigger.IsAfter) {          
        if (Trigger.isInsert) { 
            CMU_TransactionTriggerHandler tth = new CMU_TransactionTriggerHandler();
            tth.calculatePGSummaries(Trigger.new);
        }          
        if (Trigger.isUpdate) {
            CMU_TransactionTriggerHandler tth = new CMU_TransactionTriggerHandler();
            tth.calculatePGSummaries(Trigger.new);
        }
        if (Trigger.isDelete) {
            CMU_TransactionTriggerHandler tth = new CMU_TransactionTriggerHandler();
            tth.calculatePGSummaries(Trigger.old);
        }
    }
}