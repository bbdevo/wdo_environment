import { LightningElement, api, track } from 'lwc';

export default class Picklist extends LightningElement {
    @api
    get searchable(){
        return this._searchable;
    }

    set searchable(value){
        this._searchable = value;
    }
    @api
    get required(){
        return this._required;
    }

    set required(value){
        this._required = value;
    }
    @api
    get readonly(){
        return this._readonly;
    }

    set readonly(value){
        this._readonly = value;
    }
    @api
    get disabled(){
        return this._disabled;
    }

    set disabled(value){
        this._disabled = value;
    }

    @api variant = 'standard';
    @api placeholder = '--- Select an option ---';
    @api searchBy = 'label';
    @api name = '';

    @api threshold = 1;
    @api dropdownHeight = 5;

    @api label = '';
    @api options = [];

    @track validity = true;
    @track showMenu = false;

    @track _value = '';
    @track searchTerm = '';
    @track valueLabel = '';
    @track errorMessage = 'Complete this field';

    @track focusIndex = -1;
    @track keyboardMode = false;

    @track blurTimeout;
    @track dropdownStyles = '';

    @api
    focus(){
        if(!this.showMenu){
            this.toggleMenu();
        } else{
            this.template.querySelector('.sp-menu-button').focus();
        }
    }

    @api
    blur(){
        this.blur();
    }

    @api
    isValid(){
        return this.validity;
    }

    @api
    setErrorMessage(message){
        this.errorMessage = message;
    }

    @api
    get value(){
        return this._value;
    }

    set value(value){
        this._value = value || value === 0 ? value.toString() : '';
        this.calcValueLabel(value);
    }

    ticking = false;
    topAdjustment = 0;
    translateYAdjustment = 0;
    anchorDropdownToBottom = false;

    repositionDropdown = (() => {
        let inputBoundingRect = this.getBoundingClientRect();
        let dropdownHeight = this.template.querySelector('.slds-dropdown').getBoundingClientRect().height;
        let marginBottom = parseInt(window.getComputedStyle(this.template.querySelector('.slds-form-element')).marginBottom, 10);

        this.topAdjustment = inputBoundingRect.bottom - marginBottom;
        this.translateYAdjustment = window.innerHeight - inputBoundingRect.bottom - dropdownHeight + marginBottom - 3;
        this.anchorDropdownToBottom = (inputBoundingRect.bottom + dropdownHeight - marginBottom + 3) > window.innerHeight;

        if(!this.ticking) {
            this.ticking = true;

            window.requestAnimationFrame(() => {
                this.dropdownStyles = 'top: ' + this.topAdjustment + 'px; width: ' + inputBoundingRect.width + 'px;';

                if(this.anchorDropdownToBottom) {
                    this.dropdownStyles += ' transform: translate(0, ' + this.translateYAdjustment + 'px, 0);';
                }

                this.ticking = false;
            });
        }
    }).bind(this);

    calcValueLabel(value){
        let valueLabel = this.placeholder;
        let options = JSON.parse(JSON.stringify(this.options));

        if(options && options.length > 0) {
            for(var i = 0; i < options.length; i++){
                if(options[i].isOptGroup){
                    let selectedOption = options[i].options.find(groupOption => {
                        return groupOption.value === value;
                    })

                    if(selectedOption){
                        valueLabel = selectedOption.label
                        break;
                    }
                } else{
                    let selectedOption = options.find(option => {
                        return option.value === value;
                    })

                    if(selectedOption){
                        valueLabel = selectedOption.label
                        break;
                    }
                }
            }
        }
        this.valueLabel = valueLabel;
    }

    select(event){
        clearTimeout(this.blurTimeout);

        let selectedOption = JSON.parse(JSON.stringify(event.detail.selectedOption));
        this._value = selectedOption.value.toString();
        this.valueLabel = selectedOption.label.toString();
        this.validity = !this.required || (this._value && this.required);
        this.hideMenu();

        let evt = new CustomEvent('select',{
            detail: {
                value: this._value,
                label: this.valueLabel
            }
        });
        this.dispatchEvent(evt);
    }

