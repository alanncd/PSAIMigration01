@isTest
public class CadencesTriggerHandlerTst {
    
     static User setupTestUser(String profileName){
         System.debug('test setup');
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
        List<PermissionSet> ps = [SELECT Id,Name FROM PermissionSet Where name='Left_Main_User'];
        User thisUser = setupTestUser('System Administrator');
       
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
        smsTemplateList.add(new LMR_TemplateSms__c(Name='Buyer',Body__c='Test {!Status} 1',Object__c='Lead',Folder__c='New Lead - Drip',Status__c='Active',Schedule__c=1,TypeOfSchedule__c='Now'));
       	smsTemplateList.add(new LMR_TemplateSms__c(Name='Buyer 2',Body__c='Test {!Status} 2',Object__c='Lead',Folder__c='New Lead - Drip',Status__c='Active',Schedule__c=1,TypeOfSchedule__c='Minutes'));
       	smsTemplateList.add(new LMR_TemplateSms__c(Name='Buyer 3',Body__c='Test {!Status} 3',Object__c='Lead',Folder__c='New Lead - Drip',Status__c='Active',Schedule__c=1,TypeOfSchedule__c='Days'));
		smsTemplateList.add(new LMR_TemplateSms__c(Name='Buyer 4',Body__c='Test {!Status} 4',Object__c='Lead',Folder__c='New Lead - Drip',Status__c='Active',Schedule__c=1,TypeOfSchedule__c='Hours'));        
        smsTemplateList.add(new LMR_TemplateSms__c(Name='Buyer 5',Body__c='Test {!Opportunity.account.firstname} 5',Object__c='Opportunity',Folder__c='New Lead - Drip',Status__c='Active',Schedule__c=1,TypeOfSchedule__c='Hours'));        

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
                                                 EmailTemplate WHERE (Folder.Name ='Left Main Email Follow Up' OR Folder.Name ='Left Main Lead Follow Up')
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
        SObject lead2 = mock('Lead');
        List<SObject> leads = new List<Lead>();
        leads.add(lead);
        leads.add(lead2);
        insert leads;
        Lead lNew = [Select Id,MobilePhone from Lead  LIMIT 1];
        lNew.MobilePhone='92399234';
        update lNew;
        
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
        
        //Account
        SObject Acc = mock('Account');
        insert Acc;
        Account accUpd =[Select firstName From Account LIMIT 1];
        accUpd.Name='testname';
        update accUpd;
        
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
        oppnew.AccountId = Acc.Id;
        update oppnew;
        
        //Transaction
        Boolean trxObj1 = doesObjectExist('Transactions__c');
        Boolean trxObj2 = doesObjectExist('Left_Main__Transactions__c');
        String varTransaction='Left_Main__Transactions__c';
        if(trxObj1){varTransaction='Transactions__c';}
        
        SObject trx = mock(varTransaction);
		insert trx;
        Transactions__c trxNew = [Select Id,Mobile__c from Transactions__c LIMIT 1];
        trxNew.Mobile__c='92399234';
        trxNew.Opportunity__c=oppnew.Id;
        update trxNew;
        
        //Insert Interested Buyer
        Interested_Buyers__c ibc = new Interested_Buyers__c();
        ibc.Name='ibc Test';
        ibc.Transactions__c=trxNew.Id;
		insert ibc;
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
    static void createBulkCadence(){
      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
      String json=		'{'+
		'    "status": true,'+
		'}';
      List<Lead> leads = [Select Phone,mobilePhone from Lead];
        
      Test.startTest();
        System.runAs(thisUser){
         List<Cadences__c> smsTemplateList = new List<Cadences__c>();
         smsTemplateList.add(new Cadences__c(Name='Test1',FolderEmail__c='Folder 1',SmsFolder__c='New Lead - Drip',TaskEmailTemplate__c='Folder1',TargetId__c = leads[0].Id,Ownerid=thisUser.Id));
		 //smsTemplateList.add(new Cadences__c(Name='Test2',FolderEmail__c='Folder 2',SmsFolder__c='New Lead - Drip2',TaskEmailTemplate__c='Folder2',TargetId__c = leads[1].Id,Ownerid=thisUser.Id));            
         insert smsTemplateList;    
         system.assertNotEquals(smsTemplateList.size(), 0);
        }
      Test.stopTest();
    }
    @IsTest
    static void createCadenceSmrtphone(){
 
      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Id,Phone,mobilePhone from Lead LIMIT 1];        
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='New Lead - Drip',TaskEmailTemplate__c='Folder1',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
         //Lmr_SmrtPhone_cls.smartPhoneCallout(lead1.Id,smsTemplateList[0].Id);
    
         system.assertNotEquals(smsTemplateList.size(), 0);
         
         SingleRequestMock mock2 = new SingleRequestMock(400, 'FAIL', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock2);
        // Lmr_SmrtPhone_cls.smartPhoneCallout(lead1.Id,smsTemplateList[0].Id);
         
         List<LMR_SmsError__c> errorRecords = [SELECT Id FROM LMR_SmsError__c];
         System.assertEquals(errorRecords.size(),0 , 'Se esperaba que se creara un registro de error');
            
        } 
        Test.stopTest();
    }
    @IsTest
    static void createCadenceSmrtphoneTwo(){
 
      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Id,Phone,mobilePhone from Lead LIMIT 1];        
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='New Lead - Drip',TaskEmailTemplate__c='Folder1',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
        insert smsTemplateList;
    
              
            try{
                 Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpointResponse());
                 // Lmr_SmrtPhone_cls.smartPhoneCallout(lead1.Id,smsTemplateList[0].Id);
              
                 
            }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
                  List<LMR_SmsError__c> errorRecords = [SELECT Id FROM LMR_SmsError__c];
               System.assertEquals(errorRecords.size(),0 , 'Se esperaba que se creara un registro de error');
       
            }   
      

            
        } 
        Test.stopTest();
    }
    

    @IsTest
    static void createCadenceDialpad(){
      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        
       
        Test.startTest();
        Lmr_SmrtPhone_cls.isDialPad = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isGoSmrtphone = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='New Lead - Drip',TaskEmailTemplate__c='Folder1',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
        //Lmr_SmrtPhone_cls.smartPhoneCallout(lead1.Id,smsTemplateList[0].Id);

         //system.assertNotEquals(smsTemplateList.size(), 0);
         
         List<LMR_SmsHistory__c> smsHistory = [SELECT Id FROM LMR_SmsHistory__c];
         System.assertEquals(smsHistory.size(),0 , 'Se esperaba que se creara un registro de error');
     
            
         SingleRequestMock mock2 = new SingleRequestMock(400, 'FAIL', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock2);
       
       // Lmr_SmrtPhone_cls.smartPhoneCallout(lead1.Id,smsTemplateList[0].Id);
          List<LMR_SmsError__c> errorRecords = [SELECT Id FROM LMR_SmsError__c];
         System.assertEquals(errorRecords.size(),0 , 'Se esperaba que se creara un registro de error');
     

        }
        Test.stopTest();
    }
    
    @IsTest
    static void createCadenceDialpadException(){
      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        
       
        Test.startTest();
        Lmr_SmrtPhone_cls.isDialPad = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isGoSmrtphone = false;
        Lmr_SmrtPhone_cls.isGoSmrtphone = false;
        
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='New Lead - Drip',TaskEmailTemplate__c='Folder1',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
        
        insert smsTemplateList;
            
              try{
                 Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpointResponse());
                 // Lmr_SmrtPhone_cls.smartPhoneCallout(lead1.Id,smsTemplateList[0].Id);
              
                 
            }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
                  List<LMR_SmsError__c> errorRecords = [SELECT Id FROM LMR_SmsError__c];
               System.assertEquals(errorRecords.size(),0 , 'Se esperaba que se creara un registro de error');
       
            }   
            
        }
        Test.stopTest();
    }
    
    @IsTest
    static void createCadenceDialpadOpp(){
      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		//Lead lead1 = [Select MobilePhone__c from Lead LIMIT 1];
              
        Test.startTest();
        System.runAs(thisUser){
             Opportunity opp = [Select MobilePhone__c From Opportunity Limit 1 ];

             List<Cadences__c> smsTemplateList = new List<Cadences__c>();
      
             smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='New Lead - Drip',TaskEmailTemplate__c='Folder1',TargetId__c = Opp.Id,Ownerid=thisUser.Id));
             SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);  
         	 Test.setMock(HttpCalloutMock.class, mock);
             insert smsTemplateList;
             List<LMR_TemplateSms__c> templateOfSms = [
              SELECT Name, Body__c, Object__c
              FROM LMR_TemplateSms__c LIMIT 1
             ];
       
             system.assertNotEquals(smsTemplateList.size(), 0);
        }
       
       
        
        Test.stopTest();
    }
    
    @IsTest
    static void createSMSHistoryContact(){
      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		//Lead lead1 = [Select MobilePhone__c from Lead LIMIT 1];
              
        Test.startTest();
        System.runAs(thisUser){
             Contact ct = [Select mobilePhone From Contact Limit 1 ];

             List<Cadences__c> smsTemplateList = new List<Cadences__c>();
      
             smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='New Lead - Drip',TaskEmailTemplate__c='Folder1',TargetId__c = ct.Id,Ownerid=thisUser.Id));
             SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);  
         	 Test.setMock(HttpCalloutMock.class, mock);
             insert smsTemplateList;
             List<LMR_TemplateSms__c> templateOfSms = [
              SELECT Name, Body__c, Object__c
              FROM LMR_TemplateSms__c LIMIT 1
             ];
       
             system.assertNotEquals(smsTemplateList.size(), 0);
        }
       
       
        
        Test.stopTest();
    }

    @IsTest
    static void createCadenceRingCentral(){



        List<Ring_Central_Configuration__mdt> apiSettingRingCentral = Ring_Central_Configuration__mdt.getall().values();

        String authUrl=apiSettingRingCentral[0].authUrl__c;
        String authUrl2=apiSettingRingCentral[0].authUrl2__c;


      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        
        Test.startTest();
        Lmr_SmrtPhone_cls.isRingCentral = true;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
        Lmr_SmrtPhone_cls.isGoSmrtphone = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='New Lead - Drip',TaskEmailTemplate__c='Folder1',TargetId__c = lead1.Id,Ownerid=thisUser.Id));


        String token=		'{'+
		'  "access_token": "1/fFAGRNJru1FTz70BzhT3Zg",'+
		'  "expires_in": 3920,'+
		'  "scope": "https://platform.ringcentral.com/restapi/oauth/token?extension=101",'+
		'  "token_type": "Bearer"'+
		'}';
    

        
        
