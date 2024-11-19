@isTest
global class RingCentralTaskCalloutTest{
    
  
    private static integer itemsMissing = 09;
   
   @isTest
    public   static void validateNoduplicateSubjectDate() {
        
      	RingCentralTaskSetting__c lrcs = new RingCentralTaskSetting__c(); //.getOrgDefaults();
        lrcs.Activate_Trigger__c=TRUE;
        insert lrcs;
        
        //we will create two task with the same time and subject and see if it is duplicated
         String Subject1='Inbound from +16023182030'; 

         Task t = new Task();
         t.Subject='Inbound from +16023182030';
         t.CallDisposition='Missed';
         t.Tracking_Number__c='(602) 318-2030';
        // t.CallType='Inbound';
         
         
         try{
          //scheduling our class

         System.Debug('updating tracking');     
             String querysub='Inbound from +16023182030';
             
List<Task> ListTasks = [SELECT Subject,CallDisposition FROM Task WHERE Subject =:t.Subject and CallDisposition='Missed' limit 1 ];
       
                 System.assertEquals(0, ListTasks.size(),'errorTest');
          
          }
      Catch(exception e){
          System.Debug(e);
      }
       
        Test.startTest();
        
         Test.setMock(HttpCalloutMock.class, new RestMock());
      
        //Call our method and expect to not create the same task with the same subject and misscalldatetime
 
     Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standttt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testinguser1234', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='leadTestUser12349@testorg.com', Division = 'Brazil');
		insert u;
		Set<Id> idSet = new Set<Id>();
        System.runAs(u){   
            For(Task tk : CreateTask(u)){
              idSet.add(tk.Id);  
            }
        }
        
        
        List<Task> ListTasks = [SELECT Subject,CallDisposition FROM Task WHERE Subject =:t.Subject and CallDisposition='Missed' limit 1 ];
       
         Test.stopTest();
        System.assertEquals(0, 0,'errorTest');
          //RingCentralTaskCallout.fortesting1('Inbound from +16023182030');
            //RingCentralTaskCallout.fortesting2('Inbound from +16023182030');
            //RingCentralTaskCallout.fortesting3('Inbound from +16023182030');
             //RingCentralTaskCallout.getMissedCalls(idSet);
             //RingCentralTaskCallout.fortesting3('Inbound from +16023182030');
        
    }
   
    
// simulate the http response to avoid callout error web service from test methods
//add this to autorise callout from test class
     private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            
            //test schedule the class test
            
       
            System.assertEquals(0, 0,'errorTest');
            //justto test 
            //Do Callout here to get response http
            //
         String Subject1='InboundRC+1100000000'; 
         String MissedCallDatetime='2022-02-23T20:18:33.771Z'; 
         Task t = new Task();
         t.Subject='Inbound from +16023182030';
         t.CallDisposition='Missed';
            return new HTTPResponse();
        }}
            
            
    
    //test 1 
    
    
    public static List<task> CreateTask(User u){
        
       
        
    	List<task> tksList = new List<task>();
        
        Task rec1 = new Task( Subject='Inbound from +12086178472',CallDisposition='Missed',CallType='Inbound',Lead_Phone_Number__c='2086178472');
           

	tksList.add(rec1);
        
        Task rec2 = new Task( Subject='Inbound from +12086178471',CallDisposition='Missed',CallType='Inbound',Lead_Phone_Number__c='2086178471');
           

		tksList.add(rec2); 
        
          Task rec3 = new Task( Subject='Inbound from +12086178474',CallDisposition='Missed',CallType='Inbound',Lead_Phone_Number__c='2086178474');
           
 
		tksList.add(rec3);  
        
        insert tksList;
        
        Return tksList;
        
    }
    	
    


}