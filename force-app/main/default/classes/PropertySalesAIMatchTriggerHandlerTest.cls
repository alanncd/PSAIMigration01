@isTest
public class PropertySalesAIMatchTriggerHandlerTest {
    
    // Test data setup using @testSetup annotation
    @testSetup
    static void setupTestData() {
        // Create test Leads
        Lead lead1 = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Company = 'Doe Enterprises',
            Status = 'Open - Not Contacted',
            Match_Found_Previous_Status__c = 'Contacted'
        );
        
        Lead lead2 = new Lead(
            FirstName = 'Jane',
            LastName = 'Smith',
            Company = 'Smith LLC',
            Status = 'Open - Not Contacted',
            Match_Found_Previous_Status__c = 'Contacted'
        );
        
        insert new List<Lead> {lead1, lead2};
        
        // Create test Opportunities
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity Alpha',
            StageName = 'Prospecting',
            CloseDate = Date.today().addMonths(1),
            Match_Found_Previous_Stage__c = 'Qualification'
        );
        
        Opportunity opp2 = new Opportunity(
            Name = 'Opportunity Beta',
            StageName = 'Prospecting',
            CloseDate = Date.today().addMonths(1),
            Match_Found_Previous_Stage__c = 'Qualification'
        );
        
        insert new List<Opportunity> {opp1, opp2};
        
        Property_SalesAI_History__c history = new Property_SalesAI_History__c(
            Name = 'Test History Record' 
        );
        insert history;

        // Create Property_SalesAI_Match__c records associated with Leads and Opportunities
        Property_SalesAI_Match__c match1 = new Property_SalesAI_Match__c(
            Property_SalesAI_History__c = history.Id,
            Status__c = 'Confirmed',
            Type__c = 'Lead Match',
            Lead__c = lead1.Id
        );
        
        Property_SalesAI_Match__c match2 = new Property_SalesAI_Match__c(
            Property_SalesAI_History__c = history.Id,
            Status__c = 'Confirmed',
            Type__c = 'Opportunity Match',
            Opportunity__c = opp1.Id
        );
        
        Property_SalesAI_Match__c match3 = new Property_SalesAI_Match__c(
            Property_SalesAI_History__c = history.Id,
            Status__c = 'Confirmed',
            Type__c = 'Lead Match',
            Lead__c = lead2.Id
        );
        
        Property_SalesAI_Match__c match4 = new Property_SalesAI_Match__c(
            Property_SalesAI_History__c = history.Id,
            Status__c = 'Confirmed',
            Type__c = 'Opportunity Match',
            Opportunity__c = opp2.Id
        );
        
        insert new List<Property_SalesAI_Match__c>{ match1, match2, match3, match4 };
    }
    
    /**
     * Test Case 1: Update Status from 'Confirmed' to 'Rejected' for a Lead-associated match.
     * Expected Outcome: Related Lead's Status should be updated to Match_Found_Previous_Status__c.
     */
    @isTest
    static void testUpdateLeadsStatus() {
        // Retrieve test data
        Lead lead1 = [SELECT Id, Status, Match_Found_Previous_Status__c FROM Lead WHERE LastName = 'Doe' LIMIT 1];
        Property_SalesAI_Match__c match1 = [SELECT Id, Status__c, Lead__c FROM Property_SalesAI_Match__c WHERE Lead__c = :lead1.Id LIMIT 1];
        
        // Prepare old map
        Map<Id, Property_SalesAI_Match__c> oldMap = new Map<Id, Property_SalesAI_Match__c>{
            match1.Id => match1
        };
        
        // Update the match status to 'Rejected'
        match1.Status__c = 'Rejected';
        update match1;
        
        // Retrieve updated match
        Property_SalesAI_Match__c updatedMatch = [SELECT Id, Status__c, Lead__c FROM Property_SalesAI_Match__c WHERE Id = :match1.Id LIMIT 1];
        
        // Prepare new list
        List<Property_SalesAI_Match__c> newList = new List<Property_SalesAI_Match__c>{ updatedMatch };
        
        // Invoke the handler method
        Test.startTest();
        PropertySalesAIMatchTriggerHandler.updateLeadsAndOppsRollBack(newList, oldMap);
        Test.stopTest();
        
        // Assert that the Lead's Status has been updated
        Lead updatedLead = [SELECT Id, Status FROM Lead WHERE Id = :lead1.Id LIMIT 1];
        System.assertEquals(
            lead1.Match_Found_Previous_Status__c,
            updatedLead.Status,
            'The Lead\'s Status should be updated to Match_Found_Previous_Status__c.'
        );
    }
    
    /**
     * Test Case 2: Update Status from 'Confirmed' to 'Rejected' for an Opportunity-associated match.
     * Expected Outcome: Related Opportunity's StageName should be updated to Match_Found_Previous_Stage__c.
     */
    @isTest
    static void testUpdateOpportunitiesStage() {
        // Retrieve test data
        Opportunity opp1 = [SELECT Id, StageName, Match_Found_Previous_Stage__c FROM Opportunity WHERE Name = 'Opportunity Alpha' LIMIT 1];
        Property_SalesAI_Match__c match2 = [SELECT Id, Status__c, Opportunity__c FROM Property_SalesAI_Match__c WHERE Opportunity__c = :opp1.Id LIMIT 1];
        
        // Prepare old map
        Map<Id, Property_SalesAI_Match__c> oldMap = new Map<Id, Property_SalesAI_Match__c>{
            match2.Id => match2
        };
        
        // Update the match status to 'Rejected'
        match2.Status__c = 'Rejected';
        update match2;
        
        // Retrieve updated match
        Property_SalesAI_Match__c updatedMatch = [SELECT Id, Status__c, Opportunity__c FROM Property_SalesAI_Match__c WHERE Id = :match2.Id LIMIT 1];
        
        // Prepare new list
        List<Property_SalesAI_Match__c> newList = new List<Property_SalesAI_Match__c>{ updatedMatch };
        
        // Invoke the handler method
        Test.startTest();
        PropertySalesAIMatchTriggerHandler.updateLeadsAndOppsRollBack(newList, oldMap);
        Test.stopTest();
        
        // Assert that the Opportunity's StageName has been updated
        Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp1.Id LIMIT 1];
        System.assertEquals(
            opp1.Match_Found_Previous_Stage__c,
            updatedOpp.StageName,
            'The Opportunity\'s StageName should be updated to Match_Found_Previous_Stage__c.'
        );
    }
    
    /**
     * Test Case 3: No Status Change from 'Confirmed' to 'Rejected'.
     * Expected Outcome: No updates should occur on Leads or Opportunities.
     */
    @isTest
    static void testNoStatusChange() {
        // Retrieve test data
        Lead lead2 = [SELECT Id, Status, Match_Found_Previous_Status__c FROM Lead WHERE LastName = 'Smith' LIMIT 1];
        Opportunity opp2 = [SELECT Id, StageName, Match_Found_Previous_Stage__c FROM Opportunity WHERE Name = 'Opportunity Beta' LIMIT 1];
        Property_SalesAI_Match__c match3 = [SELECT Id, Status__c, Lead__c FROM Property_SalesAI_Match__c WHERE Lead__c = :lead2.Id LIMIT 1];
        Property_SalesAI_Match__c match4 = [SELECT Id, Status__c, Opportunity__c FROM Property_SalesAI_Match__c WHERE Opportunity__c = :opp2.Id LIMIT 1];
        
        // Prepare old map
        Map<Id, Property_SalesAI_Match__c> oldMap = new Map<Id, Property_SalesAI_Match__c>{
            match3.Id => match3,
            match4.Id => match4
        };
        
        // Update the matches without changing the status
        match3.Status__c = 'Confirmed'; // No change
        match4.Status__c = 'Confirmed'; // No change
        update new List<Property_SalesAI_Match__c>{ match3, match4 };
        
        // Retrieve updated matches
        Property_SalesAI_Match__c updatedMatch3 = [SELECT Id, Status__c, Lead__c FROM Property_SalesAI_Match__c WHERE Id = :match3.Id LIMIT 1];
        Property_SalesAI_Match__c updatedMatch4 = [SELECT Id, Status__c, Opportunity__c FROM Property_SalesAI_Match__c WHERE Id = :match4.Id LIMIT 1];
        
        // Prepare new list
        List<Property_SalesAI_Match__c> newList = new List<Property_SalesAI_Match__c>{ updatedMatch3, updatedMatch4 };
        
        // Invoke the handler method
        Test.startTest();
        PropertySalesAIMatchTriggerHandler.updateLeadsAndOppsRollBack(newList, oldMap);
        Test.stopTest();
        
        // Assert that the Lead's Status remains unchanged
        Lead updatedLead2 = [SELECT Id, Status FROM Lead WHERE Id = :lead2.Id LIMIT 1];
        System.assertEquals(
            lead2.Status,
            updatedLead2.Status,
            'The Lead\'s Status should remain unchanged.'
        );
        
        // Assert that the Opportunity's StageName remains unchanged
        Opportunity updatedOpp2 = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp2.Id LIMIT 1];
        System.assertEquals(
            opp2.StageName,
            updatedOpp2.StageName,
            'The Opportunity\'s StageName should remain unchanged.'
        );
    }
    
    /**
     * Test Case 4: Mixed Scenario - Some Matches Meet Criteria, Others Do Not.
     * Expected Outcome: Only the relevant Leads and Opportunities are updated.
     */
    @isTest
    static void testMixedStatusChanges() {
        // Retrieve test data
        Lead lead1 = [SELECT Id, Status, Match_Found_Previous_Status__c FROM Lead WHERE LastName = 'Doe' LIMIT 1];
        Opportunity opp1 = [SELECT Id, StageName, Match_Found_Previous_Stage__c FROM Opportunity WHERE Name = 'Opportunity Alpha' LIMIT 1];
        Lead lead2 = [SELECT Id, Status, Match_Found_Previous_Status__c FROM Lead WHERE LastName = 'Smith' LIMIT 1];
        Opportunity opp2 = [SELECT Id, StageName, Match_Found_Previous_Stage__c FROM Opportunity WHERE Name = 'Opportunity Beta' LIMIT 1];
        
        // Retrieve matches
        Property_SalesAI_Match__c match1 = [SELECT Id, Status__c, Lead__c FROM Property_SalesAI_Match__c WHERE Lead__c = :lead1.Id LIMIT 1];
        Property_SalesAI_Match__c match2 = [SELECT Id, Status__c, Opportunity__c FROM Property_SalesAI_Match__c WHERE Opportunity__c = :opp1.Id LIMIT 1];
        Property_SalesAI_Match__c match3 = [SELECT Id, Status__c, Lead__c FROM Property_SalesAI_Match__c WHERE Lead__c = :lead2.Id LIMIT 1];
        Property_SalesAI_Match__c match4 = [SELECT Id, Status__c, Opportunity__c FROM Property_SalesAI_Match__c WHERE Opportunity__c = :opp2.Id LIMIT 1];
        
        // Prepare old map
        Map<Id, Property_SalesAI_Match__c> oldMap = new Map<Id, Property_SalesAI_Match__c>{
            match1.Id => match1,
            match2.Id => match2,
            match3.Id => match3,
            match4.Id => match4
        };
        
        // Update some matches to 'Rejected' and others remain 'Confirmed'
        match1.Status__c = 'Rejected'; // Should update lead1
        match2.Status__c = 'Rejected'; // Should update opp1
        // match3 and match4 remain 'Confirmed'
        update new List<Property_SalesAI_Match__c>{ match1, match2 };
        
        // Retrieve updated matches
        Property_SalesAI_Match__c updatedMatch1 = [SELECT Id, Status__c, Lead__c FROM Property_SalesAI_Match__c WHERE Id = :match1.Id LIMIT 1];
        Property_SalesAI_Match__c updatedMatch2 = [SELECT Id, Status__c, Opportunity__c FROM Property_SalesAI_Match__c WHERE Id = :match2.Id LIMIT 1];
        
        // Prepare new list
        List<Property_SalesAI_Match__c> newList = new List<Property_SalesAI_Match__c>{ updatedMatch1, updatedMatch2, match3, match4 };
        
        // Invoke the handler method
        Test.startTest();
        PropertySalesAIMatchTriggerHandler.updateLeadsAndOppsRollBack(newList, oldMap);
        Test.stopTest();
        
        // Assert that lead1 and opp1 are updated
        Lead updatedLead1 = [SELECT Id, Status FROM Lead WHERE Id = :lead1.Id LIMIT 1];
        System.assertEquals(
            lead1.Match_Found_Previous_Status__c,
            updatedLead1.Status,
            'Lead1 Status should be updated to Match_Found_Previous_Status__c.'
        );
        
        Opportunity updatedOpp1 = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp1.Id LIMIT 1];
        System.assertEquals(
            opp1.Match_Found_Previous_Stage__c,
            updatedOpp1.StageName,
            'Opportunity1 StageName should be updated to Match_Found_Previous_Stage__c.'
        );
        
        // Assert that lead2 and opp2 are not updated
        Lead updatedLead2 = [SELECT Id, Status FROM Lead WHERE Id = :lead2.Id LIMIT 1];
        System.assertEquals(
            lead2.Status,
            updatedLead2.Status,
            'Lead2 Status should remain unchanged.'
        );
        
        Opportunity updatedOpp2 = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp2.Id LIMIT 1];
        System.assertEquals(
            opp2.StageName,
            updatedOpp2.StageName,
            'Opportunity2 StageName should remain unchanged.'
        );
    }

    /**
     * Test Case 5: Create a Match Record with Status 'Confirmed'.
     * Expected Outcome: The Match record should be created successfully with the status 'Confirmed'.
     */
    @isTest
    static void testCreateConfirmedMatch() {
        // Retrieve test data
        Lead lead1 = [SELECT Id FROM Lead WHERE LastName = 'Doe' LIMIT 1];
        Property_SalesAI_History__c history = [SELECT Id FROM Property_SalesAI_History__c LIMIT 1];

        // Create a new match record with status 'Confirmed'
        Property_SalesAI_Match__c newMatch = new Property_SalesAI_Match__c(
            Property_SalesAI_History__c = history.Id,
            Status__c = 'Confirmed',
            Type__c = 'Lead Match',
            Lead__c = lead1.Id
        );

        // Insert the new match record
        insert newMatch;

        // Retrieve the inserted match record
        Property_SalesAI_Match__c insertedMatch = [SELECT Id, Status__c FROM Property_SalesAI_Match__c WHERE Id = :newMatch.Id LIMIT 1];
        // Retrieve new task created
        Task task = [SELECT Id, Status FROM Task WHERE WhoId = :newMatch.Lead__c LIMIT 1];
        // Assert that the match record was created with the status 'Confirmed'
        System.assertEquals(
            'Confirmed',
            insertedMatch.Status__c,
            'The Match record should be created with the status \'Confirmed\'.'
        );        
        System.assertEquals(
            'Completed',
            task.Status,
            'The Task should be created with the status Completed .'
        );
    }
}