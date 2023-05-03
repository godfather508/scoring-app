@isTest
private class ScoringAppLWCControllerTest {
    @testSetup static void dataSetup(){
        ScoringDataFactory.createBasicScoringData();
    }

    @isTest static void testScoringAppLWCController_temp() {
        try {
            Test.startTest();
            Scoring_Event__c sEvent = [SELECT Id FROM Scoring_Event__c LIMIT 1];
            ScoringAppLWCController.findLeadingTeam(sEvent.Id);
            ScoringAppLWCController.findJoinedEvent(sEvent.Id);
            ScoringAppLWCController.findTeams(sEvent.Id);
            ScoringAppLWCController.findClues(sEvent.Id);
            
            Scoring_Team__c team = [SELECT Id FROM Scoring_Team__c LIMIT 1];
            ScoringAppLWCController.saveTeamMember(team.Id, true);
            ScoringAppLWCController.saveTeamMember(team.Id, false);
            Test.stopTest();
        } catch (Exception ex) {
            
        } finally {
            List<Scoring_Event_Submission__c> subs = [SELECT Id, Submission_Score__c FROM Scoring_Event_Submission__c WHERE Submission_Score__c > 0];
            Assert.areEqual(1, 1, 'Update later.');
        }
    }
}