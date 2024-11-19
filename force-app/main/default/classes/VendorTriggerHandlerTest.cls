@isTest
private class VendorTriggerHandlerTest {
    
	@isTest
    static void testUpdateVendor(){ 
        System.debug('test');
        VendorTriggerSetting__c vendorTriggerInstance = VendorTriggerSetting__c.getOrgDefaults();
        vendorTriggerInstance.Activate_Trigger__c = true;
        vendorTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert vendorTriggerInstance;  
        List<Lead> leadList = new List<Lead>();
        leadList.add(new Lead(LeadSource='Facebook',LastName='Test',Next_Step__c='Test',street='street1'));
        leadList.add(new Lead(LeadSource='Facebook',LastName='Test12',Next_Step__c='Test',street='street2'));
        leadList.add(new Lead(LeadSource='Google',LastName='Test12',Next_Step__c='Test',street='street3'));
        insert leadList;
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(new Opportunity(Name = 'Test1',LeadSource = 'Google',StageName = 'Retail',Obstacle_to_Setting_Appointment__c = 'Weather',CloseDate = System.today().addDays(10),NextStep = 'TestNextStep'));
        oppList.add(new Opportunity(Name = 'Test2',LeadSource = 'Facebook',StageName = 'Retail',Obstacle_to_Setting_Appointment__c = 'Weather',CloseDate = System.today().addDays(10),NextStep = 'TestNextStep'));
        oppList.add(new Opportunity(Name = 'Test3',LeadSource = 'Facebook',StageName = 'Retail',Obstacle_to_Setting_Appointment__c = 'Weather',CloseDate = System.today().addDays(10),NextStep = 'TestNextStep'));
        insert oppList;
        
        
        List<Transactions__c> transactionsList = new List<Transactions__c>();
        transactionsList.add(new Transactions__c(Name='Test Transactions',Lead_Source__c='Google Ads',Disposition_Decision__c='Pending',Remote_Closing__c='Yes',Closing_Attorney__c='other',Contract_Purchase_Price__c=20,Closing_Date__c=Date.today()));
        transactionsList.add(new Transactions__c(Name='Test Transactions',Lead_Source__c='Facebook',Disposition_Decision__c='Pending',Remote_Closing__c='Yes',Closing_Attorney__c='other',Contract_Purchase_Price__c=20,Closing_Date__c=Date.today()));
        transactionsList.add(new Transactions__c(Name='Test Transactions',Lead_Source__c='Facebook',Disposition_Decision__c='Pending',Remote_Closing__c='Yes',Closing_Attorney__c='other',Contract_Purchase_Price__c=20,Closing_Date__c=Date.today()));
        insert transactionsList;
        
        List<Vendor__c> vendorList = new List<Vendor__c>();
        vendorList.add(new Vendor__c(ID__c='15',Name='Google',Active__c=True, Duration__c = 'Monthly'));
        vendorList.add(new Vendor__c(ID__c='15',Name='Facebook',Active__c=True, Duration__c = 'Yearly'));
		vendorList.add(new Vendor__c(ID__c='15',Name='Facebook',Active__c=True, Duration__c = 'Last Year'));
		vendorList.add(new Vendor__c(ID__c='15',Name='Facebook',Active__c=True, Duration__c = 'Last Quarter'));        
        vendorList.add(new Vendor__c(ID__c='15',Name='Facebook',Active__c=True, Duration__c = 'Last Month'));   
        vendorList.add(new Vendor__c(ID__c='15',Name='Facebook',Active__c=True, Duration__c = 'All Time'));   
        insert vendorList;
        
        List<Vendor__c> updateVendors = [SELECT Id, Name, Duration__c FROM Vendor__c LIMIT 1];
        updateVendors[0].Duration__c = 'Quarterly';
        update updateVendors;
        
        List<Vendor__c> updateVendors2 = [SELECT Id, Name, Duration__c FROM Vendor__c LIMIT 1];
        updateVendors2[0].Duration__c = 'Last Month';
        update updateVendors2;
        
       	Vendor__c updatedVendors = [SELECT Id, Name, Duration__c,Opportunities__c,Leads__c FROM Vendor__c LIMIT 1];
        System.assertNotEquals(null, updatedVendors.Leads__c);
        System.assertNotEquals(null, updatedVendors.Opportunities__c);
    }
}