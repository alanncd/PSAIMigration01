({
	getTemmplateData: function (component, event, helper) {
        try {
            var self = this;
			var action = component.get("c.getLeadTemplates"); 
			component.set("v.displaySpinner",true);
			action.setParams({
				recId : component.get("v.recordId")
			});
			action.setCallback(this, function (response) {  
				let state = response.getState();
				if (state != null) {
					if (state === "SUCCESS") { 
                        var templateOption = response.getReturnValue();
						component.set( 'v.options',templateOption);
					} else if (state === "INCOMPLETE") {
						console.log("From server: " + response.getReturnValue());
					} else if (state === "ERROR") {
						var errors = response.getError();
						if (errors[0] && errors[0].message) {
							self.showToast('Info Message',errors[0].message,'','3000','info_alt','error','dismissible');
						} else {
							console.log("Unknown error");
						}
					}
				}
				component.set("v.displaySpinner",false); 
			});
			$A.enqueueAction(action);
        } catch (e) {
            console.log(e);
        }
    },
    
   saveTemmplateData: function (component, event, helper) {
        try {
            var self = this;
            var selectedValue = component.get("v.selectedValue"); 
			var selectedLabel = '';
			var options = component.get('v.options');
			console.log('options'+options);
			if(!$A.util.isEmpty(options) && !$A.util.isEmpty(selectedValue) ){
				for(var index in options){
					if(options[index].id == selectedValue){
						selectedLabel = options[index].label;
						break;
					}
				}
			}
			console.log('selectedValue'+selectedValue);
			console.log('selectedLabel'+selectedLabel);
            var action = component.get("c.saveLeadTemplates"); 
            component.set("v.displaySpinner",true);
			action.setParams({
				recId : component.get("v.recordId"),
				templateId : selectedValue,
				templateName : selectedLabel
			});
			action.setCallback(this, function (response) {  
				let state = response.getState();
				if (state != null) {
					if (state === "SUCCESS") { 
                       self.showToast('Info Message','Successfully Saved','','3000','info_alt','success','dismissible');
					   $A.get('e.force:refreshView').fire();
					} else if (state === "INCOMPLETE") {
						console.log("From server: " + response.getReturnValue());
					} else if (state === "ERROR") {
						var errors = response.getError();
						if (errors[0] && errors[0].message) {
							self.showToast('Info Message',errors[0].message,'','3000','info_alt','error','dismissible');
						} else {
							console.log("Unknown error");
						}
					}
				}
				component.set("v.displaySpinner",false); 
			});
			$A.enqueueAction(action);
        } catch (e) {
            console.log(e);
        }
    },
    
    showToast: function (title, message, messageTemplate, duration, key, type, mode) {
        try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: title, 
                message: message, 
                messageTemplate: messageTemplate,
                duration: duration,
                key: key,
                type: type,
                mode: mode
            });
            toastEvent.fire();
        } catch (e) {
            console.log(e);
        }
    },
})