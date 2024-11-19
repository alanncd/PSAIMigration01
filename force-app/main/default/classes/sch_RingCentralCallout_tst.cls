@istest
public class sch_RingCentralCallout_tst {
    @testSetup static void setup() {
    List<Ring_Central_Configuration__mdt> apiSettingRingCentral = [
        SELECT apiKey__c, authUrl__c, Authentication_Method__c, authUrl2__c, Password__c, secretKey__c, username__c, JWT__c, Url_Call_Logs__c, Url_Message_Store__c
        FROM Ring_Central_Configuration__mdt
    ];
    }
    @isTest
    public static void testApi(){
        Datetime localgmt=Datetime.now();
		Datetime formattedDT = Datetime.newInstance(localgmt.year(), localgmt.month(), localgmt.day(), localgmt.hour(), localgmt.minute(), localgmt.second());        
		String datetoParam=formattedDT.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');  
        
		Datetime timeFrom =localgmt.addHours(-10);
        Datetime formattedDTFrom = Datetime.newInstance(timeFrom.year(), timeFrom.month(), timeFrom.day(), timeFrom.hour(), timeFrom.minute(), timeFrom.second());              
		String datefromParam=formattedDTFrom.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        
        String urlToken='https://platform.ringcentral.com/restapi/v1.0/account/~/call-log?view=Simple&showBlocked=true&withRecording=false&dateFrom='+datetoParam+'&totalPages=100&perPage=100000&dateTo='+datetoParam+'\'';
        String urlCallLogs='https://platform.ringcentral.com/restapi/v1.0/account/~/call-log?view=Simple&showBlocked=false&withRecording=false&dateFrom='+datefromParam+'&totalPages=100&perPage=100000&dateTo='+datetoParam;
        String urlReadMessages='https://platform.ringcentral.com/restapi/v1.0/account/~/extension/~/message-store?availability=Alive&dateFrom='+datefromParam;
        
        SingleRequestMock tokenMock = new SingleRequestMock(200,'OK',jsonToken(), null);
        SingleRequestMock callLogsMock = new SingleRequestMock(200,'OK',jsonCallLogs(), null);
        SingleRequestMock readMessagesMock = new SingleRequestMock(200,'OK',jsonReadMessages(), null);
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(urlToken,tokenMock);
    	requests.put(urlCallLogs,callLogsMock);
        requests.put(urlReadMessages,readMessagesMock);
      	MultiRequestMock mock = new MultiRequestMock(requests);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        	sch_RingCentralCallout.endpointTk=urlToken;
        	sch_RingCentralCallout.endpoint1=urlCallLogs;
        	sch_RingCentralCallout.endpoint2=urlReadMessages;
			sch_RingCentralCallout.getRingCentralLogs();
         	System.schedule('CentralringScheduler_test1',  '0 00 * * * ?', new sch_RingCentralCallout());
        	system.assertEquals(null, null);
	    Test.stopTest();
    }    
      