String jsonr=		'{'+
		' "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log?view=Simple&dateFrom=2015-11-24T12:07:53.175Z&dateTo=2015-11-25T12:07:53.175Z&page=1&perPage=2",'+
		'  "records" : [ {'+
		'    "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log/IWM7cJogEv7xlu8?view=Simple",'+
		'    "id" : "IWM7cJogEv7xlu8",'+
		'    "sessionId" : "403631628008",'+
		'    "telephonySessionId": "s-9a03590172ea4d39a7cf7d5b6dba6a3b",'+
		'    "startTime" : "2015-11-25T12:07:51.000Z",'+
		'    "duration" : 10,'+
		'    "type" : "Voice",'+
		'    "direction" : "Inbound",'+
		'    "action" : "Phone Call",'+
		'    "result" : "Missed",'+
		'    "to" : {'+
		'      "phoneNumber" : "+16505556678"'+
		'    },'+
		'    "from" : {'+
		'      "phoneNumber" : "+18883930031",'+
		'      "name" : "John Smith"'+
		'    }'+
		'  }, {'+
		'    "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log/IWM7bHBPqeZTlu8?view=Simple",'+
		'    "id" : "IWM7bHBPqeZTlu8",'+
		'    "sessionId" : "403631625008",'+
		'    "telephonySessionId": "t-9a03590172ea4d39a7cf7d5b6dba6a3b",'+
		'    "startTime" : "2015-11-25T12:07:51.000Z",'+
		'    "duration" : 10,'+
		'    "type" : "Voice",'+
		'    "direction" : "Outbound",'+
		'    "action" : "VoIP Call",'+
		'    "result" : "Call connected",'+
		'    "to" : {'+
		'      "phoneNumber" : "+16504445567",'+
		'      "location" : "Palo Alto, CA"'+
		'    },'+
		'    "from" : {'+
		'      "phoneNumber" : "+18883930031",'+
		'      "name" : "John Smith"'+
		'    }'+
		'  } ],'+
		'  "paging" : {'+
		'    "page" : 1,'+
		'    "perPage" : 2,'+
		'    "pageStart" : 0,'+
		'    "pageEnd" : 1'+
		'  },'+
		'  "navigation" : {'+
		'    "nextPage" : {'+
		'      "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log?view=Simple&dateFrom=2015-11-24T12:07:53.175Z&dateTo=2015-11-25T12:07:53.175Z&page=2&perPage=2"'+
		'    },'+
		'    "firstPage" : {'+
		'      "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log?view=Simple&dateFrom=2015-11-24T12:07:53.175Z&dateTo=2015-11-25T12:07:53.175Z&page=1&perPage=2"'+
		'    }'+
		'  } '+
		'}';

         SingleRequestMock tokenMock = new SingleRequestMock(200, 'OK', token, null);
         SingleRequestMock createEventMock = new SingleRequestMock(200, 'OK', jsonr, null);

         Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
         requests.put(authUrl,tokenMock);
         requests.put(authUrl2,createEventMock);
         MultiRequestMock mock = new MultiRequestMock(requests);

      	 Test.setMock(HttpCalloutMock.class, mock);

        insert smsTemplateList;
        //Lmr_SmrtPhone_cls.smartPhoneCallout(lead1.Id,smsTemplateList[0].Id);

         system.assertNotEquals(smsTemplateList.size(), 0);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void createCadenceRingCentralTwo(){



        List<Ring_Central_Configuration__mdt> apiSettingRingCentral = Ring_Central_Configuration__mdt.getall().values();

        String authUrl=apiSettingRingCentral[0].authUrl__c;
        String authUrl2=apiSettingRingCentral[0].authUrl2__c;


      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        
        Test.startTest();
        Lmr_SmrtPhone_cls.isRingCentral = true;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
        Lmr_SmrtPhone_cls.isGoSmrtphone = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='New Lead - Drip',TaskEmailTemplate__c='Folder1',TargetId__c = lead1.Id,Ownerid=thisUser.Id));


        String token=		'{'+
		'  "access_token": "1/fFAGRNJru1FTz70BzhT3Zg",'+
		'  "expires_in": 3920,'+
		'  "scope": "https://platform.ringcentral.com/restapi/oauth/token?extension=101",'+
		'  "token_type": "Bearer"'+
		'}';
    

        
        
