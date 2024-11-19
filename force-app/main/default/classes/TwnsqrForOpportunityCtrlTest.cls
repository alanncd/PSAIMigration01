@isTest
public class TwnsqrForOpportunityCtrlTest {
    
    @testSetup static void createData() {
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
    }

   	static testMethod void testMethod1() {
        List<Opportunity> oppList = [SELECT Id,Address_1__c FROM Opportunity];
		Test.StartTest(); 
			ApexPages.StandardSetController sc = new ApexPages.StandardSetController(oppList);
        	sc.setSelected(oppList);
			TwnsqrForOpportunityCtrl obj = new TwnsqrForOpportunityCtrl(sc);
         	Test.setMock(HttpCalloutMock.class, new RestMock());
        	obj.getTwnsqrUpdate();
		Test.StopTest();
	}
    
    static testMethod void testMethod2() {
        List<Opportunity> oppList = new List<Opportunity>();
		Test.StartTest(); 
			ApexPages.StandardSetController sc = new ApexPages.StandardSetController(oppList);
        	sc.setSelected(oppList);
			TwnsqrForOpportunityCtrl obj = new TwnsqrForOpportunityCtrl(sc);
		Test.StopTest();
	}
    
    static testMethod void testMethod3() {
		List<Opportunity> oppList = new List<Opportunity>();
		Test.StartTest(); 
			ApexPages.StandardSetController sc = new ApexPages.StandardSetController(oppList);
        	sc.setSelected(oppList);
			TwnsqrForOpportunityCtrl obj = new TwnsqrForOpportunityCtrl(sc);
        	obj.hideToast();
		Test.StopTest();
	}
    
    static testMethod void testMethod4() {
        List<Opportunity> oppList = [SELECT Id,Address_1__c FROM Opportunity];
        oppList[0].Address_1__c = null;
        update oppList;
		Test.StartTest(); 
			ApexPages.StandardSetController sc = new ApexPages.StandardSetController(oppList);
        	sc.setSelected(oppList);
			TwnsqrForOpportunityCtrl obj = new TwnsqrForOpportunityCtrl(sc);
         	Test.setMock(HttpCalloutMock.class, new RestMock());
        	obj.getTwnsqrUpdate();
		Test.StopTest();
	}
    private class RestMock implements HttpCalloutMock {
        List<Opportunity> oppList = [SELECT Id,Address_1__c FROM Opportunity];
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{\"data\":{\"MatchingDemands\":[{\"args\":{\"address\":\"1119NorthEuclidAvePittsburgh\",\"addressFormatted\":\"1119NEuclidAve,Pittsburgh,PA15206,USA\",\"idempotencyKey\":\"'+oppList[0].Id+'\"},\"success\":true,\"contacts\":9159,\"buyBoxes\":1}]}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}