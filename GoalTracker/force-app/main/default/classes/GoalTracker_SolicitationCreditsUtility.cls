public class GoalTracker_SolicitationCreditsUtility {

public static Set<Id> users = new Set<Id>();
public static set<Id> contacts = new Set<Id>();
public static Set<String> fiscalYears = new Set<String>();
public static List<Contact> conUsers = new List<Contact>();
public static List<User> userCons = new List<User>();
public static List<Goal_Tracker__c> goals = new List<Goal_Tracker__c>();
public static List<AQB__Solicitation_Credit__c> scList = new List<AQB__Solicitation_Credit__c>();
public static String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;

    
    @InvocableMethod
    public static void doWhat(List<AQB__Solicitation_Credit__c> credits){
        
        for(AQB__Solicitation_Credit__c sc : credits){
            if(sc.Gift_Date_Fiscal__c != NULL){
                fiscalYears.add(sc.Gift_Date_Fiscal__c);    
            }
            if(sc.Goal_Fiscal__c != NULL){
                fiscalYears.add(sc.Goal_Fiscal__c);    
            }
            
            if (sc.AQB__User__c != NULL){
            	users.add(sc.AQB__User__c);    
            }
            
            if (sc.AQB__Contact__c != NULL) {
                contacts.add(sc.AQB__Contact__c);
                users.add(sc.AQB__Contact__r.PM_User_Record__c);
            }     
        }
        fiscalYears.remove(null);
        users.remove(null);
        contacts.remove(null);
        
        
        
        
           System.debug('fiscalYears has: ' + fiscalYears);
           System.debug('users has: ' + users);
           System.debug('contacts has: ' + contacts);
 
        
         //get the contacts and contact ids for these Users, add to all contacts
        if ( !users.isEmpty() ) {
            System.debug('made it past the IF, going to query anyway, users has: ' + users);
            
        conUsers = [SELECT Id, PM_User_Record__c  FROM Contact WHERE PM_User_Record__c IN : users];  
        }
          System.debug('Contacts found: ' + conUsers);
        
        for(Contact c : conUsers){
            if (! contacts.contains(c.Id)){
                contacts.add(c.Id);
            }
        }
          System.debug('contacts list after the conUsers have been added: ' + contacts);
        
        goals = [SELECT Id, Fiscal_Year__c, Prospect_Manager__c,
                Solicitation_Credits_Count_Team_Leader__c, Solicitation_Credits_Total_Team_Leader__c, Solicitation_Credits_Team_Leader__c,
                Solicitation_Credits_Count_Team_Member__c, Solicitation_Credits_Total_Team_Member__c, Solicitation_Credits_Team_Member__c
                FROM Goal_tracker__c
                WHERE Fiscal_Year__c IN : FiscalYears
                AND (Prospect_Manager__c IN : users)];
                     System.debug('goals has: ' + goals);
        
        
        scList = [SELECT Id, Gift_Date_Fiscal__c, AQB__User__c, AQB__Contact__c, AQB__CreditAmount__c, AQB__Contact__r.PM_User_Record__c,
                  Opportunity_Team_Role__c, AQB__GiftPledge__c, AQB__GiftPledge__r.Name, Gift_Link__c
                  FROM AQB__Solicitation_Credit__c
                  WHERE Gift_Date_Fiscal__c IN : fiscalYears
                  AND (Opportunity_Team_Role__c = 'Team Leader' OR Opportunity_Team_Role__c = 'Team Member')
                  //AND AQB__GiftPledge__r.AQB__CreditedOpportunity__c = NULL
                  AND (AQB__User__r.Id IN :users OR AQB__Contact__r.Id IN :contacts)];        
						System.debug('scList has: ' + scList.size() +' elements');                
        				System.debug('scList has these: ' + scList);

        

        
        for (Id u : users) {
        Map<String, Goal_Tracker__c> goalsByFiscalMap = new Map<String, Goal_Tracker__c>();
            
            for(Goal_Tracker__c gt : goals) {
                if (u == gt.Prospect_Manager__c) {
                       System.debug('These IDS should MATCH -- user u is: ' + u + ' gt.prospect_manager__c is: '+ gt.Prospect_Manager__c);
                    gt.Solicitation_Credits_Count_Team_Leader__c = 0;
                    gt.Solicitation_Credits_Total_Team_Leader__c = 0.00;
                    gt.Solicitation_Credits_Team_Leader__c = '';
                    gt.Solicitation_Credits_Count_Team_Member__c = 0; 
                    gt.Solicitation_Credits_Total_Team_Member__c = 0.00; 
                    gt.Solicitation_Credits_Team_Member__c = '';
                    goalsByFiscalMap.put(gt.Fiscal_Year__c, gt);        
                }
            } 

            for(AQB__Solicitation_Credit__c sc : scList) {
                if (u == sc.AQB__User__c  || u == sc.AQB__Contact__r.PM_User_Record__c){
                    System.debug('found a matching solic credit: ' + sc.AQB__GiftPledge__r.Name);
                    System.debug('match on User: ' + sc.AQB__User__c);
                    System.debug('match on Contact: ' + sc.AQB__Contact__c);
                    
                    
                    if(goalsByFiscalMap.keyset().contains(sc.Gift_Date_Fiscal__c))	{				
                        Goal_Tracker__c creditGoal = goalsByFiscalMap.get(sc.Gift_Date_Fiscal__c);
                        
                        if(sc.Opportunity_Team_Role__c == 'Team Leader'){
                            creditGoal.Solicitation_Credits_Count_Team_Leader__c = creditGoal.Solicitation_Credits_Count_Team_Leader__c + 1;
                            creditGoal.Solicitation_Credits_Total_Team_Leader__c = creditGoal.Solicitation_Credits_Total_Team_Leader__c + sc.AQB__CreditAmount__c;
                            creditGoal.Solicitation_Credits_Team_Leader__c = creditGoal.Solicitation_Credits_Team_Leader__c + sc.Gift_Link__c + '<br>';
                            creditGoal.Last_Goals_Update__c = System.Now();
                        }
                               
                        if(sc.Opportunity_Team_Role__c == 'Team Member'){
                            creditGoal.Solicitation_Credits_Count_Team_Member__c = creditGoal.Solicitation_Credits_Count_Team_Member__c + 1;
                            creditGoal.Solicitation_Credits_Total_Team_Member__c = creditGoal.Solicitation_Credits_Total_Team_Member__c + sc.AQB__CreditAmount__c;
                            creditGoal.Solicitation_Credits_Team_Member__c = creditGoal.Solicitation_Credits_Team_Member__c + sc.Gift_Link__c + '<br>';
                            creditGoal.Last_Goals_Update__c = System.Now();
                        }
                    } 

                    
                }
            }
        }
         for (Goal_Tracker__c g : goals){
        	if (g.Solicitation_Credits_Count_Team_Leader__c > 20) {
            	g.Solicitation_Credits_Team_Leader__c = 'See Report';            
            }
            if (g.Solicitation_Credits_Count_Team_Member__c > 20) {
            	g.Solicitation_Credits_Team_Member__c = 'See Report';            
            }    
        }
        update goals;
    }
    
    
    
    


    
    
    
    
    
    //call this method in the SOLICITATION CREDITS MASTER TRIGGER
    //before Insert to sync the User and COntact fields on the Solic Credit
    
    public static void syncUserContact (List<AQB__Solicitation_Credit__c> credits){
    List<Id> searchByUser = new list<Id>();
    Map<Id, Id> userToContactMap = new Map<Id, Id>();
    
        System.debug('credits has: ' + credits);
        
        for (AQB__Solicitation_Credit__c sc : credits){
            if (sc.AQB__User__c != NULL  && sc.AQB__Contact__c == NULL){
                searchByUser.add(sc.AQB__User__c);
                  System.debug('searchByUser has: ' + searchByUser);
            }
        }
        
        List<Contact> contactsReturned = [SELECT Id, PM_User_Record__c FROM Contact WHERE PM_User_Record__c IN : searchByUser];
          System.debug('contactsReturned has: ' + contactsReturned);
        
        for (Contact c : contactsReturned) {
             userToContactMap.put(c.PM_User_Record__c, c.Id);
        }
        
        
        for(AQB__Solicitation_Credit__c sc : credits){
            if (sc.AQB__User__c != NULL  && sc.AQB__Contact__c == NULL){
                sc.AQB__Contact__c = userToContactMap.get(sc.AQB__User__c); 
                 System.debug('Had User, No Contact...Contact is now = ' + sc.AQB__Contact__c);
            }
            if (sc.AQB__User__c == NULL  && sc.AQB__Contact__c != NULL){
                sc.AQB__User__c = sc.AQB__Contact__r.PM_User_Record__c;
                  System.debug('Had Contact, No User...User is now = ' + sc.AQB__User__c);
            }           
        }         
    }

    
}