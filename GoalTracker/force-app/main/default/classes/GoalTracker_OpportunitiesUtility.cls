public class GoalTracker_OpportunitiesUtility {

public static Set<Id> users = new Set<ID>();
public static Set<String> fiscalYears = new Set<String>();
public static List<Goal_Tracker__c> goals = new List<Goal_Tracker__c>(); 
public static String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;
public static Set<Opportunity> oppSet = new Set<Opportunity>();

    
    @InvocableMethod
    public static void doWhat(List<Opportunity> opps){  
    oppSet.addAll(opps); 

    List<OpportunityTeamMember> getAllTeammates = [SELECT Id, OpportunityId, UserId, TeamMemberRole, Close_Fiscal_Year__c, User.isActive
                                                   FROM OpportunityTeamMember
                                                   WHERE Opportunity.Id IN : oppSet
                                                   AND User.isActive = TRUE
                                                   AND (TeamMemberRole = 'Team Member'
                                                   OR TeamMemberRole = 'Planned Gift Advisor')];

       
          // make a set of fiscal years and a set of users to query with
        for(Opportunity opp : opps){
            users.add(opp.OwnerId);
            if(opp.Ask_Date_Fiscal__c != NULL){
            	fiscalYears.add(opp.Ask_Date_Fiscal__c);
            }
            if(opp.Close_Date_Fiscal__c != NULL){   
                fiscalYears.add(opp.Close_Date_Fiscal__c);
            }   
            if(opp.Goal_Fiscal__c != NULL){    
            	fiscalYears.add(opp.Goal_Fiscal__c);
            }
        } 
        for(OpportunityTeamMember teamMem : getAllTeammates){
            users.add(teamMem.UserId);
        }
          System.debug('set of users has: ' + users);
          System.debug('set of fiscals has: ' + fiscalYears);         
        
        
          // query for a list of goalTrackers associated with the list of user above for the fiscals above
        goals = [SELECT Id, Prospect_Manager__c, Fiscal_Year__c, Last_Goals_Update__c,
                 Submitted_Count__c, Submitted_Total_Asks__c, Submitted_Opportunities__c, 
                 Accepted_Count__c, Accepted_Opportunities__c, Revenue_To_Date_PM__c, Revenue_To_Date_Non_PM__c     
                 FROM Goal_Tracker__c 
                 WHERE Prospect_Manager__c IN : users
                 AND Fiscal_Year__c IN : fiscalYears];
          System.debug('results set of goals has: ' + goals);    
        
          // query for the all users' Opportunities...
        List<Opportunity> oppQuery = [SELECT Id, OwnerId, StageName, RecordType.Name, 
                                      Ask_Date__c, Ask_Date_Fiscal__c, CloseDate, Close_Date_Fiscal__c,
                                      Submitted_Opp_Name_Link__c, Accepted_Opp_Name_Link__c, Name, Amount, Ask_Amount__c 
                                      FROM Opportunity
                                      WHERE (Ask_Date_Fiscal__c IN : fiscalYears OR Close_Date_Fiscal__c IN : fiscalYears)
                                      AND (StageName = 'Solicitation'
                                         OR StageName = 'Advisory'
                                         OR StageName = 'Proposal Outstanding'
                                         OR StageName = 'Negotiation/Review'
                                         OR StageName = 'Accepted'
                                         OR StageName = 'Declined')
                                     // AND (RecordType.Name = 'Major Gift'
                                      //   OR RecordType.Name = 'Estate Gift'
                                      //   OR RecordType.Name = 'Life Income Gift')                  
									  AND OwnerId IN : users];
                                           					        
          System.debug('oppQuery query had: ' + oppQuery.size() + ' Elements');  
          System.debug('oppQuery had the following recs: ' + oppQuery);
        
        
        
          // query for the all users' Opportunity Team Member records...
		List<OpportunityTeamMember> otmQuery = [SELECT Id, OpportunityId, UserId, TeamMemberRole, Close_Fiscal_Year__c, 
                                                  Opportunity.Amount, Opportunity.StageName, Opportunity.Name, Opportunity.Submitted_Opp_Name_Link__c, Opportunity.Accepted_Opp_Name_Link__c 
                                                FROM OpportunityTeamMember
                                                WHERE Opportunity.StageName = 'Accepted'
                                                AND Close_Fiscal_Year__c = : fiscalYears
                                                AND (TeamMemberRole = 'Team Member'
                                                    OR TeamMemberRole = 'Planned Gift Advisor')
                                                AND UserId IN : users];

          System.debug('otmQuery query had: ' + otmQuery.size() + ' Elements');  
          System.debug('otmQuery had the following recs: ' + otmQuery);        
        
        
        
        
          //loop through the users and their opps and place them in the correct maps for submitted and/or accepted opps...
          //also place the OpportunityTeamMembers into the map
        for (Id u : users) {
        Map<String, Goal_Tracker__c> goalsByFiscalMap = new Map<String, Goal_Tracker__c>();
            
            for(Goal_Tracker__c gt : goals) {
                if (u == gt.Prospect_Manager__c) {
                    gt.Submitted_Count__c = 0;
                    gt.Submitted_Total_Asks__c = 0.00;
                    gt.Submitted_Opportunities__c = '';
                    gt.Accepted_Count__c = 0; 
                    gt.Accepted_Opportunities__c = ''; 
                    gt.Revenue_To_Date_PM__c = 0.00;
                    gt.Revenue_To_Date_Non_PM__c = 0.00;
                    goalsByFiscalMap.put(gt.Fiscal_Year__c, gt);        
                }
            } 
            
            
            for (Opportunity opp : oppQuery){
                if (u == opp.OwnerId){
                    
                    
                    
                    if(goalsByFiscalMap.containsKey(opp.Ask_Date_Fiscal__c)){
                        Goal_Tracker__c subGoal = goalsByFiscalMap.get(opp.Ask_Date_Fiscal__c); 
                        Decimal aa = opp.Ask_Amount__c;
                            if(aa == NULL){
                                aa = 0.00;
                            }
                        subGoal.Submitted_Total_Asks__c = subGoal.Submitted_Total_Asks__c + aa;
                        subGoal.Submitted_Count__c = subGoal.Submitted_Count__c + 1;
                        subGoal.Submitted_Opportunities__c = subGoal.Submitted_Opportunities__c + opp.Submitted_Opp_Name_Link__c + '<br>';
                        subGoal.Last_Goals_Update__c = System.Now(); 
                    }
                    
                    
                    
                    if(opp.StageName == 'Accepted'){
                        if(goalsByFiscalMap.containsKey(opp.Close_Date_Fiscal__c)){
                            Goal_Tracker__c accGoal = goalsByFiscalMap.get(opp.Close_Date_Fiscal__c); 
                            accGoal.Accepted_Count__c = accGoal.Accepted_Count__c + 1;
                            accGoal.Revenue_To_Date_PM__c = accGoal.Revenue_To_Date_PM__c + opp.Amount;
                            accGoal.Accepted_Opportunities__c = accGoal.Accepted_Opportunities__c + opp.Accepted_Opp_Name_Link__c + '<br>';
                            accGoal.Last_Goals_Update__c = System.Now();
                        }
                    }   
                }
            }
            
            
            
            for(OpportunityTeamMember otm : otmQuery){
                if(u == otm.UserId){
                    if(goalsByFiscalMap.containsKey(otm.Close_Fiscal_Year__c)){
                        Goal_Tracker__c nonpmGoal = goalsByFiscalMap.get(otm.Close_Fiscal_Year__c); 
                        nonpmGoal.Revenue_To_Date_Non_PM__c = nonpmGoal.Revenue_To_Date_Non_PM__c + otm.Opportunity.Amount;  
                        nonPMGoal.Last_Goals_Update__c = System.Now();
                    }
                }
            }
        }
         for (Goal_Tracker__c g : goals){
        	if (g.Accepted_Count__c > 20) {
            	g.Accepted_Opportunities__c = 'See Report';            
            }
            if (g.Submitted_Count__c > 20) {
            	g.Submitted_Opportunities__c = 'See Report';            
            }    
        }
        
        
        update goals;
    }
}