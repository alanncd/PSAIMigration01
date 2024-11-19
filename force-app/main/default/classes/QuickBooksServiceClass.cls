public with sharing class QuickBooksServiceClass {
	public static HttpResponse makeHttpRequest(String endPoint,String method,Map<String,String> headers,String body){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(method);
        request.setTimeout(120*1000);

        for(String header : headers.keySet()){
            request.setHeader(header,headers.get(header));
        }
        
        /* check body is null or not to solve problem when method type 'GET' */
        if(String.isNotBlank(body)){
            request.setBody(body);
        }
        Http h = new Http();
        HttpResponse response;
        try{
            response = h.send(request);
            return response;
        }
        catch(Exception e){
            return null;
        }
    }
}