/** 
 * @description Constructor for the Lmg_SimilarityKey_Bth class. Initializes the batch with the given object type and external ID.
 * @param objectType   The type of object to process in the batch (e.g., 'Lead', 'Opportunity', 'Property__c').
 * @param externalId   An optional external identifier to track logs or chain batches.
 * @comment class to generate similarity key.
 */
public with sharing class Lmg_SimilarityKey_Bth implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts,Schedulable{
 
    private String objectType;
    private String externalId;

    private static final String LEAD = 'Lead';
    private static final String OPPORTUNITY = 'Opportunity';
    private static final String PROPERTY_SALES = 'Property__c';

    private Map<String, Integer> successCounts = new Map<String, Integer>();
    private Map<String, Integer> failureCounts = new Map<String, Integer>();
    private List<String> failedRecordIds = new List<String>();
    private static Property_SalesAI_Settings__c customSettings = LeadAndOppMatchingBatchHelper.getCustomSettingOrgDefaultRecord();
    Similarity_Key_Setting__c similarityKeySettings = Similarity_Key_Setting__c.getOrgDefaults();

    private map<String,String> mapAddressKey = new map<String,String>();

    // variables to track results across batches
    private Integer totalSuccessCount = 0;
    private Integer totalFailureCount = 0;
    private List<String> totalFailedRecordIds = new List<String>();
    private List<Map<String, String>> failureDetailsList = new List<Map<String, String>>();

    /**
     * @method constructor
     * @description This is constructor method.
     * @param objectType is used to specify the type of object.
     * @param externalId is used to specify the log record external Id.
     */
    public Lmg_SimilarityKey_Bth(String objectType,string externalId) {
        this.objectType = objectType;
        this.externalId = externalId;
    }

    /**
     * @method getQueryLocatorMap
     * @description Prepares the query locator for batch processing based on the object type. Determines which records to process.
     * @return Map<String, Database.QueryLocator> A query locator containing the records to be processed in batches.
     */

     private Map<String, Database.QueryLocator> getQueryLocatorMap() {

        return new Map<String, Database.QueryLocator>{
            LEAD => getLeadQuery(),
            OPPORTUNITY => getOpportunityQuery(),
            PROPERTY_SALES => getPropertyQuery()
        };

    }

        /**
         * Prepares the query locator for batch processing based on the object type.
         * @description Determines which records to process.
         * 
         * @param bc The batchable context passed by the system.
         * @return Database.QueryLocator A query locator containing the records to be processed in batches.
         * @throws IllegalArgumentException If the object type is invalid.
         */
        public Database.QueryLocator start(Database.BatchableContext bc) {
            try{
                Map<String, Database.QueryLocator> queryLocatorMap = getQueryLocatorMap();
                if (!queryLocatorMap.containsKey(objectType)) {
                    throw new IllegalArgumentException('Invalid object type for batch processing.');
                }
                return queryLocatorMap.get(objectType);
            }catch(Exception e){
                Lmg_SimilarityKeyHelper_cls.logError(e,'Similarity Key Batch: Start','Batch Job','WARNING');
                Set<Id> emptySet = new Set<Id>();
                return Database.getQueryLocator([ SELECT Id FROM Account WHERE Id IN :emptySet]);
            }

        }

    /**
     * @method execute
     * @description Processes each batch of records, makes API callouts to update Similarity Keys, and logs success and failure results.
     * @param bc     The batchable context passed by the system.
     * @param scope  The list of records in the current batch scope.
     */

     public void execute(Database.BatchableContext bc, List<SObject> scope) {
        try{
            Left_Main_SimilarityKey_Setting__mdt apiToken = Left_Main_SimilarityKey_Setting__mdt.getInstance('Production');
        // List<SObject> recordsToUpdateFinal = new List<SObject>();
            RecordProcessingContext context = new RecordProcessingContext();
        
            processRecords(scope, context);

            if (context.addressList.isEmpty()) {
                return; // Exit early if no valid addresses to process
            }
        
            String encodedRecords = Lmg_AddressKeyIntegration_cls.createAndEncodeJsonFromRecords(context.recordsToUpdate, mapAddressKey.get('Street'), 'Id');
            String jsonResponse = Lmg_AddressKeyIntegration_cls.callMatchAddress(apiToken.Api_Token__c, encodedRecords);
        
            processApiResponse(jsonResponse, context.recordMap, context.recordPostalCode, context.recordsToUpdate);
        
            if (!context.recordsToUpdate.isEmpty()) {
                performBulkUpdate(context.recordsToUpdate);
            }
        }catch(Exception e){
            Lmg_SimilarityKeyHelper_cls.logError(e,'Similarity Key Batch','Batch Job','WARNING');
        }
    }
    
    /**
     * @description Processes the records in the scope, extracting address data and preparing for API callouts.
     * @param scope The records processed.
     * @param context class to be used in all the process
     */
        private void processRecords(List<SObject> scope, RecordProcessingContext context) {

            for (SObject record : scope) {
                if (!mapAddressKey.containsKey('Street') || !mapAddressKey.containsKey('PostalCode')) {
                    continue; // Skip if required keys are not present
                }
        
                String street = (String) record.get(mapAddressKey.get('Street'));
                String postalCode = (String) record.get(mapAddressKey.get('PostalCode'));
                String recordId = (String) record.get('Id');
        
                if (String.isBlank(street) || String.isBlank(postalCode)) {
                    continue; // Skip records with missing address data
                }
        
                context.recordMap.put(recordId, record);
                context.recordPostalCode.put(recordId, postalCode);
                context.addressList.add(new Map<String, String>{'Data' => street, 'Reference' => recordId});
                context.recordsToUpdate.add(record);
            }
        }
    
    /**
     * @description Processes the API response and prepares records for updates.
     * @param jsonResponse variable used in api process.
     * @param recordMap variable used in api process.
     * @param recordPostalCode variable used in api process.
     * @param recordsToUpdateFinal variable used in api process.  
     */
    private void processApiResponse(
        String jsonResponse,
        Map<String, SObject> recordMap,
        Map<String, String> recordPostalCode,
        List<SObject> recordsToUpdateFinal
    ) {
        recordsToUpdateFinal.clear();


        Lmg_AddressKeyIntegration_cls.ApiResponse response =
            (Lmg_AddressKeyIntegration_cls.ApiResponse) JSON.deserialize(jsonResponse, Lmg_AddressKeyIntegration_cls.ApiResponse.class);
    
        if (response.Status != 'success' || response.MatchKeys == null) {
            return; // Exit if response is not successful or has no match keys
        }
    
        for (Lmg_AddressKeyIntegration_cls.MatchKey match : response.MatchKeys) {
            if (!recordMap.containsKey(match.Reference)) {
                continue; // Skip if match reference is not found in record map
            }
    
            SObject recordToUpdate = recordMap.get(match.Reference);
            recordToUpdate.put('Similarity_Key__c', match.SimKey + '_' + recordPostalCode.get(match.Reference));
            recordsToUpdateFinal.add(recordToUpdate);
        }

    }
    
    /**
     * @description Performs a bulk update and tracks success and failure results.
     * @param recordsToUpdateFinal records to be updated.
     */
    private void performBulkUpdate(List<SObject> recordsToUpdateFinal) {
        Database.SaveResult[] updateResults = Database.update(recordsToUpdateFinal, false,AccessLevel.USER_MODE);
    
        for (Integer i = 0; i < updateResults.size(); i++) {
            if (updateResults[i].isSuccess()) {
                totalSuccessCount++;
            } else {
                totalFailureCount++;
                totalFailedRecordIds.add((String) recordsToUpdateFinal[i].get('Id'));
                Map<String, String> failureDetail = new Map<String, String>{
                    'Id' => (String) recordsToUpdateFinal[i].get('Id'),
                    'Error' => updateResults[i].getErrors()[0].getMessage()
                };
                failureDetailsList.add(failureDetail);
            }
        }
    }

    /**
     * @method finish
     * @description Executes after all batch operations are complete. Logs the results of the batch process and chains additional batches if necessary.
     * @param bc The batchable context passed by the system.
     */
    public void finish(Database.BatchableContext bc) {
        
        try{
        String externalIdFinal = '';
        if(String.isBlank(externalId)){
            externalId = ''+UUID.randomUUID();
        } 

    // Split the failureDetailsJson into chunks
    String failureDetailsJson = JSON.serialize(failureDetailsList);
    Integer maxCharacters = 131000; //131000; // Adjust based on Detail__c limit
    List<Lmr_Metric__c> logsToInsert = new List<Lmr_Metric__c>();

    Integer chunkIndex = 0;
    while (failureDetailsJson.length() > 0) {
        String partialJson;
        if (failureDetailsJson.length() > maxCharacters) {
            partialJson = failureDetailsJson.substring(0, maxCharacters);
            failureDetailsJson = failureDetailsJson.substring(maxCharacters);
        } else {
            partialJson = failureDetailsJson;
            failureDetailsJson = ''; // Clear the remaining string
        }
        if(chunkIndex == 0){
            externalIdFinal=externalId;
        }else{
            externalIdFinal=externalId + '_' + chunkIndex;
        }
        Lmr_Metric__c log = createLog(partialJson,externalIdFinal);
        logsToInsert.add(log);
        chunkIndex++;
    }


        // Insert or update log records
        upsert as user logsToInsert External_Id__c;

        if (objectType == LEAD) {
            // Chain Opportunity batch
        Integer sizeOppBatch = (Integer) (similarityKeySettings.Size_Opportunity__c >= 100 || similarityKeySettings.Size_Opportunity__c <= 0 || similarityKeySettings.Size_Opportunity__c == NULL? 100: similarityKeySettings.Size_Opportunity__c);
         Database.executeBatch(new Lmg_SimilarityKey_Bth(OPPORTUNITY,externalId),sizeOppBatch);

        } else if (objectType == OPPORTUNITY) {
            // Chain Property_SalesAI batch
          Integer sizePropertyBatch = (Integer) (similarityKeySettings.Size_Properties__c >= 100 || similarityKeySettings.Size_Properties__c <= 0 || similarityKeySettings.Size_Properties__c == NULL ? 100: similarityKeySettings.Size_Properties__c);
          Database.executeBatch(new Lmg_SimilarityKey_Bth(PROPERTY_SALES,externalId),sizePropertyBatch);
        }
    }catch (Exception e){
        Lmg_SimilarityKeyHelper_cls.logError(e,'Similarity Key Batch: '+objectType,'Batch Job','WARNING');

    }
    
    }
        /**
        * @method createLog
        * @description Helper method to create a log record with details of batch processing results.
        * @param detail The serialized JSON string containing failure details.
        * @param extId  The external ID for the log record.
        * @return Lmr_Metric__c A new log record populated with the given details.
        */
        private Lmr_Metric__c createLog(String detail, String extId) {

            Lmr_Metric__c log = new Lmr_Metric__c();
            log.External_Id__c = extId;
            log.Detail__c = detail;
           switch on objectType {
            when 'Lead' {
                log.Leads_Processed__c = totalSuccessCount;
                log.Leads_Not_Processed__c = totalFailureCount;
            }
            when 'Opportunity' {
                log.Opportunities_Processed__c = totalSuccessCount;
                log.Opportunities_Not_Processed__c = totalFailureCount;
            }
            when 'Property__c' {
                log.Properties_Processed__c = totalSuccessCount;
                log.Properties_Not_Processed__c = totalFailureCount;
            }
        }

            return log;
        }


    /**
     * @method execute
     * @description Executes the schedulable task. Starts the batch processing for Leads.
     * @param sc The schedulable context passed by the system.
     */
    public void execute(SchedulableContext sc) {

         if (Test.isRunningTest()) {return; }
            Integer sizeLeadBatch = (Integer) (similarityKeySettings.Size_Lead__c >= 100 || similarityKeySettings.Size_Lead__c <= 0 || similarityKeySettings.Size_Lead__c == NULL? 100: similarityKeySettings.Size_Lead__c);
			Database.executeBatch(new Lmg_SimilarityKey_Bth('Lead',null), sizeLeadBatch);
    	}

    private Database.QueryLocator getLeadQuery() {
        if (objectType != LEAD) { return null; }
        mapAddressKey.put('Street', customSettings.Lead_Address_Street__c);
        mapAddressKey.put('PostalCode', customSettings.Lead_Address_PostalCode__c);
        List<String> stringListFields = new List<String>{'Id', customSettings.Lead_Address_Street__c, customSettings.Lead_Address_PostalCode__c};
        return Lmg_SimilarityKeyHelper_cls.getQueryLead(stringListFields);
    }
    
    private Database.QueryLocator getOpportunityQuery() {
        if (objectType != OPPORTUNITY) { return null; }
        mapAddressKey.put('Street', customSettings.Opportunity_Address_Street__c);
        mapAddressKey.put('PostalCode', customSettings.Opportunity_Address_PostalCode__c);
        List<String> stringListFields = new List<String>{'Id', customSettings.Opportunity_Address_Street__c, customSettings.Opportunity_Address_PostalCode__c};
        return Lmg_SimilarityKeyHelper_cls.getQueryOpp(stringListFields);
    }
    
    private Database.QueryLocator getPropertyQuery() {
        if (objectType != PROPERTY_SALES) { return null; }
        mapAddressKey.put('Street', 'Street__c');
        mapAddressKey.put('PostalCode', 'Zip_Code__c');
        return Database.getQueryLocator(Lmg_SimilarityKeyHelper_cls.getQueryProperties());
    }

    private class RecordProcessingContext {
        private Map<String, SObject> recordMap = new Map<String, SObject>();
        private Map<String, String> recordPostalCode = new Map<String, String>();
        private List<Map<String, String>> addressList = new List<Map<String, String>>();
        private List<SObject> recordsToUpdate = new List<SObject>();
    }

}