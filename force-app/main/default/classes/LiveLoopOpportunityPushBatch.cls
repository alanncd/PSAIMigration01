global with sharing class LiveLoopOpportunityPushBatch implements Database.Batchable<sobject>,Database.AllowsCallouts,Schedulable {
    global Iterable<sObject> start(Database.BatchableContext BC) {
        return Database.getQueryLocator('select id,Name,leadsource, StageName, Description, Account.Name, CreatedDate,LastModifiedDate,Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry  from Opportunity where Pushed_to_Audantic__c=false');
    }
    public void execute(Database.BatchableContext info, List<Opportunity> oppList){
        
        LiveLoopReqWrapper.OrgDetails orgDetails=LiveLoopCallout.getOrgDetails();
        
        for(Opportunity opportunity: oppList){
            String calloutResult= LiveLoopCallout.sendPipelineObject(LiveLoopReqWrapper.getOpportunityRequest(opportunity),orgDetails);
            if(calloutResult=='success'){
                opportunity.Pushed_to_Audantic__c=true;
            }
        }
        LeftMain_SecurityUtils.checkUpdate(Opportunity.SObjectType,new List<String> {'Pushed_to_Audantic__c'});
        LeftMain_SecurityUtils.checkInsert(Opportunity.SObjectType,new List<String> {'Pushed_to_Audantic__c'});
        SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, oppList);
        Database.upsert(oppList = decision3.getRecords());
        
    }     
    public void finish(Database.BatchableContext info){
        System.debug('>>>>>>>>> LiveLoopOpportunityPushBatch completed successfully');
    } 
        
        
    global void execute(SchedulableContext sc) {
        LiveLoopOpportunityPushBatch batchObj = new LiveLoopOpportunityPushBatch(); 
         if(!Test.isRunningTest()){
            database.executebatch(batchObj,5);
        }
    }
    
}