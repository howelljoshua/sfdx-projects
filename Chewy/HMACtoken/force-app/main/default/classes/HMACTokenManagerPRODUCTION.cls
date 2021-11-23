/**
 * RA, A73
 * Util class for HMACToken generation.
 */
public class HMACTokenManager {
    public static Map<String, Chewy_Setting__mdt> chewySettingsMap {
        get {
            if(chewySettingsMap == null) {
                chewySettingsMap = new Map<String, Chewy_Setting__mdt>();
                for(Chewy_Setting__mdt setting: [Select developername, value__c from Chewy_Setting__mdt]) {
                    chewySettingsMap.put(setting.developerName, setting);
                }
            }
            return chewySettingsMap;
        }
        set;
    }// = new Map<String
    /**
     * invocable function to kick off token generation
     * @param recordIds - list of source record ids
     * @return null for now
     */
    @InvocableMethod(label='Generate HMAC Token for an object')
    public static List<String> generate(List<sObject> lstsObj) {
      //generateToken(recordIds[0]);
      generateTokens(lstsObj);
        return null;
    }
    
        /**
     * function for generating hmac token
     * @param recordId - source record id
     */
    public static void generateToken(Id recordId) {
        // start with record Id
    String inputText= recordId;
        if((recordId.getSobjectType()+'').equals('Lead')) {             
      // query and get Company, email and chewy id
      Lead objLead = [Select Company, email, Unique_Chewy_ID__c, Onboarding_id__c
                from Lead where id=:recordId];
            // modify the input text separated by delimiter, this is the data to be encrypted
            ChewyToken tokenObj = new ChewyToken();
            try {
                tokenObj.clinic_id = Long.valueOf(objLead.Unique_Chewy_Id__c);
            }
            catch(Exception ex) {
                System.debug('>>> Exception in converting value: ' + ex.getMessage());
            }
            try {
                tokenObj.onboarding_id = objLead.Onboarding_Id__c;
            }
            catch(Exception ex) {
                System.debug('>>> Exception in converting ref_id: ' + ex.getMessage());
            }
            tokenObj.email = objLead.email;
            tokenObj.clinic_name = objLead.Company;
            inputText = JSON.serialize(tokenObj);
            //inputText = objLead.company + '|'+objLead.email +'|'+ objLead.Unique_Chewy_ID__c;
        }
        
        String encryptedString = getToken(inputText);
        
        /**
         * update source record based on sObjectType
         */
        if((recordId.getSobjectType()+'').equals('Contact')) {
          Contact c = new Contact(id=recordId, Token__c=encryptedString);
            update c;
        }
        if((recordId.getSobjectType()+'').equals('Lead')) {
          Lead l = new Lead(id=recordId, Token__c=encryptedString);    
            update l;
        }
        
    }
    
     /**
     * function for generating hmac token
     * @param lstsObj List Of Records
     */
    public static void generateTokens(List<sObject> lstsObj) {
        system.debug('lstsObj=>'+lstsObj);
        Id recId = (Id)lstsObj[0].get('Id');
        String sObjectName =recId.getSobjectType()+'';
        
        List<Lead> ldList = new List<Lead>();
        List<Account> accList = new List<Account>();
        List<Contact> cntList = new List<Contact>();
        for(sObject sobj : lstsObj){
            String inputText= (String)sobj.get('Id');
            if(sObjectName == 'Lead'){
                Lead objLead = (Lead)sObj;
                // modify the input text separated by delimiter, this is the data to be encrypted
                ChewyToken tokenObj = new ChewyToken();
                try {
                    tokenObj.clinic_id = Long.valueOf(objLead.Unique_Chewy_Id__c);
                }
                catch(Exception ex) {
                    System.debug('>>> Exception in converting value: ' + ex.getMessage());
                }
                try {
                    tokenObj.onboarding_id = objLead.Onboarding_Id__c;
                }
                catch(Exception ex) {
                    System.debug('>>> Exception in converting ref_id: ' + ex.getMessage());
                }
                tokenObj.email = objLead.email;
                tokenObj.clinic_name = objLead.Company;
                inputText = JSON.serialize(tokenObj);
                //inputText = (String)sobj.get('company')+ '|'+(String)sobj.get('email')+'|'+ (String)sobj.get('Unique_Chewy_ID__c');
            }
            System.debug('>>>About to Encrypt: ' + inputText);
            String encryptedString = getToken(inputText);
            // also test decryption of the data
            // Blob decrypted = Crypto.decryptWithManagedIV('AES128', key, encrypted);
            // String decryptedString = decrypted.toString();
            // System.assert(decryptedString.equals(inputText));
            
            if(sObjectName == 'Lead'){
                Lead ld = new Lead(id=(String)sobj.get('Id'), Token__c=encryptedString);    
                ldList.add(ld);
            }
            if(sObjectName == 'Contact'){
                Contact cnt = new Contact(id=(String)sobj.get('Id'), Onboarding_Token__c=encryptedString);    
                cntList.add(cnt);
            }
        }
        
        if(ldList.size() > 0){
            update ldList;
        }
        if(cntList.size() > 0){
            update cntList;
        }
        if(accList.size() > 0){
            update accList;
        }
        
    }

