public with sharing class ScoringDataFactory {
    public static void createEvent(String name, String description, Integer num) {

    }

    public static void createLocation(String name, String description, Integer num) {

    }

    public static void createClue(String name, String description, Integer num) {

    }

    public static void createTeam(String name, String description, Integer num) {

    }

    public static void createEventTeam(String name, String description, Integer num) {

    }

    public static void createSubmission(String name, String description, Integer num) {

    }

    public static void createScoringData(String name, String description) {
        createEvent('Event', 'Test Event', 1);
        createLocation('Location', 'Test Location', 1);
        createClue('Clue', 'Test Clue', 100);
        createTeam('Team', 'Test Team', 10);
        createEventTeam('EventTeam','Test EventTeam', 10);
        createSubmission('Submission','Test Submission', 100);
    }
}