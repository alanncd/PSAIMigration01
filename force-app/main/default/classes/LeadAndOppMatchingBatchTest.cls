@isTest
public class LeadAndOppMatchingBatchTest {

    @testSetup
    static void setupTestData() {
        // Fetch the organization defaults for Property_SalesAI_Settings__c
        Property_SalesAI_Settings__c orgDefaults = Property_SalesAI_Settings__c.getOrgDefaults();

        // If orgDefaults is null, create a new one
        if (orgDefaults == null) {
            orgDefaults = new Property_SalesAI_Settings__c();
        }

        // Set the fields based on the provided values in the image
        orgDefaults.Lead_Status__c = 'Open - Not Contacted, Working - Contacted';
        Map<String, Schema.RecordTypeInfo> leadRecordTypes = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
        orgDefaults.Lead_Record_Types__c = leadRecordTypes.get('Business_Account').getRecordTypeId();
        orgDefaults.Lead_Record_Types__c += ', ' + leadRecordTypes.get('Homeowner').getRecordTypeId();
        orgDefaults.Lead_History_Duration__c = 90;
        orgDefaults.Matched_Lead_Reason_Field__c = 'Unqualified_Reason__c';
        orgDefaults.Matched_Lead_Reason__c = 'Already sold (Other Investor)';
        orgDefaults.Matched_Lead_Status__c = 'Closed - Not Converted';
        Map<String, Schema.RecordTypeInfo> oppRecordTypes = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
        orgDefaults.Opportunity_Record_Types__c = oppRecordTypes.get('Opportunity').getRecordTypeId();
        orgDefaults.Opportunity_History_Duration__c = 80;
        orgDefaults.Matched_Opportunity_Stage__c = 'Closed Lost';
        orgDefaults.Matched_Opportunity_Reason_Field__c = 'Closed_Lost_Reason__c';
        orgDefaults.Matched_Opportunity_Reason__c = 'Sold To Other Investor';
        orgDefaults.Opportunity_Stage__c = 'Negotiation/Review,Proposal/Price Quote,Perception Analysis,Id. Decision Makers,Value Proposition,Needs Analysis,Qualification,Prospecting';
        orgDefaults.Property_Sales_History_Duration__c = 80;
        orgDefaults.IsSetupComplete__c = true;
        orgDefaults.AutomaticUpdate__c = true;
        // Update the custom setting with new values
        upsert orgDefaults;

        // Generate 200 Leads and Opportunities with Similarity Key
        List<Lead> leadsToInsert = new List<Lead>();
        List<Opportunity> oppsToInsert = new List<Opportunity>();
        List<Property__c> propertiesToInsert = new List<Property__c>();
        List<Property_SalesAI__c> propertiesSalesToInsert = new List<Property_SalesAI__c>();
        //Dummie account to prevent Opportunity Validation Rule
        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.Industry = 'Technology'; 
        testAcc.Phone = '123-456-7890'; 
        Map<String, Schema.RecordTypeInfo> accRecordTypes = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        testAcc.RecordTypeId = AccRecordTypes.get('Realtor').getRecordTypeId();
        insert testAcc;

        for (Integer i = 0; i < 50; i++) {
            String similarityKey = 'KeyO_1000' + i;

            // Create Lead
            Lead lead = new Lead(LastName = 'Test Lead MatchesBoth' + i, Company = 'Test Company ' + i, Similarity_Key__c = similarityKey, Status = 'Open - Not Contacted');
            leadsToInsert.add(lead);

            // Create Opportunity
            Opportunity opp = new Opportunity(Name = 'Test Opportunity MatchesBoth' + i, AccountId = testAcc.Id, Last_Offer_Made__c = 234000, 
            StageName = 'Prospecting', CloseDate = Date.today(), Similarity_Key__c = similarityKey);
            oppsToInsert.add(opp);

            Property__c property = new Property__c(Similarity_Key__c = similarityKey);
            propertiesToInsert.add(property);

        }       

        for (Integer i = 0; i < 50; i++) {
            String similarityKey = 'KeyT2000_' + i;

            // Create Lead
            Lead lead = new Lead(LastName = 'Test Lead OnlyMatchesLead' + i, Company = 'Test Company ' + i, Similarity_Key__c = similarityKey, Status = 'Working - Contacted');
            leadsToInsert.add(lead);

            // Create Property_SalesAI__c
            Property__c property = new Property__c(Similarity_Key__c = similarityKey);
            propertiesToInsert.add(property);
        }        
        
        for (Integer i = 0; i < 50; i++) {
            String similarityKey = 'KeyT3000_' + i;
            
            // Create Opportunity
            Opportunity opp = new Opportunity(Name = 'Test Opportunity OnlyMatchesOpp OK' + i,  AccountId = testAcc.Id, Last_Offer_Made__c = 234000,
            StageName = 'Proposal/Price Quote', CloseDate = Date.today(), Similarity_Key__c = similarityKey);
            oppsToInsert.add(opp);

            // Create Property_SalesAI__c
            Property__c sp = new Property__c(Similarity_Key__c = similarityKey);
            propertiesToInsert.add(sp);
        }

        for (Integer i = 0; i < 50; i++) {
            String similarityKey = 'KeyF_5000' + i;

            // Create Lead
            Lead lead = new Lead(LastName = 'Test Lead  NoMatches' + i, Company = 'Test Company ' + i, Similarity_Key__c = similarityKey, Status = 'Open - Not Contacted');
            leadsToInsert.add(lead);

            // Create Opportunity
            Opportunity opp = new Opportunity(Name = 'Test Opportunity NoMatches ' + i, StageName = 'Prospecting', CloseDate = Date.today(), Similarity_Key__c = similarityKey);
            oppsToInsert.add(opp);
        }     

        // Insert all Leads, Opportunities, and Property_SalesAI__c records
        insert leadsToInsert;
        insert oppsToInsert;
        insert propertiesToInsert;
        for (Property__c prop : propertiesToInsert) {
            Property_SalesAI__c sp = new Property_SalesAI__c(Property__c = prop.Id);
            propertiesSalesToInsert.add(sp);    
        }
        insert propertiesSalesToInsert;

    }

