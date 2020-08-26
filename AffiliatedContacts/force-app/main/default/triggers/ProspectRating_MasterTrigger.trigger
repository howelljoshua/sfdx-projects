/*
 * Prospect Rating Trigger 
 * Authors: Josh Howell (CMU) and Michael Steptoe (Affinaquest)
 * Completed 1/21/2019 (JH)
 * Update 1/23/2019 (MS)
 * 
 * Classes involved:
 * **1. ProspectRating_PopulateAccount (Author:JH)
 * ****Called before insert and before update (operates only if Trigger.new has a single record with a value in 'Capacity Rating' field)
 * ****Promotes the Capacity rating on the Capacity Prospect Rating record being inserted/updated up to the Account mirror field 
 * ****Queries and Expires all other 'active' Capacity Prospect Ratings on the Account
 * 
 * 
 * **2. ProspectRating_CMU1000 (Author:MS)
 * ****Called after insert and after update
 * 
 *Test Classes needed to promote to Production:
 * ProspectRating_MasterTrigger_Test (JH) -- covers at 100%
 * ProspectRating_CMU1000 (MS) -- covers at 100%
 * 
 */


trigger ProspectRating_MasterTrigger on Prospect_Rating__c (before insert,after insert,before update,after update,before delete,after delete) {

  if (Trigger.isBefore) {
      
    if (Trigger.isInsert) {        
        if (CheckRecursive.runOnce()) {
            ProspectRating_PopulateAccount.updateAccountCapacity();  
        }
    }
      
    if (Trigger.isUpdate) {
        if (CheckRecursive.runOnce()) {
            ProspectRating_PopulateAccount.updateAccountCapacity(); 
        }
    }
      
    if (Trigger.isDelete) {
    }
  }

    
    
  if (Trigger.IsAfter) {
      
    if (Trigger.isInsert) {
      
      ProspectRating_CMU1000.afterInsertCMU1000(Trigger.newMap); // STEPTOE EDIT 01/23/19
    } 
      
    if (Trigger.isUpdate) {
      ProspectRating_CMU1000.afterUpdateCMU1000(Trigger.oldMap, Trigger.newMap); // STEPTOE EDIT 01/23/19
    }
      
    if (Trigger.isDelete) {
		
		GoalTracker_QualificationsUtility.doWhat(Trigger.oldMap.values());        
    }
  }
}