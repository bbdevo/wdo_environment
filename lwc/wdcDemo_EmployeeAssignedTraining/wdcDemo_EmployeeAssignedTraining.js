/**
 * @description       :
 * @author            : shawn.butters
 * @group             :
 * @last modified on  : 01-31-2021
 * @last modified by  : shawn.butters
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   01-31-2021   shawn.butters   Initial Version
**/
import { LightningElement } from 'lwc';
import SVG_URL from '@salesforce/resourceUrl/assignedLearningSVG';

export default class WdcDemo_EmployeeAssignedTraining extends LightningElement {
    svgURL = `${SVG_URL}#assignedLearningSVG`;
}