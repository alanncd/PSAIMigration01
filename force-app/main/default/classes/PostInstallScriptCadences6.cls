global without sharing class PostInstallScriptCadences6 implements InstallHandler{
	global void onInstall (InstallContext context)
	  {
  List<LMR_TemplateSms__c> listSmsCadencesAll= [SELECT Id FROM LMR_TemplateSms__c WHERE NAME LIKE '%Logical Oppty%' LIMIT 200 ];
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
  l1.add(new LMR_TemplateSms__c(Name = 'Logical Oppty 1',Body__c = 'Hi {!Opportunity.account.firstname} - {!$User.firstname} here with {!$Organization.name}. Just wanted to follow up with you about selling your house at {!Opportunity.left_main__address_1__c}. Are you still interested in our offer?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=7,Folder__c='Logical Larry'));
  l1.add(new LMR_TemplateSms__c(Name = 'Logical Oppty 2', Body__c = 'Hi {!Opportunity.account.firstname}, {!$Organization.name}. here! Checking in on you and the house. I want to make sure I am not dropping the ball on you! How are things going? Can we chat a little more about the house and your plans for selling?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=10,Folder__c='Logical Larry'));
  l1.add(new LMR_TemplateSms__c(Name = 'Logical Oppty 3', Body__c = 'Hi {!Opportunity.account.firstname}! It&#39;s{!$Organization.name} - this year is crazy isn&#39;t it? In any case, I just wanted to check in with you. Where are your thoughts right now about selling?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=10,Folder__c='Logical Larry'));
  l1.add(new LMR_TemplateSms__c(Name = 'Logical Oppty 4', Body__c = 'Good morning! Hope you are off to an amazing day today. I would like to re-evaluate our offer for your property at {!Opportunity.left_main__address_1__c}. Things have changed with this market being so hot and I want to make sure we stay as competitive as possible. Are you available for a quick call?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=30,Folder__c='Logical Larry'));
  l1.add(new LMR_TemplateSms__c(Name = 'Logical Oppty 5', Body__c = 'Hi {!Opportunity.account.firstname}! I&#39;d love to move things along with !Opportunity.left_main__address_1__c}... Let me know what questions you still have or if there is anything I can do!',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=31,Folder__c='Logical Larry'));
  l1.add(new LMR_TemplateSms__c(Name = 'Logical Oppty 6', Body__c = 'Maybe you have given up selling your home... &#128546;',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=27,Folder__c='Logical Larry'));
  l1.add(new LMR_TemplateSms__c(Name = 'Logical Oppty 7', Body__c = 'Did you still have any interest in selling your property? Let me know either way so I can stop bugging you.',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=60,Folder__c='Logical Larry'));
  l1.add(new LMR_TemplateSms__c(Name = 'Logical Oppty 8', Body__c = 'Hello again! I was just going through my files and I see here that we never got to a purchase agreement with your house.Maybe you\'re somewhere sipping cocktails on an island without a worry in the world Or maybe you\'ve been swamped with work….'+'\n'+'But what I worry about the most is that maybe I unknowingly did something that upset you or caused you to lose confidence in me and the help my company provides.'+'\n'+'My fear is that I have unknowingly done something to upset you...When I came across our messages the other day, I thought that I should probably close your file, but I didn&#39;t want to do so without your permission. I would really appreciate a call or message back so that I know where we stand and what I need to do to get our discussions back on track.',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=60,Folder__c='Logical Larry'));
  l1.add(new LMR_TemplateSms__c(Name = 'Opp - Pending Appt 1', Body__c = 'Hi {!Opportunity.account.firstname}, thank you so much for our conversation earlier. As we chatted about, the best way for us to make the highest offer is to have a quick chat and either in-person walk-thru or Facetime/Zoom walk-thru of your home with our',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Pending Appt 1'));
  l1.add(new LMR_TemplateSms__c(Name = 'Opp - Pending Appt 2', Body__c = 'Hi {!Opportunity.account.firstname}! It&#39;s {!Opportunity.owner.firstname} with Better Path - this year is crazy isn&#39;t it? In any case, I would love to see the house and make our cash offer or we can Facetime/Zoom and we can make our offer over the phone. (',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Pending Appt 2'));
  l1.add(new LMR_TemplateSms__c(Name = 'Opp - Pending Appt 3', Body__c = 'Hi {!Opportunity.account.firstname}, Better Path Homes here! Schedules are crazy lately aren&#39;t they?! I really want to see your property at {!Opportunity.Address__c} so I can get you a cash offer. &#128522; I have time to FaceTime this week - or we can make an i',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Pending Appt 3'));
  l1.add(new LMR_TemplateSms__c(Name = 'Opp - Pending Appt 4', Body__c = 'Missed Chances make me CRY!!! Hey {!Opportunity.account.firstname},  I can’t believe we haven’t gotten to see your property yet!!! Please let me know when we can come by and make you an offer!',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Pending Appt 4'));
  LeftMain_SecurityUtils.checkInsert(LMR_TemplateSms__c.SObjectType,new List<String> {
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