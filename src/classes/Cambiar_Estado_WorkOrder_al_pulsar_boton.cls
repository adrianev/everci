public without sharing class Cambiar_Estado_WorkOrder_al_pulsar_boton {

	private ApexPages.StandardSetController standardController;
	
	public transient List<Workorder> selectedWO{get;set;}
	
	public boolean puedeRevisar {get; set;}
	private boolean paginaActual = false;
	private String currentURL = '';
	private Integer numPageUpdate = 0;
	public boolean isOver {get;set;}

	public Cambiar_Estado_WorkOrder_al_pulsar_boton(ApexPages.StandardSetController standardController)
	{
		this.standardController = standardController;
		
		if(Apexpages.currentPage().getUrl().contains('cambiar_estado_workorder_al_pulsar_boton')){
			paginaActual = true;
		} else {
			currentURL = Apexpages.currentPage().getUrl();
		}
		
		system.debug(Apexpages.currentPage().getUrl());
		/*puedeRevisar = (Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_SUPERVISOR_AUDITORIA_GESTION);
		if(!puedeRevisar){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No tiene permiso para realizar esta operación'));
		}*/
	}

	public PageReference revisionAutoWorkOrders()
	{
		system.debug(paginaActual);
		system.debug(currentURL);
		system.debug(Apexpages.currentPage().getUrl());
		if(paginaActual){
			List<String> fields = new List<String> {'Status','OTR_SEL_Subestado__c'};
			if(!Test.isRunningTest()){
				standardController.addFields(fields);
			}
		}
		
				
		puedeRevisar = (Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_SUPERVISOR_AUDITORIA_GESTION);
		puedeRevisar = true;
		if(!puedeRevisar){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No tiene permiso para realizar esta operación'));
		}
		
		numPageUpdate = 0;
		isOver = false;
		// Get the selected records
		List<Workorder> temp = (List<WorkOrder>) standardController.getSelected();
		
		selectedWO = new List<Workorder>();
		if(temp.size() > 200){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Se están revisando un número elevado de elementos. Se muestran los 200 primeros'));
		}
		
		for(Workorder wo: temp){
			if(selectedWO.size()>199)
				break;
			selectedWO.add(wo);
		}
		

		return null;
	}
	public void updateWorkOrders()
	{
		// Call StandardSetController 'save' method to update (optional, you can use your own DML)
		/*PageReference pag = standardController.save();
		system.debug(pag);
		system.debug(pag==null);*/
		
		try{
			
			List<WorkOrder> selectedWorkOrders = (List<WorkOrder>) standardController.getSelected();
				
			system.debug('--------enUpdate: ' + numPageUpdate + ',' + selectedWorkOrders.size());
				
			List<Workorder> selWoUpd = new List<Workorder>();


			// Update records
			//for(WorkOrder selectedWorkOrder : selectedWorkOrders)
			for(Integer i = 1000*numPageUpdate; (i<1000*(numPageUpdate+1) && i<selectedWorkOrders.size());i++)
			{	
				Workorder selectedWorkOrder = selectedWorkOrders[i];
				if(selectedWorkOrder.Status == Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO) {
					selectedWorkOrder.Status = Label.OTR_ESTADO_REVISADO;
					selectedWorkOrder.OTR_SEL_Subestado__c = Label.OTR_SUBESTADO_REVISADO_AUT_CON_INTER_GESTOR;
					selectedWorkOrder.OTR_CAS_Servicio_Revisado__c = true;
					selectedWorkOrder.OTR_DAT_Fecha_revision__c = Datetime.Now().date();
					selectedWorkOrder.OTR_HOR_Hora_de_revision__c = Datetime.Now().time();
					selectedWorkOrder.OTR_TXT_Estado_Anterior__c = selectedWorkOrder.Status;
					selectedWorkOrder.OTR_LKP_Gestor_revision__c = UserInfo.getUserId();
					
					selWoUpd.add(selectedWorkOrder);
				}else{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.OTR_ERROR_Orden_Revisada_Autom));	
				}
			}
			
			if(1000*(numPageUpdate+1) > selectedWorkOrders.size()){
				isOver = true;
			}
			
			numPageUpdate++;
			
			system.debug('----------------'+numPageUpdate);
			system.debug('----------------'+isOver);
			
			Baipas.establecerVariableControl();
			update selWoUpd;
			Baipas.deshabilitarVariableControl();
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Servicios revisados correctamente'));
		} catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
				system.debug('****** EXCEPTION : ' + e);
			isOver = true;
		}
		
		/*if(paginaActual)
			return pag;
		else
			return volver();*/
		//return volver();
	}

	public PageReference volver(){
		//PageReference paginaRedireccion = new PageReference('/0WO');
		//return paginaRedireccion;
		if(paginaActual){
			return standardController.cancel();
		} else {
			PageReference page = new PageReference(currentUrl);
			page.setRedirect(false);
			return page;
		}
	}
}