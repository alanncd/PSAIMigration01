public with sharing class SignUpController {
    @AuraEnabled
    public static void sendEmail(String expectations, String places, String functionRole) {    
        // Get the current user's information
        User currentUser = [SELECT Name, Email, Phone FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
        Organization org = [SELECT Id, Name FROM Organization WITH SECURITY_ENFORCED LIMIT 1];
        String url = URL.getOrgDomainURL().toExternalForm();
        url += '/lightning/n/Property_Sales_AI_Sign_Up';
        // Fetch the email addresses from custom settings
        List<String> toAddresses = new List<String>{currentUser.Email};
    
        // Email 1: To the team
        List<String> teamToAddresses = new List<String>{'product@leftmainrei.com', 'success@leftmainrei.com', 'jennie@leftmainrei.com'};
        String teamEmailBody = 'Dear Team,<br><br>' +
            'A new user has expressed interest in Property Sales AI. The user\'s questionnaire responses are listed below:<br><br>' +
            '<b>Business Improvement Goals:</b> ' + expectations + '<br>' +
            '<b>Primary Team Function:</b> ' + functionRole + '<br>' +
            '<b>Referral Source:</b> ' + places + '<br><br>' +
            '<b>User Contact Information:</b><br>' +
            '<ul style="margin-left: 0.5em; padding-left: 0;">' + // Adjust margins and padding
            '<li><b>Name:</b> ' + currentUser.Name + '</li>' +
            '<li><b>Email:</b> ' + currentUser.Email + '</li>' +
            '<li><b>Org ID:</b> ' + org.Id + '</li>' +
            '<li><b>Account Name:</b> ' + org.Name + '</li>' +
            '</ul><br>' +
            '<b>CS:</b> Please reach out within 24 business hours to confirm their interest and subscription preferences and to schedule the 45-minute onboarding call.<br>' +
            '<b>Billing:</b> Please coordinate with CS to deliver the appropriate contract terms and invoice.<br><br>' +
            'Warmly,<br><br>' +
            'Left Main Product and Engineering Team';

        Messaging.SingleEmailMessage teamEmail = new Messaging.SingleEmailMessage();
        teamEmail.setToAddresses(teamToAddresses);
        teamEmail.setSubject('New User Signup Details for Property Sales AI');
        teamEmail.setHtmlBody(teamEmailBody);

        // Email 2: To the triggering user
        List<String> userToAddresses = new List<String>{currentUser.Email};
        String userEmailBody = 'Thank you for signing up for Property Sales AI! We\'re excited to help you transform your real estate operations.<br><br>' +
            'Why Property Sales AI?<br><br>' +
            '<b>Reduce Costs.</b> Automatically close out leads and opportunities when properties are recorded by the county as sold, freeing up time for higher-value tasks and money on phone usage, direct mail and follow-up costs.<br>' +
            '<b>Drive Revenue.</b> Prioritize leads and opportunities based on sold property data to focus your efforts on deals ready to convert and capture gaps in your follow-up process.<br>' +
            '<b>Gain Unprecedented Insight Into Your Competition.</b> Track activity of local investors, monitor your sales pipeline and merge local market data with CRM data, helping you make smarter, data-driven decisions.<br><br>' +
            '<b>Next Steps</b><br>' +
            '<ol style="margin-left: 0.5em; padding-left: 0;">' + // Adjust margins and padding
            '<li>Your Customer Success Specialist will contact you to confirm your preferences and schedule a 45-minute onboarding session.</li>' +
            '<li>You’ll receive an invoice for your preferred county and market data subscriptions.</li>' +
            '<li>Follow our setup wizard and Desk Reference for a seamless onboarding experience.</li>' +
            '</ol><br>' +
            'We look forward to helping you achieve more with less.<br><br>' +
            'Warmly,<br><br>' +
            'Left Main Product and Customer Success Teams';

        Messaging.SingleEmailMessage userEmail = new Messaging.SingleEmailMessage();
        userEmail.setToAddresses(userToAddresses);
        userEmail.setSubject('Welcome to Property Sales AI – Unlock Your Real Estate Potential');
        userEmail.setHtmlBody(userEmailBody);

        // Send both emails
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { teamEmail, userEmail });
        
    }
}