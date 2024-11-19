public class TwnsqrUpdateForLeadCntrl {
    
    private ApexPages.StandardController controller {get; set;}
    public Lead leadRecord{get;set;}
    
    public TwnsqrUpdateForLeadCntrl(ApexPages.StandardController controller){
        this.controller = controller;
        this.leadRecord = (Lead)controller.getRecord();
    }       
}