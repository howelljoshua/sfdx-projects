Global class AGScoreDistribution2 implements Database.Batchable<sObject>, Database.Stateful{

    Global FINAL List<String> AGgrades = new List<String>{'B', 'B+', 'A-', 'A', 'A+'};
    Global List<Giving_Score__c> gsList = new List<Giving_Score__c>();
    Global List<Giving_Score__c> agsLeftovers = new List<Giving_Score__c>();
    Global Integer counter;
    
        
        global Database.QueryLocator start(Database.BatchableContext bc) {
            return Database.getQueryLocator('SELECT Id, Annual_Giving_Score__c, Annual_Giving_Grade__c, Volunteer_Score__c, Volunteer_Grade__c FROM Giving_Score__c ORDER BY Annual_Giving_Score__c ASC, Volunteer_Score__c ASC'); 
        } 

        
        /*
        global void execute(System.QueueableContext qc){
            start(Database.BatchableContext);
        }
        */
        
        global void execute(Database.BatchableContext bc, List<Giving_Score__c> scope){
            this.gsList = scope;
               System.debug('Started AGScoreDistribution with this many Giving Scores: ' + gsList.size());
               System.debug('Started AGScoreDistribution with these Giving Scores: ' + gsList);
            Integer numberInAgsBucket = (gsList.size() / agGrades.size());        
            Integer agsRemainder = Math.mod(gsList.size(), agGrades.size());
               System.debug('agsRemainder has this many remainders: ' + agsRemainder);
    
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
        }
        
    
        global void finish(Database.BatchableContext bc){
        System.debug('Giving Scores updates with new Annual Giving Grades: ' + counter);
        //VScoreDistribution vsd = new VScoreDistribution();
        //Id batchId = Database.executeBatch(vsd);
        }  
    }