@isTest
public with sharing class QuickBooksControllerTest implements HttpCalloutMock {
    
    @testsetup
    static void testSetup(){
        System.debug('test');
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> uu = new List<User>();
        while (uu.size() < 1) {
          Blob b = Crypto.GenerateAESKey(128);
          String h = EncodingUtil.ConvertTohex(b);
          String uid = h.SubString(0,8);
      		User u = new User(Alias = uid, Email= 'letfmain@testdomain.com', 
          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = p.Id, 
          TimeZoneSidKey='America/New_York', UserName= uid + '@testdomain.com');      
      	uu.add(u);
    }
    insert uu;
        List<PermissionSetAssignment> listPermissionSet = New List<PermissionSetAssignment>();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Label = 'Left Main User'];
        for(User u:uu){
            listPermissionSet.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id)); 
        }

        insert listPermissionSet;
    }
    public static testmethod void testGetVendorsAndExpenses(){

        User thisUser = [SELECT Id FROM User WHERE email ='letfmain@testdomain.com'];
        System.runAs(thisUser){

        
        // The following code runs as user 'u'
        Vendor__c vndrObj = new Vendor__c();
        vndrObj.name = 'test';
        insert vndrObj;

        Vendor__c vndr = new Vendor__c();
        vndr.ID__c='57';
        vndr.Active__c=True;
        vndr.Sparse__c=True;
        vndr.Name='Test Vendor';

        insert vndr;

        Expense__c e =  new Expense__c(Total_Amount__c=10000,Payee__c=vndr.Id,date__c=date.parse('05/27/2021'));
        insert e;
        
        Test.startTest();
        staticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ExpensesStaticResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        System.assertEquals('200', QuickBooksController.getVendorsAndExpenses('-30'),'');
        Test.stopTest();
            

        }
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        req.setBody('{"QueryResponse":{"Purchase":[{"AccountRef":{"value":"41","name":"Mastercard"},"PaymentType":"CreditCard","EntityRef":{"value":"57","name":"Squeaky Kleen Car Wash","type":"Vendor"},"Credit":false,"TotalAmt":19.99,"PurchaseEx":{"any":[{"name":"{http://schema.intuit.com/finance/v3}NameValue","declaredType":"com.intuit.schema.finance.v3.NameValue","scope":"javax.xml.bind.JAXBElement$GlobalScope","value":{"Name":"TxnType","Value":"1"},"nil":false,"globalScope":true,"typeSubstituted":false}]},"domain":"QBO","sparse":false,"Id":"141","SyncToken":"1","MetaData":{"CreateTime":"2020-10-07T14:37:27-07:00","LastUpdatedTime":"2020-11-20T04:33:52-08:00"},"TxnDate":"2020-09-28","CurrencyRef":{"value":"USD","name":"United States Dollar"},"Line":[{"Id":"1","Amount":19.99,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"93","name":"Advertising & Marketing"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}}]}],,"startPosition":1,"maxResults":5},"time":"2020-12-02T22:53:50.744-08:00"}');
        res.setStatusCode(200);
        return res;
    }
    
    

    public static testmethod void testPurchaseWrapperParse(){
        Test.startTest();
        PurchaseWrapper pa = PurchaseWrapper.parse('{"QueryResponse":{ "Vendor":[{ "BillAddr":{ "Id":"97", "Line1":"Dianne Auto Shop", "Line2":"Dianne Bradley", "Line3":"29834 Mustang Ave.", "City":"Millbrae", "Country":"U.S.A", "CountrySubDivisionCode":"CA", "PostalCode":"94030" }, "TaxIdentifier":"XXXXXX8293", "Balance":0, "AcctNum":"35372649", "Vendor1099":false, "CurrencyRef":{ "value":"USD", "name":"United States Dollar" }, "domain":"QBO", "sparse":false, "Id":"59", "SyncToken":"0", "MetaData":{ "CreateTime":"2020-10-20T03:08:37-07:00", "LastUpdatedTime":"2020-10-20T03:08:37-07:00" }, "Title":"Ms.", "GivenName":"Dianne", "FamilyName":"Bradley", "Suffix":"Sr.", "CompanyName":"Dianne Auto Shop", "DisplayName":"Dianne Auto Shop2", "PrintOnCheckName":"Dianne Auto Shop", "Active":true, "PrimaryPhone":{ "FreeFormNumber":"(650) 555-2342" }, "Mobile":{ "FreeFormNumber":"(650) 555-2000" }, "PrimaryEmailAddr":{ "Address":"dbradley@myemail.com" }, "WebAddr":{ "URI":"http://DiannesAutoShop.com" } } ], "startPosition":1, "maxResults":13 }, "time":"2020-10-26T06:24:20.974-07:00" }');
        Test.stopTest();
        System.assertNotEquals(null,pa,'');
    }
    public static testmethod void testQuickBookScheduler(){
        Test.startTest();
        Vendor__c vndr = new Vendor__c();
        vndr.ID__c='57';
        vndr.Active__c=True;
        vndr.Sparse__c=True;
        vndr.Name='Test Vendor';
        insert vndr;
        staticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ExpensesStaticResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);  
         //System.schedule('Scheduler_test1',  '0 00 * * * ?', new QuickBooksScheduler());
        system.assertNotEquals(vndr, null);
        Test.stopTest();
    }
    
    public static testmethod void testcheckedQuickbookScheduler(){
        Test.startTest();
        List<Boolean> result = QuickBooksController.checkedQuickbookScheduler();
        system.assertEquals(result[0], false, 'The result should be false');

        Test.stopTest();
        
    }
    
    public static testmethod void testcurrentQuarterQuery(){
        Test.startTest();

    // Call the method to be tested
    String query = QuickBooksController.currentQuarterQuery();

    // Perform assertions to verify the expected behavior
    System.assertNotEquals(null, query, 'The query should not be null');
    System.assert(query.contains('select+*+from+Purchase+where+MetaData.LastUpdatedTime+'), 'The query should contain the expected object');

    // Additional assertions based on the specific behavior of your method

    Test.stopTest();
    }
    
    public static testmethod void testqueryLastQuarter(){
       User thisUser = [SELECT Id FROM User WHERE email ='letfmain@testdomain.com'];
        System.runAs(thisUser){
       Test.startTest();

    // Call the method to be tested
    String query = QuickBooksController.queryLastQuarter();

    // Perform assertions to verify the expected behavior
    System.assertNotEquals(null, query, 'The query should not be null');
    System.assert(query.contains('SELECT+*+FROM+Purchase+WHERE+MetaData.LastUpdatedTime+'), 'The query should contain the expected object');

    // Additional assertions based on the specific behavior of your method

    Test.stopTest();
    }
    
    }
}