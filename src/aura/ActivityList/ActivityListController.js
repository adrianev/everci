({
	doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Subject', fieldName: 'Name', type: 'text',sortable:false},
            {label: 'Status', fieldName: 'Status', type: 'text',sortable:false},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date',sortable:false},
            {label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'date',sortable:false}
        ]);
        helper.getListTask(component,event,helper);
	}
})