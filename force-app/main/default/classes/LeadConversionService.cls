public with sharing class LeadConversionService {
    public static void updAddressIndexedUpd(List<Lead> newList, Map<ID,Lead> oldMap){
        for (Lead l : newList){
            Lead oldLead = oldMap.get(l.Id);
            if(oldLead.City <> l.City || oldLead.Street <> l.Street){
                 String street='';
                String city = '';
                if(l.Street<>null){
                    street=l.Street;
                }
                if(l.city<>null){
                    city=l.city;
                }
                l.AddressIndex__c = street+''+city;   
            }
        }
    }
    public static void updAddressIndexedCreate(List<Lead> newList){

        for (Lead l : newList){
                 String street='';
                String city = '';
                if(l.Street<>null){
                    street=l.Street;
                }
                if(l.city<>null){
                    city=l.city;
                }
                l.AddressIndex__c = street+''+city;   
        }
    }
    // For lead field mapping on Account and Opportunity object.
    public static void LeadFieldMapping(List<Lead> newList,Map<ID,Lead> oldMap){
        Set<Id> leadIds = new Set<Id>();
        Set<Id> convertedAccountIds = new Set<Id>();
        Set<Id> convertedOpportunityIds = new Set<Id>(); 
        Map < String, String > leadAndOppMap = new Map<String,String>();
LeftMain_SecurityUtils.checkRead( Lead.SObjectType,new List<String> {
'Id',
'Property_Type__c',
'Age_of_HVAC__c',
'Bedrooms__c',
'Age_of_Roof__c',
'Bathrooms__c',
'Age_of_HWH__c',
'Square_footage__c',
'Special_Features__c',
'Year_Built__c',
'Reason_For_Selling__c',
'Lot_Size__c',
'Any_Recent_Updates__c',
'Mortgage_Owed__c',
'How_soon_are_you_looking_to_close__c',
'Occupancy__c',
'Decision_Makers__c',
'Current_on_Payments__c',
'Asking_Price__c',
'Tenant_Current_Monthly_Rent__c',
'How_Long_Owned__c',
'Tenant_Current_Lease_Terms__c'
});
        // Map all those account and opportunity whose create after lead converting.
        for (Lead leadObj : newList) {
            Lead oldLead = oldMap.get(leadObj.Id);
            if (leadObj.convertedAccountId != null && !oldLead.IsConverted && leadObj.isConverted) {
                convertedAccountIds.add(leadObj.convertedAccountId);
            }
            if (leadObj.convertedOpportunityId != null && !oldLead.IsConverted && leadObj.isConverted) {
                leadIds.add(leadObj.Id);
                leadAndOppMap.put(leadObj.convertedOpportunityId,leadObj.Id);
                convertedOpportunityIds.add(leadObj.convertedOpportunityId); 
            }
        }
        
        LeftMain_SecurityUtils.checkRead( Account.SObjectType,new List<String> {
        'Id',
        'firstName',
        'LastName'
        }); 
        
        List<Account> accounts =
            [SELECT Id,firstName,LastName FROM Account
             WHERE Id IN : convertedAccountIds WITH USER_MODE];
        
        Map<Id, Account> mAccounts = new Map<Id, Account>(accounts);
        
LeftMain_SecurityUtils.checkRead( Account.SObjectType,new List<String> {
'Id',
'Name'
}); 
        List<Opportunity> opportunities =
            [SELECT Id, Name,Address_1__c 
             FROM Opportunity
             WHERE Id IN : convertedOpportunityIds WITH USER_MODE];
        
        Map<Id, Opportunity> mOpportunities = new Map<Id, Opportunity>(opportunities);
        
        
        List<Account> updateAccounts = new List<Account>();
        List<Opportunity> updateOpportunities = new List<Opportunity>();
        
        
LeftMain_SecurityUtils.checkUpdate( Account.SObjectType,new List<String> {
'FirstName',
'LastName',
'Property_Type__c',
'Age_of_HVAC__c',
'Bedrooms__c',
'Age_of_Roof__c',
'Bathrooms__c',
'Age_of_HWH__c',
'Square_footage__c',
'Special_Features__c',
'Year_Built__c',
'Reason_For_Selling__c',
'Lot_Size__c',
'Any_Recent_Updates__c',
'Mortgage_Owed__c',
'How_soon_are_you_looking_to_close__c',
'Occupancy__c',
'Decision_Makers__c',
'Current_on_Payments__c',
'Asking_Price__c',
'Tenant_Current_Monthly_Rent__c',
'How_Long_Owned__c',
'Tenant_Current_Lease_Terms__c'
}); 
        
        //for mapping lead record field value in on account object record fields and Opportunity record fields.
        for (Lead leadObj : newList) {
            Lead oldLead = oldMap.get(leadObj.Id);
            if (!oldLead.IsConverted && leadObj.isConverted) {
                // ** CONVERSION FOUND **
                if(leadObj.convertedAccountId != null && mAccounts.containsKey(leadObj.convertedAccountId)){
                    Account accountObj = mAccounts.get(leadObj.convertedAccountId);
                    if(accountObj.FirstName != null && accountObj.LastName != null){
                        accountObj.FirstName = accountObj.FirstName;
                        accountObj.LastName = accountObj.LastName;
                    }
                    accountObj.Property_Type__c = leadObj.Property_Type__c;
                    accountObj.Age_of_HVAC__c = leadObj.Age_of_HVAC__c;
                    accountObj.Bedrooms__c = leadObj.Bedrooms__c;
                    accountObj.Age_of_Roof__c = leadObj.Age_of_Roof__c;
                    accountObj.Bathrooms__c = leadObj.Bathrooms__c;
                    accountObj.Age_of_HWH__c = leadObj.Age_of_HWH__c;
                    accountObj.Square_footage__c = leadObj.Square_footage__c;
                    accountObj.Special_Features__c = leadObj.Special_Features__c;
                    accountObj.Year_Built__c = leadObj.Year_Built__c;
                    accountObj.Reason_For_Selling__c = leadObj.Reason_For_Selling__c; 
                    accountObj.Repairs_Needed__c = leadObj.Repairs_Needed__c;
                    accountObj.Lot_Size__c = leadObj.Lot_Size__c;
                    accountObj.Any_Recent_Updates__c = leadObj.Any_Recent_Updates__c;
                    accountObj.Mortgage_Owed__c = leadObj.Mortgage_Owed__c;
                    accountObj.How_soon_are_you_looking_to_close__c = leadObj.How_soon_are_you_looking_to_close__c;
                    accountObj.Occupancy__c = leadObj.Occupancy__c;
                    accountObj.Decision_Makers__c = leadObj.Decision_Makers__c;
                    accountObj.Current_on_Payments__c = leadObj.Current_on_Payments__c;
                    accountObj.Asking_Price__c = leadObj.Asking_Price__c;
                    accountObj.Tenant_Current_Monthly_Rent__c = leadObj.Tenant_Current_Monthly_Rent__c;
                    accountObj.How_Long_Owned__c = leadObj.How_Long_Owned__c;
                    accountObj.Tenant_Current_Lease_Terms__c = leadObj.Tenant_Current_Lease_Terms__c; 
                    accountObj.Email__c = leadObj.Email;
                    updateAccounts.add(accountObj);
                    
                }
                if(leadObj.convertedOpportunityId != null && mOpportunities.containsKey(leadObj.convertedOpportunityId)){
                    Opportunity opportunityOBJ = mOpportunities.get(leadObj.convertedOpportunityId);
                    
                    String leadAddress = '';
                    leadAddress += String.isNotBlank(leadObj.Street) ? leadObj.Street: '';
                    leadAddress += String.isNotBlank(leadObj.City) ? ','+leadObj.City : '';
                    leadAddress += String.isNotBlank(leadObj.State) ? ','+leadObj.State : '';
                    leadAddress += String.isNotBlank(leadObj.PostalCode) ? ','+leadObj.PostalCode : '';
                    leadAddress += String.isNotBlank(leadObj.Country) ? ','+leadObj.Country : ''; 
                    if(String.isNotBlank(leadAddress)){
                        opportunityOBJ.Full_Address__c = leadAddress;
                    }
                    
                    if(String.isNotBlank(leadAddress) && String.isBlank(opportunityOBJ.Address_1__c)){
                        opportunityOBJ.Address_1__c = leadAddress;  
                    }   
                    
                    opportunityOBJ.Phone__c = leadObj.Phone;
                    opportunityOBJ.MobilePhone__c = leadObj.MobilePhone; 
                    opportunityOBJ.Rating__c = leadObj.Rating;
                    opportunityOBJ.Email__c = leadObj.Email; 
                    opportunityOBJ.Reason_For_Selling__c = leadObj.Reason_For_Selling__c;   
                    opportunityOBJ.Mailing_Address__c  =    leadObj.Mailing_Address__c;
                    
                    opportunityOBJ.Property_Type__c = leadObj.Property_Type__c;
                    opportunityOBJ.Age_of_HVAC__c = leadObj.Age_of_HVAC__c;
                    opportunityOBJ.Bedrooms__c = leadObj.Bedrooms__c;
                    opportunityOBJ.Age_of_Roof__c = leadObj.Age_of_Roof__c;
                    opportunityOBJ.Bathrooms__c = leadObj.Bathrooms__c;
                    opportunityOBJ.Age_of_HWH__c = leadObj.Age_of_HWH__c;
                    opportunityOBJ.Square_footage__c = leadObj.Square_footage__c;
                    opportunityOBJ.Special_Features__c = leadObj.Special_Features__c;
                    opportunityOBJ.Year_Built__c = leadObj.Year_Built__c;
                    opportunityOBJ.Repairs_Needed__c = leadObj.Repairs_Needed__c;
                    opportunityOBJ.Lot_Size__c = leadObj.Lot_Size__c;
                    opportunityOBJ.Any_Recent_Updates__c = leadObj.Any_Recent_Updates__c;
                    opportunityOBJ.Mortgage_Owed__c = leadObj.Mortgage_Owed__c;
                    opportunityOBJ.How_soon_are_you_looking_to_close__c = leadObj.How_soon_are_you_looking_to_close__c;
                    opportunityOBJ.Occupancy__c = leadObj.Occupancy__c;
                    opportunityOBJ.Decision_Makers__c = leadObj.Decision_Makers__c;
                    opportunityOBJ.Current_on_Payments__c = leadObj.Current_on_Payments__c;
                    opportunityOBJ.Asking_Price__c = leadObj.Asking_Price__c;
                    opportunityOBJ.Tenant_Current_Monthly_Rent__c = leadObj.Tenant_Current_Monthly_Rent__c;
                    opportunityOBJ.How_Long_Owned__c = leadObj.How_Long_Owned__c;
                    opportunityOBJ.Tenant_Current_Lease_Terms__c = leadObj.Tenant_Current_Lease_Terms__c;
                    updateOpportunities.add(opportunityOBJ);
                }
            }
        }
        
        
        if (!updateAccounts.isEmpty()) {
             //Commenting this because we are disabling FLS for this package 1.15 Uncomment this when you need FLS for Security Review.
			SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, updateAccounts);
			//update decision.getRecords(); 
    		//List<Database.SaveResult> myResult1 =  Database.update(updateAccounts, false);
            List<Database.SaveResult> myResult1 =  Database.update(decision.getRecords(), false);
        }
        
        if (!updateOpportunities.isEmpty()) {
            // Commenting this because we are disabling FLS for this package 1.15 Uncomment this when you need FLS for Security Review.  
			SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, updateOpportunities);
			//update decision.getRecords(); 
            //List<Database.SaveResult> myResult = Database.update(updateOpportunities, false);
            List<Database.SaveResult> myResult = Database.update(decision.getRecords(), false);

        }
    }
    
    // For convert all those lead where converLead checkbox true.
    public static void convertSelectedLead(List<Lead> newList,Map<ID,Lead> oldMap){
           LeftMain_SecurityUtils.checkRead( Lead.SObjectType,new List<String> {
'Id',
'ConvertLead__c',
'IsConverted'
}); 
        
        Set<Id> LeadIds = new Set<Id>();
        
        // Add those lead record where convertLead checkbox is seleted.
        for (Lead leadObj : newList) {
            Lead oldLead = oldMap.get(leadObj.Id);
            if (!leadObj.isConverted && leadObj.ConvertLead__c && oldLead.ConvertLead__c != leadObj.ConvertLead__c ) {
                LeadIds.add(leadObj.Id); 
            }
        }
        if(!LeadIds.isEmpty()){
            convertSelectedLeadFuture(LeadIds);
        }
        
    }
    
    @Future
    public static void convertSelectedLeadFuture(Set<Id> LeadIds){
        
        LeftMain_SecurityUtils.checkRead( LeadStatus.SObjectType,new List<String> {
        'Id',
        'MasterLabel',
        'IsConverted'
        });

        LeftMain_SecurityUtils.checkRead( Lead.SObjectType,new List<String> {
        'Id',
        'Name'
        }); 
        
        List<LeadStatus> LeadStatusList = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true AND MasterLabel != null WITH USER_MODE  Limit 1];
        List<Lead> LeadToConvert = [SELECT Id,Name From Lead WHERE Id IN:LeadIds AND isConverted = false WITH USER_MODE ];
        if(!LeadStatusList.isEmpty()){
            List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();     
            
            // Add lead in list for covert.
            for(Lead LeadObj : LeadToConvert){                
                Database.LeadConvert Leadconvert = new Database.LeadConvert();    
                Leadconvert.setLeadId(LeadObj.Id);                               
                Leadconvert.setConvertedStatus(LeadStatusList[0].MasterLabel);             
                MassLeadconvert.add(Leadconvert);     
            }                  
            if (!MassLeadconvert.isEmpty()){ 
                try{
                List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert);       
                }catch(Exception e){
                    
                }
                }  
        } 
    }
    
    
    // convert Prospect Lead into Homeowner Lead with Campaign 
    public static void findProspectLead(List<Lead> newList){ 
        Id leadHomeownerId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Homeowner').getRecordTypeId();
        Id leadProspectId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();
        Set<String> streetSet = new Set<String>();
        Set<String> citySet = new Set<String>();
        Set<String> phoneSet = new Set<String>();
        Set<String> mobileSet = new Set<String>();        
        Set<String> streetIndexSet = new Set<String>();        
        Map<String,Lead> newLeadMap = new Map<String,Lead>();
        Map<String,Lead> newPhoneLeadMap = new Map<String,Lead>();
        Map<String,Lead> newMobileLeadMap = new Map<String,Lead>();
        for(Lead leadObj : newList){
            if(leadObj.RecordTypeId != null &&   leadObj.RecordTypeId == leadHomeownerId && 
               String.isNotBlank(leadObj.Street) && String.isNotBlank(leadObj.City) ){
                   streetSet.add(leadObj.Street);
                   citySet.add(leadObj.City);
                   streetIndexSet.add(leadObj.AddressIndex__c);
                   newLeadMap.put(leadObj.Street.toLowerCase()+''+leadObj.City.toLowerCase(),leadObj);
               }
            if(leadObj.RecordTypeId != null &&   leadObj.RecordTypeId == leadHomeownerId && 
               String.isNotBlank(leadObj.phone)){
                   phoneSet.add(leadObj.phone);
                   newPhoneLeadMap.put(leadObj.phone,leadObj);
               }
            if(leadObj.RecordTypeId != null &&   leadObj.RecordTypeId == leadHomeownerId && 
               String.isNotBlank(leadObj.MobilePhone)){
                   mobileSet.add(leadObj.MobilePhone);
                   newMobileLeadMap.put(leadObj.MobilePhone,leadObj);
               }
        }
        List<Lead> updateLeadList = new List<Lead>();
        List<Lead> deleteProspectList = new List<Lead>();
        List<CampaignMember> insertCampaignList = new List<CampaignMember>();
        LeftMain_SecurityUtils.checkRead(CampaignMember.SObjectType,new List<String> {
                            'campaignid',
                             'leadid'
        				});       
		LeftMain_SecurityUtils.checkInsert(CampaignMember.SObjectType,new List<String> {
                            'campaignid',
                             'leadid'
        				});
        //List<Lead> prospectLeadList = new List<Lead>();
        List<Lead> prospectLeadList = [SELECT Id, LastName, FirstName, Salutation, Name, 
                                       RecordTypeId, Title, Company, Street, City, State, PostalCode, Country, Latitude, 
                                       Longitude, Address, Phone, MobilePhone, Fax, Email, Website, 
                                       PhotoUrl, Description, LeadSource, Status, Industry, Rating, AnnualRevenue, 
                                       NumberOfEmployees, SICCode__c, 
                                       ProductInterest__c,Primary__c, CurrentGenerators__c, 
                                       NumberofLocations__c,Age_of_HVAC__c, Age_of_HWH__c,
                                       Age_of_Roof__c,Any_Recent_Updates__c, Asking_Price__c,
                                       Bathrooms__c,
                                       Bedrooms__c, Contacted__c, Current_on_Payments__c,
                                       Decision_Makers__c, Email__c, How_Long_Owned__c,
                                       How_soon_are_you_looking_to_close__c, Lead_Source__c,
                                       Lot_Size__c, Mortgage_Owed__c, Next_Step__c,
                                       Occupancy__c, Phone__c, Special_Features__c,
                                       Square_footage__c, Year_Built__c, Lead_Contacted_Time__c,
                                       Elapsed_Minutes_to_Contacted__c, Unqualified_Reason__c, 
                                       Repairs_Needed__c, Tenant_Current_Monthly_Rent__c,
                                       Tenant_Current_Lease_Terms__c, Property_Type__c, 
                                       TaskCount__c, EventCount__c, Activity_Count_TE__c, 
                                       ConvertLead__c, Reason_for_Selling__c, 
                                       Garage__c, Mailing_Address__c, Bed_Count__c 
                                       FROM Lead WHERE  
                                       (AddressIndex__c IN :streetIndexSet OR Phone IN :phoneSet OR 
                                        MobilePhone IN :mobileSet  OR (city IN : citySet AND street IN:streetSet )) AND RecordTypeId  != null AND RecordTypeId =:leadProspectId WITH USER_MODE];

        if(!prospectLeadList.isEmpty()){ 
            Map<String,List<CampaignMember>> mapCampaign = new Map<String,List<CampaignMember>>();
            List<CampaignMember> campaignList = [SELECT Id,CampaignId,LeadId FROM CampaignMember WHERE leadId IN :prospectLeadList AND LeadId != null AND CampaignId != null WITH USER_MODE];
            for(CampaignMember campaignObj : campaignList){
                if(!mapCampaign.containsKey(campaignObj.LeadId)){
                    mapCampaign.put(campaignObj.LeadId, new List<CampaignMember>{campaignObj});
                }else{
                    mapCampaign.get(campaignObj.LeadId).add(campaignObj);
                }
            }
            
            String flgName = ''; //Key to mark if the record exist
            String flgKey = ''; //Key to mark if the record exist
            for(Lead prospectLeadObj : prospectLeadList){
                Boolean LeadFound = false;
                Lead leadObj;
                String Street = String.isNotBlank(prospectLeadObj.Street) ? prospectLeadObj.Street.toLowerCase() : '';
                String City  = String.isNotBlank(prospectLeadObj.City) ? prospectLeadObj.City.toLowerCase() : '';
                String StreetAndCity = Street+''+City;
                String phone = String.isNotBlank(prospectLeadObj.phone) ?  prospectLeadObj.phone : '';
                String mobile = String.isNotBlank(prospectLeadObj.MobilePhone) ?  prospectLeadObj.MobilePhone : '';
                //Verify if the value exist more than 1 time
                if(flgKey<>''){
                    if(flgKey=='StreetCity'){
                        if(flgName==StreetAndCity){
                            flgKey='';
                            flgName='';
                            deleteProspectList.add(prospectLeadObj);
                            continue;}
                    }else if(flgKey=='phone'){
                        if(flgName==phone){
                            flgKey='';
                            flgName='';
                            deleteProspectList.add(prospectLeadObj);
                            continue;}
                    }else if(flgKey=='mobile'){
                        if(flgName==mobile){
                            flgKey='';
                            flgName='';
                            deleteProspectList.add(prospectLeadObj);
                            continue;}
                    }
                }
                if(String.isNotBlank(Street)  && String.isNotBlank(City) && newLeadMap != null && newLeadMap.Size() > 0 && newLeadMap.containsKey(StreetAndCity)){
                    leadObj = newLeadMap.get(StreetAndCity);
                    LeadFound = true;
                    flgKey = 'StreetCity';
                    flgName = StreetAndCity;
                }else if(String.isNotBlank(phone) && newPhoneLeadMap != null && newPhoneLeadMap.Size() > 0 && newPhoneLeadMap.containsKey(phone)){
                    leadObj = newPhoneLeadMap.get(phone);
                    LeadFound = true;
                    flgKey = 'phone';
                    flgName = phone;
                }else if(String.isNotBlank(mobile) && newMobileLeadMap != null && newMobileLeadMap.Size() > 0 && newMobileLeadMap.containsKey(mobile)){
                    leadObj = newMobileLeadMap.get(mobile);
                    LeadFound = true;
                    flgKey = 'mobile';
                    flgName = mobile;
                }
                
                if(LeadFound){
                    Id ProspectId = prospectLeadObj.Id;
                    Id LeadId = leadObj.id;
                    String firstName = leadObj.FirstName;
                    String lastName   = leadObj.LastName;
                    leadObj  = prospectLeadObj.clone(false, false, false, false);
                    leadObj.firstName = firstName;
                    leadObj.LastName  = lastName;
                    leadObj.Id = LeadId;
                    leadObj.RecordTypeId = leadHomeownerId;
                    updateLeadList.add(leadObj);
                    if(mapCampaign != null && mapCampaign.containsKey(prospectLeadObj.Id)){
                        List<CampaignMember> campaignMemberUpdateList = mapCampaign.get(prospectLeadObj.Id) != null && !mapCampaign.get(prospectLeadObj.Id).isEmpty() ? mapCampaign.get(prospectLeadObj.Id) : new List<CampaignMember>();
                        for(CampaignMember CampaignMemObj : campaignMemberUpdateList){
                            CampaignMember newCampaign = new CampaignMember(); 
                            newCampaign.campaignid = CampaignMemObj.CampaignId;
                            newCampaign.leadid= LeadId;
                            insertCampaignList.add(newCampaign);   
                        }
                    }
                    deleteProspectList.add(prospectLeadObj);
                }
            }

            if (!deleteProspectList.isEmpty() &&  deleteProspectList.getSObjectType().getDescribe().isDeletable() ) {
                Database.delete(deleteProspectList, AccessLevel.System_mode);
            }
            if(!updateLeadList.isEmpty()){
                SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.UPDATABLE, updateLeadList);
                update decision1.getRecords();
            }
            if(!insertCampaignList.isEmpty()){
				SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, insertCampaignList);
                insert decision.getRecords();
            }
        }
    }
    
    
    // For lead chatter mapping on Opportunity object.
    public static void MapChatterPost(List<Lead> newList,Map<ID,Lead> oldMap){
        Set<Id> leadIds = new Set<Id>(); 
        Set<Id> convertedAccountIds = new Set<Id>();
        Set<Id> convertedOpportunityIds = new Set<Id>(); 
        Map < String, String > leadAndOppMap = new Map<String,String>();
        for (Lead leadObj : newList) {
            Lead oldLead = oldMap.get(leadObj.Id);
            if (leadObj.convertedAccountId != null && !oldLead.IsConverted && leadObj.isConverted) {convertedAccountIds.add(leadObj.convertedAccountId);
            }
            if (leadObj.convertedOpportunityId != null && !oldLead.IsConverted && leadObj.isConverted) {leadIds.add(leadObj.Id);
                leadAndOppMap.put(leadObj.convertedOpportunityId,leadObj.Id);
                convertedOpportunityIds.add(leadObj.convertedOpportunityId); 
            }
        }
        
        List<Account> accounts =
            [SELECT Id,firstName,LastName FROM Account
             WHERE Id IN : convertedAccountIds WITH USER_MODE];
        
        Map<Id, Account> mAccounts = new Map<Id, Account>(accounts);
        List<Opportunity> opportunities =
            [SELECT Id, Name,Address_1__c 
             FROM Opportunity
             WHERE Id IN : convertedOpportunityIds WITH USER_MODE];
        
        if(leadAndOppMap != null && leadAndOppMap.size() > 0){addLeadChatter(leadAndOppMap,opportunities,leadIds);
        }
    } 
    
    public static void addLeadChatter(Map < String, String > leadAndOppMap,List<Opportunity> oppRecordList,Set<Id> newleadIdSet) {
        Map<Id,List<FeedItem>> newFeedItemMap = new Map<Id,List<FeedItem>>();
        List<FeedItem> newLeadFeedItemList = [SELECT Id, ParentId, Type, Body, Title, LinkUrl, IsRichText, RelatedRecordId FROM FeedItem 
                                              WHERE ParentId IN  :newleadIdSet WITH USER_MODE ];
        for(FeedItem feed : newLeadFeedItemList) {
            if(newFeedItemMap.containsKey(feed.ParentId) ) {
                List<FeedItem> feedList = newFeedItemMap.get(feed.ParentId);
                feedList.add(feed);                    
                newFeedItemMap.put(feed.ParentId,feedList);
            } else {                    
                newFeedItemMap.put(feed.ParentId,new List<FeedItem> { feed });
            }
        }           
        
        List<FeedItem> feedItemToInsertList = new List<FeedItem>();
        for(Opportunity record : oppRecordList) {
            if (record.Id != null && leadAndOppMap != null && leadAndOppMap.size() > 0 && leadAndOppMap.containsKey(record.id)) {
                String LeadId = leadAndOppMap.get(record.id);
                if(record.Id != null && newFeedItemMap.containsKey(LeadId)) { 
                    for(FeedItem feed : newFeedItemMap.get(LeadId)) {                        
                        if(feed.Body != null && feed.Body != '') 
                        {
                            FeedItem post = new FeedItem();
                            post.ParentId = record.Id; 
                            post.Body = (feed.Body).replaceAll('<[^>]+>',' ');
                            feedItemToInsertList.add(post);
                        }
                    }                               
                }      
            }           
        }
        if(!feedItemToInsertList.isEmpty()) {
            LeftMain_SecurityUtils.checkInsert(FeedItem.SObjectType,new List<String> {
                'ParentId',
                 'Body'
            });
            SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, feedItemToInsertList);
            Database.insert(feedItemToInsertList = decision3.getRecords());
        }
    }
}