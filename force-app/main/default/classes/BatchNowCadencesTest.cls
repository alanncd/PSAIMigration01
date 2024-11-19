@IsTest
public class BatchNowCadencesTest {
    @IsTest
    static void testEmailBatch() {
        Set<Id> mailIds = new Set<Id>();
         List<Id> insertedCadenceIds = new List<Id>();
          Lead leadRec = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open',
                    Street = '2100 Woodward Ave',
                    City = 'Detroit',
                    State = 'MI',
                    PostalCode = '48201',
                    Country = 'US'); 
        insert leadRec; 
        
        ScheduleCadenceEmail__c scheduledCadenceEmail = new ScheduleCadenceEmail__c();
        scheduledCadenceEmail.Name = 'test';
        scheduledCadenceEmail.IdTemplate__c = 'listEmail[0].Id';
        scheduledCadenceEmail.Related_Record_id__c = leadRec.id;
        scheduledCadenceEmail.Status__c='Pending'; 
       	insert scheduledCadenceEmail;
        insertedCadenceIds.add(scheduledCadenceEmail.Id);
       
        Test.startTest();
          ExecuteBatchNowCadenceEmails.executeBatch(insertedCadenceIds);
        Test.stopTest();
        
          // Realiza afirmaciones para verificar que los campos de oportunidad se hayan actualizado correctamente
        for (ScheduleCadenceEmail__c email : [SELECT Id,Status__c  FROM ScheduleCadenceEmail__c WHERE Id IN :mailIds]) {
            System.assertEquals('Completed', email.Status__c);
            
        }
            
        
    }
    
    @IsTest
    static void testTaskBatch() {
        Set<Id> taskIds = new Set<Id>();
        List<Id> insertedCadenceIds = new List<Id>();
          Lead leadRec = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open',
                    Street = '2100 Woodward Ave',
                    City = 'Detroit',
                    State = 'MI',
                    PostalCode = '48201',
                    Country = 'US');
        insert leadRec;
        
       
        
        ScheduleCadenceTask__c scheduledCadenceTask = new ScheduleCadenceTask__c();
        scheduledCadenceTask.Name = 'test';
        scheduledCadenceTask.IdTemplate__c = 'listEmail[0].Id';
        scheduledCadenceTask.Related_Record_id__c = leadRec.id;
        scheduledCadenceTask.Status__c='Pending';
       	insert scheduledCadenceTask;
        taskIds.add(scheduledCadenceTask.Id);
        insertedCadenceIds.add(scheduledCadenceTask.Id);
         
        
        Test.startTest();
           //BatchCalloutCadenceTasks  batch = new BatchCalloutCadenceTasks (taskIds);
          //Database.executeBatch(batch);
          ExecuteBatchNowCadenceTasks.executeBatch(insertedCadenceIds);
        Test.stopTest();
        
          // Realiza afirmaciones para verificar que los campos de oportunidad se hayan actualizado correctamente
        for (ScheduleCadenceTask__c task : [SELECT Id,Status__c  FROM ScheduleCadenceTask__c WHERE Id IN :taskIds]) {
            System.assertEquals('Completed', task.Status__c);
            
        }
            
        
    }
    
    
    
    
    
}