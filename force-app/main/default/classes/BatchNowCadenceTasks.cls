public with sharing class BatchNowCadenceTasks implements Database.Batchable<SObject> {
    private Set<Id> setTasksIds;
 
    public BatchNowCadenceTasks(Set<Id> setTasksIds) {
        this.setTasksIds = setTasksIds;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String sQuery = 'SELECT Id, Related_Record_id__c, IdTemplate__c, Status__c FROM ScheduleCadenceTask__c WHERE Id IN :setTasksIds';
        return Database.getQueryLocator(sQuery);
    }

    public void execute(Database.BatchableContext BC, List<ScheduleCadenceTask__c> taskList) {
        try{
        List<Task> listTasks = new List<Task>();
        for(ScheduleCadenceTask__c task : taskList ){
           // Lmr_TaskAutomation.taskCallout(task.Related_Record_id__c,''+task.IdTemplate__c);
            listTasks.add(Lmr_TaskAutomation.taskCalloutRefactor(task.Related_Record_id__c,''+task.IdTemplate__c));
            task.Status__c = 'Completed';
        }
        LeftMain_SecurityUtils.checkUpdate(ScheduleCadenceTask__c.SObjectType,new List<String> {'Status__c'});

        SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.UPDATABLE, taskList);
        Database.update(taskList = decision2.getRecords());

        LeftMain_SecurityUtils.checkInsert(Task.SObjectType,new List<String> {'Subject','ActivityDate','Description','WhoID','WhatId','OwnerId','Information__c'});

        SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, listTasks);
        Database.insert(listTasks = decision3.getRecords());
        }catch(Exception e){
            ErrorHandler_cls.handleException(e,'Task Cadence Now');
        }
    }

    public void finish(Database.BatchableContext BC) {
        // Additional logic after batch execution, if needed
       
    }

}