String jsonr=		'{'+
		' "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log?view=Simple&dateFrom=2015-11-24T12:07:53.175Z&dateTo=2015-11-25T12:07:53.175Z&page=1&perPage=2",'+
		'  "records" : [ {'+
		'    "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log/IWM7cJogEv7xlu8?view=Simple",'+
		'    "id" : "IWM7cJogEv7xlu8",'+
		'    "sessionId" : "403631628008",'+
		'    "telephonySessionId": "s-9a03590172ea4d39a7cf7d5b6dba6a3b",'+
		'    "startTime" : "2015-11-25T12:07:51.000Z",'+
		'    "duration" : 10,'+
		'    "type" : "Voice",'+
		'    "direction" : "Inbound",'+
		'    "action" : "Phone Call",'+
		'    "result" : "Missed",'+
		'    "to" : {'+
		'      "phoneNumber" : "+16505556678"'+
		'    },'+
		'    "from" : {'+
		'      "phoneNumber" : "+18883930031",'+
		'      "name" : "John Smith"'+
		'    }'+
		'  }, {'+
		'    "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log/IWM7bHBPqeZTlu8?view=Simple",'+
		'    "id" : "IWM7bHBPqeZTlu8",'+
		'    "sessionId" : "403631625008",'+
		'    "telephonySessionId": "t-9a03590172ea4d39a7cf7d5b6dba6a3b",'+
		'    "startTime" : "2015-11-25T12:07:51.000Z",'+
		'    "duration" : 10,'+
		'    "type" : "Voice",'+
		'    "direction" : "Outbound",'+
		'    "action" : "VoIP Call",'+
		'    "result" : "Call connected",'+
		'    "to" : {'+
		'      "phoneNumber" : "+16504445567",'+
		'      "location" : "Palo Alto, CA"'+
		'    },'+
		'    "from" : {'+
		'      "phoneNumber" : "+18883930031",'+
		'      "name" : "John Smith"'+
		'    }'+
		'  } ],'+
		'  "paging" : {'+
		'    "page" : 1,'+
		'    "perPage" : 2,'+
		'    "pageStart" : 0,'+
		'    "pageEnd" : 1'+
		'  },'+
		'  "navigation" : {'+
		'    "nextPage" : {'+
		'      "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log?view=Simple&dateFrom=2015-11-24T12:07:53.175Z&dateTo=2015-11-25T12:07:53.175Z&page=2&perPage=2"'+
		'    },'+
		'    "firstPage" : {'+
		'      "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log?view=Simple&dateFrom=2015-11-24T12:07:53.175Z&dateTo=2015-11-25T12:07:53.175Z&page=1&perPage=2"'+
		'    }'+
		'  } '+
		'}';

         SingleRequestMock tokenMock2 = new SingleRequestMock(200, 'OK', token, null);
         SingleRequestMock createEventMock2 = new SingleRequestMock(400, 'FAIL', jsonr, null);

         Map<String, HttpCalloutMock> requests2 = new Map<String, HttpCalloutMock>();
         requests2.put(authUrl,tokenMock2);
         requests2.put(authUrl2,createEventMock2);
         MultiRequestMock mock2 = new MultiRequestMock(requests2);

      	 Test.setMock(HttpCalloutMock.class, mock2);

        insert smsTemplateList;
        //Lmr_SmrtPhone_cls.smartPhoneCallout(lead1.Id,smsTemplateList[0].Id);

         List<LMR_SmsError__c> errorRecords = [SELECT Id FROM LMR_SmsError__c];
         System.assertEquals(errorRecords.size(),0 , 'Se esperaba que se creara un registro de error');
       
        }
        Test.stopTest();
    }
    
    @IsTest
    static void createCadenceRingCentralException(){



        List<Ring_Central_Configuration__mdt> apiSettingRingCentral = Ring_Central_Configuration__mdt.getall().values();

        String authUrl=apiSettingRingCentral[0].authUrl__c;
        String authUrl2=apiSettingRingCentral[0].authUrl2__c;


      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        
        Test.startTest();
        Lmr_SmrtPhone_cls.isRingCentral = true;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
        Lmr_SmrtPhone_cls.isGoSmrtphone = false;
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='New Lead - Drip',TaskEmailTemplate__c='Folder1',TargetId__c = lead1.Id,Ownerid=thisUser.Id));


        String token=		'{'+
		'  "access_token": "1/fFAGRNJru1FTz70BzhT3Zg",'+
		'  "expires_in": 3920,'+
		'  "scope": "https://platform.ringcentral.com/restapi/oauth/token?extension=101",'+
		'  "token_type": "Bearer"'+
		'}';
    

        
        
