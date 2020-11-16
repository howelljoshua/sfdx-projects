Global class PRScoreDistribution implements Queueable{

Global FINAL List<String> prGrades = new List<String>{'B', 'B+', 'A-', 'A', 'A+'};    
Global List<Giving_Score__c> gsList = new List<Giving_Score__c>();
Global List<Giving_Score__c> prLeftovers = new List<Giving_Score__c>();
Global Integer counter;

    global void execute(QueueableContext qc){

        gsList = [SELECT Id, Research_Score__c, Research_Grade__c, Annual_Giving_Score__c, Volunteer_Score__c
                    FROM Giving_Score__c ORDER BY Research_Score__c ASC, Annual_Giving_Score__c ASC, Volunteer_Score__c ASC];
            

            System.debug('Started PRscoreDistribution with this many Giving Scores: ' + gsList);     
        Integer numberInPrBucket = (gsList.size() / prGrades.size());
            System.debug('number in each bucket: '+ numberInPrBucket);
        Integer prRemainder = Math.mod(gsList.size(), prGrades.size());
            System.debug('number of remainders' + prRemainder);

        For(Integer i=0; i<prRemainder; i++){
            prLeftovers.add(gsList[i]); 
            gsList.remove(i);          
        }
        
        counter = 0;
        for(String grade : prGrades) {            
            for(Integer i=0; i<(numberInPrBucket); i++){                       
                gsList[counter].Research_Grade__c = grade;            
                counter ++;
            }
        }
        
        for(Giving_Score__c gsc : prLeftovers){
            gsc.Research_Grade__c = prGrades[0];
            gsList.add(gsc);
            counter ++;
        }        
    update gsList;     
    ID jobID = System.enqueueJob(new GivingScoreUpdateContact());
    }
}