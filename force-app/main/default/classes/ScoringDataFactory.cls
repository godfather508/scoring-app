public with sharing class ScoringDataFactory {
    public static List<Scoring_Event__c> createEvents(String name, String description, Integer num) {
        List<Scoring_Event__c> events = new List<Scoring_Event__c>();
        for(Integer i = 0;i< num;i++) {
            events.add(new Scoring_Event__c(
                Name = name,
                Description__c = description,
                Scoring_Start__c = System.now(),
                Scoring_End__c = System.now().addHours(1)
            ));
        }
        insert events;
        return events;
    }

    public static List<Scoring_Event_Location__c> createLocations(String name, String description, Integer num, List<Scoring_Event__c> events) {
        List<Scoring_Event_Location__c> locations = new List<Scoring_Event_Location__c>();
        for(Scoring_Event__c event : events) {
            for(Integer i = 0;i< num;i++) {
                locations.add(new Scoring_Event_Location__c(
                    Name = name,
                    Description__c = description,
                    Scoring_Event__c = event.Id
                ));
            }
        }
        insert locations;
        return locations;
    }

    public static List<Scoring_Event_Clue__c> createClues(String name, String description, Integer num, List<Scoring_Event_Location__c> locations) {
        List<Scoring_Event_Clue__c> clues = new List<Scoring_Event_Clue__c>();
        for(Scoring_Event_Location__c location : locations) {
            for(Integer i = 0;i< num;i++) {
                clues.add(new Scoring_Event_Clue__c(
                    Description__c = description,
                    Event_Location__c = location.Id,
                    Max_Point__c = i * 10,
                    Min_Point__c = 10,
                    Reduction_Step_Point__c = 5
                ));
            }
        }
        insert clues;
        return clues;
    }

    public static List<Scoring_Team__c> createTeams(String name, String description, Integer num) {
        List<Scoring_Team__c> teams = new List<Scoring_Team__c>();
        for(Integer i = 0;i< num;i++) {
            teams.add(new Scoring_Team__c(
                Name = name,
                Description__c = description
            ));
        }
        insert teams;
        return teams;
    }

    public static List<Scoring_Team_Member__c> createTeamMembers(String name, String description, Integer num, List<Scoring_Team__c> teams) {
        List<Scoring_Team_Member__c> members = new List<Scoring_Team_Member__c>();
        for (Scoring_Team__c team : teams) {
            for(Integer i = 0;i< num;i++) {
                members.add(new Scoring_Team_Member__c(
                    User__c = UserInfo.getUserId(),
                    Team__c = team.Id
                ));
            }
        }
        insert members;
        return members;
    }

    public static List<Scoring_Event_Team__c> createEventTeams(String name, String description, Integer num, Scoring_Event__c event, Scoring_Event_Location__c location, List<Scoring_Team__c> teams) {
        List<Scoring_Event_Team__c> eventTeams = new List<Scoring_Event_Team__c>();
        for (Scoring_Team__c team : teams) {
            eventTeams.add(new Scoring_Event_Team__c(
                Scoring_Event__c = event.Id,
                Scoring_Event_Location__c = location.Id,
                Scoring_Team__c = team.Id
            ));
        }
        insert eventTeams;
        return eventTeams;
    }

    public static List<Scoring_Event_Submission__c> createSubmissions(String name, String description, Integer num, List<Scoring_Event_Clue__c> clues) {
        List<Scoring_Event_Submission__c> submissions = new List<Scoring_Event_Submission__c>();
        for (Scoring_Event_Clue__c clue : clues) {
            for(Integer i = 0;i< num;i++) {
                submissions.add(new Scoring_Event_Submission__c(
                    Description__c = description,
                    Scoring_Event_Clue__c = clue.Id
                ));
            }
        }
        insert submissions;
        return submissions;
    }

    public static void createBasicScoringData() {
        List<Scoring_Event__c> events = createEvents('Event', 'Test Event', 1);
        List<Scoring_Event_Location__c> locations = createLocations('Location', 'Test Location', 2, events);
        List<Scoring_Event_Clue__c> clues = createClues('Clue', 'Test Clue', 10, locations);
        
        List<Scoring_Team__c> groupTeam1 = createTeams('Team', 'Test Team', 2);
        createTeamMembers('Team', 'Test Team', 4, groupTeam1);
        createEventTeams('EventTeam','Test EventTeam', 10, events.get(0), locations.get(0), groupTeam1);

        List<Scoring_Team__c> groupTeam2 = createTeams('Team', 'Test Team', 2);
        createTeamMembers('Team', 'Test Team', 4, groupTeam1);
        createEventTeams('EventTeam','Test EventTeam', 10, events.get(0), locations.get(1), groupTeam1);

        createSubmissions('Submission','Test Submission', 2, clues);
    }
}