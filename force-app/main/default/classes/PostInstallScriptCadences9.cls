global without sharing class PostInstallScriptCadences9 implements InstallHandler {
  global void onInstall (InstallContext context)
    {
        Id recordTypeId = Schema.SObjectType.LMR_TemplateSms__c.getRecordTypeInfosByDeveloperName().get('Cadence').getRecordTypeId();
        List<LMR_TemplateSms__c> listTemplates = [SELECT Id, Folder__c, Body__c, Object__c, RecordTypeId, Name FROM LMR_TemplateSms__c limit 10000];

        for(LMR_TemplateSms__c template: listTemplates){
    
            if(String.isNotBlank(template.Body__c) && template.Body__c.containsIgnoreCase('Lead') )  {
                
            template.Object__c = 'Lead';
            }else if(String.isNotBlank(template.Body__c) && template.Body__c.containsIgnoreCase('Opportunity') ){
    
            template.Object__c = 'Opportunity';
    
            }else if(String.isNotBlank(template.Body__c) && template.Body__c.containsIgnoreCase('Contact')){
            template.Object__c = 'Contact';
            }
            
            template.recordTypeId= recordTypeId;
        }

        LeftMain_SecurityUtils.checkUpdate(LMR_TemplateSms__c.SObjectType,new List<String> {'Object__c','recordTypeId'});

        SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.UPDATABLE, listTemplates);
        Database.update(listTemplates = decision3.getRecords());
        


        List<Opportunity> listOpp = [SELECT Id, Account.PersonEmail, Account.Mobile__c, Email__c, MobilePhone__c FROM Opportunity WHERE (Account.Mobile__c != null OR Account.PersonEmail != null) AND (Email__c = null OR MobilePhone__c = Null) LIMIT 9600];

        for(Opportunity opp : listOpp) {
            if(opp.Account.PersonEmail != null && opp.Email__c == null) {
                opp.Email__c = opp.Account.PersonEmail;
            }
            if(opp.Account.Mobile__c != null && opp.MobilePhone__c == null) {
                opp.MobilePhone__c = opp.Account.Mobile__c;
            }
        }

        LeftMain_SecurityUtils.checkUpdate(Opportunity.SObjectType,new List<String> {'Email__c','MobilePhone__c'});

            SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.UPDATABLE, listOpp);
            Database.update(listOpp = decision2.getRecords());
            
    }
    
}