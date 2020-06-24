public class GoalTracker_VisitsUtility {

public static Set<Id> users = new Set<ID>();
public static Set<String> fiscalYears = new Set<String>();
public static Set<Id> theseActReports = new Set<Id>();
public static List<Goal_Tracker__c> goals = new List<Goal_Tracker__c>(); 
public static String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;


    
    @InvocableMethod
    public static void doWhat(List<AQB__ActivityReportParticipant__c> arps){ 
           //make a set of Users and a set of Fiscal Yrs to query with   
        for(AQB__ActivityReportParticipant__c arp : arps){
            if(arp.AQB__User__c != NULL){
            	users.add(arp.AQB__User__c);
            }
            if(arp.Fiscal_Year__c != NULL){
            	fiscalYears.add(arp.Fiscal_Year__c);
            }
            if(arp.Goal_Fiscal__c != NULL){
                fiscalYears.add(arp.Goal_Fiscal__c);
            }
            if(arp.AQB__ActivityReport__c != NULL){
                theseActReports.add(arp.AQB__ActivityReport__c);
            }
        }
          System.debug('set of users has: ' + users);
          System.debug('set of fiscalYears has: ' + fiscalYears);            
        
          // query for a list of goalTrackers associated with the users and FY's above
        goals = [SELECT Id, Prospect_Manager__c, Fiscal_Year__c, Visits_Goal__c,  
                 Visits_Count__c, Visits__c, Last_Goals_Update__c 
                 FROM Goal_Tracker__c
                 WHERE fiscal_Year__c IN : fiscalYears
                 AND Prospect_Manager__c IN : users];
        
          System.debug('results set of goals has: ' + goals.size() + ' elements'); 
          System.debug('results set of goals has: ' + goals);

        
          // query for the all users' Activity Report Participant records
        List<AQB__ActivityReportParticipant__c> arpList = [SELECT Id, AQB__User__c, AQB__UserRole__c, Fiscal_Year__c, AQB__ActivityReport__r.AQB__Date__c, AQB__ActivityReport__c                                            					   
                                                           FROM AQB__ActivityReportParticipant__c
                                                           WHERE AQB__ActivityReport__c IN : theseActReports
                                                           AND Fiscal_Year__c IN : fiscalYears
                                                           AND AQB__User__c IN : users
                                                           AND AQB__ActivityReport__r.AQB__ReportStatus__c = 'Final'
                                                           AND(Fiscal_Year_Num__c < 2020 AND (AQB__ActivityReport__r.AQB__Type__c = 'Visit In' OR AQB__ActivityReport__r.AQB__Type__c = 'Visit Out'))
                                                           AND(Fiscal_Year_Num__c >= 2020 AND (AQB__ActivityReport__r.AQB__Type__c = 'Visit In' OR AQB__ActivityReport__r.AQB__Type__c = 'Visit Out' OR AQB__ActivityReport__r.AQB__Type__c = 'Virtual Visit'))
                                                           AND(AQB__UserRole__c = 'Assigned To' OR AQB__UserRole__c = 'Participant')];

															   
                                           					        
          System.debug('arpList query had: ' + arpList.size() + ' Elements');  
          System.debug('arpList query had the following recs: ' + arpList);
   
        

        for (ID u : users){
            Map<String, Goal_Tracker__c> goalsByFiscalMap = new Map<String, Goal_Tracker__c>();
            
            for(Goal_Tracker__c gt : goals) {
                if (u == gt.Prospect_Manager__c) {
                    gt.Visits_Count__c = 0;
                    goalsByFiscalMap.put(gt.Fiscal_Year__c, gt);        
                }
            }
            
            for(AQB__ActivityReportParticipant__c arp : arpList){
                if(u == arp.AQB__User__c){
                    if(goalsByFiscalMap.containsKey(arp.Fiscal_Year__c)){
                        Goal_Tracker__c thisGoal = goalsByFiscalMap.get(arp.Fiscal_Year__c);
                        thisGoal.Visits_Count__c = thisGoal.Visits_Count__c + 1;
                        thisGoal.Last_Goals_Update__c = System.Now();
                    }
                }          
            }
        }
        update goals;
    }  
}