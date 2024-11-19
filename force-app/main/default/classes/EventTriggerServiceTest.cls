@isTest
private class EventTriggerServiceTest {
    
    static testMethod void testEventTriggerOne(){
        LeadActivityCountSetting__c leadTriggerInstance = LeadActivityCountSetting__c.getOrgDefaults();
        leadTriggerInstance.ActivateTaskTrigger__c = true;
        leadTriggerInstance.ActivateEventTrigger__c = true;
        leadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert leadTriggerInstance; 
        
        
        Lead leadOBJ = new Lead(LastName = String.ValueOf('A'),Next_Step__c = 'Test', Status = 'Appointment Set');
        insert leadOBJ;
        
        Event eventObj = new Event(Subject = 'Acquisition Appointment', 
                                   ActivityDate = date.today(), 
                                   StartDateTime = System.Now(),
                                   EndDateTime = System.Now() + 5,
                                   whoId = leadOBJ.Id);
        
        Opportunity opportunityOBJ = new Opportunity(Name = 'A',StageName='Appointment Set',CloseDate=date.today(),Address_1__c='test');
        insert opportunityOBJ;
        
        Event oppEventObj = new Event(Subject = 'Acquisition Appointment', 
                                   ActivityDate = date.today(), 
                                   StartDateTime = System.Now(),
                                   EndDateTime = System.Now() + 5,
                                   WhatId = opportunityOBJ.Id);
        
       
        Test.StartTest();
         insert eventObj;
         insert oppEventObj;
        Test.StopTest();
        Opportunity opp = [SELECT Id,Appointment_Date_Time__c,Event_Count__c From Opportunity Where Id =:oppEventObj.WhatId Limit 1];
        Lead l1 = [SELECT Id,EventCount__c From Lead Where Id =:eventObj.WhoId Limit 1];
        System.assertNotEquals(null, opp.Appointment_Date_Time__c,'');
        System.assertNotEquals(null, opp.Event_Count__c,'');
        System.assertNotEquals(null, l1.EventCount__c,'');
    }
    
    static testMethod void testEventTriggerDelete(){
        LeadActivityCountSetting__c leadTriggerInstance = LeadActivityCountSetting__c.getOrgDefaults();
        leadTriggerInstance.ActivateTaskTrigger__c = true;
        leadTriggerInstance.ActivateEventTrigger__c = true;
        leadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert leadTriggerInstance;
        
        
        Lead leadOBJ = new Lead(LastName = String.ValueOf('A'),Next_Step__c = 'Test', Status = 'Appointment Set');
        insert leadOBJ;
        
     	Event eventObj = new Event(Subject = 'Acquisition Appointment', 
                                   ActivityDate = date.today(), 
                                   StartDateTime = System.Now(),
                                   EndDateTime = System.Now() + 5,
                                   whoId = leadOBJ.Id);
        insert eventObj;
        Test.StartTest();
        delete eventObj;
        Lead l1 = [SELECT Id,EventCount__c From Lead Where Id =:eventObj.WhoId Limit 1];
        System.assertNotEquals(null, l1.EventCount__c,'');
        Test.StopTest();
    }
    
    static testMethod void testEventTriggerSecond(){
        LeadActivityCountSetting__c leadTriggerInstance = LeadActivityCountSetting__c.getOrgDefaults();
        leadTriggerInstance.ActivateTaskTrigger__c = false;
        leadTriggerInstance.ActivateEventTrigger__c = false;
        leadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId();
        upsert leadTriggerInstance;
        
        Lead leadOBJ = new Lead(LastName = String.ValueOf('A'),Next_Step__c = 'Test', Status = 'Appointment Set');
        insert leadOBJ;
        
       	Event eventObj = new Event(Subject = 'Acquisition Appointment', 
                                   ActivityDate = date.today(), 
                                   StartDateTime = System.Now(),
                                   EndDateTime = System.Now() + 5,
                                   whoId = leadOBJ.Id);
        Opportunity opportunityOBJ = new Opportunity(Name = 'A',StageName='Appointment Set',CloseDate=date.today(),Address_1__c='test');
        insert opportunityOBJ;
        
        Event oppEventObj = new Event(Subject = 'Acquisition Appointment', 
                                   ActivityDate = date.today(), 
                                   StartDateTime = System.Now(),
                                   EndDateTime = System.Now() + 5,
                                   WhatId = opportunityOBJ.Id);
        
        Test.StartTest();
        insert oppEventObj;
        insert eventObj;
        Test.StopTest();
        Opportunity opp = [SELECT Id,Appointment_Date_Time__c,Event_Count__c From Opportunity Where Id =:oppEventObj.WhatId Limit 1];
        Lead l1 = [SELECT Id,EventCount__c From Lead Where Id =:eventObj.WhoId Limit 1];
        System.assertEquals(null, opp.Appointment_Date_Time__c,'');
        System.assertEquals(null, opp.Event_Count__c,'');
        System.assertEquals(null, l1.EventCount__c,'');
    }
}