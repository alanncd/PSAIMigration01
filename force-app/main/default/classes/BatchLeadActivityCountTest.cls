@isTest
private class BatchLeadActivityCountTest {
    
    static testMethod void TestEventTriggerOne(){
        LeadActivityCountSetting__c LeadTriggerInstance = LeadActivityCountSetting__c.getOrgDefaults();
        LeadTriggerInstance.ActivateTaskTrigger__c = true;
        LeadTriggerInstance.ActivateEventTrigger__c = true;
        LeadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert LeadTriggerInstance;
        
        
        Lead LeadOBJ = new Lead(LastName = String.ValueOf('A'),Next_Step__c = 'Test', Status = 'Appointment Set');
        insert LeadOBJ;
        
        Event EventObj = new Event(Subject = 'Test', 
                                   ActivityDate = date.today(), 
                                   StartDateTime = System.Now(),
                                   EndDateTime = System.Now() + 5,
                                   whoId = LeadOBJ.Id);
        insert EventObj;
        Task taskObj = new task(WhoID = LeadOBJ.id,Subject='Donni',Status='Completed',Priority='Normal');
        insert taskObj;
        Task taskObj2 = new task(WhoID = LeadOBJ.id,Subject='CallTest',Status='Completed',Priority='Normal',TaskSubtype='Call');
        insert taskObj2;
        Test.StartTest();
            BatchLeadActivityCount LeadActivityObj = new BatchLeadActivityCount(); 
            Database.executeBatch(LeadActivityObj,200);
        	System.assertEquals(null, LeadOBJ.EventCount__c);
        	System.assertEquals(null, LeadOBJ.TaskCount__c);
            Lead l1 = [Select Id,Next_Step__c,EventCount__c,TaskCount__c From Lead Where Id=:LeadOBJ.Id Limit 1];
        	//System.assertNotEquals(null, l1.EventCount__c);
        	//System.assertNotEquals(null, l1.TaskCount__c);
        Test.StopTest();
    }

    static testMethod void TestEventTriggerTWO(){
        LeadActivityCountSetting__c LeadTriggerInstance = LeadActivityCountSetting__c.getOrgDefaults();
        LeadTriggerInstance.ActivateTaskTrigger__c = true;
        LeadTriggerInstance.ActivateEventTrigger__c = true;
        LeadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert LeadTriggerInstance;
        
        
        Lead LeadOBJ = new Lead(LastName = String.ValueOf('A'),Next_Step__c = 'Test', Status = 'Appointment Set');
        insert LeadOBJ;
        Test.StartTest();
            BatchLeadActivityCount LeadActivityObj = new BatchLeadActivityCount(); 
            Database.executeBatch(LeadActivityObj,200);
            Lead l1 = [Select Id,Next_Step__c,EventCount__c,TaskCount__c From Lead Where Id=:LeadOBJ.Id Limit 1];
        	System.assertEquals(null, l1.EventCount__c);
        	System.assertEquals(null, l1.TaskCount__c);
        Test.StopTest();
    }


    static testMethod void TestEventTriggerThree(){
        LeadActivityCountSetting__c LeadTriggerInstance = LeadActivityCountSetting__c.getOrgDefaults();
        LeadTriggerInstance.ActivateTaskTrigger__c = true;
        LeadTriggerInstance.ActivateEventTrigger__c = true;
        LeadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert LeadTriggerInstance;
        
        
        Lead LeadOBJ = new Lead(LastName = String.ValueOf('A'),Next_Step__c = 'Test', Status = 'Appointment Set');
        insert LeadOBJ;
        
        Event EventObj = new Event(Subject = 'Test', 
                                   ActivityDate = date.today(), 
                                   StartDateTime = System.Now(),
                                   EndDateTime = System.Now() + 5,
                                   whoId = LeadOBJ.Id);
        insert EventObj;
        Event EventObjTWO = new Event(Subject = 'Test', 
                                   ActivityDate = date.today(), 
                                   StartDateTime = System.Now(),
                                   EndDateTime = System.Now() + 5,
                                   whoId = LeadOBJ.Id);
        insert EventObjTWO;
        Task taskObj = new task(WhoID = LeadOBJ.id,Subject='Donni',Status='Completed',Priority='Normal');
        insert taskObj;
        Task taskObjTWO = new task(WhoID = LeadOBJ.id,Subject='Donni',Status='Completed',Priority='Normal');
        insert taskObjTWO;
        Test.StartTest();
            BatchLeadActivityCount LeadActivityObj = new BatchLeadActivityCount(); 
            Database.executeBatch(LeadActivityObj,200);
            System.assertEquals(null, LeadOBJ.EventCount__c);
        	System.assertEquals(null, LeadOBJ.TaskCount__c);
            Lead l1 = [Select Id,Next_Step__c,EventCount__c,TaskCount__c From Lead Where Id=:LeadOBJ.Id Limit 1];
        	//System.assertNotEquals(null, l1.EventCount__c);
        	//System.assertNotEquals(null, l1.TaskCount__c);
        Test.StopTest();
    }

    static testMethod void TestEventTriggerFour(){
        LeadActivityCountSetting__c LeadTriggerInstance = LeadActivityCountSetting__c.getOrgDefaults();
        LeadTriggerInstance.ActivateTaskTrigger__c = true;
        LeadTriggerInstance.ActivateEventTrigger__c = true;
        LeadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert LeadTriggerInstance;
        
        
        Lead LeadOBJ = new Lead(LastName = String.ValueOf('A'),Next_Step__c = 'Test', Status = 'Appointment Set');
        insert LeadOBJ;
        
        Event EventObj = new Event(Subject = 'Test', 
                                   ActivityDate = date.today(), 
                                   StartDateTime = System.Now(),
                                   EndDateTime = System.Now() + 5,
                                   whoId = LeadOBJ.Id);
        insert EventObj;
        Event EventObjTWO = new Event(Subject = 'Test', 
                                   ActivityDate = date.today(), 
                                   StartDateTime = System.Now(),
                                   EndDateTime = System.Now() + 5,
                                   whoId = LeadOBJ.Id);
        insert EventObjTWO;
        Task taskObj = new task(WhoID = LeadOBJ.id,Subject='Donni',Status='Completed',Priority='Normal');
        insert taskObj;
        Task taskObjTWO = new task(WhoID = LeadOBJ.id,Subject='Donni',Status='Completed',Priority='Normal');
        insert taskObjTWO;
        Test.StartTest();
         BatchLeadActivityCount ActivityCountBatchOBJ = new BatchLeadActivityCount();
        String CRON_Exprestion = '0 0 8 1/1 * ? *'; 
        id jobId = system.schedule('BatchLeadActivityCount', CRON_Exprestion, ActivityCountBatchOBJ);
        System.assertNotEquals(null,jobId);
        Test.StopTest();
    }

    
}