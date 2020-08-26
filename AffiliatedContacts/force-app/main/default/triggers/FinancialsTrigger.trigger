trigger FinancialsTrigger on AQB__Financials__c (before insert, before update, after insert, after update, before delete, after delete) {

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
            FinancialsTriggerHandler.findMostRecentFinancials(Trigger.new);
        }             
        if (Trigger.isUpdate) { 
            FinancialsTriggerHandler.findMostRecentFinancials(Trigger.new);    
        }
        if (Trigger.isDelete) {   
            FinancialsTriggerHandler.findMostRecentFinancials(Trigger.old);         
        }
    }
}