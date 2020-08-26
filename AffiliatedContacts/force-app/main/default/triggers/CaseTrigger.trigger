/**
* @author Mathew Ruff, Sierra-Cedar
* @date 10/19/18
*
* Case Trigger
*/
trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.run(new CaseTriggerHandler()); 
}