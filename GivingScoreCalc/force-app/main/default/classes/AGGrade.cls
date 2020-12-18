Global class AGGrade implements Database.Batchable<sObject>{

Global FINAL List<String> AGGrades = new List<String>{'B', 'B+', 'A-', 'A', 'A+'};
Global Map<Decimal,String> gradeValuesMap = new Map<Decimal,String>();
GLobal List<Decimal> vals = new List<Decimal>();
Global Decimal max = 0;
Global Decimal min = 0;
Global Decimal range = 0;
Global Decimal bucketSize = 0;
Global Decimal boundary = 0;
Global Integer bucketCount = 0;


    global AGGrade(){
        List<Giving_Score__c> extremeMax = [SELECT Id, Annual_Giving_Score__c FROM Giving_Score__c ORDER BY Annual_Giving_Score__c DESC LIMIT 1];

        max = extremeMax[0].Annual_Giving_Score__c; 
            System.debug('extreme max score is: ' + max);

        List<Giving_Score__c> extremeMin = [SELECT Id, Annual_Giving_Score__c FROM Giving_Score__c ORDER BY Annual_Giving_Score__c ASC LIMIT 1];

        min = extremeMin[0].Annual_Giving_Score__c;        
            System.debug('extreme min score is: ' + min);
        range = max - min;
            System.debug('range is: '+ range);
        bucketSize = range / AGGrades.size();
            System.debug('bucketsize is: ' + bucketSize);


        List<Giving_Score__c> truMax = [SELECT Id, Annual_Giving_Score__c FROM Giving_Score__c ORDER BY Annual_Giving_Score__c DESC LIMIT 1000];
        Integer maxIndex = 0;
        for (Giving_Score__c gsMax : truMax){
            maxIndex ++;
            if (  (gsMax.Annual_Giving_Score__c - truMax[maxIndex].Annual_Giving_Score__c)  <  bucketSize ) {
                max = gsMax.Annual_Giving_Score__c;
                break;
            } 
        }
          System.debug('NEW max after the loop is: ' + max);
        
        List<Giving_Score__c> truMin = [SELECT Id, Annual_Giving_Score__c FROM Giving_Score__c ORDER BY Annual_Giving_Score__c ASC LIMIT 1000];
        Integer minIndex = 0;
        for (Giving_Score__c gsMin : truMin){
            minIndex ++;
            if ( (gsMin.Annual_Giving_Score__c - truMin[minIndex].Annual_Giving_Score__c)  <  (bucketSize/2)  ) {
                min = gsMin.Annual_Giving_Score__c;
                break;
            } 
        }
          System.debug('NEW min after the loop is: ' + min);

        boundary = min;
          System.debug('boundary is: ' + boundary);


        //refigure final Range and final Bucketsize after outliers are removed
        range = max - min;
        System.debug('NEW range is: '+ range);
        bucketSize = range / AGGrades.size();
        System.debug('NEW bucketsize is: ' + bucketSize);



        for(String grade : AGGrades){          
            gradeValuesMap.put(boundary, AGGrades[bucketCount]);
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
        return Database.getQueryLocator('SELECT Id, Annual_Giving_Score__c, Annual_Giving_Grade__c FROM Giving_Score__c'); 
    }  






    global void execute(Database.BatchableContext bc, List<Giving_Score__c> scope){

        for(Giving_Score__c gs : scope){
            if(vals.size() >= 2){
                for(Integer i=0; i<vals.size()-1; i++){
                    if( gs.Annual_Giving_Score__c >= vals[i] && gs.Annual_Giving_Score__c < vals[i+1] )  {
                        gs.Annual_Giving_Grade__c = gradeValuesMap.values()[i];
                    }
                    else if (gs.Annual_Giving_Score__c  < vals[0]){
                        gs.Annual_Giving_Grade__c = gradeValuesMap.values()[0];
                    }
                    else if( gs.Annual_Giving_Score__c >= vals[vals.size()-1] ) {
                        gs.Annual_Giving_Grade__c = gradeValuesMap.values()[vals.size()-1];
                    }                   
                }
            }
        }
        update scope;
    }





    global void finish(Database.BatchableContext bc){
    VGrade vg = new VGrade();
    Id batchId = Database.executeBatch(vg);
    }
}