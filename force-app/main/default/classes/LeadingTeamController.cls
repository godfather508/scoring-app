public with sharing class LeadingTeamController {

    @AuraEnabled(cacheable=true)
    public static Scoring_Event_Team__c findLeadingTeam(String eventId) {
        List<Scoring_Event_Team__c> teams = [SELECT Id, Event_Team_Scoring__c, Scoring_Team__r.Name FROM Scoring_Event_Team__c 
            WHERE Scoring_Event__c = :eventId AND Event_Team_Scoring__c > 0 ORDER BY Event_Team_Scoring__c DESC];
        if (teams.size() > 0) return teams[0];
        return null;
    }
}