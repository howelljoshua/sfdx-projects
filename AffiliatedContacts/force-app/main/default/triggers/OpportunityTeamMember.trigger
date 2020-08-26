/**
* @author Mathew Ruff, Sierra-Cedar
* @date 11/1/18
*
* @edit 01/04/18 Michael Steptoe (Sleek), Added logic for populating Team_Leader__c on Opportunity
*
* OpportunityTeamMember Trigger
*/
trigger OpportunityTeamMember on OpportunityTeamMember (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            Set<Id> opportunityIds = new Set<Id>();
            List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

            for (OpportunityTeamMember member : Trigger.new) {
                opportunityIds.add(member.OpportunityId);
            }

            for (Opportunity opp : [
                SELECT Team_Leader__c, Team_Member__c, (
                    SELECT UserId, User.Name, AQB__StartDate__c, AQB__EndDate__c, TeamMemberRole
                    FROM OpportunityTeamMembers
                    ORDER BY User.Name ASC
                )
                FROM Opportunity
                WHERE Id IN :opportunityIds
            ]) {
                Boolean updateOpp = false;
                String teamMembers = '';
                // (Steptoe - 01/04/18 BEGIN)
                Boolean teamLeaderNotFound = true;
                // (Steptoe - 01/04/18 END)

                for (OpportunityTeamMember member : opp.OpportunityTeamMembers) {
                    if (member.AQB__StartDate__c != null && member.AQB__EndDate__c == null) {
                        if (member.TeamMemberRole != 'Team Leader') {
                            teamMembers += member.User.Name + ', ';
                        } else if (member.TeamMemberRole == 'Team Leader') {
                            opp.OwnerId = member.UserId;
                            // (Steptoe - 01/04/18 BEGIN) Team Leader found add name to Opportunity
                            opp.Team_Leader__c = member.User.Name;
                            teamLeaderNotFound = false;
                            // (Steptoe - 01/04/18 END)
                            updateOpp = true;
                        }
                    }
                }

                // (Steptoe - 01/04/18 BEGIN) If Team Leader not found this section should be blank
                if (teamLeaderNotFound && !String.isBlank(opp.Team_Leader__c)) {
                    opp.Team_Leader__c = '';
                    updateOpp = true;
                }
                // (Steptoe - 01/04/18 END)

                if (!teamMembers.equals(opp.Team_Member__c)) {
                    opp.Team_Member__c = teamMembers.substringBeforeLast(', ');
                    updateOpp = true;
                }

                if (updateOpp) {
                    opportunitiesToUpdate.add(opp);
                }
            }

            if (!opportunitiesToUpdate.isEmpty()) {
                update opportunitiesToUpdate;
            }
        }
    }
}