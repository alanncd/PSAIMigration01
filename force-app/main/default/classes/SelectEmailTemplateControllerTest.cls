@isTest
public class SelectEmailTemplateControllerTest {
    
    static testMethod void getLeadTemplatesTest(){
        LeadFollowUpService.createLeadFollowUpRecords();
        List<Lead_Follow_Up_Sequence__c> leadSequenceList = [SELECT Id,Email_Template_Id__c FROM Lead_Follow_Up_Sequence__c
                                                                         LIMIT 1];
        if(!leadSequenceList.isEmpty()){
            SelectEmailTemplateController.getLeadTemplates(leadSequenceList[0].Id);
            system.assertNotEquals(null, SelectEmailTemplateController.getLeadTemplates(leadSequenceList[0].Id)[0].label);
            
        }
    }
    
    static testMethod void SaveLeadTemplatesTest(){
        LeadFollowUpService.createLeadFollowUpRecords();
        List<Lead_Follow_Up_Sequence__c> leadSequenceList = [SELECT Id,Email_Template_Id__c,Email_Template_Name__c FROM Lead_Follow_Up_Sequence__c
                                                                         LIMIT 1];
        if(!leadSequenceList.isEmpty()){
            SelectEmailTemplateController.saveLeadTemplates(leadSequenceList[0].Id,leadSequenceList[0].Email_Template_Id__c,leadSequenceList[0].Email_Template_Name__c);
            List<Lead_Follow_Up_Sequence__c> lll = [SELECT Id,Email_Template_Id__c,
                                                    Email_Template_Name__c
                                                    FROM Lead_Follow_Up_Sequence__c LIMIT 1];            
            system.assertEquals(1, lll.size());
        }
    }
}