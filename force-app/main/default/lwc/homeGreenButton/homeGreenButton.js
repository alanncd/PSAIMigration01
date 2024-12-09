import { LightningElement, api } from 'lwc';

export default class HomeGreenButton extends LightningElement {
    @api label;
    @api size;

    get computedClass() {
        let baseClass = 'slds-button slds-button_neutral homeGreenButton';
        return this.size === 'big' ? `${baseClass} bigButton` : baseClass;
    }
}