import { LightningElement,track,api,wire } from 'lwc';
import getReports from '@salesforce/apex/LmrReportByRole_ctr.getReports';


const columns = [
    { label: 'Name', fieldName: 'recordLink',type: 'url',
    typeAttributes: {label: { fieldName: 'Name' }, tooltip:"Name", target: "_blank"},
    sortable: true},
    { label: 'Name', fieldName: 'Name' },
    { label: 'Api Name', fieldName: 'DeveloperName' },
    { label: 'Folder Name', fieldName: 'FolderName' }
];


export default class LmrReportByRole extends LightningElement {
    @track allReports;

    @track columns = columns;
    @api recordId;
    @track countRecords =0;
    @wire(getReports)
    wiredReports({error,data}){
        if (data) { 
            console.log('data: '+ JSON.stringify(data));
            this.countRecords =  data.length;
            var tempOppList = [];  
            for (var i = 0; i < data.length; i++) {  
             let tempRecord = Object.assign({}, data[i]); //cloning object  
             tempRecord.recordLink = "/" + tempRecord.Id;  
             tempOppList.push(tempRecord);  
            }  
            this.allReports = tempOppList; 
            this.error = undefined;  
           } else if (error) {  
            console.log('error is: '+JSON.stringify(error));
            this.error = error;  
            this.allReports = undefined;  
           }  
        
    }

}