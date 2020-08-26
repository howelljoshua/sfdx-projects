trigger ShoppingCartTrigger on pymt__Shopping_Cart_Item__c (after insert) {
		if(Trigger.isAfter){
			if(Trigger.isInsert){
				ShoppingCartTriggerHandler.handleAfterInsert(Trigger.new);
			}

		}
}