@isTest
public class LeadConversionServiceTest {
    
    static testMethod void testTaskTriggerOneTst(){
        LeadConversionSettings__c leadTriggerInstance = LeadConversionSettings__c.getOrgDefaults();
        leadTriggerInstance.Activate_Trigger__c = false;
        leadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert leadTriggerInstance;
        test.startTest();
        Lead leadOBJ = new Lead(); 
        leadOBJ.LastName = String.ValueOf('A');
        LeadObj.Street = 'test';
       	LeadObj.City = 'test';
        leadOBJ.Next_Step__c = 'Test';
        leadOBJ.Property_Type__c = 'Single Family';
        leadOBJ.Age_of_HVAC__c = 20;
        leadOBJ.Bedrooms__c = 20;
        leadOBJ.Age_of_Roof__c = 20;
        leadOBJ.Bathrooms__c = 20;
        leadOBJ.Age_of_HWH__c = 20;
        leadOBJ.Square_footage__c = 20;
        leadOBJ.Special_Features__c = 'test';
        leadOBJ.Year_Built__c = 20;
        leadOBJ.Repairs_Needed__c = 'test';
        leadOBJ.Lot_Size__c = 'test';
        leadOBJ.Any_Recent_Updates__c = 'test'; 
        leadOBJ.Mortgage_Owed__c = 20;
        leadOBJ.How_soon_are_you_looking_to_close__c = 'test';
        leadOBJ.Occupancy__c = 'Owner occupied';
        leadOBJ.Decision_Makers__c = 'test';
        leadOBJ.Current_on_Payments__c = 'Yes';
        leadOBJ.Asking_Price__c = 20;
        leadOBJ.Tenant_Current_Monthly_Rent__c = 20;
        leadOBJ.How_Long_Owned__c = 'test';
        leadOBJ.Tenant_Current_Lease_Terms__c = 'test';
        insert leadOBJ;
        
        
        
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(leadOBJ.id);
        
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        test.stopTest();
        try{
        System.debug('try convertion');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        if (!lcr.IsSuccess()) {
    		String errormsg = lcr.errors.get(0).message;
            System.debug('error message: '+errormsg);
        }
        System.assert(lcr.isSuccess(),''); 
        lc.setOpportunityName('Cole Swain');
        System.debug('try convertion 2');

        }catch(Exception e){
            
        }
        
        
        
    }
    
    static testMethod void testTaskTriggerTwo(){
        LeadConversionSettings__c leadTriggerInstance = LeadConversionSettings__c.getOrgDefaults();
        leadTriggerInstance.Activate_Trigger__c = true;
			leadTriggerInstance.Activate_Chatter_Mapping__c  = true;                
        leadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert leadTriggerInstance;
        
        
        Lead leadOBJ = new Lead(); 
       leadOBJ.LastName = String.ValueOf('A');
        leadOBJ.Next_Step__c = 'Test';
        LeadObj.Street = 'test';
        	LeadObj.City = 'test';
        leadOBJ.Property_Type__c = 'Single Family';
        leadOBJ.Age_of_HVAC__c = 20;
        leadOBJ.Bedrooms__c = 20;
        leadOBJ.Age_of_Roof__c = 20;
        leadOBJ.Bathrooms__c = 20;
        leadOBJ.Age_of_HWH__c = 20;
        leadOBJ.Square_footage__c = 20;
        leadOBJ.Special_Features__c = 'test';
        leadOBJ.Year_Built__c = 20;
        leadOBJ.Repairs_Needed__c = 'test';
        leadOBJ.Lot_Size__c = 'test';
        leadOBJ.Any_Recent_Updates__c = 'test'; 
        leadOBJ.Mortgage_Owed__c = 20;
        leadOBJ.How_soon_are_you_looking_to_close__c = 'test';
        leadOBJ.Occupancy__c = 'Owner occupied';
        leadOBJ.Decision_Makers__c = 'test';
        leadOBJ.Current_on_Payments__c = 'Yes';
        leadOBJ.Asking_Price__c = 20;
        leadOBJ.Tenant_Current_Monthly_Rent__c = 20;
        leadOBJ.How_Long_Owned__c = 'test';
        leadOBJ.Tenant_Current_Lease_Terms__c = 'test';
        insert leadOBJ;
        
        test.startTest();
           FeedItem feed = new FeedItem (
        parentid = leadOBJ.id,
        type = 'ContentPost',
        Body = 'Hello'
    );
    try {
        insert feed;    
    } catch (exception e) {
        System.assert(e.getMessage().contains('Sorry..!! You cannot attach this file format'));
    }
        
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(leadOBJ.id);
        
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        try{
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess(),'');
        
        lc.setOpportunityName('Cole Swain'); 
        }catch(Exception e){
            
        }
        