    @isTest
    static void testHelperMethods() {
        // Test getCustomSettingOrgDefaultRecord
        Property_SalesAI_Settings__c setting = LeadAndOppMatchingBatchHelper.getCustomSettingOrgDefaultRecord();
        
        System.assertNotEquals(null, setting, 'Custom setting org default should not be null');

        // Test getListFromCommaSeparatedList
        List<String> resultList = LeadAndOppMatchingBatchHelper.getListFromCommaSeparatedList('a,b,c');
        System.assertEquals(3, resultList.size(), 'List should have 3 elements');
        System.assertEquals('a', resultList[0].trim(), 'First element should be "a"');
        System.assertEquals('b', resultList[1].trim(), 'Second element should be "b"');
        System.assertEquals('c', resultList[2].trim(), 'Third element should be "c"');

        // Test getMapBySimilarityKey
        List<Lead> leadList = [SELECT Id, Similarity_Key__c FROM Lead];
        Map<String, List<Lead>> resultMap = LeadAndOppMatchingBatchHelper.getMapBySimilarityKey(leadList);
        System.assertEquals(leadList.size(), resultMap.size(), 'Map size should match list size');
    }

    
    @IsTest
    static void testBothLeadAndOppHaveMatchUsingScheduleable() {
        Property_SalesAI_Settings__c orgDefaults = Property_SalesAI_Settings__c.getOrgDefaults();
        orgDefaults.Opportunity_Stage__c = 'Prospecting';
        orgDefaults.Lead_Status__c = 'Open - Not Contacted';
        upsert orgDefaults;

        Test.startTest();
        LeadAndOppMatchingScheduler schedulableInstance = new LeadAndOppMatchingScheduler();
        String sch = '20 30 8 10 2 ? 2050';
        String jobID = System.schedule('Match Job', sch, schedulableInstance);
        Database.executeBatch(new LeadAndOppMatchingBatch());
        Test.stopTest();

        // Verify that 50 leads and opportunities are updated, and 100 records are inserted
        List<Lead> updatedLeads = [SELECT Id, Status FROM Lead WHERE Status = 'Closed - Not Converted'];
        List<Opportunity> updatedOpps = [SELECT Id, StageName FROM Opportunity WHERE StageName = 'Closed Lost'];
        List<Property_SalesAI_Match__c> matchedRecords = [SELECT Id FROM Property_SalesAI_Match__c WHERE Lead__c != null OR Opportunity__c != null];

        System.assertEquals(50, updatedLeads.size(), '50 Leads should be updated to "Closed - Not Converted"');
        System.assertEquals(50, updatedOpps.size(), '50 Opportunities should be updated to "Closed Lost"');
        System.assertEquals(100, matchedRecords.size(), '100 Property_SalesAI_Match__c records should be inserted either an opportunity or a lead related');
    }

