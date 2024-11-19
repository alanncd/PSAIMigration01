public with sharing class PropertySalesAIMatchTriggerHandler {
    
    public static void updateLeadsAndOppsRollBack(List<Property_SalesAI_Match__c> newList, Map<Id, Property_SalesAI_Match__c> oldMap) {
        // Collect all Lead and Opportunity IDs to query
        Set<Id> leadIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();

        for (Property_SalesAI_Match__c match : newList) {
            Property_SalesAI_Match__c oldMatch = oldMap.get(match.Id);

            // Check if Status changed from Confirmed to Rejected
            if (oldMatch.Status__c == 'Confirmed' && match.Status__c == 'Rejected') {
                if (match.Lead__c != null) {
                    leadIds.add(match.Lead__c);
                } else if (match.Opportunity__c != null) {
                    oppIds.add(match.Opportunity__c);
                }
            }
        }

        // Query related Leads
        Map<Id, Lead> leadMap = new Map<Id, Lead>([
            SELECT Id, Status, Match_Found_Previous_Status__c FROM Lead WHERE Id IN :leadIds WITH SECURITY_ENFORCED
        ]);

        // Query related Opportunities
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
            SELECT Id, StageName,Match_Found_Previous_Stage__c FROM Opportunity WHERE Id IN :oppIds WITH SECURITY_ENFORCED
        ]);

        // Prepare lists for bulk updates
        List<Lead> leadsToUpdate = new List<Lead>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Task> tasksToInsert = new List<Task>();
        String userName = UserInfo.getName();
        Id userId = UserInfo.getUserId();

        // Loop through the records again to update Leads and Opportunities
        for (Property_SalesAI_Match__c match : newList) {
            Property_SalesAI_Match__c oldMatch = oldMap.get(match.Id);
            
            if (oldMatch.Status__c == 'Confirmed' && match.Status__c == 'Rejected') {
                String subject = 'Updated by Property Sales.AI - Confirmed to Rejected';
                String descr = ' when ' + userName + ' rejected previously confirmed match found between';

                if (match.Lead__c != null && leadMap.containsKey(match.Lead__c)) {
                    // Update the related Lead's status
                    Lead ld = leadMap.get(match.Lead__c);
                    String oldStatus = ld.status;
                    ld.Status = ld.Match_Found_Previous_Status__c;
                    Task newTask = new Task();
                    newTask.OwnerId = userId;
                    newTask.Subject = 'Lead ' + subject;
                    newTask.Description = 'Status updated from ' + oldStatus + ' to ' + ld.Status + descr + ' Lead record address and Property Sales record address.';
                    newTask.WhoId = ld.Id;
                    newTask.status = 'Completed';

                    leadsToUpdate.add(ld);
                    tasksToInsert.add(newTask);
                    
                } else if (match.Opportunity__c != null && oppMap.containsKey(match.Opportunity__c)) {
                    // Update the related Opportunity's stage
                    Opportunity opp = oppMap.get(match.Opportunity__c);
                    String oldStage = opp.StageName;
                    opp.StageName = opp.Match_Found_Previous_Stage__c;
                    Task newTask = new Task();
                    newTask.OwnerId = userId;
                    newTask.Subject = 'Opportunity ' + subject;
                    newTask.Description = 'Stage updated from ' + oldStage + ' to ' + opp.StageName  + descr + ' Opportunity record address and Property Sales record address.';
                    newTask.WhatId = opp.Id;
                    newTask.status = 'Completed';

                    tasksToInsert.add(newTask);
                    oppsToUpdate.add(opp);
                }
            }
        }
        // Perform bulk updates
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }

    }

    public static void updateLeadsAndOppsConfirm(List<Property_SalesAI_Match__c> newList, Map<Id, Property_SalesAI_Match__c> oldMap) {
        Property_SalesAI_Settings__c customSettings = LeadAndOppMatchingBatchHelper.getCustomSettingOrgDefaultRecord();
        String oppStageSold = customSettings.Matched_Opportunity_Stage__c;
        String oppReason = customSettings.Matched_Opportunity_Reason__c;
        String oppReasonField = customSettings.Matched_Opportunity_Reason_Field__c;
        String leadReason = customSettings.Matched_Lead_Reason__c;
        String leadStatusSold = customSettings.Matched_Lead_Status__c;
        String leadReasonField = customSettings.Matched_Lead_Reason_Field__c;

        Boolean isInsert = oldMap == null;
        // Collect all Lead and Opportunity IDs to query
        Set<Id> leadIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();

        for (Property_SalesAI_Match__c match : newList) {
            Property_SalesAI_Match__c oldMatch = isInsert ? null : oldMap.get(match.Id);

            // Check if Status changed from Confirmed to Rejected
            if ((!isInsert && match.Status__c != oldMatch.Status__c && match.Status__c == 'Confirmed') ||
                (isInsert && match.Status__c == 'Confirmed')) {
                if (match.Lead__c != null) {
                    leadIds.add(match.Lead__c);
                } else if (match.Opportunity__c != null) {
                    oppIds.add(match.Opportunity__c);
                }
            }
        }

        // Query related Leads
        Map<Id, Lead> leadMap = new Map<Id, Lead>([
            SELECT Id, Status FROM Lead WHERE Id IN :leadIds WITH SECURITY_ENFORCED
        ]);

        // Query related Opportunities
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
            SELECT Id, StageName FROM Opportunity WHERE Id IN :oppIds WITH SECURITY_ENFORCED
        ]);

        // Prepare lists for bulk updates
        List<Lead> leadsToUpdate = new List<Lead>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Task> tasksToInsert = new List<Task>();
        String userName = UserInfo.getName();
        Id userId = UserInfo.getUserId();

        // Loop through the records again to update Leads and Opportunities
        for (Property_SalesAI_Match__c match : newList) {
            Property_SalesAI_Match__c oldMatch = isInsert ? null : oldMap.get(match.Id);
            
            if ((!isInsert && match.Status__c != oldMatch.Status__c && match.Status__c == 'Confirmed') ||
                (isInsert && match.Status__c == 'Confirmed')) {
                String subject = isInsert ? 
                    'Updated by Property Sales.AI Automation' : 
                    'Updated by Property Sales.AI - Confirmed';
                String descr = isInsert ? 
                    ' by an automated process within the Property Sales.AI app.' : 
                    ' when ' + userName  + ' confirmed potential match found between';
                if (match.Lead__c != null && leadMap.containsKey(match.Lead__c)) {
                    // Update the related Lead's status
                    Lead ld = leadMap.get(match.Lead__c);
                    String oldStatus = ld.Status;
                    ld.Status = leadStatusSold; // Update status to "Sold"
                    if (leadReasonField != null && !String.isBlank(leadReasonField)) {
                        ld.put(leadReasonField, leadReason); 
                    }        
                    Task newTask = new Task();
                    newTask.OwnerId = userId;
                    newTask.Subject = 'Status ' + subject;
                    String descriptionFinal = isInsert ? 
                        'Status updated from ' + oldStatus + ' to ' + ld.Status + descr :
                        'Status updated from ' + oldStatus + ' to ' + ld.Status + descr + ' Lead record address and Property Sales record address.';
                    newTask.Description = descriptionFinal;
                    newTask.WhoId = ld.Id;
                    newTask.status = 'Completed';

                    tasksToInsert.add(newTask);
                    leadsToUpdate.add(ld);
                    
                } else if (match.Opportunity__c != null && oppMap.containsKey(match.Opportunity__c)) {
                    // Update the related Opportunity's stage
                    Opportunity opp = oppMap.get(match.Opportunity__c);
                    String oldStage = opp.StageName;
                    opp.StageName = oppStageSold; // Update stage
                    if (oppReasonField != null && !String.isBlank(oppReasonField)) {
                        opp.put(oppReasonField, oppReason);
                    }    
                    //Create a task related  to the Opp
                    Task newTask = new Task();
                    newTask.OwnerId = userId;
                    newTask.Subject = 'Stage ' + subject;
                    String descriptionFinal = isInsert ? 
                        'Stage updated from ' + oldStage + ' to ' + opp.StageName + descr :
                        'Stage updated from ' + oldStage + ' to ' + opp.StageName + descr + ' Opportunity record address and Property Sales record address.';
                    newTask.Description = descriptionFinal;
                    newTask.WhatId = opp.Id;
                    newTask.status = 'Completed';
                    
                    tasksToInsert.add(newTask);
                    oppsToUpdate.add(opp);
                }
            }
        }
        // Perform bulk updates
        if (!isInsert && !leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
        if (!isInsert && !oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}