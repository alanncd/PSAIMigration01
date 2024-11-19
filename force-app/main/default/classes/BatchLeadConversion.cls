public with sharing class BatchLeadConversion implements
    Database.Batchable<sObject>, Database.Stateful{ 

    public List<String> LeadIdSet = new List<String>();
    public String userEmailAddress = ''; 
    List<LeadStatus> LeadStatusList = new List<LeadStatus>();
        
    public BatchLeadConversion(List<String> LeadIdSet,String userEmailAddress){ 
            this.LeadIdSet = LeadIdSet;
       		this.userEmailAddress = userEmailAddress;
            LeadStatusList = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true AND MasterLabel != null  Limit 1];
    }
        
    public Database.QueryLocator start(Database.BatchableContext bc) {
        LeftMain_SecurityUtils.checkRead(Lead.SObjectType,new List<String> 
        {
        'Id',
        'Name',
        'IsConverted'
        });
        String SOQLLead = 'SELECT Id, Name FROM Lead WHERE Id IN :LeadIdSet AND IsConverted = false LIMIT 5000000';
        System.debug(SOQLLead);
        return Database.getQueryLocator(SOQLLead); 
    }
    public void execute(Database.BatchableContext bc, List<Lead> scope){
        // process each batch of records
        Set<String> LeadIdSet = new  Set<String>();
        
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
                    try{
                    List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert);       
                    }Catch(Exception e){
                        
                    }                
                    }      
            }
        }
    }
        
    public void finish(Database.BatchableContext bc){
        LeftMain_SecurityUtils.checkRead(AsyncApexJob.SObjectType,new List<String> 
        {
        'Id',
        'NumberOfErrors',
        'TotalJobItems'
        });
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