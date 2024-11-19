@isTest
public class TwnsqrForLeadCtrlTest {
    
    @testSetup static void createData() {
        Lead leadRec = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open',
                    Street = '2100 Woodward Ave',
                    City = 'Detroit',
                    State = 'MI',
                    PostalCode = '48201',
                    Country = 'US');
        insert leadRec;
    }

   	static testMethod void testMethod1() {
        List<Lead> leadList = [SELECT Id,FirstName,LastName,Street,City,State,PostalCode FROM Lead];
		Test.StartTest(); 
			ApexPages.StandardSetController sc = new ApexPages.StandardSetController(leadList);
        	sc.setSelected(leadList);
			TwnsqrForLeadCtrl obj = new TwnsqrForLeadCtrl(sc);
         	Test.setMock(HttpCalloutMock.class, new RestMock());
        	obj.getTwnsqrUpdate();
		Test.StopTest();
	}
    
    static testMethod void testMethod2() {
        List<Lead> leadList = new List<Lead>();
		Test.StartTest(); 
			ApexPages.StandardSetController sc = new ApexPages.StandardSetController(leadList);
        	sc.setSelected(leadList);
			TwnsqrForLeadCtrl obj = new TwnsqrForLeadCtrl(sc);
		Test.StopTest();
	}
    
    static testMethod void testMethod3() {
		List<Lead> leadList = new List<Lead>();
		Test.StartTest(); 
			ApexPages.StandardSetController sc = new ApexPages.StandardSetController(leadList);
			TwnsqrForLeadCtrl obj = new TwnsqrForLeadCtrl(sc);
        	obj.hideToast();
		Test.StopTest();
	}
    
    static testMethod void testMethod4() {
        Lead leadRec = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        insert leadRec;
        List<lead> leadList = new List<Lead>{leadRec};
		Test.StartTest(); 
			ApexPages.StandardSetController sc = new ApexPages.StandardSetController(leadList);
        	sc.setSelected(leadList);
			TwnsqrForLeadCtrl obj = new TwnsqrForLeadCtrl(sc);
         	Test.setMock(HttpCalloutMock.class, new RestMock());
        	obj.getTwnsqrUpdate();
		Test.StopTest();
	}
    private class RestMock implements HttpCalloutMock {
        List<Lead> leadList = [SELECT Id,FirstName,LastName,Street,City,State,PostalCode FROM Lead];
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{\"data\":{\"MatchingDemands\":[{\"args\":{\"address\":\"1119NorthEuclidAvePittsburgh\",\"addressFormatted\":\"1119NEuclidAve,Pittsburgh,PA15206,USA\",\"idempotencyKey\":\"'+leadList[0].Id+'\"},\"success\":true,\"contacts\":9159,\"buyBoxes\":1}]}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}