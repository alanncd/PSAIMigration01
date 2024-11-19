public class RingCentralDataStoreHandler {

    public static void onAfterInsertTask(map<id,task> newTaskMap){
        set<id> tksId = new set<id>();
     
        
              
        for(task taskRec : [SELECT Id, Subject, CallType, CallDisposition, Lead_Phone_Number__c, Tracking_Number__c, Activity_Create_Date_Time__c FROM Task where id in: newTaskMap.keySet() ]){
            if(taskRec.Tracking_Number__c == null && taskRec.subject != null && taskRec.CallDisposition == 'Missed' && taskRec.CallType =='Inbound'){
                tksId.add(taskRec.Id);
                
            }
        }
         //RingCentralTaskCallout.getMissedCalls(tksId);
    }

}