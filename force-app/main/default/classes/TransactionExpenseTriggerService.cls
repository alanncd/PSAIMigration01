public with sharing class TransactionExpenseTriggerService {

    // for check loan amount is valid or not
    public static void validationForTransactionExpense(List <Transaction_Expense__c > newlist, List<Transaction_Expense__c > oldlist) {
        set<String> oldId = new Set<String>();
        
        LeftMain_SecurityUtils.checkObjectIsReadable(Transaction_Expense__c.SObjectType);
        if(oldlist != null && oldList.Size() > 0){
            for(Transaction_Expense__c TransactionExpenseObj: oldlist){
                oldId.add(TransactionExpenseObj.Id);
            }
        }
        Id accountLenderId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender').getRecordTypeId();
        Id LenderExpenseRecordId = Schema.SObjectType.Transaction_Expense__c.getRecordTypeInfosByName().get('Lender Expense').getRecordTypeId();
        
        Set<String> accountSet = new Set<String>();
        Set<String> transactionSet = new Set<String>();
        Map<String,Decimal> accountAndTransactionLoanAmountMap = new Map<String,decimal>();

        LeftMain_SecurityUtils.checkRead(Transaction_Expense__c.SObjectType,new List<String> {
            'Account__c',
            'Transaction__c',
            'RecordTypeId',
            'LoanAmount__c',
            'Id'
        });

        // Mapping Account and Transaction Id with loan amount.
        for (Transaction_Expense__c TransactionExpenseObj : newlist) {
            if(TransactionExpenseObj.Account__c != null && 	TransactionExpenseObj.Transaction__c != null && TransactionExpenseObj.RecordTypeId == LenderExpenseRecordId){
                accountSet.add(TransactionExpenseObj.Account__c);
                transactionSet.add(TransactionExpenseObj.Transaction__c);
                String AccountAndTransactionId  = String.valueOf(TransactionExpenseObj.Account__c+''+TransactionExpenseObj.Transaction__c);
                Decimal Amount = TransactionExpenseObj.LoanAmount__c != null ?  TransactionExpenseObj.LoanAmount__c : 0;
                if(!accountAndTransactionLoanAmountMap.containsKey(AccountAndTransactionId)){
                    accountAndTransactionLoanAmountMap.put(AccountAndTransactionId,Amount);
                }else{
                    Decimal oldAmount = accountAndTransactionLoanAmountMap.get(AccountAndTransactionId);
                    accountAndTransactionLoanAmountMap.put(AccountAndTransactionId,(Amount+oldAmount)); 
                }
            }   
        }

        LeftMain_SecurityUtils.checkRead(Account.SObjectType,new List<String> {
            'Id',
            'Loan_Amount__c',
            'RecordTypeId'
        });
        Map<ID, Account> AccountMap = new Map<ID, Account>([SELECT Id,Loan_Amount__c FROM Account WHERE RecordTypeId =:accountLenderId AND ID IN :accountSet]);

        List<Transaction_Expense__c> TransactionExpenseList = [SELECT Id, Account__c,Transaction__c,LoanAmount__c FROM Transaction_Expense__c 
                                                                WHERE RecordTypeId = :LenderExpenseRecordId AND ID NOT IN :oldId AND (Account__c IN :accountSet OR  Transaction__c IN :transactionSet  ) WITH USER_MODE];

        // Mapping Account and Transaction Id with loan amount.
        for (Transaction_Expense__c TransactionExpenseObj : TransactionExpenseList) { 
            if(TransactionExpenseObj.Account__c != null && 	TransactionExpenseObj.Transaction__c != null){
                String AccountAndTransactionId  = String.valueOf(TransactionExpenseObj.Account__c+''+TransactionExpenseObj.Transaction__c);
                Decimal Amount = TransactionExpenseObj.LoanAmount__c != null ?  TransactionExpenseObj.LoanAmount__c : 0;
                if(!accountAndTransactionLoanAmountMap.containsKey(AccountAndTransactionId)){
                    accountAndTransactionLoanAmountMap.put(AccountAndTransactionId,Amount);
                }else{
                    Decimal oldAmount = accountAndTransactionLoanAmountMap.get(AccountAndTransactionId);
                    accountAndTransactionLoanAmountMap.put(AccountAndTransactionId,(Amount+oldAmount));
                }
            } 
        }

        // Check loan amount value in valid or not?
        for (Transaction_Expense__c TransactionExpenseObj : newlist) {
            if(TransactionExpenseObj.Account__c != null && 	TransactionExpenseObj.Transaction__c != null && TransactionExpenseObj.RecordTypeId == LenderExpenseRecordId){
                String AccountAndTransactionId  = String.valueOf(TransactionExpenseObj.Account__c+''+TransactionExpenseObj.Transaction__c);
                if(accountAndTransactionLoanAmountMap.containsKey(AccountAndTransactionId)){
                    decimal ToatalAmount = accountAndTransactionLoanAmountMap.get(AccountAndTransactionId);
                    decimal loanAmount = 0;
                    if(AccountMap.containsKey(TransactionExpenseObj.Account__c)){
                        loanAmount = AccountMap.get(TransactionExpenseObj.Account__c).Loan_Amount__c !=  null ? AccountMap.get(TransactionExpenseObj.Account__c).Loan_Amount__c : 0;
                    }
                    if(ToatalAmount > loanAmount){
                        TransactionExpenseObj.addError('Transcation Expense Amount is greater then Loan Amount || Loan Amount : '+loanAmount+' || Total Amount : '+ToatalAmount);
                    }
                }else{
                    decimal ToatalAmount = TransactionExpenseObj.LoanAmount__c != null ? TransactionExpenseObj.LoanAmount__c : 0;
                    decimal loanAmount = 0;
                    if(AccountMap.containsKey(TransactionExpenseObj.Account__c)){
                        loanAmount = AccountMap.get(TransactionExpenseObj.Account__c).Loan_Amount__c !=  null ? AccountMap.get(TransactionExpenseObj.Account__c).Loan_Amount__c : 0;
                    }
                    if(ToatalAmount > loanAmount){
                        TransactionExpenseObj.addError('Transcation Expense Amount is greater then Loan Amount || Loan Amount : '+loanAmount+' || Total Amount : '+ToatalAmount);
                    }
                }
               
            }
        }

    }

}