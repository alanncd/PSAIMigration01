public with sharing class SendContactListEmailController {
    
    public String templateId {get; set;}
    public String owdEmailId {get; set;}
    public String templateBody{get; set;}
    public List<Contact> contacts {get; set;}
    public String contactNames {get; set;}
    public Map<String,EmailTemplate> emailTemplates; 
        
    public Boolean showSuccess{get;set;}
    public Boolean isError{get;set;}
    public String toastTitle{get;set;}
    public String toastMessage{get;set;}
    
    public Boolean goBack{get;set;}
        
    public SendContactListEmailController(){
        
    }
    
    public SendContactListEmailController(Id templateId,String owdEmailId,List<Contact> contacts){
        this.templateId=templateId;
        this.owdEmailId=owdEmailId; 
        this.contacts=contacts;
    }
    
    public SendContactListEmailController(ApexPages.StandardSetController cntlr){
        contacts = cntlr.getSelected(); //get selected records from contact list view
        goBack = false;
        if(contacts.size()>0){
            showSuccess=false;
            isError=false; 
            contactNames='';
            Set<Id> contactIds = (new Map<Id,SObject>(contacts)).keySet();
            contacts=[Select name,email from Contact where id in :contactIds AND email != null WITH USER_MODE];
            if(contacts != null && !contacts.isEmpty()){
                Integer count = 1;
                for(Contact contact : contacts){
                    contactNames += contact.name;
                    if(count != contacts.size()){
                        contactNames += ', ';
                    }
                    count ++;
                }
            }else{
                isError=true;
                showSuccess=true;
                goBack = false;
                toastTitle='No contacts selected!';
                toastMessage='Please select atleast one Contact(with email) to trigger email';
            } 
        }else{ 
            isError=true;
            showSuccess=true;
            goBack = false;
            toastTitle='No contacts selected!';
            toastMessage='Please select atleast one Contact(with email) to trigger email';
        }
        
    }
    
    public void sendEmail() { 
        try{
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {};
                if(templateId == null || (templateId != null && templateId.length()==0)){
                    isError=true;
                    goBack = true;
                    showSuccess=true;
                    toastTitle='Template is required';
                    toastMessage='Please select template to trigger email';
                }else if(String.isblank(owdEmailId) || (owdEmailId != null && owdEmailId.length()==0)){
                    isError=true;
                    goBack = true;
                    showSuccess=true;
                    toastTitle='From Email is required';
                    toastMessage='Please select from email to trigger email';
                } else{
                    for(Contact contact: contacts){
                        if(String.isNotBlank(contact.email)){
                            Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
                            message.setOrgWideEmailAddressId(owdEmailId);
                            message.setTargetObjectId(contact.id); 
                            message.setTemplateId(templateId);
                            message.setSaveAsActivity(false);
                            messages.add(message);
                        }
                    }
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    showSuccess=true;
                    goBack = false;
                    toastTitle='Success';
                    toastMessage='Successfully triggered mail for selected contacts.';
                }
        }Catch(Exception ex){
            System.debug('Exception while triggering mail - '+ex);
            isError=true;
            goBack = true;
            showSuccess=true;
            toastTitle='Something went wrong!';
            toastMessage=ex.getMessage();
        }
    }

    public void goBackAction() { 
        showSuccess = false;
        isError = false;
    }
    
    
    public List<SelectOption> getcontactTemplates(){
        
        List<SelectOption> templateList = new List<SelectOption>();
        emailTemplates=new Map<String,EmailTemplate>();
        templateList.add(new SelectOption('','--Select here--'));
        for( EmailTemplate emailTemplate :[SELECT Id, Name, TemplateStyle, IsActive, Description, Subject, Body,HtmlValue FROM EmailTemplate where Folder.Name ='Contact List Email Templates' and IsActive=true WITH USER_MODE ]){
            templateList.add(new SelectOption(emailTemplate.Id,emailTemplate.Name));
            emailTemplates.put(emailTemplate.Id,emailTemplate);
        }
        return templateList;
    }
    
    public List<SelectOption> getOwdEmails(){
 
        List<List_Email_Configuration__mdt> userEmailConfigList=[Select user_Name__c,Email_ID__C from List_Email_Configuration__mdt WITH USER_MODE LIMIT 10000];
		List<String> userEmailList=new List<String>();
        
        for(List_Email_Configuration__mdt userEmailConfig : userEmailConfigList){
            userEmailList.add(userEmailConfig.Email_ID__c);
        }
        
        List<SelectOption> emailList = new List<SelectOption>();
        emailList.add(new SelectOption('','--Select here--'));
        for( OrgWideEmailAddress orgWideEmailAddress :[SELECT Id, Address FROM OrgWideEmailAddress WITH USER_MODE LIMIT 10000]){
            if(userEmailList.contains(orgWideEmailAddress.Address)){
                emailList.add(new SelectOption(orgWideEmailAddress.Id,orgWideEmailAddress.Address));
            }
        }
        return emailList; 
    } 
    
    public void changeTemplateBody(){
        if(null!=templateId){
            EmailTemplate emailTemplate =emailTemplates.get(templateId);
            if(null!=emailTemplate && null!=emailTemplate.Body){
                this.templateBody=emailTemplate.Body;
            }else if(null!=emailTemplate && null!=emailTemplate.HtmlValue){
                System.debug(emailTemplate.HtmlValue);
                this.templateBody=emailTemplate.HtmlValue;
            } 
        }
    }
    
}