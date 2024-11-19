public with sharing class ExecuteBatchCalloutCadenceSMS {
    public static void executeBatch(List<Id> listSMS ){
        Set<Id> smsIdSet = new Set<Id>(listSMS);
        if(!System.isFuture() && !System.isBatch()){
            BatchCalloutCadenceSMS batchSMS = new BatchCalloutCadenceSMS(smsIdSet);
            Database.executeBatch(batchSMS, 1);
        }
    }
}