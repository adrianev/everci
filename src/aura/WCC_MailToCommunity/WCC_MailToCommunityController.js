({
	getEmail : function(component, event, helper) {
       	var action =component.get("c.getCommunityManageEmail");
        
        var checkbox = component.get("v.bCommunityManager");
        
        //alert('checkbox' + checkbox);
        if (checkbox){
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('Success');
                // Alert the user with the value returned 
                // from the server
                //alert("From server: " + response.getReturnValue());
                
                component.set("v.sEmail", response.getReturnValue());

                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                alert('INCOMPLETE');
                // do something
            }
            else if (state === "ERROR") {
                alert('ERROR');
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
	},
    sendEmail : function(component, event, helper) {        
        var email = component.get("v.sEmail");
        
        //alert('email' + email);
        
        //window.open("mailto:"+email,"_self");
        var urlEvent = $A.get("e.force:navigateToURL");

        urlEvent.setParams({
          "url": 'mailto:'+email
        });
    	urlEvent.fire();
	}
})