public class IntegrationMessageTriggerHandler {
    
    public void OnAfterInsert(List<Integration_Message__c> IntegrationMessageList){
        
        List<Order__c> OrderList = new List<Order__c>();
        List<Order__c> OrderListData = new List<Order__c>();
        Set<Id> IntegrationMessageIds = new Set<Id>();
        String PackageData = '';
        String DtTime = '';
        Integration_Message__c IMList = new Integration_Message__c();
        /*Customer_Settings__mdt Sorderettings = new Customer_Settings__mdt ();
        Sorderettings = [Select AccountId_Customer__c from Customer_Settings__mdt where developername = 'PhoenixET_ServiceChannel'];
        String AccId = Sorderettings.AccountId_Customer__c ;*/
        
        for(Integration_Message__c IM : IntegrationMessageList){
            if(IM.Id != null){
                IntegrationMessageIds.add(IM.Id);
            }
        }
        IMList = [Select id,Name,Package__c from Integration_Message__c where ID IN:IntegrationMessageIds];
        PackageData = IMList.Package__c;
        Map<String, Object> WebhookDataMap = (Map<String, Object>)JSON.deserializeUntyped(PackageData);
        Map<String, Object> MapOfWebhookObj = (Map<String, Object>)WebhookDataMap.get('Object');
        String OrderNumber = MapOfWebhookObj.get('orderNumber').toString();
        String OrderStatus= WebhookDataMap.get('orderStatus').toString();
        String PhysicianName= String.valueof(MapOfWebhookObj.get('physicianName'));
        //system.debug('SubscriberID--------'+SubscriberID);
        String OrderEntryDate= MapOfWebhookObj.get('orderEntryDate').toString();
        String LocationId = String.valueof(MapOfWebhookObj.get('LocationId'));
        //system.debug('LocationID--------'+LocationID);
        //String RplDtTime = DtTime.replace('T',' ');
        //String NewDtTime  = RplDtTime; 
        Datetime DateFieldValue = Date.valueOf(orderEntryDate);
        /*List<Account> AccCaseLookUpList = [Select id From Account where Third_Party_FM_Id__c =: LocationID ];
        system.debug('AccCaseLookUpListSIZE--------'+AccCaseLookUpList.size());
        List<Account> ParentAccCaseLookUpList = [Select id From Account where Third_Party_FM_Id__c =: SubscriberID ];
        system.debug('ParentAccCaseLookUpListSIZE--------'+AccCaseLookUpList.size());
        if(Action == 'NEW'){*/
            Order__c order = new Order__c();
            /*if(AccCaseLookUpList.size() > 0){
                order.AccountId = AccCaseLookUpList[0].Id;
            }else{
                order.AccountId = AccId;
            }
            if(ParentAccCaseLookUpList.size() > 0){
                    order.Parent_Account__c = AccCaseLookUpList[0].Id;
                }else{
                    order.Parent_Account__c = AccId;
                }*/
            //order.X3rd_Party_Priority__c = MapOfWebhookObj.get('Priority').toString();
            order.Order_Status__c= MapOfWebhookObj.get('orderStatus').toString();
            //order.Scheduled_New__c = DtTimeFieldValue; 
            //order.Subject = MapOfWebhookObj.get('ProblemCode').toString();
            //order.Customer_WO__c = CustomerWOId;
            //order.Description = MapOfWebhookObj.get('Description').toString();
            //order.X3rd_Party_Problem__c = MapOfWebhookObj.get('Category').toString();
            OrderList.add(order);
            insert  OrderList;
        }/*else if(Action == 'UPDATE'){
            OrderListData = [Select id,AccountId,Priority,Issue_Type__c,Scheduled_New__c,Subject,Customer_WO__c,Description From Case where Customer_WO__c =: CustomerWOId ];
            if(OrderListData.size() > 0){
                Order__c order = new order();
                order.Id = OrderListData[0].Id;
                /*if(AccCaseLookUpList.size() > 0){
                    order.AccountId = AccCaseLookUpList[0].Id;
                }else{
                    order.AccountId = AccId;
                }
                order.X3rd_Party_Priority__c = MapOfWebhookObj.get('Priority').toString();
                order.X3rd_Party_Issue_Type__c = MapOfWebhookObj.get('Trade').toString();
                order.Scheduled_New__c = DtTimeFieldValue; 
                order.Subject = MapOfWebhookObj.get('ProblemCode').toString();
                order.Customer_WO__c = CustomerWOId;
                order.Description = MapOfWebhookObj.get('Description').toString();
                order.X3rd_Party_Problem__c = MapOfWebhookObj.get('Category').toString();
                OrderList.add(order);
            }
        }
        Update OrderList;
    }*/
    
}