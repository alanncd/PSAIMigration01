@isTest
public class deleteErrorHandler_tst {

    private static testMethod void testAutoRun(){
        
           PageReference pageRef = Page.DeleteErrorHandlerRc;
  			ErrorHandlerLmr__c acc = new ErrorHandlerLmr__c(ProcessName__c='test');
  			insert acc;
        
          Test.setCurrentPage(pageRef);
           ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        
           deleteErrorHandler controller = new deleteErrorHandler(sc);
        	controller.deleteRecord();

            Assert.isNotNull(acc, 'The instance is null');

    }
        private static testMethod void testAutoRun2(){
        
           PageReference pageRef = Page.DeleteErrorHandlerRc;
  			ErrorHandlerLmr__c acc = new ErrorHandlerLmr__c(ProcessName__c='test');
  			insert acc;
        
          Test.setCurrentPage(pageRef);
           ApexPages.StandardController sc = new ApexPages.standardController(acc);
        
           deleteErrorHandler controller = new deleteErrorHandler(sc);
        	controller.deleteErrorSms();

            Assert.isNotNull(acc, 'The instance is null');

    }
    
}