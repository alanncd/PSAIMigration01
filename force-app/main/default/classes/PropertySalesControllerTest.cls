@isTest
private class PropertySalesControllerTest {

    @testSetup
    static void setupTestData() {
        Property_SalesAI_Settings__c settings = new Property_SalesAI_Settings__c(
            Lead_Address_PostalCode__c = '12345',
            Lead_Address_State__c = 'CA',
            Lead_Address_Street__c = 'Street',
            Lead_Address_City__c = 'San Francisco',
            Lead_Record_Types__c = 'LeadRecordTypeId',
            Lead_History_Duration__c = 90,
            Lead_Status__c = 'Open',
            Matched_Lead_Reason__c = 'Duplicate',
            Matched_Lead_Reason_Field__c = 'Status',
            Matched_Lead_Status__c = 'Closed',

            Opportunity_Address_PostalCode__c = '67890',
            Opportunity_Address_State__c = 'NY',
            Opportunity_Address_Street__c = 'Street__c',
            Opportunity_Address_City__c = 'New York',
            Opportunity_Record_Types__c = 'OppRecordTypeId',
            Opportunity_History_Duration__c = 180,
            Opportunity_Stage__c = 'Prospecting',
            Matched_Opportunity_Reason__c = 'Existing Client',
            Matched_Opportunity_Reason_Field__c = 'StageName',
            Matched_Opportunity_Stage__c = 'Closed Won',

            Property_Sales_History_Duration__c = 365,
            Matching_Day__c = 'Monday', // Converted Date to String
            IsSetupComplete__c = false
        );
        insert settings;
        // Create test data for Property_SalesAI_History__c
        Property_SalesAI_History__c history = new Property_SalesAI_History__c(
            Name = 'Test History Record' 
        );
        insert history;

        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.Industry = 'Technology'; 
        testAcc.Phone = '123-456-7890'; 
        Map<String, Schema.RecordTypeInfo> accRecordTypes = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        testAcc.RecordTypeId = AccRecordTypes.get('Realtor').getRecordTypeId();
        insert testAcc;


        Lead lead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Status = 'Open - Not Contacted',
            Similarity_Key__c = 'KeyO_10001'
        );
        insert lead;
        // Create test data for Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAcc.Id, 
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Similarity_Key__c = 'KeyO_10001' 
        );
        insert opp;
        Property__c property = new Property__c(Similarity_Key__c = 'KeyO_10001');
        insert property;

        Property_SalesAI__c sp = new Property_SalesAI__c(Property__c = property.Id);
        insert sp;
        
        // Create test data for Property_SalesAI_Match__c
        List<Property_SalesAI_Match__c> matches = new List<Property_SalesAI_Match__c>();
        matches.add(new Property_SalesAI_Match__c(
            Property_SalesAI_History__c = history.Id,
            Status__c = 'Pending',
            Type__c = 'Lead Match',
            Lead__c = lead.Id, 
            Property_SalesAI__c = sp.Id 
        ));
        matches.add(new Property_SalesAI_Match__c(
            Property_SalesAI_History__c = history.Id,
            Status__c = 'Pending',
            Type__c = 'Opportunity Match',
            Opportunity__c = opp.Id, 
            Property_SalesAI__c = sp.Id 
        ));
        insert matches;

    }

    @isTest
    static void testGetMatches() {
        // Retrieve the history record
        Property_SalesAI_History__c history = [SELECT Id FROM Property_SalesAI_History__c LIMIT 1];

        // Call the method
        Test.startTest();
        List<PropertySalesController.MatchWrapper> matches = PropertySalesController.getMatches(history.Id);
        Test.stopTest();

        // Assert the results
        System.assertNotEquals(0, matches.size(), 'Matches should be returned');
    }

    @isTest
    static void testMarkAsGoodMatches() {
        // Retrieve the match records
        List<Property_SalesAI_Match__c> matches = [SELECT Id FROM Property_SalesAI_Match__c];
        List<String> matchIds = new List<String>();
        for (Property_SalesAI_Match__c match : matches) {
            matchIds.add(match.Id);
        }

        // Retrieve the history record
        Property_SalesAI_History__c history = [SELECT Id FROM Property_SalesAI_History__c LIMIT 1];

        // Call the method
        Test.startTest();
        PropertySalesController.markAsGoodMatches(matchIds, history.Id);
        Test.stopTest();

        // Assert the results
        matches = [SELECT Status__c FROM Property_SalesAI_Match__c WHERE Id IN :matchIds];
        for (Property_SalesAI_Match__c match : matches) {
            System.assertEquals('Confirmed', match.Status__c, 'Match should be confirmed');
        }
    }

    @isTest
    static void testMarkAsNotMatch() {
        // Retrieve the match records
        List<Property_SalesAI_Match__c> matches = [SELECT Id FROM Property_SalesAI_Match__c];
        List<String> matchIds = new List<String>();
        for (Property_SalesAI_Match__c match : matches) {
            matchIds.add(match.Id);
        }

        // Retrieve the history record
        Property_SalesAI_History__c history = [SELECT Id FROM Property_SalesAI_History__c LIMIT 1];

        // Call the method
        Test.startTest();
        PropertySalesController.markAsNotMatch(matchIds, history.Id);
        Test.stopTest();

        // Assert the results
        matches = [SELECT Status__c FROM Property_SalesAI_Match__c WHERE Id IN :matchIds];
        for (Property_SalesAI_Match__c match : matches) {
            System.assertEquals('Rejected', match.Status__c, 'Match should be rejected');
        }
    }
}