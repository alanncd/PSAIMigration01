trigger TransactionExpenseTrigger on Transaction_Expense__c (before insert,before update) {
    
    // Check through custom setting 
    if( TransactionsExpenseTriggerControl__c.getOrgDefaults().ActivateTrigger__c){
        If(Trigger.IsBefore && (Trigger.IsInsert || Trigger.IsUpdate) ){ 
            // for check loan amount is valid or not.
            TransactionExpenseTriggerService.validationForTransactionExpense(Trigger.New,Trigger.old);
        }  
    }
}