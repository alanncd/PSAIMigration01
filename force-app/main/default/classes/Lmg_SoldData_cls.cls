@RestResource(urlMapping='/LmgPilot/*')
global with sharing class Lmg_SoldData_cls {
 @HttpPost
    global static void receiveData() {
        Result_Subscription__c newResultSubscription = new Result_Subscription__c();
        String bodyReceived = RestContext.request.requestBody.toString();
        Left_Main_Sold_Data_Setting__mdt metadataRecord = [SELECT Api_Token__c FROM Left_Main_Sold_Data_Setting__mdt WHERE DeveloperName = 'Connection1' WITH SECURITY_ENFORCED LIMIT 1];
        String validToken = metadataRecord.Api_Token__c;
       try{
        LeadfuzionWrapper tr = (LeadfuzionWrapper)JSON.deserialize(bodyReceived, LeadfuzionWrapper.class);

        if(!String.isBlank(tr.custom) && !String.isBlank(validToken) && tr.custom == validToken){
        
            List<Subscription__c> listSubscriptions = [Select id from Subscription__c where County__c =: tr.county and state__c =: tr.state WITH SECURITY_ENFORCED];
            
            if(listSubscriptions.size() > 0 && !String.isBlank(tr.county) && (tr.records != Null && tr.records.size() > 0)){

                RestContext.response.statusCode = 200;
                RestContext.response.responseBody = Blob.valueOf('{"message": "Operation Completed Successfully."}');
                if (Schema.sObjectType.Result_Subscription__c.isCreateable() &&
                    Schema.sObjectType.Result_Subscription__c.fields.Count__c.isUpdateable() &&
                    Schema.sObjectType.Result_Subscription__c.fields.State__c.isUpdateable() &&
                    Schema.sObjectType.Result_Subscription__c.fields.County__c.isUpdateable() &&
                    Schema.sObjectType.Result_Subscription__c.fields.Subscription__c.isUpdateable()) {
                    newResultSubscription.Count__c = (String.isBlank(tr.count) || tr.count == null)? null : Decimal.valueOf(tr.count);
                    newResultSubscription.State__c =  tr.state;
                    newResultSubscription.County__c = tr.county;
                    newResultSubscription.Subscription__c = listSubscriptions[0].Id;
                    insert as user newResultSubscription;
                }
                Lmg_SoldData_bch batchInstance = new Lmg_SoldData_bch(tr.records,newResultSubscription.Id );
                Database.executeBatch(batchInstance, 2000);
                
            }else if(listSubscriptions.size() <= 0 && !String.isBlank(tr.county) && (tr.records.size()) > 0){
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf('{"message": "State And County Not Subscribed:'+tr.state+' And '+tr.county+'"}');
                if (Schema.sObjectType.ErrorHandlerLmr__c.isCreateable() &&
                    Schema.sObjectType.ErrorHandlerLmr__c.fields.ProcessName__c.isUpdateable() &&
                    Schema.sObjectType.ErrorHandlerLmr__c.fields.LogDetail__c.isUpdateable() ) {
                    insert as user insertErrorHandler('Sold Data Issue','County And State Not Subscribed.');
                }
            }else{
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf('{"message": "Bad Request."}');
                if (Schema.sObjectType.ErrorHandlerLmr__c.isCreateable() &&
                    Schema.sObjectType.ErrorHandlerLmr__c.fields.ProcessName__c.isUpdateable() &&
                    Schema.sObjectType.ErrorHandlerLmr__c.fields.LogDetail__c.isUpdateable() ) {
                    insert as user insertErrorHandler('Sold Data Issue','Error With Data.');
                }
            }

            }else{
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf('{"message": "Token not Valid."}');
                if (Schema.sObjectType.ErrorHandlerLmr__c.isCreateable() &&
                    Schema.sObjectType.ErrorHandlerLmr__c.fields.ProcessName__c.isUpdateable() &&
                    Schema.sObjectType.ErrorHandlerLmr__c.fields.LogDetail__c.isUpdateable() ) {
                    insert as user insertErrorHandler('Sold Data Issue','Token not Valid.');
                }
            }
       }catch(Exception e){
        // If newResultSubscription was not inserted, attempt to insert it here
        if (newResultSubscription != null && newResultSubscription.Id == null) {
            if (Schema.sObjectType.Result_Subscription__c.isCreateable() &&
                Schema.sObjectType.Result_Subscription__c.fields.Count__c.isUpdateable() &&
                Schema.sObjectType.Result_Subscription__c.fields.State__c.isUpdateable() &&
                Schema.sObjectType.Result_Subscription__c.fields.County__c.isUpdateable() &&
                Schema.sObjectType.Result_Subscription__c.fields.Subscription__c.isUpdateable()) {
                insert as user newResultSubscription;
            }
        }

        // Relate file with the record
       // Lmg_Utilities_cls.generateFileAndRelate(newResultSubscription.Id,bodyReceived);

        RestContext.response.statusCode = 400; // Bad Request
        RestContext.response.responseBody = Blob.valueOf('{"error": "Bad Request: ' + e.getMessage() + '"}');
        System.debug('number: '+e.getLineNumber());
        try{
            ErrorHandlerLmr__c transactionLog = new ErrorHandlerLmr__c  (
                LogDetail__c = e.getStackTraceString() +';'+ '<br/> <strong> Mensaje es: </strong>'+e.getMessage() +';'
                + '<br/>'+ e.getCause() +';'+ '<br/>'+ e.getTypeName() +';'+ '<br/>' +'Linea es: '+ e.getLineNumber(),
                ProcessName__c  = 'LeadFuzion'
            );
            if (Schema.sObjectType.ErrorHandlerLmr__c.isCreateable()) {
                insert as user transactionLog;
            }
        } catch(Exception ex) {
            System.debug('Error is'+ex);
        }
           
       }
            
    }

    public static ErrorHandlerLmr__c insertErrorHandler(String processName, String logDetail){
        Left_Main__ErrorHandlerLmr__c errorHanlder = new ErrorHandlerLmr__c();
        if (Schema.sObjectType.ErrorHandlerLmr__c.fields.ProcessName__c.isUpdateable() &&
            Schema.sObjectType.ErrorHandlerLmr__c.fields.LogDetail__c.isUpdateable()) {
            errorHanlder.ProcessName__c = processName;
            errorHanlder.LogDetail__c = logDetail;
        }
        return errorHanlder;
    }
    public static void insertBulkRecords(List<LeadfuzionRecord> records,String resultSubscription) {
        if (records == null || records.isEmpty()) return;

        List<Property_SalesAI__c > sales = new List<Property_SalesAI__c >();
        Map<String, Property__c> propertiesMap = new Map<String, Property__c>();
        Map<String, Property_SalesAI__c> salesTempMap = new Map<String, Property_SalesAI__c>();

        for (LeadfuzionRecord record : records) {
            // Check if the property is already in the map, if not, add it
            if (!propertiesMap.containsKey(record.lfid)) {
                Property__c property = new Property__c();
                property.ExternalId__c = record.lfid;
                property.State__c = record.analytics_property_state;
                property.County__c = record.analytics_property_county;
                property.Zip_Code__c = record.analytics_property_zip;
                property.City__c = record.analytics_property_city;
                property.Street__c = record.analytics_property_street;
                propertiesMap.put(record.lfid, property);
            }

            // Create the sale record with a placeholder for Property__c relationship
            Property_SalesAI__c  sale = new Property_SalesAI__c();
                sale.Seller_First_Name__c  = record.seller_first_name;
                sale.Seller_Last_Name__c  = record.seller_last_name;
                sale.Estimated_Value__c = (String.isBlank(record.estimated_value) || record.estimated_value == null)? null : Decimal.valueOf(record.estimated_value);
                sale.Property_Address__c = record.property_address;
                sale.State__c  = record.analytics_property_state;
                sale.County__c  = record.analytics_property_county;
                sale.Zip_Code__c  = record.analytics_property_zip;
                sale.City__c  = record.analytics_property_city;
                sale.Street__c  = record.analytics_property_street;
               	sale.Recording_Date__c = (String.isBlank(record.recording_date) || record.recording_date == null)? null : dateParserMethod(record.recording_date);
                sale.Sales_Price__c  = (String.isBlank(record.sales_price) || record.sales_price == null)? null : Decimal.valueOf(record.sales_price);
                sale.Taxed_Assessed_Value__c  = (String.isBlank(record.tax_assessed_value) || record.tax_assessed_value == null)? null : Decimal.valueOf(record.tax_assessed_value);
                sale.Status__c = record.status;
                sale.Buyer_First_Name__c  = record.buyer_first_name;
                sale.Buyer_Last_Name__c  = record.buyer_last_name;
                sale.Buyer_Mailing_Address__c  = record.buyer_mailing_address;
                sale.External_Id__c = record.lfid +sale.Recording_Date__c;
                sale.Subscription_Results__c = resultSubscription;

                salesTempMap.put(record.lfid, sale);
        }
    
        // Bulk upsert Property__c records to get their Ids
        upsert propertiesMap.values() ExternalId__c;

        for (String lfid : salesTempMap.keySet()) {
            Property_SalesAI__c sale = salesTempMap.get(lfid);
            sale.Property__c = propertiesMap.get(lfid).Id;
            sales.add(sale);
        }
            propertiesMap.clear();
            if (Schema.sObjectType.Property_SalesAI__c.isCreateable() && Schema.sObjectType.Property_SalesAI__c.isUpdateable()) {
                upsert sales External_Id__c;
            }
            sales.clear();
    }

    global class LeadfuzionWrapper {
        public String lf_subscription_id;
        public String count;
        public String state;
        public String county;
        public String custom;
        public String jobid;
        public List<LeadfuzionRecord> records;
    }
    global class LeadfuzionRecord {
        public String lfid;
        public String seller_first_name;
        public String seller_last_name;
        public String buyer_first_name;
        public String buyer_last_name;
        public String buyer_mailing_address;
        public String estimated_value;
        public String previous_seller;
        public String previous_seller_mailing_address;
        public String property_address;
        public String analytics_property_state;
        public String analytics_property_county;
        public String analytics_property_zip;
        public String analytics_property_city;
        public String analytics_property_street;
        public String recording_date;
        public String sales_price;
        public String tax_assessed_value;
        public String status;
    }
    
    private static Date dateParserMethod(String dateString){
        List<String> dateComponents = dateString.split('/');
        if (dateComponents.size() == 3) {
            Integer month = Integer.valueOf(dateComponents[0]);
            Integer day = Integer.valueOf(dateComponents[1]);
            Integer year = Integer.valueOf(dateComponents[2]);
            // Create a Date instance using the parsed components
            Date parsedDate = Date.newInstance(year, month, day);
            
            // Output the parsed date to verify correctness
            return parsedDate;
        } else {
            System.debug('Invalid date format');
            return null;
        }
    }

}