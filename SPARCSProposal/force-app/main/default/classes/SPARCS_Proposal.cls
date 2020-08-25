public with sharing class SPARCS_Proposal { 

    public static String getName(Id propId) {
        List<SPARCS_Proposal__c> props = [SELECT Id, Name FROM SPARCS_Proposal__c WHERE Id = :propId LIMIT 1];
        return props[0].name;
    }
}
