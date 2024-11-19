@isTest
public class TwnsqrUpdateForLeadCntrlTest {

    static testMethod void testMethod1() 
	{
		Lead leadRec = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open',
                    Street = '2100 Woodward Ave',
                    City = 'Detroit',
                    State = 'MI',
                    PostalCode = '48201',
                    Country = 'US');
        insert leadRec;
		Test.StartTest(); 
			ApexPages.StandardController sc = new ApexPages.StandardController(leadRec);
			TwnsqrUpdateForLeadCntrl obj = new TwnsqrUpdateForLeadCntrl(sc);
		Test.StopTest();
	}
}