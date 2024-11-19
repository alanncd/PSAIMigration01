global without sharing class PostInstallScriptCadences2 implements InstallHandler{

    global void onInstall (InstallContext context)
    {
        List<LMR_TemplateSms__c> listSmsCadencesAll= [SELECT Id FROM LMR_TemplateSms__c WHERE NAME LIKE '%Drama Oppty%' LIMIT 200 ];
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

l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 1', Body__c = 'Hello again! Just wanted to reach out and make sure that you got all of your questions answered yesterday! How are you feeling about everything today?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=1,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 2', Body__c = '✨{!Opportunity.account.firstname} , Let\'s make this happen. Close this month?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=3,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 3', Body__c = 'Just checking if you still wanted to discuss the property you were interested in selling. We\'ve got room to purchase a few more this month!'+'/n'+'Check out this video about how selling to us works',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=3,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 4', Body__c = 'I know you are in the middle of a thousand things, {!Opportunity.account.firstname}. Can I help you take the house stuff off your plate? You are going to feel so much better when its all wrapped up. Whats the next step?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=4,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 5', Body__c = 'If you are worrying about repairs on the house or getting it all dolled up for market, let me just stop you right there! Hit the easy button with me ⏱️ You ready?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=7,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 6', Body__c = 'Good morning {!Opportunity.account.firstname}, Thinking about you today. How are you?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=3,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 7', Body__c = 'Hi there!2; Checking on you again. I’m not an agent, just a private investor, so we would buy the house directly from you. Super simple and easy… and also personal and private. Life is crazy enough, this doesn\'t have to add to it!',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=14,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 8', Body__c = 'Hi {!Opportunity.account.firstname} - {!$User.firstname} here with {!$Organization.name}. Just wanted to follow up with you I know you are super busy and I want to make this as easy for you as possible. Can I call in you 15 minutes or so?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=7,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 9', Body__c = 'Hi {!Opportunity.account.firstname}, {!$Organization.name}. here! How are you? Are you feeling a little overwhelmed with everything going on this year and the real estate market? What can I do to make it easier for you?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=10,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 10', Body__c = 'Good morning {!Opportunity.account.firstname}! {!$Organization.name} - Crazy question-- if we come to terms on the house, would you rather close this week or next?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=10,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 11', Body__c = 'Good morning! Hope you are off to an amazing day today. I would like to re-evaluate our offer for your property at {!Opportunity.left_main__address_1__c}. Things have changed with this market being so hot and I want to make sure we stay as competitive as possible. Are you available for a quick call?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=30,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 12', Body__c = 'Hi {!Opportunity.account.firstname}! I&#39;d love to move things along with !Opportunity.left_main__address_1__c}... Let me know what questions you still have or if there is anything I can do!',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=31,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 13', Body__c = 'How\'s it going?; Haven\'t heard back from you regarding the house we spoke about a few months ago. We’re in the position to purchase a few more houses and would be happy to provide another offer for you if you needed to sell at this time. No obligations or anything, just thought I’d follow up. Thanks!',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=10,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 14', Body__c = 'Am I bugging you or am I helping you? :( I don\'t want to make you uncomfortable with too much follow up but I also know how crazy life is and I don’t want to drop the ball on you.',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=30,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 15', Body__c = '{!Opportunity.account.firstname}- What would help you the most with your upcoming move: Packing help or movers/moving truck? Both?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=30,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 16', Body__c = 'Hi {!Opportunity.account.firstname}! Was just thinking about you today and wanted to check in. How are you?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=7,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 17', Body__c = 'Maybe you have given up selling your home...;',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=27,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 18', Body__c = 'Did you still have any interest in selling your property? Let me know either way so I can stop bugging you.',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=60,Folder__c='Drama'));
l1.add(new LMR_TemplateSms__c(Name = 'Drama Oppty 19', Body__c = 'Hello again! I was just going through my files and I see here that we never got to a purchase agreement with your house.'+'\n'+'Maybe you\'re somewhere sipping cocktails on an island without a worry in the world'+' Or maybe you\'ve been swamped with work….But what I worry about the most is that maybe I unknowingly did something that upset you or caused you to lose confidence in me and the help my company provides.'+'\n'+'My fear is that I have unknowingly done something to upset you...'+'\n'+'When I came across our messages the other day, I thought that I should probably close your file, but I didn&#39;t want to do so without your permission. I would really appreciate a call or message back so that I know where we stand and what I need to do to get our discussions back on track.',Object__c='',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=60,Folder__c='Drama'));

LeftMain_SecurityUtils.checkInsert(LMR_TemplateSms__c.SObjectType,new List<String> {
	'Name',
	'Body__c',
	'Object__c',
	'Status__c',
	'TypeOfSchedule__c',
	'Folder__c'
});
SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, l1);
Database.insert(l1 = decision3.getRecords());

        }
        
List<Lead_Follow_Up_Sequence__c> listEmailTemplates= [SELECT Id FROM Lead_Follow_Up_Sequence__c LIMIT 50000];
if(listEmailTemplates.isEmpty()){    
	LeadFollowUpService.createLeadFollowUpRecords();
}else{
	LeadFollowUpService.updateDaysFieldFollowUpObject();    
}
    }
}