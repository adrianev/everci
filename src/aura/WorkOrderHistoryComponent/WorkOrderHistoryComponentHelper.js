({
	getWoHistory : function(component, event, helper) {
		var action=component.get("c.getWoHistories");
        action.setParams(
            {"idRelatedTo" : component.get("v.recordId")
        });
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.nWoHistory",response.getReturnValue().length);
                component.set("v.lOrders",response.getReturnValue());
                component.set("v.loaded","true");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	}
})