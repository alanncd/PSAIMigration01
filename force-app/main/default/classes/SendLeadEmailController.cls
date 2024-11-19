public with sharing class SendLeadEmailController {
    
    public String templateId {get; set;}
    public String owdEmailId {get; set;}
    public String templateBody{get; set;}
    public List<Lead> leads {get; set;}
    public String leadNames {get; set;}
    public Map<String,EmailTemplate> emailTemplates; 
        
    public Boolean showSuccess{get;set;}
    public Boolean isError{get;set;}
    public String toastTitle{get;set;}
    public String toastMessage{get;set;}

    public Boolean goBack{get;set;}
    
        
    public SendLeadEmailController(){
        
    }
    
    public SendLeadEmailController(Id templateId,Id owdEmailId,List<Lead> leads){
        this.templateId=templateId;
        this.owdEmailId=owdEmailId;
        this.leads=leads;
    }
    
    public SendLeadEmailController(ApexPages.StandardSetController cntlr){
        goBack = false;
        leads = cntlr.getSelected(); //get selected records from leas list view
        if(leads.size()>0){
            showSuccess=false;
            isError=false; 
            leadNames='';
            Set<Id> leadIds = (new Map<Id,SObject>(leads)).keySet();
            leads=[Select name,email from Lead where id in :leadIds AND email != null WITH USER_MODE];
            if(Leads != null && !Leads.isEmpty() ){
                Integer count = 1;
                for(Lead lead : leads ){
                    leadNames+=lead.name;
                    if(count != leads.size()){
                        leadNames+= ', ';
                    }
                    count ++;
                }
            }else{
                isError=true;
                showSuccess=true;
                goBack = false;
                toastTitle='No Leads selected!';
                toastMessage='Please select atleast one Lead(with email) to trigger email';
            }
        }else{
            isError=true;
            showSuccess=true;
            goBack = false;
            toastTitle='No Leads selected!';
            toastMessage='Please select atleast one Lead(with email) to trigger email';
        }
        
    }
    
    public void sendEmail() {
        try{
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {};
                if(templateId == null || (templateId != null && templateId.length()==0)){
                    goBack = true;
                    isError=true;
                    showSuccess=true;
                    toastTitle='Template is required';
                    toastMessage='Please select template to trigger email';
                }else if(owdEmailId == null || (owdEmailId != null && owdEmailId.length()==0)){
                    goBack = true;
                    isError=true;
                    showSuccess=true;
                    toastTitle='From Email is required';
                    toastMessage='Please select from email to trigger email';
                } else{
                    for(Lead lead: leads){
                        if(String.isNotBlank(lead.email)){
                            Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
                            message.setOrgWideEmailAddressId(owdEmailId);
                            message.setTargetObjectId(lead.id); 
                            message.setTemplateId(templateId);
                            message.setSaveAsActivity(false);
                            messages.add(message);
                        }
                    }
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    showSuccess=true;
                    goBack = false;
                    toastTitle='Success';
                    toastMessage='Successfully triggered mail for selected leads.';
                }
        }Catch(Exception ex){
            System.debug('Exception while triggering mail - '+ex);
            goBack = true;
            isError = true;
            showSuccess=true;
            toastTitle='Something went wrong!';
            toastMessage=ex.getMessage();
        }
    }

    public void goBackAction() {
        showSuccess = false;
        isError = false;
    }
    
    
    public List<SelectOption> getLeadTemplates(){
        
        List<SelectOption> templateList = new List<SelectOption>();
        emailTemplates=new Map<String,EmailTemplate>();
        templateList.add(new SelectOption('','--Select here--'));
        for( EmailTemplate emailTemplate :[SELECT Id, Name, TemplateStyle, IsActive, Description, Subject, Body,HtmlValue FROM EmailTemplate where Folder.Name ='Lead List Email Templates' and IsActive=true WITH USER_MODE]){
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