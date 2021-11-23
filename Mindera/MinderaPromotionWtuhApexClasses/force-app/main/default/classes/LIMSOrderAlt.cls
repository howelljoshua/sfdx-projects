@RestResource(urlMapping = '/LIMSOrderAlt/*')
global with sharing class LIMSOrderAlt {

    @HTTPPost
    global static Order__c createNewOrder(){
    
    RestRequest orderRequest = RestContext.request;
    String requestBody = orderRequest.requestBody.toString();
    
    Order__c order = (Order__c) JSON.deserialize(requestBody, Order__c.class);

    insert order;
    
    return order;
    
   }
}