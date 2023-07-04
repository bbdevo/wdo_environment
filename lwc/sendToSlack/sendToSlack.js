import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import callGetObjectData from '@salesforce/apex/sendToSlack.getObjectData';
import callGetNameField from '@salesforce/apex/sendToSlack.getPrimaryObjectNameField';
import callGetRecordData from '@salesforce/apex/sendToSlack.getRecordData';
import callGetAuthData from '@salesforce/apex/sendToSlack.getAuthData';
import callGetRecentChannels from '@salesforce/apex/sendToSlack.getRecentChannels';
import callGetRecentlyViewed from '@salesforce/apex/sendToSlack.getRecentlyViewed';
import callSearchRecords from '@salesforce/apex/sendToSlack.searchRecords';
import callSendMessage from '@salesforce/apex/sendToSlack.sendMessage';
import callUpdateMostRecentWorkspace from '@salesforce/apex/sendToSlack.updateMostRecentWorkspace';
import callCreateRecentChannel from '@salesforce/apex/sendToSlack.createRecentChannel';
import callDeleteAuth from '@salesforce/apex/sendToSlack.deleteAuth';

export default class SendToSlack extends LightningElement {

    @api isGlobalAction;
    @api isClassic;
    @api recordId;
    @api objectApiName;

    @track loading = true;
    @track objectSelectOptions = [];
    @track selectedObjectName;
    @track selectedObjectNameField;
    @track selectedRecordId;
    @track selectedRecordData;
    @track recentlyViewed = [];
    @track _recordSearchResults;
    @track isUserAuthed;
    @track newAuth = false;
    @track workspaceList = [];
    @track selectedSlackAuthId;
    @track channelList = [];
    @track selectedChannelName;
    @track selectedChannelId;
    @track hasError;
    @track errMsg;
    @track toastTitle;
    @track toastMessage;
    @track toastVariant;
    @track toastMode;
    @track isExpired = false;
    @track isSending = false;

    promises = [];
    selectedChannelType;
    wiredAuthDataResults;
    wiredRecentChannelsResults;
    authErrorMessage = 'Invalid Auth';
    channelTypes = 'channel,user,mpim';

    get recordSearchResults() {
        return this._recordSearchResults ? this._recordSearchResults : this.selectedRecordData;
    }
    set recordSearchResults(value) {
        this._recordSearchResults = value;
    }

    get recordSearchIconName() {
        return this.selectedObjectName ? 'standard:' + this.selectedObjectName.toLowerCase() : '';
    }

    get recordSearchDisabled() {
        return this.selectedObjectName ? '' : 'disabled';
    }

    get channelSelectDisabled() {
        return this.selectedSlackAuthId || this.selectedSlackAuthId !== '' ? false : true;
    }

    get submitButtonDisabled() {
        return this.selectedObjectName && this.selectedRecordId && this.selectedSlackAuthId && this.selectedChannelId ? false : true;
    }

    get isCaseObject() {
        return this.objectApiName === 'Case';
    }

    get modalLayout() {
        return this.isClassic || this.objectApiName !== 'Case';
    }

    get authedClass() {
        return 'slack-composer_authed slds-grid slds-grid_vertical' + (!this.isUserAuthed || this.newAuth ? ' slds-hide' : '');
    }

    get notAuthedClass() {
        return 'slack-composer_not-authed slds-grid slds-grid_vertical' + (!this.isUserAuthed || this.newAuth ? ' slds-grid_align-center' : '');
    }

    get composerClassList() {
        let classList = 'slds-is-relative';
        if (this.isGlobalAction) {
            classList += ' slack-composer_global-action';
        } else {
            classList += ' slack-composer_quick-action';

            if (this.objectApiName === 'Case') {
                classList += ' slack-composer_case';
            }
        }
        if (this.isClassic) {
            classList += ' slack-is-classic';
        }
        return classList;
    }

    connectedCallback() {
        if (!this.isGlobalAction) {
            this.selectedRecordId = this.recordId;
            this.selectedObjectName = this.objectApiName;
        }
        this.getAllData();
    }

    getAllData() {
        this.getAuthData().then(() => {
            if (this.isUserAuthed) {
                this.promises.push(this.getObjectData());
                this.promises.push(this.getRecentChannels());
                if (!this.isGlobalAction) {
                    this.promises.push(this.getNameField());
                    this.promises.push(this.getRecordData());
                }
                Promise.all(this.promises).then(() =>{
                    this.promises = [];
                    this.loading = false;
                });
            } else {
                this.loading = false;
            }
        });
    }

    getObjectData() {
        return callGetObjectData({ isGlobal: this.isGlobalAction }).then(data => {
            this.objectSelectOptions = data.results.objects;
        });
    }

    getNameField() {
        return callGetNameField({ objectName: this.selectedObjectName }).then(data => {
            if (data.isSuccess) {
                this.selectedObjectNameField = data.results.nameField;
            } else {
                this.hasError = true;
                this.errMsg = data.error
            }
        });
    }

    getRecordData() {
        return callGetRecordData({ recordId: this.selectedRecordId, objectName: this.selectedObjectName }).then(data => {
            if (data.isSuccess) {
                let recordData = {
                    searchTerm: '',
                    searchMessage: '',
                    results: data.results.recordData
                }
                this.selectedRecordData = recordData;
            } else {
                this.hasError = true;
                this.errMsg = data.error
            }
        });
    }

