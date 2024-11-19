public with sharing class BatchCalloutCadenceSMS implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private Set<Id> setSMSIds;
    
    public BatchCalloutCadenceSMS(Set<Id> setSMSIds) {
        this.setSMSIds = setSMSIds;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('start');
        String sQuery = 'SELECT Id,TargetId__c,IdTemplate__c FROM ScheduleCadence__c WHERE Id IN :setSMSIds';
        return Database.getQueryLocator(sQuery);
    }

    public void execute(Database.BatchableContext BC, List<ScheduleCadence__c> smsList) {
        List<Sobject> listSobjects = new List<Sobject>();
        List<LMR_SmsHistory__c> listSentSms = new List<LMR_SmsHistory__c>();
        try{
        for(ScheduleCadence__c sms : smsList ){

            listSobjects.addAll(Lmr_SmrtPhone_cls.getSmsCallout(sms.TargetId__c,''+sms.IdTemplate__c));
            sms.Status__c = 'Completed';
        }

        LeftMain_SecurityUtils.checkUpdate(ScheduleCadence__c.SObjectType,new List<String> {'Status__c'});
        SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.UPDATABLE, smsList);
        Database.update(smsList = decision1.getRecords());

        LeftMain_SecurityUtils.checkInsert(ErrorHandlerLmr__c.SObjectType,new List<String> {'ProcessName__c','LogDetail__c'});
        LeftMain_SecurityUtils.checkInsert(
            LMR_SmsHistory__c.SObjectType,
            new List<String>{
              'From__c',
              'To__c',
              'Body__c',
              'Name',
              'SmsTemplate__c',
              'Lead__c',
              'Opportunity__c',
              'Contact__c',
              'Information__c'
            });

            SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, listSobjects);
            Database.insert(listSobjects = decision3.getRecords());

        }Catch(Exception e){
            ErrorHandler_cls.handleException(e,'Now SMS');
        }


    }

    public void finish(Database.BatchableContext BC) {
        // Additional logic after batch execution, if needed
    }

}