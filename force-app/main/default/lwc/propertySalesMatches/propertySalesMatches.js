import { LightningElement, api, track, wire } from 'lwc';
import fetchMatches from '@salesforce/apex/PropertySalesController.getMatches';
import markAsGoodMatches from '@salesforce/apex/PropertySalesController.markAsGoodMatches';
import markAsNotMatch from '@salesforce/apex/PropertySalesController.markAsNotMatch';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

export default class PropertySalesMatches extends LightningElement {
    @api recordId; // The current Property_SalesAI_History__c Id
    data = []; // Table data for matched leads/opportunities
    selectedRows = []; // Stores the selected rows
    isUpdateDisabled = true; // To control update button state
    showDataTable = true; // To control dynamic rendering between two views
    confirmUpdate;
    wiredMatchesResult;
    loading;
    // Columns for the datatable
    columns = [
        { label: 'Sold Property Address', fieldName: 'soldPropertyAddress', type: 'text' },
        { label: 'Lead/Opp Address', fieldName: 'leadOppAddress', type: 'text' }
    ];

    // Fetch the matches when the component is initialized
    @wire(fetchMatches, { historyId: '$recordId' })
    wiredMatches(result) {
        this.wiredMatchesResult = result; // Store the full wired result
        if (result.data) {
            this.data = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
            console.error('Error fetching matches:', result.error);
        }
    }
    

    // Handle row selection in the datatable
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRows = selectedRows;
        this.isUpdateDisabled = selectedRows.length === 0;
    }

    // Switch to match confirmation page
    handleUpdate() {
        this.loading = true;
        if (this.confirmUpdate === 'Confirm Selected As Match') {
            this.confirmSelectedAsGood();
        } else {
            this.confirmSelectedAsNotMatch();
        }
        this.goBack();
    }

    // Switch back to the datatable view
    handleBack() {
        this.goBack();
    }

    goBack() {
        this.showDataTable = true;
        this.selectedRows = [];
        this.selectedData = [];
        this.isUpdateDisabled = true;
    }

    // Mark a match as "Looks Good!"
    markSelectedAsGood() {
        if (this.selectedRows.length > 0) {
            this.showDataTable = false; // Switch to match confirmation page
            this.selectedData = this.selectedRows;
            this.confirmUpdate = 'Confirm Selected As Match';
        }
    }

    confirmSelectedAsGood(){
        const selectedMatchIds = this.selectedData.map(record => record.id);
        markAsGoodMatches({ matchIds: selectedMatchIds, historyId: this.recordId })
            .then(() => {
                this.showToast('Success', 'Matches marked as Looks Good successfully.', 'success');
                updateRecord({ fields: { Id: this.recordId }});
                this.loading = false;
                return refreshApex(this.wiredMatchesResult);
            })
            .catch(error => {
                console.error('Error marking as good matches:', error);
                this.showToast('Error', 'An error occurred while marking matches as Looks Good.', 'error');
            });
    }
    
    // Mark a match as "Not a Match"
    markAsNotMatch() {
        if (this.selectedRows.length > 0) {
            this.showDataTable = false; // Switch to match confirmation page
            this.selectedData = this.selectedRows;
            this.confirmUpdate = 'Confirm Selected As Not A Match';
        }
    }

    confirmSelectedAsNotMatch() {
        const selectedMatchIds = this.selectedData.map(record => record.id);
        markAsNotMatch({ matchIds: selectedMatchIds, historyId: this.recordId })
            .then(() => {
                this.showToast('Success', 'Matches marked as Not a Match successfully.', 'success');
                updateRecord({ fields: { Id: this.recordId }});
                this.loading = false;
                return refreshApex(this.wiredMatchesResult);
            })
            .catch(error => {
                console.error('Error marking as not match:', error);
                this.showToast('Error', 'An error occurred while marking matches as Not a Match.', 'error');
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}