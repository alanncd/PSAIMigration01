public with sharing class CustomWelcomeMatController {

    @auraEnabled public static WelcomeMatInfoWrapper getWelcomeMatInfo(String parametersJson){
          try{
              //Verify if the modal should appear in this user
              User usr = [Select Id, Hide_Welcome_LeftMain__c FROM User Where Id =:UserInfo.getUserId() WITH USER_MODE LIMIT 1];
              
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            WelcomeMatInfoWrapper wmw = new WelcomeMatInfoWrapper();
              List<LM_WelcomeMat_Config__mdt> mcs = [Select Id,external__c,description__c,icon__c,link__c,title__c,order__c FROM LM_WelcomeMat_Config__mdt WITH USER_MODE Order By order__c ASC  LIMIT 10000];
              List<WalktroughWrapper> walkList = new List<WalktroughWrapper>();
              for(LM_WelcomeMat_Config__mdt m:mcs){
               		WalktroughWrapper wtw = new WalktroughWrapper();    
            		wtw.description =m.description__c;
            		wtw.icon		=m.icon__c; 
                  	if(m.external__c==TRUE){wtw.link=m.link__c;}else{wtw.link=baseUrl+m.link__c;}
            		wtw.title		=m.title__c;
                  	walkList.add(wtw);
              }
            wmw.walktroughs = walkList;
              if(usr.Hide_Welcome_LeftMain__c ==TRUE){wmw.showmodal = FALSE;}else{wmw.showmodal = TRUE;}
        	return wmw;
            
        } catch(Exception ex){
            system.debug(ex.getMessage());
            return null;
        }
    }
    @auraEnabled public static String setModalOffByUser(String dummy){
        try{
        User usr = [Select Id, Hide_Welcome_LeftMain__c FROM User Where Id =:UserInfo.getUserId() WITH USER_MODE LIMIT 1];
        usr.Hide_Welcome_LeftMain__c=TRUE;
        LeftMain_SecurityUtils.checkUpdate(User.SObjectType,new List<String> {'Hide_Welcome_LeftMain__c'});
        List<User> listUsers = New List<User>();
        listUsers.add(usr);

        if (!Schema.sObjectType.User.isUpdateable() ||
            !Schema.sObjectType.User.fields.Hide_Welcome_LeftMain__c.isUpdateable()){
           throw new AuraHandledException('The user doesn\'t have the appropriate permissions to perform this operation.');    
        }

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, listUsers);
        Database.update(listUsers = decision.getRecords());
       
       

        return null;
        } catch(Exception ex){
            system.debug(ex.getMessage());
            return null;
        }            
    }
    @auraEnabled public static void setFeedbackToLMR(String feedback){
   		try{
            String sourceOrgId = UserInfo.getOrganizationId();
            String sourceCompanyName=UserInfo.getOrganizationName();
            String userName=UserInfo.getName();
			String feddbackURL = 'https://leftmain.secure.force.com/LeftMainCases/services/apexrest/AccountFeedbackService/v1'; ///anyvalue
            Http http=new Http();
            HttpRequest req = new HttpRequest();
            system.debug('1.'+sourceOrgId);
            system.debug('feedback parameter = .'+feedback);
            req.setEndpoint(feddbackURL); 
            req.setMethod('POST'); 
            req.setHeader('Content-Type','application/json'); 
			req.setHeader('token',sourceOrgId); 
            req.setHeader('feedback',feedback); 	
			req.setHeader('content-length','0'); 
            system.debug('requestBody:::::::::::::..'+req);
            HttpResponse res = new HttpResponse(); 
            res = http.send(req);
            system.debug(res);
            system.debug(res.getBody());
        } catch(Exception ex){
            system.debug('Error..');
            system.debug(ex.getMessage());
			AuraHandledException exceptionMessage = new AuraHandledException(ex.getMessage());exceptionMessage.setMessage(ex.getMessage());throw exceptionMessage;
        }               
    }
  	public class WelcomeMatInfoWrapper {
        @AuraEnabled 
        public Boolean showmodal {get; set;}        
        @AuraEnabled 
        public List<WalktroughWrapper> walktroughs{get; set;}        
    }    
  	public class WalktroughWrapper {
        @AuraEnabled 
        public String icon {get; set;}
        @AuraEnabled 
        public String title {get; set;}
        @AuraEnabled 
        public String description {get; set;}        
        @AuraEnabled 
        public String link {get; set;}
    }        

}