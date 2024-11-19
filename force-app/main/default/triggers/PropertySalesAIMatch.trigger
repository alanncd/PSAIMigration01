trigger PropertySalesAIMatch on Property_SalesAI_Match__c (after update, after insert) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        PropertySalesAIMatchTriggerHandler.updateLeadsAndOppsRollBack(Trigger.new, Trigger.oldMap);
        PropertySalesAIMatchTriggerHandler.updateLeadsAndOppsConfirm(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isAfter && Trigger.isInsert) {
        PropertySalesAIMatchTriggerHandler.updateLeadsAndOppsConfirm(Trigger.new, null);
    }
}