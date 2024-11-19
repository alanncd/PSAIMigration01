global class Lmr_TaskAutomation_sch Implements Schedulable{

    String recordIdF;
    String idTemplateF;
    
    global void execute(SchedulableContext sc)
        {
            Lmr_TaskAutomation.createTaskNow(recordIdF,idTemplateF);
        }
    
    public Lmr_TaskAutomation_sch (String recordId,String idTemplate){
        if ( recordIdF == null ) {
            recordIdF =recordId;
        }
        if ( idTemplateF == null ) {
            idTemplateF =idTemplate;
        }
    } 
}