trigger SpecialEventTrigger on evt__Special_Event__c (after insert, after update, before delete, before insert, before update) {

	if(Trigger.isAfter){
		if(Trigger.isInsert){
			SpecialEventTriggerHandler.handleEventAfterInsert(Trigger.new);
		}else if(Trigger.isUpdate){
			SpecialEventTriggerHandler.handleEventAfterUpdate(Trigger.oldMap, Trigger.newMap);
		}

	}else if(Trigger.isBefore){
		if(Trigger.isDelete){
			SpecialEventTriggerHandler.handleEventBeforeDelete(Trigger.old);
		}
		else if(Trigger.isInsert){
			SpecialEventTriggerHandler.handleEventBeforeInsert(Trigger.new);
		}
		else if(Trigger.isUpdate){
			SpecialEventTriggerHandler.handleEventBeforeUpdate(Trigger.new, Trigger.oldMap);
		}
	}
}