@isTest
public class CaseCalloutMock implements HttpCalloutMock{
  public HttpResponse respond(HTTPRequest req){
      String jsonString='['+
	'   {'+
	'      "subject":"My Subject",'+
	'      "status":"New",'+
	'    "description": "description 1",'+
	'    "caseNumber": "00009104"'+
	'   }'+
	']';     
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody(jsonString);
    return res;
  }
}