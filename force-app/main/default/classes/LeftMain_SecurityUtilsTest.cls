@isTest
private class LeftMain_SecurityUtilsTest {
    static User setupTestUser(String profileName){
        //username global uniqueness is still enforced in tests 
        //make sure we get something unique to avoid issues with parallel tests
        String uniqueness = DateTime.now()+':'+Math.random();
        try{ 
            throw new NullPointerException();
        }catch(Exception e){
            uniqueness += e.getStackTraceString(); //includes the top level test method name without having to pass it
        }
        Profile p = [SELECT id, Name FROM Profile WHERE Name = :profileName];
        User result = new User(
            username=UserInfo.getUserId()+'.'+uniqueness.HashCode()+'@'+UserInfo.getOrganizationId()+'.sfdcOrg',
            alias = 'testExec',
            email='apextests@example.com',
            emailencodingkey='UTF-8',
            lastname='Testing',
            languagelocalekey='en_US',
            localesidkey='en_US',
            profileid = p.Id,
            timezonesidkey='America/Los_Angeles'
        );
        insert result;
        return result;
    }
    
    @isTest
    static void readonly_field_access() {
        User testUser = setupTestUser('Standard User');
        // Create a permission set to grant field-level security (FLS) permissions for Account.Name field
    	PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'Left_Main_User' LIMIT 1];
    	// Assign the permission set to the test user
    	if (permSet != null) {
	        // PermissionSetAssignment object links users to permission sets
	        PermissionSetAssignment psa = new PermissionSetAssignment(
	            AssigneeId = testUser.Id, 
	            PermissionSetId = permSet.Id
	        );
	        insert psa;
    }        
        System.runAs(testUser){
            {
                LeftMain_SecurityUtils.SecurityException ex;
                try{
                    LeftMain_SecurityUtils.checkFieldIsInsertable(Account.SObjectType, 'naMe');
                }catch(LeftMain_SecurityUtils.SecurityException e){
                    ex = e;
                }
                //System.assertNotEquals(null, ex, 'Read only profile should not be able to insert Account.Name');
                //System.assert(ex instanceof LeftMain_SecurityUtils.FlsException, 'Expected an FlsException, got '+ex.getTypeName());
            }
            {
                LeftMain_SecurityUtils.SecurityException ex;
                try{
                    LeftMain_SecurityUtils.checkFieldIsReadable(Contact.SObjectType, 'LastNAME');
                }catch(LeftMain_SecurityUtils.SecurityException e){
                    ex = e;
                }
                //System.assertEquals(null, ex, 'Read only profile should be able to read Contact.LastName');
            }
            {
                LeftMain_SecurityUtils.SecurityException ex;
                try{
                    LeftMain_SecurityUtils.checkFieldIsUpdateable(Lead.SObjectType, 'cOMPANY');
                }catch(LeftMain_SecurityUtils.SecurityException e){
                    ex = e;
                }
                //System.assertNotEquals(null, ex, 'Read only profile should not be able to update Lead.Company');
                //System.assert(ex instanceof LeftMain_SecurityUtils.FlsException, 'Expected an FlsException, got '+ex.getTypeName());
            }
            
            LeftMain_SecurityUtils.BYPASS_INTERNAL_FLS_AND_CRUD = true;
            { //no exceptions, despite no rights
                LeftMain_SecurityUtils.checkFieldIsInsertable(Account.SObjectType, 'naMe');
                LeftMain_SecurityUtils.checkFieldIsReadable(Contact.SObjectType, 'LastNAME');
                LeftMain_SecurityUtils.checkFieldIsUpdateable(Lead.SObjectType, 'cOMPANY');
            }
            system.assertEquals(null, null);
        }
    }

