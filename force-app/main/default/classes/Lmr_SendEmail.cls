public with sharing class Lmr_SendEmail {
    
    public static void EmailNow(String recordId,String templateId,String emailUsed){
        OrgWideEmailAddress[] owea = New List<OrgWideEmailAddress>();
        List<CadenceConfiguration__mdt> myCM2 = CadenceConfiguration__mdt.getall().values();
        Map<String,OrgWideEmailAddress> MapEmailorgAddresses = New Map<String,OrgWideEmailAddress>();


        List<OrgWideEmailAddress> listOrgWideEmailAddress = [SELECT id,Address from OrgWideEmailAddress WITH USER_MODE LIMIT 10000];

        for(OrgWideEmailAddress orgEmail: listOrgWideEmailAddress){
            MapEmailorgAddresses.put(orgEmail.Address,orgEmail);
        }

        if(listOrgWideEmailAddress.size() > 0){
            if( !String.isblank(emailUsed) && MapEmailorgAddresses.get(emailUsed) != null){
                owea.add(MapEmailorgAddresses.get(emailUsed));

            }else if(myCM2[0].Email__c != NULL && !Test.isRunningTest()){
                owea.add(MapEmailorgAddresses.get((myCM2[0].Email__c)));
            }else{
                owea.add(MapEmailorgAddresses.get(MapEmailorgAddresses.keySet().iterator().next()));
                
            }
        }else{
            if(!Test.isRunningTest()){
                insert ErrorHandler_cls.insertErrorHandler('Org does NOT have an organization-wide email address added','Now Send Email');
                return ;
            }
        }

       try {
           Lead lead = New Lead();
           Opportunity opp = New Opportunity();
           Contact con = New Contact();
           Transactions__c transactionRecord = New Transactions__c();
           Interested_Buyers__c interestedBuyer = New Interested_Buyers__c();

        string addressee;
    String objectUsed = Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(recordId);
    if(objectUsed =='Lead'){
        lead = [Select ownerId from Lead where Id=:recordId WITH USER_MODE];
        addressee = [Select email FROM Lead WHERE id =:recordId WITH USER_MODE].email;
    }else if(objectUsed =='Contact'){
        con = [Select ownerId from Contact where Id=:recordId WITH USER_MODE];
        addressee = [Select email FROM Contact WHERE id =:recordId WITH USER_MODE].email;
    }else if(objectUsed =='Opportunity'){
        opp = [Select ownerId,AccountId,Account.PersonContactId from Opportunity where Id=:recordId WITH USER_MODE];
        addressee = [Select Person_Account_Email__c FROM Opportunity WHERE id =:recordId WITH USER_MODE].Person_Account_Email__c;

        if(String.isBlank(addressee)){
            addressee = [Select Email__c FROM Opportunity WHERE id =:recordId WITH USER_MODE].Email__c;

        }
    }else if(objectUsed == 'Transactions__c' || objectUsed == 'Left_Main__Transactions__c'){
        transactionRecord = [Select Id,Email__c,Opportunity__r.Account.PersonContactId from Transactions__c where Id=:recordId WITH USER_MODE];
        addressee = [Select Id,Email__c FROM Transactions__c WHERE id =:recordId WITH USER_MODE].Email__c;
    }else if(objectUsed == 'Interested_Buyers__c' || objectUsed == 'Left_Main__Interested_Buyers__c'){
        interestedBuyer = [Select Contact__r.Email,Contact__c from Interested_Buyers__c where Id=:recordId WITH USER_MODE];
        addressee = [Select Contact__r.Email,Contact__c FROM Interested_Buyers__c WHERE id =:recordId WITH USER_MODE].Contact__r.Email;
    }
   // List<contact> conList = [select id,IsEmailBounced from contact where IsEmailBounced=false AND email <> null limit 1];
   List<contact> conList = new List<Contact>();
   List<Account> AccountList = new List<Account>();

    if(objectUsed =='Opportunity'){
       // conList = [select id,IsEmailBounced from contact where IsEmailBounced=false AND email <> null and Id=: opp.AccountId limit 1];
       conList = [Select id from Contact where id=:opp.Account.PersonContactId WITH USER_MODE limit 1];
    }else if(objectUsed =='Transactions__c' || objectUsed == 'Left_Main__Transactions__c'){
        conList = [Select id from Contact where id=:transactionRecord.Opportunity__r.Account.PersonContactId WITH USER_MODE limit 1];

    }else if(objectUsed =='Interested_Buyers__c' || objectUsed == 'Left_Main__Interested_Buyers__c'){
        conList = [Select id from Contact where id=:interestedBuyer.Contact__c WITH USER_MODE limit 1];

    }


     EmailTemplate et = [SELECT Id,Name,Subject,HtmlValue,Body FROM EmailTemplate WHERE Id =:templateId WITH USER_MODE];

    List<string> toAddress = new List<string>();
    toAddress.add(addressee);
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(et.Id);
        mail.setToAddresses(toAddress);
        mail.setTemplateId(templateId);
        if(objectUsed =='Opportunity'){
            mail.setTargetObjectId(conList[0].Id);
            mail.setSaveAsActivity(false);
            mail.setWhatId(opp.Id);
        }else if(objectUsed =='Transactions__c' ||objectUsed =='Interested_Buyers__c' || objectUsed =='Left_Main__Transactions__c' ||objectUsed =='Left_Main__Interested_Buyers__c'){

            mail.setTargetObjectId(conList[0].Id);
            mail.setSaveAsActivity(true);
            mail.setWhatId(recordId);
        }else{
            mail.setTargetObjectId(recordId);
            mail.setSaveAsActivity(true);
        }
        mail.setUseSignature(false);
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }

    List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
    allmsg.add(mail);
    Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(allmsg,false);
    Database.rollback(sp);

    String objectUsedEmailLead ='';
    String obectUsedOpportunities ='';

List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
    for (Messaging.SingleEmailMessage email : allmsg) {
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        emailToSend.setToAddresses(email.getToAddresses());
        emailToSend.setPlainTextBody(email.getPlainTextBody());
        emailToSend.setHTMLBody(email.getHTMLBody());
        emailToSend.setSubject(email.getSubject());
        emailToSend.setOrgWideEmailAddressId(owea.get(0).Id);
        if(email.getTargetObjectId() != Null){
            objectUsedEmailLead=Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(email.getTargetObjectId());

        }
        if(email.getWhatId() != Null){
            obectUsedOpportunities=Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(email.getWhatId());

        }

        if(obectUsedOpportunities =='Opportunity' || obectUsedOpportunities =='Transactions__c' || obectUsedOpportunities =='Interested_Buyers__c' || obectUsedOpportunities =='Left_Main__Transactions__c' || obectUsedOpportunities =='Left_Main__Interested_Buyers__c'){
            emailToSend.setWhatId(email.getWhatId());
            emailToSend.setSaveAsActivity(true);

        }
        if(objectUsedEmailLead =='Lead' || objectUsedEmailLead =='Contact'){
            emailToSend.setTargetObjectId(email.getTargetObjectId());
            emailToSend.setSaveAsActivity(true);

        }

        lstMsgsToSend.add(emailToSend);
    }
    Messaging.sendEmail(lstMsgsToSend);

    } catch (Exception e) {
      System.debug('except: '+e);
	  System.debug('exception e: '+e.getLineNumber());
      ErrorHandler_cls.handleException(e,'Now Send Email');

    }

    }
    @future
    public static void sendEmailNow(String recordId,String templateId,String emailUsed){
       EmailNow(recordId, templateId,emailUsed);
    }
    

    
}