/* ********************************************************
 * (c) 2018 Appirio - A Wipro Company, Inc
 * Name: OpportunityHandler.cls
 * Description: Handler class for OpportunityTrigger
 * Created Date: Sep 26, 2018
 * Created By: Deepanshu Soni
 * Date Modified      Modified By       Description of the update
 * Oct 24, 2018       Ishan Chawla      I-350528
 * Oct 25, 2018       Ishan Chawla      T-744903
 * Nov 11, 2018       Ishan Chawla      I-352401
******************************************************** */
public without sharing class OpportunityHandler {
    
    /**
     * Method Name : followOppty
     * Arguments: List<Opportunity>
     * Return : void    
     * Description: follow(Chatter) the Opportunity record
    **/
      
    public void followOppty(List<Opportunity> opptyList){
        if (opptyList != null && opptyList.size()>0) {
            Map<Id,Set<Id>> opptyOwnerIds = new  Map<Id,Set<Id>> ();
            for(Opportunity oppty: opptyList) {
                if((Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Sponsored Research Agreements'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Licensing'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Other unfunded agreement'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Subcontract (Out)'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Executive Education'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='CMU Spin-Off Investment'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='CMU Spin-Off Acquisition'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Career/Recruiting'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='CMU Real Estate'                   
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Economic Development'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Gift(IP)')){
                    //T-744903
                    //ConnectApi.Subscription subscriptionToRecord = ConnectApi.ChatterUsers.follow(null, oppty.OwnerId, oppty.Id);
                    
          if(opptyOwnerIds.get(oppty.OwnerId)==null){
                  opptyOwnerIds.put(oppty.OwnerId,new Set<Id>());    
                    }
                    opptyOwnerIds.get(oppty.OwnerId).add(oppty.Id);               
                 } 
            }
            
            if(opptyOwnerIds.keyset().size() > 0){
                for(User usr: [SELECT id, isActive FROM User WHERE Id IN :opptyOwnerIds.keyset()]){
                    if(usr.isActive){
                        for(Id opptyId : opptyOwnerIds.get(usr.id)) {
                            if(!Test.isRunningTest()){
                                ConnectApi.Subscription subscriptionToRecord = ConnectApi.ChatterUsers.follow(null, usr.Id, opptyId);
                            }   
                        }   
                    }    
                }
            }
        }
        
    }
    
     /**
     * Method Name : followOpptyTM
     * Arguments: List<OpportunityTeamMember>
     * Return : void    
     * Description: follow(Chatter) the Opportunity record
    **/
    public void followOpptyTM(List<OpportunityTeamMember> opptyTMList){
        List<EntitySubscription> ESlist = new List<EntitySubscription>();
        // I-350528 Added Map userOpptIds
        Map<Id,Id> userOpptIds = new Map<Id,Id>();
        if (opptyTMList != null && opptyTMList.size()>0) {
            for(OpportunityTeamMember opptyTM: opptyTMList) {
                // I-350528 Added Check to avoid duplicates
                if((userOpptIds.containsKey(opptyTM.UserId) && (userOpptIds.get(opptyTM.UserId)!=opptyTM.OpportunityId))||(!userOpptIds.containsKey(opptyTM.UserId) ))
                {
                //ConnectApi.Subscription subscriptionToRecord = ConnectApi.ChatterUsers.follow(null, opptyTM.UserId, opptyTM.OpportunityId);
                EntitySubscription ES = new EntitySubscription();
                ES.subscriberId = opptyTM.UserId;
                ES.parentId = opptyTM.OpportunityId;            
                ESlist.add(ES);
                userOpptIds.put(opptyTM.UserId,opptyTM.OpportunityId);
            }
            }
            upsert ESlist;
        }        
    }
    
    /**
     * Method Name : updateOpptyName
     * Arguments: List<Opportunity>
     * Return : void    
     * Description: follow(Chatter) the Opportunity record
    **/
    public void updateOpptyName(List<Opportunity> opptyList){
        List<Id> oppIds = new List<Id>();
        List<Opportunity> updatedOpptyList = new List<Opportunity>();
        if (opptyList != Null && opptyList.size()>0) {
            for(Opportunity oppty: opptyList) {
                if(Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Sponsored Research Agreements'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Licensing'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Other unfunded agreement'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Subcontract (Out)'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Executive Education'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='CMU Spin-Off Investment'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='CMU Spin-Off Acquisition'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Career/Recruiting'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='CMU Real Estate'                   
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Economic Development'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Gift(IP)'){
                        oppIds.add(oppty.Id);  
                   }     
            }
            if(oppIds!=null && oppIds.size()>0){
                for(Opportunity oppty:[SELECT Id, Name, Account.Name, Opportunity_Title__c, RecordType.Name,Counter__c FROM Opportunity WHERE id in :oppIds]){
                    date myDate = date.Today();
                    Integer month = myDate.month();
                    Integer day = myDate.day();
                    Integer year = myDate.year();
                    
                    Integer maxLengthAcc = 0;
                    Integer maxLengthRecType = 0;
                    
                    if(oppty.Account.name.length()>50)
                        {maxLengthAcc=50;}
                    else
                        {maxLengthAcc=oppty.Account.name.length();}
                    
                    if(oppty.RecordType.name.length()>50)
                        {maxLengthRecType=50;}
                    else
                        {maxLengthRecType=oppty.RecordType.name.length();}    
                    
                    oppty.Opportunity_Title__c= oppty.Account.name.substring(0,maxLengthAcc) + '-' + oppty.RecordType.Name.substring(0,maxLengthRecType) + '-' + month + '-' + day + '-' + year   + '-' + oppty.Counter__c;
                    updatedOpptyList.add(oppty);
                }
                upsert updatedOpptyList;
            }    
        }
        
    }
    
    
    /**
     * Method Name : populateOpptyTeam
     * Arguments: Opportunity
     * Return : void    
     * Description: Creating Opportunity Team from the Account Team 
    **/
      
    public void populateOpptyTeam(List<Opportunity> opptyList){
        Map<id,id> mapOppAcc = new Map<id,id>();
        Set<Id> setOppAccId = new Set<Id>();
        List<Account> accWithNoTeam = new List<Account>();
        
        /*Boolean Sponsored = false;
        Boolean Subcontract = false;
        Boolean Exec = false;
        Boolean Licensing = false;
        Boolean Investment = false;
        Boolean Acquisition = false;
        Boolean Recruiting = false;
        Boolean RealEstate = false;
        Boolean Economic = false;
        Boolean Gift = false;
        Boolean Unfunded = false;*/
        
        List<OpportunityTeamMember> opptyTMs = new List<OpportunityTeamMember> ();
        Integer opptyTeam = 0; //count the team members
        if (opptyList != Null && opptyList.size()>0) {
            for(Opportunity oppty: opptyList) {
                if(Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Sponsored Research Agreements'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Licensing'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Other unfunded agreement'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Subcontract (Out)'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Executive Education'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='CMU Spin-Off Investment'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='CMU Spin-Off Acquisition'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Career/Recruiting'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='CMU Real Estate'                   
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Economic Development'
                   || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Gift(IP)')
                  
                {     mapOppAcc.put(oppty.Id, oppty.AccountId);
                        setOppAccId.add(oppty.AccountId);
                }
                
                //Record Types
                /*Sponsored = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Sponsored Research Agreements';
                Subcontract = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Subcontract (Out)';
                Exec = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Exec Ed & Educational Projects';
                Licensing = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Licensing';
                Investment = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='CMU Spin-Off Investment';
                Acquisition = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='CMU Spin-Off Acquisition';
                Recruiting = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Career/Recruiting';
                RealEstate = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='CMU Real Estate';
                Economic = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Economic Development';
                Gift = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Gift(IP)';
                Unfunded = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Other unfunded agreement';*/
                
            }
            
            Map<id, List<AQB__PMTeam__c>> mapAccTeam = new Map<id, List<AQB__PMTeam__c>>();
            for(AQB__PMTeam__c accTm: [SELECT AQB__Account__c,AQB__Active__c,AQB__Role__c,AQB__User__c,AQB__EndDate__c,AQB__StartDate__c,AQB__GiftCredit__c
                                            FROM AQB__PMTeam__c WHERE AQB__Account__c IN :setOppAccId]){
                if(!mapAccTeam.containsKey(accTm.AQB__Account__c)){
                    mapAccTeam.put(accTm.AQB__Account__c, new List<AQB__PMTeam__c>());
                }
                mapAccTeam.get(accTm.AQB__Account__c).add(accTm);   
            }
            Map<Id,Set<Id>> mapUserOppty = new Map<Id,Set<Id>>();
            for(Opportunity oppty: opptyList){
                if(mapOppAcc.containsKey(oppty.Id) && mapAccTeam.containsKey(oppty.AccountId))
                {
                        for(AQB__PMTeam__c accTM : mapAccTeam.get(oppty.AccountId)){ system.debug('---accTM---'+accTM);
                                if(accTM.AQB__Active__c){
                                    if(!mapUserOppty.containsKey(accTM.AQB__User__c)){
                                        mapUserOppty.put(accTM.AQB__User__c, new Set<Id>());
                                    }
                                    mapUserOppty.get(accTM.AQB__User__c).add(oppty.Id); 
                                    /*Check for
                                    1. Prospect Manager (All RT's)
                                    2. Contract Officer/Analyst (Sponsored Research and Licensing RT)
                                    3. Licensing Officer (Sponsored Research and Licensing RT )
                                    4. Recruiting Manager (Recruiting RT)*/
                                
                                if(
                                    (accTM.AQB__Role__c == 'Prospect Manager')
                                    || (accTM.AQB__Role__c == 'Contract Officer' && (Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Sponsored Research Agreements' || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Licensing'))
                                    || (accTM.AQB__Role__c == 'Licensing Officer' && (Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Sponsored Research Agreements' || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Licensing'))
                                    || (accTM.AQB__Role__c == 'Recruiting Manager' && Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Career/Recruiting')
                                    ){   
                                    OpportunityTeamMember opptyTM = new OpportunityTeamMember();
                                    opptyTM.OpportunityId = oppty.Id;
                                    opptyTM.UserId = accTM.AQB__User__c;
                                    opptyTM.AQB__EndDate__c = accTM.AQB__EndDate__c;
                                    opptyTM.AQB__StartDate__c = accTM.AQB__StartDate__c;
                                    opptyTM.AQB__PercentCredit__c = accTM.AQB__GiftCredit__c;
                                    opptyTM.TeamMemberRole = accTM.AQB__Role__c;
                                    opptyTMs.add(opptyTM);
                                    }    
                                }
                        }
                }
                OpportunityTeamMember opptyTM = new OpportunityTeamMember();
                opptyTM.OpportunityId = oppty.Id;
                opptyTM.UserId = oppty.OwnerId;
                //opptyTM.AQB__EndDate__c = oppty.CloseDate;
                opptyTM.AQB__StartDate__c =System.Now().date();
                opptyTM.TeamMemberRole = 'Team Leader';
                opptyTMs.add(opptyTM);
            }
            if(!opptyTMs.isEmpty()){
                insert opptyTMs;  
                followOpptyTM(opptyTMs);
            }
            if(mapUserOppty != null){
              emailTeamMembers(mapUserOppty)  ;
            }
            
                
            
            //Email the team members
            //if (!opptyTMs.isEmpty() && (Sponsored || Subcontract || Exec || Licensing || Investment || Acquisition || Recruiting || RealEstate || Economic || Gift || Unfunded)){
                //Send an email to all the Account/Opportunity Team Members for IP Profile only 
            //      emailTeamMembers(opptyTMs);   
                
            //} 
            
            //If account team is blank, email help desk
            Integer count=0; //AQB__PMTeam__c
            for(Account acc: [SELECT Id, Name, (SELECT Id FROM AQB__Prospect_Management_Team__r LIMIT 1) FROM Account WHERE Id IN :setOppAccId ]){
                if(acc.AQB__Prospect_Management_Team__r.size()>0){
                    count++;    
                }
                else{
                    accWithNoTeam.add(acc);    
                }
            }
            if(accWithNoTeam.size()>0){
                emailHelpDesk(accWithNoTeam);       
            }
        }
    }   
    
     /**
     * Method Name : emailTeamMembers
     * Arguments: List<OpportunityTeamMember>
     * Return : void    
     * Description: Sending an email to all the Account/Opportunity Team Members for IP Profile only
    **/
    
    public void emailTeamMembers(Map<Id,Set<Id>> mapUserOppty){
        List<String> userEmails = new List<String>();
        Set<Id> setUserTMs = new Set<Id>();
        //Map<Id,Id> mapUserOppty = new Map<Id,Id>();
        //Set<Id> userForEmail = new Set<Id>();
        EmailTemplate opptyNotify = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName ='IP_Oppty_Notification'];
        //for(OpportunityTeamMember opptyTM : opptyTMs){
       // for(Id usrId : mapUserOppty.keySet()){
            //userForEmail.add(usrId);
            //mapUserOppty.put(opptyTM.UserId, opptyTM.OpportunityId);
        //}
        
        for(User userTM : [SELECT Id, Email, Name FROM User WHERE Id IN :mapUserOppty.keyset()]){ 
           Contact con = new Contact( lastname = userTM.Name, AQB__Type__c='Friend', email=userTM.Email, Department='ToBeDeleted');
            upsert con;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(opptyNotify.Id);
            mail.setUseSignature(false);
            mail.setBccSender(false);
            mail.setSaveAsActivity(false);
            con.email=userTM.Email;
            upsert con;
            mail.setTargetObjectId(con.Id); 
            //mail.setTargetObjectId(userTM.Id);
            for(Id oppId : mapUserOppty.get(userTM.Id)){
                mail.setWhatId(oppId);
                try {
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                } catch (Exception e) {
                    System.debug('--Exception--'+e.getMessage());
                } 
            }   
            delete con; 
        }
        
    }
    
     /**
     * Method Name : emailHelpDesk
     * Arguments: List<Opportunity>
     * Return : void    
     * Description: Sending an email to all the Account/Opportunity Team Members for IP Profile only
    **/
    //T-744903 Made Method static
    public static void emailHelpDesk(List<Account> accs){
        Set<String> accNames = new Set<String>();
        String helpDeskEmail = Label.CMUHelpDeskMail;
        for(Account acc : accs){
            accNames.add(String.valueOf(acc.Name));
        }
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { helpDeskEmail };
        message.subject = 'Accounts with no team members';
        message.plainTextBody = 'These following accounts do not have a team member associsted with them - '+accNames;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }    
    }
    
    /**
     * Method Name : updateOpptySharingPublic
     * Arguments: Opportunity
     * Return : void    
     * Description: Update Opportunity Sharing when Opportunity is Public
    **/
      
    public void updateOpptySharingPublic(List<Opportunity> opptyList){
        List<OpportunityShare> oppShareToInsert = new List<OpportunityShare>();
        if (opptyList != Null && opptyList.size() > 0) {
            Group internalGroup = [SELECT Id, DeveloperName FROM Group where developername ='AllInternalUsers'];
            for(Opportunity oppty: opptyList) {
                //Create the sharing for Public Read only
                OpportunityShare publicShare = new OpportunityShare();
                publicShare.OpportunityId = oppty.Id;
                publicShare.OpportunityAccessLevel = 'Read';
                publicShare.RowCause = 'Manual';
                publicShare.UserOrGroupId = internalGroup.Id;
                oppShareToInsert.add(publicShare);
            }
         }
         if(oppShareToInsert!=null)
            {upsert oppShareToInsert;}
    }
    
    /**
     * Method Name : updateOpptySharingPrivate
     * Arguments: Opportunity
     * Return : void    
     * Description: Update Opportunity Sharing when Opportunity is Private
    **/
      
    public void updateOpptySharingPrivate(List<Opportunity> opptyList){
        Set<Id> setOpptyIds = new Set<Id>();
        List<OpportunityShare> oppShareToDelete = new List<OpportunityShare>();
        
        if (opptyList != null && opptyList.size() > 0) {
            for(Opportunity oppty: opptyList) {
                setOpptyIds.add(oppty.Id);
            }
         
         
            for(OpportunityShare oppShare : [SELECT Id, OpportunityId, OpportunityAccessLevel, RowCause, UserOrGroupId 
                                            FROM OpportunityShare WHERE OpportunityId IN :setOpptyIds ]){
                
                //Create the sharing for Public Read only
                if(oppShare.RowCause == 'Manual'){
                    oppShareToDelete.add(oppShare); 
                }
            }
        }
        if(oppShareToDelete!=null)
            {delete oppShareToDelete;}
    }
    /**
     * Method Name : primeSponsorUpdate
     * Arguments: Opportunity, Boolean, AccId
     * Return : void    
     * Description: On create/update of Opportunity record, if Prime Sponsor field is not blank,update the Opportunity Team with the Prospect Manager from the Prime Sponsor Account. 
    **/
      
    public void primeSponsorUpdate(List<Opportunity> opptyList, Boolean newSponsor, List<Opportunity> opptyListOld){
        Map<id,id> mapOppAcc = new Map<id,id>();
        Map<id,id> mapOppSponsorAcc = new Map<id,id>();
        Set<Id> setOpptyIds = new Set<Id>();
        Set<Id> setOppAccId = new Set<Id>();
        Set<Id> setOppSponsorAccId = new Set<Id>();
        Set<Id> setOldSponsorAccId = new Set<Id>();
        List<OpportunityTeamMember> opptyTMstoAdd = new List<OpportunityTeamMember> ();
        Set<Id> opptyTMstoDel = new Set<Id> ();
        /*Boolean Sponsored = false;
        Boolean Licensing = false;
        Boolean unfunded = false;*/
        
        if (opptyList != null && opptyList.size() > 0) {
            for(Opportunity oppty: opptyList) {
                mapOppSponsorAcc.put(oppty.Id, oppty.Prime_Sponsor__c);
                mapOppAcc.put(oppty.Id, oppty.AccountId);
                setOppSponsorAccId.add(oppty.Prime_Sponsor__c);
                setOppAccId.add(oppty.AccountId);
                setOpptyIds.add(oppty.Id);
                
                //Record Types
                /*Sponsored = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Sponsored Research Agreements';
                Licensing = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Licensing';
                Unfunded = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Other unfunded agreement';*/
            }
            if(newSponsor && (setOppSponsorAccId != null && setOppSponsorAccId.size() > 0) ){
                Map<id, List<AQB__PMTeam__c>> mapAccSponsorTeam = new Map<id, List<AQB__PMTeam__c>>();
                for(AQB__PMTeam__c accTm: [SELECT AQB__Account__c,AQB__Active__c,AQB__Role__c,AQB__User__c,AQB__EndDate__c,AQB__StartDate__c,AQB__GiftCredit__c
                                                FROM AQB__PMTeam__c WHERE AQB__Account__c IN :setOppSponsorAccId]){
                    if(!mapAccSponsorTeam.containsKey(accTm.AQB__Account__c)){
                        mapAccSponsorTeam.put(accTm.AQB__Account__c, new List<AQB__PMTeam__c>());
                    }
                    mapAccSponsorTeam.get(accTm.AQB__Account__c).add(accTm);    
                }
                
                for(Opportunity oppty: opptyList){
                    if(mapOppSponsorAcc.containsKey(oppty.Id) && mapAccSponsorTeam.containsKey(oppty.Prime_Sponsor__c) &&
                      (Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Sponsored Research Agreements'
                      || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Licensing'
                      || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Other unfunded agreement')
                      ){
                        for(AQB__PMTeam__c accTM : mapAccSponsorTeam.get(oppty.Prime_Sponsor__c)){
                            if(accTM.AQB__Active__c && accTM.AQB__Role__c == 'Prospect Manager'){
                                OpportunityTeamMember opptyTM = new OpportunityTeamMember();
                                opptyTM.OpportunityId = oppty.Id;
                                opptyTM.UserId = accTM.AQB__User__c;
                                opptyTM.AQB__EndDate__c = accTM.AQB__EndDate__c;
                                opptyTM.AQB__StartDate__c = accTM.AQB__StartDate__c;
                                opptyTM.AQB__PercentCredit__c = accTM.AQB__GiftCredit__c;
                                opptyTM.TeamMemberRole = accTM.AQB__Role__c;
                                opptyTMstoAdd.add(opptyTM);   
                            }
                        }
                    }
                }
                if(!opptyTMstoAdd.isEmpty()){
                    upsert opptyTMstoAdd;    
                }
        
            }
            else if(!newSponsor ){
                //Remove the Team members which were part of the Prime Sponsor account before  
                Map<id,id> mapOppAccOld = new Map<id,id>();
                
                for(Opportunity oppty: opptyListOld){
                     if(Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Sponsored Research Agreements'
                      || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Licensing'
                      || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppty.recordtypeid).getname()=='Other unfunded agreement'
                      ){
                            setOldSponsorAccId.add(oppty.Prime_Sponsor__c); 
                            mapOppAccOld.put(oppty.Id, oppty.Prime_Sponsor__c);
                      }   
                }
                
                Map<id, List<AQB__PMTeam__c>> mapAccTeam = new Map<id, List<AQB__PMTeam__c>>();
                if(setOppAccId != null && setOppAccId.size() > 0){
                    for(AQB__PMTeam__c accTm: [SELECT AQB__Account__c,AQB__Active__c,AQB__Role__c,AQB__User__c,AQB__EndDate__c,AQB__StartDate__c,AQB__GiftCredit__c
                                                    FROM AQB__PMTeam__c WHERE AQB__Account__c IN :setOppAccId]){
                        if(!mapAccTeam.containsKey(accTm.AQB__Account__c)){
                            mapAccTeam.put(accTm.AQB__Account__c, new List<AQB__PMTeam__c>());
                        }
                        mapAccTeam.get(accTm.AQB__Account__c).add(accTm);   
                    }
                }
                Map<id, List<AQB__PMTeam__c>> mapAccSponsorTeam = new Map<id, List<AQB__PMTeam__c>>();
                if(setOldSponsorAccId != null && setOldSponsorAccId.size() > 0){
                    for(AQB__PMTeam__c accTm: [SELECT AQB__Account__c,AQB__Active__c,AQB__Role__c,AQB__User__c,AQB__EndDate__c,AQB__StartDate__c,AQB__GiftCredit__c
                                                    FROM AQB__PMTeam__c WHERE AQB__Account__c IN :setOldSponsorAccId]){
                        if(!mapAccSponsorTeam.containsKey(accTm.AQB__Account__c)){
                            mapAccSponsorTeam.put(accTm.AQB__Account__c, new List<AQB__PMTeam__c>());
                        }
                        mapAccSponsorTeam.get(accTm.AQB__Account__c).add(accTm);    
                    }
                }
                List<OpportunityTeamMember> opptyTMs = new  List<OpportunityTeamMember>();
                if(setOpptyIds != null && setOpptyIds.size() > 0){
                  opptyTMs = [SELECT Id, OpportunityId, UserId, TeamMemberRole
                                                    FROM OpportunityTeamMember WHERE OpportunityId IN :setOpptyIds];
                }
                    if(opptyTMs!=null && opptyTMs.size() > 0){
                        for(OpportunityTeamMember opptyTM: opptyTMs){
                            List<AQB__PMTeam__c> accTMs = mapAccTeam.get(mapOppAcc.get(opptyTM.OpportunityId));
                            if(accTMs!=null){
                                for(AQB__PMTeam__c accTM : accTMs){
                                    if(accTM.AQB__User__c != opptyTM.UserId){
                                        opptyTMstoDel.add(opptyTM.Id);
                                    }
                                }
                            }
                            else{
                                List<AQB__PMTeam__c> accTMsponsor = mapAccSponsorTeam.get(mapOppAccOld.get(opptyTM.OpportunityId));
                                if(accTMsponsor!=null){
                                    for(AQB__PMTeam__c accTM : accTMsponsor){
                                        if(accTM.AQB__User__c == opptyTM.UserId){
                                            opptyTMstoDel.add(opptyTM.Id);
                                        }
                                    }
                                }    
                            }
                        }
                    }    
                if(opptyTMstoDel.size()>0){
                    List<OpportunityTeamMember> opptyTMDel = [SELECT Id, OpportunityId, UserId, TeamMemberRole, AQB__EndDate__c, AQB__StartDate__c, AQB__PercentCredit__c
                                                    FROM OpportunityTeamMember WHERE OpportunityId IN :opptyTMstoDel];
                    
                    upsert opptyTMDel;
                }    
            }
            
        }
    }
    
    /**
     * Method Name : updateConsortiumAmountOnOpportunity
     * Arguments: Set<Internal_Consortium__c> 
     * Return : void    
     * Description: Update the Consortium amount when Consortium Or Opportunity Amount is Updated
     * Inserted Opp
     * Cloned Opp
     * Deleted Opp
     * Upadetes to Opp Sub Type 
     * Updated To Consortium Field On Opp
    **/  
    public void updateConsortiumAmountOnOpportunity(Set<ID> setOfOldConsortium, Set<Id> setRecordTypeIds){
        List<Internal_Consortium__c> consortiumToUpdate = new List<Internal_Consortium__c>();
        Map<Id,Decimal> mapOfConsortiumIdAndOppAmountSum = new Map<Id,Decimal>();
        Set<String> oppSubTypeSetForSRA = new Set<String>{'Master - Funded','Standard'};
      Set<String> oppSubTypeSetForCareerRecruting = new Set<String>{'Fee based'};
        for(AggregateResult ag:[SELECT Sum(Amount), Consortium__c, RecordType.DeveloperName, Opportunity_Sub_type__c 
                                FROM Opportunity 
                                WHERE Consortium__c != null  
                                AND RecordTypeId in : setRecordTypeIds
                                AND Consortium__c IN : setOfOldConsortium 
                                GROUP BY Consortium__c, RecordType.DeveloperName, Opportunity_Sub_type__c ]){
      if(((String)ag.get('DeveloperName')).equals('Sponsored_Research_Agreements')){
        if(oppSubTypeSetForSRA.contains((String)ag.get('Opportunity_Sub_type__c'))){
                    if(setOfOldConsortium.contains((Id)ag.get('Consortium__c'))){
                      if(mapOfConsortiumIdAndOppAmountSum.get((Id)ag.get('Consortium__c')) != null){
                      mapOfConsortiumIdAndOppAmountSum.put((Id)ag.get('Consortium__c'),
                                                         mapOfConsortiumIdAndOppAmountSum.get((Id)ag.get('Consortium__c'))
                                                         + (Decimal)ag.get('expr0'));
                        } else {
                            mapOfConsortiumIdAndOppAmountSum.put((Id)ag.get('Consortium__c'),(Decimal)ag.get('expr0'));
                        }
                    }
                }
            } 
      
      else if(((String)ag.get('DeveloperName')).equals('Career_Recruiting')){
                if(oppSubTypeSetForCareerRecruting.contains((String)ag.get('Opportunity_Sub_type__c'))){
                    if(setOfOldConsortium.contains((Id)ag.get('Consortium__c'))){
                      if(mapOfConsortiumIdAndOppAmountSum.get((Id)ag.get('Consortium__c')) != null){
                      mapOfConsortiumIdAndOppAmountSum.put((Id)ag.get('Consortium__c'),
                                                         mapOfConsortiumIdAndOppAmountSum.get((Id)ag.get('Consortium__c'))
                                                         + (Decimal)ag.get('expr0'));
                        } else{
                            mapOfConsortiumIdAndOppAmountSum.put((Id)ag.get('Consortium__c'),(Decimal)ag.get('expr0'));
                        }
                    }
                }
            } 

      else if(setOfOldConsortium.contains((Id)ag.get('Consortium__c'))){
                if(mapOfConsortiumIdAndOppAmountSum.get((Id)ag.get('Consortium__c')) != null){
                      mapOfConsortiumIdAndOppAmountSum.put((Id)ag.get('Consortium__c'),
                                                         mapOfConsortiumIdAndOppAmountSum.get((Id)ag.get('Consortium__c'))
                                                         + (Decimal)ag.get('expr0'));
                } else{
                    mapOfConsortiumIdAndOppAmountSum.put((Id)ag.get('Consortium__c'),(Decimal)ag.get('expr0'));
                }
            }
        }
        if(setOfOldConsortium != null && setOfOldConsortium.size() > 0){
            for(Internal_Consortium__c  consortium : [SELECT ID, Opportunity_Total__c 
                                                      FROM Internal_Consortium__c 
                                                      WHERE ID IN : setOfOldConsortium]){
                if(mapOfConsortiumIdAndOppAmountSum.get(consortium.ID) != null){ 
                    consortium.Opportunity_Total__c = mapOfConsortiumIdAndOppAmountSum.get(consortium.ID);
                } else{
                    consortium.Opportunity_Total__c = 0.0;
                }
                consortiumToUpdate.add(consortium);
            }
        }
        if(consortiumToUpdate != null && consortiumToUpdate.size() > 0 ){
            update consortiumToUpdate;
        }
    }
  
    /**
     * Method Name : validateOpportunityRecordTypeForConsortiomTotal
     * Arguments: none
     * Return : Set<ID>    
     * Description: Get RecordType Ids.
    **/  
    public Set<Id> validateOpportunityRecordTypeForConsortiomTotal(){
        Set<String> setOfRecordTypes = new Set<String>{ 'Sponsored_Research_Agreements',
                                  'Executive_Education',
                                  'Licensing',
                                  'CMU_Spin_Off_Acquisition',
                                  'CMU_Real_Estate',
                                  'Career_Recruiting',
                                'Subcontract_Out',
                                  'CMU_Spin_Off_Investment',
                                  'Economic_Development',
                                'Gift_IP',
                                'Other_unfunded_agreement'};
    Set<Id> setOfRecordTypeIds = new Set<Id>();
        List<Schema.RecordTypeInfo> listRTI = Schema.SObjectType.Opportunity.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rti : listRTI){
            if(setOfRecordTypes.contains(rti.getDeveloperName())){
                setOfRecordTypeIds.add(rti.getRecordTypeId());
            }
        }
        return setOfRecordTypeIds;
    }
        /**
     * Method Name : updateNonGiftRevenue
     * Arguments: List<Account>
     * Return : void    
     * Description: Total Non-Gift Revenue (new field) = Sum of all Closed Won Opportunities where Account = Account ID 
     * AND (( Record Type = SRA AND Subtype = Master-Funded, RPS OR Standard) 
     * OR ( Record Type = Exec Ed) OR ( Record Type = Licensing) 
     * OR ( Record Type = CMU Spin-Off Acquisition) OR ( Record Type = CMU Real Estate)
     * OR ( Record Type = Career/Recruiting AND Subtype = Fee based) )
    **/
      
    public void updateNonGiftRevenue(List<Opportunity> oppList){
        Set<Id> accIds = new Set<Id>();
        Map<Id, Decimal> mapAccAmt = new Map<Id, Decimal>();
        Id SRARecTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Sponsored Research Agreements').getRecordTypeId();
        Id ExecutiveRecTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Executive Education').getRecordTypeId();
        Id LicensingRecTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Licensing').getRecordTypeId();
        Id AcquisitionRecTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('CMU Spin-Off Acquisition').getRecordTypeId();
        Id RealEstateRecTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('CMU Real Estate').getRecordTypeId();
        Id RecruitingRecTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Career/Recruiting').getRecordTypeId();
        
        Set<Id> setRecordTypeIds = new Set<Id>{SRARecTypeId, ExecutiveRecTypeId, LicensingRecTypeId, AcquisitionRecTypeId, RealEstateRecTypeId, RecruitingRecTypeId};
        
        for(Opportunity opp: oppList){
            accIds.add(opp.AccountId);
        }
        for(Opportunity opp: [SELECT Id, AccountId, Amount, RecordTypeId, Opportunity_Sub_type__c
                             FROM Opportunity
                             WHERE AccountId IN : accIds
                             AND RecordTypeId IN : setRecordTypeIds]){
                                 
            if(!mapAccAmt.containsKey(opp.AccountId)){
              mapAccAmt.put(opp.AccountId, 0);
            }                    
            if(opp.RecordTypeId == SRARecTypeId 
            && (opp.Opportunity_Sub_type__c!=null && opp.Amount != null &&
                  (opp.Opportunity_Sub_type__c == 'Master - Funded' || opp.Opportunity_Sub_type__c == 'Standard'))){
              Decimal sum = mapAccAmt.get(opp.AccountId) + opp.Amount;
                mapAccAmt.put(opp.AccountId,sum);
            }else if(opp.RecordTypeId == ExecutiveRecTypeId && opp.Amount != null){
              Decimal sum = mapAccAmt.get(opp.AccountId) + opp.Amount;
                mapAccAmt.put(opp.AccountId,sum);    
            }else if(opp.RecordTypeId == LicensingRecTypeId && opp.Amount != null){
              Decimal sum = mapAccAmt.get(opp.AccountId) + opp.Amount;
                mapAccAmt.put(opp.AccountId,sum);    
            }else if(opp.RecordTypeId == AcquisitionRecTypeId && opp.Amount != null){
              Decimal sum = mapAccAmt.get(opp.AccountId) + opp.Amount;
                mapAccAmt.put(opp.AccountId,sum);    
            }else if(opp.RecordTypeId == RealEstateRecTypeId && opp.Amount != null){
              Decimal sum = mapAccAmt.get(opp.AccountId) + opp.Amount;
                mapAccAmt.put(opp.AccountId,sum);    
            }else if(opp.RecordTypeId == RecruitingRecTypeId && opp.Amount != null
                     && opp.Opportunity_Sub_type__c!=null && opp.Opportunity_Sub_type__c == 'Fee based'){
              Decimal sum = mapAccAmt.get(opp.AccountId) + opp.Amount;
                mapAccAmt.put(opp.AccountId,sum);    
            }                           
        }
        
        List<Account> accToUpdate = new List<Account>();
        for(Account acc:[SELECT Id, Total_Non_Gift_Revenue__c
                         FROM Account
                         WHERE Id IN : mapAccAmt.keyset()]){
          acc.Total_Non_Gift_Revenue__c =  mapAccAmt.get(acc.Id);  
            accToUpdate.add(acc);               
        }
        update accToUpdate;
    }
    
}