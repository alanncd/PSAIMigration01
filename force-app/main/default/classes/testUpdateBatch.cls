@isTest 
public class testUpdateBatch {
    static testMethod void testMethod1() 
    {
        List<Lead> lstLead = new List<Lead>();
        for(Integer i=0 ;i <200;i++)
        {
            Lead led = new Lead();
            led.FirstName ='FirstName';
            led.LastName ='LastName'+i;
            led.Company ='demo'+i;
            led.street = 'test';
            led.City = 'test';
            lstLead.add(led);
        }
        
        insert lstLead;
        
        Test.startTest();

        batchUpdate obj = new batchUpdate();
            DataBase.executeBatch(obj); 
            system.assertNotEquals(0, lstLead.size());
        Test.stopTest();
    }
}