public with sharing class CustomQuickEventController {
    public evt__Special_Event__c event {get;set;}
    public List<EventFeeWrapper> eventFeeWrapperList {get;set;}
    public List<evt__Event_Fee__c> eventFeeList;
    public String invitationCode {get;set;}
    public Decimal availSeats {get;set;}

    public Boolean soldOut{get;set;}
    public Boolean registrationClosed{get;set;}
    public Boolean disableRegButton {get;set;}

    public Boolean multiday {get;set;}
    public String eventStartDate {get;set;}
    public String eventEndDate {get;set;}
    public String eventStartTime {get;set;}
    public String eventEndTime {get;set;}

    public String eventFeesClasses {get;set;}
    public Decimal eventFeeOrder {get;set;}

    public String eventDetailsClasses {get;set;}
    public Decimal eventDetailsOrder {get;set;}

    public String eventVenueClasses {get;set;}
    public Decimal eventVenueOrder {get;set;}

    public String eventAgendaClasses {get;set;}
    public Decimal eventAgendaOrder {get;set;}

    public String eventAttendeesClasses {get;set;}
    public Decimal eventAttendeesOrder {get;set;}

    public List<RegistrantSortWrapper> regList; // This stores the sorted list of registrants
    public List<RegistrantWrapper> regWrapList {get;set;} // This stores the wrapper list of registrants
    public String orderBy {get;set;} // This stores the value by which the list is sorted (Name, Class, School)

    public Decimal attendeeColumn1Count {get;set;}
    public Decimal attendeeColumn2Count {get;set;}

	public Boolean noTcktsSelected {get;set;} // This is used to display and error msg when no tickets have been selected
	public Boolean atndeLimit {get;set;} // This is used to display and error msg when the attendee limit (max or additional) is exceeded
	public String param {get;set;} // This stores the tickets selected in the form of url parameters
    public Integer attndSelectionLimit {get;set;} // This stores the lesser of the two; max attendees and max additional attendees
	public Integer maxAttnd; // This stores the max attendees for the event and is used on the page to show the error message
    public String maxAddAttnd; // This stores the max additional attendees for the event and is used on the page to show the error message
    public Integer attndReg; // This stores the attendees registered for the event
    public Integer attndPend; // This stores the attendees pending payment for the event

    public CustomQuickEventController() {
        String eventId = '';
        String smallClass = ' fs-sm-';
        String mediumClass = ' fs-mg-';
        String largeClass = ' fs-lg';
        List<evt__Attendee__c> confirmedAttendees = new List<evt__Attendee__c>();
        List<Event_Landing_Page__c> landingPageSettings = new List<Event_Landing_Page__c>();
        eventFeeList = new List<evt__Event_Fee__c>();
        eventFeeWrapperList = new List<EventFeeWrapper>();
        soldOut = false;
        registrationClosed = false;
        disableRegButton = false;
        invitationCode = '';
        availSeats = 0;

        regList = new List<RegistrantSortWrapper>();
        regWrapList = new List<RegistrantWrapper>();

        multiday = false;
        eventStartDate = '';
        eventEndDate = '';
        eventStartTime = '';
        eventEndTime = '';
        
        eventFeesClasses = ' fs-cell ';
        eventFeeOrder = 0;
        eventDetailsClasses = ' fs-cell ';
        eventDetailsOrder = 0;
        eventVenueClasses = ' fs-cell ';
        eventVenueOrder = 0;
        eventAgendaClasses = ' fs-cell ';
        eventAgendaOrder = 0;
        eventAttendeesClasses = ' fs-cell ';
        eventAttendeesOrder = 0;

        attendeeColumn1Count = 0;
        attendeeColumn2Count = 0;

		noTcktsSelected = false;
		atndeLimit = false;
		param = '';
        maxAddAttnd = '';
        attndReg = 0;
        attndPend = 0;

        eventId = ApexPages.currentPage().getParameters().get('id');
        System.debug(eventId);

        if(String.isNotBlank(eventId)){
               

            List<evt__Special_Event__c> eventList = [ SELECT Id, Name, evt__Registration_Deadline__c, evt__Start__c, evt__End__c, evt__City__c,
                                                    evt__State__c, evt__Accept_Donations__c, evt__Suggested_Donation_Amounts__c, evt__Donation_Product__c,
                                                    evt__Donation_Option_Label__c, evt__Company_Field__c, evt__Salutation_Field__c, evt__Address_Fields__c, 
                                                    evt__Wait_List__c, evt__Attendees_Registered__c, evt__Attendees_Pending_Payment__c, evt__Max_Attendees__c, evt__Enable_Coupons__c, 
                                                    evt__Free_Event__c, evt__Payment_Terms__c, evt__Pay_Later_Description__c, evt__Max_Additional_Attendees__c, 
                                                    evt__Pay_Later_Date__c, evt__Days_Before_or_After__c, evt__Pay_Later_Attendee_Status__c, 
                                                    evt__Processor_Connection__c, evt__Currency_ISO_Code__c,  evt__Show_Available_Seats__c, 
                                                    evt__Publish_Agenda__c, evt__By_Invitation__c, evt__Show_Captcha__c, Custom_Gifts__c, evt__Landing_Page_HTML__c,
                                                    evt__Venue_Notes__c, evt__Venue_Name__c, evt__Street__c, evt__Postal_Code__c, evt__Country__c,
                                                    evt__Display_Map__c, evt__Agenda_HTML__c, Event_Landing_Page__c, 
                                                    Display_Registrants__c, Display_Class__c, Display_School__c, Display_Company__c, Display_Title__c 
                                                    FROM evt__Special_Event__c
                                                    WHERE Id = :eventId ];

            if(!eventList.isEmpty()){
                event = eventList[0];
                if(event.evt__Attendees_Registered__c != null) {
					attndReg = event.evt__Attendees_Registered__c.intValue();
				}
                if(event.evt__Attendees_Pending_Payment__c != null) {
					attndPend = event.evt__Attendees_Pending_Payment__c.intValue();
				}
				if(event.evt__Max_Attendees__c != null) {
					//maxAttnd = event.evt__Max_Attendees__c.intValue() - attndReg - attndPend;
                    maxAttnd = event.evt__Max_Attendees__c.intValue() - attndReg;
                    attndSelectionLimit = maxAttnd;
				}
                if(String.isNotBlank(event.evt__Max_Additional_Attendees__c)) {
					maxAddAttnd = event.evt__Max_Additional_Attendees__c;
                    if(attndSelectionLimit == null || attndSelectionLimit > Integer.valueOf(maxAddAttnd) + 1) {
                        attndSelectionLimit = Integer.valueOf(maxAddAttnd) + 1;
                    }
				}

                eventFeeList = [SELECT  Id, Name, evt__Amount__c ,evt__Order__c, evt__Category__c, evt__Event__c,
                                evt__Terms__c, evt__Pay_Later_Description__c, evt__Pay_Later_Options__c, evt__Pay_Later_Attendee_Status__c,
                                evt__Days_Before_or_After__c, evt__Description__c, evt__Refund_Policy__c,evt__Event__r.evt__Max_Additional_Attendees__c,
								evt__Limit_Per_Purchase__c
                                FROM  evt__Event_Fee__c
                                WHERE evt__Event__c = :eventId 
                                AND evt__Active__c = true
                                ORDER BY evt__Order__c];
                

                if(!eventFeeList.isEmpty()){
                    for(evt__Event_Fee__c eachFee: eventFeeList){
                        EventFeeWrapper eachFeeWrapper = new EventFeeWrapper(eachFee);
                        eventFeeWrapperList.add(eachFeeWrapper);
                    }

                }
                

                if(System.today() > event.evt__Registration_Deadline__c){
                    registrationClosed = true;
                    disableRegButton = true;
                }

                if(event.evt__Max_Attendees__c != null){
                    //availSeats = event.evt__Max_Attendees__c - (event.evt__Attendees_Registered__c + event.evt__Attendees_Pending_Payment__c);
                    availSeats = event.evt__Max_Attendees__c - event.evt__Attendees_Registered__c;
                    if(availSeats <= 0){
                        soldOut = true;
                        disableRegButton = true;
                    }
                }

                if(event.Display_Registrants__c){
                    confirmedAttendees = [SELECT Id, evt__Contact__r.Name,
                                            evt__Contact__r.AQB__School__c,
                                            evt__Contact__r.AQB__PreferredYear__c,
                                            evt__Contact__r.AQB__EmployerName__c,
                                            evt__Contact__r.AQB__PrimaryEmploymentTitle__c
                                          FROM evt__Attendee__c 
                                          WHERE evt__Event__c = :eventId 
                                          AND evt__Invitation_Status__c = 'Registered'
                                          AND Landing_Display_Opt_out__c = false
                                          ORDER BY evt__Contact__r.Name];
                    if(!confirmedAttendees.isEmpty()){
                        for(evt__Attendee__c reg : confirmedAttendees) {
                            regList.add(new RegistrantSortWrapper(reg));
                            System.debug(reg.evt__Contact__r.Name);
                        }
                        createRegList();

                        if(!regWrapList.isEmpty() && regWrapList.size() > 5){
                            System.debug(attendeeColumn1Count);
                            attendeeColumn1Count = regWrapList.size();
                            attendeeColumn1Count = attendeeColumn1Count.divide(2, 2);
                            System.debug(attendeeColumn1Count);
                            attendeeColumn1Count = attendeeColumn1Count.round(System.RoundingMode.CEILING);
                            System.debug(attendeeColumn1Count);
                            attendeeColumn2Count = regWrapList.size() - attendeeColumn1Count;
                            System.debug(attendeeColumn2Count);
                        }else{
                            attendeeColumn1Count = regWrapList.size();
                            attendeeColumn2Count = 0;
                        }
                        
                    }
                }
                if(String.isNotBlank(event.Event_Landing_Page__c)){
                    landingPageSettings = [SELECT Id, 
                                                Agenda_Details_Large_Column_Width__c, Agenda_Details_Medium_Column_Width__c, Agenda_Pass_Small_Column_Width__c, Agenda_Order__c,
                                                Attendee_Large_Column_Width__c, Attendee_Medium_Column_Width__c, Attendee_Small_Column_Width__c, Attendees_Order__c,
                                                Event_Details_Large_Column_Width__c, Event_Details_Medium_Column_Width__c, Event_Details_Small_Column_Width__c, Event_Details_Order__c,
                                                Event_Pass_Large_Column_Width__c, Event_Pass_Medium_Column_Width__c, Event_Pass_Small_Column_Width__c, Event_Pass_Order__c,
                                                Venue_Details_Large_Column_Width__c, Venue_Details_Medium_Column_Width__c, Venue_Details_Small_Column_Width__c, Venue_Details_Order__c   
                                            FROM Event_Landing_Page__c
                                            WHERE Id = :event.Event_Landing_Page__c 
                                            LIMIT 1];
                }else{
                    landingPageSettings = [SELECT Id, 
                                                Agenda_Details_Large_Column_Width__c, Agenda_Details_Medium_Column_Width__c, Agenda_Pass_Small_Column_Width__c, Agenda_Order__c,
                                                Attendee_Large_Column_Width__c, Attendee_Medium_Column_Width__c, Attendee_Small_Column_Width__c, Attendees_Order__c,
                                                Event_Details_Large_Column_Width__c, Event_Details_Medium_Column_Width__c, Event_Details_Small_Column_Width__c, Event_Details_Order__c,
                                                Event_Pass_Large_Column_Width__c, Event_Pass_Medium_Column_Width__c, Event_Pass_Small_Column_Width__c, Event_Pass_Order__c,
                                                Venue_Details_Large_Column_Width__c, Venue_Details_Medium_Column_Width__c, Venue_Details_Small_Column_Width__c, Venue_Details_Order__c   
                                            FROM Event_Landing_Page__c
                                            WHERE Default__c = true 
                                            LIMIT 1];
                }
                if(!landingPageSettings.isEmpty()){
                    //event pass
                    if(landingPageSettings[0].Event_Pass_Order__c != null){
                        eventFeeOrder = landingPageSettings[0].Event_Pass_Order__c;
                    }
                    if(String.isNotBlank(landingPageSettings[0].Event_Pass_Large_Column_Width__c)){
                        eventFeesClasses += ' fs-lg-' + landingPageSettings[0].Event_Pass_Large_Column_Width__c + ' ';
                    }else{
                        eventFeesClasses += ' fs-lg-full ';
                    }
                    if(String.isNotBlank(landingPageSettings[0].Event_Pass_Medium_Column_Width__c)){
                        eventFeesClasses += ' fs-mg-' + landingPageSettings[0].Event_Pass_Medium_Column_Width__c;
                    }else{
                        eventFeesClasses += ' fs-mg-full ';
                    }
                    if(String.isNotBlank(landingPageSettings[0].Event_Pass_Small_Column_Width__c)){
                        eventFeesClasses += ' fs-sm-' + landingPageSettings[0].Event_Pass_Small_Column_Width__c + ' ';
                    }else{
                        eventFeesClasses += ' fs-sm-full ';
                    }

                    //when and where
                    if(landingPageSettings[0].Venue_Details_Order__c != null){
                        eventVenueOrder =landingPageSettings[0].Venue_Details_Order__c;
                    }
                    if(String.isNotBlank(landingPageSettings[0].Venue_Details_Large_Column_Width__c)){
                        eventVenueClasses += ' fs-lg-' + landingPageSettings[0].Venue_Details_Large_Column_Width__c + ' ';
                    }else{
                        eventVenueClasses += ' fs-lg-full ';
                    }
                    if(String.isNotBlank(landingPageSettings[0].Venue_Details_Medium_Column_Width__c)){
                        eventVenueClasses += ' fs-mg-' + landingPageSettings[0].Venue_Details_Medium_Column_Width__c;
                    }else{
                        eventVenueClasses += ' fs-mg-full ';
                    }
                    if(String.isNotBlank(landingPageSettings[0].Venue_Details_Small_Column_Width__c)){
                        eventVenueClasses += ' fs-sm-' + landingPageSettings[0].Venue_Details_Small_Column_Width__c + ' ';
                    }else{
                        eventVenueClasses += ' fs-sm-full ';
                    }


                    //event details/summary
                    if(landingPageSettings[0].Event_Details_Order__c != null){
                        eventDetailsOrder = landingPageSettings[0].Event_Details_Order__c;
                    }
                    if(String.isNotBlank(landingPageSettings[0].Event_Details_Large_Column_Width__c)){
                        eventDetailsClasses += ' fs-lg-' + landingPageSettings[0].Event_Details_Large_Column_Width__c + ' ';
                    }else{
                        eventDetailsClasses += ' fs-lg-full ';
                    }
                    if(String.isNotBlank(landingPageSettings[0].Event_Details_Medium_Column_Width__c)){
                        eventDetailsClasses += ' fs-mg-' + landingPageSettings[0].Event_Details_Medium_Column_Width__c;
                    }else{
                        eventDetailsClasses += ' fs-mg-full ';
                    }
                    if(String.isNotBlank(landingPageSettings[0].Event_Details_Small_Column_Width__c)){
                        eventDetailsClasses += ' fs-sm-' + landingPageSettings[0].Event_Details_Small_Column_Width__c + ' ';
                    }else{
                        eventDetailsClasses += ' fs-sm-full ';
                    }


                    //agenda
                    if(landingPageSettings[0].Agenda_Order__c != null){
                        eventAgendaOrder =landingPageSettings[0].Agenda_Order__c;
                    }
                    if(String.isNotBlank(landingPageSettings[0].Agenda_Details_Large_Column_Width__c)){
                        eventAgendaClasses += ' fs-lg-' + landingPageSettings[0].Agenda_Details_Large_Column_Width__c + ' ';
                    }else{
                        eventAgendaClasses += ' fs-lg-full ';
                    }
                    if(String.isNotBlank(landingPageSettings[0].Agenda_Details_Medium_Column_Width__c)){
                        eventAgendaClasses += ' fs-mg-' + landingPageSettings[0].Agenda_Details_Medium_Column_Width__c;
                    }else{
                        eventAgendaClasses += ' fs-mg-full ';
                    }
                    if(String.isNotBlank(landingPageSettings[0].Agenda_Pass_Small_Column_Width__c)){
                        eventAgendaClasses += ' fs-sm-' + landingPageSettings[0].Agenda_Pass_Small_Column_Width__c + ' ';
                    }else{
                        eventAgendaClasses += ' fs-sm-full ';
                    }

                    //display registrants
                    if(landingPageSettings[0].Attendees_Order__c != null){
                        eventAttendeesOrder =landingPageSettings[0].Attendees_Order__c;
                    }
                    if(String.isNotBlank(landingPageSettings[0].Attendee_Large_Column_Width__c)){
                        eventAttendeesClasses += ' fs-lg-' + landingPageSettings[0].Attendee_Large_Column_Width__c + ' ';
                    }else{
                        eventAttendeesClasses += ' fs-lg-full ';
                    }
                    if(String.isNotBlank(landingPageSettings[0].Attendee_Medium_Column_Width__c)){
                        eventAttendeesClasses += ' fs-mg-' + landingPageSettings[0].Attendee_Medium_Column_Width__c;
                    }else{
                        eventAttendeesClasses += ' fs-mg-full ';
                    }
                    if(String.isNotBlank(landingPageSettings[0].Attendee_Small_Column_Width__c)){
                        eventAttendeesClasses += ' fs-sm-' + landingPageSettings[0].Attendee_Small_Column_Width__c + ' ';
                    }else{
                        eventAttendeesClasses += ' fs-sm-full ';
                    }
                    

                    
                }

                Date startDate = event.evt__Start__c == NULL ? NULL : Date.newinstance(event.evt__Start__c.year(), event.evt__Start__c.month(), event.evt__Start__c.day());
                Date endDate = event.evt__End__c == NULL ? NULL : Date.newinstance(event.evt__End__c.year(), event.evt__End__c.month(), event.evt__End__c.day());
                eventStartDate = event.evt__Start__c == NULL ? '' : event.evt__Start__c.format('MM/dd/yyyy');
                eventEndDate = event.evt__End__c == NULL ? '' : event.evt__End__c.format('MM/dd/yyyy');
                eventStartTime = event.evt__Start__c == NULL ? '' : event.evt__Start__c.format('hh:mm a');
                eventEndTime = event.evt__End__c == NULL ? '' : event.evt__End__c.format('hh:mm a');

                if(startDate != NULL && endDate != NULL && startDate != endDate){
                    multiday = true;
                }
            }
        }else{
            //display error
        }
    }

    public void createRegList() {
        regWrapList = new List<RegistrantWrapper>();
        for(RegistrantSortWrapper registrant : regList) {
            System.debug(registrant.reg.Id);
            if(String.isNotBlank(registrant.reg.evt__Contact__c)) {
                RegistrantWrapper regWrap = new RegistrantWrapper();
                System.debug(String.isBlank(registrant.reg.evt__Contact__r.Name));
                if(String.isNotBlank(registrant.reg.evt__Contact__r.Name)) {
                    regWrap.name = registrant.reg.evt__Contact__r.Name;
                }
                if(String.isNotBlank(registrant.reg.evt__Contact__r.AQB__PreferredYear__c)) {
                    regWrap.className = registrant.reg.evt__Contact__r.AQB__PreferredYear__c;
                }
                if(String.isNotBlank(registrant.reg.evt__Contact__r.AQB__School__c)) {
                    regWrap.school = registrant.reg.evt__Contact__r.AQB__School__c;
                }
                if(String.isNotBlank(registrant.reg.evt__Contact__r.AQB__EmployerName__c)) {
                    regWrap.title = registrant.reg.evt__Contact__r.AQB__EmployerName__c;
                }
                if(String.isNotBlank(registrant.reg.evt__Contact__r.AQB__PrimaryEmploymentTitle__c)) {
                    regWrap.company = registrant.reg.evt__Contact__r.AQB__PrimaryEmploymentTitle__c;
                }
                System.debug(regWrap);
                regWrapList.add(regWrap);
            }
        }
    }

    public void sortList() {
        // This if block sets the field according to which the list needs to be sorted
        if(orderBy.equals('Name')) {
            RegistrantSortWrapper.field = 'Name';
        }
        else if(orderBy.equals('Class')) {
            RegistrantSortWrapper.field = 'Class';
        }
        else if(orderBy.equals('School')) {
            RegistrantSortWrapper.field = 'School';
        }
        else if(orderBy.equals('Title')) {
            RegistrantSortWrapper.field = 'Title';
        }
        else if(orderBy.equals('Company')) {
            RegistrantSortWrapper.field = 'Company';
        }
        regList.sort();
        createRegList();
    }

    public void gotoRegistration(){
		Integer quantitySum = 0;
		param = '';
		noTcktsSelected = false;
		for(Integer count = 0; count < eventFeeWrapperList.size(); count++) {
			quantitySum += eventFeeWrapperList[count].quantity;
			param += '&qty' + count + '=' + eventFeeWrapperList[count].quantity;
		}
		param += '&crno=' + quantitySum;
		if(String.isNotBlank(invitationCode)) {
			param += '&invcode=' + invitationCode;
		}
		param = param.replaceFirst('&', '?');

		// These conditions are applied to check if current selection of attendees is within the max limit
		if(quantitySum == 0){
			noTcktsSelected = true;
			atndeLimit = false;
		}
        // This checks the max additional attendee limit
		else if(String.isNotBlank(maxAddAttnd) && quantitySum > Integer.valueOf(maxAddAttnd) + 1) {
			noTcktsSelected = false;
			atndeLimit = true;
		}
        // This checks the max attendee limit
        else if(maxAttnd != null && quantitySum > maxAttnd) {
            noTcktsSelected = false;
			atndeLimit = true;
        }
		else {
			noTcktsSelected = false;
			atndeLimit = false;
		}
        System.debug(quantitySum + ' - ' + noTcktsSelected + ' - ' + atndeLimit);
    }

    
    public class EventFeeWrapper{
        public String eventFeeName {get;set;}
        public Decimal price {get;set;}
        public Integer quantity {get;set;}
        public evt__Event_Fee__c fee {get;set;}
        public List<SelectOption> ticketCountOptions {get;set;}

        public EventFeeWrapper(evt__Event_Fee__c fee){
            Integer maxAttendee = 0;
            eventFeeName = fee.Name;
            price = fee.evt__Amount__c ;
            this.fee = fee;
            quantity = 0;
            ticketCountOptions = new List<SelectOption>();
            if(String.isNotBlank(fee.evt__Event__r.evt__Max_Additional_Attendees__c) &&
				fee.evt__Limit_Per_Purchase__c != null){
					if(Integer.valueOf(fee.evt__Event__r.evt__Max_Additional_Attendees__c) + 1 < fee.evt__Limit_Per_Purchase__c) {
						maxAttendee = Integer.valueOf(fee.evt__Event__r.evt__Max_Additional_Attendees__c) + 1;
					}
					else {
						maxAttendee = Integer.valueOf(fee.evt__Limit_Per_Purchase__c);
					}
			}
			else if(String.isNotBlank(fee.evt__Event__r.evt__Max_Additional_Attendees__c)) {
                maxAttendee = Integer.valueOf(fee.evt__Event__r.evt__Max_Additional_Attendees__c) + 1;
            }
			else if(fee.evt__Limit_Per_Purchase__c != null) {
				maxAttendee = Integer.valueOf(fee.evt__Limit_Per_Purchase__c);
			}
			else{
                maxAttendee = 1;
            }

            for(Integer counter = 0; counter <= maxAttendee; counter++){
                ticketCountOptions.add(new SelectOption(String.valueOf(counter), String.valueOf(counter)));
            }
            
        }
    }

    public with sharing class RegistrantWrapper {
        public String name {get;set;}
        public String className {get;set;}
        public String school {get;set;}
        public String title {get;set;}
        public String company {get;set;}
    }
    
}