@isTest
public class TwnsqrWebHookTst {
public static String jsonString = '{'+
    '"offerType": "Cash",'+
    '"offerNotes": "Any Notes",'+
    '"offer": 123.10,'+
    '"interedBuyerName": "InterestedBuyer NAme 123456",'+
    '"externalRef": "MyexternalRef1",'+
    '"leadSource":"Test",'+
    '"contactinfo": {'+
       '"phone": "999123123",'+
        '"mobile": "999123123",'+
        '"lastName": "Crispin",'+
        '"firstName": "plutarco",'+
        '"email": "alann.cd@gmail.com",'+
        '"accountName": "buyer 1"'+
    '}'+
'}';
    
    @isTest
    public static void TestMethodDoPost() {
		Account acc = new Account();
        acc.Name='test';
        insert acc;
        Test.startTest();
       //CREATE TRANSACTION
       User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Transactions__c tx1 = createTransaction(TRUE,usr.Id);
        insert tx1;
        String jsonString2 = jsonString.replace('MyexternalRef1',tx1.Id);
        SingleRequestMock mock = new SingleRequestMock(200, 'OK', jsonString2, null);
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put('leftmainreicoredev2-dev-ed.develop.my.salesforce-sites.com/services/apexrest/TwnsqrWebhook/'+tx1.Id,mock); 
        Test.setMock(HttpCalloutMock.class, mock);
		String ordId_tst =acc.ID;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/TwnsqrWebhook/'+tx1.Id;
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(jsonString2);
        RestContext.request = req;
        RestContext.response = res;
        system.debug(TwnsqrWebHook.doPost());
        res = RestContext.response;
        Test.stopTest();
    }
    @isTest
    public static void TestMethoddoGet() {
		Account acc = new Account();
        acc.Name='test';
        insert acc;
        Test.startTest();
       //CREATE TRANSACTION
        User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Transactions__c tx1 = createTransaction(TRUE,usr.Id);
        insert tx1;
        String jsonString2 = jsonString.replace('MyexternalRef1',tx1.Id);
        SingleRequestMock mock = new SingleRequestMock(200, 'OK', jsonString2, null);
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put('leftmainreicoredev2-dev-ed.develop.my.salesforce-sites.com/services/apexrest/TwnsqrWebhook/'+tx1.Id,mock); 
        Test.setMock(HttpCalloutMock.class, mock);
		String ordId_tst =acc.ID;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/TwnsqrWebhook/'+tx1.Id;
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(jsonString2);
        RestContext.request = req;
        RestContext.response = res;
        system.debug(TwnsqrWebHook.doGet());
        res = RestContext.response;
        Test.stopTest();
    }    
    public static Transactions__c createTransaction(Boolean Sync, String usrId){
        Transactions__c tx1 = new Transactions__c();
		tx1.Dispo_Notes__c='Any dispo notes';
 		tx1.Contract_Purchase_Price__c=100;
    	tx1.Photo_Link__c='https://anyphoto.com/photo.jpg';
        tx1.Closing_Date__c= system.today();
        tx1.Disposition_Decision__c='Pending';
    	//tx1.Street_Address__c='street test';
        tx1.Dispositions_Rep__c=usrId;      
        tx1.Twnsqr_Sync__c=Sync;
        tx1.Twnsqr_clientId__c=''; 
        return tx1;
    }
}