trigger SIS_StudentTrigger on SIS_Student__c (before insert) {
    for (SIS_Student__c student : Trigger.new) {
        student.Name = student.First_Name__c + ' ' + student.Last_Name__c;
    }
}