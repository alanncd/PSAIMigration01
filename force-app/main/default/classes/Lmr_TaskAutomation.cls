public with sharing class Lmr_TaskAutomation {

  public static Task taskCalloutRefactor(String recordId,String idTemplate){
    try{
      Id ownerId;
      String objectUsed = Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(recordId);
      if(objectUsed =='Lead'){
          ownerId = [Select ownerId FROM Lead WHERE id =:recordId].ownerId;
      }else if(objectUsed =='Contact'){
          ownerId = [Select ownerId FROM Contact WHERE id =:recordId].ownerId;
      }else if(objectUsed =='Opportunity'){
        ownerId = [Select ownerId FROM Opportunity WHERE id =:recordId].ownerId;
      }else if(objectUsed =='Transactions__c' || objectUsed =='Left_Main__Transactions__c'){
        ownerId = [Select ownerId from Transactions__c where Id=:recordId].ownerId;
      }else if(objectUsed =='Interested_Buyers__c' || objectUsed =='Left_Main__Interested_Buyers__c'){
        ownerId = [Select Transactions__r.OwnerId FROM Interested_Buyers__c WHERE id =:recordId].Transactions__r.ownerId;
      }

      List<Task_Follow_Up_Sequence__c> taskTemplateFolder = [Select Id,AssignedUser__c,Task_Subject__c,Comments__c From Task_Follow_Up_Sequence__c WHERE Id =: idTemplate WITH USER_MODE];

      Task newTask= New Task();
  LeftMain_SecurityUtils.checkRead(Task.SObjectType,new List<String> {
                    'Subject',
                  'ActivityDate',
                  'Description',
                  'WhoID',
                          'WhatId',
                          'OwnerId',
                          'Information__c'
              });
                             
      newTask.Subject = taskTemplateFolder[0].Task_Subject__c;
      newTask.ActivityDate = System.today();
      newTask.Description = taskTemplateFolder[0].Comments__c;   
      //whoId lead
      if(objectUsed =='Lead' || objectUsed =='Contact'){
        newTask.WhoID=recordId;}
      else{
        newTask.WhatId =recordId;
      }
      if(String.isBlank(taskTemplateFolder[0].AssignedUser__c)){
        newTask.OwnerId = ownerId;
      }else{newTask.OwnerId = taskTemplateFolder[0].AssignedUser__c;
      }
      
      newTask.Information__c = 'Task now Cadence';

      LeftMain_SecurityUtils.checkInsert(Task.SObjectType,new List<String> {
        'Subject',
        'ActivityDate',
        'Description',
        'WhoID',
        'WhatId',
        'OwnerId',
        'Information__c'
        });  

      return newTask;}catch(Exception e){ErrorHandler_cls.handleException(e,'Future Task Now');
      return null ;
      }
  }

  public static void taskCallout(String recordId,String idTemplate){
    try{
      Id ownerId;
      String objectUsed = Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(recordId);
      if(objectUsed =='Lead'){
          ownerId = [Select ownerId FROM Lead WHERE id =:recordId].ownerId;
      }else if(objectUsed =='Contact'){
          ownerId = [Select ownerId FROM Contact WHERE id =:recordId].ownerId;
      }else if(objectUsed =='Opportunity'){
        ownerId = [Select ownerId FROM Opportunity WHERE id =:recordId].ownerId;
      }else if(objectUsed =='Transactions__c' || objectUsed =='Left_Main__Transactions__c'){
        ownerId = [Select ownerId from Transactions__c where Id=:recordId].ownerId;
      }else if(objectUsed =='Interested_Buyers__c' || objectUsed =='Left_Main__Interested_Buyers__c'){
        ownerId = [Select Transactions__r.OwnerId FROM Interested_Buyers__c WHERE id =:recordId].Transactions__r.ownerId;
      }

      List<Task_Follow_Up_Sequence__c> taskTemplateFolder = [Select Id,AssignedUser__c,Task_Subject__c,Comments__c From Task_Follow_Up_Sequence__c WHERE Id =: idTemplate WITH USER_MODE];

      Task newTask= New Task();
  LeftMain_SecurityUtils.checkRead(Task.SObjectType,new List<String> {
                    'Subject',
                  'ActivityDate',
                  'Description',
                  'WhoID',
                          'WhatId',
                          'OwnerId',
                          'Information__c'
              });
                             
      newTask.Subject = taskTemplateFolder[0].Task_Subject__c;
      newTask.ActivityDate = System.today();
      newTask.Description = taskTemplateFolder[0].Comments__c;   
      //whoId lead
      if(objectUsed =='Lead' || objectUsed =='Contact'){
        newTask.WhoID=recordId;}
      else{
        newTask.WhatId =recordId;
      }
      if(String.isBlank(taskTemplateFolder[0].AssignedUser__c)){
        newTask.OwnerId = ownerId;
      }else{newTask.OwnerId = taskTemplateFolder[0].AssignedUser__c;
      }
      
      newTask.Information__c = 'Task now Cadence';

      LeftMain_SecurityUtils.checkInsert(Task.SObjectType,new List<String> {
        'Subject',
        'ActivityDate',
        'Description',
        'WhoID',
        'WhatId',
        'OwnerId',
        'Information__c'
        });
        List<Task> listTasks = new List<Task>();
        listTasks.add(newTask);
        SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, listTasks);
        Database.insert(listTasks = decision3.getRecords());}catch(Exception e){ErrorHandler_cls.handleException(e,'Future Task Now');
      }
  }

    @future
    public static void createTaskNow(String recordId,String idTemplate){
      taskCallout(recordId, idTemplate);
    }
    
  
}