@isTest
private class BatchTransactionControllerTest {
    static Opportunity createOpportunity(Boolean doInsert) {

        Opportunity oppRec = new Opportunity(Name = 'Test Opp', StageName = 'Pending Appointment',CloseDate = System.today()+ 7);        
        if(doInsert) {
            insert oppRec; 
        } 
        return oppRec;        
    }
    
    static ContentDocumentLink createContentDocumentLink(Boolean doInsert,sObject record) {
        
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
    
    static ContentDocumentLink createContentDocumentLink1(Boolean doInsert,sObject record) {
        //Create Document 
        ContentVersion cversion = new ContentVersion();
        cversion.Title = 'Test Document1';
        cversion.PathOnClient = 'TestDocument1.pdf';
        cversion.VersionData = Blob.valueOf('Test Content123');
        cversion.IsMajorVersion = true;
        Insert cversion;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cversion.Id].ContentDocumentId;
        
        ContentDocumentLink cdll = New ContentDocumentLink();
        cdll.LinkedEntityId = record.Id;
        cdll.ContentDocumentId = conDocId;
        cdll.shareType = 'V'; //Viewer premission. The user can explicitly view but not edit the shared file.        
        if(doInsert) {
            insert cdll;
        }
        return cdll;              
    }
    
    @testsetup
    static void insertRecords() {
        Transactions_Setting__c setting = new Transactions_Setting__c();
        setting.OpportunityApiName__c = 'Opportunity__c';
        setting.TransactionApiName__c = 'Transactions__c';
        setting.TransactionQueryString__c = 'Id,Name,Opportunity__c FROM Transactions__c';        
        insert setting;
        
        Opportunity oppRec = createOpportunity(true);        
        ContentDocumentLink cdl = createContentDocumentLink(true, oppRec);
        ContentDocumentLink cdl1 = createContentDocumentLink(true, oppRec);
        ContentDocumentLink cdl2 = createContentDocumentLink(true, oppRec);
        
        List<Transactions__c> transList = new List<Transactions__c>();       
        transList.add(new Transactions__c(Name='Testt',Contract_Purchase_Price__c = 500 ,
                                                     Closing_Date__c = System.today()+ 7,Remote_Closing__c = 'No',Closing_Attorney__c = 'Other'
                                                     ,Disposition_Decision__c = 'Pending',Opportunity__c = oppRec.Id,
                                                     Path__c = 'New Contract')); 
        insert transList;   
        Date d1 = System.today().addDays(-1);
        for(Transactions__c c1 : transList){
            Test.setCreatedDate(c1.Id, dateTime.newInstance(date.newInstance(d1.year(), d1.month(), d1.day()), time.newInstance(00, 00, 00, 00)));  
        } 
    }
    
    @isTest
    static void schedular() 
    {
        Transactions__c transactions = [SELECT ID FROM Transactions__c];
        List<ContentDocumentLink> cdlLink = [SELECT ID  FROM ContentDocumentLink WHERE LinkedEntityId =: transactions.Id LIMIT 1];
        delete cdlLink;
        Test.startTest();
            String cronExp = '0 0 12 1/1 * ? *';
            String jobId = System.schedule('BatchTransactionControllerSchedular',
                                           cronExp, 
                                           new BatchTransactionControllerSchedular());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(cronExp,  ct.CronExpression,'');
            System.assertEquals(0, ct.TimesTriggered,'');
       
        Test.stopTest(); 
    }
    /*
    @isTest
    static void testExecuteBatch() {        
        BatchTransactionController uca = new BatchTransactionController();
        Id batchId = Database.executeBatch(uca);
        System.assertNotEquals(null, batchId);
    }
    
  
    @isTest
    static void testTransactionRecordHaveFile() {
        
        Opportunity oppRec = createOpportunity(true);        
        ContentDocumentLink cdl = createContentDocumentLink(true, oppRec);
        ContentDocumentLink cdl1 = createContentDocumentLink1(true, oppRec);
        
        List<Transactions__c> transList = new List<Transactions__c>();       
        transList.add(new Transactions__c(Name='Testt',Contract_Purchase_Price__c = 500 ,
                                                     Closing_Date__c = System.today()+ 7,Remote_Closing__c = 'No',Closing_Attorney__c = 'Other'
                                                     ,Disposition_Decision__c = 'Pending',Opportunity__c = oppRec.Id,Path__c = 'New Contract')); 
        insert transList;    
        Date d1 = System.today().addDays(-1);
        for(Transactions__c c1 : transList){
            Test.setCreatedDate(c1.Id, dateTime.newInstance(date.newInstance(d1.year(), d1.month(), d1.day()), time.newInstance(00, 00, 00, 00)));  
        } 
        ContentDocumentLink cdl3 = createContentDocumentLink(true, transList[0]);
        
        Test.startTest();
            BatchTransactionController uca = new BatchTransactionController();
            Id batchId = Database.executeBatch(uca);
            System.assertNotEquals(null, batchId);
        Test.stopTest();
    }
    */
}