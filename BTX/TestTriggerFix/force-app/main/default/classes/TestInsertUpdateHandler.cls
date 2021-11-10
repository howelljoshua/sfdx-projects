/*  A handler class that handles the updation of existing Test object  Records field  Assertion Number .
*  Whenever the Onc. F/U Date Field or Path F/U Date Field is added or updated in the existing or newly
*  inserted test object this handler will update the Onc. F/U Date Field or Path F/U Date Field of the 
*  existing test object records having the Assertion Number field value.
*
*  Activity History 
*  Apex TestClassName: TestInsertUpdateTriggerTest
*  
*  Version    Author        Date             Description  
*  1.0        ForceBrain    9/17/2013        Initial Draft
*/

public with sharing class TestInsertUpdateHandler {
    
    //static variable to avoid recursion.  
    public static Boolean isTriggerExecuted = false;
    
    //Constructor
    public TestInsertUpdateHandler(){}
    
    
    /*     //on BeforeInsert
public void OnBeforeInsert(List<Test__c> pNewRecords){
Set<String> setZipCodes = new Set<String>();
List<Test__c> listIntegrationUserTest = new List<Test__c>();
List<Test__c> listRegionalAccountTest = new List<Test__c>();
for(Test__c objTest: pNewRecords){

if(objTest.Ordering_Physician__c <> NULL && objTest.Ordering_Physician__c.Trim().equalsIgnoreCase('Oncologist') &&
(objTest.Facility_Zip__c <> NULL || objTest.Facility_Zip__c <> '')){
system.debug('in Onclologist');
setZipCodes.add(objTest.Facility_Zip__c);
listRegionalAccountTest.add(objTest);

}

else if(objTest.Ordering_Physician__c <> NULL && objTest.Ordering_Physician__c.Trim().equalsIgnoreCase('Pathologist') &&
(objTest.Client_Zip__c <> NULL || objTest.Client_Zip__c <> '')){
system.debug('in pathologist');
setZipCodes.add(objTest.Client_Zip__c);
listRegionalAccountTest.add(objTest);
}

else{
system.debug('withoutBoth');
listIntegrationUserTest.add(objTest);
}
}

AssingTestOwner objTest = new AssingTestOwner();
system.debug('*****listRegionalAccountTest**'+listRegionalAccountTest);
if(listRegionalAccountTest.size()>0)
objTest.AssignRegionalAccountManager(setZipCodes, listRegionalAccountTest);
if(listIntegrationUserTest.size()>0)
objTest.AssignIntegrationUser(listIntegrationUserTest);


}//onBeforeInsert Ends

//on BeforeInsert
public void OnBeforeUpdate(Map<Id,Test__c> pMapNewTestRecords, Map<Id,Test__c> pMapOldTestRecords){
List<Test__c> ListNeverUpdateRecords = new List<Test__c>(); 
List<Test__c> ListNewUpdateRecords = new List<Test__c>();
for(Id testID: pMapNewTestRecords.keyset()){

if(((pMapNewTestRecords.get(testID).OwnerId <> pMapOldTestRecords.get(testID).OwnerId) &&
(pMapNewTestRecords.get(testID).Facility_Zip__c  == pMapOldTestRecords.get(testID).Facility_Zip__c) && 
(pMapNewTestRecords.get(testID).Client_Zip__c == pMapOldTestRecords.get(testID).Client_Zip__c)) ||
((pMapNewTestRecords.get(testID).OwnerId == pMapOldTestRecords.get(testID).OwnerId) &&
(pMapNewTestRecords.get(testID).Facility_Zip__c  == pMapOldTestRecords.get(testID).Facility_Zip__c) && 
(pMapNewTestRecords.get(testID).Client_Zip__c == pMapOldTestRecords.get(testID).Client_Zip__c)))
{ 
ListNeverUpdateRecords.add(pMapNewTestRecords.get(testID));
}
else
ListNewUpdateRecords.add(pMapNewTestRecords.get(testID)) ;
}//for


Set<String> setZipCodes = new Set<String>();
List<Test__c> listIntegrationUserTest = new List<Test__c>();
List<Test__c> listRegionalAccountTest = new List<Test__c>();
for(Test__c objTest: ListNewUpdateRecords){
if(objTest.Ordering_Physician__c <> NULL && (objTest.Facility_Zip__c <> NULL || objTest.Facility_Zip__c <> '') 
&& (objTest.Client_Zip__c <> NULL || objTest.Client_Zip__c <> ''))  {
if(objTest.Ordering_Physician__c <> NULL && objTest.Ordering_Physician__c.Trim().equalsIgnoreCase('Oncologist') &&
(objTest.Facility_Zip__c <> NULL || objTest.Facility_Zip__c <> '')){
setZipCodes.add(objTest.Facility_Zip__c);
listRegionalAccountTest.add(objTest);

}

else if(objTest.Ordering_Physician__c <> NULL && objTest.Ordering_Physician__c.Trim().equalsIgnoreCase('Pathologist') &&
(objTest.Client_Zip__c <> NULL || objTest.Client_Zip__c <> '')){
setZipCodes.add(objTest.Client_Zip__c);
listRegionalAccountTest.add(objTest);
}

else
listIntegrationUserTest.add(objTest);        
}       

}

AssingTestOwner objTest = new AssingTestOwner();
system.debug('*****listRegionalAccountTest**'+listRegionalAccountTest);
if(listRegionalAccountTest.size()> 0)
objTest.AssignRegionalAccountManager(setZipCodes, listRegionalAccountTest);
if(listIntegrationUserTest.size() > 0)
objTest.AssignIntegrationUser(listIntegrationUserTest);
system.debug('*******listRegionalAccountTest****'+listRegionalAccountTest);
system.debug('*********listIntegrationUserTest****'+listIntegrationUserTest);
}//onBeforeInsert Ends
*/     
    
    
    //On AfterInsert
    public void OnAfterInsert(List<Test__c> pNewRecords){
        
        Map<String, Test__c> mapUpdateOncFollowUpTest = new Map<String, Test__c>();
        Map<String, Test__c> mapUpdatePtFollowUpTest = new Map<String, Test__c>();
        SET<Id> orderIds = new SET<Id>();
        SET<Id> testIds = new SET<Id>();
        List<String> testNamesList = new List<String>();
        for(Test__c objTest : pNewRecords){
            
            if(String.isNotBlank(objTest.Accession_Number__c)){
                
                if(objTest.Onc_F_U_Date__c <> NULL)
                    mapUpdateOncFollowUpTest.put(objTest.Accession_Number__c, objTest);
                else if(objTest.Path_F_U_Date__c <> NULL)
                    mapUpdatePtFollowUpTest.put(objTest.Accession_Number__c, objTest);
            }
            
            if(objTest.Completion_Date__c != null){
                if(objTest.Orders__c != null){
                    orderIds.add(objTest.Orders__c);    
                }   
            }
            if(objTest.Completed__c == 'Yes' && objTest.Orders__c != null){
                //if(objTest.Orders__r.Order_Created_From_Portal__c){
                    testIds.add(objTest.Id);  
                    testNamesList.add(objTest.Name+'_Signed');
                //}  
            } 
        }//for
        if(testIds.size() > 0){
            String fileName = '%'+testNamesList[0]+'%';
            system.debug('fileName ------> '+fileName);
            List<ContentDocumentLink> cdlList = [SELECT Id, 
                                                        ContentDocument.Title, 
                                                        LinkedEntityId FROM ContentDocumentLink 
                                                        WHERE LinkedEntityId IN: testIds
                                                        AND ContentDocument.Title LIKE :fileName];
            system.debug('cdlList -------> '+cdlList);
            system.debug('cdlList size -------> '+cdlList.size());
            if(cdlList.size() > 0){
                SendEmailToPortalUsers SEP = new SendEmailToPortalUsers();
                SEP.sendEmail(testIds);     
            }
        }
        if(orderIds.size() > 0){
            List<SRP__c> ordersList = [SELECT Id, Test_Report_Available__c, Status_For_Community__c FROM SRP__c WHERE Id IN: orderIds]; 
            if(ordersList.size() > 0){
                for(SRP__c ord : ordersList){
                    ord.Test_Report_Available__c = true;
                    ord.Status_For_Community__c = 'Completed';
                } 
                update ordersList;
            }
        }
        
        UpdateFollowUpDate objInsertUpdateAction = new UpdateFollowUpDate();
        
        List<Test__c> listTestPathUpdate = objInsertUpdateAction.getTestRecordsByAccessionNum(mapUpdatePtFollowUpTest);
        List<Test__c> listTestOncUpdate = objInsertUpdateAction.getTestRecordsByAccessionNum(mapUpdateOncFollowUpTest);
        
        
        if(listTestPathUpdate != null && !listTestPathUpdate.isEmpty()) 
            objInsertUpdateAction.setFollowUpDate(listTestPathUpdate, 1, mapUpdatePtFollowUpTest);
        
        if(listTestOncUpdate != null && !listTestOncUpdate.isEmpty())          
            objInsertUpdateAction.setFollowUpDate(listTestOncUpdate, 0, mapUpdateOncFollowUpTest);
        
    }
    
    //On AfterUpdate
    public void OnAfterUpdate(List<Test__c> newTestRecords, Map<Id,Test__c> pMapNewTestRecords, Map<Id,Test__c> pMapOldTestRecords){
        
        List<Test__c> ListNewUpdateRecords = new List<Test__c>(); 
        SET<Id> testIds = new SET<Id>();
        List<String> testNamesList = new List<String>();
        for(Id testID: pMapNewTestRecords.keyset()){
            
            if(pMapNewTestRecords.get(testID).Path_F_U_Date__c <> pMapOldTestRecords.get(testID).Path_F_U_Date__c ||
               pMapNewTestRecords.get(testID).Onc_F_U_Date__c <> pMapOldTestRecords.get(testID).Onc_F_U_Date__c)
                
                ListNewUpdateRecords.add(pMapNewTestRecords.get(testID));
        }//for
        
        Map<String,Test__c> mapUpdateOncFollowUpTest = new Map<String,Test__c>();
        Map<String,Test__c> mapUpdatePtFollowUpTest = new Map<String,Test__c>();
        SET<Id> orderIds = new SET<Id>();
        for(Test__c objTest:ListNewUpdateRecords){
            
            if(objTest.Onc_F_U_Date__c <> NULL  && objTest.Accession_Number__c <> NULL)
                mapUpdateOncFollowUpTest.put(objTest.Accession_Number__c, objTest);
            
            if(objTest.Path_F_U_Date__c <> NULL && objTest.Accession_Number__c <> NULL)
                mapUpdatePtFollowUpTest.put(objTest.Accession_Number__c, objTest);
        }//for
        for(Test__c ts : newTestRecords){
            if(ts.Completion_Date__c != null){
                if(ts.Orders__c != null){
                    orderIds.add(ts.Orders__c);    
                }   
            } 
            if(ts.Completed__c == 'Yes' && pMapOldTestRecords.get(ts.Id).Completion_Date__c != ts.Completion_Date__c 
                && ts.Orders__c != null && pMapOldTestRecords.get(ts.Id).Completion_Date__c != null){
                //if(objTest.Orders__r.Order_Created_From_Portal__c){
                    testIds.add(ts.Id);  
                    testNamesList.add(ts.Name+'_Signed');
                //}  
            } 
        }
        if(testIds.size() > 0){
            String fileName = '%'+testNamesList[0]+'%';
            system.debug('fileName ------> '+fileName);
            List<ContentDocumentLink> cdlList = [SELECT Id, 
                                                        ContentDocument.Title, 
                                                        LinkedEntityId FROM ContentDocumentLink 
                                                        WHERE LinkedEntityId IN: testIds
                                                        AND ContentDocument.Title LIKE :fileName];
            system.debug('cdlList -------> '+cdlList);
            system.debug('cdlList size -------> '+cdlList.size());
            if(cdlList.size() > 0){
                SendEmailToPortalUsers SEP = new SendEmailToPortalUsers();
                SEP.sendEmail(testIds);     
            }
        }
        system.debug('orderIds -----> '+orderIds);
        if(orderIds.size() > 0){
            List<SRP__c> ordersList = [SELECT Id, Test_Report_Available__c, Status_For_Community__c FROM SRP__c WHERE Id IN: orderIds]; 
            system.debug('ordersList ------> '+ordersList);
            if(ordersList.size() > 0){
                for(SRP__c ord : ordersList){
                    ord.Test_Report_Available__c = true;
                    ord.Status_For_Community__c = 'Completed';
                } 
                update ordersList;
            }
            system.debug('ordersList -----> '+ordersList);
        }
        UpdateFollowUpDate objInsertUpdateAction = new UpdateFollowUpDate();
        List<Test__c> listTestPathUpdate = objInsertUpdateAction.getTestRecordsByAccessionNum(mapUpdatePtFollowUpTest);
        
        if(listTestPathUpdate != null && !listTestPathUpdate.isEmpty()) 
            objInsertUpdateAction.setFollowUpDate(listTestPathUpdate, 1, mapUpdatePtFollowUpTest);
        
        
        List<Test__c> listTestOncUpdate = objInsertUpdateAction.getTestRecordsByAccessionNum(mapUpdateOncFollowUpTest);
        if(listTestOncUpdate != null && !listTestOncUpdate.isEmpty())          
            objInsertUpdateAction.setFollowUpDate(listTestOncUpdate, 0, mapUpdateOncFollowUpTest);
    }
    
    //To populate CS Rep based on Owner (RAM CS Mapping.CS Agent)
    public static void OnBeforeInsert(List<Test__c> NewTestRecords){
        List<string> Owners = new List<string>();
        set<string> Territories = new set<string>();
        Map<String, String> ramCSMap = new Map<String, String>();
        for(Test__c test:NewTestRecords){
            Owners.Add(test.OwnerId);
        }
        
        List<RAM_CS_Mapping__c> RAMCSOwnerList = [SELECT Id, 
                                                  RAM_Owner__c,
                                                  CS_Agent__c
                                                  FROM RAM_CS_Mapping__c
                                                  Where RAM_Owner__c != null and RAM_Owner__c IN:Owners
                                                 ];
        //List<User> JessieUser = [select Id,Name from User where Name = 'Jessie Gaviola' limit 1];
        
        for(RAM_CS_Mapping__c RC : RAMCSOwnerList){
            ramCSMap.put(RC.RAM_Owner__c, RC.CS_Agent__c);        
        }
        
        for(Test__c test:NewTestRecords){
            if(test.Territory__c != null){
                Territories.Add(test.Territory__c);
            }
            if(ramCSMap.get(test.OwnerId) != null){
                test.User__c = ramCSMap.get(test.OwnerId);
            }else{
                test.User__c = null;
                //test.User__c = JessieUser[0].Id;
            }
        }
        
        List<string> GPShapes = new List<string>();
        Map<string,string> TerritoryVsGPShapeMap = new Map<string,string>();
        Map<string,string> GPShapeVsGPFolderMap = new Map<string,string>();
        List<string> GPFolders = new List<string>();
        Map<string,string> GPFolderVsGPParentFolderMap = new Map<string,string>();
        
        if(Territories.size() > 0){
            List<geopointe__GP_Assignment_Area__c> TerritoriesList = [select Id,Name,geopointe__Shape__c from geopointe__GP_Assignment_Area__c where Id IN:Territories];
            for(geopointe__GP_Assignment_Area__c Territory:TerritoriesList){
                if(Territory.geopointe__Shape__c != null){
                    system.debug('*******Shape1****'+Territory.geopointe__Shape__c);
                    GPShapes.Add(Territory.geopointe__Shape__c);
                    TerritoryVsGPShapeMap.put(Territory.Id,Territory.geopointe__Shape__c);
                }
            }
            if(GPShapes.size() > 0){
                List<geopointe__Shape__c> GpShapeList = [select Id,Name,geopointe__Folder__c from geopointe__Shape__c where Id IN:GPShapes];
                for(geopointe__Shape__c Gshape:GpShapeList){
                    if(Gshape.geopointe__Folder__c != null){
                        GPFolders.Add(Gshape.geopointe__Folder__c);
                        GPShapeVsGPFolderMap.put(Gshape.Id,Gshape.geopointe__Folder__c);
                    }
                }
            }
            if(GPFolders.size() > 0){
                List<geopointe__GP_Folder__c> GPFoldersList = [select Id,Name,geopointe__Parent_Folder__c from geopointe__GP_Folder__c where Id IN:GPFolders];
                for(geopointe__GP_Folder__c GPFolder:GPFoldersList){
                    if(GPFolder.geopointe__Parent_Folder__c != null){
                        GPFolderVsGPParentFolderMap.put(GPFolder.Id,GPFolder.geopointe__Parent_Folder__c);
                    }
                }
            }
        }
        for(Test__c test:NewTestRecords){
            if(test.Test_Type__c != null){
                if(test.Test_Type__c.contains('CTID')){
                    test.Product_Line__c = 'CTID';
                }
                else if(test.Test_Type__c.startsWith('NG') || test.Test_Type__c.startsWith('NH')){
                    test.Product_Line__c = 'NGS';
                }
                else if(test.Test_Type__c.contains('BCI') || test.Test_Type__c.contains('BLP') || test.Test_Type__c.contains('BDP') || test.Test_Type__c.contains('BDX') || test.Test_Type__c.contains('BLR')){
                    test.Product_Line__c = 'BCI';
                }
                else if(test.Test_Type__c.contains('SR')){
                    test.Product_Line__c = 'Summary Report';
                }
                else if(!test.Test_Type__c.contains('CTID') && !test.Test_Type__c.startsWith('NG') && !test.Test_Type__c.startsWith('NH') && !test.Test_Type__c.contains('BCI') && !test.Test_Type__c.contains('BDX') && !test.Test_Type__c.contains('BLR')){
                    test.Product_Line__c = 'Biomarkers';
                }
            }
            if(test.Territory__c != null){
                if(GPShapeVsGPFolderMap.get(TerritoryVsGPShapeMap.get(test.Territory__c)) != null){
                    test.Region__c = GPShapeVsGPFolderMap.get(TerritoryVsGPShapeMap.get(test.Territory__c));
                    if(GPFolderVsGPParentFolderMap.get(GPShapeVsGPFolderMap.get(TerritoryVsGPShapeMap.get(test.Territory__c))) != null){
                        test.Area__c = GPFolderVsGPParentFolderMap.get(GPShapeVsGPFolderMap.get(TerritoryVsGPShapeMap.get(test.Territory__c)));
                    }else{
                        test.Area__c = null;
                    }
                }else{
                    test.Region__c = null;
                    test.Area__c = null;
                }
            }
        }
        
    }
    
    //To populate CS Rep based on Owner (RAM CS Mapping.CS Agent)
    public static void OnBeforeUpdate(List<Test__c> NewTestRecords,Map<Id,Test__c> OldTestRecordsMap){
        List<string> Owners = new List<string>();
        set<string> Territories = new set<string>();
        List<string> TestIds = new List<string>();
        Map<String, String> ramCSMap = new Map<String, String>();
        SET<Id> geoCodeIds = new SET<Id>();
        Map<String, String> geoCodeCountryMap = new Map<String, String>();
        for(Test__c test:NewTestRecords){
            Owners.Add(test.OwnerId);
            if(test.Completion_Date__c != null && test.Completion_Date__c != OldTestRecordsMap.get(test.Id).Completion_Date__c){
                if(test.Is_Updated_First_Time__c && !test.Is_Completion_Date_Changed__c){
                	test.Is_Updated_First_Time__c = true;    
                }else if(test.Is_Updated_First_Time__c){
                    test.Is_Updated_First_Time__c = false;
                    test.Is_Completion_Date_Changed__c = true;
                }    
            }
        }
        
        List<RAM_CS_Mapping__c> RAMCSOwnerList = [SELECT Id, 
                                                  RAM_Owner__c,
                                                  CS_Agent__c
                                                  FROM RAM_CS_Mapping__c
                                                  Where RAM_Owner__c != null and RAM_Owner__c IN:Owners
                                                 ];
        //List<User> JessieUser = [select Id,Name from User where Name = 'Jessie Gaviola' limit 1];
        for(RAM_CS_Mapping__c RC : RAMCSOwnerList){
            ramCSMap.put(RC.RAM_Owner__c, RC.CS_Agent__c);        
        }
        
        for(Test__c test:NewTestRecords){
            if(test.Territory__c != OldTestRecordsMap.get(test.Id).Territory__c){
                if(test.Territory__c != null){
                    Territories.Add(test.Territory__c);    
                }
                if(test.Geopointe_Geocode__c != null){
                    geoCodeIds.add(test.Geopointe_Geocode__c);    
                }
            }
            if(test.Geopointe_Geocode__c != OldTestRecordsMap.get(test.Id).Geopointe_Geocode__c){
                if(test.Geopointe_Geocode__c != null){
                    geoCodeIds.add(test.Geopointe_Geocode__c);    
                }
            }
            if(test.OwnerId != OldTestRecordsMap.get(test.Id).OwnerId){
                if(ramCSMap.get(test.OwnerId) != null){
                    test.User__c = ramCSMap.get(test.OwnerId);
                }
                else{
                    test.User__c = null;
                    //test.User__c = JessieUser[0].Id;
                }
            }
        }
        
        List<string> GPShapes = new List<string>();
        Map<string,string> TerritoryVsGPShapeMap = new Map<string,string>();
        Map<string,string> GPShapeVsGPFolderMap = new Map<string,string>();
        List<string> GPFolders = new List<string>();
        Map<string,string> GPFolderVsGPParentFolderMap = new Map<string,string>();
        //Map<String, String> geoCodeCountryMap = new Map<String, String>();
        List<geopointe__Geocode__c> geocodesList = new List<geopointe__Geocode__c>();
        List<geopointe__GP_Assignment_Plan__c> plan = [SELECT Id, Name FROM geopointe__GP_Assignment_Plan__c WHERE Name = 'Test Object' LIMIT 1];
        List<geopointe__GP_Assignment_Area__c> area = [SELECT Id, Name, geopointe__User__c FROM geopointe__GP_Assignment_Area__c WHERE Name = 'All International' AND geopointe__Assignment_Plan__c =: plan[0].Id LIMIT 1];
        List<geopointe__GP_Folder__c> folder = [SELECT Id, Name FROM geopointe__GP_Folder__c WHERE Name = 'International Sales' LIMIT 1];
        system.debug('geoCodeIds ------> '+geoCodeIds);
        if(geoCodeIds.size() > 0){
            geocodesList = [SELECT Id,
                                    Name,
                                    geopointe__Country_clean__c 
                                    FROM geopointe__Geocode__c
                                    WHERE geopointe__Country_clean__c != 'US' AND Id IN: geoCodeIds];    
        }
        system.debug('geocodesList -------> '+geocodesList);
        if(geocodesList.size() > 0){
            for(geopointe__Geocode__c geocode : geocodesList){
                geoCodeCountryMap.put(geocode.Id, geocode.geopointe__Country_clean__c);
            } 
        }   
        if(Territories.size() > 0){
            List<geopointe__GP_Assignment_Area__c> TerritoriesList = [select Id,Name,geopointe__Shape__c from geopointe__GP_Assignment_Area__c where Id IN:Territories];
            for(geopointe__GP_Assignment_Area__c Territory:TerritoriesList){
                if(Territory.geopointe__Shape__c != null){
                    GPShapes.Add(Territory.geopointe__Shape__c);
                    TerritoryVsGPShapeMap.put(Territory.Id,Territory.geopointe__Shape__c);
                }
            }
            if(GPShapes.size() > 0){
                List<geopointe__Shape__c> GpShapeList = [select Id,Name,geopointe__Folder__c from geopointe__Shape__c where Id IN:GPShapes];
                for(geopointe__Shape__c Gshape:GpShapeList){
                    if(Gshape.geopointe__Folder__c != null){
                        GPFolders.Add(Gshape.geopointe__Folder__c);
                        GPShapeVsGPFolderMap.put(Gshape.Id,Gshape.geopointe__Folder__c);
                    }
                }
            }
            if(GPFolders.size() > 0){
                List<geopointe__GP_Folder__c> GPFoldersList = [select Id,Name,geopointe__Parent_Folder__c from geopointe__GP_Folder__c where Id IN:GPFolders];
                for(geopointe__GP_Folder__c GPFolder:GPFoldersList){
                    if(GPFolder.geopointe__Parent_Folder__c != null){
                        GPFolderVsGPParentFolderMap.put(GPFolder.Id,GPFolder.geopointe__Parent_Folder__c);
                    }
                }
            }
        }
        for(Test__c test:NewTestRecords){
            if(test.Test_Type__c != null){
                if(test.Test_Type__c.contains('CTID')){
                    test.Product_Line__c = 'CTID';
                }
                else if(test.Test_Type__c.startsWith('NG') || test.Test_Type__c.startsWith('NH')){
                    test.Product_Line__c = 'NGS';
                }
                else if(test.Test_Type__c.contains('BCI') || test.Test_Type__c.contains('BLP') || test.Test_Type__c.contains('BDP') || test.Test_Type__c.contains('BDX') || test.Test_Type__c.contains('BLR')){
                    test.Product_Line__c = 'BCI';
                }
                else if(test.Test_Type__c.contains('SR')){
                    test.Product_Line__c = 'Summary Report';
                }
                else if(!test.Test_Type__c.contains('CTID') && !test.Test_Type__c.startsWith('NG') && !test.Test_Type__c.startsWith('NH') && !test.Test_Type__c.contains('BCI') && !test.Test_Type__c.contains('BDX') && !test.Test_Type__c.contains('BLR')){
                    test.Product_Line__c = 'Biomarkers';
                }
            }
            if(geoCodeCountryMap.get(test.Geopointe_Geocode__c) != null){
                test.Region__c = folder[0].Id;
                test.Area__c = folder[0].Id;
                test.Territory__c = area[0].Id;
                test.OwnerId = area[0].geopointe__User__c;
                test.International__c = true;
            }else{
                if(test.Territory__c != null){
                    if(GPShapeVsGPFolderMap.get(TerritoryVsGPShapeMap.get(test.Territory__c)) != null){
                        test.Region__c = GPShapeVsGPFolderMap.get(TerritoryVsGPShapeMap.get(test.Territory__c));
                        if(GPFolderVsGPParentFolderMap.get(GPShapeVsGPFolderMap.get(TerritoryVsGPShapeMap.get(test.Territory__c))) != null){
                            test.Area__c = GPFolderVsGPParentFolderMap.get(GPShapeVsGPFolderMap.get(TerritoryVsGPShapeMap.get(test.Territory__c)));
                        }else{
                            test.Area__c = GPShapeVsGPFolderMap.get(TerritoryVsGPShapeMap.get(test.Territory__c));    
                        }
                        test.International__c = false;
                    }
                }       
            }
            
        }
        //updateOrderOnInsert(NewTestRecords);
    }
    
    public static void UpdatePhysicianCountOnInsert(List<Test__c> TestRecords){
        Set<string> Oncologists = new Set<string>();
        Set<string> Pathologists = new Set<string>();
        Set<string> AllContacts = new Set<string>();
        Map<string,List<string>> OncologistMap = new Map<string,List<string>>();
        Map<string,List<string>> OncologistMapCTID = new Map<string,List<string>>();
        Map<string,List<string>> OncologistMapCurrYr = new Map<string,List<string>>();
        Map<string,List<string>> OncologistMapPrevYr = new Map<string,List<string>>();
        Map<string,List<string>> OncologistMapCurrYrCTID = new Map<string,List<string>>();
        Map<string,List<string>> OncologistMapPrevYrCTID = new Map<string,List<string>>();
        Map<string,List<string>> PathologistMap = new Map<string,List<string>>();
        Map<string,List<string>> PathologistMapCTID = new Map<string,List<string>>();
        Map<string,List<string>> PathologistMapCurrYr = new Map<string,List<string>>();
        Map<string,List<string>> PathologistMapPrevYr = new Map<string,List<string>>();
        Map<string,List<string>> PathologistMapCurrYrCTID = new Map<string,List<string>>();
        Map<string,List<string>> PathologistMapPrevYrCTID = new Map<string,List<string>>();
        
        for(Test__c test:TestRecords){
            if(test.Oncologist__c != null){
                Oncologists.Add(test.Oncologist__c);
                Pathologists.Add(test.Oncologist__c);
                AllContacts.Add(test.Oncologist__c);
            }
            if(test.Pathologist__c != null){
                Pathologists.Add(test.Pathologist__c);
                Oncologists.Add(test.Pathologist__c);
                AllContacts.Add(test.Pathologist__c);
            } 
        }
        
        List<Test__c> TestOncologists = [select Id,Oncologist__c,Date_Received__c,Product_Line__c  from Test__c where (Product_Line__c = 'BCI' Or Product_Line__c = 'CTID') And Oncologist__c IN:Oncologists And Ordering_Physician__c = 'Oncologist'];
        for(Test__c testRec:TestOncologists){
            if(testRec.Product_Line__c == 'BCI'){  
                if(testRec.Date_Received__c != null){
                    if(testRec.Date_Received__c.Year() == System.today().Year()){
                        if (OncologistMapCurrYr.containsKey(testRec.Oncologist__c)) {
                            OncologistMapCurrYr.get(testRec.Oncologist__c).add(testRec.Id);
                        }
                        else {
                            OncologistMapCurrYr.put(testRec.Oncologist__c, new List<string>{ testRec.Id });
                        }
                    }else if(Integer.valueof(testRec.Date_Received__c.Year()) == Integer.valueof(System.today().Year() - 1)){
                        if (OncologistMapPrevYr.containsKey(testRec.Oncologist__c)) {
                            OncologistMapPrevYr.get(testRec.Oncologist__c).add(testRec.Id);
                        }
                        else {
                            OncologistMapPrevYr.put(testRec.Oncologist__c, new List<string>{ testRec.Id });
                        }
                    }
                }
                
                if (OncologistMap.containsKey(testRec.Oncologist__c)) {
                    OncologistMap.get(testRec.Oncologist__c).add(testRec.Id);
                }
                else {
                    OncologistMap.put(testRec.Oncologist__c, new List<string>{ testRec.Id });
                }
            }else if(testRec.Product_Line__c == 'CTID'){
                if(testRec.Date_Received__c != null){
                    if(testRec.Date_Received__c.Year() == System.today().Year()){
                        if (OncologistMapCurrYrCTID.containsKey(testRec.Oncologist__c)) {
                            OncologistMapCurrYrCTID.get(testRec.Oncologist__c).add(testRec.Id);
                        }
                        else {
                            OncologistMapCurrYrCTID.put(testRec.Oncologist__c, new List<string>{ testRec.Id });
                        }
                    }else if(Integer.valueof(testRec.Date_Received__c.Year()) == Integer.valueof(System.today().Year() - 1)){
                        if (OncologistMapPrevYrCTID.containsKey(testRec.Oncologist__c)) {
                            OncologistMapPrevYrCTID.get(testRec.Oncologist__c).add(testRec.Id);
                        }
                        else {
                            OncologistMapPrevYrCTID.put(testRec.Oncologist__c, new List<string>{ testRec.Id });
                        }
                    }
                }
                
                if (OncologistMapCTID.containsKey(testRec.Oncologist__c)) {
                    OncologistMapCTID.get(testRec.Oncologist__c).add(testRec.Id);
                }
                else {
                    OncologistMapCTID.put(testRec.Oncologist__c, new List<string>{ testRec.Id });
                }
            }
        }
        List<Test__c> TestPathologists = [select Id,Pathologist__c,Date_Received__c,Product_Line__c  from Test__c where (Product_Line__c = 'BCI' Or Product_Line__c = 'CTID') And Pathologist__c IN:Pathologists And Ordering_Physician__c = 'Pathologist'];
        for(Test__c testRec:TestPathologists){
            if(testRec.Product_Line__c == 'BCI'){
                if(testRec.Date_Received__c != null){
                    if(testRec.Date_Received__c.Year() == System.today().Year()){
                        if (PathologistMapCurrYr.containsKey(testRec.Pathologist__c)) {
                            //if(OncologistMapCurrYr.get(testRec.Pathologist__c) != null){
                            //if(!OncologistMapCurrYr.get(testRec.Pathologist__c).contains(testRec.Id)){
                            PathologistMapCurrYr.get(testRec.Pathologist__c).add(testRec.Id);
                            //}
                            //}else{
                            //  PathologistMapCurrYr.get(testRec.Pathologist__c).add(testRec.Id);
                            //}
                        }
                        else {
                            //PathologistMapCurrYr.put(testRec.Pathologist__c, new List<Test__c>{ testRec });
                            //if(OncologistMapCurrYr.get(testRec.Pathologist__c) != null){
                            //  if(!OncologistMapCurrYr.get(testRec.Pathologist__c).contains(testRec.Id)){
                            PathologistMapCurrYr.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                            // }
                            // }else{
                            //  PathologistMapCurrYr.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                            //}
                        }
                    }else if(Integer.valueof(testRec.Date_Received__c.Year()) == Integer.valueof(System.today().Year() - 1)){
                        if (PathologistMapPrevYr.containsKey(testRec.Pathologist__c)) {
                            //if(OncologistMapPrevYr.get(testRec.Pathologist__c) != null){
                            //  if(!OncologistMapPrevYr.get(testRec.Pathologist__c).contains(testRec.Id)){
                            PathologistMapPrevYr.get(testRec.Pathologist__c).add(testRec.Id);
                            //}
                            //}else{
                            //  PathologistMapPrevYr.get(testRec.Pathologist__c).add(testRec.Id);
                            //}
                        }
                        else {
                            //if(OncologistMapPrevYr.get(testRec.Pathologist__c) != null){
                            // if(!OncologistMapPrevYr.get(testRec.Pathologist__c).contains(testRec.Id)){
                            PathologistMapPrevYr.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                            //}
                            // }else{
                            //    PathologistMapPrevYr.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                            //}
                        }
                    }
                }
                
                if (PathologistMap.containsKey(testRec.Pathologist__c)) {
                    //if(OncologistMap.get(testRec.Pathologist__c) != null){
                    //  if(!OncologistMap.get(testRec.Pathologist__c).contains(testRec.Id)){
                    PathologistMap.get(testRec.Pathologist__c).add(testRec.Id);
                    // }
                    // }else{
                    //     PathologistMap.get(testRec.Pathologist__c).add(testRec.Id);
                    // }
                }
                else {
                    //if(OncologistMap.get(testRec.Pathologist__c) != null){
                    // if(!OncologistMap.get(testRec.Pathologist__c).contains(testRec.Id)){
                    PathologistMap.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                    // }
                    // }else{
                    //    PathologistMap.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                    //}
                }
            }else if(testRec.Product_Line__c == 'CTID'){
                if(testRec.Date_Received__c != null){
                    if(testRec.Date_Received__c.Year() == System.today().Year()){
                        if (PathologistMapCurrYrCTID.containsKey(testRec.Pathologist__c)) {
                            //if(OncologistMapCurrYrCTID.get(testRec.Pathologist__c) != null){
                            //if(!OncologistMapCurrYrCTID.get(testRec.Pathologist__c).contains(testRec.Id)){
                            PathologistMapCurrYrCTID.get(testRec.Pathologist__c).add(testRec.Id);
                            // }
                            //}else{
                            //    PathologistMapCurrYrCTID.get(testRec.Pathologist__c).add(testRec.Id);
                            //}
                        }
                        else {
                            //if(OncologistMapCurrYrCTID.get(testRec.Pathologist__c) != null){
                            //  if(!OncologistMapCurrYrCTID.get(testRec.Pathologist__c).contains(testRec.Id)){
                            PathologistMapCurrYrCTID.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                            //    }
                            // }else{
                            //    PathologistMapCurrYrCTID.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                            //}
                        }
                    }else if(Integer.valueof(testRec.Date_Received__c.Year()) == Integer.valueof(System.today().Year() - 1)){
                        if (PathologistMapPrevYrCTID.containsKey(testRec.Pathologist__c)) {
                            //if(OncologistMapPrevYrCTID.get(testRec.Pathologist__c) != null){
                            //if(!OncologistMapPrevYrCTID.get(testRec.Pathologist__c).contains(testRec.Id)){
                            PathologistMapPrevYrCTID.get(testRec.Pathologist__c).add(testRec.Id);
                            //}
                            //}else{
                            //    PathologistMapPrevYrCTID.get(testRec.Pathologist__c).add(testRec.Id);
                            //}
                        }
                        else {
                            //if(OncologistMapPrevYrCTID.get(testRec.Pathologist__c) != null){
                            //  if(!OncologistMapPrevYrCTID.get(testRec.Pathologist__c).contains(testRec.Id)){
                            PathologistMapPrevYrCTID.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                            //    }
                            //}else{
                            //    PathologistMapPrevYrCTID.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                            //}
                        }
                    }
                }
                
                if (PathologistMapCTID.containsKey(testRec.Pathologist__c)) {
                    //if(OncologistMapCTID.get(testRec.Pathologist__c) != null){
                    //    if(!OncologistMapCTID.get(testRec.Pathologist__c).contains(testRec.Id)){
                    PathologistMapCTID.get(testRec.Pathologist__c).add(testRec.Id);
                    //    }
                    //}else{
                    //    PathologistMapCTID.get(testRec.Pathologist__c).add(testRec.Id);
                    //}
                }
                else {
                    //if(OncologistMapCTID.get(testRec.Pathologist__c) != null){
                    //    if(!OncologistMapCTID.get(testRec.Pathologist__c).contains(testRec.Id)){
                    PathologistMapCTID.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                    //    }
                    //}else{
                    //    PathologistMapCTID.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                    //}
                }
            }
        }
        List<Contact> ConListToUpdate = new List<Contact>();
        for(string contactId:AllContacts){
            Contact con = new Contact();
            con.Id = contactId;
            if(OncologistMap.get(contactId) != null && PathologistMap.get(contactId) != null){
                con.BCI_Volume_All_Time__c = Integer.valueof(OncologistMap.get(contactId).size() + PathologistMap.get(contactId).size());
            }else if(OncologistMap.get(contactId) != null && PathologistMap.get(contactId) == null){
                con.BCI_Volume_All_Time__c = Integer.valueof(OncologistMap.get(contactId).size());
            }
            else if(OncologistMap.get(contactId) == null && PathologistMap.get(contactId) != null){
                con.BCI_Volume_All_Time__c = Integer.valueof(PathologistMap.get(contactId).size());
            }else{
                con.BCI_Volume_All_Time__c = 0;
            }
            
            if(OncologistMapCurrYr.get(contactId) != null && PathologistMapCurrYr.get(contactId) != null){
                con.BCI_Volume_Current_Year__c = Integer.valueof(OncologistMapCurrYr.get(contactId).size() + PathologistMapCurrYr.get(contactId).size());
            }else if(OncologistMapCurrYr.get(contactId) != null && PathologistMapCurrYr.get(contactId) == null){
                con.BCI_Volume_Current_Year__c = Integer.valueof(OncologistMapCurrYr.get(contactId).size());
            }else if(OncologistMapCurrYr.get(contactId) == null && PathologistMapCurrYr.get(contactId) != null){
                con.BCI_Volume_Current_Year__c = Integer.valueof(PathologistMapCurrYr.get(contactId).size());
            }else{
                con.BCI_Volume_Current_Year__c = 0;
            }
            
            if(OncologistMapPrevYr.get(contactId) != null && PathologistMapPrevYr.get(contactId) != null){
                con.BCI_Volume_Prev_Year__c = Integer.valueof(OncologistMapPrevYr.get(contactId).size() + PathologistMapPrevYr.get(contactId).size());
            }else if(OncologistMapPrevYr.get(contactId) != null && PathologistMapPrevYr.get(contactId) == null){
                con.BCI_Volume_Prev_Year__c = Integer.valueof(OncologistMapPrevYr.get(contactId).size());
            }else if(OncologistMapPrevYr.get(contactId) == null && PathologistMapPrevYr.get(contactId) != null){
                con.BCI_Volume_Prev_Year__c = Integer.valueof(PathologistMapPrevYr.get(contactId).size());
            }else{
                con.BCI_Volume_Prev_Year__c = 0;
            }
            
            if(OncologistMapCTID.get(contactId) != null && PathologistMapCTID.get(contactId) != null){
                con.CTID_Volume_All_Time__c = Integer.valueof(OncologistMapCTID.get(contactId).size() + PathologistMapCTID.get(contactId).size());
            }else if(OncologistMapCTID.get(contactId) != null && PathologistMapCTID.get(contactId) == null){
                con.CTID_Volume_All_Time__c = Integer.valueof(OncologistMapCTID.get(contactId).size());
            }else if(OncologistMapCTID.get(contactId) == null && PathologistMapCTID.get(contactId) != null){
                con.CTID_Volume_All_Time__c = Integer.valueof(PathologistMapCTID.get(contactId).size());
            }else{
                con.CTID_Volume_All_Time__c = 0;
            }
            
            if(OncologistMapCurrYrCTID.get(contactId) != null && PathologistMapCurrYrCTID.get(contactId) != null){
                con.CTID_Volume_Current_Year__c = Integer.valueof(OncologistMapCurrYrCTID.get(contactId).size() + PathologistMapCurrYrCTID.get(contactId).size());
            }else if(OncologistMapCurrYrCTID.get(contactId) != null && PathologistMapCurrYrCTID.get(contactId) == null){
                con.CTID_Volume_Current_Year__c = Integer.valueof(OncologistMapCurrYrCTID.get(contactId).size());
            }else if(OncologistMapCurrYrCTID.get(contactId) == null && PathologistMapCurrYrCTID.get(contactId) != null){
                con.CTID_Volume_Current_Year__c = Integer.valueof(PathologistMapCurrYrCTID.get(contactId).size());
            }else{
                con.CTID_Volume_Current_Year__c = 0;
            }
            
            if(OncologistMapPrevYrCTID.get(contactId) != null && PathologistMapPrevYrCTID.get(contactId) != null){
                con.CTID_Volume_Prev_Year__c = Integer.valueof(OncologistMapPrevYrCTID.get(contactId).size() + PathologistMapPrevYrCTID.get(contactId).size());
            }else if(OncologistMapPrevYrCTID.get(contactId) != null && PathologistMapPrevYrCTID.get(contactId) == null){
                con.CTID_Volume_Prev_Year__c = Integer.valueof(OncologistMapPrevYrCTID.get(contactId).size());
            }else if(OncologistMapPrevYrCTID.get(contactId) == null && PathologistMapPrevYrCTID.get(contactId) != null){
                con.CTID_Volume_Prev_Year__c = Integer.valueof(PathologistMapPrevYrCTID.get(contactId).size());
            }else{
                con.CTID_Volume_Prev_Year__c = 0;
            }
            
            ConListToUpdate.Add(con);
        }
        
        if(ConListToUpdate.size()>0){
            update ConListToUpdate;
        }
    }
    
    public static void UpdatePhysicianCountOnAfterUpdate(List<Test__c> TestRecords,Map<Id,Test__c> OldTestRecords){
        Set<string> Oncologists = new Set<string>();
        Set<string> Pathologists = new Set<string>();
        Set<string> AllContacts = new Set<string>();
        Map<string,List<string>> OncologistMap = new Map<string,List<string>>();
        Map<string,List<string>> OncologistMapCTID = new Map<string,List<string>>();
        Map<string,List<string>> OncologistMapCurrYr = new Map<string,List<string>>();
        Map<string,List<string>> OncologistMapPrevYr = new Map<string,List<string>>();
        Map<string,List<string>> OncologistMapCurrYrCTID = new Map<string,List<string>>();
        Map<string,List<string>> OncologistMapPrevYrCTID = new Map<string,List<string>>();
        Map<string,List<string>> PathologistMap = new Map<string,List<string>>();
        Map<string,List<string>> PathologistMapCTID = new Map<string,List<string>>();
        Map<string,List<string>> PathologistMapCurrYr = new Map<string,List<string>>();
        Map<string,List<string>> PathologistMapPrevYr = new Map<string,List<string>>();
        Map<string,List<string>> PathologistMapCurrYrCTID = new Map<string,List<string>>();
        Map<string,List<string>> PathologistMapPrevYrCTID = new Map<string,List<string>>();
        
        for(Test__c test:TestRecords){
            if((test.Oncologist__c != OldTestRecords.get(test.Id).Oncologist__c) || (test.Pathologist__c != OldTestRecords.get(test.Id).Pathologist__c) || (test.Test_Type__c != OldTestRecords.get(test.Id).Test_Type__c) || (test.Ordering_Oncologist__c != OldTestRecords.get(test.Id).Ordering_Oncologist__c) || (test.Ordering_Pathologist__c != OldTestRecords.get(test.Id).Ordering_Pathologist__c) || (test.Oncologist_NPI__c != OldTestRecords.get(test.Id).Oncologist_NPI__c) || (test.Pathologist_NPI__c != OldTestRecords.get(test.Id).Pathologist_NPI__c) || (test.Date_Received__c != OldTestRecords.get(test.Id).Date_Received__c)){
                if(test.Oncologist__c != null){
                    Oncologists.Add(test.Oncologist__c);
                    Pathologists.Add(test.Oncologist__c);
                }
                if(test.Oncologist__c != OldTestRecords.get(test.Id).Oncologist__c){
                    if(test.Oncologist__c != null){
                        Pathologists.Add(test.Oncologist__c);
                    }
                    if(OldTestRecords.get(test.Id).Oncologist__c != null){
                        Oncologists.Add(OldTestRecords.get(test.Id).Oncologist__c);
                        Pathologists.Add(OldTestRecords.get(test.Id).Oncologist__c);
                        AllContacts.Add(OldTestRecords.get(test.Id).Oncologist__c);
                    }
                }
                if(test.Oncologist__c != null){
                    AllContacts.Add(test.Oncologist__c);
                }
                
                if(test.Pathologist__c != null){
                    Pathologists.Add(test.Pathologist__c);
                    Oncologists.Add(test.Pathologist__c);
                }
                if(test.Pathologist__c != OldTestRecords.get(test.Id).Pathologist__c){
                    if(test.Pathologist__c != null){
                        Oncologists.Add(test.Pathologist__c);
                    }
                    if(OldTestRecords.get(test.Id).Pathologist__c != null){
                        Oncologists.Add(OldTestRecords.get(test.Id).Pathologist__c);
                        Pathologists.Add(OldTestRecords.get(test.Id).Pathologist__c);
                        AllContacts.Add(OldTestRecords.get(test.Id).Pathologist__c);
                    }
                }
                if(test.Pathologist__c != null){
                    AllContacts.Add(test.Pathologist__c);   
                }                
            }
            /*if((test.Pathologist__c != OldTestRecords.get(test.Id).Pathologist__c) || (test.Oncologist__c != OldTestRecords.get(test.Id).Oncologist__c) || (test.Test_Type__c != OldTestRecords.get(test.Id).Test_Type__c) || (test.Ordering_Oncologist__c != OldTestRecords.get(test.Id).Ordering_Oncologist__c) || (test.Ordering_Pathologist__c != OldTestRecords.get(test.Id).Ordering_Pathologist__c) || (test.Oncologist_NPI__c != OldTestRecords.get(test.Id).Oncologist_NPI__c) || (test.Pathologist_NPI__c != OldTestRecords.get(test.Id).Pathologist_NPI__c)){
if(test.Pathologist__c != null){
Pathologists.Add(test.Pathologist__c);
Oncologists.Add(test.Pathologist__c);
}
if(test.Pathologist__c != OldTestRecords.get(test.Id).Pathologist__c){
if(test.Pathologist__c != null){
Oncologists.Add(test.Pathologist__c);
}
if(OldTestRecords.get(test.Id).Pathologist__c != null){
Oncologists.Add(OldTestRecords.get(test.Id).Pathologist__c);
Pathologists.Add(OldTestRecords.get(test.Id).Pathologist__c);
AllContacts.Add(OldTestRecords.get(test.Id).Pathologist__c);
}
}
if(test.Pathologist__c != null){
AllContacts.Add(test.Pathologist__c);   
}
}*/
        }
        
        if(AllContacts.size()>0){
            List<Test__c> TestOncologists = [select Id,Oncologist__c,Date_Received__c,Product_Line__c  from Test__c where (Product_Line__c = 'BCI' Or Product_Line__c = 'CTID') And Oncologist__c IN:Oncologists And Ordering_Physician__c = 'Oncologist' ];
            for(Test__c testRec:TestOncologists){
                if(testRec.Product_Line__c == 'BCI'){  
                    if(testRec.Date_Received__c != null){
                        if(testRec.Date_Received__c.Year() == System.today().Year()){
                            if (OncologistMapCurrYr.containsKey(testRec.Oncologist__c)) {
                                OncologistMapCurrYr.get(testRec.Oncologist__c).add(testRec.Id);
                            }
                            else {
                                OncologistMapCurrYr.put(testRec.Oncologist__c, new List<string>{ testRec.Id });
                            }
                        }else if(Integer.valueof(testRec.Date_Received__c.Year()) == Integer.valueof(System.today().Year() - 1)){
                            if (OncologistMapPrevYr.containsKey(testRec.Oncologist__c)) {
                                OncologistMapPrevYr.get(testRec.Oncologist__c).add(testRec.Id);
                            }
                            else {
                                OncologistMapPrevYr.put(testRec.Oncologist__c, new List<string>{ testRec.Id });
                            }
                        }
                    }
                    
                    if (OncologistMap.containsKey(testRec.Oncologist__c)) {
                        OncologistMap.get(testRec.Oncologist__c).add(testRec.Id);
                    }
                    else {
                        OncologistMap.put(testRec.Oncologist__c, new List<string>{ testRec.Id });
                    }
                }else if(testRec.Product_Line__c == 'CTID'){
                    if(testRec.Date_Received__c != null){
                        if(testRec.Date_Received__c.Year() == System.today().Year()){
                            if (OncologistMapCurrYrCTID.containsKey(testRec.Oncologist__c)) {
                                OncologistMapCurrYrCTID.get(testRec.Oncologist__c).add(testRec.Id);
                            }
                            else {
                                OncologistMapCurrYrCTID.put(testRec.Oncologist__c, new List<string>{ testRec.Id });
                            }
                        }else if(Integer.valueof(testRec.Date_Received__c.Year()) == Integer.valueof(System.today().Year() - 1)){
                            if (OncologistMapPrevYrCTID.containsKey(testRec.Oncologist__c)) {
                                OncologistMapPrevYrCTID.get(testRec.Oncologist__c).add(testRec.Id);
                            }
                            else {
                                OncologistMapPrevYrCTID.put(testRec.Oncologist__c, new List<string>{ testRec.Id });
                            }
                        }
                    }
                    
                    if (OncologistMapCTID.containsKey(testRec.Oncologist__c)) {
                        OncologistMapCTID.get(testRec.Oncologist__c).add(testRec.Id);
                    }
                    else {
                        OncologistMapCTID.put(testRec.Oncologist__c, new List<string>{ testRec.Id });
                    }
                }
            }
            List<Test__c> TestPathologists = [select Id,Pathologist__c,Date_Received__c,Product_Line__c  from Test__c where (Product_Line__c = 'BCI' Or Product_Line__c = 'CTID') And Pathologist__c IN:Pathologists And Ordering_Physician__c = 'Pathologist'];
            for(Test__c testRec:TestPathologists){
                if(testRec.Product_Line__c == 'BCI'){
                    if(testRec.Date_Received__c != null){
                        if(testRec.Date_Received__c.Year() == System.today().Year()){
                            if (PathologistMapCurrYr.containsKey(testRec.Pathologist__c)) {
                                //if(OncologistMapCurrYr.get(testRec.Pathologist__c) != null){
                                //    if(!OncologistMapCurrYr.get(testRec.Pathologist__c).contains(testRec.Id)){
                                PathologistMapCurrYr.get(testRec.Pathologist__c).add(testRec.Id);
                                //    }
                                //}else{
                                //    PathologistMapCurrYr.get(testRec.Pathologist__c).add(testRec.Id);
                                //}
                            }
                            else {
                                //PathologistMapCurrYr.put(testRec.Pathologist__c, new List<Test__c>{ testRec });
                                //if(OncologistMapCurrYr.get(testRec.Pathologist__c) != null){
                                //if(!OncologistMapCurrYr.get(testRec.Pathologist__c).contains(testRec.Id)){
                                PathologistMapCurrYr.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                                //}
                                //}else{
                                //    PathologistMapCurrYr.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                                //}
                            }
                        }else if(Integer.valueof(testRec.Date_Received__c.Year()) == Integer.valueof(System.today().Year() - 1)){
                            if (PathologistMapPrevYr.containsKey(testRec.Pathologist__c)) {
                                //if(OncologistMapPrevYr.get(testRec.Pathologist__c) != null){
                                //    if(!OncologistMapPrevYr.get(testRec.Pathologist__c).contains(testRec.Id)){
                                PathologistMapPrevYr.get(testRec.Pathologist__c).add(testRec.Id);
                                //   }
                                //}else{
                                //    PathologistMapPrevYr.get(testRec.Pathologist__c).add(testRec.Id);
                                //}
                            }
                            else {
                                //if(OncologistMapPrevYr.get(testRec.Pathologist__c) != null){
                                //    if(!OncologistMapPrevYr.get(testRec.Pathologist__c).contains(testRec.Id)){
                                PathologistMapPrevYr.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                                //    }
                                //}else{
                                //    PathologistMapPrevYr.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                                //}
                            }
                        }
                    }
                    
                    if (PathologistMap.containsKey(testRec.Pathologist__c)) {
                        //if(OncologistMap.get(testRec.Pathologist__c) != null){
                        //    if(!OncologistMap.get(testRec.Pathologist__c).contains(testRec.Id)){
                        PathologistMap.get(testRec.Pathologist__c).add(testRec.Id);
                        //    }
                        //}else{
                        //    PathologistMap.get(testRec.Pathologist__c).add(testRec.Id);
                        //}
                    }
                    else {
                        //if(OncologistMap.get(testRec.Pathologist__c) != null){
                        //    if(!OncologistMap.get(testRec.Pathologist__c).contains(testRec.Id)){
                        PathologistMap.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                        //    }
                        //}else{
                        //    PathologistMap.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                        //}
                    }
                }else if(testRec.Product_Line__c == 'CTID'){
                    if(testRec.Date_Received__c != null){
                        if(testRec.Date_Received__c.Year() == System.today().Year()){
                            if (PathologistMapCurrYrCTID.containsKey(testRec.Pathologist__c)) {
                                //if(OncologistMapCurrYrCTID.get(testRec.Pathologist__c) != null){
                                //    if(!OncologistMapCurrYrCTID.get(testRec.Pathologist__c).contains(testRec.Id)){
                                PathologistMapCurrYrCTID.get(testRec.Pathologist__c).add(testRec.Id);
                                //    }
                                //}else{
                                //    PathologistMapCurrYrCTID.get(testRec.Pathologist__c).add(testRec.Id);
                                //}
                            }
                            else {
                                //if(OncologistMapCurrYrCTID.get(testRec.Pathologist__c) != null){
                                //    if(!OncologistMapCurrYrCTID.get(testRec.Pathologist__c).contains(testRec.Id)){
                                PathologistMapCurrYrCTID.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                                //    }
                                //}else{
                                //    PathologistMapCurrYrCTID.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                                //}
                            }
                        }else if(Integer.valueof(testRec.Date_Received__c.Year()) == Integer.valueof(System.today().Year() - 1)){
                            if (PathologistMapPrevYrCTID.containsKey(testRec.Pathologist__c)) {
                                //if(OncologistMapPrevYrCTID.get(testRec.Pathologist__c) != null){
                                //    if(!OncologistMapPrevYrCTID.get(testRec.Pathologist__c).contains(testRec.Id)){
                                PathologistMapPrevYrCTID.get(testRec.Pathologist__c).add(testRec.Id);
                                //    }
                                //}else{
                                //    PathologistMapPrevYrCTID.get(testRec.Pathologist__c).add(testRec.Id);
                                //}
                            }
                            else {
                                //if(OncologistMapPrevYrCTID.get(testRec.Pathologist__c) != null){
                                //    if(!OncologistMapPrevYrCTID.get(testRec.Pathologist__c).contains(testRec.Id)){
                                PathologistMapPrevYrCTID.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                                //    }
                                //}else{
                                //    PathologistMapPrevYrCTID.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                                //}
                            }
                        }
                    }
                    
                    if (PathologistMapCTID.containsKey(testRec.Pathologist__c)) {
                        //if(OncologistMapCTID.get(testRec.Pathologist__c) != null){
                        //    if(!OncologistMapCTID.get(testRec.Pathologist__c).contains(testRec.Id)){
                        PathologistMapCTID.get(testRec.Pathologist__c).add(testRec.Id);
                        //    }
                        //}else{
                        //    PathologistMapCTID.get(testRec.Pathologist__c).add(testRec.Id);
                        //}
                    }
                    else {
                        //if(OncologistMapCTID.get(testRec.Pathologist__c) != null){
                        //    if(!OncologistMapCTID.get(testRec.Pathologist__c).contains(testRec.Id)){
                        PathologistMapCTID.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                        //    }
                        //}else{
                        //    PathologistMapCTID.put(testRec.Pathologist__c, new List<string>{ testRec.Id });
                        //}
                    }
                }
            }
            List<Contact> ConListToUpdate = new List<Contact>();
            for(string contactId:AllContacts){
                Contact con = new Contact();
                con.Id = contactId;
                if(OncologistMap.get(contactId) != null && PathologistMap.get(contactId) != null){
                    con.BCI_Volume_All_Time__c = Integer.valueof(OncologistMap.get(contactId).size() + PathologistMap.get(contactId).size());
                }else if(OncologistMap.get(contactId) != null && PathologistMap.get(contactId) == null){
                    con.BCI_Volume_All_Time__c = Integer.valueof(OncologistMap.get(contactId).size());
                }
                else if(OncologistMap.get(contactId) == null && PathologistMap.get(contactId) != null){
                    con.BCI_Volume_All_Time__c = Integer.valueof(PathologistMap.get(contactId).size());
                }else{
                    con.BCI_Volume_All_Time__c = 0;
                }
                
                if(OncologistMapCurrYr.get(contactId) != null && PathologistMapCurrYr.get(contactId) != null){
                    con.BCI_Volume_Current_Year__c = Integer.valueof(OncologistMapCurrYr.get(contactId).size() + PathologistMapCurrYr.get(contactId).size());
                }else if(OncologistMapCurrYr.get(contactId) != null && PathologistMapCurrYr.get(contactId) == null){
                    con.BCI_Volume_Current_Year__c = Integer.valueof(OncologistMapCurrYr.get(contactId).size());
                }else if(OncologistMapCurrYr.get(contactId) == null && PathologistMapCurrYr.get(contactId) != null){
                    con.BCI_Volume_Current_Year__c = Integer.valueof(PathologistMapCurrYr.get(contactId).size());
                }else{
                    con.BCI_Volume_Current_Year__c = 0;
                }
                
                if(OncologistMapPrevYr.get(contactId) != null && PathologistMapPrevYr.get(contactId) != null){
                    con.BCI_Volume_Prev_Year__c = Integer.valueof(OncologistMapPrevYr.get(contactId).size() + PathologistMapPrevYr.get(contactId).size());
                }else if(OncologistMapPrevYr.get(contactId) != null && PathologistMapPrevYr.get(contactId) == null){
                    con.BCI_Volume_Prev_Year__c = Integer.valueof(OncologistMapPrevYr.get(contactId).size());
                }else if(OncologistMapPrevYr.get(contactId) == null && PathologistMapPrevYr.get(contactId) != null){
                    con.BCI_Volume_Prev_Year__c = Integer.valueof(PathologistMapPrevYr.get(contactId).size());
                }else{
                    con.BCI_Volume_Prev_Year__c = 0;
                }
                
                if(OncologistMapCTID.get(contactId) != null && PathologistMapCTID.get(contactId) != null){
                    con.CTID_Volume_All_Time__c = Integer.valueof(OncologistMapCTID.get(contactId).size() + PathologistMapCTID.get(contactId).size());
                }else if(OncologistMapCTID.get(contactId) != null && PathologistMapCTID.get(contactId) == null){
                    con.CTID_Volume_All_Time__c = Integer.valueof(OncologistMapCTID.get(contactId).size());
                }else if(OncologistMapCTID.get(contactId) == null && PathologistMapCTID.get(contactId) != null){
                    con.CTID_Volume_All_Time__c = Integer.valueof(PathologistMapCTID.get(contactId).size());
                }else{
                    con.CTID_Volume_All_Time__c = 0;
                }
                
                if(OncologistMapCurrYrCTID.get(contactId) != null && PathologistMapCurrYrCTID.get(contactId) != null){
                    con.CTID_Volume_Current_Year__c = Integer.valueof(OncologistMapCurrYrCTID.get(contactId).size() + PathologistMapCurrYrCTID.get(contactId).size());
                }else if(OncologistMapCurrYrCTID.get(contactId) != null && PathologistMapCurrYrCTID.get(contactId) == null){
                    con.CTID_Volume_Current_Year__c = Integer.valueof(OncologistMapCurrYrCTID.get(contactId).size());
                }else if(OncologistMapCurrYrCTID.get(contactId) == null && PathologistMapCurrYrCTID.get(contactId) != null){
                    con.CTID_Volume_Current_Year__c = Integer.valueof(PathologistMapCurrYrCTID.get(contactId).size());
                }else{
                    con.CTID_Volume_Current_Year__c = 0;
                }
                
                if(OncologistMapPrevYrCTID.get(contactId) != null && PathologistMapPrevYrCTID.get(contactId) != null){
                    con.CTID_Volume_Prev_Year__c = Integer.valueof(OncologistMapPrevYrCTID.get(contactId).size() + PathologistMapPrevYrCTID.get(contactId).size());
                }else if(OncologistMapPrevYrCTID.get(contactId) != null && PathologistMapPrevYrCTID.get(contactId) == null){
                    con.CTID_Volume_Prev_Year__c = Integer.valueof(OncologistMapPrevYrCTID.get(contactId).size());
                }else if(OncologistMapPrevYrCTID.get(contactId) == null && PathologistMapPrevYrCTID.get(contactId) != null){
                    con.CTID_Volume_Prev_Year__c = Integer.valueof(PathologistMapPrevYrCTID.get(contactId).size());
                }else{
                    con.CTID_Volume_Prev_Year__c = 0;
                }
                
                ConListToUpdate.Add(con);
            }
            
            if(ConListToUpdate.size()>0){
                update ConListToUpdate;
            }
        }
    }
    public static void updateOrderOnInsert(List<Test__c> TestRecords){
        List<String> patientNameList = new List<String>();
        List<Date> patientDOBList = new List<Date>();
        List<String> oncologistList = new List<String>();
        Map<String, List<SRP__c>> orderFieldsMap = new Map<String, List<SRP__c>>();
        for(Test__c TC: TestRecords){
            if(TC.Patient_Name__c != null && TC.Patient_DOB__c != null && TC.Oncologist__c != null  ){
                patientNameList.add(TC.Patient_Name__c); 
                patientDOBList.add(TC.Patient_DOB__c);
                oncologistList.add(TC.Oncologist__c);
            }    
        }
        system.debug('From updateOrderOnInsert: Patient data from test -------> '+patientNameList + ' ' + patientDOBList + ' ' + oncologistList);
        List<SRP__c>  OrderData = [SELECT Id,
                                   Patient_Name__c,
                                   Patient_DOB__c,
                                   Oncologist__c 
                                   FROM SRP__c 
                                   WHERE Patient_Name__c IN: patientNameList
                                   AND Patient_DOB__c IN: patientDOBList
                                   AND Oncologist__c IN: oncologistList
                                  ];
        system.debug('OrderData -------> '+OrderData);
        List<SRP__c> ordersList = new List<SRP__c>();
        List<Test__c> testRecordsToUpdate = new List<Test__c>();
        if(!OrderData.IsEmpty()){
            for(SRP__c order : OrderData){
               // if(orderFieldsMap.get(order.Patient_Name__c+string.valueOf(order.Patient_DOB__c)+order.Oncologist__c) != null){
                if(orderFieldsMap.get(order.Patient_Name__c.toLowercase()+string.valueOf(order.Patient_DOB__c)+order.Oncologist__c) != null){ // added to lowercase - jp 04/28/2021
                    ordersList.add(order);
                    orderFieldsMap.put(order.Patient_Name__c.toLowercase()+string.valueOf(order.Patient_DOB__c)+order.Oncologist__c, ordersList);
                }else{
                    ordersList = new List<SRP__c>();
                    ordersList.add(order);
                    orderFieldsMap.put(order.Patient_Name__c.toLowercase()+string.valueOf(order.Patient_DOB__c)+order.Oncologist__c, ordersList);
                }   
            }
            system.debug('orderFieldsMap toString() ------> '+orderFieldsMap.toString());
            for(Test__c TC: TestRecords){
                Test__c testRec = new Test__c();
                testRec.Id = TC.Id;
                String TestData = TC.Patient_Name__c.toLowercase()+string.valueOf(Date.valueOf(TC.Patient_DOB__c))+TC.Oncologist__c;
                system.debug('TESTDATA from Test ==========>> '+ TestData);
                if(orderFieldsMap.get(TestData) != null) 
                {
                    if(orderFieldsMap.get(TestData).size() == 1) 
                    {
                        system.debug('Orders Field Map == 1 ------>');
                        testRec.Orders__c = orderFieldsMap.get(TC.Patient_Name__c.toLowercase()+string.valueOf(TC.Patient_DOB__c)+TC.Oncologist__c)[0].Id;
                    }
                    else 
                    { 
                        system.debug('Orders Field Map not equal to one  ------>');
                        testRec.Multiple_Orders__c = true;
                        system.debug('MULTIPLE ORDERS IS EQUAL TO TRUE >>>>>> ' + TC.Patient_Name__c);
                    }
               }
                testRecordsToUpdate.add(testRec);
           }
        }
        system.debug('TestRecords ------> '+testRecordsToUpdate);
        if(testRecordsToUpdate.size() >= 0){
            update testRecordsToUpdate; 
            system.debug('after update --------> '+testRecordsToUpdate);
        }
    }
    
}//TestInsertUpdateHandler ends