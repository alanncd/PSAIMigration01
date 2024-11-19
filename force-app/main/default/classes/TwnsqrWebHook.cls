@RestResource(urlMapping='/TwnsqrWebhook/*')
//leftmainreicoredev2-dev-ed.develop.my.salesforce-sites.com/services/apexrest/TwnsqrWebhook/11111
//ENDPOINT METHOD
global without sharing class TwnsqrWebHook {
    @HttpPost
    global static interesedBuyer doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String trxId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Map<String, String> header = req.headers;
        String requestBody = req.requestBody.toString();
        interesedBuyer rb = (interesedBuyer)JSON.deserialize(requestBody, interesedBuyer.class);
        //VALIDATE IF THE ORG ID IS THE SAME--------------------
        Id OrgId = UserInfo.getOrganizationId();
        //END VALIDATE IF THE ORG ID IS THE SAME--------------------
      
        //Update Transaction LeadSource
        List<Transactions__c> tx = [Select Id, LastModifiedById,OwnerId,Acquisition_Rep__c,Lead_Source__c From Transactions__c Where Id=:trxId];
        if(tx.size()>0){
            tx[0].Lead_Source__c=rb.leadSource;
            Set<String> users = new Set<String>();
            users.add(tx[0].Acquisition_Rep__c);
            users.add(tx[0].OwnerId);
            users.add(tx[0].LastModifiedById);
            notifyUsers(users,rb.externalRef);
            List<Contact> contacts = [select Id, Name, Account.Name From Contact Where LastName=:rb.contactinfo.lastName AND FirstName=:rb.contactinfo.firstName];
            List<Account> accounts = [Select Id, Name FROM Account Where Name=:rb.contactinfo.accountName];
            String accId= '';
            if(accounts.size()>0){
                accId = accounts[0].Id;
            }else{
               Account newAcc= new Account();
               newAcc.Name=rb.contactinfo.accountName;
               insert newAcc;
               accId = newAcc.Id;
            }
            if(contacts.size()>0){
                Interested_Buyers__c ib = new Interested_Buyers__c();
                ib.Contact__c=contacts[0].Id;
                ib.Name=rb.interedBuyerName;
                ib.Transactions__c=rb.externalRef;
                insert  ib;
            }else{
                //Create Contact
                Contact con = new Contact();
                con.LastName=rb.contactinfo.lastName;
                con.FirstName=rb.contactinfo.firstName;
                con.AccountId= accId;
                insert con;
                // & Insert Interesed Buyer
				Interested_Buyers__c ib = new Interested_Buyers__c();
                ib.Contact__c=con.Id;
                ib.Name=rb.interedBuyerName;
                ib.Transactions__c=rb.externalRef;
                insert  ib;
            }
        }
        update tx;
        //Create metadata with users to be notified as a configuration
        return rb;
    }
    @HttpGet
    global static List<Transactions__c> doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String trxId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Map<String, String> header = req.headers;
        
        system.debug(trxId);
        List<Transactions__c> tx = [Select Id, Name From Transactions__c Where Id=:trxId];
        return tx;
    }
	global class interesedBuyer{
        String organizationId;
        String interedBuyerName;
        Double offer;
        String offerType;
        String offerNotes;
        String externalRef;
        String leadSource;
        contactInfo contactinfo;
	}
    global class contactInfo{
        String accountName;
		String lastName;
        String firstName;
        String phone;
		String mobile;
		String email;
    }
    public static void notifyUsers(Set<String> recipientsIds, String targetId) {

        // Get the Id for our custom notification type
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='Left_Main_Notification'];
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle('New Interesd Buyer Added');
        notification.setBody('New Interesd Buyer Added by Twnsqr, Verify the Transation for more details');

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        
        // Actually send the notification
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }    
}