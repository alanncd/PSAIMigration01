global  class LiveLoopPostIntstallSetupClass  implements InstallHandler{
    
    global void onInstall(InstallContext context) {
        if(context.previousVersion() == null) {
            
            System.schedule('LiveLoop Lead Push Batch Job', '0 0 1 * * ?', new LiveLoopLeadPushBatch());
            
            System.schedule('LiveLoop Opportunity Push Batch Job', '0 0 2 * * ?', new LiveLoopOpportunityPushBatch());
            
            
        }
    }   
}