import { LightningElement,api, wire } from 'lwc';
import Id from "@salesforce/user/Id";
import { RefreshEvent } from 'lightning/refresh';
import getRolesAndUsersDatas from '@salesforce/apex/avonniRelationshipGraph_Controller.setParameters';

const customGroupActions = [
    {
        label: 'See more',
        name: 'group-custom-action1',
        iconName: 'utility:preview'
    },
    {
        label: 'Delete',
        name: 'group-custom-action3',
        disabled: true
    }
];

const customItemActions = [
    {
        label: 'See more',
        name: 'see-more-item',
        iconName: 'utility:preview'
    }
];


export default class RelationshipGraphVertical extends LightningElement {

    /*actions = [
        {
            label: 'Add relationship',
            name: 'add-relationship',
            iconName: 'utility:add'
        },
        {
            label: 'Remove relationship',
            name: 'remove-relationship',
            disabled: true
        }
    ];*/

    groupActions = [
        {
            label: 'New',
            name: 'new-group'
        }
    ];
    
    //lwcUserId = Id;
    roleHierarchy;
    rLabel;
    rName;
    rAvatarSrc;
    rAvatarFallbackIconName;
    rHref;
    rItems = {};
    groups = [];
        

    hasRendered = false;
    displayGraph = false;

    connectedCallback() {
        //console.log('1. ' + this.lwcUserId);
        //this.RolesAndUsersDatas();
        //console.log('2. ' + this.lwcUserId);
        //this.RolesAndUsersDatas();
        console.log('3. ' + JSON.stringify(this.groups));
    }

    renderedCallback(){
        //console.log('renderedCallback');
        if(this.hasRendered === false){
            //this.setRolesAndUsersDatas();
            this.hasRendered = true;
        }
    }

    @wire(getRolesAndUsersDatas) 

    RolesAndUsersDatas({ error, data }) {
            if (data) {
                this.roleHierarchy = data;
                this.rLabel = this.roleHierarchy.label;
                this.rName = this.roleHierarchy.name;
                this.rAvatarSrc = this.roleHierarchy.avatarSrc;
                this.rAvatarFallbackIconName = this.roleHierarchy.avatarFallbackIconName;
                this.rHref = this.roleHierarchy.href;
                this.rItems = this.roleHierarchy.items;
                console.log(this.rLabel);
                console.log(this.rName);
                console.log(this.rAvatarSrc);
                console.log(this.rAvatarFallbackIconName);
                console.log(this.rItems.managerUserProfilePicture);
                console.log(JSON.stringify(this.rItems));

                this.setRolesAndUsersDatas();
            } else if (error) {
                this.error = error;
                console.log('error: ' + error);
                this.record = undefined;
            }
        }

   /* @wire
    getRolesAndUsersDatas()
    {
        getRolesAndUsersDatas({userId : this.lwcUserId}).then(response => {
        this.roleHierarchy = response;
        console.log('response: ' + JSON.stringify(this.roleHierarchy));
        console.log(JSON.stringify(this.roleHierarchy.label));
        this.rLabel = this.roleHierarchy.label;
        this.rName = this.roleHierarchy.name;
        this.rAvatarSrc = this.roleHierarchy.avatarSrc;
        this.rAvatarFallbackIconName = this.roleHierarchy.avatarFallbackIconName;
        this.rHref = this.roleHierarchy.href;
        this.rItems = this.roleHierarchy.items;
        console.log(this.rLabel);
        console.log(this.rName);
        console.log(this.rAvatarSrc);
        console.log(this.rAvatarFallbackIconName);
        console.log(this.rHref);
        console.log(JSON.stringify(this.rItems));
        console.log(this.rItems.managerUser.Name);
        this.setRolesAndUsersDatas();

        }).catch(error => {
            console.log('ERROR!: ' + error.message);
        });
    }*/

