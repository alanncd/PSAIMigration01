public with sharing class TaskTriggerService {
    // Update task count on lead and opportunity.
    public static void updateLeadTaskCount(List<Task> newList,Map<Id,Task> OldMap){
         LeftMain_SecurityUtils.checkObjectIsReadable(Lead.SObjectType);
        LeftMain_SecurityUtils.checkObjectIsInsertable(Opportunity.SObjectType); 

        checkRecursive.validateRecursivity = true;

        String leadPrefix = Lead.SObjectType.getDescribe().getKeyPrefix();
        String opportunityPrefix = Opportunity.SObjectType.getDescribe().getKeyPrefix();
        Set<String> leadIdSet = new Set<String>();
        Set<String> opportunityIdSet = new  Set<String>(); 
        
         LeftMain_SecurityUtils.checkRead(Task.SObjectType,new List<String> {
            'whoId',
            'WhatId', 
            'Id',
            'subject'
        });  

        //get ids of lead and opportunity from task object.
        for(Task taskOBJ : newList){
            if (taskOBJ.whoId !=null && string.valueOf(taskOBJ.whoId).startsWith(leadPrefix)) {
                leadIdSet.add(taskOBJ.whoId);
            }
            if (taskOBJ.WhatId !=null && string.valueOf(taskOBJ.WhatId).startsWith(opportunityPrefix)) {
                opportunityIdSet.add(taskOBJ.WhatId); 
            }
        }

         LeftMain_SecurityUtils.checkRead(Lead.SObjectType,new List<String> {
            'Id',
            'TaskCount__c'
        }); 

        if (!leadIdSet.isEmpty()){
            List<Lead> leadUpdateList = new List<Lead>();
            List<Lead> leadsList = [SELECT Id, TaskCount__c,
                                (SELECT Id,subject FROM Tasks) 
                                 FROM Lead WHERE Id IN :leadIdSet WITH USER_MODE];
           
            // Update task count on lead object records.
            for (Lead leadObj : leadsList) {
                Integer taskcount = 0;
                for (Task taskObj : leadObj.Tasks) {
                        taskcount ++; 
                }
                leadObj.TaskCount__c = taskcount;
                leadUpdateList.add(leadObj);
            }

            if(!leadUpdateList.isEmpty()){
                try{
                LeftMain_SecurityUtils.checkUpdate(Lead.SObjectType,new List<String> {'Task_Count__c'});
                SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.UPDATABLE, leadUpdateList);
                List<Database.SaveResult> myResult = Database.update(leadUpdateList = decision1.getRecords());
                
                }Catch(Exception e){
                    System.debug('error: '+e);
                }
            }
        }
         LeftMain_SecurityUtils.checkRead(Opportunity.SObjectType,new List<String> {
            'Id',
            'Task_Count__c'
        }); 
        if (!opportunityIdSet.isEmpty()){
            List<Opportunity> opportunityUpdateList = new List<Opportunity>();
            List<Opportunity> opportunityList = [SELECT Id, Task_Count__c,
                                (SELECT Id,subject FROM Tasks) 
                                 FROM Opportunity WHERE Id IN :opportunityIdSet WITH USER_MODE];
                                
            // Update task count on Opportunity object records.
            for (Opportunity opportunityObj : opportunityList) {
                Integer taskcount = 0;
                for (Task taskObj : opportunityObj.Tasks) {
                        taskcount ++;
                }
                opportunityObj.Task_Count__c = taskcount;
                opportunityUpdateList.add(opportunityObj);
            }

            if(!opportunityUpdateList.isEmpty()){
                try{
                LeftMain_SecurityUtils.checkUpdate(Opportunity.SObjectType,new List<String> {'Task_Count__c'});
                SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.UPDATABLE, opportunityUpdateList);
                List<Database.SaveResult> myResult = Database.update(opportunityUpdateList = decision2.getRecords(), false);}catch(Exception e){System.debug('error: '+e);}

            }
        }
    }

}