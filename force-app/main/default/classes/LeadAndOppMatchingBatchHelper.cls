public with sharing class LeadAndOppMatchingBatchHelper {

    public static Property_SalesAI_Settings__c getCustomSettingOrgDefaultRecord() {
        // Fetch the default org-level value for the custom setting
        Property_SalesAI_Settings__c defaultSetting = Property_SalesAI_Settings__c.getOrgDefaults();
        return defaultSetting;
    }

    public static List<String> getListFromCommaSeparatedList(String commaseparatedString) {
        List<String> splitList = commaseparatedString != null ? commaseparatedString.split(',') : new List<String>();
        List<String> trimmedList = new List<String>();
        for (String each : splitList) {
            trimmedList.add(each.trim());
        }
        return trimmedList;
    }

    public static Map<String, List<Lead>> getMapBySimilarityKey(List<Lead> leadList) {
        Map<String, List<Lead>> mapByKey = new Map<String, List<Lead>>();
        for (Lead each : leadList) {
            if (mapByKey.containsKey(each.Similarity_Key__c)) {
                List<Lead> currentlst = mapByKey.get(each.Similarity_Key__c);
                currentlst.add(each);
                mapByKey.put(each.Similarity_Key__c, currentlst);
            } else {
                List<Lead> currentlst = new List<Lead>();
                currentlst.add(each);
                mapByKey.put(each.Similarity_Key__c, currentlst);
            }
        }
        return mapByKey;
    }

    public static Map<String, List<Opportunity>> getMapBySimilarityKey(List<Opportunity> oppList) {
        Map<String, List<Opportunity>> mapByKey = new Map<String, List<Opportunity>>();
        for (Opportunity each : oppList) {
            if (mapByKey.containsKey(each.Similarity_Key__c)) {
                List<Opportunity> currentlst = mapByKey.get(each.Similarity_Key__c);
                currentlst.add(each);
                mapByKey.put(each.Similarity_Key__c, currentlst);
            } else {
                List<Opportunity> currentlst = new List<Opportunity>();
                currentlst.add(each);
                mapByKey.put(each.Similarity_Key__c, currentlst);
            }
        }
        return mapByKey;
    }

    public static List<Lead> getMatchingLeads(
        List<String> keys,
        List<String> recordTypeIds,
        List<String> stagesOrStatuses,
        Integer duration
    ) {
        // Check object-level read access for Lead
        if (Schema.sObjectType.Lead.isAccessible()) {
            List<Lead> leads;
            if (duration != null && duration != -1) {
                DateTime createdDateFilter = DateTime.now().addDays(-1 * duration);
                leads = [SELECT Id, Similarity_Key__c, Status FROM Lead WHERE 
                    Similarity_Key__c IN :keys 
                    AND RecordTypeId IN :recordTypeIds
                    AND Status IN :stagesOrStatuses
                    AND LastModifiedDate >= :createdDateFilter];
            } else {
                leads = [SELECT Id, Similarity_Key__c, Status FROM Lead WHERE 
                Similarity_Key__c IN :keys 
                AND RecordTypeId IN :recordTypeIds
                AND Status IN :stagesOrStatuses];
            }
            leads = (List<Lead>) Security.stripInaccessible(AccessType.READABLE, leads).getRecords();
            return leads;
        } else {
            BatchJobException ex = new BatchJobException('Insufficient access rights on Lead object.');
            throw ex;
        }
    }
    
    
    public static List<Opportunity> getMatchingOpps(
        List<String> keys,
        List<String> recordTypeIds,
        List<String> stagesOrStatuses,
        Integer duration
    ) {
        // Check object-level read access for Opportunity
        if (Schema.sObjectType.Opportunity.isAccessible()) {
            List<Opportunity> opps;
            if (duration != null && duration != -1) {
                DateTime createdDateFilter = DateTime.now().addDays(-1 * duration);
                opps = [SELECT Id, Similarity_Key__c, Last_Offer_Made__c, StageName FROM Opportunity WHERE 
                    Similarity_Key__c IN :keys 
                    AND RecordTypeId IN :recordTypeIds
                    AND StageName IN :stagesOrStatuses
                    AND LastModifiedDate >= :createdDateFilter];
            } else {
                opps = [SELECT Id, Similarity_Key__c, Last_Offer_Made__c, StageName FROM Opportunity WHERE 
                Similarity_Key__c IN :keys 
                AND RecordTypeId IN :recordTypeIds
                AND StageName IN :stagesOrStatuses];
            }
            opps = (List<Opportunity>) Security.stripInaccessible(AccessType.READABLE, opps).getRecords();
            return opps;
        } else {
            BatchJobException ex = new BatchJobException('Insufficient access rights on Opportunity object.');
            throw ex;
        }        
    }    
    
    public static List<String> getSimilarityKeys(List<Property_SalesAI__c> customObjects) {
        List<String> keys = new List<String>();
        for (Property_SalesAI__c sp : customObjects) {
            keys.add(sp.Similarity_Key__c);
        }
        return keys;
    }
    // converts Database.Error[] to List<String>
    public static List<String> getErrorMessagesFromSaveResult(Database.Error[] errors) {
        List<String> errorMessages = new List<String>();
        for (Database.Error error : errors) {
            errorMessages.add(error.getMessage());
        }
        return errorMessages;
    }

    public Static String getCurrentUserEmail() {
        User currentUser;
        if (Schema.sObjectType.User.isAccessible()) {
            Id scheduledById = UserInfo.getUserId();
            List<User> users = [SELECT Id, Email FROM User WHERE Id = :scheduledById];
            users = Security.stripInaccessible(AccessType.READABLE, users).getRecords();
            if (!users.isEmpty()) {
                currentUser = users[0];
            }
            return currentUser.Email;
        } else {
            throw new BatchJobException('Cannot get User Email');
        }
    }

    public static Id getOrgWideEmailAddress(){
        Id emailAddressId;
        if (Schema.sObjectType.OrgWideEmailAddress.isAccessible()) {
            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'support@leftmainrei.com'];
            if (owea.size() > 0 ) {
                emailAddressId = owea.get(0).Id;
            }    
        }
        return emailAddressId;
    }

    public static void sendBatchCompletionEmail(
        Integer matchedLeads, 
        Integer matchedOpportunities, 
        String leadErrors, 
        String opportunityErrors, 
        Boolean setupComplete) {
    
        String userEmail = getCurrentUserEmail();
        Id emailId = getOrgWideEmailAddress();
        // Prepare the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] {userEmail});
        if(emailId != null) {
            email.setOrgWideEmailAddressId(emailId);
        } 
        // Scenario 1: If setup is not complete
        if (!setupComplete) {
            email.setSubject('Property Sales AI not fully setup.');
            email.setPlainTextBody(
                'The Property Sales AI matching algorithm could not successfully execute. ' +
                'There are some required configuration settings that need to be updated. ' +
                'In order to complete the setup, please login to the Left Main application and go to the Property Sales AI Setup tab. ' +
                'Please make sure all required fields are properly configured.\n\n' +
                'If you need any assistance, please reach out to Left Main REI support at support@leftmainrei.com.\n\n' +
                'Thank you,\n' +
                'Left Main REI'
            );
        } else { // Scenario 2: If batch job completes successfully
            String emailBody = 'The Property Sales AI matching algorithm completed execution at ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss') + '.\n\n' +
                                'Please see the following results:\n\n' +
                                'Matched Leads: ' + matchedLeads + '\n' +
                                'Matched Opportunities: ' + matchedOpportunities + '\n\n';
            
            // If there are errors, include them in the email body
            if (!String.isBlank(leadErrors) || !String.isBlank(opportunityErrors)) {
                emailBody += 'Property Sales AI ran into some errors. Please see the details below:\n\n';
                
                if (!String.isBlank(leadErrors)) {
                    emailBody += 'Lead Errors:\n' + leadErrors  + '\n';
                }
                
                if (!String.isBlank(opportunityErrors)) {
                    emailBody += 'Opportunity Errors:\n' + opportunityErrors + '\n';
                }
            }
            
            emailBody += '\nIf you need help resolving the errors, please reach out to Left Main REI support at support@leftmainrei.com.\n\n' +
                            'Thank you,\n' +
                            'Left Main REI';
                            
            email.setSubject('Property Sales AI matching algorithm summary');
            email.setPlainTextBody(emailBody);
        }
        // Send the email
        if (!Test.isRunningTest() && Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }

    public static Set<Id> getCurrentBatchLeadIds(Map<String, List<Lead>> leadMapByKey) {
        Set<Id> currentBatchLeadIds = new Set<Id>();
        for (List<Lead> leads : leadMapByKey.values()) {
            for (Lead ld : leads) {
                currentBatchLeadIds.add(ld.Id);
            }
        }    
        return currentBatchLeadIds;
    }

    public static Set<Id> getCurrentBatchOppIds(Map<String, List<Opportunity>> oppMapByKey) {
        Set<Id> currentBatchOppIds = new Set<Id>();
        for (List<Opportunity> opps : oppMapByKey.values()) {
            for (Opportunity opp : opps) {
                currentBatchOppIds.add(opp.Id);
            }
        }
        return currentBatchOppIds;
    }

    public static Set<Id> getCurrentBatchPropertyIds(List<Property_SalesAI__c> properties) { 
        Set<Id> currentBatchPropertyIds = new Set<Id>();
        for (Property_SalesAI__c prop : properties) {
            currentBatchPropertyIds.add(prop.Id);
        }
        return currentBatchPropertyIds;
    }

    public class BatchJobException extends Exception {}

}