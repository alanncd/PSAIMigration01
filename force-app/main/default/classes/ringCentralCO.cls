//Aopex Class to Test Ring Central Sandbox
global class ringCentralCO{
    
    public static void executeMe() {
        //---------------MODIFY HERE--------------------------  
        String username='+14707992601'; //+16025671505
        String password='Maindev01!';  //Maindev01!
        String grantType='password';   
        String secretKey='ZG2H6jwQRAOOULzJNdCH_g0ub6bmHVQdCGt-US-6ITaQ';
        String apiKey='ri4qGemRSi69uxKODyqGTA';
        String authUrl='https://platform.devtest.ringcentral.com/restapi/oauth/token?extension=101';
		//---------------END MODIFY HERE-----------------------------          
        String platformRC='https://platform.devtest.ringcentral.com/';       
		Datetime localgmt=Datetime.now();
		Datetime now_test = Datetime.now();
		Datetime formattedDT = Datetime.newInstance(now_test.year(), now_test.month(), now_test.day(), now_test.hour(), now_test.minute(), now_test.second());        
		String formatedTZ=formattedDT.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
		String todaysDateStr = formattedDT.format('yyyy-MM-dd');
		String todaysDateStrHMS = formattedDT.format('HH:mm:ss'); 
		String datetoParam=formatedTZ; // todaysDateStr+ 'T'+todaysDateStrHMS+'Z';     
		Datetime now2 =now_test.addHours(-10);//.addDays(-1);  // add now_test
		String formatedTZfrom=now2.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');         
		Integer offset2 = UserInfo.getTimezone().getOffset(now2);
		Datetime local2 = now2; 
		String todaysDateStr2 = local2.format('yyyy-MM-dd');   
		String todaysDateHMSStr2 = local2.format('HH:mm:ss');          
		String datefromParam=todaysDateStr2+ 'T'+todaysDateHMSStr2+'Z'; 
		datefromParam=formatedTZfrom;
        //-------------------------------------------------------
		String accessToken=''; 
       //-----------------
       //---------------MODIFY HERE--------------------------  
        String authUrlQ1=platformRC+'restapi/v1.0/account/~/call-log?view=Simple&showBlocked=false&withRecording=false&dateFrom='+datefromParam+'&totalPages=100&perPage=100000&dateTo='+datetoParam;         
        String authUrlCalllog=platformRC+'restapi/v1.0/account/~/call-log';
        //---------------END MODIFY HERE-----------------------------   
        accessToken= getToken(authUrl,apiKey, secretKey,username, password);
		getMissedCalls(accessToken,authUrlQ1);
    }
 		public static string getToken(String authUrl,String apiKey, String secretKey,String username, String password){
     String token='';
     // Get the Access Token to get the call log
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(authUrl);
    request.setMethod('POST');   
    Blob headerValue = Blob.valueOf(apiKey + ':' + secretKey);    
    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
    request.setHeader('Authorization', authorizationHeader);
    request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    String payload = 'username='+EncodingUtil.urlEncode(username,'UTF-8')+'&password='+EncodingUtil.urlEncode(password,'UTF-8')+'&grant_type=password';

    request.setBody(payload);
    HttpResponse response = http.send(request);    

    if (response.getStatusCode() != 200) {
    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus()+response.getBody());
    } else {
    System.debug('body1'+response.getBody());   
            //get access token
            Map<String, String> values = (Map<String, String>)JSON.deserialize(response.getBody(), Map<String, String>.class);
            token = values.get('access_token');
            System.debug('access token: '+token);
            
    }
     return token;
 }
        public static void getMissedCalls(String accessToken,String authUrlQ1){
            Http http2 = new Http();
            HttpRequest request2 = new HttpRequest();
            request2.setEndpoint(authUrlQ1);
            request2.setMethod('GET');   
            String authorizationHeader2 = 'Bearer ' + accessToken;
            request2.setHeader('Authorization', authorizationHeader2);
            request2.setHeader('Content-Type', 'application/json');
            HttpResponse response2 = http2.send(request2);    
            if (response2.getStatusCode() != 200) {
            	System.debug('The status code returned was not expected: ' + response2.getStatusCode() + ' ' + response2.getStatus());
            } else {
                String responseQ2=response2.getBody();
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(responseQ2); 
        	}
    
}
}