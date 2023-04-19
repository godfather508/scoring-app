trigger SubmissionTrigger on Scoring_Event_Submission__c (after update) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            SubmissionTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.new);
        }
    }
}