/*
Create by LEftMain Rei
*/
global with sharing class batchUpdate implements Database.Batchable<Sobject> {
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query= 'SELECT Id, Name, AddressIndex__c, Street, City FROM Lead Where AddressIndex__c = NULL AND isConverted = False AND Street != NULL AND City != NULL';
        //return Database.QueryLocator(query);
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> scope)
    {
        for(Lead l: scope)
        {
            l.AddressIndex__c =l.Street+''+l.City;
        }
        LeftMain_SecurityUtils.checkUpdate(Lead.SObjectType,new List<String> {'AddressIndex__c'});
        SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.UPDATABLE, scope);
        scope = decision2.getRecords();
        Database.update(scope);

    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}