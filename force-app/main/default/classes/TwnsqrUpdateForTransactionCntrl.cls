public class TwnsqrUpdateForTransactionCntrl {
    
    private ApexPages.StandardController controller {get; set;}
    public Transactions__c transactionRecord{get;set;}
    
    public TwnsqrUpdateForTransactionCntrl(ApexPages.StandardController controller){
        this.controller = controller;
       this.transactionRecord = (Transactions__c)controller.getRecord();
    }       
}