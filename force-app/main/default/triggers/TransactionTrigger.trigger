trigger TransactionTrigger on Transactions__c (after insert,after update) {
    
    //Check from custom setting that trigger is on or not.
    if(TransactionTriggerSetting__c.getOrgDefaults().Activate_Trigger__c) {
        if(Trigger.isInsert && Trigger.isAfter) {
            TransactionTriggerHelper.upsertTransactionRecordMethod(Trigger.new);
        }
    }
    //Deprecated Code - Twnsqr
    /*
    List<Twnsqr_Config__c> lstConfig = [Select Id, Sync__c From Twnsqr_Config__c LIMIT 10000];
    if(lstConfig.size()>0){
    if(lstConfig[0].Sync__c) {
        if(Trigger.isAfter && Trigger.isUpdate) {
            TransactionTriggerHelper.twnsqrAction(Trigger.new,Trigger.old);
        }
        if(Trigger.isAfter && Trigger.isInsert) {
            TransactionTriggerHelper.twnsqrAction(Trigger.new,null);
        }        
    }    }

*/
}