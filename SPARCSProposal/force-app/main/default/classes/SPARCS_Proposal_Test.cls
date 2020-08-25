@isTest
public with sharing class SPARCS_Proposal_Test {
    
    public static testMethod void SPARCSpropTest1() {    
        SPARCS_Proposal__c prop = new SPARCS_Proposal__c(Name='New Proposal');
        insert prop;
        System.Test.startTest();
            System.assertEquals('New Proposal', SPARCS_Proposal.getName(prop.Id), 'Did not get the right name back');
        System.Test.stopTest();
    }
}
