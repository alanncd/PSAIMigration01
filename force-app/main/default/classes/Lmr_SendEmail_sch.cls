global with sharing class Lmr_SendEmail_sch Implements Schedulable{
 
    String recordIdF;
    String emailTemplateNameF;
    
    global void execute(SchedulableContext sc)
        {
            Lmr_SendEmail.sendEmailNow(recordIdF,emailTemplateNameF,'');
        }
    
    public Lmr_SendEmail_sch (String recordId,String emailTemplateName){
        if ( recordIdF == null ) {recordIdF =recordId;}
        if ( emailTemplateNameF == null ) {emailTemplateNameF =emailTemplateName;}
    }
}