({
  doInit: function (component, event, helper) {
    try {
      var simpleNewCase = {
        subject: "",
        description: "",
        email: "",
        phone: "",
        name: "",
        ticketType: "",
        attachmentLink: "",
        collaborator: "",
        collaboratorPhone: "",
        collaboratorEmail: "",
        credentials: ""
      };
      component.set("v.simpleNewCase", simpleNewCase);

      helper.searchAccManager(component, event, helper);
    } catch (e) {
      console.log(e);
    }
  },

  onChange: function (component, event, helper) {
    var value = component.find("ticketType").get("v.value");
    var simpleNewCase = component.get("v.simpleNewCase");
    if (!$A.util.isEmpty(value)) {
      simpleNewCase.ticketType = value;
    }
    component.set("v.simpleNewCase", simpleNewCase);
  },

  handleClick: function (component, event, helper) {
    try {
      var allValid = component
        .find("case")
        .reduce(function (validSoFar, inputCmp) {
          inputCmp.showHelpMessageIfInvalid();
          return (
            validSoFar &&
            !inputCmp.get("v.validity").valueMissing &&
            inputCmp.isValid() &&
            inputCmp.checkValidity()
          );
        }, true);

      var simpleNewCase = component.get("v.simpleNewCase");

      var regExpEmailformat =
        /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
      component.set("v.regExpEmailformat", regExpEmailformat);

      let isValidEmail;
      if (!$A.util.isEmpty(simpleNewCase.email)) {
        if (simpleNewCase.email.match(regExpEmailformat)) {
          isValidEmail = true;
        } else {
          isValidEmail = false;
        }
      } else {
        isValidEmail = true;
      }

      if (!isValidEmail) {
        helper.showToast(
          "Info Message",
          "Email Address is invalid.",
          "",
          "3000",
          "info_alt",
          "error",
          "dismissible"
        );
        return;
      }

      if (allValid && isValidEmail) {
        component.set("v.displaySpinner", true);
        helper.saveTemmplateData(component, event, helper);
      }
    } catch (e) {
      console.log(e);
    }
  },

  searchClick: function (component, event, helper) {
    helper.searchCases(component, event, helper, "open");
  },
  searchClickClosed: function (component, event, helper) {
    helper.searchCases(component, event, helper, "closed");
  },

  closeModal: function (cmp, event, helper) {
    helper.openCloseModal(cmp, event, helper, false);
  },

  handleRowAction: function (cmp, event, helper) {
    var action = event.getParam("action");
    var row = event.getParam("row");
    switch (action.name) {
      case "view_details":
        helper.showRowComments(row, cmp, event, helper);
        break;
      default:
        helper.showRowComments(row, cmp, event, helper);
        break;
    }
  }
});