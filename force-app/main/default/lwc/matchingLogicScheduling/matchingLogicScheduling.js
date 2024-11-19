import { LightningElement } from 'lwc';
import saveCustomSetting from '@salesforce/apex/ConfigurationController.saveCustomSetting';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCustomSettingValues from '@salesforce/apex/ConfigurationController.getCustomSettingValues';

export default class MatchingLogicScheduling extends LightningElement {
    // Default Values
    selectedDay;
    loading = true;
    selectedDateFilter = '-1';  

    autoUpdateStatus = 'false'; // Default to 'No'
    autoUpdateOptions = [
        { label: 'Yes', value: 'true' },
        { label: 'No', value: 'false' }
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

    connectedCallback() {
        this.getCustomSettings()
    }

    getCustomSettings() {
        getCustomSettingValues()
            .then(settings => {
                this.selectedDay = settings.Matching_Day ? settings.Matching_Day : 'Monday';
                this.selectedDateFilter = settings.Property_Sales_History_Duration ? settings.Property_Sales_History_Duration.toString() : '30';
                this.autoUpdateStatus = settings.AutomaticUpdate ? 'true' : 'false'; 
            })
            .catch(error => {
                console.error('Error fetching custom settings:', JSON.stringify(error));
            }).finally(() => {
                this.loading = false;
            });
    }

    // Time period options for the combobox
    get dayOfTheWeek() {
        return [
            { label: 'Monday', value: 'Monday' },
            { label: 'Tuesday', value: 'Tuesday' },
            { label: 'Wednesday', value: 'Wednesday' },
            { label: 'Thursday', value: 'Thursday' },
            { label: 'Friday', value: 'Friday' },
            { label: 'Saturday', value: 'Saturday' },
            { label: 'Sunday', value: 'Sunday' }
        ];

    }

    handleDayChange(event) {
        this.selectedDay = event.detail.value;
    }

    handleAutoUpdateChange(event) {
        this.autoUpdateStatus = event.detail.value; 
    }


    // Handle Save button click
    handleSave() {
        this.loading = true;  // Show a loading spinner

        // Check if any field is empty
        if (!this.selectedDay || !this.selectedDateFilter) {
            this.loading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please fill in all fields.',
                variant: 'error',
            }));
            return;
        }

        // Prepare the settingsMap
        const settingsMap = {
            'Matching_Day__c': this.selectedDay,
            'Property_Sales_History_Duration__c' : this.selectedDateFilter,
            'AutomaticUpdate__c': this.autoUpdateStatus
        };

        // Call Apex to save the custom settings
        saveCustomSetting({
            settingsMap: settingsMap
        })
        .then(() => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Settings saved successfully.',
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

    handleDateFilterChange(event) {
        this.selectedDateFilter = event.target.value;
    }

    // Handle Cancel button click
    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }
}