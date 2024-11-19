global without sharing class PostInstallScriptCadences4 implements InstallHandler{
    global void onInstall (InstallContext context)
    {
        List<LMR_TemplateSms__c> listSmsCadencesAll= [SELECT Id FROM LMR_TemplateSms__c WHERE NAME LIKE '%Emotional Oppty%' LIMIT 200 ];
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
            l1.add(new LMR_TemplateSms__c(Name = 'Emotional Oppty 1', Body__c = 'Hello again! Just wanted to reach out and make sure that you got all of your questions answered yesterday! How are you feeling about everything today?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=1,Folder__c='Emotional Emily'));
			l1.add(new LMR_TemplateSms__c(Name = 'Emotional Oppty 2', Body__c = 'Hi {!Opportunity.account.firstname} - {!$User.firstname} here with {!$Organization.name}. Just wanted to follow up with you and thank you for reaching out to our company for an offer on your home. I know this is an incredibly important decision! Can I call in you 15 minutes or so to just check in to see how things are going?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=7,Folder__c='Emotional Emily'));
			l1.add(new LMR_TemplateSms__c(Name = 'Emotional Oppty 3', Body__c = 'Hi {!Opportunity.account.firstname}, {!$Organization.name}. here! How are you? Are you feeling a little overwhelmed with everything going on this year and the real estate market? What can I do to make it easier for you?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=10,Folder__c='Emotional Emily'));
            l1.add(new LMR_TemplateSms__c(Name = 'Emotional Oppty 4', Body__c = 'Good morning {!Opportunity.account.firstname}! It\'s{!$Organization.name} -',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=10,Folder__c='Emotional Emily'));
            l1.add(new LMR_TemplateSms__c(Name = 'Emotional Oppty 5', Body__c = 'Good morning! Hope you are off to an amazing day today. I would like to re-evaluate our offer for your property at {!Opportunity.left_main__address_1__c}. Things have changed with this market being so hot and I want to make sure we stay as competitive as possible. Are you available for a quick call?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=30,Folder__c='Emotional Emily'));
            l1.add(new LMR_TemplateSms__c(Name = 'Emotional Oppty 6', Body__c = 'Hi {!Opportunity.account.firstname}! I&#39;d love to move things along with !Opportunity.left_main__address_1__c}... Let me know what questions you still have or if there is anything I can do!',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=31,Folder__c='Emotional Emily'));
            l1.add(new LMR_TemplateSms__c(Name = 'Emotional Oppty 7', Body__c = 'How’s it going? &#128578; Haven\'t heard back from you regarding the house we spoke about a few months ago. We’re in the position to purchase a few more houses and would be happy to provide another offer for you if you needed to sell at this time. No obligations or anything, just thought I’d follow up. Thanks!',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=10,Folder__c='Emotional Emily'));
            l1.add(new LMR_TemplateSms__c(Name = 'Emotional Oppty 8', Body__c = 'Hi there! &#128522; Checking to see if you had any interest in selling anytime soon? Again, I\'m not an agent, just a private investor, so we would buy the house directly from you. We are excited to be able to provide a very personal, white-glove experience. It\'s the benefit of being a local company who truely cares!',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=14,Folder__c='Emotional Emily'));
            l1.add(new LMR_TemplateSms__c(Name = 'Emotional Oppty 9', Body__c = '{!Opportunity.account.firstname}- What would help you the most with your upcoming move: Packing help or movers/moving truck? Both?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=30,Folder__c='Emotional Emily'));
            l1.add(new LMR_TemplateSms__c(Name = 'Emotional Oppty 10', Body__c = 'Ugh. Guilt. We all feel it. Right? Especially with these terrible “if…then” ideas when it comes to home-selling or finances. We\'ve all been there…'+'\n'+';If… I make the phone call to sell my home… Then… I may be committed to sell and I\'m just not sure.'+'\n'+'If… the person comes out to look at my house and I decide not to sell… Then …I may waste the person\'s time.'+'\n'+'If… the cash offer is not as high as I want… Then …I will feel bad for starting all of this process and not committing.Well, I am happy to report that THIS IS WHAT WE DO! We are here to help people (and a bigger secret: We like doing it)! Together, the {!$Organization.name} team has helped hundreds of homeowners, even if they decide NOT to sell to us. No guilt involved! In fact, I, myself, will be happy to come look over your property and individual situation and give you a hassle-free cash offer. So no matter the situation.',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=30,Folder__c='Emotional Emily'));
            l1.add(new LMR_TemplateSms__c(Name = 'Emotional Oppty 11', Body__c = 'Hi {!Opportunity.account.firstname}! Was just thinking about you today and wanted to check in. How are you?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=7,Folder__c='Emotional Emily'));
            l1.add(new LMR_TemplateSms__c(Name = 'Emotional Oppty 12', Body__c = 'Maybe you have given up selling your home... &#128546;',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=27,Folder__c='Emotional Emily'));
            l1.add(new LMR_TemplateSms__c(Name = 'Emotional Oppty 13', Body__c = 'Did you still have any interest in selling your property? Let me know either way so I can stop bugging you.',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=60,Folder__c='Emotional Emily'));
            l1.add(new LMR_TemplateSms__c(Name = 'Emotional Oppty 14', Body__c = 'Hello again! I was just going through my files and I see here that we never got to a purchase agreement with your houseMaybe you\'re somewhere sipping cocktails on an island without a worry in the world Or maybe you\'ve been swamped with work….'+'\n'+'But what I worry about the most is that maybe I unknowingly did something that upset you or caused you to lose confidence in me and the help my company provides.My fear is that I have unknowingly done something to upset you...When I came across our messages the other day, I thought that I should probably close your file, but I didn\'t want to do so without your permission. I would really appreciate a call or message back so that I know where we stand and what I need to do to get our discussions back on track.',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=60,Folder__c='Emotional Emily'));

            LeftMain_SecurityUtils.checkUpdate(LMR_TemplateSms__c.SObjectType,new List<String> {
                'Name',
                'Body__c',
                'Object__c',
                'Status__c',
                'TypeOfSchedule__c',
                'Folder__c'
            }); 
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