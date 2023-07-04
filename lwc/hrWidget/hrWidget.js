/**
 * @description       :
 * @author            : shawn.butters
 * @group             :
 * @last modified on  : 07-16-2021
 * @last modified by  : shawn.butters
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   07-12-2021   shawn.butters   Initial Version
**/
import { LightningElement, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';


export default class HrWidget extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference) currPage;

    isModalOpen = false;

    entitledY2D = 10;
    takenY2D = 1;

    entitledLY = 2;
    takenLY = 1;
    expiredLY = 1;

    entitledSpecial = 1;
    takenSpecial = 0;

    //nextVacationDate = '09-23-2021';
    nextVacationDuratuion = '4 Days';

    //payrollNextCycle = '05-25-2021';
    payrollOpenExpensesAmount = '354.22';
    //payrollOpenExpensesDueDate = '2021/04/16';

    showDetails = false;

    toggleShowDetails(event) {
        this.showDetails = !this.showDetails;
    }

    get nextVacationDate() {
        let thisDay = new Date();
        thisDay = thisDay.setMonth(thisDay.getMonth()+1);
        return new Date(thisDay).toLocaleDateString("en");
    }

    get payrollNextCycle() {
        let thisDay = new Date();
        thisDay = thisDay.setDate(thisDay.getDate()+1);
        return new Date(thisDay).toLocaleDateString("en");
    }

    get payrollOpenExpensesDueDate() {
        let thisDay = new Date();
        thisDay = thisDay.setMonth(thisDay.getMonth()+2);
        return new Date(thisDay).toLocaleDateString("en");
    }

    get leftY2D(){
        return this.entitledY2D - this.takenY2D;
    }

    get entitledY2DTitle(){
        return 'Entitled : ' + this.entitledY2D;
    }

    get leftY2DTitle(){
        return 'Left : ' + this.leftY2D;
    }

    get takenY2DTitle(){
        return 'Taken : ' + this.takenY2D;
    }

    get toDateTitle(){
        return this.entitledY2DTitle  + ' | ' + this.takenY2DTitle + ' | ' + this.leftY2DTitle;
    }

    // ---- SPECIAL
    get leftSpecial(){
        return this.entitledSpecial - this.takenSpecial;
    }

    get entitledSpecialTitle(){
        return 'Entitled : ' + this.entitledSpecial;
    }

    get leftSpecialTitle(){
        return 'Left : ' + this.leftSpecial;
    }

    get takenSpecialTitle(){
        return 'Taken : ' + this.takenSpecial;
    }

    get specialTitle(){
        return this.entitledSpecialTitle  + ' | ' + this.takenSpecialTitle + ' | ' + this.leftSpecialTitle;
    }

    // ---- LY
    get leftLY(){
        return this.entitledLY - this.takenLY - this.expiredLY;
    }

    get entitledLYTitle(){
        return 'Entitled : ' + this.entitledLY;
    }

    get leftLYTitle(){
        return 'Left : ' + this.leftLY;
    }

    get expiredLYTitle(){
        return 'Expired : ' + this.expiredLY;
    }

    get takenLYTitle(){
        return 'Taken : ' + this.takenLY;
    }

    get lyTitle(){
        return this.entitledLYTitle  + ' | ' + this.takenLYTitle + ' | ' + this.expiredLYTitle + ' | ' + this.leftLYTitle;
    }

    // vacation
    get nextVacationDateTitle(){
        return  this.nextVacationDuratuion + ' from ' + this.nextVacationDate ;
    }

    // payroll

    get payrollOpenExpensesDueToTitle(){
        return 'Due to ' + this.payrollOpenExpensesDueDate;
    }

    get payrollOpenExpensesTitle(){
        return this.payrollOpenExpensesAmount +' € '+this.payrollOpenExpensesDueToTitle;
    }

    hdlShowDetails(event){
        const selectedItemValue = event.detail.value;
        if(selectedItemValue === 'hide'){
            this.toggleShowDetails();
        }else if(selectedItemValue === 'parentalLeave'){
            // const _showFlow = new CustomEvent('showflow');
            // this.dispatchEvent(_showFlow);
            this[NavigationMixin.GenerateUrl]({
                type: "standard__webPage",
                attributes: {
                    url: "article/Parental-Leave"
                }
            }).then((generatedUrl) => {
                console.log(generatedUrl);
                window.location.href = generatedUrl;
            });
        }else if(selectedItemValue === 'newTravelExpense'){
            this[NavigationMixin.Navigate]({
                type : 'standard__webPage',
                attributes : {
                    url: 'https://www.concursolutions.com/expense/client/default.asp'
                }
            });
        }
    }
}