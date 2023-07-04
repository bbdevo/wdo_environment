import { LightningElement, api, track } from 'lwc';
import getRelatedMessages from '@salesforce/apex/messageViewer.getRelatedMessages';
import SLACK_ICON from "@salesforce/resourceUrl/slackIcon";
import EMPTY_STATE from "@salesforce/resourceUrl/slack_componentEmptyState";

export default class MessageViewer extends LightningElement {
    @api isClassic
    @api recordId;

    @track loading = true;
    @track messages;
    @track isLoadingMore = false;
    @track allLoaded = false;
    @track empty = true;
    @track recordsToReturn = 5;
    
    recordsToReturnAdder = 5;
    slackIcon = SLACK_ICON;
    emptyStateUrl = EMPTY_STATE;

    connectedCallback() {
        this.getRelatedMessages();
    }

    getRelatedMessages() {
        getRelatedMessages({ recordId: this.recordId, limitBy: this.recordsToReturn }).then(data => {
            this.messages = data.results.messages;
            this.allLoaded = data.results.allLoaded;
            this.empty = data.results.empty;
            this.isLoadingMore = false;
            this.loading = false;
        })
    }

    listScroll(event) {
        if (!this.allLoaded) {
            let msgContainer = event.currentTarget;
            let threshold = 30;
            if (msgContainer.scrollTop >= (msgContainer.scrollHeight - (msgContainer.getBoundingClientRect().height + threshold))) {
                clearTimeout(window.messageLoadTimeout);
                this.isLoadingMore = true;
                window.messageLoadTimeout = setTimeout(() => {
                    this.loadMore();
                }, 250);
            }
        }
    }

    loadMore() {
        this.recordsToReturn += this.recordsToReturnAdder;
        this.getRelatedMessages();
    }

    get viewerClassList() {
        return 'slds-card' + (this.isClassic ? ' slack-is-classic' : '');
    }

}