@isTest
public class GoalTracker_Test {
    
    
    public static testMethod void testGoalTrackerInsert() {
    	String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;
        List<User> users = new List<User>();
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'UA Prospect Manager' LIMIT 1];
        List<Account> accounts = new List<Account>();
        List<Contact> cons = new List<Contact>();
        List<Prospect_Rating__c> quals = new List<Prospect_Rating__c>();
        List<Goal_Tracker__c> goals = new List<Goal_Tracker__c>();
        List<AQB__ActivityReport__c> actReports = new List<AQB__ActivityReport__c>();
        List<AQB__ActivityReportParticipant__c> arps = new List<AQB__ActivityReportParticipant__c>();
        List<Event> events = new List<Event>();
        List<Opportunity> opps = new List<Opportunity>();
        List<OpportunityTeamMember> otms = new List<OpportunityTeamMember>();
        List<AQB__OpportunityComponent__c> ocs = new List<AQB__OpportunityComponent__c>();
        DateTime dT = System.now();
        Date todaysDate = date.newinstance(dT.year(), dT.month(), dT.day());


        
        User u = new User();
            u.Alias = 'testuser';
            u.Username = 'test.user@fake.email.com';
            u.Email = 'test.user@fake.email.com';
            u.FirstName = 'first';
            u.LastName = 'last';
            u.LocaleSidKey = 'en_US';
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            u.TimeZoneSidKey = 'America/New_York';
            u.ProfileId = prof.Id;
        users.add(u);
        Insert users;
        
        Goal_Tracker__c gt = new Goal_Tracker__c();
            gt.Prospect_Manager__c = u.Id;
        	gt.Fiscal_Year__c = currentFiscalYear;
        	gt.Qualifications_Goal__c = 50;
         	gt.Visits_Goal__c = 100;
        	gt.Submitted_Goal__c = 20;
        	gt.Accepted_Goal__c = 10;
        	gt.Revenue_Goal_PM__c = 1000000;
        goals.add(gt);
        insert goals;
            
        Account ac = new Account();
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        	ac.Name = 'Account';
        	ac.AQB__AccountStatus__c = 'Active';
        	ac.AQB__AccountType__c = 'Alumni';
        accounts.add(ac);
        insert accounts;
        
        Contact c = new Contact();
        	c.FirstName = 'first';
        	c.LastName = 'last';
        	c.AQB__Type__c = 'Alumni';
        	c.AccountId = ac.Id;
        	c.PM_User_Record__c = u.Id;
        cons.add(c);
        insert cons;
        
        ac.AQB__PrimaryContact__c = c.Id;
        update accounts;
        
        u.PM_Contact_Id__c = c.Id;
        update u;
        

		CheckRecursive.setFirstRun(TRUE);

        Prospect_Rating__c q = new Prospect_Rating__c();
            q.RecordTypeId = Schema.SObjectType.Prospect_Rating__c.getRecordTypeInfosByName().get('Qualification').getRecordTypeId();
            q.Account__c = ac.Id;
            q.Start_Date__c = System.Today();
            q.Qualification_Credit__c = u.Id;
        quals.add(q);
        insert quals;

       


        
        AQB__CampaignFund__c fc = new AQB__CampaignFund__c();
        	fc.RecordTypeId = Schema.SObjectType.AQB__CampaignFund__c.getRecordTypeInfosByName().get('Perennial').getRecordTypeId();
        	fc.Name = 'fake fr camp';
        Insert fc;
		system.debug('fundraising campaign inserted: ' + [SELECT Id, name FROM AQB__CampaignFund__c WHERE Name = 'fake fr camp']);
                

        Campaign camp = new Campaign();
        	camp.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Contact Campaign Appeal').getRecordTypeId();
        	camp.Name ='fake campaign';
        	camp.AQB__CampaignFund__c = fc.Id;
        Insert camp;
        system.debug('campaign inserted: ' + [SELECT Id, name FROM Campaign WHERE Name = 'fake campaign']);	

        
        Opportunity o1= new Opportunity();
            o1.AccountId = ac.Id;
        	o1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Major Gift').getRecordTypeId();
            o1.OwnerId =  u.Id;
            o1.StageName = 'Discovery';
        	o1.Ask_Date__c = todaysDate;
            o1.CloseDate = todaysDate + 30;
            o1.Name = 'Opp';
        	o1.Private__c = False;
        	o1.CampaignId = camp.Id;
        	o1.Amount = 2000000;
        opps.add(o1);
        
        Opportunity o2 = new Opportunity();
            o2.AccountId = ac.Id;
            o2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Major Gift').getRecordTypeId();
            o2.OwnerId =  System.UserInfo.getUserId();
            o2.StageName = 'Discovery';
        	o2.Ask_Date__c = todaysDate + 10;
            o2.CloseDate = todaysDate + 30;
            o2.Name = 'Opp';
        	o2.Private__c = False;
        	o2.CampaignId = camp.Id;
        	o2.Amount = 1000000;
        opps.add(o2);
		
        
        OpportunityTriggerHandler.disable = TRUE;
        
