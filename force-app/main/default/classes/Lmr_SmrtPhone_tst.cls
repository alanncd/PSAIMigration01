@isTest
public class Lmr_SmrtPhone_tst {
    static User setupTestUser(String profileName){
        String uniqueness = DateTime.now()+':'+Math.random();
        try{ 
            throw new NullPointerException();
        }catch(Exception e){
            uniqueness += e.getStackTraceString(); //includes the top level test method name without having to pass it
        }
        Profile p = [SELECT id, Name FROM Profile WHERE Name = :profileName];
        User userResult = new User(
            username=UserInfo.getUserId()+'.'+uniqueness.HashCode()+'@'+UserInfo.getOrganizationId()+'.sfdcOrg',
            alias = 'testExec',
            email='apextests@example.com',
            emailencodingkey='UTF-8',
            lastname='Testing',
            languagelocalekey='en_US',
            localesidkey='en_US',
            profileid = p.Id,
            Phone = '+93882323',
            timezonesidkey='America/Los_Angeles'
        );
        insert userResult;
        return userResult;
        
    }
   
    @TestSetup
    static void makeData(){
        LeadFollowUpService.createLeadFollowUpRecords();

        User testUser = setupTestUser('System Administrator');
        

        
        List<PermissionSet> ps = [SELECT Id,Name FROM PermissionSet Where name='Left_Main_User'];       
        System.runAs(testUser){
        try{
        PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = testUser.Id,PermissionSetId = ps[0].Id);
            upsert psa1; }catch(exception e){
                
            }
            
		Map<Schema.SObjectField, Object> mapFieldsU = new Map<Schema.SObjectField, Object>();
        mapFieldsU.put(Schema.User.Username,'cadences@leftmainrei.com');
        mapFieldsU.put(Schema.User.Phone,'+9324942394');
		User us = DataGeneratorLMR_tst.getUser(true, mapFieldsU);

        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = us.Id,PermissionSetId = ps[0].Id);
        upsert psa;     
        }

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
       	smsTemplateList.add(new LMR_TemplateSms__c(Name='Buyer 3',Body__c='Test {!Opportunity.OwnerId}',Object__c='Opportunity',Folder__c='New Opp - Drip',Status__c='Active',Schedule__c=1,TypeOfSchedule__c='Now'));
       	smsTemplateList.add(new LMR_TemplateSms__c(Name='Buyer 3',Body__c='Test {!Contact.OwnerId}',Object__c='Opportunity',Folder__c='New Con - Drip',Status__c='Active',Schedule__c=1,TypeOfSchedule__c='Now'));

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
        
        Boolean trxObj1 = doesObjectExist('Transactions__c');
        Boolean trxObj2 = doesObjectExist('Left_Main__Transactions__c');
        String varTransaction='Left_Main__Transactions__c';
        if(trxObj1){varTransaction='Transactions__c';}
		SObject transactionRec = mock(varTransaction);
		insert transactionRec;
        
        Boolean iBuyObj1 = doesObjectExist('Interested_Buyers__c');
        Boolean iBuyObj2 = doesObjectExist('Left_Main__Interested_Buyers__c');
        String varInterestedBuyer='Left_Main__Interested_Buyers__c';
        if(iBuyObj1){varInterestedBuyer='Interested_Buyers__c';}
        
        Interested_Buyers__c interestedBuyerRec =(Interested_Buyers__c) mock(varInterestedBuyer);
        interestedBuyerRec.Transactions__c = transactionRec.Id;
		insert interestedBuyerRec;
        
        
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
        @IsTest
    static void createCadenceSmrtphoneSuccessNoPhone(){

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        lead1.mobilePhone = null;
        lead1.Phone = null;
        update lead1;
        
       // LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isRingCentral = false;
        Lmr_SmrtPhone_cls.isDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Lead',SmsFolder__c='New Lead - Drip',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    @IsTest
    static void createCadenceSmrtphoneSuccess(){

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isRingCentral = false;
        Lmr_SmrtPhone_cls.isDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Lead',SmsFolder__c='New Lead - Drip',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void createCadenceSmrtphoneSuccessInterestedBuyer(){

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Interested_Buyers__c interestedBuyerRecord = [Select Id from Interested_Buyers__c LIMIT 1];
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isRingCentral = false;
        Lmr_SmrtPhone_cls.isDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Lead',SmsFolder__c='New Lead - Drip',TargetId__c = interestedBuyerRecord.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
   
    @IsTest
    static void createCadenceSmrtphoneSuccessTransactions(){

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Transactions__c transactionRecord = [Select Id from Transactions__c LIMIT 1];
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isRingCentral = false;
        Lmr_SmrtPhone_cls.isDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Lead',SmsFolder__c='New Lead - Drip',TargetId__c = transactionRecord.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void createCadenceSmrtphoneSuccessOpp(){

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Opportunity opp1 = [Select Id from Opportunity LIMIT 1];
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isRingCentral = false;
        Lmr_SmrtPhone_cls.isDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Opportunity',SmsFolder__c='New Opp - Drip',TargetId__c = opp1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
       // Lmr_SmrtPhone_cls.getSmsCallout(opp1.Id,templateSms.Id);
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void createCadenceSmrtphoneNonNumberOpp(){

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Opportunity opp1 = [Select Id from Opportunity LIMIT 1];
        opp1.MobilePhone__c = null;
        update opp1;
        
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isRingCentral = false;
        Lmr_SmrtPhone_cls.isDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Opportunity',SmsFolder__c='New Opp - Drip',TargetId__c = opp1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
       // Lmr_SmrtPhone_cls.getSmsCallout(opp1.Id,templateSms.Id);
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    @IsTest
    static void createCadenceSmrtphoneSuccessContact(){

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Contact contact = [Select Id from Contact LIMIT 1];
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isRingCentral = false;
        Lmr_SmrtPhone_cls.isDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Contact',SmsFolder__c='New Con - Drip',TargetId__c = contact.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
       // Lmr_SmrtPhone_cls.getSmsCallout(opp1.Id,templateSms.Id);
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    @IsTest
    static void createCadenceSmrtphoneSuccessNonPhoneContact(){

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Contact contact = [Select Id from Contact LIMIT 1];
        contact.mobilePhone = null;
        update contact;
        
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isRingCentral = false;
        Lmr_SmrtPhone_cls.isDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Contact',SmsFolder__c='New Con - Drip',TargetId__c = contact.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
       // Lmr_SmrtPhone_cls.getSmsCallout(opp1.Id,templateSms.Id);
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    @isTest
    static void createCadenceSmrtphoneError(){
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        lead1.OwnerId =	thisUser.Id; 
        update lead1;
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isRingCentral = false;
        Lmr_SmrtPhone_cls.isDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Lead',SmsFolder__c='New Lead - Drip',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(400, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    @isTest
    static void createCadenceSmrtphoneNoPhone(){
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
        
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
		lead1.Phone = null;
		lead1.MobilePhone = null;
        lead1.ownerId = thisUser.Id;
		update lead1;
        
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isRingCentral = false;
        Lmr_SmrtPhone_cls.isDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Lead',SmsFolder__c='New Lead - Drip',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(400, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
    
        system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    
    @isTest
    static void createCadenceSmrtphoneErrorException(){
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        lead1.ownerId = thisUser.Id;
        update lead1;
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isRingCentral = false;
        Lmr_SmrtPhone_cls.isDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Lead',SmsFolder__c='New Lead - Drip',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(null, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
       //  Lmr_SmrtPhone_cls.getSmsCallout(lead1.Id,templateSms.Id);
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    @IsTest
    static void createCadenceRingCentralSuccess(){
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": \"true\",'+
        '    "access_token": \"test\"'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
		lead1.ownerId = thisUser.Id;
        update lead1;
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoRingCentral = true;
        Lmr_SmrtPhone_cls.isRingCentral = true;
        Lmr_SmrtPhone_cls.isDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Lead',SmsFolder__c='New Lead - Drip',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
         //+ Lmr_SmrtPhone_cls.getSmsCallout(lead1.Id,templateSms.Id);
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    @IsTest
    static void createCadenceRingCentralError(){
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": \"true\",'+
        '    "access_token": \"test\"'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
		lead1.ownerId = thisUser.Id;
        update lead1;
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoRingCentral = true;
        Lmr_SmrtPhone_cls.isRingCentral = true;
        Lmr_SmrtPhone_cls.isDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Lead',SmsFolder__c='New Lead - Drip',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(400, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
         //Lmr_SmrtPhone_cls.getSmsCallout(lead1.Id,templateSms.Id);
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    @IsTest
    static void createCadenceRingCentralErrorException(){
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": \"true\",'+
        '    "access_token": \"test\"'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];

        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoRingCentral = true;
        Lmr_SmrtPhone_cls.isRingCentral = true;
        Lmr_SmrtPhone_cls.isDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Lead',SmsFolder__c='New Lead - Drip',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(null, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
         //Lmr_SmrtPhone_cls.getSmsCallout(lead1.Id,templateSms.Id);
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void createCadenceDialPadSuccess(){
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": \"true\",'+
        '    "access_token": \"test\"'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
    
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = true;
        Lmr_SmrtPhone_cls.isDialpad = true;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Lead',SmsFolder__c='New Lead - Drip',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
         Lmr_SmrtPhone_cls.getSmsCallout(lead1.Id,templateSms.Id);
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    @IsTest
    static void createCadenceDialPadError(){
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": \"true\",'+
        '    "access_token": \"test\"'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];

        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = true;
        Lmr_SmrtPhone_cls.isDialpad = true;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Lead',SmsFolder__c='New Lead - Drip',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(400, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
          Lmr_SmrtPhone_cls.getSmsCallout(lead1.Id,templateSms.Id);
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    @IsTest
    static void createCadenceDialPadErrorException(){
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": \"true\",'+
        '    "access_token": \"test\"'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];

        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = true;
        Lmr_SmrtPhone_cls.isDialpad = true;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Lead',SmsFolder__c='New Lead - Drip',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(null, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
          Lmr_SmrtPhone_cls.getSmsCallout(lead1.Id,templateSms.Id);
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }

    @IsTest
    static void createCadenceCallRailSuccess(){
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": \"true\",'+
        '    "access_token": \"test\"'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
    
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
        Lmr_SmrtPhone_cls.isDialpad = false;
        Lmr_SmrtPhone_cls.isGoCallRail = true;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Lead',SmsFolder__c='New Lead - Drip',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
        // Lmr_SmrtPhone_cls.getSmsCallout(lead1.Id,templateSms.Id);
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    @IsTest
    static void createCadenceCallRailError(){
        LMR_TemplateSms__c templateSms = [Select id from LMR_TemplateSms__c Limit 1];

      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": \"true\",'+
        '    "access_token": \"test\"'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];

        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
        Lmr_SmrtPhone_cls.isDialpad = false;
        Lmr_SmrtPhone_cls.isGoCallRail = true;
        
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',Object__c = 'Lead',SmsFolder__c='New Lead - Drip',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(400, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
        // Lmr_SmrtPhone_cls.getSmsCallout(lead1.Id,templateSms.Id);
    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }       
    
    public static Boolean doesObjectExist(String objectApiName) {
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        return globalDescribe.containsKey(objectApiName);
    }            
}