global class BatchLeadConvert implements Database.Batchable<sObject>,Database.Stateful{

    global String userEmailAddress='';
    global BatchLeadConvert(String userEmailAddress){
        this.userEmailAddress = userEmailAddress;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<querysUtilities__mdt> queriesBatch  = [SELECT Query__c FROM querysUtilities__mdt WHERE DeveloperName ='batchConvertLead'];
        if(queriesBatch.size() == 1){
            return Database.getQueryLocator(queriesBatch[0].Query__c);
        } else {
            return Database.getQueryLocator('');
        }
    }

    global void execute(Database.BatchableContext bc, List<Lead> scope){
        Set<String> LeadIdSet = new  Set<String>();
        List<LeadStatus> LeadStatusList = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true AND MasterLabel != null  Limit 1];
 
        for(Lead LeadObj : scope){
            LeadIdSet.add(LeadObj.Id);
        }

        if(!LeadIdSet.isEmpty()){
            List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();    
            if(!LeadStatusList.isEmpty()){
                // Add lead in list for covert.
                for(String LeadId : LeadIdSet){                
                    Database.LeadConvert Leadconvert = new Database.LeadConvert();    
                    Leadconvert.setLeadId(LeadId);                               
                    Leadconvert.setConvertedStatus(LeadStatusList[0].MasterLabel);             
                    MassLeadconvert.add(Leadconvert);     
                }                  
                if (!MassLeadconvert.isEmpty()){ 
                    List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert,false);       
                }      
            }
        }

    }

    global void finish(Database.BatchableContext bc){

        List<AsyncApexJob> AsyncApexObjList = [SELECT Id, NumberOfErrors,TotalJobItems
                                                     FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        if(String.isNotBlank(userEmailAddress) && !AsyncApexObjList.isEmpty() ){
            
            // Send an email to the Apex job's submitter notifying of job completion.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {userEmailAddress};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Lead Conversion Completed.'); 
            mail.setPlainTextBody('The batch Apex job processed ' + AsyncApexObjList[0].TotalJobItems +' batches with '+ AsyncApexObjList[0].NumberOfErrors + ' failures.');
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '+ results[0].errors[0].message);
            }
        }
    }


}