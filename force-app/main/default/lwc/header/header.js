import { LightningElement, api } from 'lwc';

export default class Header extends LightningElement {
    // API properties to make the component reusable and configurable
    @api title;        // Title text (e.g., 'Rohde Corp - 80,000 Widgets')
    @api subtitle;     // Subtitle text (e.g., 'Mark Jaeckal • Unlimited Customer • 11/13/15')

    get iconTitle() {
        return this.iconName ? this.iconName : 'default';
    }
}