/*
 * Mass Email Search Controller -- supports the MassEmailSearch VisualForcepage
 *  Author: Josh Howell  10/2018
 * 
 * Updated 2/5/19 -- to include additional search parameters for Advance ID and generate CSV class -- JH
 * Update 3/25/19 -- to add new functionality to the Event for regDate, regStatus, and noShow indicator -- JH
 * Update 4/29/19 -- Fixed an issue with the pagination and added record count numbers --  JH
 * Update 5/18/21 -- changed Card Id query to search Alternate Channels / Changed Email query to search all emails on Contact / consolidated redundant queries -- JH
 * 
 * Test Coverage =  MassEmailSearchController_Test -- covers at 93%
 */


public class MassEmailSearchController {

    public String searchType {get; set;}   
    public String selectedCampaign {get; set;}
    public String selectedEvent {get; set;}

    public String input {get; set;}  //List of Emails input into the inputTextArea field 
    public List<String> inputs {get; set;}  //Input String broken into list elements
    public static List<Contact> results {get; set;}  //List of Contacts returned from the query
    public List<contact> shortResults {get; set;} // List that holds just the IDs for viewstate
    public List<Contact> contactsToShow {get; set;}  //List to show in the paginated grid
    
    public String campOrEventName {get; set;}  //For capturing new campaign name from input
    
    public Id CampaignId {get; set;}  //For retrieving available Campaign ID's

    public List<Campaign> myCamps {get; set;}
    public Map<String, Campaign> campMap = new Map<String, Campaign>();
       
    public Id EventId {get; set;}  //For retrieving available Event ID's
    public List<AQB__Event__c> myEvents {get; set;}
    public Map<String, AQB__Event__c>eventMap = new Map<String, AQB__Event__c>();
    
    public Integer counter = 0;     //To track the number of records parsed  
    public Integer limitSize = 20;  //Number of records to be displayed
    public Integer totalSize = 0;   //Total number of records available in 'results' list
    
    public String message {get; set;}
    public String message2 {get; set;}
    public Boolean resultsHasValues {get; set;}
    
    public Date regDate {get; set;} 
    public String regStatus {get; set;}
    public Boolean noShow {get; set;} 
    

    
//Initial methods to load search type selections, create the correct query string, and perform the initial query.................................................................................................

    public List<SelectOption> getSearchTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Email','Email Address'));
        options.add(new SelectOption('AID','Advance ID'));
        options.add(new SelectOption('CID','Card ID'));
        options.add(new SelectOption('SFID','Salesforce ID'));
        return options;
    } 


    public List<SelectOption> getRegStatuses() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Invited','Invited'));
        options.add(new SelectOption('Preregistered','Preregistered'));
        options.add(new SelectOption('Registered','Registered')); 
        return options;
    }    
    


    
    public void search(){ 
        if (searchType == 'Email') {
            if(input.contains(',')){
                inputs = input.split(','); 
            }            
            else if(input.contains(' ')) {
                inputs = input.split(' '); 
            }
            else{
                inputs = input.split('\n'); 
            }
        results = [SELECT LastName, FirstName, Account.Name, Email, Contact_External_ID_Clean__c, Inst_Suffix__c, 
                  Card_ID__c, Id, Contact_15_Digit_ID__c, Contact_18_Digit_ID__c, Link__c, Account_Link__c 
                  FROM Contact 
                  WHERE RecordType.Name = 'Advancement Contact'
                  AND AQB__Type__c != 'Event Registrant'
                  AND (Email IN :inputs
                  OR AQB__PersonalEmail__c IN :inputs
                  OR AQB__BusinessEmail__c IN :inputs
                  OR AQB__OtherEmail__c IN :inputs)
                  ORDER BY LastName ASC];
        totalSize = results.size();              
        }
        

        else if (searchType == 'AID'){
            if (input.contains(',')){
                inputs = input.split(',');            
            }
            else if (input.contains(' ')){
                inputs = input.split(' ');             
            }
            else{
                inputs = input.split('\n');  
            }
            results = [SELECT LastName, FirstName, Account.Name, Email, Contact_External_ID_Clean__c, Inst_Suffix__c, Id, 
                      Card_ID__c, Contact_15_Digit_ID__c, Contact_18_Digit_ID__c, Link__c, Account_Link__c 
                      FROM Contact WHERE Contact_External_ID_Clean__c IN :inputs ORDER BY LastName ASC];
            totalSize = results.size();
        }

        
        else if (searchType == 'CID'){
            if (input.contains(',')){
                inputs = input.split(',');           
            }
            else if (input.contains(' ')){
                inputs = input.split(' ');              
            }
            else{
                inputs = input.split('\n');
            } 
            List<AQB__AlternateId__c> cardIDs = [SELECT Id, AQB__NonuniqueAlternateId__c , AQB__ContactReferenced__c 
                                                FROM AQB__AlternateId__c 
                                                WHERE AQB__Type__c = 'CARD ID' 
                                                AND AQB__NonuniqueAlternateId__c IN :inputs];  
            List<Id> foundIDs = new List<Id>();
                for(AQB__AlternateId__c altId : cardIDs){
                    foundIDs.add(altId.AQB__ContactReferenced__c);
                }
            results = [SELECT LastName, FirstName, Account.Name, Email, Contact_External_ID_Clean__c, Inst_Suffix__c, 
                      Card_ID__c, Id, Contact_15_Digit_ID__c, Contact_18_Digit_ID__c, Link__c, Account_Link__c 
                      FROM Contact 
                      WHERE RecordType.Name = 'Advancement Contact' 
                      AND AQB__Type__c != 'Event Registrant'
                      AND Id IN :foundIDs ORDER BY LastName ASC];
            totalSize = results.size();           
        }
        
        else{
            if (input.contains(',')){
                inputs = input.split(',');            
            }
            else if (input.contains(' ')){
                inputs = input.split(' ');                
            }
            else{
                inputs = input.split('\n');  
            }
            results = [SELECT LastName, FirstName, Account.Name, Email, Contact_External_ID_Clean__c, Inst_Suffix__c, 
                      Card_ID__c, Id, Contact_15_Digit_ID__c, Contact_18_Digit_ID__c, Link__c, Account_Link__c 
                      FROM Contact WHERE ID IN :inputs ORDER BY LastName ASC];
            totalSize = results.size();                      
        }     

        ShortResults = [SELECT Id FROM Contact WHERE Id IN :results];
        
        contactsToShow = new List<Contact>();
        if ((counter+limitSize) <= totalSize){
            for(Integer i=0; i<limitSize; i++){
                contactsToShow.add(results.get(i));              
            }
        }
        else{
            for(Integer i=0; i<totalSize; i++){
                contactsToShow.add(results.get(i));                
            }
        }  
        message = 'Found '+ results.size() + ' Contacts from your Input List of ' + inputs.size() +':' ;             
    }
   
 
    
 