    getAuthData() {
        return callGetAuthData().then(data => {
            if (data.isSuccess) {
                this.isUserAuthed = data.results.isUserAuthed;
                if (!this.isExpired) {
                    this.selectedSlackAuthId = this.selectedSlackAuthId ? this.selectedSlackAuthId : data.results.mostRecentWorkspaceId;
                }
                this.workspaceList = data.results.workspaceList;
                if (this.workspaceList.length > 1 && this.isExpired && this.selectedSlackAuthId !== '') {
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
        });
    }

    authed() {
        this.loading = true;
        this.getAllData ();
        this.newAuth = false;
        this.isExpired = false;
    }

    objectSelect(event) {
        this.deselectRecord(this.selectedObjectName ? false : true);
        this.selectedObjectName = event.detail.value;
        this.getNameField().then(() => {
            this.getRecentlyViewed(); 
        });
    }

    getRecentlyViewed() {
        callGetRecentlyViewed({ objectName: this.selectedObjectName }).then(result => {
            if (result.isSuccess) {
                let recentlyViewed = result.results.recentlyViewed;
                if (this.selectedObjectNameField !== 'Name') {
                    recentlyViewed.forEach(recentRecord => {
                        recentRecord[this.selectedObjectNameField] = recentRecord.Name;
                    });
                }
                this.recentlyViewed = recentlyViewed;
            } else {
                this.hasError = true;
                this.errMsg = result.error
            }
        });
    }

    searchRecords(event) {
        callSearchRecords({
            searchTerm: event.detail,
            objectName: this.selectedObjectName
        }).then(result => {
            if (result.isSuccess) {
                let results = {
                    searchTerm: event.detail,
                    searchMessage: 'Results for "' + event.detail + '" in ' + this.selectedObjectName,
                    results: result.results.results
                }
                this.recordSearchResults = results;
            } else {
                this.hasError = true;
                this.errMsg = result.error;
            }
        });
    }

    recordSelect(event) {
        this.selectedRecordId = event.detail;
    }

    recordUnselect() {
        this.selectedRecordId = '';
        this.getRecentlyViewed();
    }

    workspaceSelect(event) {
        let newWorkspaceId = event.detail.value;
        if (newWorkspaceId === 'Add Workspace') {
            this.newAuth = true;
            this.selectedSlackAuthId = '';
            this.channelList = [];
            this.selectedChannelId = null;
            this.selectedChannelName = null;
        } else {
            this.selectedChannelName = this.selectedSlackAuthId !== newWorkspaceId ? '' : this.selectedChannelName;
            this.selectedChannelId = this.selectedSlackAuthId !== newWorkspaceId ? '' : this.selectedChannelId;
            this.selectedSlackAuthId = newWorkspaceId;
            this.getRecentChannels();
        }

        this.template.querySelector('.js-channel-picklist').value = '';
    }

    channelFocus() {
        this.getRecentChannels();
    }

    channelSelect(event) {
        var valueParts = event.detail.value.split('|');
        this.selectedChannelName = event.detail.label;
        this.selectedChannelId = valueParts[0];
        this.selectedChannelType = valueParts[1];
    }

    invalidAuth(event) {
        this.hasError = true;
        this.errMsg = event.detail;
    }

    send() {
        this.isSending = true;
        let params = {
            message: this.template.querySelector('.js-message').value,
            channelId: this.selectedChannelId,
            channelType: this.selectedChannelType,
            slackAuthId: this.selectedSlackAuthId,
            recordId: this.selectedRecordId
        }

        callSendMessage(params).then(data => {
            if (data.isSuccess) {
                this.toastVariant = 'success';
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

                this.template.querySelector('.js-message').value = '';
            } else {
                this.isSending = false;
                this.toastVariant = 'error';
            }

            if (this.isClassic) {
                let toast = this.template.querySelector('.slack-toast__classic .slds-notify_container');
                toast.classList.add('show');

                setTimeout(() => {
                    this.sendEvent();
                }, 1500);
            } else {
                this.isSending = false;
                this.showToast();
                this.sendEvent();
            }
        }).catch(() => {
            this.isSending = false;
            this.toastVariant = 'error';
            this.sendEvent();
            this.showToast();
        });
    }

    cancel() {
        this.cancelEvent();
    }

    goBack() {
        this.newAuth = false;
    }

    deselectRecord(valid) {
        this.template.querySelector('c-lookup').unselect(valid);
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

    sendEvent() {
        const sendEvent = new CustomEvent('send');
        this.dispatchEvent(sendEvent);
    }

    cancelEvent() {
        const cancelEvent = new CustomEvent('cancel');
        this.dispatchEvent(cancelEvent);
    }

    showToast() {
        var selectedRecord = this.selectedRecordData.results[0];
        var name = selectedRecord[this.selectedObjectNameField];

        if (this.toastVariant === 'success') {
            this.toastTitle = name + ' was successfully sent to Slack.';
            this.toastMessage = '';
            this.toastMode = 'dismissable'
        } else if (this.toastVariant === 'error') {
            this.toastTitle = 'There was a problem sending the selected record to Slack';
            this.toastMessage = name + ' was not sent to Slack. Please try again later or contact your Salesforce Administrator if the problem continues.';
            this.toastMode = 'sticky'
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