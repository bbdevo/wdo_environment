import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import callGetAuthData from '@salesforce/apex/sendToSlack.getAuthData';
import callGetRecentChannels from '@salesforce/apex/sendToSlack.getRecentChannels';
import callGetSubscriptions from '@salesforce/apex/slackAlerts.getSubscriptions';
import callGetExistingChannelNames from '@salesforce/apex/slackAlerts.getExistingChannelNames';
import callSendSubscriptionPayload from '@salesforce/apex/slackAlerts.sendSubscriptionPayload';
import callUpdateMostRecentWorkspace from '@salesforce/apex/sendToSlack.updateMostRecentWorkspace';
import callCreateRecentChannel from '@salesforce/apex/sendToSlack.createRecentChannel';
import callDeleteAuth from '@salesforce/apex/slackAlerts.deleteAuth';

export default class SlackAlerts extends LightningElement {
    @api isClassic;
    @api recordId;
    @api objectApiName;

    @track loading = true;
    @track selectedRecordId;
    @track newAuth = false;
    @track isUserAuthed;
    @track workspaceList;
    @track selectedSlackAuthId;
    @track channelList = [];
    @track selectedChannelId = '';
    @track selectedChannelName;
    @track subscriptions;
    @track existingChannelNames;
    @track selectedOptions = [];
    @track unselectedOptions = [];
    @track hasError;
    @track errMsg;
    @track toastTitle;
    @track toastMessage;
    @track toastVariant;
    @track toastMode;
    @track isSending = false;
    @track isExpired = false;

    promises = [];
    selectedChannelType;
    channelTypes = 'channel';
    authErrorMessage = 'Invalid Auth';

    get channelSelectDisabled() {
        return this.selectedSlackAuthId || this.selectedSlackAuthId !== '' ? false : true;
    }

    get isDisabled() {
        return this.selectedChannelId ? false : true;
    }

    get isCaseObject() {
        return this._objectApiName === 'Case';
    }

    get modalLayout() {
        return this.isClassic || this.objectApiName !== 'Case';
    }

    get existingChannelList() {
        let channelList = '';
        if (this.existingChannelNames) {
            channelList = this.existingChannelNames.join(', ');
        }

        return channelList;
    }

    get saveDisabled() {
        return !this.selectedChannelId ? true : false;
    }

    get authedClass() {
        return 'slack-picker_authed slds-grid slds-grid_vertical' + (!this.isUserAuthed || this.newAuth ? ' slds-hide' : '');
    }

    get notAuthedClass() {
        return 'slack-picker_not-authed slds-grid slds-grid_vertical' + (!this.isUserAuthed || this.newAuth ? ' slds-grid_align-center' : '');
    }

    get pickerClassList() {
        let classList = 'slack-picker_quick-action slds-is-relative';

        if (this.objectApiName === 'Case') {
            classList += ' slack-picker_case';
        }

        if (this.isClassic) {
            classList += ' slack-is-classic';
        }

        return classList;
    }

    connectedCallback() {
        this.selectedRecordId = this.recordId;
        this.getAuthData().then(() => {
            if (this.isUserAuthed){
                this.promises.push(this.getRecentChannels());
                this.promises.push(this.getSubscriptions());
                this.promises.push(this.getExistingChannelNames());
                Promise.all(this.promises).then(() => {
                    this.promises = [];
                    this.loading = false;
                });
            } else {
                this.loading = false;
            }
        });
    }

    getAuthData() {
        return callGetAuthData().then(data => {
            if (data.isSuccess) {
                this.isUserAuthed = data.results.isUserAuthed;
                if (this.isExpired === false) {
                    this.selectedSlackAuthId = this.selectedSlackAuthId ? this.selectedSlackAuthId : data.results.mostRecentWorkspaceId;
                }
                this.workspaceList = data.results.workspaceList;
                if (this.workspaceList.length > 1 && this.isExpired === true && this.selectedSlackAuthId !== '') {
                    this.isExpired = false;
                }
            } else {
                if (this.authErrorMessage === data.error) {
                    this.isExpired = true;
                    this.deleteAuth().then(() => {
                        this.getAuthData();
                    });
                    this.selectedSlackAuthId = '';
                } else {
                    this.hasError = true;
                    this.errMsg = data.error;
                }
            }
        });
    }

    getRecentChannels() {
        return callGetRecentChannels({ slackAuthId: this.selectedSlackAuthId, types: this.channelTypes }).then(data => {
            if (data.isSuccess) {
                this.channelList = data.results.recentChannels;
                if (this.workspaceList.length > 1 && this.isExpired === true && this.selectedSlackAuthId !== '') {
                    this.isExpired = false;
                }
            } else {
                if (this.authErrorMessage === data.error) {
                    this.isExpired = true;
                    this.deleteAuth().then(() => {
                        this.getAuthData();
                    });
                    this.selectedSlackAuthId = '';
                } else {
                    this.hasError = true;
                    this.errMsg = data.error;
                }
            }
        })
    }

    getSubscriptions() {
        return callGetSubscriptions({ objectApiName: this.objectApiName, recordId: this.recordId, channelId: this.selectedChannelId }).then(data => {
            if (data.isSuccess) {
                this.subscriptions = data.results.subscriptions;
                this.selectedOptions = this.subscriptions.filter(item => item.checked === true);
                this.unselectedOptions = this.subscriptions.filter(item => item.checked === false);
            } else {
                this.hasError = true;
                this.errMsg = data.error
            }
        });
    }

