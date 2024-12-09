@isTest
private class ConfigurationControllerTest {

    @testSetup
    static void setupTestData() {
        // Initialize custom settings with default values
        Property_SalesAI_Settings__c settings = new Property_SalesAI_Settings__c(
            Lead_Address_PostalCode__c = '12345',
            Lead_Address_State__c = 'CA',
            Lead_Address_Street__c = '123 Main St',
            Lead_Address_City__c = 'San Francisco',
            Lead_Record_Types__c = 'LeadRecordTypeId',
            Lead_History_Duration__c = 90,
            Lead_Status__c = 'Open',
            Matched_Lead_Reason__c = 'Duplicate',
            Matched_Lead_Reason_Field__c = 'Reason__c',
            Matched_Lead_Status__c = 'Closed',

            Opportunity_Address_PostalCode__c = '67890',
            Opportunity_Address_State__c = 'NY',
            Opportunity_Address_Street__c = '456 Broadway',
            Opportunity_Address_City__c = 'New York',
            Opportunity_Record_Types__c = 'OppRecordTypeId',
            Opportunity_History_Duration__c = 180,
            Opportunity_Stage__c = 'Prospecting',
            Matched_Opportunity_Reason__c = 'Existing Client',
            Matched_Opportunity_Reason_Field__c = 'Reason__c',
            Matched_Opportunity_Stage__c = 'Closed Won',

            Property_Sales_History_Duration__c = 365,
            Matching_Day__c = 'Monday', // Converted Date to String
            IsSetupComplete__c = false
        );
        insert settings;
        // Insert a sample Property_SalesAI_History__c record for testing
        Property_SalesAI_History__c historyRecord = new Property_SalesAI_History__c(
            Name = 'Test History',
            Finish_Time__c = DateTime.now().addDays(-1),
            Status__c = 'Completed'
        );
        insert historyRecord;
    }

    @isTest
    static void testGetRecordTypes() {
        // Query existing RecordTypes
        List<RecordType> leadRecordTypes = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Lead' LIMIT 1];
        List<RecordType> oppRecordTypes = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' LIMIT 1];

        Test.startTest();
        List<RecordType> returnedLeadRecordTypes = ConfigurationController.getRecordTypes('Lead');
        List<RecordType> returnedOppRecordTypes = ConfigurationController.getRecordTypes('Opportunity');
        Test.stopTest();

        System.assertNotEquals(0, returnedLeadRecordTypes.size(), 'Lead record types should not be empty');
        System.assertNotEquals(0, returnedOppRecordTypes.size(), 'Opportunity record types should not be empty');
    }

    @isTest
    static void testGetStatuses() {
        Test.startTest();
        List<ConfigurationController.PickListWrapper> leadStatuses = ConfigurationController.getStatuses('Lead');
        List<ConfigurationController.PickListWrapper> oppStages = ConfigurationController.getStatuses('Opportunity');
        Test.stopTest();

        System.assertNotEquals(0, leadStatuses.size(), 'Lead statuses should not be empty');
        System.assertNotEquals(0, oppStages.size(), 'Opportunity stages should not be empty');
    }

    @isTest
    static void testGetCustomSettingValues() {
        Test.startTest();
        Map<String, Object> customSettings = ConfigurationController.getCustomSettingValues();
        Test.stopTest();

        System.assertEquals('12345', customSettings.get('Lead_Address_PostalCode'), 'Lead_Address_PostalCode should match');
        System.assertEquals('CA', customSettings.get('Lead_Address_State'), 'Lead_Address_State should match');
        System.assertEquals(false, customSettings.get('IsSetupComplete'), 'IsSetupComplete should be false initially');
    }

    @isTest
    static void testUpdateIsSetupComplete() {
        Property_SalesAI_Settings__c settingsBefore = [SELECT IsSetupComplete__c FROM Property_SalesAI_Settings__c LIMIT 1];
        System.assertEquals(false, settingsBefore.IsSetupComplete__c, 'IsSetupComplete should be false before update');
        List<CronTrigger> scheduledJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Matching logic weekly run'];
        if (!scheduledJobs.isEmpty()) {
            System.abortJob(scheduledJobs[0].Id);
        }
    
        Test.startTest();
        ConfigurationController.updateIsSetupComplete();
        Test.stopTest();

        Property_SalesAI_Settings__c settingsAfter = [SELECT IsSetupComplete__c FROM Property_SalesAI_Settings__c LIMIT 1];
        System.assertEquals(true, settingsAfter.IsSetupComplete__c, 'IsSetupComplete should be true after update');
    }

    @isTest
    static void testUpdateIsSetupCompleteJobScheduledTwice() {
        // Ensure IsSetupComplete is false before the test
        Property_SalesAI_Settings__c settingsBefore = [SELECT IsSetupComplete__c FROM Property_SalesAI_Settings__c LIMIT 1];
        System.assertEquals(false, settingsBefore.IsSetupComplete__c, 'IsSetupComplete should be false before update');
    
        // Abort any existing scheduled jobs named "Matching logic weekly run"
        List<CronTrigger> scheduledJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Matching logic weekly run'];
        for (CronTrigger ct : scheduledJobs) {
            System.abortJob(ct.Id);
        }
    
        Test.startTest();
        ConfigurationController.updateIsSetupComplete();    
        try {
            ConfigurationController.updateIsSetupComplete();
        } catch (Exception e) {
            System.debug('Exception message: ' + e.getMessage());
            System.assert(e.getMessage().contains('already scheduled'), 'Expected exception when scheduling job twice. Actual message: ' + e.getMessage());
        }
        Test.stopTest();
        Property_SalesAI_Settings__c settingsAfter = [SELECT IsSetupComplete__c FROM Property_SalesAI_Settings__c LIMIT 1];
        System.assertEquals(true, settingsAfter.IsSetupComplete__c, 'IsSetupComplete should be true after update');
        List<CronTrigger> jobsAfter = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Matching logic weekly run'];
        System.assertEquals(1, jobsAfter.size(), 'Only one scheduled job should exist');
    }
    
