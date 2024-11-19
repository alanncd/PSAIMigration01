public class SendSmsDialPad {
    private final static String tokenParam = 'Authorization';    
    public static DialPadWrapperResponse sendSms(String phoneToSend,String phoneCustomer,String messageBody) {

        List<Dialpad_Configuration__mdt> apiSettingDialpad = Dialpad_Configuration__mdt.getall().values();
        String authUrl= 'https://dialpad.com/api/v2/sms?accept=application/json&content-type=application/json';

        String toNumber = phoneToSend;
        String token=apiSettingDialpad[0].Token__c;
        String userId = '';
        Boolean booleanSpecificUser=apiSettingDialpad[0].SpecificUser__c;

        if(booleanSpecificUser == true){
            userId=apiSettingDialpad[0].UserId__c;
        }else{
            userId=phoneCustomer;
        }
        String dialpadToken='Bearer '+token;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(authUrl);
        request.setMethod('POST');   
        request.setHeader(tokenParam, 'Bearer '+token);

        String payload = '{'+
        '"infer_country_code": false,'+
        '"to_numbers": ["'+toNumber+'"],'+
        '"user_id": '+userId+','+
        '"text": '+'"'+messageBody+'"'+
        '}';

        request.setBody(payload);
        DialPadWrapperResponse responseReturned = new DialPadWrapperResponse();
        HttpResponse response = http.send(request);

        responseReturned.responseApi = response;
        responseReturned.requestSend = payload;

        return responseReturned;

    }

    public class DialPadWrapperResponse{
        public HttpResponse responseApi;
        public String requestSend;
    }
}