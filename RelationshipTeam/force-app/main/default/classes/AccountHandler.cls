/* ********************************************************
 * (c) 2018 Appirio - A Wipro Company, Inc
 * Name: AccountHandler.cls
 * Description: Handler class for AccountTrigger
 * Created Date: Oct 08, 2018
 * Created By: Deepanshu Soni
 * Date Modified      Modified By       Description of the update
 * 25-10-2018         Ishan Chawla      T-744903
******************************************************** */
public without sharing class AccountHandler {
    
    
    /**
     * Method Name : followAccount
     * Arguments: List<Account>
     * Return : void    
     * Description: follow(Chatter) the Account record
    **/
      
    public void followAccount(List<Account> accList){
        
       /*
        
            List<EntitySubscription> ESlist = new List<EntitySubscription>();
            //T-744903 Added map to avoid duplicates
            //Map<Id,Id> userAccIds = new Map<Id,Id>();
            Map<Id,Set<Id>> accountSubscriberMap = new Map<Id,Set<Id>>();
            for(EntitySubscription es : [SELECT Id,ParentId,SubscriberId FROM EntitySubscription WHERE ParentId IN :accList]) {
                if(!accountSubscriberMap.containsKey(es.ParentId)) {
                    accountSubscriberMap.put(es.ParentId,new Set<id>());
                }    
                    accountSubscriberMap.get(es.ParentId).add(es.SubscriberId);
            }
            if (accList != null) {
                for(Account acc: accList) {
                    //T-744903 Added check to avoid duplicates
                    //if((userAccIds.containsKey(acc.OwnerId) && (userAccIds.get(acc.OwnerId)!=acc.Id))|| !(userAccIds.containsKey(acc.OwnerId))){
                    //ConnectApi.Subscription subscriptionToRecord = ConnectApi.ChatterUsers.follow(null, acc.OwnerId, acc.Id);
                    if(!accountSubscriberMap.containsKey(acc.Id)|| !accountSubscriberMap.get(acc.Id).contains(acc.OwnerId)) {
                        if( !accountSubscriberMap.containsKey(acc.Id)) {
                            accountSubscriberMap.put(acc.Id,new Set<Id>());    
                        }
                        EntitySubscription ES = new EntitySubscription();
                        ES.subscriberId =acc.OwnerId;
                        ES.parentId = acc.Id;			
                        ESlist.add(ES);
                        //userAccIds.put(acc.OwnerId,acc.Id);
                        accountSubscriberMap.get(acc.Id).add(acc.OwnerId);
                    }
                }
                //upsert ESlist;
                Database.insert(esList,false);
            }
            //List<EntitySubscription> ESlist = new List<EntitySubscription>();
            //if (accList != null) {
                //for(Account acc: accList) {
                    //if(!Test.isRunningTest()
                      //&& (Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.recordtypeid).getname()=='Corporation'
                       // || Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.recordtypeid).getname()=='Organization')){
                       // ConnectApi.Subscription subscriptionToRecord = ConnectApi.ChatterUsers.follow(null, acc.OwnerId, acc.Id);   
                    //}
                //}
           // } 
                
       }
    */
    }	
}