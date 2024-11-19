public with sharing class TransactionExpensePayOffController {
    public String currentRecordId     {get;set;}
    public TransactionWrapper WrapObj {get; set;}
    public TransactionExpensePayOffController(ApexPages.StandardController controller) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('MYID');
        wrapObj = new TransactionWrapper();
        LeftMain_SecurityUtils.checkObjectIsReadable(Transaction_Expense__c.SObjectType);
        List<Transaction_Expense__c> TransactionList = [SELECT id,Name,Account__r.Name,Account__r.Closing_Attorney__c,
                                                        	Transaction__r.name,PayoffDate__c,PayOffamount__c,PerDiemRate__C,
                                                        Account__r.BankName__c,Account__r.BankAddress__c,Account__r.BankPhoneNumber__c,
                                                        Account__r.RoutingNumber__c,Account__r.AccountNumber__c,Account__r.Email__c 
                                                        FROM Transaction_Expense__c where id =:currentRecordId LIMIT 50000];
        if(!TransactionList.isEmpty()){
            String myGeneratedFileName = ''+TransactionList[0].Account__r.Name+'.pdf';
            Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+myGeneratedFilename); 
            wrapObj.AccountName    =             TransactionList[0].Account__r.Name != null ? TransactionList[0].Account__r.Name : '';
            wrapObj.TransactionName =            TransactionList[0].Transaction__r.name != null ? TransactionList[0].Transaction__r.name : '';
            wrapObj.ClosingAttorney =            TransactionList[0].Account__r.Closing_Attorney__c != null ? TransactionList[0].Account__r.Closing_Attorney__c : '';             
            wrapObj.TodaysDate  =                Datetime.now().format('MMMM')+' '+ Datetime.now().day()+', '+Datetime.now().year();
            if(TransactionList[0].PayoffDate__c != null){ 
                Integer d = TransactionList[0].PayoffDate__c.day();
                Integer mo = TransactionList[0].PayoffDate__c.month();
                Integer yr = TransactionList[0].PayoffDate__c.year(); 
                Datetime PayOfDate = DateTime.newInstance(yr, mo, d);
                wrapObj.PayOffDate  = PayOfDate.format('MMMM')+' '+ PayOfDate.day()+', '+PayOfDate.year();   
            }
            if(TransactionList[0].PayoffDate__c != null){
                Integer d = TransactionList[0].PayoffDate__c.day();
                Integer mo = TransactionList[0].PayoffDate__c.month();
                Integer yr = TransactionList[0].PayoffDate__c.year();
                Datetime PayOfDate = DateTime.newInstance(yr, mo, d); 
                Datetime PayOfDateThirtyPlus = PayOfDate.addDays(30);
                wrapObj.ClosingDateExtraThirtyDate  = PayOfDateThirtyPlus.format('MMMM')+' '+ PayOfDateThirtyPlus.day()+', '+PayOfDateThirtyPlus.year();   
            }
            wrapObj.PayOffAmount  =              TransactionList[0].PayOffamount__c != null ? TransactionList[0].PayOffamount__c.format() + '.00 ': '';  
            wrapObj.PerDiemInterestRate =        TransactionList[0].PerDiemRate__C != null ? TransactionList[0].PerDiemRate__C.format() + '.00 ' : '';  
            wrapObj.BankName     =               TransactionList[0].Account__r.BankName__c != null ? TransactionList[0].Account__r.BankName__c : '';   
            wrapObj.BankAddress  =               TransactionList[0].Account__r.BankAddress__c != null ? TransactionList[0].Account__r.BankAddress__c : ''; 
            wrapObj.BankPhoneNumber =            TransactionList[0].Account__r.BankPhoneNumber__c != null ? TransactionList[0].Account__r.BankPhoneNumber__c : ''; 
            wrapObj.RoutningNumber  =            TransactionList[0].Account__r.RoutingNumber__c != null ? TransactionList[0].Account__r.RoutingNumber__c : '';  
            wrapObj.AccountNumber   =            TransactionList[0].Account__r.AccountNumber__c != null ? TransactionList[0].Account__r.AccountNumber__c : '';  
            wrapObj.AccountEmail    =            TransactionList[0].Account__r.Email__c!= null ? TransactionList[0].Account__r.Email__c : '';
        }
    } 
 
    public class TransactionWrapper{
        public String AccountName                  {get;set;}
        public String TransactionName              {get;set;}
        public String ClosingAttorney              {get;set;}
        public String TodaysDate                   {get;set;}
        public String PayOffDate                   {get;set;}
        public String ClosingDateExtraThirtyDate   {get;set;}
        public String PayOffAmount                 {get;set;}
        public String PerDiemInterestRate          {get;set;}
        public String BankName                     {get;set;}
        public String BankAddress                  {get;set;}
        public String BankPhoneNumber              {get;set;}
        public String RoutningNumber               {get;set;}
        public String AccountNumber                {get;set;}
        public String AccountEmail                 {get;set;}
    }
    
}