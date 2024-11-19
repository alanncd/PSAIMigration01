import { LightningElement, api} from 'lwc';

export default class ProgressRing extends LightningElement {
    @api fillPercent = 0;  // Fill percentage (0-100)
    @api label;

    get arcPath() {
        // Convert percentage to [0-1] for calculation
        const fill = this.fillPercent / 100;
        
        // Calculate arc properties
        const arcX = Math.cos(2 * Math.PI * fill);
        const arcY = -1 * Math.sin(2 * Math.PI * fill);
        const isLong = fill > 0.5 ? 1 : 0;  // Determine if the arc should take the long path
        
        return `M 1 0 A 1 1 0 ${isLong} 0 ${arcX} ${arcY} L 0 0`;
    }

    get isComplete() {
        return this.fillPercent === 100;
    }
}