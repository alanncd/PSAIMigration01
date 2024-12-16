/**
 * @description Batch class to process and insert lead data records into the system.
 *              Implements the Database.Batchable interface for batch processing.
 * @class Lmg_SoldData_bch
 */
public with sharing class Lmg_SoldData_bch implements Database.Batchable<Lmg_SoldData_cls.LeadfuzionRecord> {
    
    private List<Lmg_SoldData_cls.LeadfuzionRecord> recordsBatch;
    private final String subscriptionResultId;

    /**
     * @description Constructor for the batch class.
     * @param records List of LeadfuzionRecord objects to process in the batch.
     * @param subscriptionResultId The ID associated with the subscription result.
     */

    public Lmg_SoldData_bch(List<Lmg_SoldData_cls.LeadfuzionRecord> records,String subscriptionResultId) {
        this.recordsBatch = records;
        this.subscriptionResultId = subscriptionResultId;
    }

    /**
     * @description Prepares the batch process by returning the iterable list of records to process.
     * @param bc The BatchableContext instance provided by the batch framework.
     * @return An iterable list of LeadfuzionRecord objects to process in the batch.
     */

    public Iterable<Lmg_SoldData_cls.LeadfuzionRecord> start(Database.BatchableContext bc) {
        return recordsBatch;
    }

    /**
     * @description Processes the batch by inserting lead records in bulk and handling errors.
     * @param bc The BatchableContext instance provided by the batch framework.
     * @param scope A list of LeadfuzionRecord objects for the current batch scope.
     */
    public void execute(Database.BatchableContext bc, List<Lmg_SoldData_cls.LeadfuzionRecord> scope) {

        try{
        Lmg_SoldData_cls.insertBulkRecords(scope,subscriptionResultId);
        }catch(Exception e){
            insert Lmg_SoldData_cls.insertErrorHandler('Sold Data Import',''+e);
        }
        }
        
    /**
     * @description Finalizes the batch process. Can be used for post-processing steps if required.
     * @param bc The BatchableContext instance provided by the batch framework.
     */
    public void finish(Database.BatchableContext bc) {}

}