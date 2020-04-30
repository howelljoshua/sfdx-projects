trigger ContactChangeEventTrigger on ContactChangeEvent (after insert) {
    List<ContactChangeEvent> changes = Trigger.new;
     
    Set<String> oppIds = new Set<String>();
     
    //Get all record Ids for this change and add it to a set for further processing
    for(ContactChangeEvent opp: changes){
        List<String> recordIds = opp.ChangeEventHeader.getRecordIds();
        oppIds.addAll(recordIds);
    }

    ContactHandler handler = new ContactHandler();
    handler.updateCommunityUsers(new List<String>(oppIds));

}