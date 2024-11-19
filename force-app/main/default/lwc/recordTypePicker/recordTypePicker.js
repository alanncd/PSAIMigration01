import { LightningElement, api, track, wire } from 'lwc';
import getRecordTypes from '@salesforce/apex/ConfigurationController.getRecordTypes';
import getCustomSettingValues from '@salesforce/apex/ConfigurationController.getCustomSettingValues';
import saveCustomSetting from '@salesforce/apex/ConfigurationController.saveCustomSetting';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RecordTypePicker extends LightningElement {
    @api objectApiName;  
    recordTypes = [];  
    selectedRowIds = []; 
    selectedDateFilter = '30';  
    loading = true; 

    columns = [
        {
            label: 'Record Type Name',  
            fieldName: 'label',         
            type: 'text',               
            sortable: true              
        }
    ];

    dateFilterOptions = [
        { label: '7 Days', value: '7' },
        { label: '30 Days', value: '30' },
        { label: '60 Days', value: '60' },
        { label: '90 Days', value: '90' },
        { label: '180 Days', value: '180' },
        { label: '1 Year', value: '365' },
        { label: 'All time', value:  '-1' }
    ];

    get header() {
        return this.objectApiName === 'Lead' 
        ? 'Select Lead Record Types to be included in address matching for Property Sales.AI. You must include at least one record type:'
        : 'Select Opportunity Record Types to be included in address matching for Property Sales.AI. You must include at least one record type.'; 
    }

    get selectedRecordTypeIds() {
        return this.selectedRowIds;
    }

    get comboboxLabel() {
        return `Include ${this.objectApiName}s that were created or updated in the last`;
    }

    @wire(getRecordTypes, { objectApiName: '$objectApiName' })
    wiredRecordTypes({ error, data }) {
        if (data) {
            // Initialize the recordTypes list
            this.recordTypes = data.map(rt => ({
                label: rt.Name,
                value: rt.Id
            }));

            // Call the method to fetch custom settings and update selected rows
            this.getCustomSettings();
        } else if (error) {
            this.recordTypes = [];
            console.error('Error fetching record types:', error);
        }
    }

    // Fetch custom settings and mark rows as selected
    getCustomSettings() {
        getCustomSettingValues()
        .then(settings => {
            let selectedRecordTypeIds = [];
            let selectedDate;
            if (this.objectApiName === 'Lead') {
                selectedRecordTypeIds = settings.Lead_Record_Types
                    ? settings.Lead_Record_Types.split(',').map(id => id.trim())
                    : [];
                selectedDate = settings.Lead_History_Duration
                    ? settings.Lead_History_Duration.toString()
                    : '30'; 
    
            } else if (this.objectApiName === 'Opportunity') {
                selectedRecordTypeIds = settings.Opportunity_Record_Types
                    ? settings.Opportunity_Record_Types.split(',').map(id => id.trim())
                    : [];
                selectedDate = settings.Opportunity_History_Duration
                    ? settings.Opportunity_History_Duration.toString()
                    : '30'; 
            }
            this.selectedDateFilter = selectedDate
            this.selectedRowIds = selectedRecordTypeIds;
        })
        .catch(error => {
            console.error('Error fetching custom settings:', error);
        }).finally(() => {
            this.loading = false;
        });
    }    

    // Handle Save button click
    handleSave() {
        this.loading = true;  // Show a loading spinner

        const selectedRows = this.template.querySelector('lightning-datatable[data-id="recordTypeTable"]').getSelectedRows();
        const selectedDays = this.selectedDateFilter;

        if (!selectedRows || selectedRows.length === 0 || !selectedDays) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'You must select at least one record type.',
                variant: 'error',
            }));
            this.loading = false;
            return;
        }

        const recordTypesKey = this.objectApiName + '_' + 'Record_Types__c';
        const historyDurationKey = this.objectApiName + '_' + 'History_Duration__c';
        const selectedRowIds = selectedRows.map(row => row.value).join(',');

        const settingsMap = {
            [recordTypesKey] : selectedRowIds,
            [historyDurationKey] : selectedDays
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

    handleDateFilterChange(event) {
        this.selectedDateFilter = event.detail.value;
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }
}