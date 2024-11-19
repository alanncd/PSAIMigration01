({
    doInit: function (component, event, helper) {
        try {
            helper.getParametersInfo(component, event, helper);
        } catch (e) {
            console.log(e);
        }
    },
	closeModal: function(cmp, event, helper) {
	    helper.openCloseModal(cmp, event, helper, false);
	    },  
	setModalOff: function(cmp, event, helper) {
	    helper.setModalOffHelper(cmp, event, helper, false);
	    },
	setLike: function(cmp, event, helper) {
	    helper.setLikeToLMA(cmp, event, helper, true);
	    },
	setDislike: function(cmp, event, helper) {
	    helper.setLikeToLMA(cmp, event, helper, false);
	    },    
})