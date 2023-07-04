import { LightningElement, api } from 'lwc';

export default class Result extends LightningElement {
    @api result;
    @api iconName;
    @api primaryField;
    @api secondaryField;

    get primaryFieldLabel() { 
        return this.result[this.primaryField];
    }

    get secondaryFieldLabel() {
        return this.result[this.secondaryField];
    }
    
}