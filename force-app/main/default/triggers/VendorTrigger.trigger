trigger VendorTrigger on Vendor__c (before insert,before update){
    //Check from custom setting that trigger is on or not.
    if(VendorTriggerSetting__c.getOrgDefaults().Activate_Trigger__c) {
        if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
            VendorTriggerHandler.updateVendor(trigger.new, trigger.oldMap, trigger.isUpdate);
        }
    }
}