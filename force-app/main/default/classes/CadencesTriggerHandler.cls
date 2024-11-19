public with sharing class CadencesTriggerHandler {
  private static Map<String, List<LMR_TemplateSms__c>> mapFilterSmsTemplate = new Map<String, List<LMR_TemplateSms__c>>();
  private static Map<String, List<Lead_Follow_Up_Sequence__c>> mapFolderTemplate = new Map<String, List<Lead_Follow_Up_Sequence__c>>();
  private static Map<String, List<Task_Follow_Up_Sequence__c>> mapFolderTask = new Map<String, List<Task_Follow_Up_Sequence__c>>();

  private static List<ScheduleCadence__c> listInsertedCadences = new List<ScheduleCadence__c>();
  private static List<ScheduleCadenceEmail__c> listInsertedCadencesEmail = new List<ScheduleCadenceEmail__c>();
  private static List<ScheduleCadenceTask__c> listInsertedCadencesTask = new List<ScheduleCadenceTask__c>();


  public static void processBulkCadence(List<Cadences__c> newRecordList) {

    Set<String> FolderSms = new Set<String>();
    Set<String> FolderEmail = new Set<String>();
    Set<String> FolderTask = new Set<String>();
    Map<String,String> newMap = new Map<String,String>();

    //Loop for Ids
    Set<String> targetIds = new Set<String>();
    for (Cadences__c c : newRecordList) {
      targetIds.add(c.TargetId__c);
      newMap.put(c.TargetId__c,c.Id);
      FolderSms.add(c.SmsFolder__c);
      FolderEmail.add(c.FolderEmail__c);
      FolderTask.add(c.TaskEmailTemplate__c);
    }
    List<LMR_TemplateSms__c> listTemplateSmss = new List<LMR_TemplateSms__c>();
    listTemplateSmss = [
      SELECT Name, Body__c, TypeOfSchedule__c, Schedule__c, Folder__c
      FROM LMR_TemplateSms__c
      WHERE Folder__c IN :FolderSms AND Folder__c != NULL WITH USER_MODE LIMIT 10000];

    List<Lead_Follow_Up_Sequence__c> listTemplateEmails = new List<Lead_Follow_Up_Sequence__c>();
    listTemplateEmails = [
      SELECT
        Email__c,
        Email_Template_Id__c,
        Days__c,
        Folder__c,
        Email_Template_Name__c,
        TypeOfSchedule__c
      FROM Lead_Follow_Up_Sequence__c
      WHERE Folder__c IN :FolderEmail AND Folder__c != NULL WITH USER_MODE LIMIT 10000];

    List<Task_Follow_Up_Sequence__c> listTemplateTasks = new List<Task_Follow_Up_Sequence__c>();
    listTemplateTasks = [
      SELECT Id, Name, Number__c, Task_Cadence_Folder__c, Frequency__c
      FROM Task_Follow_Up_Sequence__c
      WHERE
        Task_Cadence_Folder__c IN :FolderTask
        AND Task_Cadence_Folder__c != NULL WITH USER_MODE LIMIT 10000];

    if (
      listTemplateSmss.size() > 0 ||
      CadencesTrigger__c.getOrgDefaults().activateSmartphone__c
    ) {
      QueuableFutureMethodBulkSMS Sms = new QueuableFutureMethodBulkSMS(
        targetIds,
        listTemplateSmss,
        newMap
      );
      system.enqueueJob(Sms);
    }
    if (
      listTemplateEmails.size() > 0 ||
      CadencesTrigger__c.getOrgDefaults().EmailAutomation__c
    ) {
      QueuableFutureMethodBulkEmail Email = new QueuableFutureMethodBulkEmail(
        targetIds,
        listTemplateEmails,
        newMap
      );
      system.enqueueJob(Email);
    }
    if (
      listTemplateTasks.size() > 0 ||
      CadencesTrigger__c.getOrgDefaults().TaskAutomation__c
    ) {
      QueuableFutureMethodBulkTask Task = new QueuableFutureMethodBulkTask(
        targetIds,
        listTemplateTasks,
        newMap
      );
      system.enqueueJob(Task);
    }
  }

  public static void setRecordId(List<Cadences__c> newRecordList) {
    for (Cadences__c cadence : newRecordList) {
      if (cadence.TargetId__c != null) {
        String objectUsed = Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(
          cadence.TargetId__c
        );

        if (objectUsed == 'Lead') {
          cadence.Lead__c = cadence.TargetId__c;
        } else if (objectUsed == 'Opportunity') {
          cadence.Opportunity__c = cadence.TargetId__c;
        } else if (objectUsed == 'Contact') {
          cadence.Contact__c = cadence.TargetId__c;
        } else if (objectUsed == 'Transactions__c' || objectUsed == 'Left_Main__Transactions__c') {
          cadence.Transactions__c = cadence.TargetId__c;
        } else if (objectUsed == 'Interested_Buyers__c'  || objectUsed == 'Left_Main__Interested_Buyers__c') {
          cadence.Interested_Buyers__c = cadence.TargetId__c;
        }
      }
    }
    stopCadences(newRecordList);
  }

  public with sharing class QueuableFutureMethodBulkSMS implements Queueable {
    private Set<string> targetObjectListId;
    private List<LMR_TemplateSms__c> listTemplateSms;
    private map<String,String> newMap;

    public QueuableFutureMethodBulkSMS(
      Set<string> targetObjectListId,
      List<LMR_TemplateSms__c> listTemplateSms,
      map<String,String> newMap
    ) {
      this.targetObjectListId = targetObjectListId;
      this.listTemplateSms = listTemplateSms;
      this.newMap = newMap;
    }
    public void execute(QueueableContext qc) {
      List<LMR_TemplateSms__c> listNow = new List<LMR_TemplateSms__c>();
      List<LMR_TemplateSms__c> listMinutes = new List<LMR_TemplateSms__c>();
      List<LMR_TemplateSms__c> listDays = new List<LMR_TemplateSms__c>();
      List<LMR_TemplateSms__c> listHours = new List<LMR_TemplateSms__c>();

      if (listTemplateSms.size() > 0) {
        for (LMR_TemplateSms__c templateIterate : listTemplateSms) {
          if (templateIterate.TypeOfSchedule__c == 'Now') {
            listNow.add(templateIterate);
          } else if (templateIterate.TypeOfSchedule__c == 'Minutes') {
            listMinutes.add(templateIterate);
          } else if (templateIterate.TypeOfSchedule__c == 'Days') {
            listDays.add(templateIterate);
          } else if (templateIterate.TypeOfSchedule__c == 'Hours') {
            listHours.add(templateIterate);
          }
          mapFilterSmsTemplate.put('Now', listNow);
          mapFilterSmsTemplate.put('Minutes', listMinutes);
          mapFilterSmsTemplate.put('Days', listDays);
          mapFilterSmsTemplate.put('Hours', listHours);
        }
      }
      //now
      if (mapFilterSmsTemplate.get('Now') != null) {
        for (
          LMR_TemplateSms__c iterateTemplate : mapFilterSmsTemplate.get('Now')
        ) {
          Integer intConvertedValue = 0;
          for (String toi : targetObjectListId) {
            String cadencesId = newMap.get(toi);
            ScheduleCadence__c cadenceNow = instanceCadences(
              toi,
              'Now',
              iterateTemplate.Id,
              iterateTemplate.Name,
              intConvertedValue,
              cadencesId
            );

            listInsertedCadences.add(cadenceNow);
          }
          
        }
        LeftMain_SecurityUtils.checkInsert(ScheduleCadence__c.SObjectType,new List<String> {
          'Sequence__c',
          'IdTemplate__c',
          'Frecuency_To_Flow__c',
          'TargetId__c',
          'Name',
          'Cadence__c',
          'transactions__c',
          'Contact__c',
          'Lead__c',
          'Opportunity__c',
          'interested_buyers__c'
        });

        SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, listInsertedCadences);
        Database.insert(listInsertedCadences = decision3.getRecords());

        List<Id> insertedCadenceIds = new List<Id>();
        for(Integer i = 0; i < listInsertedCadences.size(); i++) {
         insertedCadenceIds.add(listInsertedCadences[i].Id);
        }

        ExecuteBatchCalloutCadenceSMS.executeBatch(insertedCadenceIds);
        listInsertedCadences.clear();
      }
      //Minutes
      if (mapFilterSmsTemplate.get('Minutes') != null) {
        for (
          LMR_TemplateSms__c iterateTemplate : mapFilterSmsTemplate.get(
            'Minutes'
          )
        ) {
          Integer intConvertedValue = iterateTemplate.Schedule__c.intValue();
          for (String toi : targetObjectListId) {
            String cadencesId = newMap.get(toi);

            ScheduleCadence__c cadenceMinutes = instanceCadences(
              toi,
              'Minutes',
              iterateTemplate.Id,
              iterateTemplate.Name,
              intConvertedValue,
              cadencesId
            );
            listInsertedCadences.add(cadenceMinutes);
          }
        }
      }

      //Days
      if (mapFilterSmsTemplate.get('Days') != null) {
        for (
          LMR_TemplateSms__c iterateTemplate : mapFilterSmsTemplate.get('Days')
        ) {
          Integer intConvertedValue = iterateTemplate.Schedule__c.intValue();
          for (String toi : targetObjectListId) {
            String cadencesId = newMap.get(toi);

            ScheduleCadence__c cadenceDays = instanceCadences(
              toi,
              'Days',
              iterateTemplate.Id,
              iterateTemplate.Name,
              intConvertedValue,
              cadencesId
            );
            listInsertedCadences.add(cadenceDays);
          }
        }
      }

      if (mapFilterSmsTemplate.get('Hours') != null) {
        for (
          LMR_TemplateSms__c iterateTemplate : mapFilterSmsTemplate.get('Hours')
        ) {
          Integer intConvertedValue = iterateTemplate.Schedule__c.intValue();
          for (String toi : targetObjectListId) {
            String cadencesId = newMap.get(toi);

            ScheduleCadence__c cadenceHours = instanceCadences(
              toi,
              'Hours',
              iterateTemplate.Id,
              iterateTemplate.Name,
              intConvertedValue,
              cadencesId
            );
            listInsertedCadences.add(cadenceHours);
          }
        }
      }

      LeftMain_SecurityUtils.checkInsert(ScheduleCadence__c.SObjectType,new List<String> {
        'Sequence__c',
        'IdTemplate__c',
        'Frecuency_To_Flow__c',
        'TargetId__c',
        'Name',
        'Cadence__c',
        'transactions__c',
        'Contact__c',
        'Lead__c',
        'Opportunity__c',
        'interested_buyers__c'
      });
      SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, listInsertedCadences);
      Database.insert(listInsertedCadences = decision3.getRecords());
    }
  }
  public with sharing class QueuableFutureMethodBulkEmail implements Queueable {
    private Set<string> targetObjectListId;
    private List<Lead_Follow_Up_Sequence__c> listTemplateEmail;
    private map<String,String> newMap;

    public QueuableFutureMethodBulkEmail(
      Set<string> targetObjectListId,
      List<Lead_Follow_Up_Sequence__c> listTemplateEmail,
      map<String,String> newMap
    ) {
      this.targetObjectListId = targetObjectListId;
      this.listTemplateEmail = listTemplateEmail;
      this.newMap = newMap;
    }
    public void execute(QueueableContext qc) {
      List<Lead_Follow_Up_Sequence__c> listEmailNow = new List<Lead_Follow_Up_Sequence__c>();
      List<Lead_Follow_Up_Sequence__c> listEmailDays = new List<Lead_Follow_Up_Sequence__c>();
      List<Lead_Follow_Up_Sequence__c> listEmailHours = new List<Lead_Follow_Up_Sequence__c>();
      List<Lead_Follow_Up_Sequence__c> listEmailMinutes = new List<Lead_Follow_Up_Sequence__c>();

      for (Lead_Follow_Up_Sequence__c emailTemplate : listTemplateEmail) {
        if (emailTemplate.Days__c == 0) {
          listEmailNow.add(emailTemplate);
        } else if (
          emailTemplate.Days__c != null &&
          (String.isBlank(emailTemplate.TypeOfSchedule__c) ||
          emailTemplate.TypeOfSchedule__c == 'Days')
        ) {
          listEmailDays.add(emailTemplate);
        } else if (
          emailTemplate.Days__c != null &&
          emailTemplate.TypeOfSchedule__c == 'Minutes'
        ) {
          listEmailMinutes.add(emailTemplate);
        } else if (
          emailTemplate.Days__c != null &&
          emailTemplate.TypeOfSchedule__c == 'Hours'
        ) {
          listEmailHours.add(emailTemplate);
        }
      }

      mapFolderTemplate.put('Now', listEmailNow);
      mapFolderTemplate.put('Days', listEmailDays);
      mapFolderTemplate.put('Minutes', listEmailMinutes);
      mapFolderTemplate.put('Hours', listEmailHours);

      if (mapFolderTemplate.get('Now') != null) {
        for (
          Lead_Follow_Up_Sequence__c iterateTemplate : mapFolderTemplate.get(
            'Now'
          )
        ) {
          Integer intConvertedValue = 0;
          for (String toi : targetObjectListId) {
            String cadencesId = newMap.get(toi);

            ScheduleCadenceEmail__c cadenceEmailNow = instanceCadencesEmail(
              toi,
              'Now',
              intConvertedValue,
              iterateTemplate.Email_Template_Id__c,
              iterateTemplate.Email_Template_Name__c,
              iterateTemplate.Email__c,
              cadencesId
            );
            listInsertedCadencesEmail.add(cadenceEmailNow);
          }
        }
        LeftMain_SecurityUtils.checkInsert(ScheduleCadenceEmail__c.SObjectType,new List<String> {
          'related_record_id__c',
          'frecuency__c',
          'sequence__c',
          'idtemplate__c',
          'Name',
          'email__c',
          'cadence__c',
          'Contact__c',
          'Lead__c',
          'Opportunity__c',
          'transactions__c',
          'interested_buyers__c'
        });

         SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, listInsertedCadencesEmail);
         Database.insert(listInsertedCadencesEmail = decision3.getRecords());

         List<Id> insertedCadenceIds = new List<Id>();
         for(Integer i = 0; i < listInsertedCadencesEmail.size(); i++) {
          insertedCadenceIds.add(listInsertedCadencesEmail[i].Id);
         }
         ExecuteBatchNowCadenceEmails.executeBatch(insertedCadenceIds);
         listInsertedCadencesEmail.clear();
      }
      if (mapFolderTemplate.get('Days') != null) {
        for (
          Lead_Follow_Up_Sequence__c iterateTemplate : mapFolderTemplate.get(
            'Days'
          )
        ) {
          Integer intConvertedValue = iterateTemplate.Days__c.intValue();
          for (String toi : targetObjectListId) {
            String cadencesId = newMap.get(toi);

            ScheduleCadenceEmail__c cadenceEmailDays = instanceCadencesEmail(
              toi,
              'Days',
              intConvertedValue,
              iterateTemplate.Email_Template_Id__c,
              iterateTemplate.Email_Template_Name__c,
              iterateTemplate.Email__c,
              cadencesId
            );
            listInsertedCadencesEmail.add(cadenceEmailDays);
          }
        }
      }
      if (mapFolderTemplate.get('Hours') != null) {
        for (
          Lead_Follow_Up_Sequence__c iterateTemplate : mapFolderTemplate.get(
            'Hours'
          )
        ) {
          Integer intConvertedValue = iterateTemplate.Days__c.intValue();
          for (String toi : targetObjectListId) {
            String cadencesId = newMap.get(toi);

            ScheduleCadenceEmail__c cadenceEmailDays = instanceCadencesEmail(
              toi,
              'Hours',
              intConvertedValue,
              iterateTemplate.Email_Template_Id__c,
              iterateTemplate.Email_Template_Name__c,
              iterateTemplate.Email__c,
              cadencesId
            );
            listInsertedCadencesEmail.add(cadenceEmailDays);
          }
        }
      }
      if (mapFolderTemplate.get('Minutes') != null) {
        for (
          Lead_Follow_Up_Sequence__c iterateTemplate : mapFolderTemplate.get(
            'Minutes'
          )
        ) {
          Integer intConvertedValue = iterateTemplate.Days__c.intValue();
          for (String toi : targetObjectListId) {
            String cadencesId = newMap.get(toi);

            ScheduleCadenceEmail__c cadenceEmailDays = instanceCadencesEmail(
              toi,
              'Minutes',
              intConvertedValue,
              iterateTemplate.Email_Template_Id__c,
              iterateTemplate.Email_Template_Name__c,
              iterateTemplate.Email__c,
              cadencesId
            );
            listInsertedCadencesEmail.add(cadenceEmailDays);
          }
        }
      }

      SObjectAccessDecision securityDecision = Security.stripInaccessible(
        AccessType.CREATABLE,
        listInsertedCadencesEmail
      );
      upsert securityDecision.getRecords();
      //upsert listInsertedCadencesEmail;
    }
  }
  public with sharing class QueuableFutureMethodBulkTask implements Queueable {
    private List<Task_Follow_Up_Sequence__c> listTemplateTask;
    private Set<string> targetObjectListId;
    map<String,String> newMap;

    public QueuableFutureMethodBulkTask(
      Set<string> targetObjectListId,
      List<Task_Follow_Up_Sequence__c> listTemplateTask,
      map<String,String> newMap
    ) {
      this.listTemplateTask = listTemplateTask;
      this.targetObjectListId = targetObjectListId;
      this.newMap = newMap;
    }

    public void execute(QueueableContext qc) {
      List<Task_Follow_Up_Sequence__c> listNow = new List<Task_Follow_Up_Sequence__c>();
      List<Task_Follow_Up_Sequence__c> listHours = new List<Task_Follow_Up_Sequence__c>();
      List<Task_Follow_Up_Sequence__c> listDays = new List<Task_Follow_Up_Sequence__c>();
      List<Task_Follow_Up_Sequence__c> listMinutes = new List<Task_Follow_Up_Sequence__c>();

      for (Task_Follow_Up_Sequence__c taskTemplate : listTemplateTask) {
        if (taskTemplate.Frequency__c == 'Now') {
          listNow.add(taskTemplate);
        } else if (taskTemplate.Frequency__c == 'Hours') {
          listHours.add(taskTemplate);
        } else if (taskTemplate.Frequency__c == 'Days') {
          listDays.add(taskTemplate);
        } else if (taskTemplate.Frequency__c == 'Minutes') {
          listMinutes.add(taskTemplate);
        }
      }

      mapFolderTask.put('Now', listNow);
      mapFolderTask.put('Hours', listHours);
      mapFolderTask.put('Days', listDays);
      mapFolderTask.put('Minutes', listMinutes);

      if (mapFolderTask.get('Now') != null) {
        for (
          Task_Follow_Up_Sequence__c iterateTemplate : mapFolderTask.get('Now')
        ) {
          Integer intConvertedValue = 0;
          for (String toi : targetObjectListId) {
            String cadencesId = newMap.get(toi);

            ScheduleCadenceTask__c cadenceTaskNow = instanceCadencesTask(
              toi,
              intConvertedValue,
              iterateTemplate.Id,
              iterateTemplate.Name,
              'Now',
              cadencesId
            );
            listInsertedCadencesTask.add(cadenceTaskNow);
          }
        }
        LeftMain_SecurityUtils.checkInsert(ScheduleCadenceTask__c.SObjectType,new List<String> {
          'Cadence__c',
          'Name',
          'Contact__c',
          'Frecuency_To_Flow__c',
          'IdTemplate__c',
          'Interested_Buyers__c',
          'Lead__c',
          'Log__c',
          'Related_Record_id__c',
          'Sequence__c',
          'Status__c',
          'Transactions__c',
          'Opportunity__c'
        });

        SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, listInsertedCadencesTask);
        Database.insert(listInsertedCadencesTask = decision3.getRecords());

        List<Id> insertedCadenceIds = new List<Id>();
        for(Integer i = 0; i < listInsertedCadencesTask.size(); i++) {
         insertedCadenceIds.add(listInsertedCadencesTask[i].Id);
        }
        
        ExecuteBatchNowCadenceTasks.executeBatch(insertedCadenceIds);
        listInsertedCadencesTask.clear();
      }
      if (mapFolderTask.get('Hours') != null) {
        for (
          Task_Follow_Up_Sequence__c iterateTemplate : mapFolderTask.get(
            'Hours'
          )
        ) {
          Integer intConvertedValue = iterateTemplate.Number__c.intValue();
          for (String toi : targetObjectListId) {
            String cadencesId = newMap.get(toi);

            ScheduleCadenceTask__c cadenceTaskHours = instanceCadencesTask(
              toi,
              intConvertedValue,
              iterateTemplate.Id,
              iterateTemplate.Name,
              'Hours',
              cadencesId
            );
            listInsertedCadencesTask.add(cadenceTaskHours);
          }
        }
      }
      if (mapFolderTask.get('Minutes') != null) {
        for (
          Task_Follow_Up_Sequence__c iterateTemplate : mapFolderTask.get(
            'Minutes'
          )
        ) {
          Integer intConvertedValue = iterateTemplate.Number__c.intValue();
          for (String toi : targetObjectListId) {
            String cadencesId = newMap.get(toi);

            ScheduleCadenceTask__c cadenceTaskMinutes = instanceCadencesTask(
              toi,
              intConvertedValue,
              iterateTemplate.Id,
              iterateTemplate.Name,
              'Minutes',
              cadencesId
            );
            listInsertedCadencesTask.add(cadenceTaskMinutes);
          }
        }
      }
      if (mapFolderTask.get('Days') != null) {
        for (
          Task_Follow_Up_Sequence__c iterateTemplate : mapFolderTask.get('Days')
        ) {
          Integer intConvertedValue = iterateTemplate.Number__c.intValue();
          for (String toi : targetObjectListId) {
            String cadencesId = newMap.get(toi);

            ScheduleCadenceTask__c cadenceTaskDays = instanceCadencesTask(
              toi,
              intConvertedValue,
              iterateTemplate.Id,
              iterateTemplate.Name,
              'Days',
              cadencesId
            );
            listInsertedCadencesTask.add(cadenceTaskDays);
          }
        }
      }

      LeftMain_SecurityUtils.checkInsert(ScheduleCadenceTask__c.SObjectType,new List<String> {
        'Cadence__c',
        'Name',
        'Contact__c',
        'Frecuency_To_Flow__c',
        'IdTemplate__c',
        'Interested_Buyers__c',
        'Lead__c',
        'Log__c',
        'Related_Record_id__c',
        'Sequence__c',
        'Status__c',
        'Transactions__c',
        'Opportunity__c'
      });
      SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, listInsertedCadencesTask);
      Database.insert(listInsertedCadencesTask = decision3.getRecords());
    }
  }

  @AuraEnabled(cacheable=true)
  public static CadencesTrigger__c getCustomSettings() {
    return CadencesTrigger__c.getOrgDefaults();
  }

  @InvocableMethod(
    label='Stop Cadences Sobject'
    description='Stop Cadences Sobject'
    category='Cadences'
  )
  public static void stopCadenceTrigger(List<Sobject> listSobjects) {
    List<string> filters = new List<string>();

    for (Sobject filtersId : listSobjects) {
      filters.add('%' + filtersId.Id + '%');
    }
    List<CronTrigger> cronListTotal = [
      SELECT Id, CronJobDetail.Name, State
      FROM CronTrigger
      WHERE
        CronJobDetail.Name LIKE :filters
        AND (CronJobDetail.Name LIKE '%Send Email%'
        OR CronJobDetail.Name LIKE '%Callout SmarthPhone%'
        OR CronJobDetail.Name LIKE '%Send Task%')
        WITH USER_MODE
    ];
    if (cronListTotal.size() > 0) {
      for (CronTrigger recordIdCronTrigger : cronListTotal) {
        System.abortJob(recordIdCronTrigger.Id);
      }
    }
  }

  public static void stopCadences(List<Cadences__c> listCadencesRecords) {
    List<Id> listCadences = new List<Id>();
    for (Cadences__c iterate : listCadencesRecords) {
      listCadences.add(iterate.TargetId__c);
    }
    List<Cadences__c> previousCadences = [
      SELECT Id, StopCadences__c
      FROM Cadences__c
      WHERE TargetId__c IN :listCadences WITH USER_MODE
    ]; // AND Id NOT IN:listCadencesRecords
    for (Cadences__c pc : previousCadences) {
      pc.StopCadences__c = true;
    }
    List<ScheduleCadence__c> listSmsScheduled = [
      SELECT Id, Status__c
      FROM ScheduleCadence__c
      WHERE TargetId__c IN :listCadences AND Status__c = 'Pending'
      WITH USER_MODE
    ];
    List<ScheduleCadenceTask__c> listTaskScheduled = [
      SELECT Id, Status__c
      FROM ScheduleCadenceTask__c
      WHERE Related_Record_id__c IN :listCadences AND Status__c = 'Pending'
      WITH USER_MODE
    ];
    List<ScheduleCadenceEmail__c> listEmailScheduled = [
      SELECT Id, Status__c
      FROM ScheduleCadenceEmail__c
      WHERE Related_Record_id__c IN :listCadences AND Status__c = 'Pending'
      WITH USER_MODE
    ];

    for (ScheduleCadence__c cadenceSms : listSmsScheduled) {
      cadenceSms.Status__c = 'Completed';
    }
    for (ScheduleCadenceTask__c cadenceTask : listTaskScheduled) {
      cadenceTask.Status__c = 'Completed';
    }
    for (ScheduleCadenceEmail__c cadenceEmail : listEmailScheduled) {
      cadenceEmail.Status__c = 'Completed';
    }

    LeftMain_SecurityUtils.checkUpdate(ScheduleCadence__c.SObjectType,new List<String> {'Status__c'});

    SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.UPDATABLE, listSmsScheduled);
    Database.update(listSmsScheduled = decision1.getRecords());

    LeftMain_SecurityUtils.checkUpdate(ScheduleCadenceTask__c.SObjectType,new List<String> {'Status__c'});

    SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.UPDATABLE, listTaskScheduled);
    Database.update(listTaskScheduled = decision2.getRecords());

    LeftMain_SecurityUtils.checkUpdate(ScheduleCadenceEmail__c.SObjectType,new List<String> {'Status__c'});

    SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.UPDATABLE, listEmailScheduled);
    Database.update(listEmailScheduled = decision3.getRecords());

    LeftMain_SecurityUtils.checkUpdate(Cadences__c.SObjectType,new List<String> {'StopCadences__c'});

    SObjectAccessDecision decision4 = Security.stripInaccessible(AccessType.UPDATABLE, previousCadences);
    Database.update(previousCadences = decision4.getRecords());
  }

  public static ScheduleCadence__c instanceCadences(
    String targetObjectId,
    String frecuency,
    String idTemplate,
    String templateName,
    Integer scheduledTime,
    String cadenceId
  ) {
    ScheduleCadence__c newScheduled = new ScheduleCadence__c();
    LeftMain_SecurityUtils.checkRead(
      ScheduleCadence__c.SObjectType,
      new List<String>{
        'Sequence__c',
        'IdTemplate__c',
        'Frecuency_To_Flow__c',
        'TargetId__c',
        'Name'
      }
    );
    LeftMain_SecurityUtils.checkUpdate(
      ScheduleCadence__c.SObjectType,
      new List<String>{
        'Sequence__c',
        'IdTemplate__c',
        'Frecuency_To_Flow__c',
        'TargetId__c',
        'Name'
      }
    );
    String objectUsed = Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(
      targetObjectId
    );

    newScheduled.Name = templateName;
    newScheduled.TargetId__c = targetObjectId;
    newScheduled.Frecuency_To_Flow__c = frecuency;
    newScheduled.IdTemplate__c = idTemplate;
    newScheduled.Sequence__c = scheduledTime;
    newScheduled.Cadence__c = cadenceId;
    if (objectUsed == 'Lead') {
      newScheduled.Lead__c = targetObjectId;
    } else if (objectUsed == 'Opportunity') {
      newScheduled.Opportunity__c = targetObjectId;
    } else if (objectUsed == 'Contact') {
      newScheduled.Contact__c = targetObjectId;
    } else if (objectUsed == 'Transactions__c' || objectUsed == 'Left_Main__Transactions__c') {
      newScheduled.Transactions__c = targetObjectId;
    } else if (objectUsed == 'Interested_Buyers__c' || objectUsed == 'Left_Main__Interested_Buyers__c') {
      newScheduled.Interested_Buyers__c = targetObjectId;
    }
    return newScheduled;
  }

  public static ScheduleCadenceEmail__c instanceCadencesEmail(
    String targetObjectId,
    String frecuency,
    Integer Sequence,
    String idTemplate,
    String templateName,
    String email,
    String cadenceId
  ) {
    LeftMain_SecurityUtils.checkRead(
      ScheduleCadenceEmail__c.SObjectType,
      new List<String>{
        'Related_Record_id__c',
        'Sequence__c',
        'IdTemplate__c',
        'Name'
      }
    );
    LeftMain_SecurityUtils.checkUpdate(
      ScheduleCadenceEmail__c.SObjectType,
      new List<String>{
        'Related_Record_id__c',
        'Sequence__c',
        'IdTemplate__c',
        'Name'
      }
    );
    String objectUsed = Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(
      targetObjectId
    );

    ScheduleCadenceEmail__c newScheduledEmail = new ScheduleCadenceEmail__c();
    newScheduledEmail.Related_Record_id__c = targetObjectId;
    newScheduledEmail.Frecuency__c = frecuency;
    newScheduledEmail.Sequence__c = Sequence;
    newScheduledEmail.IdTemplate__c = idTemplate;
    newScheduledEmail.Name = templateName;
    newScheduledEmail.Email__c = email;
    newScheduledEmail.Cadence__c = cadenceId;
    if (objectUsed == 'Lead') {
      newScheduledEmail.Lead__c = targetObjectId;
    } else if (objectUsed == 'Opportunity') {
      newScheduledEmail.Opportunity__c = targetObjectId;
    } else if (objectUsed == 'Contact') {
      newScheduledEmail.Contact__c = targetObjectId;
    } else if (objectUsed == 'Transactions__c' || objectUsed == 'Left_Main__Transactions__c') {
      newScheduledEmail.Transactions__c = targetObjectId;
    } else if (objectUsed == 'Interested_Buyers__c' || objectUsed == 'Left_Main__Interested_Buyers__c') {
      newScheduledEmail.Interested_Buyers__c = targetObjectId;
    }
    return newScheduledEmail;
  }

  public static ScheduleCadenceTask__c instanceCadencesTask(
    String targetObjectId,
    Integer sequence,
    String idTemplate,
    String templateName,
    String frequency,
    String cadenceId
  ) {
    ScheduleCadenceTask__c newScheduledTask = new ScheduleCadenceTask__c();
    String objectUsed = Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(
      targetObjectId
    );


    newScheduledTask.Related_Record_id__c = targetObjectId;
    newScheduledTask.Sequence__c = sequence;
    newScheduledTask.IdTemplate__c = idTemplate;
    newScheduledTask.Name = templateName;
    newScheduledTask.Frecuency_To_Flow__c = frequency;
    newScheduledTask.Cadence__c = cadenceId;

    if (objectUsed == 'Lead') {
      newScheduledTask.Lead__c = targetObjectId;
    } else if (objectUsed == 'Opportunity') {
      newScheduledTask.Opportunity__c = targetObjectId;
    } else if (objectUsed == 'Contact') {
      newScheduledTask.Contact__c = targetObjectId;
    } else if (objectUsed == 'Transactions__c' || objectUsed == 'Left_Main__Transactions__c') {
      newScheduledTask.Transactions__c = targetObjectId;
    } else if (objectUsed == 'Interested_Buyers__c' || objectUsed == 'Left_Main__Interested_Buyers__c') {
      newScheduledTask.Interested_Buyers__c = targetObjectId;
    }
    return newScheduledTask;
  }

  @AuraEnabled(cacheable=true)
  public static Boolean getOrganizationWideDefault() {
    List<OrgWideEmailAddress> owea = [
      SELECT Id, Address, DisplayName
      FROM OrgWideEmailAddress
      WITH USER_MODE
      LIMIT 50000
    ];
    Boolean trueOrFalse = owea.size() > 0 ? true : false;
    return trueOrFalse;
  }
}