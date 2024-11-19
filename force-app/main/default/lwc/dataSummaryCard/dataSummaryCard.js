import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";


export default class DataSummaryCard extends NavigationMixin(LightningElement) {
    @api propertySalesHistory; // Property_SalesAI_History__c record passed from parent

    get backgroundClasses() {
        return this.hasError ? "slds-scoped-notification red" 
        : "slds-scoped-notification grey";
    }

    get textClasses() {
        return this.hasError ? "white-text" : "";
    }

    get finishTime() {
        return this.propertySalesHistory ? this.propertySalesHistory.Finish_Time__c : '';
    }

    get hasError() {
        return this.propertySalesHistory && 
        this.propertySalesHistory.Status__c && 
        this.propertySalesHistory.Status__c.toLowerCase().includes('error');
    }

    get errorMessage() {
        let errors;
        if (this.propertySalesHistory.Lead_Errors__c) {
            errors = 'Errors Occurred on Lead';
        }
        if (this.propertySalesHistory.Opportunity_Errors__c) {
            errors += ' and Opportunity';
        }
        errors += ' Matching'
        return errors;
    }

    get iconName() {
        console.log(this.hasError);
        return this.hasError ? "utility:error" : "utility:info";
    }

    get iconVariant() {
        return this.hasError ? "inverse" : "";
    }
    
    get buttonVariant() {
        return this.hasError ? "destructive" : "base";
    }

    handleSeeDetails() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.propertySalesHistory.Id, 
                objectApiName: this.propertySalesHistory.sObjectAPIName, 
                actionName: 'view'
            }
        });
    }
}