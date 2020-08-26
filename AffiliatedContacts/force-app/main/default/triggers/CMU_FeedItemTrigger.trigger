/**
 * Created by Anand on 3/29/2019.
 */

trigger CMU_FeedItemTrigger on FeedItem (before insert, before update, after insert, after update) {
  if(trigger.isInsert){
    if(trigger.isAfter){
      CMU_FeedItemHandler.fillDefaultTopic(trigger.new); 
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