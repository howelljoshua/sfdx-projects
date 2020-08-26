/**
 * Created by lucasd on 7/1/2019.
 */

trigger CaseCommentTrigger on CaseComment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        CaseCommentTriggerHandler.updateCaseCommentDate(Trigger.new);
    }

}