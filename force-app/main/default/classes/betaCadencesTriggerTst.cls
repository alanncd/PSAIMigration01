@isTest
public class betaCadencesTriggerTst {

    @TestSetup
    static void makeData(){
        LeadFollowUpService.createLeadFollowUpRecords();
        

        
        List<PermissionSet> ps = [SELECT Id,Name FROM PermissionSet Where name='Left_Main_User'];
    
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        thisUser.Phone = '+93882323';
        update thisUser;

        
        System.runAs(thisUser){
        try{
        PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = thisUser.Id,PermissionSetId = ps[0].Id);
            upsert psa1; }catch(exception e){
                
            }
            
		Map<Schema.SObjectField, Object> mapFieldsU = new Map<Schema.SObjectField, Object>();
        mapFieldsU.put(Schema.User.Username,'cadences@leftmainrei.com');
        mapFieldsU.put(Schema.User.Phone,'+9324942394');
		User us = DataGeneratorLMR_tst.getUser(true, mapFieldsU);

        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = us.Id,PermissionSetId = ps[0].Id);
        upsert psa;     
        }

        
		//SmrtPhone_Config__mdt;
       CadencesTrigger__c cadenceTriggers = CadencesTrigger__c.getOrgDefaults();
        cadenceTriggers.Activate_trigger_cadences__c = true;
        cadenceTriggers.TaskAutomation__c = true;
        cadenceTriggers.EmailAutomation__c = true;
        cadenceTriggers.activateSmartphone__c = true;

        upsert cadenceTriggers;
        
        //Create SMS Template
        List<LMR_TemplateSms__c> smsTemplateList = new List<LMR_TemplateSms__c>();
        smsTemplateList.add(new LMR_TemplateSms__c(Name='Buyer',Body__c='Test {!Lead.OwnerId}',Object__c='Lead',Folder__c='New Lead - Drip',Status__c='Active',Schedule__c=1,TypeOfSchedule__c='Now'));
       	smsTemplateList.add(new LMR_TemplateSms__c(Name='Buyer 2',Body__c='Test {!Lead.OwnerId}',Object__c='Lead',Folder__c='New Lead - Drip',Status__c='Active',Schedule__c=1,TypeOfSchedule__c='Minutes'));
       	smsTemplateList.add(new LMR_TemplateSms__c(Name='Buyer 3',Body__c='Test {!Lead.OwnerId}',Object__c='Lead',Folder__c='New Lead - Drip',Status__c='Active',Schedule__c=1,TypeOfSchedule__c='Days'));

        insert smsTemplateList;


        //Create Task Template

        List<Task_Follow_Up_Sequence__c> taskFolderTemplate = new List<Task_Follow_Up_Sequence__c>();
        taskFolderTemplate.add(new Task_Follow_Up_Sequence__c(Name='Uncontacted Lead',Task_Subject__c='Test',Task_Cadence_Folder__c='Uncontacted Lead',Frequency__c='Now',Number__c=1));
        taskFolderTemplate.add(new Task_Follow_Up_Sequence__c(Name='Uncontacted Lead2',Task_Subject__c='Test',Task_Cadence_Folder__c='Uncontacted Lead',Frequency__c='Hours',Number__c=1));
        taskFolderTemplate.add(new Task_Follow_Up_Sequence__c(Name='Uncontacted Lead3',Task_Subject__c='Test',Task_Cadence_Folder__c='Uncontacted Lead',Frequency__c='Days',Number__c=1));

        insert taskFolderTemplate;
		
        //create email template        
        List<EmailTemplate> emailTemplateList = [SELECT Id, Name,DeveloperName, TemplateStyle, IsActive, Description, 
                                                 Subject, Body,HtmlValue FROM
                                                 EmailTemplate WHERE Folder.Name ='Left Main Lead Follow Up'
                                                 AND IsActive=true AND (NOT Name  LIKE '%same%') ORDER BY Name];
        Map<String,String> templateDeveloperNameWithId = new Map<String,String>();
        Map<String,String> templateDeveloperNameWithName = new Map<String,String>();
        for(EmailTemplate emailTemObj : emailTemplateList){
            templateDeveloperNameWithId.put(emailTemObj.DeveloperName,emailTemObj.Id);
            templateDeveloperNameWithName.put(emailTemObj.DeveloperName,emailTemObj.Name);
        }
        List<Lead_Follow_Up_Sequence__c> upsertList = new List<Lead_Follow_Up_Sequence__c>();
        if(templateDeveloperNameWithId != null && templateDeveloperNameWithId.Size() > 0){
            if(templateDeveloperNameWithId.containsKey('X10_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 10;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X10_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X10_Day_Lead_Longterm_Follow_Up');
                followUpObj.Folder__c='Folder 1';
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X30_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 0;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X30_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X30_Day_Lead_Longterm_Follow_Up');
                followUpObj.Folder__c='Folder 1';
                upsertList.add(followUpObj);
            }


            if(!upsertList.isEmpty()){
                insert upsertList;
            }
            
            
            
        }

       SObject lead = mock('Lead');
        insert lead;
               
        ScheduleCadence__c scheduledCadence = New ScheduleCadence__c();
        scheduledCadence.Name='test';
       // scheduledCadence.Lead__c = lead.id;
        scheduledCadence.IdTemplate__c = smsTemplateList[0].Id;
        scheduledCadence.TargetId__c = lead.id;
        insert scheduledCadence;
                  
         
        
        ScheduleCadenceTask__c newScheduledTask = new ScheduleCadenceTask__c();
        newScheduledTask.Name = 'test';
        newScheduledTask.IdTemplate__c = taskFolderTemplate[0].Id;
        newScheduledTask.Related_Record_id__c = lead.id;
        
        insert newScheduledTask;
        
        Lead newLead = [Select Id from lead where Id =: lead.Id];
        newLead.phone='92399234';
        newLead.mobilePhone='9234423';
        update newLead;
        
       //Contact - PA 
        SObject Contact = mock('Contact');
        insert Contact;
        Contact newContact = [Select Id,mobilePhone from Contact LIMIT 1];
		newContact.mobilePhone='998834343';
        upsert newContact;
        
        //Opportunity
        SObject opp = mock('Opportunity');
		insert opp;
        Opportunity oppnew = [Select Id,MobilePhone__c from Opportunity LIMIT 1];
        oppnew.MobilePhone__c='92399234';

        update oppnew;
        
        //insert campaign 
        SObject campaignL = mock('Campaign');
		insert campaignL;
         
      ScheduleCadenceTask__c newScheduledTask2 = new ScheduleCadenceTask__c();
        newScheduledTask2.Name = 'test';
        newScheduledTask2.IdTemplate__c = taskFolderTemplate[0].Id;
        newScheduledTask2.Related_Record_id__c = opp.id;
        
        upsert newScheduledTask2;
        
        ScheduleCadenceTask__c newScheduledTask3 = new ScheduleCadenceTask__c();
        newScheduledTask3.Name = 'test';
        newScheduledTask3.IdTemplate__c = taskFolderTemplate[0].Id;
        newScheduledTask3.Related_Record_id__c = Contact.id;
        
        upsert newScheduledTask3;   
        //campaign
        //List<Campaign> campaignCreated = new List<Campaign>();
        //campaignCreated.add(new Campaign(Name='Test Campaign',smrtPhone_Number__c='+51954794271'));
        //insert campaignCreated;

        //campaign Member
        List<CampaignMember> testCampMemb1 = new List<CampaignMember>();

	    testCampMemb1.add(new CampaignMember(LeadId =lead.Id,CampaignId=campaignL.Id, Status = 'Sent'));
 
        insert testCampMemb1;

        insertTemplate();
        

    }
    
        @IsTest
    static void createCadence(){

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',Object__c = 'Lead',SmsFolder__c='New Lead - Drip',TaskEmailTemplate__c='Folder1',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
          //Lmr_SmrtPhone_cls.smartPhoneCallout(lead1.Id,smsTemplateList[0].Id);
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }

    @isTest
    public static void testDeprecatedClass(){
       String valueGenerated = Lmr_SendEmailUtils_cls.generateCronExpression(3);
       system.assertNotEquals(valueGenerated, '');  
    }

        static SObject mock(String sobjectName) {
        SObjectType t = Schema.getGlobalDescribe().get(sobjectName);

        SObject o = t.newSobject();

        Map<String, Schema.SObjectField> m = t.getDescribe().fields.getMap();

        for (String fieldName : m.keySet()) {
            DescribeFieldResult f = m.get(fieldName).getDescribe();
            
            if ((!f.isNillable() && f.isCreateable() && !f.isDefaultedOnCreate()) || (fieldName == 'Name' && (sobjectName =='Account' || sobjectName =='Campaign')) )  {
                if (f.getType() == DisplayType.Boolean) {
                    o.put(f.getName(), false);
                }
                else if (f.getType() == DisplayType.Currency) {
                    o.put(f.getName(), 0);
                }
                else if (f.getType() == DisplayType.Date) {
                    o.put(f.getName(), Date.today());
                }
                else if (f.getType() == DisplayType.DateTime) {
                    o.put(f.getName(), System.now());
                }
                else if (f.getType() == DisplayType.Double) {
                    o.put(f.getName(), 0.0);
                }
                else if (f.getType() == DisplayType.Email) {
                    o.put(f.getName(), 'foo@foo.com');
                }
                else if (f.getType() == DisplayType.Integer) {
                    o.put(f.getName(), 0);
                }
                else if (f.getType() == DisplayType.Percent) {
                    o.put(f.getName(), 0);
                }
                else if (f.getType() == DisplayType.Phone) {
                    o.put(f.getName(), '555-555-1212');
                }
                else if (f.getType() == DisplayType.String) {
                    o.put(f.getName(), 'TEST');
                }
                else if (f.getType() == DisplayType.TextArea) {
                    o.put(f.getName(), 'TEST');
                }
                else if (f.getType() == DisplayType.Time) {
                    o.put(f.getName(), System.now().time());
                }
                else if (f.getType() == DisplayType.URL) {
                    o.put(f.getName(), 'http://foo.com');
                }
                else if (f.getType() == DisplayType.PickList) {
                    o.put(f.getName(), f.getPicklistValues()[0].getValue());
                }
            }
        }
        return o;
    }
    
        @future
    public static void insertTemplate(){
        List<EmailTemplate> listEmail = [SELECT Id, Name, FolderId FROM EmailTemplate LIMIT 1];
        EmailTemplate e = new EmailTemplate (developerName = 'test', FolderId = listEmail[0].FolderId, TemplateType= 'Text', Name = 'test'); // plus any other fields that you want to set
		insert e;
        
        
         String userId = UserInfo.getUserId();
        EmailTemplate e2 = new EmailTemplate (developerName = 'test2', FolderId = userId, TemplateType= 'Text', Name = 'test'); // plus any other fields that you want to set
		insert e2;
                       
    }
    
}