global with sharing class batchCadence implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful,Schedulable{

    @TestVisible public static boolean isDialPad = false;
    @TestVisible public static boolean isRingCentral = false;
    @TestVisible public static boolean isSmrtphone = false;
    @TestVisible public static boolean isGoSmrtPhone = true;
    @TestVisible public static boolean isGoRingCentral = true;
    @TestVisible public static boolean isGoDialpad = true;
    @TestVisible public static boolean isGoCallRail = false;
    
    global List<ScheduleCadence__c> listScheduleCadence = new List<ScheduleCadence__c>();
    global String accessToken = null;
    private final static String tokenParam = 'Authorization';
    global Map<String, ScheduleCadence__c> mapScheduledCadence = new Map<String, ScheduleCadence__c>();

    public Organization myOrg = [ Select Name From Organization LIMIT 1];
    @TestVisible public static Boolean bypassChaining = false;
    global Map<Id,String> logMap = New Map<Id,String>();

    global Database.QueryLocator start(Database.BatchableContext BC)
        {
            System.debug('start');
            DateTime currentTime = System.now();
            String query = 'Select Id, IdTemplate__c,TargetId__c,Name_Owner__c,Lead__c,OwnerId,Name,Status__c,Frecuency_To_Flow__c,StatusCode__c,BodyResponse__c FROM ScheduleCadence__c Where Time_to_be_dispatched__c <=: currentTime AND Status__c = \'Pending\' ORDER BY CreatedDate ASC LIMIT 100';
            return Database.getQueryLocator(query);
        }
    global void execute(Database.BatchableContext BC, List<ScheduleCadence__c> scope)
        {
           List<ScheduleCadence__c> listScheduleCadenceLocal = new List<ScheduleCadence__c>();
            Map<Id,String> logMapLocal = New Map<Id,String>();
            List<LMR_SmsHistory__c> listSentSms = new List<LMR_SmsHistory__c>();
            List<SmrtPhone_Config__mdt> myCM = SmrtPhone_Config__mdt.getall().values();
            List<CadenceConfiguration__mdt> myCM2 = CadenceConfiguration__mdt.getall().values();
            List<Ring_Central_Configuration__mdt> apiSettingRingCentral = Ring_Central_Configuration__mdt.getall().values();
            List<LMR_SmsError__c> listErrors = new List<LMR_SmsError__c>();
            List<ErrorHandlerLmr__c> listErrorsHandler = new List<ErrorHandlerLmr__c>();
            String log = '';
            for(ScheduleCadence__c scheduledCadence: scope){
                logMapLocal.put(scheduledCadence.Id,log);
                log = '';
                log+= 'Init Cadence SMS'+'<br />';
                String recordId=scheduledCadence.TargetId__c;
                String idTemplate=scheduledCadence.IdTemplate__c;


                Try{
                    String phoneToSend;
                    String phoneCustomer;
                    String nameOfUser;

                    Lead lead = new Lead();
                    Opportunity opportunity = New Opportunity();
                    Contact contact = New Contact();
                    Transactions__c transactionRecord = New Transactions__c();
                    Interested_Buyers__c interestedBuyer = New Interested_Buyers__c();
                    User userRecord = New User();


                   String objectUsed = Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(recordId);
                   log+= 'Cadence: '+scheduledCadence+'<br />';
                   if(objectUsed =='Lead'){
                        List<CampaignMember> cms=[SELECT CampaignID,Campaign.smrtPhone_Number__c, LeadID, Status FROM CampaignMember WHERE LeadID =: recordId];
                        if(cms.size()>0 && cms[0].Campaign.smrtPhone_Number__c != NULL){
                            lead = [Select Id, MobilePhone,Phone,FirstName,LastName,Street,owner.firstname,owner.phone,Owner.Name,OwnerId From Lead Where Id =:recordId];
                            User userCampaign = [Select Id,DialPadUserId__c FROM User where Id =:lead.OwnerId];
                            phoneToSend = lead.MobilePhone;
                            phoneCustomer = cms[0].Campaign.smrtPhone_Number__c;
                            nameOfUser=lead.Owner.Name != null? lead.Owner.Name:'';
                            if(myCM2[0].Provider_SMS__c == 'Dialpad'){
                                phoneCustomer = userCampaign.DialPadUserId__c;
                                }
                            log+= 'Number used in Campaign: '+Campaign.smrtPhone_Number__c+'<br />';
                        }else{
                            log+= 'Lead.'+'<br />';
                            lead = [Select Id, Phone,MobilePhone,FirstName,LastName,Street,owner.firstname,OwnerId,Owner.Name From Lead Where Id =:recordId];//Id =:recordId            
                            User user1 = [Select Id,SMS_Number__c,Phone,DialPadUserId__c FROM User where Id =:lead.OwnerId];
                            nameOfUser=lead.Owner.Name != null? lead.Owner.Name:'';
                            phoneToSend = lead.MobilePhone;
                           phoneCustomer =user1.Phone;
                            if(myCM2[0].Provider_SMS__c == 'Dialpad'){
                            phoneCustomer = user1.DialPadUserId__c;
                            }
                           log+= 'Number used to send Sms: '+phoneCustomer+'<br/>';
                        }
                        if(phoneToSend == null){
                            log+= 'Cadence does not have number'+'<br />';
                            listErrors.add(returnInsertError(phoneCustomer,phoneToSend,'Lead doesn\'t have number','',lead.Id,'Lead doesn\'t have number'));
                            scheduledCadence.BodyResponse__c = 'Lead doesn\'t have number';
                            mapScheduledCadence.put(scheduledCadence.Id,scheduledCadence);
                            logMapLocal.put(scheduledCadence.Id,log);
                            Continue;
                        }
                    }else if(objectUsed =='Opportunity'){
                        log+= 'Opp 1.'+'<br />';
                        opportunity = [Select MobilePhone__c,owner.phone,account.firstname,owner.Id,Owner.Name,Owner.firstname,Address_1__c,Appointment_Date_Time__c From Opportunity Where Id =:recordId];//Id =:recordId
                        User user2 = [Select Id,SMS_Number__c,Phone,DialPadUserId__c FROM User where Id =:opportunity.OwnerId];
                        log+= 'Number owner cadence opp: '+user2.Phone+'<br />';
                        phoneToSend = opportunity.MobilePhone__c;
                        nameOfUser=opportunity.Owner.Name != null? opportunity.Owner.Name:'';
                        phoneCustomer =user2.Phone;

                        if(myCM2[0].Provider_SMS__c == 'Dialpad'){
                            phoneCustomer = user2.DialPadUserId__c;
                        }

                        if(phoneToSend == null){
                            log+= 'Opp does not have number'+'<br />';
                            listErrors.add(returnInsertError(phoneCustomer,phoneToSend,'Opportunity doesn\'t have number','',opportunity.Id,'opportunity doesn\'t have number'));
                            scheduledCadence.BodyResponse__c = 'Opportunity doesn\'t have number';
                            mapScheduledCadence.put(scheduledCadence.Id,scheduledCadence);
                            logMapLocal.put(scheduledCadence.Id,log); 
                            continue;
                        }

                        }else if(objectUsed =='Contact'){
                        log+= 'Contact 1.'+'<br />';
                        contact = [Select mobilePhone,owner.phone,ownerId,Owner.Name From Contact Where Id =:recordId];//Id =:recordId
                        User user3 = [Select Id,SMS_Number__c,phone,DialPadUserId__c FROM User where Id =:contact.OwnerId];
                        log+= 'Number owner cadence contact: '+user3.SMS_Number__c+'<br />';
                        phoneToSend = contact.mobilePhone;
                        nameOfUser=Contact.Owner.Name != null? Contact.Owner.Name:'';
                        phoneCustomer =user3.Phone;

                        if(myCM2[0].Provider_SMS__c == 'Dialpad'){
                            phoneCustomer = user3.DialPadUserId__c;
                        }

                        if(phoneToSend == null){
                            log+= 'Contact does not have number'+'<br />';
                            scheduledCadence.BodyResponse__c = 'Contact doesn\'t have number';
                            mapScheduledCadence.put(scheduledCadence.Id,scheduledCadence);
                            listErrors.add(returnInsertError(phoneCustomer,phoneToSend,'Contact doesn\'t have number','',contact.Id,'contact doesn\'t have number'));
                            logMapLocal.put(scheduledCadence.Id,log);
                            continue;
                        }
                        }else if(objectUsed =='Transactions__c' ||objectUsed =='Left_Main__Transactions__c'){
                            transactionRecord = [Select Id,Mobile_Phone__c,OwnerId,Owner.Name from Transactions__c where Id=:recordId];
                            userRecord = [Select Id,SMS_Number__c,Phone,DialPadUserId__c FROM User where Id =:transactionRecord.OwnerId];
                            nameOfUser=transactionRecord.Owner.Name != null? transactionRecord.Owner.Name:'';
                            phoneToSend = transactionRecord.Mobile_Phone__c;
                            phoneCustomer = userRecord.Phone;
                            if(myCM2[0].Provider_SMS__c == 'Dialpad'){
                                phoneCustomer = userRecord.DialPadUserId__c;
                            }

                            if(phoneToSend == null){
                                log+= 'Contact does not have number'+'<br />';
                                //listScheduleCadenceLocal.add(scheduledCadence);
                                scheduledCadence.BodyResponse__c = 'transaction doesn\'t have number';
                                mapScheduledCadence.put(scheduledCadence.Id,scheduledCadence);
                                listErrors.add(returnInsertError(phoneCustomer,phoneToSend,'transaction doesn\'t have number','',transactionRecord.Id,'transaction doesn\'t have number'));
                                logMapLocal.put(scheduledCadence.Id,log);
                                continue;
                            }                       
                            }else if(objectUsed == 'Interested_Buyers__c' || objectUsed == 'Left_Main__Interested_Buyers__c'){
                                interestedBuyer = [Select Id,Contact__r.mobilePhone,Transactions__r.OwnerId,Transactions__r.Owner.Name from Interested_Buyers__c where Id=:recordId];
                                userRecord = [Select Id,SMS_Number__c,Phone,DialPadUserId__c FROM User where Id =:interestedBuyer.Transactions__r.OwnerId];
                                nameOfUser=interestedBuyer.Transactions__r.Owner.Name != null? interestedBuyer.Transactions__r.Owner.Name:'';
                                phoneToSend = interestedBuyer.Contact__r.mobilePhone;
                                phoneCustomer = userRecord.Phone;
                                if(myCM2[0].Provider_SMS__c == 'Dialpad'){
                                    phoneCustomer = userRecord.DialPadUserId__c;
                                }
                            if(phoneToSend == null){
                                log+= 'Contact does not have number'+'<br />';
                                scheduledCadence.BodyResponse__c = 'Interested buyer doesn\'t have number';
                                mapScheduledCadence.put(scheduledCadence.Id,scheduledCadence);
                                listErrors.add(returnInsertError(phoneCustomer,phoneToSend,'Interested buyer doesn\'t have number','',transactionRecord.Id,'Interested buyer doesn\'t have number'));
                                logMapLocal.put(scheduledCadence.Id,log);
                                continue;
                                } 

                            }

                        List<LMR_TemplateSms__c> templateOfSms = [Select Name,Body__c,Object__c FROM LMR_TemplateSms__c Where Id =:idTemplate ];
                        String objTemplate = templateOfSms[0].Object__c;
                        if(objTemplate == 'Interested Buyers'){
                            objTemplate = 'Interested_Buyers__c';
                        }else if( objTemplate == 'Transactions'){
                            objTemplate ='Transactions__c';
                        }
                        String messagebody = templateOfSms[0].Body__c;
                        String templateName = templateOfSms[0].Name;
                        Id templateId = templateOfSms[0].Id;
                        log+= 'get the template'+'<br />';

                    if(messagebody.contains('{LastName}') && lead?.LastName != Null){messagebody= messagebody.replace('{LastName}', lead.LastName);
                        }

                        if(messagebody.contains('{!$User.name}') && scheduledCadence.Name_Owner__c != Null){messagebody= messagebody.replace('{!$User.name}', scheduledCadence.Name_Owner__c);
                        }    
                        if(messagebody.contains('{!$Organization.name}') && myOrg.Name != Null){messagebody= messagebody.replace('{!$Organization.name}', myOrg.Name);
                        }          
                        if(messagebody.contains('{!Lead.owner.firstname}') && lead?.owner.firstname != Null){messagebody= messagebody.replace('{!Lead.owner.firstname}', lead.owner.firstname);
                        }
                        if(messagebody.contains('{!Lead.owner.phone}') && lead?.owner.Phone != Null){messagebody= messagebody.replace('{!Lead.owner.phone}', lead?.owner.Phone);
                        }else{messagebody= messagebody.replace('{!Lead.owner.phone}', '#######');
                        }
                            if(Opportunity.account?.firstname != Null && messagebody.contains('{!Opportunity.account.firstname}') && objectUsed =='Opportunity'){
                        messagebody= messagebody.replace('{!Opportunity.account.firstname}', opportunity.account.firstname);
                        } 

                        if(Opportunity.owner?.firstname != Null && messagebody.contains('{!Opportunity.owner.firstname}') && objectUsed =='Opportunity'){messagebody= messagebody.replace('{!Opportunity.owner.firstname}', opportunity.owner.firstname);}

                        if(Opportunity?.Address_1__c != Null && messagebody.contains('{!Opportunity.Address_1__c}') && objectUsed =='Opportunity'){messagebody= messagebody.replace('{!Opportunity.Address_1__c}', opportunity.Address_1__c);}
                        
                        if(Opportunity?.Appointment_Date_Time__c != Null && messagebody.contains('{!Opportunity.Appointment_Date_Time__c}') && objectUsed =='Opportunity'){messagebody= messagebody.replace('{!Opportunity.Appointment_Date_Time__c}', ''+opportunity.Appointment_Date_Time__c.date());}
                
                        if(messagebody.contains('&#39;')){messagebody= messagebody.replace('&#39;', '\'');}  
                    
                        if(messagebody.contains('&#39')){messagebody= messagebody.replace('&#39', '\'');
                        }  
                        system.debug('---------------------------- START Building message now--------------------------');            
                        messagebody =Lmr_SmrtPhoneUtils_cls.buildMessage(messagebody,objTemplate,recordId);
                        system.debug('---------------------------- END Building message now--------------------------'+messagebody);            
                        messagebody = messagebody.replaceAll('\\{.*?\\}', '***');
                        log+= 'Finish get the template'+'<br />';
            

                        String errorMessage = '';


                    if((myCM2[0].Provider_SMS__c == NULL || myCM2[0].Provider_SMS__c == 'Smrtphone' || isSmrtphone == true)&& isDialPad ==false && isRingCentral == false && isGoSmrtphone == true){
                        String endPoint = myCM[0].base_url__c ;
                        String accessToken = myCM[0].access_token__c;
                        String finalEndPoint = endPoint;
                    
                        log+= ' phoneCustomer: '+phoneCustomer+'phoneToSend: '+phoneToSend+' messagebody: '+messagebody+'<br />';                    
	                    String requestBody = 'from='+EncodingUtil.urlEncode(phoneCustomer, 'UTF-8')+'&to='+EncodingUtil.urlEncode(phoneToSend, 'UTF-8')+'&message='+EncodingUtil.urlEncode(messagebody, 'UTF-8')+'&sfRecordId='+EncodingUtil.urlEncode(recordId, 'UTF-8'); 
                        Http http = new Http();
                        httpRequest httpReq = new httpRequest();
                        HttpResponse response = new HttpResponse();
                        
                        httpReq.setMethod('POST');
                        httpReq.setEndpoint(finalEndPoint);
                        httpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                        httpReq.setHeader('X-Auth-smrtPhone', accessToken);
                        httpReq.setBody(requestBody); 
                            
                        try{
                            log+= 'Send request'+'<br />';
                             response = http.send(httpReq);
                             String responseBody = response.getBody();
                            if( response.getStatusCode() == 200 ){
                                log+= 'Status code 200'+'<br />';
                                scheduledCadence.StatusCode__c = ''+response.getStatusCode();
                                scheduledCadence.BodyResponse__c = ''+responseBody;
                                mapScheduledCadence.put(scheduledCadence.Id,scheduledCadence);
                                logMapLocal.put(scheduledCadence.Id,log);
                                listSentSms.add(returnSmsHistory(phoneCustomer,phoneToSend,messagebody,templateName,templateId,recordId));
                            }else{
                                log+= 'Unexpected Error while communicating with API'+'<br />';
                                errorMessage = 'Unexpected Error while communicating with API. '
                                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode() +' Api Response: '+responseBody;
                                listErrors.add(returnInsertError(phoneCustomer,phoneToSend,messagebody,templateName,recordId,errorMessage+' requestBody: '+requestBody));
                                scheduledCadence.StatusCode__c = ''+response.getStatusCode();
                                scheduledCadence.BodyResponse__c = responseBody;
                                logMapLocal.put(scheduledCadence.Id,log);
                                mapScheduledCadence.put(scheduledCadence.Id,scheduledCadence);
                                continue;
                            }
                        }catch(System.Exception e){
                            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                                errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
                                    +' Remote Site Setting and add '+' '+ endPoint +' Endpoint';
                            }else{
                                errorMessage = 'Unexpected Error while communicating with API. '
                                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
                            }
                            log+= 'catch: '+e +'<br />';
                            listErrors.add(returnInsertError(phoneCustomer,phoneToSend,messagebody,templateName,recordId,errorMessage+' requestBody: '+requestBody));
                            logMapLocal.put(scheduledCadence.Id,log); 
                            continue;
                    } 
                }

                else if((myCM2[0].Provider_SMS__c == 'Ring Central' || isRingCentral == true) && isDialPad ==false && isSmrtphone == false && isGoRingCentral == true){
                    List<sObject> smsLstObj = Lmr_SmrtPhone_cls.getSmsCallout(scheduledCadence.TargetId__c,''+scheduledCadence.IdTemplate__c);
                    LeftMain_SecurityUtils.checkInsert(LMR_SmsHistory__c.SObjectType,new List<String> {
                        'From__c',
                        'To__c',
                        'Body__c',
                        'Name',
                        'SmsTemplate__c',
                        'Lead__c',
                        'Opportunity__c',
                        'Contact__c',
                        'Information__c'
                    }); 
                        SObjectAccessDecision decisionX = Security.stripInaccessible(AccessType.CREATABLE ,smsLstObj);
                        Database.insert(smsLstObj = decisionX.getRecords());
                }else if((myCM2[0].Provider_SMS__c == 'Dialpad' || isDialPad == true) && isRingCentral ==false && isSmrtphone == false && isGoDialpad == true){
        			List<Dialpad_Configuration__mdt> apiSettingDialpad = Dialpad_Configuration__mdt.getall().values();

        			String authUrl= 'https://dialpad.com/api/v2/sms?accept=application/json&content-type=application/json';

                    String token=apiSettingDialpad[0].Token__c;
                    String userId='';
                    Boolean booleanSpecificUser=apiSettingDialpad[0].SpecificUser__c;

                    if(booleanSpecificUser == true){
                        userId=apiSettingDialpad[0].UserId__c;
                    }else{
                        userId = phoneCustomer;
                    }
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(authUrl);
                    request.setMethod('POST');   
                    request.setHeader(tokenParam, 'Bearer '+token);

                    String payload = '{'+
                    '"infer_country_code": false,'+
                    '"to_numbers": ["'+phoneToSend+'"],'+
                    '"user_id": '+userId+','+
                    '"text":'+'"'+messageBody+'"'+
                    '}';

                    request.setBody(payload);

                    HttpResponse response = http.send(request);
                    String responseBody = response.getBody();

                    log+= 'Send request'+'<br />';

                    if(response.getStatusCode() == 200 ){
                        log+= 'Status code 200'+'<br />';
                        scheduledCadence.StatusCode__c = ''+response.getStatusCode();
                        scheduledCadence.BodyResponse__c = ''+responseBody;
                        mapScheduledCadence.put(scheduledCadence.Id,scheduledCadence);
                        logMapLocal.put(scheduledCadence.Id,log);
                        listSentSms.add(returnSmsHistory(phoneCustomer,phoneToSend,messagebody,templateName,templateId,recordId));
                    }else{
                        log+= 'Unexpected Error while communicating with API'+'<br />';
                        errorMessage = 'Unexpected Error while communicating with API. '
                            +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode()+' Api Response: '+responseBody;
                        listErrors.add(returnInsertError(phoneCustomer,phoneToSend,payload,templateName,recordId,errorMessage));
                        scheduledCadence.BodyResponse__c = ''+responseBody;
                        mapScheduledCadence.put(scheduledCadence.Id,scheduledCadence);
                        logMapLocal.put(scheduledCadence.Id,log);
                        continue;
                    }

                }else if(myCM2[0].Provider_SMS__c == 'CallRail' || isGoCallRail==TRUE){
                     String toNumber = phoneToSend;
                     HttpResponse response=SendSMSCallRail.sendSms(toNumber,messagebody,phoneCustomer);
                     String responseBody = response.getBody();

                       if( response.getStatusCode() == 200 ){
                           log+= 'Status code 200'+'<br />';
                           scheduledCadence.StatusCode__c = ''+response.getStatusCode();
                           scheduledCadence.BodyResponse__c = ''+responseBody;
                           mapScheduledCadence.put(scheduledCadence.Id,scheduledCadence);
                           logMapLocal.put(scheduledCadence.Id,log);
                           listSentSms.add(returnSmsHistory(phoneCustomer,phoneToSend,messagebody,templateName,templateId,recordId));

                       }else{
                           log+= 'Unexpected Error while communicating with API'+'<br />';
                           errorMessage = 'Unexpected Error while communicating with API. '
                               +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode()+' Api Response: '+response.getBody();
                            listErrors.add(returnInsertError(phoneCustomer,phoneToSend,messagebody,templateName,recordId,errorMessage));
                           scheduledCadence.BodyResponse__c = ''+responseBody;
                           mapScheduledCadence.put(scheduledCadence.Id,scheduledCadence);
                           logMapLocal.put(scheduledCadence.Id,log);
                           continue;
                       }
                }   


                }catch(Exception e){
                            log+= 'catch 2: '+e +'<br />';
                            ScheduleCadence__c scheduled = new ScheduleCadence__c();
                            scheduled =scheduledCadence;
                            listErrorsHandler.add(ErrorHandler_cls.returnHandleException(e,'batch SPhone: '+recordId +' cd: '+scheduledCadence.Id));
                        scheduledCadence.BodyResponse__c = 'Exception: '+e;
                        mapScheduledCadence.put(scheduledCadence.Id,scheduledCadence);
                        continue;
                }


                    logMapLocal.put(scheduledCadence.Id,log);
                    Integer maxLogLimit = SObjectType.ScheduleCadence__c.Fields.LogDetail__c.Length;

                    scheduledCadence.Status__c ='Completed';
                    if ( logMapLocal.get(scheduledCadence.Id).length() >=  maxLogLimit ){
                        String oldLog = logMapLocal.get(scheduledCadence.Id);
                        String newLog = oldLog.substring(0,(maxLogLimit-80));
                        scheduledCadence.LogDetail__c = newLog;
                    }else{
                        scheduledCadence.LogDetail__c =logMapLocal.get(scheduledCadence.Id);
                    }

                    mapScheduledCadence.put(scheduledCadence.Id,scheduledCadence);
                    listScheduleCadenceLocal.add(scheduledCadence);
            }



            LeftMain_SecurityUtils.checkUpdate(ScheduleCadence__c.SObjectType,new List<String> {
                'LogDetail__c','StatusCode__c','BodyResponse__c','Status__c'
            });

            if (Schema.sObjectType.ScheduleCadence__c.isUpdateable()) {
                update listScheduleCadenceLocal;
            }
            LeftMain_SecurityUtils.checkInsert(LMR_SmsHistory__c.SObjectType,new List<String> {
                'Name',
                 'SmsTemplate__c',
                 'Lead__c',
                 'Opportunity__c',
                 'Contact__c',
                 'Transactions__c',
                 'Interested_Buyers__c',
                 'Information__c'
            }); 
            
                SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE ,listSentSms);
                listSentSms = decision.getRecords();
                Database.insert(listSentSms);

                LeftMain_SecurityUtils.checkInsert(ErrorHandlerLmr__c.SObjectType,new List<String> {
                    'LogDetail__c',
                    'ProcessName__c'
                  });

                //insert listErrorsHandler;
                SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.CREATABLE, listErrorsHandler);
                Database.insert(listErrorsHandler = decision2.getRecords());
            
            LeftMain_SecurityUtils.checkInsert(LMR_SmsError__c.SObjectType,new List<String> {
                'From__c',
                 'To__c',
                 'Body__c',
                 'Template__c',
                 'RecordObject__c',
                 'Error_Body__c',
                 'Information__c'
            });

            //insert listErrorsHandler;
            SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, listErrors);
            Database.insert(listErrors = decision3.getRecords());
            //insert listErrors;
            

        }
    global void finish(Database.BatchableContext BC)
        {
            for(ScheduleCadence__c iterateScheduledCadence: mapScheduledCadence.values()){
                iterateScheduledCadence.Status__c ='Completed';
            }
            if(!mapScheduledCadence.values().isEmpty()){ update mapScheduledCadence.values();}
            
			if (bypassChaining) return;


        }

        public static LMR_SmsHistory__c returnSmsHistory(String phoneCustomer, String phoneToSend, String messagebody,String templateName,Id templateId,Id recordId) {
            String objectUsed = Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(recordId);
            LMR_SmsHistory__c smsHistory = new LMR_SmsHistory__c();
            smsHistory.From__c = phoneCustomer;
            smsHistory.To__c = phoneToSend;
            smsHistory.Body__c = messagebody;
            Integer maxSize = 80;
            if(templateName.length() > maxSize ){
            templateName = templateName.substring(0, maxSize);
            }
            smsHistory.Name = templateName;
            smsHistory.SmsTemplate__c = templateId;
            if(objectUsed =='Lead'){
                smsHistory.Lead__c = recordId;
            }else if(objectUsed =='Opportunity'){
                smsHistory.Opportunity__c = recordId;
            }else if(objectUsed =='Contact'){
                smsHistory.Contact__c = recordId;
            }else if(objectUsed =='Transactions__c' || objectUsed =='Left_Main__Transactions__c'){
                smsHistory.Transactions__c = recordId;
            }else if(objectUsed =='Interested_Buyers__c' || objectUsed =='Left_Main__Interested_Buyers__c'){
                smsHistory.Interested_Buyers__c = recordId;
            }
            smsHistory.Information__c = 'Scheduled SMS batch';
            return smsHistory;
           
        }

        public static LMR_SmsError__c returnInsertError(String phoneCustomer, String phoneToSend, String messagebody,String templateName,Id recordId,String errorBody) {
            LMR_SmsError__c smsHistory = new LMR_SmsError__c();
            smsHistory.From__c = phoneCustomer;
            smsHistory.To__c = phoneToSend;
            smsHistory.Body__c = messagebody;
            smsHistory.Template__c = templateName;
            smsHistory.RecordObject__c = recordId;
            smsHistory.Error_Body__c = errorBody;
            smsHistory.Information__c = 'Scheduled SMS';

            LeftMain_SecurityUtils.checkInsert(LMR_SmsError__c.SObjectType,new List<String> {
                'From__c',
                 'To__c',
                 'Body__c',
                 'Template__c',
                 'RecordObject__c',
                 'Error_Body__c',
                 'Information__c'
            });

            return smsHistory;
           
        }

        global void execute(SchedulableContext sc) {
            batchCadence batchObj = new batchCadence(); 
             if(!Test.isRunningTest()){database.executebatch(batchObj,1);}
        }


}