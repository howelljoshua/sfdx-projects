/**
* @author Mathew Ruff, Sierra-Cedar
* @date 10/17/18
*
* Opportunity Trigger
*/
trigger Opportunity on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.run(new OpportunityTriggerHandler());
}