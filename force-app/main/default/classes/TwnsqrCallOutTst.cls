@isTest
public class TwnsqrCallOutTst {
    @testSetup
    static void setup() {
        Twnsqr_Config__c tcon = new Twnsqr_Config__c();
        tcon.Sync__c=FALSE;
        tcon.org_name__c='any org name tst';
        tcon.baseURL__c='https://api-onwz6wrxya-uc.a.run.app';
        tcon.token__c='2d026926-868d-4af8-9e46-f4ffc8545fe1';
        insert tcon;
        User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Transactions__c tx1 = createTransaction(TRUE,usr.Id);
		insert tx1;
    }
    @isTest
    public static void testTwnsqrGetConfig(){
        Test.setMock(HttpCalloutMock.class, new TwnsqrCalloutMock());
        List<Twnsqr_Config__c> x =[Select Id from Twnsqr_Config__c];
        x[0].Sync__c=TRUE;
        update x;
        TwnsqrCallOut.TwnsqrGetConfig();
		String jsonString='"anyId"';           
    }    
	@isTest
    public static void testTwnsqrPostConfig(){
        Test.setMock(HttpCalloutMock.class, new TwnsqrCalloutMock());
        TwnsqrCallOut.TwnsqrPostConfig();
		//String jsonString='"anyId"'; 
    }    
	@isTest
    public static void testTwnsqrPostDeal(){
        Twnsqr_Config__c tco = [Select Id, Sync__c FROM Twnsqr_Config__c];
        tco.Sync__c=TRUE;
        update tco;
        
        Test.setMock(HttpCalloutMock.class, new TwnsqrCalloutMock());
        Transactions__c t = createTransaction(FALSE,UserInfo.getUserId());
        insert t;
        List<Transactions__c> trxs1 =[Select Id,Twnsqr_clientId__c,Twnsqr_Sync__c,Photo_Link__c,Dispo_Notes__c,Contract_Purchase_Price__c,Street_Address__c,Dispositions_Rep__c,Disposition_Decision__c,Closing_Date__c FROM Transactions__c];
		trxs1[0].Twnsqr_clientId__c=NULL;
        update trxs1;
        //TransactionTriggerHelper.twnsqrAction(trxs1, null);
		//String jsonString='"anyId"';           
    }    
	@isTest
    public static void testTwnsqrPutDeal(){
        Twnsqr_Config__c tco = [Select Id, Sync__c FROM Twnsqr_Config__c];
        tco.Sync__c=TRUE;
        update tco;
        
        Test.setMock(HttpCalloutMock.class, new TwnsqrCalloutMock());
        List<Transactions__c> trxs1 =[Select Id,Twnsqr_clientId__c,Twnsqr_Sync__c,Photo_Link__c,Dispo_Notes__c,Contract_Purchase_Price__c,Street_Address__c,Dispositions_Rep__c,Disposition_Decision__c,Closing_Date__c FROM Transactions__c];
		trxs1[0].Twnsqr_Sync__c=FALSE;
        update trxs1;
    }    
    @isTest
    public static void testErrorApi(){
        String json='{'+
					' "status": false,'+
					'}';
        Test.startTest();
        SingleRequestMock mock = new SingleRequestMock(401, 'Error', json, null);
      	Test.setMock(HttpCalloutMock.class, mock);
        TwnsqrCallOut.TwnsqrGetConfig();
        Test.stopTest();
    }
    public static Transactions__c createTransaction(Boolean Sync, String usrId){
        Transactions__c tx1 = new Transactions__c();
		tx1.Dispo_Notes__c='tes value';
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