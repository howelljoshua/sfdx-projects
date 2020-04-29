public class GoalTracker_QualificationsUtility {

public static Set<Id> users = new Set<ID>();
public static Set<String> fiscalYears = new Set<String>();
public static List<Goal_Tracker__c> goals = new List<Goal_Tracker__c>();
public static String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;

    @InvocableMethod
    public static void doWhat(List<Prospect_Rating__c> quals){
          //make a set of Users and a set of Fiscal Yrs to query with
        for(Prospect_Rating__c pr : quals){
            users.add(pr.Qualification_Credit__c); 
            if(pr.Fiscal_Year__c != NULL){
            	fiscalYears.add(pr.Fiscal_Year__c);
            }
            if(pr.Goal_Fiscal__c != NULL){
            	fiscalYears.add(pr.Goal_Fiscal__c);
            }
        }
        
        
        
          System.debug('set of users has: ' + users);
          System.debug('set of fiscalYears has: ' + fiscalYears);        
        
        
          // query for a list of goalTrackers associated with the users and FY's above
        goals = [SELECT Id, Prospect_Manager__c, Fiscal_Year__c, Qualifications_Goal__c,  
                 Qualifications_Count__c, Qualifications__c, Last_Goals_Update__c 
                 FROM Goal_Tracker__c
                 WHERE fiscal_Year__c IN : fiscalYears
                 AND Prospect_Manager__c IN : users];
        
          System.debug('results set of goals has: ' + goals.size() + ' elements'); 
          System.debug('results set of goals has: ' + goals);

          // query for the all users' qualification prospect ratings (active and from all the named FY's)
        List<Prospect_Rating__c> prList = [SELECT Id, Account__c, Qualification_Credit__c, Name, 
                                           Account__r.Account_Name_Link__c, Goal_Link__c, Fiscal_Year__c
                                           FROM Prospect_Rating__c
                                           WHERE RecordType.Name = 'Qualification'
                                           AND Active__c = TRUE
                                           AND Fiscal_Year__c IN : fiscalYears
                                           AND Qualification_Credit__c IN : users
                                           ORDER BY Start_Date__c DESC];
        System.debug('prList query had: ' + prList.size() + ' elements');  
        System.debug('prList query had: ' + prList);

        for (ID u : users){
            Map<String, Goal_Tracker__c> goalsByFiscalMap = new Map<String, Goal_Tracker__c>();
            
            for(Goal_Tracker__c gt : goals) {
                if (u == gt.Prospect_Manager__c) {
                    gt.Qualifications_Count__c = 0;
                    gt.Qualifications__c = '';
                    goalsByFiscalMap.put(gt.Fiscal_Year__c, gt);        
                }
            }
            
            for(Prospect_Rating__c pr : prList){
                if(u == pr.Qualification_Credit__c){
                    if(goalsByFiscalMap.containsKey(pr.Fiscal_Year__c)){    
                        Goal_Tracker__c thisGoal = goalsByFiscalMap.get(pr.Fiscal_Year__c);
                        thisGoal.Qualifications_Count__c = thisGoal.Qualifications_Count__c + 1;
                        thisGoal.Qualifications__c = thisGoal.Qualifications__c + pr.Account__r.Account_Name_Link__c + '<br>';
                        thisGoal.Last_Goals_Update__c = System.Now();
                    }

                }  
            }
        }
        for (Goal_Tracker__c g : goals){
        	if (g.Qualifications_Count__c > 20) {
            	g.Qualifications__c = 'See Report';            
            }    
        }
        update goals;
    }    
}