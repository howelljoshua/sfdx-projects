Global class PRGrade implements Database.Batchable<sObject>{

Global FINAL List<String> PRGrades = new List<String>{'B', 'B+', 'A-', 'A', 'A+'};
Global Map<Decimal,String> gradeValuesMap = new Map<Decimal,String>();
GLobal List<Decimal> vals = new List<Decimal>();
Global Decimal max = 0;
Global Decimal min = 0;
Global Decimal range = 0;
Global Decimal bucketSize = 0;
Global Decimal boundary = 0;
Global Integer bucketCount = 0;


    global PRGrade(){
        List<Giving_Score__c> extremeMax = [SELECT Id, Research_Score__c FROM Giving_Score__c ORDER BY Research_Score__c DESC LIMIT 1];

        max = extremeMax[0].Research_Score__c; 
            System.debug('extreme max score is: ' + max);

        List<Giving_Score__c> extremeMin = [SELECT Id, Research_Score__c FROM Giving_Score__c ORDER BY Research_Score__c ASC LIMIT 1];

        min = extremeMin[0].Research_Score__c;        
            System.debug('extreme min score is: ' + min);
        range = max - min;
            System.debug('range is: '+ range);
        bucketSize = range / PRGrades.size();
            System.debug('bucketsize is: ' + bucketSize);


        List<Giving_Score__c> truMax = [SELECT Id, Research_Score__c FROM Giving_Score__c ORDER BY Research_Score__c DESC LIMIT 1000];
        Integer maxIndex = 0;
        for (Giving_Score__c gsMax : truMax){
            maxIndex ++;
            if (  (gsMax.Research_Score__c - truMax[maxIndex].Research_Score__c)  <  bucketSize ) {
                max = gsMax.Research_Score__c;
                break;
            } 
        }
            System.debug('NEW max after the loop is: ' + max);
        
        List<Giving_Score__c> truMin = [SELECT Id, Research_Score__c FROM Giving_Score__c ORDER BY Research_Score__c ASC LIMIT 1000];
        Integer minIndex = 0;
        for (Giving_Score__c gsMin : truMin){
            minIndex ++;
            if ( (gsMin.Research_Score__c - truMin[minIndex].Research_Score__c)  <  bucketSize  ) {
                min = gsMin.Research_Score__c;
                break;
            } 
        }
            System.debug('NEW min after the loop is: ' + min);

        boundary = min;
            System.debug('boundary is: ' + boundary);


        //refigure final Range and final Bucketsize after outliers are removed
        range = max - min;
        System.debug('NEW range is: '+ range);
        bucketSize = range / PRGrades.size();
        System.debug('NEW bucketsize is: ' + bucketSize);



        for(String grade : PRGrades){          
            gradeValuesMap.put(boundary, PRGrades[bucketCount]);
            boundary = boundary + bucketsize;
            bucketCount ++;
        }
            System.debug('gradeValuesMap is: ' + gradeValuesMap);
            System.debug('gradevaluesmap keyset: ' + gradeValuesMap.keyset());
        vals.addAll(gradeValuesMap.keyset());
        vals.sort();
            System.debug('sorted vals are: ' + vals);
    }







    global Database.QueryLocator start(Database.BatchableContext bc) { 
        return Database.getQueryLocator('SELECT Id, Research_Score__c, Research_Grade__c FROM Giving_Score__c'); 
    }  






    global void execute(Database.BatchableContext bc, List<Giving_Score__c> scope){

        for(Giving_Score__c gs : scope){
            if(vals.size() >= 2){
                for(Integer i=0; i<vals.size()-1; i++){
                    if( gs.Research_Score__c >= vals[i] && gs.Research_Score__c < vals[i+1] )  {
                        gs.Research_Grade__c = gradeValuesMap.values()[i];
                    }
                    else if (gs.Research_Score__c  < vals[0]){
                        gs.Research_Grade__c = gradeValuesMap.values()[0];
                    }
                    else if( gs.Research_Score__c >= vals[vals.size()-1] ) {
                        gs.Research_Grade__c = gradeValuesMap.values()[vals.size()-1];
                    }                   
                }
            }
        }
        update scope;
    }





    global void finish(Database.BatchableContext bc){
        GivingScoreUpdateContact gsuc = new GivingScoreUpdateContact();
        Id batchId = Database.executeBatch(gsuc);
    }
}