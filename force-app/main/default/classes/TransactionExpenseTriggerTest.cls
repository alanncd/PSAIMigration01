@isTest
private class TransactionExpenseTriggerTest  {

   @isTest
    static void testLenderExpense() {
        TransactionsExpenseTriggerControl__c expenseTriggerInstance = TransactionsExpenseTriggerControl__c.getOrgDefaults();
        expenseTriggerInstance.ActivateTrigger__c = true;
        expenseTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert expenseTriggerInstance; 
        Id accountLenderId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender').getRecordTypeId();
        Id lenderExpenseRecordId = Schema.SObjectType.Transaction_Expense__c.getRecordTypeInfosByName().get('Lender Expense').getRecordTypeId();

        Transactions__c transRec = new Transactions__c(Name='Testt',Contract_Purchase_Price__c = 500 ,
                                                     Closing_Date__c = System.today()+ 7,Remote_Closing__c = 'No',Closing_Attorney__c = 'Other'
                                                     ,Disposition_Decision__c = 'Pending'); 
        insert transRec; 
        Account acc = new Account(Name = 'Test Lender',Loan_Amount__c=500,RecordTypeId=accountLenderId,BillingPostalCode = '12345', BillingCity = 'Statesville' ,BillingState = 'NC');
        insert acc;

        Transaction_Expense__c trNewone = new Transaction_Expense__c(Account__c=acc.id,recordTypeId = lenderExpenseRecordId,Transaction__c =transRec.Id,LoanAmount__c=10,PurchaseDate__c=Date.Today(), PayoffDate__c=Date.Today()+7, LoanOriginationPoints__c = 2, APR__c = 8);
        Transaction_Expense__c trNewtwo = new Transaction_Expense__c(Account__c=acc.id,recordTypeId = lenderExpenseRecordId,Transaction__c =transRec.Id,LoanAmount__c=10,PurchaseDate__c=Date.Today(), PayoffDate__c=Date.Today()+7, LoanOriginationPoints__c = 2, APR__c = 8);
        insert trNewone;
        insert trNewtwo;
        Transaction_Expense__c trNewthree = new Transaction_Expense__c(Account__c=acc.id,recordTypeId = lenderExpenseRecordId,Transaction__c =transRec.Id,LoanAmount__c=10,PurchaseDate__c=Date.Today(), PayoffDate__c=Date.Today()+7, LoanOriginationPoints__c = 2, APR__c = 8);
        Transaction_Expense__c trNewfour = new Transaction_Expense__c(Account__c=acc.id,recordTypeId = lenderExpenseRecordId,Transaction__c =transRec.Id,LoanAmount__c=10,PurchaseDate__c=Date.Today(), PayoffDate__c=Date.Today()+7, LoanOriginationPoints__c = 2, APR__c = 8);
        List<Transaction_Expense__c> lie = new List<Transaction_Expense__c>();
        lie.add(trNewthree);
        lie.add(trNewfour);
        Test.StartTest();
            insert lie;
        	System.assertNotEquals(null, lie);
        Test.StopTest();
    }

    @isTest
    static void testLenderSingle() {
        TransactionsExpenseTriggerControl__c expenseTriggerInstance = TransactionsExpenseTriggerControl__c.getOrgDefaults();
        expenseTriggerInstance.ActivateTrigger__c = true;
        expenseTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert expenseTriggerInstance;
        Id accountLenderId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender').getRecordTypeId();
        Id lenderExpenseRecordId = Schema.SObjectType.Transaction_Expense__c.getRecordTypeInfosByName().get('Lender Expense').getRecordTypeId();

        Transactions__c transRec = new Transactions__c(Name='Testt',Contract_Purchase_Price__c = 500 ,
                                                     Closing_Date__c = System.today()+ 7,Remote_Closing__c = 'No',Closing_Attorney__c = 'Other'
                                                     ,Disposition_Decision__c = 'Pending'); 
        insert transRec; 
        Account acc = new Account(Name = 'Test Lender',Loan_Amount__c=500,RecordTypeId=accountLenderId,BillingPostalCode = '12345', BillingCity = 'Statesville' ,BillingState = 'NC');
        insert acc;

        Transaction_Expense__c trNewone = new Transaction_Expense__c(Account__c=acc.id,recordTypeId = lenderExpenseRecordId,Transaction__c =transRec.Id,LoanAmount__c=10,PurchaseDate__c=Date.Today(), PayoffDate__c=Date.Today()+7, LoanOriginationPoints__c = 2, APR__c = 8);
       
        Test.StartTest();
            insert trNewone;
        	System.assertNotEquals(null, trNewone);
        Test.StopTest();
    }

