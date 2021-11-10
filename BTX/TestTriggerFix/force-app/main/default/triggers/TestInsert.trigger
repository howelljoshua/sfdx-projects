trigger TestInsert on Test__c (before insert, before update) 
{
    for (Test__c t : Trigger.New)
    {
        if(t.OwnerId !=null)
        {
            t.Ram__c = t.OwnerId;
        }
    }
}