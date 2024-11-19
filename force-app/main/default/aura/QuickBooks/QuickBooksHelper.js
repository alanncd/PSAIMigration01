({    
    getToken : function(component, event, helper) {        
        var action = component.get('c.getVendorsAndExpenses');
		action.setParams({
			"days" : component.get("v.selectedValue")
		});
		action.setCallback(this,function(response){
			var result =  response.getReturnValue();  
            console.log(result);
            if (result === '200'){
                 $A.util.addClass( component.find( 'spinner1' ), 'slds-hide' ); 
                component.set('v.selectedValue', 'None');
                this.showToast('Success','Records are saved Successfully...!','success');
                
			} else if(result === '401'){
                $A.util.addClass( component.find( 'spinner1' ), 'slds-hide' ); 
                component.set('v.selectedValue', 'None');
                this.showToast('Authentication Failed...!','Please Contact your System Admin','error');
                
            } else {
                $A.util.addClass( component.find( 'spinner1' ), 'slds-hide' );
                component.set('v.selectedValue', 'None');
                this.showToast('ERROR','Unable to save records','error');
			}
		});
		$A.enqueueAction(action);
    },
    refreshData : function(component, event, helper){
        var self  = this;
        var action = component.get('c.refreshVendorData');
		action.setCallback(this,function(response){
			var state = response.getState();
            if (state === "SUCCESS") {
                self.showToast('Success','Batch has started to refresh the count...!','success');
            }else{
                self.showToast('ERROR','Unable to refresh records','error');
            }
		});
		$A.enqueueAction(action);
    },
    showToast : function(title,msg,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type":type
        });
        toastEvent.fire();
    },
})