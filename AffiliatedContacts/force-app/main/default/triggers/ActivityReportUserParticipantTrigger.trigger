trigger ActivityReportUserParticipantTrigger on AQB__ActivityReportParticipant__c (before insert,after insert,before update,after update,before delete,after delete) {
   
    
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
    } 
      
      
    if (Trigger.isUpdate) {     
    }
      
      
    if (Trigger.isDelete) {
        GoalTracker_VisitsUtility.doWhat(Trigger.OldMap.values()) ;
          System.debug('Calling the Delete method with the delete record');

    }
  }
}