//Create and Query CAMPAIGN methods.....................................................................................................
    

    public PageReference createCampaign(){ 
        
        if(campOrEventName == ''){
            campOrEventName = UserInfo.getName()+' New Campaign '+System.Datetime.Now();   
            System.debug('campOrEventName = '+ campOrEventName);
        }
            
        Campaign camp = new Campaign();    
        camp.Name = campOrEventName;
        camp.RecordTypeId=Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Contact Communication List').getRecordTypeId();
        camp.IsActive = TRUE;   
        insert camp;
        
        CampaignMemberStatus cms = New CampaignMemberStatus(CampaignId=camp.Id, HasResponded=false, Label='Planned'); 
        insert cms;
        
        List<CampaignMember> cmlist = new List<CampaignMember>();
        for (Contact c : shortResults){
            cmlist.add(new CampaignMember(ContactId=c.Id, CampaignId=camp.Id, status='Planned'));            
        }
        insert cmlist; 
        
   //     For (CampaignMember cm :cmlist){
   //         cm.status='Planned';
   //     }
   //     update cmlist;
        
        PageReference pr = new PageReference('/'+ camp.Id);
        return pr;    
    }
    
   
    
    public pageReference updateCampaign(){
        Campaign camp = campMap.get(selectedCampaign); 
          System.debug('Selected Campaign is: '+ selectedCampaign + 'and ID is '+ camp.Id);
        List<CampaignMember> existingMembers = [SELECT Id, ContactID FROM CampaignMember 
                                                WHERE Campaign.Name = :selectedCampaign
                                                AND ContactId IN :shortResults];
        
        Set<Id> existingContactIDs = new Set<Id>();        
        for(CampaignMember cm : existingMembers){
            existingContactIDs.add(cm.ContactId);       
        }  
        
        List<CampaignMember> cmlist = new List<CampaignMember>();        
        
        for(Contact c : shortResults){
            if (!existingContactIDs.contains(c.Id)){
                cmlist.add(new CampaignMember(ContactId=c.Id, CampaignId=camp.Id)); 
            }
        }
          System.debug('Trying to add these Ids: '+ cmList);
        insert cmlist;
          System.debug('Insert Complete');
        pageReference pr = new PageReference('/'+ camp.Id);
        return pr;     
    }   
    
    
    
    public void loadCampaigns(){
        myCamps = [SELECT Id, Name FROM Campaign WHERE OwnerId =:UserInfo.getUserId() ]; 
          System.debug('Campaigns found for you: ' + myCamps);
    }  
   
    

    public List<SelectOption> getCampaigns() {
        List<SelectOption> options = new List<SelectOption>();
        for (Campaign c : myCamps) {
            options.add(new SelectOption(c.Name, c.Name));
            campMap.put(c.Name, c);
        }
        return options;
    }

 
    
    public pageReference campaignPage(){
        PageReference pr = new PageReference('/apex/MassEmailAddCampaign');
        return pr;              
    }
    
  
    

    
