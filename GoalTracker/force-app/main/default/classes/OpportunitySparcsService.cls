/**
* @author Josh Howell, CMU
* @date 5/27/19
*
* Fires when SPARCS Opporunities are inserted to create a 
* new OpportunityContact and new Proposal for syncing to the SPARCS CM application
* Also generates the Sparcs AG NUMBER from a custom setting
*/

public class OpportunitySparcsService {
        
    
      //invoked Before Insert by the OpportunityTriggerHandler
      //gets the Opp List being inserted (Trigger.New)
      //If the Opportunity is an IP Record Type... 
      //queries the AGNum custom setting which stores the last AGNumber generated, adds 1, 
      //updates the 'Associated_Contract_Number__c' field, sets and saves the customer setting record.   
    public static void createAgNumber(List<Opportunity> opps){
    AGNum__c agNum = [SELECT Id, Name, AGNumber__c FROM AGNum__c WHERE Name = 'LastAGNum' ];
    Integer lastAGNumber = (Integer)agNum.AGNumber__c;
    Map<String,String> stages = new Map<String,String>{
        'Draft' => 'Proposal In Development',
        'Revised Budget Created' => 'Negotiation/Review',
        'Department Review' => 'Negotiation/Review',
        'Specialist Review' => 'Negotiation/Review',
        'Specialist Review: Pending Changes by PI' => 'Negotiation/Review',
        'Pending Sponsor Review' => 'Negotiation/Review',
        'Pending Sponsor Review Award Anticipated' => 'Negotiation/Review',
        'Specialist Review' => 'Negotiation/Review',
        'Department Review: Response Pending from PI' => 'Negotiation/Review',
        'Final SPO Review' => 'Negotiation/Review',
        'SPO Status Confirmation' => 'Negotiation/Review',
        'Award Notification Received' => 'Accepted',
        'Awarded' => 'Accepted',
        'Not Funded' => 'Declined',
        'Not Submitted' => 'Disqualified',
        'Withdrawn From Sponsor' => 'Withdrawn'
    };
        
        for (Opportunity oppty : opps){
            if(oppty.RecordTypeID != Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Major Gift').getRecordTypeId()) {
                if(oppty.RecordTypeID != Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Estate Gift').getRecordTypeId()) { 
                    if(oppty.RecordTypeID != Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Life Income Gift').getRecordTypeId()) {
                        lastAGNumber++;
                        oppty.Associated_Contract_Number__c = 'AG'+ lastAGNumber;   


                        if(oppty.InsertedInMass__c == TRUE  
                          && oppty.Source_System__c == 'SPARCS'
                          && oppty.RecordTypeID == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sponsored Research Agreements').getRecordTypeId()) {
                            oppty.Private__c = FALSE;
                            oppty.OwnerId = '005f4000002wHEBAA2'; //assign to the AISSYS user
                            if(stages.containsKey(oppty.StageName)){
                                oppty.StageName = stages.get(oppty.StageName);
                            }
                            if (oppty.StageName == 'Declined') {
                                oppty.Decline_Reason__c = 'Other'; 
                            }
                        }
                    }
                }   
            }
        }
        agNum.AGNumber__c = lastAGNumber;
        update agNum;
    }





    
    

      //invoked After Insert by OpportunityTriggerHandler
      //Creates an OpportunityContactRole on the Sponsored Research Agreement records
    public static void createOppContacts(List<Opportunity> opps){
    List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
    Set<String>hrisIds = new Set<String>();
        
        for (Opportunity oppty : opps){
            if(oppty.RecordTypeID == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sponsored Research Agreements').getRecordTypeId()) {
                hrisIds.add(oppty.OppContactID__c);
            }
        }
        hrisIds.remove(null);
          
          System.debug('hrisID SET has ' + hrisIDs.size() + ' elements'); 
          System.debug('hrisID set is: ' + hrisIds);
        
        
        
                
        List<AQB__AlternateID__c> altIdList = [SELECT Id, AQB__ContactReferenced__c, AQB__NonuniqueAlternateID__c
                                               FROM AQB__AlternateID__c                                                
                                               WHERE OwnerId = '005f4000000jLLLAA2'
                                               AND AQB__Type__c = 'HRIS ID'
                                               AND AQB__NonuniqueAlternateID__c IN :hrisIds];
                                               
        
          System.debug('altID list found these records in the query: ' + altIdList);

        /*
        List<AQB__AlternateID__c> altIdList = new List<AQB__AlternateID__c>();
        
        
        for (AQB__AlternateID__c altid : altIdQuery){
            if (hrisIDs.contains(altid.AQB__NonuniqueAlternateID__c)) {
                altIdList.add(altid);
            }
        }
        
        */
        
                
            Map<String,Id> altIdMap = new Map<String,Id>();
            
            for(AQB__AlternateID__c alt : altIdList){
                altIdMap.put(alt.AQB__NonuniqueAlternateID__c, alt.AQB__ContactReferenced__c);
            }
              System.debug('altIDMap: ' + altIdMap);
            
            
            for (Opportunity opp : opps ){
                if (opp.oppContactId__c != NULL){                    
                    if (altIdMap.containsKey(opp.oppContactID__c)) {
                        if(altIdMap.get(opp.OppContactID__c) != NULL){
                            OpportunityContactRole ocr = new OpportunityContactRole();
                            ocr.OpportunityId = opp.Id;
                            ocr.ContactID = altIdMap.get(opp.OppContactID__c);
                            ocr.Role = opp.oppContactRole__c;
                            System.debug('ocr being added is: ' + ocr);
                            ocrList.add(ocr);
                        }
                    }
                }
            }
            System.debug('ocrList about to be inserted has: ' + ocrList);   
            Database.upsert(ocrList);
    }
    

    
      //invoked After Insert by the OpportunityTriggerHandler class...
      //creates a proposal with the number given in the insert to correspond to the SpringCM system
    public static void createProposals(List<Opportunity> opps){
    List<Proposal__c> propsList = new List<Proposal__c>();

    
        for (Opportunity opp : opps){
            if(opp.RecordTypeID == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sponsored Research Agreements').getRecordTypeId()) {
                if(opp.SPARCS_Proposal_Number__c != NULL) {
                    if(opp.SPARCS_Proposal_Status__c != NULL){
                        Proposal__c prop = new Proposal__c();
                        prop.Opportunity__c = opp.Id;                     
                        prop.Proposal_Number__c = opp.SPARCS_Proposal_Number__c;
                        prop.Name = opp.SPARCS_Proposal_Name__c;
                        prop.Proposal_Purpose__c = opp.Sponsored_Projects_Purpose__c;
                        prop.Start_Date__c = opp.SPARCS_Proposal_Start_Date__c;
                        prop.End_Date__c = opp.SPARCS_Proposal_End_Date__c;
                        prop.Proposal_Status__c = opp.SPARCS_Proposal_Status__c; 
                        if(prop.Proposal_Status__c == 'Awarded' || prop.Proposal_Status__c == 'Award Notification Received' ){prop.Proposal_Approved__c = TRUE;}                    
                         System.debug('prop being added to list is: '+ prop);
                        propsList.add(prop);
                    }
                }
            }
        }
          System.debug('propsList =' + propsList);
        Database.insert(propsList); 
        
      System.debug('inserted in mass and record type is SRA' );
    }
}