@isTest
public class ExpenseTriggerHandlerTest {
@isTest
    public static void testExpenses(){
        ExpenseTriggerSetting__c expTriggerInstance = ExpenseTriggerSetting__c.getOrgDefaults();
        expTriggerInstance.Activate_Trigger__c = true;      
		expTriggerInstance.SetupOwnerId = UserInfo.getOrganizationId(); 
        upsert expTriggerInstance;
        List<Vendor__c> testVendor = new List<Vendor__c>();
        testVendor.add(new Vendor__c(Name='testVendor1',duration__c='Yearly'));
        testVendor.add(new Vendor__c(Name='testVendor2',duration__c='Monthly'));
        testVendor.add(new Vendor__c(Name='testVendor3',duration__c='Quarterly'));
        testVendor.add(new Vendor__c(Name='testVendor3',duration__c='Last Month'));
        testVendor.add(new Vendor__c(Name='testVendor3',duration__c='Last Year'));
        testVendor.add(new Vendor__c(Name='testVendor3',duration__c='All Time'));
		insert testVendor;
        List<Vendor__c> vendorList = [SELECT Name,duration__c FROM Vendor__c];
        List<Expense__c> expenses = new List<Expense__c>();
       // expenses.add(new );
        expenses.add(new expense__c(Total_Amount__c=10000,Payee__c=vendorList[0].Id,date__c=date.parse('05/27/2021')));
		expenses.add(new expense__c(Total_Amount__c=10000,Payee__c=vendorList[1].Id,date__c=date.parse('02/27/2021')));
		expenses.add(new expense__c(Total_Amount__c=10000,Payee__c=vendorList[2].Id,date__c=date.parse('02/27/2021')));
        expenses.add(new expense__c(Total_Amount__c=10000,Payee__c=vendorList[1].Id,date__c=date.parse('02/27/2022')));
		expenses.add(new expense__c(Total_Amount__c=10000,Payee__c=vendorList[2].Id,date__c=date.parse('05/27/2022')));
		insert expenses;
        List<Expense__c> expensesList = new List<Expense__c>();
        expensesList = [SELECT Total_Amount__c,Payee__c,date__c FROM expense__c];
        expensesList[0].Total_Amount__c =15000;
        update expensesList;
        system.assertEquals(expenses.size(),5 );
    }
}