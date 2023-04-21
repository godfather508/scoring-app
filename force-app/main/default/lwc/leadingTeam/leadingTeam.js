import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import findLeadingTeam from '@salesforce/apex/LeadingTeamController.findLeadingTeam';

export default class LeadingTeam extends LightningElement {
    messageCongrats = 'Congratulations to the team A who is leading with 100 points';
    @api recordId;
    // @wire(findLeadingTeam, { recordId: '$recordId' })
    // wiredData({ error, data }) {
    //     if (data) {
    //         console.log(data);
    //         this.messageCongrats = 'Congratulations to the team ' + data.name + ' who is leading with ' + data.teamPoint + ' points';
    //     } else {
    //         this.messageCongrats = '';
    //     }
    // }

    // // Method to refresh the wire adapter every minute
    // refreshData() {
    //     return refreshApex(this.wiredData);
    // }

    // // Call refreshData every minute
    // connectedCallback() {
    //     this.refreshInterval = setInterval(() => {
    //         this.refreshData();
    //     }, 60000);
    // }

    // // Stop refreshing when the component is disconnected
    // disconnectedCallback() {
    //     clearInterval(this.refreshInterval);
    // }
}
