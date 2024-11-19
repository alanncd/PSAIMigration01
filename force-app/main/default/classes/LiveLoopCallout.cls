public with sharing class LiveLoopCallout {
    
    public static string sendPipelineObject(String requestJson,LiveLoopReqWrapper.OrgDetails orgDetails) {
        
        String encodedStringOrg = EncodingUtil.URLENCODE(orgDetails.orgName,'UTF-8').replace('+', '%20');
       // if()
        String restAPIURL = System.Label.LeftMainAudanticEndpoint + '/services/apexrest/AudanticData?OrgId='+orgDetails.orgId+'&OrgName='+encodedStringOrg+'&IsSandBox='+orgDetails.isSandbox;   
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('GET'); 
        httpRequest.setHeader('Content-Type','application/json');
        httpRequest.setTimeout(120000);
        httpRequest.setEndpoint(restAPIURL); 
        String response1 = '';
        Http http1 = new Http();   
        HttpResponse res;
        if(!Test.isRunningTest()){
            system.debug('Invoking API to LMA to check liscence availablility -' +restAPIURL);
            res =http1.send(httpRequest);
            system.debug('Liscence availability check response -' +res.getBody());
        }else{
            res=new HttpResponse();
            res.setStatusCode(200);
            res.setBody('Success');
        }
        string limitResult = string.valueOf(res.getBody());
        string result;
        
        if(limitResult.contains('Success')){
            HTTP http = new HTTP();
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint(System.Label.AudanticEndpoint);
            request.setTimeout(120000);
            request.setHeader('api_key', System.Label.Audantic_API_Key);
            request.setHeader('Content-Type','application/json');
                request.setBody(requestJson);
            request.setMethod('POST');
            HTTPResponse response;
            if(!Test.isRunningTest()){
                System.debug('API Invoked - '+System.Label.AudanticEndpoint);
                system.debug('Requst to LiveLoop : '+requestJson);
                response = http.send(request);
            }else{
                response=new HttpResponse();
                response.setStatusCode(200);
            }
            system.debug('Live loop callout statuscode -'+response.getStatusCode());
            system.debug('Live loop response -'+response.getBody());
            if(response.getStatusCode() == 200) {
                result = 'Data send to Audantic successfully';  
                HttpRequest httpRequestUpdateAPI = new HttpRequest();  
                httpRequestUpdateAPI.setMethod('POST'); 
                httpRequestUpdateAPI.setHeader('Content-Type','application/json');
                httpRequestUpdateAPI.setTimeout(120000);
                httpRequestUpdateAPI.setEndpoint(restAPIURL); 
                system.debug('orgId'+orgDetails.orgId);
                String body = '{'+
                    ' "ORGNAME" : "'+orgDetails.orgName+'", '+
                    ' "ORGID" : "'+orgDetails.orgId+'" ,'+
                    ' "userName" : "'+orgDetails.userName+'", '+ 
                    ' "apiName" : "'+'AudanticDetail'+'" '+  
                    '}';
                httpRequestUpdateAPI.setBody(body); 
                Http httpUpdateAPI = new Http();
                HttpResponse resUpdateApi;
                if(!Test.isRunningTest()){
                    resUpdateApi = httpUpdateAPI.send(httpRequestUpdateAPI);
                }else{
                    resUpdateApi=new HttpResponse();
                    resUpdateApi.setStatusCode(200);
                }
                system.debug('LMA Audantic API usage update request response -'+resUpdateApi.getBody());
                result='success';
            }
            else
            {
                result = 'Live loop callout failed status='+response.getStatusCode();
            }
        }
        else if(limitResult.contains('API limit exceeded. Upgrade your plan')){
            System.debug('API limit exceeded. Upgrde your plan!!');
            result = 'API limit exceeded. Upgrde your plan!!';
        }      
        else if (limitResult==null){
            System.debug('LMA liscence check callout failed');
            result = 'LMA liscence check callout failed';
        }
        else{
            result = limitResult;
        }
        
        return result;
    }
    
    public static LiveLoopReqWrapper.OrgDetails getOrgDetails() {
        LiveLoopReqWrapper.OrgDetails orgDetails=new LiveLoopReqWrapper.OrgDetails();
        orgDetails.IsSandbox = 'false';
        string username;
        List<Organization>  orgList = [SELECT Id, Name,issandbox  FROM Organization WITH USER_MODE LIMIT 1];
        List<User>  userList = [SELECT Id, Name  FROM User WHERE id = :UserInfo.getUserId() WITH USER_MODE LIMIT 1];
        if(!orgList.isEmpty()){ 
            orgDetails.OrgName = orgList[0].Name;
            String orgId = orgList[0].Id;
            orgDetails.OrgId   = orgId.substring(0,orgId.length()-3);
            orgDetails.IsSandbox  = string.valueOf(orgList[0].issandbox); 
        }
        if(!userList.isEmpty()){
            userName = userList[0].Name; 
        }
        return orgDetails;
    }
    
    public static void publishAccessToken(){
        LiveLoopReqWrapper.AccessToken wrapper  = new LiveLoopReqWrapper.AccessToken();
        wrapper.access_token = System.Label.Access_Token;
        String tokenJson = JSON.serialize(wrapper);
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        request.setEndpoint(System.Label.AudanticTokenEndPoint);        
        request.setTimeout(120000);
        request.setHeader('api_key',  System.Label.Audantic_API_Key);
        request.setBody(tokenJson);
        request.setMethod('PUT');
        HTTPResponse response;
        if(!Test.isRunningTest()){
            response =  http.send(request); 
        }else{
            response=new HttpResponse();
            response.setStatusCode(200);
        }
        system.debug('Response status- '+response.getStatusCode()+'Response body - '+response.getBody());        
        if(response.getStatusCode() == 200) {
            system.debug('Access Key send to Audantic successfully');
        }
        
    }
}