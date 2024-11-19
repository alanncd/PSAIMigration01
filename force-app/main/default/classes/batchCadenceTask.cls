global with sharing class batchCadenceTask implements Database.Batchable<sObject>,Database.Stateful,Schedulable{
   // global List<ErrorHandlerLmr__c> listScheduleCadence = new List<ErrorHandlerLmr__c>();
   global List<ScheduleCadenceTask__c> listScheduleCadenceTask = new List<ScheduleCadenceTask__c>();
    global Map<Id,String> mapLog = New Map<Id,String>();
    global List<ErrorHandlerLmr__c> listScheduleCadenceError = new List<ErrorHandlerLmr__c>();

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        DateTime currentTime = System.now();
        String query = 'Select Name,OwnerId,IdTemplate__c,Related_Record_id__c,Sequence__c,Status__c,Time_to_be_dispatched__c,Lead__r.OwnerId,Opportunity__r.OwnerId,Contact__r.OwnerId,Transactions__r.OwnerId,Interested_Buyers__r.Transactions__r.OwnerId FROM ScheduleCadenceTask__c WHERE Time_to_be_dispatched__c <=: currentTime AND Status__c = \'Pending\' ORDER BY CreatedDate desc LIMIT 9000';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<ScheduleCadenceTask__c> scope)
    {
        Set<Id> listTemplatesIds = new Set<Id>();
        map<Id,Task_Follow_Up_Sequence__c> mapTemplates = New map<Id,Task_Follow_Up_Sequence__c>();

        List<Task> newListTask = New List<Task>();
        String log ='Initial Log'+'<br />';
        
        try{
        for(ScheduleCadenceTask__c scheduledTask: scope ){
            listScheduleCadenceTask.add(scheduledTask);
            listTemplatesIds.add(scheduledTask.IdTemplate__c);
        }
        List<Task_Follow_Up_Sequence__c> taskTemplateFolder = [Select Id,AssignedUser__c,Task_Subject__c,Comments__c From Task_Follow_Up_Sequence__c WHERE Id IN: listTemplatesIds WITH USER_MODE ];


        for(Task_Follow_Up_Sequence__c listTaskFollowUp:taskTemplateFolder ){
            mapTemplates.put(listTaskFollowUp.Id,listTaskFollowUp);
        }

            for(ScheduleCadenceTask__c scheduledTask: scope ){
                mapLog.put(scheduledTask.Id,'');
                log = '';
               log+= scheduledTask+'<br />';
                String objectUsed = Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(scheduledTask.Related_Record_id__c);    
                Task newTask= New Task();
                newTask.Subject = mapTemplates.get(scheduledTask.IdTemplate__c).Task_Subject__c;
                newTask.ActivityDate = System.today();
                newTask.Description = mapTemplates.get(scheduledTask.IdTemplate__c).Comments__c;   
                //whoId lead
                if(objectUsed =='Lead' || objectUsed =='Contact'){
                  newTask.WhoID=scheduledTask.Related_Record_id__c;}
                else{
                  newTask.WhatId =scheduledTask.Related_Record_id__c;
                }
                newTask.OwnerId = scheduledTask.ownerId;
                newTask.Information__c = 'Task Schedule Cadence';

                if(String.isNotBlank(mapTemplates.get(scheduledTask.IdTemplate__c).AssignedUser__c)){
                    newTask.OwnerId = mapTemplates.get(scheduledTask.IdTemplate__c).AssignedUser__c;
                }else{
                    if(objectUsed =='Lead'){
                        newTask.OwnerId = scheduledTask.Lead__r?.OwnerId;
                    }else if(objectUsed =='Opportunity'){
                        newTask.OwnerId = scheduledTask.Opportunity__r?.OwnerId;
                    }else if(objectUsed =='Contact'){
                        newTask.OwnerId = scheduledTask.Contact__r?.OwnerId;
                    }else if(objectUsed =='Transactions__c' || objectUsed =='Left_Main__Transactions__c'){
                        newTask.OwnerId = scheduledTask.Transactions__r?.OwnerId;
                    }else if(objectUsed =='Interested_Buyers__c' || objectUsed =='Left_Main__Interested_Buyers__c'){
                        newTask.OwnerId = scheduledTask.Interested_Buyers__r?.Transactions__r.OwnerId;
                    }
                }
                if(String.isBlank(newTask.OwnerId)){
                    log+= 'owner not exist';
                    mapLog.put(scheduledTask.Id,log);
                    continue;
                }
                newListTask.add(newTask);

                log+= 'End batch Task';
                mapLog.put(scheduledTask.Id,log);

            }

            LeftMain_SecurityUtils.checkInsert(Task.SObjectType,new List<String> {
                'Information__c',
                 'OwnerId',
                 'WhoID',
                 'WhatId',
                 'Subject',
                 'ActivityDate',
                 'Description'
            });
            SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, newListTask);
            newListTask = decision3.getRecords();

            Database.SaveResult[] srList = Database.insert(newListTask, false);

            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                        ErrorHandlerLmr__c errorHandler = new ErrorHandlerLmr__c();
                        errorHandler.ProcessName__c = 'Batch Cadence task';
                        errorHandler.LogDetail__c = err.getStatusCode() + ': ' + err.getMessage()+'; fields that affected this error: ' + err.getFields();
                        listScheduleCadenceError.add(errorHandler);
                    }
                }
            }


            System.debug('termine de insertar');
                }catch(Exception e){
                    ErrorHandler_cls.handleException(e,'Future Task batch');
                }
    }

    global void finish(Database.BatchableContext BC)
    {
		Integer maxLogLimit = SObjectType.ScheduleCadenceTask__c.Fields.Log__c.Length;
        
        for(ScheduleCadenceTask__c iterateScheduledTask: listScheduleCadenceTask){

            iterateScheduledTask.Status__c ='Completed';
        }

        LeftMain_SecurityUtils.checkUpdate(ScheduleCadenceTask__c.SObjectType,new List<String> {'Status__c'});
        SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.UPDATABLE, listScheduleCadenceTask);
        listScheduleCadenceTask = decision1.getRecords();
        Database.update(listScheduleCadenceTask);
        //update listScheduleCadenceTask;
        
         for(ScheduleCadenceTask__c iterateScheduledTask: listScheduleCadenceTask){
             if( mapLog.get(iterateScheduledTask.Id) != NULL){
                if ( mapLog.get(iterateScheduledTask.Id).length() >=  maxLogLimit ){
                    String oldLog = mapLog.get(iterateScheduledTask.Id);
                    String newLog = oldLog.substring(0,(maxLogLimit-80));
                    iterateScheduledTask.Log__c = newLog;
                }else{
                iterateScheduledTask.Log__c = mapLog.get(iterateScheduledTask.Id);  
                }
            }
        }
        LeftMain_SecurityUtils.checkUpdate(ScheduleCadenceTask__c.SObjectType,new List<String> {'Status__c','Log__c'});

        SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.UPDATABLE, listScheduleCadenceTask);
        listScheduleCadenceTask = decision2.getRecords();
        Database.update(listScheduleCadenceTask);

        LeftMain_SecurityUtils.checkInsert(ErrorHandlerLmr__c.SObjectType,new List<String> {'ProcessName__c','LogDetail__c'});

        SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, listScheduleCadenceError);
        listScheduleCadenceError = decision3.getRecords();
        Database.insert(listScheduleCadenceError);

    }

    global void execute(SchedulableContext sc) {
        batchCadenceTask batchObj = new batchCadenceTask(); 
         if(!Test.isRunningTest()){
            database.executebatch(batchObj,500);
        }
    }

}