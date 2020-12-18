Global class  AGScoreDistribution implements Queueable{

Global FINAL List<String> AGgrades = new List<String>{'B', 'B+', 'A-', 'A', 'A+'};
Global List<Giving_Score__c> gsList = new List<Giving_Score__c>();
Global List<Giving_Score__c> agsLeftovers = new List<Giving_Score__c>();
Global Integer counter;

    global void execute(QueueableContext qc){

        gsList = [SELECT Id, Annual_Giving_Score__c, Annual_Giving_Grade__c, Volunteer_Score__c, Research_Score__c
                  FROM Giving_Score__c ORDER BY Annual_Giving_Score__c ASC, Volunteer_Score__c ASC, Research_Score__c ASC];
           

          System.debug('Started AGScoreDistribution with this many Giving Scores: ' + gsList); 
        Integer numberInAgsBucket = (gsList.size() / agGrades.size());
          System.debug('number in each bucket: '+ numberInAgsBucket);
        Integer agsRemainder = Math.mod(gsList.size(), agGrades.size());
          System.debug('number of remainders' + agsRemainder);

        For(Integer i=0; i<agsRemainder; i++){
            agsLeftovers.add(gsList[i]); 
            gsList.remove(i);          
        }
        
        counter = 0;
        for(String grade : AGgrades) {            
            for(Integer i=0; i<(numberInAgsBucket); i++){                         
                gsList[counter].Annual_Giving_Grade__c = grade;            
                counter ++;
            }
        }
        
        for(Giving_Score__c gsc : AGSLeftovers){
            gsc.Annual_Giving_Grade__c = AGgrades[0];
            gsList.add(gsc);
            counter ++;
        }      
    update gsList;     
    ID jobID = System.enqueueJob(new VScoreDistribution());
    }
}