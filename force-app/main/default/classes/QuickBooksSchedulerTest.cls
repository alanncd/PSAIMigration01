@isTest
private class QuickBooksSchedulerTest {

  @isTest
  static void testScheduleQuickBooksJob() {
    Test.startTest();

    // Call the method to be tested
    //List<Boolean> result = QuickBooksScheduler.scheduleQuickBooksJob();
    String sch = '20 30 8 * * ?'; // 8:30 AM as a fallback time
    QuickBooksScheduler qsc = new QuickBooksScheduler();
    System.schedule('Test deprecatedJob', sch, qsc);
      //String jobID = 
    // Perform assertions to verify the expected behavior
    //System.assert(result.size() > 0, 'There should be two job statuses in the result list');
    //System.assertEquals(true, result[0], 'The first job should be scheduled successfully');
    //System.assertEquals(true, result[1], 'The second job should be scheduled successfully');

    // Additional assertions based on the specific behavior of your method

    Test.stopTest();
  }
}