        insert opps;

        system.debug('OPPORTUNITIES JUST INSERTED BY THE TEST CLASS: ' + [SELECT Id, Name, StageName FROM Opportunity WHERE StageName = 'Discovery']);
        
        
        OpportunityTeamMember o1tm1 = new OpportunityTeamMember();
        	o1tm1.TeamMemberRole = 'Team Member';
        	o1tm1.UserId = u.Id;
        	o1tm1.OpportunityId = o1.Id;
        	otms.add(o1tm1);

        OpportunityTeamMember o1tm2 = new OpportunityTeamMember();
        	o1tm2.TeamMemberRole = 'Team Member';
        	o1tm2.UserId = System.UserInfo.getUserId();
        	o1tm2.OpportunityId = o1.Id;
        	otms.add(o1tm2);      
        
        OpportunityTeamMember o2tm1 = new OpportunityTeamMember();
        	o2tm1.TeamMemberRole = 'Team Member';
        	o2tm1.UserId = u.Id;
        	o2tm1.OpportunityId = o2.Id;
        	otms.add(o2tm1);

        OpportunityTeamMember o2tm2 = new OpportunityTeamMember();
        	o2tm2.TeamMemberRole = 'Team Member';
        	o2tm2.UserId = System.UserInfo.getUserId();
        	o2tm2.OpportunityId = o2.Id;
        	otms.add(o2tm2);
        
        
        insert otms;           
        
        

        AQB__ActivityReport__c ar1 = new AQB__ActivityReport__c();
        	ar1.AQB__Opportunity__c = o1.Id;	
        	ar1.OwnerId = u.Id;
        	ar1.AQB__Date__c = todaysDate - 5;
        	ar1.AQB__ActivityDate__c = todaysDate - 5;
        	ar1.AQB__ActivityDateTime__c = System.DateTime.Now() - 5;
            ar1.AQB__Date__c = todaysDate; 
            ar1.AQB__ReportStatus__c = 'Final';
        	ar1.AQB__Type__c = 'Visit In';
            ar1.AQB__Purpose__c = 'Cultivate a Prospect';
            ar1.AQB__Result__c = 'Cultivate a Prospect';
            ar1.AQB__Account__c = ac.Id;
        actReports.add(ar1);
        
        
        AQB__ActivityReport__c ar2 = new AQB__ActivityReport__c();
        	ar2.AQB__Opportunity__c = o2.Id;		
        	ar2.OwnerId = u.Id;         	
        	ar2.AQB__Date__c = todaysDate - 5;
        	ar2.AQB__ActivityDate__c = todaysDate - 5;
        	ar2.AQB__ActivityDateTime__c = System.DateTime.Now() - 5;
            ar2.AQB__ReportStatus__c = 'Final';
        	ar2.AQB__Type__c = 'Visit In';
            ar2.AQB__Purpose__c = 'Cultivate a Prospect';
            ar2.AQB__Result__c = 'Cultivate a Prospect';
            ar2.AQB__Account__c = ac.Id;
        actReports.add(ar2);

        insert actReports;
        
        AQB__ActivityReportParticipant__c arp1 = new AQB__ActivityReportParticipant__c();
            arp1.AQB__User__c = u.Id;
            arp1.AQB__UserRole__c = 'Assigned To';
            arp1.AQB__ActivityReport__c = ar1.Id;
        arps.add(arp1);
        
       AQB__ActivityReportParticipant__c arp2 = new AQB__ActivityReportParticipant__c();
            arp2.AQB__User__c = System.UserInfo.getUserId();
            arp2.AQB__UserRole__c = 'Participant';
            arp2.AQB__ActivityReport__c = ar1.Id;
        arps.add(arp2);
        
        AQB__ActivityReportParticipant__c arp3 = new AQB__ActivityReportParticipant__c();
            arp3.AQB__User__c = System.UserInfo.getUserId();
            arp3.AQB__UserRole__c = 'Assigned To';
            arp3.AQB__ActivityReport__c = ar2.Id;
        arps.add(arp3);
        
        AQB__ActivityReportParticipant__c arp4 = new AQB__ActivityReportParticipant__c();
            arp4.AQB__User__c = u.Id;
            arp4.AQB__UserRole__c = 'Participant';
            arp4.AQB__ActivityReport__c = ar2.Id;
        arps.add(arp4);
        insert arps;
        System.debug('ARPS JUST INSERTED BY TEST CLASS: ' + [SELECT Id, AQB__User__c, AQB__UserRole__c FROM AQB__ActivityReportParticipant__c]); 
        

		AQB__OpportunityComponent__c oc1 = new AQB__OpportunityComponent__c();
			oc1.AQB__Opportunity__c = o1.Id;
        	oc1.Department__c = 'Art';
        	oc1.School__c = 'College of Fine Arts';
        	oc1.Account_Type__c = 'Endowment';
        	oc1.Account_Sub_type__c = 'Facilities';
        	oc1.AQB__Amount__c = 2000000;
        ocs.add(oc1);