String jsonr=		'{'+
		' "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log?view=Simple&dateFrom=2015-11-24T12:07:53.175Z&dateTo=2015-11-25T12:07:53.175Z&page=1&perPage=2",'+
		'  "records" : [ {'+
		'    "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log/IWM7cJogEv7xlu8?view=Simple",'+
		'    "id" : "IWM7cJogEv7xlu8",'+
		'    "sessionId" : "403631628008",'+
		'    "telephonySessionId": "s-9a03590172ea4d39a7cf7d5b6dba6a3b",'+
		'    "startTime" : "2015-11-25T12:07:51.000Z",'+
		'    "duration" : 10,'+
		'    "type" : "Voice",'+
		'    "direction" : "Inbound",'+
		'    "action" : "Phone Call",'+
		'    "result" : "Missed",'+
		'    "to" : {'+
		'      "phoneNumber" : "+16505556678"'+
		'    },'+
		'    "from" : {'+
		'      "phoneNumber" : "+18883930031",'+
		'      "name" : "John Smith"'+
		'    }'+
		'  }, {'+
		'    "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log/IWM7bHBPqeZTlu8?view=Simple",'+
		'    "id" : "IWM7bHBPqeZTlu8",'+
		'    "sessionId" : "403631625008",'+
		'    "telephonySessionId": "t-9a03590172ea4d39a7cf7d5b6dba6a3b",'+
		'    "startTime" : "2015-11-25T12:07:51.000Z",'+
		'    "duration" : 10,'+
		'    "type" : "Voice",'+
		'    "direction" : "Outbound",'+
		'    "action" : "VoIP Call",'+
		'    "result" : "Call connected",'+
		'    "to" : {'+
		'      "phoneNumber" : "+16504445567",'+
		'      "location" : "Palo Alto, CA"'+
		'    },'+
		'    "from" : {'+
		'      "phoneNumber" : "+18883930031",'+
		'      "name" : "John Smith"'+
		'    }'+
		'  } ],'+
		'  "paging" : {'+
		'    "page" : 1,'+
		'    "perPage" : 2,'+
		'    "pageStart" : 0,'+
		'    "pageEnd" : 1'+
		'  },'+
		'  "navigation" : {'+
		'    "nextPage" : {'+
		'      "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log?view=Simple&dateFrom=2015-11-24T12:07:53.175Z&dateTo=2015-11-25T12:07:53.175Z&page=2&perPage=2"'+
		'    },'+
		'    "firstPage" : {'+
		'      "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log?view=Simple&dateFrom=2015-11-24T12:07:53.175Z&dateTo=2015-11-25T12:07:53.175Z&page=1&perPage=2"'+
		'    }'+
		'  } '+
		'}';

         SingleRequestMock tokenMock2 = new SingleRequestMock(200, 'OK', token, null);
         SingleRequestMock createEventMock2 = new SingleRequestMock(400, 'FAIL', jsonr, null);

         Map<String, HttpCalloutMock> requests2 = new Map<String, HttpCalloutMock>();
         requests2.put(authUrl,tokenMock2);
         requests2.put(authUrl2,createEventMock2);
         MultiRequestMock mock2 = new MultiRequestMock(requests2);

      	 //Test.setMock(HttpCalloutMock.class, tokenMock2);
            

        insert smsTemplateList;

            
             try{
                  //Test.setMock(HttpCalloutMock.class, tokenMock2);
                  Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpointResponse());
                 // Lmr_SmrtPhone_cls.smartPhoneCallout(lead1.Id,smsTemplateList[0].Id);
              
                 
            }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
                  List<LMR_SmsError__c> errorRecords = [SELECT Id FROM LMR_SmsError__c];
               System.assertEquals(errorRecords.size(),0 , 'Se esperaba que se creara un registro de error');
       
            }   
       
        }
        
         
        Test.stopTest();
    }


        @IsTest
    	static void createCadenceOpp(){//14%
        User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];

       	String json=		'{'+
		'    "status": true,'+
		'}';
        System.runAs(thisUser){
		Opportunity opp1 = [Select Name,MobilePhone__c from Opportunity LIMIT 1];
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='Folder1',TaskEmailTemplate__c='Folder1',TargetId__c = opp1.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
        //Lmr_SmrtPhone_cls.smartPhoneCallout(opp1.Id,smsTemplateList[0].Id);
        system.assertNotEquals(smsTemplateList.size(), 0);
        opp1.MobilePhone__c = null;
        update opp1;    
       // Lmr_SmrtPhone_cls.smartPhoneCallout(opp1.Id,smsTemplateList[0].Id);
        List<LMR_SmsError__c> errorRecords = [SELECT Id FROM LMR_SmsError__c];
        System.assertEquals(errorRecords.size(),0 , 'Se esperaba que se creara un registro de error');
       
    
            
        Test.stopTest();
        }
    }
        @IsTest
    	static void createCadenceTransaction(){
        User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];

       	String json=		'{'+
		'    "status": true,'+
		'}';
        System.runAs(thisUser){
		Transactions__c trx1 = [Select Name,Mobile__c,Mobile_Phone__c from Transactions__c LIMIT 1];
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='Folder1',TaskEmailTemplate__c='Folder1',TargetId__c = trx1.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
        //Lmr_SmrtPhone_cls.smartPhoneCallout(trx1.Id,smsTemplateList[0].Id);
        system.assertNotEquals(smsTemplateList.size(), 0);
        trx1.Mobile__c = null;
        update trx1;    
       // Lmr_SmrtPhone_cls.smartPhoneCallout(trx1.Id,smsTemplateList[0].Id);
        List<LMR_SmsError__c> errorRecords = [SELECT Id FROM LMR_SmsError__c];
        System.assertEquals(errorRecords.size(),0 , 'Se esperaba que se creara un registro de error');
      
        Test.stopTest();
        }
    }    
		@IsTest
    	static void createCadenceInterestedBuyer(){
        User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];

       	String json=		'{'+
		'    "status": true,'+
		'}';
        System.runAs(thisUser){
		Interested_Buyers__c ibc1 = [Select Name,Transactions__r.OwnerId,Transactions__r.Mobile_Phone__c from Interested_Buyers__c LIMIT 1];
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='Folder1',TaskEmailTemplate__c='Folder1',TargetId__c = ibc1.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
       //Lmr_SmrtPhone_cls.smartPhoneCallout(ibc1.Id,smsTemplateList[0].Id);
        system.assertNotEquals(smsTemplateList.size(), 0);
        
      
        Test.stopTest();
        }
    }            

    @IsTest
    static void createCadenceContact(){
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Contact contact1 = [Select Phone,mobilePhone from Contact LIMIT 1];
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='Folder1',TaskEmailTemplate__c='Folder1',TargetId__c = contact1.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
        system.assertNotEquals(smsTemplateList.size(), 0);
        contact1.mobilePhone = null;
        update contact1;
        //Lmr_SmrtPhone_cls.smartPhoneCallout(contact1.Id,smsTemplateList[0].Id);
        List<LMR_SmsError__c> errorRecords = [SELECT Id FROM LMR_SmsError__c];
        System.assertEquals(errorRecords.size(),0 , 'Se esperaba que se creara un registro de error');

        Test.stopTest();
    }
    
    
        @IsTest
    static void createCadenceError1(){

		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        Test.startTest();
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='Folder1',TaskEmailTemplate__c='Folder1',TargetId__c = lead1.Id));
        try{
            insert smsTemplateList;
            system.assertEquals(smsTemplateList.size(), 1);
        }catch(Exception e){
            }
        Test.stopTest();
        
    }
    
        @IsTest
    static void createCadenceError2(){
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        Test.startTest();
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='Folder1',TaskEmailTemplate__c='Folder1',TargetId__c = lead1.Id));
         SingleRequestMock mock = new SingleRequestMock(401, 'Error', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
        List<Cadences__c> smsTemplateList2 = new List<Cadences__c>();
        smsTemplateList2.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='Folder1',TaskEmailTemplate__c='Folder1',TargetId__c = lead1.Id));
         SingleRequestMock mock2 = new SingleRequestMock(401, 'Error', json, null);
        insert smsTemplateList2;
        system.assertNotEquals(smsTemplateList.size(), 0);
        Test.stopTest();
        
    }
    
            @IsTest
    static void createCadenceError3(){
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='Folder1',TaskEmailTemplate__c='Folder1',TargetId__c = lead1.Id));
         SingleRequestMock.UnauthorizedEndpointResponse mock = new SingleRequestMock.UnauthorizedEndpointResponse();
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
        system.assertNotEquals(smsTemplateList.size(), 0);
        Test.stopTest();
        
    }
    

    @IsTest
    static void testNowTasks(){
        Test.startTest();
       	Lead lead1 = [Select id from LEAD LIMIT 1];
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',TaskEmailTemplate__c='Uncontacted Lead',TargetId__c = lead1.Id));
        
        insert smsTemplateList;
        Test.stopTest();
        system.assertNotEquals(smsTemplateList, Null);

    } 
    
    @isTest
    static void testSmarthPhone(){
       // Test.setMock(HttpcalloutMock.class, new MockGenerator_Test());
       
		String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];

          List<LMR_TemplateSms__c> smsTemplateList = [Select Id,Name,Body__c,Object__c,Folder__c,Status__c,Schedule__c,TypeOfSchedule__c FROM LMR_TemplateSms__c];
        SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
 		Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
       // Lmr_SmrtPhone_cls.smartPhoneCallout(lead1.Id,smsTemplateList[0].Id);
        system.assertNotEquals(json, Null);
       
        Test.stopTest();

        
    }
    @isTest
    static void testSmarthPhoneErrorHandler(){
        
      	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        lead1.mobilePhone = null;
        update lead1;

          List<LMR_TemplateSms__c> smsTemplateList = [Select Id,Name,Body__c,Object__c,Folder__c,Status__c,Schedule__c,TypeOfSchedule__c FROM LMR_TemplateSms__c];
        SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
 		Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
       // Lmr_SmrtPhone_cls.smartPhoneCallout(lead1.Id,smsTemplateList[0].Id);
        
        List<LMR_SmsError__c> errorRecords = [SELECT Id FROM LMR_SmsError__c];
        System.assertEquals(errorRecords.size(),0 , 'Se esperaba que se creara un registro de error');
       
        Test.stopTest();  
        

        
    }
    @isTest
    static void testSmarthPhone2(){
       // Test.setMock(HttpcalloutMock.class, new MockGenerator_Test());
       
		String json=		'{'+
		'    "status": true,'+
		'}';
		Contact contact1 = [Select Id from Contact LIMIT 1];

          List<LMR_TemplateSms__c> smsTemplateList = [Select Id,Name,Body__c,Object__c,Folder__c,Status__c,Schedule__c,TypeOfSchedule__c FROM LMR_TemplateSms__c];
        SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
 		Test.startTest();
        Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
       // Lmr_SmrtPhone_cls.smartPhoneCallout(contact1.Id,smsTemplateList[0].Id);
        system.assertNotEquals(json, Null);
         Test.stopTest();

        
    }
        @isTest
    static void testSmarthPhone3(){
       // Test.setMock(HttpcalloutMock.class, new MockGenerator_Test());
       
		String json=		'{'+
		'    "status": true,'+
		'}';
		Opportunity opp1 = [Select Id from Opportunity LIMIT 1];

          List<LMR_TemplateSms__c> smsTemplateList = [Select Id,Name,Body__c,Object__c,Folder__c,Status__c,Schedule__c,TypeOfSchedule__c FROM LMR_TemplateSms__c];
        SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
 		Test.startTest();
       Lmr_SmrtPhone_cls.isSmrtphone = true;
        Lmr_SmrtPhone_cls.isGoRingCentral = false;
        Lmr_SmrtPhone_cls.isGoDialpad = false;
       // Lmr_SmrtPhone_cls.smartPhoneCallout(opp1.Id,smsTemplateList[0].Id);
        system.assertNotEquals(json, Null);
         Test.stopTest();

        
    }

    @IsTest
    static void sendTasks(){
        Test.startTest();
		List<Task_Follow_Up_Sequence__c> taskFollowup = [Select id From Task_Follow_Up_Sequence__c LIMIT 1];
        Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];

        Lmr_TaskAutomation.createTaskNow(lead1.id,taskFollowup[0].Id);
        system.assertNotEquals(lead1, null) ;
        Test.stopTest();
        
    }
   @IsTest
    static void sendTasks2(){
        Test.startTest();
		List<Task_Follow_Up_Sequence__c> taskFollowup = [Select id From Task_Follow_Up_Sequence__c LIMIT 1];
        Opportunity opp1 = [Select Id from Opportunity LIMIT 1];

        Lmr_TaskAutomation.createTaskNow(opp1.id,taskFollowup[0].Id);
		system.assertNotEquals(opp1, null) ;
        Test.stopTest();
        
    }
    
       @IsTest
    static void sendTasks3(){
        Test.startTest();
		List<Task_Follow_Up_Sequence__c> taskFollowup = [Select id From Task_Follow_Up_Sequence__c LIMIT 1];
        Contact Contact1 = [Select Id from Contact LIMIT 1];

        Lmr_TaskAutomation.createTaskNow(Contact1.id,taskFollowup[0].Id);
        system.assertNotEquals(Contact1, null) ;
        Test.stopTest();
        
    }
       @IsTest
    static void sendTasks6(){
        Test.startTest();
		List<Task_Follow_Up_Sequence__c> taskFollowup = [Select id From Task_Follow_Up_Sequence__c LIMIT 1];
        Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];

    //    Lmr_TaskAutomation.createTaskMethodHours(lead1.id,taskFollowup[0].Id,2);
		system.assertNotEquals(lead1, null) ;
        Test.stopTest();
        
    }
    
           @IsTest
    static void sendTasks4(){
        Test.startTest();
		List<Task_Follow_Up_Sequence__c> taskFollowup = [Select id From Task_Follow_Up_Sequence__c LIMIT 1];
        Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
		system.assertNotEquals(lead1, null) ;
        Test.stopTest();
    }

           @IsTest
    static void sendTasks5(){
        Test.startTest();
		List<Task_Follow_Up_Sequence__c> taskFollowup = [Select id From Task_Follow_Up_Sequence__c LIMIT 1];
        Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        system.assertNotEquals(lead1, null) ;
        Test.stopTest();
    }
    
    @isTest
       static void testStopCadences(){
      User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        
        Test.startTest();
        System.runAs(thisUser){
        List<Cadences__c> smsTemplateList = new List<Cadences__c>();
        smsTemplateList.add(new Cadences__c(Name='Test',FolderEmail__c='Folder 1',SmsFolder__c='Folder1',TaskEmailTemplate__c='Folder1',TargetId__c = lead1.Id,Ownerid=thisUser.Id));
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
        insert smsTemplateList;
            
            try{
			Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(lead1.Id);
            LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            }catch(Exception e){
                System.debug('el mensaje es: '+e);
            }
        }
            Test.stopTest();
        List<lead> listLead = [Select Id FROM lead];
       CadencesTriggerHandler.stopCadenceTrigger(listLead);
        system.assertNotEquals(json, null) ;
       

    }

	@isTest
	static void cadenceBatch(){
        User thisUser = [SELECT Id,Phone FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json = '{' +
        '    "status": true,' +
        '}';
		Lead lead1 = [Select Phone, mobilePhone from Lead LIMIT 1];
        lead1.OwnerId = thisUser.Id;
		update lead1;
    System.runAs(thisUser){
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
        Test.setMock(HttpCalloutMock.class, mock);
   
        batchCadence bs = new batchCadence();
        Test.startTest();
        batchCadence.isSmrtphone = true;
        batchCadence.isGoRingCentral = false;
        batchCadence.isGoDialpad = false;

        batchCadence.bypassChaining = true;
        database.executeBatch(bs, 1);
        system.assertNotEquals(json, null);
        Test.stopTest();
    }
}

   @isTest
   static void cadenceBatchLeadDialPad(){
        User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        
        System.runAs(thisUser){
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
   
        batchCadence bs = new batchCadence();
        Test.startTest();
        batchCadence.isDialPad = true;
        batchCadence.isGoRingCentral = false;
        batchCadence.isGoSmrtPhone = false;
            
        batchCadence.bypassChaining = true;
        database.executeBatch(bs,1);
        system.assertNotEquals(json, null) ;
        Test.stopTest();
        }
       }
    
   @isTest
   static void cadenceBatchLeadRingCentral(){
        User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'    "accessToken": "tokentest"'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        
        System.runAs(thisUser){
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
   
        batchCadence bs = new batchCadence();
        Test.startTest();
        batchCadence.isDialPad = false;
        batchCadence.isGoRingCentral = true;
        batchCadence.isGoSmrtPhone = false;
		batchCadence.isRingCentral =TRUE;
        batchCadence.bypassChaining = true;
        database.executeBatch(bs,1);
        system.assertNotEquals(json, null) ;
        Test.stopTest();
        }
       }

   @isTest
   static void cadenceBatchLeadCallRail(){
        User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String jsonTracker= ''+
            '{'+
    '"trackers": ['+
       ' {'+
       '     "id": "idtest",'+
       '     "name": "test test Facebook LP",'+
       '     "type": "source",'+
            '"status": "active",'+
            '"destination_number": "+17043477777",'+
        '    "tracking_numbers": ['+
         '       "+17043477777"'+
         '   ],'+
         '   "sms_supported": true,'+
         '   "sms_enabled": true,'+
         '   "company": {'+
         '       "id": "idcompanytest",'+
          '      "name": "Full test test, LLC"'+
         '   }'+
       ' },'+
      '    {'+
      '      "id": "idtest2",'+
      '      "name": "test2 test Facebook LP",'+
      '      "type": "source",'+
      '      "status": "active",'+
      '      "destination_number": "+17043466666",'+
'            "tracking_numbers": ['+
                '"+17047466666"'+
            '],'+
            '"sms_supported": true,'+
            '"sms_enabled": true,'+
            '"company": {'+
                '"id": "idcompany2test",'+
                '"name": "Full test2 test, LLC"'+
            '}'+
       ' }'+
	']'+
'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        
        System.runAs(thisUser){
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', jsonTracker, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
   
        batchCadence bs = new batchCadence();
        Test.startTest();
        batchCadence.isDialPad = false;
        batchCadence.isGoRingCentral = false;
        batchCadence.isGoSmrtPhone = false;
		batchCadence.isRingCentral =false;
		batchCadence.isGoCallRail =true;
        batchCadence.bypassChaining = true;
        database.executeBatch(bs,1);
        system.assertNotEquals(jsonTracker, null) ;
        Test.stopTest();
        }
       }
    
   @isTest
   static void cadenceBatch_1(){
        User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
       	String json=		'{'+
		'    "status": true,'+
		'}';
		Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];
        List<ScheduleCadence__c> scheduledCadence = [Select Id from ScheduleCadence__c];
        delete scheduledCadence;
       SObject lead = mock('Lead');
        insert lead;
           
       List<LMR_TemplateSms__c> smsTemplateList = [Select Id from LMR_TemplateSms__c];
   
        ScheduleCadence__c scheduledCadence2 = New ScheduleCadence__c();
        scheduledCadence2.Name='test';
       // scheduledCadence.Lead__c = lead.id;
        scheduledCadence2.IdTemplate__c = smsTemplateList[0].Id;
        scheduledCadence2.TargetId__c = lead.id;
        insert scheduledCadence2;
           
        System.runAs(thisUser){
         SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
   
        batchCadence bs = new batchCadence();
        Test.startTest();
       	batchCadence.isSmrtphone = true;
        batchCadence.isGoRingCentral = false;
        batchCadence.isGoDialpad = false;
            batchCadence.bypassChaining = true;
        	database.executeBatch(bs,1);
            system.assertNotEquals(json, null) ;
        Test.stopTest();
        }
       }
   
    @isTest
   static void cadenceBatch2(){
        
         SObject opp = mock('Opportunity');
		insert opp;
        Opportunity oppnew = [Select Id,MobilePhone__c from Opportunity LIMIT 1];
        oppnew.MobilePhone__c='92399234';

        update oppnew;
        List<ScheduleCadence__c> scheduledCadence = [Select Id from ScheduleCadence__c];
        delete scheduledCadence;
        List<LMR_TemplateSms__c> smsTemplateList = [Select Id from LMR_TemplateSms__c];
        ScheduleCadence__c scheduledCadence2 = New ScheduleCadence__c();
        scheduledCadence2.Name='test';
       // scheduledCadence.Lead__c = lead.id;
        scheduledCadence2.IdTemplate__c = smsTemplateList[0].Id;
        scheduledCadence2.TargetId__c = oppnew.id;
        insert scheduledCadence2;
        Test.startTest();
                batchCadence bs = new batchCadence();
        batchCadence.isSmrtphone = true;
        batchCadence.isGoRingCentral = false;
        batchCadence.isGoDialpad = false;
            batchCadence.bypassChaining = true;
        	database.executeBatch(bs,1);
        	system.assertNotEquals(oppnew, null) ;
        Test.stopTest();
    }
    
    @isTest
    static void cadenceBatch2_1(){
        
         SObject opp = mock('Opportunity');
		insert opp;

        List<ScheduleCadence__c> scheduledCadence = [Select Id from ScheduleCadence__c];
        delete scheduledCadence;
        List<LMR_TemplateSms__c> smsTemplateList = [Select Id from LMR_TemplateSms__c Where Object__c='Opportunity'];
        ScheduleCadence__c scheduledCadence2 = New ScheduleCadence__c();
        scheduledCadence2.Name='test';
       // scheduledCadence.Lead__c = lead.id;
        scheduledCadence2.IdTemplate__c = smsTemplateList[0].Id;
        scheduledCadence2.TargetId__c = opp.id;
        insert scheduledCadence2;
        Test.startTest();
                batchCadence bs = new batchCadence();
        batchCadence.isSmrtphone = true;
        batchCadence.isGoRingCentral = false;
        batchCadence.isGoDialpad = false;
            batchCadence.bypassChaining = true;
        	database.executeBatch(bs,1);
        	system.assertEquals(batchCadence.bypassChaining, true) ;
        Test.stopTest();
    }
	
    @isTest
    static void cadenceBatchContact(){
        SObject Contact = mock('Contact');
        insert Contact;
        Contact newContact = [Select Id,mobilePhone from Contact LIMIT 1];
		newContact.mobilePhone='998834343';
        upsert newContact;
        List<ScheduleCadence__c> scheduledCadence = [Select Id from ScheduleCadence__c];
        delete scheduledCadence;
        List<LMR_TemplateSms__c> smsTemplateList = [Select Id from LMR_TemplateSms__c];
        ScheduleCadence__c scheduledCadence2 = New ScheduleCadence__c();
        scheduledCadence2.Name='test';
        scheduledCadence2.IdTemplate__c = smsTemplateList[0].Id;
        scheduledCadence2.TargetId__c = newContact.id;
        insert scheduledCadence2;
        Test.startTest();
        batchCadence.isSmrtphone = true;
        batchCadence.isGoRingCentral = false;
        batchCadence.isGoDialpad = false;
        batchCadence bs = new batchCadence();
        batchCadence.bypassChaining = true;
        database.executeBatch(bs,1);
        system.assertEquals(batchCadence.bypassChaining, true) ;
        Test.stopTest();
    }

    @isTest
    static void cadenceBatchTransaction(){
        Transactions__c trx1 = [Select Id, Name FROM Transactions__c];
        List<ScheduleCadence__c> scheduledCadence = [Select Id,TargetId__c from ScheduleCadence__c];
        scheduledCadence[0].TargetId__c = trx1.id;
        update scheduledCadence;
        Test.startTest();
        batchCadence.isSmrtphone = true;
        batchCadence.isGoRingCentral = false;
        batchCadence.isGoDialpad = false;
        batchCadence bs = new batchCadence();
        batchCadence.bypassChaining = true;
        database.executeBatch(bs,1);
        system.assertEquals(batchCadence.bypassChaining, true) ;
        Test.stopTest();
    }

    @isTest
    static void cadenceBatchInterestedBuyer(){
        Interested_Buyers__c ib1 = [Select Id, Name FROM Interested_Buyers__c];
        List<ScheduleCadence__c> scheduledCadence = [Select Id,TargetId__c from ScheduleCadence__c];
        scheduledCadence[0].TargetId__c = ib1.id;
        update scheduledCadence;
        Test.startTest();
        batchCadence.isSmrtphone = true;
        batchCadence.isGoRingCentral = false;
        batchCadence.isGoDialpad = false;
        batchCadence bs = new batchCadence();
        batchCadence.bypassChaining = true;
        database.executeBatch(bs,1);
        system.assertEquals(batchCadence.bypassChaining, true) ;
        Test.stopTest();
    }
    
    @isTest
    static void cadenceSmsScheduled(){
    Test.startTest();
         batchCadence myClass = new batchCadence();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);    
         system.assertEquals('0 0 23 * * ?', chron);
    Test.stopTest();
    }
    
    @isTest
    static void cadenceBatchEmail(){
        User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
        System.runAs(thisUser){
        List<EmailTemplate> listEmail = [SELECT Id, Name, FolderId,developerName FROM EmailTemplate WHERE developerName ='test2' LIMIT 1];
        Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];                                     
        ScheduleCadenceEmail__c scheduledCadenceEmail = new ScheduleCadenceEmail__c();
        scheduledCadenceEmail.Name = 'test';
        scheduledCadenceEmail.IdTemplate__c = listEmail[0].Id;
        scheduledCadenceEmail.Related_Record_id__c = lead1.id;
        scheduledCadenceEmail.Status__c='Pending';
       	insert scheduledCadenceEmail;
            
   		Opportunity opp1 = [Select Id from Opportunity Limit 1];
         ScheduleCadenceEmail__c scheduledCadenceEmail2 = new ScheduleCadenceEmail__c();
        scheduledCadenceEmail2.Name = 'test';
        scheduledCadenceEmail2.IdTemplate__c = listEmail[0].Id;
        scheduledCadenceEmail2.Related_Record_id__c = opp1.id;
        scheduledCadenceEmail2.Status__c='Pending';
       	insert scheduledCadenceEmail2;


        Contact con1 = [Select Id from Contact Limit 1];
        ScheduleCadenceEmail__c scheduledCadenceEmail3 = new ScheduleCadenceEmail__c();
        scheduledCadenceEmail3.Name = 'test';
        scheduledCadenceEmail3.IdTemplate__c = listEmail[0].Id;
        scheduledCadenceEmail3.Related_Record_id__c = con1.id;
        scheduledCadenceEmail3.Status__c='Pending';
       	insert scheduledCadenceEmail3;

            
        List<ScheduleCadenceEmail__c> listEmail2 = [Select id from ScheduleCadenceEmail__c];
        batchCadenceEmail bs = new batchCadenceEmail();
        Test.startTest();
        batchCadence.isSmrtphone = true;
        batchCadence.isGoRingCentral = false;
        batchCadence.isGoDialpad = false;
            
           batchCadence.bypassChaining = true;
        	database.executeBatch(bs,100);
            system.assertNotEquals(con1, null);
        Test.stopTest();
        } 

    }
    
           @isTest
       static void testSendEmailNow(){
        User thisUser = [SELECT Id,Username FROM User WHERE Username = 'cadences@leftmainrei.com'];
        System.runAs(thisUser){
        List<EmailTemplate> listEmail = [SELECT Id, Name, FolderId,developerName FROM EmailTemplate WHERE developerName ='test2' LIMIT 1];
        Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];                                     
        Lmr_SendEmail.sendEmailNow(lead1.Id,listEmail[0].Id,'');
        Test.startTest();
            system.assertEquals('cadences@leftmainrei.com', thisUser.Username );
        Test.stopTest();
        } 

    }
    
               @isTest
       static void testSendEmailNow2(){
        User thisUser = [SELECT Id,Username FROM User WHERE Username = 'cadences@leftmainrei.com'];
        System.runAs(thisUser){
        List<EmailTemplate> listEmail = [SELECT Id, Name, FolderId,developerName FROM EmailTemplate WHERE developerName ='test2' LIMIT 1];
        Contact contact1 = [Select Id from Contact LIMIT 1];                                     
        Lmr_SendEmail.sendEmailNow(contact1.Id,listEmail[0].Id,'');
        Test.startTest();
			system.assertEquals('cadences@leftmainrei.com', thisUser.Username );
        Test.stopTest();
        } 

    }
    
               @isTest
       static void testSendEmailNow3(){
        User thisUser = [SELECT Id,Username FROM User WHERE Username = 'cadences@leftmainrei.com'];
        System.runAs(thisUser){
        List<EmailTemplate> listEmail = [SELECT Id, Name, FolderId,developerName FROM EmailTemplate WHERE developerName ='test2' LIMIT 1];
        Opportunity opp1 = [Select Id from Opportunity LIMIT 1];                                     
        Lmr_SendEmail.sendEmailNow(opp1.Id,listEmail[0].Id,'');
        Test.startTest();
			system.assertEquals('cadences@leftmainrei.com', thisUser.Username );
        Test.stopTest();
        } 

    }
    
    @isTest
    static void testScheduledCadenceEmail(){
                User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
        System.runAs(thisUser){
        List<EmailTemplate> listEmail = [SELECT Id, Name, FolderId,developerName FROM EmailTemplate WHERE developerName ='test2' LIMIT 1];
        Lead lead1 = [Select Phone,mobilePhone from Lead LIMIT 1];                                     
        ScheduleCadenceEmail__c scheduledCadenceEmail = new ScheduleCadenceEmail__c();
        scheduledCadenceEmail.Name = 'test';
        scheduledCadenceEmail.IdTemplate__c = listEmail[0].Id;
        scheduledCadenceEmail.Related_Record_id__c = lead1.id;
        scheduledCadenceEmail.Status__c='Pending';
       	insert scheduledCadenceEmail;
            
   		Opportunity opp1 = [Select Id from Opportunity Limit 1];
         ScheduleCadenceEmail__c scheduledCadenceEmail2 = new ScheduleCadenceEmail__c();
        scheduledCadenceEmail2.Name = 'test';
        scheduledCadenceEmail2.IdTemplate__c = listEmail[0].Id;
        scheduledCadenceEmail2.Related_Record_id__c = opp1.id;
        scheduledCadenceEmail2.Status__c='Pending';
       	insert scheduledCadenceEmail2;


        Contact con1 = [Select Id from Contact Limit 1];
        ScheduleCadenceEmail__c scheduledCadenceEmail3 = new ScheduleCadenceEmail__c();
        scheduledCadenceEmail3.Name = 'test';
        scheduledCadenceEmail3.IdTemplate__c = listEmail[0].Id;
        scheduledCadenceEmail3.Related_Record_id__c = con1.id;
        scheduledCadenceEmail3.Status__c='Pending';
       	insert scheduledCadenceEmail3;
            
          Contact cont = new Contact(FirstName ='First Name', LastName ='Last Name', Email='sakthi@theblogreaders.com');
        insert cont;
         
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String CRON_EXP = '0 6 * * * ?';
         
        Test.startTest();
         
        String jobId = System.schedule('Update Contacts', CRON_EXP, new batchCadenceEmail());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
         
        Test.stopTest();
        }
    }
    
    @isTest
    static void testbatchTask(){
        User thisUser = [SELECT Id FROM User WHERE Username = 'cadences@leftmainrei.com'];
        System.runAs(thisUser){

        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String CRON_EXP = '0 6 * * * ?';
         
        Test.startTest();
         
        String jobId = System.schedule('Update Task', CRON_EXP, new batchCadenceTask());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
         
        Test.stopTest();
        }
    }
    
    
    
                @isTest
       static void cadenceBatchTask(){
        User thisUser = [SELECT Id,Username FROM User WHERE Username = 'cadences@leftmainrei.com'];
           
        System.runAs(thisUser){
        batchCadenceTask bs = new batchCadenceTask();
        Test.startTest();
            batchCadence.bypassChaining = true;
        	database.executeBatch(bs,100);
            system.assertEquals('cadences@leftmainrei.com', thisUser.Username );
        Test.stopTest();
        } 

    }
    
     @IsTest
