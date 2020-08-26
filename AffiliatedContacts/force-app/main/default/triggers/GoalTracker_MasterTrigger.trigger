trigger GoalTracker_MasterTrigger on Goal_Tracker__c (before insert,after insert,before update,after update,before delete,after delete) {
    
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
        if (CheckRecursive.runOnce()) {
            GoalTracker_Utility.doWhat(Trigger.New);
        }
    } 
      
      
    if (Trigger.isUpdate) {
        if (CheckRecursive.runOnce()) {
            GoalTracker_Utility.doWhat(Trigger.New);
        }
    }
      
      
    if (Trigger.isDelete) {
    }
  }
}