    @IsTest
    static void testOnlyLeadsHaveMatch() {
        Property_SalesAI_Settings__c orgDefaults = Property_SalesAI_Settings__c.getOrgDefaults();
        orgDefaults.Opportunity_Stage__c = 'Value Proposition';
        orgDefaults.Lead_Status__c = 'Working - Contacted';
        upsert orgDefaults;


        Test.startTest();
        LeadAndOppMatchingBatch batch = new LeadAndOppMatchingBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify that 50 leads are updated, but no opportunities are updated
        List<Lead> updatedLeads = [SELECT Id, Status FROM Lead WHERE Status = 'Closed - Not Converted' AND Similarity_Key__c LIKE 'KeyT2000_%'];
        List<Opportunity> updatedOpps = [SELECT Id, StageName FROM Opportunity WHERE StageName = 'Closed Lost' AND Similarity_Key__c LIKE 'KeyT2000_%'];
        List<Property_SalesAI_Match__c> matchedRecords = [SELECT Id FROM Property_SalesAI_Match__c WHERE Lead__c != null AND Opportunity__c = null];

        System.assertEquals(50, updatedLeads.size(), '50 Leads should be updated to "Closed - Not Converted"');
        System.assertEquals(0, updatedOpps.size(), 'No Opportunities should be updated');
        System.assertEquals(50, matchedRecords.size(), '50 Property_SalesAI_Match__c records should be inserted only for Leads');
    }

    @IsTest
    static void testOnlyOppsHaveMatch() {
        Property_SalesAI_Settings__c orgDefaults = Property_SalesAI_Settings__c.getOrgDefaults();
        orgDefaults.Opportunity_Stage__c = 'Proposal/Price Quote';
        orgDefaults.Lead_Status__c = '';
        upsert orgDefaults;

        Test.startTest();
        LeadAndOppMatchingBatch batch = new LeadAndOppMatchingBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify that 50 opportunities are updated, but no leads are updated
        List<Lead> updatedLeads = [SELECT Id, Status FROM Lead WHERE Status = 'Closed - Not Converted' AND Similarity_Key__c LIKE 'KeyT3000_%'];
        List<Opportunity> updatedOpps = [SELECT Id, StageName FROM Opportunity WHERE StageName = 'Closed Lost' AND Similarity_Key__c LIKE 'KeyT3000_%'];
        List<Property_SalesAI_Match__c> matchedRecords = [SELECT Id FROM Property_SalesAI_Match__c WHERE Lead__c = null AND Opportunity__c != null];

        System.assertEquals(0, updatedLeads.size(), 'No Leads should be updated');
        System.assertEquals(50, updatedOpps.size(), '50 Opportunities should be updated to "Closed Lost"');
        System.assertEquals(50, matchedRecords.size(), '50 Property_SalesAI_Match__c records should be inserted only for Opportunities');
    }

    @IsTest
    static void testNoMatches() {
        Property_SalesAI_Settings__c orgDefaults = Property_SalesAI_Settings__c.getOrgDefaults();
        orgDefaults.Opportunity_Stage__c = '';
        orgDefaults.Lead_Status__c = '';
        upsert orgDefaults;

        Test.startTest();
        LeadAndOppMatchingBatch batch = new LeadAndOppMatchingBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify that no leads or opportunities are updated
        List<Lead> updatedLeads = [SELECT Id, Status FROM Lead WHERE Status = 'Closed - Not Converted' AND Similarity_Key__c LIKE 'KeyF_5000%'];
        List<Opportunity> updatedOpps = [SELECT Id, StageName FROM Opportunity WHERE StageName = 'Closed Lost' AND Similarity_Key__c LIKE 'KeyF_5000%'];
        List<Property_SalesAI_Match__c> matchedRecords = [SELECT Id FROM Property_SalesAI_Match__c WHERE Property_SalesAI_History__c != null];

        System.assertEquals(0, updatedLeads.size(), 'No Leads should be updated');
        System.assertEquals(0, updatedOpps.size(), 'No Opportunities should be updated');
        System.assertEquals(0, matchedRecords.size(), 'No Property_SalesAI_Match__c records should be inserted');
    }

