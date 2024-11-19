@isTest
private class LeadConversionAuraControllerTest {

    @isTest
    static void LeadConversionTest() {
        Lead leadOBJ = new Lead();
        leadOBJ.LastName = String.ValueOf('A');
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
        Test.startTest();
            List<LeadConversionAuraController.leadConversionWrapper> respoOne = LeadConversionAuraController.fetchLeadRecords('');
            System.assertNotEquals(null, respoOne.Size());
            List<LeadConversionAuraController.leadConversionWrapper> respoTwo = LeadConversionAuraController.fetchLeadRecords('Test');
            System.assertNotEquals(null, respoTwo.Size());
        Test.stopTest();
    }

    @isTest
    static void LeadConversionTestBatch() {
        Lead leadOBJ = new Lead();
        leadOBJ.LastName = String.ValueOf('A');
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
        Test.startTest();
            List<String> LeadList = new List<String>();
            LeadList.add(leadOBJ.Id);
            String batchprocessid = LeadConversionAuraController.convertSelectedLead(LeadList,'test@gamil.com');
            System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
    }
}