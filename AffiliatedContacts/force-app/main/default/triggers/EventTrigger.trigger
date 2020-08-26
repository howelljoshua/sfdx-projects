/* ********************************************************
 * (c) 2018 Appirio - A Wipro Company, Inc
 * Name: EventTrigger.trigger
 * Description: Custom trigger for Event object
 * Created Date: Nov 1, 2018
 * Created By: Deepanshu Soni
 * Date Modified        Modified By         Description of the update
 * 02/26/2019           Michael Steptoe     Added logic to update essential before insert
******************************************************** */

trigger EventTrigger on Event (after delete, after insert, after update, before delete, before insert, before update) {
    EventHandler evntHandler = new EventHandler();

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            for(Event eve : Trigger.new){
                if(eve.AQB__ActivityReport__c != null){
                    eve.AQB__EssentialMove__c = true;
                }
            }
        }
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            //evntHandler.updateWhoName(Trigger.new);     
        }
    }
}