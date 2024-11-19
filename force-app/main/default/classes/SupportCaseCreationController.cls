public with sharing class SupportCaseCreationController {
    @auraEnabled public static void saveCase(String JSONInput) {
        try{
            CaseCreationData caseCreationdata = (SupportCaseCreationController.CaseCreationData) JSON.deserialize(JSONInput, CaseCreationData.Class);

            String sourceOrgId = UserInfo.getOrganizationId();
            String sourceCompanyName=UserInfo.getOrganizationName();
            String userName=UserInfo.getName();

            Http http=new Http();
            HttpRequest req = new HttpRequest();
            //Retriving email id from userinfo if email is not provided by user
            if(!String.isNotEmpty(caseCreationdata.email)){
                caseCreationdata.email=UserInfo.getUserEmail();
            }
            String caseCreationURL;
            caseCreationdata.ticketType = String.isNotBlank(caseCreationdata.ticketType) ? caseCreationdata.ticketType : '';
            caseCreationdata.attachmentLink = String.isNotBlank(caseCreationdata.attachmentLink) ? caseCreationdata.attachmentLink : '';
            caseCreationdata.collaborator= String.isNotBlank(caseCreationdata.collaborator) ? caseCreationdata.collaborator : '';
            caseCreationdata.collaboratorPhone= String.isNotBlank(caseCreationdata.collaboratorPhone) ? caseCreationdata.collaboratorPhone : '';
            caseCreationdata.collaboratorEmail = String.isNotBlank(caseCreationdata.collaboratorEmail) ? caseCreationdata.collaboratorEmail : '';
			caseCreationdata.credentials = String.isNotBlank(caseCreationdata.credentials) ? caseCreationdata.credentials : '';
            //Contactinating the values recieved from user form and constructing WebToCase URL
            if(!Test.isRunningTest()){
                //Production case creation URL
                caseCreationURL='https://webto.salesforce.com/servlet/servlet.WebToCase?encoding=UTF-8&orgid=00D6g000002gRaH&00N6g00000UTdHs='+EncodingUtil.urlEncode(sourceCompanyName,'UTF-8')+'&00N6g00000UTdHt='+EncodingUtil.urlEncode(sourceOrgId,'UTF-8')+'&00N6g00000UTe05='+EncodingUtil.urlEncode(userName,'UTF-8')+'&subject='+EncodingUtil.urlEncode(caseCreationdata.subject,'UTF-8')+'&description='+EncodingUtil.urlEncode(caseCreationdata.description,'UTF-8')+'&email='+caseCreationdata.email+'&phone='+EncodingUtil.urlEncode(caseCreationdata.phone,'UTF-8')
                    +'&name='+EncodingUtil.urlEncode(caseCreationdata.name,'UTF-8')
                	+'&00N6g00000Uwzc9='+EncodingUtil.urlEncode(caseCreationdata.collaborator,'UTF-8') 
					+'&00N6g00000UwzcE='+EncodingUtil.urlEncode(caseCreationdata.collaboratorPhone,'UTF-8')
					+'&00N6g00000UwzcJ='+caseCreationdata.collaboratorEmail
					+'&00N6g00000UwzcO='+EncodingUtil.urlEncode(caseCreationdata.credentials,'UTF-8')                    
                    +'&00N6g00000V6xbF='+EncodingUtil.urlEncode(caseCreationdata.ticketType,'UTF-8')
                    +'&00N6g00000VAWat='+EncodingUtil.urlEncode(caseCreationdata.attachmentLink,'UTF-8')
                    +'&submit=Submit';
            }else{ 
                //Sandbox case creation URL
                caseCreationURL='https://cs200.salesforce.com/servlet/servlet.WebToCase?encoding=UTF-8&orgid=00D7g0000008mQq&00N7g00000ABNmy='+EncodingUtil.urlEncode(sourceCompanyName,'UTF-8')+'&00N7g00000ABNhU='+EncodingUtil.urlEncode(sourceOrgId,'UTF-8')+'&00N7g00000ABObS='+EncodingUtil.urlEncode(userName,'UTF-8')+'&subject='+EncodingUtil.urlEncode(caseCreationdata.subject,'UTF-8')+'&description='+EncodingUtil.urlEncode(caseCreationdata.description,'UTF-8')+'&email='+caseCreationdata.email
                +'&phone='+EncodingUtil.urlEncode(caseCreationdata.phone,'UTF-8')
                +'&name='+EncodingUtil.urlEncode(caseCreationdata.name,'UTF-8')
                +'&00N6g00000Uwzc9='+EncodingUtil.urlEncode(caseCreationdata.collaborator,'UTF-8') 
				+'&00N6g00000UwzcE='+EncodingUtil.urlEncode(caseCreationdata.collaboratorPhone,'UTF-8')
				+'&00N6g00000UwzcJ='+caseCreationdata.collaboratorEmail
				+'&00N6g00000UwzcO='+EncodingUtil.urlEncode(caseCreationdata.credentials,'UTF-8')                    
                +'&00N6g00000V6xbF='+EncodingUtil.urlEncode(caseCreationdata.ticketType,'UTF-8')
                +'&00N6g00000VAWat='+EncodingUtil.urlEncode(caseCreationdata.attachmentLink,'UTF-8')
                +'&submit=Submit';
            }
            system.debug('CaseCreationURL' + caseCreationURL);
            //Invoking rest service to create case using WebToCase end point
            req.setEndpoint(caseCreationURL); 
            req.setMethod('POST'); 
            req.setHeader('Content-Type','application/x-www-form-urlencoded'); 
            req.setTimeout(120000);
            HttpResponse res = new HttpResponse(); 
            res = http.send(req);
            System.debug('Response -'+res);
        } catch(Exception ex){
            AuraHandledException exceptionMessage = new AuraHandledException(ex.getMessage());exceptionMessage.setMessage(ex.getMessage());throw exceptionMessage;
        }
    }
    
	@auraEnabled public static List <CaseWrapper1> viewCase(String str) {
        try{
            String sourceOrgId = UserInfo.getOrganizationId();
            String sourceCompanyName=UserInfo.getOrganizationName();
            String userName=UserInfo.getName();
            String endpoint='';
            //PRODUCTION
            if(!Test.isRunningTest()){
               // endpoint='https://leftmain.secure.force.com/LeftMainCases/services/apexrest/ViewCaseConnect';
                endpoint='https://leftmainrei.my.salesforce-sites.com/LeftMainCases/services/apexrest/ViewCaseConnect';

            }else{//DEV ORG
                endpoint='https://onedirect-leftmain.cs62.force.com/LeftMainCases/services/apexrest/ViewCaseConnect';
            }
            Http http=new Http();
            HttpRequest req = new HttpRequest();
            //Invoking rest service to create case using WebToCase end point
            req.setEndpoint(endpoint); 
            req.setMethod('GET'); 
            req.setHeader('token', sourceOrgId);
            req.setHeader('stat', str);
            req.setHeader('Content-Type','application/json'); 
            system.debug('sourceOrgId::::'+sourceOrgId);
            HttpResponse res = new HttpResponse(); 
            res = http.send(req);
            List<CaseWrapper1> cw = new List<CaseWrapper1>();
            cw  = (List<CaseWrapper1>) System.JSON.deserialize(res.getBody(), List<CaseWrapper1>.class);
            system.debug('My Wrapper'+cw);
            return cw;
        } catch(Exception ex){
            system.debug(ex.getMessage());
            return null;
            //AuraHandledException exceptionMessage = new AuraHandledException(ex.getMessage());exceptionMessage.setMessage(ex.getMessage());throw exceptionMessage;
        }
    }
    
    @auraEnabled public static AccManagerWrapper searchAccManager(String str){
          try{
              //FullPhotoUrl ::: https://salesforce.stackexchange.com/questions/117129/retrieving-the-profile-photo-for-a-user
            String sourceOrgId = UserInfo.getOrganizationId();
            String sourceCompanyName=UserInfo.getOrganizationName();
            String userName=UserInfo.getName();
            String endpoint='';
            //PRODUCTION
            if(!Test.isRunningTest()){
                //endpoint='https://leftmain.secure.force.com/LeftMainCases/services/apexrest/ViewAccountMngrConnect';
                endpoint = 'https://leftmainrei.my.salesforce-sites.com/LeftMainCases/services/apexrest/ViewAccountMngrConnect';
            }else{//DEV ORG
                endpoint='https://onedirect-leftmain.cs62.force.com/LeftMainCases/services/apexrest/ViewAccountMngrConnect';
            }
            Http http=new Http();
            HttpRequest req = new HttpRequest();
            //Invoking rest service to create case using WebToCase end point
            req.setEndpoint(endpoint); 
            req.setMethod('GET'); 
            req.setHeader('token', sourceOrgId);
            req.setHeader('Content-Type','application/json'); 
            system.debug('sourceOrgId::::'+sourceOrgId);
            HttpResponse res = new HttpResponse(); 
            res = http.send(req);
            AccManagerWrapper amw = new AccManagerWrapper();
            amw  = (AccManagerWrapper) System.JSON.deserialize(res.getBody(), AccManagerWrapper.class); 
            system.debug('My Wrapper'+amw);
        	return amw;
            
        } catch(Exception ex){
            system.debug(ex.getMessage());
            return null;
        }
    }
        
  	public class CaseWrapper1 {
        @AuraEnabled 
        public String caseNumber {get; set;}
        @AuraEnabled 
        public String subject{get; set;}
        @AuraEnabled 
        public String status{get; set;}
        @AuraEnabled 
        public String description{get; set;}
		@AuraEnabled 
        public String createdDate{get; set;}
        @AuraEnabled 
        public List<CaseComentWrapper> coments{get; set;}
    }    
	public class CaseComentWrapper {
        @AuraEnabled 
        public String commentBody {get; set;}
        @AuraEnabled 
        public DateTime createdDate {get; set;}
    }    
	public class AccManagerWrapper {
        @AuraEnabled 
        public String name {get; set;}
        @AuraEnabled 
        public String email {get; set;}
        @AuraEnabled 
        public String phone {get; set;}
        @AuraEnabled 
        public String mobile {get; set;}        
    }        
    public class CaseCreationData {
        public String subject;
        public String description;
        public String email;
        public String phone;
        public String name;
        public String ticketType;
        public String attachmentLink;
        public String collaborator;
        public String collaboratorPhone;
        public String collaboratorEmail;
        public String credentials;    
    }
}