    @IsTest
    static void testCustomSettingNotCreated() {
        Property_SalesAI_Settings__c orgDefaults = Property_SalesAI_Settings__c.getOrgDefaults();
        orgDefaults.Opportunity_Stage__c = 'Perception Analysis';
        delete orgDefaults;

        Test.startTest();
        LeadAndOppMatchingBatch batch = new LeadAndOppMatchingBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify that the Property_SalesAI_History__c record was inserted with an error status
        Property_SalesAI_History__c executionRecord = [SELECT Id, Status__c FROM Property_SalesAI_History__c ORDER BY CreatedDate DESC LIMIT 1];
        
        System.assertEquals('Finished With Errors', executionRecord.Status__c, 'The status should be "Finished With Errors"');
    }
    
    @IsTest
    static void testCustomSettingNotPopulated() {
        Property_SalesAI_Settings__c orgDefaults = Property_SalesAI_Settings__c.getOrgDefaults();
        orgDefaults.IsSetupComplete__c = false;
        upsert orgDefaults;

        Test.startTest();
        LeadAndOppMatchingBatch batch = new LeadAndOppMatchingBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify that the Property_SalesAI_History__c record was inserted with an error status
        Property_SalesAI_History__c executionRecord = [SELECT Id, Status__c FROM Property_SalesAI_History__c ORDER BY CreatedDate DESC LIMIT 1];
        
        System.assertEquals('Finished With Errors', executionRecord.Status__c, 'The status should be "Finished With Errors"');
    }

    @isTest
    static void testBatchJobWithDuplicateSimilarityKey() {
        delete [SELECT id from Property_SalesAI__c];
        delete [SELECT id from Lead];
        delete [SELECT id from Opportunity];
        // Setup Test Data with duplicate Similarity_Key__c
        List<Lead> leadsToInsert = new List<Lead>();
        List<Opportunity> oppsToInsert = new List<Opportunity>();

        // Create leads with the same Similarity_Key__c
        for (Integer i = 0; i < 5; i++) {
            Lead lead = new Lead(LastName = 'Test Lead DuplicateKey' + i, Company = 'Test Company', Similarity_Key__c = 'DuplicateKey');
            leadsToInsert.add(lead);
            Opportunity opp = new Opportunity(Name = 'Test Opportunity DuplicateKey ' + i, StageName = 'Prospecting', CloseDate = Date.today(), Similarity_Key__c = 'DuplicateKey');
            oppsToInsert.add(opp);
        }
        // Insert the leads
        insert leadsToInsert;
        insert oppsToInsert;

        // Setup Property_SalesAI__c records to match with the leads
        Property__c property = new Property__c(Similarity_Key__c = 'DuplicateKey');
        insert property;

        Property_SalesAI__c propertySale = new Property_SalesAI__c(Property__c = property.Id);
        insert propertySale;

        // Execute the batch job
        Test.startTest();
        LeadAndOppMatchingBatch batch = new LeadAndOppMatchingBatch();
        Database.executeBatch(batch, 200); // Batch size of 200 should cover all records in one go
        Test.stopTest();

        // After batch job, check the updates (Optional: assert based on the expected outcome of the batch)
        List<Lead> updatedLeads = [SELECT Id, Status FROM Lead WHERE Status = 'Closed - Not Converted'];
        System.assertEquals(5, updatedLeads.size(), '5 Leads should be updated to "Closed - Not Converted" with DuplicateKey');

        // Check if the Property_SalesAI_Match__c records are created for the leads with the DuplicateKey
        List<Property_SalesAI_Match__c> matchedRecords = [SELECT Id FROM Property_SalesAI_Match__c WHERE Lead__c != null AND Property_SalesAI__c != null];
        System.assertEquals(5, matchedRecords.size(), '5 Property_SalesAI_Match__c records should be created for the DuplicateKey leads');
    }

    
    @IsTest
    static void testOpportunityFailed() {
        List<Opportunity> opps = [SELECT ID FROM Opportunity LIMIT 2];
        Id oppId;
        Opportunity opp;
        Opportunity opp2;
        if (!opps.isEmpty()) {
            opp = opps[0];
            oppId = opps[0].Id;
            opp2 = opps[1];
        }
        //DO THE SAME FOR Property_SalesAI__c
        List<Property_SalesAI__c> sps = [SELECT ID FROM Property_SalesAI__c LIMIT 1];
        Id spId;
        if (!sps.isEmpty()) {
            spId = sps[0].Id;
        }
        List<String> errorMessages = new List<String>{'Update Error 1', 'Update Error 2'};

        LeadAndOppMatchingBatch batch = new LeadAndOppMatchingBatch();
        batch.newRecord = new Property_SalesAI_History__c(); 
        // Call the method
        Test.startTest();
        batch.logFailedOppUpdate(opp, errorMessages);
        LeadAndOppMatchingBatchHelper.sendBatchCompletionEmail(1, 0, String.join(errorMessages,','), null, true);
        batch.logFailedOppUpdate(opp2, errorMessages);
        Test.stopTest();


        String expectedMessage = 'Opportunity update failed for Opportunity: '+ oppId + ' due to Update Error 1, Update Error 2';
        System.assert(batch.newRecord.Opportunity_Errors__c.contains(expectedMessage), 'Error: Opportunity_Errors__c was not set correctly in logFailedOppUpdate.');
        System.assertEquals('Finished With Errors', batch.newRecord.Status__c, 'Error: Status__c was not set to Finished With Errors.');
    }

