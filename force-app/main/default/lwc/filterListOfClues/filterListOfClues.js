import { LightningElement, api, wire } from 'lwc';
import CreateSubmissionModal from 'c/createSubmissionModal';
import findClues from '@salesforce/apex/ScoringAppLWCController.findClues';
import { NavigationMixin } from 'lightning/navigation';

const actions = [
    { label: 'Submit a submission', name: 'create_submission' },
    { label: 'Show details', name: 'show_details' },
];

const columns = [
    // { label: 'Name', fieldName: 'Name' },
    { label: 'Description', fieldName: 'Description__c'},
    { label: 'Max Point', fieldName: 'Max_Point__c', initialWidth: 110},
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

export default class FilterListOfClues extends NavigationMixin(LightningElement) {
    @api recordId;
    clues;
    columns = columns;
    clueId;
    error;

    @wire(findClues, {recordId: '$recordId'})
    loadFindClues({ error, data }) {
        if (data) {
            this.clues = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.clues = undefined;
        }
    }

    handleClueSelect(event) {
        const actionName = event.detail.action.name;
        this.clueId = event.detail.row.Id;
        switch (actionName) {
            case 'create_submission':
                this.createSubmission();
                break;
            case 'show_details':
                this.showSetails();
                break;
            default:
        }
    }

    createSubmission() {
        CreateSubmissionModal.open({
            clueId: this.clueId
        });
    }

    showSetails() {
        this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: this.clueId,
				objectApiName: 'Scoring_Event_Clue__c',
				actionName: 'view',
			},
		});
    }
}