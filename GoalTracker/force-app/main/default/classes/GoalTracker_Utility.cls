public class GoalTracker_Utility {

public static List<Prospect_Rating__c> quals = new List<Prospect_Rating__c>(); 
public static List<AQB__ActivityReportParticipant__c> arps = new List<AQB__ActivityReportParticipant__c>();
public static List<Opportunity> opps = new List<Opportunity>();
public static List<AQB__Solicitation_Credit__c> credits = new List<AQB__Solicitation_Credit__c>();

    
    public static void doWhat(List<Goal_Tracker__c> gts){
        
        
        for(Goal_Tracker__c gt : gts) {
            
            Integer fiscalInt = integer.valueOf(gt.Fiscal_Year__c);
            
            Account ac = new Account();
            	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
            	ac.Name = 'Account';
            	ac.AQB__AccountStatus__c = 'Active';
            	ac.AQB__AccountType__c = 'Alumni';
           
            Prospect_Rating__c q = new Prospect_Rating__c();
                q.RecordTypeId = Schema.SObjectType.Prospect_Rating__c.getRecordTypeInfosByName().get('Qualification').getRecordTypeId();
            	q.Account__c = ac.Id;
            	q.Start_Date__c = date.newinstance(fiscalInt-1, 7, 1);
                q.Qualification_Credit__c = gt.Prospect_Manager__c;
                q.goal_fiscal__c = gt.Fiscal_Year__c;
            quals.add(q);
            
            
            Opportunity o = new Opportunity();
                o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Major Gift').getRecordTypeId();
                o.OwnerId =  gt.Prospect_Manager__c;
                o.StageName = 'Accepted';
                o.CloseDate = date.newinstance(fiscalInt-1, 7, 1);
            	o.Ask_Date__c = date.newinstance(fiscalInt-1, 7, 1);
                o.Name = 'Opp';
                o.AccountId = ac.Id;
            	o.goal_fiscal__c = gt.Fiscal_Year__c;
            opps.add(o);
            
            
			AQB__ActivityReport__c ar = new AQB__ActivityReport__c();
            	ar.OwnerId = gt.Prospect_Manager__c;
            	ar.AQB__Date__c = date.newinstance(fiscalInt-1, 7, 1);
            	ar.AQB__ReportStatus__c = 'Final';
            	ar.AQB__Purpose__c = 'Closing a Prospect';
            	ar.AQB__Result__c = 'Closing a Prospect';
            	ar.AQB__Opportunity__c = o.Id;
                ar.AQB__Account__c = ac.Id;
               
            AQB__ActivityReportParticipant__c arp = new AQB__ActivityReportParticipant__c();
                arp.AQB__User__c = gt.Prospect_Manager__c;
            	arp.AQB__UserRole__c = 'Assigned To';
            	arp.goal_fiscal__c = gt.Fiscal_Year__c;
            	arp.AQB__ActivityReport__c = ar.Id;
            arps.add(arp);  
            
            
            
            
            AQB__Gift__c gift = new AQB__Gift__c();
                gift.AQB__Account__c = ac.Id;
            	gift.AQB__Date__c = date.newinstance(fiscalInt-1, 7, 1);   	
            	
            AQB__Solicitation_Credit__c sc = new AQB__Solicitation_Credit__c();
            	sc.AQB__User__c = gt.Prospect_Manager__c;
            	sc.AQB__GiftPledge__c = gift.Id;
            	sc.AQB__PercentCredit__c = 100;
            	sc.Opportunity_Team_Role__c = 'Team Leader';
            	sc.Goal_Fiscal__c = gt.Fiscal_Year__c;
            	
            credits.add(sc);	  
        }
        
        
        GoalTracker_QualificationsUtility.doWhat(quals);
        GoalTracker_VisitsUtility.doWhat(arps);
        GoalTracker_OpportunitiesUtility.doWhat(opps); 
        GoalTracker_SolicitationCreditsUtility.doWhat(credits);
    }
    
}