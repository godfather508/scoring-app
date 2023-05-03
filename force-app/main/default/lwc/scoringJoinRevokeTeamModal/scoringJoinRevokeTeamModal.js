import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import findTeams from '@salesforce/apex/ScoringAppLWCController.findTeams';
import saveTeamMember from '@salesforce/apex/ScoringAppLWCController.saveTeamMember';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import findJoinedEvent from '@salesforce/apex/ScoringAppLWCController.findJoinedEvent';

export default class ScoringJoinRevokeTeamModal extends LightningModal {
    @api teamId;
    @api eventId;
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
        if (this.eventId && this.isJoin) {
            findTeams({ eventId: this.eventId })
            .then(result => {
                this.teamOptions = result.map(item => ({
                    label: item.Scoring_Team__r.Name,
                    value: item.Scoring_Team__c
                }));
            })
            .catch(error => {
                this.error = 'System has a issue. Please contact administrator.';
                console.log(error);
            });
        }

        if (this.eventId && !this.isJoin) {
            findJoinedEvent({ eventId: this.eventId })
            .then(result => {
                console.log(result);
                this.teamOptions = result.map(item => ({
                    label: item.Team__r.Name,
                    value: item.Team__c
                }));
                this.teamId = result[0].Team__c;
            })
            .catch(error => {
                this.error = 'System has a issue. Please contact administrator.';
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
        console.log(this.teamId);
        if (this.teamId) {
            saveTeamMember({ teamId: this.teamId, isJoin: this.isJoin })
                .then(result => {
                    this.showSuccessToast();
                    this.close('success');
                })
                .catch(error => {
                    this.error = 'System has a issue. Please contact administrator.';
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