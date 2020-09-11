/*
 * PachinkoCalc // Author - Josh Howell CMU
 * 
 * Calculates Assignment Values for Accounts based on factors in data
 * Uses Pachinko Custom Settings object for Rule Ordering 
 * Single Test Class PachinkoCalc_Test covers this class at 93%
 * 
 * Final Updates and move to Production 4/10/2019
 */

global class PachinkoCalc implements Database.Batchable<sObject>, Database.Stateful{
 
global Integer recordsProcessed = 0;
global List<Account> acctList = new List<Account>(); 
global Map<Id, Account> acctMap = new Map<Id, Account>();
global Set<Account> accountSet = new Set<Account>();
global List<Account> hasContacts = new List<Account>();     
global List<Contact> contacts = new List<Contact>();
global Map<Id, Contact> contactMap = new Map<Id, Contact>(); 
global Map<Account, Contact> AcctContMap = new Map<Account, Contact>(); 
global List<AQB__RelationshipContact__c> relationships = new List<AQB__RelationshipContact__c>();    
global List<Pachinko__c> rules = [SELECT Rule__c, General_Category__c, Specific_Category__c FROM Pachinko__c];
global List<String> capValues = new List<String>{'$5,000,000-9,999,999', '$10,000,000-24,999,999', '$25,000,000-49,999,999', '$50,000,000-99,999,999', '$100,000,000+'};      
global List<String> dualAffils = new List<string>{'Multiple', 'Margaret Morrison', 'Print Management'};
global Map<String, Integer> compareStrategic = new Map<String, Integer>{'BrainHub'=>3, 'Simon Initiative'=>2, 'Swartz Center'=>1, 'Null'=>0};
global Map<String, Integer> comparePriority = new Map<String, Integer> {'Health and Wellness' => 5, 'Athletics'=> 4, 'Library' => 3, 'Student Affairs' => 2, 'Academic Affairs' => 1, 'Null' => 0};
global Map<String, Integer> compareSchools = new Map<String, Integer> {'CFA' => 7, 'MCS' => 6, 'CIT' => 5, 'DC' => 4, 'SCS' => 3, 'Heinz' => 2, 'Tepper' => 1, 'Null' => 0};  
global Map<String, String> schoolNameFix = new Map<String, String>{'College of Fine Arts'=>'CFA', 'Mellon College of Science'=>'MCS', 'Carnegie Institute of Technology'=>'CIT', 'College of Engineering'=>'CIT',
                                                                   'Computer Science'=>'SCS', 'School of Computer Science'=>'SCS', 'Software Engineering Institute'=>'SCS',
                                                                   'Heinz School'=>'Heinz', 'Heinz College'=>'Heinz', 'Humanities and Social Sciences'=>'DC', 'Dietrich College of H and SS'=>'DC', 'Dietrich College'=>'DC', 
                                                                   'Industries'=>'Tepper', 'Industrial Management'=>'Tepper','Margaret Morrison'=>'Margaret Morrison', 'Printing Management'=>'Print Management', 
                                                                   'Indust Mgmt (Graphic Comms Mgmt)'=>'Tepper', 'Graduate School of Industrial Admin.'=>'Tepper', 'Tepper School of Business'=>'Tepper', 'Multiple Schools'=>'Multiple'};
//global List<Id> exclusions = new List<Id>{'001f400000oMAjCAAW', '001f400000oLkpZAAS' , '001f400000oLnTLAA0' , '001f400000oLzf9AAC' , '001f400000oLnT5AAK' , '001f400000oMCFCAA4'};                                                           
//global List<String> homeland = new List<String>{'US', 'U.S.', 'USA', 'U.S.A.', 'US of A', 'U.S. of A.', 'United States', 'United States of America', 'America', 'Merica', 'Land of the Free'};
global Date yesterday = System.today()-1;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, AQB__AccountType__c, AQB__Capacity__c, AQB__BillingAddressCountryId__c, Parent_School_Affiliation__c, '+
                                        'Strategic_Initiative_Interest__c, University_Priorities_Interest__c, University_Priorities_Gifts__c, Primary_Contact_Alum__c, Primary_Contact_School__c, ' +
                                        'Secondary_Contact_Alum__c, Secondary_Contact_School__c, Dual_Affiliate__c, MSCF_Gift_or_Interest__c, President_s_Global_Advisory_Council__c, ' +
                                        'Pachinko_Input__c, General_Category__c, Specific_Category__c, Clean_Country__c, Clean_Iso_Country__c, BillingCountry, BillingCity, BillingStreet, ' +
                                        'Capacity_Rating__c, Contact_Count__c, AQB__PrimaryContact__c, AQB__SecondaryContact__c  ' +
                                        'FROM Account WHERE RecordType.Name = \'Household\' AND (AQB__AccountStatus__c = \'Active\' OR AQB__AccountStatus__c = \'Restricted Contact\')  ' +
                                        'AND AQB__AccountType__c != \'Student\' AND AQB__PrimaryContact__c != NULL  AND Pachinko_Assignment_Comment__c = NULL ');
                                        
                                        
                                        //'AND LastModifiedDate < yesterday   AND AQB__AccountType__c != \'Student\' AND AQB__PrimaryContact__c != NULL  AND Pachinko_Assignment_Comment__c = NULL  ');
                                        //'AND AQB__AccountType__c != \'Student\' AND Contact_Count__c > 0');
                                        //'AND ID NOT IN : exclusions AND AQB__AccountType__c != \'Student\'  ');
                                        //'FROM Account WHERE Run_Pachinko_Assignment__c = FALSE AND Pachinko_Assignment_Comment__c = null');
    }
    
    
    global void execute(Database.BatchableContext bc, List<Account> scope){
        recordsProcessed += scope.size();
        acctList = scope;
        acctMap = new Map<Id, Account>(scope);
          System.debug('In execute method, first assignment of acctMap is: ' + acctMap);
          System.debug('In execute method, acctMap Size is: ' + acctMap.size() );
        
        contacts = [SELECT Id, AccountId, Account.Parent_School_Affiliation__c, AQB__School__c, AQB__Age__c, Primary_School__c,  
                    AQB__IsPrimaryContact__c, AQB__Relationship__c, AQB__Type__c, AQB__SecondaryType__c 
                    FROM Contact WHERE AccountId IN :scope]; 
        contactMap = new Map<Id, Contact>(contacts);
          System.debug('In execute method, first assignment of contactMap is: ' + contactMap);
          System.debug('In execute method, contactMap Size is:: ' + contactMap.size() );  
        wipeout();
        findInterests();
        findGifts();
        findSchools();
        findParentSchoolAffil();
        findMultiSchool();
        findPGAC();
        findDonorComp();
        assign();
        Database.update(acctList, false);        
    }//End of execute()================================================================================================================================================
    
    global void wipeout(){
        for (Account a : acctList){
            a.Parent_School_Affiliation__c = null;
            a.Strategic_Initiative_Interest__c = null;
            a.Strategic_Initiative_Gift__c = null;
            a.University_Priorities_Interest__c = null;
            a.University_Priorities_Gifts__c = null;
            a.Primary_Contact_Alum__c = false;
            a.Primary_Contact_School__c = null;
            a.Secondary_Contact_Alum__c = false;
            a.Secondary_Contact_School__c = null;
            a.Dual_Affiliate__c = false;
            a.MSCF_Gift_or_Interest__c = false;
            a.President_s_Global_Advisory_Council__c = FALSE;
            a.Donor_Compass_Prospect__c = FALSE;
            a.Pachinko_Input__c = null;
            a.General_Category__c = null;
            a.Specific_Category__c = null;
            a.Run_Pachinko_Assignment__c = FALSE;    
        }      
    }//end of wipeout()=================================================================================================================================================
    

    
    
    
    
    
    global void findInterests(){        
    List<AQB__Interest__c> interests = [SELECT AQB__Contact__r.AccountID, AQB__LLInterestType__r.Name
                                        FROM AQB__Interest__c
                                        WHERE  AQB__Contact__r.AccountID IN :acctList
                                        AND Interest_Prospect_Indicator__c = TRUE
                                        AND AQB__LLInterestType__r.Name != NULL]; 
        
        
     System.debug('In findInterests method, checking the contents of acctMap: ' + acctMap);   
        
        
        for(AQB__Interest__c i : interests){ 
            Account a = acctMap.get(i.AQB__Contact__r.AccountID);    
                    
            String interestName = i.AQB__LLInterestType__r.Name;
            if( interestName.contains('Health')  || interestName.contains('health')  ) {interestName = 'Health and Wellness';}
            
            String sii = a.Strategic_Initiative_Interest__c;
            if (sii == null){sii = 'Null';}
            
            String upi = a.University_Priorities_Interest__c;
            if (upi == null){upi = 'Null';}
            
            if (compareStrategic.ContainsKey(interestName)) {
                if(compareStrategic.get(interestName) > compareStrategic.get(sii)){
                    a.Strategic_Initiative_Interest__c = interestName; 
                    System.debug('Strategic Interest: ' + a.Strategic_Initiative_Interest__c);
                } 
            }
            
            if (comparePriority.ContainsKey(interestName)) {
                if(comparePriority.get(interestName) > comparePriority.get(upi)){
                    a.University_Priorities_Interest__c = interestName; 
                    System.debug('University Priorities Interest: ' + a.University_Priorities_Interest__c);
                }
            }
            
            if ( interestName.contains('Computational Finance')  || interestName.contains('MSCF') ) {
                a.MSCF_Gift_or_Interest__c = TRUE;
            }

        }
    }//End of findInterests()=======================================================================================================================================
        
    //global Map<String, Integer> comparePriority = new Map<String, Integer> {'Health and Wellness' => 5, 'Athletics'=> 4, 'Library' => 3, 'Student Affairs' => 2, 'Academic Affairs' => 1, 'Null' => 0};
    //global Map<String, Integer> compareStrategic = new Map<String, Integer>{'BrainHub'=>3, 'Simon Initiative'=>2, 'Swartz Center'=>1, 'Null'=>0};

    global void findGifts(){    
        
    List<String> studentAffairsDesignations = new List<String>{'750100','750103','750106','750110','750131','750130','750140','750141','750150','750152','750160',
                                                               '750200','750210','750220','750221','750250','750301','750300','750420','760000','760010','770000','710410'}; 
        
     
        
    List<AQB__Transaction__c> gifts = [SELECT AQB__Account__c, AQB__ChartofAccounts__r.Name, AQB__ChartofAccounts__r.AQB__Account_Sub_Type__c, 
                                       AQB__ChartofAccounts__r.AQB__DesignationAccountNumberGroupFour__c, AQB__ChartofAccounts__r.AQB__Department__c, AQB__Date__c
                                       FROM AQB__Transaction__c
                                       WHERE  AQB__Account__c IN :acctList];


        System.debug('In findgifts method, checking the contents of acctMap: ' + acctMap);   


        for(AQB__Transaction__c g : gifts){ 
            Account a = acctMap.get(g.AQB__Account__c);    

            String designationName = g.AQB__Chartofaccounts__r.Name;
            String dagFour = g.AQB__ChartofAccounts__r.AQB__DesignationAccountNumberGroupFour__c;
            Date transDate = Date.newInstance(2016,11,01);
            
            if (designationName =='Academic Development') {designationName = 'Academic Affairs'; }
            
            if (g.AQB__ChartofAccounts__r.AQB__Account_Sub_Type__c == 'Athletics' || g.AQB__ChartofAccounts__r.AQB__Department__c == 'Athletics Department') {designationName = 'Athletics';}
            if (g.AQB__ChartofAccounts__r.AQB__Account_Sub_Type__c == 'Library Support' || g.AQB__ChartofAccounts__r.AQB__Department__c == 'Library') {designationName = 'Library';}
            if(studentAffairsdesignations.contains(dagFour)){designationName = 'Student Affairs';}
            
            if(dagFour == '100012'){designationName = 'BrainHub';}
            if(dagFour == '100008'){designationName = 'Simon Initiative';}
            if(dagFour == '100016'){designationName = 'Swartz Center';}
            if( (dagFour == '233050') && (g.AQB__Date__c >= transDate) ){designationName = 'Swartz Center';}
            
            if (designationName != NULL) {
                if (designationName.contains('Computational Finance') || designationName.contains('MSCF') ) {a.MSCF_Gift_or_Interest__c = TRUE;}
            } 
            
            //if (designationName.contains('Student Affair') &&  (  !designationName.contains('Tepper')  && !designationName.contains('Heinz')  )  ) {designationName = 'Student Affairs'; }
            //if (g.AQB__ChartofAccounts__r.AQB__DesignationAccountNumberGroupFour__c == 'Student Programs') {designationName = 'Student Affairs';}                      
            //if (designationName.contains('Athletics') && !designationName.contains('health') ) {designationName = 'Athletics';}
            
            
            String upg = a.University_Priorities_Gifts__c;
            if (upg == null){upg = 'Null';}
            
            if (comparePriority.ContainsKey(designationName)) {
                if(comparePriority.get(designationName) > comparePriority.get(upg)){
                    a.University_Priorities_Gifts__c = designationName;   
                } 
            }
               
            
            String sig = a.Strategic_Initiative_Gift__c;
            if (sig == null){sig = 'Null';}
            
            if (compareStrategic.ContainsKey(designationName)) {
                if(compareStrategic.get(designationName) > compareStrategic.get(sig)){
                    a.Strategic_Initiative_Gift__c = designationName;   
                } 
            }                    

        }
    }//end of findGifts()============================================================================================================================================


    
    
    global void findSchools(){   

    System.debug('In findSchools method, checking the contents of acctMap: ' + acctMap);   
   
        for (Contact c: contacts){
            if(c.AccountID != NULL){
                Account a = acctMap.get(c.AccountId);   
                if(  c.AQB__IsPrimaryContact__c == 'Yes'  ||  c.AQB__Relationship__c == 'Main Contact') { 
                    String mcPrimarySchool = c.Primary_School__c;
                    String mcRawSchool = c.AQB__School__c;
                    
                    if(schoolNameFix.ContainsKey(mcPrimarySchool)){
                        a.Primary_Contact_School__c = schoolNameFix.get(mcPrimarySchool);
                        a.Primary_Contact_Alum__c = TRUE;
                    }
                    
                    if(schoolNameFix.ContainsKey(mcRawSchool)){
                        mcRawSchool = schoolNameFix.get(mcRawSchool);
                    }                                      
                    
                    if(dualAffils.contains(mcRawSchool)){
                        a.Primary_Contact_School__c = mcRawSchool;
                        a.Dual_Affiliate__c = TRUE;
                    }
                    
                    if(mcRawSchool == 'Library'){
                        if(comparePriority.get(mcRawSchool) > comparePriority.get(a.University_Priorities_Interest__c)){
                            a.University_Priorities_Interest__c = 'Library';   
                        }
                    }        
                }  
                
                
                
                else if (c.AQB__Relationship__c == 'Additional Contact') {
                    String acPrimarySchool = c.Primary_School__c; 
                    String acRawSchool = c.AQB__School__c; 
                    
                    if(schoolNameFix.ContainsKey(acPrimarySchool)){
                        a.Secondary_Contact_School__c = schoolNameFix.get(acPrimarySchool);
                        a.Secondary_Contact_Alum__c = TRUE;
                    }
                    
                    if(schoolNameFix.ContainsKey(acRawSchool)){
                        acRawSchool = schoolNameFix.get(acRawSchool);
                    }                    
                    
                    if(dualAffils.contains(acRawSchool)){
                        a.Secondary_Contact_School__c = acRawSchool;
                        a.Dual_Affiliate__c = TRUE;                                
                    }
                    
                    if(acRawSchool == 'Library'){
                        if(comparePriority.get(acRawSchool) > comparePriority.get(a.University_Priorities_Interest__c)){
                            a.University_Priorities_Interest__c = 'Library';   
                        }
                    }                           
                }         
            } 
        }    
    }//END of findSchools()=======================================================================================================================================


    
    
    global void findParentSchoolAffil(){   
      List<Parent_Affiliation__c> affils = [SELECT Name, School__c, Contact__c, Child_Contact_Record__c, Contact__r.AccountId, Contact__r.Account.Parent_School_Affiliation__c 
                                            FROM Parent_Affiliation__c
                                            WHERE Contact__c IN :contacts];

        System.debug('In findParentSchoolAffils method, checking the contents of acctMap: ' + acctMap);

        for (Parent_Affiliation__c pa : affils) {
            Account a = acctMap.get(pa.Contact__r.AccountId);    
            String school = schoolNameFix.get(pa.School__c);   
            String psa = a.Parent_School_Affiliation__c;
            if (psa == NULL){psa ='Null';}
            if (compareSchools.ContainsKey(school)) {
                if(compareSchools.get(school) > compareSchools.get(psa)){ 
                    a.Parent_School_Affiliation__c = school;    
                }                                
            }              
        }       
    }//END of findParentSchoolAffil()=============================================================================================================================               
 

    
    
    global void findMultiSchool(){
        List<AQB__Education__c> edus = [SELECT ID, AQB__Contact__c, AQB__Contact__r.AccountId, AQB__School__c, AQB__DegreeLevel__c, Major_1__r.Name
                                         FROM AQB__Education__c
                                         WHERE AQB__Contact__r.AccountId IN :acctList
                                         AND RecordType.Name = 'Institutional'
                                         AND Status__c = 'Completed'
                                         AND AQB__Contact__r.AQB__IsPrimaryContact__c = 'YES'];
        for (Account ac : acctList){ 
        Set<String> schools = new Set<String>();
            for(AQB__Education__c ed : edus){           
                if(ed.AQB__Contact__r.AccountID == ac.Id){ 
                    schools.add(schoolNameFix.get(ed.AQB__School__c));
                    if(ed.AQB__DegreeLevel__c == 'Master\'s Degree' && ed.Major_1__r.Name == 'Computational Finance' ) {ac.MSCF_Gift_or_Interest__c = TRUE;}                
                }   
            }
            if(schools.size() > 1){
                ac.Primary_Contact_School__c = 'Multiple';
            }
            if(schools.contains('Carnegie Mellon University')){
                ac.Dual_Affiliate__c = TRUE;
            }
        }
    }//END of findMultiSchool()==================================================================================================================================
  
    
    
 
    global void findPGAC(){
        List<AQB__VolunteerPosition__c> vpList = [SELECT ID, AQB__Contact__c, AQB__Contact__r.AccountId, AQB__AffiliatedOrganization__c
                                                    FROM AQB__VolunteerPosition__c
                                                    WHERE AQB__AffiliatedOrganization__r.Name = 'President\'s Global Advisory Council'
                                                    AND AQB__Contact__c IN : contacts];      
        for(AQB__VolunteerPosition__c vp : vpList){
            Account a = acctMap.get(vp.AQB__Contact__r.AccountId);      
            if(vp.AQB__Contact__r.AccountId == a.Id){
                a.President_s_Global_Advisory_Council__c = TRUE;
            }
        }        
    }//END of findPGAC()==========================================================================================================================================
    


    
    global void findDonorComp(){
        
            
     System.debug('In findDonorCompScore method, checking the contents of acctMap: ' + acctMap);
     System.debug('In findDonorCompScore method, acctMap Size is: ' + acctMap.size() );   
     System.debug('In findDonorCompScore method, checking the contents of contactMap: ' + contactMap);    
     System.debug('In findDonorCompScore method, contactMap Size is: ' + contactMap.size() );           
        
        
        List<Prospect_Rating__c> donorComps = [SELECT ID, Account__c, Donor_Compass_Score__c 
                                              FROM Prospect_Rating__c
                                              WHERE Donor_Compass_Score__c >= 17
                                              AND Account__c IN :acctList];

    System.debug('In findDonorCompScore method, donorComps found: ' +donorComps.size() );
        if(donorComps.size() > 0){            
            for (Prospect_rating__c dc : donorComps){
                Account a = acctMap.get(dc.Account__c); 
                Contact c = contactMap.get(a.AQB__PrimaryContact__c);

                try{
                    if(c.AQB__Age__c >= 51){
                        a.Donor_Compass_Prospect__c = TRUE; 
                    }
                } catch(Exception e){
                    System.debug('Exception in Donor Comp Score '+ e.getMessage());
                } finally{
                    return;      
                }                      
            }            
        }
    } //END of findDonorComp()==========================================================================================================================================





    
    global void assign() {
        for(Account a : acctList){
            if(a.AQB__AccountType__c == 'Trustee'){a.Pachinko_Input__c = 'Board of Trustees';}
                else if(a.President_s_Global_Advisory_Council__c == TRUE){a.Pachinko_Input__c = 'President\'s Global Advisory Council';}  
                    else if(capValues.contains(a.Capacity_Rating__c)) {a.Pachinko_Input__c = 'Rated $5M+' ;}
                        //else if(a.BillingCountry!=NULL  &&   !homeland.contains(a.BillingCountry) ) {a.Pachinko_Input__c = 'International';}
                        else if(a.Clean_Country__c != 'US' && (a.BillingCity != NULL && a.BillingStreet != NULL) ) {a.Pachinko_Input__c = 'International';}
                            else if(a.AQB__AccountType__c == 'Parent') {a.Pachinko_Input__c = 'Parents (Non-Alum/Trustee) / ' + a.Parent_School_Affiliation__c;}
								else if(a.Strategic_Initiative_Gift__c != NULL) {a.Pachinko_Input__c = a.Strategic_Initiative_Gift__c;}            
                                	else if(a.Strategic_Initiative_Interest__c != NULL) {a.Pachinko_Input__c = a.Strategic_Initiative_Interest__c;}
            							else if(a.University_Priorities_Interest__c != NULL) {a.Pachinko_Input__c = 'Interest - ' + a.University_Priorities_Interest__c;}
            						        else if(a.University_Priorities_Gifts__c != NULL) {a.Pachinko_Input__c = 'Giving - ' + a.University_Priorities_Gifts__c;}                            
                                                else if(a.MSCF_Gift_or_Interest__c == TRUE) {a.Pachinko_Input__c = 'MSCF';}
                                                    else if(a.Primary_Contact_School__c == 'Multiple') {a.Pachinko_Input__c = 'Attended 2+ schools';}
                                                        else if(  (a.Primary_Contact_School__c != NULL && a.Secondary_Contact_School__c !=NULL)  
                                                                 && ( schoolNameFix.get(a.Primary_Contact_School__c) != schoolNameFix.get(a.Secondary_Contact_School__c) )  ) 
                                                                 {a.Pachinko_Input__c = 'Spouse Attended Different School';}
                                                            else if(a.Primary_Contact_School__c == 'Margaret Morrison'){a.Pachinko_Input__c = 'MM School';}
                                                                else if(a.Primary_Contact_School__c == 'Print Management'){a.Pachinko_Input__c = 'PM School';}
                                                                    else if(a.Dual_Affiliate__c == TRUE) {a.Pachinko_Input__c = 'Dual Affiliate';}
           																else if(a.Donor_Compass_Prospect__c == TRUE) {a.Pachinko_Input__c = 'Donor Compass Prospect';}
                                                                        	else if(a.Primary_Contact_School__c != NULL) {a.Pachinko_Input__c = 'School Indicator = ' + a.Primary_Contact_School__c;}            																	
            																	else if(a.AQB__AccountType__c == 'Faculty'){a.Pachinko_Input__c = 'Faculty';}            																		
            																		else if(a.AQB__AccountType__c == 'Staff'){a.Pachinko_Input__c = 'Staff';}
                                                                            			else {a.Pachinko_Input__c = 'No Pachinko Category';}
        }
        System.debug('Rules List: ' + rules);
        for(Account a : acctList){
            for(Pachinko__c rule : rules){
                if (a.Pachinko_Input__c == rule.Rule__c){
                    a.General_Category__c = rule.General_Category__c;
                    a.Specific_Category__c = rule.Specific_category__c;
                }
            }
        }
    }//End of assign()===========================================================================================================================================    

    
    
    

    global void finish(Database.BatchableContext bc){    
        //UnknownClass uc = new UnknownClass(accList);       
        System.debug('Contacts processed with a new Pachinko: ' + recordsProcessed);
        
        if(AQCMU_Util.canSendEmail() ){
            AQCMU_Util.sendFinishResultsEmail(
                bc,
                'PachinkoCalc Batch Has Completed',
                'Contacts processed with a new Pachinko: ' + recordsProcessed,
                false);
        } 
    }//END of finish() method


}//END of PachinkoCalc class