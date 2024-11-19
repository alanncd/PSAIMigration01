global without sharing class PostInstallScriptCadences implements InstallHandler{

    global void onInstall (InstallContext context)
    {


        List<Task_Follow_Up_Sequence__c> listTasksCadences= [SELECT Id FROM Task_Follow_Up_Sequence__c LIMIT 200 ];
        LeftMain_SecurityUtils.checkRead(Task_Follow_Up_Sequence__c.SObjectType,new List<String> {
            				'Id',
            				'Name',
            				'Task_Subject__c',
            				'Task_Cadence_Folder__c',
                            'Frequency__c',
                            'Number__c'
        				});       


        if(listTasksCadences.isEmpty()){
            List<Task_Follow_Up_Sequence__c> listTasksCadencesNew = new List<Task_Follow_Up_Sequence__c>();

            listTasksCadencesNew.add(new Task_Follow_Up_Sequence__c(Name = 'Uncontacted Lead Task 1', Task_Subject__c = 'Call New Lead!',Task_Cadence_Folder__c='Uncontacted Lead',Frequency__c='Now',Number__c=1));
            listTasksCadencesNew.add(new Task_Follow_Up_Sequence__c(Name = 'Uncontacted Lead Task 2', Task_Subject__c = 'Call New Lead! 1 Hour Old',Task_Cadence_Folder__c='Uncontacted Lead',Frequency__c='Hours',Number__c=1));
            listTasksCadencesNew.add(new Task_Follow_Up_Sequence__c(Name = 'Uncontacted Lead Task 3', Task_Subject__c = 'Call New Lead! 4 Hour Old',Task_Cadence_Folder__c='Uncontacted Lead',Frequency__c='Hours',Number__c=4));
            listTasksCadencesNew.add(new Task_Follow_Up_Sequence__c(Name = 'Uncontacted Lead Task 3', Task_Subject__c = 'Call New Lead! Still Uncontacted Day 2',Task_Cadence_Folder__c='Uncontacted Lead',Frequency__c='Days',Number__c=2));
            listTasksCadencesNew.add(new Task_Follow_Up_Sequence__c(Name = 'Uncontacted Lead Task 3', Task_Subject__c = 'Call New Lead! Still Uncontacted Day 3',Task_Cadence_Folder__c='Uncontacted Lead',Frequency__c='Days',Number__c=3));
            listTasksCadencesNew.add(new Task_Follow_Up_Sequence__c(Name = 'Uncontacted Lead Task 3', Task_Subject__c = 'Call New Lead! Still Uncontacted Day 4',Task_Cadence_Folder__c='Uncontacted Lead',Frequency__c='Days',Number__c=4));

            LeftMain_SecurityUtils.checkInsert(Task_Follow_Up_Sequence__c.SObjectType,new List<String> {
                'Name',
                'Task_Subject__c',
                'Task_Cadence_Folder__c',
                'Frequency__c',
                'Number__c'
            });
            SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, listTasksCadencesNew);
            listTasksCadencesNew = decision3.getRecords();
            Database.insert(listTasksCadencesNew);

            List<PermissionSet> listPermissionSet = [SELECT Id,Name FROM PermissionSet Where name='Left_Main_Cadences_Permission_set'];
            List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
            for (User u : [SELECT ID,UserRole.Name,Profile.Name,IsActive FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true WITH USER_MODE]){
                PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = listPermissionSet[0].Id, AssigneeId = u.Id);
                permissionSetList.add(psa);
            }
            try{
                LeftMain_SecurityUtils.checkInsert(PermissionSetAssignment.SObjectType,new List<String> {
                    'PermissionSetId',
                    'AssigneeId'
                });
                if (Schema.sObjectType.PermissionSetAssignment.isCreateable() && Schema.sObjectType.PermissionSetAssignment.isUpdateable()) {
                    // Ensure that the fields themselves are also creatable and updatable
                    if (Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetId.isCreateable() && 
                        Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetId.isUpdateable() &&
                        Schema.sObjectType.PermissionSetAssignment.fields.AssigneeId.isCreateable() && 
                        Schema.sObjectType.PermissionSetAssignment.fields.AssigneeId.isUpdateable()) {
                
                        SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.CREATABLE, permissionSetList);
                        decision2 = Security.stripInaccessible(AccessType.UPDATABLE, decision2.getRecords());
                        Database.upsert(decision2.getRecords());
                
                    } else {
                        throw new AuraHandledException('You do not have permission to create or update the necessary fields on PermissionSetAssignment.');
                    }
                } else {
                    throw new AuraHandledException('You do not have permission to create or update PermissionSetAssignment records.');
                }
                
                
             

            }catch(exception e){
                system.debug('exception caught' + e);
            }


        }




    }    
}