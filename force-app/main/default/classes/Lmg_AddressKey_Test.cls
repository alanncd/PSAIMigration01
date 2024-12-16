@IsTest
public class Lmg_AddressKey_Test {

    // Mock returns a success response with a match key referencing our test lead
    private class AddressKeyHttpMock implements HttpCalloutMock {
        Id leadId;
        AddressKeyHttpMock(Id leadId) {
            this.leadId = leadId;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String json = '{"Status":"success","Message":"OK","MatchKeys":[' +
                          '{"Data":"123 Main St","Reference":"' + String.valueOf(leadId) + '","SimKey":"SIMKEY123"}]}';
            res.setBody(json);
            return res;
        }
    }

    @TestSetup
    static void setupTestData() {
        // Insert a user and assign the permission set BEFORE inserting any non-setup data.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email='testuser@example.com',
            Username='testuser'+System.currentTimeMillis()+'@example.com',
            Alias='tusr',
            TimeZoneSidKey='America/Los_Angeles',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            ProfileId=p.Id,
            LanguageLocaleKey='en_US'
        );
        insert testUser;

        System.runAs(new User(Id = Userinfo.getUserId())) {
        
            // Assign the "Property_SalesAI_Admin" permission set to the user
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Property_SalesAI_Admin' LIMIT 1];
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = testUser.Id,
                PermissionSetId = ps.Id
            );
            insert psa; 
        }
        
        // Retrieve standard record types by querying. We assume the default record types exist.
        Id leadRtId = [SELECT Id FROM RecordType WHERE SObjectType='Lead' AND IsActive = true LIMIT 1].Id;
        Id oppRtId = [SELECT Id FROM RecordType WHERE SObjectType='Opportunity' AND IsActive = true LIMIT 1].Id;
        Id accountRtId = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND IsActive = true LIMIT 1].Id;

        // Create an Account with BillingStreet and BillingPostalCode
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '456 Opp St',
            BillingPostalCode = '67890',
            recordTypeId = accountRtId
        );
        insert testAccount;

        // Insert required custom settings with real record type IDs
        // Update the Opportunity_Address_Street__c and Opportunity_Address_PostalCode__c to the formula fields:
        // These formula fields map to Account.BillingStreet and Account.BillingPostalCode.
        Property_SalesAI_Settings__c propSettings = new Property_SalesAI_Settings__c(
            SetupOwnerId=UserInfo.getOrganizationId(),
            Lead_Record_Types__c=leadRtId, // Use actual record type id
            Lead_Status__c='Open - Not Contacted',
            Lead_Status_2__c=',Working - Contacted', 
            Lead_History_Duration__c=30,
            Opportunity_Record_Types__c=oppRtId, // Use actual record type id
            Opportunity_Stage__c='Prospecting',
            Opportunity_Stage_2__c=',Qualification',
            Opportunity_History_Duration__c=30,
            Lead_Address_Street__c='Street',
            Lead_Address_PostalCode__c='PostalCode',
            Opportunity_Address_Street__c='Left_Main__Street__c',
            Opportunity_Address_PostalCode__c='Left_Main__PostalCode__c'
        );
        insert propSettings;

        // Insert test lead
        Lead testLead = new Lead(
            FirstName='Test',
            LastName='Lead',
            Company='Test Company',
            Street='123 Test St',
            PostalCode='12345',
            RecordTypeId=leadRtId,
            Status='Open - Not Contacted'
        );
        insert testLead;
        
        // Insert test opportunity linked to the account
        Opportunity testOpp = new Opportunity(
            Name='Test Opportunity',
            StageName='Prospecting',
            CloseDate=Date.today().addDays(30),
            AccountId = testAccount.Id,
            RecordTypeId=oppRtId
        );
        insert testOpp;

        // Insert test property
        Property__c testProperty = new Property__c(
            Street__c='789 Property Ave',
            Zip_Code__c='99999'
        );
        insert testProperty;

        // Insert similarity key settings
        Similarity_Key_Setting__c simKeySetting = new Similarity_Key_Setting__c(
            SetupOwnerId=UserInfo.getOrganizationId(),
            Env_Mode__c='Dev',
            Size_Lead__c=200,
            Size_Opportunity__c=200,
            Size_Properties__c=200
        );
        insert simKeySetting;
    }

    
    @isTest
    static void testLmg_SimilarityKey_bth_LeadTest(){
        User userId = [Select id from User where email='testuser@example.com'];
         System.runAs(userId) {
        // Set the HTTP mock to return a valid response with the test lead Id as Reference
       	Lead lead = [Select id from Lead LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new AddressKeyHttpMock(lead.Id));

        Test.startTest();
        // Execute the Lead batch
        Lmg_SimilarityKey_Bth leadBatch = new Lmg_SimilarityKey_Bth('Lead',null);
        Database.executeBatch(leadBatch, 100);
        Test.stopTest();
        List<Lead> listLead = [select id from Lead where Similarity_Key__c != Null];
    	System.assertEquals(1, listLead.size(), 'The actual value does not match the expected value.');
        }
    }
    
        @isTest
    	static void testLmg_SimilarityKey_bth_scheduled(){
            User userId = [Select id from User where email='testuser@example.com'];
             System.runAs(userId) {
                 Test.startTest();
                // Test scheduleNightlyBatch - just call and ensure no exceptions
                Lmg_AddressKeyIntegration_cls.scheduleNightlyBatch();
                Test.stopTest();
                // Query the scheduled job
        		CronTrigger ct = [SELECT Id, State, CronJobDetail.Name
                           FROM CronTrigger 
                           WHERE CronJobDetail.Name = 'Nightly Similarity Key Batch'
                           LIMIT 1];

                // Assert that the scheduled job exists
                System.assertNotEquals(null, ct, 'The scheduled job should exist.'); 
            }
    	}

            /**
     * @description Test to validate the creation of a default custom setting.
     */
    @isTest
    static void testCreateCustomSettingDefault_NewRecord() {
        // Ensure no default custom setting exists
        delete [SELECT Id FROM Similarity_Key_Setting__c];
        
        Test.startTest();
        // Call the method
        Lmg_SimilarityKeyHelper_cls.createCustomSettingDefault();
        Test.stopTest();
        
        // Verify a default record is created with correct values
        Similarity_Key_Setting__c customSettings = Similarity_Key_Setting__c.getOrgDefaults();
        System.assertNotEquals(null, customSettings, 'Custom settings should be created.');
        System.assertEquals(100, customSettings.Size_Lead__c, 'Size_Lead__c should be set to 100.');
        System.assertEquals(100, customSettings.Size_Properties__c, 'Size_Properties__c should be set to 100.');
        System.assertEquals(100, customSettings.Size_Opportunity__c, 'Size_Opportunity__c should be set to 100.');
    }

    
}