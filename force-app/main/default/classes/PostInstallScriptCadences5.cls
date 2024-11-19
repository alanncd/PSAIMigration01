global without sharing class PostInstallScriptCadences5 implements InstallHandler{
  global void onInstall (InstallContext context)
    {
      List<LMR_TemplateSms__c> listSmsCadencesAll= [SELECT Id FROM LMR_TemplateSms__c WHERE NAME LIKE '%Opp - Nurture - Drip%' LIMIT 200 ];
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
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Nurture - Drip1', Body__c = 'Hi {!Opportunity.account.firstname} - {!$User.firstname} here with {!$Organization.name}. Just wanted to follow up with you about selling your house at {!Opportunity.left_main__address_1__c}. Are you still interested in our offer?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='Days',Schedule__c=1,Folder__c='Opp - Nurture - Drip'));
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Nurture - Drip2', Body__c = 'Hi {!Opportunity.account.firstname} - {!$User.firstname} here with {!$Organization.name} again. I know we have not been able yet to see the property at {!Opportunity.address__c} yet to make our cash offer. Can we set an appointment? Reply with a date/time',Object__c='Opportunity',Status__c='Active',Folder__c='Opp - Nurture - Drip2'));
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Nurture - Drip3', Body__c = 'Hi {!Opportunity.account.firstname} - {!$User.firstname} here with {!$Organization.name}. Hope everyone is doing fine, just want to drop a friendly reminder. I AM STILL BUYING HOUSES. How is everything going?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Nurture - Drip3'));
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Nurture - Drip4', Body__c = 'Hi {!Opportunity.account.firstname}, Better Path Homes here! Checking in on you and the house. I want to make sure I am not dropping the ball on you! How are things going? Can we chat a little more about the house and your plans for selling?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Nurture - Drip4'));
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Nurture - Drip5', Body__c = 'Hi {!Opportunity.account.firstname}, {!Opportunity.owner.firstname} here with Better Path Homes! Just reaching out to see if you are still interested in selling your home at {!Opportunity.Address__c}? Just need a quick chat and we can make an offer. (Yes,',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Nurture - Drip5'));
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Nurture - Drip6', Body__c = 'Hi {!Opportunity.account.firstname}, I hope you are doing well &#128522; January here, with Better Path Homes. Did you already sell your house?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Nurture - Drip6'));
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Nurture - Drip7', Body__c = 'Hi {!Opportunity.account.firstname}! It&#39;s {!Opportunity.owner.firstname} w/ {!$Organization.name} - this year is crazy isn\'t it? In any case, I just wanted to check in on you. Where are your thoughts right now about selling?',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Nurture - Drip7'));
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Nurture - Drip8', Body__c = 'Hi {!Opportunity.account.firstname}! Hope you are having an amazing day - January here, I would like to re-evaluate our offer of {!Opportunity.last_offer_made__c} for your property at {!Opportunity.Address__c} . Things have changed with this market and we',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Nurture - Drip8'));
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Nurture - Drip9', Body__c = 'OMG {!Opportunity.account.firstname}! It&#39;s {!Opportunity.owner.firstname} with Better Path -  I realized that I hadn\'t heard back from you since we made the offer! Is everything ok?! Call me soon (or text here) :)',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Nurture - Drip9'));
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Nurture - Drip10', Body__c = 'Hi {!Opportunity.account.firstname}! &#128522; I&#39;d love to move things along with {!Opportunity.Address__c}. Let me know what questions you still have or if there is anything I can do!',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Nurture - Drip10'));
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Nurture - Drip11', Body__c = 'Maybe you have given up selling your home... &#128546;',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Nurture - Drip11'));
          l1.add(new LMR_TemplateSms__c(Name = 'Opp - Nurture - Drip12', Body__c = 'Hey  {!Opportunity.account.firstname}!! OMG I hope I&#39;m not too late. Did you already sell your property at {!Opportunity.address__c}? My team is looking at properties in your neighborhood and I would love to get a cash offer to you RIGHT AWAY so we can ke',Object__c='Opportunity',Status__c='Active',TypeOfSchedule__c='',Folder__c='Opp - Nurture - Drip12'));

        Database.insert(l1);
      }
    }
}