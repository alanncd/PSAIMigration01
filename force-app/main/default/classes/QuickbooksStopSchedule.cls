public with sharing class QuickbooksStopSchedule {
  @InvocableMethod(label='Stop Schedule Job Quickbooks')
  public static List<Boolean> stopQuickbookScheduler() {
    List<Boolean> result = new List<Boolean>();
    List<CronTrigger> cronTriggers = [
      SELECT
        Id,
        CronExpression,
        CronJobDetailId,
        CronJobDetail.Name,
        StartTime,
        State,
        EndTime
      FROM CronTrigger
      WHERE
        (CronJobDetail.Name = 'get Quickbooks Job'
        OR CronJobDetail.Name = 'Refresh Vendor Batch')
        AND EndTime = NULL
    ];

    if (!cronTriggers.isEmpty()) {
      for (CronTrigger job : cronTriggers) {
        System.abortJob(job.Id);
      }
      result.add(true);
    } else {
      result.add(false);
    }

    return result;
  }
}