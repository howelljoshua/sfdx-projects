@isTest
private class CustomQuickEventControllerTest {
     @TestSetup
    static void dataSetup(){
        
        Event_Landing_Page__c landingPageObj = new Event_Landing_Page__c();
        landingPageObj.Name = 'Test';
        landingPageObj.Default__c = true;
        landingPageObj.Event_Pass_Order__c = 1;
        landingPageObj.Event_Pass_Small_Column_Width__c = 'full';
        landingPageObj.Event_Pass_Medium_Column_Width__c = 'full';
        landingPageObj.Event_Pass_Large_Column_Width__c = 'full';
        landingPageObj.Attendees_Order__c = 2;
        landingPageObj.Attendee_Small_Column_Width__c = 'full';
        landingPageObj.Attendee_Medium_Column_Width__c = 'full';
        landingPageObj.Attendee_Large_Column_Width__c = 'full';
        landingPageObj.Event_Details_Order__c = 3;
        landingPageObj.Event_Details_Small_Column_Width__c = 'full';
        landingPageObj.Event_Details_Medium_Column_Width__c = 'full';
        landingPageObj.Event_Details_Large_Column_Width__c = 'full';
        landingPageObj.Venue_Details_Order__c = 4;
        landingPageObj.Venue_Details_Small_Column_Width__c = 'full';
        landingPageObj.Venue_Details_Medium_Column_Width__c = 'full';
        landingPageObj.Venue_Details_Large_Column_Width__c = 'full';
        landingPageObj.Agenda_Order__c = 5;
        landingPageObj.Agenda_Pass_Small_Column_Width__c = 'full';
        landingPageObj.Agenda_Details_Medium_Column_Width__c = 'full';
        landingPageObj.Agenda_Details_Large_Column_Width__c = 'full';
        insert landingPageObj;
        
        // Inserting Special Event Record
        evt__Special_Event__c objEvent = new evt__Special_Event__c();
        objEvent.Name = 'Conference Test';
        objEvent.evt__Start__c = system.now();
        objEvent.evt__End__c = system.now().addDays(1);
        objEvent.evt__Payment_Terms__c = 'Use Terms on Event Fee';
        objEvent.evt__Pay_Later_Description__c = 'Pay by check';
        objEvent.evt__Pay_Later_Attendee_Status__c = 'Payment Pending';
        objEvent.evt__Pay_Later_Date__c = 'Day of Registration';
        objEvent.evt__Days_Before_or_After__c = 1;
        objEvent.evt__Enable_Coupons__c = true;
        objEvent.evt__Max_Attendees__c = 10;
        objEvent.Display_Registrants__c = true;
        objEvent.Community_Visibility__c = 'All (Guest and Authenticated)';
        insert objEvent;
       

        // Inserting Event Fee Record
        evt__Event_Fee__c objEventFeeTest = new evt__Event_Fee__c();
        objEventFeeTest.Name = 'Test Fee';
        objEventFeeTest.evt__Category__c = 'Attendee';
        objEventFeeTest.evt__Amount__c = 100;
        objEventFeeTest.evt__Event__c = objEvent.Id;
        objEventFeeTest.evt__Active__c = true;
        insert objEventFeeTest;

        evt__Event_Product__c prodObj = new evt__Event_Product__c();
        prodObj.Name = 'Test';
        prodObj.evt__Price__c = 10;
        prodObj.evt__Special_Event__c = objEvent.Id;
        prodObj.evt__Description__c = 'Test';
        insert prodObj;

        Contact contactObj = new Contact();
        contactObj.LastName = 'Test';
        insert contactObj;  

		List<evt__Attendee__c> lstAttnd = new List<evt__Attendee__c>();
        evt__Attendee__c attendeeObj1 = new evt__Attendee__c();
        attendeeObj1.evt__Invitation_Status__c = 'Registered';
        attendeeObj1.evt__Contact__c = contactObj.Id;
        attendeeObj1.evt__Event__c = objEvent.Id;
		lstAttnd.add(attendeeObj1);
		evt__Attendee__c attendeeObj2 = new evt__Attendee__c();
        attendeeObj2.evt__Invitation_Status__c = 'Registered';
        attendeeObj2.evt__Contact__c = contactObj.Id;
        attendeeObj2.evt__Event__c = objEvent.Id;
		lstAttnd.add(attendeeObj2);
		evt__Attendee__c attendeeObj3 = new evt__Attendee__c();
        attendeeObj3.evt__Invitation_Status__c = 'Registered';
        attendeeObj3.evt__Contact__c = contactObj.Id;
        attendeeObj3.evt__Event__c = objEvent.Id;
		lstAttnd.add(attendeeObj3);
		evt__Attendee__c attendeeObj4 = new evt__Attendee__c();
        attendeeObj4.evt__Invitation_Status__c = 'Registered';
        attendeeObj4.evt__Contact__c = contactObj.Id;
        attendeeObj4.evt__Event__c = objEvent.Id;
		lstAttnd.add(attendeeObj4);
		evt__Attendee__c attendeeObj5 = new evt__Attendee__c();
        attendeeObj5.evt__Invitation_Status__c = 'Registered';
        attendeeObj5.evt__Contact__c = contactObj.Id;
        attendeeObj5.evt__Event__c = objEvent.Id;
		lstAttnd.add(attendeeObj5);
		evt__Attendee__c attendeeObj6 = new evt__Attendee__c();
        attendeeObj6.evt__Invitation_Status__c = 'Registered';
        attendeeObj6.evt__Contact__c = contactObj.Id;
        attendeeObj6.evt__Event__c = objEvent.Id;
		lstAttnd.add(attendeeObj6);
        insert lstAttnd;
    }

    static testMethod void testRegistrationPositive(){
        evt__Special_Event__c event = [SELECT Id FROM evt__Special_Event__c LIMIT 1];
        PageReference tempRef;
        
        Test.setCurrentPageReference(new PageReference('Page.customquickevent'));
        System.currentPageReference().getParameters().put('id', event.id);

        System.test.startTest();
        CustomQuickEventController controller = new CustomQuickEventController();
        controller.eventFeeWrapperList[0].quantity = 1;
        controller.gotoRegistration();
        controller.orderBy = 'Name';
        controller.sortList();
        controller.orderBy = 'Class';
        controller.sortList();
        controller.orderBy = 'School';
        controller.sortList();
        controller.orderBy = 'Title';
        controller.sortList();
        controller.orderBy = 'Company';
        controller.sortList();
        System.test.stopTest();
    }
}