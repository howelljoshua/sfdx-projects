public class AccountHandler {
    
   @InvocableMethod(label='Send Client to LIMS' description='Sends an Account Client to LIMS' category='Account')
    /*public static List<String> getAccountNames(List<ID> ids) {
    List<String> accountNames = new List<String>();
    List<Account> accounts = [SELECT Id, PracticeID__c, Name FROM Account WHERE Id in :ids];
    for (Account account : accounts) {
      accountNames.add(account.Name);
      accountNames.add(account.PracticeID__c);
    }
    return accountNames;
  }
      public class FlowInputs{  
        
        @InvocableVariable
        public String ids;
  }
  
  //output details which goes from apex to flow
    public class FlowOutputs{
        
        @InvocableVariable
        public String accountNames;
     }
}*/
    public static List<FlowOutputs> updateApplication(List<FlowInputs> request) {
        List<FlowOutputs> results = new List<FlowOutputs>();
        return results;
        
        /*//payload
        String body = new payload();
        payload = '{'+
        '"clientId":"1000",'+ 
        '"practiceName":"xyz",'+ 
          '}';*/
         
        
    }
    
    
        //input details that comes to apex from flow
    public class FlowInputs{
    
        @InvocableVariable
        public String clientId;
        
        @InvocableVariable
        public String practiceName;
        
        @InvocableVariable
        public String payload;
        
        
    }
    
      //output details which goes from apex to flow
        public class FlowOutputs{
        
       
        @InvocableVariable
        public String payload;
        
        
     }
}
    /*public static void WebCallout_Account_to_LIMS(String AcctName, String ClientId, String AcctId){ 
        Account acctRec = [select id, name from Account where Id=:AcctId];
        //system.debug('acctRec-->' +acctRec);
        //List<Account> acctlist = new List<Account>();
        //String Note = '"Note" : "' + AcctName +'"'+ '}'; 
        //String accessToken = ProcessServiceChannelRequest.ReturnAccessToken();
        //system.debug('accessToken-------'+accessToken);
        String aName = AcctName + '/status';
        //String endPoint = 'https://sb2api.servicechannel.com/v3/workorders/' + WOId;
        //system.debug('endPoint------'+endPoint);
        String body;
        if(acctRec.Name =='Accepted'){
            body = '{"Status": {"Primary": "IN PROGRESS","Extended": "DISPATCH CONFIRMED"},'+Note;
        }
        else{
            body = '{"Status": {"Primary": "COMPLETED"},'+Note;
        } */       
        /*HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        httpReq.setMethod('POST');
        httpReq.setEndPoint(endPoint);
        httpReq.setHeader('Content-Type' , 'application/json');
        httpReq.setBody(body);
        httpReq.setHeader('Authorization' , 'Bearer '+accessToken);
        httpRes = http.send(httpReq);
        system.debug('httpRes-----------'+httpRes);
        system.debug('httpRes-----------'+httpRes.getBody());
        Map<String, Object> response_Map = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());            
        String data = (String)response_Map.get('Object');
        system.debug('data------------'+data);
        String ErrorMessage = (String)response_Map.get('ErrorMessage');
        system.debug('ErrorMessage------------'+ErrorMessage);
        if(ErrorMessage != null){
            if(ErrorMessage.length() >= 255){  
                caseRec.X3rd_Party_Update_Error__c = ErrorMessage.Substring(0,255);
            }
            else{
                caseRec.X3rd_Party_Update_Error__c = ErrorMessage;
            }
            caselist.add(caseRec);
            update caselist;
        }
    }
    
}*/