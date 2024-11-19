public with sharing class ErrorHandler_cls {
    public static void handleException(System.Exception ex, String processName){

        try{
            ErrorHandlerLmr__c   transactionLog = new ErrorHandlerLmr__c  (
                LogDetail__c 	 = ex.getStackTraceString() +';'+ '<br/> <strong> Message is: </strong>'+ex.getMessage() +';'
                + '<br/>'+ ex.getCause() +';'+ '<br/>'+ ex.getTypeName() +';'+ '<br/>' +'Line is: '+ ex.getLineNumber(),
                ProcessName__c  = processName
            );
            LeftMain_SecurityUtils.checkInsert(ErrorHandlerLmr__c.SObjectType,new List<String> {
                'LogDetail__c',
                'ProcessName__c'
              });
              List<ErrorHandlerLmr__c> listErrorHandler = new List<ErrorHandlerLmr__c>();
              listErrorHandler.add(transactionLog);

              if(Schema.sObjectType.ErrorHandlerLmr__c.isCreateable() && 
              Schema.sObjectType.ErrorHandlerLmr__c.fields.LogDetail__c.isCreateable() &&
              Schema.sObjectType.ErrorHandlerLmr__c.fields.ProcessName__c.isCreateable()
              ){
                SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE ,listErrorHandler);
                listErrorHandler = decision.getRecords();
                Database.insert(listErrorHandler);
              }

             
  
                 // insert transactionLog;
            }catch(Exception e){System.debug('Error is'+e);}
    }

    public static ErrorHandlerLmr__c returnHandleException(System.Exception ex, String processName){

        try{
            ErrorHandlerLmr__c   transactionLog = new ErrorHandlerLmr__c  (
                LogDetail__c 	 = ex.getStackTraceString() +';'+ '<br/> <strong> Message is: </strong>'+ex.getMessage() +';'
                + '<br/>'+ ex.getCause() +';'+ '<br/>'+ ex.getTypeName() +';'+ '<br/>' +'Line is: '+ ex.getLineNumber(),
                ProcessName__c  = processName
            );

            return transactionLog;}catch(Exception e){System.debug('Error is'+e);return null; }
    }

    public static ErrorHandlerLmr__c insertErrorHandler(String message, String processName){
        ErrorHandlerLmr__c newError = new ErrorHandlerLmr__c();
        newError.LogDetail__c = message;
        newError.ProcessName__c = processName;

        return newError;
    }
}