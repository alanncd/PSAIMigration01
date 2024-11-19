@isTest
private class Batch_FollowupTaskForTrasaction_Test {
   
    @isTest
    static void testInsertRecordWithoutOpportunity() {
        String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
        Account acc = new Account( RecordTypeID=RecTypeId, FirstName='Test FName', LastName='Test LName', PersonMailingStreet='test@yahoo.com',
          PersonMailingPostalCode='12345', PersonMailingCity='SFO', PersonEmail='test@yahoo.com', Phone='1234567', PersonMobilePhone='12345678');
        insert acc;
        
        Opportunity oppRec = new Opportunity(Name = 'Test Opp', StageName = 'Pending Appointment', AccountId = acc.Id, Last_Offer_Made__c = 12345,
                                             Address_1__c = 'Demo address',
                                             CloseDate = System.today()+ 7,Obstacles_to_Setting_Appointment__c = 'None: Appointment Set. Boom!' , NextStep = 'go on appointment');        
        insert oppRec; 
        
        oppRec.StageName = 'Contract Signed';
        update oppRec;
        System.assertNotEquals(null, oppRec);
        Test.startTest();
        	Batch_FollowupTaskForTrasaction batchTaskSchedule = new Batch_FollowupTaskForTrasaction(); 
            String sch ='0 48 * * * ?'; 
            id jobId = System.schedule('Schedule to send task from transaction', sch,batchTaskSchedule);
            System.assertNotEquals(null,jobId);
        Test.stopTest();
    }
}