/** 
 * @description Class Helper for Lmg_SimilarityKey_btch.cls.
 * @param Property_SalesAI_Settings__c Custom setting that contains SalesAIsetting.
 * @param leadRecordTypeIds Record types Ids.
 * @comment class helper.
 */

public with sharing class Lmg_SimilarityKeyHelper_cls {


    private static Property_SalesAI_Settings__c customSettings = LeadAndOppMatchingBatchHelper.getCustomSettingOrgDefaultRecord();
    private static List<String> leadRecordTypeIds;
    private static List<String> leadStatusesToInclude;
    private static Integer leadDuration;

    private static List<String> oppRecordTypeIds;
    private static List<String> oppStagesToInclude;
    private static Integer oppDuration;

    /** 
     * @description Return default custom settings.
     * @comment class helper returning custom settings.
     * @return return custom setting
     */
    public static Property_SalesAI_Settings__c getCustomSettingOrgDefaultRecord() {
        // Fetch the default org-level value for the custom setting
        Property_SalesAI_Settings__c defaultSetting = Property_SalesAI_Settings__c.getOrgDefaults();
        return defaultSetting;
    }

    /** 
     * @description Class Helper for Lmg_SimilarityKey_btch.cls.
     * @param fieldsToRetrieve List of fields to be used in the query.
     * @comment class helper.
     * @return custom settings.
     */
    public static Database.QueryLocator getQueryLead(List<String> fieldsToRetrieve){
        if(customSettings == null){
            customSettings = LeadAndOppMatchingBatchHelper.getCustomSettingOrgDefaultRecord();
        }
        getCustomSettingsValues();
        return getMatchingLeads(leadRecordTypeIds,leadStatusesToInclude,leadDuration,fieldsToRetrieve);

    }
    /** 
     * @description Class Helper for Lmg_SimilarityKey_btch.cls.
     * @param fieldsToRetrieve List of fields to be used in the query.
     * @return opportunities records to be returned.
     * @comment class helper.
     */
    public static Database.QueryLocator getQueryOpp(List<String> fieldsToRetrieve){
        if(customSettings == null){
            customSettings = LeadAndOppMatchingBatchHelper.getCustomSettingOrgDefaultRecord();
        }
        getCustomSettingsValues();
        return getMatchingOpps(oppRecordTypeIds,oppStagesToInclude,oppDuration,fieldsToRetrieve);

    }

        /** 
     * @description Class Helper for Lmg_SimilarityKey_btch.cls.
     * @return String of the query.
     * @comment class helper.
     */

    public static String getQueryProperties(){

            // Check object-level read access for Opportunity
        if (!Schema.sObjectType.Property__c.isAccessible()) {
            throw new IllegalArgumentException('No data returned. User does not have access to Properties.');
        }

        String query = 'select id,Street__c,Zip_Code__c from Property__c WHERE Similarity_Key__c = NULL';

        return query;
    }

        /** 
     * @description Class Helper for Lmg_SimilarityKey_btch.cls.
     * @comment class helper.
     */

    private static void getCustomSettingsValues(){

        leadRecordTypeIds = LeadAndOppMatchingBatchHelper.getListFromCommaSeparatedList(customSettings.Lead_Record_Types__c);
        String leadStatuses = customSettings.Lead_Status__c;
        leadStatuses += customSettings.Lead_Status_2__c != null ? customSettings.Lead_Status_2__c : '';
        leadStatusesToInclude = LeadAndOppMatchingBatchHelper.getListFromCommaSeparatedList(leadStatuses);
        leadDuration = Integer.valueOf(customSettings.Lead_History_Duration__c);

        oppRecordTypeIds = LeadAndOppMatchingBatchHelper.getListFromCommaSeparatedList(customSettings.Opportunity_Record_Types__c);
        String oppStages = customSettings.Opportunity_Stage__c;
        oppStages += customSettings.Opportunity_Stage_2__c != null ? customSettings.Opportunity_Stage_2__c : '';
        oppStagesToInclude = LeadAndOppMatchingBatchHelper.getListFromCommaSeparatedList(oppStages);
        oppDuration = Integer.valueOf(customSettings.Opportunity_History_Duration__c);

    }

        /** 
     * @description Class Helper for Lmg_SimilarityKey_btch.cls.
     * @param recordTypeIds List of record types ids to be used in the query.
     * @param stagesOrStatuses List of status to be used in the query.
     * @param duration duration to be used in the query.
     * @param fieldsToRetrieve List of fields to be used in the query.
     * @return record to be returned.
     * @comment class helper.
     */

    public static Database.QueryLocator getMatchingLeads(
        List<String> recordTypeIds,
        List<String> stagesOrStatuses,
        Integer duration,
        List<String> fieldsToRetrieve
    ) {
        // Validate inputs
        if (fieldsToRetrieve == null || fieldsToRetrieve.isEmpty()) {
            throw new IllegalArgumentException('Fields to retrieve cannot be null or empty.');
        }
    
        // Check object-level read access for Lead
        if (!Schema.sObjectType.Lead.isAccessible()) {
            throw new IllegalArgumentException('No data returned. User does not have access to Lead.');
        }
    
        // Construct the base query
        String query = 'SELECT ' + String.join(fieldsToRetrieve, ', ') +
                       ' FROM Lead WHERE RecordTypeId IN :recordTypeIds AND Status IN :stagesOrStatuses AND Similarity_Key__c = NULL AND isconverted = false';
        // Add duration filter if provided
        if (duration != null && duration != -1) {
            DateTime createdDateFilter = DateTime.now().addDays(-1 * duration);
            query += ' AND LastModifiedDate >= :createdDateFilter';
            return Database.getQueryLocator(query);
        }
    
        // Execute query without duration filter
        return Database.getQueryLocator(query);
    }
    
        /** 
     * @description Class Helper for Lmg_SimilarityKey_btch.cls.
     * @param recordTypeIds List of record types ids to be used in the query.
     * @param stagesOrStatuses List of status to be used in the query.
     * @param duration duration to be used in the query.
     * @param fieldsToRetrieve List of fields to be used in the query.
     * @return records to be returned.
     * @comment class helper.
     */
    public static Database.QueryLocator getMatchingOpps(
    List<String> recordTypeIds,
    List<String> stagesOrStatuses,
    Integer duration,
    List<String> fieldsToRetrieve
) {
    // Validate inputs
    if (fieldsToRetrieve == null || fieldsToRetrieve.isEmpty()) {
        throw new IllegalArgumentException('Fields to retrieve cannot be null or empty.');
    }

    // Check object-level read access for Opportunity
    if (!Schema.sObjectType.Opportunity.isAccessible()) {
        throw new IllegalArgumentException('No data returned. User does not have access to Opportunity.');
    }

    // Construct the base query
    String query = 'SELECT ' + String.join(fieldsToRetrieve, ', ') +
                   ' FROM Opportunity WHERE RecordTypeId IN :recordTypeIds AND StageName IN :stagesOrStatuses AND Similarity_Key__c = NULL';

    // Add duration filter if provided
    if (duration != null && duration != -1) {
        DateTime createdDateFilter = DateTime.now().addDays(-1 * duration);
        query += ' AND LastModifiedDate >= :createdDateFilter';
        return Database.getQueryLocator(query);

    }
    return Database.getQueryLocator(query);

}

    /**
     * Logs the details of an exception into a single field.
     *
     * @param ex The exception to log.
     * @param className The name of the class where the exception occurred.
     * @param methodName The name of the method where the exception occurred.
     * @param severity The severity level (e.g., 'INFO', 'WARNING', 'ERROR').
     */
    public static void logError(Exception ex, String className, String methodName, String severity, String additionalMessage) {
        try {
            // Format the log details into a single string
            String logDetails = 'Timestamp: ' + String.valueOf(System.now()) + '\n' +
                                'Class: ' + className + '\n' +
                                'Method: ' + methodName + '\n' +
                                'Severity: ' + severity + '\n' +
                                'Message: ' + ex.getMessage() + '\n' +
                                'Stack Trace: ' + ex.getStackTraceString();

            // Create the error log record
            ErrorHandlerLmr__c errorLog = new ErrorHandlerLmr__c();
            errorLog.ProcessName__c = className;
            errorLog.LogDetail__c = logDetails +'\n' + additionalMessage;

            // Insert the log record
            insert errorLog;
        } catch (Exception logEx) {
            // Handle logging failure gracefully
            System.debug('Failed to log error: ' + logEx.getMessage());
        }
    }

    /**
     * @description Class Helper to create the custom setting.
     * @throws IllegalArgumentException If the user does not have access to the custom setting object.
     */
    public static void createCustomSettingDefault() {
        Similarity_Key_Setting__c customSettings = Similarity_Key_Setting__c.getOrgDefaults();
        Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Similarity_Key_Setting__c.fields.getMap();

        if (!Schema.sObjectType.Similarity_Key_Setting__c.isAccessible()) {
            throw new IllegalArgumentException('No Access to Custom Setting.');
        }else{
            if(customSettings.Size_Lead__c == null && fieldsMap.get('Size_Lead__c').getDescribe().isAccessible() && customSettings.Size_Properties__c == null && fieldsMap.get('Size_Properties__c').getDescribe().isAccessible() && customSettings.Size_Opportunity__c == null && fieldsMap.get('Size_Opportunity__c').getDescribe().isAccessible() ){
                customSettings.Size_Lead__c = 100;
                customSettings.Size_Properties__c = 100;
                customSettings.Size_Opportunity__c = 100;
                insert customSettings;
            }

        }

    }

}