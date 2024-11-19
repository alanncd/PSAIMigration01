({
    getParametersInfo: function (component, event, helper,stat) {
        //Execute Apex Controller
        try {
            var str1 ='dummmy';
            var action = component.get('c.getWelcomeMatInfo');
            action.setParams({
                str: str1
            });
             action.setCallback(this, function (response) {
                var state = response.getState();
                var result = response.getReturnValue();
                if (state === 'SUCCESS') {
                    //component.set("v.linkWalk", result.domain);
                    component.set("v.isModalOpen", result.showmodal);
                    component.set("v.walktroughs", result.walktroughs);
                    console.log("test message walktroughs-----"+result.walktroughs);
                    console.log("test message showmodal-----"+result.showmodal);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    var message;
                    if (errors[0] && errors[0].message) {
                        this.showToast('ErrorCallBack',errors[0].message,'error');
                    }
                }
            })
            $A.enqueueAction(action);
         } catch (err) {
             console.log("test message");
            console.log(err);
        }      
    },
    setLikeToLMA: function(cmp, event, helper, boolParam){
		console.log(boolParam);
        try {
            var str1 =boolParam;
            var action = cmp.get('c.setFeedbackToLMR');
            action.setParams({
                feedback: str1
            });
             action.setCallback(this, function (response) {
                var state = response.getState();
                //var result = response.getReturnValue();
                 //console.log(result);
                if (state === 'SUCCESS') {
                    this.showToast('Success','Thanks for your feedback...!','success');
                    console.log(state);
                }else{
                    this.showToast('Error','Sorry, our system is currently unavailable. Please contact our support Team','error');
                } 
            })
            $A.enqueueAction(action);
         } catch (err) {
            console.log(err);
        }    
    },
    openCloseModal: function(cmp, event, helper, boolParam) {
    	cmp.set('v.isModalOpen', boolParam);
    },    
    setModalOffHelper: function(cmp, event, helper, boolParam) {
        try {
            var str1 ='dummmy';
            var action = cmp.get('c.setModalOffByUser');
            action.setParams({
                str: str1
            });
             action.setCallback(this, function (response) {
                var state = response.getState();
                var result = response.getReturnValue();
                 console.log(result);
                if (state === 'SUCCESS') {
                    cmp.set('v.isModalOpen', boolParam);
                    console.log(result);
                } 
            })
            $A.enqueueAction(action);
         } catch (err) {
            console.log(err);
        }      
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