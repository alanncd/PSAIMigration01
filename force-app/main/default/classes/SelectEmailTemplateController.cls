public with sharing class SelectEmailTemplateController {
    
    @AuraEnabled
    public static List<selectWrapper> getLeadTemplates(String recId){
        try{
            String templateId = '';
            List<selectWrapper> templateList = new List<selectWrapper>();
            templateList.add(new selectWrapper('','--Select here--',false));
            List<Lead_Follow_Up_Sequence__c> leadSequenceList = [SELECT Id,Email_Template_Id__c FROM Lead_Follow_Up_Sequence__c
                                                                            WHERE Id =:recId WITH USER_MODE LIMIT 1];
            if(!leadSequenceList.isEmpty()){
                if(String.isNotBlank(leadSequenceList[0].Email_Template_Id__c)){
                    templateId = leadSequenceList[0].Email_Template_Id__c;
                } 
                for( EmailTemplate emailTemplate :[SELECT Id, Name, TemplateStyle, IsActive, Description, 
                                                    Subject, Body,HtmlValue FROM
                                                    EmailTemplate WHERE Folder.DeveloperName ='Left_Main_Lead_Follow_Up'
                                                    AND IsActive=true AND (NOT Name  LIKE '%same%') WITH USER_MODE ORDER BY Name]){
                    if(String.isNotBlank(templateId) && templateId == emailTemplate.Id){
                        templateList.add(new selectWrapper(emailTemplate.Id,emailTemplate.Name,true));
                    }else{
                        templateList.add(new selectWrapper(emailTemplate.Id,emailTemplate.Name,false));
                    }
                }
            }
            return templateList;   
        }catch(Exception ex){
            AuraHandledException exceptionMessage = new AuraHandledException(ex.getMessage());
            exceptionMessage.setMessage(ex.getMessage());
            throw exceptionMessage;
        }
        
    }
    
    @AuraEnabled
    public static void saveLeadTemplates(String recId,String templateId,String templateName){
        try{
            // Check if the user has permission to update the object and fields

         

            List<Lead_Follow_Up_Sequence__c> leadSequenceList = [SELECT Id,Email_Template_Id__c,
                                                    Email_Template_Name__c
                                                    FROM Lead_Follow_Up_Sequence__c WHERE Id =:recId WITH USER_MODE LIMIT 1];
            List<Lead_Follow_Up_Sequence__c> upsertList = new List<Lead_Follow_Up_Sequence__c>();
            if(!leadSequenceList.isEmpty()){
                leadSequenceList[0].Email_Template_Id__c = templateId;
                leadSequenceList[0].Email_Template_Name__c = templateName;
                upsertList.add(leadSequenceList[0]); 
            }
            if(!upsertList.isEmpty()){
                 // Filtrar registros que tienen acceso de creación

                 if (Schema.sObjectType.Lead_Follow_Up_Sequence__c.isCreateable() ||                 Schema.sObjectType.Lead_Follow_Up_Sequence__c.fields.Email_Template_Id__c.isCreateable() ||                Schema.sObjectType.Lead_Follow_Up_Sequence__c.fields.Email_Template_Name__c.isCreateable() ||                  Schema.sObjectType.Lead_Follow_Up_Sequence__c.isUpdateable() ||                Schema.sObjectType.Lead_Follow_Up_Sequence__c.fields.Email_Template_Id__c.isUpdateable() ||                Schema.sObjectType.Lead_Follow_Up_Sequence__c.fields.Email_Template_Name__c.isUpdateable() ) { 
                  // Filter records with CREATABLE access
                  SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, upsertList);

                  //Filter records with UPDATABLE access
                  SObjectAccessDecision decisiontwo = Security.stripInaccessible(AccessType.UPDATABLE, decision.getRecords());
          
                  //Schema.SObjectField f = DirectOneTemplate__c.Fields.Id;
                  // upsert in records foltered by an external key
                  upsertList = decisiontwo.getRecords();
                  Database.upsert(upsertList );
                    }
     
               

                  

            }
        }catch(Exception ex){
            AuraHandledException exceptionMessage = new AuraHandledException(ex.getMessage());
            exceptionMessage.setMessage(ex.getMessage());
            throw exceptionMessage;
        }
    }
    
    
    public class selectWrapper{
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public Boolean selected {get; set;}
        public selectWrapper(String id ,String label ,Boolean selected){
            this.id= id;
            this.label = label;
            this.selected = selected;
        }
    }
}