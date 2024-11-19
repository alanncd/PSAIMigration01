/******************************************************************
 * Name: Batch_FollowupTaskForTrasaction
 * Description: This batch will help to create followup task for transaction.
 * Change History:
 * Version    Date of Change    Author Name        Description
 * -------    --------------    -----------        -----------
 * 1.0        19-March-2020     Briskminds     Original version
 *******************************************************************/

global with sharing class Batch_FollowupTaskForTrasaction implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Set<String> skipPathName = new Set<String>();
        skipPathName.add('Closed/Won');
        skipPathName.add('Contract Cancelled/Lost');

        LeftMain_SecurityUtils.checkRead( Transactions__c.SObjectType,new List<String> 
                {
                'Id',
                'OwnerId',
                'Path__c'
                });
        String query = 'SELECT Id, OwnerId FROM Transactions__c WHERE Path__c NOT IN: skipPathName LIMIT 5000000';
        return Database.getQueryLocator(query);           
    }
    
    global void execute(Database.BatchableContext BC, List<Transactions__c> scopeTransaction ) {
        LeftMain_SecurityUtils.checkRead( Transaction_Follow_up_task__mdt.SObjectType,new List<String> 
                {
                'isActive__c',
                'Skip_buyers_task__c',
                'Skip_homeowner_task__c',
                'DeveloperName',
                'Subject_for_Homeowner__c',
                'Subject_for_Buyer__c'
                });
                
        List<Task> taskToCreateList = new List<Task>();
        Transaction_Follow_up_task__mdt followUpmetadata = [SELECT
                                                                                isActive__c,
                                                                                Skip_buyers_task__c,
                                                                                Skip_homeowner_task__c,
                                                                                Subject_for_Buyer__c,
                                                                                Subject_for_Homeowner__c
                                                                        FROM
                                                                                Transaction_Follow_up_task__mdt 
                                                                        WHERE
                                                                                DeveloperName = 'Transaction_Follow_up_task'  LIMIT 1 
                                                                              
                                                                        ];
        if( followUpmetadata != NULL && followUpmetadata.isActive__c ){
            for( Transactions__c trac : scopeTransaction ){
                // Task for Follow up with Homeowner
                if( ! followUpmetadata.Skip_homeowner_task__c  ){
                    Task homeownerTask = new Task();
                    homeownerTask.OwnerId = trac.OwnerId;
                    homeownerTask.Subject = followUpmetadata.Subject_for_Homeowner__c;
                    homeownerTask.WhatId = trac.Id;
                    homeownerTask.ActivityDate = System.today() + 7;
                    homeownerTask.Status = 'Not Started';
                    homeownerTask.Priority = 'Normal';
                    taskToCreateList.add(homeownerTask);
                }
                
                // Task for Follow up with buyer
                if( ! followUpmetadata.Skip_buyers_task__c ){
                    Task buyerTask = new Task();
                    buyerTask.OwnerId = trac.OwnerId;
                    buyerTask.Subject = followUpmetadata.Subject_for_Buyer__c;
                    buyerTask.WhatId = trac.Id;
                    buyerTask.ActivityDate = System.today() + 7;
                    buyerTask.Status = 'Not Started';
                    buyerTask.Priority = 'Normal';
                    taskToCreateList.add(buyerTask);
                }
            }
        }
        try {
            LeftMain_SecurityUtils.checkInsert(Task.SObjectType,new List<String> {
                'OwnerId',
                'Subject',
                'WhatId',
                'ActivityDate',
                'Status',
                'Priority'
            });
            
            SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, taskToCreateList);
            taskToCreateList = decision3.getRecords();
            Database.insert(taskToCreateList);
        }
        catch (exception ex){
            System.debug(' >> ex.getMessage() >> '+ex.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {
      
    }
    
    global void execute(SchedulableContext sc) {
         Batch_FollowupTaskForTrasaction batch = new Batch_FollowupTaskForTrasaction();
         Database.executeBatch(batch,200);
    }
}