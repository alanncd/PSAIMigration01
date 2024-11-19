@isTest
public class Lmr_SmrtPhoneScheduled_schTest {

    // Test method
    @isTest
    static void testExecuteMethod() {
        // Create an instance of the schedulable class
        Lmr_SmrtPhoneScheduled_sch scheduledJob = new Lmr_SmrtPhoneScheduled_sch('1','1');
        
        // You can set values to the public variables if needed
        scheduledJob.scheduledRecordId = 'testRecordId';
        scheduledJob.scheduledSmsTemplate = 'testTemplate';

        // Schedule the job and run the execute method
        String cronExpression = '0 0 12 * * ?'; // Example cron expression to schedule at noon every day
        String jobId = System.schedule('Test Scheduled Job Lmr_SmrtPhoneScheduled_sch', cronExpression, scheduledJob);
        
        // Now validate that the job was scheduled properly
        System.assertNotEquals(null, jobId, 'Job was not scheduled properly.');

        // Simulate the execution of the job
        Test.startTest();
        // Trigger the execution by calling the execute method manually
        scheduledJob.execute(null);
        Test.stopTest();

        // Since there is only a debug statement, there's nothing more to assert, 
        // but this ensures that the execute method runs without errors.
    }
}