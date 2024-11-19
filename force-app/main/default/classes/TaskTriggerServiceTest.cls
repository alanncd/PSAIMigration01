@isTest
private class TaskTriggerServiceTest {
    /*
    static testMethod void TestTaskTriggerOne(){
        LeadActivityCountSetting__c LeadTriggerInstance = LeadActivityCountSetting__c.getOrgDefaults();
        LeadTriggerInstance.ActivateTaskTrigger__c = true;
        LeadTriggerInstance.ActivateEventTrigger__c = true;
        LeadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert LeadTriggerInstance;
        
        
        Lead LeadOBJ = new Lead(LastName = String.ValueOf('A'),Next_Step__c = 'Test', Status = 'Appointment Set');
        insert LeadOBJ;
        
        Task taskObj = new task(WhoID = LeadOBJ.id,Subject='Donni',Status='Completed',Priority='Normal');
        
        Test.StartTest();
        insert taskObj;
        Lead l = [Select Id,TaskCount__c FROM Lead Where Id =:LeadOBJ.Id Limit 1];
        System.assertNotEquals(null, l.TaskCount__c);
        Test.StopTest();
    }
    
    static testMethod void TestTaskTriggerDelete(){
        LeadActivityCountSetting__c LeadTriggerInstance = LeadActivityCountSetting__c.getOrgDefaults();
        LeadTriggerInstance.ActivateTaskTrigger__c = true;
        LeadTriggerInstance.ActivateEventTrigger__c = true;
        LeadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert LeadTriggerInstance;
        
        
        Lead LeadOBJ = new Lead(LastName = String.ValueOf('A'),Next_Step__c = 'Test', Status = 'Appointment Set');
        insert LeadOBJ;
        
        Task taskObj = new task(WhoID = LeadOBJ.id,Subject='Donni',Status='Completed',Priority='Normal');
        insert taskObj;
        Test.StartTest();
        delete taskObj;
        Lead l = [Select Id,TaskCount__c FROM Lead Where Id =:LeadOBJ.Id Limit 1];
        System.assertNotEquals(null, l.TaskCount__c);
        Test.StopTest();
    }
    
    static testMethod void TestTaskTriggerSecond(){
        LeadActivityCountSetting__c LeadTriggerInstance = LeadActivityCountSetting__c.getOrgDefaults();
        LeadTriggerInstance.ActivateTaskTrigger__c = false;
        LeadTriggerInstance.ActivateEventTrigger__c = false;
        LeadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId();
        upsert LeadTriggerInstance;
        
        Lead LeadOBJ = new Lead(LastName = String.ValueOf('A'),Next_Step__c = 'Test', Status = 'Appointment Set');
        insert LeadOBJ;
        
        Task taskObj = new task(WhoID = LeadOBJ.id,Subject='Donni',Status='Completed',Priority='Normal');
        
        Test.StartTest();
        insert taskObj;
        Lead l = [Select Id,TaskCount__c FROM Lead Where Id =:LeadOBJ.Id Limit 1];
        System.assertEquals(null, l.TaskCount__c);
        Test.StopTest();
    }

*/
}