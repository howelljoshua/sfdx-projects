/**
 * Created by Anand on 3/29/2019.
 */

trigger CMU_FeedCommentTrigger on FeedComment (before insert, before update, before delete, after insert, after update, after delete) {
  if(trigger.isInsert){
    if(trigger.isAfter){

    }
    if(trigger.isBefore){
      CMU_FeedItemHandler.blockUpdatesOnFlaggedItems(trigger.new,null);
    }

  }if(trigger.isUpdate){
    if(trigger.isAfter){

    }
    if(trigger.isBefore){
      CMU_FeedItemHandler.blockUpdatesOnFlaggedItems(trigger.new,trigger.oldMap);
    }

  }
}