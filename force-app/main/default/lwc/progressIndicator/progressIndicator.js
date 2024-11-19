import { LightningElement, api, track} from 'lwc';

export default class ProgressIndicator extends LightningElement {
    _subSteps;  // Internal copy of the subSteps
    @api wizardMode;
    
    @api
    set subSteps(value) {
        this._subSteps = value.map(step => ({ ...step }));
        this.updateSubSteps();  // Perform calculations like isCurrent and cssClass
    }

    get subSteps() {
        return this._subSteps;  // Return the mutable copy
    }

    // Update the steps (calculate isCurrent and cssClass)
    updateSubSteps() {
        let currentFound = false;
        let allPreviousCompleted = true;  // Track if all previous steps are completed
    
        // Loop through each step and calculate isCurrent and cssClass
        this._subSteps = this._subSteps.map(step => {
            const updatedStep = { ...step };  // Create a new object reference for each step
    
            if (!updatedStep.isCompleted) {
                allPreviousCompleted = false;  // If this step is not completed, then not all previous are completed
            }
    
            if (!updatedStep.isCompleted && !currentFound) {
                updatedStep.isCurrent = true;  // Mark the first incomplete step as current
                currentFound = true;
            } else {
                updatedStep.isCurrent = false;  // Other steps are not current
            }
    
            // Compute the CSS class for each step and assign to updated step
            updatedStep.cssClass = this.getStepClass(updatedStep, allPreviousCompleted);
            updatedStep.isFullyCompleted = updatedStep.cssClass.includes('slds-is-completed'); 
            
            return updatedStep;  // Return the newly created object (ensures reactivity)
        });
    }
    
    // Method to determine the CSS class for the step based on its state
    getStepClass(step, allPreviousCompleted) {
        if (step.isCompleted && allPreviousCompleted) {
            return 'slds-progress__item slds-is-completed';
        } else if (step.isCurrent) {
            return 'slds-progress__item slds-is-active';
        } else {
            return 'slds-progress__item';
        }
    }
    
    // Method to handle button click
    handleButtonClick(event) {
        const actionKey = event.target.value;
        this.dispatchEvent(new CustomEvent('buttonclick', {
            detail: { actionKey }
        }));
    }
}