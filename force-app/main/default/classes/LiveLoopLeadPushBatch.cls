global with sharing class LiveLoopLeadPushBatch implements Database.Batchable<sobject>, Database.AllowsCallouts,Schedulable{
    global Iterable<sObject> start(Database.BatchableContext BC) {
        return Database.getQueryLocator('Select id,LeadSource,Address,Name,Description, Street, City, State,LastActivityDate, PostalCode, CreatedDate,LastModifiedDate,ConvertedContact.Name,Status  from Lead where Pushed_to_Audantic__c=false');
    }
    public void execute(Database.BatchableContext info, List<Lead> leadList){
		
		LiveLoopReqWrapper.OrgDetails orgDetails=LiveLoopCallout.getOrgDetails();
        
        for(Lead lead: leadList){//EVERY TWO HOURS.
            String calloutResult= LiveLoopCallout.sendPipelineObject(LiveLoopReqWrapper.getLeadRequest(lead),orgDetails);
            if(calloutResult=='success'){
                lead.Pushed_to_Audantic__c=true;
            }
        }
        LeftMain_SecurityUtils.checkUpdate(Lead.SObjectType,new List<String> {'Pushed_to_Audantic__c'});
        LeftMain_SecurityUtils.checkInsert(Lead.SObjectType,new List<String> {'Pushed_to_Audantic__c'});

        SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, leadList);
        Database.upsert(leadList = decision3.getRecords());
        
    }     
    public void finish(Database.BatchableContext info){
        System.debug('>>>>>>>>> LiveLoopLeadPushBatch completed successfully');
    } 
    
        
    global void execute(SchedulableContext sc) {
        LiveLoopLeadPushBatch batchObj = new LiveLoopLeadPushBatch();
        if(!Test.isRunningTest()){
            database.executebatch(batchObj,5);
        }
    }
}