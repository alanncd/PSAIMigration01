public with sharing class LeadAndOppMatchingScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        LeadAndOppMatchingBatch batchInstance = new LeadAndOppMatchingBatch();
        Database.executeBatch(batchInstance, 200);
    }
}