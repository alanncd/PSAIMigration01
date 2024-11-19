global with sharing class BatchLeadEmailSequence implements
Database.Batchable<sObject>, Database.Stateful,Schedulable{ 
    
    global Map<Integer,Lead_Follow_Up_Sequence__c> dayWithFollowUpSequence;
    global BatchLeadEmailSequence(){ 
        dayWithFollowUpSequence = new Map<Integer,Lead_Follow_Up_Sequence__c>();
        List<Lead_Follow_Up_Sequence__c> EmailTemplateList = [SELECT Id, Days__c, Email_Template_Id__c, 
                                                                         Email_Template_Name__c FROM Lead_Follow_Up_Sequence__c 
                                                                         WHERE Days__c != null AND Email_Template_Id__c != null 
                                                                         AND Email_Template_Name__c != null WITH USER_MODE LIMIT 10000];
        for(Lead_Follow_Up_Sequence__c followUpObj : EmailTemplateList){
            dayWithFollowUpSequence.put(Integer.valueOf(followUpObj.Days__c),followUpObj);
        }
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String SOQLLead = 'SELECT Id, Name,ownerID,Email,Enable_Lead_Follow_Up_Sequence__c,Sequence_Day__c,HasOptedOutOfEmail FROM Lead '+
            +' WHERE IsConverted = false AND Enable_Lead_Follow_Up_Sequence__c = true AND Email != null AND EmailBouncedReason = NULL LIMIT 5000000';
        return Database.getQueryLocator(SOQLLead); 
    }
    global void execute(Database.BatchableContext bc, List<Lead> scope){
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {};
        List<Task> taskInsertList = new List<Task>();
        List<Lead> LeadUpdateList = new  List<Lead>();
        for(Lead LeadObj : scope){
            LeadObj.Sequence_Day__c = LeadObj.Sequence_Day__c != null ? (LeadObj.Sequence_Day__c + 1) : 1;
            Integer leadSequenceDay = Integer.valueOf(LeadObj.Sequence_Day__c);
            if(!LeadObj.HasOptedOutOfEmail  && dayWithFollowUpSequence != null && 
               				dayWithFollowUpSequence.size() > 0 && dayWithFollowUpSequence.containsKey(leadSequenceDay)){
                Lead_Follow_Up_Sequence__c leadfollowUpObj =  dayWithFollowUpSequence.get(leadSequenceDay);
                Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
                message.setTargetObjectId(LeadObj.Id); 
                message.setTemplateId(leadfollowUpObj.Email_Template_Id__c);
                message.setSaveAsActivity(false);
                messages.add(message);
                Task taskObj = new Task(); 
                taskObj.whoID = LeadObj.Id;
                taskObj.Subject = 'Email-Sequence : '+leadfollowUpObj.Email_Template_Name__c;
                taskObj.Priority = 'Normal';
                taskObj.Status = 'Completed';
                taskObj.ownerID = LeadObj.ownerID;
                taskInsertList.add(taskObj); 
            }
            LeadUpdateList.add(LeadObj);
        }
        if(!messages.isEmpty()){
            try{
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages,false);
            if(!taskInsertList.isEmpty()){
                LeftMain_SecurityUtils.checkInsert(Task.SObjectType,new List<String> {'whoID','Subject','Priority','Status'});
               // insert taskInsertList;
                SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, taskInsertList);
                taskInsertList = decision3.getRecords();
                Database.insert(taskInsertList);
            }}catch(Exception e){
                System.debug('error: '+e);
            }
        }
        if(!LeadUpdateList.isEmpty()){
            LeftMain_SecurityUtils.checkUpdate(Lead.SObjectType,new List<String> {'Sequence_Day__c'});
            SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.UPDATABLE, LeadUpdateList);
            LeadUpdateList = decision2.getRecords();
            Database.update(LeadUpdateList);
        }
    }
    
    global void finish(Database.BatchableContext bc){
      
    }

    global void execute(SchedulableContext ctx) {
        //Use this for sechdule 
        String cronExpression = '0 0 8 * * ? *';
        // Schedule batch process
        BatchLeadEmailSequence batch = new BatchLeadEmailSequence();
        Database.executeBatch(batch,1);
    }

}