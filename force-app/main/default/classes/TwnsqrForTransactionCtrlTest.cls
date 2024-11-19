@isTest
public class TwnsqrForTransactionCtrlTest {
    
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
        
        Transactions__c transRec = new Transactions__c();
        transRec.Opportunity__c = testOpportunity.Id;
        transRec.Closing_Date__c = Date.valueOf('2022-07-10');
        transRec.Contract_Purchase_Price__c = 22;
        transRec.Disposition_Decision__c = 'Wholesale';
        insert transRec;
    }

   	static testMethod void testMethod1() {
        List<Transactions__c> transList = [SELECT Id FROM Transactions__c];
		Test.StartTest(); 
			ApexPages.StandardSetController sc = new ApexPages.StandardSetController(transList);
        	sc.setSelected(transList);
			TwnsqrForTransactionCtrl obj = new TwnsqrForTransactionCtrl(sc);
         	Test.setMock(HttpCalloutMock.class, new RestMock());
        	obj.getTwnsqrUpdate();
		Test.StopTest();
	}
    
    static testMethod void testMethod2() {
        List<Transactions__c> transList = new List<Transactions__c>();
		Test.StartTest(); 
			ApexPages.StandardSetController sc = new ApexPages.StandardSetController(transList);
        	sc.setSelected(transList);
			TwnsqrForTransactionCtrl obj = new TwnsqrForTransactionCtrl(sc);
		Test.StopTest();
	}
    
    static testMethod void testMethod3() {
		List<Transactions__c> transList = new List<Transactions__c>();
		Test.StartTest(); 
			ApexPages.StandardSetController sc = new ApexPages.StandardSetController(transList);
        	sc.setSelected(transList);
			TwnsqrForTransactionCtrl obj = new TwnsqrForTransactionCtrl(sc);
        	obj.hideToast();
		Test.StopTest();
	}
    private class RestMock implements HttpCalloutMock {
        List<Transactions__c> transList = [SELECT Id FROM Transactions__c];
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{\"data\":{\"MatchingDemands\":[{\"args\":{\"address\":\"1119NorthEuclidAvePittsburgh\",\"addressFormatted\":\"1119NEuclidAve,Pittsburgh,PA15206,USA\",\"idempotencyKey\":\"'+transList[0].Id+'\"},\"success\":true,\"contacts\":9159,\"buyBoxes\":1}]}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}