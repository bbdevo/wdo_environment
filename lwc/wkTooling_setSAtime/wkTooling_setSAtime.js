import { LightningElement, track } from "lwc";
import updateTime from "@salesforce/apex/wkDemo_AppointTimeChange.updTime";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class WkTooling_setSAtime extends LightningElement {
  @track showSpinner = false;
  updTime() {
    this.showSpinner = true;
    console.log("in upd");
    updateTime()
      .then((result) => {
        this.showSpinner = false;
        const event = new ShowToastEvent({
          title: "Success",
          message: "Appointments updated"
        });
        this.dispatchEvent(event);
      })
      .catch((error) => {
        console.log(error);
      });
  }
}