({
	updateCount : function(component, event) {
		var action = component.get("c.doCount");
        console.log('Hasta aquí');
        action.setCallback(this, function(response){
            var result = response.getState();
			if (result === "SUCCESS") {
				console.log('OK');
                component.set('v.count',response.getReturnValue());
            }else if(result === "ERROR"){
                console.log('ERROR');
            }
            
        });
        $A.enqueueAction(action);
	},
    
    getListAccount : function(component, event) {
		var action = component.get("c.doGetListAccount");
        
        action.setCallback(this,function(response){
            var result = response.getState();
			if (result === "SUCCESS") {
				console.log('OK');
                component.set('v.accountList',response.getReturnValue());
            }else if(result === "ERROR"){
                console.log('ERROR');
            }
        });
        
        $A.enqueueAction(action);
	},
     saveAccount : function(component, event) {
		var action = component.get("c.doSave");
        action.setParams({acc : component.get('v.acc')});
         
        action.setCallback(this,function(response){
            var result = response.getState();
			if (result === "SUCCESS") {
				console.log('OK');
                this.getListAccount(component,event);
            }else if(result === "ERROR"){
                console.log('ERROR');
                alert(result);
            }
        });
        
        $A.enqueueAction(action);
	}
})