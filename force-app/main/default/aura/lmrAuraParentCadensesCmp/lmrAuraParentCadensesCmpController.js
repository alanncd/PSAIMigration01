({
    init : function(component, event, helper) {
        var id = component.get("v.recordId");
    },
    
    closeMethodInAuraController : function(component, event, helper) {
        helper.refreshView();
        $A.get("e.force:closeQuickAction").fire();
       
    },
    refreshView: function(component, event) {
        // refresh the view
        $A.get('e.force:refreshView').fire();
    },
})