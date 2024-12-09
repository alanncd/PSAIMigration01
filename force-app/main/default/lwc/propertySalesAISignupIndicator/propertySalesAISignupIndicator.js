import { LightningElement, api, track } from "lwc";

export default class PropertySalesAISignupIndicator extends LightningElement {
    @track _currentStep;
    @track _subSteps = [];

    @api
    set currentStep(value) {
        this._currentStep = value;
        this.updateSubSteps();
    }

    get currentStep() {
        return this._currentStep;
    }

    @api
    set subSteps(value) {
        this._subSteps = value.map((step) => ({ ...step }));
        this.updateSubSteps(); // Perform updates when steps are set
    }

    get subSteps() {
        return this._subSteps;
    }

    // Calculates the progress bar value
    get progressValue() {
        const currentIndex = this._subSteps.findIndex((step) => step.number === this.currentStep);
        return ((currentIndex) / (this._subSteps.length-1)) * 100;
    }

    // Style for the progress bar
    get progressBarStyle() {
        return `width: ${this.progressValue}%`;
    }

    // Updates the classes and attributes for each step
    updateSubSteps() {
        let currentFound = false;
        let allPreviousCompleted = true;
        
        this._subSteps = this._subSteps.map((step) => {
            const updatedStep = { ...step };
            // Set isCompleted to true if _currentStep is greater than updatedStep.number
            if (this._currentStep > updatedStep.number) {
                updatedStep.isCompleted = true;
            } else {
                updatedStep.isCompleted = false;
                allPreviousCompleted = false; // Mark incomplete if one is not completed
            }

            if (!updatedStep.isCompleted) {
                allPreviousCompleted = false; // Mark incomplete if one is not completed
            }

            // Identify the current step
            if (!updatedStep.isCompleted && !currentFound) {
                updatedStep.isCurrent = true;
                currentFound = true;
            } else {
                updatedStep.isCurrent = false;
            }

            // Assign CSS classes dynamically
            updatedStep.cssClass = this.getStepClass(updatedStep, allPreviousCompleted);
            updatedStep.isFullyCompleted = updatedStep.cssClass.includes("slds-is-completed");

            return updatedStep;
        });
    }

    getStepClass(step, allPreviousCompleted) {
        if (step.isCompleted && allPreviousCompleted) {
            return "slds-progress__item slds-is-completed";
        } else if (step.isCurrent) {
            return "slds-progress__item slds-is-active";
        } else {
            return "slds-progress__item";
        }
    }
}