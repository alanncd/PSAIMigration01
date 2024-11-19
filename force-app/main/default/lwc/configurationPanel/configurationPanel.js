import { LightningElement, api, wire, track} from 'lwc';
import getCustomSettingValues from '@salesforce/apex/ConfigurationController.getCustomSettingValues';
import updateIsSetupComplete from '@salesforce/apex/ConfigurationController.updateIsSetupComplete';
import getExecutionHistory from '@salesforce/apex/ConfigurationController.getExecutionHistory';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ConfigurationPanel extends LightningElement {
    @api currentView = 'default';  
    loading = true;   
    wizardMode = false;
    historyRecord;

    connectedCallback() {
        this.fetchCustomSettings();
    }

    @track configurations = [
        {   stepNumber : 1,
            title: 'Configure Leads',
            description: 'Lead data to be used in address matching',
            timeToComplete: '5',
            key: 'Lead',
            subSteps: []
        },
        {   stepNumber : 2,
            title: 'Configure Opportunities',
            description: 'Opportunity data to be used in address matching',
            timeToComplete: '5',
            key: 'Opportunity',
            subSteps: []
        },
        {   
            stepNumber : 3,
            title: 'Configure Automation and Processing',
            description: '',
            timeToComplete: '5',
            key: 'Schedule',
            subSteps: []
        }
    ];

    @wire(getExecutionHistory)
    wiredSalesHistory({ data, error }) {
        if (data) {
            this.historyRecord = data;
        } else if (error) {
            console.error('Error fetching sales history:', error);
        }
    }

    // Get custom setting values from Apex
    fetchCustomSettings() {
        getCustomSettingValues()
            .then(data => {
                this.wizardMode = !data.IsSetupComplete;
                this.configurations.forEach((config, index) => {
                    this.configurations[index].subSteps = this.buildSubSteps(data, config);
                });
                this.loading = false;
            })
            .catch(error => {
                console.error('Error fetching custom settings:', error);
            });
    }

    buildSubSteps(data, stepConfig) {
        let subSteps = [];
        switch(stepConfig.key) {
            case 'Lead':
                subSteps.push({
                    label: this.wizardMode ? 'Select Record Types'  : 'Modify Record Types',
                    buttonLabel: this.wizardMode ? 'Select Record Types' : 'Modify Record Types',
                    isCompleted: data.Lead_Record_Types && data.Lead_History_Duration ? true : false,
                    actionKey: 'addRecordTypes'
                });
                subSteps.push({
                    label: this.wizardMode ? 'Select Lead Statuses to Include' : 'Modify Lead Statuses to Include',
                    buttonLabel: this.wizardMode ? 'Select Statuses' : 'Modify Statuses',
                    isCompleted: data.Lead_Statuses && data.Lead_Matched_Reason && data.Lead_Matched_Reason_Field && data.Lead_Matched_Status ? true : false,
                    actionKey: 'addStatuses'
                });
                subSteps.push({
                    label: this.wizardMode ? 'Configure Lead Address Fields for Matching' : 'Modify Lead Address Fields for Matching',
                    buttonLabel: this.wizardMode ? 'Configure Address Fields' : 'Modify Address Fields',
                    isCompleted: data.Lead_Address_PostalCode && data.Lead_Address_State && data.Lead_Address_Street && data.Lead_Address_City ? true : false,
                    actionKey: 'configureMapping'
                });
                break;
            case 'Opportunity':
                subSteps.push({
                    label: this.wizardMode ? 'Select Record Types' : 'Modify Record Types',
                    buttonLabel: this.wizardMode ? 'Add Record Types' : 'Modify Record Types',
                    isCompleted: data.Opportunity_Record_Types && data.Opportunity_History_Duration ? true : false,
                    actionKey: 'addRecordTypes'
                });
                subSteps.push({
                    label: this.wizardMode ? 'Select Opportunity Stages to Include' : 'Modify Opportunity Stages to Include',
                    buttonLabel: this.wizardMode ? 'Select Stages' : 'Modify Stages',
                    isCompleted: data.Opportunity_Stages && data.Opportunity_Matched_Reason && data.Opportunity_Matched_Reason_Field && data.Opportunity_Matched_Stage ? true : false,
                    actionKey: 'addStatuses'
                });
                subSteps.push({
                    label: this.wizardMode ? 'Configure Address Fields for Matching' : 'Modify Opportunity Address Fields for Matching',
                    buttonLabel: this.wizardMode ? 'Configure Address Fields' : 'Modify Address Fields',
                    isCompleted: data.Opportunity_Address_PostalCode && data.Opportunity_Address_State && data.Opportunity_Address_Street && data.Opportunity_Address_City ? true : false,
                    actionKey: 'configureMapping'
                });
                break;
            case 'Schedule':
                subSteps.push({
                    actionKey: 'scheduleMatching',
                    label: this.wizardMode ? 'Schedule Property Sales.AI Algorithm Execution' : 'Modify Property Sales.AI Algorithm Execution', 
                    buttonLabel: this.wizardMode ? 'Add Schedule' : 'Modify Schedule',
                    isCompleted: data.Matching_Day /*&& data.Property_Sales_History_Duration*/ ? true : false
                });
                break;
        }
        return subSteps;
    }
        
    handleNavigate(event) {
        const actionKey = event.detail.actionKey;
        this.stepKey = event.detail.stepKey;  // Capture stepKey from event

        // Update the current view based on the action key
        switch (actionKey) {
            case 'addRecordTypes':
                this.currentView = 'recordTypePicker';
                break;
            case 'addStatuses':
                this.currentView = 'statusMultiPicker';
                break;
            case 'scheduleMatching':
                this.currentView = 'scheduleMatching';
                break;
            case 'filterByCreatedDate':
                this.currentView = 'createdDateFilter';
                break;
            case 'configureMapping':
                this.currentView = 'configureMapping';
                break;
            default:
                this.currentView = 'default';
                break;
        }
    }

    // Reset the view to the default when necessary (e.g., when navigation is complete)
    handleBack() {
        this.currentView = 'default';  // Return to default view or reset as needed
    }

    // Reset the view to the default when necessary (e.g., when navigation is complete)
    handleSave() {
        this.loading = true;
        this.currentView = 'default';  // Return to default view or reset as needed
        this.fetchCustomSettings();
        this.loading = false;
    }

    // Conditional rendering for components based on the current view
    get isRecordTypePicker() {
        return this.currentView === 'recordTypePicker';
    }

    get isDefault() {
        return this.currentView === 'default';
    }

    get isDefaultWizard() {
        return this.currentView === 'default' && this.wizardMode;
    }

    get isDefaultNonWizard() {
        return this.currentView === 'default' && !this.wizardMode;
    }

    get displayHistoryRecordInfo() {
        return this.isDefaultNonWizard && this.historyRecord && Object.keys(this.historyRecord).length > 0;
    }

    get isStatusMultiPicker() {
        return this.currentView === 'statusMultiPicker';
    }

    get isScheduleMatching() {
        return this.currentView === 'scheduleMatching';
    }

    get isCreatedDateFilter() {
        return this.currentView === 'createdDateFilter';
    }

    get isConfigureMapping(){
        return this.currentView === 'configureMapping'
    }

    get headerTitle() {
        switch (this.currentView) {
            case 'recordTypePicker':
                return 'Select ' + this.stepKey +' Record Types';
            case 'statusMultiPicker':
                return this.stepKey === 'Lead' ? 'Select Lead Statuses' : 'Select Opportunity Stages';
            case 'scheduleMatching':
                return 'Schedule Matching';
            case 'configureMapping':
                return 'Configure ' + this.stepKey + ' Address Fields For Matching';
            default:
                return this.wizardMode ? 'Setup Wizard' : 'Configuration';
        }
    }

    get headerSubtitle() {
        return 'Property Sales.AI'
    }

    get calculatePercentage() { 
        let completedConsecutiveSteps = 0;
        let totalSubSteps = 0;
    
        for (let i = 0; i < this.configurations.length; i++) {
            const subSteps = this.configurations[i].subSteps;
            totalSubSteps += subSteps.length; // Keep track of total substeps
            
            for (let j = 0; j < subSteps.length; j++) {
                if (subSteps[j].isCompleted) {
                    completedConsecutiveSteps++;
                } else {
                    break;
                }
            }
        }
        return totalSubSteps > 0 ? ((completedConsecutiveSteps / totalSubSteps) * 100).toFixed(0) : 0;
    }

    get disabled() {
        return this.calculatePercentage != 100;
    }
    
    handleScheduleMatchingLogic() {
        this.loading = true; // Show spinner
    
        updateIsSetupComplete()
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Schedule matching setup completed successfully.',
                        variant: 'success'
                    })
                );
                this.loading = false; // Hide spinner
                this.wizardMode = false;
            })
            .catch(error => {
                this.loading = false; // Hide spinner
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error completing schedule matching setup: ' + error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}