import { LightningElement, api, wire } from 'lwc';
import findLeadingTeam from '@salesforce/apex/ScoringAppLWCController.findLeadingTeam';

export default class LeadingTeam extends LightningElement {
    messageCongrats = 'Congratulations to the team A who is leading with 100 points';

    @api recordId;
    @wire(findLeadingTeam, {eventId: '$recordId'})
    findLeadingTeam({ error, data }) {
        if (data) {
            this.messageCongrats = 'Congratulations to the team ' + data.Scoring_Team__r.Name
                + ' who is leading with ' + data.Event_Team_Scoring__c + ' points';
        } else {
            this.messageCongrats = 'Waiting.';
        }
    }
}