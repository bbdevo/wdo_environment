import { LightningElement, api } from 'lwc';

export default class Message extends LightningElement {
    @api message;

    open() {
        window.open(this.message.Message_Url__c);
    }
    
}