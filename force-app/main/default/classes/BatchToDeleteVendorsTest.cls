/* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : test class for BatchToDeleteVendors
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           : Tushar Sharma <>
* @modifiedBy       : Tushar Sharma <>
* @modifiedy        : Tushar Sharma <>
* @maintainedBy     : Tushar Sharma <>
* @version          : 1.0
* @created          : 
* @modified         : --
* @systemLayer      :
* @see              : ????
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest(SeeAllData=false)
public with sharing class BatchToDeleteVendorsTest{
    public static String cronEXP = '0 0 0 28 2 ? 2022';
    // Create Test Data
    @testSetup
    public static void dataFactory(){
        Vendor__c vndrObj = new Vendor__c();
        vndrObj.name = 'test';
        insert vndrObj;
    }
    public static testmethod void test(){
        test.startTest();
        Vendor__c v = [Select Id FROM Vendor__c Limit 1];
        System.assertNotEquals(null, v,'No Data');
        BatchToDeleteVendors b = new BatchToDeleteVendors(); 
        database.executebatch(b,200);
        test.stopTest();

    }
    // Schedule the test job
    static testmethod void testScheduledJob() {
        Test.startTest();
        try{
        String jobId = System.schedule('delete vendors',cronEXP,new BatchToDeleteVendors());
            System.assertNotEquals(null, jobId,'Batch Not Schedule');}catch(exception e){
                System.debug('test');
            }
        Test.stopTest();
    }
    
}