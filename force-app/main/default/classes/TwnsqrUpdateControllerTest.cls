@isTest
public class TwnsqrUpdateControllerTest {
	
    @testSetup static void createData() {
        Lead leadRec = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open',
                    Street = '2100 Woodward Ave',
                    City = 'Detroit',
                    State = 'MI',
                    PostalCode = '48201',
                    Country = 'US');
        insert leadRec;
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        Account testAccount = new Account(Name='Test Account',BillingStreet = '2100 Woodward Ave',
                                          BillingCity = 'Detroit',
                                          BillingState = 'MI',
                                          BillingCountry = 'US',
                                          BillingPostalCode = '48201',recordTypeId = recTypeId);
        insert testAccount;
        Opportunity testOpportunity = new Opportunity(
            StageName = 'Sourcing Demand',
            CloseDate = Date.valueOf('2016-01-01'),
            AccountId = testAccount.Id,
            Name = 'Test Opportunity',
            Address_1__c='2100 Woodward Ave Detroit MI 48201 US'
        );
        insert testOpportunity;
        
        Transactions__c transRec = new Transactions__c();
        transRec.Opportunity__c = testOpportunity.Id;
        transRec.Closing_Date__c = Date.valueOf('2022-07-10');
        transRec.Contract_Purchase_Price__c = 22;
        transRec.Disposition_Decision__c = 'Wholesale';
        insert transRec;
    }
    
    @isTest
    static void getTwnsqrUpdateTest(){
        Lead leadRec = [SELECT Id FROM Lead LIMIT 1];
        TwnsqrUpdateController twnsqr = new TwnsqrUpdateController();
        twnsqr.objectName = 'Lead';
        twnsqr.recordId = leadRec.id;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            twnsqr.getTwnsqrUpdate();
        Test.stopTest();
    }
    
    @isTest
    static void getTwnsqrUpdateTest1(){
        Opportunity oppRec = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        TwnsqrUpdateController twnsqr = new TwnsqrUpdateController();
        twnsqr.objectName = 'Opportunity';
        twnsqr.recordId = oppRec.id;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            twnsqr.getTwnsqrUpdate();
        Test.stopTest();
    }
    
    @isTest
    static void getTwnsqrUpdateTest2(){
        Transactions__c transRec = [SELECT Id,Opportunity__c,Opportunity__r.Account.BillingAddress FROM Transactions__c LIMIT 1];
        
        TwnsqrUpdateController twnsqr = new TwnsqrUpdateController();
        twnsqr.objectName = 'Transactions__c';
        twnsqr.recordId = transRec.id;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            twnsqr.getTwnsqrUpdate();
        Test.stopTest();
    }
    
    @isTest
    static void getTwnsqrUpdateTest3(){
        Lead leadRec = [SELECT ID, Street,City,State,PostalCode,Country FROM Lead LIMIT 1];
        leadRec.Street= null;
        leadRec.City= null;
        leadRec.State= null;
        leadRec.PostalCode= null;
        leadRec.Country= null;
        update leadRec;
        TwnsqrUpdateController twnsqr = new TwnsqrUpdateController();
        twnsqr.objectName = 'Lead';
        twnsqr.recordId = leadRec.id;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            twnsqr.getTwnsqrUpdate();
        Test.stopTest();
    }
    
    @isTest
    static void getTwnsqrUpdateTest4(){
        Lead leadRec = [SELECT ID, Street,City,State,PostalCode,Country FROM Lead LIMIT 1];
        TwnsqrUpdateController twnsqr = new TwnsqrUpdateController();
        twnsqr.objectName = 'Lead';
        twnsqr.recordId = leadRec.id;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockError());
            twnsqr.getTwnsqrUpdate();
        Test.stopTest();
    }
    
    @isTest
    static void hideToastTest(){
        TwnsqrUpdateController twnsqr = new TwnsqrUpdateController();
        twnsqr.hideToast();
    }
    
    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"data":{"MatchingDemands":[{"args":{"address":"525 S. Lexington Ave Burlington NC 27215 USA","addressFormatted":"525 S Lexington Ave, Burlington, NC 27215, USA"},"success":true,"contacts":61997,"buyBoxes":0}]}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class RestMockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"data":{"MatchingDemands":[{"args":{"address":"ghghghhhhhh "},"success":false,"error":"No results found for address: ghghghhhhhh "}]}}';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}