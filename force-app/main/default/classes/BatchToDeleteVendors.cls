/* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Use to delete old vendor records from salesforce  
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
global with sharing class BatchToDeleteVendors implements Database.Batchable<sobject>,DataBase.stateful, Schedulable{
    global Database.QueryLocator start(Database.BatchableContext BC){
        String qbName = 'QuickBooks Config';
        if(Test.isRunningTest())
            qbName = 'QuickBooks Config Demo';
        
        LeftMain_SecurityUtils.checkRead(QuickBooks_Config__mdt.SObjectType,new List<String> {
            'Days_To_Delete_vendors__c',
            'Label'
        });

        QuickBooks_Config__mdt QuickBooksMTDT = [select Days_To_Delete_vendors__c from QuickBooks_Config__mdt where Label=: qbName];
        dateTime dt = System.now();   
        dateTime newDateTime = dt.addDays(integer.valueof('-'+QuickBooksMTDT.Days_To_Delete_vendors__c));
        if(test.isRunningTest()){
            newDateTime = System.now(); 
        }

        LeftMain_SecurityUtils.checkRead( Vendor__c.SObjectType,new List<String> {
            'Id',
            'CreatedDate'
        });
        return Database.getQueryLocator('SELECT id FROM Vendor__c where CreatedDate <:newDateTime  LIMIT 5000000');
    }
    global void execute(Database.BatchableContext BC,List<Vendor__c> UservendorList){
        // Delete Vendor__C records whose created date in less than the date which we store in metadata.
        LeftMain_SecurityUtils.checkObjectIsDeletable(  UservendorList.getSObjectType());
        if(Schema.sObjectType.Vendor__c.isDeletable()){
            delete UservendorList;
        }
    }
    global void finish(Database.BatchableContext BC ){
    }
    global void execute(SchedulableContext ctx) {
        BatchToDeleteVendors b = new BatchToDeleteVendors(); 
        database.executebatch(b,200);
    }
}