@IsTest 
global class UnauthorizedEndpointResponse implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        CalloutException e = (CalloutException)CalloutException.class.newInstance();
        e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
        throw e;
    }
}