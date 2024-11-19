({
	doInit : function(component, event, helper) {
		try { 
			helper.getTemmplateData(component, event, helper); 
        } catch (e) {
            console.log(e);    
        }
	},

	handleClick : function(component, event, helper) {
		try {
            helper.saveTemmplateData(component, event, helper);
        } catch (e) {
            console.log(e);   
        }
	},
})