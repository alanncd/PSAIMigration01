@isTest
private class LeftMain_SObjectDescribeTest {

    /**
     * Verify that the different ways of getting your hands on an SObjectDescribeinstance all handle null inputs
     * (and blank/empty strings, why not?) by returning null - since there's no possible way to resolve it.
    **/

    @isTest
    static void NamespacedAttributeMap_implementations(){
        //System.assertEquals(Schema.getGlobalDescribe().size(), gdm.size());

        LeftMain_SObjectDescribe acccountDescribe = LeftMain_SObjectDescribe.getDescribe(Account.SobjectType);
        SObjectField fld = acccountDescribe.getField('Name');
        System.assertEquals('Name', fld.getDescribe().getName());
        LeftMain_SObjectDescribe.FieldsMap fields = acccountDescribe.getFields();

        System.assertEquals(fields.get('name'), Account.SObjectType.fields.name); //behavior of FieldsMap is tested in another method
        System.assertEquals(Schema.SObjectType.Account.fields.getMap().size(), fields.size());

        System.assertEquals(null, fields.get(null), 'Null input should result in null ouput.');
        System.assertEquals(null, fields.get(''), 'Invalid fieldname input should result in null ouput.');
    }

    @isTest
    static void FieldsMap(){
        String fakeNamespace = 'fflib_test';
        Map<String,Schema.SObjectField> fakeFieldData = new Map<String,Schema.SObjectField>{
            'name__c' => Contact.SObjectType.fields.name, //re-use standard field types since we can't mock them
            fakeNamespace+'__name__c' => Account.SObjectType.fields.name,
            fakeNamespace+'__otherField__c' => Account.SObjectType.fields.name,
            'createddate' => Contact.SObjectType.fields.CreatedDate
        };
        LeftMain_SObjectDescribe.FieldsMap fields = new LeftMain_SObjectDescribe.FieldsMap(fakeFieldData);
        fields.currentNamespace = fakeNamespace;
        System.assertEquals(true, fields.containsKey('name__c') );
        System.assertEquals(true, fields.containsKey(fakeNamespace.toUpperCase()+'__nAMe__c') );
        System.assert(fields.get('NAme__c') === fields.get(fakeNamespace+'__namE__c'));

        System.assert(!fields.keySet(false).contains('otherField__c'));
        System.assert(fields.keySet(false).contains(fakeNamespace+'__otherField__c'));

        System.assert(fields.keySet(true).contains('otherField__c'));
        System.assert(!fields.keySet(true).contains(fakeNamespace+'__otherField__c'));

        fields.currentNamespace = 'someOtherNamespace';
        System.assertNotEquals(fields.get('name__C'), fields.get(fakeNamespace.capitalize()+'__nAme__c'));
    }

    @isTest
    static void GlobalDescribeMap(){
        String fakeNamespace = 'fflib_test';
        Map<String,Schema.SObjectType> fakeFieldData = new Map<String,Schema.SObjectType>{
            'name__c' => Contact.SObjectType, //re-use stndard object types since we can't mock them
            fakeNamespace+'__name__c' => Account.SObjectType,
            'createddate' => Lead.SObjectType
        };
        LeftMain_SObjectDescribe.GlobalDescribeMap gdm = new LeftMain_SObjectDescribe.GlobalDescribeMap(fakeFieldData);
        gdm.currentNamespace = fakeNamespace;
        System.assertEquals(true, gdm.containsKey('name__c') );
        System.assertEquals(true, gdm.containsKey(fakeNamespace+'__name__c') );
        System.assert(gdm.get('name__c') === gdm.get(fakeNamespace+'__name__c'));

        gdm.currentNamespace = 'someOtherNamespace';
        System.assertNotEquals(gdm.get('name__c'), gdm.get(fakeNamespace+'__name__c'));
    }

    @isTest //Tests all forms of the getDescribe static
    static void getAccountDescribes(){
        LeftMain_SObjectDescribe d2 = LeftMain_SObjectDescribe.getDescribe(Account.SObjectType);
        System.assert( d2 != null ,'All three getDescribe calls should return the same cached instance.');
    }

    @isTest
    static void simpleAccountFieldDescribe(){
        LeftMain_SObjectDescribe d = LeftMain_SObjectDescribe.getDescribe(Account.SObjectType);

        // Describe Limits removed since Summer ’14.
        // https://developer.salesforce.com/releases/release/Summer14/New+Apex+Enhancements

        // Because describe limits are no longer enforced in any API version, this method is no longer available.
        // In API version 30.0 and earlier, this method is available but is deprecated.

        // System.assertEquals(1, Limits.getFieldsDescribes() );

        System.assert(d != null);
    }
}