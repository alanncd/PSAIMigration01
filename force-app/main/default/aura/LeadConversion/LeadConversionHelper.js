({
    toggleSpinner: function (component, event, show) {
        try {
            component.set('v.showSpinner', show);
        } catch (e) {
            console.log(e);
        }
    },

    fetchRecords: function (component, event, helper) { 
        try {
            var self = this;
            helper.toggleSpinner(component, event, true);
            var action = component.get("c.fetchLeadRecords");
            action.setParams({
                "nextStep": component.get('v.nextStep'),
            })
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var JSONObj = JSON.parse(JSON.stringify(response.getReturnValue()));
                    var leadWrapper = response.getReturnValue();
                    component.set("v.leadWrapper", leadWrapper);
                    self.handleSelectedLeads(component, event,helper);
                } else if (state === "INCOMPLETE") {
                    // do something
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                errors[0].message);
                            alert(errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
                helper.toggleSpinner(component, event, false);
            });
            $A.enqueueAction(action);
        } catch (e) {
            console.log(e);
        }
    },

    convertLead: function (component, event, helper) {
        try {
            var leadWrapperList = component.get("v.leadWrapper");
            var selectedLead = component.get('v.selectedLead'); 
            var userEmail = component.get("v.userEmail");
            if (!$A.util.isEmpty(selectedLead) && !$A.util.isEmpty(userEmail)) {
                var action = component.get("c.convertSelectedLead");
                action.setParams({
                    "selectedLead": selectedLead,
                    "EmailAddress" : userEmail 
                })
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var responseObj = response.getReturnValue();
                        if ($A.util.isEmpty(responseObj)){ 
                            alert('Something went wrong please connect with System Admin');
                        }else{
                            alert('Lead Conversion Succesfully Started Please check your email. Batch Id :'+responseObj);
                            location.reload();
                        }   
                    } else if (state === "INCOMPLETE") {
                        // do something
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " +
                                    errors[0].message);
                                alert(errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
            } else {
                if ($A.util.isEmpty(selectedLead)) {
                    alert('Please select atleast one Lead');
                } else if ($A.util.isEmpty(userEmail)) {
                    alert('Please add email adddress');
                }
            }
        } catch (e) {
            console.log(e);
        }
    },

    handleSelectedLeads : function (component, event, helper) {
        try {
            var selectedLead = component.get('v.selectedLead');
            var leadWrapper = component.get('v.leadWrapper');
            var isAllSelected = true;
            if(!$A.util.isEmpty(selectedLead) && !$A.util.isEmpty(leadWrapper)){
                for (var i = 0; i < leadWrapper.length; i++) {
                    if(selectedLead.includes(leadWrapper[i].leadObj.Id)){ 
                        leadWrapper[i].isBoolean = true;
                    }
                }
            }
            if(!$A.util.isEmpty(leadWrapper)){
                for (var i = 0; i < leadWrapper.length; i++) {
                    if(isAllSelected && !leadWrapper[i].isBoolean){
                        isAllSelected = false;
                    }
                }
            }
            component.set('v.allSelected',isAllSelected);
            component.set('v.leadWrapper',leadWrapper);
        } catch (error) {
            console.log(error);
        }
    },

})