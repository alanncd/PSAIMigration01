import { LightningElement, api, wire, track} from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import saveCustomSetting from '@salesforce/apex/ConfigurationController.saveCustomSetting';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCustomSettingValues from '@salesforce/apex/ConfigurationController.getCustomSettingValues';

export default class AddressFieldMatcher extends LightningElement {
    @api objectApiName;  // Object name passed from the parent component (either Lead or Opportunity)
    loading = true;
    // Field values for the combobox selections
    streetFieldValue;
    cityFieldValue;
    stateFieldValue;
    zipFieldValue;

    zipFieldLabel;
    streetFieldLabel;
    cityFieldLabel;
    stateFieldLabel;

    // options for fields 
    addressFields = [];
    
    alreadyFetched = false;
   
    getDynamicComboboxValue(combo) {
        return this.template.querySelector(`c-dynamic-combo-box[data-id=${combo}]`).getSelectedValue();
    }

    fetchCustomSettingValues() {
        getCustomSettingValues()
            .then(settings => {
                if (this.objectApiName === 'Lead') {
                    this.streetFieldValue = settings.Lead_Address_Street;
                    this.cityFieldValue = settings.Lead_Address_City;
                    this.stateFieldValue = settings.Lead_Address_State;
                    this.zipFieldValue = settings.Lead_Address_PostalCode;
                } else if (this.objectApiName === 'Opportunity') {
                    this.streetFieldValue = settings.Opportunity_Address_Street;
                    this.cityFieldValue = settings.Opportunity_Address_City;
                    this.stateFieldValue = settings.Opportunity_Address_State;
                    this.zipFieldValue = settings.Opportunity_Address_PostalCode;
                }
                this.streetFieldLabel = this.getLabelForValue(this.streetFieldValue);
                this.cityFieldLabel = this.getLabelForValue(this.cityFieldValue);
                this.stateFieldLabel = this.getLabelForValue(this.stateFieldValue);
                this.zipFieldLabel = this.getLabelForValue(this.zipFieldValue); 
                this.loading = false;
                this.alreadyFetched = true;
            })
            .catch(error => {
                console.error('Error fetching custom settings:', JSON.stringify(error));
                if (error.body) {
                    console.error('Error body:', JSON.stringify(error.body.message));
                }
            });
    }

    // Using wire to get object info dynamically based on the passed objectApiName
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfo({ data, error }) {
        if (data) {
            this.populateAddressFields(data.fields);
            if (!this.alreadyFetched) {
                this.fetchCustomSettingValues();
            }
        }
        if (error) {
            console.error('Error loading object info', error);
        }
    }

    /**
     * Populates the address fields for the combobox options
     * @param {Object} fields - Fields metadata for the object (Lead or Opportunity)
     */
    populateAddressFields(fields) {
        // Map all the fields into options for the combobox
        this.addressFields = Object.keys(fields).map(fieldName => {
            return {
                label: fields[fieldName].apiName,   // Field Label for the combobox
                value: fields[fieldName].apiName  // API Name for the field
            };
        });   
    }  
    
    handleSave() {
        this.loading = true;  // Show a loading spinner
        this.streetFieldValue = this.getDynamicComboboxValue('street');
        this.stateFieldValue = this.getDynamicComboboxValue('state');
        this.zipFieldValue = this.getDynamicComboboxValue('postalCode');
        this.cityFieldValue = this.getDynamicComboboxValue('city');

        // Check if any field is empty
        if (!this.validateFields()) {
            return;
        }

        const streetKey = this.objectApiName + '_' + 'Address_Street__c';
        const cityKey = this.objectApiName + '_' + 'Address_City__c';
        const stateKey = this.objectApiName + '_' + 'Address_State__c';
        const postalCodeKey = this.objectApiName + '_' + 'Address_PostalCode__c';

        const settingsMap = {
            [streetKey] : this.streetFieldValue,
            [cityKey] : this.cityFieldValue,
            [stateKey] : this.stateFieldValue,
            [postalCodeKey] : this.zipFieldValue
        };
        // Call Apex to save the custom settings
        saveCustomSetting({
            objectApiName: this.objectApiName,
            settingsMap: settingsMap
        })
        .then(() => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Address fields saved successfully.',
                variant: 'success',
            }));
            this.dispatchEvent(new CustomEvent('save'));
        })
        .catch(error => {
            console.error('Error saving custom setting:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'An error occurred while saving. Please try again.',
                variant: 'error',
            }));
        }).finally(() => {
            this.loading = false;  
        });
    }

    validateFields() {
        if (!this.streetFieldValue || !this.cityFieldValue || !this.stateFieldValue || !this.zipFieldValue) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'All fields must be selected.',
                variant: 'error',
            }));
            this.loading = false;
            return false;
        }
        
        const fieldValues = [this.streetFieldValue, this.cityFieldValue, this.stateFieldValue, this.zipFieldValue];
        const validValues = this.addressFields.map(field => field.value);

        for (let value of fieldValues) {
            if (!validValues.includes(value)) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a value available in the drop-down list(s)' ,
                    variant: 'error',
                }));
                this.loading = false;
                return false;
            }
        }

        return true;
    }
    
    // Handle Cancel button click
    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    getLabelForValue(value) {
        if (value) {
            const normalizedValue = value.trim().toLowerCase();
            const field = this.addressFields.find(
              field => field.value.trim().toLowerCase() === normalizedValue
            );
            return field ? field.label : null;    
        }
        return null;
    }
}