    setRolesAndUsersDatas()
    {
        console.log('ITT');
        console.log(this.rLabel);
        console.log('subUsers' + JSON.stringify(this.rItems.subUsers));
        this.groups = [];

        console.log('subs: ' + Object.keys(this.rItems.subUsers).length);
        for (let i = 0; i < Object.keys(this.rItems.subUsers).length; i++) {
            console.log(i + '. ' + JSON.stringify(this.rItems.subUsers[i]));
            
        }
        /*console.log(this.rLabel);
        console.log(this.rName);
        console.log(this.rAvatarSrc);
        console.log(this.rAvatarFallbackIconName);
        console.log(this.rHref);*/
            this.groups = [
                {
                    // Group
                    label: 'Manager',
                    name: 'Manager',
                    avatarSrc:
                        'https://www.lightningdesignsystem.com/assets/images/avatar2.jpg',
                    avatarFallbackIconName: 'standard:account',
                    href: 'https://en.wikipedia.org/wiki/Manager_(disambiguation)',
                    // Items
                    items: [
                        {
                            label: this.rItems.managerUser.Name,
                            name: this.rItems.managerUser.Name,
                            avatarSrc:
                            this.rItems.managerUserProfilePicture,
                            avatarFallbackIconName: 'standard:user',
                            href: this.roleHierarchy.href,
                            data: [
                                {
                                    label: 'Role:',
                                    value: this.rItems.managerUserRoleName
                                },
                                {
                                    label: 'Tel:',
                                    value: '+36305945079'
                                }   
                            ],
                            groups: [
                                {
                                    label: 'Employee',
                                    name: 'Employee',
                                    avatarFallbackIconName: 'standard:account',
                
                                    href: 'https://simple.wikipedia.org/wiki/Employee',
                                    
                                    // Items
                                    items: [
                                        {
                                            label: this.rItems.currentUser.Name,
                                            name: this.rItems.currentUserRoleName,
                                            avatarFallbackIconName: 'custom:custom51',
                                            avatarSrc:
                                            this.rItems.currentUserProfilePicture,
                                            href: this.roleHierarchy.href,
                                            data: [
                                                {
                                                    label: 'Role:',
                                                    value: this.rItems.currentUserRoleName
                                                },
                                                {
                                                    label: 'Tel:',
                                                    value: '+36207854697'
                                                }
                                            ],
                                            groups: [
                                                {
                                                    label: 'Subordinate',
                                                    name: 'Subordinate',
                                                    avatarFallbackIconName: 'standard:account',
                                                    href: 'https://en.wikipedia.org/wiki/Subordination_(linguistics)',
                                                    items: [
                                                        {
                                                            label: this.rItems.subUsers[0].Name,
                                                            name: this.rItems.subUsers[0].Name,
                                                            avatarFallbackIconName: 'standard:campaign',
                                                            avatarSrc:
                                                            this.rItems.subUsersProfilePictures[0],
                                                            href: this.roleHierarchy.href,
                                                            data: [
                                                                {
                                                                    label: 'Role:',
                                                                    value: this.rItems.subUsersRoleNames[0]
                                                                },
                                                                {
                                                                    label: 'Tel:',
                                                                    value: '+36701234567'
                                                                }
                                                            ],
                                                            actions: customItemActions
                                                        },
                                                        {
                                                            label: this.rItems.subUsers[1].Name,
                                                            name: this.rItems.subUsers[1].Name,
                                                            avatarFallbackIconName: 'standard:campaign',
                                                            avatarSrc:
                                                            this.rItems.subUsersProfilePictures[1],
                                                            href: this.roleHierarchy.href,
                                                            data: [
                                                                {
                                                                    label: 'Role:',
                                                                    value: this.rItems.subUsersRoleNames[1]
                                                                },
                                                                {
                                                                    label: 'Tel:',
                                                                    value: '+36207654321'
                                                                }
                                                            ],
                                                            //actions: customItemActions,
                                                            //hideDefaultActions: true,
                                                            // Groups
                                                        }
                                                    ],
                                                    hideDefaultActions: false,
                                                    //actions: customGroupActions
                                                }
                                            ]
                                        }
                                    ],
                                    hideDefaultActions: false,
                                    //actions: customGroupActions
                                },
                            ]
                        }
                    ]
                },
            ];
            console.log('this.groups: ' + JSON.stringify(this.groups));
            this.displayGraph = true;   
    }   
}