import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class CreateSubmissionModal extends LightningModal {
    @api clueId;

    get flowInput(){
        return [{
            name: 'clueId',
            type: 'String',
            value: this.clueId
        }];
    }

    flowStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            this.close('success');
        }
    }
}