Global class GivingScoreCalc implements Database.Batchable<sObject>, Database.Stateful{

global Integer recordsProcessed = 0;
public Integer currentFiscal;
public List<Contact> conList = new List<Contact>();
public List<Giving_Score__c> gsList = new List<Giving_Score__c>();
public List<Id> accIds = new List<Id>();
public List<Contact> demographics = new List<Contact>();
public List<AQB__RelationshipContact__c> relationships = new List<AQB__RelationshipContact__c>();
Map<Id,Giving_Score__c> gsMap = new Map<Id,Giving_Score__c>();
public Date thirtyDaysAgo = Date.Today() - 90;
public Id advancement = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advancement Contact').getRecordTypeId();
public Id household =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();



    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, AQB__Full_Name__c, AccountId FROM Contact '+
                                        'WHERE RecordTypeId = :advancement '+
                                        'AND Account.RecordTypeId = :household '+
                                        'AND Account.AQB__AccountStatus__c = \'Active\' '+
                                        'AND LastModifiedDate >= :thirtyDaysAgo ');  
        
        


        //return Database.getQueryLocator('SELECT Id, AQB__Full_Name__c, AccountId FROM Contact WHERE Update_Giving_Score__c = TRUE');   
        //return Database.getQueryLocator('SELECT Id, AQB__Full_Name__c, AccountId FROM Contact WHERE Update_Giving_Score__c = TRUE AND LastName = \'Howell\'');    
    }



    
      
    global void execute(Database.BatchableContext bc, List<Contact> scope){  
        this.conList = scope;   
        
        System.debug('scope is :' + scope);
        System.debug('conList is :' + conList);
        
        for(Contact c : conList) {
            Giving_Score__c gs = new Giving_Score__c();
                gs.Name = c.AQB__Full_Name__c + ' -- Giving Score -- ' + Date.today().month() + '.' + Date.today().day() + '.' + Date.today().year();
                gs.Contact__c = c.Id;
                gs.Account__c = c.AccountID;
                gs.Undergrad_Indicator__c = false;
                gs.Undergrad_Education_Record__c = null; 
                gs.Current_Year_Volunteering__c = 0;
                gs.Last_Year_Volunteering__c = 0; 
                gs.Two_Years_Ago_Volunteering__c = 0;
                gs.Three_Years_Ago_Volunteering__c = 0; 
                gs.Last_Year_Events_Attended__c = 0;
                gs.Two_Years_Ago_Events_Attended__c = 0;
                gs.Three_Years_Ago_Events_Attended__c = 0;  
                gs.Current_Year_Gifts__c = 0;
                gs.Last_Year_Gifts__c = 0;
                gs.Two_Years_Ago_Gifts__c = 0;
                gs.Three_Years_Ago_Gifts__c = 0;
                gs.Four_Years_Ago_Gifts__c = 0;
                gs.Five_Plus_Years_Ago_Gifts__c = 0;                        
                gs.Legacy_Indicator__c = false;
                gs.Legacy_Contact_Record__c = null;
                gs.Relationship_with_Legacy_Contact__c = null; 
                gs.Married_Flag__c = false;
                gs.Email_Listed_Flag__c = false;
                gs.Gmail_Indicator__c = false;
                gs.Greek_Indicator__c = false;
                gs.Home_Phone_Listed_Flag__c = false;
                gs.Business_Phone_Listed_Flag__c = false; 
                gs.Years_With_Event_Attendance__c = 0;
                gs.Years_With_Volunteer_Activity__c = 0;
                gs.Total_Events_Attended__c = 0;  
                gs.Total_Volunteer_Activities__c = 0;                
                gs.CFA__c = false;
                gs.MCS__c = false;
                gs.CIT__c = false;
                gs.DC__c = false;
                gs.SCS__c = false;
                gs.Heinz__c = false;
                gs.Tepper__c = false;
                gs.CMU__c = false; 
                gs.Masters_Indicator__c = false;
                gs.Masters_Education_Record__c = null;
                gs.Doctorate_Indicator__c = false;
                gs.Doctorate_Education_Record__c = null;
                gs.Dual_Affiliate_Indicator__c = false;
                gs.Alumni_Spouse_Contact_Record__c = null;
                gs.Recent_Alumni_Indicator__c = false;
                gs.Preferred_Graduation_Year__c = null;
                gs.Lifetime_Total_Gifts__c = 0;
                gs.Consecutive_Years_of_Giving__c = 0;  
                gs.Giving_Years__c = null;  
                gs.Recency_Score__c = 0;
                gs.Frequency_Score__c = 0;
                gs.Giving_Span__c = 0;
                gs.Years_Giving_Multiplier__c = 0;
                gs.Giving_Frequency__c = 0.00; 
                gs.Largest_Gift__c = 0.00;
                gs.Cumulative_Giving__c = 0.00;
                gs.Annual_Giving_Grade__c = null;
                gs.Volunteer_Grade__c = null;               
            gsList.add(gs);                
            accIds.add(c.AccountId);            
            } 
        //add contents of this List to a map with the Contact as the Key        
        for(Giving_Score__c givScore : gsList){
            gsMap.put(givScore.Contact__c, givScore);
        }

        getCurrentFiscal();                     
        findDemFlags();
        findEducation(); 
        findDualAlumOrLegacy();
        findSchool(); 
        findGifts();        
        findVolunteer();       
        findEvents();      
        findStudentInterests();     
        insertGivingScores(gsList);
        deleteOldScores();
    }





      //Determine Fiscal Year for the Annual Giving Score
    public void getCurrentFiscal() {    
        Date t = System.Today();          
        if( (t.month()>= 7) && (t.month()<=12) ) {    
            currentFiscal = t.year() + 1;
        }
        else{currentFiscal = t.year();}          
    }




      //Query demographic fields and relationships from the Contacts.     
    public void findDemFlags() {      
          
        demographics = [SELECT AQB__PersonalEmail__c, AQB__BusinessEmail__c, AQB__OtherEmail__c, Email, AQB__School__c, 
                        AQB__MaritalStatus__c, Phone, AQB__BusinessPhone__c, AQB__AccountPhone__c, 
                        AQB__Gender__c, AQB__PreferredYear__c, AQB__DegreeYear__c 
                        FROM Contact WHERE id IN :conList];                                              
                      
        relationships = [SELECT Id, AQB__Contact__c, AQB__RelatedContactRole__r.Name
                         FROM AQB__RelationshipContact__c  
                         WHERE AQB__Contact__c IN :conList];                    
    
    
        for(Giving_Score__c gs : gsList) {
            for(Contact c : demographics) {
                if(gs.Contact__c == c.Id) { 
                
                    
                      //check the contact's Marital Status and Relationships Records for a Spouse, and update the 'Married Flag' on the Giving Score                        
                    if ( c.AQB__MaritalStatus__c == 'Married' || hasSpouseRecord(gs.Contact__c) ){              
                        gs.Married_Flag__c = TRUE;
                        }
                        else{ 
                            gs.Married_Flag__c = FALSE; 
                        }


                      //check the contact's 4 email address fields and update the 'Email Listed' flag on the giving score   
                    gs.Email_Listed_Flag__c = TRUE;                            
                    if (c.AQB__PersonalEmail__c == NULL) {                       
                        if (c.AQB__BusinessEmail__c == NULL) {               
                            if (c.AQB__OtherEmail__c == NULL) {  
                                if (c.Email == NULL) {                  
                                    gs.Email_Listed_Flag__c = FALSE;
                                }                               
                            }
                        }
                    }


                      //check to see if the preferred email address is a 'Gmail' address
                    if (c.Email != NULL && c.Email.containsIgnoreCase('gmail.com')){
                        gs.Gmail_Indicator__c = TRUE;
                    }    
                    
                    
                    
                                                                         
                      //check the contact's Home Phone Field and update the 'Home Phone Listed flag' on the giving score
                    if (c.AQB__AccountPhone__c != NULL ) {
                        gs.Home_Phone_Listed_Flag__c = TRUE;
                    }                    
                                     
                    
                      //check their Business Phone Field and update the 'Business Phone Listed flag' on the giving score
                    if (c.AQB__BusinessPhone__c != NULL ) {
                        gs.Business_Phone_Listed_Flag__c = TRUE;
                    }
                    
                       //check the Contact's Gender                   
                    if (c.AQB__Gender__c != NULL) {
                       gs.Gender__c = c.AQB__Gender__c;
                    }   
                    
                    
                      //get pref year
                    if (c.AQB__PreferredYear__c != NULL) {
                        Integer prefYear = Integer.valueOf(c.AQB__PreferredYear__c);
                        if(  (System.Today().Year() - prefYear) <= 9) {
                            gs.Recent_Alumni_Indicator__c = TRUE;
                            gs.Preferred_Graduation_Year__c = String.valueOf(prefYear);
                        }
                        else{
                            gs.Preferred_Graduation_Year__c = String.valueOf(prefYear);
                        }      
                    }                                                                                                                                                                                                     
                }                
            }
        } 
    }
    



      //method for determining whether this Contact has a Relationship to another Contact indicating 'Spouse' or 'Partner/Spouse' as the Related Contact Role      
    public Boolean hasSpouseRecord(Id contactId){         
        for (AQB__RelationshipContact__c rc : relationships) {
            if (rc.AQB__Contact__c == contactID) {
                if (rc.AQB__RelatedContactRole__r.Name == 'Spouse' || rc.AQB__RelatedContactRole__r.Name == 'Spouse/Partner') {               
                    return TRUE;
                }
            } 
        }   
    return FALSE;
    }






     //query for education records containing a degree like "Bachelor"...loop through results and match to the Contact...
     //check the 'Undergrad Indicator' and link the Edu record to the Contact in 'Undergrad Education Record' field 
     
    public void findEducation(){ 
        List<AQB__Education__c> bachRecs = new List<AQB__Education__c>(); 
        List<AQB__Education__c> masterRecs = new List<AQB__Education__c>(); 
        List<AQB__Education__c> doctorRecs = new List<AQB__Education__c>();  
               
        
        String[] bFilters = new String[]{'%Bachelor%'};  
        
        bachRecs = [SELECT Id, RecordType.Name, Status__c, AQB__DegreeDiploma__c, AQB__Contact__c         
                    FROM AQB__Education__c  
                    WHERE AQB__Contact__c IN :conList
                    AND RecordType.Name = 'Institutional' 
                    AND (AQB__DegreeLevel__c = 'Undergraduate'
                    OR AQB__DegreeDiploma__c LIKE :bFilters)];
            
        for (AQB__Education__c ed : bachRecs) {
            for (Giving_Score__c gs : gsList) {
                if (ed.AQB__Contact__c == gs.Contact__c) {
                    gs.Undergrad_Indicator__c = TRUE;
                    gs.Undergrad_Education_Record__c = ed.Id;           
                }
            }
        } 
        

        String[] mFilters = new String[]{'%Master%','%MBA%'};        
        
        masterRecs = [SELECT Id, RecordType.Name, Status__c, AQB__DegreeDiploma__c, AQB__Contact__c         
                      FROM AQB__Education__c  
                      WHERE AQB__Contact__c IN :conList
                      AND RecordType.Name = 'Institutional' 
                      AND (AQB__DegreeLevel__c = 'Masters'
                      OR AQB__DegreeDiploma__c LIKE :mFilters)];
           
        for (AQB__Education__c ed : masterRecs) {
            for (Giving_Score__c gs : gsList) {
                if (ed.AQB__Contact__c == gs.Contact__c) {
                    gs.Masters_Indicator__c = TRUE;
                    gs.Masters_Education_Record__c = ed.Id;           
                }
            }
        }          

       
        String[] dFilters = new String[]{'%Doctor%','%Doctorate%', '%PHD%'};        
        
        doctorRecs = [SELECT Id, RecordType.Name, Status__c, AQB__DegreeDiploma__c, AQB__Contact__c         
                      FROM AQB__Education__c  
                      WHERE AQB__Contact__c IN :conList
                      AND RecordType.Name = 'Institutional'                        
                      AND (AQB__DegreeLevel__c = 'Doctorate'
                      OR AQB__DegreeDiploma__c LIKE :dFilters)];
           
        for (AQB__Education__c ed : doctorRecs) {
            for (Giving_Score__c gs : gsList) {
                if (ed.AQB__Contact__c == gs.Contact__c) {
                    gs.Doctorate_Indicator__c = TRUE;
                    gs.Doctorate_Education_Record__c = ed.Id;           
                }
            }
        }                            
    }





      //Query the Contact Relationships to return records of Contacts which are both immediate family and Alumni...
      //If found, check the 'Legacy Indicator'box, link their family member to the Giving score object, and add the familial relationship in the 'Relationship with Legacy Contact' field.
            
    public void findDualAlumOrLegacy(){ 
    List<AQB__RelationshipContact__c> relCons = new List<AQB__RelationshipContact__c>();            

        relCons = [SELECT Id, AQB__Contact__c, AQB__RelatedContact__r.Name , AQB__RelatedContactRole__r.Name
                   FROM AQB__RelationshipContact__c
                   WHERE AQB__Contact__c IN :conList 
                   AND AQB__RelatedContact__r.AQB__Type__c = 'Alumni'
                   AND AQB__RelatedContactRole__r.Name IN ('Mother','Father','Brother','Sister','Grandfather','Grandmother','Aunt','Uncle','Guardian','Cousin', 'Spouse', 'Spouse/Partner')];    
            
        for(AQB__RelationshipContact__c rc : relCons) {
            for (Giving_Score__c gs : gsList) {
                if (rc.AQB__Contact__c == gs.Contact__c) {
                           
                    if (rc.AQB__RelatedContactRole__r.Name == 'Spouse' || rc.AQB__RelatedContactRole__r.Name == 'Spouse/Partner') {  
                        gs.Dual_Affiliate_Indicator__c = TRUE;
                        gs.Alumni_Spouse_Contact_Record__c = rc.AQB__RelatedContact__r.Id;
                    }
                                               
                    else {                   
                        gs.Legacy_Indicator__c = TRUE;
                        gs.Legacy_Contact_Record__c = rc.AQB__RelatedContact__r.Id;
                        gs.Relationship_with_Legacy_Contact__c = rc.AQB__RelatedContactRole__r.Name;                  
                    }                                
                }            
            }              
        }
    }





      //Get the name of the Preferred school from Affiniquest's field on the Contact, if it is populated.
      //Check the appropriate School Indicator checkbox on the Giving Score Object.
      
    public void findSchool() {     
        for (Contact c : demographics) {
            for (Giving_Score__c gs : gsList) { 
                if (c.Id == gs.Contact__c) { 
                    if      (c.AQB__School__c == 'College of Fine Arts') {gs.CFA__c = TRUE;}                    
                    else if (c.AQB__School__c == 'Carnegie Institute of Technology') {gs.CIT__c = TRUE;}
                    else if (c.AQB__School__c == 'Margaret Morrison') {gs.CMU__c = TRUE;}
                    else if (c.AQB__School__c == 'Carnegie Mellon University') {gs.CMU__c = TRUE;}                    
                    else if (c.AQB__School__c == 'Library') {gs.CMU__c = TRUE;}
                    else if (c.AQB__School__c == 'Printing Management') {gs.CMU__c = TRUE;}
                    else if (c.AQB__School__c == 'Unspecified') {gs.CMU__c = TRUE;}                    
                    else if (c.AQB__School__c == 'Humanities and Social Sciences') {gs.DC__c = TRUE;}
                    else if (c.AQB__School__c == 'Dietrich College of H and SS') {gs.DC__c = TRUE;}                    
                    else if (c.AQB__School__c == 'Heinz School') {gs.HEINZ__c = TRUE;}
                    else if (c.AQB__School__c == 'Heinz College') {gs.HEINZ__c = TRUE;}
                    else if (c.AQB__School__c == 'Mellon College of Science') {gs.MCS__c = TRUE;}                    
                    else if (c.AQB__School__c == 'Computer Science') {gs.SCS__c = TRUE;}                    
                    else if (c.AQB__School__c == 'Graduate School of Industrial Admin.') {gs.TEPPER__c = TRUE;}
                    else if (c.AQB__School__c == 'Tepper School of Business') {gs.TEPPER__c = TRUE;} 
                    else if (c.AQB__School__c == 'Industrial Management') {gs.TEPPER__c = TRUE;}
                    else if (c.AQB__School__c == 'Indust Mgmt (Graphic Comms Mgmt)') {gs.TEPPER__c = TRUE;}   
                    else if (c.AQB__School__c == 'Industries') {gs.TEPPER__c = TRUE;}                    
                }      
            }
        }
    }





      //Query 'Gift Recognition Credits' object off of the Contact, calculate Fiscal Year, update the correct counting fields.
      //Also calculates 'how many consecutive years the contact gave, starting with current year, going back.  This will now include Soft Credits from gifts the contact is linked to on other accounts.
      //Calculate RFM Score in 3 parts using the gift recognition data.
    public void findGifts() {
    List<AQB__GiftCredit__c> gifts = new List<AQB__GiftCredit__c>();  
    Set<String> fiscals = new Set<String>(); 
            
    gifts = [SELECT ID, AQB__ContactCredited__c, AQB__GiftDate__c, Fiscal_Year__c, AQB__SecondaryGiftCreditAmount__c 
             FROM AQB__GiftCredit__c 
             WHERE AQB__ContactCredited__c IN :conList];                   
       
        
        
        //Count the Gifts found in the Query (Lifetime Gifts) and Count the Gifts by Fiscal Year, Update the appropriate fields...
        for (Giving_Score__c gs : gsList) {
            Set<Integer> fySet = new Set<Integer>();  //add the fiscal years to a set as you loop over each gift
            List<Double> GiftAmounts = new List<Double>();  // add the amount to a list (doubles) as you loop over the gifts   
                for (AQB__GiftCredit__c gc : gifts) {           
                    if (gc.AQB__ContactCredited__c == gs.Contact__c){
                        gs.Lifetime_Total_Gifts__c ++; 
                        if(gc.Fiscal_Year__c != NULL){ 
                            fySet.add(Integer.valueOf(gc.Fiscal_Year__c)); 
                            System.debug(fySet);
                            giftAmounts.add(gc.AQB__SecondaryGiftCreditAmount__c); 
                            System.debug(giftAmounts);                                                                
                            if ( currentFiscal - (Integer.valueof(gc.Fiscal_Year__c) ) == 0 ) {gs.Current_Year_Gifts__c ++;}                                   
                            if ( currentFiscal - (Integer.valueof(gc.Fiscal_Year__c) ) == 1 ) {gs.Last_Year_Gifts__c ++;}
                            if ( currentFiscal - (Integer.valueof(gc.Fiscal_Year__c) ) == 2 ) {gs.Two_Years_Ago_Gifts__c ++;}
                            if ( currentFiscal - (Integer.valueof(gc.Fiscal_Year__c) ) == 3 ) {gs.Three_Years_Ago_Gifts__c ++;}
                            if ( currentFiscal - (Integer.valueof(gc.Fiscal_Year__c) ) == 4 ) {gs.Four_Years_Ago_Gifts__c ++;}
                            if ( currentFiscal - (Integer.valueof(gc.Fiscal_Year__c) ) >= 5 ) {gs.Five_Plus_Years_Ago_Gifts__c ++;}                                                            
                        }
                    }    
                }
                

                
                  //Count the consecutive years of giving back from last fiscal year (not including this current fiscal yr)...
                gs.Giving_Years__c = String.valueOf(fySet);
                for(Integer i=1; i<=fySet.size(); i++) {
                    if(fySet.contains(currentFiscal - i)) {
                        gs.Consecutive_Years_of_Giving__c ++;
                    }
                    else{break;}
                }  
                
                
                
                  //RFM SCORING PART A:  
                  //Determine the RECENCY SCORE by looking at the FY gift counting fields, assigning appropriate points...
                if (gs.Current_Year_Gifts__c > 0) {gs.Recency_Score__c = 20;}
                else if (gs.Last_Year_Gifts__c > 0) {gs.Recency_Score__c = 15;}
                else if (gs.Two_Years_Ago_Gifts__c > 0) {gs.Recency_Score__c = 10;}
                else if (gs.Three_Years_Ago_Gifts__c > 0) {gs.Recency_Score__c = 5;}
                else if (gs.Four_Years_Ago_Gifts__c > 0) {gs.Recency_Score__c = 2;}
                else if (gs.Five_Plus_Years_Ago_Gifts__c > 0) {gs.Recency_Score__c = 1;}
                else {gs.Recency_Score__c = 0;}
                
                
                
                  //RFM SCORING PART B:
                  //Determine the FREQUENCY SCORE below (4 steps):
                  //step #1 of 4 ... sort the fiscal years to determine first and last FY; calculate Giving Span (Last FY - First FY)...
                List<Integer> fiscalSort =  new List<Integer>();
                fiscalSort.addAll(fySet);
                Integer givingSpan = 0;
                Double givingPercent = 0.0;
                
                if (fiscalSort.size() > 0) {
                    fiscalSort.sort();                
                    Integer fyMin = fiscalSort[0];                
                    Integer fyMax = fiscalSort[fiscalSort.size()-1];                
                    givingSpan = (fyMax - fyMin);                
                    gs.Giving_Span__c = givingSpan;   
                                
                      //step #2 of 4 ... calculate the 'Giving Percent' (GiftCount / GivingSpan) ...
                    if(givingSpan > 0){
                        givingPercent = Double.valueOf( (gs.Lifetime_Total_Gifts__c / givingSpan) * 100);
                        gs.Giving_Frequency__c = givingPercent;
                    }
                }

                  //step #3 of 4 ... calculate the 'Years Giving Muliplier' by assigning the appropriate points for Giving Span years...
                if (givingSpan >= 20) {gs.Years_Giving_Multiplier__c = 3.0;}
                else if (givingSpan >= 15) {gs.Years_Giving_Multiplier__c = 2.5;}
                else if (givingSpan >= 10) {gs.Years_Giving_Multiplier__c = 2.0;}
                else if (givingSpan >= 5) {gs.Years_Giving_Multiplier__c = 1.5;}
                else if (givingSpan >= 1) {gs.Years_Giving_Multiplier__c = 1.0;}
                else {gs.Years_Giving_Multiplier__c = 0;}
                
                
                  //step #4 of 4 ... final calc of the 'Frequency Score' by assigning points for the 'Giving Frequency Percentage', multiplied by the 'Y.G.Multiplier'...
                if (givingPercent == 100) {gs.Frequency_Score__c = 10 * gs.Years_Giving_Multiplier__c; }
                else if (givingPercent >= 90) {gs.Frequency_Score__c = 8 * gs.Years_Giving_Multiplier__c;}
                else if (givingPercent >= 80) {gs.Frequency_Score__c = 6 * gs.Years_Giving_Multiplier__c;}
                else if (givingPercent >= 70) {gs.Frequency_Score__c = 4 * gs.Years_Giving_Multiplier__c;}
                else if (givingPercent >= 60) {gs.Frequency_Score__c = 2 * gs.Years_Giving_Multiplier__c;}
                else {gs.Frequency_Score__c = 1 * gs.Years_Giving_Multiplier__c;}  
                
                    
                
                //RFM SCORING PART C:
                //Determine the MONETARY SCORE (2 steps):
                
                  //step #1 of 2...determine the Largest Gift, assign appropriate points:
                giftAmounts.sort();
                Integer giftScore = 0;
                Double giftMax = 0.0;
                
                
                if (giftAmounts.size() > 0) {                
                    giftMax = giftAmounts[giftAmounts.size()-1];
                    gs.Largest_Gift__c = giftMax;
                }  
                
                            
                if (giftMax >= 5000) {giftScore = 25;}
                else if (giftMax >= 2000) {giftScore = 15;}
                else if (giftMax >= 1000) {giftScore = 10;}
                else if (giftMax >= 500) {giftScore = 5;}
                else if (giftMax > 0) {giftScore = 1;}
                else {giftScore = 0;}
                
    
                 //step #2 of 2...determine the Cumulative Giving Total, assign appropriate points:
                Double giftTotal = 0;
                Integer cumulativeScore = 0;
                for (Double amt : giftAmounts) {
                    giftTotal = giftTotal + amt;                   
                }
                gs.Cumulative_Giving__c = giftTotal;                
                                               
                if (giftTotal >= 20000) {cumulativeScore = 25;}
                else if (giftTotal >= 10000) {cumulativeScore = 15;}
                else if (giftTotal >= 5000) {cumulativeScore = 5;}       
                else {cumulativeScore = 0;}               
                             
                gs.Monetary_score__c = giftScore + cumulativeScore;                                     
        }        
    } 
    
    
    

      //Method to find Volunteer Position records for the contacts and map them to the correct fiscal year.
      
    public void findVolunteer() {
    List<AQB__VolunteerPosition__c> vols = new List<AQB__VolunteerPosition__c>();    
    
    vols = [SELECT Id, AQB__Contact__c, AQB__StartDate__c, Fiscal_Year__c
            FROM AQB__VolunteerPosition__c 
            WHERE AQB__Contact__c IN :conList];            
       
        for (Giving_Score__c gs : gsList) {
            Set<Integer> fySet = new Set<Integer>();       
                for (AQB__VolunteerPosition__c vp : vols) {           
                    if (vp.AQB__Contact__c == gs.Contact__c){ 
                        gs.Total_Volunteer_Activities__c ++;
                        if(vp.Fiscal_Year__c != NULL){                    
                            fySet.add(Integer.valueOf(vp.Fiscal_Year__c));                                                                   
                            if ( currentFiscal - (Integer.valueof(vp.Fiscal_Year__c)) == 0 ){gs.Current_Year_Volunteering__c ++;}                                   
                            else if ( currentFiscal - (Integer.valueof(vp.Fiscal_Year__c)) == 1 ){gs.Last_Year_Volunteering__c ++;}
                            else if ( currentFiscal - (Integer.valueof(vp.Fiscal_Year__c)) == 2 ){gs.Two_Years_Ago_Volunteering__c ++;}
                            else if ( currentFiscal - (Integer.valueof(vp.Fiscal_Year__c)) == 3 ){gs.Three_Years_Ago_Volunteering__c ++;} 
                        }                                                               
                    }
                }
            gs.Years_With_Volunteer_Activity__c = fySet.size();           
        }        
    }  




      //Method to find Event Guest records for the contacts and map them to the correct fiscal year.
      
    public void findEvents() {
    List<AQB__EventGuest__c> events = new List<AQB__EventGuest__c>();
    Set<String> fiscals = new Set<String>(); 
            
    events = [SELECT AQB__Event_Date__c, Id, AQB__Contact__c, Fiscal_Year__c
             FROM AQB__EventGuest__c 
             WHERE AQB__Contact__c IN :conList];            
       
        for (Giving_Score__c gs : gsList) {
            Set<Integer> fySet = new Set<Integer>();       
                for (AQB__EventGuest__c eg : events) {           
                    if (eg.AQB__Contact__c == gs.Contact__c){
                        gs.Total_Events_Attended__c ++;  
                        if(eg.Fiscal_Year__c != NULL){
                            fySet.add(Integer.valueOf(eg.Fiscal_Year__c));                                                                   
                            if ( currentFiscal - (Integer.valueof(eg.Fiscal_Year__c)) == 0 ) {gs.Current_Year_Events_Attended__c ++;}                                   
                            else if ( currentFiscal - (Integer.valueof(eg.Fiscal_Year__c)) == 1 ) {gs.Last_Year_Events_Attended__c ++;}
                            else if ( currentFiscal - (Integer.valueof(eg.Fiscal_Year__c)) == 2 ) {gs.Two_Years_Ago_Events_Attended__c ++;}
                            else if ( currentFiscal - (Integer.valueof(eg.Fiscal_Year__c)) == 3 ) {gs.Three_Years_Ago_Events_Attended__c ++;} 
                        }                                                           
                    }
                }
            gs.Years_With_Event_Attendance__c = fySet.size();           
        }        
    } 



    public void findStudentInterests(){
    List<AQB__StudentInterest__c> studentInts = new List<AQB__StudentInterest__c>();
    List<Id> theseContacts = new List<Id>();
    List<Giving_Score__c> theseGS = new List<Giving_Score__c>();

      //query student ints and get only Greek interests for these contacts
    studentInts = [SELECT ID, AQB__InterestGroup__c, Contact__c
                  FROM AQB__StudentInterest__c
                  WHERE AQB__InterestGroup__c = 'Greek'
                  AND Contact__c IN :conList];                     
        System.debug('student interest greek list: '+ studentInts);
                  
          //add the contacts from these found Student interests to a small list         
        for (AQB__StudentInterest__c stInt : studentInts) {
            theseContacts.add(stInt.Contact__c);
        }

          //query the Map with the small contact list to get the Giving Scores into a small list 
        for(Id thisCon : theseContacts){
            theseGS.add(gsMap.get(thisCon));
        }
             
          //iterate the small list of giving scores against the list of stundet intersts to check the Greek indictor field
        for (Giving_Score__c gs : theseGS){
            for (AQB__StudentInterest__c si : studentInts){
                if (si.Contact__c == gs.Contact__c){
                    gs.Greek_Indicator__c = TRUE;
                }
            }
        }
    }



        //insert the full gsList at once, set the count for the list size
    public void insertGivingScores(List<Giving_Score__c> gsList){
        Database.insert(gsList, FALSE);
        recordsProcessed = gsList.size();
    }





      //Delete the old Giving Score object for every Contact that got a new one        
    public void deleteOldScores(){    
        System.debug('Hit the Delete old scores method');
        List<Giving_Score__c> oldScores = new List<Giving_Score__c>();
    
        oldScores = [SELECT Id, Contact__c FROM Giving_Score__c
                     WHERE Contact__c IN :conList
                     AND Id NOT IN :gsList];                       
        delete oldScores;  
        System.debug('finished the Delete old scores method');                       
    }
    
    
    
    
    global void finish(Database.BatchableContext bc){
    System.debug('Contacts processed with a new GivingScores: ' + recordsProcessed);
    System.debug('AGScore and VScore batches are turned off at the moment');
    //AGScoreDistribution agsd = new AGScoreDistribution();
    //Id batchId = Database.executeBatch(agsd);
    ID jobID = System.enqueueJob(new AGScoreDistribution());
    }    
}