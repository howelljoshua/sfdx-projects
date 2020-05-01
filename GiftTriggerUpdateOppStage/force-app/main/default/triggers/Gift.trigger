/**
* @author Mathew Ruff, Sierra-Cedar
* @date 10/30/18
*
* AQB__Gift__c Trigger
*/
trigger Gift on AQB__Gift__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.run(new GiftTriggerHandler());
}