		AQB__OpportunityComponent__c oc2 = new AQB__OpportunityComponent__c();
			oc2.AQB__Opportunity__c = o2.Id;
        	oc2.Department__c = 'Art';
        	oc2.School__c = 'College of Fine Arts';
        	oc2.Account_Type__c = 'Endowment';
        	oc2.Account_Sub_type__c = 'Facilities';
        	oc2.AQB__Amount__c = 1000000;
        ocs.add(oc2);
        
        insert ocs;
		     

		   //CheckRecursive.setFirstRun(TRUE);
        o1.Ask_Date__c = todaysDate;
        o1.Ask_Amount__c = 2000000;
        o1.Amount = 2000000;
        o1.Anticipated_Amount__c = 2000000;
        o1.CloseDate = todaysDate+10;
        OpportunityTriggerHandler.disable = TRUE;
        update o1;
        

        System.debug('opportunity updated');
        System.debug('Opp Owner: ' + o1.OwnerId);
        System.debug('ask date: ' + o1.Ask_Date__c);        
        System.debug('ask amount: ' + o1.Ask_Amount__c);
        System.debug('amount: ' + o1.Amount);
        System.debug('anticipated amount: ' + o1.Anticipated_Amount__c);
        System.debug('close date: ' + o1.CloseDate);
        System.debug('Opp Component Opps Name: ' + oc1.AQB__Opportunity__r.Name);
        System.debug('Opp Component School: ' + oc1.School__c);
        System.debug('Opp Component Acct type: ' + oc1.Account_Type__c);
        System.debug('Opp Component Acct sub type: ' + oc1.Account_Sub_type__c);
        System.debug('Activity Report Opps Name: ' + ar1.AQB__Opportunity__c);
        System.debug('Activity Report Owner: ' + ar1.OwnerId);
        

        
		Test.startTest();
            o1.StageName = 'Solicitation';
            OpportunityTriggerHandler.disable = TRUE;
            update opps;
    
            system.debug('OPPORTUNITIES JUST UPDATED BY THE TEST CLASS: ' + [SELECT Id, Name, StageName FROM Opportunity]);
            
            o2.Ask_Date__c = todaysDate-10;
            o2.CloseDate = todaysDate;
            update opps;
    
            CheckRecursive.setFirstRun(TRUE);
            o1.StageName = 'Accepted';
            update opps;
	

            CheckRecursive.setFirstRun(TRUE);
            gt.Accepted_Goal__c = gt.Accepted_Goal__c + 1;
            update gt;
            DELETE ar1;
       
        
       
        
       
        AQB__LLChartofAccounts__c coa = new AQB__LLChartofAccounts__c();
        	coa.Name = 'LibraryTime';
        insert coa;
        
        
        AQB__Acknowledgement__c ack = new AQB__Acknowledgement__c();
        	ack.Name = 'AckThis';
        insert ack;      
 
        
        
        AQB__Gift__c gift = new AQB__Gift__c();
        	gift.RecordTypeId = Schema.SObjectType.AQB__Gift__c.getRecordTypeInfosByName().get('Gift').getRecordTypeId();
        	gift.AQB__Date__c = todaysDate;
        	gift.AQB__Account__c = ac.Id; 
        	gift.AQB__CreditedOpportunity__c = o2.Id;
        insert gift;
        
 
        
        AQB__Transaction__c trans = new AQB__Transaction__c();
            trans.AQB__Account__c = ac.Id;	
            trans.AQB__Gift__c = gift.Id;
        	trans.AQB__Amount__c = 100000;
        	trans.AQB__Method__c = 'Check';
        	trans.AQB__CampaignAppeal__c = camp.Id;
        	trans.AQB__ChartofAccounts__c = coa.Id;
        	trans.AQB__Acknowledgement__c = ack.Id;
        insert trans;
        
        
        AQB__Solicitation_Credit__c sc1 = new AQB__Solicitation_Credit__c();
        	sc1.AQB__GiftPledge__c = gift.Id;
        	sc1.AQB__PercentCredit__c = 100;
        	sc1.AQB__User__c = u.Id;
        	sc1.Opportunity_Team_Role__c = 'Team Leader';
            //sc1.Goal_Fiscal__c = gt.Fiscal_Year__c;
        insert sc1;
        
        
        
        AQB__Solicitation_Credit__c sc2 = new AQB__Solicitation_Credit__c();
        	sc2.AQB__GiftPledge__c = gift.Id;
        	sc2.AQB__PercentCredit__c = 100;
        	sc2.AQB__Contact__c = c.Id;
        	sc2.Opportunity_Team_Role__c = 'Team Member';
            //sc2.Goal_Fiscal__c = gt.Fiscal_Year__c;
        insert sc2;
        
        delete sc1;

        
       Test.stopTest();  
        
    }
    
}