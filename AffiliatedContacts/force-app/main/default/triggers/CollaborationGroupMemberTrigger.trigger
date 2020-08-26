/*
 * Created By: Swapnil Prajapati(Appirio)
 * Created On: 17th January 2019
 * Description: Create preference record when joined a chatter group - T-772800
 */
trigger CollaborationGroupMemberTrigger on CollaborationGroupMember (after insert, after delete) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            CollaborationGroupMemberHandler.onAfterInsert(Trigger.new);
        }else if(Trigger.isDelete){
            CollaborationGroupMemberHandler.onAfterDelete(Trigger.old);
        }
    }
}