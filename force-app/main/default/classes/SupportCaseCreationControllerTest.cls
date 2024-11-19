@isTest public with sharing class SupportCaseCreationControllerTest {
    @isTest
    public static void testSaveCase() { 
        Test.setMock(HttpCalloutMock.class, new CaseCalloutMock());
        String jsonInput = '{\"attachmentLink\": \"https://leftmain-dev-ed.lightning.force.com/lightning/n/Left_Main_Support\",\"description\": \"Testing \",\"email\": \"testing@leftmainrei.com\",\"name\": \"Testing User\",\"phone\": \"9785452556\",\"subject\": \"Testing Purpose\",\"ticketType\": \"Mapping\" }';
        SupportCaseCreationController.saveCase(jsonInput);
		
        SupportCaseCreationController.CaseCreationData caseCreationdata = (SupportCaseCreationController.CaseCreationData) JSON.deserialize(jsonInput, SupportCaseCreationController.CaseCreationData.Class);
		System.assertNotEquals(null, caseCreationdata.email,'');
		System.assertNotEquals(null, caseCreationdata.description,'');
        System.assertNotEquals(null, caseCreationdata.subject,''); 
    }
    @isTest
    public static void testViewCase(){
        Test.setMock(HttpCalloutMock.class, new CaseCalloutMock());
        SupportCaseCreationController.viewCase('');
	String jsonString='['+
	'   {'+
	'      "subject":"My Subject",'+
	'      "status":"New",'+
	'    "description": "description 1",'+
	'    "caseNumber": "00009104"'+
	'   }'+
	']';        
        List<SupportCaseCreationController.CaseWrapper1> caseWrapper = (List<SupportCaseCreationController.CaseWrapper1>) System.JSON.deserialize(jsonString, List<SupportCaseCreationController.CaseWrapper1>.class);
		System.assertNotEquals(null, caseWrapper[0].subject,'');
		System.assertNotEquals(null, caseWrapper[0].status,'');
        System.assertNotEquals(null, caseWrapper[0].description,'');         
        System.assertNotEquals(null, caseWrapper[0].caseNumber,'');         
    }
    @isTest
    public static void testViewAccManager(){
        Test.setMock(HttpCalloutMock.class, new CaseCalloutMock());
        SupportCaseCreationController.searchAccManager('');
	String jsonString=' {'				+
	'      "title":"My title",'			+
	'      "photo":"photo123",'			+
	'    "phone": "99988877711",'		+
	'    "name": "accountmanager",' 	+
	'    "mobile": "99988877711",'		+
	'    "email": "test@leftmainrei.com"'+        
	'   }';
		SingleRequestMock mock = new SingleRequestMock(200, 'OK', jsonString, null);
        SupportCaseCreationController.AccManagerWrapper accMngrWrapper = (SupportCaseCreationController.AccManagerWrapper) System.JSON.deserialize(jsonString, SupportCaseCreationController.AccManagerWrapper.class);
		System.assertNotEquals(null, accMngrWrapper.name,'');
		System.assertNotEquals(null, accMngrWrapper.email,'');
        System.assertNotEquals(null, accMngrWrapper.phone,'');         
        System.assertNotEquals(null, accMngrWrapper.mobile,'');         
    }    
}