/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, track } from 'lwc';

export default class Lookup extends LightningElement {
    @api defaultResults;
    @api emptyStateText = 'No results found';
    @api errorMessage = 'Required';
    @api iconName;
    @api label;
    @api minSearchLength = 2;
    @api placeholder = 'Search...';
    @api primaryField;
    @api required
    @api secondaryField;
    @api threshold = 1;
    @api disabled

    _valid = true;

    @api
    get searchResults() {
        if (this._searchResults) {
            return this._searchResults;
        }

        if (this.defaultResults) {
            return {
                results: this.defaultResults
            };
        }

        return null;
    }
    set searchResults(searchResults) {
        if(searchResults) {
            let searchTerm = searchResults.searchTerm;

            if (!searchTerm) {
                searchTerm = '';
            }

            if (searchTerm != this.searchTerm) {
                return;
            }

            this._searchResults = searchResults;

            if(searchResults.hasOwnProperty('searchMessage')) {
                this.searchMessage = searchResults.searchMessage;
            } else {
                this.searchMessage = 'Results for "' + this.searchTerm + '"';
            }

            if(searchResults.results) {
                if(this.value !== '') {
                    this.value = this.value;
                    this.showListbox = false;
                } else {
                    this.showListbox = true;
                    this.searching = false;
                    setTimeout(() => {
                        this.setListBox();
                    }, 1);
                }
            }
        } else {
            this._searchResults = null
            this.searchMessage = null;
        }
    }

    @api
    get valid() {
        if(this.required) {
            return this._valid;
        }
        return true;
    }
    set valid(valid) {
        this._valid = valid;
    }

    @api
    get value(){
        return this._value || '';
    }
    set value(value){
        this._value = value;
        this.selectedOption = undefined;
        this.showListbox = false;

        let searchResults = this.searchResults;

        if(searchResults && searchResults.results && searchResults.results.length) {
            searchResults.results.forEach(result => {
                if(result.Id == value) {
                    this._value = value;
                    this.valid = true;
                    this.selectedOption = result[this.primaryField];
                    this.searchTerm = '';
                }
            });
        }
    }

    @track searchTerm = '';
    @track selectedOption;
    @track searching = false;
    @track showListbox = false;
    @track searchMessage;

    get errorState() {
        return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' + (this.valid ? '' : ' slds-has-error');
    }

    get inputDivClass() {
        if(this.selectedOption) {
            return 'slds-combobox__form-element slds-input-has-icon slds-input-has-icon_left-right';
        }
        return 'slds-combobox__form-element slds-input-has-icon slds-input-has-icon_right';
    }

    get inputClass() {
        return 'slds-input slds-combobox__input' + (this.selectedOption ? ' slds-combobox__input-value slds-combobox__input-value' : '');
    }

    get iconNameAttribute() {
        return this.iconName;
    }

    get buttonIcon() {
        return 'slds-button slds-button_icon slds-input__icon slds-input__icon_right' + (this.selectedOption ? ' slds-show' : ' slds-hide');
    }

    get listboxClass() {
        return 'slds-dropdown slds-dropdown_length-with-icon-7 slds-dropdown_fluid' + (this.showListbox ? '' : ' slds-hidden');
    }

    setListBox(){
        let listbox = this.template.querySelector('.slds-dropdown');

        if(listbox !== null){
            //height adjusted based on threshold
            let adjustedHeight = listbox.getBoundingClientRect().height * (1 - this.threshold);
            //use adjusted height to calculate new bottom
            let adjustedBottom = listbox.getBoundingClientRect().bottom + adjustedHeight;
            //check if new adjusted bottom is out of window
            if(window.innerHeight - adjustedBottom < 0) {
                listbox.classList.add('slds-dropdown_bottom');
            } else if(window.innerHeight - adjustedBottom > 400){
                listbox.classList.remove('slds-dropdown_bottom');
            }
        }
    }

    search(event) {
        this.valid = true;

        if(this.searchTerm !== event.target.value) {
            this.searchTerm = event.target.value;
            clearTimeout(this.delayTimeout);

            if (this.searchTerm.length < this.minSearchLength) {
                this.searchResults = null;
                this.searching = false;
                if (this.searchResults) {
                    this.showListbox = true;
                } else {
                    this.showListbox = false;
                }
                return;
            }

            this.showListbox = true;
            this.searching = true;
            this.delayTimeout = setTimeout(() => {
                if(this.searchTerm.length >= this.minSearchLength) {
                    const searchEvent = new CustomEvent('search', {
                        detail: this.searchTerm
                    });
                    this.dispatchEvent(searchEvent);
                } else {
                    this.searchResults = null;
                }
            }, 500);
        }
    }

    select(event) {
        this.value = event.currentTarget.dataset.id;

        const changeEvent = new CustomEvent('change', {
            detail: event.currentTarget.dataset.id
        })
        this.dispatchEvent(changeEvent);
    }

    @api
    unselect() {
        this.selectedOption = undefined;
        this.value = '';
        this.valid = false;
        this.searchTerm = '';
        this.searchResults = null;
        this.dispatchEvent(new CustomEvent('unselect'));
    }

    hideDropdown() {
        this.showListbox = false;
    }

    showDropdown() {
        if (this.value === '') {
            if (this.searchTerm.length > this.minSearchLength || this.defaultResults) {
                this.showListbox = true;
                this.searching = false;
                setTimeout(() => {
                    this.setListBox();
                }, 1);
            }
        }
    }

    @api
    blur() {
        this.template.querySelector('.slds-input').blur();
    }

    @api
    focus() {
        this.template.querySelector('.slds-input').focus();
    }

    @api
    setErrorMessage(errorMessage) {
        this.errorMessage = errorMessage;
    }
}