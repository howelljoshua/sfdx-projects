/* ********************************************************
 * (c) 2018 Appirio - A Wipro Company, Inc
 * Name: OpptyTMHandler.cls
 * Description: Handler class for OpportunityTrigger
 * Created Date: Oct 5, 2018
 * Created By: Deepanshu Soni
 * Date Modified      Modified By       Description of the update
 * 
******************************************************** */
public without sharing class OpptyTMHandler {
    
    /**
     * Method Name : followRecord
     * Arguments: List<OpportunityTeamMember>
     * Return : void    
     * Description: Follow the Opportunity record(chatter) 
    **/
      
    public void followRecord(List<OpportunityTeamMember> opptyTMList){
        
        for(OpportunityTeamMember opptyTM : opptyTMList){
            system.debug('---opptyTM.UserId---'+opptyTM.UserId);
            //ConnectApi.Subscription subscriptionToRecord = ConnectApi.ChatterUsers.follow(null, opptyTM.UserId, opptyTM.OpportunityId);
        }
    }
}