    @isTest
    static void testTransactionExpense() {
        TransactionsExpenseTriggerControl__c expenseTriggerInstance = TransactionsExpenseTriggerControl__c.getOrgDefaults();
        expenseTriggerInstance.ActivateTrigger__c = true;
        expenseTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert expenseTriggerInstance;
        Id accountLenderId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Buyer').getRecordTypeId();
        Id lenderExpenseRecordId = Schema.SObjectType.Transaction_Expense__c.getRecordTypeInfosByName().get('Transaction Expense').getRecordTypeId();

        Transactions__c transRec = new Transactions__c(Name='Testt',Contract_Purchase_Price__c = 500 ,
                                                     Closing_Date__c = System.today()+ 7,Remote_Closing__c = 'No',Closing_Attorney__c = 'Other'
                                                     ,Disposition_Decision__c = 'Pending'); 
        insert transRec; 
        Account acc = new Account(Name = 'Test Lender',Loan_Amount__c=500,RecordTypeId=accountLenderId,BillingPostalCode = '12345', BillingCity = 'Statesville' ,BillingState = 'NC');
        insert acc;

        Transaction_Expense__c trNewone = new Transaction_Expense__c(Account__c=acc.id,recordTypeId = lenderExpenseRecordId,Transaction__c =transRec.Id,LoanAmount__c=10,PurchaseDate__c=Date.Today(), PayoffDate__c=Date.Today()+7, LoanOriginationPoints__c = 2, APR__c = 8);
        Transaction_Expense__c trNewtwo = new Transaction_Expense__c(Account__c=acc.id,recordTypeId = lenderExpenseRecordId,Transaction__c =transRec.Id,LoanAmount__c=10,PurchaseDate__c=Date.Today(), PayoffDate__c=Date.Today()+7, LoanOriginationPoints__c = 2, APR__c = 8);
        List<Transaction_Expense__c> exlist = new List<Transaction_Expense__c>();
        exlist.add(trNewone);
        exlist.add(trNewtwo);
        Test.StartTest();
           insert exlist;
        System.assertNotEquals(null, exlist);
        Test.StopTest();
    }

    @isTest
    static void testUpdate() {
        TransactionsExpenseTriggerControl__c expenseTriggerInstance = TransactionsExpenseTriggerControl__c.getOrgDefaults();
        expenseTriggerInstance.ActivateTrigger__c = true;
        expenseTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert expenseTriggerInstance;
        Id accountLenderId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender').getRecordTypeId();
        Id lenderExpenseRecordId = Schema.SObjectType.Transaction_Expense__c.getRecordTypeInfosByName().get('Lender Expense').getRecordTypeId();

        Transactions__c transRec = new Transactions__c(Name='Testt',Contract_Purchase_Price__c = 500 ,
                                                     Closing_Date__c = System.today()+ 7,Remote_Closing__c = 'No',Closing_Attorney__c = 'Other'
                                                     ,Disposition_Decision__c = 'Pending'); 
        insert transRec; 
        Account acc = new Account(Name = 'Test Lender',Loan_Amount__c=500,RecordTypeId=accountLenderId,BillingPostalCode = '12345', BillingCity = 'Statesville' ,BillingState = 'NC');
        insert acc;

        Transaction_Expense__c trNewone = new Transaction_Expense__c(Account__c=acc.id,recordTypeId = lenderExpenseRecordId,Transaction__c =transRec.Id,LoanAmount__c=10,PurchaseDate__c=Date.Today(), PayoffDate__c=Date.Today()+7, LoanOriginationPoints__c = 2, APR__c = 8);
        Transaction_Expense__c trNewtwo = new Transaction_Expense__c(Account__c=acc.id,recordTypeId = lenderExpenseRecordId,Transaction__c =transRec.Id,LoanAmount__c=10,PurchaseDate__c=Date.Today(), PayoffDate__c=Date.Today()+7, LoanOriginationPoints__c = 2, APR__c = 8);
        insert trNewone;
        insert trNewtwo;
        Test.StartTest();
            trNewone.LoanAmount__c = 20;
            trNewtwo.LoanAmount__c = 20;
            update trNewone;
            update trNewtwo;
        	Transaction_Expense__c te = [Select Id,LoanAmount__c FROM Transaction_Expense__c WHERE Id =:trNewone.Id Limit 1];
        	System.assertEquals(trNewone.LoanAmount__c, te.LoanAmount__c);
        Test.StopTest();
    }

    @isTest
    static void testUpdatetwo() {
        TransactionsExpenseTriggerControl__c expenseTriggerInstance = TransactionsExpenseTriggerControl__c.getOrgDefaults();
        expenseTriggerInstance.ActivateTrigger__c = true;
        expenseTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert expenseTriggerInstance;
        Id accountLenderId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender').getRecordTypeId();
        Id lenderExpenseRecordId = Schema.SObjectType.Transaction_Expense__c.getRecordTypeInfosByName().get('Lender Expense').getRecordTypeId();

        Transactions__c transRec = new Transactions__c(Name='Testt',Contract_Purchase_Price__c = 500 ,
                                                     Closing_Date__c = System.today()+ 7,Remote_Closing__c = 'No',Closing_Attorney__c = 'Other'
                                                     ,Disposition_Decision__c = 'Pending'); 
        insert transRec; 
        Account acc = new Account(Name = 'Test Lender',Loan_Amount__c=500,RecordTypeId=accountLenderId,BillingPostalCode = '12345', BillingCity = 'Statesville' ,BillingState = 'NC');
        insert acc;

        Transaction_Expense__c trNewone = new Transaction_Expense__c(Account__c=acc.id,recordTypeId = lenderExpenseRecordId,Transaction__c =transRec.Id,LoanAmount__c=10,PurchaseDate__c=Date.Today(), PayoffDate__c=Date.Today()+7, LoanOriginationPoints__c = 2, APR__c = 8);
        Transaction_Expense__c trNewtwo = new Transaction_Expense__c(Account__c=acc.id,recordTypeId = lenderExpenseRecordId,Transaction__c =transRec.Id,LoanAmount__c=10,PurchaseDate__c=Date.Today(), PayoffDate__c=Date.Today()+7, LoanOriginationPoints__c = 2, APR__c = 8);
        List<Transaction_Expense__c> exlist = new List<Transaction_Expense__c>();
        exlist.add(trNewone);
        exlist.add(trNewtwo);
        insert exlist;
        Test.StartTest();
        try{
            trNewone.LoanAmount__c = 5000;
            trNewtwo.LoanAmount__c = 5000;
            update trNewone;
            update trNewtwo;
        }catch(Exception ex){
			System.assertNotEquals(null, ex);
            System.assert(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        Test.StopTest();
    }

    
}