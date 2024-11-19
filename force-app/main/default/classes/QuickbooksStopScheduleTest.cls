@isTest
private class QuickbooksStopScheduleTest {

  @isTest
  static void testStopQuickbookScheduler() {
    // Test data setup (if needed)
    // ...

    Test.startTest();

    // Call the method to be tested
    List<Boolean> result = QuickbooksStopSchedule.stopQuickbookScheduler();

    // Perform assertions to verify the expected behavior
    //System.assertEquals(1, result.size(), 'There should be one boolean result in the list');
      System.assert(result.size() > 0, 'There should be two job statuses in the result list');
    
    //System.assert(result[0], 'At least one job should have been stopped');

    // Additional assertions based on the specific behavior of your method

    Test.stopTest();
  }
    
     @isTest
  static void testStopQuickbookSchedulerTrue() {
    // Test data setup (if needed)
    // ...

    Test.startTest();

    QuickBooksSchedulerTwo.scheduleQuickBooksJob();
    // Call the method to be tested
    List<Boolean> result = QuickbooksStopSchedule.stopQuickbookScheduler();

    // Perform assertions to verify the expected behavior
    //System.assertEquals(1, result.size(), 'There should be one boolean result in the list');
      System.assert(result.size() > 0, 'There should be two job statuses in the result list');
    
    //System.assert(result[0], 'At least one job should have been stopped');

    // Additional assertions based on the specific behavior of your method

    Test.stopTest();
  }
}