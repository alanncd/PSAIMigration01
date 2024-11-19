@isTest
public class CustomWelcomeMatControllerTst {
    @isTest
    public static void testShowModal() {
        String t='tst';
        system.debug(CustomWelcomeMatController.getWelcomeMatInfo(t));
        system.debug(CustomWelcomeMatController.setModalOffByUser(t));

        System.assert(CustomWelcomeMatController.getWelcomeMatInfo(t) != NULL);

    }
    @isTest
    public static void testViewCase(){
        Test.setMock(HttpCalloutMock.class, new CaseCalloutMock());
        CustomWelcomeMatController.setFeedbackToLMR('TRUE');


        System.assert(CustomWelcomeMatController.setFeedbackToLMR('TRUE') == NULL);
    }    
}