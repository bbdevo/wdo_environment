import { LightningElement, track, api } from 'lwc';
import getAuthData from '@salesforce/apex/auth.getAuthData';
import SLACK_LOGO from '@salesforce/resourceUrl/slackLogo_horizontal';
import SLACK_BUTTON from '@salesforce/resourceUrl/slack_signInbutton';

export default class Auth extends LightningElement {

    /* VARIABLES */
    @api header;
    @api message;

    @track _newAuth;
    @track uri;
    @track messageKey;
    @track isComplete;

    processPostMessage;

    /* GETTERS WITH SETTERS */
    @api
    get newAuth() {
        return this._newAuth;
    }
    set newAuth(value) {
        this._newAuth = value === 'true' ? true : false;
    }

    /* HANDLERS */
    authClick() {
        let height = 500;
        let width = 500;
        let left = (screen.width / 2) - (width / 2);
        let top = (screen.height / 2) - (height / 2);

        // initiate oauth flow
        window.open(this.uri, null, 'height=' + height + ',width=' + width + ',left=' + left + ',top=' + top);
    }

    goBack() {
        this.backEvent();
    }

    /* CALLBACKS */
    connectedCallback() {
        getAuthData()
            .then(data => {
                // var clientId = data.results.slackClientId;
                var slackBaseUrl = data.results.slackBaseUrl;
                // var scope = encodeURIComponent('commands chat:write:bot links:read links:write bot users.profile:read');
                // var redirectUrl = encodeURIComponent(slackBaseUrl + '/auth/callback/slack');

                // var state = {
                //     isSandbox : data.results.isSandbox,
                //     origin : window.location.origin
                // }

                this.uri = slackBaseUrl + '/install?origin=' + encodeURIComponent(window.location.origin) + '&is_sandbox=' + data.results.isSandbox;
                //this.uri = 'https://slack.com/oauth/authorize?client_id=' + clientId + '&scope=' + scope + '&redirect_uri=' + redirectUrl + '&state=' + encodeURIComponent(JSON.stringify(state));
            });

        this.processPostMessage = (event) => {
            if ('https://dev.slack.com' === event.origin || 'https://slack.com' === event.origin) {
                this.authedEvent();
            }
        };

        window.addEventListener('message', this.processPostMessage);
    }

    disconnectedCallback() {
        window.removeEventListener('message', this.processPostMessage);
    }


    /* EVENT DISPATCHERS */
    authedEvent() {
        const authedEvent = new CustomEvent('authed');
        this.dispatchEvent(authedEvent);
    }

    backEvent() {
        const backEvent = new CustomEvent('back');
        this.dispatchEvent(backEvent);
    }


    /* TEMPLATE RESOURCES */
    slackLogoUrl = SLACK_LOGO;
    slackButton = SLACK_BUTTON;

}