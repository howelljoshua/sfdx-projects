/**
* @author Mathew Ruff, Sierra-Cedar
* @date 10/17/18
*
* AQB__PMTeam__c Trigger
*/
trigger PMTeam on AQB__PMTeam__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.run(new PMTeamTriggerHandler()); 
}