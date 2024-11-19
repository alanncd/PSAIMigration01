import { LightningElement, track, api, wire } from "lwc";
import { getPicklistValues,getObjectInfo } from 'lightning/uiObjectInfoApi';
import { createRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CADENCE_OBJECT from '@salesforce/schema/Cadences__c';
import NAME_FIELD from '@salesforce/schema/Cadences__c.Name';
import SMS_FIELD from '@salesforce/schema/Cadences__c.SmsFolder__c';
import EMAIL_FIELD from '@salesforce/schema/Cadences__c.FolderEmail__c';
import TASK_FIELD from '@salesforce/schema/Cadences__c.TaskEmailTemplate__c';
import TARGET_FIELD from '@salesforce/schema/Cadences__c.TargetId__c';

import FolderEmailPicklist from '@salesforce/schema/Lead_Follow_Up_Sequence__c.Folder__c';
import FollowUpSequence from '@salesforce/schema/Lead_Follow_Up_Sequence__c'; 
import TaskFollowUpSequenceobject from '@salesforce/schema/Task_Follow_Up_Sequence__c'; 
import TaskSequenceFolder from '@salesforce/schema/Task_Follow_Up_Sequence__c.Task_Cadence_Folder__c'; 
import SmsFollowUpSequenceobject from '@salesforce/schema/LMR_TemplateSms__c'; 
import SmsSequenceFolder from '@salesforce/schema/LMR_TemplateSms__c.Folder__c'; 

import getCustomSettings from '@salesforce/apex/CadencesTriggerHandler.getCustomSettings';
import getEmailDefault from '@salesforce/apex/CadencesTriggerHandler.getOrganizationWideDefault';

export default class LmrLwcTemplateEmail extends LightningElement {

    @api recordId;
    @track disabledButton = false;
    @track customSettingsTrigger;
    @track triggerCadence=false;
    @track triggerSmartphone;
    @track triggerTask;
    @track triggerEmail;
    @track titleCadence ='Initial Cadence';
    @track emailVerified = false;
    @track markedEmail;

    @wire(getCustomSettings)
    myCustomSettings({data,error}){
        if(data){
            console.log('data: '+JSON.stringify(data)); 
           this.triggerCadence = data.Activate_trigger_cadences__c;
            this.triggerSmartphone = data.activateSmartphone__c;
            this.triggerTask = data.TaskAutomation__c;
          this.triggerEmail = data.EmailAutomation__c;
        }
        if(error){
            console.log('error: customSetting'+JSON.stringify(error));
            console.error(error);
        }
    }

    get incoming(){
        return this.customSettingsTrigger[0].Id;
    }

    @track selectedUser;
    @track selectedUserId;
    @track isModalFormOpen =true;
    @track folderSelectedEmail;
    @track emailTemplateValue;
    @track TaskSequenceFolderValue;
    @track smsTemplateValue;


      handleCancel() {
          this.closeModalForm();        

      }

      closeModalForm(){
            this.isModalFormOpen = false;
            const closeMethodInAuraController = new CustomEvent("close");
        this.dispatchEvent(closeMethodInAuraController);
        }


        handleChangeaTaskSequence(event) {
            this.TaskSequenceFolderValue = event.detail.value;
        }
        handleChangeFolderEmail(event) {
            this.emailTemplateValue = event.detail.value;
        }

        handleChangeFolderTask(e) {
            this.smsTemplateValue = e.detail.value;
        }
//get Object Follow Up Sequence
@track picklistTemplatesOptions;
@wire (getObjectInfo, {objectApiName: FollowUpSequence})
    objectInfo;

//get Object Task follow Up Sequence
@track TaskSequenceFolderOpions;
@wire (getObjectInfo, {objectApiName: TaskFollowUpSequenceobject})
    objectInfoT;

//get Object SMS Template
@track SmsTemplatesOptions;
@wire (getObjectInfo, {objectApiName: SmsFollowUpSequenceobject})
    objectInfoS;

    //get picklist SMS Folder
        @wire(getPicklistValues, {recordTypeId: '$objectInfoS.data.defaultRecordTypeId',fieldApiName: SmsSequenceFolder })
        getSmsFolders({ error, data }) {
            if (data) {
                console.log(+'default recordtype'+this.objectInfoS.data.defaultRecordTypeId);
                this.SmsTemplatesOptions = [{label: '--No Value--', value: null}, ...data.values];
            } else if (error) {
                this.error = error;
            }else{
            }
        }

    // get picklist values Email Folder 
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: FolderEmailPicklist })
    getFoldersTemplates({ error, data }) {
        if (data) {
            this.picklistTemplatesOptions = [{label: '--No Value--', value: null}, ...data.values];
        } else if (error) {
            this.error = error;
        }
    }

    // get picklist values Task Folder 
    @wire(getPicklistValues, {recordTypeId: '$objectInfoT.data.defaultRecordTypeId',fieldApiName: TaskSequenceFolder })
    getTaskFolders({ error, data }) {
        if (data) {
            this.TaskSequenceFolderOpions = [{label: '--No Value--', value: null}, ...data.values];
        } else if (error) {
            this.error = error;
        }else{
        }
    }

    isLoaded = false
    renderedCallback(){
        if(this.picklistTemplatesOptions){
        if(this.isLoaded) return
        const style = document.createElement('style')
        style.innerText = `c-lmr-lwc-template-email .slds-dropdown{
            position:relative;
        } `
        this.template.querySelector('lightning-combobox').appendChild(style)
        this.isLoaded = true}

        
    }

    handleClick(){
        this.disabledButton = true;
        this.createCadence();
    }

    handleInputChange(event) {
        this.titleCadence = event.detail.value;
    }

    createCadence(){
        const fields = {};
        fields[NAME_FIELD.fieldApiName] = this.titleCadence;
        fields[SMS_FIELD.fieldApiName] = this.smsTemplateValue;
        fields[EMAIL_FIELD.fieldApiName] = this.emailTemplateValue;
        fields[TASK_FIELD.fieldApiName] = this.TaskSequenceFolderValue;
        fields[TARGET_FIELD.fieldApiName] = this.recordId;

        const recordInput = { apiName: CADENCE_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(account => {
                this.accountId = account.id;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Cadence created.',
                        variant: 'success',
                    }),
                );
                this.dispatchEvent(new CustomEvent('recordChange'));
                this.closeModalForm(); 
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
                this.disabledButton = false;
                console.log('error: '+JSON.stringify(error));
            });

    }

    @wire(getEmailDefault)
    getEmailDefault({data,error}){
        if(data){
            this.emailVerified = 'Organization-wide email address added';
            this.markedEmail = true;
        }else{
            this.emailVerified = 'Please add an organization-wide email address';
            this.markedEmail = false;
        }
        if(error){
            console.error(error)
        }
    }

}