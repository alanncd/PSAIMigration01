@isTest
public class testInstallPostScriptCadences {

    @TestSetup
    static void makeData(){
          ContentVersion contentVersion = new ContentVersion(
          Title          = 'Post-deploy steps cadences',
          PathOnClient   = 'Pic.jpg',
          VersionData    = Blob.valueOf('Test Content'),
          IsMajorVersion = true);
        insert contentVersion; 

    // Crear datos de prueba para Opportunity
        Account testAccount = new Account(Name = 'Test Account', Mobile__c = '1234567890');
        insert testAccount;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert opp;
    }
    @isTest
    static void testInstallScript() {
        test.startTest();
        PostInstallScript postinstall = new PostInstallScript();
          Test.testInstall(postinstall, null);
          Test.testInstall(postinstall, new Version(1,0), true);
          List<LMR_TemplateSms__c> a = [Select id from LMR_TemplateSms__c];
        System.assertNotEquals(0, a.size());
        	test.stopTest();	
        
        }
}