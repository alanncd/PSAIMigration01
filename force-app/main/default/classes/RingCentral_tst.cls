@isTest
public class RingCentral_tst {
@TestSetup
static void createTestData() {
    insert new RingCentralTaskSetting__c(Activate_Trigger__c=TRUE);
    Lead l = new Lead();
    l.LastName='testLead';
    l.MobilePhone='+51999888777';
    l.Phone='+51999888777';
    insert l;
        
	List<RingCentral_Data_Store2__c> rlist = new List<RingCentral_Data_Store2__c>();
	RingCentral_Data_Store2__c r1 = new RingCentral_Data_Store2__c();
	RingCentral_Data_Store2__c r2 = new RingCentral_Data_Store2__c();
	r1.From_Number__c='+51999888777';
    r1.To_Number__c='+51999888777';
    r1.Raw_Time_Filter__c='fil1';
    r1.Caller_Phone_Number__c='+51999888777';
    r1.To_Phone_Number__c='+51999888777';
    r1.Call_Result__c='Missed';
    //---
	r2.From_Number__c='+51987950594';
    r2.To_Number__c='+51987950594';
    r2.Raw_Time_Filter__c='fil2';
    r2.Caller_Phone_Number__c='+51987950594';
    r2.To_Phone_Number__c='+51987950594';  
    r2.Call_Result__c='Missed';
	rlist.add(r1);
	rlist.add(r2);
	insert rlist;
}
@isTest
    static void clearMessagesTest() {
      	List<RingCentral_Data_Store2__c> r = [Select Id From RingCentral_Data_Store2__c];
        system.assertNotEquals(0, r.size());
    }    
}