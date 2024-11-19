global without sharing class PostInstallScriptCadences3 implements InstallHandler {

    global void onInstall (InstallContext context)
    {
        List<LMR_TemplateSms__c> listSmsCadencesAll= [SELECT Id FROM LMR_TemplateSms__c WHERE NAME LIKE '%Opp - Pending Appt%' LIMIT 200 ];
		LeftMain_SecurityUtils.checkRead(LMR_TemplateSms__c.SObjectType,new List<String> {
            				'Id',
            				'Name',
            				'Body__c',
            				'Object__c',
                            'Status__c',
                            'TypeOfSchedule__c',
                            'Folder__c'
        				});   
        if(listSmsCadencesAll.isEmpty()){
            List<LMR_TemplateSms__c> l1 = new List<LMR_TemplateSms__c>();
            l1.add(new LMR_TemplateSms__c(Name = 'Opp - Pending Appt 1', Body__c = 'Hi {!Opportunity.account.firstname}, thank you so much for our conversation earlier. As we chatted about, the best way for us to make the highest offer is to have a quick chat and either in-person walk-thru or Facetime/Zoom walk-thru of your home with our',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Pending Appt 1'));
            l1.add(new LMR_TemplateSms__c(Name = 'Opp - Pending Appt 2', Body__c = 'Hi {!Opportunity.account.firstname}! It\'s {!Opportunity.owner.firstname} - this year is crazy isn\'t it? In any case, I would love to see the house and make our cash offer or we can Facetime/Zoom and we can make our offer over the phone. (',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Pending Appt 2'));
            l1.add(new LMR_TemplateSms__c(Name = 'Opp - Pending Appt 3', Body__c = 'Hi {!Opportunity.account.firstname}, Better Path Homes here! Schedules are crazy lately aren\'t they?! I really want to see your property at {!Opportunity.Address__c} so I can get you a cash offer.; I have time to FaceTime this week - or we can make an i',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Pending Appt 3'));
            l1.add(new LMR_TemplateSms__c(Name = 'Opp - Pending Appt 4', Body__c = 'Missed Chances make me CRY!!! Hey {!Opportunity.account.firstname},  I can’t believe we haven’t gotten to see your property yet!!! Please let me know when we can come by and make you an offer!',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Pending Appt 4'));
            l1.add(new LMR_TemplateSms__c(Name = 'New Lead - Uncontacted 1', Body__c = 'Hi {!Lead.FirstName} - {!Lead.owner.firstname} here with {!$Organization.name}. I\'ve just received the information you submitted for an offer on {!Lead.Street}. This is our direct line for calling or texting if that\'s more convenient for you.',Object__c='Lead',Status__c='Active',TypeOfSchedule__c='Now',Folder__c='New Lead - Drip'));
            l1.add(new LMR_TemplateSms__c(Name = 'New Lead - Uncontacted 2', Body__c = 'Hi again {!Lead.FirstName} - {!Lead.owner.firstname} here with {!$Organization.name}. We received your inquiry to put together an offer on {!Lead.Street} but we haven\'t been able to get a hold of you! Texting you in case that is more convenient. When is a',Object__c='Lead',Status__c='Active',TypeOfSchedule__c='Minutes',Schedule__c=1,Folder__c='New Lead - Drip'));
            l1.add(new LMR_TemplateSms__c(Name = 'New Lead - Uncontacted 3', Body__c = 'Hey {!Lead.FirstName} - {!Lead.owner.firstname} here again with {!$Organization.name}. Are you still interested in selling your property? Not sure when a good time to chat is but I\'m happy to make myself available to you -- even if it is before or after noon',Object__c='Lead',Status__c='Active',TypeOfSchedule__c='',Folder__c='New Lead - Drip'));
            l1.add(new LMR_TemplateSms__c(Name = 'New Lead - Uncontacted 4', Body__c = 'Hey {!Lead.FirstName} - {!Lead.owner.firstname} here again with {!$Organization.name}. Have you sold your house at {!Lead.Street}? If not, my team is still interested! Let me know',Object__c='Lead',Status__c='Active',Folder__c='New Lead - Drip'));
            l1.add(new LMR_TemplateSms__c(Name = 'New Lead - Uncontacted 5', Body__c = 'Hey {!Lead.FirstName} - {!Lead.owner.firstname} here again with {!$Organization.name}. Just wondering if you have given up selling your house.',Object__c='Lead',Status__c='Active',Folder__c='New Lead - Drip'));

            LeftMain_SecurityUtils.checkInsert(LMR_TemplateSms__c.SObjectType,new List<String> {
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
            SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, l1);
            l1 = decision3.getRecords();
            Database.insert(l1);
        }
    }
}