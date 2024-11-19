public with sharing class deleteErrorHandler {
    public deleteErrorHandler(ApexPages.StandardSetController controller){}
    public deleteErrorHandler(ApexPages.StandardController controller){}

    public PageReference deleteRecord(){
        
        List<ErrorHandlerLmr__c> list1 = [select id from ErrorHandlerLmr__c WITH USER_MODE Limit 10000];
       // LeftMain_SecurityUtils.checkObjectIsDeletable(ErrorHandlerLmr__c.SObjectType);
        if (!list1.isEmpty() &&  list1.getSObjectType().getDescribe().isDeletable() ) {
            Database.delete(list1, AccessLevel.User_mode);
        }
        
        Schema.DescribeSObjectResult result = ErrorHandlerLmr__c.SObjectType.getDescribe(); 
  		PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
  		pageRef.setRedirect(true); 
  		return pageRef; 
    }

    public PageReference deleteErrorSms(){
        List<LMR_SmsError__c> list1 = [select id from LMR_SmsError__c WITH USER_MODE Limit 10000];
        LeftMain_SecurityUtils.checkObjectIsDeletable(LMR_SmsError__c.SObjectType);

        if (!list1.isEmpty() &&  list1.getSObjectType().getDescribe().isDeletable() ) {
            Database.delete(list1, AccessLevel.User_mode);
        }
        Schema.DescribeSObjectResult result = LMR_SmsError__c.SObjectType.getDescribe(); 
  		PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
  		pageRef.setRedirect(true); 
  		return pageRef; 
    }
}