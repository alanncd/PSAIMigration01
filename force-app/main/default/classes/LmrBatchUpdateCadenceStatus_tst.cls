@isTest
public class LmrBatchUpdateCadenceStatus_tst {

    @testSetup static void setupmethod() {
    	System.debug('setup');
         SObject o = mock('Lead');
        insert o;


        Boolean cadObj1 = doesObjectExist('Cadences__c');
        Boolean cadObj2 = doesObjectExist('Left_Main__Cadences__c');
        String varCadence='Left_Main__Cadences__c';
        if(cadObj1){varCadence='Cadences__c';}
        
        SObject c = mock(varCadence);
        
        Cadences__c cadenceLead = (Cadences__c) c;
		cadenceLead.Lead__c =o.iD;
        //cadenceLead.StopCadences__c = true;
        
        
         SObject opp = mock('Opportunity');
        insert opp;
        cadenceLead.Opportunity__c =opp.iD;

        	
        
        
        insert cadenceLead;
    }

    @istest 
    public static void UpdateLeadsWithCadence(){
    
    
        Test.StartTest();
        LmrBatchUpdateCadenceStatus bch = new LmrBatchUpdateCadenceStatus('Select id , (select id from Cadences__r where Lead__c != Null and StopCadences__c = false order by createdDate desc Limit 1),CreatedDate from Lead order by CreatedDate Desc','Lead','true');
        ID batchprocessid = Database.executeBatch(bch,200);
        Test.StopTest();
        
        Lead findLead = [select id , Has_Cadence__c from Lead Limit 1];
        
        System.assertEquals(true, findLead.Has_Cadence__c);
    
    }
     
    @istest 
    public static void testBathDeleteErrors(){
    
    
        Test.StartTest();
        Lmr_BatchDeleteErrors bch = new Lmr_BatchDeleteErrors('Select id from Lead LIMIT 1');
        ID batchprocessid = Database.executeBatch(bch,200);
        Test.StopTest();
        
        List<Lead> listLeads = [select id from Lead Limit 1];
        
        System.assertEquals(0,listLeads.size());
    }

     @istest 
    public static void UpdateOpportunitiesWithCadence(){
    
    
        Test.StartTest();
        LmrBatchUpdateCadenceStatus bch = new LmrBatchUpdateCadenceStatus('Select id , (select id from Cadences__r where Opportunity__c != Null and StopCadences__c = false order by createdDate desc Limit 1),CreatedDate from Opportunity order by CreatedDate Desc','Opportunity');
        ID batchprocessid = Database.executeBatch(bch,200);
        Test.StopTest();
        
        Opportunity findOpp = [select id , Has_Cadence__c from Opportunity Limit 1];
        
        System.assertEquals(true, findOpp.Has_Cadence__c);
    
    }
        static SObject mock(String sobjectName) {
        SObjectType t = Schema.getGlobalDescribe().get(sobjectName);

        SObject o = t.newSobject();

        Map<String, Schema.SObjectField> m = t.getDescribe().fields.getMap();

        for (String fieldName : m.keySet()) {
            DescribeFieldResult f = m.get(fieldName).getDescribe();
            if (!f.isNillable() && f.isCreateable() && !f.isDefaultedOnCreate()) {
                if (f.getType() == DisplayType.Boolean) {
                    o.put(f.getName(), false);
                }
                else if (f.getType() == DisplayType.Currency) {
                    o.put(f.getName(), 0);
                }
                else if (f.getType() == DisplayType.Date) {
                    o.put(f.getName(), Date.today());
                }
                else if (f.getType() == DisplayType.DateTime) {
                    o.put(f.getName(), System.now());
                }
                else if (f.getType() == DisplayType.Double) {
                    o.put(f.getName(), 0.0);
                }
                else if (f.getType() == DisplayType.Email) {
                    o.put(f.getName(), 'foo@foo.com');
                }
                else if (f.getType() == DisplayType.Integer) {
                    o.put(f.getName(), 0);
                }
                else if (f.getType() == DisplayType.Percent) {
                    o.put(f.getName(), 0);
                }
                else if (f.getType() == DisplayType.Phone) {
                    o.put(f.getName(), '555-555-1212');
                }
                else if (f.getType() == DisplayType.String) {
                    o.put(f.getName(), 'TEST');
                }
                else if (f.getType() == DisplayType.TextArea) {
                    o.put(f.getName(), 'TEST');
                }
                else if (f.getType() == DisplayType.Time) {
                    o.put(f.getName(), System.now().time());
                }
                else if (f.getType() == DisplayType.URL) {
                    o.put(f.getName(), 'http://foo.com');
                }
                else if (f.getType() == DisplayType.PickList) {
                    o.put(f.getName(), f.getPicklistValues()[0].getValue());
                }
            }
        }
        return o;
    }
    
    public static Boolean doesObjectExist(String objectApiName) {
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        return globalDescribe.containsKey(objectApiName);
    }
    
}