({
  doInit: function (component, event, helper) {
    let days = [
      { id: "None", label: "--None--" },
      { id: "LastQuarter", label: "Last Quarter" },
      { id: "CurrentQuarter", label: "Current Quarter" },
      { id: "-1", label: "1 Day" }
    ];
    for (var i = 2; i <= 80; i++) {
      let obj = { id: "-" + i, label: i + " Days" };
      days.push(obj);
    }

    component.set("v.options", days);
  },
  onChange: function (cmp, evt, helper) {
    cmp.set("v.selectedValue", cmp.find("select").get("v.value"));
  },

  getRecords: function (component, event, helper) {
    if (component.get("v.selectedValue") === "None") {
      helper.showToast("Error", "Please select days...!", "error");
    } else {
      $A.util.removeClass(component.find("spinner1"), "slds-hide");
      helper.getToken(component, event, helper);
    }
  },
  refreshData: function (component, event, helper) {
    helper.refreshData(component, event, helper);
  }
});