    handleKeyupOnInput(event){
        let keyCode = event.keyCode;
        if(keyCode !== 38 && keyCode !== 40 && keyCode !== 27){
            if(this.searchTerm !== event.currentTarget.value){
                this.focusIndex = -1;
                this.searchTerm = event.currentTarget.value;
            }
            //stopProp on space
            if(keyCode === 32){
                event.stopPropagation();
            }
        }
    }

    handleKeyupOnPicklist(event){
        if((event.keyCode === 13 || event.keyCode === 32) && this.focusIndex < 0){
            this.preventDefaultStopProp(event);
            clearTimeout(this.blurTimeout);
            this.toggleMenu();
        } else{
            if(event.keyCode === 27){
                //close menu on escape
                this.preventDefaultStopProp(event);
                this.hideMenu();
            } else if(event.keyCode === 38){
                this.preventDefaultStopProp(event);
                if(this.showMenu){
                    this.focusIndex -= 1;
                    this.navigate(event);
                }
            } else if(event.keyCode === 40){
                this.preventDefaultStopProp(event);
                if(this.showMenu){
                    this.focusIndex += 1;
                    this.navigate(event);
                }
            } else if(event.keyCode === 13 && this.focusIndex > -1){
                this.preventDefaultStopProp(event);
                let picklistOptions = this.template.querySelectorAll('c-picklist-option');
                if(this.focusIndex < picklistOptions.length){
                    picklistOptions[this.focusIndex].select();
                }
            }
        }
    }

    handleKeydownOnInput(event){
        let keyCode = event.keyCode;
        //prevent default on enter, esc, up and down. stopProp on space
        if(keyCode === 13 || keyCode === 27 || keyCode === 38 || keyCode === 40){
            event.preventDefault();
        } else if(keyCode === 32){
            event.stopPropagation();
        }
    }

    handleKeydownOnPicklist(event){
        let keyCode = event.keyCode;
        //prevent default on enter, esc, space, up and down
        if(keyCode === 13 || keyCode === 27 || keyCode === 32 || keyCode === 38 || keyCode === 40){
            event.preventDefault();
        }
    }

    focus(){
        this.dispatchEvent(new Event('focus'));
    }

    click(event){
        clearTimeout(this.blurTimeout);

        this.preventDefaultStopProp(event);

        this.dispatchEvent(new Event('click'));
        this.toggleMenu();
    }

    disableKeyboardMode(){
        this.keyboardMode = false;
    }

    navigate(event){
        this.keyboardMode = true;

        let picklistOptions = this.template.querySelectorAll('c-picklist-option');
        let focusIndex = this.focusIndex;

        if(focusIndex < 0){
            this.focusIndex = picklistOptions.length - 1;
        } else if(focusIndex === picklistOptions.length){
            this.focusIndex = 0;
        }
        focusIndex = this.focusIndex;
        let selected = picklistOptions.forEach((option, index) => {
            if(index === focusIndex){
                option.addFocus();
                option.scrollIntoViewIfNeeded();
            } else{
                option.removeFocus();
            }
        })
    }

    updateFocusIndex(event){
        if(!this.keyboardMode){
            let focusedValue = event.detail;
            let picklistOptions = this.template.querySelectorAll('c-picklist-option');
            picklistOptions.forEach((option, index) => {
                if(option.getValue() === focusedValue){
                    this.focusIndex = index;
                    option.addFocus();
                } else{
                    option.removeFocus();
                }
            })
        }
    }

    preventDefaultStopProp(event){
        event.preventDefault();
        event.stopPropagation();
    }

