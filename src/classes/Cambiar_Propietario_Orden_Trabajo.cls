public without sharing class Cambiar_Propietario_Orden_Trabajo {

	private ApexPages.StandardSetController controlador;
	//public List<User> usuario{get;set;}   
	//public User usu  {get;set;}   
	
	public boolean puedeRevisar {get; set;}
	private boolean paginaActual = false;
	private String currentURL = '';
	private Integer numPageUpdate = 0;
	public boolean isOver {get;set;}

	public WorkOrder wo {get;set;} 

	public Cambiar_Propietario_Orden_Trabajo(ApexPages.StandardSetController standardController)
	{
		wo = new WorkOrder();
		controlador = standardController;
		
		if(Apexpages.currentPage().getUrl().contains('Cambiar_Propietario_Orden_Trabajo')){
			paginaActual = true;
		} else {
			currentURL = Apexpages.currentPage().getUrl();
		}
		/*puedeRevisar = (Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == 'Supervisor auditoria de gestión');
		if(!puedeRevisar){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No tiene permiso para realizar esta operación'));
		}*/
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cosa: '+String.valueof(standardController.getSelected().size())));
	}

	public List<WorkOrder> selectedWorkOrders{get;set;}

	public PageReference cambiarPropAutoWorkOrders()
	{   
		
		if(paginaActual){
			List<String> fields = new List<String> {'Id','WorkOrderNumber','OwnerId'};
			if(!Test.isRunningTest()){
				controlador.addFields(fields);
			}
		}
		
		//wo = new WorkOrder();
		//this.standardController = standardController;
		
		puedeRevisar = (Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_SUPERVISOR_AUDITORIA_GESTION);
		if(!puedeRevisar){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No tiene permiso para realizar esta operación'));
		}
		
		numPageUpdate = 0;
		isOver = false;
		
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cosa: '+String.valueof(standardController.getSelected().size())));

		selectedWorkOrders = (List<WorkOrder>) controlador.getSelected();
		
		system.debug(selectedWorkOrders.size());

		return null;
	}    

	public void guardar(){
		
		if(wo.OwnerId != null){
			isOver = false;
			List<Workorder> selWoUpd = new List<Workorder>();
			
			system.debug('--------enUpdate: ' + numPageUpdate + ',' + selectedWorkOrders.size());
			
			//for(WorkOrder woSelec : selectedWorkOrders){
			for(Integer i = 1000*numPageUpdate; (i<1000*(numPageUpdate+1) && i<selectedWorkOrders.size());i++){
				Workorder woSelec = selectedWorkOrders[i];
				woSelec.OwnerId = wo.OwnerId; 
				selWoUpd.add(woSelec);
			}
			
			if(1000*(numPageUpdate+1) > selectedWorkOrders.size()){
				isOver = true;
			}
			
			numPageUpdate++;
			
			system.debug('----------------'+numPageUpdate);
			system.debug('----------------'+isOver);
			
			
			try{
				
				Baipas.establecerVariableControl();
				update selWoUpd;
				Baipas.deshabilitarVariableControl();
				//update selectedWorkOrders;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, label.INFO_CAMBIAR_PROPIETARIO_WO));
			}catch(Exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
				system.debug('****** EXCEPTION : ' + e);
				isOver = true;
			}
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No se ha rellenado el propietario'));
			isOver = true;
		}
	}

	public PageReference volver(){
		//PageReference paginaRedireccion = new PageReference('/0WO');
		//return paginaRedireccion;
		if(paginaActual){
			return controlador.cancel();
		} else {
			PageReference page = new PageReference(currentUrl);
			page.setRedirect(false);
			return page;
		}
	}

}