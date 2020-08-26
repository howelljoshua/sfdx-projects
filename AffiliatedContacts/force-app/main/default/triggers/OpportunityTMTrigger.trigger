/* ********************************************************
 * (c) 2018 Appirio - A Wipro Company, Inc
 * Name: OpportunityTMTrigger.trigger
 * Description: Custom trigger for OpportunityTeamMember object
 * Created Date: Oct 5, 2018
 * Created By: Deepanshu Soni
 * Date Modified      Modified By       Description of the update
 * 
******************************************************** */

trigger OpportunityTMTrigger on OpportunityTeamMember(after delete, after insert, after update, before delete, before insert, before update) {
    
    OpptyTMHandler opttyHandler = new OpptyTMHandler();
    List<OpportunityTeamMember> opptyTMs = new List<OpportunityTeamMember>();
    
    if (Trigger.isAfter) {
        
        if (Trigger.isInsert) {
            opttyHandler.followRecord(Trigger.New);    
        }
        if (Trigger.isUpdate) {
            opttyHandler.followRecord(Trigger.New);    
        }
    }
}