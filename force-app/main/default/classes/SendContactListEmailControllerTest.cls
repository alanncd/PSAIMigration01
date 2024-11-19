@isTest
public class SendContactListEmailControllerTest {
    
    @isTest
    public static void sendEmailTest(){
        EmailTemplate validEmailTemplate= [Select id from EmailTemplate limit 1];
        
        contact contact = new contact(LastName='test',firstName='test', email='test@gmail.com');
        insert contact;
        List<contact> contacts=new List<contact>();
        contacts.add(contact);
        
        List<OrgWideEmailAddress> orgWideEmailAddressList =[SELECT Id, Address FROM OrgWideEmailAddress limit 1];
      	String orgWideId = '';
        if(!orgWideEmailAddressList.isEmpty()){
            orgWideId = orgWideEmailAddressList[0].Id;
        }
        SendContactListEmailController sendListEmailController=new SendContactListEmailController(validEmailTemplate.id,orgWideId,contacts);
        sendListEmailController.sendEmail();    
        system.assertNotEquals(validEmailTemplate.id, null) ;
    }
    

    @isTest
    public static void sendEmailErrorMessageTest(){
        EmailTemplate validEmailTemplate= [Select id from EmailTemplate limit 1];
        
        Contact contact = new Contact(LastName='test', firstName='test',email='test@gmail.com');
        insert contact;
        List<Contact> contacts=new List<contact>();
        contacts.add(contact);
        
        
        List<OrgWideEmailAddress> orgWideEmailAddressList =[SELECT Id, Address FROM OrgWideEmailAddress limit 1];
      	String orgWideId = '';
        if(!orgWideEmailAddressList.isEmpty()){
            orgWideId = orgWideEmailAddressList[0].Id;
        }
        SendContactListEmailController sendListEmailController=new SendContactListEmailController(null,orgWideId,contacts);
        sendListEmailController.sendEmail();    
        
        sendListEmailController=new SendContactListEmailController(validEmailTemplate.id,null,contacts);
        sendListEmailController.sendEmail();    
        
        sendListEmailController=new SendContactListEmailController(validEmailTemplate.id,orgWideId,null);
        sendListEmailController.sendEmail();  
        
        List<contact> contactList = [SELECT id FROM contact where LastName='test'];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(contactList);
        sendListEmailController=new SendContactListEmailController(ssc);
        system.assertNotEquals(contactList.size(), 0) ;
    }
    
    
    @isTest
    public static void getcontactTemplatesTest(){
        SendContactListEmailController sendListEmailController=new SendContactListEmailController();
        System.assertNotEquals(null, sendListEmailController.getcontactTemplates().size());
    }
    
    @isTest
    public static void getgetOwdEmailsTest(){
        SendContactListEmailController sendListEmailController=new SendContactListEmailController();
        System.assertNotEquals(null, sendListEmailController.getOwdEmails().size());
    }

     @isTest
    public static void testGoBackAction() {
        // Crear contactos de prueba
        Contact testContact1 = new Contact(LastName = 'Test1', FirstName = 'Contact1', Email = 'test1@example.com');
        insert testContact1;
        
        // Recuperar los contactos insertados
        List<Contact> selectedContacts = [SELECT Id, Name, Email FROM Contact LIMIT 1];
        
        // Crear una instancia del StandardSetController usando los contactos seleccionados
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(selectedContacts);
        
        // Crear una instancia del controlador SendContactListEmailController
        SendContactListEmailController controller = new SendContactListEmailController(stdSetController);
        
        // Simular un escenario donde showSuccess e isError podrían ser true
        controller.showSuccess = true;
        controller.isError = true;
        
        // Llamar al método goBackAction
        controller.goBackAction();
        
        // Verificar que showSuccess e isError hayan sido establecidos en false
        System.assertEquals(false, controller.showSuccess, 'showSuccess should be set to false.');
        System.assertEquals(false, controller.isError, 'isError should be set to false.');
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
        
        SendContactListEmailController sendListEmailController=new SendContactListEmailController(validEmailTemplate.id,null,null);
        sendListEmailController.getContactTemplates();
        sendListEmailController.changeTemplateBody();
        System.assertEquals(null, sendListEmailController.templateBody);
        
    }    


 

    
}