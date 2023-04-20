@isTest
private class SubmissionTriggerHandlerTest {
    @testSetup static void dataSetup(){
        ScoringDataFactory.createBasicScoringData();
    }

    @isTest static void testSubmissionTriggerHandler_UpdateApprove() {
        try {
            Test.startTest();
            Scoring_Event_Submission__c sub = [SELECT Id, Approval_Status__c FROM Scoring_Event_Submission__c LIMIT 1];
            sub.Approval_Status__c = 'Approved';
            update sub;
            Test.stopTest();
        } catch (Exception ex) {
            
        } finally {
            List<Scoring_Event_Submission__c> subs = [SELECT Id, Submission_Score__c FROM Scoring_Event_Submission__c WHERE Submission_Score__c > 0];
            Assert.areEqual(subs.size(), 1, 'The submission score is updated.');
        }
    }
}