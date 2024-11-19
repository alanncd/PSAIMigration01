public without sharing class TransactionTriggerHelper {
    public static void upsertTransactionRecordMethod(List<Transactions__c > newTranactionRecList) {
        
        LeftMain_SecurityUtils.checkRead(Transactions__c.SObjectType,new List<String> {
            'Opportunity__c'
        });

        Set<Id> newOppIdSet = new Set<Id>();
        for(Transactions__c  newRecord : newTranactionRecList) {
            if(newRecord.Opportunity__c != null) {
                newOppIdSet.add(newRecord.Opportunity__c );
            }
        }        
        
        if(newOppIdSet.size() > 0) {
            LeftMain_SecurityUtils.checkRead(ContentDocumentLink.SObjectType,new List<String> {
                'LinkedEntityId',
                'ContentDocumentId',
                'ShareType',
                'Id'
            });
            Map<Id,List<ContentDocumentLink>> newOppFilesMap = new Map<Id,List<ContentDocumentLink>>();
            List<ContentDocumentLink> newOppFilesList = [SELECT LinkedEntityId,ContentDocumentId,ShareType,Id  FROM ContentDocumentLink WHERE LinkedEntityId IN :newOppIdSet WITH USER_MODE];
            for(ContentDocumentLink file : newOppFilesList) {
                if(newOppFilesMap.containsKey(file.LinkedEntityId)) {
                    List<ContentDocumentLink> fileList = newOppFilesMap.get(file.LinkedEntityId);
                    fileList.add(file);                    
                    newOppFilesMap.put(file.LinkedEntityId,fileList);
                } else {                    
                    newOppFilesMap.put(file.LinkedEntityId,new List<ContentDocumentLink> { file });
                }
            }           
            
            List<ContentDocumentLink> listToInsert = new List<ContentDocumentLink>();
            for(Transactions__c record : newTranactionRecList) {
                if(record.Opportunity__c != null && newOppFilesMap.containsKey(record.Opportunity__c)) { 
                    for(ContentDocumentLink file : newOppFilesMap.get(record.Opportunity__c)) {                        
                        ContentDocumentLink cdl = New ContentDocumentLink();
                        cdl.LinkedEntityId = record.Id;
                        cdl.ContentDocumentId = file.ContentDocumentId;
                        cdl.shareType = file.shareType; 
                        listToInsert.add(cdl);
                    }                               
                }                 
            }
            if(listToInsert.size() > 0) {
                LeftMain_SecurityUtils.checkInsert(ContentDocumentLink.SObjectType,new List<String> {
                    'LinkedEntityId',
                    'ContentDocumentId',
                    'ShareType'
                });
                SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.CREATABLE, listToInsert);
                Database.insert(listToInsert = decision1.getRecords());
            }
            
            LeftMain_SecurityUtils.checkRead(FeedItem.SObjectType,new List<String> {
                'Id',
                'ParentId',
                'Type',
                'Body',
                'LinkUrl',
                'IsRichText',
                'RelatedRecordId'
            });

            //Copying chatter posts from Opportunity to Transaction record
            system.debug('newOppIdSet::'+newOppIdSet);
            Map<Id,List<FeedItem>> newFeedItemMap = new Map<Id,List<FeedItem>>();
            List<FeedItem> newOppFeedItemList = [SELECT Id, ParentId, Type, Body, Title, LinkUrl, IsRichText, RelatedRecordId FROM FeedItem 
                                                 WHERE ParentId IN :newOppIdSet]; // WITH USER_MODE
            for(FeedItem feed : newOppFeedItemList) {
                if(newFeedItemMap.containsKey(feed.ParentId)) {
                    List<FeedItem> feedList = newFeedItemMap.get(feed.ParentId);
                    feedList.add(feed);                    
                    newFeedItemMap.put(feed.ParentId,feedList);
                } else {                    
                    newFeedItemMap.put(feed.ParentId,new List<FeedItem> { feed });
                }
            }           
            
            List<FeedItem> feedItemToInsertList = new List<FeedItem>();
            for(Transactions__c record : newTranactionRecList) {
                if(record.Opportunity__c != null && newFeedItemMap.containsKey(record.Opportunity__c)) { 
                    for(FeedItem feed : newFeedItemMap.get(record.Opportunity__c)) {                        
                        if(feed.Body != null && feed.Body != '')
                        {
                            FeedItem post = new FeedItem();
                            post.ParentId = record.Id; 
                            post.Body = (feed.Body).replaceAll('<[^>]+>',' ');
                            feedItemToInsertList.add(post);
                        }
                    }                               
                }                 
            }
            if(feedItemToInsertList.size() > 0) {
                LeftMain_SecurityUtils.checkInsert(FeedItem.SObjectType,new List<String> {
                    'ParentId',
                    'Body'
                });
                SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.CREATABLE, feedItemToInsertList);
                Database.insert(feedItemToInsertList = decision2.getRecords());

            }
            
        }
    }
    public static void twnsqrAction(List<Transactions__c > trxLst,List<Transactions__c > trxLstOld) {
        String action1='PostDeal';
        String action2='PutUnSync';
        String action3='PutReSync';
        system.debug(trxLstOld);
        system.debug(trxLst[0].Twnsqr_Sync__c);
        system.debug(trxLst[0].Twnsqr_clientId__c);
        if(trxLst[0].Twnsqr_Sync__c==TRUE && (trxLst[0].Twnsqr_clientId__c=='' || trxLst[0].Twnsqr_clientId__c ==NULL)){
			twnsqrCallout(trxLst[0].Id,action1);
        }
        else if(trxLstOld != NULL && trxLst[0].Twnsqr_Sync__c==FALSE && trxLstOld[0].Twnsqr_Sync__c==TRUE && trxLst[0].Twnsqr_clientId__c!=''){
			twnsqrCallout(trxLst[0].Id,action2);            
        }        
        else if(trxLstOld != NULL && trxLst[0].Twnsqr_Sync__c==TRUE && trxLstOld[0].Twnsqr_Sync__c==FALSE && trxLst[0].Twnsqr_clientId__c!=''){
			twnsqrCallout(trxLst[0].Id,action3);            
        }

        
    }
    @future(callout=TRUE)
    public static void twnsqrCallout(String ids,String method){
       Transactions__c t =[Select Id,Dispo_Notes__c,Contract_Purchase_Price__c,Street_Address__c,City__c,State__c,Zipcode__c,
                           Dispositions_Rep__r.Name,Dispositions_Rep__r.phone,Dispositions_Rep__r.email,Owner.Name, Opportunity__r.Comp_1__c,
                           Opportunity__r.Comp_2_Address_Bed_Bath_Sqft__c,Opportunity__r.Comp_3_Address_Bed_Bath_Sqft__c,
                           Owner.phone,Owner.email,LastModifiedBy.Name,LastModifiedBy.phone,LastModifiedBy.email,Photo_Link__c 
                           From Transactions__c Where Id=:ids WITH USER_MODE];
        if(method=='PostDeal'){
            TwnsqrCallOut.TwnsqrPostDeal(t);
        }
        if(method=='PutReSync'){
			TwnsqrCallOut.TwnsqrPutDeal(t,'RECHECK');
        }
        if(method=='PutUnSync'){
			TwnsqrCallOut.TwnsqrPutDeal(t,'UNCHECK');
        }        
    }
    
    
    /*
    public static void upsertTransactionAllTask(List<Transactions__c > newTranactionRecList,Map<ID,Transactions__c> oldMap) {
         Set<Id> newTransacIdSet = new Set<Id>();
        for(Transactions__c  newRecord : newTranactionRecList) {
            if(newRecord.Path__c != null &&  oldMap != null && 
                oldMap.containsKey(newRecord.Id) && 
                oldMap.get(newRecord.Id).Path__c != newRecord.Path__c && 
                newRecord.Path__c == 'Contract Cancelled/Lost' ) {
                newTransacIdSet.add(newRecord.Id);
            }
        }   

        List<task> taskList = [SELECT Id, WhatId, Status FROM Task Where WhatId IN :newTransacIdSet];

        if(!taskList.isEmpty()){ 
            List<String> taskClosedStatusSet = new List<String>();
            for(TaskStatus ts: [select ApiName from TaskStatus WHERE IsClosed=TRUE]){
                taskClosedStatusSet.add(ts.ApiName);
            }
            for(Task taskObj : taskList){
                if(taskClosedStatusSet != null && !taskClosedStatusSet.isEmpty()){
                    taskObj.Status = taskClosedStatusSet[0];
                }
            } 
            update taskList;
        }
    } */
}