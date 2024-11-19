({
  saveTemmplateData: function (component, event, helper) {
    try {
      var self = this;
      var simpleNewCase = component.get("v.simpleNewCase");

      var action = component.get("c.saveCase");
      action.setParams({
        JSONInput: JSON.stringify(simpleNewCase)
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        var result = response.getReturnValue();
        if (state === "SUCCESS") {
          var message =
            "Your case was successfully created. Please monitor your email for further details.";

          // Set the attribute value
          component.set("v.toastMessage", message);
          component.set("v.showInput", false);
        } else if (state === "INCOMPLETE") {
          alert("From server: " + response.getReturnValue());
        } else if (state === "ERROR") {
          var errors = response.getError();
          var message;
          if (errors[0] && errors[0].message) {
            self.showToast(
              "Info Message",
              errors[0].message,
              "",
              "3000",
              "info_alt",
              "error",
              "dismissible"
            );
          }
        }
        component.set("v.displaySpinner", false);
      });
      $A.enqueueAction(action);
    } catch (err) {
      console.log(err);
    }
  },
  searchCases: function (component, event, helper, stat) {
    component.set("v.mycolumns", [
      {
        label: "Case Number",
        fieldName: "caseNumber",
        type: "text",
        initialWidth: 125
      },
      { label: "Status", fieldName: "status", type: "text", initialWidth: 135 },
      {
        label: "Created Date",
        fieldName: "createdDate",
        type: "Date",
        initialWidth: 135
      },
      { label: "Subject", fieldName: "subject", type: "text" },
      {
        label: "Comments",
        type: "button",
        initialWidth: 135,
        typeAttributes: {
          label: "View...",
          name: "view_details",
          title: "Click to View Details"
        }
      },
      {
        label: "Description",
        fieldName: "description",
        type: "text",
        wrapText: true
      }
    ]);
    try {
      var str1 = stat;
      var action = component.get("c.viewCase");
      action.setParams({
        str: str1
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        var result = response.getReturnValue();
        if (state === "SUCCESS") {
          //component.set('v.showInput', true);
          component.set("v.myCases", result);
          //alert(result);
        } else if (state === "INCOMPLETE") {
          alert("From server: " + response.getReturnValue());
        } else if (state === "ERROR") {
          var errors = response.getError();
          var message;
          if (errors[0] && errors[0].message) {
            self.showToast(
              "Info Message",
              errors[0].message,
              "",
              "3000",
              "info_alt",
              "error",
              "dismissible"
            );
          }
        }
        component.set("v.displaySpinner", false);
      });
      $A.enqueueAction(action);
    } catch (err) {
      console.log(err);
    }
  },
  searchAccManager: function (component, event, helper, stat) {
    //Execute Apex Controller
    try {
      //alert('Open');
      var str1 = "dummmy";
      var action = component.get("c.searchAccManager");
      action.setParams({
        str: str1
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        var result = response.getReturnValue();
        if (state === "SUCCESS") {
          component.set("v.accManagerInfo", result);
          //alert(result);
        } else if (state === "INCOMPLETE") {
          alert("From server: " + response.getReturnValue());
        } else if (state === "ERROR") {
          var errors = response.getError();
          var message;
          if (errors[0] && errors[0].message) {
            self.showToast(
              "Info Message",
              errors[0].message,
              "",
              "3000",
              "info_alt",
              "error",
              "dismissible"
            );
          }
        }
        component.set("v.displaySpinner", false);
      });
      $A.enqueueAction(action);
    } catch (err) {
      console.log(err);
    }
  },
  showRowComments: function (row, component, event, helper) {
    // eslint-disable-next-line no-alert
    component.set("v.columnsComments", [
      { label: "Date", fieldName: "createdDate", type: "Date" },
      { label: "Comment", fieldName: "commentBody", type: "text" }
    ]);
    //alert('--------------'+row.coments);
    if (row.coments == "") {
      alert("Ticket without comments");
      component.set("v.isModalOpen", false);
    } else {
      component.set("v.myCaseComents", row.coments);
      component.set("v.isModalOpen", true);
    }
  },
  openCloseModal: function (cmp, event, helper, boolParam) {
    cmp.set("v.isModalOpen", boolParam);
  },
  showToast: function (
    title,
    message,
    messageTemplate,
    duration,
    key,
    type,
    mode
  ) {
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
  }
});