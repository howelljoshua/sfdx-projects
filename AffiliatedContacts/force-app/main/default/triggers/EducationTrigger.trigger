/**
 * Created by Anand on 2/14/2019.
 */

trigger EducationTrigger on AQB__Education__c (after insert, after update,before delete, after delete) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            EducationTriggerHandler.updateAvailableCommunityExperiences(trigger.new,null);
        }
        if(trigger.isUpdate){
            EducationTriggerHandler.updateAvailableCommunityExperiences(trigger.new,trigger.oldMap);
        }
    }
    if(trigger.isBefore){
        if(trigger.isDelete){
            EducationTriggerHandler.updateAvailableCommunityExperiences(trigger.old,null);
        }

    }

}