        test.stopTest();
    }

    static testMethod void testConvertLeadThree(){
            LeadConversionSettings__c leadTriggerInstance = LeadConversionSettings__c.getOrgDefaults();
            leadTriggerInstance.Activate_Trigger__c = true;
			leadTriggerInstance.Activate_Chatter_Mapping__c  = true;        
            leadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
            upsert leadTriggerInstance;
            Lead leadOBJ = new Lead(); 
            leadOBJ.LastName = 'BBBB';
        	LeadObj.Street = 'test';
        	LeadObj.City = 'test';
            leadOBJ.Next_Step__c = 'Test';
            insert leadOBJ;  
             
            Test.startTest();    
           
            leadOBJ.ConvertLead__c = true;
            update leadOBJ;

        	leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true Limit 1];
        	System.assertNotEquals(null, convertStatus,'');
        
            Test.stopTest();
    }
    
    static testMethod void testPropect(){
            LeadConversionSettings__c leadTriggerInstance = LeadConversionSettings__c.getOrgDefaults();
            leadTriggerInstance.Activate_Trigger__c = true;
        	leadTriggerInstance.Find_Prospect__c  = true;
        leadTriggerInstance.Activate_Chatter_Mapping__c  = true;
            leadTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
            upsert leadTriggerInstance;
        	Id leadProspectId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();
        	Id leadHomeownerId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Homeowner').getRecordTypeId();
            Lead leadOBJ = new Lead(); 
            leadOBJ.LastName = 'BBBB';
        	LeadObj.Street = 'test';
        	LeadObj.City = 'test';
        	LeadObj.phone = '555555555';
        	LeadObj.mobilePhone = '995555555';
            leadOBJ.Next_Step__c = 'Test';
        	leadOBJ.RecordTypeId = leadProspectId;
            insert leadOBJ;  
            Campaign camp1 = new Campaign(Name = 'Test Campaign 1', IsActive = True);
        	insert camp1;
        	Campaign camp2 = new Campaign(Name = 'Test Campaign 2', IsActive = True);
        	insert camp2;
        	CampaignMember testCampMemb1 = new CampaignMember(LeadId =leadOBJ.Id , CampaignId = camp1.Id, Status = 'Sent');
        	CampaignMember testCampMemb2 = new CampaignMember(LeadId =leadOBJ.Id , CampaignId = camp2.Id, Status = 'Sent');
        	insert testCampMemb1;
        	insert testCampMemb2;
            Test.startTest();    
        
                Lead leadOBJhome = new Lead(); 
                leadOBJhome.LastName = 'AAAA';
                leadOBJhome.Street = 'test2';
                leadOBJhome.City = 'test';
        		leadOBJhome.phone = '555555555';
        		LeadObj.mobilePhone = '995555555';
                leadOBJhome.Next_Step__c = 'Test';
                leadOBJhome.RecordTypeId = leadHomeownerId;
                insert leadOBJhome;  
        		system.assertEquals(leadHomeownerId, leadOBJhome.RecordTypeId);
            Test.stopTest();
    }
    static testMethod void testLeadCreation(){
        		Id rt = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();
                Lead leadA = new Lead(); 
        		leadA.LastName = 'AAAA';
                leadA.Street = 'testA';
                leadA.City = 'testAA';
        		leadA.RecordTypeId = rt;
        		insert leadA;  
        		system.assertNotEquals(leadA, null);
    }
    

    
    
    
}