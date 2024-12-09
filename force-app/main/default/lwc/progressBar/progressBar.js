import { LightningElement, api } from 'lwc';

export default class ProgressBarComponent extends LightningElement {
    // API properties to allow flexibility in usage
    @api progressPercentage = 0;  // Default progress is set to 0
    @api setupName = 'Property Sales AI';  // Default setup name
    
    // Validation to ensure progress is between 0 and 100
    get validProgress() {
        return Math.max(0, Math.min(this.progressPercentage, 100));
    }
}