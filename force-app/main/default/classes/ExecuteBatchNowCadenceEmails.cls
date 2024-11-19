public class ExecuteBatchNowCadenceEmails {
    public static void executeBatch(List<Id> listEmails ){
        Set<Id> emailIdSet = new Set<Id>(listEmails);
        if(!System.isFuture() && !System.isBatch()){
            BatchNowCadenceEmails batchSMS = new BatchNowCadenceEmails(emailIdSet);
            Database.executeBatch(batchSMS);
        }
    }
}