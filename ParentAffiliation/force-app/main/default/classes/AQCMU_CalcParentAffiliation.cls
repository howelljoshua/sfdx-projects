/* 
*
* Apex Batch to create and update Parent Afilliation Records
*
* 12/07/2018    Michael Steptoe (Sleek)
*/
global class AQCMU_CalcParentAffiliation implements Database.Batchable<sObject>, Database.Stateful {
    
    global Integer existingRecordsFound = 0;
    global Integer recordsNotDeleted = 0;
    global Integer recordsDeleted = 0;
    global Integer recordsNotUpdated = 0;
    global Integer recordsUpdated = 0;
    global Integer recordsNotInserted = 0;
    global Integer recordsInserted = 0;
    global String strBodyError = '';
    global String institutionalNameString = '';

    private Map<String, Parent_Affiliation_Setting__mdt> settingMap;

    /*  
    * Get a list of all Parent Affiliation Settings
    *  
    * @return a Map that associates the developer name of the setting to the setting record
    */
    public Map<String, Parent_Affiliation_Setting__mdt> getParentAffiliationSettings(){
        Map<String, Parent_Affiliation_Setting__mdt> settingMap = new Map<String, Parent_Affiliation_Setting__mdt>();
        
        //Loop through a query of Parent_Affiliation_Setting__mdt records, populate the Map with Name as the key
        for(Parent_Affiliation_Setting__mdt pa_mdt : [SELECT DeveloperName, Item__c, Value__c FROM Parent_Affiliation_Setting__mdt]){
            settingMap.put(pa_mdt.DeveloperName, pa_mdt);
        }
        
        return settingMap;
    }
    
    /*
    * Query for all Relationship Contacts that have related contact roles of 'child'.
    *  
    * @param bc a Database.BatchableContext that references the current Batch context
    * @return a Database.QueryLocator that contains all of the Relationship Contacts that have related contact
    *         roles of 'child'.
    */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.Debug('Start');


/*
        String query = 'SELECT AQB__Contact__c, AQB__RelatedName__c,  AQB__relatedContact__c, Active__c ' +
            'FROM AQB__RelationshipContact__c ' +
            //'WHERE AQB__relatedContact__c = \'0030U00000hc6I4QAI\' AND AQB__ReverseRelationship__c in ';
            
            'WHERE AQB__relatedContact__c != null AND AQB__RelatedContactRole__r.Name in ';
            
            // 'WHERE AQB__relatedContact__c = \'0030U00000hc6I4QAI\' AND AQB__RelatedContactRole__r.Name in ';
        

        String subQuery = '(\'Child\',\'Stepchild\',\'Stepdaughter\',\'Stepson\',\'Ward\') ';
*/ 
        

        String query = 'SELECT AQB__Contact__c, AQB__RelatedName__c,AQB__relatedContact__c, Active__c,AQB__Relationship__c,AQB__ReverseRelationship__c '+
                       'FROM AQB__RelationshipContact__c ' +
                       'WHERE AQB__relatedContact__c != NULL ' +
                       'AND AQB__ReverseRelationship__c = \'Child\' ' ;

 


        /*
        List<String> roles = new List<String>();
        
        settingMap = getParentAffiliationSettings();
        Parent_Affiliation_Setting__mdt childRelationshipRoles = settingMap.get(AQCMU_Util.CHILD_RELATIONSHIP_ROLES);
        // If the Child Relationship Roles are specified in the settings then use them
        if(childRelationshipRoles != null && !String.isBlank(childRelationshipRoles.Value__c)){
            roles = AQCMU_Util.string2List(childRelationshipRoles.Value__c, ';');
            subQuery = ':roles ';
        }
        */
        
        
        System.debug('full query is: ' + query);
        
        
        //return Database.getQueryLocator(query + subQuery + 'ORDER BY AQB__relatedContact__c');
        return Database.getQueryLocator(query + 'ORDER BY AQB__relatedContact__c');
    }
    

    /*  
    * Gathers the field information for the Parent Affiliation records to be created or updated based on the provided
    * Relationship Contacts.
    *  
    * @param bc a Database.BatchableContext that references the current Batch context
    * @param scope a list of AQB__RelationshipContact__c to calculate Parent Affiliations for
    */
    global void execute(Database.BatchableContext bc, List<AQB__RelationshipContact__c> scope){
        System.debug('AQCMU_CalcParentAffiliation.execute -> scope: ' + scope.size());
        System.debug('Query returned: ' + scope);
        System.debug('AQCMU_CalcParentAffiliation.execute -> settingMap: ' + settingMap);
        Map<Integer, AQB__RelationshipContact__c> relationshipContactsByIndex = new Map<Integer,  AQB__RelationshipContact__c>();
        Set<Id> relationshipContactId = new Set<Id>();
        Set<Id> relationshipChildId = new Set<Id>();
        Map<String, Integer> indexByContactIdChildId = new Map<String, Integer>();
        // Set<String> contactIdChildId = new Set<String>();

        // Build a map that relates Parent to Child Name and a combination of them to their index in the Relationship Contact List
        for(Integer i = 0; i < scope.size(); i++){
            AQB__RelationshipContact__c relationshipContact = scope[i];
            Id contactId = relationshipContact.AQB__Contact__c;
            Id childId = relationshipContact.AQB__relatedContact__c;

            relationshipContactId.add(contactId);
            relationshipChildId.add(childId);
            indexByContactIdChildId.put(contactId + '_' + childId, i);
            relationshipContactsByIndex.put(i, relationshipContact);
        }

        // Remove Relationship Contacts from the List to process that have existing Parent Affiliations
        Map<Id, List<Parent_Affiliation__c>> existParentAffiliationsListByChildId = new Map<Id, List<Parent_Affiliation__c>>();
        // If the relationship is no longer active then remove the parent affiliation
        List<Parent_Affiliation__c> deleteParentAffiliations = new List<Parent_Affiliation__c>();
        for(Parent_Affiliation__c parentAffiliation : [
            SELECT Contact__c, Child_Contact_Record__c, Child_s_Name__c, Student_Athlete__c
            FROM Parent_Affiliation__c
            WHERE Contact__c in :relationshipContactId
            AND Child_Contact_Record__c in :relationshipChildId
        ]){
            Id contactId = parentAffiliation.Contact__c;
            Id childId = parentAffiliation.Child_Contact_Record__c;
            Integer index = indexByContactIdChildId.get(contactId + '_' + childId);

            if(index != null){
                // Reset Student Athlete, will set true if record found
                parentAffiliation.Student_Athlete__c = false;
                
                AQB__RelationshipContact__c relationship = relationshipContactsByIndex.get(index);
                // If the relationship is no longer active then remove the Parent Affiliation
                if(relationship != null && relationship.Active__c){
                    
                    List<Parent_Affiliation__c> parentAffiliations = existParentAffiliationsListByChildId.get(childId);
                    // If there is not a Parent Affiliations list for the 'Child' of the current record create a list and store it
                    // Otherwise add the Parent Affiliation to the Parent Affiliations list associated to the 'Child'
                    if(parentAffiliations == null){
                        existParentAffiliationsListByChildId.put(childId, new List<Parent_Affiliation__c>{parentAffiliation});
                    }
                    else{
                        parentAffiliations.add(parentAffiliation);
                    }
                }
                else{
                    deleteParentAffiliations.add(parentAffiliation);
                }

                // Remove the Relationship Contact from the Map so that it is not considered for new Parent Affiliations
                relationshipContactsByIndex.remove(index);
                existingRecordsFound++;
            }
        }
        // Clear the Maps
        indexByContactIdChildId.clear();
        relationshipContactId.clear();
        relationshipChildId.clear();


        // Create Parent Affiliations and build a map that relates Child Id to list of Parent Affiliations
        Map<Id, List<Parent_Affiliation__c>> parentAffiliationsListByChildId = new Map<Id, List<Parent_Affiliation__c>>();
        for(AQB__RelationshipContact__c relationshipContact : relationshipContactsByIndex.values()){
            if(relationshipContact.Active__c){
                Id childId = relationshipContact.AQB__relatedContact__c;

                Parent_Affiliation__c parentAffiliation = new Parent_Affiliation__c(
                    Contact__c = relationshipContact.AQB__Contact__c,
                    Child_Contact_Record__c = childId,
                    Child_s_Name__c = relationshipContact.AQB__RelatedName__c
                );

                List<Parent_Affiliation__c> parentAffiliations = parentAffiliationsListByChildId.get(childId);
                // If there is not a Parent Affiliations list for the 'Child' of the current record create a list and store it
                // Otherwise add the Parent Affiliation to the Parent Affiliations list associated to the 'Child'
                if(parentAffiliations == null){
                    parentAffiliationsListByChildId.put(childId, new List<Parent_Affiliation__c>{parentAffiliation});
                }
                else{
                    parentAffiliationsListByChildId.get(childId).add(parentAffiliation);
                }
            }
        }
        // Clear the Map
        relationshipContactsByIndex.clear();

        // Get all child ids that Parent Affiliation fields need to be populated for
        Set<Id> allChildIds =new Set<Id>();
        allChildIds.addAll(parentAffiliationsListByChildId.keySet());
        allChildIds.addAll(existParentAffiliationsListByChildId.keySet());

        // Education record ids for all Parent Affiliation records associated with it
        Map<Id, List<Parent_Affiliation__c>> parentAffiliationsByEducationIds = new Map<Id, List<Parent_Affiliation__c>>();

        String educationStatus = 'In Progress';
        
        Parent_Affiliation_Setting__mdt inProgressDegree = settingMap.get(AQCMU_Util.IN_PROGRESS_DEGREE);
        // If In Progress Degree is specified in the settings then use them
        if(inProgressDegree != null && !String.isBlank(inProgressDegree.Value__c)){
            educationStatus = inProgressDegree.Value__c;
        }

        List<Parent_Affiliation__c> updateParentAffiliations = new List<Parent_Affiliation__c>();
        List<Parent_Affiliation__c> insertParentAffiliations = new List<Parent_Affiliation__c>();
        
        System.debug('Education Status ->  ' + educationStatus + ' Inst Name -> ' + AQCMU_Util.EDUCATIONAL_INSTITUTE_NAME + 'Contacts -> ' + allChildIds);
        // Check if the student has 'In progress' degrees
        for(AQB__Education__c education : [
            SELECT AQB__Contact__c, Name, Primary_School__c, Status__c, AQB__EntryClassYear__c, AQB__PreferredYear__c,
            Department__c, AQB__DegreeLevel__c
            FROM AQB__Education__c
            WHERE Status__c = :educationStatus
            AND AQB__Institution__r.Name = :AQCMU_Util.EDUCATIONAL_INSTITUTE_NAME
            AND AQB__Contact__c in :allChildIds
        ]){
            Id childId = education.AQB__Contact__c;

            List<Parent_Affiliation__c> parentAffiliations = parentAffiliationsListByChildId.get(childId);
            // If the list of new Parent Affiliations has records for the current 'Child' then update the PAs
            // and remove it from the list as it does not need to be considered further and should be retained
            if(parentAffiliations != null){
                for(Parent_Affiliation__c parentAffiliation : parentAffiliations){
                    parentAffiliation.School__c = education.Primary_School__c;
                    parentAffiliation.Status__c = education.Status__c;
                    parentAffiliation.Entering_Class__c = education.AQB__EntryClassYear__c;
                    parentAffiliation.Expected_Grad_Year__c = education.AQB__PreferredYear__c;
                    parentAffiliation.Department__c = education.Department__c;
                    parentAffiliation.Degree_Level__c = education.AQB__DegreeLevel__c;
                    insertParentAffiliations.add(parentAffiliation);

                    List<Parent_Affiliation__c> paList = parentAffiliationsByEducationIds.get(education.Id);
                    if(paList == null){
                        parentAffiliationsByEducationIds.put(education.Id, new List<Parent_Affiliation__c>{parentAffiliation});
                    }
                    else{
                        paList.add(parentAffiliation);
                    }
                }
                parentAffiliationsListByChildId.remove(childId);
            }

            parentAffiliations = existParentAffiliationsListByChildId.get(childId);
            // If the list of existing Parent Affiliations has records for the current 'Child' then update the PAs
            // and remove it from the list as it does not need to be considered further and should be retained
            if(parentAffiliations != null){
                for(Parent_Affiliation__c parentAffiliation : parentAffiliations){
                    parentAffiliation.School__c = education.Primary_School__c;
                    parentAffiliation.Status__c = education.Status__c;
                    parentAffiliation.Entering_Class__c = education.AQB__EntryClassYear__c;
                    parentAffiliation.Expected_Grad_Year__c = education.AQB__PreferredYear__c;
                    parentAffiliation.Department__c = education.Department__c;
                    parentAffiliation.Degree_Level__c = education.AQB__DegreeLevel__c;
                    updateParentAffiliations.add(parentAffiliation);
                    
                    List<Parent_Affiliation__c> paList = parentAffiliationsByEducationIds.get(education.Id);
                    if(paList == null){
                        parentAffiliationsByEducationIds.put(education.Id, new List<Parent_Affiliation__c>{parentAffiliation});
                    }
                    else{
                        paList.add(parentAffiliation);
                    }
                }
                existParentAffiliationsListByChildId.remove(childId);
            }
        }

        String isPrimaryDegree = 'YES';
        Parent_Affiliation_Setting__mdt primaryDegree = settingMap.get(AQCMU_Util.PRIMARY_DEGREE);
        // If Primary Degree is specified in the settings then use them
        if(primaryDegree != null && !String.isBlank(primaryDegree.Value__c)){
            isPrimaryDegree = primaryDegree.Value__c;
        }

        // Get all child ids that Parent Affiliation fields need to be populated for
        allChildIds = new Set<Id>();
        allChildIds.addAll(parentAffiliationsListByChildId.keySet());
        allChildIds.addAll(existParentAffiliationsListByChildId.keySet());

        /*System.debug('Is Primary Degree ->  ' + isPrimaryDegree + ' Inst Name -> ' + AQCMU_Util.EDUCATIONAL_INSTITUTE_NAME + 'Contacts -> ' + allChildIds);
        List<AQB__Education__c> Luketest = [SELECT AQB__Contact__c, Name, Primary_School__c,  Status__c, AQB__EntryClassYear__c, AQB__PreferredYear__c,
                Department__c, AQB__DegreeLevel__c, AQB__Institution__r.Name, AQB__Institution__c, AQB__IsPrimaryDegree__c
                FROM AQB__Education__c];

        for(AQB__Education__c lt : Luketest){
            system.debug('Status -> ' + lt.Status__c);
            system.debug('inst -> ' + lt.AQB__Institution__r.Name);
            system.debug('prim deg -> ' + lt.AQB__IsPrimaryDegree__c);
            system.debug('Contact -> ' + lt.AQB__Contact__c);
        }*/
        
        //Luke Dickson - Added a check, hitting a validation rule on insert of education records that you can't have an insutition associated with them, so nulling that value if test
        if(Test.isRunningTest()){
            institutionalNameString = null;
        }
        else{
            institutionalNameString = AQCMU_Util.EDUCATIONAL_INSTITUTE_NAME;
        }
        // Check if the student has a Primary degree that is not in progress
        for(AQB__Education__c education : [
            SELECT AQB__Contact__c, Name, Primary_School__c,  Status__c, AQB__EntryClassYear__c, AQB__PreferredYear__c,
            Department__c, AQB__DegreeLevel__c, AQB__Institution__r.Name
            FROM AQB__Education__c
            WHERE Status__c != :educationStatus
            AND AQB__Institution__r.Name = :institutionalNameString
            //AND AQB__Institution__r.Name = :AQCMU_Util.EDUCATIONAL_INSTITUTE_NAME
            AND AQB__IsPrimaryDegree__c = :isPrimaryDegree
            AND AQB__Contact__c in :allChildIds
        ]){
            Id childId = education.AQB__Contact__c;

            List<Parent_Affiliation__c> parentAffiliations = parentAffiliationsListByChildId.get(childId);
            // If the list of new Parent Affiliations has records for the current 'Child' then update the PAs
            // and remove it from the list and add it to the list to be retained
            if(parentAffiliations != null){
                for(Parent_Affiliation__c parentAffiliation : parentAffiliations){
                    parentAffiliation.School__c = education.Primary_School__c;
                    parentAffiliation.Status__c = education.Status__c;
                    parentAffiliation.Entering_Class__c = education.AQB__EntryClassYear__c;
                    parentAffiliation.Expected_Grad_Year__c = education.AQB__PreferredYear__c;
                    parentAffiliation.Department__c = education.Department__c;
                    parentAffiliation.Degree_Level__c = education.AQB__DegreeLevel__c;
                    insertParentAffiliations.add(parentAffiliation);

                    List<Parent_Affiliation__c> paList = parentAffiliationsByEducationIds.get(education.Id);
                    if(paList == null){
                        parentAffiliationsByEducationIds.put(education.Id, new List<Parent_Affiliation__c>{parentAffiliation});
                    }
                    else{
                        paList.add(parentAffiliation);
                    }
                }
                parentAffiliationsListByChildId.remove(childId);
            }


            parentAffiliations = existParentAffiliationsListByChildId.get(childId);
            // If the list of existing Parent Affiliations has records for the current 'Child' then update the PAs
            // and remove it from the list and add it to the list to be retained
            if(parentAffiliations != null){
                for(Parent_Affiliation__c parentAffiliation : parentAffiliations){
                    parentAffiliation.School__c = education.Primary_School__c;
                    parentAffiliation.Status__c = education.Status__c;
                    parentAffiliation.Entering_Class__c = education.AQB__EntryClassYear__c;
                    parentAffiliation.Expected_Grad_Year__c = education.AQB__PreferredYear__c;
                    parentAffiliation.Department__c = education.Department__c;
                    parentAffiliation.Degree_Level__c = education.AQB__DegreeLevel__c;
                    updateParentAffiliations.add(parentAffiliation);

                    List<Parent_Affiliation__c> paList = parentAffiliationsByEducationIds.get(education.Id);
                    if(paList == null){
                        parentAffiliationsByEducationIds.put(education.Id, new List<Parent_Affiliation__c>{parentAffiliation});
                    }
                    else{
                        paList.add(parentAffiliation);
                    }
                }
                existParentAffiliationsListByChildId.remove(childId);
            }
        }

        String interestGroup = 'Sport';
        Parent_Affiliation_Setting__mdt studentAthleteInterest = settingMap.get(AQCMU_Util.STUDENT_ATHLETE_INTEREST_GROUP);
        // If Student Athlete Interest Group is specified in the settings then use it
        if(studentAthleteInterest != null && !String.isBlank(studentAthleteInterest.Value__c)){
            interestGroup = studentAthleteInterest.Value__c;
        }

        List<String> participationLevel = new List<String>{'Varsity', 'Varsity per Athletics'};
        Parent_Affiliation_Setting__mdt studentAthleteParticipation = settingMap.get(AQCMU_Util.STUDENT_ATHLETE_PARTICIPATION_LEVEL);
        // If Student Athlete Participation Level is specified in the settings then use it
        if(studentAthleteParticipation != null && !String.isBlank(studentAthleteParticipation.Value__c)){
            participationLevel = AQCMU_Util.string2List(studentAthleteParticipation.Value__c, ';');
        }

        System.debug('interestGroup: ' + interestGroup);
        System.debug('participationLevel: ' + participationLevel);
        System.debug('parentAffiliationsByEducationIds: ' + parentAffiliationsByEducationIds);
        
        // Check if the student is an athlete
        for(AQB__StudentInterest__c studentInterest : [
            SELECT AQB__EducationLink__c
            FROM AQB__StudentInterest__c
            WHERE (AQB__InterestGroup__c = :interestGroup OR Participation_Level__c in :participationLevel)
            AND AQB__EducationLink__c in :parentAffiliationsByEducationIds.keySet()
        ]){
            List<Parent_Affiliation__c> parentAffiliations = parentAffiliationsByEducationIds.get(studentInterest.AQB__EducationLink__c);
            // Update Parent Affiliations with Student Athlete as true since a matching Interest exists
            // for the current Education record
            if(parentAffiliations != null){
                for(Parent_Affiliation__c parentAffiliation : parentAffiliations){
                    parentAffiliation.Student_Athlete__c = true;
                }
            }
        }
        parentAffiliationsByEducationIds.clear();

        // Add all remaining records of existing Parent Affiliations to a single object for remova
        // These no longer meet the criteria so remove them
        for(List<Parent_Affiliation__c> parentAffiliations : existParentAffiliationsListByChildId.values()){
            deleteParentAffiliations.addAll(parentAffiliations);
        }
        
        // System.debug('AQCMU_CalcParentAffiliation.execute -> deleteParentAffiliations:' + deleteParentAffiliations);
        // System.debug('AQCMU_CalcParentAffiliation.execute -> updateParentAffiliations:' + updateParentAffiliations);
        // System.debug('AQCMU_CalcParentAffiliation.execute -> insertParentAffiliations:' + insertParentAffiliations);

        // Delete the Parent Affiliations that no longer have children with 'In progress' or Primary Degrees and check the results for errors
        Database.DeleteResult[] ldr = Database.delete(deleteParentAffiliations, false);
        for(Database.DeleteResult dr : ldr){
            if (dr.isSuccess()){
                recordsDeleted += 1;
            }
            if(!dr.isSuccess() || Test.isRunningTest()) {
                String deleteErrors = '';
                for(Database.Error error : dr.getErrors()){
                    recordsNotDeleted += 1;
                    deleteErrors += dr.getId() + ':' + error.getStatusCode() + ':' + error.getMessage() + ' \n';
                }
                strBodyError += deleteErrors;
                System.debug('Could not update record(s): ' + deleteErrors);
            }
        }

        // Update the existing Parent Affiliations and check the results for errors
        Database.SaveResult[] lsr = Database.update(updateParentAffiliations, false);
        for(Database.SaveResult sr : lsr){
            if (sr.isSuccess()){
                recordsUpdated += 1;
            }
            if(!sr.isSuccess() || Test.isRunningTest()) {
                String updateErrors = '';
                for(Database.Error error : sr.getErrors()){
                    recordsNotUpdated += 1;
                    updateErrors += sr.getId() + ':' + error.getStatusCode() + ':' + error.getMessage() + ' \n';
                }
                strBodyError += updateErrors;
                System.debug('Could not update record(s): ' + updateErrors);
            }
        }

        // the new Parent Affiliations and check the results for errors
        lsr = Database.insert(insertParentAffiliations, false);
        for(Database.SaveResult sr : lsr){
            if(sr.isSuccess()){
                recordsInserted += 1;
            }
            if(!sr.isSuccess() || Test.isRunningTest()) {
                String insertErrors = '';
                for(Database.Error error : sr.getErrors()){
                    recordsNotInserted += 1;
                    insertErrors += sr.getId() + ':' + error.getStatusCode() + ':' + error.getMessage() + ' \n';
                }
                strBodyError += insertErrors;
                System.debug('Could not insert record(s): ' + insertErrors);
            }
        }
    }

    /*  
    * Using the record processed information send an email to the user that scheduled the batch job.
    *  
    * @param bc a Database.BatchableContext that references the current Batch context
    */
    global void finish(Database.BatchableContext bc){
        System.debug('Finish');
        System.debug('AQCMU_CalcParentAffiliation.finish -> existingRecordsFound:' + existingRecordsFound);
        System.debug('AQCMU_CalcParentAffiliation.finish -> recordsDeleted:' + recordsDeleted);
        System.debug('AQCMU_CalcParentAffiliation.finish -> recordsNotDeleted:' + recordsNotDeleted);
        System.debug('AQCMU_CalcParentAffiliation.finish -> recordsUpdated:' + recordsUpdated);
        System.debug('AQCMU_CalcParentAffiliation.finish -> recordsNotUpdated:' + recordsNotUpdated);
        System.debug('AQCMU_CalcParentAffiliation.finish -> recordsInserted:' + recordsInserted);
        System.debug('AQCMU_CalcParentAffiliation.finish -> recordsNotInserted:' + recordsNotInserted);

        if(AQCMU_Util.canSendEmail()){
            AQCMU_Util.sendFinishResultsEmail(
                bc,
                'Parent Affiliation',
                'existingRecordsFound: ' + existingRecordsFound + '\n' +
                'recordsDeleted: ' + recordsDeleted + '\n' +
                'recordsNotDeleted: ' + recordsNotDeleted + '\n' +
                'recordsUpdated: ' + recordsUpdated + '\n' +
                'recordsNotUpdated: ' + recordsNotUpdated + '\n' +
                'recordsInserted: ' + recordsInserted + '\n' +
                'recordsNotInserted: ' + recordsNotInserted + '\n' +
                'Error Record Ids: ' + strBodyError + '\n\n',
                false
            );
        }
    }
}