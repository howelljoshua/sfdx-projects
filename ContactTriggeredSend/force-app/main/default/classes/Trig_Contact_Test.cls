@isTest
public with sharing class Trig_Contact_Test {
    public static testMethod void Trig_Contact_Test() {
        Contact c = new Contact();
        c.lastName = 'Test';
        insert c;
    }
}
