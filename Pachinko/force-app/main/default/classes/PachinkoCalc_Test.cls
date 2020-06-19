/*
 * PachinkoCalc_Test  Author - Josh Howell, CMU
 * Single Test Class for PachinkoCalc class
 * Test PachinkoCalc at 94%
 * 
 * 
 */



@isTest

global class PachinkoCalc_Test {
 
    global static testmethod void testPachinko(){
        List<Account> accountList = new List<Account>();  
        List<Contact> contactList = new List<Contact>();
        List<AQB__Interest__c> interests = new List<AQB__Interest__c>();
        List<AQB__LLInterestType__c> llInterestTypes = new List<AQB__LLInterestType__c>(); 
        List<AQB__LLChartofAccounts__c> coaList = new List<AQB__LLChartofAccounts__c>();
        List<AQB__Transaction__c> transList = new List<AQB__Transaction__c>();
        List<AQB__CampaignFund__c> fcList = new List<AQB__CampaignFund__c> ();
        List<Campaign> campList = new List<Campaign>();
        List<AQB__Gift__c> giftList = new List<AQB__Gift__c>();
        List<AQB__Education__c> eduList = new List<AQB__Education__c>();
        List<Parent_Affiliation__c> pAffilList = new List<Parent_Affiliation__c>();
        List<Pachinko__c> pachinkoList = new List<Pachinko__c>();        
        
          //add some new sample Pachinko Rules to the Custom Setting object
        Pachinko__c pach1 = new Pachinko__c();
        pach1.Name = 'PACHINKO1';
        pach1.Rule__c = 'Interest - Swartz Center';
        pach1.General_Category__c = 'Strategic Initiative';
        pach1.Specific_Category__c = 'Swartz Center';
        pachinkoList.add(pach1);
        
        Pachinko__c pach2 = new Pachinko__c();
        pach2.Name = 'PACHINKO2';
        pach2.Rule__c = 'Interest - Library';
        pach2.General_Category__c = 'University Priorities';
        pach2.Specific_Category__c = 'Library';
        pachinkoList.add(pach2); 
        
        Pachinko__c pach3 = new Pachinko__c();
        pach3.Name = 'PACHINKO3';
        pach3.Rule__c = 'MSCF';
        pach3.General_Category__c = 'MSCF';
        pach3.Specific_Category__c = 'MSCF';
        pachinkoList.add(pach3);         
        
        insert pachinkoList;
        
        

          //add a few new Interest Types to LL-InterestType
        AQB__LLInterestType__c it1 = new AQB__LLInterestType__c();
        it1.Name = 'Swartz Center';
        llInterestTypes.add(it1);
        
        AQB__LLInterestType__c it2 = new AQB__LLInterestType__c();
        it2.Name = 'Library'; 
        llInterestTypes.add(it2);
        
        AQB__LLInterestType__c it3 = new AQB__LLInterestType__c();
        it3.Name = 'MSCF'; 
        llInterestTypes.add(it3);        
        
        insert llInterestTypes;


        
          //add a sample Fundraising Campaign
        AQB__CampaignFund__c campFund = new AQB__CampaignFund__c();
        campfund.Name = 'camp fund';
        campfund.AQB__StartDate__c = Date.Today() - 90;
        campfund.AQB__EndDate__c = Date.Today() + 90;
        fcList.add(campFund);
        insert fcList;
        
          //add a sample campaign
        Campaign camp = new Campaign();
        camp.Name = 'fake campaign';
        camp.AQB__CampaignFund__c = campFund.Id;
        camp.Status = 'planned';
        camp.StartDate = Date.Today();
        camp.Drop_Date__c = Date.Today() + 5;
        camp.EndDate = Date.Today() + 60;
        camp.Appeal_Code__c = 'appeal';
        campList.add(camp);
        insert campList;

        
          //add CCAB Account for PGAC
        Account pgac = new Account(Name='President\'s Global Advisory Council');
        pgac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Affiliated Organization').getRecordTypeId();
        Insert pgac;
        
        
        
          //add a few new Chart of Accounts
        AQB__LLChartofAccounts__c coa1 = new AQB__LLChartofAccounts__c();
        coa1.Name = 'Tepper Student Affairs';
        coaList.add(coa1);
        
        AQB__LLChartofAccounts__c coa2 = new AQB__LLChartofAccounts__c();
        coa2.Name = 'Student Affairs';
        coaList.add(coa2);
        
        AQB__LLChartofAccounts__c coa3 = new AQB__LLChartofAccounts__c();
        coa3.Name = 'Academic Development';
        coaList.add(coa3);
        
        AQB__LLChartofAccounts__c coa4 = new AQB__LLChartofAccounts__c();
        coa4.Name = 'MSCF';
        coaList.add(coa4); 
        
        Insert coaList;

        
        
          //add 2 new sample Accounts
        Account a = new Account();
        a.Name = 'Account '+ 1;
        a.AQB__AccountType__c = 'Alumni';
        a.AQB__AccountStatus__c = 'Active';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        a.Run_Pachinko_Assignment__c = TRUE;
        a.Primary_Contact_Alum__c = TRUE;
        a.Secondary_Contact_Alum__c =  TRUE;
        a.Parent_School_Affiliation__c = 'SCS'; 
        a.Contact_Count__c = 1;
        a.Clean_Country__c = 'US';
        accountList.add(a);
        
        Account a2 = new Account();
        a2.Name = 'Account '+ 2;
        a2.AQB__AccountType__c = 'Alumni';
        a2.AQB__AccountStatus__c = 'Active';
        a2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        a2.Run_Pachinko_Assignment__c = TRUE;
        a2.Dual_Affiliate__c = TRUE;
        a2.Contact_Count__c = 1;
        a2.Clean_Country__c = 'US';
        accountList.add(a2);
        
        Account a3 = new Account();
        a3.Name = 'Account '+ 3;
        a3.AQB__AccountType__c = 'Alumni';
        a3.AQB__AccountStatus__c = 'Active';
        a3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        a3.Run_Pachinko_Assignment__c = TRUE;
        a3.Primary_Contact_Alum__c = TRUE;
        a3.Primary_Contact_School__c = 'Tepper';
        a3.Secondary_Contact_Alum__c =  TRUE;
        a3.Secondary_Contact_School__c = 'Heinz';
        a3.Parent_School_Affiliation__c = 'SCS'; 
        a3.Clean_Country__c = 'US';
        a3.Contact_Count__c = 1;
        accountList.add(a3);
        
        Account a4 = new Account();
        a4.Name = 'Account '+ 4;
        a4.AQB__AccountType__c = 'Alumni';
        a4.AQB__AccountStatus__c = 'Active';
        a4.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        a4.Run_Pachinko_Assignment__c = TRUE;
        a4.Primary_Contact_Alum__c = TRUE;
        a4.Primary_Contact_School__c = 'Multiple';
        a4.Contact_Count__c = 1;
        a4.Clean_Country__c = 'US';
        accountList.add(a4);
        
        Account a5 = new Account();
        a5.Name = 'Account '+ 5;
        a5.AQB__AccountType__c = 'Alumni';
        a5.AQB__AccountStatus__c = 'Active';
        a5.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        a5.Run_Pachinko_Assignment__c = TRUE;
        a5.Primary_Contact_Alum__c = TRUE;
        a5.Primary_Contact_School__c = 'Tepper';
        a5.Contact_Count__c = 1;
        a5.Clean_Country__c = 'US';
        accountList.add(a5);
        
        
        Account a6 = new Account();
        a6.Name = 'Account '+ 6;
        a6.AQB__AccountType__c = 'Faculty';
        a6.AQB__AccountStatus__c = 'Active';
        a6.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        a6.Run_Pachinko_Assignment__c = TRUE;
        a6.Primary_Contact_Alum__c = FALSE;
        a6.Primary_Contact_School__c = '';
        a6.Contact_Count__c = 1;
        a6.Clean_Country__c = 'US';
        accountList.add(a6);
        
        
        Account a7 = new Account();
        a7.Name = 'Account '+ 7;
        a7.AQB__AccountType__c = 'Friend';
        a7.AQB__AccountStatus__c = 'Active';
        a7.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        a7.Run_Pachinko_Assignment__c = TRUE;
        a7.Primary_Contact_Alum__c = FALSE;
        a7.Primary_Contact_School__c = '';
        a7.Contact_Count__c = 1;
        a7.Clean_Country__c = 'US';
        accountList.add(a7);        
      
        
        Account a8 = new Account();
        a8.Name = 'Account '+ 8;
        a8.AQB__AccountType__c = 'Staff';
        a8.AQB__AccountStatus__c = 'Active';
        a8.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        a8.Run_Pachinko_Assignment__c = TRUE;
        a8.Primary_Contact_Alum__c = FALSE;
        a8.Primary_Contact_School__c = '';
        a8.Contact_Count__c = 1;
        a8.Clean_Country__c = 'US';
        a8.AQB__AccountType__c = 'Staff';
        accountList.add(a8); 
              
        insert accountList;
        
        
        
          //Add 2 new sample Contacts
        Contact c1 = new Contact();
        c1.AccountId = a.Id;
        c1.LastName = a.Name + 1; 
        c1.AQB__Type__c = 'Alumni';
        c1.AQB__SecondaryType__c = 'Parent';
        contactList.add(c1);   
        
        Contact c2 = new Contact();
        c2.AccountId = a.Id;
        c2.LastName = a.Name + 2; 
        c2.AQB__Type__c = 'Staff';
        c2.AQB__SecondaryType__c = 'Parent';
        c2.AQB__Relationship__c = 'Spouse';
        contactList.add(c2);     

        
        Contact c3 = new Contact();
        c3.AccountId = a2.Id;
        c3.LastName = a2.Name + 3; 
        c3.AQB__Type__c = 'Alumni';
        c3.AQB__SecondaryType__c = 'Parent';
        contactList.add(c3);
        

        Contact c4 = new Contact();
        c4.AccountId = a3.Id;
        c4.LastName = a3.Name; 
        c4.AQB__Type__c = 'Alumni';
        c4.AQB__SecondaryType__c = 'Parent';        
        contactList.add(c4);

        Contact c5 = new Contact();
        c5.AQB__Relationship__c = 'Additional Contact';
        c5.AccountId = a3.Id;
        c5.LastName = a3.Name; 
        c5.AQB__Type__c = 'Alumni';    
        contactList.add(c5);
        
        
        Contact c6 = new Contact();
        c6.AccountId = a4.Id;
        c6.LastName = a4.Name; 
        c6.AQB__Type__c = 'Alumni';          
        contactList.add(c6);
        
        Contact c7 = new Contact();
        c7.AccountId = a6.Id;
        c7.LastName = a6.Name; 
        c7.AQB__Type__c = 'friend';          
        contactList.add(c7);
        
        Contact c8 = new Contact();
        c8.AccountId = a7.Id;
        c8.LastName = a7.Name; 
        c8.AQB__Type__c = 'friend'; 
        c8.Birthdate = Date.Today()-20000;
        contactList.add(c8);
        
        Contact c9 = new Contact();
        c9.AccountId = a8.Id;
        c9.LastName = a8.Name; 
        c9.AQB__Type__c = 'Staff';
        contactList.add(c9);  
        
        Contact c10 = new Contact();
        c10.AccountId = a5.Id;
        c10.LastName = a5.Name; 
        c10.AQB__Type__c = 'Faculty';
        contactList.add(c10); 
   
        insert contactList;

        
        a.AQB__PrimaryContact__c = c1.Id; 
        a.AQB__SecondaryContact__c = c2.Id; 
        a2.AQB__PrimaryContact__c = c3.Id;
        a3.AQB__PrimaryContact__c = c4.Id;
        a3.AQB__SecondaryContact__c = c5.Id;
        a4.AQB__PrimaryContact__c = c6.Id;
        a5.AQB__PrimaryContact__c = c10.Id; 
        a6.AQB__PrimaryContact__c = c7.Id; 
        a7.AQB__PrimaryContact__c = c8.Id;
        a8.AQB__PrimaryContact__c = c9.Id; 

        
        update accountList;
        
        
          //add volunteer positions
        AQB__VolunteerPosition__c vp1 = new AQB__VolunteerPosition__c(AQB__Contact__c=c4.Id, AQB__AffiliatedOrganization__c=pgac.Id);
        insert vp1;
        
          //add some majors
        LL_Major__c maj1 =  new LL_Major__c(Name='Computational Finance');
    
        
        
          //add some sample education records for these contacts
        
        AQB__Education__c edu1 = new AQB__Education__c();
        edu1.AQB__Contact__c = c1.Id;
        edu1.AQB__School__c = 'Tepper School of Business';
        eduList.add(edu1);
        
        AQB__Education__c edu2 = new AQB__Education__c();
        edu2.AQB__Contact__c = c2.Id;
        edu2.AQB__School__c = 'Heinz College';
        eduList.add(edu2);  
        
        AQB__Education__c edu3 = new AQB__Education__c();
        edu3.AQB__Contact__c = c4.Id;
        edu3.AQB__School__c = 'Heinz College';
        eduList.add(edu3);
        
        AQB__Education__c edu4 = new AQB__Education__c();
        edu4.AQB__Contact__c = c4.Id;
        edu4.AQB__School__c = 'Computer Science';
        eduList.add(edu4);
        
        AQB__Education__c edu5 = new AQB__Education__c();
        edu5.AQB__Contact__c = c5.Id;
        edu5.AQB__School__c = 'Margaret Morrison';
        eduList.add(edu5);
        
        AQB__Education__c edu6 = new AQB__Education__c();
        edu6.AQB__Contact__c = c6.Id;
        edu6.AQB__School__c = 'Printing Management';
        edu6.Status__c = 'Completed';
        edu6.RecordTypeId = Schema.SObjectType.AQB__Education__c.getRecordTypeInfosByName().get('Institutional').getRecordTypeId();
        eduList.add(edu6);
        
        AQB__Education__c edu7 = new AQB__Education__c();
        edu7.AQB__Contact__c = c6.Id;
        edu7.AQB__School__c = 'Industrial Management';
        eduList.add(edu7);
        
        AQB__Education__c edu8 = new AQB__Education__c();
        edu8.AQB__Contact__c = c6.Id;
        edu8.RecordTypeId = Schema.SObjectType.AQB__Education__c.getRecordTypeInfosByName().get('Institutional').getRecordTypeId();
        edu8.Major_1__c = maj1.Id;
        edu8.Status__c = 'Completed';
        edu8.AQB__DegreeLevel__c = 'Master\'s Degree';
        eduList.add(edu8);
        
        insert eduList;
        
        
        
          //update Contact1 and Contact2 with their Primary Education Links
        c1.AQB__EducationLink__c = edu1.Id;
        c2.AQB__EducationLink__c = edu2.Id;
        c4.AQB__EducationLink__c = edu4.Id;
        c5.AQB__EducationLink__c = edu5.Id;
        c6.AQB__EducationLink__c = edu6.Id;
        update contactList;
        
        
        
        //add PRospect Rating Donor Compass Score for Account a7
        Prospect_Rating__c pr7 = new Prospect_Rating__c();
        pr7.Account__c = a7.Id;
        pr7.RecordTypeId = Schema.SObjectType.Prospect_Rating__c.getRecordTypeInfosByName().get('Donor Compass Score').getRecordTypeId();
        pr7.Donor_Compass_Score__c = 22;
        pr7.Start_Date__c = date.today() - 365;
        insert pr7;
        
        
        //add PArent Affils
        Parent_Affiliation__c pa1 = new Parent_Affiliation__c();
        pa1.Contact__c = c1.Id;
        pa1.Child_Contact_Record__c = c6.Id;
        pa1.School__c = 'Tepper School of Business';
        pAffilList.add(pa1);
        
        Parent_Affiliation__c pa2 = new Parent_Affiliation__c();
        pa2.Contact__c = c1.Id;
        pa2.Child_Contact_Record__c = c4.Id;
        pa2.School__c = 'College of Fine Arts';
        pAffilList.add(pa2);
            
        Parent_Affiliation__c pa3 = new Parent_Affiliation__c();
        pa3.Contact__c = c2.Id;
        pa3.Child_Contact_Record__c = c5.Id;
        pa3.School__c = 'Computer Science';
        pAffilList.add(pa3);

        insert pAffilList;      



        
        
        
          // add Interests
        AQB__Interest__c int1 = new AQB__Interest__c();
        int1.AQB__LLInterestType__c = it1.Id;
        int1.AQB__Contact__c = c1.Id;
        int1.Interest_Prospect_Indicator__c = TRUE;
        interests.add(int1);
        
        AQB__Interest__c int2 = new AQB__Interest__c();
        int2.AQB__LLInterestType__c = it2.Id;
        int2.AQB__Contact__c = c1.Id;
        int2.Interest_Prospect_Indicator__c = TRUE;
        interests.add(int2);
        
        AQB__Interest__c int3 = new AQB__Interest__c();
        int3.AQB__LLInterestType__c = it3.Id;
        int3.AQB__Contact__c = c1.Id;
        int3.Interest_Prospect_Indicator__c = TRUE;
        interests.add(int3);
        
        AQB__Interest__c int4 = new AQB__Interest__c();
        int4.AQB__LLInterestType__c = it1.Id;
        int4.AQB__Contact__c = c2.Id;
        int4.Interest_Prospect_Indicator__c = TRUE;
        interests.add(int4);
        
        AQB__Interest__c int5 = new AQB__Interest__c();
        int5.AQB__LLInterestType__c = it2.Id;
        int5.AQB__Contact__c = c3.Id;
        int5.Interest_Prospect_Indicator__c = TRUE;
        interests.add(int5);
        
        AQB__Interest__c int6 = new AQB__Interest__c();
        int6.AQB__LLInterestType__c = it3.Id;
        int6.AQB__Contact__c = c5.Id;
        int6.Interest_Prospect_Indicator__c = TRUE;
        interests.add(int6);
        
        
        insert interests;
        
        
        
          // Add gifts (4)
        AQB__Gift__c gift1 = new AQB__Gift__c();
        gift1.AQB__Account__c = a.Id;
        gift1.AQB__Date__c = Date.today() - 365;
        giftList.add(gift1);
                    
        AQB__Gift__c gift2 = new AQB__Gift__c();
        gift2.AQB__Account__c = a.Id;
        gift2.AQB__Date__c = Date.today() - 465;        
        giftList.add(gift2);
        
        AQB__Gift__c gift3 = new AQB__Gift__c();
        gift3.AQB__Account__c = a.Id;
        gift3.AQB__Date__c = Date.today() - 565;        
        giftList.add(gift3);
        
        AQB__Gift__c gift4 = new AQB__Gift__c();
        gift4.AQB__Account__c = a.Id;
        gift4.AQB__Date__c = Date.today() - 665;   
        giftList.add(gift4);
        
        insert giftList;
        
        
        
        
        
          // add transactions for the gifts
        AQB__Transaction__c tr1 = new AQB__Transaction__c();
        tr1.AQB__Account__c = a.Id;
        tr1.AQB__Amount__c = 100.00;
        tr1.AQB__ChartofAccounts__c = coa1.Id;
        tr1.AQB__Date__c = Date.Today(); 
        tr1.AQB__CampaignAppeal__c = camp.Id;
        tr1.AQB__Gift__c = gift1.Id;
        transList.add(tr1); 
        
        AQB__Transaction__c tr2 = new AQB__Transaction__c();
        tr2.AQB__Account__c = a.Id;
        tr2.AQB__Amount__c = 100.00;
        tr2.AQB__ChartofAccounts__c = coa2.Id; 
        tr2.AQB__Date__c = Date.Today();
        tr2.AQB__CampaignAppeal__c = camp.Id;
        tr2.AQB__Gift__c = gift2.Id;
        transList.add(tr2);    
        
        AQB__Transaction__c tr3 = new AQB__Transaction__c();
        tr3.AQB__Account__c = a.Id;
        tr3.AQB__Amount__c = 100.00;
        tr3.AQB__ChartofAccounts__c = coa3.Id;
        tr3.AQB__Date__c = Date.Today();   
        tr3.AQB__CampaignAppeal__c = camp.Id;
        tr3.AQB__Gift__c = gift3.Id;
        transList.add(tr3);   
        
        AQB__Transaction__c tr4 = new AQB__Transaction__c();
        tr4.AQB__Account__c = a.Id;
        tr4.AQB__Amount__c = 100.00;
        tr4.AQB__ChartofAccounts__c = coa4.Id;
        tr4.AQB__Date__c = Date.Today(); 
        tr4.AQB__CampaignAppeal__c = camp.Id;
        tr4.AQB__Gift__c = gift4.Id;
        transList.add(tr4);
        
        insert transList;
        
        
        Test.startTest();
        
            PachinkoCalc pc = new PachinkoCalc();
            Database.executeBatch(pc);
        
        Test.stopTest();
       
    }
    
 
   
    
    
/*
 * *************************************************************************************************************
 * BULK TEST BELOW
 * *************************************************************************************************************
 */    

    /*
    
    global static testmethod void testBatchPachinko(){

        List<Account> accountList = new List<Account>();  
        List<Contact> contactList = new List<Contact>();
        List<AQB__InterestAccount__c> acctInterests = new List<AQB__InterestAccount__c>();
        List<AQB__LLInterestType__c> llInterestTypes = new List<AQB__LLInterestType__c>(); 
        List<AQB__LLChartofAccounts__c> coaList = new List<AQB__LLChartofAccounts__c>();
        List<AQB__Transaction__c> transList = new List<AQB__Transaction__c>();
        List<AQB__CampaignFund__c> fcList = new List<AQB__CampaignFund__c> ();
        List<Campaign> campList = new List<Campaign>();
        List<AQB__Gift__c> giftList = new List<AQB__Gift__c>();
        List<AQB__Education__c> eduList = new List<AQB__Education__c>();
        List<Pachinko__c> pachinkoList = new List<Pachinko__c>(); 
        List<String> parentSchools = new List<String>{'CFA', 'MCS', 'CIT', 'DC', 'SCS', 'Heinz', 'Tepper', 'Multiple', 'Margaret Morrison', 'Print Management', 'Tepper'};  
        List<String> contactTypes = new List<String>{'Alumni', 'Staff', 'Parent', 'Trustee', 'Faculty', 'Friend', 'Alumni', 'Staff', 'Parent', 'Friend', 'Parent'};
        List<String> colleges = new List<String>{'Carnegie Mellon University','College of Fine Arts','Computer Science','Graduate School of Industrial Admin.','Heinz College','Humanities and Social Sciences','Industrial Management','Margaret Morrison','Mellon College of Science','Printing Management','Tepper School of Business'};
    
    
    
    
        
          //add some new sample Pachinko Rules to the Custom Setting object
        Pachinko__c pach1 = new Pachinko__c();
        pach1.Name = 'PACHINKO1';
        pach1.Rule__c = 'Interest - Swartz Center';
        pach1.General_Category__c = 'Strategic Initiative';
        pach1.Specific_Category__c = 'Swartz Center';
        pachinkoList.add(pach1);
        
        Pachinko__c pach2 = new Pachinko__c();
        pach2.Name = 'PACHINKO2';
        pach2.Rule__c = 'Interest - Library';
        pach2.General_Category__c = 'University Priorities';
        pach2.Specific_Category__c = 'Library';
        pachinkoList.add(pach2); 
        
        Pachinko__c pach3 = new Pachinko__c();
        pach3.Name = 'PACHINKO3';
        pach3.Rule__c = 'MSCF';
        pach3.General_Category__c = 'MSCF';
        pach3.Specific_Category__c = 'MSCF';
        pachinkoList.add(pach3);         
        
        insert pachinkoList;
        
        

          //add a few new Interest Types to LL-InterestType
        AQB__LLInterestType__c it1 = new AQB__LLInterestType__c();
        it1.Name = 'Swartz Center';
        llInterestTypes.add(it1);
        
        AQB__LLInterestType__c it2 = new AQB__LLInterestType__c();
        it2.Name = 'Library'; 
        llInterestTypes.add(it2);
        
        AQB__LLInterestType__c it3 = new AQB__LLInterestType__c();
        it3.Name = 'MSCF'; 
        llInterestTypes.add(it3);        
        
        insert llInterestTypes;


        
          //add a sample Fundraising Campaign
        AQB__CampaignFund__c campFund = new AQB__CampaignFund__c();
        campfund.Name = 'camp fund';
        campfund.AQB__StartDate__c = Date.Today() - 90;
        campfund.AQB__EndDate__c = Date.Today() + 90;
        fcList.add(campFund);
        insert fcList;
        
          //add a sample campaign
        Campaign camp = new Campaign();
        camp.Name = 'fake campaign';
        camp.AQB__CampaignFund__c = campFund.Id;
        camp.Status = 'planned';
        camp.StartDate = Date.Today();
        camp.Drop_Date__c = Date.Today() + 5;
        camp.EndDate = Date.Today() + 60;
        camp.Appeal_Code__c = 'appeal';
        campList.add(camp);
        insert campList;
        
        
          //add a few new Chart of Accounts
        AQB__LLChartofAccounts__c coa1 = new AQB__LLChartofAccounts__c();
        coa1.Name = 'Tepper Student Affairs';
        coaList.add(coa1);
        
        AQB__LLChartofAccounts__c coa2 = new AQB__LLChartofAccounts__c();
        coa2.Name = 'Student Affairs';
        coaList.add(coa2);
        
        AQB__LLChartofAccounts__c coa3 = new AQB__LLChartofAccounts__c();
        coa3.Name = 'Academic Development';
        coaList.add(coa3);
        
        AQB__LLChartofAccounts__c coa4 = new AQB__LLChartofAccounts__c();
        coa4.Name = 'MSCF';
        coaList.add(coa4); 
        
        Insert coaList;     
        
        
        //insert bulk accounts
        
        for(Integer i=0; i<101; i++){      
            Account a = new Account();
            a.Name = 'Account '+ i;
            a.Type = 'Household';
            a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
            a.Run_Pachinko_Assignment__c = TRUE;
            a.Primary_Contact_Alum__c = TRUE;
            a.Secondary_Contact_Alum__c =  TRUE;
            a.Parent_School_Affiliation__c = parentSchools[Math.round(Math.random()* 10)];
            a.Contact_Count__c = 1;
            accountList.add(a);            
        }
        insert  accountlist;
        
        for (Account a : accountList){     
      
            Contact c1 = new Contact();
            c1.AccountId = a.Id;
            c1.LastName = a.Name+'1'; 
            c1.AQB__Type__c = contactTypes[Math.round(Math.random()* 10)] ;
            c1.AQB__SecondaryType__c = contactTypes[Math.round(Math.random()* 10)];
            a.AQB__PrimaryContact__c = c1.Id;
            contactList.add(c1);
            
            Contact c2 = new Contact();
            c2.AccountId = a.Id;
            c2.LastName = a.Name+'2'; 
            c2.AQB__Type__c = contactTypes[Math.round(Math.random() * 10)] ;
            c2.AQB__SecondaryType__c = contactTypes[Math.round(Math.random() * 10)];
            contactList.add(c2); 
            
            AQB__InterestAccount__c ai1 = new AQB__InterestAccount__c();
            ai1.AQB__LLInterestType__c = it1.Id;
            ai1.AQB__Account__c = a.Id;
            acctInterests.add(ai1);
            
            
            AQB__InterestAccount__c ai2 = new AQB__InterestAccount__c();
            ai2.AQB__LLInterestType__c = it2.Id;
            ai2.AQB__Account__c = a.Id;
            acctInterests.add(ai2);
        }
        insert contactList;
        insert acctInterests;
        
        For (Contact c: contactList){
            AQB__Education__c edu = new AQB__Education__c();
            edu.AQB__Contact__c = c.Id;
            edu.AQB__School__c = colleges[Math.round(Math.random() * 10)];
            c.AQB__EducationLink__c = edu.Id;                   
            eduList.add(edu);
        }
        insert eduList;
        
        Test.startTest();
        
            PachinkoCalc pc = new PachinkoCalc();
            Database.executeBatch(pc);
        
        Test.stopTest();        
        
    }  
*/
    
}