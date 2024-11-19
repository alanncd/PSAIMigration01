@isTest
private class TransactionExpensePayOffControllerTest  {

   @isTest
    static void testLenderExpense() {
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
        insert trNewthree;
        Test.StartTest();
            PageReference pageRef = Page.TransactionExpensePayOffVF;
            Test.setCurrentPage(pageRef); 
            pageRef.getParameters().put('MYID', String.valueOf(trNewthree.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(trNewthree);
            TransactionExpensePayOffController testAccPlan = new TransactionExpensePayOffController(sc);
        	System.assertNotEquals(null, testAccPlan,'');
        	System.assertEquals(testAccPlan.currentRecordId, trNewthree.Id,'');
        Test.StopTest();  
    }
}