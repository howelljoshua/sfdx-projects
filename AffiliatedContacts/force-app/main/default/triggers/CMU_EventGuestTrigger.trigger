trigger CMU_EventGuestTrigger on AQB__EventGuest__c (before insert, after insert, after update, after delete) {
    CMU_EventGuestHandler eventHandler = new CMU_EventGuestHandler();

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            eventHandler.setAttendeeFields(Trigger.new);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isDelete) {
            eventHandler.updateContactAttendeeFields(Trigger.old);
        }
        else {
            eventHandler.updateContactAttendeeFields(Trigger.new);
        }
    }
}