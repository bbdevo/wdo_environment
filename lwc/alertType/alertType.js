import { LightningElement, api } from 'lwc';

export default class AlertType extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api subscription;
    @api isDisabled;
    @api isChecked;

    // get isChecked() {
    //     return this.subscription.checked;
    // }

    toggleChange() {
        const changeEvent = new CustomEvent('checkboxchange', {
            detail: {
                value: this.subscription,
                checked: this.template.querySelector('lightning-input.toggle').checked
            }
        });
        this.dispatchEvent(changeEvent);
    }

}