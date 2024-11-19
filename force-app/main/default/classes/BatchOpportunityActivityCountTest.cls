@isTest
private class BatchOpportunityActivityCountTest {
    
    static testMethod void testEventTriggerOne(){
        LeadActivityCountSetting__c leadTriggerInstance = LeadActivityCountSetting__c.getOrgDefaults();
        leadTriggerInstance.ActivateTaskTrigger__c = true;
        leadTriggerInstance.ActivateEventTrigger__c = true;
        leadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert leadTriggerInstance;
        
        
        Opportunity opportunityOBJ = new Opportunity(Name = 'A',StageName='Appointment Set',CloseDate=date.today(),Address_1__c='test');
        insert opportunityOBJ;
        
        Event eventObj = new Event(Subject = 'Test', 
                                   ActivityDate = date.today(), 
                                   StartDateTime = System.Now(),
                                   EndDateTime = System.Now() + 5,
                                   WhatId = opportunityOBJ.Id);
        insert eventObj;
        Task taskObj = new task(WhatId = opportunityOBJ.id,Subject='Donni',Status='Completed',Priority='Normal');
        insert taskObj;
        Task taskObj2 = new task(WhatId = opportunityOBJ.id,Subject='Call1',Status='Completed',Priority='Normal',TaskSubtype='Call');
        insert taskObj2;
        Test.StartTest();
            BatchOpportunityActivityCount opportunityActivityObj = new BatchOpportunityActivityCount(); 
            Database.executeBatch(opportunityActivityObj,200);
        	System.assertEquals(null, opportunityOBJ.Event_Count__c);
        	System.assertEquals(null, opportunityOBJ.Task_Count__c);
            Opportunity opp = [SELECT Id,Event_Count__c,Task_Count__c FROM Opportunity Where Id =:opportunityOBJ.Id Limit 1];
            System.assertNotEquals(null, opp.Event_Count__c);
        	System.assertNotEquals(null, opp.Task_Count__c);
        Test.StopTest();
    }

    static testMethod void testEventTriggerTWO(){
        LeadActivityCountSetting__c leadTriggerInstance = LeadActivityCountSetting__c.getOrgDefaults();
        leadTriggerInstance.ActivateTaskTrigger__c = true;
        leadTriggerInstance.ActivateEventTrigger__c = true;
        leadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert leadTriggerInstance;
        
        
        Opportunity opportunityOBJ = new Opportunity(Name = 'A',StageName='Appointment Set',CloseDate=date.today(),Address_1__c='test');
        insert opportunityOBJ;
        Test.StartTest();
            BatchOpportunityActivityCount opportunityActivityObj = new BatchOpportunityActivityCount(); 
            Database.executeBatch(opportunityActivityObj,200);
        	//System.assertEquals(null, opportunityOBJ.Event_Count__c);
        	//System.assertEquals(null, opportunityOBJ.Task_Count__c);
            Opportunity opp = [SELECT Id,Event_Count__c,Task_Count__c FROM Opportunity Where Id =:opportunityOBJ.Id Limit 1];
            System.assertEquals(null, opp.Event_Count__c);
        	System.assertEquals(null, opp.Task_Count__c);
        Test.StopTest();
    }


    static testMethod void testEventTriggerThree(){
        LeadActivityCountSetting__c leadTriggerInstance = LeadActivityCountSetting__c.getOrgDefaults();
        leadTriggerInstance.ActivateTaskTrigger__c = true;
        leadTriggerInstance.ActivateEventTrigger__c = true;
        leadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert leadTriggerInstance;
        
        
        Opportunity opportunityOBJ = new Opportunity(Name = 'A',StageName='Appointment Set',CloseDate=date.today(),Address_1__c='test');
        insert opportunityOBJ;
        
        Event eventObj = new Event(Subject = 'Test', 
                                   ActivityDate = date.today(), 
                                   StartDateTime = System.Now(),
                                   EndDateTime = System.Now() + 5,
                                   WhatId = opportunityOBJ.Id);
        insert eventObj;
        Task taskObj = new task(WhatId = opportunityOBJ.id,Subject='Donni',Status='Completed',Priority='Normal');
        insert taskObj;

         Event eventObjTWO = new Event(Subject = 'Test', 
                                   ActivityDate = date.today(), 
                                   StartDateTime = System.Now(),
                                   EndDateTime = System.Now() + 5,
                                   WhatId = opportunityOBJ.Id);
        insert eventObjTWO;
        Task taskObjTWO = new task(WhatId = opportunityOBJ.id,Subject='Donni',Status='Completed',Priority='Normal');
        insert taskObjTWO;
        Test.StartTest();
            BatchOpportunityActivityCount opportunityActivityObj = new BatchOpportunityActivityCount(); 
            Database.executeBatch(opportunityActivityObj,200);
//System.assertEquals(null, opportunityOBJ.Event_Count__c);
//        	System.assertEquals(null, opportunityOBJ.Task_Count__c);
            Opportunity opp = [SELECT Id,Event_Count__c,Task_Count__c FROM Opportunity Where Id =:opportunityOBJ.Id Limit 1];
            System.assertNotEquals(null, opp.Event_Count__c);
        	System.assertNotEquals(null, opp.Task_Count__c);
        Test.StopTest();
    }

    static testMethod void testEventTriggerFour(){
        LeadActivityCountSetting__c leadTriggerInstance = LeadActivityCountSetting__c.getOrgDefaults();
        leadTriggerInstance.ActivateTaskTrigger__c = true;
        leadTriggerInstance.ActivateEventTrigger__c = true;
        leadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert leadTriggerInstance;
        
        
        Opportunity opportunityOBJ = new Opportunity(Name = 'A',StageName='Appointment Set',CloseDate=date.today(),Address_1__c='test');
        insert opportunityOBJ;
        
        Event eventObj = new Event(Subject = 'Test', 
                                   ActivityDate = date.today(), 
                                   StartDateTime = System.Now(),
                                   EndDateTime = System.Now() + 5,
                                   WhatId = opportunityOBJ.Id);
        insert eventObj;
        Task taskObj = new task(WhatId = opportunityOBJ.id,Subject='Donni',Status='Completed',Priority='Normal');
        insert taskObj;

         Event eventObjTWO = new Event(Subject = 'Test', 
                                   ActivityDate = date.today(), 
                                   StartDateTime = System.Now(),
                                   EndDateTime = System.Now() + 5,
                                   WhatId = opportunityOBJ.Id);
        insert eventObjTWO;
        Task taskObjTWO = new task(WhatId = opportunityOBJ.id,Subject='Donni',Status='Completed',Priority='Normal');
        insert taskObjTWO;
        Test.StartTest();
         BatchOpportunityActivityCount opportunityActivityObj = new BatchOpportunityActivityCount();
        String CRON_Exprestion = '0 0 8 1/1 * ? *'; 
        id jobId = system.schedule('BatchOpportunityActivityCount', CRON_Exprestion, opportunityActivityObj);
        System.assertNotEquals(null,jobId);
        Test.StopTest();
    }

    
}