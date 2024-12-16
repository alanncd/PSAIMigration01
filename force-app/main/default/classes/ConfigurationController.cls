public with sharing class ConfigurationController {
    
    @AuraEnabled(cacheable=true)
    public static List<RecordType> getRecordTypes(String objectApiName) {
        if (Schema.SObjectType.RecordType.isAccessible()) {
            List<RecordType> rts = [SELECT Id, Name FROM RecordType WHERE SObjectType = :objectApiName AND IsActive = true WITH SECURITY_ENFORCED];
           
            rts = (List<RecordType>) Security.stripInaccessible(AccessType.READABLE, rts).getRecords();
            return rts;
        } else  {
            throw new AuraHandledException('No access to RecordTypes');
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<PickListWrapper> getStatuses(String objectApiName) {
        List<PicklistEntry> statuses = new List<PicklistEntry>();

        if (objectApiName == 'Lead') {
            statuses = Lead.Status.getDescribe().getPicklistValues();
        } else if (objectApiName == 'Opportunity') {
            statuses = Opportunity.StageName.getDescribe().getPicklistValues();
        }
        return getWrapperList(statuses);
    }

    @AuraEnabled
    public static List<PickListWrapper> getPicklistValuesForField(String objectApiName, String fieldApiName) {
        List<PicklistEntry> picklistValues = new List<PicklistEntry>();
        try {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
            Schema.DescribeSObjectResult describeSObjectResult = sObjectType.getDescribe();
            Schema.SObjectField field = describeSObjectResult.fields.getMap().get(fieldApiName);
            picklistValues = field.getDescribe().getPicklistValues();
            return getWrapperList(picklistValues);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getExecutionHistory() {
        // Ensure the user has read access to Property_SalesAI_History__c
        if (!Schema.sObjectType.Property_SalesAI_History__c.isAccessible()) {
            throw new AuraHandledException('You do not have access to Property Sales AI history records.');
        }
        
        try {
            // Query the most recent Property_SalesAI_History__c record based on Finish_Time__c
            List<Property_SalesAI_History__c> histories = [
                SELECT Id, OwnerId, Name, Finish_Time__c, Matched_Leads__c, Matched_Opportunities__c, Status__c,
                Lead_Errors__c, Opportunity_Errors__c
                FROM Property_SalesAI_History__c
                WHERE IsDeleted = false
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            Map<String, Object> result = new Map<String, Object>();
            if (histories.size() > 0) {
                result.put('Id', histories[0].Id);
                result.put('Status__c', histories[0].Status__c);
                result.put('Finish_Time__c', histories[0].Finish_Time__c);
                result.put('Matched_Leads__c', histories[0].Matched_Leads__c);
                result.put('Matched_Opportunities__c', histories[0].Matched_Opportunities__c);
                result.put('Lead_Errors__c', histories[0].Lead_Errors__c);
                result.put('Opportunity_Errors__c', histories[0].Opportunity_Errors__c);
                result.put('sObjectAPIName', histories[0].getSObjectType().getDescribe().getName());
                for (ChildRelationship cr : histories[0].getSObjectType().getDescribe().getChildRelationships()) {
                    if(cr.getRelationshipName() != null && cr.getRelationshipName().contains('Properties_Sales_Matches__r')) {
                        result.put('ChildRelationshipName', cr.getRelationshipName());
                    }
                }
            }
            return result;
        } catch (Exception e) {
            // Log the error and handle it gracefully
            System.debug('Error fetching Property_SalesAI_History__c: ' + e.getMessage());
            throw new AuraHandledException('Unable to retrieve Property Sales AI history');
        }
    }

    public static List<PickListWrapper> getWrapperList(List<PicklistEntry> statuses) {
        List<PickListWrapper> result = new List<PickListWrapper>();
        for (PicklistEntry status : statuses) {
            result.add(new PickListWrapper(status.label, status.value));
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> getCustomSettingValues() {
        Map<String, Object> result = new Map<String, Object>();

        // Retrieve the custom setting values (Assuming it's a hierarchy custom setting)
        Property_SalesAI_Settings__c settings = Property_SalesAI_Settings__c.getOrgDefaults();
        
        // Lead custom setting values
        result.put('Lead_Address_PostalCode', settings.Lead_Address_PostalCode__c);
        result.put('Lead_Address_State', settings.Lead_Address_State__c);
        result.put('Lead_Address_Street', settings.Lead_Address_Street__c);
        result.put('Lead_Address_City', settings.Lead_Address_City__c);
        result.put('Lead_Record_Types', settings.Lead_Record_Types__c);
        result.put('Lead_History_Duration', settings.Lead_History_Duration__c);
        result.put('Lead_Statuses', settings.Lead_Status__c);
        result.put('Lead_Statuses_2', settings.Lead_Status_2__c);
        result.put('Lead_Matched_Reason', settings.Matched_Lead_Reason__c);
        result.put('Lead_Matched_Reason_Field', settings.Matched_Lead_Reason_Field__c);
        result.put('Lead_Matched_Status', settings.Matched_Lead_Status__c);

        // Opportunity custom setting values
        result.put('Opportunity_Address_PostalCode', settings.Opportunity_Address_PostalCode__c);
        result.put('Opportunity_Address_State', settings.Opportunity_Address_State__c);
        result.put('Opportunity_Address_Street', settings.Opportunity_Address_Street__c);
        result.put('Opportunity_Address_City', settings.Opportunity_Address_City__c);
        result.put('Opportunity_Record_Types', settings.Opportunity_Record_Types__c);
        result.put('Opportunity_History_Duration', settings.Opportunity_History_Duration__c);
        result.put('Opportunity_Stages', settings.Opportunity_Stage__c);
        result.put('Opportunity_Stages_2', settings.Opportunity_Stage_2__c);
        result.put('Opportunity_Matched_Reason', settings.Matched_Opportunity_Reason__c);
        result.put('Opportunity_Matched_Reason_Field', settings.Matched_Opportunity_Reason_Field__c);
        result.put('Opportunity_Matched_Stage', settings.Matched_Opportunity_Stage__c);

        // Property custom setting values
        result.put('Property_Sales_History_Duration', settings.Property_Sales_History_Duration__c);
        result.put('Matching_Day', settings.Matching_Day__c);
        result.put('AutomaticUpdate', settings.AutomaticUpdate__c);

        result.put('IsSetupComplete', settings.IsSetupComplete__c);
        return result;
    }

    @AuraEnabled
    public static void updateIsSetupComplete(){
        try {
            Property_SalesAI_Settings__c settings = Property_SalesAI_Settings__c.getOrgDefaults();
            settings.IsSetupComplete__c = true;
            if (Schema.sObjectType.Property_SalesAI_Settings__c.isUpdateable() && Schema.sObjectType.Property_SalesAI_Settings__c.isCreateable()) {
                upsert settings;
                String cronExp = getCronExpressionFromDay(settings.Matching_Day__c);
                System.schedule('Matching logic weekly run', cronExp, new LeadAndOppMatchingScheduler());
               	Lmg_AddressKeyIntegration_cls.scheduleNightlyBatch();
               	Lmg_SimilarityKeyHelper_cls.createCustomSettingDefault();

            } else {
                Exception ex = new AuraHandledException('No access to modify custom setting');
                ex.setMessage('No access to modify custom setting');
                throw ex;    
            }
        } catch (Exception e) {
            Exception ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }

    @AuraEnabled
    public static void saveCustomSetting(String objectApiName, Map<String, String> settingsMap) {
       
        // Retrieve the custom setting instance
        Property_SalesAI_Settings__c customSetting = Property_SalesAI_Settings__c.getOrgDefaults();
        Boolean reschedule = false;
        try {
            // Dynamically assign field values based on the object API name and the map provided
            for (String field : settingsMap.keySet()) {
                String fieldValue = settingsMap.get(field);
                if (field.contains('Duration')) {
                    // Convert string to integer for duration fields
                    Integer duration = Integer.valueOf(fieldValue);
                    putField(customSetting, field, duration);
                } else if (field.contains('Automatic')) {
                    // Convert string to boolean for Automatic fields
                    Boolean automatic = Boolean.valueOf(fieldValue);
                    putField(customSetting, field, automatic);
                } else {
                    // Directly assign string values for other fields
                    if (field.contains('Matching_Day') &&
                    customSetting.IsSetupComplete__c && customSetting.Matching_Day__c != null &&
                    !customSetting.Matching_Day__c.equals(fieldValue)) {
                        reschedule = true;
                    }
                    putField(customSetting, field, fieldValue);
                }
            }
            if (Schema.sObjectType.Property_SalesAI_Settings__c.isUpdateable() && Schema.sObjectType.Property_SalesAI_Settings__c.isCreateable()) {
                upsert customSetting;
            } else {
                throw new AuraHandledException('Insufficient permissions to update custom settings.');
            }
            if (reschedule) {
                // Query the existing scheduled job
                CronTrigger ct = [SELECT Id, CronJobDetail.Name 
                    FROM CronTrigger 
                    WHERE CronJobDetail.Name = 'Matching logic weekly run' 
                    WITH SECURITY_ENFORCED LIMIT 1];
                
                // Abort the existing job if found
                if (ct != null) {
                    System.abortJob(ct.Id);
                }
                
                // Schedule the new job
                String cronExp = getCronExpressionFromDay(customSetting.Matching_Day__c);
                System.schedule('Matching logic weekly run', cronExp, new LeadAndOppMatchingScheduler());
            }
        } catch (Exception e) {
            Exception ex = new AuraHandledException('Error saving custom settings: ' + e.getMessage());
            ex.setMessage('Error saving custom settings: ' + e.getMessage());
            throw ex;
        }
    }

    /**
     * Helper method to put values in SObject fields dynamically.
     */
    static void putField(SObject obj, String fieldName, Object value) {
        Schema.SObjectType objectType = obj.getSObjectType();
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        String namespacePrefix = getNamespacePrefixForObject(objectDescribe); 
        String key = namespacePrefix + fieldName;

        if (fieldMap.containsKey(key)) {
            obj.put(key, value);
        } else if (fieldMap.containsKey(fieldName)) {
            obj.put(fieldName, value);
        } else {
            Exception ex = new AuraHandledException('Field does not exist: ' + fieldName);
            ex.setMessage('Field does not exist: ' + fieldName);
            throw ex;
        }
    }

    static String getNamespacePrefixForObject(Schema.DescribeSObjectResult objectDescribe){
        String fullName = objectDescribe.getName();       // E.g., 'lmgpilot__CustomSetting__c' or 'CustomSetting__c'
        String localName = objectDescribe.getLocalName(); // E.g., 'CustomSetting__c'
        // Determine the namespace prefix
        String namespacePrefix = '';
        if (!fullName.equals(localName)) {
            // Extract the namespace prefix by removing the local name from the full name
            namespacePrefix = fullName.substring(0, fullName.indexOf(localName));
        }    
        return namespacePrefix;
    }

    public static String getCronExpressionFromDay(String day) {
        String cronExp;
        if (day !=null) {
            cronExp = '0 0 0 ? * ';
            cronExp += day.substring(0,3).toUpperCase();
            return cronExp;
        }
        return cronExp;
    }

    public class PickListWrapper {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value {get; set; }

        PickListWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}