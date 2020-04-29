public class Goals_ActivityReportUtility {

public static List<AQB__ActivityReportParticipant__c> visits = new List<AQB__ActivityReportParticipant__c>();

    public static void doWhat(List<AQB__ActivityReport__c> actReports ){
        DELETE [SELECT Id, AQB__User__c 
                FROM AQB__ActivityReportParticipant__c
                WHERE AQB__ActivityReport__c IN : actReports ];
    }
}