//Create and Query EVENT methods......................................................................................................    

    public pageReference createEvent(){  
        if(campOrEventName == ''){
            campOrEventName = UserInfo.getName()+' New Event '+System.Datetime.Now();
        }       
        AQB__Event__c event = new AQB__Event__c();
        event.Name = campOrEventName;
        event.RecordTypeId = Schema.SObjectType.AQB__Event__c.getRecordTypeInfosByName().get('Institutional Event').getRecordTypeId();
        event.AQB__Status__c = 'Planned';
        event.AQB__StartDateandTime__c = Datetime.now();
        event.AQB__StopDateandTime__c = Datetime.now().addDays(7);
        insert event;
        
        List<AQB__Registration__c> regList = new List<AQB__Registration__c>();
        for (Contact c : shortResults){
            AQB__Registration__c reg = new AQB__Registration__c();
            reg.AQB__Contact__c=c.Id;   
            reg.AQB__Event__c=event.Id;
            if(regDate != NULL){reg.AQB__Date_of_Registration__c  = regDate;}
                else{reg.AQB__Date_of_Registration__c=System.today();}
            if(regStatus != NULL) {reg.Registration_Status__c = regStatus;}
                else{reg.Registration_Status__c='Invited';}
            regList.add(reg);
        }      
        insert reglist;        
        
        List<AQB__EventGuest__c> guestList = new List<AQB__EventGuest__c>();
        for(AQB__Registration__c r : regList){
            AQB__EventGuest__c eg = new AQB__EventGuest__c();
            eg.AQB__Event_Registration__c = r.Id;
            eg.AQB__Contact__c = r.AQB__Contact__c;
            if(noShow != NULL){eg.No_Show__c = noShow;}
                else{eg.No_Show__c = FALSE;}
            guestlist.add(eg);             
        }
        System.debug('adding guestList: '+ guestList);
        insert guestList;
 
        pageReference pr = new PageReference('/'+event.Id);
        return pr;    
    }  
    

    
        public pageReference updateEvent(){
        AQB__Event__c event = eventMap.get(selectedEvent);
        
        System.debug('Selected Event is: '+ selectedEvent);
        List<AQB__Registration__c> existingReg = [SELECT Id, AQB__Contact__c FROM AQB__Registration__c WHERE AQB__Event__r.Name = :selectedEvent];        
        List<ID> existingRegIDs = new List<ID>();        
        for(AQB__Registration__c er : existingReg){
            existingRegIDs.add(er.AQB__Contact__c);       
        }
        System.debug('existing contact Ids: '+ existingRegIDs);
        
        List<AQB__Registration__c> reglist = new List<AQB__Registration__c>();        
        for(Contact c : shortResults){
            if (!existingRegIDs.contains(c.Id)){
                AQB__Registration__c reg = new AQB__Registration__c();
                reg.AQB__Contact__c=c.Id;   
                reg.AQB__Event__c=event.Id;
                if(regDate != NULL){reg.AQB__Date_of_Registration__c  = regDate;}
                    else{reg.AQB__Date_of_Registration__c=System.today();}
                if(regStatus != NULL) {reg.Registration_Status__c = regStatus;}
                    else{reg.Registration_Status__c='Invited';}
                regList.add(reg);
            }
        }
        System.debug('adding regList: '+ regList);
        insert regList;
            
        List<AQB__EventGuest__c> guestList = new List<AQB__EventGuest__c>();
        for(AQB__Registration__c r : regList){
            AQB__EventGuest__c eg = new AQB__EventGuest__c();
            eg.AQB__Event_Registration__c = r.Id;
            eg.AQB__Contact__c = r.AQB__Contact__c;
            if(noShow != NULL){eg.No_Show__c = noShow;}
                else{eg.No_Show__c = FALSE;}
            guestlist.add(eg);             
        }
        System.debug('adding guestList: '+ guestList);
        insert guestList;        
            
        pageReference pr = new PageReference('/'+ event.Id);
        return pr;     
    }   
    
    
    
    public void loadEvents(){
        myEvents = [SELECT Id, Name FROM AQB__Event__c
                    WHERE OwnerId =:UserInfo.getUserId()
                    AND (AQB__Status__c != 'Completed'
                    AND AQB__Status__c != 'Complete')]; 
    }  
   
    

    public List<SelectOption> getEvents() {
        List<SelectOption> options = new List<SelectOption>();
        for (AQB__Event__c e: myEvents) {
            options.add(new SelectOption(e.Name, e.Name));
            eventMap.put(e.Name, e);
        }
        return options;
    }

 
    
    public pageReference eventPage(){
        PageReference pr = new PageReference('/apex/MassEmailAddEvent');
        return pr;              
    }
    
    
    

    
