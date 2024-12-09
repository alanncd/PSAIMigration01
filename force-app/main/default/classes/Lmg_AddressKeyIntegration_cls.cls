/**
 * @class Lmg_AddressKeyIntegration_cls
 * @description Utility class for handling address key integration, including making API callouts, encoding URLs, 
 * processing address data, and scheduling nightly batches.
 */
public with sharing class Lmg_AddressKeyIntegration_cls {

    private static Similarity_Key_Setting__c similarityKeySettings = Similarity_Key_Setting__c.getOrgDefaults();

    /**
     * @method encodeUrl
     * @description Encodes a URL by appending query parameters from the provided map.
     * @param url The base URL to which query parameters will be appended.
     * @param bodyMap A map of parameters to include in the query string.
     * @return String The encoded URL with appended query parameters.
     */
        private static String encodeUrl(String url,Map<String,Object> bodyMap ) {

        List<String> params = new List<String>();

        for(String key : bodyMap.keySet()) {

            String value = String.valueOf(bodyMap.get(key));

            if(String.isNotBlank(value)) {
                if(key == 'apikey' || key == 'data'){
                    params.add(key + '=' + value);
                }else{
                params.add(key+'='+EncodingUtil.urlEncode(value,'UTF-8'));
                }
            }

        }

        if(! params.isEmpty()) {

            url += '?'+String.join(params,'&');

        }

        return url;

    }

    /**
     * @method callMatchAddress
     * @description Makes a POST API call to match an address using the provided API key and encoded data.
     * @param apiKey The API key required for authentication.
     * @param encodedData The encoded address data to be matched.
     * @return String The response body from the API call.
     */
    public static String callMatchAddress(String apiKey,String encodedData){
        String environment = (String.isBlank(similarityKeySettings.Env_Mode__c) || similarityKeySettings.Env_Mode__c != 'Dev')? 'Production':'Dev';
        Left_Main_SimilarityKey_Setting__mdt config = Left_Main_SimilarityKey_Setting__mdt.getInstance(environment);
        
        Map<String,Object> bodyMap = New Map<String,Object>();
        bodyMap.put('function','match');
        bodyMap.put('apikey',config.Api_Token__c);
        bodyMap.put('source','jsonrefbatch');
        bodyMap.put('data',encodedData);
        bodyMap.put('category','address');
        bodyMap.put('process','keysonly');
        bodyMap.put('table','jsonrefbatch');
        bodyMap.put('keysoutputall','true');
        bodyMap.put('target','json');

       String lastEndpoint = encodeUrl(config.Url__c,bodyMap);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(lastEndpoint);
        request.setMethod('POST');
        request.setTimeout(120000); // Timeout in milliseconds, 120000 ms = 120 seconds

       HttpResponse response = http.send(request);

        return response.getBody();
    }


    /**
     * @method createAndEncodeJsonFromRecords
     * @description Converts a list of records into a JSON structure and encodes it for use in API callouts.
     * @param records The list of SObjects to process.
     * @param addressField The name of the address field in the records.
     * @param referenceField The name of the reference field in the records.
     * @return String The encoded JSON string.
     * @throws IllegalArgumentException If records are null/empty or fields are invalid.
     */
    public static String createAndEncodeJsonFromRecords(
        List<SObject> records, 
        String addressField, 
        String referenceField
    ) {

        validateInput(records, addressField, referenceField); // Validation step

        List<Map<String, String>> addressList = extractValidAddresses(records, addressField, referenceField); // Extraction step

        if (addressList.isEmpty()) {
            throw new IllegalArgumentException('No valid data found in the given records.');
        }

        return serializeAndEncodeData(addressList); // Serialization and encoding step

    }

    /**
     * @method serializeAndEncodeData
     * @description Serializes a list of maps to JSON and URL-encodes the resulting string.
     * @param addressList A list of maps containing address and reference data.
     * @return String The URL-encoded JSON string.
     * @throws IllegalArgumentException If serialization or encoding fails.
     */
    private static String serializeAndEncodeData(List<Map<String, String>> addressList) {
        try {
            String jsonData = JSON.serialize(addressList);
            return EncodingUtil.urlEncode(jsonData, 'UTF-8');
        } catch (Exception e) {
            throw new IllegalArgumentException('Error serializing or encoding data: ' + e.getMessage());
        }
    }

    /**
     * @method validateInput
     * @description Validates the input records and field names.
     * @param records The list of records to validate.
     * @param addressField The address field name to validate.
     * @param referenceField The reference field name to validate.
     * @throws IllegalArgumentException If the input is invalid.
     */

    private static void validateInput(
        List<SObject> records, 
        String addressField, 
        String referenceField
    ) {
        if (records == null || records.isEmpty()) {
            throw new IllegalArgumentException('Record list cannot be null or empty.');
        }
        if (String.isBlank(addressField) || String.isBlank(referenceField)) {
            throw new IllegalArgumentException('Address and Reference fields cannot be null or blank.');
        }
    }

    /**
     * @method extractValidAddresses
     * @description Extracts valid address and reference data from a list of records.
     * @param records The list of records to process.
     * @param addressField The address field name in the records.
     * @param referenceField The reference field name in the records.
     * @return List<Map<String, String>> A list of maps containing valid address and reference data.
     */
    private static List<Map<String, String>> extractValidAddresses(
    List<SObject> records, 
    String addressField, 
    String referenceField
    ) {
        List<Map<String, String>> addressList = new List<Map<String, String>>();

        for (SObject record : records) {
            String address = (String) record.get(addressField);
            String reference = (String) record.get(referenceField);

            if (String.isNotBlank(address) && String.isNotBlank(reference)) {
                addressList.add(new Map<String, String>{
                    'Data' => address,
                    'Reference' => reference
                });
            }
        }
        return addressList;
    }

    /**
     * @method scheduleNightlyBatch
     * @description Schedules the nightly batch process for generating similarity keys.
     */
    public static void scheduleNightlyBatch() {
        	String jobName = 'Nightly Similarity Key Batch';
            // Check if the scheduled job already exists
            List<CronTrigger> existingJob = [
                SELECT Id, State 
                FROM CronTrigger 
                WHERE CronJobDetail.Name =: jobName
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
			// Job is already scheduled, do nothing
            if (existingJob.size() > 0) {return;}	
            // Generate a random hour and minute within the range
            Integer randomHour = (Integer) Math.floor(Math.random() * 7) + 22; // 22 (10 PM) to 4 (4 AM)
            if (randomHour >= 24) {
                randomHour -= 24; // Adjust for hours beyond midnight
            }
    
            Integer randomMinute = (Integer) Math.floor(Math.random() * 60);
            String cronExpression = generateCronExpression(randomHour, randomMinute);
            
            System.schedule(jobName, cronExpression, new Lmg_SimilarityKey_Bth('Lead',null));    
    }

    /**
     * @method generateCronExpression
     * @description Generates a cron expression for the given hour and minute.
     * @param hour The hour for the cron schedule.
     * @param minute The minute for the cron schedule.
     * @return String The cron expression.
     */

    private static String generateCronExpression(Integer hour, Integer minute) {
        // Generate a cron expression for the given hour and minute
        return '0 ' + minute + ' ' + hour + ' * * ?';
    }

    /**
     * @class ApiResponse
     * @description Represents the response from the address matching API.
     */
    public class ApiResponse {
        public String Status;
        public String Message;
        public List<MatchKey> MatchKeys;
    }

    /**
     * @class MatchKey
     * @description Represents a matched key from the API response.
     */
    public class MatchKey {
        public String Data;
        public String Reference;
        public String SimKey;
    }
    

}