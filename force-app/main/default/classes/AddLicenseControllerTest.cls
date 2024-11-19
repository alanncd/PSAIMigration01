@isTest
public class AddLicenseControllerTest {
    @isTest
    static void addLicence () {
        AddLicenseController ctlr = new AddLicenseController();
       // System.assertEquals(UserInfo.getOrganizationId(), ctlr.orgId);
       // Test promotion Jun 21
        System.assert(ctlr.leftMainUrl != null);
    }

}