    @isTest
    static void testGetCronExpressionFromDayNullDay() {
        // Delete the custom setting to simulate missing configuration
        delete [SELECT Id FROM Property_SalesAI_Settings__c LIMIT 1];

        Test.startTest();
        // Call the method with null input
        String cronExpression = ConfigurationController.getCronExpressionFromDay(null);
        Test.stopTest();

        // Assert that cronExpression is null
        System.assertEquals(null, cronExpression, 'Cron expression should be null when day is null');
    }


    @isTest
    static void testSaveCustomSettingValidData() {
        Map<String, String> settingsMap = new Map<String, String>{
            'Lead_Address_PostalCode__c' => '99999',
            'Lead_History_Duration__c'   => '45',
            'Lead_Status__c'             => 'New;Working',
            'Opportunity_Stage__c'       => 'Qualification',
            'Property_Sales_History_Duration__c' => '730'
        };

        Test.startTest();
        ConfigurationController.saveCustomSetting('Lead', settingsMap);
        Test.stopTest();

        Property_SalesAI_Settings__c updatedSettings = [SELECT Lead_Address_PostalCode__c, Lead_History_Duration__c, Lead_Status__c, Opportunity_Stage__c, Property_Sales_History_Duration__c FROM Property_SalesAI_Settings__c LIMIT 1];

        System.assertEquals('99999', updatedSettings.Lead_Address_PostalCode__c, 'Lead_Address_PostalCode should be updated');
        System.assertEquals(45, updatedSettings.Lead_History_Duration__c, 'Lead_History_Duration should be updated');
        System.assertEquals('New;Working', updatedSettings.Lead_Status__c, 'Lead_Status__c should be updated');
        System.assertEquals('Qualification', updatedSettings.Opportunity_Stage__c, 'Opportunity_Stage should be updated');
        System.assertEquals(730, updatedSettings.Property_Sales_History_Duration__c, 'Property_Sales_History_Duration should be updated');
    }

    @isTest
    static void testSaveCustomSettingInvalidField() {
        Map<String, String> settingsMap = new Map<String, String>{
            'Invalid_Field__c' => 'Some Value'
        };

        Test.startTest();
        try {
            ConfigurationController.saveCustomSetting('Lead', settingsMap);
            System.assert(false, 'Expected an exception due to invalid field');
        } catch (Exception e) {
            System.debug('Exception message: ' + e.getMessage());
            System.assert(e.getMessage().contains('Field does not exist'), 'Exception message should indicate missing field. Actual message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testPutFieldMethod() {
        Map<String, String> settingsMap = new Map<String, String>{
            'Lead_Address_State__c' => 'TX'
        };

        Test.startTest();
        ConfigurationController.saveCustomSetting('Lead', settingsMap);
        Test.stopTest();

        Property_SalesAI_Settings__c updatedSettings = [SELECT Lead_Address_State__c FROM Property_SalesAI_Settings__c LIMIT 1];
        System.assertEquals('TX', updatedSettings.Lead_Address_State__c, 'Lead_Address_State should be updated to TX');
    }

    @isTest
    static void testSaveCustomSettingNonIntegerDuration() {
        Map<String, String> settingsMap = new Map<String, String>{
            'Lead_History_Duration__c' => 'NotANumber'
        };

        Test.startTest();
        try {
            ConfigurationController.saveCustomSetting('Lead', settingsMap);
            System.assert(false, 'Expected an exception due to invalid integer conversion');
        } catch (Exception e) {
            System.debug('Exception message: ' + e.getMessage());
            System.assert(e.getMessage().contains('Error saving custom settings'), 'Exception message should indicate error saving settings. Actual message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testGetStatusesInvalidObject() {
        Test.startTest();
        List<ConfigurationController.PickListWrapper> statuses = ConfigurationController.getStatuses('InvalidObject');
        Test.stopTest();

        System.assertEquals(0, statuses.size(), 'Statuses list should be empty for invalid object');
    }

    @isTest
    static void testGetHistory() {
        // Call the Apex method
        Test.startTest();
        Map<String,Object> result = ConfigurationController.getExecutionHistory();
        Test.stopTest();

        // Validate the result is not null and contains the expected data
        System.assertNotEquals(null, result, 'Expected to retrieve a history record');
    //    System.assertEquals(0, result.get('Matched_Leads__c'), 'Expected 0 matched leads');
      //  System.assertEquals(0, result.get('Matched_Opportunities__c'), 'Expected 0 matched opportunities');
        System.assertEquals('Completed', result.get('Status__c'), 'Expected status to be Completed');
    }

    @isTest
    static void testGetPicklistValuesForField() {

        List<ConfigurationController.PickListWrapper> picklistValues = ConfigurationController.getPicklistValuesForField('Lead', 'Industry');

        // Assert: Verify that the picklist values are returned correctly
        System.assertNotEquals(null, picklistValues, 'Picklist values should not be null');
        System.assert(picklistValues.size() > 0, 'Picklist values should be retrieved');
    }

}