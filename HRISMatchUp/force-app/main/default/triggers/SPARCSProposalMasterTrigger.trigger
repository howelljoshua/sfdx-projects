trigger SPARCSProposalMasterTrigger on SPARCS_Proposal__c (before insert,after insert,before update,after update,before delete,after delete) {

    if (Trigger.isBefore) {        
        if (Trigger.isInsert) {  
            HRISMatchUp.matchUp(Trigger.new);
        }
        if (Trigger.isUpdate) {  
            HRISMatchUp.matchUp(Trigger.new);     
        }
        if (Trigger.isDelete) {
        }
    }
    if (Trigger.IsAfter) {
        if (Trigger.isInsert) {
        } 
        if (Trigger.isUpdate) {
        }
        if (Trigger.isDelete) {
        }
    }
}