public class TwnsqrUpdateForOpportunityCntrl {
    
 private ApexPages.StandardController controller {get; set;}
    public Opportunity opportunityRecord{get;set;}
    
    public TwnsqrUpdateForOpportunityCntrl(ApexPages.StandardController controller){
        this.controller = controller;
        this.opportunityRecord = (Opportunity)controller.getRecord();
    }       
}