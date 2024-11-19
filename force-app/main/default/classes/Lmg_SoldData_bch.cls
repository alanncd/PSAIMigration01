public without sharing class Lmg_SoldData_bch implements Database.Batchable<Lmg_SoldData_cls.LeadfuzionRecord> {
    
    private List<Lmg_SoldData_cls.LeadfuzionRecord> recordsBatch;
    private final String subscriptionResultId;

    public Lmg_SoldData_bch(List<Lmg_SoldData_cls.LeadfuzionRecord> records,String subscriptionResultId) {
        this.recordsBatch = records;
        this.subscriptionResultId = subscriptionResultId;
    }

    public Iterable<Lmg_SoldData_cls.LeadfuzionRecord> start(Database.BatchableContext BC) {
        return recordsBatch;
    }

    public void execute(Database.BatchableContext BC, List<Lmg_SoldData_cls.LeadfuzionRecord> scope) {

        try{
        Lmg_SoldData_cls.insertBulkRecords(scope,subscriptionResultId);
        }catch(Exception e){
            insert Lmg_SoldData_cls.insertErrorHandler('Sold Data Import',''+e);

        }
    
        }

    public void finish(Database.BatchableContext BC) {
        // Optional: Log completion or perform follow-up actions
    }

}