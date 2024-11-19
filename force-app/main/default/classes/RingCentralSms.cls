//Util Class to sent sms - Unt used
public with sharing class RingCentralSms {

    
    public static void sendSms(){

String username=Ring_Central_API_Setting__c.getOrgDefaults().username__c;
String password=Ring_Central_API_Setting__c.getOrgDefaults().password__c;
String grantType='password';   
String secretKey=Ring_Central_API_Setting__c.getOrgDefaults().secretKey__c;
String apiKey=Ring_Central_API_Setting__c.getOrgDefaults().apiKey__c;
String authUrl=Ring_Central_API_Setting__c.getOrgDefaults().authUrl__c;
String accessToken='';
authUrl ='https://platform.devtest.ringcentral.com/restapi/oauth/token';
username ='+14703172792';
password = 'leftmain123!';
// Get the Access Token to get the call log
Http http = new Http();
HttpRequest request = new HttpRequest();
request.setEndpoint(authUrl);
request.setMethod('POST');   
Blob headerValue = Blob.valueOf(apiKey + ':' + secretKey);    
//String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
String authorizationHeader = 'Basic '+'MWpxdTlhSGdUYjJNbTJtdkVEUVQ2dzpVNW02REM4alRSdTNrdU1jcVU4Ty13c2YxMWpFc0RRa0NHQ0dfaUJ5TDJfUQ==';

request.setHeader('Authorization', authorizationHeader);
request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
String payload = 'username='+EncodingUtil.urlEncode(username,'UTF-8')+'&password='+EncodingUtil.urlEncode(password,'UTF-8')+'&grant_type=password';
System.debug(''+payload);
System.debug(authorizationHeader);
request.setBody(payload);
HttpResponse response = http.send(request);    
System.debug('httprequest1'+request)    ;
    // Parse the JSON response
if (response.getStatusCode() != 200) {
System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus()+response.getBody());
} else {
System.debug('body1'+response.getBody());
Map<String, String> values = (Map<String, String>)JSON.deserialize(response.getBody(), Map<String, String>.class);
accessToken = values.get('access_token');
System.debug('Access token: '+accessToken);

String numberto = '+14703172792';
String numberFrom = '+14703172792';

String bodyApex = '{'+
'"to": [{"phoneNumber": "'+numberto+'"}],'+
'"from": {"phoneNumber": "'+numberFrom+'"},'+
'"text": "Test SMS message from Platform server"'+
'}';
String authUrlQ1 ='https://platform.devtest.ringcentral.com/restapi/v1.0/account/~/extension/~/sms';
Http http2 = new Http();
HttpRequest request2 = new HttpRequest();
request2.setEndpoint(authUrlQ1);
request2.setMethod('POST');
String authorizationHeader2 = 'Bearer ' + accessToken;
request2.setHeader('Authorization', authorizationHeader2);
request2.setHeader('Content-Type', 'application/json');
request2.setBody(bodyApex);
Try{
HttpResponse response2 = http2.send(request2);   

}catch(Exception e){

}

    }
}
    public static void sendSmsCallTrackingMetrics(){
        String smsUrl = 'https://api.calltrackingmetrics.com/api/v1/accounts/313948/sms';
        Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(smsUrl);
		request.setMethod('POST');   
		request.setHeader('Authorization', 'Basic YTMxMzk0OGQ0YjBhNmM3NjY4NThhOTY3YjYwNGMwYThhNWIwZGM0ZTpiYzZjNGU2NzgyZmViMjBjOTkzYmIyYjAxODdjMzRkZDI2Yjg=');
        //request.setHeader('Content-Type','multipart/form-data');
        request.setHeader('Content-Type', 'application/json');
        String fromNumber ='+17177449094';
        String ToNumber='+51987950594';
        String message ='Test Message';
		String payload = '{'+
	        '"from":"'+ fromNumber +'",'+
	        '"to":"'+ toNumber +'",'+
	        '"msg":"'+ message +'"'+
	        '}';
        String payl ='{"from":"+17177449094","to":"+51987950594","msg":"Test From LeftMain"}';
		request.setBody(payload);
		HttpResponse response = http.send(request);    

	    // Parse the JSON response
			if (response.getStatusCode() != 200) {
				System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus()+response.getBody());
			} else {
				System.debug('body1'+response.getBody());        
	    	}
        /*
         * RESPONSE PARSER
         {
    "status": "processing",
    "id": "MSGA9B07EC712F11C71B4887A7E9761449E03182663022C034DA25532996E25ED02",
    "warnings": {},
    "call_id": 2000713164,
    "parent_id": null
}
*/
		}
    public static void sendSmsDialPad(){
    String token='jPnXVGQK8d9sV6uCu6ugNCfH2GbwdNazQApZycAYjdbbQdwxxVeXvjtHzUZZ8Dz7tjqgAk5WGNTCfPwTKZU6nXAPV2KxUg4mfhKj';
	String numberUrl='https://dialpad.com/api/v2/numbers/%2B16027370407';
    String smsUrl= 'https://dialpad.com/api/v2/sms?accept=application/json&content-type=application/json';
    String user_id_sms ='';
    String message = 'test sms API';
    String to_number = '+13322642313';
        
    Http http1 = new Http();
	HttpRequest request1 = new HttpRequest();
	request1.setEndpoint(numberUrl);
	request1.setMethod('GET');   
    request1.setHeader('accept','application/json');
	request1.setHeader('Authorization', 'Bearer '+token);        
    HttpResponse response1 = http1.send(request1);
	if (response1.getStatusCode() == 200) {        
        System.debug('body 0 '+response1.getBody());   
        numberWrapper nw = (numberWrapper) System.JSON.deserialize(response1.getBody(), numberWrapper.class);
        System.debug(nw.target_type);   
        System.debug(nw.target_id);
        user_id_sms = nw.target_id;
    }             
	
    Http http = new Http();
	HttpRequest request = new HttpRequest();
	request.setEndpoint(smsUrl);
	request.setMethod('POST');   
	request.setHeader('Authorization', 'Bearer '+token);
	String payload = '{'+
        '"infer_country_code": false,'+
        '"to_numbers": ['+
        '"'+ to_number + '"'+
        '],'+
        '"user_id": '+user_id_sms+','+ 
        '"text": "'+ message + '"'+
        '}';
	request.setBody(payload);
        
	HttpResponse response = http.send(request);    
    // Parse the JSON response
		if (response.getStatusCode() != 200) {
			System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus()+response.getBody());
		} else {
			System.debug('body1'+response.getBody());        
    	}
	}
    
    class numberWrapper{
        public String target_id;
        public String target_type;        
    }
   
    class smsWrapper{
        public String direction;
        public String created_date;
        public String from_number;
        public String user_id;
        public List<String> to_numbers;
    }
}