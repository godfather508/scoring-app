import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import findTeams from '@salesforce/apex/ScoringAppLWCController.findTeams';
import saveTeamMember from '@salesforce/apex/ScoringAppLWCController.saveTeamMember';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ScoringJoinRevokeTeamModal extends LightningModal {
    @api teamId;
    @api eventId;
    @api joinedTeams;
    @api isJoin;

    modalLabel;
    okBtnLabel;
    message;
    error;
    teamOptions = [];

    connectedCallback() {
        if (this.isJoin) { 
            this.okBtnLabel = 'Join';
            this.modalLabel = this.eventId ? 'Join Event Team' : 'Join Team';
            this.message = '';
        } else {
            this.okBtnLabel = 'Withdraw';
            this.modalLabel = this.eventId ? 'Withdraw Event Team' : 'Withdraw Team';
            this.message = 'Are you sure you want to withdraw?';
        }
        this.loadFindTeams();
    }

    loadFindTeams() {
        if (this.eventId) {
            findTeams({ eventId: this.eventId })
            .then(result => {
                this.teamOptions = result.map(item => ({
                    label: item.Scoring_Team__r.Name,
                    value: item.Scoring_Team__c
                }));
            })
            .catch(error => {
                this.error = error;
                console.log(error);
            });
        }
    }

    handleTeamChange(event) {
        this.teamId = event.detail.value;
    }

    handleCancel(event) {
        this.close('cancel');
    }

    handleOkay() {
        if (this.validate()) {
            this.loadSaveTeamMember();
        }
    }

    validate() {
        return true;
    }

    loadSaveTeamMember() {
        if (this.joinedTeams && this.joinedTeams.length === 1) {
            this.teamId = this.joinedTeams[0].Team__c;
        }
        if (this.teamId) {
            saveTeamMember({ teamId: this.teamId, isJoin: this.isJoin })
                .then(result => {
                    this.showSuccessToast();
                    this.close('success');
                })
                .catch(error => {
                    this.error = error;
                    console.log(error);
                });
        }
    }

    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Information',
            message: this.isJoin ? 'You are joined.' : 'You are withdraw.',
        });
        this.dispatchEvent(evt);
      }
}