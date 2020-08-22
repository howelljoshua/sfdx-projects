@isTest

global class GivingScoreCalc_Test {
    
    global static testMethod void testGivingScoreCalc() {
        List<Account> accountList = new List<Account>();  
        List<Contact> contactList = new List<Contact>();
        List<AQB__RelationshipContact__c> relationships = new List<AQB__RelationshipContact__c>();
        List<AQB__LLContactRole__c> contactRoles = new List<AQB__LLContactRole__c>();
        List<AQB__Education__c> eduList = new List<AQB__Education__c>();


        
          //add contact role
        AQB__LLContactRole__c cr1 = new AQB__LLContactRole__c();
        cr1.Name= 'Spouse';
        contactRoles.add(cr1);
        insert contactRoles;
        
        
        
          //add accounts
        Account a = new Account();
        a.Name = 'Account '+ 1;
        a.Type = 'Household';
        a.RecordTypeId = '012f4000000gmsBAAQ';
        accountList.add(a);
        
        Account a2 = new Account();
        a2.Name = 'Account '+ a2;
        a2.Type = 'Household';
        a2.RecordTypeId = '012f4000000gmsBAAQ';
        accountList.add(a2);
        
        Account a3 = new Account();
        a3.Name = 'Account '+ a3;
        a3.Type = 'Household';
        a3.RecordTypeId = '012f4000000gmsBAAQ';
        accountList.add(a3);
        
        Account a4 = new Account();
        a4.Name = 'Account '+ a4;
        a4.Type = 'Household';
        a4.RecordTypeId = '012f4000000gmsBAAQ';
        accountList.add(a4);
        
        Account a5 = new Account();
        a5.Name = 'Account '+ a5;
        a5.Type = 'Household';
        a5.RecordTypeId = '012f4000000gmsBAAQ';
        accountList.add(a5);
        
        Account a6 = new Account();
        a6.Name = 'Account '+ a6;
        a6.Type = 'Household';
        a6.RecordTypeId = '012f4000000gmsBAAQ';
        accountList.add(a6);
        
        
        
        insert accountList;
        

           //add contacts
        Contact c1 = new Contact();
        c1.AccountId = a.Id;
        c1.LastName = a.Name + 1; 
        c1.AQB__Type__c = 'Alumni';
        c1.AQB__SecondaryType__c = 'Parent';
        c1.Update_Giving_Score__c = TRUE;        
        c1.AQB__Gender__c = 'Male';
        contactList.add(c1);
        
        Contact c2 = new Contact();
        c2.AccountId = a.Id;
        c2.LastName = a.Name + 2; 
        c2.AQB__Type__c = 'Staff';
        c2.AQB__SecondaryType__c = 'Parent';
        c2.AQB__Relationship__c = 'Spouse';
        c2.Update_Giving_Score__c = TRUE;
        c2.AQB__Gender__c = 'Female';
        contactList.add(c2);    

        Contact c3 = new Contact();
        c3.AccountId = a2.Id;
        c3.LastName = a2.Name + 3; 
        c3.AQB__Type__c = 'Staff';
        c3.AQB__SecondaryType__c = 'Parent';
        c3.AQB__Relationship__c = 'Spouse';
        c3.Update_Giving_Score__c = TRUE;
        c3.AQB__Gender__c = 'Male';
        contactList.add(c3);  


        Contact c4 = new Contact();
        c4.AccountId = a3.Id;
        c4.LastName = a3.Name + 4; 
        c4.AQB__Type__c = 'Staff';
        c4.AQB__SecondaryType__c = 'Parent';
        c4.AQB__Relationship__c = 'Spouse';
        c4.Update_Giving_Score__c = TRUE;
        c4.AQB__Gender__c = 'Female';
        contactList.add(c4);  


        Contact c5 = new Contact();
        c5.AccountId = a4.Id;
        c5.LastName = a4.Name + 5; 
        c5.AQB__Type__c = 'Staff';
        c5.AQB__SecondaryType__c = 'Parent';
        c5.AQB__Relationship__c = 'Spouse';
        c5.Update_Giving_Score__c = TRUE;
        c5.AQB__Gender__c = 'Female';
        contactList.add(c5);  


        Contact c6 = new Contact();
        c6.AccountId = a5.Id;
        c6.LastName = a5.Name + 6; 
        c6.AQB__Type__c = 'Staff';
        c6.AQB__SecondaryType__c = 'Parent';
        c6.AQB__Relationship__c = 'Spouse';
        c6.Update_Giving_Score__c = TRUE;
        c6.AQB__Gender__c = 'Female';
        contactList.add(c6);  

        Contact c7 = new Contact();
        c7.AccountId = a6.Id;
        c7.LastName = a6.Name + 7; 
        c7.AQB__Type__c = 'Staff';
        c7.AQB__SecondaryType__c = 'Parent';
        c7.AQB__Relationship__c = 'Spouse';
        c7.Update_Giving_Score__c = TRUE;
        c7.AQB__Gender__c = 'Male';
        contactList.add(c7);  
        
        insert contactList;
        




        
          //add relationship spouse
        AQB__RelationshipContact__c rel1 = new AQB__RelationshipContact__c();
        rel1.AQB__Contact__c = c1.Id;
        rel1.AQB__ContactRole__c = cr1.Id;
        rel1.AQB__relatedContact__c = c2.Id;
        rel1.AQB__RelatedContactRole__c = cr1.Id;
        relationships.add(rel1);
        insert relationships;
        
        
          //add education links
        AQB__Education__c edu1 = new AQB__Education__c();
        edu1.AQB__Contact__c = c1.Id;
        edu1.AQB__School__c = 'Tepper School of Business';
        edu1.AQB__PreferredYear__c = '1990';
        edu1.AQB__DegreeLevel__c = 'Undergraduate';
        eduList.add(edu1); 
        
        AQB__Education__c edu2 = new AQB__Education__c();
        edu2.AQB__Contact__c = c2.Id;
        edu2.AQB__School__c = 'Heinz College';
        edu2.AQB__PreferredYear__c = '2014';
        edu2.AQB__DegreeLevel__c = 'Masters';
        eduList.add(edu2); 
        
        AQB__Education__c edu3 = new AQB__Education__c();
        edu3.AQB__Contact__c = c2.Id;
        edu3.AQB__School__c = 'Tepper School of Business';
        edu3.AQB__PreferredYear__c = '2016';
        edu3.AQB__DegreeLevel__c = 'Doctorate';
        eduList.add(edu3); 
        
        insert eduList;
        
        
          //upate preferred education links
        c1.AQB__EducationLink__c = edu1.Id;
        c2.AQB__EducationLink__c = edu2.Id;
        update contactList;
        
        
        
        Test.startTest();
        
            GivingScoreCalc gsc = new GivingScoreCalc();
            Database.executeBatch(gsc);
        
        Test.stopTest();        
        
        
        
        
    }

}