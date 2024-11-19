public with sharing class LeadAndOppMatchingBatch implements Database.Batchable<SObject>, Database.Stateful {

    Integer numberOfMatchedLeads;
    Integer numberOfMatchedOpps;
    public Property_SalesAI_History__c newRecord;
    Property_SalesAI_Settings__c customSettings;
    List<String> leadRecordTypeIds;
    List<String> leadStatusesToInclude;
    Integer leadDuration;
    String leadStatusSold;
    List<String> oppRecordTypeIds;
    List<String> oppStagesToInclude;
    Integer oppDuration;
    String oppStageSold;
    String leadReason;
    String leadReasonField;
    String oppReason;
    String oppReasonField;
    Boolean automaticUpdate = true;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Get all Property_SalesAI__c records to be matched against leads-opps 
        this.newRecord = new Property_SalesAI_History__c();
        this.newRecord.Start_Time__c = DateTime.now();
        this.newRecord.Status__c = 'Processing';
        this.newRecord.Name = 'Execution ' + DateTime.now();
        numberOfMatchedLeads = 0;
        numberOfMatchedOpps = 0;
         // Get custom settings and put it in static variable
        customSettings = LeadAndOppMatchingBatchHelper.getCustomSettingOrgDefaultRecord();
        String query;
        if (customSettings != null && customSettings.IsSetupComplete__c) {
            DateTime soldPropertyFilter = DateTime.now().addDays(-1 * Integer.ValueOf(customSettings.Property_Sales_History_Duration__c));
            query = 'SELECT Id, Name, Similarity_Key__c, Property_Address__c FROM Property_SalesAI__c WHERE Similarity_Key__c != null'  + 
            (soldPropertyFilter != null && Integer.ValueOf(customSettings.Property_Sales_History_Duration__c) != -1 ?
                ' AND CreatedDate >= :soldPropertyFilter' : '') +
            ' ORDER BY CreatedDate DESC';
            populateCustomSettings();
        } else {
            query = 'SELECT Id, Similarity_Key__c FROM Property_SalesAI__c WHERE Id = null';
            this.newRecord.Status__c = 'Finished With Errors';
        }
        insert this.newRecord;    
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Property_SalesAI__c> customObjects) {
        // Populate user custom setting variables
        List<String> keys = LeadAndOppMatchingBatchHelper.getSimilarityKeys(customObjects);

        // Query Leads that match Key in Property_SalesAI__c
        Map<String, List<Lead>> leadMapByKey = getMatchingLeads(keys);
        Map<String, List<Opportunity>> oppMapByKey = getMatchingOpportunities(keys);

        //Collect current batch Lead and Opportunity IDs
        Set<Id> currentBatchLeadIds = LeadAndOppMatchingBatchHelper.getCurrentBatchLeadIds(leadMapByKey);
        Set<Id> currentBatchOppIds = LeadAndOppMatchingBatchHelper.getCurrentBatchOppIds(oppMapByKey);
        Set<Id> currentBatchPropertyIds = LeadAndOppMatchingBatchHelper.getCurrentBatchPropertyIds(customObjects);

        Set<Id> leadIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();

        //Retrieve matches related to this batch execution (to prevent 2 sold properties to be related to one lead/opp)
        for (Property_SalesAI_Match__c match : [
            SELECT Lead__c, Opportunity__c 
            FROM Property_SalesAI_Match__c 
            WHERE Property_SalesAI_History__c = :newRecord.Id 
            AND (Lead__c IN :currentBatchLeadIds OR Opportunity__c IN :currentBatchOppIds)
            WITH SECURITY_ENFORCED
        ]) {
            if (match.Lead__c != null) {
                leadIds.add(match.Lead__c);
            }
            if (match.Opportunity__c != null) {
                oppIds.add(match.Opportunity__c);
            }
        }

        Set<String> pendingOrRejectedLeadIds = new Set<String>();
        Set<String> pendingOrRejectedOppIds = new Set<String>();

        for (Property_SalesAI_Match__c match : [
            SELECT Lead__c, Opportunity__c, Property_SalesAI__c
            FROM Property_SalesAI_Match__c 
            WHERE (Status__c = 'Pending' OR Status__c = 'Rejected')
            AND Property_SalesAI__c IN :currentBatchPropertyIds
            AND (Lead__c IN :currentBatchLeadIds OR Opportunity__c IN :currentBatchOppIds)
            WITH SECURITY_ENFORCED
        ]) {
            String key = match.Property_SalesAI__c;
            if (match.Lead__c != null) {
                pendingOrRejectedLeadIds.add(key + match.Lead__c);
            }
            if (match.Opportunity__c != null) {
                pendingOrRejectedOppIds.add(key + match.Opportunity__c);
            }
        }

        //Matching LOGIC
        Map<Id, Property_SalesAI_Match__c> recordsToInsertMap = new Map<Id, Property_SalesAI_Match__c>();
        Map<Id, Lead> leadsToUpdateMap = new Map<Id, Lead>();
        Map<Id, Opportunity> oppsToUpdateMap = new Map<Id, Opportunity>();

        for (Property_SalesAI__c sp : customObjects) {
            // Matching Leads
            if (leadMapByKey.containsKey(sp.Similarity_Key__c)) {
                List<Lead> leads = leadMapByKey.get(sp.Similarity_Key__c);
                for(Lead ld: leads) {
                    String combinedId = String.valueOf(sp.id) + String.valueOf(ld.Id);
                    //IF lead wasn't match during other batch or during this batch and there is no match already created by another execution
                    if (!leadIds.contains(ld.Id) && !recordsToInsertMap.containsKey(ld.Id) && !pendingOrRejectedLeadIds.contains(combinedId)) {
                        Property_SalesAI_Match__c mr = new Property_SalesAI_Match__c();
                        mr.Lead__c = ld.Id; 
                        mr.Property_SalesAI__c = sp.Id; 
                        mr.Property_SalesAI_History__c = this.newRecord.Id;
                        mr.Status__c = 'Pending';
                        mr.Type__c = 'Lead Match';
                        ld.Match_Found_Previous_Status__c = ld.Status;    
                        
                        if (automaticUpdate) {
                            mr.Status__c = 'Confirmed';
                            ld.Status = leadStatusSold; // Update status to "Sold"
                            if (!String.isBlank(leadReasonField)) {
                                ld.put(leadReasonField, leadReason); 
                            }        
                        }     
                        leadsToUpdateMap.put(ld.Id, ld);
                        recordsToInsertMap.put(ld.Id, mr);
                    }
                }
            }
            // Matching Opportunities
            if (oppMapByKey.containsKey(sp.Similarity_Key__c)) {
                List<Opportunity> opps = oppMapByKey.get(sp.Similarity_Key__c);
                for(Opportunity opp : opps) {
                    String combinedId = String.valueOf(sp.id) + String.valueOf(opp.Id);
                    if (!oppIds.contains(opp.Id) && !recordsToInsertMap.containsKey(opp.Id) && !pendingOrRejectedOppIds.contains(combinedId)) {
                        Property_SalesAI_Match__c mr = new Property_SalesAI_Match__c();
                        mr.Opportunity__c = opp.Id;
                        mr.Property_SalesAI__c = sp.Id;
                        mr.Property_SalesAI_History__c = this.newRecord.Id;
                        mr.Status__c = 'Pending';
                        mr.Type__c = 'Opportunity Match';  
                        opp.Match_Found_Previous_Stage__c = opp.StageName;
    
                        if (automaticUpdate) {
                            mr.Status__c = 'Confirmed';
                            opp.StageName = oppStageSold; // Update stage
                            if (!String.isBlank(oppReasonField)) {
                                opp.put(oppReasonField, oppReason);
                            }    
                        } 
                        if (opp.Left_Main__Last_Offer_Made__c == null) {
                            opp.Left_Main__Last_Offer_Made__c = 0;
                        }
    
                        oppsToUpdateMap.put(opp.Id, opp);
                        recordsToInsertMap.put(opp.Id, mr);
                    }
                }
            }
        }
        performDMLs(leadsToUpdateMap, oppsToUpdateMap, recordsToInsertMap);      
    }

    public void finish(Database.BatchableContext bc) {
        this.newRecord.Finish_Time__c = DateTime.now();
        String leadErrors = this.newRecord.Lead_Errors__c;
        String opportunityErrors = this.newRecord.Opportunity_Errors__c;
        if (!String.isBlank(this.newRecord.Lead_Errors__c)) {
            this.newRecord.Lead_Errors__c = this.newRecord.Lead_Errors__c.abbreviate(131072);
        }
        if (!String.isBlank(this.newRecord.Opportunity_Errors__c)) {
            this.newRecord.Opportunity_Errors__c = this.newRecord.Opportunity_Errors__c.abbreviate(131072);
        }
        if(!String.isBlank(this.newRecord.Property_SalesAI_Errors__c)) {
            this.newRecord.Property_SalesAI_Errors__c = this.newRecord.Property_SalesAI_Errors__c.abbreviate(131072);
        }
        if (this.newRecord.Status__c != 'Finished With Errors'){
            this.newRecord.Status__c = 'Finished Successfully';
        }
        update this.newRecord;

        try {
            LeadAndOppMatchingBatchHelper.sendBatchCompletionEmail(
                this.numberOfMatchedLeads, this.numberOfMatchedOpps, leadErrors, opportunityErrors, customSettings.IsSetupComplete__c);
        } catch (Exception e) {
            this.newRecord.Property_SalesAI_Errors__c = 'Error sending email ' + e.getMessage() + '\n' + e.getStackTraceString() + '\n' + this.newRecord.Property_SalesAI_Errors__c;
            this.newRecord.Property_SalesAI_Errors__c = this.newRecord.Property_SalesAI_Errors__c.abbreviate(131072);
            update this.newRecord;
        }
    }

    private void populateCustomSettings() {
        //LEAD SETTINGS
        leadRecordTypeIds = LeadAndOppMatchingBatchHelper.getListFromCommaSeparatedList(customSettings.Lead_Record_Types__c);
        String leadStatuses = customSettings.Lead_Status__c;
        leadStatuses += customSettings.Lead_Status_2__c != null ? customSettings.Lead_Status_2__c : '';
        leadStatusesToInclude = LeadAndOppMatchingBatchHelper.getListFromCommaSeparatedList(leadStatuses);
        leadDuration = Integer.valueOf(customSettings.Lead_History_Duration__c);
        leadStatusSold = customSettings.Matched_Lead_Status__c;
        leadReason = customSettings.Matched_Lead_Reason__c;
        leadReasonField = customSettings.Matched_Lead_Reason_Field__c;
        //OPP SETTINGS
        oppRecordTypeIds = LeadAndOppMatchingBatchHelper.getListFromCommaSeparatedList(customSettings.Opportunity_Record_Types__c);
        String oppStages = customSettings.Opportunity_Stage__c;
        oppStages += customSettings.Opportunity_Stage_2__c != null ? customSettings.Opportunity_Stage_2__c : '';
        oppStagesToInclude = LeadAndOppMatchingBatchHelper.getListFromCommaSeparatedList(oppStages);
        oppDuration = Integer.valueOf(customSettings.Opportunity_History_Duration__c);
        oppStageSold = customSettings.Matched_Opportunity_Stage__c;
        oppReason = customSettings.Matched_Opportunity_Reason__c;
        oppReasonField = customSettings.Matched_Opportunity_Reason_Field__c;

        automaticUpdate = customSettings.AutomaticUpdate__c;
    }

    private Map<String, List<Opportunity>> getMatchingOpportunities(List<String> keys) {
        List<Opportunity> oppsToMatch = (List<Opportunity>) LeadAndOppMatchingBatchHelper.getMatchingOpps(
            keys, oppRecordTypeIds, oppStagesToInclude, oppDuration
        );
        return LeadAndOppMatchingBatchHelper.getMapBySimilarityKey(oppsToMatch);
    }

    private Map<String, List<Lead>> getMatchingLeads(List<String> keys) {
        List<Lead> leadsToMatch = (List<Lead>) LeadAndOppMatchingBatchHelper.getMatchingLeads(
            keys, leadRecordTypeIds, leadStatusesToInclude, leadDuration
        );
        return LeadAndOppMatchingBatchHelper.getMapBySimilarityKey(leadsToMatch);
    }

    public void performDMLs(
        Map<Id, Lead> allLeads, 
        Map<Id, Opportunity> allOpps, 
        Map<Id, Property_SalesAI_Match__c> allMatches) {

        List<Lead> leadsToUpdate = new List<Lead>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        //Map<Id, Property_SalesAI_Match__c> succesfullJunctionMap = new Map<Id, Property_SalesAI_Match__c>();
        Map<Id, List<Property_SalesAI_Match__c>> leadIdToJunctionMap = new Map<Id, List<Property_SalesAI_Match__c>>();
        Map<Id, List<Property_SalesAI_Match__c>> oppIdToJunctionMap = new Map<Id, List<Property_SalesAI_Match__c>>();

        // Insert Junction Object
        Database.SaveResult[] junctionSaveResults = Database.insert(allMatches.values(), false);
    
        for (Integer i = 0; i < junctionSaveResults.size(); i++) {
            Property_SalesAI_Match__c match = allMatches.values()[i];
            if (junctionSaveResults[i].isSuccess()) {
                //succesfullJunctionMap.put(allMatches.values()[i].Id, allMatches.values()[i]);
                Id leadOrOppId = !String.isBlank(allMatches.values()[i].Lead__c) ? 
                    allMatches.values()[i].Lead__c : allMatches.values()[i].Opportunity__c;
                if (allLeads.containsKey(leadOrOppId)) {
                    leadsToUpdate.add(allLeads.get(leadOrOppId));
                    if (!leadIdToJunctionMap.containsKey(Id.valueOf(leadOrOppId))) {
                        leadIdToJunctionMap.put(Id.valueOf(leadOrOppId), new List<Property_SalesAI_Match__c>());
                    }
                    leadIdToJunctionMap.get(Id.valueOf(leadOrOppId)).add(match);
                }
                if (allOpps.containsKey(leadOrOppId)) {
                    oppsToUpdate.add(allOpps.get(leadOrOppId));
                    if (!oppIdToJunctionMap.containsKey(leadOrOppId)) {
                        oppIdToJunctionMap.put(leadOrOppId, new List<Property_SalesAI_Match__c>());
                    }
                    oppIdToJunctionMap.get(leadOrOppId).add(match);
                }    
            } else {
                // Store failed junctions and error message, don't proceed with corresponding Lead/Opportunity updates
                logFailedJunction(allMatches.values()[i], LeadAndOppMatchingBatchHelper.getErrorMessagesFromSaveResult(junctionSaveResults[i].getErrors()), true);
            }
        }
        List<Property_SalesAI_Match__c> junctionsToDelete = new List<Property_SalesAI_Match__c>();
        List<Property_SalesAI_Match__c> tempJunctions = new List<Property_SalesAI_Match__c>();
        // Update corresponding Leads and Opportunities
        if (!leadsToUpdate.isEmpty()) {
            Database.SaveResult[] leadUpdateResults = Database.update(leadsToUpdate, false);
            tempJunctions = processLeadResults(leadUpdateResults, leadsToUpdate, leadIdToJunctionMap);
            junctionsToDelete.addAll(tempJunctions);

        }
        if (!oppsToUpdate.isEmpty()) {
            Database.SaveResult[] oppUpdateResults = Database.update(oppsToUpdate, false);
            tempJunctions = processOppResults(oppUpdateResults, oppsToUpdate, oppIdToJunctionMap);
            junctionsToDelete.addAll(tempJunctions);
        }

        // Delete Junctions if needed (due to failure in Lead/Opportunity update)
        if (!junctionsToDelete.isEmpty()) {
            Database.DeleteResult[] junctionDeleteResults = Database.delete(junctionsToDelete, false);
            for (Integer i = 0; i < junctionDeleteResults.size(); i++) {
                if (!junctionSaveResults[i].isSuccess()) {
                    logFailedJunction(junctionsToDelete[i], LeadAndOppMatchingBatchHelper.getErrorMessagesFromSaveResult(junctionSaveResults[i].getErrors()), false);
                }
            }
        }
    }

   // Process the results of Lead updates and return the junctions that should be deleted
    public List<Property_SalesAI_Match__c> processLeadResults(
        Database.SaveResult[] leadResults, 
        List<Lead> leadsToUpdate,
        Map<Id, List<Property_SalesAI_Match__c>> leadIdToJunctionMap) {
        List<Property_SalesAI_Match__c> junctionsToDelete = new List<Property_SalesAI_Match__c>();
        
        // Assuming leadsToUpdate is aligned with the successfulJunctions list (corresponding Leads)
        for (Integer i = 0; i < leadResults.size(); i++) {
            Lead ld = leadsToUpdate[i];
            if (!leadResults[i].isSuccess()) {
                List<Property_SalesAI_Match__c> correspondingJunctions = leadIdToJunctionMap.get(ld.Id);
                // Add all the related junctions to be deleted
                if (correspondingJunctions != null) {
                    junctionsToDelete.addAll(correspondingJunctions);
                }
                logFailedLeadUpdate(ld, LeadAndOppMatchingBatchHelper.getErrorMessagesFromSaveResult(leadResults[i].getErrors()));
            } else {
                this.numberOfMatchedLeads++;    
            }
        }
        return junctionsToDelete;
    }

    // Process the results of Opportunity updates and return the junctions that should be deleted
    public List<Property_SalesAI_Match__c> processOppResults(
        Database.SaveResult[] oppResults, 
        List<Opportunity> oppsToUpdate,
        Map<Id, List<Property_SalesAI_Match__c>> oppIdToJunctionMap) {
        List<Property_SalesAI_Match__c> junctionsToDelete = new List<Property_SalesAI_Match__c>();
        
        // Assuming oppsToUpdate is aligned with the successfulJunctions list (corresponding Opportunities)
        for (Integer i = 0; i < oppResults.size(); i++) {
            Opportunity opp = oppsToUpdate[i];
            if (!oppResults[i].isSuccess()) {
                // Get the related Junction records for the failed Opportunity update
                List<Property_SalesAI_Match__c> correspondingJunctions = oppIdToJunctionMap.get(opp.Id);
                
                // Add all the related junctions to be deleted
                if (correspondingJunctions != null) {
                    junctionsToDelete.addAll(correspondingJunctions);
                }
                logFailedOppUpdate(opp, LeadAndOppMatchingBatchHelper.getErrorMessagesFromSaveResult(oppResults[i].getErrors()));
            } else {
                this.numberOfMatchedOpps++;
            }
        }
        return junctionsToDelete;
    }

    // Method to log failed Opportunity update
    public void logFailedOppUpdate(Opportunity opp, List<String> errorMessages) {
        String errorMessage = ' Opportunity update failed for Opportunity: ' + opp.Id + ' due to ' + String.join(errorMessages, ', ');
        if (String.isBlank(this.newRecord.Opportunity_Errors__c)) {
            this.newRecord.Opportunity_Errors__c = errorMessage;
            this.newRecord.Status__c = 'Finished With Errors';
        } else {
            this.newRecord.Opportunity_Errors__c += '\n' + errorMessage;
        }
    }

    // Method to log failed Junction insert
    public void logFailedJunction(Property_SalesAI_Match__c match, List<String> errorMessages, Boolean isInsert) {
        String relatedRecordId;
        // Determine whether Lead__c or Opportunity__c is populated
        if (match.Lead__c != null) {
            relatedRecordId = 'Lead: ' + match.Lead__c;
        } else {
            relatedRecordId = 'Opportunity: ' + match.Opportunity__c;
        } 
        String opType = isInsert ? 'insert' : 'delete';
        // Construct the error message
        String errorMessage = ' Property_SalesAI_Match__c record ' + opType + ' failed for ' + relatedRecordId + ' and SoldProperty record: ' + 
                              match.Property_SalesAI__c + ' due to ' + String.join(errorMessages, ', ');
        
        if (String.isBlank(this.newRecord.Property_SalesAI_Errors__c)) {
            this.newRecord.Property_SalesAI_Errors__c = errorMessage;
            this.newRecord.Status__c = 'Finished With Errors';

        } else {
            this.newRecord.Property_SalesAI_Errors__c += '\n' + errorMessage;
        }
    }    

    // Method to log failed Lead update
    public void logFailedLeadUpdate(Lead ld, List<String> errorMessages) {
        String errorMessage = ' Lead update failed for lead: ' + ld.Id + ' due to ' + String.join(errorMessages, ', ');
        if (String.isBlank(this.newRecord.Lead_Errors__c)) {
            this.newRecord.Lead_Errors__c = errorMessage;
            this.newRecord.Status__c = 'Finished With Errors';
        } else {
            this.newRecord.Lead_Errors__c += '\n' + errorMessage;
        }
    }
}