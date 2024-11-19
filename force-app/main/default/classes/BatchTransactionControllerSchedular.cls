global with sharing class BatchTransactionControllerSchedular implements Schedulable {
    global void execute(SchedulableContext ctx) {
        // Schedule batch process
        BatchTransactionController batch = new BatchTransactionController();
        Database.executeBatch(batch);
    }
}