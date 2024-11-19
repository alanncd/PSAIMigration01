@isTest
public class ErrorHandler_tst {
    @istest
    static void testInvokeError(){

        try{
            ErrorHandler_cls.insertErrorHandler('test','test');
            integer i = 10/0;
        }catch(System.Exception e){
            ErrorHandler_cls.returnHandleException(e,'Testing');
            ErrorHandler_cls.handleException(e,'Testing');
            ErrorHandlerLmr__c eh = [Select Id From ErrorHandlerLmr__c limit 1];
            system.assertNotEquals(eh, null);
        }
    }
}