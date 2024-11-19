@isTest
private with sharing class Lmg_SoldData_tst {
    
    @TestSetup
    static void setup() {
        // Insert a valid Subscription__c record
        Subscription__c subscription = new Subscription__c(County__c = 'TestCounty',state__c ='TestState');
        insert subscription;
    }

    // Helper method to create a LeadfuzionWrapper object
    private static Lmg_SoldData_cls.LeadfuzionWrapper createTestWrapper(String county, String state, String lf_subscription_id, String customData) {
        Lmg_SoldData_cls.LeadfuzionWrapper wrapper = new Lmg_SoldData_cls.LeadfuzionWrapper();
        wrapper.count = '1';
        wrapper.county = county;
        wrapper.state = state;
        wrapper.lf_subscription_id = lf_subscription_id;
        wrapper.custom = customData;
        wrapper.records = new List<Lmg_SoldData_cls.LeadfuzionRecord>();

        Lmg_SoldData_cls.LeadfuzionRecord record = new Lmg_SoldData_cls.LeadfuzionRecord();
        record.lfid = 'lfid123';
        record.seller_first_name = 'John';
        record.seller_last_name = 'Doe';
        record.buyer_first_name = 'Jane';
        record.buyer_last_name = 'Smith';
        record.property_address = '123 Test St';
        record.analytics_property_state = 'CA';
        record.analytics_property_county = county;
        record.analytics_property_zip = '12345';
        record.analytics_property_city = 'Test City';
        record.analytics_property_street = 'Test St';
        record.recording_date = '12/31/2023';
        record.sales_price = '100000';
        wrapper.records.add(record);

        return wrapper;
    }

    
        @isTest
    static void testReceiveDataWithInvalidToken() {
        // Prepare test data with an invalid token
        String requestBody = '{"custom":"invalidToken","county":"TestCounty","count":"5","records":[]}';
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/LmgPilot/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        RestContext.response = new RestResponse();

        // Call the method
        Test.startTest();
        Lmg_SoldData_cls.receiveData();
        Test.stopTest();

        // Assertions
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('{"message": "Token not Valid."}', RestContext.response.responseBody.toString());
    }
        @isTest
    	static void testReceiveDataWithUnsubscribedCounty() {
        Left_Main_Sold_Data_Setting__mdt metadataRecord = [SELECT Api_Token__c FROM Left_Main_Sold_Data_Setting__mdt WHERE DeveloperName = 'Connection1' LIMIT 1];
        String validToken = metadataRecord.Api_Token__c;
            
        // Prepare test data with an unsubscribed county
            //String requestBody = '{"custom":"'+validToken+'","county":"UnsubscribedCounty","count":"5","records":[\'null\']}';
            String requestBody = '{' + 
            '"lf_subscription_id":"123",' +
            '"count":"5",' +
            '"state":"TestState",' +
            '"county":"TestCounty2",' +
            '"custom":"'+validToken+'",' +
            '"records":[{' +
                '"lfid":"1",' +
                '"seller_first_name":"John",' +
                '"seller_last_name":"Doe",' +
                '"estimated_value":"100000",' +
                '"analytics_property_state":"TestState",' +
                '"analytics_property_county":"TestCounty",' +
                '"analytics_property_zip":"12345",' +
                '"analytics_property_city":"TestCity",' +
                '"analytics_property_street":"TestStreet",' +
                '"recording_date":"12/01/2022",' +
                '"sales_price":"200000",' +
                '"tax_assessed_value":"150000",' +
                '"status":"Active",' +
                '"buyer_first_name":"Jane",' +
                '"buyer_last_name":"Doe",' +
                '"buyer_mailing_address":"123 Buyer St"' +
            '}]}';
            
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/LmgPilot/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        RestContext.response = new RestResponse();

        // Call the method
        Test.startTest();
        Lmg_SoldData_cls.receiveData();
        Test.stopTest();

        // Assertions
        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('State And County Not Subscribed'));
    }
    
        @IsTest
    static void testBatchExecution() {
        // Prepare sample data for batch execution
        List<Lmg_SoldData_cls.LeadfuzionRecord> records = new List<Lmg_SoldData_cls.LeadfuzionRecord>();
        Lmg_SoldData_cls.LeadfuzionRecord record = new Lmg_SoldData_cls.LeadfuzionRecord();
        record.lfid = '1';
        record.seller_first_name = 'John';
        record.seller_last_name = 'Doe';
        record.estimated_value = '100000';
        record.analytics_property_state = 'TestState';
        record.analytics_property_county = 'TestCounty';
        record.analytics_property_zip = '12345';
        record.analytics_property_city = 'TestCity';
        record.analytics_property_street = 'TestStreet';
        records.add(record);
        
        Result_Subscription__c newResultSubscription = new Result_Subscription__c();
        newResultSubscription.Count__c = 3;
        newResultSubscription.State__c =  'state';
        newResultSubscription.County__c ='county';
        insert newResultSubscription;
        
        // Instantiate the batch class
        Lmg_SoldData_bch batchInstance = new Lmg_SoldData_bch(records,''+newResultSubscription.Id );

        Test.startTest();
        Database.executeBatch(batchInstance, 2000);
        Test.stopTest();

        // Validate batch processing by checking inserted records
        List<Property_SalesAI__c> sales = [SELECT Id, Seller_First_Name__c, Estimated_Value__c FROM Property_SalesAI__c];
        System.assertEquals(1, sales.size());
        System.assertEquals('John', sales[0].Seller_First_Name__c);
        System.assertEquals(100000, sales[0].Estimated_Value__c);
    }
    
     @isTest
    static void testReceiveDataWithException() {
        Left_Main_Sold_Data_Setting__mdt metadataRecord = [SELECT Api_Token__c FROM Left_Main_Sold_Data_Setting__mdt WHERE DeveloperName = 'Connection1' LIMIT 1];
        String validToken = metadataRecord.Api_Token__c;
        
        //Prepare test data to cause an exception
        String requestBody = '{"custom":"'+validToken+'","county":"TestCounty","count":"5","state":"TestState","records":null}';
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/LmgPilot/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        RestContext.response = new RestResponse();

        // Call the method
        Test.startTest();
        Lmg_SoldData_cls.receiveData();
        Test.stopTest();

        // Assertions

        System.assertEquals(400, RestContext.response.statusCode);        
        System.assert(RestContext.response.responseBody.toString().contains('Bad Request'));
    }
    
    @IsTest
    static void testReceiveDataSuccess() {
        Left_Main_Sold_Data_Setting__mdt metadataRecord = [SELECT Api_Token__c FROM Left_Main_Sold_Data_Setting__mdt WHERE DeveloperName = 'Connection1' LIMIT 1];
        String validToken = metadataRecord.Api_Token__c;

        // Valid request with correct token and county
        Lmg_SoldData_cls.LeadfuzionWrapper wrapper = createTestWrapper('TestCounty','TestState', 'validSubscriptionId', validToken);
        String jsonString = JSON.serialize(wrapper);

        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(jsonString);
        RestContext.response = new RestResponse();

        Test.startTest();
        Lmg_SoldData_cls.receiveData();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode, 'Expected success status code 200');
        System.assert(RestContext.response.responseBody.toString().contains('Operation Completed Successfully.'), 'Expected success message in response');
    }

    @IsTest
    static void testReceiveDataInvalidToken() {
        // Request with an invalid token
        Lmg_SoldData_cls.LeadfuzionWrapper wrapper = createTestWrapper('TestCounty', 'TestState','validSubscriptionId', 'invalidToken');
        String jsonString = JSON.serialize(wrapper);

        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(jsonString);
        RestContext.response = new RestResponse();

        Test.startTest();
        Lmg_SoldData_cls.receiveData();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode, 'Expected status code 400 for invalid token');
        System.assert(RestContext.response.responseBody.toString().contains('Token not Valid.'), 'Expected token validation error message');
    }

    @IsTest
    static void testReceiveDataWithInvalidCounty() {
        Left_Main_Sold_Data_Setting__mdt metadataRecord = [SELECT Api_Token__c FROM Left_Main_Sold_Data_Setting__mdt WHERE DeveloperName = 'Connection1' LIMIT 1];
        String validToken = metadataRecord.Api_Token__c;

        // Request with an invalid county
        Lmg_SoldData_cls.LeadfuzionWrapper wrapper = createTestWrapper('InvalidCounty','TestState', 'validSubscriptionId', validToken);
        String jsonString = JSON.serialize(wrapper);

        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(jsonString);
        RestContext.response = new RestResponse();

        Test.startTest();
        Lmg_SoldData_cls.receiveData();
        Test.stopTest();

       	System.assertEquals(400, RestContext.response.statusCode, 'Expected status code 400 for invalid county');
        //System.assert(RestContext.response.responseBody.toString().contains('County not subscribed.'), 'Expected county not subscribed message');
    }

    @IsTest
    static void testReceiveDataWithInvalidCount() {
        Left_Main_Sold_Data_Setting__mdt metadataRecord = [SELECT Api_Token__c FROM Left_Main_Sold_Data_Setting__mdt WHERE DeveloperName = 'Connection1' LIMIT 1];
        String validToken = metadataRecord.Api_Token__c;

        // Setting invalid `count` to trigger an error during data processing
        Lmg_SoldData_cls.LeadfuzionWrapper wrapper = createTestWrapper('TestCounty','TestState', 'validSubscriptionId', validToken);
        wrapper.count = 'invalidCount';  // Set count to a non-numeric value
        String jsonString = JSON.serialize(wrapper);

        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(jsonString);
        RestContext.response = new RestResponse();

        Test.startTest();
        try {
            Lmg_SoldData_cls.receiveData();
        } catch (Exception e) {
            System.debug('Exception caught: ' + e.getMessage());
        }
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode, 'Expected status 400 due to invalid count because now batch');
    }
    

    @IsTest
    static void testReceiveDataWithExceptionInInsertBulkRecords() {
        Left_Main_Sold_Data_Setting__mdt metadataRecord = [SELECT Api_Token__c FROM Left_Main_Sold_Data_Setting__mdt WHERE DeveloperName = 'Connection1' LIMIT 1];
        String validToken = metadataRecord.Api_Token__c;

        // Null required fields in `LeadfuzionRecord` to trigger a DML exception
        Lmg_SoldData_cls.LeadfuzionWrapper wrapper = createTestWrapper('TestCounty','TestState', 'validSubscriptionId', validToken);
        wrapper.records[0].seller_first_name = null; // Required field set to null
        String jsonString = JSON.serialize(wrapper);

        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(jsonString);
        RestContext.response = new RestResponse();

        Test.startTest();
        try {
            Lmg_SoldData_cls.receiveData();
        } catch (Exception e) {
            System.debug('Exception caught: ' + e.getMessage());
        }
        Test.stopTest();

       	System.assertEquals(200, RestContext.response.statusCode, 'Expected status 200 due to a DML exception');
        //System.assert(RestContext.response.responseBody.toString().contains('Bad request'), 'Expected error message in response body');
    }

    @IsTest
    static void testGenerateFileAndRelate() {
        // Step 1: Create a test record to relate the file to
        Result_Subscription__c testAccount = new Result_Subscription__c(Name = 'Test Account');
        insert testAccount;

        // Step 2: Create a sample JSON body that mimics the LeadfuzionWrapper structure
        String sampleJsonBody = '{"lf_subscription_id":"12345","county":"Test County","state":"TX","jobid":"job-123","records":[{"lfid":"lf-1","seller_first_name":"John","seller_last_name":"Doe","estimated_value":"500000","property_address":"123 Test St","analytics_property_state":"TX","analytics_property_county":"Test County","analytics_property_zip":"75001","analytics_property_city":"Test City","analytics_property_street":"Test St","recording_date":"2024-10-11","sales_price":"480000","tax_assessed_value":"450000","status":"Sold","buyer_first_name":"Jane","buyer_last_name":"Doe","buyer_mailing_address":"456 Buy St"}]}';

        // Step 3: Call the method
        Test.startTest();
        Lmg_Utilities_cls.generateFileAndRelate(testAccount.Id, sampleJsonBody);
        Test.stopTest();

        // Step 4: Verify the file was created and related to the test record
        List<ContentVersion> contentVersions = [
            SELECT Title, PathOnClient, VersionData, FirstPublishLocationId
            FROM ContentVersion
            WHERE FirstPublishLocationId = :testAccount.Id
        ];

        System.assertEquals(1, contentVersions.size(), 'A ContentVersion file should have been created.');
        ContentVersion createdFile = contentVersions[0];

        // Check the file title
        System.assert(createdFile.Title.startsWith('Leftmain Sold Data-Test County-12345'), 'The file title should match the expected format.');

        // Check the file path
        System.assert(createdFile.PathOnClient.endsWith('.csv'), 'The file path should end with .csv.');
    }
}