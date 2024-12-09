import {LightningElement, api} from 'lwc';

export default class ConfirmationDialog extends LightningElement {
    @api visible; //used to hide/show dialog
    @api title; //modal title
    @api name; //reference name of the component
    @api message; //modal message
    @api confirmLabel; //confirm button label
    @api cancelLabel; //cancel button label

    //handles button clicks
    handleClick(event){
        //creates object which will be published to the parent component
        let finalEvent = {
            originalMessage: this.originalMessage,
            status: event.target.name
        };
        console.log(JSON.stringify(event.target.name));
        if (event.target.name === 'cancel') {
            this.dispatchEvent(new CustomEvent('cancel', {detail: finalEvent}));
        } else {
            this.dispatchEvent(new CustomEvent('confirm', {detail: finalEvent}));
        }
    }
}