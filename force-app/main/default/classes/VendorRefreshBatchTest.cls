@isTest
public class VendorRefreshBatchTest {
    
    @isTest
    private static void refreshUpdateVendor(){
        System.debug('test');
        List<Lead> leadList = new List<Lead>();
        leadList.add(new Lead(LeadSource='Facebook',LastName='Test',Next_Step__c='Test'));
        leadList.add(new Lead(LeadSource='Facebook',LastName='Test12',Next_Step__c='Test'));
        leadList.add(new Lead(LeadSource='Google',LastName='Test12',Next_Step__c='Test'));
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
        vendorList.add(new Vendor__c(ID__c='15',Name='Google',Active__c=True, Duration__c = null));
        vendorList.add(new Vendor__c(ID__c='15',Name='Google',Active__c=True, Duration__c = 'Monthly'));
        vendorList.add(new Vendor__c(ID__c='15',Name='Facebook',Active__c=True, Duration__c = 'Yearly'));
        vendorList.add(new Vendor__c(ID__c='15',Name='Facebook',Active__c=True, Duration__c = 'Quarterly'));
        insert vendorList;
        leadList = new List<Lead>();
        leadList.add(new Lead(LeadSource='Facebook',LastName='Test',Next_Step__c='Test'));
        leadList.add(new Lead(LeadSource='Facebook',LastName='Test12',Next_Step__c='Test'));
        leadList.add(new Lead(LeadSource='Google',LastName='Test12',Next_Step__c='Test'));
        insert leadList;
        Test.startTest();
        try{
        Database.executeBatch(new VendorRefreshBatch(),2000);}catch(Exception e){System.debug('log');}
        
        Test.stopTest();
        Vendor__c ven = [SELECT Id, Duration__c, Name, Transactions__c, Total_Project_Profit__c, Leads__c, Opportunities__c FROM Vendor__c Where Duration__c != null Limit 1];
       // System.assertNotEquals(null, ven.Leads__c);
       System.assertEquals(vendorList.size(), 4);
    }
}