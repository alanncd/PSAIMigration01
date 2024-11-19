global with sharing class BatchTransactionController implements Database.Batchable<sObject> , Database.Stateful {
    
    // Get transcation query and api name from Custom settings
    Transactions_Setting__c transacction = Transactions_Setting__c.getInstance();      
    String transactionQuery = transacction.TransactionQueryString__c;
    String transactionOppApi = transacction.OpportunityApiName__c;   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        LeftMain_SecurityUtils.checkRead( Transactions__c.SObjectType,new List<String> {
            'Id',
            'Name',
            'Opportunity__c'
        });
        return Database.getQueryLocator('SELECT '+transactionQuery+' WHERE CreatedDate = YESTERDAY LIMIT 5000000');
    }
     
     
    global void execute(Database.BatchableContext BC, List<sObject> transactionRecList) {
        Set<Id> newOppIdSet = new Set<Id>();
        Set<Id> newTransIdSet = new Set<Id>();
        
        // Create Id set of Transaction and related opportunity.
        for(sObject obj : transactionRecList) {
            if(obj.get(transactionOppApi) != null) {               
                newOppIdSet.add(String.valueOf(obj.get(transactionOppApi)));
                newTransIdSet.add(String.valueOf(obj.get('Id')));
            }           
        }
        if(newOppIdSet.size() > 0) {
            LeftMain_SecurityUtils.checkObjectIsReadable(ContentDocumentLink.SObjectType);
            Map<Id,List<ContentDocumentLink>> newOppFilesMap = new Map<Id,List<ContentDocumentLink>>();
            
            LeftMain_SecurityUtils.checkRead( ContentDocumentLink.SObjectType,new List<String> {
                'LinkedEntityId',
                'ContentDocumentId',
                'ShareType',
                'Id'
            });
            List<ContentDocumentLink> newOppFilesList = [SELECT LinkedEntityId,ContentDocumentId,ShareType,Id  FROM ContentDocumentLink WHERE LinkedEntityId IN :newOppIdSet ];
            
            // for mapping tansaction record and there file.
            for(ContentDocumentLink file : newOppFilesList) {
                if(newOppFilesMap.containsKey(file.LinkedEntityId)) {
                    List<ContentDocumentLink> fileList = newOppFilesMap.get(file.LinkedEntityId);
                    fileList.add(file);                    
                    newOppFilesMap.put(file.LinkedEntityId,fileList);
                } else {                    
                    newOppFilesMap.put(file.LinkedEntityId,new List<ContentDocumentLink> { file });
                }
            }     
            
            // for checking transaction record already have same file
            Map<Id,List<Id>> newTransExistingFilesMap = new Map<Id,List<Id>>();
            List<ContentDocumentLink> newTransExistingFilesList = [SELECT LinkedEntityId,ContentDocumentId,ShareType,Id  FROM ContentDocumentLink WHERE LinkedEntityId IN :newTransIdSet];
            for(ContentDocumentLink file : newTransExistingFilesList) {
                if(newTransExistingFilesMap.containsKey(file.LinkedEntityId)) {
                    List<Id> fileList = newTransExistingFilesMap.get(file.LinkedEntityId);
                    fileList.add(file.ContentDocumentId);                    
                    newTransExistingFilesMap.put(file.LinkedEntityId,fileList);
                } else {                    
                    newTransExistingFilesMap.put(file.LinkedEntityId,new List<Id> { file.ContentDocumentId });
                }
            }
           
            List<ContentDocumentLink> listToInsert = new List<ContentDocumentLink>();
            // Create ContentDoucmentLink record and linked with transaction.
            for(sObject obj : transactionRecList) {
                if(obj.get(transactionOppApi) != null && newOppFilesMap.containsKey(String.valueOf(obj.get(transactionOppApi)))) { 
                    for(ContentDocumentLink file : newOppFilesMap.get(String.valueOf(obj.get(transactionOppApi)))) { 
                        List<Id> transactionExistingFileList;
                        if(newTransExistingFilesMap.containsKey(String.valueOf(obj.get('Id')))) {
                            transactionExistingFileList  =  newTransExistingFilesMap.get(String.valueOf(obj.get('Id')));
                            if(!(transactionExistingFileList.contains(file.ContentDocumentId))) {                           
                                ContentDocumentLink cdl = New ContentDocumentLink(); cdl.LinkedEntityId = String.valueOf(obj.get('Id')); cdl.ContentDocumentId = file.ContentDocumentId;
                                cdl.shareType = file.shareType;  listToInsert.add(cdl);
                            }   
                        } else {
                            ContentDocumentLink cdl = New ContentDocumentLink(); cdl.LinkedEntityId = String.valueOf(obj.get('Id')); cdl.ContentDocumentId = file.ContentDocumentId;
                            cdl.shareType = file.shareType;  listToInsert.add(cdl);
                        }                    
                    }                               
                }                 
            }            
            if(listToInsert.size() > 0) {
                LeftMain_SecurityUtils.checkInsert(ContentDocumentLink.SObjectType,new List<String> {
                    'LinkedEntityId',
                    'ContentDocumentId',
                    'ShareType'
                });
                
                SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, listToInsert);
                listToInsert = decision3.getRecords();
                Database.insert(listToInsert);
            }
        }      
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}