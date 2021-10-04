//Author - Josh Howell 9/30/2021
//Testing JSON Serialize for LIMS integration


public class SendAccountToLIMS {

    @invocableMethod(label='Send Practice to LIMS' description='Send Practice to LIMS' category='Account')
    public static void getAccount(List<Id> Ids){

//QUERY THE ACCOUNT WITH THE ACCOUNT ID PASSED FROM THE FLOW    
    List<Account> practiceList = [SELECT Id, PracticeID__c, Name, Payload__c, BillingAddress,
                                  BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
                                  FROM Account WHERE Id IN :Ids];
                                  
//SET THE QUERY RESULT TO A SINGLE ACCOUNT                                                                             
    Account practice = practiceList[0];  


//CALL THE WRAPPER CLASS BELOW TO CONSTRUCT THE ADDRESS WRAPPER OBJECT USING THE FIELDS WE NEED    
    AddressWrapper jsonAddress =  new AddressWrapper();
    jsonAddress.city = practice.BillingCity;
    jsonAddress.addressline1 = practice.BillingStreet;
    jsonAddress.addressline2 = practice.BillingStreet;
    jsonAddress.state = practice.BillingState;
    jsonAddress.zipcode = practice.BillingPostalCode;


//CREATE A MAP WITH THE FIELDS AND ADDRESS OBJECT NEEDED FOR THE PAYLOAD, SERIALIZE THE PAYLOAD INTO JSON 
    Map<String, Object> jsonMap = new Map<String, Object>();    
    jsonMap.put('address', jsonAddress);
    jsonMap.put('practiceName', practice.Name);
    jsonMap.put('clientId', practice.PracticeID__c);  
    String str = JSON.serialize(jsonMap);

//SET THE "PAYLOAD" CUSTOM FIELD ON THIS ACCOUNT AND UPDATE                               
    practice.Payload__c = str;
    //update practice; 
    
//MAKE THE CALLOUT    
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint('https://dev-api-lims.skin-atlas.com/api/v1/client'); //CREATE CLIENT ENDPOINT
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
    request.setHeader('api_key', 'e3acaf58-43e5-489b-be52-5847b8272337');
    request.setHeader('api_secret', 'DNY3YdZU0ZCyB)GIqq');
   
  
//SET THE BODY AS A JSON OBJECT
    request.setBody(str);
    HttpResponse response = http.send(request);
    practice.Payload__c = practice.Payload__c + '      ' + response.getBody();
    update practice;

// PARSE THE JSON RESPONSE
        if(response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } 
        else {
            System.debug(response.getBody());
        }    
    }   
   


//WRAPPER CLASS FOR ADDRESS WRAPPER OBJECT TO CONTROL WHICH FIELDS ARE IN THE PAYLOAD
    public class addressWrapper{
        public String city;
        public String addressline1;
        public String addressline2;
        public String state;
        public String zipcode;        
    }
    
}