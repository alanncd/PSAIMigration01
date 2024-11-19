global without sharing class PostInstallScriptCadences7 {
  global void onInstall (InstallContext context)
    {
      if (!Schema.sObjectType.LMR_TemplateSms__c.isAccessible() ||
      !Schema.sObjectType.LMR_TemplateSms__c.fields.Name.isAccessible() ||
      !Schema.sObjectType.LMR_TemplateSms__c.fields.Body__c.isAccessible() ||
      !Schema.sObjectType.LMR_TemplateSms__c.fields.Object__c.isAccessible() ||
      !Schema.sObjectType.LMR_TemplateSms__c.fields.Status__c.isAccessible() ||
      !Schema.sObjectType.LMR_TemplateSms__c.fields.TypeOfSchedule__c.isAccessible() ||
      !Schema.sObjectType.LMR_TemplateSms__c.fields.Folder__c.isAccessible()) {
      
      throw new AuraHandledException('You do not have permission to access the necessary fields on LMR_TemplateSms__c.');
   }
    // Check permissions for updating fields
    if (!Schema.sObjectType.LMR_TemplateSms__c.isUpdateable() ||
        !Schema.sObjectType.LMR_TemplateSms__c.fields.Name.isUpdateable() ||
        !Schema.sObjectType.LMR_TemplateSms__c.fields.Body__c.isUpdateable() ||
        !Schema.sObjectType.LMR_TemplateSms__c.fields.Object__c.isUpdateable() ||
        !Schema.sObjectType.LMR_TemplateSms__c.fields.Status__c.isUpdateable() ||
        !Schema.sObjectType.LMR_TemplateSms__c.fields.TypeOfSchedule__c.isUpdateable() ||
        !Schema.sObjectType.LMR_TemplateSms__c.fields.Folder__c.isUpdateable()) {
        
        throw new AuraHandledException('You do not have permission to update the necessary fields on LMR_TemplateSms__c.');
    }
      List<LMR_TemplateSms__c> listSmsCadencesAll= [SELECT Id FROM LMR_TemplateSms__c WHERE NAME LIKE '%Opp - Post-Offer%' LIMIT 200 ];
		LeftMain_SecurityUtils.checkRead(LMR_TemplateSms__c.SObjectType,new List<String> {
            				'Id',
            				'Name',
            				'Body__c',
            				'Object__c',
                    'Status__c',
                    'TypeOfSchedule__c',
                    'Folder__c'
        				});       
                
	LeftMain_SecurityUtils.checkUpdate(LMR_TemplateSms__c.SObjectType,new List<String> {
            				'Name',
            				'Body__c',
            				'Object__c',
                    'Status__c',
                    'TypeOfSchedule__c',
                    'Folder__c'
        				});                       
                
                // Check permissions for reading fields
       

   
      if(listSmsCadencesAll.isEmpty()){
          List<LMR_TemplateSms__c> l1 = new List<LMR_TemplateSms__c>();
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Post-Offer - Drip1', Body__c = 'Hi {!Opportunity.account.firstname} - {!Opportunity.owner.firstname} here @ {!$Organization.name}. Let me know if I can help answer any questions you have about our offer for your property.',Object__c='Opportunity',Status__c='Active',Folder__c='Opp - Post-Offer - Drip'));
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Post-Offer - Drip2', Body__c = 'Hey there {!Opportunity.account.firstname} - {!Opportunity.owner.firstname} here @ {!$Organization.name}. I\'ve not heard back from you about our offer to purchase your home. Are you still looking to sell?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Post-Offer - Drip'));
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Post-Offer - Drip3', Body__c = 'Hello again {!Opportunity.account.firstname} - {!Opportunity.owner.firstname} here @ {!$Organization.name}. What are your thoughts on the offer? Are you ready to move forward?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Post-Offer - Drip'));
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Post-Offer - Drip4', Body__c = 'Hi {!Opportunity.account.firstname} - {!Opportunity.owner.firstname} here @ {!$Organization.name}. I have your number sitting on my desk. Do you have a property for sale? If so, please call me @ {!Lead.owner.phone}',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Post-Offer - Drip'));
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Post-Offer - Drip5', Body__c = 'Hi {!Opportunity.account.firstname} - {!Opportunity.owner.firstname} here @ {!$Organization.name}. Are you still looking to sell your property? We\'re looking to purchase a few in the next week or so.',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Post-Offer - Drip'));
          LeftMain_SecurityUtils.checkInsert(LMR_TemplateSms__c.SObjectType,new List<String> {
            'Name',
            'Body__c',
            'Object__c',
            'Status__c',
            'TypeOfSchedule__c',
            'Folder__c'
        });
        // Check insert permissions before attempting to insert
        if (!Schema.sObjectType.LMR_TemplateSms__c.isCreateable() ||
        !Schema.sObjectType.LMR_TemplateSms__c.fields.Name.isCreateable() ||
        !Schema.sObjectType.LMR_TemplateSms__c.fields.Body__c.isCreateable() ||
        !Schema.sObjectType.LMR_TemplateSms__c.fields.Object__c.isCreateable() ||
        !Schema.sObjectType.LMR_TemplateSms__c.fields.Status__c.isCreateable() ||
        !Schema.sObjectType.LMR_TemplateSms__c.fields.TypeOfSchedule__c.isCreateable() ||
        !Schema.sObjectType.LMR_TemplateSms__c.fields.Folder__c.isCreateable()) {

        throw new AuraHandledException('You do not have permission to create the necessary fields on LMR_TemplateSms__c.');
     }

        SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, l1);
        l1 = decision3.getRecords();
        Database.insert(l1);
      }
    }
}