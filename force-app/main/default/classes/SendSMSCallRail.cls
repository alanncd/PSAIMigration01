public class SendSMSCallRail {
    private final static String tokenParam = 'Authorization';    
	public static HttpResponse sendSms(String customer_phone_number,String content,String userPhone) {
        System.debug('send sms');
        List<CallRail_Configuration__mdt> callRailConf = CallRail_Configuration__mdt.getall().values();
        smsBodyWrapper smsBody =new smsBodyWrapper();
		String callRailAccount= Test.isRunningTest() ? '3333333' : callRailConf[0]?.CallRail_Account_Number__c;
        String token=Test.isRunningTest() ? '33333': callRailConf[0].CallRail_Token__c;//'77d664ec441f5efa614969634753ab69';
		//Get Tracker 
		String endpoint ='https://api.callrail.com/v3/a/'+callRailAccount+'/trackers.json';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');   
        request.setHeader(tokenParam, 'Token token='+token);
        HttpResponse response = http.send(request);
        TrackerWrapper tw = (TrackerWrapper) System.JSON.deserialize(response.getBody(), TrackerWrapper.class);
		//Sent SMS
        smsBody.customer_phone_number=customer_phone_number;
        smsBody.content=content;
        smsBody.tracking_number = Test.isRunningTest() ? '3333333' : callRailConf[0].Default_Tracking_Number__c;//Default Number
        String endpointSms ='https://api.callrail.com/v3/a/'+callRailAccount+'/text-messages.json';
        for(Trackers t : tw.trackers){
            if(t.tracking_numbers.size()>0){
                smsBody.company_id = t.company.id;
                if(userPhone==t.tracking_numbers[0]){
                 	smsBody.tracking_number = t.tracking_numbers[0]; 
                    break;
                }
            }
        }
        Http http2 = new Http();
        HttpRequest request2 = new HttpRequest();
        request2.setEndpoint(endpointSms);
        request2.setMethod('POST');   
        request2.setHeader(tokenParam, 'Token token='+token);        
        request2.setHeader('Content-Type', 'application/json');   
        request2.setBody(System.JSON.serialize(smsBody));
		HttpResponse response2 = http.send(request2);
        return response;
    }
    public class smsBodyWrapper{
		  String customer_phone_number;
          String tracking_number;
          String content;
          String company_id;
    }
	public class Company {
		public String id;
		public String name;
	}
    public class Trackers {
		public String id;
		public String name;
		public String type;
		public String status;
		public String destination_number;
		public List<String> tracking_numbers;
		public Boolean sms_supported;
		public Boolean sms_enabled;
		public Company company;
	}
	public class TrackerWrapper {
		public List<Trackers> trackers;
	}    
}