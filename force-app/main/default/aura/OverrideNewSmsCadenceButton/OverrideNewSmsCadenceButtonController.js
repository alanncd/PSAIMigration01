({
    init : function (component,event) {
      component.set("v.isModalOpen", true);
        var flow = component.find("flowData");
         flow.startFlow("SelectTemplateCadence");
    },


   closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);
   }


})