@IsTest
public class SingleRequestMock implements HttpCalloutMock{
	protected Integer code;
    protected String status;
    protected String bodyAsString;
    protected Blob bodyAsBlob;
    protected Map<String, String> responseHeaders;

    public SingleRequestMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.bodyAsString = body;
        this.bodyAsBlob = null;
        this.responseHeaders = responseHeaders;
 }
 
 public SingleRequestMock(Integer code, String status, Blob body, Map<String, String> responseHeaders) {
      this.code = code;
      this.status = status;
      this.bodyAsBlob = body;
      this.bodyAsString = null;
      this.responseHeaders = responseHeaders;
 }
 
 public HTTPResponse respond(HTTPRequest req) {
     HttpResponse resp = new HttpResponse();
     resp.setStatusCode(code);
     resp.setStatus(status);
     if (bodyAsBlob != null) {
         resp.setBodyAsBlob(bodyAsBlob);
     } else {
         resp.setBody(bodyAsString);
     }
     
     if (responseHeaders != null) {
         for (String key : responseHeaders.keySet()) {
             resp.setHeader(key, responseHeaders.get(key));
         }
     }
     if(code == null){
        throw new CalloutException('HTTP callout not supported for test methods');

     }
     return resp;
 }

 @TestVisible class UnauthorizedEndpointResponse implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
        CalloutException e = (CalloutException)CalloutException.class.newInstance();
        e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
        throw e;
    }
}

}