    public static String jsonToken(){
        String token=		'{'+
		'  "access_token": "1/fFAGRNJru1FTz70BzhT3Zg",'+
		'  "expires_in": 3920,'+
		'  "scope": "https://platform.ringcentral.com/restapi/oauth/token?extension=101",'+
		'  "token_type": "Bearer"'+
		'}';
        return token;
    }
    public static String jsonCallLogs(){
        String jsonr=		'{'+
		' "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log?view=Simple&dateFrom=2015-11-24T12:07:53.175Z&dateTo=2015-11-25T12:07:53.175Z&page=1&perPage=2",'+
		'  "records" : [ {'+
		'    "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log/IWM7cJogEv7xlu8?view=Simple",'+
		'    "id" : "IWM7cJogEv7xlu8",'+
		'    "sessionId" : "403631628008",'+
		'    "telephonySessionId": "s-9a03590172ea4d39a7cf7d5b6dba6a3b",'+
		'    "startTime" : "2015-11-25T12:07:51.000Z",'+
		'    "duration" : 10,'+
		'    "type" : "Voice",'+
		'    "direction" : "Inbound",'+
		'    "action" : "Phone Call",'+
		'    "result" : "Missed",'+
		'    "to" : {'+
		'      "phoneNumber" : "+16505556678"'+
		'    },'+
		'    "from" : {'+
		'      "phoneNumber" : "+18883930031",'+
		'      "name" : "John Smith"'+
		'    }'+
		'  }, {'+
		'    "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log/IWM7bHBPqeZTlu8?view=Simple",'+
		'    "id" : "IWM7bHBPqeZTlu8",'+
		'    "sessionId" : "403631625008",'+
		'    "telephonySessionId": "t-9a03590172ea4d39a7cf7d5b6dba6a3b",'+
		'    "startTime" : "2015-11-25T12:07:51.000Z",'+
		'    "duration" : 10,'+
		'    "type" : "Voice",'+
		'    "direction" : "Outbound",'+
		'    "action" : "VoIP Call",'+
		'    "result" : "Call connected",'+
		'    "to" : {'+
		'      "phoneNumber" : "+16504445567",'+
		'      "location" : "Palo Alto, CA"'+
		'    },'+
		'    "from" : {'+
		'      "phoneNumber" : "+18883930031",'+
		'      "name" : "John Smith"'+
		'    }'+
		'  } ],'+
		'  "paging" : {'+
		'    "page" : 1,'+
		'    "perPage" : 2,'+
		'    "pageStart" : 0,'+
		'    "pageEnd" : 1'+
		'  },'+
		'  "navigation" : {'+
		'    "nextPage" : {'+
		'      "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log?view=Simple&dateFrom=2015-11-24T12:07:53.175Z&dateTo=2015-11-25T12:07:53.175Z&page=2&perPage=2"'+
		'    },'+
		'    "firstPage" : {'+
		'      "uri" : "https://platform.ringcentral.com/restapi/v1.0/account/400643090008/call-log?view=Simple&dateFrom=2015-11-24T12:07:53.175Z&dateTo=2015-11-25T12:07:53.175Z&page=1&perPage=2"'+
		'    }'+
		'  } '+
		'}';
        
        return jsonr;
    }
    public static String jsonReadMessages(){
        String jsonRM=		'{'+
		'    "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/account/313317004/extension/313317004/message-store?availability=Alive&dateFrom=2022-08-01T03:56:00.000Z&page=1&perPage=100",'+
		'    "records": ['+
		'        {'+
		'            "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/account/313317004/extension/313317004/message-store/11577807004",'+
		'            "id": 11577807004,'+
		'            "extensionId": "313317004",'+
		'            "to": ['+
		'                {'+
		'                    "phoneNumber": "+14707992601",'+
		'                    "name": "Larry Kite",'+
		'                    "location": "Atlanta Northeast, GA"'+
		'                }'+
		'            ],'+
		'            "from" : {'+
		'                "phoneNumber": "+14707992601",'+
		'                "name": "Larry Kite",'+
		'                "location": "Atlanta Northeast, GA"'+
		'            },'+
		'            "type": "SMS",'+
		'            "creationTime": "2022-08-02T03:50:43.000Z",'+
		'            "readStatus": "Unread",'+
		'            "priority": "Normal",'+
		'            "attachments": ['+
		'                {'+
		'                    "id": 11577807004,'+
		'                    "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/account/313317004/extension/313317004/message-store/11577807004/content/11577807004",'+
		'                    "type": "Text",'+
		'                    "contentType": "text/plain"'+
		'                }'+
		'            ],'+
		'            "direction": "Inbound",'+
		'            "availability": "Alive",'+
		'            "subject": "Test SMS using a RingCentral Developer account - Hello World 2",'+
		'            "messageStatus": "Received",'+
		'            "conversationId": 2993725128944309569,'+
		'            "conversation": {'+
		'                "id": "2993725128944309569",'+
		'                "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/conversation/2993725128944309569"'+
		'            },'+
		'            "lastModifiedTime": "2022-08-02T03:50:43.826Z"'+
		'        },'+
		'        {'+
		'            "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/account/313317004/extension/313317004/message-store/11577805004",'+
		'            "id": 11577805004,'+
		'            "extensionId": "313317004",'+
		'            "to": ['+
		'                {'+
		'                    "phoneNumber": "+14707992601",'+
		'                    "name": "Larry Kite",'+
		'                    "location": "Atlanta Northeast, GA"'+
		'                }'+
		'            ],'+
		'            "from" : {'+
		'                "phoneNumber": "+14707992601",'+
		'                "name": "Larry Kite",'+
		'                "location": "Atlanta Northeast, GA"'+
		'            },'+
		'            "type": "SMS",'+
		'            "creationTime": "2022-08-02T03:50:42.000Z",'+
		'            "readStatus": "Read",'+
		'            "priority": "Normal",'+
		'            "attachments": ['+
		'                {'+
		'                    "id": 11577805004,'+
		'                    "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/account/313317004/extension/313317004/message-store/11577805004/content/11577805004",'+
		'                    "type": "Text",'+
		'                    "contentType": "text/plain"'+
		'                }'+
		'            ],'+
		'            "direction": "Outbound",'+
		'            "availability": "Alive",'+
		'            "subject": "Test SMS using a RingCentral Developer account - Hello World 2",'+
		'            "messageStatus": "Delivered",'+
		'            "smsSendingAttemptsCount": 1,'+
		'            "conversationId": 2993725128944309569,'+
		'            "conversation": {'+
		'                "id": "2993725128944309569",'+
		'                "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/conversation/2993725128944309569"'+
		'            },'+
		'            "lastModifiedTime": "2022-08-02T03:50:44.108Z"'+
		'        },'+
		'        {'+
		'            "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/account/313317004/extension/313317004/message-store/11577797004",'+
		'            "id": 11577797004,'+
		'            "extensionId": "313317004",'+
		'            "to": ['+
		'                {'+
		'                    "phoneNumber": "+14707992601",'+
		'                    "name": "Larry Kite",'+
		'                    "location": "Atlanta Northeast, GA"'+
		'                }'+
		'            ],'+
		'            "from" : {'+
		'                "phoneNumber": "+14707992601",'+
		'                "name": "Larry Kite",'+
		'                "location": "Atlanta Northeast, GA"'+
		'            },'+
		'            "type": "SMS",'+
		'            "creationTime": "2022-08-02T03:50:03.000Z",'+
		'            "readStatus": "Unread",'+
		'            "priority": "Normal",'+
		'            "attachments": ['+
		'                {'+
		'                    "id": 11577797004,'+
		'                    "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/account/313317004/extension/313317004/message-store/11577797004/content/11577797004",'+
		'                    "type": "Text",'+
		'                    "contentType": "text/plain"'+
		'                }'+
		'            ],'+
		'            "direction": "Inbound",'+
		'            "availability": "Alive",'+
		'            "subject": "Test SMS using a RingCentral Developer account - Hello World 1",'+
		'            "messageStatus": "Received",'+
		'            "conversationId": 2993725128944309569,'+
		'            "conversation": {'+
		'                "id": "2993725128944309569",'+
		'                "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/conversation/2993725128944309569"'+
		'            },'+
		'            "lastModifiedTime": "2022-08-02T03:50:03.400Z"'+
		'        },'+
		'        {'+
		'            "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/account/313317004/extension/313317004/message-store/11577795004",'+
		'            "id": 11577795004,'+
		'            "extensionId": "313317004",'+
		'            "to": ['+
		'                {'+
		'                    "phoneNumber": "+14707992601",'+
		'                    "name": "Larry Kite",'+
		'                    "location": "Atlanta Northeast, GA"'+
		'                }'+
		'            ],'+
		'            "from" : {'+
		'                "phoneNumber": "+14707992601",'+
		'                "name": "Larry Kite",'+
		'                "location": "Atlanta Northeast, GA"'+
		'            },'+
		'            "type": "SMS",'+
		'            "creationTime": "2022-08-02T03:49:52.000Z",'+
		'            "readStatus": "Read",'+
		'            "priority": "Normal",'+
		'            "attachments": ['+
		'                {'+
		'                    "id": 11577795004,'+
		'                    "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/account/313317004/extension/313317004/message-store/11577795004/content/11577795004",'+
		'                    "type": "Text",'+
		'                    "contentType": "text/plain"'+
		'                }'+
		'            ],'+
		'            "direction": "Outbound",'+
		'            "availability": "Alive",'+
		'            "subject": "Test SMS using a RingCentral Developer account - Hello World 1",'+
		'            "messageStatus": "Delivered",'+
		'            "smsSendingAttemptsCount": 1,'+
		'            "conversationId": 2993725128944309569,'+
		'            "conversation": {'+
		'                "id": "2993725128944309569",'+
		'                "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/conversation/2993725128944309569"'+
		'            },'+
		'            "lastModifiedTime": "2022-08-02T03:50:03.460Z"'+
		'        }'+
		'    ],'+
		'    "paging": {'+
		'        "page": 1,'+
		'        "totalPages": 1,'+
		'        "perPage": 100,'+
		'        "totalElements": 4,'+
		'        "pageStart": 0,'+
		'        "pageEnd": 3'+
		'    },'+
		'    "navigation": {'+
		'        "firstPage": {'+
		'            "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/account/313317004/extension/313317004/message-store?availability=Alive&dateFrom=2022-08-01T03:56:00.000Z&page=1&perPage=100"'+
		'        },'+
		'        "lastPage": {'+
		'            "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/account/313317004/extension/313317004/message-store?availability=Alive&dateFrom=2022-08-01T03:56:00.000Z&page=1&perPage=100"'+
		'        }'+
		'    }'+
		'}';
        return jsonRM;
    }
}