    toggleMenu(){
        clearTimeout(this.blurTimeout);

        if(!this.showMenu){
            this.showMenu = true;

            setTimeout(() => {
                //focus and add slds-has-focus to correct option
                let picklistOptions = this.template.querySelectorAll('c-picklist-option');
                picklistOptions.forEach((option, index) => {
                    if(option.getValue() === this.value){
                        this.focusIndex = index;
                        option.addFocus();
                        option.scrollIntoViewIfNeeded();
                    } else{
                        option.removeFocus();
                    }
                });

                this.repositionDropdown();

                window.addEventListener('scroll', this.repositionDropdown, true);
                window.addEventListener('resize', this.repositionDropdown, true);

                setTimeout(() => {
                    this.template.querySelector('.sp-input').focus();
                }, 50);
            }, 10);
        } else{
            this.hideMenu();
        }
    }

    hideMenu(){
        this.showMenu = false;
        this.template.querySelector('.sp-input').value = '';
        this.focusIndex = -1;
        this.searchTerm = '';
        this.dropdownStyles = '';

        window.removeEventListener('scroll', this.repositionDropdown, true);
        window.removeEventListener('resize', this.repositionDropdown, true);
    }

    blur(event){
        this.preventDefaultStopProp(event);
        this.blurTimeout = setTimeout(() => this.hideMenu(), 100);
    }

    clearBlurTimeout(){
        clearTimeout(this.blurTimeout);
    }

    get hasResults(){
        return this.showMenu ? this.filteredOptions.length > 0 : false;
    }

    get filteredOptions(){
        let searchTerm = this.searchTerm || this.searchTerm === 0 ? this.searchTerm.toString().toLowerCase() : '';
        let searchBy = this.searchBy;
        let filteredOptions = [];
        if(this.options && this.options.length > 0 && searchTerm){
            filteredOptions = JSON.parse(JSON.stringify(this.options)).filter(option => {
                if(option.isOptGroup){
                    let groupOptions = option.options.filter(groupOption => {
                        let label = groupOption.label.toString();
                        let value = groupOption.value.toString();
                        let labelIncludes = label && label.toLowerCase().includes(searchTerm);
                        let valueIncludes = value && value.toLowerCase().includes(searchTerm);
                        return searchBy === 'label' ? labelIncludes : (searchBy === 'both' ? (labelIncludes || valueIncludes) : valueIncludes);
                    })
                    option.options = groupOptions;
                    return groupOptions.length > 0;
                } else{
                    let label = option.label.toString();
                    let value = option.value.toString();
                    let labelIncludes = label && label.toLowerCase().includes(searchTerm);
                    let valueIncludes = value && value.toLowerCase().includes(searchTerm);
                    return searchBy === 'label' ? labelIncludes : (searchBy === 'both' ? (labelIncludes || valueIncludes) : valueIncludes);
                }
            })
        } else{
            filteredOptions = this.options;
        }
        return filteredOptions;
    }

    get labelHidden(){
        return this.variant === 'label-hidden';
    }

    get outerClassList(){
        return 'slds-form-element' +
               (!this.validity ? ' slds-has-error ' : '') + (this.class ? ' ' + this.class : '');
    }

    get picklistClassList(){
        return 'slds-picklist slds-dropdown-trigger slds-dropdown-trigger_click' +
               (this.showMenu ? ' slds-is-open' : '') + (this.disabled ? ' sp-disabled' : (this.readonly ? ' sp-readonly' : ''));
    }

    get dropdownClassList(){
        return 'slds-listbox slds-listbox_vertical slds-dropdown' + (this.showMenu ? '' : ' slds-hidden');
    }

    get inputClassList(){
        return 'sp-picklist__input slds-col slds-p-horizontal_xx-small' +
               (this.searchable ? '' : ' slds-hide');
    }

    get dropdownMenuStyles(){
        return '-webkit-overflow-scrolling: touch; overflow-y: auto;' +
               (this.dropdownHeight == 0 ? '' : 'max-height: calc(((0.8125rem * 1.5) + 1rem) * ' + this.dropdownHeight + ')');
    }

    get showDropdownIcon(){
        return !this.readonly || (this.disabled && this.readonly);
    }
}