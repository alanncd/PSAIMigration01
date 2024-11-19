public with sharing class LeftMain_SecurityUtils { 
    @testVisible 
    private Enum OperationType { CREATE, READ, MODIFY, DEL } //UPDATE and DELETE are reserved words

    public virtual class SecurityException extends Exception {
        protected OperationType m_operation;
        protected Schema.SObjectType m_objectType;
    }
    
    // for check crudException
    public class CrudException extends SecurityException{
        @TestVisible
        private CrudException(OperationType operation, Schema.SObjectType objectType){
            this.m_operation = operation;
            this.m_objectType = objectType;
            if(operation == OperationType.CREATE)                
                this.setMessage('Security error, ' + objectType.getDescribe().getLabel() + ' not insertable.');
            else if(operation == OperationType.READ)                
                this.setMessage('Security error, ' + objectType.getDescribe().getLabel() + ' not readable.');
            else if(operation == OperationType.MODIFY)                
                this.setMessage('Security error, ' + objectType.getDescribe().getLabel() + ' not updateable.');
            else if(operation == OperationType.DEL)                
                this.setMessage('Security error, ' + objectType.getDescribe().getLabel() + ' not deletable.');

            this.setMessage(
                String.format(
                    this.getMessage(),
                    new List<String>{
                        objectType.getDescribe().getName()
                    } 
                )
            );
        }
    }
    
    //Check field level security.
    public class FlsException extends SecurityException{
        private Schema.SObjectField m_fieldToken;

        //Check field level security
        @TestVisible
        private FlsException(OperationType operation, Schema.SObjectType objectType, Schema.SObjectField fieldToken){
            this.m_operation = operation;
            this.m_objectType = objectType;
            this.m_fieldToken = fieldToken;
            if(operation == OperationType.CREATE)
                this.setMessage('Security error, ' + fieldToken.getDescribe().getLabel() + ' on ' + objectType.getDescribe().getLabel() + ' not insertable.');
            else if(operation == OperationType.READ)
                this.setMessage('Security error, ' + fieldToken.getDescribe().getLabel() + ' on ' + objectType.getDescribe().getLabel() + ' not readable.');
            else if(operation == OperationType.MODIFY)
                this.setMessage('Security error, ' + fieldToken.getDescribe().getLabel() + ' on ' + objectType.getDescribe().getLabel() + ' not updateable.');

            this.setMessage(
                String.format(
                    this.getMessage(),
                    new List<String>{
                        objectType.getDescribe().getName(),
                        fieldToken.getDescribe().getName()
                    }
                )
            );
        }
    }
    // Marking this boolean true because we are disabling FLS for this package 1.15 Unmark this when you need FLS for Security Review.
    public static boolean BYPASS_INTERNAL_FLS_AND_CRUD = FALSE;  

    public static void bypassFLSForSpeceficProfile(){
        if(!BYPASS_INTERNAL_FLS_AND_CRUD){
            List<Bypass_FLS_Setting__mdt> BypassList =[SELECT Id,MasterLabel,Profile_Name__c 
                                                       FROM Bypass_FLS_Setting__mdt WHERE Profile_Name__c != null WITH USER_MODE LIMIT 10000];
            if(!BypassList.isEmpty()){
                Id userProfileId = userinfo.getProfileId();
                String profileName = '';
                List<Profile> profileList = [SELECT Id,Name FROM Profile WHERE Id=:userProfileId WITH USER_MODE LIMIT 1];
                if(!profileList.isEmpty()){
                    profileName = profileList[0].Name;
                }
                Set<String> profileNameSet = new Set<String>();
                for(Bypass_FLS_Setting__mdt BypassMDTObj :  BypassList){
                    profileNameSet.add(BypassMDTObj.Profile_Name__c);
                }
                if(String.isNotBlank(profileName) && !profileNameSet.isEmpty() && profileNameSet.contains(profileName)){
                    BYPASS_INTERNAL_FLS_AND_CRUD = true;
                }
            }
        }
    }
    
    //Check fields and object is creatable or not.
    public static void checkInsert(SObjectType objType, List<String> fieldNames)
    {
        checkObjectIsInsertable(objType);
        for (String fieldName : fieldNames)
        {
            checkFieldIsInsertable(objType, fieldName);
        }
    }
   
    //Check fields and object is readable or not.
    public static void checkRead(SObjectType objType, List<String> fieldNames)
    {
        if(fieldNames != null && !fieldNames.contains('Id')){
            fieldNames.add('Id');
        }
        checkObjectIsReadable(objType);
        for (String fieldName : fieldNames)
        {
            checkFieldIsReadable(objType, fieldName);
        }
    }
    
    //Check fields and object is updateable or not.
    public static void checkUpdate(SObjectType objType, List<String> fieldNames)
    {
        checkObjectIsUpdateable(objType);
        for (String fieldName : fieldNames)
        {
            checkFieldIsUpdateable(objType, fieldName);
        }
    }

    //Check fields are creatable or not.
    public static void checkFieldIsInsertable(SObjectType objType, String fieldName)
    {
        checkFieldIsInsertable(objType, LeftMain_SObjectDescribe.getDescribe(objType).getField(fieldName));
    }

    //Check fields are creatable or not.
    public static void checkFieldIsInsertable(SObjectType objType, SObjectField fieldToken)
    {
        checkFieldIsInsertable(objType, fieldToken.getDescribe());
    }

    //Check fields are creatable or not.
    public static void checkFieldIsInsertable(SObjectType objType, DescribeFieldResult fieldDescribe)
    {
        bypassFLSForSpeceficProfile();

        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!fieldDescribe.isCreateable())
            throw new FlsException(OperationType.CREATE, objType, fieldDescribe.getSObjectField());
    }
 
    //Check fields are Readable or not.
    public static void checkFieldIsReadable(SObjectType objType, String fieldName)
    {
        checkFieldIsReadable(objType, LeftMain_SObjectDescribe.getDescribe(objType).getField(fieldName));
    }

    //Check fields are Readable or not.
    public static void checkFieldIsReadable(SObjectType objType, SObjectField fieldToken)
    {
        checkFieldIsReadable(objType, fieldToken.getDescribe());
    }

    //Check fields are Readable or not.
    public static void checkFieldIsReadable(SObjectType objType, DescribeFieldResult fieldDescribe)
    {
        bypassFLSForSpeceficProfile();

        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!fieldDescribe.isAccessible())
            throw new FlsException(OperationType.READ, objType, fieldDescribe.getSObjectField());
    }
    
    public static void checkFieldIsUpdateable(SObjectType objType, String fieldName)
    {
        checkFieldIsUpdateable(objType, LeftMain_SObjectDescribe.getDescribe(objType).getField(fieldName));
    }

    public static void checkFieldIsUpdateable(SObjectType objType, SObjectField fieldToken)
    {
        checkFieldIsUpdateable(objType, fieldToken.getDescribe());
    }

    public static void checkFieldIsUpdateable(SObjectType objType, DescribeFieldResult fieldDescribe)
    {
        bypassFLSForSpeceficProfile();

        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!fieldDescribe.isUpdateable())
            throw new FlsException(OperationType.MODIFY, objType, fieldDescribe.getSObjectField());
    }

    public static void checkObjectIsInsertable(SObjectType objType)
    {
        bypassFLSForSpeceficProfile();

        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!objType.getDescribe().isCreateable())
        {
            throw new CrudException(OperationType.CREATE, objType); 
        }
    }

    public static Boolean checkObjectIsInsertableNoException(SObjectType objType)
    {
        bypassFLSForSpeceficProfile();

        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return true;

        if (objType.getDescribe().isCreateable()) {
           return true;
        }else {
            return false;
        }
    }
    
    public static void checkObjectIsReadable(SObjectType objType)
    {
        bypassFLSForSpeceficProfile();

        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!objType.getDescribe().isAccessible())
            throw new CrudException(OperationType.READ, objType);
    }

    public static void checkObjectIsUpdateable(SObjectType objType)
    {
        bypassFLSForSpeceficProfile();

        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!objType.getDescribe().isUpdateable())
            throw new CrudException(OperationType.MODIFY, objType);
    }

    public static void checkObjectIsDeletable(SObjectType objType)
    {
        bypassFLSForSpeceficProfile();

        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!objType.getDescribe().isDeletable())
            throw new CrudException(OperationType.DEL, objType);
    }
    
    public static void checkStrpiAccessUpdate(List<sObject> obj){
        if (BYPASS_INTERNAL_FLS_AND_CRUD){
                try{
                List<Database.SaveResult> myResult = Database.update(obj, false);
                }Catch(Exception e){
                    System.debug('error: '+e);
                }
        }
        else{
        		SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, obj);
        		update decision.getRecords(); 
            }
    }
}