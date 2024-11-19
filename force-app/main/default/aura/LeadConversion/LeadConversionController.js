({
    handleSearch: function (component, event, helper) {
        try {
            component.set('v.allSelected',false);
            helper.fetchRecords(component, event, helper);
        } catch (error) {
            console.log(error);
        }
    },

    displayPopUp : function (component, event, helper) {
        try {
            component.set('v.userEmail','');
            component.set('v.showPopUp', true);
        } catch (error) {
            console.log(error);
        }
    },

    handleConverstion  : function (component, event, helper) {
        try {
            helper.convertLead(component, event, helper); 
        } catch (error) {
            console.log(error);
        }
    },

    handleRecordSelect: function (component, event, helper) {
        try {
            var isSelected = event.getSource().get('v.checked');
            var selectedLead = component.get('v.selectedLead');
            var selectedLeadArray = !$A.util.isEmpty(selectedLead) ? selectedLead : [];
            var AllData = component.get('v.leadWrapper');
            if (!$A.util.isEmpty(AllData) && !$A.util.isEmpty(AllData)) {
                for (var i = 0; i < AllData.length; i++) {
                    AllData[i].isBoolean = isSelected;
                    if(isSelected){
                        if(!selectedLeadArray.includes(AllData[i].leadObj.Id))
                            selectedLeadArray.push(AllData[i].leadObj.Id);
                    }else{
                        selectedLeadArray.splice( selectedLeadArray.findIndex( obj => {
                            return obj === AllData[i].leadObj.Id
                        }), 1 );
                    } 
                }
            }
            component.set('v.selectedLead',selectedLeadArray);
            component.set('v.leadWrapper', AllData);
        } catch (error) {
            console.log(error);
        }
    },

    handleCancel: function (component, event, helper) {
        try {
            component.set('v.showPopUp', false);
        } catch (error) {
            console.log(error);
        }
    },

    handleSelect : function (component, event, helper) {
        try {
            var leadWrapper = component.get('v.leadWrapper');
            var isAllSelected = true;
            var selectedLead = component.get('v.selectedLead');
            var selected = event.getSource().get('v.checked');
            var recordId = event.getSource().get('v.value');
            var selectedLeadArray = !$A.util.isEmpty(selectedLead) ? selectedLead : [];
            if( !selected ) {
                selectedLeadArray.splice( selectedLeadArray.findIndex( obj => {
                    return obj === recordId
                }), 1 );
            } else {
                selectedLeadArray.push( recordId ); 
            }
            if(!$A.util.isEmpty(leadWrapper)){
                for (var i = 0; i < leadWrapper.length; i++) {
                    if(isAllSelected && !leadWrapper[i].isBoolean){
                        isAllSelected = false;
                    }
                }
            }
            component.set('v.allSelected',isAllSelected);
            component.set('v.selectedLead',selectedLeadArray);
            
        } catch (error) {
            console.log(error);
        }
    },

})