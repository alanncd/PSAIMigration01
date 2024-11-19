global with sharing class Lmr_BatchDeleteErrors implements Database.batchable<sObject>{
    global String sQuery;

    global Lmr_BatchDeleteErrors( String sQuery){
        this.sQuery = sQuery;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
    
        return Database.getQueryLocator( sQuery );

    }
    global void execute(Database.BatchableContext BC, List<sObject> lstObj){
        Id idSobjectValidation;
        for(sObject record: lstObj){
            idSobjectValidation = record.Id;
        }
        LeftMain_SecurityUtils.checkObjectIsDeletable(idSobjectValidation.getSobjectType());
        Database.delete(lstObj, AccessLevel.User_mode);

    }

    global void finish(Database.BatchableContext bc){

    }
}