@isTest
public class SendLeadEmailControllerTest {
    
    @isTest
    public static void sendEmailTest(){
        EmailTemplate validEmailTemplate= [Select id from EmailTemplate limit 1];

        Lead lead = new lead(LastName='test',Company='test', PostalCode='12345',email='test@gmail.com',Next_Step__c='test');
		insert lead;
        List<lead> leads=new List<Lead>();
        leads.add(lead);
        
        OrgWideEmailAddress orgWideEmailAddress =[SELECT Id, Address FROM OrgWideEmailAddress limit 1];
        
        SendLeadEmailController SendLeadEmailController=new SendLeadEmailController(validEmailTemplate.id,orgWideEmailAddress.id,leads);
		SendLeadEmailController.sendEmail();    
        system.assertEquals(lead.LastName, 'test');
    }
    
    @isTest
    public static void sendEmailErrorMessageTest(){
        
        EmailTemplate validEmailTemplate= [Select id from EmailTemplate limit 1];

        Lead lead = new lead(LastName='test',Company='test', PostalCode='12345',email='test@gmail.com',Next_Step__c='test');
		insert lead;
        List<lead> leads=new List<Lead>();
        leads.add(lead);
        
        OrgWideEmailAddress orgWideEmailAddress =[SELECT Id, Address FROM OrgWideEmailAddress limit 1];
        
        SendLeadEmailController SendLeadEmailController=new SendLeadEmailController(null,orgWideEmailAddress.id,leads);
		SendLeadEmailController.sendEmail();    
        
        SendLeadEmailController=new SendLeadEmailController(validEmailTemplate.id,null,leads);
		SendLeadEmailController.sendEmail();    
        
        SendLeadEmailController=new SendLeadEmailController(validEmailTemplate.id,orgWideEmailAddress.id,null);
		SendLeadEmailController.sendEmail();  
        
        List<Lead> leadList = [SELECT id FROM Lead where LastName='test'];
		ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(leadList);
        SendLeadEmailController=new SendLeadEmailController(ssc);
        system.assertNotEquals(0, leadList.size());
    }
    
    @isTest
    public static void getLeadTemplatesTest(){
        SendLeadEmailController SendLeadEmailController=new SendLeadEmailController();
        System.assertNotEquals(null, SendLeadEmailController.getLeadTemplates().size());
    }
    
    @isTest
    public static void getgetOwdEmailsTest(){
        SendLeadEmailController SendLeadEmailController=new SendLeadEmailController();
        System.assertNotEquals(null, SendLeadEmailController.getOwdEmails().size());
    }
    
    
    @isTest
    public static void changeTemplateBodyTest(){
        
         EmailTemplate validEmailTemplate;
        System.runAs (new User(Id = UserInfo.getUserId()) ){
            validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();

            insert validEmailTemplate;
        }
        
        SendLeadEmailController SendLeadEmailController=new SendLeadEmailController(validEmailTemplate.id,null,null);
        SendLeadEmailController.getLeadTemplates();
        SendLeadEmailController.changeTemplateBody(); 
        System.assertEquals(null, SendLeadEmailController.templateBody);
        
    }  

 @isTest
    static void testGoBackAction() {
        // Crear una instancia del controlador
        SendLeadEmailController controller = new SendLeadEmailController();
        
        // Simular un estado donde showSuccess e isError son true
        controller.showSuccess = true;
        controller.isError = true;
        
        // Llamar al método goBackAction()
        controller.goBackAction();
        
        // Verificar que los valores de showSuccess e isError se hayan restablecido a false
        System.assertEquals(false, controller.showSuccess, 'showSuccess debería ser false después de llamar a goBackAction');
        System.assertEquals(false, controller.isError, 'isError debería ser false después de llamar a goBackAction');
    }  
}