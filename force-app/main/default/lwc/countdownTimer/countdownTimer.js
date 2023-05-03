import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class CountdownTimer extends LightningElement {
    days=365;
    hours=24;
    minutes=60;
    seconds=100;
    
    startTime;
    endTime;
    timeRemaining;
    intervalId;
    title = 'Countdown';

    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: ['Scoring_Event__c.Scoring_End__c', 'Scoring_Event__c.Scoring_Start__c'] })
    loadEvent({ error, data }) {
        if (error) {
            this.error = error;
          } else if (data) {
            this.startTime = new Date(data.fields.Scoring_Start__c.value);
            this.endTime = new Date(data.fields.Scoring_End__c.value);
            this.startCountdown();
          }
    }
    
    // Start the countdown to the start time
    startCountdown() {
        this.intervalId = setInterval(() => {
            this.calcCountDown();
        }, 1000);
    }

    calcCountDown() {
        const now = new Date().getTime();
            if (this.startTime.getTime() > now) {
                this.title = 'Countdown to Start Time';
                const distance = this.startTime.getTime() - now;
                this.days = Math.floor(distance / (1000 * 60 * 60 * 24));
                this.hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                this.minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                this.seconds = Math.floor((distance % (1000 * 60)) / 1000);
                this.timeRemaining = `${this.days}d ${this.hours}h ${this.minutes}m ${this.seconds}s`;
            } 

            if (this.startTime.getTime() <= now && this.endTime.getTime() >= now) {
                this.title = 'Countdown to End Time';
                const distance = this.endTime.getTime() - now;
                this.days = Math.floor(distance / (1000 * 60 * 60 * 24));
                this.hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                this.minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                this.seconds = Math.floor((distance % (1000 * 60)) / 1000);
                this.timeRemaining = `${this.days}d ${this.hours}h ${this.minutes}m ${this.seconds}s`;
            }

            if (this.endTime.getTime() < now) {
                clearInterval(this.intervalId);
                this.title = 'Countdown';
                this.timeRemaining = 'The event finished';
            }
    }
    
    disconnectedCallback() {
        clearInterval(this.intervalId);
    }
}