public with sharing class OpportunityTriggerHandler {

    // Update opportunity record value in before trigger.
    public static void processRecords(List < Opportunity > newRecordList) {

        /* LeftMain_SecurityUtils.checkRead( Opportunity__mdt.SObjectType,new List<String> {
            'DeveloperName',
            'Square_Feet__c',
            'Level_1__c',
            'Level_2__c',
            'Level_3__c',
            'Level_4__c' 
        }); */


        Map < Decimal, Opportunity__mdt > oppMetaDataMap = new Map < Decimal, Opportunity__mdt > ();
        List < Opportunity__mdt > oppMetaDataRecords = [SELECT DeveloperName, Square_Feet__c, Level_1__c, Level_2__c, Level_3__c, Level_4__c FROM Opportunity__mdt WITH USER_MODE ORDER BY Square_Feet__c ASC Limit 50000];
        for (Opportunity__mdt metaDatarecord: oppMetaDataRecords) {
            oppMetaDataMap.put(metaDatarecord.Square_Feet__c, metaDatarecord);
        }

        /*  LeftMain_SecurityUtils.checkUpdate( Opportunity.SObjectType,new List<String> {
             'Rehab_Level__c',
             'Sqft__c',
             'Estimated_Rehab_Costs__c'
         }); */

        //Upate Opportunity fields.
        for (Opportunity record: newRecordList) {
            if (record.Rehab_Level__c != null && record.Sqft__c != null) {
                for (Decimal metadata: oppMetaDataMap.keySet()) {
                    String levelType = '';
                    if (record.Rehab_Level__c.contains('Level 1')) {
                        levelType = 'Level_1__c';
                    } else if (record.Rehab_Level__c.contains('Level 2')) {
                        levelType = 'Level_2__c';
                    } else if (record.Rehab_Level__c.contains('Level 3')) {
                        levelType = 'Level_3__c';
                    } else if (record.Rehab_Level__c.contains('Level 4')) {
                        levelType = 'Level_4__c';
                    }
                    if (record.Sqft__c < 500 && levelType != '') {
                        record.Estimated_Rehab_Costs__c = (Decimal) oppMetaDataMap.get(500.0).get(levelType) * 1.3 * record.Sqft__c;
                        break;
                    } else if (metadata == record.Sqft__c && levelType != '') {
                        record.Estimated_Rehab_Costs__c = (Decimal) oppMetaDataMap.get(metadata).get(levelType) * 1.3 * record.Sqft__c;
                        break;
                    } else if (!(oppMetaDataMap.containsKey(record.Sqft__c)) ) {
                        if (metadata > record.Sqft__c && levelType != '') {
                            record.Estimated_Rehab_Costs__c = (Decimal) oppMetaDataMap.get(metadata).get(levelType) * 1.3 * record.Sqft__c;
                            break;
                        }
                    }
                }
            }
        }
    }
    
}