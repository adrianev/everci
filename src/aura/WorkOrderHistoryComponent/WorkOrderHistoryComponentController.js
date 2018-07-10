({
	doInit : function(component, event, helper) {
    	helper.getWoHistory(component,event,helper);
	},
    navigateTo : function(component, event, helper){
        var idx = event.target.id;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": idx
        });
        navEvt.fire();
    }

})