({
	getListTask : function(component, event, helper) {
		var action=component.get("c.getListTasks");
        action.setParams(
            {"idRelatedTo" : component.get("v.recordId")
        });
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                component.set("v.nTasks",response.getReturnValue().length);
                component.set("v.lTasks",response.getReturnValue());
                component.set("v.loaded","false");

                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
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