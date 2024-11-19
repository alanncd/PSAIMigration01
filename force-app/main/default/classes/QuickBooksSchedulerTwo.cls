public with sharing class QuickBooksSchedulerTwo {
  @InvocableMethod(label='Schedule QuickBooks Job')
  public static List<Boolean> scheduleQuickBooksJob() {
      System.debug('test');
    List<QuickBooks_Config__mdt> quickbookSchedule = [
      SELECT Id, Schedule_Quickbook__c
      FROM QuickBooks_Config__mdt
      WHERE Label = 'QuickBooks Config'
      WITH USER_MODE
      LIMIT 1
    ];

    // Default cron expression for fallback scheduling
    String sch = '20 30 8 * * ?'; // 8:30 AM as a fallback time
    String schV = '20 30 10 * * ?';

    List<Boolean> results = new List<Boolean>();
    System.debug('el list del quickbook' + quickbookSchedule);

    if (
      !quickbookSchedule.isEmpty() &&
      quickbookSchedule[0].Schedule_Quickbook__c != null) {Datetime timeScheduled = quickbookSchedule[0].Schedule_Quickbook__c;
      // Extract hour and minute from the Datetime object
      String hour = String.valueOf(timeScheduled.hour());
      String minAux = String.valueOf(timeScheduled.minute() + 10);
      String minute = String.valueOf(timeScheduled.minute());

      // Form the cron expression using the extracted time
      sch = '0 ' + minute + ' ' + hour + ' * * ?'; // Seconds set to 0 for scheduling
      schV = '0 ' + minAux + ' ' + hour + ' * * ?'; // Seconds set to 0 for scheduling
    }
    System.debug('lo que viy agregar ' + sch);
    QuickBooksController qbc = new QuickBooksController();
    // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    String jobID = System.schedule('get Quickbooks Job', sch, qbc);

    VendorRefreshBatch vend = new VendorRefreshBatch();
    String jobIDV = System.schedule('Refresh Vendor Batch', schV, vend);

    // Store the job ID in a custom object or return it in some way
    // For simplicity, you can log it or return it as a debug message
    System.debug('Scheduled Job ID: ' + jobID);
    // Check if both job IDs are not null
    Boolean aux = (jobID != null && jobIDV != null);

    // Return the result as a List<String>
    return new List<Boolean>{ aux };
  }
}