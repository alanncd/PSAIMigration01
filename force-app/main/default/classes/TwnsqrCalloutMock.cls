@isTest
public class TwnsqrCalloutMock implements HttpCalloutMock{
  public HttpResponse respond(HTTPRequest req){
      String jsonString='['+
	'   {'+
	'      "subject":"My Subject",'+
	'      "status":"New",'+
	'    "description": "description 1",'+
	'    "caseNumber": "00009104"'+
	'   }'+
	']';     
String x = '{"clientId":"123456","price":100.0,"photosLink":"https://anyphoto.com/photo.jpg",'+
           '"notifyContacts":[{"phone":"999999999","name":"Copado Integration",'+
           '"email":"technology@leftmainrei.com","company":null,"avatar":null},{"phone":null,"name":null,"email":null,"company":null,"avatar":null},{"phone":"999999999","name":"Copado Integration","email":"technology@leftmainrei.com","company":null,"avatar":null}],"externalRef":"a0V6e000018AmegEAC","expiresAt":"2023-12-10 00:00:00","displayContact":{"phone":"999999999","name":"Copado Integration","email":"technology@leftmainrei.com","company":null,"avatar":null},"description":null,"address":null}';
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody(x);
    return res;
  }
}