public with sharing class BatchNowCadenceEmails implements Database.Batchable<SObject> {
    private Set<Id> setEmailIds;

    public BatchNowCadenceEmails(Set<Id> setEmailIds) {
        this.setEmailIds = setEmailIds;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String sQuery = 'SELECT Id, Related_Record_id__c, IdTemplate__c, Status__c,Email__c FROM ScheduleCadenceEmail__c WHERE Id IN :setEmailIds';
        return Database.getQueryLocator(sQuery);
    }

    public void execute(Database.BatchableContext BC, List<ScheduleCadenceEmail__c> emailList) {
        for(ScheduleCadenceEmail__c email : emailList ){
             Lmr_SendEmail.EmailNow(email.Related_Record_id__c,email.IdTemplate__c,email.Email__c);
            email.Status__c = 'Completed';
        }
        LeftMain_SecurityUtils.checkUpdate(ScheduleCadenceEmail__c.SObjectType,new List<String> {'Status__c'});
        SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.UPDATABLE, emailList);
        Database.update(emailList = decision2.getRecords());

    }

    public void finish(Database.BatchableContext BC) {
        // Additional logic after batch execution, if needed
    }
}