    /**
     * function to convert encrypted token for a string using a shared code
     * @param inputText denotes text in string format to be encrypted
     * @return generated token
     */
    public static String getToken(String inputText) {
        String sharedSecret=getKey();
        Blob key = Blob.valueOf(sharedSecret);
        
        // convert to Blob, required by API for encryption
        Blob inputBlobData = Blob.valueOf(inputText);
        // encrypt the data using AES128 that needs 16 byte key
    String algorithm = chewySettingsMap.get('Encryption_Algorithm').Value__c;
        Blob encrypted = Crypto.encryptWithManagedIV(algorithm, key, inputBlobData);
        //Blob encrypted = Crypto.encrypt(algorithm, key, Blob.valueOf(sharedSecret), inputBlobData);
        // convert blob to string to store on the record, this will be sent in the URL
        String encryptedString = EncodingUtil.base64Encode(encrypted);
        return encryptedString;
    }

    /**
     * function to get shared string
     * @return shared secret
     */
    public static String getKey(){
        String sharedSecret=chewySettingsMap.get('Shared_Secret').Value__c;//'lor3MiPs0m';
        // since encryptWithManagedIV requires 16 byte key we will need to pad it with 0s
        String suffixIfAny = chewySettingsMap.get('Secret_Suffix').Value__c;
        if(suffixIfAny != null) {
          sharedSecret = sharedSecret + suffixIfAny ;//'000000';
        }       
        return sharedSecret;
    }

    /**
     * function to get decrypted token
     */
    public static String getInputString(Blob encrypted) {
        Blob key = Blob.valueOf(getKey());
        // also test decryption of the data
        Blob decrypted = Crypto.decryptWithManagedIV('AES128', key, encrypted);
        String decryptedString = decrypted.toString();
        // System.debug('Data text for encryption : ' + inputText);
        // System.debug('Encrypted text : ' + encryptedString);
        System.debug('Decrypted Data text : '+ decryptedString);
        // System.assert(decryptedString.equals(inputText));
        return decryptedString;
    }
    
    /**
     * function for generating hmac token
     * @param recordId - source record id
     */
    public static void generateTokenOld(Id recordId) {
        String sharedSecret='lor3MiPs0m';
        Blob key = Blob.valueOf(sharedSecret);
        // This key need to be shared with client as its required for decryption and verification of MAC
        //String keyStr = EncodingUtil.base64Encode(key);
        //System.debug('Key String : ' + keyStr);
    String inputText= recordId;
        if((recordId.getSobjectType()+'').equals('Lead')) {             
      // query and get Company, email and chewy id
      Lead objLead = [Select Company, email, Unique_Chewy_ID__c from Lead where id=:recordId];
            inputText = objLead.company + '|'+objLead.email +'|'+ objLead.Unique_Chewy_ID__c;
        }
        
        /** 
         * ideally, the data should be encrypted         
          Blob inputBlobData = Blob.valueOf(inputText);
      Blob encryptedData = Crypto.encryptWithManagedIV('AES256', Blob.valueOf(sharedSecret+sharedSecret+sharedSecret+'12'), inputBlobData);
                
          String encryptedData4Url = EncodingUtil.urlEncode(EncodingUtil.base64Encode(encryptedData), 'UTF-8');
          */         
        Blob mac = Crypto.generateMac('hmacSHA256', Blob.valueOf(inputText), key);
                
        String mac4Url = EncodingUtil.urlEncode(EncodingUtil.base64Encode(mac), 'UTF-8');
        /**
         * update source record based on sObjectType
         */
        if((recordId.getSobjectType()+'').equals('Contact')) {
          Contact c = new Contact(id=recordId, Token__c=mac4Url);    
            update c;
        }
        if((recordId.getSobjectType()+'').equals('Lead')) {
          Lead l = new Lead(id=recordId, Token__c=mac4Url);    
            update l;
        }
        
    }
    /**
   *@description method to select Lead for token generation
  *@param oldLeads Old Lead Records 
  *@param newLeads New Lead Records
  *@return List<Lead> list Of Lead Records
  */
    public static List<Lead> getLeadsForTokenUpdate(Map<Id,Lead> oldLeads,Map<Id,Lead> newLeads){
        List<Lead> lstLeads = new List<Lead>();
        
        for(Lead ld : newLeads.values()){
            Lead oldLead = oldLeads.get(ld.Id);
            //check if values are changed
            if(ld.company != oldLead.company || ld.email != oldLead.email || ld.Unique_Chewy_ID__c != oldLead.Unique_Chewy_ID__c){
                lstLeads.add(ld);
            }
        }
        return lstLeads;
    }
    
    /**
    * @description method to select Contact for token generation
   * @param oldAccts Old Contact Records 
   * @param newAccts New Contact Records
   * @return List<Contact> list Of Contact Records
  */
    public static List<Contact> getContactsForTokenUpdate(Map<Id,Contact> oldCons,Map<Id,Contact> newCons){
        List<Contact> lstContacts = new List<Contact>();
        for(Contact con : newCons.values()){
            Contact oldCon = oldCons.get(con.Id);
            //check if values are changed
            if(con.AccountId != oldCon.AccountId || con.Email != oldCon.Email || con.Onboarding_Id__c != oldCon.Onboarding_Id__c || con.Unique_Chewy_ID_NEW__c != oldCon.Unique_Chewy_ID_NEW__c){
                lstContacts.add(con);
            }
        }
        return lstContacts;
    }

    public class ChewyToken {
        public String email {get; set;} // email
        public String clinic_name {get; set;} // company
        public long clinic_id {get; set;} // unique chewy id
        public String onboarding_id {get; set;} // auto number
    }
}
