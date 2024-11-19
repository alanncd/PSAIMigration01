import { LightningElement, api, track} from 'lwc';

export default class ConfigurationStep extends LightningElement {
    @api title;            // E.g., 'Configure Leads' or 'Configure Opportunities'
    @api description;      // E.g., 'Lead data to be used in address matching'
    @api timeToComplete;   // E.g., '5' (minutes)
    @api subSteps = [];     // Array of buttons, each with a 'label'
    @api stepNumber; // Default step number
    @api stepCompleted = false;
    @api stepKey;
    @api wizardMode;
    
    icon = 'utility:chevrondown';
    showSection = true;
    
    // Boolean to determine if the step is completed
    get isStepCompleted() {
        return this.fillPercent == 100; // You can change the logic based on your needs
    }

    // Example array of steps with dynamic data
    @api
    toggleSection() {
        this.showSection = !this.showSection;
        if (this.showSection) {
            this.icon = 'utility:chevrondown';
        } else {
            this.icon = 'utility:chevronright';
        }
    }

    // Calculate the fill percent based on the number of consecutive completed substeps
    get fillPercent() {
        let completedConsecutiveSteps = 0;
        const totalSteps = this.subSteps.length;
        // Loop through the substeps to count consecutive completed ones
        for (let i = 0; i < totalSteps; i++) {
            if (this.subSteps[i].isCompleted) {
                completedConsecutiveSteps++;
            } else {
                break;  // Stop counting as soon as we hit an incomplete step
            }
        }
        // Calculate the fill percentage as (consecutive completed / total) * 100
        return totalSteps > 0 ? (completedConsecutiveSteps / totalSteps) * 100 : 0;
    }

    handleButtonClick(event){
        this.dispatchEvent(new CustomEvent('navigate', {
            detail: { 
                actionKey: event.detail.actionKey,  // Set the correct key-value pair
                stepKey: this.stepKey               // Set the correct key-value pair
            }
        }));
    }
}