@isTest
public class TwnsqrUpdateForTransactionCntrlTest {

    static testMethod void testMethod1() 
	{
		Lead leadRec = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open',
                    Street = '2100 Woodward Ave',
                    City = 'Detroit',
                    State = 'MI',
                    PostalCode = '48201',
                    Country = 'US');
        insert leadRec;
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

		Test.StartTest(); 
			ApexPages.StandardController sc = new ApexPages.StandardController(transRec);
			TwnsqrUpdateForTransactionCntrl obj = new TwnsqrUpdateForTransactionCntrl(sc);
		Test.StopTest();
	}
}