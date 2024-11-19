global without sharing class PostInstallScheduledJob implements InstallHandler{

    
        global void onInstall(InstallContext context) {
         // List<CronTrigger> jobsToAbort = [select Id,state from CronTrigger where CronJobDetail.JobType = '7' AND State != 'DELETED' LIMIT 149];
			
     List<CronTrigger> jobsToAbort = [select Id,CronJobDetail.Name from CronTrigger where CronJobDetail.JobType = '7'
     AND (CronJobDetail.Name='Cadence SMS' OR CronJobDetail.Name LIKE '%Cadence SMS%' OR CronJobDetail.Name LIKE '%Cadence%' OR CronJobDetail.Name='Cadence Task' OR CronJobDetail.Name='Cadence Email') LIMIT 140];
	for (CronTrigger job : jobsToAbort) { System.abortJob(job.Id); }
           try{
               
System.schedule('Cadence SMS 0', '0 0 8-21 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadence());
System.schedule('Cadence SMS 10', '0 10 8-21 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadence());
System.schedule('Cadence SMS 20', '0 20 8-21 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadence());
System.schedule('Cadence SMS 30', '0 30 8-21 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadence());
System.schedule('Cadence SMS 40', '0 40 8-21 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadence());               
System.schedule('Cadence SMS 50', '0 50 8-21 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadence());
System.schedule('Cadence Task', '0 0 9-18 ? * MON,TUE,WED,THU,FRI,SAT *', new batchCadenceTask());
System.schedule('Cadence Email', '0 30 8-21 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadenceEmail());
           }catch(Exception e){
                System.debug('its scheduled');
           }
        }
    


}