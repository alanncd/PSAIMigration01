/**
 * @description         : Test Class generator Utilities
 * @Fernando Fernandez  : fernandofernandez@leftmainrei.com
 * @group               : 
 * @last modified on    : 01-02-2022
 * @last modified by    : fernandofernandez@leftmainrei.com
 * Modifications Log 
 * Ver   Date         Author                              Modification
 * 1.0   01-02-2022   fernandofernandez@leftmainrei.com   Initial Version
**/
@isTest
public class DataGeneratorLMR_tst {
    
	public static User getUser(Boolean doInsert, Map<Schema.SObjectField, Object> mapFields) {
		//default fields
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User obj = new User();
		obj.LastName = 'User';
		obj.Username = 'fernando@instance.nice';
		obj.Alias = 'fer';
		obj.CommunityNickname = 'RandomUser';
		obj.TimeZoneSidKey = 'America/New_York';
		obj.LocaleSidKey = 'en_US';
		obj.Email = 'user@test.com';
		obj.EmailEncodingKey = 'ISO-8859-1';
		obj.ProfileId = p.id;
		obj.LanguageLocaleKey = 'en_US';
		for (Schema.SObjectField sfield : mapFields.keySet()) {
			obj.put(sfield, mapFields.get(sfield));
		}
		//Insert object
		if (doInsert) {
			insert obj;
		}
		return obj;
	}
}