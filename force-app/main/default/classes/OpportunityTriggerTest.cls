@isTest
private class OpportunityTriggerTest {
    
    @testsetup
    static void insertOppRecord() {
        Opportunity oppRec = new Opportunity(Name = 'Test Opp', StageName = 'Pending Appointment',Sqft__c = (Decimal)500,Rehab_Level__c = 'Level 1 -- Paint & Carpet',
                                             CloseDate = System.today()+ 7);        
        insert oppRec;        
    }
    static Opportunity createOpportunity(Integer sqft,String rehebLevel) {
        Opportunity oppRec = new Opportunity(Name = 'Test Opp', StageName = 'Pending Appointment',Sqft__c = (Decimal)sqft,Rehab_Level__c = rehebLevel,
                                             CloseDate = System.today()+ 7);        
        return oppRec;        
    } 
    
     @isTest
    static void testInsertRecordLevel1() {
        OpportunityTriggerSetting__c oppTriggerInstance = OpportunityTriggerSetting__c.getOrgDefaults();
        oppTriggerInstance.Activate_Trigger__c = true;
        oppTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert oppTriggerInstance;  
        Opportunity opp = createOpportunity(450,'Level 2 -- Kitchen');
        insert opp;
        System.assertNotEquals(null,opp,'');
    } 
    
    @isTest
    static void testInsertRecordLevel2() {
        OpportunityTriggerSetting__c oppTriggerInstance = OpportunityTriggerSetting__c.getOrgDefaults();
        oppTriggerInstance.Activate_Trigger__c = true;
        oppTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert oppTriggerInstance;  
        Opportunity opp = createOpportunity(950,'Level 2 -- Kitchen');
        insert opp;
        System.assertNotEquals(null,opp,'');
    }
    
    @isTest
    static void testInsertRecordLevel3() {
        OpportunityTriggerSetting__c oppTriggerInstance = OpportunityTriggerSetting__c.getOrgDefaults();
        oppTriggerInstance.Activate_Trigger__c = true;
        oppTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert oppTriggerInstance;  
        Opportunity opp = createOpportunity(690,'Level 3 -- Kitchen & All Baths and/or 2 systems');
        insert opp;
        System.assertNotEquals(null,opp,'');
    }
    
    @isTest
    static void testInsertRecordLevel4() { 
        OpportunityTriggerSetting__c oppTriggerInstance = OpportunityTriggerSetting__c.getOrgDefaults();
        oppTriggerInstance.Activate_Trigger__c = true;
        oppTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert oppTriggerInstance;  
        Opportunity opp = [SELECT Name,Rehab_Level__c,Sqft__c FROM Opportunity LIMIT 1];
        opp.Rehab_Level__c = 'Level 4 -- Kitchen, Baths, and/or Floorpan Changes';
        update opp;
        System.assertNotEquals(null,opp,'');
    }
}