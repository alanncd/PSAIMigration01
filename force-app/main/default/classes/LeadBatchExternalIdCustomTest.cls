@isTest 
public class LeadBatchExternalIdCustomTest {
    static testMethod void testMethod1() 
    {
        List<Lead> lstLead = new List<Lead>();
        for(Integer i=0 ;i <200;i++)
        {
            Lead led = new Lead();
            led.FirstName ='FirstName';
            led.LastName ='LastName'+i;
            led.Company ='demo'+i;
            led.Street ='street'+i;
            lstLead.add(led);
        }
        
        insert lstLead;
        
        Test.startTest();

        LeadBatchExternalIdCustom obj = new LeadBatchExternalIdCustom();
            DataBase.executeBatch(obj); 
        	system.assertNotEquals(0, lstLead.size());
        Test.stopTest();
    }
}