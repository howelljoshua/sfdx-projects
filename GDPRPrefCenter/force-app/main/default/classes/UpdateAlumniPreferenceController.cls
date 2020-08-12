/********************************************************************************
// Apex Class Name: UpdateAlumniPreferenceController
// Controller Class For Lightning Component : UpdateAlumniPreference
// Description: Controller Class For Lightning Component "UpdateAlumniPreference".
//
// 16 Jan 2019    Shivani Bhatia        Original
*********************************************************************************/

public without sharing class UpdateAlumniPreferenceController {
    /*
* @Name : getFieldSetMember
* @ReturnType : String
* @param : String objectName , String fieldSetName
* @Description : List all the Fields that are added into the FielsSet
*/
    @AuraEnabled 
    public static String getFieldSetMember(String fieldSetName){
        
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get('Marketing_Preference__c');
        
        List<FieldSetMemberWrapperClass> wrapperList = new List<FieldSetMemberWrapperClass>();
        List<Schema.FieldSetMember> fieldsList = new List<Schema.FieldSetMember>();
        
        fieldsList = FieldSetUtility.readFieldSet(fieldSetName);
        
        for(Schema.FieldSetMember fieldMember : fieldsList) {
            FieldSetMemberWrapperClass wrapper = new FieldSetMemberWrapperClass();
            wrapper.isDBRequired = fieldMember.getDbRequired();
            wrapper.isRequired = fieldMember.getRequired();
            wrapper.fieldType = String.valueOf(fieldMember.getType());
            wrapper.fieldLabel = fieldMember.getLabel();
            wrapper.fieldAPIName = fieldMember.getFieldPath();
            wrapperList.add(wrapper);
        }
        return JSON.serialize(wrapperList);
    }
    
    @auraEnabled
    public static AlumniPreferenceWrapperClass getAlumniPreference(String guid){
        
        AlumniPreferenceWrapperClass wrapper = new AlumniPreferenceWrapperClass();
        List<Contact> conList = new List<Contact>();
        Id conId;
        System.debug('UserTpe==>>'+UserInfo.getUserType());
        if(UserInfo.getUserType()=='Guest' || Test.isRunningTest()) {
            wrapper.isGuest = true;
            if(!String.isBlank(guid)) {
                conList = [SELECT Id, Name, Email, accountId, account.BillingAddress, account.Preferred_Region_1__c,account.Preferred_Region_2__c, account.Preferred_Region_3__c
                           FROM Contact
                           WHERE Public_GUID__c = :guid
                           LIMIT 1];
                if(conList.isEmpty()) {
                    wrapper.errorMessage = System.Label.ContactMissingError;
                    return wrapper;
                }
                else if(conList[0].accountId == Null ){
                    wrapper.errorMessage = System.Label.AccountMissingError;
                    return wrapper;
                }
                else{
                    if(conList[0].account.Preferred_Region_1__c != Null) {
                        wrapper.region1 = conList[0].account.Preferred_Region_1__c;
                    }
                    conId = conList[0].Id;
                    wrapper.conEmail = conList[0].Email;
                    wrapper.conId = conList[0].Id;
                    wrapper.accId = conList[0].accountId;
                    if(conList[0].account.BillingAddress != Null) {
                        wrapper.BillingAddress = conList[0].account.BillingAddress;
                        
                    }
                }
            }
            else{
                wrapper.errorMessage = System.Label.ContactMissingError;
                return wrapper;
            }       
        }
        else {
            wrapper.isGuest=false;
            wrapper.conEmail = UserInfo.getUserEmail();
            List<Account> accList = new List<Account>();
            List<User> usrList = new List<User>();
            usrList = [Select contactid, Profile.Name from User where id =: Userinfo.getUserid()];
            if(usrList[0].Profile.Name == 'System Administrator'){
                conList = [Select AccountID, Id from Contact WHERE Public_GUID__c = '1']; 
                if(!conList.isEmpty())
                    conId = conList[0].Id;
            }
            else{
                if(usrList[0].contactId == null){
                    wrapper.errorMessage = System.Label.ContactMissingError;
                    return wrapper;
                }
                conId = usrList[0].contactId;
                conList = [Select AccountID from Contact where id =: conId];
            }
            if(conList[0].AccountId == Null){
                wrapper.errorMessage = System.Label.AccountMissingError;
                return wrapper;
            }
            ID AccID  = conList[0].AccountId;
            accList = [SELECT Id, BillingAddress, Preferred_Region_1__c, Preferred_Region_2__c, Preferred_Region_3__c, 
                       (SELECT Id,Email FROM Contacts WHERE Id = :conId)
                       FROM Account Where Id = :AccID];  
            
            //conId=accList[0].Contacts[0].Id;
            wrapper.conId = conId;
            wrapper.accId = accList[0].Id;
            if(accList[0].Preferred_Region_1__c != Null) {
                wrapper.region1 = accList[0].Preferred_Region_1__c;
            }
            if(accList[0].BillingAddress != Null) {
                wrapper.BillingAddress = accList[0].BillingAddress;
            }
        }
        
        List<Marketing_Preference__c> prefList = new List<Marketing_Preference__c>();
        prefList = [SELECT Id, Preferred_Region_2__c, Preferred_Region_3__c, Is_Tepper__c,No_Communication__c, No_Solicitations__c
                    FROM Marketing_Preference__c
                    WHERE Contact__c =: conId
                    AND Active__c = true
                    LIMIT 1];
        if(!prefList.isEmpty()) {
            wrapper.preference = prefList[0];
            wrapper.isTepper = prefList[0].Is_Tepper__c;
            if(prefList[0].Preferred_Region_2__c != Null) {
                wrapper.region2 = prefList[0].Preferred_Region_2__c;
            }
            if(prefList[0].Preferred_Region_3__c != Null) {
                wrapper.region3 = prefList[0].Preferred_Region_3__c;
            }
        }
        
        return wrapper;
    }  
    
    @AuraEnabled
    public static void updateAlumniBio(String newAddress, String oldAddress, String conId, String accId) {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bio Update').getRecordTypeId();
        Case cs = new Case();
        cs.RecordTypeId = recordTypeId;
        cs.Type = 'Address Change';
        cs.Status = 'New';
        cs.ContactId = conId;
        cs.AccountId = accId;
        cs.Subject =  'Please Review and Update New Contact Address / Email Address';
        cs.Description = 'A User made a change to their Address / Email Address via the Preference Center. ' +
            'Please review the information below for accuracy and update the corresponding Contact record. ' +
            '\r\nOld Email : '+ oldAddress +
            '\r\nNew Email : '+ newAddress;
        
        Insert cs;
    }
    
    public static Set<String> getAllFields() {
        List<Schema.SObjectField> preferenceSchemaFieldsSet = Schema.SObjectType.Marketing_Preference__c.fields.getMap().values();
        Set<String> preferenceFieldsSet = new Set<String>();
        for(Schema.SObjectField s: preferenceSchemaFieldsSet){
            //if(s != Preferred_Region_1__c){
                String str=''+s;
                if(!str.Contains('Preferred_Region_1__c')){
                    if(!preferenceFieldsSet.contains(str)){
                        preferenceFieldsSet.add(str);
                    }
                }
            //}            
        }
        Set<String> systemFieldsSet = new Set<String>{'Id', 'Name', 'IsDeleted', 'CreatedDate', 'CreatedById', 'LastModifiedDate', 'LastModifiedById', 'SystemModstamp', 'LastViewedDate', 'LastReferencedDate'};
        preferenceFieldsSet.removeAll(systemFieldsSet);
        return preferenceFieldsSet;
        
    }

    public static Set<String> getPreferencePageFields(){
      Set<String> pageFieldsSet = new Set<String>{'Unsubscribe_from_all_email_subscriptions__c', 'Preferred_Region_2__c', 'Preferred_Region_3__c', 'Preferred_Region_1__c'
                                                    , 'Contact__c', 'Is_Manual__c', 'Active__c', 'Country__c', 'EU__c', 'EU_Email__c', 'Clean_Country__c'};
      Set<Schema.FieldSetMember> schemaFieldSet = new Set<Schema.FieldSetMember>();
        schemaFieldSet.addAll(FieldSetUtility.readFieldSet('category'));
        schemaFieldSet.addAll(FieldSetUtility.readFieldSet('schools_Colleges'));
        schemaFieldSet.addAll(FieldSetUtility.readFieldSet('schools_Colleges_Tepper'));
        schemaFieldSet.addAll(FieldSetUtility.readFieldSet('Identity_Networks'));
        schemaFieldSet.addAll(FieldSetUtility.readFieldSet('Student_Organizations'));
        for(Schema.FieldSetMember fs : schemaFieldSet) {
            String str = fs.getFieldPath();
            pageFieldsSet.add(str);
        }
        return pageFieldsSet;
    }
    
    @AuraEnabled
    public static String getClonedRecord(String conId, String oldPrefId, Marketing_Preference__c mp1) {
        System.debug('oldPrefId==== ' + oldPrefId + ' mp1 :' +mp1);
        mp1.Contact__c = conId;
        if(String.isBlank(oldPrefId)){
            System.debug('Pref Id found');
            insert mp1;
        }else{
            Set<String> mpAllFields = getAllFields();
            Set<String> pageFields = getPreferencePageFields();
            
            String commaSepratedFields = '';
            for(String fieldName : mpAllFields){
                if(commaSepratedFields == null || commaSepratedFields == ''){
                    commaSepratedFields = fieldName;
                }else{
                    commaSepratedFields = commaSepratedFields + ', ' + fieldName;
                }
            } 
            
            Marketing_Preference__c oldMP = database.query('select ' + commaSepratedFields + ' from ' + 'Marketing_Preference__c where Id = ' + '\'' +oldPrefId+ '\'');
            
            for(String fieldAPI : mpAllFields){
                if(!pageFields.contains(fieldAPI)){
                    System.debug(fieldAPI);
                    mp1.put(fieldAPI, oldMP.get(fieldAPI));
                    
                }
            }
            insert mp1;
        }
        return 'Your Email Preferences are updated successfully';
        
    }

    @AuraEnabled
    public static AlumniPreferenceWrapperClass getAllFieldsNew(String guid){
        AlumniPreferenceWrapperClass wrapper = new AlumniPreferenceWrapperClass();
        Set<String> s = UpdateAlumniPreferenceController.getAllFields();
            String fields = 'Id, ';
            for(String st : s){
                    fields += ' ' + st + ',';
            }
            fields = fields.removeEnd(',');
            String newQuery = 'SELECT ' + fields + ' from Marketing_Preference__c where Active__c = true AND Contact__c = :conId';
        //if(UserInfo.getUserType()=='Guest' || Test.isRunningTest()) {
        if(UserInfo.getUserType()=='Guest') {
            Contact conList = [SELECT Id, Name, Email, accountId, account.BillingAddress, account.Preferred_Region_1__c,account.Preferred_Region_2__c, account.Preferred_Region_3__c
                           FROM Contact
                           WHERE Public_GUID__c = :guid
                           LIMIT 1];
            Id conId = conList.Id;
            List<Marketing_Preference__c> mList = Database.query(newQuery);
            wrapper.preference = mList[0];
            wrapper.conEmail = conList.Email;
            wrapper.BillingAddress = conList.account.BillingAddress;
            wrapper.conId = conId;
            wrapper.accId = conList.accountId;
            wrapper.region1 = conList.account.Preferred_Region_1__c;
            wrapper.region2 = mList[0].Preferred_Region_2__c;
            wrapper.region3 = mList[0].Preferred_Region_3__c;
            wrapper.isGuest = true;
            wrapper.isTepper = mList[0].Is_Tepper__c;
            system.debug('mid -> ' + mList[0].Id);

            return wrapper;
        }
        else{
            List<Contact> conList = new List<Contact>();
            Id conId;
            wrapper.isGuest=false;
            wrapper.conEmail = UserInfo.getUserEmail();
            List<Account> accList = new List<Account>();
            List<User> usrList = new List<User>();
            usrList = [Select contactid, Profile.Name from User where id =: Userinfo.getUserid()];
            if(usrList[0].Profile.Name == 'System Administrator'){
                conList = [Select AccountID, Id from Contact WHERE Public_GUID__c = '1']; 
                if(!conList.isEmpty())
                    conId = conList[0].Id;
            }
            else{
                if(usrList[0].contactId == null){
                    wrapper.errorMessage = System.Label.ContactMissingError;
                    return wrapper;
                }
                conId = usrList[0].contactId;
                conList = [Select AccountID from Contact where id =: conId];
            }
            if(conList[0].AccountId == Null){
                wrapper.errorMessage = System.Label.AccountMissingError;
                return wrapper;
            }
            ID AccID  = conList[0].AccountId;
            accList = [SELECT Id, BillingAddress, Preferred_Region_1__c, Preferred_Region_2__c, Preferred_Region_3__c, 
                       (SELECT Id,Email FROM Contacts WHERE Id = :conId)
                       FROM Account Where Id = :AccID];  
            
            //conId=accList[0].Contacts[0].Id;
            wrapper.conId = conId;
            wrapper.accId = accList[0].Id;
            if(accList[0].Preferred_Region_1__c != Null) {
                wrapper.region1 = accList[0].Preferred_Region_1__c;
            }
            if(accList[0].BillingAddress != Null) {
                wrapper.BillingAddress = accList[0].BillingAddress;
            }

            List<Marketing_Preference__c> mList = Database.query(newQuery);
            wrapper.preference = mList[0];
            wrapper.region2 = mList[0].Preferred_Region_2__c;
            wrapper.region3 = mList[0].Preferred_Region_3__c;

            return wrapper;

        }
    }

    @AuraEnabled 
    public static void updatePrefNew(Marketing_Preference__c m){
        system.debug('mid -> ' + m.id);
        system.debug('unsub-> ' + m.Unsubscribe_from_all_email_subscriptions__c);
        Set<String> mpAllFields = getAllFields();
        Set<String> pageFields = getPreferencePageFields();
        Set<String> pageFieldsSet = new Set<String>{'Unsubscribe_from_all_email_subscriptions__c', 'Preferred_Region_2__c', 'Preferred_Region_3__c', 'Preferred_Region_1__c'
                                                    , 'Contact__c', 'Is_Manual__c', 'Active__c'};
            
        String commaSepratedFields = '';
        for(String fieldName : mpAllFields){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        } 
            
        Marketing_Preference__c oldMP = database.query('select ' + commaSepratedFields + ' from ' + 'Marketing_Preference__c where Id = ' + '\'' +m.id+ '\'');

        /*map<string,object> objmap = (map<string,object>) Json.deserializeuntyped(JSON.serialize(m));
        map<string,object> obj2map = (map<string,object>) Json.deserializeuntyped(JSON.serialize(oldMP));
        map<string,Boolean> newmap = new map<string,Boolean>();
        objmap.remove('attributes');
        obj2map.remove('attributes');*/

        for(String fieldAPI : mpAllFields){
            system.debug('FieldAPI -> ' + fieldAPI);
            if(!pageFields.contains(fieldAPI)){
                System.debug(fieldAPI);
                m.put(fieldAPI, oldMP.get(fieldAPI));
                
            }
            else if(pageFields.contains(fieldAPI) && m.Unsubscribe_from_all_email_subscriptions__c && !pageFieldsSet.contains(fieldAPI)){
                m.put(fieldAPI, false);
            }
        }
        //insert mp1;
        m.id = null;
        system.debug('lets see -> ' + m.AB_Tech_Alumni__c + ' m contact id -> ' + m.Contact__c);
        insert m;
    }
    
    @AuraEnabled
    public static List<string> getRegionValues(){
        List<String> pickListValuesList= new List<String>();
        pickListValuesList.add('--None--');
        Schema.DescribeFieldResult fieldResult = Marketing_Preference__c.Preferred_Region_2__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }    
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static void updateAlumniAddress(String newStreet,String newCity,String newProvince,String newCountry,String newPostalCode,
                                           String oldStreet,String oldCity,String oldProvince,String oldCountry,String oldPostalCode,
                                           String conId, String accId, String addType) {
                                               Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bio Update').getRecordTypeId();
                                               Case cs = new Case();
                                               cs.RecordTypeId = recordTypeId;
                                               cs.Type = 'Address Change';
                                               cs.Status = 'New';
                                               cs.ContactId = conId;
                                               cs.AccountId = accId;
                                               cs.Subject =  'Please Review and Update New Contact Address / Email Address';
                                               cs.Description = 'A User made a change to their Address / Email Address via the Preference Center. ' +
                                                   'Please review the information below for accuracy and update the corresponding Contact record. ' +
                                                   '\r\nOld Address : '+ 
                                                   '\r\nOld Street : '+ oldStreet +
                                                   '\r\nOld City : '+ oldCity +
                                                   '\r\nOld Province : '+ oldProvince +
                                                   '\r\nOld Country : '+ oldCountry +
                                                   '\r\nOld PostalCode : '+ oldPostalCode +
                                                   '\r\nNew Address : '+ 
                                                   '\r\nAddress Type: '+ addType +
                                                   '\r\nNew Street : '+ newStreet +
                                                   '\r\nNew City : '+ newCity +
                                                   '\r\nNew Province : '+ newProvince +
                                                   '\r\nNew Country : '+ newCountry +
                                                   '\r\nNew PostalCode : '+ newPostalCode ;
                                               
                                               Insert cs;
                                           } 
    
    public class PreferenceFieldWrapperClass{
        @AuraEnabled
        public Marketing_Preference__c clonedPref                      { get; set; }
        @AuraEnabled
        public List<String> preferenceFieldList                        { get; set; }
    }
    
    public class FieldSetMemberWrapperClass{        
        @AuraEnabled
        public Boolean isDBRequired                      { get; set; }
        @AuraEnabled
        public Boolean isRequired                        { get; set; }
        @AuraEnabled
        public String fieldType                          { get; set; }
        @AuraEnabled
        public String fieldLabel                         { get; set; }
        @AuraEnabled
        public String fieldAPIName                       { get; set; }
        @AuraEnabled 
        public List<Schema.PicklistEntry> pickListValues { get; set; } 
        
    }
    public class AlumniPreferenceWrapperClass{        
        @AuraEnabled
        public Marketing_Preference__c preference    { get; set; }
        @AuraEnabled
        public String conEmail                       { get; set; }
        @AuraEnabled
        public Address BillingAddress                { get; set; } 
        @AuraEnabled
        public String conId                          { get; set; } 
        @AuraEnabled
        public String accId                          { get; set; } 
        @AuraEnabled
        public String region1                        { get; set; } 
        @AuraEnabled
        public String region2                        { get; set; } 
        @AuraEnabled
        public String region3                        { get; set; } 
        @AuraEnabled
        public Boolean isGuest                       { get; set; } 
        @AuraEnabled
        public Boolean isTepper                      { get; set; } 
        @AuraEnabled 
        public String errorMessage                   { get; set; }
    }
}