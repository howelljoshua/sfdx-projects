public with sharing class CMU_TransactionTriggerHandler {

public Integer cfy; // current fiscal year
public Integer pfy; // previous fiscal year
public Integer tfya; // two fiscal years ago






      //calculate the summary fields on the parent COA for each transaction in trigger...
    public void calculatePGSummaries(List<AQB__Transaction__c> transactions){

        calcFY();

        Set<Id> allCOAs = new Set<Id>();

        for(AQB__Transaction__c tr: transactions){
            allCOAs.add(tr.AQB__ChartofAccounts__c);
        }


        Map<Id, AQB__Transaction__c> payments = [SELECT Id, AQB__Amount__c, AQB__Date__c
                                                        FROM Transaction
                                                        WHERE RecordType.Name NOT IN ('Soft Credit','Pledge Soft Credit')   
                                                        AND AQB__Type__c = 'Payment'                                                
                                                        AND AQB__Amount__c > 0                                                    
                                                        AND AQB__Voided__c = FALSE
                                                        AND AQB_Designation__c IN: allCOAs];


        Map<Id, AQB__Transaction__c> pledges = [SELECT Id, AQB__Amount__c, AQB__Date__c
                                                        FROM Transaction
                                                        WHERE RecordType.Name NOT IN ('Soft Credit','Pledge Soft Credit')   
                                                        AND AQB__Type__c = 'Pledge' 
                                                        AND AQB__PledgePaymentLink__c = NULL
                                                        AND AQB__Balance__c > 0                                                                                       
                                                        AND AQB__Voided__c = FALSE
                                                        AND AQB_Designation__c IN: allCOAs];    


        Map<Id, AQB__LLChartofAccounts__c> charts = new Map<Id, AQB__LLChartofAccounts__c>();
        for(Id coaId : allCOAs){
            AQB__LLChartofAccounts__c thisCOA = new AQB__LLChartofAccounts__c();
            thisCOA.Id = coaId;
            thisCOA.CFY_Cash__c = 0.00;
            thisCOA.PFY_Cash__c = 0.00;
            thisCOA.X2FYA_Cash__c = 0.00;
            thisCOA.Lifetime_Cash_and_Commitments__c = 0.00;
            charts.put(coaId, thisCOA );
        }


          //loop thru the PAYMENT transactions and update all 4 summary fields
        for (AQB__Transaction__c payment : payments){
            if(payment.AQB__Date__c.year() == cfy){
                allCOAS.get(payment.AQB__ChartofAccounts__c).CFY_Cash__c += payment.AQB__Amount__c;
            }

            else if(payment.AQB__Date__c.year() == pfy){
                allCOAS.get(payment.AQB__ChartofAccounts__c).PFY_Cash__c += payment.AQB__Amount__c;
                
            }

            else if(payment.AQB__Date__c.year() == tfya){
                allCOAS.get(payment.AQB__ChartofAccounts__c).X2FYA_Cash__c += payment.AQB__Amount__c;
            }
            else{
                allCOAS.get(payment.AQB__ChartofAccounts__c).Lifetime_Cash_and_Commitments__c += payment.AQB__Amount__c;
            }
            
        }


          //loop thru the PLEDGE transactions and update the lifetime total field
//        for (AQB__Transaction__c pledge : pledges){
//        }

    update allCOAS.values();
    }
















//........................................................................................................
// gets called once and calculates/populates the FY fields used by the summary method.....................................

    public void calcFY(){
        Integer month =  Date.Today().month();
        Integer year =  Date.Today().year();

        if(month > 6){
            year ++;
        }

        cfy = year;
        pfy = year - 1;
        tfya = year - 2;
    }
}