trigger EventTrigger on Event (before insert,after insert,after delete) {
    
    //check from custom setting for trigger 
    if(LeadActivityCountSetting__c.getOrgDefaults().ActivateEventTrigger__c) {
        if (Trigger.isAfter && Trigger.isInsert) {
            //Update event count on opportunity and lead.
           EventTriggerService.updateLeadEventCount(Trigger.New,Trigger.OldMap);
        }
        if (Trigger.isBefore && Trigger.isInsert) {
            //Update address on event and  appointment on opportunity.
           EventTriggerService.updateEventAddressAndAppointmentDT(Trigger.New,Trigger.OldMap);
        }
    } 
    
}