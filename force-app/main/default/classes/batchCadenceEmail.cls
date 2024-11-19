global with sharing class batchCadenceEmail implements Database.Batchable<sObject>,Database.Stateful,Schedulable{
    global List<ErrorHandlerLmr__c> listScheduleCadence = new List<ErrorHandlerLmr__c>();
    global List<ScheduleCadenceEmail__c> listScheduleCadenceEmail = new List<ScheduleCadenceEmail__c>();

    global Database.QueryLocator start(Database.BatchableContext BC)
        {
            DateTime currentTime = System.now();
            String query = 'Select Name,Email__c,IdTemplate__c,Related_Record_id__c,Sequence__c,Status__c,Time_to_be_dispatched__c FROM ScheduleCadenceEmail__c WHERE Time_to_be_dispatched__c <=: currentTime AND Status__c = \'Pending\' ORDER BY CreatedDate desc LIMIT 2000';
            return Database.getQueryLocator(query);
        }
    global void execute(Database.BatchableContext BC, List<ScheduleCadenceEmail__c> scope)
        {
            try {
            List<CadenceConfiguration__mdt> myCM2 = CadenceConfiguration__mdt.getall().values();
            OrgWideEmailAddress[] owea = New List<OrgWideEmailAddress>();
            Map<String,OrgWideEmailAddress> MapEmailorgAddresses = New Map<String,OrgWideEmailAddress>();

            List<OrgWideEmailAddress> listEmailOrgAddress = [SELECT Id,DisplayName, Address FROM OrgWideEmailAddress LIMIT 10000];

            for(OrgWideEmailAddress orgEmail: listEmailOrgAddress){
                MapEmailorgAddresses.put(orgEmail.Address,orgEmail);
            }


            if(myCM2[0].Email__c == NULL || Test.isRunningTest()){
                owea = [select Id from OrgWideEmailAddress LIMIT 1];
            }else{
                owea = [select Id from OrgWideEmailAddress Where Address =: myCM2[0].Email__c LIMIT 1];
            }
            List<contact> conList = [select id from contact where IsEmailBounced=false limit 1];
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage> {};
            List<Id> listIdsLeads = new List<Id>();
            List<Id> listIdsOpportunities = new List<Id>();
            List<Id> listIdsContact = new List<Id>();
            List<Id> listIdsTransaction = new List<Id>();
            List<Id> listIdsInterestedBuyer = new List<Id>();

            Map<String,string> mapIdTemplateId = New Map<String,string>();
            Map<String,string> mapIdEmailById= New Map<String,string>();

            for(ScheduleCadenceEmail__c iterateEmail :scope){
                String objectUsed = Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(iterateEmail.Related_Record_id__c);
                iterateEmail.Status__c ='Completed';
                listScheduleCadenceEmail.add(iterateEmail);
                if(objectUsed =='Lead'){
                 listIdsLeads.add(iterateEmail.Related_Record_id__c);
                }else if(objectUsed =='Contact'){
                    listIdsContact.add(iterateEmail.Related_Record_id__c);
                }else if(objectUsed =='Opportunity'){
                    listIdsOpportunities.add(iterateEmail.Related_Record_id__c);
                }else if(objectUsed =='Transactions__c' || objectUsed =='Left_Main__Transactions__c'){
                    listIdsTransaction.add(iterateEmail.Related_Record_id__c);
                }else if(objectUsed =='Interested_Buyers__c' || objectUsed =='Left_Main__Interested_Buyers__c'){
                    listIdsInterestedBuyer.add(iterateEmail.Related_Record_id__c);
                }
                mapIdTemplateId.put(iterateEmail.Related_Record_id__c,iterateEmail.IdTemplate__c);
                if(!String.isBlank(iterateEmail.Email__c)  && MapEmailorgAddresses.get(iterateEmail.Email__c) != Null){
                    mapIdEmailById.put(iterateEmail.Related_Record_id__c,MapEmailorgAddresses.get(iterateEmail.Email__c).Id);
                }else{
                    mapIdEmailById.put(iterateEmail.Related_Record_id__c,owea.get(0).Id);
                }
            }
            if ( owea.size() < 1 ) {
                if(!Test.isRunningTest()){
                    insert ErrorHandler_cls.insertErrorHandler('Org does NOT have an organization-wide email address added','Batch Send Email');
                    return ;
                }else{
                }
            }
            List<Lead> listLead= [Select id,email,OwnerId from Lead where Id IN: listIdsLeads];
            List<Opportunity> listOpportunities= [Select id,Person_Account_Email__c,Email__c,OwnerId,Account.PersonContactId,Account.PersonEmail from Opportunity where Id IN: listIdsOpportunities];
            List<Contact> listContacts= [Select id,email,OwnerId from Contact where Id IN: listIdsContact];
            List<Transactions__c> listTransactions= [Select id,Email__c,Opportunity__r.Account.PersonContactId from Transactions__c where Id IN: listIdsTransaction];
            List<Interested_Buyers__c> listInterestedBuyers= [Select id,Contact__r.Email,Contact__c from Interested_Buyers__c where Id IN: listIdsInterestedBuyer];

            
                for(Lead LeadObj : listLead){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new String[] {LeadObj.Email});
                    mail.setTemplateId(mapIdTemplateId.get(LeadObj.Id));
                    mail.setTargetObjectId(LeadObj.Id);
                    mail.setSaveAsActivity(true);
                    mail.setUseSignature(false);
                    if ( owea.size() > 0 ) {
                        mail.setOrgWideEmailAddressId(mapIdEmailById.get(LeadObj.Id));
                    }
                    messages.add(mail);
                }
                for(Opportunity opp1 : listOpportunities){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    if(String.isBlank(opp1.Account.PersonEmail)){
                        mail.setToAddresses(new String[] {opp1.Email__c});
                    }else{
                        mail.setToAddresses(new String[] {opp1.Account.PersonEmail});
                    }
                    
                    mail.setTemplateId(mapIdTemplateId.get(opp1.Id));
                  //  mail.setTargetObjectId(opp1.OwnerId);
                   // mail.setTargetObjectId(conList[0].Id);
                   mail.setTargetObjectId(opp1.Account.PersonContactId);
                    mail.setSaveAsActivity(false);
                    mail.setWhatId(opp1.Id);
                    mail.setUseSignature(false);
                    if ( owea.size() > 0 ) {
                        mail.setOrgWideEmailAddressId(mapIdEmailById.get(opp1.Id));
                    }
                    messages.add(mail);
                }
                for(Contact contact1 : listContacts){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new String[] {contact1.Email});
                    mail.setTemplateId(mapIdTemplateId.get(contact1.Id));
                    mail.setTargetObjectId(contact1.Id);
                    mail.setSaveAsActivity(true);
                    mail.setUseSignature(false);
                    if ( owea.size() > 0 ) {
                        mail.setOrgWideEmailAddressId(mapIdEmailById.get(contact1.Id));
                    }
                    messages.add(mail);
                }
                for(Transactions__c transaction1 : listTransactions){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new String[] {transaction1.Email__c});              
                    mail.setTemplateId(mapIdTemplateId.get(transaction1.Id));
                   mail.setTargetObjectId(transaction1.Opportunity__r.Account.PersonContactId);
                    mail.setSaveAsActivity(false);
                    mail.setWhatId(transaction1.Id);
                    mail.setUseSignature(false);
                    if ( owea.size() > 0 ) {
                        mail.setOrgWideEmailAddressId(mapIdEmailById.get(transaction1.Id));
                    }
                    messages.add(mail);
                }
                for(Interested_Buyers__c interestedBuyer1 : listInterestedBuyers){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new String[] {interestedBuyer1.Contact__r.Email});
                    mail.setTemplateId(mapIdTemplateId.get(interestedBuyer1.Id));
                   mail.setTargetObjectId(interestedBuyer1.Contact__c);
                    mail.setSaveAsActivity(false);
                    mail.setWhatId(interestedBuyer1.Id);
                    mail.setUseSignature(false);
                    if ( owea.size() > 0 ) {
                        mail.setOrgWideEmailAddressId(mapIdEmailById.get(interestedBuyer1.Id));
                    }
                    messages.add(mail);
                }
                
                if(!messages.isEmpty()){
                    Savepoint sp = Database.setSavepoint();
                   Messaging.SendEmailResult[] currentSendEmailResult = Messaging.sendEmail(messages,false);
                   for (Messaging.SendEmailResult mr : currentSendEmailResult) 
                        {
                            if (!mr.isSuccess()) {
                                for(Messaging.SendEmailError err : mr.getErrors()) {
                                    ErrorHandlerLmr__c errorHandlerInitial = new ErrorHandlerLmr__c();
                                    errorHandlerInitial.RelatedRecordId__c = err.getTargetObjectId();
                                    errorHandlerInitial.ProcessName__c = 'Batch Email Cadence';
                                    errorHandlerInitial.LogDetail__c = err.getMessage();
                                    errorHandlerInitial.RelatedRecordId__c = err.getTargetObjectId();
                                    listScheduleCadence.add(errorHandlerInitial);
                                }

                            } 
                        }
                    
                  	Database.rollback(sp);

                    String objectUsedEmailLead ='';
                    String obectUsedOpportunities ='';
                
                    List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
                    for (Messaging.SingleEmailMessage email : messages) {
                        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                        emailToSend.setToAddresses(email.getToAddresses());
                        emailToSend.setPlainTextBody(email.getPlainTextBody());
                        emailToSend.setHTMLBody(email.getHTMLBody());
                        emailToSend.setSubject(email.getSubject());
                      //  emailToSend.setOrgWideEmailAddressId(owea.get(0).Id);
                        emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());

                        if(email.getTargetObjectId() != Null){
                            objectUsedEmailLead=Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(email.getTargetObjectId());
                        }
                        if(email.getWhatId() != Null){
                            obectUsedOpportunities=Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(email.getWhatId());   
                        }
                        if(obectUsedOpportunities =='Opportunity' || obectUsedOpportunities =='Transactions__c' || obectUsedOpportunities =='Interested_Buyers__c' || obectUsedOpportunities =='Left_Main__Interested_Buyers__c' || obectUsedOpportunities =='Left_Main__Transactions__c'){
                            emailToSend.setWhatId(email.getWhatId());
                        }
                        if(objectUsedEmailLead =='Lead' || (objectUsedEmailLead =='Contact' && String.isBlank(email.getWhatId()))){
                            emailToSend.setTargetObjectId(email.getTargetObjectId());
                        }
                        emailToSend.setSaveAsActivity(true);
                        emailToSend.setUseSignature(false);
                        
                        lstMsgsToSend.add(emailToSend);
                    }
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMsgsToSend,false);
                    for (Messaging.SendEmailResult mr : results) 
                        {
                            if (mr.isSuccess()) {
                            }  else {
                                // Operation failed, so get all errors                
                                for(Messaging.SendEmailError err : mr.getErrors()) {
                                    ErrorHandlerLmr__c errorHandler = new ErrorHandlerLmr__c();
                                    errorHandler.ProcessName__c = 'Batch Send Email';
                                    errorHandler.LogDetail__c = err.getStatusCode() + ': ' + err.getMessage()+'; fields that affected this error: ' + err.getFields();
                                   	errorHandler.RelatedRecordId__c = err.getTargetObjectId();

                                   // listScheduleCadence.add(errorHandler);
                                }
                            }
                        }

                }
              
            } catch (Exception e) {
              ErrorHandler_cls.handleException(e,'batch Send Email');
        
            }

            LeftMain_SecurityUtils.checkUpdate(ScheduleCadenceEmail__c.SObjectType,new List<String> {'Status__c'});

            if (Schema.sObjectType.ScheduleCadenceEmail__c.isUpdateable()) {
                update scope;
            }
        }
    global void finish(Database.BatchableContext BC)
        {
            Map<Id,ScheduleCadenceEmail__c> mapScheduledEmails = new Map<Id,ScheduleCadenceEmail__c>();

            try {
                SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, listScheduleCadence);
                listScheduleCadence = decision.getRecords();
                Database.insert(listScheduleCadence);
                //insert listScheduleCadence;
            } catch (Exception e) {
              ErrorHandler_cls.handleException(e,'batch Send Email End');
            }
            
            for(ScheduleCadenceEmail__c iterateScheduledEmail: listScheduleCadenceEmail){
                iterateScheduledEmail.Status__c ='Completed';
                mapScheduledEmails.put(iterateScheduledEmail.Id,iterateScheduledEmail);
            }

            LeftMain_SecurityUtils.checkUpdate(ScheduleCadenceEmail__c.SObjectType,new List<String> {'Status__c'});
            if(!mapScheduledEmails.values().isEmpty() && Schema.sObjectType.ScheduleCadenceEmail__c.isUpdateable() && Schema.sObjectType.ScheduleCadenceEmail__c.fields.Status__c.isUpdateable()){
                List<ScheduleCadenceEmail__c> listEmails = new List<ScheduleCadenceEmail__c>();
                listEmails.addAll(mapScheduledEmails.values());

                SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.UPDATABLE, listEmails);
                listEmails = decision1.getRecords();
                Database.update(listEmails);
                
            }
           
            
        }

        global void execute(SchedulableContext sc) {
            batchCadenceEmail batchObj = new batchCadenceEmail(); 
             if(!Test.isRunningTest()){
                database.executebatch(batchObj,250);
            }
        }


}