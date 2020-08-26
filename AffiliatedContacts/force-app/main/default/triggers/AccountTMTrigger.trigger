/* ********************************************************
 * (c) 2018 Appirio - A Wipro Company, Inc
 * Name: AccountTMTrigger.trigger
 * Description: Custom trigger for Relationship Management object
 * Created Date: Oct 8, 2018
 * Created By: Deepanshu Soni
 * Date Modified      Modified By       Description of the update
 * 
******************************************************** */

trigger AccountTMTrigger on AQB__PMTeam__c(after delete, after insert, after update, before delete, before insert, before update) {
    
    AccTMHandler accountHandler = new AccTMHandler();
    
    if (Trigger.isAfter) {
        
        if (Trigger.isInsert) {
            Map<Id,Set<AQB__PMTeam__c>> accToAccTM = new Map<Id,Set<AQB__PMTeam__c>>();
            Set<Id> accIds = new Set<Id>();
            List<AQB__PMTeam__c> acTMtoUpdate = new  List<AQB__PMTeam__c> ();
            List<AQB__PMTeam__c> acTMTempPm = new  List<AQB__PMTeam__c> ();
            //System.debug('Trigger.New--->'+Trigger.New);
            //accountHandler.followRecord(Trigger.New); 
            
            //Map all the accounts with their respective Account Teams
            for(AQB__PMTeam__c accTM : Trigger.New){
                 if(accToAccTM.get(accTM.AQB__Account__c)==null){
                    accToAccTM.put(accTM.AQB__Account__c,new Set<AQB__PMTeam__c>());    
                }
                if(accTM.AQB__Role__c == 'Temporary Prospect Manager' && accTM.AQB__StartDate__c <= System.Today() && (accTM.AQB__EndDate__c > System.TODAY() || accTM.AQB__EndDate__c == null)){
                    acTMTempPm.add(accTM);
                }
                accToAccTM.get(accTM.AQB__Account__c).add(accTM);
            }
            system.debug('--accToAccTM--'+accToAccTM);
            //Filter the Accounts which hav record type as 'Corporation' OR 'Organization'
            for(Account acc:[SELECT Id, RecordTypeId FROM Account WHERE Id IN :accToAccTM.keySet()]){
                if(Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.recordtypeid).getname()=='Corporation'
                   || Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.recordtypeid).getname()=='Organization'){
                        accIds.add(acc.Id); 
                        acTMtoUpdate.addAll(accToAccTM.get(acc.Id));
                   }
            }
            system.debug('--acTMtoUpdate--'+acTMtoUpdate);
            if(acTMtoUpdate!=null)
                {accountHandler.followRecord(acTMtoUpdate);}
            if(!acTMTempPm.isEmpty()){
                AccTMHandler.updateTempPMInsert(acTMTempPm);
            }

        }
        if (Trigger.isUpdate) {

            List<AQB__PMTeam__c> acTMTempPm = new  List<AQB__PMTeam__c> ();
            for(AQB__PMTeam__c accTM : Trigger.New){
                if(accTM.AQB__Role__c == 'Temporary Prospect Manager' && accTM.AQB__EndDate__c <= System.TODAY() && (Trigger.oldMap.get(accTM.Id).AQB__EndDate__c == null || Trigger.oldMap.get(accTM.Id).AQB__EndDate__c > System.TODAY())){
                    acTMTempPm.add(accTM);
                }
            }
            if(!acTMTempPm.isEmpty())
                AccTMHandler.updateTempPMUpdateDelete(acTMTempPm);
        }
    }
     if (Trigger.isBefore) {
          if (Trigger.isDelete) {
              //accountHandler.validateDelete(Trigger.Old); 
              
                Map<Id,Set<AQB__PMTeam__c>> accToAccTM = new Map<Id,Set<AQB__PMTeam__c>>();
                Set<Id> accIds = new Set<Id>();
                List<AQB__PMTeam__c> acTMtoUpdate = new  List<AQB__PMTeam__c> ();
                List<AQB__PMTeam__c> acTMTempPm = new  List<AQB__PMTeam__c> ();
                
                //Map all the accounts with their respective Account Teams
                for(AQB__PMTeam__c accTM : Trigger.Old){
                     if(accToAccTM.get(accTM.AQB__Account__c)==null){
                        accToAccTM.put(accTM.AQB__Account__c,new Set<AQB__PMTeam__c>());    
                    }
                    if(accTM.AQB__Role__c == 'Temporary Prospect Manager' && accTM.AQB__Active__c){
                        AcTMTempPM.add(accTM);
                    }
                    accToAccTM.get(accTM.AQB__Account__c).add(accTM);
                }
                
                //Filter the Accounts which hav record type as 'Corporation' OR 'Organization'
                for(Account acc:[SELECT Id, RecordTypeId FROM Account WHERE Id IN :accToAccTM.keySet()]){
                    if(Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.recordtypeid).getname()=='Corporation'
                       || Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.recordtypeid).getname()=='Organization'){
                            accIds.add(acc.Id); 
                            acTMtoUpdate.addAll(accToAccTM.get(acc.Id));
                       }   
                }
                
                if(acTMtoUpdate!=null)
                    {accountHandler.validateDelete(acTMtoUpdate);}
                if(!acTMTempPm.isEmpty()){
                    AccTMHandler.updateTempPMUpdateDelete(acTMTempPm);
                }

              }
     }
}