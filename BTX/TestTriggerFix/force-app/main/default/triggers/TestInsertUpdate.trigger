trigger TestInsertUpdate on Test__c (before insert,after insert,after update,before update)
{
    
    /*if(Trigger.isBefore){
String Zip3s = '';

for(Test__c t:Trigger.new)
{
if(t.Client_Code__c != null)
{
if(Pattern.matches('^INT.*$', t.Client_Code__c) && t.Client_Code__c != null)
{
t.OwnerId = '00530000004AXbI';
}
else if(Pattern.matches('^SCRI.*$', t.Client_Code__c) && t.Client_Code__c != null)
{
t.OwnerId = '00530000004CeTA'; 
//t.OwnerId = '00530000003eme7';
}
else if(t.Oncologist_Zip2__c != null  && t.Oncologist_Zip2__c.length() >= 5)
{
Zip3s += '\'' + t.Oncologist_Zip2__c.Substring(0,5) + '\',';
}
else if(t.Oncologist_Zip2__c == null && t.Pathologist_Zip__c != null && t.Pathologist_Zip__c.length() >= 5)
{
Zip3s += '\'' + t.Pathologist_Zip__c.Substring(0,5) + '\',';
}
}       
}

if(Zip3s != '')
{
Zip3s = Zip3s.Substring(0, Zip3s.Length() -1);
}
else
{

return;
}   
Map<String,Id> ownerMap = new Map<String,Id>();
String TerritoryQuery = 'Select Id, Zip5__c, Territory_Owner__c from Territory_Assignment__c where Country_Code_ISO2__c = \'US\' and Zip5__c in (' + Zip3s + ')';
system.debug(TerritoryQuery);
for(Territory_Assignment__c ta :  Database.query(TerritoryQuery))
{
ownerMap.put(ta.Zip5__c, ta.Territory_Owner__c);
}


for(Test__c t:Trigger.new)
{
if(t.Client_Code__c != null)
{
if(Pattern.matches('^INT.*$', t.Client_Code__c) && t.Client_Code__c != null)
{
t.OwnerId = '00530000004AXbI';
}
else if(Pattern.matches('^SCRI.*$', t.Client_Code__c) && t.Client_Code__c != null)
{
t.OwnerId = '00530000003eme7';
}
else if(t.Oncologist_Zip2__c != null && t.Oncologist_Zip2__c.length() >= 5)
{
String Zip3 = t.Oncologist_Zip2__c.Substring(0,5);
if(ownerMap.get(Zip3) != null)
{
t.OwnerId = ownerMap.get(Zip3);
}
}
else if(t.Oncologist_Zip2__c == null && t.Pathologist_Zip__c != null && t.Pathologist_Zip__c.length() >= 5)
{
String Zip4 = t.Pathologist_Zip__c.Substring(0,5);
if(ownerMap.get(Zip4) != null)
{
t.OwnerId = ownerMap.get(Zip4); 
}
}       
}
}
}*/
    
    /*
* Author: Forcebrain
* Date  : 09/17/2013
* 
* Updates the Onc. Followup Date Time or Path. Followup Date Time on the corresponding 
* Test__c records having the same Accession Number, when either Onc. Followup Date Time or 
* Path. Followup Date Time is updated by the User.  
*/
    /*    if(Trigger.isBefore){

TestInsertUpdateHandler handler = new TestInsertUpdateHandler();
if(Trigger.isInsert){
handler.OnBeforeInsert(Trigger.New);
}

if(Trigger.isUpdate){


//handler.OnBeforeUpdate(Trigger.New);
handler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
}

} */
    if(ExecuteTrigger.isEnabled('Test_Trigger__c')){
        if(Trigger.isAfter){
            
            //After Insert Operation
            if(Trigger.isInsert){
                TestInsertUpdateHandler.UpdatePhysicianCountOnInsert(Trigger.new);
                if(Test.isRunningTest())
                    TestInsertUpdateHandler.isTriggerExecuted = false;
                
                //Check for recursive trigger execution
                if(!TestInsertUpdateHandler.isTriggerExecuted){
                    
                    TestInsertUpdateHandler.isTriggerExecuted = true;
                    TestInsertUpdateHandler handler = new TestInsertUpdateHandler();
                    handler.OnAfterInsert(Trigger.new);
                }
            }
            
            //After Update Operation
            if(Trigger.isUpdate){
                TestInsertUpdateHandler.UpdatePhysicianCountOnAfterUpdate(Trigger.new,Trigger.oldMap);
                if(Test.isRunningTest())
                    TestInsertUpdateHandler.isTriggerExecuted = false;
                
                //Check for recursive trigger execution
                if(!TestInsertUpdateHandler.isTriggerExecuted){
                    
                    TestInsertUpdateHandler.isTriggerExecuted = true;
                    TestInsertUpdateHandler handler = new TestInsertUpdateHandler();
                    handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
                    TestInsertUpdateHandler.updateOrderOnInsert(Trigger.new); 
                }
            }
            
            if(Trigger.isDelete){
                TestInsertUpdateHandler.UpdatePhysicianCountOnInsert(Trigger.old);
            }
            
        }//isAfter
        if(Trigger.IsInsert && Trigger.IsBefore){
            TestInsertUpdateHandler.OnBeforeInsert(Trigger.New);
        }
        if(Trigger.IsUpdate && Trigger.IsBefore){
            TestInsertUpdateHandler.OnBeforeUpdate(Trigger.New,Trigger.OldMap);
        }
    }
        TestInsertUpdateHandler handler = new TestInsertUpdateHandler();
        if(Trigger.isAfter && Trigger.isInsert ){
            TestInsertUpdateHandler.updateOrderOnInsert(Trigger.new);       
        }
        
}