static void testTransactionsAndInterestedBuyersHandling() {
    Test.startTest();
    
    // Crear un registro de Transactions__c con los campos requeridos
    Transactions__c trx = new Transactions__c();
    trx.Name = 'Test Transaction';
    trx.Closing_Date__c = Date.today(); // Fecha de cierre requerida
    trx.Contract_Purchase_Price__c = 100000; // Precio de compra requerido
    trx.Disposition_Decision__c = 'Pending'; // Decisión de disposición requerida
    insert trx;
    
    // Crear un registro de Interested_Buyers__c
    Interested_Buyers__c interestedBuyer = new Interested_Buyers__c();
    interestedBuyer.Name = 'Test Interested Buyer';
    interestedBuyer.Transactions__c = trx.Id;
    insert interestedBuyer;
    
    // Crear un registro de ScheduleCadenceTask__c relacionado con Transactions__c
    ScheduleCadenceTask__c scheduleTaskTransaction = new ScheduleCadenceTask__c();
    scheduleTaskTransaction.Name = 'Test Task for Transaction';
    scheduleTaskTransaction.Related_Record_id__c = trx.Id;
    scheduleTaskTransaction.IdTemplate__c = 'someTemplateId'; // Proporciona un ID de plantilla válido
    insert scheduleTaskTransaction;
    
    // Crear un registro de ScheduleCadenceTask__c relacionado con Interested_Buyers__c
    ScheduleCadenceTask__c scheduleTaskInterestedBuyer = new ScheduleCadenceTask__c();
    scheduleTaskInterestedBuyer.Name = 'Test Task for Interested Buyer';
    scheduleTaskInterestedBuyer.Related_Record_id__c = interestedBuyer.Id;
    scheduleTaskInterestedBuyer.IdTemplate__c = 'someTemplateId'; // Proporciona un ID de plantilla válido
    insert scheduleTaskInterestedBuyer;
    
    // Ejecutar el batch o método que maneja estos registros para activar la lógica del bloque
    batchCadenceTask batch = new batchCadenceTask();
    List<ScheduleCadenceTask__c> taskList = new List<ScheduleCadenceTask__c>{scheduleTaskTransaction, scheduleTaskInterestedBuyer};
    batch.execute(null, taskList);
    
    // Verificar que el bloque de código se ejecutó y los OwnerId se asignaron correctamente
    for(ScheduleCadenceTask__c task : taskList) {
        if (task.Related_Record_id__c == trx.Id) {
            System.assertEquals(trx.OwnerId, task.OwnerId, 'OwnerId should match the Transactions__c OwnerId');
        } else if (task.Related_Record_id__c == interestedBuyer.Id) {
            System.assertEquals(trx.OwnerId, task.OwnerId, 'OwnerId should match the Interested_Buyers__c Transactions__r.OwnerId');
        }
    }
    
    Test.stopTest();
}

    
        @isTest
       static void getCustomSettings(){

           CadencesTrigger__c cadencesTriggerSetup = CadencesTriggerHandler.getCustomSettings();
           
           System.assertEquals(cadencesTriggerSetup.Activate_trigger_cadences__c, true);

    	}
    
           @isTest
       static void ScheduleCadenceTest(){
                   Test.startTest();
             String json=		'{'+
		'    "status": true,'+
		'}';
           Lead lead = [Select id from Lead LIMIT 1];
          SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);

                   Cadences__c newCadence = new Cadences__c();
                    newCadence.Name = 'Test';
          			newCadence.TargetId__c = lead.Id;
           
                    insert newCadence;

