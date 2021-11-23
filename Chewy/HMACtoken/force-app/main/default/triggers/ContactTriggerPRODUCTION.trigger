/**
 * RA , 26/09/2021
 * @description Trigger On Contact for generating Tokens
*/
trigger ContactTrigger on Contact (after update) {
	if(Trigger.isAfter && Trigger.isUpdate){
        List<Contact> consToUpdate = new List<Contact>();
        consToUpdate = HMACTokenManager.getContactsForTokenUpdate(Trigger.oldMap,Trigger.newMap);
        if(consToUpdate.size() > 0){
            HMACTokenManager.generateTokens(consToUpdate);
        }
    }
}