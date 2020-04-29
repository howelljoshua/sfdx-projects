trigger AwardRecipientTrigger on AQB__AwardRecipients__c (before insert,after insert,before update,after update,before delete,after delete) {

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
            AwardRecipientHandler.updateAwardParent(Trigger.new);
        } 
        
        
        if (Trigger.isUpdate) {   
            AwardRecipientHandler.updateAwardParent(Trigger.new);  
        }
        
        
        if (Trigger.isDelete) {
            AwardRecipientHandler.updateAwardParent(Trigger.new);  
    
        }
    }
}