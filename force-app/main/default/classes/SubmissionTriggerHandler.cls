public class SubmissionTriggerHandler {
    public static void afterUpdate(Map<Id, Scoring_Event_Submission__c> oldSubs, List<Scoring_Event_Submission__c> newSubs) {
        System.debug('SubmissionTriggerHandler');
        updateApprovedScoring(oldSubs, newSubs);
    }


    public static void updateApprovedScoring(Map<Id, Scoring_Event_Submission__c> oldSubs, List<Scoring_Event_Submission__c> newSubs) {
        List<Id> recordIds = new List<Id>();
        for (Scoring_Event_Submission__c newSub : newSubs) {
            Scoring_Event_Submission__c oldSub  = oldSubs.get(newSub.Id);
            if (newSub.Approval_Status__c == 'Approved' && newSub.Approval_Status__c != oldSub.Approval_Status__c) {
                recordIds.add(newSub.Scoring_Event_Clue__c);
            }
        }
        submissionScoringCalc(recordIds);
    }
    
    @future
    public static void submissionScoringCalc(List<Id> recordIds) {
        Map<Id, Scoring_Event_Clue__c> clues = new Map<Id, Scoring_Event_Clue__c>(
            [SELECT Id, Max_Point__c, Min_Point__c, Reduction_Step_Point__c 
            FROM Scoring_Event_Clue__c WHERE Id IN :recordIds]);
        List<Scoring_Event_Submission__c> subs = [SELECT Id, Scoring_Event_Clue__c, Scoring_Event_Team__c, CreatedDate
                                                FROM Scoring_Event_Submission__c 
                                                WHERE Scoring_Event_Clue__c IN :recordIds AND Approval_Status__c = 'Approved'];
        Map<Id, Map<Id, Scoring_Event_Submission__c>> calcSubs = new Map<Id, Map<Id, Scoring_Event_Submission__c>>();
        for (Scoring_Event_Submission__c sub : subs) {
            if (!calcSubs.containsKey(sub.Scoring_Event_Clue__c)) {
                calcSubs.put(sub.Scoring_Event_Clue__c, new Map<Id, Scoring_Event_Submission__c>());
            }
            calcSubs.get(sub.Scoring_Event_Clue__c).put(sub.Scoring_Event_Team__c, sub);
        }

        List<Scoring_Event_Submission__c> updSubmissions = new List<Scoring_Event_Submission__c>();
        for(Id clueId : calcSubs.keySet()) {
            List<Scoring_Event_Submission__c> calcSub = calcSubs.get(clueId).values();
            calcScoring(calcSub, clues.get(clueId));
            updSubmissions.addAll(calcSub);
        }
        update updSubmissions;
    }

    public static void calcScoring(List<Scoring_Event_Submission__c> subs, Scoring_Event_Clue__c clue) {
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