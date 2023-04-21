@isTest
private class LeadingTeamControllerTest {

    @testSetup static void setup() {
        // Create test data for Scoring_Event_Team__c object
        ScoringDataFactory.createBasicScoringData();
    }

    @isTest static void testFindLeadingTeam() {
        Test.startTest();
        Scoring_Event_Submission__c sub = [SELECT Id, Approval_Status__c FROM Scoring_Event_Submission__c LIMIT 1];
        sub.Approval_Status__c = 'Approved';
        List<Scoring_Event__c> events = [SELECT Id FROM Scoring_Event__c];
        Scoring_Event_Team__c result = LeadingTeamController.findLeadingTeam(events.get(0).Id);
        Test.stopTest();
    }
}
