public with sharing class Lmg_Utilities_cls {

    public static void generateFileAndRelate(Id recordId, String body){

        String generatedCSVFile ='';

        String fileRow = 'lf_subscription_id,county,state,jobid,lfid,seller_first_name,seller_last_name,Estimated_Value__c,Property_Address__c,State__c,County__c,Zip_Code__c,City__c,Street__c,Recording_Date__c,Sales_Price__c,Taxed_Assessed_Value__c,Status__c,Buyer_First_Name__c,Buyer_Last_Name__c,Buyer_Mailing_Address__c';


         generatedCSVFile = fileRow + '\n';

         Lmg_SoldData_cls.LeadfuzionWrapper tr = (Lmg_SoldData_cls.LeadfuzionWrapper)JSON.deserialize(body, Lmg_SoldData_cls.LeadfuzionWrapper.class);

         for(Lmg_SoldData_cls.LeadfuzionRecord iterate : tr.records){

            fileRow = '';
            fileRow = fileRow + tr.lf_subscription_id;
            fileRow = fileRow +','+ tr.county;
            fileRow = fileRow +','+ tr.state;
            fileRow = fileRow +','+ tr.jobid;
            fileRow = fileRow +','+ iterate.lfid;
            fileRow = fileRow +','+iterate.seller_first_name;
            fileRow = fileRow +','+ iterate.seller_last_name;
            fileRow = fileRow +','+ iterate.estimated_value;
            fileRow = fileRow +','+ iterate.property_address;
            fileRow = fileRow +','+ iterate.analytics_property_state;
            fileRow = fileRow +','+ iterate.analytics_property_county;
            fileRow = fileRow +','+ iterate.analytics_property_zip;
            fileRow = fileRow +','+ iterate.analytics_property_city;
            fileRow = fileRow +','+ iterate.analytics_property_street;
            fileRow = fileRow +','+ iterate.recording_date;
            fileRow = fileRow +','+ iterate.sales_price;
            fileRow = fileRow +','+ iterate.tax_assessed_value;
            fileRow = fileRow +','+ iterate.status;
            fileRow = fileRow +','+ iterate.buyer_first_name;
            fileRow = fileRow +','+ iterate.buyer_last_name;
            fileRow = fileRow +','+ iterate.buyer_mailing_address;

            generatedCSVFile = generatedCSVFile + fileRow + '\n';
         }
        // Convert CSV to Blob
        Blob csvBlob = Blob.valueOf(generatedCSVFile);

        // Define file name and relate it to a record
        ContentVersion contentVersionFile = new ContentVersion();
        contentVersionFile.Title = 'Leftmain Sold Data-'+tr.county+'-'+tr.lf_subscription_id;
        contentVersionFile.PathOnClient = 'Leftmain Sold Data-'+tr.county+'-'+tr.lf_subscription_id+'.csv';
        contentVersionFile.VersionData = csvBlob;
        contentVersionFile.FirstPublishLocationId = recordId;         // Relate to record (parentId)
        contentVersionFile.IsMajorVersion = true;
        if (Schema.sObjectType.ContentVersion.isCreateable()) {
            insert contentVersionFile;
        }
    }



}