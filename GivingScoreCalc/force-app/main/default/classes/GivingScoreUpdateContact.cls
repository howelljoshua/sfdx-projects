Global class GivingScoreUpdateContact implements Queueable{

    global void execute(QueueableContext qc){
        List<Giving_Score__c> gsList = [SELECT Id, Contact__c, Annual_Giving_Grade__c, 
                                        Volunteer_Grade__c, Research_Grade__c 
                                        FROM Giving_Score__c];

        List<Id> conList = new List<Id>();
        for (Giving_Score__c gs : gsList){
            conList.add(gs.Contact__c);
        }

        Map<Id, Contact> conMap = new Map<Id, Contact>([SELECT Id, Giving_Score__c, Annual_Giving_Grade__c, 
                                                        Volunteer_Grade__c, Prospect_Research_Grade__c 
                                                        FROM Contact WHERE ID IN : conList]);


        for (Giving_Score__c g : gsList){
            if (conMap.containsKey(g.Contact__c)){
                Contact c = conMap.get(g.Contact__c);
                c.Giving_Score__c = g.Id;
                c.Annual_Giving_Grade__c = g.Annual_Giving_Grade__c;
                c.Volunteer_Grade__c = g.Volunteer_Grade__c;
                c.Prospect_Research_Grade__c = g.Research_Grade__c;
            }
        }
    Database.update(conMap.values(), false);
    }
}