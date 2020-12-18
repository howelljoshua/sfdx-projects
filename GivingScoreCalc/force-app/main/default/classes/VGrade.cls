Global class VGrade implements Database.Batchable<sObject>{

Global FINAL List<String> VGrades = new List<String>{'B', 'B+', 'A-', 'A', 'A+'};
Global Map<Decimal,String> gradeValuesMap = new Map<Decimal,String>();
GLobal List<Decimal> vals = new List<Decimal>();
Global Decimal max = 0;
Global Decimal min = 0;
Global Decimal range = 0;
Global Decimal bucketSize = 0;
Global Decimal boundary = 0;
Global Integer bucketCount = 0;


    global VGrade(){
        List<Giving_Score__c> extremeMax = [SELECT Id, Volunteer_Score__c FROM Giving_Score__c ORDER BY Volunteer_Score__c DESC LIMIT 1];

        max = extremeMax[0].Volunteer_Score__c; 
            System.debug('extreme max score is: ' + max);

        List<Giving_Score__c> extremeMin = [SELECT Id, Volunteer_Score__c FROM Giving_Score__c ORDER BY Volunteer_Score__c ASC LIMIT 1];

        min = extremeMin[0].Volunteer_Score__c;        
            System.debug('extreme min score is: ' + min);
        range = max - min;
            System.debug('range is: '+ range);
        bucketSize = range / VGrades.size();
            System.debug('bucketsize is: ' + bucketSize);


        List<Giving_Score__c> truMax = [SELECT Id, Volunteer_Score__c FROM Giving_Score__c ORDER BY Volunteer_Score__c DESC LIMIT 1000];
        Integer maxIndex = 0;
        for (Giving_Score__c gsMax : truMax){
            maxIndex ++;
            if (  (gsMax.Volunteer_Score__c - truMax[maxIndex].Volunteer_Score__c)  <  bucketSize ) {
                max = gsMax.Volunteer_Score__c;
                break;
            } 
        }
            System.debug('NEW max after the loop is: ' + max);
        
        List<Giving_Score__c> truMin = [SELECT Id, Volunteer_Score__c FROM Giving_Score__c ORDER BY Volunteer_Score__c ASC LIMIT 1000];
        Integer minIndex = 0;
        for (Giving_Score__c gsMin : truMin){
            minIndex ++;
            if ( (gsMin.Volunteer_Score__c - truMin[minIndex].Volunteer_Score__c)  <  bucketSize  ) {
                min = gsMin.Volunteer_Score__c;
                break;
            } 
        }
            System.debug('NEW min after the loop is: ' + min);

        boundary = min;
            System.debug('boundary is: ' + boundary);


        //refigure final Range and final Bucketsize after outliers are removed
        range = max - min;
        System.debug('NEW range is: '+ range);
        bucketSize = range / VGrades.size();
        System.debug('NEW bucketsize is: ' + bucketSize);



        for(String grade : VGrades){          
            gradeValuesMap.put(boundary, VGrades[bucketCount]);
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
        return Database.getQueryLocator('SELECT Id, Volunteer_Score__c, Volunteer_Grade__c FROM Giving_Score__c'); 
    }  






    global void execute(Database.BatchableContext bc, List<Giving_Score__c> scope){

        for(Giving_Score__c gs : scope){
            if(vals.size() >= 2){
                for(Integer i=0; i<vals.size()-1; i++){
                    if( gs.Volunteer_Score__c >= vals[i] && gs.Volunteer_Score__c < vals[i+1] )  {
                        gs.Volunteer_Grade__c = gradeValuesMap.values()[i];
                    }
                    else if (gs.Volunteer_Score__c  < vals[0]){
                        gs.Volunteer_Grade__c = gradeValuesMap.values()[0];
                    }
                    else if( gs.Volunteer_Score__c >= vals[vals.size()-1] ) {
                        gs.Volunteer_Grade__c = gradeValuesMap.values()[vals.size()-1];
                    }                   
                }
            }
        }
        update scope;
    }





    global void finish(Database.BatchableContext bc){
    PRGrade prg = new PRGrade();
    Id batchId = Database.executeBatch(prg);
    }
}