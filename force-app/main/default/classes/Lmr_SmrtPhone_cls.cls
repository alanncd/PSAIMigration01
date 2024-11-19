public with sharing class Lmr_SmrtPhone_cls {
  @TestVisible
  public static boolean isDialPad = false;
  @TestVisible
  public static boolean isRingCentral = false;
  @TestVisible
  public static boolean isSmrtphone = false;
  @TestVisible
  public static boolean isGoSmrtPhone = true;
  @TestVisible
  public static boolean isGoRingCentral = true;
  @TestVisible
  public static boolean isGoDialpad = true;   
  @TestVisible
  public static boolean isGoCallRail = false;
  private final static String tokenParam = 'Authorization';    
  public static List<sObject> getSmsCallout(String recordId, String idTemplate){
    Boolean hasCampaign = false;
    List<Sobject> listSobject = new List<Sobject>();
    String error = '';
    List<SmrtPhone_Config__mdt> myCM = SmrtPhone_Config__mdt.getall().values();
    List<CadenceConfiguration__mdt> myCM2 = CadenceConfiguration__mdt.getall()
      .values();
    List<Ring_Central_Configuration__mdt> apiSettingRingCentral = [
      SELECT apiKey__c, authUrl__c, Authentication_Method__c,authUrl2__c, Password__c, secretKey__c,username__c,JWT__c FROM Ring_Central_Configuration__mdt WITH USER_MODE LIMIT 1];

      User userSended = [
        SELECT Id, Name, Phone, SMS_Number__c, Username, DialPadUserId__c
        FROM USER
        WHERE ID = :UserInfo.getUserId()
        WITH USER_MODE
      ];

      Organization myOrg = [SELECT Name FROM Organization WITH USER_MODE LIMIT 1];

      String phoneToSend;
      String phoneCustomer;
      String nameOfUser;

      Lead lead = new Lead();
      Opportunity opportunity = new Opportunity();
      Contact contact = new Contact();
      Transactions__c transactionRecord = new Transactions__c();
      Interested_Buyers__c interestedBuyer = new Interested_Buyers__c();
      User userRecord = new User();

      String objectUsed = Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(
        recordId
      );
      if (objectUsed == 'Lead') {
        List<CampaignMember> cms = [
          SELECT CampaignID, Campaign.smrtPhone_Number__c, LeadID, Status
          FROM CampaignMember
          WHERE LeadID = :recordId
          WITH USER_MODE
        ];
        if (cms.size() > 0 && cms[0].Campaign.smrtPhone_Number__c != null) {lead = [SELECT Id,MobilePhone, Phone,FirstName,LastName,Street,owner.firstname,owner.phone,Owner.Name,OwnerId FROM Lead WHERE Id = :recordId WITH USER_MODE]; //Id =:recordId
          User userCampaign = [Select Id,DialPadUserId__c FROM User where Id =:lead.OwnerId WITH USER_MODE];

          phoneToSend = lead.MobilePhone;
          phoneCustomer = cms[0].Campaign.smrtPhone_Number__c;
          nameOfUser = lead.Owner.Name != null ? lead.Owner.Name : '';
          hasCampaign = true;

          if (myCM2[0].Provider_SMS__c == 'Dialpad') {
            phoneCustomer = userCampaign.DialPadUserId__c;
          }

        } else {
          lead = [
            SELECT
              Id,
              Phone,
              MobilePhone,
              FirstName,
              LastName,
              Street,
              owner.firstname,
              Owner.Name,
              owner.phone,
              OwnerId
            FROM Lead
            WHERE Id = :recordId
            WITH USER_MODE
          ];
          User user1 = [
            SELECT Id, Phone, SMS_Number__c, DialPadUserId__c
            FROM User
            WHERE Id = :lead.OwnerId
            WITH USER_MODE
          ];
          nameOfUser = lead.Owner.Name != null ? lead.Owner.Name : '';
          phoneToSend = lead.MobilePhone;
          phoneCustomer = user1.Phone;

          if (myCM2[0].Provider_SMS__c == 'Dialpad') {phoneCustomer = user1.DialPadUserId__c;
          }
        }
        if (phoneToSend == null) {
          
          listSobject.add(returnError(
            phoneCustomer,
            phoneToSend,
            'Lead doesn\'t have number',
            '',
            lead.Id,
            'Lead doesn\'t have number'
          ));
             
          return listSobject;
        }
      } else if (objectUsed == 'Opportunity') {
        opportunity = [
          SELECT
            MobilePhone__c,
            owner.phone,
            account.firstname,
            Owner.Name,
            Owner.firstname,
            Appointment_Date_Time__c,
            Owner.DialPadUserId__c
          FROM Opportunity
          WHERE Id = :recordId
          WITH USER_MODE
        ];
        User user2 = [
          SELECT Id, SMS_Number__c, Phone, DialPadUserId__c
          FROM User
          WHERE Id = :opportunity.OwnerId
          WITH USER_MODE
        ];
        nameOfUser = opportunity.Owner.Name != null
          ? opportunity.Owner.Name : '';
        phoneToSend = opportunity.MobilePhone__c;
        phoneCustomer = user2.Phone;

        if (myCM2[0].Provider_SMS__c == 'Dialpad') { phoneCustomer = user2.DialPadUserId__c;
        }

        if (phoneToSend == null) {
            
          listSobject.add(returnError(
            phoneCustomer,
            phoneToSend,
            'Opportunity doesn\'t have number',
            '',
            opportunity.Id,
            'opportunity doesn\'t have number'
          ));
          return listSobject;
             
         
        }
      } else if (objectUsed == 'Contact') {
        contact = [
          SELECT mobilePhone, owner.phone, OwnerId, Owner.Name
          FROM Contact
          WHERE Id = :recordId
          WITH USER_MODE
        ]; 
        User user3 = [
          SELECT Id, SMS_Number__c, Phone, DialPadUserId__c
          FROM User
          WHERE Id = :contact.OwnerId
          WITH USER_MODE
        ];
        nameOfUser = Contact.Owner.Name != null ? Contact.Owner.Name : '';
        phoneToSend = contact.mobilePhone;
        phoneCustomer = user3.Phone;

        if (myCM2[0].Provider_SMS__c == 'Dialpad') { phoneCustomer = user3.DialPadUserId__c;
        }

        if (phoneToSend == null) {
          
          listSobject.add(returnError(
            phoneCustomer,
            phoneToSend,
            'Contact doesn\'t have number',
            '',
            contact.Id,
            'contact doesn\'t have number'
          ));
          return listSobject;
        }
      } else if (
        objectUsed == 'Transactions__c' ||
        objectUsed == 'Left_Main__Transactions__c'
      ) {
        transactionRecord = [
          SELECT Id, Mobile_Phone__c, OwnerId, Owner.Name
          FROM Transactions__c
          WHERE Id = :recordId
          WITH USER_MODE
        ];
        userRecord = [
          SELECT Id, SMS_Number__c, Phone, DialPadUserId__c
          FROM User
          WHERE Id = :transactionRecord.OwnerId
          WITH USER_MODE
        ];
        nameOfUser = transactionRecord.Owner.Name != null
          ? transactionRecord.Owner.Name
          : '';
        phoneToSend = transactionRecord.Mobile_Phone__c;
        phoneCustomer = userRecord.Phone;

        if (myCM2[0].Provider_SMS__c == 'Dialpad') {
          phoneCustomer = userRecord.DialPadUserId__c;
        }

      } else if (
        objectUsed == 'Interested_Buyers__c' ||
        objectUsed == 'Left_Main__Interested_Buyers__c'
      ) {
        interestedBuyer = [
          SELECT
            Id,
            Contact__r.mobilePhone,
            Transactions__r.OwnerId,
            Transactions__r.Owner.Name
          FROM Interested_Buyers__c
          WHERE Id = :recordId
          WITH USER_MODE
        ];
        userRecord = [
          SELECT Id, SMS_Number__c, Phone, DialPadUserId__c
          FROM User
          WHERE Id = :interestedBuyer.Transactions__r.OwnerId
          WITH USER_MODE
        ];
        nameOfUser = interestedBuyer.Transactions__r.Owner.Name != null
          ? interestedBuyer.Transactions__r.Owner.Name
          : '';
        phoneToSend = interestedBuyer.Contact__r.mobilePhone;
        phoneCustomer = userRecord.Phone;

        if (myCM2[0].Provider_SMS__c == 'Dialpad') {
          phoneCustomer = userRecord.DialPadUserId__c;
        }

      }

      error += 'line 73';

      List<LMR_TemplateSms__c> templateOfSms = [
        SELECT Name, Body__c, Object__c
        FROM LMR_TemplateSms__c
        WHERE Id = :idTemplate
        WITH USER_MODE
      ];
      error += 'line 76';

      String objTemplate = templateOfSms[0].Object__c;
      if(objTemplate == 'Interested Buyers'){ objTemplate = 'Interested_Buyers__c';
      }else if( objTemplate == 'Transactions'){ objTemplate ='Transactions__c';
      }
		system.debug('>objTemplate:::'+objTemplate);
      String messagebody = templateOfSms[0].Body__c;
      String templateName = templateOfSms[0].Name;
      Id templateId = templateOfSms[0].Id;
      error += 'line 82';

      if (messagebody.contains('{LastName}') && lead?.LastName != null) {messagebody = messagebody.replace('{LastName}', lead.LastName);
      }
      if (messagebody.contains('{Lead.LastName}') && lead?.LastName != null) {messagebody = messagebody.replace('{Lead.LastName}', lead.LastName);
      }
      if (messagebody.contains('{!$User.name}') && nameOfUser != null) {messagebody = messagebody.replace('{!$User.name}', nameOfUser);
      }
      if (messagebody.contains('{!$Organization.name}') && myOrg.Name != null) {messagebody = messagebody.replace('{!$Organization.name}', myOrg.Name);
      }
      error += 'line 92';
      if (
        messagebody.contains('{!Lead.owner.firstname}') && lead?.owner.firstname != null
      ) {
        messagebody = messagebody.replace(
          '{!Lead.owner.firstname}',
          lead.owner.firstname
        );
      }
      if ( messagebody.contains('{!Lead.owner.phone}') && lead?.owner.Phone != null
      ) {
        messagebody = messagebody.replace(
          '{!Lead.owner.phone}',
          lead.owner.Phone
        );
      } else {
        messagebody = messagebody.replace('{!Lead.owner.phone}', '#######');
      }
      if (
        Opportunity.account?.firstname != null &&
        messagebody.contains('{!Opportunity.account.firstname}') &&
        objectUsed == 'Opportunity'
      ) {
        messagebody = messagebody.replace(
          '{!Opportunity.account.firstname}',
          opportunity.account.firstname
        );
      }

      if (
        Opportunity.owner?.firstname != null &&
        messagebody.contains('{!Opportunity.owner.firstname}') &&
        objectUsed == 'Opportunity'
      ) {
        messagebody = messagebody.replace(
          '{!Opportunity.owner.firstname}',
          opportunity.owner.firstname
        );
      }


      if (messagebody.contains('&#39;')) { messagebody = messagebody.replace('&#39;', '\'');
      }

      if (messagebody.contains('&#39')) { messagebody = messagebody.replace('&#39', '\'');
      }
      error += 'line 114';


      error += 'messagebody: ' + messagebody;
      String msgBody = messagebody;

      List<String> blackListStr = new List<String>{
        'owner.firstname',
        'account.firstname',
        'owner.phone'
      };
      Pattern pt = Pattern.compile('\\{\\!([a-z|A-Z|0-9].*?)\\}'); // {}
      msgBody = msgBody.replace('Lead.', '');
      msgBody = msgBody.replace('Opportunity.', '');
      msgBody = msgBody.replace('Contact.', '');
      msgBody = msgBody.replace('Left_Main__Interested_Buyers__c.', '');
      msgBody = msgBody.replace('Left_Main__Transactions__c.', '');
      msgBody = msgBody.replace('Transactions__c.', '');
      msgBody = msgBody.replace('Interested_Buyers__c.', '');

      Matcher m = pt.matcher(msgBody);
      List<String> names = new List<String>();
      Map<String, String> mapFields = new Map<String, String>();
      String Query = 'SELECT ';
      while (m.find()) {
        names.add(m.group());
        String myfield = m.group().removeStart('{!').replace('}', '');
        mapFields.put(m.group(), myfield);
        if (!Query.contains(myfield)) {
          Query += myfield + ', ';
        }
      }

      Query +=
        'Id ' +
        ' FROM ' +
        objTemplate +
        ' ' +
        ' WHERE ' +
        ' Id=\'' +
        recordId +
        '\'';

      error += Query;

      messagebody = Lmr_SmrtPhoneUtils_cls.buildMessage(
        messagebody,
        objTemplate,
        recordId
      );
      error += messagebody;

      error += 'line 118';
      messagebody = messagebody.replaceAll('\\{.*?\\}', '');

      String errorMessage = '';

      error += 'line 118';
      if (
        (myCM2[0].Provider_SMS__c == null ||
        myCM2[0].Provider_SMS__c == 'Smrtphone' ||
        isSmrtphone == true) &&
        isDialPad == false &&
        isRingCentral == false &&
        isGoSmrtphone == true
      ) {
        System.debug('enter smrtphone');
        error += 'line 414';
        error += 'Smrtphone Provider';
        String endPoint = myCM[0].base_url__c;
        String accessToken = myCM[0].access_token__c;
        String finalEndPoint = endPoint;

        String testBody = 'message';

        String requestBody =
          'from=' +
          EncodingUtil.urlEncode(phoneCustomer, 'UTF-8') +
          '&to=' +
          EncodingUtil.urlEncode(phoneToSend, 'UTF-8') +
          '&message=' +
          EncodingUtil.urlEncode(messagebody, 'UTF-8') +
          '&sfRecordId=' +
          EncodingUtil.urlEncode(recordId, 'UTF-8');
        Http http = new Http();
        httpRequest httpReq = new httpRequest();
        HttpResponse response = new HttpResponse();
        error += 'requestBody: ' + requestBody;
        httpReq.setMethod('POST');
        httpReq.setEndpoint(finalEndPoint);
        httpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        httpReq.setHeader('X-Auth-smrtPhone', accessToken);
        httpReq.setBody(requestBody);
        error += 'httpReq: ' + httpReq;

        try {
          response = http.send(httpReq);
            System.debug('response status: '+response.getStatusCode());
          if (response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            listSobject.add(returnSmsHistory(
              phoneCustomer,
              phoneToSend,
              messagebody,
              templateName,
              templateId,
              recordId
            ));
          } else {
            String responseBody = response.getBody();
            errorMessage =
              'Unexpected Error while communicating with API. ' +
              'Status ' +
              response.getStatus() +
              ' and Status Code ' +
              response.getStatuscode();
            listSobject.add(returnError(phoneCustomer,phoneToSend,messagebody,templateName,recordId,errorMessage + ' requestBody: ' + requestBody));

          }
        } catch (System.Exception e) {
          if (String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')) {
            errorMessage ='Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->' +' Remote Site Setting and add ' +' ' +endPoint +' Endpoint';
          } else {
            errorMessage ='Unexpected Error while communicating with API. ' +'Status ' +response.getStatus() +' and Status Code ' +response.getStatuscode();
          }

          listSobject.add(returnError(phoneCustomer,phoneToSend,messagebody,templateName,recordId,errorMessage + ' requestBody: ' + requestBody));
        }
      } else if (
        (myCM2[0].Provider_SMS__c == 'Ring Central' ||
        isRingCentral == true) &&
        isDialPad == false &&
        isSmrtphone == false &&
        isGoRingCentral == true
      ) {
        
        error += 'Ring Central Provider';
        String typeOfAuthentication = apiSettingRingCentral[0]
          .Authentication_Method__c;
        String JWT = apiSettingRingCentral[0].JWT__c;

        String username = apiSettingRingCentral[0].username__c;
        String password = apiSettingRingCentral[0].password__c;
        String grantType = 'password';
        String secretKey = apiSettingRingCentral[0].secretKey__c;
        String apiKey = apiSettingRingCentral[0].apiKey__c;
        String authUrl = apiSettingRingCentral[0].authUrl__c;
        String authUrl2 = apiSettingRingCentral[0].authUrl2__c;

        String accessToken = '';

        // Get the Access Token to get the call log
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(authUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String authorizationHeader = '';
        String requestBody = '';

        if (typeOfAuthentication == 'Password Flow') {
          Blob headerValue = Blob.valueOf(apiKey + ':' + secretKey);
          authorizationHeader =
            'Basic ' + EncodingUtil.base64Encode(headerValue);
          requestBody =
          'username=' +
          EncodingUtil.urlEncode(username, 'UTF-8') +
          '&password=' +
          EncodingUtil.urlEncode(password, 'UTF-8') +
          '&grant_type=password';
        } else if (typeOfAuthentication == 'JWT') {
          String credentials = apiKey + ':' + secretKey;
          Blob headerValue = Blob.valueOf(credentials);
          authorizationHeader =
            'Basic ' + EncodingUtil.base64Encode(headerValue);
          requestBody =
            'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' +
            EncodingUtil.urlEncode(JWT, 'UTF-8');
        }

        request.setHeader(tokenParam, authorizationHeader);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(requestBody);

        HttpResponse response = http.send(request);

        // Parse the JSON response
        if (response.getStatusCode() != 200) {
          insert ErrorHandler_cls.insertErrorHandler(
            'The status code returned was not expected: ' +
              response.getStatusCode() +
              ' ' +
              response.getStatus() +
              response.getBody(),
            'Authentication Ring central'
          );
        } else {
            System.debug('values: '+response.getBody());
          Map<String, String> values = (Map<String, String>) JSON.deserialize(
            response.getBody(),
            Map<String, String>.class
          );
            System.debug('values: '+values);
          accessToken = values.get('access_token');

          String bodyApex =
            '{' +
            '"to": [{"phoneNumber": "' +
            phoneToSend +
            '"}],' +
            '"from": {"phoneNumber": "' +
            phoneCustomer +
            '"},' +
            '"text": "' +
            messagebody +
            '"' +
            '}';

          //String authUrlQ1 ='https://platform.devtest.ringcentral.com/restapi/v1.0/account/~/extension/~/sms';
          String authUrlQ1 = authUrl2;
          Http http2 = new Http();
          HttpRequest request2 = new HttpRequest();
          request2.setEndpoint(authUrlQ1);
          request2.setMethod('POST');
          String authorizationHeader2 = 'Bearer ' + accessToken;
          request2.setHeader(tokenParam, authorizationHeader2);
          request2.setHeader('Content-Type', 'application/json');
          request2.setBody(bodyApex);
          HttpResponse response2 = new HttpResponse();
          try {
            response2 = http2.send(request2);
            if (response2.getStatusCode() == 200) {
              String responseBody = response2.getBody();
              listSobject.add(returnSmsHistory(
                phoneCustomer,
                phoneToSend,
                messagebody,
                templateName,
                templateId,
                recordId
              ));
            } else {
              errorMessage =
                'Unexpected Error while communicating with API. ' +
                'Status ' +
                response2.getStatus() +
                ' and Status Code ' +
                response2.getStatuscode();

              listSobject.add(returnError(phoneCustomer,phoneToSend,messagebody,templateName,recordId,errorMessage + ' requestBody: ' + bodyApex));

              listSobject.add(returnError(phoneCustomer,phoneToSend,messagebody,templateName,recordId,response2.getBody()));

            }
          } catch (Exception e) {
            if (
              String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')
            ) {
              errorMessage =
                'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->' +
                ' Remote Site Setting and add ' +
                ' ' +
                authUrlQ1 +
                ' Endpoint';
            } else {
              errorMessage =
                'Unexpected Error while communicating with API. ' +
                'Status ' +
                response2.getStatus() +
                ' and Status Code ' +
                response2.getStatuscode();
            }
            listSobject.add(returnError(phoneCustomer,phoneToSend,messagebody,templateName,recordId,errorMessage + ' requestBody: ' + bodyApex));
          }
        }
      } else if (
        (myCM2[0].Provider_SMS__c == 'Dialpad' ||
        isDialPad == true) &&
        isRingCentral == false &&
        isSmrtphone == false &&
        isGoDialpad == true
      ) {
        error += 'DialPad: ';
        error += '' + phoneCustomer;
        List<Dialpad_Configuration__mdt> apiSettingDialpad = Dialpad_Configuration__mdt.getall().values();
        Boolean booleanSpecificUser=apiSettingDialpad[0].SpecificUser__c;

        if(booleanSpecificUser == true){
          phoneCustomer = apiSettingDialpad[0].UserId__c;
        }
        //HttpResponse responseDialPad = new HttpResponse();
        try {
          //newcomment
          //SendSmsDialPad sendRequestsms = new SendSmsDialPad();
          SendSmsDialPad.DialPadWrapperResponse wrapperResponse = new SendSmsDialPad.DialPadWrapperResponse();
          wrapperResponse= SendSmsDialPad.sendSms(phoneToSend, phoneCustomer,messagebody);
          
          if (wrapperResponse.responseApi.getStatusCode() != 200) {
            errorMessage =
              'Unexpected Error while communicating with API. ' +
              'Status ' +
              wrapperResponse.responseApi.getStatus() +
              ' and Status Code ' +
              wrapperResponse.responseApi.getStatuscode()+' body: '+wrapperResponse.responseApi.getBody();
						 
										
              listSobject.add(returnError(
              phoneCustomer,
              phoneToSend,
              wrapperResponse.requestSend,
              templateName,
              recordId,
              errorMessage
              ));
            
          } else {
            String responseBody = wrapperResponse.responseApi.getBody();
            listSobject.add(returnSmsHistory(
              phoneCustomer,
              phoneToSend,
              messagebody,
              templateName,
              templateId,
              recordId
            ));
          }
        } catch (Exception e) {
          if (
            String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')
          ) {
            errorMessage =
              'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->' +
              ' Remote Site Setting and add Endpoint';
          }
          listSobject.add(returnError(
            phoneCustomer,
            phoneToSend,
            messagebody,
            templateName,
            recordId,
            errorMessage + e
          ));
          return listSobject;
        }
        error += 'line 283';
      } else if (myCM2[0].Provider_SMS__c == 'CallRail' || isGoCallRail == true) {
        String toNumber = phoneToSend;
        HttpResponse response = SendSMSCallRail.sendSms(
          toNumber,
          messagebody,
          phoneCustomer
        );
        if (response.getStatusCode() == 200) {
          String responseBody = response.getBody();
          listSobject.add(returnSmsHistory(
            phoneCustomer,
            phoneToSend,
            messagebody,
            templateName,
            templateId,
            recordId
          ));
        } else {
          errorMessage =
            'Unexpected Error while communicating with API. ' +
            'Status ' +
            response.getStatus() +
            ' and Status Code ' +
            response.getStatuscode();
          
          listSobject.add(returnError(phoneCustomer,phoneToSend,messagebody,templateName,recordId,errorMessage + ' requestBody: ' + response.getBody()));
        }

      }
      return listSobject;

  }


  public static LMR_SmsHistory__c returnSmsHistory(String phoneCustomer,String phoneToSend,String messagebody,String templateName,Id templateId,Id recordId) {
    String objectUsed = Lmr_SmrtPhoneUtils_cls.findObjectNameFromRecordIdPrefix(recordId);

    LMR_SmsHistory__c smsHistory = new LMR_SmsHistory__c();

    LeftMain_SecurityUtils.checkRead(
      LMR_SmsHistory__c.SObjectType,
      new List<String>{
        'From__c',
        'To__c',
        'Body__c',
        'Name',
        'SmsTemplate__c',
        'Lead__c',
        'Opportunity__c',
        'Contact__c',
        'Information__c'
      }
    );

    smsHistory.From__c = phoneCustomer;
    smsHistory.To__c = phoneToSend;
    smsHistory.Body__c = messagebody;
    Integer maxSize = 80;
    if(templateName.length() > maxSize ){ templateName = templateName.substring(0, maxSize);
    }

    smsHistory.Name = templateName;
    smsHistory.SmsTemplate__c = templateId;
    if (objectUsed == 'Lead') {
      smsHistory.Lead__c = recordId;
    } else if (objectUsed == 'Opportunity') {
      smsHistory.Opportunity__c = recordId;
    } else if (objectUsed == 'Contact') {
      smsHistory.Contact__c = recordId;
    } else if (
      objectUsed == 'Transactions__c' ||
      objectUsed == 'Left_Main__Transactions__c'
    ) {
      smsHistory.Transactions__c = recordId;
    } else if (
      objectUsed == 'Interested_Buyers__c' ||
      objectUsed == 'Left_Main__Interested_Buyers__c'
    ) {
      smsHistory.Interested_Buyers__c = recordId;
     }
    smsHistory.Information__c = 'Now SMS';
    LeftMain_SecurityUtils.checkInsert(LMR_SmsHistory__c.SObjectType,new List<String>{
        'From__c',
        'To__c',
        'Body__c',
        'Name',
        'SmsTemplate__c',
        'Lead__c',
        'Opportunity__c',
        'Contact__c',
        'Information__c',
        'transactions__c',
        'interested_buyers__c'
      }
    );
    return smsHistory;
  }


  public static LMR_SmsError__c returnError(
    String phoneCustomer,
    String phoneToSend,
    String messagebody,
    String templateName,
    Id recordId,
    String errorBody
  ) {
    LMR_SmsError__c smsHistory = new LMR_SmsError__c();
    smsHistory.From__c = phoneCustomer;
    smsHistory.To__c = phoneToSend;
    smsHistory.Body__c = messagebody;
    smsHistory.Template__c = templateName;
    smsHistory.RecordObject__c = recordId;
    smsHistory.Error_Body__c = errorBody;
    smsHistory.Information__c = 'Now SMS';

    LeftMain_SecurityUtils.checkInsert(LMR_SmsError__c.SObjectType,new List<String>{
      'From__c',
      'To__c',
      'Body__c',
      'Template__c',
      'RecordObject__c',
      'Error_Body__c',
      'Information__c'
    }
  );
    return smsHistory;
    
  }
}