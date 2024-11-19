global with sharing class BatchLeadActivityCount implements
    Database.Batchable<sObject>, Database.Stateful,Schedulable { 
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {

        LeftMain_SecurityUtils.checkRead(Lead.SObjectType,new List<String> 
                {
                'Id',
                'Name',
                'Next_Step__c',
                'TaskCount__c',
                'EventCount__c'
                }); 
        String SOQLLead = 'SELECT Id, Name, Next_Step__c, TaskCount__c, EventCount__c, Number_Outbound_Calls__c FROM Lead LIMIT 5000000';
        return Database.getQueryLocator(SOQLLead);
    }
    global void execute(Database.BatchableContext bc, List<Lead> scope){
        // process each batch of records
       	List<Lead> LeadList = new List<Lead>(); 
        Set<String> LeadIdSet = new  Set<String>();
        
        for(Lead LeadObj : scope){
            LeadIdSet.add(LeadObj.Id);
        }
        
        LeftMain_SecurityUtils.checkRead(Task.SObjectType,new List<String> {
                'Id',
                'OwnerId',
                'Subject',
                'whoId'
        });
		//Start Count Calls with whoId
		List<task> callList = [Select Id,OwnerId,Subject,whoId from Task Where TaskSubtype = 'Call' AND whoId IN :LeadIdSet WITH USER_MODE];
        Map<String,List<Task>> callMap = new Map<String,List<Task>>();
        for(Task callObj : callList){
            if(!callMap.containsKey(callObj.whoId)){
                List<task> tempCallList = new List<Task>();
                tempCallList.add(callObj);
                callMap.put(callObj.whoId,tempCallList);
                
            }else{
               	List<task> tempCallList = callMap.get(callObj.whoId) != null ? callMap.get(callObj.whoId) : new List<Task>();
                tempCallList.add(callObj);
                callMap.put(callObj.whoId,tempCallList); 
            }
        }
		//End Count Calls        
		
        List<task> TaskList = [Select Id,OwnerId,Subject,whoId from Task Where whoId IN :LeadIdSet WITH USER_MODE];
        Map<String,List<Task>> taskMap = new Map<String,List<Task>>();
		
        // Mapping task with whoId
        for(Task taskObj : TaskList){
            if(!taskMap.containsKey(taskObj.whoId)){
                List<task> tempTaskList = new List<Task>();
                tempTaskList.add(taskObj);
                taskMap.put(taskObj.whoId,tempTaskList);
                
            }else{
               	List<task> tempTaskList = taskMap.get(taskObj.whoId) != null ? taskMap.get(taskObj.whoId) : new List<Task>();
                tempTaskList.add(taskObj);
                taskMap.put(taskObj.whoId,tempTaskList); 
            }
        }
        
        LeftMain_SecurityUtils.checkRead(Event.SObjectType,new List<String> {
                'Id',
                'OwnerId',
                'Subject',
                'whoId'
        });
        List<Event> EventList =[Select Id,OwnerId,Subject,whoId from Event WHERE whoId IN :LeadIdSet WITH USER_MODE];
        Map<String,List<Event>> eventMap = new Map<String,List<Event>>();
        
        // Mapping event with whoId (LeadId)
        for(Event eventObj : EventList){
            if(!eventMap.containsKey(eventObj.whoId)){
                List<Event> tempEventList = new List<Event>();
                tempEventList.add(eventObj);
                eventMap.put(eventObj.whoId,tempEventList);
            }else{
               	List<Event> tempEventList = eventMap.get(eventObj.whoId) != null ? eventMap.get(eventObj.whoId) : new List<Event>();
                tempEventList.add(eventObj);
                eventMap.put(eventObj.whoId,tempEventList);
            }
        }
        
        // Count task and Event and assign on lead object.
        // Count Calls
        for (Lead LeadObj : scope) {
            if(taskMap.containskey(LeadObj.Id)){
                List<task> tempTaskList = taskMap.get(LeadObj.Id) != null ? taskMap.get(LeadObj.Id) : new List<Task>();
                LeadObj.TaskCount__c = !tempTaskList.isEmpty() ? tempTaskList.Size() : 0;
            }else{
                LeadObj.TaskCount__c = 0;
            }
            if(eventMap.containskey(LeadObj.Id)){
                List<Event> tempEventList = eventMap.get(LeadObj.Id) != null ? eventMap.get(LeadObj.Id) : new List<Event>();
                LeadObj.EventCount__c = !tempEventList.isEmpty() ? tempEventList.Size() : 0;
            }else{
                LeadObj.EventCount__c = 0;
            }
            if(callMap.containskey(LeadObj.Id)){
                List<task> tempCallList = callMap.get(LeadObj.Id) != null ? callMap.get(LeadObj.Id) : new List<task>();
                LeadObj.Number_Outbound_Calls__c = !tempCallList.isEmpty() ? tempCallList.Size() : 0;
            }else{
                LeadObj.Number_Outbound_Calls__c = 0;
            }
            
            if(String.isBlank(LeadObj.Next_Step__c)){
                LeadObj.Next_Step__c = 'Please add Next Step';
            }
            LeadList.add(LeadObj);
        }
        if(!LeadList.isEmpty()){

            LeftMain_SecurityUtils.checkUpdate(Lead.SObjectType,new List<String> {
            'Next_Step__c',
            'EventCount__c',
            'TaskCount__c'
            });
            
            /* Commenting this because we are disabling FLS for this package 1.15 Uncomment this when you need FLS for Security Review. */
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, LeadList);
            update decision.getRecords(); 
           // update LeadList;
           //List<Database.SaveResult> myResult = Database.update(LeadList, false);

        }
    }
    global void finish(Database.BatchableContext bc){
       
    }
        
    global void execute(SchedulableContext SC) { 
            BatchLeadActivityCount LeadActivityObj = new BatchLeadActivityCount(); 
            Database.executeBatch(LeadActivityObj,200); 
  	}
}