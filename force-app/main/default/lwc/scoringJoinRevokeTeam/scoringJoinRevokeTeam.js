import { LightningElement, api, wire } from 'lwc';
import ScoringJoinRevokeTeamModal from 'c/scoringJoinRevokeTeamModal';
import { refreshApex } from '@salesforce/apex';
import checkJoinedEvent from '@salesforce/apex/ScoringAppLWCController.checkJoinedEvent';

export default class ScoringJoinRevokeTeam extends LightningElement {  

    message = '';
    isJoin = true;
    labelButton = 'Join Event';
    joinedTeams;

    @api recordId = '';

    connectedCallback() {
        this.loadCheckJoinedEvent();
    }

    loadCheckJoinedEvent() {
        checkJoinedEvent({ eventId: this.recordId })
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
            isJoin: this.isJoin,
            joinedTeams: this.joinedTeams
        }).then((result) => {
            if (resultModal === 'success') {
                this.loadCheckJoinedEvent();
            }
        });
      }
}