// Method to call the CSV Generate Class... Creates a CSV of Contacts and Emails it to the User 
    
    public void createCSV(){ 
        System.debug('Calling generateCSV with results: ' + results);
        message2 = 'Your Contacts file has been emailed to you.';
        search();     
        MassEmailGenerateCSV gen = new MassEmailGenerateCSV(results);
    }

    



//Button navigation methods below........................................................................................................       
        
    public void beginning(){
    List<Contact> parse = [SELECT LastName, FirstName, Account.Name, Email, Contact_External_ID_Clean__c, Inst_Suffix__c, 
                           Id, Card_ID__c, Contact_15_Digit_ID__c, Contact_18_Digit_ID__c, Link__c, Account_Link__c 
                           FROM Contact WHERE ID IN :shortResults ORDER BY LastName ASC]; 
        ContactsToShow.clear();
        counter=0;
        if((counter + limitSize) <= totalSize){       
            for(Integer i=0; i<limitSize; i++){
                ContactsToShow.add(parse.get(i));
            }
            message = 'Viewing 1 to 20 of '+ parse.size(); 
             
        }
        else{       
            for(Integer i=0; i<totalSize; i++){
                ContactsToShow.add(parse.get(i));
            }              
        }     
    }    



    public void next(){
    List<Contact> parse = [SELECT LastName, FirstName, Account.Name, Email, Contact_External_ID_Clean__c, Inst_Suffix__c, 
                           Id, Card_ID__c, Contact_15_Digit_ID__c, Contact_18_Digit_ID__c, Link__c, Account_Link__c 
                           FROM Contact WHERE ID IN :shortResults ORDER BY LastName ASC];    
        
        ContactsToShow.clear();
        
        counter = counter + limitSize;       
        if((counter + limitSize) <= totalSize){
            for(Integer i=counter; i<(counter+limitSize); i++){
                ContactsToShow.add(parse.get(i));
            }
            message = 'Viewing ' + ((counter + 20) -19) +' to '+ (counter + 20) + ' of '+ parse.size();   
        } 
        
        else{
            for(Integer i=counter; i<totalSize; i++){
                ContactsToShow.add(parse.get(i));
            }
            message = 'Viewing ' + ((counter + 20) -19) +' to '+ totalSize + ' of '+ parse.size();
        }      
    }

   
    public void previous(){
    List<Contact> parse = [SELECT LastName, FirstName, Account.Name, Email, Contact_External_ID_Clean__c, Inst_Suffix__c, 
                           Id, Card_ID__c, Contact_15_Digit_ID__c, Contact_18_Digit_ID__c, Link__c, Account_Link__c 
                           FROM Contact WHERE ID IN :shortResults ORDER BY LastName ASC]; 
        ContactsToShow.clear();
        counter = counter - limitSize;    
        for(Integer i=counter; i<(counter+limitSize); i++){
            ContactsToShow.add(parse.get(i));
        }
        message = 'Viewing ' + (counter + 1) + ' to '+ (counter + 20) + ' of '+ parse.size();
    }


    public void last(){
    List<Contact> parse = [SELECT LastName, FirstName, Account.Name, Email, Contact_External_ID_Clean__c, Inst_Suffix__c, 
                           Id, Card_ID__c, Contact_15_Digit_ID__c, Contact_18_Digit_ID__c, Link__c, Account_Link__c 
                           FROM Contact WHERE ID IN :shortResults ORDER BY LastName ASC]; 
        ContactsToShow.clear();       
        if(math.mod(totalSize , limitSize) == 0){
            counter = limitSize * ((totalSize/limitSize)-1);
        } 
        else if (math.mod(totalSize , limitSize) != 0){
            counter = limitSize * ((totalSize/limitSize));
        }       
        for(Integer i=counter-1; i<totalSize-1; i++){
                ContactsToShow.add(parse.get(i));
        } 
        message = 'Viewing ' + counter + ' to '+ totalSize + ' of '+ parse.size();
    }
    
    
    public Boolean getDisableNext(){
        if((counter + limitSize) >= totalSize){
            return true;
        }    
        else{
            return false;
        }     
    }

   
    public Boolean getDisablePrevious(){  
        if(counter == 0){
            return true;
        }    
        else{
            return false;
        } 
    } 
    
    
    
    public Boolean resultsHasValues(){
        resultsHasValues = (results.size() > 0);
        return resultsHasValues;
    }
}