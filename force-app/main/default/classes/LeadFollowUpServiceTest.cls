@isTest
public class LeadFollowUpServiceTest {
    
	 static testMethod void testcreateLeadFollowUp(){
        LeadFollowUpService.createLeadFollowUpRecords();
        List<Lead_Follow_Up_Sequence__c> lfus = [Select Id From Lead_Follow_Up_Sequence__c];
         system.assertNotEquals(0, lfus.size());
    }
}