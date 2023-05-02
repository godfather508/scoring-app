public with sharing class ScoringAppLWCController {
    @AuraEnabled(cacheable=true)
    public static Scoring_Event_Team__c findLeadingTeam(String eventId) {
        List<Scoring_Event_Team__c> teams = [SELECT Id, Event_Team_Scoring__c, Scoring_Team__r.Name FROM Scoring_Event_Team__c 
            WHERE Scoring_Event__c = :eventId AND Event_Team_Scoring__c > 0 ORDER BY Event_Team_Scoring__c DESC];
        if (teams.size() > 0) return teams[0];
        return null;
    }

    @AuraEnabled
    public static List<Scoring_Team_Member__c> checkJoinedEvent(String eventId) {
        List<Scoring_Event_Team__c> eventTeams = findTeams(eventId);
        Set<Id> teamIds = new Set<Id>();
        for (Scoring_Event_Team__c eventTeam : eventTeams) {
            teamIds.add(eventTeam.Scoring_Team__c);
        }
        List<Scoring_Team_Member__c> teamMembers = [SELECT Id, Team__r.Name FROM Scoring_Team_Member__c WHERE Team__c IN :teamIds AND User__c = :UserInfo.getUserId()];
        return teamMembers;
    }

    @AuraEnabled
    public static List<Scoring_Event_Team__c> findTeams(String eventId) {
        return [SELECT Id, Scoring_Team__c, Scoring_Team__r.Name FROM Scoring_Event_Team__c WHERE Scoring_Event__c = :eventId];
    }

    @AuraEnabled
    public static void saveTeamMember(String teamId, Boolean isJoin) {
        if (isJoin) {
            Scoring_Team_Member__c teamMember = new Scoring_Team_Member__c(
                Team__c = teamId,
                User__c = UserInfo.getUserId()
            );
            insert teamMember;
        } else {
            delete [SELECT Id FROM Scoring_Team_Member__c WHERE Team__c = :teamId AND User__c = :UserInfo.getUserId()];
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Scoring_Event_Clue__c> findClues(String recordId) {
        Id tempId = Id.valueOf(recordId);
        if (tempId.getSobjectType() == Schema.Scoring_Event__c.getSObjectType()) {
            List<Scoring_Team_Member__c> teams = checkJoinedEvent(tempId);
            
        }
        List<Scoring_Event_Clue__c> clues = [SELECT Id, Description__c, Max_Point__c FROM Scoring_Event_Clue__c];
        return clues;
    }
}