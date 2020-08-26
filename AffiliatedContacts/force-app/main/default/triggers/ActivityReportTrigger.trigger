/*
*
* Trigger for Activity Report records
*
* @author   Michael Steptoe (Sleek) 02/12/2019
*/
trigger ActivityReportTrigger on AQB__ActivityReport__c (before insert, after insert, before update, after update, before delete, after delete) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            // Process before insert
        }
        
        if(Trigger.isDelete){
              System.debug('calling the Goals_ActivityReportUtility class to make the Activity Report User list');
            Goals_ActivityReportUtility.doWhat(Trigger.old);            
        }
        
        else if (Trigger.isUpdate) {
            // Process before update
        }
    }




    else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            // Process after insert
            ActivityReportTriggerHandler.afterInsert(Trigger.newMap);
        }
        
        
        if (Trigger.isDelete) {

        }
        
        else if (Trigger.isUpdate) {
            // Process after update
            ActivityReportTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);
        }      
    }
}