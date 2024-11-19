({

    init : function (component,event) {
        component.set("v.isModalOpen", true);
          var flow = component.find("flowData");
           flow.startFlow("LeftM_DirectOne__SelectSequenceTemplate");
      },

    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
     },
     handleStatusChange: function(component,event,helper){
      if(event.getParam("status") === "FINISHED") {

     var outputVariables = event.getParam("outputVariables");
     var outputVar; 
     for(var i = 0; i < outputVariables.length; i++) { 
           outputVar = outputVariables[i]; // Pass the values to the component's attributes 
           if(outputVar.name === "recordId") { 
                var navEvt = $A.get("e.force:navigateToSObject"); 
                navEvt.setParams({ "recordId": outputVar.value, "slideDevName": "related" });
                navEvt.fire(); 
            } 
      } 
          
      }
  }
})