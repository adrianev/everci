({
	updateCount : function(component, event, helper) {
		console.log(component.get('v.count'));
        helper.updateCount(component,event);
	},
    
    getListAccount : function(component, event, helper) {
		console.log(component.get('v.accountList'));
        helper.getListAccount(component,event);
	},
    
    saveAccount : function(component, event, helper) {
        helper.saveAccount(component,event);
	}
    
})