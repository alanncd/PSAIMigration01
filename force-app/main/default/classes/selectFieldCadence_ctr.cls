public with sharing class selectFieldCadence_ctr {
    public selectFieldCadence_ctr() {

    }
    @AuraEnabled(cacheable=true)
    public static List<customValueWrapper> getFields(String myobject){ 
        try {
            //String myobject = 'Lead';
            List<customValueWrapper> customObjWrapper = new list < customValueWrapper > ();
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(myobject);
			Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe().fields.getMap();
    		for (Schema.SObjectField field : fieldMap.values()) {
                customValueWrapper cw = new customValueWrapper();
                cw.custFldlabel = field.getDescribe().getLabel();
                cw.custFldvalue = field.getDescribe().getName();
                System.debug('FIELD Label: '+ cw.custFldlabel);
                System.debug('FIELD Value: '+ cw.custFldvalue);
                customObjWrapper.add(cw);
     		}
            system.debug('customObjWrapper: '+customObjWrapper);
            return customObjWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public with sharing class customValueWrapper {
        @auraEnabled public string custFldlabel {get;set;}        
        @auraEnabled public string custFldvalue {get;set;}
        
        }
}