    @isTest
    static void testLogFailedLeadUpdate() {
        List<Lead> lds = [SELECT ID FROM LEAD LIMIT 2];
        Id ldId;
        Lead ld1;
        Lead ld2;
        if (!lds.isEmpty()) {
            ld1 = lds[0];
            ldId = lds[0].Id;
            ld2 = lds[1];
        }
        //DO THE SAME FOR Property_SalesAI__c
        List<Property_SalesAI__c> sps = [SELECT ID FROM Property_SalesAI__c LIMIT 1];
        Id spId;
        if (!sps.isEmpty()) {
            spId = sps[0].Id;
        }

        // Create a list of error messages to simulate failures
        List<String> errorMessages = new List<String>{'Update Error 1', 'Update Error 2'};

        // Create an instance of LeadAndOppMatchingBatch
        LeadAndOppMatchingBatch batch = new LeadAndOppMatchingBatch();
        batch.newRecord = new Property_SalesAI_History__c(); 
        // Call the method
        Test.startTest();
        batch.logFailedLeadUpdate(ld1, errorMessages);
        LeadAndOppMatchingBatchHelper.sendBatchCompletionEmail(1, 0, String.join(errorMessages,','), null, true);
        batch.logFailedLeadUpdate(ld2, errorMessages);
        Test.stopTest();

        String expectedMessage = 'Lead update failed for lead: '+ ldId + ' due to Update Error 1, Update Error 2';
        System.assert(batch.newRecord.Lead_Errors__c.contains(expectedMessage), 'Error: Lead_Errors__c was not set correctly in logFailedLeadUpdate.');
        System.assertEquals('Finished With Errors', batch.newRecord.Status__c, 'Error: Status__c was not set to Finished With Errors.');
    }


