global with sharing class BatchOpportunityActivityCount implements
    Database.Batchable<sObject>, Database.Stateful,Schedulable { 
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        LeftMain_SecurityUtils.checkRead( Opportunity.SObjectType,new List<String> {
            'Id',
            'Name',
            'Task_Count__c',
            'Event_Count__c',
            'BypassApex__c'
        });
        String SOQLOpportunity = 'SELECT Id, Name, Task_Count__c, Event_Count__c,Number_Outbound_Calls__c, BypassApex__c FROM Opportunity  LIMIT 5000000';
        return Database.getQueryLocator(SOQLOpportunity);
    }
    global void execute(Database.BatchableContext bc, List<Opportunity> scope){
        // process each batch of records
        List<Opportunity> OpportunityList = new List<Opportunity>(); 
        Set<String> OpportunityIdSet = new  Set<String>();
        
        for(Opportunity OpportunityObj : scope){
            OpportunityIdSet.add(OpportunityObj.Id);
        }
        
        LeftMain_SecurityUtils.checkRead( Task.SObjectType,new List<String> {
            'Id',
            'OwnerId',
            'Subject',
            'WhatId'
        });
        /*BEGIN COUNT CALLS*/
        List<task> callList = [Select Id,OwnerId,Subject,WhatId from Task Where TaskSubtype = 'Call' AND WhatId IN :OpportunityIdSet WITH USER_MODE];
        Map<String,List<Task>> callMap = new Map<String,List<Task>>();
        
        // Map CALLS with WhatId (Opportunity).
        for(Task callObj : callList){
            if(!callMap.containsKey(callObj.WhatId)){
                List<task> tempCallList = new List<Task>(); 
                tempCallList.add(callObj);
                callMap.put(callObj.WhatId,tempCallList);
                
            }else{
                List<task> tempCallList = callMap.get(callObj.WhatId) != null ? callMap.get(callObj.WhatId) : new List<Task>();
                tempCallList.add(callObj);
                callMap.put(callObj.WhatId,tempCallList); 
            }
        }
        
        /*END COUNT CALLS*/
        List<task> TaskList = [Select Id,OwnerId,Subject,WhatId from Task Where WhatId IN :OpportunityIdSet WITH USER_MODE];
        Map<String,List<Task>> taskMap = new Map<String,List<Task>>();
        
        // Map Task with WhatId (Opportunity).
        for(Task taskObj : TaskList){
            if(!taskMap.containsKey(taskObj.WhatId)){
                List<task> tempTaskList = new List<Task>(); 
                tempTaskList.add(taskObj);
                taskMap.put(taskObj.WhatId,tempTaskList);
                
            }else{
                List<task> tempTaskList = taskMap.get(taskObj.WhatId) != null ? taskMap.get(taskObj.WhatId) : new List<Task>();
                tempTaskList.add(taskObj);
                taskMap.put(taskObj.WhatId,tempTaskList); 
            }
        }

        LeftMain_SecurityUtils.checkRead( Event.SObjectType,new List<String> {
            'Id',
            'OwnerId',
            'Subject',
            'WhatId'
        });
        List<Event> EventList =[Select Id,OwnerId,Subject,WhatId from Event WHERE WhatId IN :OpportunityIdSet WITH USER_MODE];
        Map<String,List<Event>> eventMap = new Map<String,List<Event>>();
        
        // Map Eask with WhatId (Opportunity)
        for(Event eventObj : EventList){
            if(!eventMap.containsKey(eventObj.WhatId)){
                List<Event> tempEventList = new List<Event>();
                tempEventList.add(eventObj);
                eventMap.put(eventObj.WhatId,tempEventList);
            }else{
                List<Event> tempEventList = eventMap.get(eventObj.WhatId) != null ? eventMap.get(eventObj.WhatId) : new List<Event>();
                tempEventList.add(eventObj);
                eventMap.put(eventObj.WhatId,tempEventList);
            }
        }
       

        LeftMain_SecurityUtils.checkUpdate(Opportunity.SObjectType,new List<String> {
            'Task_Count__c',
            'Event_Count__c'
        });

        // Count task and event on a opportunity and assign value to related field.
        // Acd: Add Calls(Tasks)
        for (Opportunity opportunityObj : scope) {
            opportunityObj.BypassApex__c = true;
            if(taskMap.containskey(opportunityObj.Id)){
                List<task> tempTaskList = taskMap.get(opportunityObj.Id) != null ? taskMap.get(opportunityObj.Id) : new List<Task>();
                opportunityObj.Task_Count__c = !tempTaskList.isEmpty() ? tempTaskList.Size() : 0;
            }else{
                opportunityObj.Task_Count__c = 0;
            }
            if(eventMap.containskey(opportunityObj.Id)){
                List<Event> tempEventList = eventMap.get(opportunityObj.Id) != null ? eventMap.get(opportunityObj.Id) : new List<Event>();
                opportunityObj.Event_Count__c = !tempEventList.isEmpty() ? tempEventList.Size() : 0;
            }else{
                opportunityObj.Event_Count__c = 0;
            }
           //acd: Call Count
           if(callMap.containskey(opportunityObj.Id)){
                List<task> tempCallList = callMap.get(opportunityObj.Id) != null ? callMap.get(opportunityObj.Id) : new List<task>();
                opportunityObj.Number_Outbound_Calls__c = !tempCallList.isEmpty() ? tempCallList.Size() : 0;
            }else{
                opportunityObj.Number_Outbound_Calls__c = 0;
            }
            OpportunityList.add(opportunityObj);
        }
        if(!OpportunityList.isEmpty()){
            /* Commenting this because we are disabling FLS for this package 1.15 Uncomment this when you need FLS for Security Review.  */
            SObjectAccessDecision decisionOpp = Security.stripInaccessible(AccessType.UPDATABLE, OpportunityList);
            update decisionOpp.getRecords(); 
            //update OpportunityList;  
        }
    }
    global void finish(Database.BatchableContext bc){
       
    }
        
    global void execute(SchedulableContext SC) { 
            BatchOpportunityActivityCount OpportunityActivityObj = new BatchOpportunityActivityCount(); 
            Database.executeBatch(OpportunityActivityObj,200); 
    }
}