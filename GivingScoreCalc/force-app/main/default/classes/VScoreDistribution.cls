Global class VScoreDistribution implements Queueable{

Global FINAL List<String> Vgrades = new List<String>{'B', 'B+', 'A-', 'A', 'A+'};    
Global List<Giving_Score__c> gsList = new List<Giving_Score__c>();
Global List<Giving_Score__c> vsLeftovers = new List<Giving_Score__c>();
Global Integer counter;

    global void execute(QueueableContext qc){

        gsList = [SELECT Id, Volunteer_Score__c, Volunteer_Grade__c, Annual_Giving_Score__c, Research_Score__c
                 FROM Giving_Score__c ORDER BY Volunteer_Score__c ASC, Annual_Giving_Score__c ASC, Research_Score__c ASC];
            

          System.debug('Started VScoreDistribution with this many Giving Scores: ' + gsList);     
        Integer numberInVsBucket = (gsList.size() / VGrades.size());
          System.debug('number in each bucket: '+ numberInVsBucket);
        Integer VsRemainder = Math.mod(gsList.size(), VGrades.size());
          System.debug('number of remainders' + vsRemainder);

        For(Integer i=0; i<VsRemainder; i++){
            VsLeftovers.add(gsList[i]); 
            gsList.remove(i);          
        }
        
        counter = 0;
        for(String grade : Vgrades) {            
            for(Integer i=0; i<(numberInVsBucket); i++){                       
                gsList[counter].Volunteer_Grade__c = grade;            
                counter ++;
            }
        }
        
        for(Giving_Score__c gsc : VsLeftovers){
            gsc.Volunteer_Grade__c = Vgrades[0];
            gsList.add(gsc);
            counter ++;
        }        
    update gsList; 
    ID jobID = System.enqueueJob(new PRScoreDistribution());
    }
}