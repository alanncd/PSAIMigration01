trigger TaskTrigger on Task (after insert,after delete) {
	
   //check from custom setting for trigger 
   if(LeadActivityCountSetting__c.getOrgDefaults().ActivateTaskTrigger__c && !System.isFuture() && !System.isBatch() && !checkRecursive.validateRecursivity) {
      if (Trigger.isAfter && Trigger.isInsert) {
         // Update task count on lead object records.
         //If User License is = Guest User License	// Try to avoid this method
        TaskTriggerService.updateLeadTaskCount(Trigger.New,Trigger.OldMap);
      } 
   } 
}