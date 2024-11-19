trigger CadencesTrigger on Cadences__c (After insert,Before insert) {


    if(CadencesTrigger__c.getOrgDefaults().Activate_trigger_cadences__c) { 
        switch on Trigger.operationType{

            when BEFORE_INSERT {
                if(Trigger.isInsert && Trigger.isBefore ) {
                    CadencesTriggerHandler.setRecordId(Trigger.New);
                } 

            }
            when AFTER_INSERT {
                if(Trigger.isInsert && Trigger.isAfter ) {
                    CadencesTriggerHandler.processBulkCadence(Trigger.New);          
                }

            }
        }

    }

}