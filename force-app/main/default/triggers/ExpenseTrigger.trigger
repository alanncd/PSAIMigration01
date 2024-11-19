trigger ExpenseTrigger on Expense__c (after insert,after update) {
    
    if(ExpenseTriggerSetting__c.getOrgDefaults().Activate_Trigger__c) {
        if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
            ExpenseTriggerHandler.updateExpenses(trigger.new);
        }}
}