    getExistingChannelNames() {
        return callGetExistingChannelNames({ recordId: this.recordId, authId: this.selectedSlackAuthId }).then(data => {
            if (data.isSuccess) {
                this.existingChannelNames = data.results.existingChannelNames;
            } else {
                this.hasError = true;
                this.errMsg = data.error
            }
        })
    }

    authed() {
        this.loading = true;
        this.getAuthData().then(() => {
            if (this.isUserAuthed){
                this.promises.push(this.getRecentChannels());
                this.promises.push(this.getSubscriptions());
                this.promises.push(this.getExistingChannelNames());
                Promise.all(this.promises).then(() => {
                    this.promises = [];
                    this.loading = false;
                });
            } else {
                this.loading = false;
            }
        });
        this.newAuth = false;
        this.isExpired = false;
    }

    goBack() {
        this.newAuth = false;
    }

    workspaceSelect(event) {
        let newWorkspaceId = event.detail.value;
        if (newWorkspaceId === 'Add Workspace') {
            this.newAuth = true;
            this.selectedSlackAuthId = '';
            this.channelList = [];
            this.selectedChannelId = null;
            this.selectedChannelName = null;
            this.existingChannelNames = null;
            this.getSubscriptions();
        } else {
            this.selectedChannelName = this.selectedSlackAuthId !== newWorkspaceId ? '' : this.selectedChannelName;
            this.selectedChannelId = this.selectedSlackAuthId !== newWorkspaceId ? '' : this.selectedChannelId;
            this.selectedSlackAuthId = newWorkspaceId;
            this.getSubscriptions();
            this.getRecentChannels();
            this.getExistingChannelNames();
        }

        this.template.querySelector('.js-channel-picklist').value = ''
    }

    channelSelect(event) {
        var valueParts = event.detail.value.split('|');
        this.selectedChannelName = event.detail.label;
        this.selectedChannelId = valueParts[0];
        this.selectedChannelType = valueParts[1];
        this.getSubscriptions();
    }

    toggleChange(event) {
        if (event.detail.checked) {
            if (this.selectedOptions.indexOf(event.detail.value) === -1) {
                this.selectedOptions.push(event.detail.value);
            }
            this.unselectedOptions = this.unselectedOptions.filter(item => item.label !== event.detail.value.label);
        } else {
            if (!this.unselectedOptions.indexOf(event.detail.value) > -1) {
                this.unselectedOptions.push(event.detail.value);
            }
            this.selectedOptions = this.selectedOptions.filter(item => item.label !== event.detail.value.label);
        }
    }

    channelFocus() {
        this.getRecentChannels();
    }

    createRecentChannel() {
        return callCreateRecentChannel({
            name: this.selectedChannelName,
            slackAuthId: this.selectedSlackAuthId,
            channelId: this.selectedChannelId,
            type: this.selectedChannelType
        });
    }

    updateMostRecentWorkspace(slackAuthId) {
        return callUpdateMostRecentWorkspace({ slackAuthId: slackAuthId });
    }

    deleteAuth() {
        return callDeleteAuth({ authId: this.selectedSlackAuthId });
    }

    send() {
        this.isSending = true;
        this.createRecentChannel().then(createChannelResult => {
            if (createChannelResult && this.objectApiName === 'Case') {
                this.getRecentChannels();
            }
        });
        this.updateMostRecentWorkspace(this.selectedSlackAuthId).then(updateMostRecentChannelResult => {
            if (updateMostRecentChannelResult && this.objectApiName === 'Case') {
                this.getAuthData();
            }
        });
        this.sendPayload().then(sendPayloadResult => {
            if (sendPayloadResult.isSuccess) {
                this.sendEvent();

                if (this.isClassic) {
                    let toast = this.template.querySelector('.slack-toast__classic .slds-notify_container');
                    toast.classList.add('show');

                    this.sendEvent();
                } else {
                    this.isSending = false;
                    this.toastVariant = 'success';
                    this.showToast();
                    this.sendEvent();
                }
                if (this.objectApiName === 'Case') {
                    this.getExistingChannelNames();
                    this.getSubscriptions();
                }
            } else {
                this.toastVariant = 'error';
                this.sendEvent();
                this.showToast();
                this.isSending = false;
            }
        });
    }

    cancel() {
        this.cancelEvent();
    }

    sendEvent() {
        const sendEvent = new CustomEvent('send');
        this.dispatchEvent(sendEvent);
    }

    cancelEvent() {
        const cancelEvent = new CustomEvent('cancel');
        this.dispatchEvent(cancelEvent);
    }

    sendPayload() {
        return callSendSubscriptionPayload({
            selectedOptionsJson: JSON.stringify(this.selectedOptions),
            unselectedOptionsJson: JSON.stringify(this.unselectedOptions),
            channelId: this.selectedChannelId,
            channelName: this.selectedChannelName,
            recordId: this.recordId,
            authId: this.selectedSlackAuthId
        });
    }

    showToast() {
        if (this.toastVariant === 'success') {
            this.toastTitle = 'Slack alert preferences were successfully saved';
            this.toastMessage = '';
            this.toastMode = 'dismissable'
        } else if (this.toastVariant === 'error') {
            this.toastTitle = 'There was a problem saving your Slack alert preferences';
            this.toastMessage = 'Please try again later or contact your Salesforce Administrator if the problem continues';
            this.toastMode = 'dismissable'
        }

        const toast = new ShowToastEvent({
            title: this.toastTitle,
            message: this.toastMessage,
            variant: this.toastVariant,
            mode: this.toastMode
        });

        this.dispatchEvent(toast);
    }

}