global with sharing class Lmr_SmrtPhoneScheduled_sch Implements Schedulable{
    public String scheduledRecordId;
    public String scheduledSmsTemplate;
    
    global void execute(SchedulableContext sc)
        {
           System.debug('delete this class');
        }
    global Lmr_SmrtPhoneScheduled_sch (String recordId,String idTemplate){
        if ( scheduledRecordId == null ) {
            scheduledRecordId =recordId;
        }
        if ( scheduledSmsTemplate == null ) {
            scheduledSmsTemplate =idTemplate;
        }
    }    
}