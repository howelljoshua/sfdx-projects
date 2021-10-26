@isTest
public class LIMSOrder_TC {
    @istest public static void testLimorder(){
       Account Acc=new Account();
        Acc.Name='Test';
        Acc.BillingCity='New York';
        Insert Acc;
        
        Contact cntrec=new Contact();
        cntrec.AccountId=Acc.id;
        cntrec.Email='test@gmail.com';
        cntrec.FirstName='testcontact';
        cntrec.LastName='last';
        cntrec.NPI_Number__c='1234556789';
        insert cntrec;
        
        LIMSOrder.createNewOrder('In Process', Date.today().adddays(3), 'test','1234556789' , Acc.id,'687946', 'testpayor1','testertype', 'test456','testpayor 3', 'testtype2','test658',Date.today().adddays(10));
    }
    @istest public static void testlimexistorder(){
        Account Acc=new Account();
        Acc.Name='Test';
        Acc.BillingCity='New York';
        Insert Acc;
        
        Contact cntrec=new Contact();
        cntrec.AccountId=Acc.id;
        cntrec.Email='test@gmail.com';
        cntrec.FirstName='testcontact';
        cntrec.LastName='last';
        cntrec.NPI_Number__c='1234556789';
        insert cntrec;
        
        Order__c order = new Order__c();
        order.Name='687946';
        insert order;
        
        LIMSOrder.createNewOrder('In Process', Date.today().adddays(3), 'test','1234556789' , Acc.id,'687946', 'testpayor1','testertype', 'test456','testpayor 3', 'testtype2','test658',Date.today().adddays(10));
    }
}