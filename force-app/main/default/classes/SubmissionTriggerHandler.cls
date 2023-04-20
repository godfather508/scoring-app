public class SubmissionTriggerHandler {
    public static void beforeInsert(List<Scoring_Event_Submission__c> newSubs) {
        updateLookupSubmission(newSubs);
    }

    public static void beforeUpdate(Map<Id, Scoring_Event_Submission__c> oldSubs, List<Scoring_Event_Submission__c> newSubs) {
        updateLookupSubmission(newSubs);
        updateApprovedScoring(oldSubs, newSubs);
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static void updateLookupSubmission(List<Scoring_Event_Submission__c> newSubs) {
        List<Scoring_Event_Submission__c> hasClueSubs = new List<Scoring_Event_Submission__c>();
        for (Scoring_Event_Submission__c newSub : newSubs) {
            if (newSub.Scoring_Event_Clue__c != null) {
                hasClueSubs.add(newSub);
            }
        }
        updateLookupSubmission_Clue(hasClueSubs);
    }
    
    public static void updateLookupSubmission_Clue(List<Scoring_Event_Submission__c> subs) {
        List<Scoring_Team_Member__c> teamMembers = [SELECT Id, Team__c FROM Scoring_Team_Member__c WHERE User__c = :UserInfo.getUserId()];
        if (teamMembers.size() == 0) return;
        Set<Id> teamIds = new Set<Id>();
        for (Scoring_Team_Member__c teamMember : teamMembers) {
            teamIds.add(teamMember.Team__c);
        }

        Set<Id> clueIds = new Set<Id>();
        for (Scoring_Event_Submission__c sub : subs) {
            clueIds.add(sub.Scoring_Event_Clue__c);
        }
        Map<Id, Scoring_Event_Clue__c> clues = new Map<Id, Scoring_Event_Clue__c>([
            SELECT Id, Event_Location__c, Event_Location__r.Scoring_Event__c 
            FROM Scoring_Event_Clue__c WHERE Id IN :clueIds
        ]);
        Set<Id> eventIds = new Set<Id>();
        for (Scoring_Event_Clue__c clue : clues.values()) {
            eventIds.add(clue.Event_Location__r.Scoring_Event__c);
        }
        Map<Id, Scoring_Event__c> events = new Map<Id, Scoring_Event__c>([
            SELECT Id, (SELECT Scoring_Team__c FROM Scoring_Event_Teams__r) 
            FROM Scoring_Event__c WHERE Id IN :eventIds
        ]);
        for (Scoring_Event_Submission__c sub : subs) {
            Scoring_Event_Clue__c clue = clues.get(sub.Scoring_Event_Clue__c);
            Scoring_Event__c event = events.get(clue.Event_Location__r.Scoring_Event__c);
            if (event.Scoring_Event_Teams__r == null) continue;
            for (Scoring_Event_Team__c eventTeam : event.Scoring_Event_Teams__r) {
                if (teamIds.contains(eventTeam.Scoring_Team__c)) {
                    sub.Scoring_Event_Team__c = eventTeam.Id;
                    sub.Scoring_Team__c = eventTeam.Scoring_Team__c;
                    continue;
                }
            }
            sub.Location__c = clue.Event_Location__c;
            sub.Scoring_Event__c = event.Id;
        } 
    }   

    public static void updateApprovedScoring(Map<Id, Scoring_Event_Submission__c> oldSubs, List<Scoring_Event_Submission__c> newSubs) {
        List<Id> recordIds = new List<Id>();
        List<Scoring_Event_Submission__c> curAppSubs = new List<Scoring_Event_Submission__c>();
        for (Scoring_Event_Submission__c newSub : newSubs) {
            Scoring_Event_Submission__c oldSub  = oldSubs.get(newSub.Id);
            if (newSub.Approval_Status__c == 'Approved' && newSub.Approval_Status__c != oldSub.Approval_Status__c) {
                recordIds.add(newSub.Scoring_Event_Clue__c);
                curAppSubs.add(newSub);
            }
        }

        List<Scoring_Event_Submission__c> calcSubs = calcSubmissionScoring(curAppSubs, recordIds, false);

        updateTriggerSub(newSubs, new Map<Id,Scoring_Event_Submission__c>(calcSubs));
    }

    public static void updateTriggerSub(List<Scoring_Event_Submission__c> newSubs, Map<Id,Scoring_Event_Submission__c> calcSubs) {
        for (Scoring_Event_Submission__c newSub : newSubs) {
            if (calcSubs.containsKey(newSub.Id)) {
                newSub.Submission_Score__c = calcSubs.get(newSub.Id).Submission_Score__c;
                calcSubs.remove(newSub.Id);
            }
        }
        update calcSubs.values();
    }
    
    public static List<Scoring_Event_Submission__c> calcSubmissionScoring(List<Scoring_Event_Submission__c> curAppSubs, List<Id> recordIds, Boolean isUpdate) {
        List<Scoring_Event_Submission__c> updSubmissions = new List<Scoring_Event_Submission__c>();
        Map<Id, Scoring_Event_Clue__c> clues = new Map<Id, Scoring_Event_Clue__c>(
            [SELECT Id, Max_Point__c, Min_Point__c, Reduction_Step_Point__c 
            FROM Scoring_Event_Clue__c WHERE Id IN :recordIds]);
        List<Scoring_Event_Submission__c> subs = [SELECT Id, Scoring_Event_Clue__c, Scoring_Event_Team__c, 
                                                    Submission_Score__c, CreatedDate
                                                FROM Scoring_Event_Submission__c 
                                                WHERE Scoring_Event_Clue__c IN :recordIds 
                                                    AND Approval_Status__c = 'Approved'
                                                    AND Scoring_Event_Team__c != null
                                                ORDER BY CreatedDate ASC];
        curAppSubs.addAll(subs);
        
        Map<Id, Map<Id, Scoring_Event_Submission__c>> calcSubs = new Map<Id, Map<Id, Scoring_Event_Submission__c>>();
        for (Scoring_Event_Submission__c sub : curAppSubs) {
            if (!calcSubs.containsKey(sub.Scoring_Event_Clue__c)) {
                calcSubs.put(sub.Scoring_Event_Clue__c, new Map<Id, Scoring_Event_Submission__c>());
            }
            if (calcSubs.get(sub.Scoring_Event_Clue__c).containsKey(sub.Scoring_Event_Team__c)) {
                Scoring_Event_Submission__c newSub = calcSubs.get(sub.Scoring_Event_Clue__c).get(sub.Scoring_Event_Team__c);
                newSub.Submission_Score__c = 0;
                updSubmissions.add(newSub);
            }
            calcSubs.get(sub.Scoring_Event_Clue__c).put(sub.Scoring_Event_Team__c, sub);
        }
        
        for(Id clueId : calcSubs.keySet()) {
            List<Scoring_Event_Submission__c> calcSub = calcSubs.get(clueId).values();
            calcClueSubmissionScoring(calcSub, clues.get(clueId));
            updSubmissions.addAll(calcSub);
        }
        if (isUpdate) update updSubmissions;
        return updSubmissions;
    }

    public static void calcClueSubmissionScoring(List<Scoring_Event_Submission__c> subs, Scoring_Event_Clue__c clue) {
        Decimal currentPoint = clue.Max_Point__c;
        for (Scoring_Event_Submission__c sub : subs) {
            sub.Submission_Score__c = currentPoint;
            currentPoint = currentPoint - clue.Reduction_Step_Point__c;
            if (currentPoint < clue.Min_Point__c) {
                currentPoint = clue.Min_Point__c;
            }
        }
    }
}