global without sharing class PostInstallScriptCadences8 {
  global void onInstall (InstallContext context)
    {

      // Check permissions for reading fields
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
      List<LMR_TemplateSms__c> listSmsCadencesAll= [SELECT Id FROM LMR_TemplateSms__c WHERE NAME LIKE '%New Lead - Style%' WITH USER_MODE LIMIT 200 ];		        
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
       
      if(listSmsCadencesAll.isEmpty()){
          List<LMR_TemplateSms__c> l1 = new List<LMR_TemplateSms__c>();
              l1.add(new LMR_TemplateSms__c(Name = 'New Lead - Style2 - Drip1', Body__c = 'Hi {!Lead.FirstName} - {!Lead.owner.firstname} here @  {!$Organization.name}. I received your msg. I\'ll follow-up with you shortly to learn more about your property. Reply w/ a specific date/time if you like.',Object__c='Lead',Status__c='Active',TypeOfSchedule__c='Now',Folder__c='New Lead - Style - Drip'));
              l1.add(new LMR_TemplateSms__c(Name = 'New Lead - Style2 - Drip2', Body__c = 'Hi {!Lead.FirstName} - {!Lead.owner.firstname} here @ {!$Organization.name}. Still looking to receive an offer on your property? Call me to discuss - {!Lead.owner.phone}',Object__c='Lead',Status__c='Active',TypeOfSchedule__c='Minutes',Schedule__c=1,Folder__c='New Lead - Style - Drip'));
              l1.add(new LMR_TemplateSms__c(Name = 'New Lead - Style2 - Drip3', Body__c = 'Hi {!Lead.FirstName} - {!Lead.owner.firstname} here @ {!$Organization.name} again. I&#39;ve been trying to reach you to find out more about your property. Give me a call @ {!Lead.owner.phone}.',Object__c='Lead',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=1,Folder__c='New Lead - Style - Drip'));
              l1.add(new LMR_TemplateSms__c(Name = 'New Lead - Style2 - Drip4', Body__c = 'Hi {!Lead.FirstName} - {!Lead.owner.firstname} here with {!$Organization.name}. I&#39;m looking to buy one more property in your area, so please call me back ({!Lead.owner.phone}) if you\'re still looking to sell.',Object__c='Lead',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=2,Folder__c='New Lead - Style - Drip'));
              l1.add(new LMR_TemplateSms__c(Name = 'New Lead - Style2 - Drip5', Body__c = 'Hi {!Lead.FirstName} - {!Lead.owner.firstname} here with {!$Organization.name}. Are you still looking for a cash offer on your property? If so, please give me a call @{!Lead.owner.phone}',Object__c='Lead',Status__c='Active',TypeOfSchedule__c='',Folder__c='New Lead - Style - Drip'));
              l1.add(new LMR_TemplateSms__c(Name = 'New Lead - Style2 - Drip6', Body__c = 'Hi {!Lead.FirstName} - {!Lead.owner.firstname} here with {!$Organization.name}. I\'d love to buy your house as-is, for cash. Are you still selling?',Object__c='Lead',Status__c='Active',TypeOfSchedule__c='',Folder__c=''));
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