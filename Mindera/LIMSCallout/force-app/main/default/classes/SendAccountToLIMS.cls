/*
AUTHOR - JOSH HOWELL 9/30/2021
USING JSON SERIALIZER TO CREATE ACCOUNT+CONTACT JSON PAYLOAD AND SENDING IT TO LIMS SYSTEM

UPDATE OCT 11 2021 - CHANGE CALLOUT TO RETRIEVE TOKEN FROM '/get-token' API ENDPOINT
ADD TOKEN TO HEADER PARAM AND CALL '/client' ENDPOINT TO PASS PAYLOAD

*/


public class SendAccountToLIMS {

    @invocableMethod(label='Send Practice to LIMS' description='Send Practice to LIMS' category='Account')
    public static void getAccount(List<Id> Ids){

//QUERY THE ACCOUNT WITH THE ACCOUNT ID PASSED FROM THE FLOW    
    List<Account> practiceList = [SELECT Id, PracticeID__c, Name, Payload__c, BillingAddress,
                                  BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
                                  FROM Account WHERE Id IN :Ids];
                                  
//SET THE QUERY RESULT TO A SINGLE ACCOUNT (THERE WILL ONLY BE ONE)                                                                             
    Account practice = practiceList[0];  


//CALL THE ADDRESS WRAPPER CLASS BELOW TO CONSTRUCT THE ADDRESS WRAPPER OBJECT USING THE FIELDS WE NEED    
    AddressWrapper jsonAddress =  new AddressWrapper();
    jsonAddress.city = practice.BillingCity;
    jsonAddress.addressline1 = practice.BillingStreet;
    jsonAddress.addressline2 = practice.BillingStreet;
    jsonAddress.state = practice.BillingState;
    jsonAddress.zipcode = practice.BillingPostalCode;


 //QUERY THE CONTACTS FROM THIS ACCOUNT
    List<Contact> contactList = [SELECT Id, Salutation, FirstName, LastName, Suffix, NPI_Number__c, Phone, MobilePhone, Email
                                  FROM Contact WHERE AccountId IN :Ids];
    
    List<ContactWrapper> jsonContacts = new List<ContactWrapper>();    


//CALL THE CONTACT WRAPPER CLASS BELOW TO PRODUCE LIST OF CONTACTS
    for(Contact con : contactList){
        ContactWrapper jsonContact = new ContactWrapper();
        jsonContact.prefix = con.Salutation;
        jsonContact.firstName = con.Firstname;
        jsonContact.lastName = con.Lastname;
        jsonContact.suffix = con.Suffix;
        jsonContact.npi = con.NPI_Number__c;
        jsonContact.phoneNumber = con.Phone;
        jsonContact.mobile = con.MobilePhone;
        jsonContact.emailAddress = con.Email;
        jsonContacts.add(jsonContact);
    }                                


//CREATE A MAP WITH THE FIELDS AND ADDRESS OBJECT NEEDED FOR THE PAYLOAD, SERIALIZE THE PAYLOAD INTO JSON 
    Map<String, Object> jsonMap = new Map<String, Object>();    
    jsonMap.put('physicians', jsonContacts);
    jsonMap.put('address', jsonAddress);
    jsonMap.put('practiceName', practice.Name);
    jsonMap.put('clientId', practice.PracticeID__c);
    jsonMap.put('accountId', practice.Id);  
    String str = JSON.serialize(jsonMap);

//just for testing...can remove later...want to see the payload field before making the callout.
    practice.Payload__c = str;
    
/*  ORIGINAL CODE...COMMENTED OUT TO TRY THE BEARER TOKEN METHOD
//SET THE BODY AS THE JSON OBJECT
    request.setBody(str);
    HttpResponse response = http.send(request);

//PARSE THE JSON RESPONSE
        if(response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } 
        else {
            System.debug(response.getBody() + ' ' + response.getStatusCode() + ' ' + response.getStatus());
        } 

//WRITE THE RESPONSE INTO THE FIELD FOR DISPLAY IN THE FLOW AND UPDATE RECORD
    practice.Payload__c = response.getBody() + '\n' + '\n' + response.getStatusCode() + ' ' + response.getStatus();
    update practice;          
    }   
*/



//MAKE THE FIRST CALLOUT    
    Http http1 = new Http();
    HttpRequest request1 = new HttpRequest();
    request1.setEndpoint('https://dev-api-lims.skin-atlas.com/api/v1/client/get-token');
    request1.setMethod('POST');
    request1.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
    request1.setHeader('api_key', 'e3acaf58-43e5-489b-be52-5847b8272337');
    request1.setHeader('api_secret', 'DNY3YdZU0ZCyB)GIqq');
    HttpResponse response1 = http1.send(request1);


//DESERIALIZE JSON RESPONSE AND USE "TOKEN" SENT BACK
     //System.debug('response1 is: '+ response1);
   Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
     //System.System.debug('reponseMap is: ' + responseMap);
   String token = (String)responseMap.get('token');
     //System.debug('token is: ' + token);


//SECOND CALLOUT WITH PAYLOAD.................................................................
    Http http2 = new Http();
    HttpRequest request2 = new HttpRequest();
    request2.setEndpoint('https://dev-api-lims.skin-atlas.com/api/v1/client'); //CREATE CLIENT ENDPOINT
    request2.setMethod('POST');
    request2.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
    request2.setHeader('Authorization', 'Bearer ' + token);
   
  
//SET THE BODY AS THE JSON OBJECT
    request2.setBody(str);
    HttpResponse response2 = http2.send(request2);


//PARSE THE JSON RESPONSE
        if(response2.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' + response2.getStatusCode() + ' ' + response2.getStatus());
        } 
        else {
            System.debug(response2.getBody() + ' ' + response2.getStatusCode() + ' ' + response2.getStatus());
        }


//WRITE THE RESPONSE INTO THE FIELD FOR DISPLAY IN THE FLOW AND UPDATE RECORD
    practice.Payload__c = response2.getBody() + '\n' + '\n' + response2.getStatusCode() + ' ' + response2.getStatus();
    update practice;         
    }   


//WRAPPER CLASS FOR ADDRESS WRAPPER OBJECT TO CONTROL WHICH FIELDS ARE IN THE PAYLOAD
    public class addressWrapper{
        public String city;
        public String addressLine1;
        public String addressLine2;
        public String state;
        public String zipcode;        
    }


//WRAPPER CLASS TO CREATE CONTACT(S) TO ADD TO CONTACT LIST
    public class contactWrapper{
        public String prefix;
        public String firstName;
        public String lastName;
        public String suffix;
        public String npi;
        public String phoneNumber; 
        public String mobile;
        public String emailAddress;

    }
    
}