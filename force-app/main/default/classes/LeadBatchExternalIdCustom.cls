global with sharing class LeadBatchExternalIdCustom implements Database.Batchable<Sobject> {
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query= 'SELECT Id, Name, CustomExternalId__c, Street, City FROM Lead Where CustomExternalId__c	 = NULL AND Name <> Null And Street<> Null And isConverted = False';
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> scope)
    {
        for(Lead l: scope)
        {
            String varStreet = '';
            String varCity = '';
            if(l.Street <> NULL){
                varStreet=l.Street;
            }
            if(l.City <> NULL){
                varCity=l.City;
            }
            l.CustomExternalId__c =l.Name+'*'+varStreet+'*'+varCity;
        }
        LeftMain_SecurityUtils.checkUpdate(Lead.SObjectType,new List<String> {'CustomExternalId__c'});
        SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.UPDATABLE, scope);
        scope = decision3.getRecords();
        Database.update(scope );

    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}