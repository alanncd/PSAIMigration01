public with sharing class LeadConversionAuraController {

    @AuraEnabled
    public static list<leadConversionWrapper> fetchLeadRecords(String nextStep){ 
        try {

            if (!Schema.sObjectType.Lead.isAccessible() || 
            !Schema.sObjectType.Lead.fields.Name.isAccessible() || 
            !Schema.sObjectType.Lead.fields.Email.isAccessible() || 
            !Schema.sObjectType.Lead.fields.Phone.isAccessible() || 
            !Schema.sObjectType.Lead.fields.Next_Step__c.isAccessible() || 
            !Schema.sObjectType.Lead.fields.Status.isAccessible())  {
                throw new AuraHandledException('The user doesn\'t have the appropriate permissions to perform this operation.');
                
            }

            LeftMain_SecurityUtils.checkRead(Lead.SObjectType,new List<String> 
            {
            'Id',
            'Name',
            'Email',
            'Phone',
            'Next_Step__c',
            'Status'
            });
         // Start building the SOQL query
         String soqlQuery = 'SELECT Id, Name, Email, Phone, Next_Step__c, Status FROM Lead WHERE IsConverted = false';
        
         // Add condition using a bind variable
         if (String.isNotBlank(nextStep)) {
             soqlQuery += ' AND Next_Step__c LIKE :nextStepPattern';
         }
 
         soqlQuery += ' ORDER BY Name ASC LIMIT 50000';
         
         // Define the bind variable
         String nextStepPattern = '%' + nextStep + '%';
 
         // Execute the query with the bind variable
         List<Lead> leadListObj = Database.query(soqlQuery);
 
            list<leadConversionWrapper> leadWrapper= new list<leadConversionWrapper>();
            for(Lead LeadObj :leadListObj){
                // Adding lead in wrapper class.
                leadWrapper.add(new leadConversionWrapper(LeadObj)) ;  
            }
            // Returning wrapper class.
            return leadWrapper;
        }catch(Exception ex){AuraHandledException exceptionMessage = new AuraHandledException(ex.getMessage());exceptionMessage.setMessage(ex.getMessage());throw exceptionMessage;}
    }

    @AuraEnabled
    public static String convertSelectedLead(List<String> selectedLead,String EmailAddress){
        try {
            if(!selectedLead.isEmpty() && String.isNotBlank(EmailAddress)){ 
                BatchLeadConversion batchConversionObj = new BatchLeadConversion(selectedLead,EmailAddress);
                ID batchprocessid = Database.executeBatch(batchConversionObj,1); 
                return String.valueOf(batchprocessid);
            }
            return '';
        }catch(Exception ex){AuraHandledException exceptionMessage = new AuraHandledException(ex.getMessage()); exceptionMessage.setMessage(ex.getMessage());throw exceptionMessage;}
    }

    public class leadConversionWrapper{
        @AuraEnabled public Lead leadObj; 
        @AuraEnabled public Boolean isBoolean;
        public leadConversionWrapper(Lead leadObj){
            this.leadObj = leadObj;
            this.isBoolean = false;
        }
    }

}