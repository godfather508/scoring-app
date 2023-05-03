public with sharing class ScoringAppLWCController {
    @AuraEnabled(cacheable=true)
    public static Scoring_Event_Team__c findLeadingTeam(String eventId) {
        List<Scoring_Event_Team__c> teams = [SELECT Id, Event_Team_Scoring__c, Scoring_Team__r.Name FROM Scoring_Event_Team__c 
            WHERE Scoring_Event__c = :eventId AND Event_Team_Scoring__c > 0 ORDER BY Event_Team_Scoring__c DESC];
        if (teams.size() > 0) return teams[0];
        return null;
    }

    @AuraEnabled
    public static List<Scoring_Team_Member__c> findJoinedEvent(String eventId) {
        List<Scoring_Event_Team__c> eventTeams = findTeams(eventId);
        Set<Id> teamIds = new Set<Id>();
        for (Scoring_Event_Team__c eventTeam : eventTeams) {
            teamIds.add(eventTeam.Scoring_Team__c);
        }
        List<Scoring_Team_Member__c> teamMembers = [SELECT Id, Team__c, Team__r.Name FROM Scoring_Team_Member__c WHERE Team__c IN :teamIds AND User__c = :UserInfo.getUserId()];
        return teamMembers;
    }

    @AuraEnabled
    public static List<Scoring_Event_Team__c> findTeams(String eventId) {
        return [SELECT Id, Scoring_Team__c, Scoring_Event_Location__c, Scoring_Team__r.Name FROM Scoring_Event_Team__c WHERE Scoring_Event__c = :eventId];
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

    @AuraEnabled
    public static List<String> findJoinedLocationIds(String eventId) {
        List<Scoring_Event_Team__c> eventTeams = findTeams(eventId);
        Map<Id, Scoring_Event_Team__c> mapIdTeams = new Map<Id, Scoring_Event_Team__c>();
        for (Scoring_Event_Team__c eventTeam : eventTeams) {
            mapIdTeams.put(eventTeam.Scoring_Team__c, eventTeam);
        }
        List<Scoring_Team_Member__c> teamMembers = [SELECT Id, Team__c, Team__r.Name FROM Scoring_Team_Member__c WHERE Team__c IN :mapIdTeams.keySet() AND User__c = :UserInfo.getUserId()];
        List<String> locationIds = new List<String>();
        for (Scoring_Team_Member__c teamMember : teamMembers) {
            locationIds.add(mapIdTeams.get(teamMember.Team__c).Scoring_Event_Location__c);
        }
        return locationIds;
    }

    @AuraEnabled(cacheable=true)
    public static List<Scoring_Event_Clue__c> findClues(String recordId) {
        List<Scoring_Event_Clue__c> clues = new List<Scoring_Event_Clue__c>();
        Id tempId = Id.valueOf(recordId);
        if (tempId.getSobjectType() == Schema.Scoring_Event__c.getSObjectType()) {
            if (!Scoring_Event_Clue__c.getSobjectType().getDescribe().isCreateable()) {
                Scoring_Event__c evt = [SELECT Id, Scoring_Start__c FROM Scoring_Event__c WHERE Id = :recordId LIMIT 1];
                if (evt.Scoring_Start__c < Datetime.now()) {
                    return new List<Scoring_Event_Clue__c>();
                }
                List<String> locationIds = findJoinedLocationIds(recordId);
                clues = [SELECT Id, Description__c, Max_Point__c FROM Scoring_Event_Clue__c WHERE Event_Location__c IN :locationIds];
            }else {
                clues = [SELECT Id, Description__c, Max_Point__c FROM Scoring_Event_Clue__c WHERE Scoring_Event__c = :recordId];
            } 
        }
        return clues;
    }
}