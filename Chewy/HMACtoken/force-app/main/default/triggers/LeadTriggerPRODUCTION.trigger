/**
 * RA , 28/07/2021
 * @description Trigger On Lead for generating Tokens
*/
trigger LeadTrigger on Lead (after insert ,after update) {
    
   
    Boolean triggerActive = Boolean.valueOf(HMACTokenManager.chewySettingsMap.get('Enable_LeadTrigger').Value__c);
    
    if(Trigger.isAfter && triggerActive){
        if(Trigger.isInsert){
            HMACTokenManager.generateTokens(Trigger.New);
        }
        if(Trigger.isUpdate){
            List<Lead> leadsToUpdate = new List<Lead>();
            leadsToUpdate = HMACTokenManager.getLeadsForTokenUpdate(Trigger.oldMap,Trigger.newMap);
            if(leadsToUpdate.size() > 0){
                 HMACTokenManager.generateTokens(leadsToUpdate);
            }
        }
    }
    
}