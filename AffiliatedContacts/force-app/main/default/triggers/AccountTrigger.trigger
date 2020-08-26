/* ********************************************************
 * (c) 2018 Appirio - A Wipro Company, Inc
 * Name: AccountTrigger.trigger
 * Description: Custom trigger for Account object
 * Created Date: Oct 08, 2018
 * Created By: Deepanshu Soni
 * Date Modified      Modified By       Description of the update
 * 
******************************************************** */

trigger AccountTrigger on Account(after delete, after insert, after update, before delete, before insert, before update) {
    
    AccountHandler accHandler = new AccountHandler();

    if (CMU_Util.isSystemUser() || CMU_Util.isRunningJob()) {
        return;
    }
    
    if (Trigger.isAfter) {
        List<Account> accCorpOrg = new List<Account>();
        if (Trigger.isInsert) {
            for(Account acc : Trigger.new){
                if(Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.recordtypeid).getname()=='Corporation'
                   || Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.recordtypeid).getname()=='Organization'){
                        accCorpOrg.add(acc);   
                   }
            }
            accHandler.followAccount(accCorpOrg);
        }
        if (Trigger.isUpdate) {
            List<Account> accOwnerUpdated = new List<Account>();
            for(Account acc : Trigger.New){
                Account oldAcc = Trigger.oldMap.get(acc.ID);
                if(oldAcc.OwnerId != acc.OwnerId
                  &&(Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.recordtypeid).getname()=='Corporation'
                   || Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.recordtypeid).getname()=='Organization')){
                    accOwnerUpdated.add(acc);    
                }
            }    
            if(accOwnerUpdated != null){
                accHandler.followAccount(accOwnerUpdated);    
            }
            
        }
    }

}