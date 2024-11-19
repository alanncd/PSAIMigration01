global with sharing class LeadFollowUpService {
    
    global static void createLeadFollowUpRecords(){
        List<EmailTemplate> emailTemplateList = [SELECT Id, Name,DeveloperName, TemplateStyle, IsActive, Description, 
                                                 Subject, Body,HtmlValue FROM
                                                 EmailTemplate WHERE Folder.Name ='Left Main Email Follow Up'
                                                 AND IsActive=true AND (NOT Name  LIKE '%same%') WITH USER_MODE ORDER BY Name];
        Map<String,String> templateDeveloperNameWithId = new Map<String,String>();
        Map<String,String> templateDeveloperNameWithName = new Map<String,String>();
        for(EmailTemplate emailTemObj : emailTemplateList){
            templateDeveloperNameWithId.put(emailTemObj.DeveloperName,emailTemObj.Id);
            templateDeveloperNameWithName.put(emailTemObj.DeveloperName,emailTemObj.Name);
        }
        List<Lead_Follow_Up_Sequence__c> upsertList = new List<Lead_Follow_Up_Sequence__c>();
        
            LeftMain_SecurityUtils.checkRead(Lead_Follow_Up_Sequence__c.SObjectType,new List<String> {
                            'Email_Template_Name__c',
                             'Email_Template_Id__c',
                             'Days__c'
        				});       
		LeftMain_SecurityUtils.checkInsert(Lead_Follow_Up_Sequence__c.SObjectType,new List<String> {
                            'Email_Template_Name__c',
                             'Email_Template_Id__c',
                             'Days__c'
        				});                   
        if(templateDeveloperNameWithId != null && templateDeveloperNameWithId.Size() > 0){
            if(templateDeveloperNameWithId.containsKey('X10_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 10;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X10_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X10_Day_Lead_Longterm_Follow_Up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X30_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 30;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X30_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X30_Day_Lead_Longterm_Follow_Up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X45_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 45;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X45_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X45_Day_Lead_Longterm_Follow_Up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X60_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 60;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X60_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X60_Day_Lead_Longterm_Follow_Up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X90_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 90;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X90_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X90_Day_Lead_Longterm_Follow_Up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X120_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 120;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X120_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X120_Day_Lead_Longterm_Follow_Up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X150_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 150;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X150_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X150_Day_Lead_Longterm_Follow_Up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X180_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 180;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X180_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X180_Day_Lead_Longterm_Follow_Up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X210_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 210;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X210_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X210_Day_Lead_Longterm_Follow_Up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X240_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 240;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X240_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X240_Day_Lead_Longterm_Follow_Up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X270_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 270;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X270_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X270_Day_Lead_Longterm_Follow_Up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X300_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 300;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X300_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X300_Day_Lead_Longterm_Follow_Up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X330_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 330;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X330_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X330_Day_Lead_Longterm_Follow_Up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X365_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 365;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X365_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X365_Day_Lead_Longterm_Follow_Up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X400_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 400;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X400_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X400_Day_Lead_Longterm_Follow_Up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X430_Day_Lead_Longterm_Follow_up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 430;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X430_Day_Lead_Longterm_Follow_up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X430_Day_Lead_Longterm_Follow_up');
                upsertList.add(followUpObj);
            }
             if(templateDeveloperNameWithId.containsKey('X460_Day_Lead_Longterm_Follow_up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 460;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X460_Day_Lead_Longterm_Follow_up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X460_Day_Lead_Longterm_Follow_up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X490_Day_Lead_Longterm_Follow_up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 490;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X490_Day_Lead_Longterm_Follow_up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X490_Day_Lead_Longterm_Follow_up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X520_Day_Lead_Longterm_Follow_up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 520;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X520_Day_Lead_Longterm_Follow_up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X520_Day_Lead_Longterm_Follow_up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X550_Day_Lead_Longterm_Follow_up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 550;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X550_Day_Lead_Longterm_Follow_up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X550_Day_Lead_Longterm_Follow_up');
                upsertList.add(followUpObj);
            }
            if(templateDeveloperNameWithId.containsKey('X580_Day_Lead_Longterm_Follow_Up')){
                Lead_Follow_Up_Sequence__c followUpObj = new Lead_Follow_Up_Sequence__c();
                followUpObj.Days__c = 580;
                followUpObj.Email_Template_Id__c = templateDeveloperNameWithId.get('X580_Day_Lead_Longterm_Follow_Up');
                followUpObj.Email_Template_Name__c = templateDeveloperNameWithName.get('X580_Day_Lead_Longterm_Follow_Up');
                upsertList.add(followUpObj);
            }

            if(!upsertList.isEmpty()){
                LeftMain_SecurityUtils.checkInsert(Lead_Follow_Up_Sequence__c.SObjectType,new List<String> {
                    'Days__c',
                     'Email_Template_Id__c',
                     'Email_Template_Name__c'
                });
                LeftMain_SecurityUtils.checkUpdate(Lead_Follow_Up_Sequence__c.SObjectType,new List<String> {
                    'Days__c',
                     'Email_Template_Id__c',
                     'Email_Template_Name__c'
                });

                SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, upsertList);
                Database.insert(upsertList = decision3.getRecords());
            }
        }
        
        
    }
    global static void updateDaysFieldFollowUpObject(){
        // Check if the user has permission to update the 'Days__c' field
    if (!Schema.sObjectType.Lead_Follow_Up_Sequence__c.isUpdateable() ||
        !Schema.sObjectType.Lead_Follow_Up_Sequence__c.fields.Days__c.isUpdateable()) {
        throw new AuraHandledException('You do not have permission to update the Days__c field on Lead_Follow_Up_Sequence__c.');
     }

        List<Lead_Follow_Up_Sequence__c> lstEmailTemplates = [Select  Days__c, Day__c FROM Lead_Follow_Up_Sequence__c Where Day__c != null AND Days__c=NULL WITH SECURITY_ENFORCED Limit 200];
        for(Lead_Follow_Up_Sequence__c l:lstEmailTemplates){
            l.Days__c= l.Day__c;
        }
        
        LeftMain_SecurityUtils.checkUpdate(Lead_Follow_Up_Sequence__c.SObjectType,new List<String> {'Days__c'});

        SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.UPDATABLE, lstEmailTemplates);
        lstEmailTemplates = decision3.getRecords();
        if (!lstEmailTemplates.isEmpty()) {
            Database.update(lstEmailTemplates);
        }
    }
}