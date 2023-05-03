import { LightningElement, api, wire } from 'lwc';
import ScoringJoinRevokeTeamModal from 'c/scoringJoinRevokeTeamModal';
import findJoinedEvent from '@salesforce/apex/ScoringAppLWCController.findJoinedEvent';

export default class ScoringJoinRevokeTeam extends LightningElement {  

    message = '';
    isJoin = true;
    labelButton = 'Join Event';
    joinedTeams;

    @api recordId = '';

    connectedCallback() {
        this.loadFindJoinedEvent();
    }

    loadFindJoinedEvent() {
        findJoinedEvent({ eventId: this.recordId })
            .then(result => {
                this.joinedTeams = result;
                if (this.joinedTeams.length > 0) {
                    const teamNames = [];
                    this.joinedTeams.forEach(item => (
                        teamNames.push(item.Team__r.Name)
                    ));
                    this.message = 'Your team <b>' + teamNames.toString() + '</b> has registered to attend this event.';
                    this.isJoin = false;
                    this.labelButton = 'Withdraw Event';
                } else {
                    this.joinedTeams = null;
                    this.message = 'This is an interesting event, click the button to join';
                    this.isJoin = true;
                    this.labelButton = 'Join Event';
                }
            })
            .catch(error => {
                this.error = error;
                console.log(error);
            });
    }

    handleButtonClick() {
        ScoringJoinRevokeTeamModal.open({
            eventId: this.recordId,
            isJoin: this.isJoin
        }).then((result) => {
            if (resultModal === 'success') {
                this.loadFindJoinedEvent();
            }
        });
      }
}