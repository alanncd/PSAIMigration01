global with sharing class LmrBatchUpdateCadenceStatus implements Database.Batchable<sObject>, Database.Stateful{
	global String sQuery;
    global String sObjectName;
    global String flagForUpdate;
    
    global LmrBatchUpdateCadenceStatus( String sQuery ,String sObjectName){
		this.sQuery = sQuery;
        this.sObjectName = sObjectName; 
	}
    global LmrBatchUpdateCadenceStatus( String sQuery ,String sObjectName, String flagForUpdate){
		this.sQuery = sQuery;
        this.sObjectName = sObjectName; 
        this.flagForUpdate = flagForUpdate;
	}

    global Database.QueryLocator start(Database.BatchableContext bc) {
    
        return Database.getQueryLocator( sQuery );

    }
    
    global void execute(Database.BatchableContext BC, List<sObject> lstObj){
        List<Lead> newListLead = new List<Lead>();
        List<Opportunity> newListOpportunity = new List<Opportunity>();

        for(sObject record:lstObj){
            switch on String.valueOf(sObjectName) {
                when 'Lead' { 
                    Lead newLead = new Lead();
                    newLead.Id = record.Id;
                    if(flagForUpdate == 'false'){
                        newLead.Has_Cadence__c = false;
                    }else{
                        newLead.Has_Cadence__c = true;

                    }

                    newListLead.add(newLead);
                }
                when 'Opportunity' { 
                    Opportunity opp = new Opportunity(); 
                    opp.id = record.Id;
                    opp.Has_Cadence__c =true;
                    newListOpportunity.add(opp);

                }
            }

        }

        SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.UPDATABLE, newListLead);
        newListLead = decision1.getRecords();
        Database.update(newListLead);

        SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.UPDATABLE, newListOpportunity);
        newListOpportunity = decision2.getRecords();
        Database.update(newListOpportunity);
        
    }
    global void finish(Database.BatchableContext bc){
        if(flagForUpdate == 'true'){
            //LmrBatchUpdateCadenceStatus bch2 = new LmrBatchUpdateCadenceStatus('SELECT Id, Has_Cadence__c FROM Lead WHERE Has_Cadence__c = true AND isConverted=false AND Id NOT IN (SELECT Lead__c from Cadences__c where StopCadences__c = false)','Lead','false');
          //  ID batchprocessid2 = Database.executeBatch(bch2,200);
        }

    }
}