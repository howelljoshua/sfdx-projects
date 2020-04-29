public without sharing class AwardRecipientHandler {
    
    public static void updateAwardParent(List<AQB__AwardRecipients__c> recips) {
    
    List<Id> awardIds = new List<Id>();
    Map<Id, AQB__AwardRecipients__c> arMap = new Map<Id, AQB__AwardRecipients__c>();
        
        for (AQB__AwardRecipients__c ar : recips){
            awardIds.add(ar.AQB__Scholarship__c);
            arMap.put(ar.AQB__Scholarship__c, ar);
        }

    List<AQB__Award__c> awards = [SELECT Id, Most_Recent_Award_Recipient__c 
                                  FROM AQB__Award__c WHERE Id IN :awardIds];   //query the awards for these aw recips
    Map<Id, AQB__Award__c> awardsMap = new Map<Id, AQB__Award__c>();           //add all awards to map
    awardsMap.putAll(awards);

    List<AQB__AwardRecipients__c> mostRecents = [SELECT Id, AQB__Scholarship__c, Most_Recent__c, AQB__StartDate__c
                                                 FROM AQB__AwardRecipients__c
                                                 WHERE AQB__Scholarship__c IN :awardIds
                                                 AND Most_Recent__c = TRUE];         // query the most recent recip for these awards
    Map<Id, AQB__AwardRecipients__c> mostRecentsMap = new Map<Id, AQB__AwardRecipients__c>();  //new map  

        for(AQB__AwardRecipients__c r : mostRecents){
            mostRecentsMap.put(r.AQB__Scholarship__c, r);   //loop and add all most recent recips to most recent map         
        }

        for(AQB__Award__c award : awards){
            AQB__AwardRecipients__c triggerRecip;
            AQB__AwardRecipients__c queryRecip;
            if(arMap.containsKey(award.Id)){
                triggerRecip = arMap.get(award.Id);
            }
            if(mostRecentsMap.containsKey(award.Id)){
                queryRecip = mostRecentsMap.get(award.Id);
            }

            if(triggerRecip.AQB__StartDate__c >= queryRecip.AQB__StartDate__c){
                award.Most_Recent_Award_Recipient__c = triggerRecip.Id;
            }
            else {
                award.Most_Recent_Award_Recipient__c = queryRecip.Id;    
            }       
        }  
        
        
        //awardsMap.get(r.AQB__Scholarship__c).Most_Recent_Award_Recipient__c = r.Id;
    update awards;
    }
}