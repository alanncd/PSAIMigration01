@isTest
public class CommonUtilsComparePhones_tst {
   @testSetup static void setup() {
		Campaign c =new Campaign();
        c.Name='TestCampaing';
        c.Lead_Sync__c=TRUE;
        c.IsActive=TRUE;
        c.smrtPhone_Number__c='12018675309';
        insert c;     
    }
    @isTest static void test_method_getCampaing(){

        List<String> xs = New List<String>();
		String x='12018675309';
		xs.add(x);
        system.debug(CommonUtilComparePhones.getCampaignbyPhoneNumber(xs));
        List<String> camp = CommonUtilComparePhones.getCampaignbyPhoneNumber(xs);
        Assert.isNotNull(camp, 'The instance is null');
    }
}