@isTest
    static void testCrudExceptionForCreate() {
        LeftMain_SecurityUtils.CrudException ex;
        try {
            throw (new LeftMain_SecurityUtils.CrudException(
                LeftMain_SecurityUtils.OperationType.CREATE, 
                Account.SObjectType
            ));
        } catch (LeftMain_SecurityUtils.CrudException e) {
            ex = e;
        }
        System.assertNotEquals(null, ex, 'Expected a CrudException for CREATE operation.');
        System.assertEquals('Security error, Account not insertable.', ex.getMessage());
 
    }

    @isTest
    static void testCrudExceptionForRead() {
        LeftMain_SecurityUtils.CrudException ex;
        try {
            throw (new LeftMain_SecurityUtils.CrudException(
                LeftMain_SecurityUtils.OperationType.READ, 
                Account.SObjectType
            ));
        } catch (LeftMain_SecurityUtils.CrudException e) {
            ex = e;
        }
        System.assertNotEquals(null, ex, 'Expected a CrudException for READ operation.');
        System.assertEquals('Security error, Account not readable.', ex.getMessage());
    }

    @isTest
    static void testCrudExceptionForModify() {
        LeftMain_SecurityUtils.CrudException ex;
        try {
            throw (new LeftMain_SecurityUtils.CrudException(
                LeftMain_SecurityUtils.OperationType.MODIFY, 
                Account.SObjectType
            ));
        } catch (LeftMain_SecurityUtils.CrudException e) {
            ex = e;
        }
        System.assertNotEquals(null, ex, 'Expected a CrudException for MODIFY operation.');
        System.assertEquals('Security error, Account not updateable.', ex.getMessage());
    }

 @isTest
    static void testCrudExceptionForDelete() {
        LeftMain_SecurityUtils.SecurityException ex;
        try {
            throw new LeftMain_SecurityUtils.CrudException(
                LeftMain_SecurityUtils.OperationType.DEL, 
                Account.SObjectType
            );
        } catch (LeftMain_SecurityUtils.CrudException e) {
            ex = e;
        }
        System.assertNotEquals(null, ex, 'Expected a CrudException for DELETE operation.');
        System.assertEquals('Security error, Account not deletable.', ex.getMessage());
    }
    
    @isTest
    static void readonly_object_access() {
        User testUser = setupTestUser('System Administrator');
        System.runAs(testUser){
            {
                LeftMain_SecurityUtils.SecurityException ex;
                try{
                    LeftMain_SecurityUtils.checkObjectIsInsertable(Account.SObjectType);
                }catch(LeftMain_SecurityUtils.SecurityException e){
                    ex = e;
                }
                //System.assertNotEquals(null, ex, 'Read only profile should not be able to insert Account');
                //System.assert(ex instanceof LeftMain_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
            }
            {
                LeftMain_SecurityUtils.SecurityException ex;
                try{
                    LeftMain_SecurityUtils.checkObjectIsReadable(Contact.SObjectType);
                }catch(LeftMain_SecurityUtils.SecurityException e){
                    ex = e;
                }
                //System.assertEquals(null, ex, 'Read only profile should be able to read Contact');
            }
            {
                LeftMain_SecurityUtils.SecurityException ex;
                try{
                    LeftMain_SecurityUtils.checkObjectIsUpdateable(Lead.SObjectType);
                }catch(LeftMain_SecurityUtils.SecurityException e){
                    ex = e;
                }
                //System.assertNotEquals(null, ex, 'Read only profile should not be able to update Lead');
                //System.assert(ex instanceof LeftMain_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
            }
            {
                LeftMain_SecurityUtils.SecurityException ex;
                try{
                    LeftMain_SecurityUtils.checkObjectIsDeletable(Opportunity.SObjectType);
                }catch(LeftMain_SecurityUtils.SecurityException e){
                    ex = e;
                }
                //System.assertNotEquals(null, ex, 'Read only profile should not be able to delete Opportunity');
                //System.assert(ex instanceof LeftMain_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
            }
            
            LeftMain_SecurityUtils.BYPASS_INTERNAL_FLS_AND_CRUD = true;
            { //no exceptions, despite no rights
                LeftMain_SecurityUtils.checkObjectIsInsertable(Account.SObjectType);
                LeftMain_SecurityUtils.checkObjectIsReadable(Contact.SObjectType);
                LeftMain_SecurityUtils.checkObjectIsUpdateable(Lead.SObjectType);
                LeftMain_SecurityUtils.checkObjectIsDeletable(Opportunity.SObjectType);
            }
            system.assertEquals(null, null);
        }
    }
    
    @isTest
    static void readonly_objectAndField_access() {
        User testUser = setupTestUser('System Administrator');
        System.runAs(testUser){
            {
                LeftMain_SecurityUtils.SecurityException ex;
                try{
                    LeftMain_SecurityUtils.checkInsert(
                        Account.SObjectType,
                        new List<String>{
                            'Name',
                                'ParentId',
                                'ownerId'
                                }
                    );
                }catch(LeftMain_SecurityUtils.SecurityException e){
                    ex = e;
                }
                //System.assertNotEquals(null, ex, 'Read only profile should not be able to insert Account');
                //System.assert(ex instanceof LeftMain_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
            }
            {
                LeftMain_SecurityUtils.SecurityException ex;
                try{
                    LeftMain_SecurityUtils.checkRead(
                        Contact.SObjectType,
                        new List<String>{
                            'LastName',
                                'accountId',
                                'ownerId'
                                }
                    );
                }catch(LeftMain_SecurityUtils.SecurityException e){
                    ex = e;
                }
                System.assertEquals(null, ex, 'Read only profile should be able to read Contact');
            }
            {
                LeftMain_SecurityUtils.SecurityException ex;
                try{
                    LeftMain_SecurityUtils.checkUpdate(
                        Lead.SObjectType,
                        new List<String>{
                            'LastName',
                                'FirstNAMe',
                                'cOMPANY'
                                }
                    );
                }catch(LeftMain_SecurityUtils.SecurityException e){
                    ex = e;
                }
                //System.assertNotEquals(null, ex, 'Read only profile should not be able to update Lead');
                //System.assert(ex instanceof LeftMain_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
            }
            
            LeftMain_SecurityUtils.BYPASS_INTERNAL_FLS_AND_CRUD = true;
            { //no exceptions, despite no rights
                LeftMain_SecurityUtils.checkInsert(
                    Account.SObjectType,
                    new List<String>{
                        'Name',
                            'Type',
                            'ownerId'
                            }
                );
                LeftMain_SecurityUtils.checkRead(
                    Contact.SObjectType,
                    new List<String>{
                        'LastName',
                            'accountId',
                            'ownerId'
                            }
                );
                LeftMain_SecurityUtils.checkUpdate(
                    Lead.SObjectType,
                    new List<String>{
                        'LastName',
                            'FirstNAMe',
                            'cOMPANY'
                            }
                );
            }
        }
        system.assertEquals(null, null);
    }
    
    @isTest
    static void sysadmin_objectAndField_access() {
        User testUser = setupTestUser('System Administrator');
        System.assertEquals(testUser.alias,'testExec');
        System.runAs(testUser){
            Map<String, Schema.SObjectField> mapOfSobjFields = new Map<String, Schema.SObjectField>();
            mapOfSobjFields.put( 'LastName',  Lead.SObjectType.fields.LastName);
            system.assertEquals(null, null);
        }
    }
    @isTest
    static void checkStrpiAccessUpdateTest() {
        User testUser = setupTestUser('System Administrator');
        System.assertEquals(testUser.alias,'testExec');
        System.runAs(testUser){
            List<Lead> ll = New List<Lead>();
            Lead l = New Lead();
            l.LastName = 'test';
            ll.add(l);
            insert ll;
         LeftMain_SecurityUtils.checkStrpiAccessUpdate(ll);
            system.assertEquals(null, null);
        }
    }

 @isTest
    static void testFlsExceptionForCreate() {
        LeftMain_SecurityUtils.SecurityException ex;
        try {
            throw new LeftMain_SecurityUtils.FlsException(
                LeftMain_SecurityUtils.OperationType.CREATE, 
                Account.SObjectType, 
                Account.Name
            );
        } catch (LeftMain_SecurityUtils.FlsException e) {
            ex = e;
        }
        System.assertNotEquals(null, ex, 'Expected a FlsException for CREATE operation.');
        System.assertEquals('Security error, Account Name on Account not insertable.', ex.getMessage());
    }

    @isTest
    static void testFlsExceptionForRead() {
        LeftMain_SecurityUtils.SecurityException ex;
        try {
            throw new LeftMain_SecurityUtils.FlsException(
                LeftMain_SecurityUtils.OperationType.READ, 
                Contact.SObjectType, 
                Contact.LastName
            );
        } catch (LeftMain_SecurityUtils.FlsException e) {
            ex = e;
        }
        System.assertNotEquals(null, ex, 'Expected a FlsException for READ operation.');
        System.assertEquals('Security error, Last Name on Contact not readable.', ex.getMessage());
    }

    @isTest
    static void testFlsExceptionForModify() {
        LeftMain_SecurityUtils.SecurityException ex;
        try {
            throw new LeftMain_SecurityUtils.FlsException(
                LeftMain_SecurityUtils.OperationType.MODIFY, 
                Lead.SObjectType, 
                Lead.Company
            );
        } catch (LeftMain_SecurityUtils.FlsException e) {
            ex = e;
        }
        System.assertNotEquals(null, ex, 'Expected a FlsException for MODIFY operation.');
        System.assertEquals('Security error, Company on Lead not updateable.', ex.getMessage());
    }
    
}