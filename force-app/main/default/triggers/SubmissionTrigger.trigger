trigger SubmissionTrigger on Scoring_Event_Submission__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            SubmissionTriggerHandler.beforeInsert(Trigger.new);
        }

        if (Trigger.isUpdate) {
            SubmissionTriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.new);
        }
    }
}