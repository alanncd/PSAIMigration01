trigger OpportunityTrigger on Opportunity (after insert,before insert,before update) {

    //check from custom setting for trigger 
    if(OpportunityTriggerSetting__c.getOrgDefaults().Activate_Trigger__c) {

        if(Trigger.isInsert && Trigger.isBefore ) {
            OpportunityTriggerHandler.processRecords(Trigger.new);
        } 

        if( Trigger.isUpdate && Trigger.isBefore) { 
            if(Trigger.new != trigger.old){  
                OpportunityTriggerHandler.processRecords(Trigger.new);
            }
        }

    }
    
}