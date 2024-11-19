public class ExecuteBatchNowCadenceTasks {
    public static void executeBatch(List<Id> listTasks ){
        Set<Id> taskIdSet = new Set<Id>(listTasks);
        if(!System.isFuture() && !System.isBatch()){
            BatchNowCadenceTasks batchTasks = new BatchNowCadenceTasks(taskIdSet);
            Database.executeBatch(batchTasks, 1);
        }
    }
}