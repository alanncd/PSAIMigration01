import { LightningElement, api, track, wire } from 'lwc';
import getStatuses from '@salesforce/apex/ConfigurationController.getStatuses';
import getCustomSettingValues from '@salesforce/apex/ConfigurationController.getCustomSettingValues';
import saveCustomSetting from '@salesforce/apex/ConfigurationController.saveCustomSetting';
import getPicklistValuesForField from '@salesforce/apex/ConfigurationController.getPicklistValuesForField'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class StatusPicker extends LightningElement {
    @api objectApiName;
    statuses = [];
    selectedRowIds = [];
    loading = true;
    filteredStatuses = [];

    // New properties for comboboxes and input field
    selectedStatus = '';
    selectedField = '';
    reason = '';
    statusOptions = [];
    fieldOptions = [];
    selectedOption;
    picklistValues; //if selected option is a picklist field this are the options
    
    preventRaceCond = false; // New property to track readiness

    get header() {
        return this.objectApiName === 'Lead' 
            ? 'Select Lead Statuses to be included in address matching for Property Sales AI. You must include at least one status.'
            : 'Select Opportunity Stages to be included in address matching for Property Sales AI. You must include at least one stage.'; 
    }
    // Getter for selected rows in the datatable
    get selectedStatusIds() {
        return this.selectedRowIds;
    }

    get statusLabel() {
        return this.objectApiName === 'Lead' 
            ? 'When a match is found, update the Lead Status to:' 
            : 'When a match is found, update the Opportunity Stage to:';
    }

    get fieldLabel() {
        return this.objectApiName === 'Lead' 
            ? 'Select the Lead Reason field' 
            : 'Select the Opportunity Reason field';
    }

    get reasonLabel() {
        return this.objectApiName === 'Lead' 
            ? 'Input Lead Reason field value when a match is found' 
            : 'Input Opportunity Reason field value when a match is found';
    }

    getDynamicComboboxValue() {
        return this.template.querySelector('c-dynamic-combo-box[data-id="reasonField"]').getSelectedValue();
    }

    // Getter to define columns dynamically based on objectApiName
    get columns() {
        if (this.objectApiName === 'Lead') {
            return [
                { label: 'Lead Status', fieldName: 'label', type: 'text' }
            ];
        } else if (this.objectApiName === 'Opportunity') {
            return [
                { label: 'Stage', fieldName: 'label', type: 'text' }
            ];
        }
        return [];
    }

    // Wire to fetch statuses from Apex and set them in the datatable
    @wire(getStatuses, { objectApiName: '$objectApiName' })
    wiredStatuses({ error, data }) {
        if (data) {
            this.statuses = data.map(status => ({
                label: status.label,
                value: status.value
            }));
            if (this.preventRaceCond) {
                this.getCustomSettings();
            } else {
                this.preventRaceCond = true;
            }
        } else if (error) {
            this.statuses = [];
            console.error('Error fetching statuses:', JSON.stringify(error));
        }
    }

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfo({ data, error }) {
        if (data) {
            this.populateFieldOptions(data.fields);
            if (this.preventRaceCond) {
                this.getCustomSettings();
            } else {
                this.preventRaceCond = true;
            }
        }
        if (error) {
            console.error('Error loading object info', error);
        }
    }    

    get isPicklist() {
        return this.selectedOption && this.selectedOption.dataType === 'Picklist';
    }

    get isText() {
        return this.selectedOption && (this.selectedOption.dataType === 'String' ||  this.selectedOption.dataType === 'TextArea');
    }

    // Method to populate field options for the combobox
    populateFieldOptions(fields) {
        this.fieldOptions = Object.values(fields)
            .filter(field => field.dataType === 'Picklist' || field.dataType === 'String' || field.dataType === 'TextArea')
            .map(field => {
                return { label: field.apiName, value: field.apiName, dataType: field.dataType };
            });
    }
    
    // Fetch custom settings and mark rows as selected based on objectApiName
    getCustomSettings() {
        getCustomSettingValues()
            .then(settings => {
                if (this.objectApiName === 'Lead') {
                    let statusesConcat = settings.Lead_Statuses;
                    statusesConcat += settings.Lead_Statuses_2 ? settings.Lead_Statuses_2 : '';
                    const selectedStatusIds = statusesConcat
                        ? statusesConcat.split(',').map(id => id.trim())
                        : [];
                    this.selectedRowIds = selectedStatusIds;
                    this.selectedStatus = settings.Lead_Matched_Status;
                    this.selectedField = settings.Lead_Matched_Reason_Field;
                    this.selectedFieldLabel = this.getLabelForValueAndPopulateOption(this.selectedField);
                    this.reason = settings.Lead_Matched_Reason;
                } else if (this.objectApiName === 'Opportunity') {
                    let stagesConcat = settings.Opportunity_Stages;
                    stagesConcat += settings.Opportunity_Stages_2 ? settings.Opportunity_Stages_2 : '';
                    const selectedStatusIds = stagesConcat
                        ? stagesConcat.split(',').map(id => id.trim())
                        : [];
                    this.selectedRowIds = selectedStatusIds;
                    this.selectedStatus = settings.Opportunity_Matched_Stage;
                    this.selectedField = settings.Opportunity_Matched_Reason_Field;
                    this.selectedFieldLabel = this.getLabelForValueAndPopulateOption(this.selectedField);
                    this.reason = settings.Opportunity_Matched_Reason;
                }
                this.refreshFilteredStatuses();
                this.loading = false;
            })
            .catch(error => {
                console.error('Error fetching custom settings:', JSON.stringify(error));
            });
    }

    handleRowSelection() {
        this.refreshFilteredStatuses();
    }

    getErrorMessage() {
        if (this.objectApiName === 'Lead') {
            return 'A lead status included in address matching cannot be selected for updating when a match is found.';
        } else {
            return 'An opportunity stage included in address matching cannot be selected for updating when a match is found.';
        }
    }

    refreshFilteredStatuses() {
        const statusTable = this.template.querySelector('lightning-datatable[data-id="statusTable"]');    
        const selectedRows = statusTable.getSelectedRows();
        const selectedRowsValues = selectedRows.map(row => row.value);
        this.filteredStatuses = this.statuses.filter(status => !selectedRowsValues.includes(status.value));
    
        if (selectedRowsValues.includes(this.selectedStatus)) {
            this.selectedStatus = '';
        }
    
        if (this.filteredStatuses.length === 0) {
            this.isError = true;
            this.comboboxError = this.getErrorMessage();
            this.comboboxClass = 'slds-has-error';
        } else {
            this.isError = false;
            this.comboboxError = '';
            this.comboboxClass = '';
        }
    }

    // Handle Save button click
    handleSave() {
        this.loading = true;  // Show a loading spinner
        const selectedRows = this.template.querySelector('lightning-datatable[data-id="statusTable"]').getSelectedRows();
        this.selectedField = this.getDynamicComboboxValue();

        if (!this.validateFields(selectedRows)) {
            return;
        }

        const fieldKey = this.objectApiName === 'Lead' ? 'Lead_Status__c' : 'Opportunity_Stage__c';
        const fieldKey2 = this.objectApiName === 'Lead' ? 'Lead_Status_2__c' : 'Opportunity_Stage_2__c';
        const reasonKey = this.objectApiName === 'Lead' ? 'Matched_Lead_Reason__c' : 'Matched_Opportunity_Reason__c';
        const reasonFieldKey = this.objectApiName === 'Lead' ? 'Matched_Lead_Reason_Field__c' : 'Matched_Opportunity_Reason_Field__c';
        const StageKey = this.objectApiName === 'Lead' ? 'Matched_Lead_Status__c' : 'Matched_Opportunity_Stage__c';
        const selectedRowIds = selectedRows.map(row => row.value).join(',');
        
        const maxFieldLength = 255;
        const selectedRowIds1 = selectedRowIds.length > maxFieldLength ? selectedRowIds.substring(0, maxFieldLength) : selectedRowIds;
        const selectedRowIds2 = selectedRowIds.length > maxFieldLength ? selectedRowIds.substring(maxFieldLength) : '';
        
        const settingsMap = {
            [fieldKey] : selectedRowIds1,
            [fieldKey2] : selectedRowIds2,
            [reasonKey] : this.reason,
            [reasonFieldKey] : this.selectedField,
            [StageKey] : this.selectedStatus
        };
        
        // Call Apex to save the custom settings
        saveCustomSetting({
            objectApiName: this.objectApiName,
            settingsMap: settingsMap
        })
        .then(() => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Record types and history duration saved successfully.',
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
        })
        .finally(() => {
            this.loading = false; 
        });     
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
    }

    handleReasonChange(event) {
        this.reason = event.target.value;
    } 

    handleSelectOption(event) {
        this.selectedField = event.detail.value;
        this.selectedFieldLabel = this.getLabelForValueAndPopulateOption(this.selectedField);
        this.reason = '';
    }

    getLabelForValueAndPopulateOption(value) {
        if (value) {
            this.loading = true;
            const normalizedValue = value.trim().toLowerCase();
            const field = this.fieldOptions.find(
                field => field.value.trim().toLowerCase() === normalizedValue
            );
            if (field) {
                this.selectedOption = field;
                if (field.dataType === 'Picklist') {
                    getPicklistValuesForField({ objectApiName: this.objectApiName, fieldApiName: value })
                        .then(result => {
                            this.picklistValues = result;
                        })
                        .catch(error => {
                            console.error('Error fetching picklist values:', error);
                        });
                }
                this.loading = false;
                return field.label;
            } else {
                this.loading = false;
                return null;
            }
        }
    }

    validateFields(selectedRows) {
        if (selectedRows.length === 0 || !this.selectedField || !this.reason || !this.selectedStatus) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'All fields must be populated.',
                variant: 'error',
            }));
            this.loading = false;
            return false;
        }
        const validValues = this.fieldOptions.map(field => field.value);
        if (!validValues.includes(this.selectedField)) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please select a value available in the reason field drop-down' ,
                variant: 'error',
            }));
            this.loading = false;
            return false;
        }
        return true
    }
}