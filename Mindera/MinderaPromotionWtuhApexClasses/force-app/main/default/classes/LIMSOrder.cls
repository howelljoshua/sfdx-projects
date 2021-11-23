@RestResource(urlMapping = '/LIMSOrder/*')
global with sharing class LIMSOrder {

    @HTTPPost
    global static Order__c createNewOrder(String orderStatus, Date orderEntryDate, String clientId, String physicianNpi, String accountId, String orderNumber, String primaryPayor, String primaryPayorType, String primaryPayorID, String secondaryPayor, String secondaryPayorType, String secondaryPayorID, Date orderCompletedDate){
    
    Order__c order = new Order__c();
    order.Order_Status__c = orderStatus;
    order.Order_Entry_Date__c = orderEntryDate;
    order.Name = orderNumber;
    order.Primary_Payor_Name__c = primaryPayor;
    order.Primary_Payor_Type__c = primaryPayorType;
    order.Primary_Payor_Payor_ID__c = primaryPayorID;
    order.Secondary_Payor_Name__c = secondaryPayor;
    order.Secondary_Payor_Type__c = secondaryPayorType;
    order.Secondary_Payor_Payor_ID__c = secondaryPayorID;
    order.Order_Completed_Date__c = orderCompletedDate;
    
    //(not needed - resides on related account/client) order.Practice_Id__c = clientId;
    order.Account__c = accountId;
    
    //get contact/physician from NPI
    Id contactRef = [Select Id from Contact where NPI_Number__c = :physicianNpi].Id;
    
    //insert contact/physician
    order.Contact__c = contactRef;
    
    List<Order__c> orderCheck = [Select Id from Order__c where Name = :orderNumber];
    
    if (orderCheck.size() > 0) {
        Order__c o = orderCheck.get(0);
        order.Id = o.id;
        update order;
        }
    else{
    insert order;
    }
    
    return order;
    
   }
}