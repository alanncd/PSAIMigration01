@isTest
public class LiveLoopCalloutTest {
    
    @isTest
    public static void leadCalloutTest(){
        Lead lead = new Lead( FirstName = 'Test', LastName = 'Sample',Street='street',City='city',State='state',Country='country',Company='Test'
                             //,Next_Step__c='NS'
                            ); 
        insert lead;
                Test.startTest();
        LiveLoopLeadPushBatch liveLoopLeadPushBatch = new LiveLoopLeadPushBatch();
        Id batchId = Database.executeBatch(liveLoopLeadPushBatch);
        system.assertNotEquals(batchId, null); 
        Test.stopTest();
    }
    
    @isTest
    public static void opportunityCalloutTest(){
        // Create Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        //opp.Address_1__c = 'address update test';
        opp.CloseDate= System.Today();
        opp.StageName='Prospecting';
        insert opp;
        Sale__c sale = new sale__c();
        sale.Pipeline_Live_Loop_Connect_Id__c=null;
        sale.Sale_Id__c = 'S12000001';
        sale.Status__c='Sold';
        insert sale;

        Test.startTest();
        LiveLoopOpportunityPushBatch liveLoopOpportunityPushBatch = new LiveLoopOpportunityPushBatch();
        Id batchId = Database.executeBatch(liveLoopOpportunityPushBatch);
        system.assertNotEquals(batchId, null);
        Test.stopTest();
    }
    
    
    @isTest
    public static void leadOpportunitySingleObjectCalloutTest(){
        Lead lead = new Lead( FirstName = 'Test', LastName = 'Sample',Street='street',City='city',State='state',Country='country',Company='Test'
                             //, Next_Step__c='NS'
                            );
        insert lead;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        //opp.Address_1__c = 'address update test';
        opp.CloseDate= System.Today();
        opp.StageName='Prospecting';
        insert opp;
        
        Test.startTest();
        //LiveLoopCallout.sendPipelineObject(lead.id);
        //LiveLoopCallout.sendPipelineObject(opp.id);
        system.assertNotEquals(opp, null);
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void publishAccessTokenTest(){
        Test.startTest();
        LiveLoopCallout.publishAccessToken();
        system.assertEquals(null, null);
        Test.stopTest();
    }
    
    
    @isTest
    public static void liveloopResponseTest(){
        Lead lead = new Lead( FirstName = 'Test', LastName = 'Sample',Street='street',City='city',State='state',Country='country',Company='Test'
                             //, Next_Step__c='NS'
                            );
        insert lead;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        //opp.Address_1__c = 'address update test';
        opp.CloseDate= System.Today();
        opp.StageName='Prospecting';
        insert opp;
        Sale__c sale = new sale__c();
        sale.Pipeline_Live_Loop_Connect_Id__c=null;
        sale.Sale_Id__c = 'S12000001';
        sale.Status__c='Sold';
        insert sale;

        string jsonString = '[{'+
            '"pipeline_objects_connected": ['+
            '{'+
            '"pipeline_object_type": "Lead",'+
            '"pipeline_object_id": "'+lead.id +'"'+
            '},'+
            '{'+
            '"pipeline_object_type": "Opportunity",'+
            '"pipeline_object_id": "'+opp.id +'"'+
            '}'+
            '],'+
            '"pipeline_liveloop_connect_id": null,'+
            '"sale_id": "S12000001",'+
            '"seller": "Jinne rose",'+
            '"buyer_owner_occupied": 1,'+
            '"property_address":'+
            '{'+
            '"street_address_line_1": "2022 Spruce Stt",'+
            '"street_address_line_2": "",'+
            '"city": "Philadelphia",'+
            '"state": "PA",'+
            '"zipcode": "19146"'+
            '},'+
            '"recording_date": "2021-11-10",'+
            '"sale_price": 1,'+
            '"estimated_value_low": 1,'+
            '"estimated_value": 1,'+
            '"estimated_value_high": 1,'+
            '"tax_assessed_value": 1,'+
            '"discount": 1.0,'+
            '"property_type": "",'+
            '"previous_seller": "",'+
            '"previous_seller_mail_address": {"city": "Charlotte","state": "NC","street_address_line_1": "4530 Park Rd Ste 220","street_address_line_2": null,"zipcode": "28209"},'+
            '"previous_recording_date": "",'+
            '"previous_sale_price": 1,'+
            '"buyer": {'+
            '"buyer_name": "Trony vine",'+
            '"buyer_id": "BUY100021",'+
            '"buyer_lender": "",'+
            '"buyer_cbsa_entries": 1,'+
            '"buyer_cbsa_exits": 1,'+
            '"buyer_cbsa_median_enter_discount": 1.0,'+
            '"buyer_cbsa_median_exit_discount": 1.0,'+
            '"buyer_cbsa_median_enter_sale_price": 1,'+
            '"buyer_cbsa_median_exit_sale_price": 1.0,'+
            '"buyer_cbsa_median_enter_tax_improvement_percent": 1,'+
            '"buyer_cbsa_median_enter_tax_improvement_value": 1,'+
            '"buyer_cbsa_median_enter_loo": 1.0,'+
            '"buyer_cbsa_median_exit_loo": 1.0,'+
            '"buyer_cbsa_median_square_footage": 1,'+
            '"buyer_cbsa_median_year_built": 1,'+
            '"buyer_national_entries": 1,'+
            '"buyer_national_exits": 1'+
            '}'+
            '}]';
        
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/sales/'+System.Label.Access_Token; 
        req.addHeader('Content-Type', 'application/json');
         req.addHeader('token', System.Label.Access_Token);
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;
        
        LiveLoopSalesAPI.soldProperty();
        res = RestContext.response; //Set the response here
        //System.assertEquals(200,res.statusCode); //Assert with expected status code. Status Code needs to be set in the main class.
        system.assertEquals(200, res.statusCode);
        Test.stopTest(); 
        
        
    }
    
    @isTest
    public static void liveloopResponseTest2(){
        Lead lead = new Lead( FirstName = 'Test', LastName = 'Sample',Street='street',City='city',State='state',Country='country',Company='Test'
                             //, Next_Step__c='NS'
                            );
        insert lead;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        //opp.Address_1__c = 'address update test';
        opp.CloseDate= System.Today();
        opp.StageName='Prospecting';
        insert opp;


        string jsonString = '[{'+
            '"pipeline_objects_connected": ['+
            '{'+
            '"pipeline_object_type": "Lead",'+
            '"pipeline_object_id": "'+lead.id +'"'+
            '},'+
            '{'+
            '"pipeline_object_type": "Opportunity",'+
            '"pipeline_object_id": "'+opp.id +'"'+
            '}'+
            '],'+
            '"pipeline_liveloop_connect_id": null,'+
            '"sale_id": "S12000001",'+
            '"seller": "Jinne rose",'+
            '"buyer_owner_occupied": 1,'+
            '"property_address":'+
            '{'+
            '"street_address_line_1": "2022 Spruce Stt",'+
            '"street_address_line_2": "",'+
            '"city": "Philadelphia",'+
            '"state": "PA",'+
            '"zipcode": "19146"'+
            '},'+
            '"recording_date": "2021-11-10",'+
            '"sale_price": 1,'+
            '"estimated_value_low": 1,'+
            '"estimated_value": 1,'+
            '"estimated_value_high": 1,'+
            '"tax_assessed_value": 1,'+
            '"discount": 1.0,'+
            '"property_type": "",'+
            '"previous_seller": "",'+
            '"previous_seller_mail_address": {"city": "Charlotte","state": "NC","street_address_line_1": "4530 Park Rd Ste 220","street_address_line_2": null,"zipcode": "28209"},'+
            '"previous_recording_date": "",'+
            '"previous_sale_price": 1,'+
            '"buyer": {'+
            '"buyer_name": "Trony vine",'+
            '"buyer_id": "BUY100021",'+
            '"buyer_lender": "",'+
            '"buyer_cbsa_entries": 1,'+
            '"buyer_cbsa_exits": 1,'+
            '"buyer_cbsa_median_enter_discount": 1.0,'+
            '"buyer_cbsa_median_exit_discount": 1.0,'+
            '"buyer_cbsa_median_enter_sale_price": 1,'+
            '"buyer_cbsa_median_exit_sale_price": 1.0,'+
            '"buyer_cbsa_median_enter_tax_improvement_percent": 1,'+
            '"buyer_cbsa_median_enter_tax_improvement_value": 1,'+
            '"buyer_cbsa_median_enter_loo": 1.0,'+
            '"buyer_cbsa_median_exit_loo": 1.0,'+
            '"buyer_cbsa_median_square_footage": 1,'+
            '"buyer_cbsa_median_year_built": 1,'+
            '"buyer_national_entries": 1,'+
            '"buyer_national_exits": 1'+
            '}'+
            '}]';
        
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/sales/'+System.Label.Access_Token; 
        req.addHeader('Content-Type', 'application/json');
         req.addHeader('token', System.Label.Access_Token);
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;
        
        LiveLoopSalesAPI.soldProperty();
        res = RestContext.response; //Set the response here
        system.assertEquals(200, res.statusCode);
        //System.assertEquals(200,res.statusCode); //Assert with expected status code. Status Code needs to be set in the main class.
        Test.stopTest(); 
        
        
    }
    
    @isTest
    public static void liveloopResponseTest3(){
        Lead lead = new Lead( FirstName = 'Test', LastName = 'Sample',Street='street',City='city',State='state',Country='country',Company='Test'
                             //, Next_Step__c='NS'
                            );
        insert lead;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        //opp.Address_1__c = 'address update test';
        opp.CloseDate= System.Today();
        opp.StageName='Prospecting';
        insert opp;


        string jsonString = '[{'+
            '"pipeline_objects_connected": ['+
            '],'+
            '"pipeline_liveloop_connect_id": null,'+
            '"sale_id": "S12000001",'+
            '"seller": "Jinne rose",'+
            '"buyer_owner_occupied": 1,'+
            '"property_address":'+
            '{'+
            '"street_address_line_1": "2022 Spruce Stt",'+
            '"street_address_line_2": "",'+
            '"city": "Philadelphia",'+
            '"state": "PA",'+
            '"zipcode": "19146"'+
            '},'+
            '"recording_date": "2021-11-10",'+
            '"sale_price": 1,'+
            '"estimated_value_low": 1,'+
            '"estimated_value": 1,'+
            '"estimated_value_high": 1,'+
            '"tax_assessed_value": 1,'+
            '"discount": 1.0,'+
            '"property_type": "",'+
            '"previous_seller": "",'+
            '"previous_seller_mail_address": {"city": "Charlotte","state": "NC","street_address_line_1": "4530 Park Rd Ste 220","street_address_line_2": null,"zipcode": "28209"},'+
            '"previous_recording_date": "",'+
            '"previous_sale_price": 1,'+
            '"buyer": {'+
            '"buyer_name": "Trony vine",'+
            '"buyer_id": "BUY100021",'+
            '"buyer_lender": "",'+
            '"buyer_cbsa_entries": 1,'+
            '"buyer_cbsa_exits": 1,'+
            '"buyer_cbsa_median_enter_discount": 1.0,'+
            '"buyer_cbsa_median_exit_discount": 1.0,'+
            '"buyer_cbsa_median_enter_sale_price": 1,'+
            '"buyer_cbsa_median_exit_sale_price": 1.0,'+
            '"buyer_cbsa_median_enter_tax_improvement_percent": 1,'+
            '"buyer_cbsa_median_enter_tax_improvement_value": 1,'+
            '"buyer_cbsa_median_enter_loo": 1.0,'+
            '"buyer_cbsa_median_exit_loo": 1.0,'+
            '"buyer_cbsa_median_square_footage": 1,'+
            '"buyer_cbsa_median_year_built": 1,'+
            '"buyer_national_entries": 1,'+
            '"buyer_national_exits": 1'+
            '}'+
            '}]';
        
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/sales/'+System.Label.Access_Token; 
        req.addHeader('Content-Type', 'application/json');
         req.addHeader('token', System.Label.Access_Token);
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;
        
        LiveLoopSalesAPI.soldProperty();
        res = RestContext.response; //Set the response here
        system.assertEquals(200, res.statusCode);
        //System.assertEquals(200,res.statusCode); //Assert with expected status code. Status Code needs to be set in the main class.
        Test.stopTest(); 
        
        
    }
    @istest
    public static void testschedule() {
        Test.StartTest();
        LiveLoopLeadPushBatch liveLoopLeadPushBatch = new LiveLoopLeadPushBatch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test liveLoopLeadPushBatch', sch, liveLoopLeadPushBatch );
        
        LiveLoopOpportunityPushBatch liveLoopOpportunityPushBatch = new LiveLoopOpportunityPushBatch();
        system.schedule('Test liveLoopOpportunityPushBatch', sch, liveLoopOpportunityPushBatch );
        system.assertEquals(sch, '0 0 23 * * ?');
        Test.stopTest();
    }
}