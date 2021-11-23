@isTest
public class SendAccountToLIMS_TC {
    public class MockHttpResponseGenerator implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test1"}');
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    public static void testsendaccount(){
        List<Id> AccId=new List<Id>();
        Account Acc=new Account();
        Acc.Name='Test';
        Acc.BillingCity='New York';
        //Acc.BillingAddress='test';
        Acc.BillingCountry='US';
        Acc.BillingState='NY';
        Acc.BillingStreet='test street';
        Acc.BillingPostalCode='55809';
        Insert Acc;
        AccId.add(Acc.id);
        
        Contact cntrec=new Contact();
        cntrec.AccountId=Acc.id;
        cntrec.Email='test@gmail.com';
        cntrec.Phone='64985854';
        cntrec.FirstName='testcontact';
        cntrec.LastName='last';
        cntrec.NPI_Number__c='1234556789';
        insert cntrec;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        SendAccountToLIMS.getAccount(AccId);
        
    }
}