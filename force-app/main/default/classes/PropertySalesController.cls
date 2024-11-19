public with sharing class PropertySalesController {

    @AuraEnabled(cacheable=true)
    public static List<MatchWrapper> getMatches(Id historyId) {
        Property_SalesAI_Settings__c customSettings = LeadAndOppMatchingBatchHelper.getCustomSettingOrgDefaultRecord();
        String leadStreet = customSettings.Lead_Address_Street__c;
        String oppStreet = customSettings.Opportunity_Address_Street__c;
    
        // Construct the dynamic SOQL query using the variables
        String query = 'SELECT Id, Property_Address__c, ' +
                       'Lead__r.' + leadStreet + ', ' +
                       'Opportunity__r.' + oppStreet + ', ' +
                       'Lead__c, Opportunity__c ' +
                       'FROM Property_SalesAI_Match__c ' +
                       'WHERE Property_SalesAI_History__c = :historyId ' +
                       'AND Status__c = \'Pending\' ' +
                       'WITH SECURITY_ENFORCED';
    
        // Execute the query dynamically
        List<Property_SalesAI_Match__c> matches = Database.query(query);
    
        // Transform the results into a list of wrappers for the LWC
        List<MatchWrapper> matchWrappers = new List<MatchWrapper>();
        for(Property_SalesAI_Match__c match : matches) {
            String leadStreetValue = match.Lead__c != null ? (String) match.getSObject('Lead__r').get(leadStreet) : null;
            String oppStreetValue = match.Opportunity__c != null ? (String) match.getSObject('Opportunity__r').get(oppStreet) : null;
    
            matchWrappers.add(new MatchWrapper(
                match.Id, 
                match.Property_Address__c, 
                leadStreetValue != null ? leadStreetValue : oppStreetValue,
                match.Lead__c != null ? match.Lead__c : match.Opportunity__c
            ));
        }
    
        return matchWrappers;
    }
    
    @AuraEnabled
    public static void markAsGoodMatches(List<String> matchIds, String historyId) {
        try {
            // Query all match records using the list of matchIds
            List<Property_SalesAI_Match__c> matchRecords = [
                SELECT Id, Lead__c, Opportunity__c, Property_SalesAI_History__c
                FROM Property_SalesAI_Match__c
                WHERE Id IN :matchIds
                WITH SECURITY_ENFORCED
            ];

            for (Property_SalesAI_Match__c matchRecord : matchRecords) {
                matchRecord.Status__c = 'Confirmed';
            }

            update matchRecords;
        } catch (Exception e) {
            System.debug('Error in markAsGoodMatches: ' + e.getStackTraceString());
            throw new AuraHandledException('Unable to mark as good matches: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void markAsNotMatch(List<String> matchIds, String historyId) {
        try {
            // Query all match records using the list of matchIds
            List<Property_SalesAI_Match__c> matchRecords = [
                SELECT Id, Lead__c, Opportunity__c, Property_SalesAI_History__c
                FROM Property_SalesAI_Match__c
                WHERE Id IN :matchIds
                WITH SECURITY_ENFORCED
            ];

            for (Property_SalesAI_Match__c matchRecord : matchRecords) {
                matchRecord.Status__c = 'Rejected';
            }

            update matchRecords;

        } catch (Exception e) {
            System.debug('Error in markAsNotMatch: ' + e.getMessage());
            throw new AuraHandledException('Unable to mark as not match: ' + e.getMessage());
        }
    }


    // Inner class to represent a match in the LWC
    public class MatchWrapper {
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public String soldPropertyAddress {get; set;}
        @AuraEnabled public String leadOppAddress {get; set;}
        @AuraEnabled public String leadOppId {get; set;}

        public MatchWrapper(
            String id,
            String soldPropertyAddress, 
            String leadOppAddress, 
            String leadOppId
        ) {
            this.id = id;
            this.soldPropertyAddress = soldPropertyAddress;
            this.leadOppAddress = leadOppAddress;
            this.leadOppId = leadOppId;
        }
    }
}