    @isTest
    static void testLogFailedJunctionRelatedToLead() {
        List<Lead> lds = [SELECT ID FROM LEAD LIMIT 1];
        Id ldId;
        if (!lds.isEmpty()) {
            ldId = lds[0].Id;
        }
        //DO THE SAME FOR Property_SalesAI__c
        List<Property_SalesAI__c> sps = [SELECT ID FROM Property_SalesAI__c LIMIT 2];
        Id spId;
        if (!sps.isEmpty()) {
            spId = sps[0].Id;
        }

        // Create a mock Property_SalesAI_Match__c record
        Property_SalesAI_Match__c match = new Property_SalesAI_Match__c(
            Lead__c = ldId, // Mock Lead ID
            Property_SalesAI__c = spId // Mock Property Sales AI ID
        );

        // Create a list of error messages to simulate failures
        List<String> errorMessages = new List<String>{'Error 1', 'Error 2'};

        LeadAndOppMatchingBatch batch = new LeadAndOppMatchingBatch();

        Test.startTest();
        batch.newRecord = new Property_SalesAI_History__c(); 
        // Call the method
        batch.logFailedJunction(match, errorMessages, true);
        batch.logFailedJunction(match, errorMessages, true);
        Test.stopTest();

        // Assert that the Property_SalesAI_Errors__c field was populated correctly
        String expectedMessage = 'Property_SalesAI_Match__c record insert failed for Lead: ' + ldId + ' and SoldProperty record: ' + spId + ' due to Error 1, Error 2';
        System.assert(batch.newRecord.Property_SalesAI_Errors__c.contains(expectedMessage), 'Error: Property_SalesAI_Errors__c was not set correctly in logFailedJunction.');
        System.assertEquals('Finished With Errors', batch.newRecord.Status__c, 'Error: Status__c was not set to Finished With Errors.');
    }

    
    @isTest
    static void testLogFailedJunctionRelatedToOpp() {
        List<Opportunity> opps = [SELECT ID FROM Opportunity LIMIT 1];
        Id oppId;
        if (!opps.isEmpty()) {
            oppId = opps[0].Id;
        }
        //DO THE SAME FOR Property_SalesAI__c
        List<Property_SalesAI__c> sps = [SELECT ID FROM Property_SalesAI__c LIMIT 1];
        Id spId;
        if (!sps.isEmpty()) {
            spId = sps[0].Id;
        }

        // Create a mock Property_SalesAI_Match__c record
        Property_SalesAI_Match__c match = new Property_SalesAI_Match__c(
            Opportunity__c = oppId, // Mock Lead ID
            Property_SalesAI__c = spId // Mock Property Sales AI ID
        );

        // Create a list of error messages to simulate failures
        List<String> errorMessages = new List<String>{'Error 1', 'Error 2'};

        LeadAndOppMatchingBatch batch = new LeadAndOppMatchingBatch();

        Test.startTest();
        // Create a new mock record for the Property_SalesAI_Errors__c field
        batch.newRecord = new Property_SalesAI_History__c(); 
        // Call the method
        batch.logFailedJunction(match, errorMessages, false);
        Test.stopTest();

        // Assert that the Property_SalesAI_Errors__c field was populated correctly
        String expectedMessage = ' Property_SalesAI_Match__c record delete failed for Opportunity: '+ oppId + ' and SoldProperty record: ' + spId + ' due to Error 1, Error 2';
        System.assert(batch.newRecord.Property_SalesAI_Errors__c.contains(expectedMessage), 'Error: Property_SalesAI_Errors__c was not set correctly in logFailedJunction.');
        System.assertEquals('Finished With Errors', batch.newRecord.Status__c, 'Error: Status__c was not set to Finished With Errors.');
    }    

    @isTest
    static void testGetMatchingLeadsWithAccessAndNoDuration() {
        // Test case: User has access to Lead, no duration provided
        Test.startTest();
        List<String> keys = new List<String>{'KeyO_10001', 'KeyO_10002', 'KeyO_10003'};
        
        Set<Id> ids = Schema.SObjectType.Lead.getRecordTypeInfosById().keySet();
        List<String> recordTypeIds = new List<String>();
        for(Id i : ids) {
            recordTypeIds.add(i);
        }
        List<String> statuses = new List<String>{'Open - Not Contacted'};
        Integer duration = -1; 
        List<Lead> result = LeadAndOppMatchingBatchHelper.getMatchingLeads(keys, recordTypeIds, statuses, duration);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Expected result list of leads');
        System.assertEquals(3, result.size(), 'Expected 3 matching leads');

    }

    @isTest
    static void testGetMatchingOppsWithAccessAndNoDuration() {
        // Test case: User has access to Lead, no duration provided
        Test.startTest();
        List<String> keys = new List<String>{'KeyO_10001', 'KeyO_10002', 'KeyO_10003'};
        
        Set<Id> ids = Schema.SObjectType.Opportunity.getRecordTypeInfosById().keySet();
        List<String> recordTypeIds = new List<String>();
        for(Id i : ids) {
            recordTypeIds.add(i);
        }
        List<String> statuses = new List<String>{'Prospecting'};
        Integer duration = -1; 
        List<Opportunity> result = LeadAndOppMatchingBatchHelper.getMatchingOpps(keys, recordTypeIds, statuses, duration);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Expected result list of opps');
        System.assertEquals(3, result.size(), 'Expected 3 matching opps');

    }

}