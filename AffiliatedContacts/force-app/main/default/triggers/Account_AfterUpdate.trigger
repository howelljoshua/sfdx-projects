trigger Account_AfterUpdate on Account (after update) {

if(CheckRecursive.runOnce()){

    List<Account> accountsForPachinko = [SELECT Id, Pachinko_Input__c, General_Category__c, Specific_Category__c 
                                         FROM Account WHERE Id IN :Trigger.New];
                                         
                                        
    //PachinkoCalc pachinko = new PachinkoCalc(accountsForPachinko); 
    }
    
}