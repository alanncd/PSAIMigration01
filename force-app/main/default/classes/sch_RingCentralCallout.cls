//Apex Class To Call by Schedule Job RingCentral Call Logs / Read Messages
//@LeftMainRei
global with sharing class sch_RingCentralCallout implements Schedulable, Database.AllowsCallouts {
    @TestVisible public static String endpoint1 ='';
    @TestVisible public static String endpoint2 ='';
    @TestVisible public static String endpointTk ='';
	public static String authUrl;
	public static String authUrlCallLogs;
	public static String authUrlMessageStore;
    private final static String tokenParam = 'Authorization';
    global void execute(SchedulableContext SC) {
        sch_RingCentralCallout.getRingCentralLogs();
    }

    @future(callout=true) 
    public static void getRingCentralLogs() {  

        String accessToken=getToken();
		Datetime localgmt=Datetime.now();
		Datetime formattedDT = Datetime.newInstance(localgmt.year(), localgmt.month(), localgmt.day(), localgmt.hour(), localgmt.minute(), localgmt.second());        
		String datetoParam=formattedDT.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');  
        
		Datetime timeFrom =localgmt.addHours(-10);
        Datetime formattedDTFrom = Datetime.newInstance(timeFrom.year(), timeFrom.month(), timeFrom.day(), timeFrom.hour(), timeFrom.minute(), timeFrom.second());              
		String datefromParam=formattedDTFrom.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
        List<RingCentral_Data_Store2__c> rcdList = new list<RingCentral_Data_Store2__c>();
    	Map<string,RingCentral_Data_Store2__c> rcdValues = getCurrentRCDataStore();
        Map<string,RingCentral_Data_Store2__c> rcdValuesByExtId = getCurrentRCDataStoreByExtId();
        String endpointCalls=authUrlCallLogs+'?view=Simple&showBlocked=false&withRecording=false&dateFrom='+datefromParam+'&totalPages=100&perPage=100000&dateTo='+datetoParam;
        String endpointMessages=authUrlMessageStore+'?availability=Alive&dateFrom='+datefromParam;
        if(Test.isRunningTest()) {
            endpointCalls = endpoint1;
            endpointMessages = endpoint2;
        }
		HttpResponse res1 = getCallOut(accessToken, 'GET', endpointCalls);
		HttpResponse res2 = getCallOut(accessToken, 'GET', endpointMessages);        
        if (res2.getStatusCode() == 200) {
            Map<String, Object> resMsg = (Map<String, Object>)JSON.deserializeUntyped(res2.getBody());
            String json1 = res2.getBody().replace('"from" :', '"from1" :');  //Avoid Reserved Word
            uriWrapper  lstRecords= (uriWrapper) System.JSON.deserialize(json1, uriWrapper.class);
            List<Object> msgRecords = (List<Object>)resMsg.get('records');
            for(recordsWrapper msg : lstRecords.records){
                if(msg.direction=='Inbound' && msg.type=='SMS') {
                	if(rcdValuesByExtId.get(msg.id)==NULL){
                        RingCentral_Data_Store2__c RCDS = new RingCentral_Data_Store2__c();
                        LeftMain_SecurityUtils.checkRead(RingCentral_Data_Store2__c.SObjectType,new List<String> {
            				'name',
            				'Raw_Time_Filter__c',
            				'From_Number__c',
            				'To_Number__c',
                            'Caller_Phone_Number__c',
                            'To_Phone_Number__c',
                            'Type__c',
                            'Call_Result__c',
                            'ExternalId__c',
                            'Subject__c',
                            'conversationId__c'
        				});
        				LeftMain_SecurityUtils.checkUpdate(RingCentral_Data_Store2__c.SObjectType,new List<String> {
            				'name',
            				'Raw_Time_Filter__c',
            				'From_Number__c',
            				'To_Number__c',
                            'Caller_Phone_Number__c',
                            'To_Phone_Number__c',
                            'Type__c',
                            'Call_Result__c',
                            'ExternalId__c',
                            'Subject__c',
                            'conversationId__c'
        				});                             
                        string fromPhoneNumber='0000000';
	                    if(msg.from1.phoneNumber<>NULL){fromPhoneNumber = phoneNoPrefix(msg.from1.phoneNumber);}
                        List<toWrapper> toLst = msg.to;
    	            	string toPhoneNumber = phoneNoPrefix(toLst[0].phoneNumber);
                        RCDS.name = fromPhoneNumber;
                        RCDS.Raw_Time_Filter__c = msg.creationTime;
                        RCDS.From_Number__c = fromPhoneNumber;
                		RCDS.To_Number__c = toLst[0].phoneNumber;
                		RCDS.Caller_Phone_Number__c=string.valueof( fromPhoneNumber );
                		RCDS.To_Phone_Number__c =string.valueof( toPhoneNumber );  
                        RCDS.Type__c= msg.type;
                        RCDS.Subject__c= msg.subject.left(250);
                        RCDS.conversationId__c = msg.conversationId;
                        RCDS.ExternalId__c = msg.id;
                        rcdList.add(RCDS);
                    }
                }
            }
        }else{
            System.debug('ReadMessages: The status code returned was not expected: ' + res2.getStatusCode() + ' ' + res2.getStatus());
        }
		if (res1.getStatusCode() != 200) {
			System.debug('The status code returned was not expected: ' + res1.getStatusCode() + ' ' + res1.getStatus());
		} else {
			Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res1.getBody());
			List<Object> callrecords = (List<Object>)results.get('records');
	    	Integer Missed=0;
    		for(Object inidividualRecords : callrecords){
        
    	        Map<String,Object> uriv = (Map<String,Object> )inidividualRecords;
		        if(uriv.get('direction').equals('Inbound') )  {
            		Missed=Missed+1;
	            	Map<String, Object> resultsfrom = (Map<String, Object>)uriv.get('from');

    		        Map<String, Object> resultsto = (Map<String, Object>)uriv.get('to');
					if(rcdValues.get(uriv.get('startTime').toString())==null){ //If no exist the get, try to insert...
						string fromPhoneNumber;
	                    if(resultsfrom.get('phoneNumber')<>NULL){fromPhoneNumber = phoneNoPrefix(resultsfrom.get('phoneNumber').toString());}
	                    else{fromPhoneNumber = '0000000';}
    	            	string toPhoneNumber = phoneNoPrefix(resultsto.get('phoneNumber').toString());
  						RingCentral_Data_Store2__c RCDS = new RingCentral_Data_Store2__c();
                        LeftMain_SecurityUtils.checkRead(RingCentral_Data_Store2__c.SObjectType,new List<String> {
            				'name',
            				'Raw_Time_Filter__c',
            				'From_Number__c',
            				'To_Number__c',
                            'Caller_Phone_Number__c',
                            'To_Phone_Number__c',
                            'Call_Start_Time__c',
                            'Type__c',
                            'Call_Result__c',
                            'ExternalId__c'
        				});
        				LeftMain_SecurityUtils.checkUpdate(RingCentral_Data_Store2__c.SObjectType,new List<String> {
            				'name',
            				'Raw_Time_Filter__c',
            				'From_Number__c',
            				'To_Number__c',
                            'Caller_Phone_Number__c',
                            'To_Phone_Number__c',
                            'Call_Start_Time__c',
                            'Type__c',
                            'Call_Result__c',
                            'ExternalId__c'
        				});            
                		RCDS.name = fromPhoneNumber;
                		RCDS.Raw_Time_Filter__c = uriv.get('startTime').toString();
                		RCDS.From_Number__c = fromPhoneNumber;
                		RCDS.To_Number__c = resultsto.get('phoneNumber').toString();
                		RCDS.Caller_Phone_Number__c=string.valueof( fromPhoneNumber );
                		RCDS.To_Phone_Number__c =string.valueof( toPhoneNumber );    
                		RCDS.Call_Start_Time__c=datetime.valueof(string.valueof(uriv.get('startTime')).replace('T',' ')).addHours(-7);// why -7 ?
						RCDS.Type__c= uriv.get('type').toString();
                		RCDS.Call_Result__c = uriv.get('result').toString();
						RCDS.ExternalId__c = uriv.get('id').toString();
                 		rcdList.add(RCDS);
                }
    		}
    }
 
            if(rcdList.size()>0){
                SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, rcdList);
            	insert decision.getRecords(); 
            }
		}    
	}

    public static String getToken(){
		List<Ring_Central_Configuration__mdt> apiSettingRingCentral = [
			SELECT apiKey__c, authUrl__c, Authentication_Method__c,authUrl2__c, Password__c, secretKey__c,username__c,JWT__c,Url_Call_Logs__c,Url_Message_Store__c FROM Ring_Central_Configuration__mdt WITH USER_MODE LIMIT 1];		
    	String typeOfAuthentication = apiSettingRingCentral[0].Authentication_Method__c;
        String JWT = apiSettingRingCentral[0].JWT__c;
		authUrl=apiSettingRingCentral[0].authUrl__c;
		authUrlCallLogs=apiSettingRingCentral[0].Url_Call_Logs__c;
		authUrlMessageStore=apiSettingRingCentral[0].Url_Message_Store__c;
        String username = apiSettingRingCentral[0].username__c;
        String password = apiSettingRingCentral[0].password__c;
        String grantType = 'password';
        String secretKey = apiSettingRingCentral[0].secretKey__c;
        String apiKey = apiSettingRingCentral[0].apiKey__c;

        String accessToken = '';

        //Get the Access Token to get the call log
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
         if(Test.isRunningTest()) {
            authUrl = endpointTk;
        }
        
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
          authorizationHeader ='Basic ' + EncodingUtil.base64Encode(headerValue);
          requestBody ='grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' +EncodingUtil.urlEncode(JWT, 'UTF-8');
        }

        request.setHeader(tokenParam, authorizationHeader);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(requestBody);

        HttpResponse response = http.send(request);

		if (response.getStatusCode() != 200) {
			System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus()+response.getBody());
            return '';
		} else {
			//get access token
			Map<String, String> values = (Map<String, String>)JSON.deserialize(response.getBody(), Map<String, String>.class);
        	return values.get('access_token');
        }
    }
    public static HttpResponse getCallOut(String token, String method, String endPoint){
		Http http2 = new Http();
		HttpRequest request2 = new HttpRequest();
		request2.setEndpoint(endPoint);
		request2.setMethod(method);
		request2.setHeader(tokenParam, 'Bearer ' + token);
		request2.setHeader('Content-Type', 'application/json');
		HttpResponse res = http2.send(request2);            
        return res; 
    }
    public static map<string,RingCentral_Data_Store2__c> getCurrentRCDataStore(){
        map<string,RingCentral_Data_Store2__c> rcdValues = new map<string,RingCentral_Data_Store2__c>();
        list<RingCentral_Data_Store2__c> oldrcd = [select id,From_Number__c,To_Number__c,Raw_Time_Filter__c,Caller_Phone_Number__c,Formatted_Date__c,To_Phone_Number__c 
                                               FROM RingCentral_Data_Store2__c WHERE CreatedDate =THIS_WEEK WITH USER_MODE];
    	for(RingCentral_Data_Store2__c rcdss :oldrcd){rcdValues.put(rcdss.Raw_Time_Filter__c,rcdss);
    		}
        return rcdValues;
    }
    public static map<string,RingCentral_Data_Store2__c> getCurrentRCDataStoreByExtId(){
        map<string,RingCentral_Data_Store2__c> rcdValues = new map<string,RingCentral_Data_Store2__c>();
        list<RingCentral_Data_Store2__c> oldrcd = [Select id,ExternalId__c,From_Number__c,To_Number__c,Raw_Time_Filter__c,Caller_Phone_Number__c,Formatted_Date__c,To_Phone_Number__c 
                                               FROM RingCentral_Data_Store2__c WHERE CreatedDate =THIS_WEEK WITH USER_MODE];
    	for(RingCentral_Data_Store2__c rcdss :oldrcd){rcdValues.put(rcdss.ExternalId__c,rcdss);
    		}
        return rcdValues;
    }
    public static String phoneNoPrefix(String phone){
        return phone.replaceAll('\\+1', '');
    }
    class uriWrapper{
        public List<recordsWrapper> records;
        public String uri;
    }
	class recordsWrapper {
		public String id;	//11577807004
		public String extensionId;	//313317004
		public List<toWrapper> to;
		public fromWrapper from1;
		public String type;	//SMS
		public String creationTime;	//2022-08-02T03:50:43.000Z
		public String readStatus;	//Unread
		public String priority;	//Normal
		public String direction;	//Inbound
		public String availability;	//Alive
		public String subject;	//Test SMS using a RingCentral Developer account - Hello World 2
		public String messageStatus;	//Received
		public String conversationId;	//2993725128944310000
		public String lastModifiedTime;	//2022-08-02T03:50:43.826Z
    }
	class toWrapper {
		public String phoneNumber;	//+14707992601
		public String name;	//Larry Kite
		public String location;	//Atlanta Northeast, GA
	}
	class fromWrapper {
		public String phoneNumber;	//+14707992601
		public String name;	//Larry Kite
		public String location;	//Atlanta Northeast, GA
	}    
}