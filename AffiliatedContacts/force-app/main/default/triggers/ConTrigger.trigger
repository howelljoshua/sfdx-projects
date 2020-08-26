/* ********************************************************
 * (c) 2018 Appirio - A Wipro Company, Inc
 * Name: ConTrigger.trigger
 * Description: Custom trigger for Contact object
 * Created Date: Oct 08, 2018
 * Created By: Deepanshu Soni
 * Date Modified      Modified By       Description of the update
 * 
******************************************************** */

trigger ConTrigger on Contact(after delete, after insert, after update, before delete, before insert, before update) {
    
    ContactHandler conHandler = new ContactHandler();
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            conHandler.followContact(Trigger.new);
            conHandler.createMarketingPreference(Trigger.new);
        }
        if (Trigger.isUpdate) {
            List<Contact> ownerUpdated = new List<Contact>();
            for(Contact con : Trigger.New){
                Contact oldCon = Trigger.oldMap.get(con.ID);
                if(oldCon.OwnerId != con.OwnerId){
                    ownerUpdated.add(con);    
                }
            }    
            if(ownerUpdated != null){
                conHandler.followContact(ownerUpdated);    
            }
            conHandler.primarySchoolCheck(Trigger.new, Trigger.oldMap);
        }
    }
    
    if (trigger.isBefore) {
        conHandler.updateGUID(trigger.new);
    }

}