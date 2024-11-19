@isTest
public class CaseCreationControllerTest {
    
    @isTest
    public static void testSaveCase() { 
        Test.setMock(HttpCalloutMock.class, new CaseCalloutMock());
        CaseCreationController caseCreationController=new CaseCreationController();
        caseCreationController.setEmail(caseCreationController.getEmail()!=null ? caseCreationController.getEmail(): 'test@gmail.com');
        caseCreationController.setDescription(caseCreationController.getDescription()!=null ? caseCreationController.getDescription(): 'Test Description');
        caseCreationController.setSubject(caseCreationController.getSubject()!=null ? caseCreationController.getSubject() : 'Test subject');
        caseCreationController.setUserName('test');
        caseCreationController.setSourceCompanyName('Test company name');
        caseCreationController.setphone('1234567890');
        caseCreationController.setname('test');
        caseCreationController.setattachmentLink('Test org id');
        caseCreationController.setticketType('DocuSign'); 
        caseCreationController.saveCase();
		
		System.assertNotEquals(null, caseCreationController.getEmail(),'');
		System.assertNotEquals(null, caseCreationController.getDescription(),'');
        System.assertNotEquals(null, caseCreationController.getSubject(),''); 
    }
    
}