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


        Map<Id, AQB__Transaction__c> payments = new Map<Id, AQB__Transaction__c>([SELECT Id, AQB__Amount__c, AQB__Date__c, AQB__ChartofAccounts__c
                                                                                FROM AQB__Transaction__c
                                                                                WHERE RecordType.Name NOT IN ('Soft Credit','Pledge Soft Credit')   
                                                                                AND AQB__Type__c = 'Payment'                                                
                                                                                AND AQB__Amount__c > 0                                                    
                                                                                AND AQB__Voided__c = FALSE
                                                                                AND AQB__ChartofAccounts__c IN: allCOAs] );


        Map<Id, AQB__Transaction__c> pledges = new Map<Id, AQB__Transaction__c>([SELECT Id, AQB__Amount__c, AQB__Date__c, AQB__ChartofAccounts__c
                                                                                FROM AQB__Transaction__c
                                                                                WHERE RecordType.Name NOT IN ('Soft Credit','Pledge Soft Credit')   
                                                                                AND AQB__Type__c = 'Pledge' 
                                                                                AND AQB__PledgePaymentLink__c = NULL
                                                                                AND AQB__Balance__c > 0                                                                                       
                                                                                AND AQB__Voided__c = FALSE
                                                                                AND AQB__ChartofAccounts__c IN: allCOAs]);    


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


          //loop thru the PAYMENT transactions and update the 4 summary fields, as appropriate....
        for (AQB__Transaction__c payment : payments.values()){            
             //for now, set "this" Transactions's fy to the actual year of the payment date
            integer fy = payment.AQB__Date__c.year();
             // check month of payment date, if July or later, add 1 to "this" payment's fiscal year...
            if (payment.AQB__Date__c.month() > 6){
                fy ++;
            }


              //total all PAYMENTS into the lifetime field, regardless of year, etc....
            charts.get(payment.AQB__ChartofAccounts__c).Lifetime_Cash_and_Commitments__c += payment.AQB__Amount__c;

              // if fiscal year of this PAYMENT is the current fiscal year, add it here...
            if (fy == cfy){
                charts.get(payment.AQB__ChartofAccounts__c).CFY_Cash__c += payment.AQB__Amount__c;
            }

              // if fiscal year of this PAYMENT is the previous fiscal year, add it here...
            else if (fy == pfy){
                charts.get(payment.AQB__ChartofAccounts__c).PFY_Cash__c += payment.AQB__Amount__c;
                
            }
              // if fiscal year of this PAYMENT is 2 fiscal years ago, add it here...
            else if (fy == tfya){
                charts.get(payment.AQB__ChartofAccounts__c).X2FYA_Cash__c += payment.AQB__Amount__c;
            }
            
        }


          //loop thru the PLEDGE transactions and summarize into the lifetime total field, adding to the PAYMENTS
        for (AQB__Transaction__c pledge : pledges.values()){
            charts.get(pledge.AQB__ChartofAccounts__c).Lifetime_Cash_and_Commitments__c += pledge.AQB__Amount__c;
        }

    update charts.values();
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