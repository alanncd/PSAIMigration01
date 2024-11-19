import { LightningElement, track, wire, api } from "lwc";
import getFields from "@salesforce/apex/selectFieldCadence_ctr.getFields";
export default class selectFieldCadenceLwc extends LightningElement {
  @api strRecordId;
  @api strObject;
  @api templateMessage = "";
  @track
  value = "Lead";
  value2 = "-";
  @api richValue = "";
  prevRichValue = "";

  get options() {
    return [
      { label: "Lead", value: "Lead" },
      { label: "Opportunity", value: "Opportunity" },
      { label: "Account", value: "Account" },
      { label: "Contact", value: "Contact" },
      { label: "Interested Buyers", value: "Interested_Buyers__c" },
      { label: "Transactions", value: "Transactions__c" }
    ];
  }
  @wire(getFields, { myobject: "$strObject" }) selectTargetValues;

  handleChange(event) {
    this.value = event.detail.value;
  }
  handleChangeField(event) {
    this.value2 = "{!" + this.strObject + "." + event.target.value + "}";
  }
  handleClick(event) {
    this.richValue = this.richValue + this.value2;

    this.templateMessage = this.richValue;
    this.templateMessage = this.templateMessage.replace(/<[^>]+>/g, "");
  }
  handleChangeRich(event) {
    this.templateMessage = event.target.value.replace(/<[^>]+>/g, "");
    this.richValue = this.templateMessage;


  }
}