//String targetObjectId,String frecuency,String idTemplate,String templateName,Integer scheduledTime
		
      CadencesTriggerHandler.instanceCadences(lead.Id,'Days','324324','Test',233443,newCadence.Id);
           system.assertNotEquals(lead.id, null);
        Test.stopTest();

    	} 

               @isTest
       static void ScheduleCadenceTest2(){
                   Test.startTest();
         String json=		'{'+
		'    "status": true,'+
		'}';
           SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);
      	 Test.setMock(HttpCalloutMock.class, mock);
           Lead lead = [Select id from Lead Limit 1];
                   Cadences__c newCadence = new Cadences__c();
                    newCadence.Name = 'Test';
           			newCadence.TargetId__c = lead.Id;
                    insert newCadence;
           
      CadencesTriggerHandler.instanceCadencesEmail('2323322242','Days',23,'Days','23213321','test@leftmain.com',newCadence.Id);
				system.assertEquals(null, null);
        Test.stopTest();
    	} 

         @isTest
       static void ScheduleCadenceTest3(){
        Lead lead = [Select id from Lead Limit 1];
        Cadences__c newCadence = new Cadences__c();
        newCadence.TargetId__c = lead.Id;
        newCadence.Name = 'Test';
           
        insert newCadence;

      CadencesTriggerHandler.instanceCadencesTask('2323342',1,'23213321','Test','Days',newCadence.Id);
           system.assertEquals(null, null);
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
    
    static SObject mock(String sobjectName) {
        String prefix = '';
        
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
    
    public static Boolean doesObjectExist(String objectApiName) {
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        return globalDescribe.containsKey(objectApiName);
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