@RestResource(urlMapping='/LimsAPI/*')
global class LIMSOrderPackage{
    
    @HttpPost
    global static void handlePost(){
        
        
        RestRequest request = RestContext.request;
        map<String,Object> head = request.headers;
        system.debug('requestBody--->'+request.requestBody.toString());
        map<String,Object> params = (map<String,Object>)JSON.deserializeUntyped(request.requestBody.toString());
        system.debug('params---->'+params);
        Integration_Message__c IntegrationMessage = new Integration_Message__c(Package__c=request.requestBody.toString());
        
        insert IntegrationMessage;
        
    }
     
}