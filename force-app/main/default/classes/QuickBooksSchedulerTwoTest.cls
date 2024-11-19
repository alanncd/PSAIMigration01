@isTest
private class QuickBooksSchedulerTwoTest {

  @isTest
  static void testScheduleQuickBooksJob() {
      System.debug('first assert');
    Test.startTest();
     
    // Call the method to be tested
    List<Boolean> result = QuickBooksSchedulerTwo.scheduleQuickBooksJob();

    // Perform assertions to verify the expected behavior
    System.assert(result.size() > 0, 'There should be two job statuses in the result list');


    Test.stopTest();
  }
}