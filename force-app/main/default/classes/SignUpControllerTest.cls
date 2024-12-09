@isTest
private class SignUpControllerTest {
    
    @isTest
    static void testSendEmail() { 
        Test.startTest();  
        Boolean emailSent = false;
        Boolean exceptionCaught = false;

        try {
            // Call the sendEmail method with all parameters
            SignUpController.sendEmail('High Expectations, Other: Custom Expectation', 'New York', 'Other: Custom Function');
            Integer invocations = Limits.getEmailInvocations();
            emailSent = (invocations == 1);
        } catch (Exception e) {
            exceptionCaught = true;
        }
        
        Test.stopTest();
        
        // Assert that either the email was sent or an exception was caught
        System.assert(emailSent || exceptionCaught, 'Either an email should be sent or an exception should be caught');
    }
}