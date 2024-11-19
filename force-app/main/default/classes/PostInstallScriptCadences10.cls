global without sharing class PostInstallScriptCadences10 {
    global void onInstall (InstallContext context){

ContentAsset im1 = [SELECT Id, DeveloperName, MasterLabel, NamespacePrefix, ContentDocumentId, IsVisibleByExternalUsers FROM ContentAsset where DeveloperName='LM_Add_Cadence' WITH USER_MODE limit 1];
ContentAsset im2 = [SELECT Id, DeveloperName, MasterLabel, NamespacePrefix, ContentDocumentId, IsVisibleByExternalUsers FROM ContentAsset where DeveloperName='LM_Call_a_Lead' WITH USER_MODE limit 1];
ContentAsset im3 = [SELECT Id, DeveloperName, MasterLabel, NamespacePrefix, ContentDocumentId, IsVisibleByExternalUsers FROM ContentAsset where DeveloperName='LM_Document_Appointment' WITH USER_MODE limit 1];
ContentAsset im4 = [SELECT Id, DeveloperName, MasterLabel, NamespacePrefix, ContentDocumentId, IsVisibleByExternalUsers FROM ContentAsset where DeveloperName='LM_Send_Direct_Mail' WITH USER_MODE limit 1];
ContentAsset im5 = [SELECT Id, DeveloperName, MasterLabel, NamespacePrefix, ContentDocumentId, IsVisibleByExternalUsers FROM ContentAsset where DeveloperName='LM_Text_a_lead' WITH USER_MODE limit 1];

List<Recommendation> listRecommendation = new List<Recommendation>();
        
/* This Code is just for Jul 2023 release - after this we will remove this below 4 lines of code*/
        List<Recommendation> listRecommendationDelete = [Select Id from Recommendation WITH USER_MODE Limit 10000];
        
        if (!listRecommendationDelete.isEmpty() &&  listRecommendationDelete.getSObjectType().getDescribe().isDeletable() ) {
            Database.delete(listRecommendationDelete, AccessLevel.User_mode);
        }
/*End of code */


listRecommendation.add(new Recommendation(Name = 'Text a lead',Description='Reach out to the lead via text',Category__c='SMS',Object__c='Lead',Order__c=2,AcceptanceLabel='Let\'s do it',RejectionLabel='No thanks',ActionReference='NBA_Text_Lead',ImageId = im5.Id, ExternalId__c='NBA_Textlead'	 )); 
listRecommendation.add(new Recommendation(Name = 'Call a lead',Description='Reach out to the lead via call',Category__c='Call',Object__c='Lead',Order__c=1,AcceptanceLabel='Let\'s do it',RejectionLabel='No thanks!',ActionReference='NBA_Call_Posting',ImageId = im2.Id, ExternalId__c='NBA_Calllead'));
listRecommendation.add(new Recommendation(Name = 'Add Cadence',Description='Do you want to add a Cadence to this Lead/Prospect?',Category__c='Cadence',Object__c='Lead',AcceptanceLabel='Let\'s do it',RejectionLabel='No thanks!',ActionReference='NBA_Cadence_Screen_Flow',ImageId = im1.Id, ExternalId__c='NBA_AddCadencelead'));
listRecommendation.add(new Recommendation(Name = 'Set Appointment',Description='Set an Appointment for the Opportunity',Category__c='Set Appointment',Object__c='Opportunity',AcceptanceLabel='Let\'s do it',RejectionLabel='No thanks!',ActionReference='NBA_Set_Appointment_Flow',ImageId = im3.Id, ExternalId__c='NBA_SetAppointment')); 
listRecommendation.add(new Recommendation(Name = 'Prepare for Appointment',Description='Prepare for the Appointment',Category__c='Prepare Appointment',Object__c='Opportunity',AcceptanceLabel='Yes  - Let\'s do it',RejectionLabel='No thanks',ActionReference='NBA_Prepare_Appointment_Flow',ImageId = im3.Id, ExternalId__c='NBA_PrepareAppointment')); 
listRecommendation.add(new Recommendation(Name = 'Document Appointment',Description='Document the Appointment',Category__c='Document',Object__c='Opportunity',AcceptanceLabel='Let\'s do it!',RejectionLabel='No thanks!',ActionReference='NBA_Document_Appointment_Flow',ImageId = im3.Id, ExternalId__c='NBA_DocumentAppointment')); 
listRecommendation.add(new Recommendation(Name = 'Post Appointment',Description='Customer Survey',Category__c='Post Appointment',Object__c='Opportunity',AcceptanceLabel='Yes  - Let\'s do it',RejectionLabel='No thanks',ActionReference='NBA_Post_Appointment_QA_QI',ImageId = im2.Id, ExternalId__c='NBA_PostAppointment')); 
listRecommendation.add(new Recommendation(Name = 'Appointment attended?',Description='Appointment attended?',Category__c='Appointment attended',Object__c='Opportunity',AcceptanceLabel='Yes',RejectionLabel='No',ActionReference='NBA_Appointment_Attended',ImageId = im3.Id, ExternalId__c='NBA_AppointmentAttended'));
listRecommendation.add(new Recommendation(Name = 'Add Opportunity Cadence',Description='Do you want to add a Cadence to this Opportunity?',Category__c='Cadence',Object__c='Opportunity',AcceptanceLabel='Let\'s do it!',RejectionLabel='No thanks!',ActionReference='NBA_Opportunity_Cadence_Screen_Flow',ImageId = im1.Id, ExternalId__c='NBA_AddCadenceOpportunity'));
listRecommendation.add(new Recommendation(Name = 'Deal Analysis',Description='Deal Analysis',Category__c='Deal Analysis',Object__c='Opportunity',AcceptanceLabel='Let\'s do it!',RejectionLabel='No thanks',ActionReference='NBA_Deal_Analysis_Flow',ImageId = im3.Id, ExternalId__c='NBA_DealAnalysis'));

        try{
            SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, listRecommendation);
            Database.upsert (listRecommendation = decision3.getRecords(),Recommendation.ExternalId__c);
         }Catch(Exception e){ ErrorHandler_cls.handleException(e,'Package org installation Script');
        }        
        
        
       //execute batch for update lead and opportunity with cadences
       //
        try{
            LmrBatchUpdateCadenceStatus bch = new LmrBatchUpdateCadenceStatus('Select id , (select id from Cadences__r where Lead__c != Null and StopCadences__c = false order by createdDate desc Limit 1),CreatedDate from Lead order by CreatedDate Desc','Lead');
        	ID batchprocessid = Database.executeBatch(bch,200);}
        Catch(Exception e){
            ErrorHandler_cls.handleException(e,'Package org installation job 1');
        	}

        
        try{
        LmrBatchUpdateCadenceStatus bch2 = new LmrBatchUpdateCadenceStatus('Select id , (select id from Cadences__r where Opportunity__c != Null and StopCadences__c = false order by createdDate desc Limit 1),CreatedDate from Opportunity order by CreatedDate Desc','Opportunity');
        ID batchprocessid2 = Database.executeBatch(bch2,200);
    	}Catch(Exception e){
            ErrorHandler_cls.handleException(e,'Package org installation job 2');
        	}
    }

}