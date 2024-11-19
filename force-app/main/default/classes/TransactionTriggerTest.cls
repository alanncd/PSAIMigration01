@isTest
private class TransactionTriggerTest  {
    
    static Opportunity createOpportunity(Boolean doInsert) {
        Opportunity oppRec = new Opportunity(Name = 'Test Opp', StageName = 'Pending Appointment',
                                             CloseDate = System.today()+ 7,Obstacles_to_Setting_Appointment__c = 'None: Appointment Set. Boom!' , NextStep = 'go on appointment');        
        if(doInsert) {
            insert oppRec;
        }
        return oppRec;        
    }
    
    static ContentDocumentLink createContentDocumentLink(Boolean doInsert,Opportunity record) {
        TransactionTriggerSetting__c triggerTRRInstance = TransactionTriggerSetting__c.getOrgDefaults();
        triggerTRRInstance.Activate_Trigger__c = true;
        triggerTRRInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert triggerTRRInstance;  
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = record.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V'; //Viewer premission. The user can explicitly view but not edit the shared file.        
        if(doInsert) {
            insert cdl;
        }
        return cdl;        
    }    
    
    static FeedItem createChatterPost(Boolean doInsert,Opportunity record) {
        TransactionTriggerSetting__c triggerTRRInstance = TransactionTriggerSetting__c.getOrgDefaults();
        triggerTRRInstance.Activate_Trigger__c = true;
        triggerTRRInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert triggerTRRInstance;  
        //Create Chatter Post
        FeedItem post = new FeedItem();
        post.ParentId = record.Id; 
        post.Body = 'Test Chatter Body';
        insert post;
        
        return post;        
    }    
    
    @isTest
    static void testInsertRecordWithoutOpportunity() {
        TransactionTriggerSetting__c triggerTRRInstance = TransactionTriggerSetting__c.getOrgDefaults();
        triggerTRRInstance.Activate_Trigger__c = true;
        triggerTRRInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert triggerTRRInstance;  
        Transactions__c transRec = new Transactions__c(Name='Testt',Contract_Purchase_Price__c = 500 ,
                                                                             Closing_Date__c = System.today()+ 7,Remote_Closing__c = 'No',Closing_Attorney__c = 'Other'
                                                                             ,Disposition_Decision__c = 'Wholesale',Path__c = 'New Contract'); 
        insert transRec; 
        System.assertNotEquals(null,transRec);
    }
    
    @isTest
    static void testInsertRecordWithOpportunity() {
        TransactionTriggerSetting__c triggerTRRInstance = TransactionTriggerSetting__c.getOrgDefaults();
        triggerTRRInstance.Activate_Trigger__c = true;
        triggerTRRInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert triggerTRRInstance;    
        Opportunity oppRec = createOpportunity(true);        
        ContentDocumentLink cdl = createContentDocumentLink(true, oppRec);
		ContentDocumentLink cdl1 = createContentDocumentLink(true, oppRec); 
        FeedItem f1 = createChatterPost(true, oppRec); 
        FeedItem f2 = createChatterPost(true, oppRec); 
        Transactions__c transRec = new Transactions__c(Name='Testt',Contract_Purchase_Price__c = 500 ,Path__c = 'New Contract',
                                                                             Closing_Date__c = System.today()+ 7,Remote_Closing__c = 'No',Closing_Attorney__c = 'Other'
                                                                             ,Disposition_Decision__c = 'Wholesale',Opportunity__c = oppRec.Id); 
        insert transRec;  
        System.assertNotEquals(null,transRec);
    }
    
}