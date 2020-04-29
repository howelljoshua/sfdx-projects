/* ********************************************************
 * (c) 2018 Appirio - A Wipro Company, Inc
 * Name: OpportunityTrigger.trigger
 * Description: Custom trigger for Opportunity object
 * Created Date: Sep 26, 2018
 * Created By: Deepanshu Soni
 * Date Modified      Modified By       Description of the update
 * 
 *  08/20/2019     JOSHUA HOWELL      Excluded the UA Record Types (MG, EG, LIG) from the After Insert and After Update methods
******************************************************** */

trigger OpportunityTrigger on Opportunity(after delete, after insert, after update, before delete, before insert, before update) {
    //Instance of OpportunityHandler class
    OpportunityHandler opttyHandler = new OpportunityHandler();
    List < Opportunity > opptyList = new List < Opportunity > ();
    List < Opportunity > natOpptyList = new List < Opportunity > ();    
    

        if (Trigger.isAfter) {
            //After Insert
            if(Trigger.IsInsert) {
                List < Opportunity > privateOpptys = new List < Opportunity > ();
                List < Opportunity > publicOpptys = new List < Opportunity > ();
                List < Opportunity > sponsorOpptys = new List < Opportunity > ();
                List < Opportunity > amtUpdateOpptys = new List < Opportunity > ();
                Set < ID > setOfConsortium = new Set < ID >();
                
                for(Opportunity oppty : Trigger.New){   
                    if(!oppty.Private__c)
                    {publicOpptys.add(oppty);}
                    else
                    {privateOpptys.add(oppty);}
                    
                    if(oppty.Prime_Sponsor__c != null)
                    {sponsorOpptys.add(oppty);}
                    
                    if(oppty.Consortium__c != null)     
                    {setOfConsortium.add(oppty.Consortium__c);}
                    if(oppty.Amount != null)        
                    {amtUpdateOpptys.add(oppty);}
                }
                opttyHandler.updateOpptySharingPublic(publicOpptys);
                opttyHandler.updateOpptySharingPrivate(privateOpptys);        
                opttyHandler.updateOpptyName(Trigger.new);
                opttyHandler.populateOpptyTeam(Trigger.new);
                opttyHandler.followOppty(Trigger.new);
                opttyHandler.primeSponsorUpdate(sponsorOpptys, true, null);
                Set<Id> setRecordTypeIds = opttyHandler.validateOpportunityRecordTypeForConsortiomTotal();
                opttyHandler.updateConsortiumAmountOnOpportunity(setOfConsortium, setRecordTypeIds);
                if(amtUpdateOpptys.size()>0)
                {opttyHandler.updateNonGiftRevenue(amtUpdateOpptys);}
        }
            
            
            
            

            
            //After Update
        if(Trigger.IsUpdate){
                List < Opportunity > ownerUpdated = new List < Opportunity > ();
                List < Opportunity > privateOpptys = new List < Opportunity > ();
                List < Opportunity > publicOpptys = new List < Opportunity > ();
                List < Opportunity > sponsorOpptys = new List < Opportunity > ();
                List < Opportunity > sponsorOpptysOld = new List < Opportunity > ();
                List < Opportunity > unSponsorOpptys = new List < Opportunity > ();
                List < Opportunity > unSponsorOpptysOld = new List < Opportunity > ();
                List < Opportunity > amtUpdateOpptys = new List < Opportunity > ();
                Set < ID > setOfConsortium = new Set < ID >();
                Set < ID > setOfOldConsortium = new Set < ID >();
                Map <ID,Decimal> MapConsortiumOppAmount = new Map <ID,Decimal>();
                for(Opportunity oppty : Trigger.New){
                    Opportunity oldOppty = Trigger.oldMap.get(oppty.ID);
                    
                    if(oldOppty.Private__c != oppty.Private__c){
                        if(!oppty.Private__c)
                        {publicOpptys.add(oppty);}
                        else
                        {privateOpptys.add(oppty);}
                    }
                    if(oldOppty.OwnerId != oppty.OwnerId){
                        ownerUpdated.add(oppty);   
                    }
                    if(oldOppty.Amount != oppty.Amount){
                        amtUpdateOpptys.add(oppty);   
                    }
                    if((oldOppty.Prime_Sponsor__c!= oppty.Prime_Sponsor__c ) && oppty.Prime_Sponsor__c != null)
                    {sponsorOpptys.add(oppty); sponsorOpptysOld.add(oldOppty);}
                    if ((oldOppty.Prime_Sponsor__c!= oppty.Prime_Sponsor__c ) && oldOppty.Prime_Sponsor__c != null)
                    {unSponsorOpptys.add(oppty); unSponsorOpptysOld.add(oldOppty);}
                    if((oldOppty.Consortium__c != oppty.Consortium__c) 
                       || (oldOppty.Amount != oppty.Amount)
                       || (oldOppty.Opportunity_Sub_type__c != oppty.Opportunity_Sub_type__c)){
                           if(oppty.Consortium__c != null){
                               setOfConsortium.add(oppty.Consortium__c);
                           } 
                           if(oldOppty.Consortium__c != null){
                               setOfOldConsortium.add(oldOppty.Consortium__c);
                           }
                       }
                }
                
                //opttyHandler.followOppty(ownerUpdated);
                opttyHandler.updateOpptySharingPublic(publicOpptys);
                opttyHandler.updateOpptySharingPrivate(privateOpptys);
                opttyHandler.primeSponsorUpdate(sponsorOpptys, true, sponsorOpptysOld);
                opttyHandler.primeSponsorUpdate(unSponsorOpptys, false, unSponsorOpptysOld);
                Set<Id> setRecordTypeIds = opttyHandler.validateOpportunityRecordTypeForConsortiomTotal();
                opttyHandler.updateConsortiumAmountOnOpportunity(setOfConsortium, setRecordTypeIds);
                opttyHandler.updateConsortiumAmountOnOpportunity(setOfOldConsortium, setRecordTypeIds);
                if(amtUpdateOpptys.size()>0)
                {opttyHandler.updateNonGiftRevenue(amtUpdateOpptys);}
        }

            
        if(Trigger.IsDelete){
            Set < ID > setOfConsortium = new Set < ID >();
            for(Opportunity oppty : Trigger.old){
                if(oppty.Consortium__c != null)     
                {setOfConsortium.add(oppty.Consortium__c);}
            }
            Set<Id> setRecordTypeIds = opttyHandler.validateOpportunityRecordTypeForConsortiomTotal();
            opttyHandler.updateConsortiumAmountOnOpportunity(setOfConsortium, setRecordTypeIds);
        }
    }
}