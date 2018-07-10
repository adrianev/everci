global without sharing class Click2CallController {

	public WorkOrder wo {get; set;}
	public String error {get; set;}
	public integer telefono  {get; set;}
	public boolean distanciaMenor  {get; set;}
	public boolean deshabilitarCampo {get; set;}
	
	public Click2CallController() {
		deshabilitarCampo = false;
		
		PageReference paginaActual = ApexPages.currentPage();
		
		if (paginaActual.getParameters().containsKey('id')) {
			List<WorkOrder> listaWO = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{paginaActual.getParameters().get('id')}).values();
			//List<WorkOrder> listaWO = Util_Orden_Trabajo.queryOTBySet(new Set<Id>{paginaActual.getParameters().get('id')},null,null).values();
			//List<WorkOrder> listaWO = Util_Orden_Trabajo.queryOT(paginaActual.getParameters().get('id'),null,null);
			/*List<WorkOrder> listaWO = [SELECT Id, OTR_NUM_Numero_C2C__c, OTR_DAT_Fecha_ultimo_C2C__c, OTR_TEL_Telefono_C2C__c, 
												Latitude, Longitude, OTR_CAS_Urgente__c, WorkOrderNumber, OTR_FOR_Tipo_de_Caso__c
										FROM WorkOrder WHERE Id =: paginaActual.getParameters().get('id')];*/
			if (!listaWO.isEmpty()) {
				wo = listaWO.get(0);
			}
			else {
				error = Label.C2C_No_id;
			}
		}
		system.debug(wo + ' WorkOrderInfo');
		if(wo != null && wo.OTR_DAT_Fecha_ultimo_C2C__c == Date.today() && wo.OTR_NUM_Numero_C2C__c == 2){
			error = Label.C2C_Error_Llamadas;
		}
		if(error !=null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
		}
	}



	private void validarNumeroLLamadas(){
		if(wo.OTR_DAT_Fecha_ultimo_C2C__c == Date.today() && wo.OTR_NUM_Numero_C2C__c < 2 && wo.OTR_NUM_Numero_C2C__c!=null){
			wo.OTR_NUM_Numero_C2C__c ++;
		}else if(wo.OTR_DAT_Fecha_ultimo_C2C__c != Date.today()){
			wo.OTR_NUM_Numero_C2C__c = 1;
			wo.OTR_DAT_Fecha_ultimo_C2C__c = Date.today();
		}
	}
	
	public void solicitarLlamada2(){
		Callout_ClickToCall_RQ aux = new Callout_ClickToCall_RQ();
		String devNameCustomMetadata;
		aux.telefono  = wo.OTR_TEL_Telefono_C2C__c;
		
		if((distanciaMenor || wo.OTR_CAS_Urgente__c)){
			if(wo.OTR_FOR_Tipo_de_Caso__c == Label.CAS_TIPOLOGIA_ASISTENCIA){
				devNameCustomMetadata = Label.Asistencia_Prioritaria;
			}else if(wo.OTR_FOR_Tipo_de_Caso__c == Label.CAS_TIPOLOGIA_B2B2C){
				devNameCustomMetadata = Label.B2B2C_B2B_Prioritaria;
			}		
		}else{
			if(wo.OTR_FOR_Tipo_de_Caso__c == Label.CAS_TIPOLOGIA_ASISTENCIA){
				devNameCustomMetadata = Label.Asistencia_No_Prioritaria;
			}else if(wo.OTR_FOR_Tipo_de_Caso__c == Label.CAS_TIPOLOGIA_B2B2C){
				devNameCustomMetadata = Label.B2B2C_B2B_No_Prioritaria;
			}		
		}

		//nueva llamada por el util
		Callout_ClickToCall.Resultado res;
		if(!Test.isRunningTest()){
			res = Util_Click2Call.solicitarLlamadaClick2Call(devNameCustomMetadata, wo.WorkOrderNumber, wo.OTR_TEL_Telefono_C2C__c);			
			
		}else{
			res = new Callout_ClickToCall.Resultado();
			res.code = 'PRS-001';
		}
		//Callout_ClickToCall.Resultado res = Util_Click2Call.solicitarLlamadaClick2Call(devNameCustomMetadata, wo.WorkOrderNumber, wo.OTR_TEL_Telefono_C2C__c);

		//List<Configuracion_VDN__mdt> conf = Util_Metadatos.getConfVDNMetadataByDevName(new Set<String>{devNameCustomMetadata}).values();
		//List<Configuracion_VDN__mdt> conf = Util_Metadatos.queryConfiguracionVDN(devNameCustomMetadata,null);
		//List<Configuracion_VDN__mdt> conf = [SELECT Distancia_prioridad__c, LoadId__c, ServiceId__c FROM Configuracion_VDN__mdt WHERE DeveloperName = :devNameCustomMetadata];
		/*aux.idCarga = Configuracion_VDN__mdt.B2B2C_B2B_No_Prioritaria.LoadId__c;
		aux.idServicio = Configuracion_VDN__mdt.B2B2C_B2B_No_Prioritaria.ServiceId__c;*/
		/*if(!conf.isEmpty()){
			aux.idCarga = Integer.valueOf(conf[0].LoadId__c);
			aux.idServicio = Integer.valueOf(conf[0].ServiceId__c);
		}
		System.debug('RPM conf: ' + devNameCustomMetadata);
		System.debug('RPM aux: ' + aux);

		Callout_ClickToCall.Resultado res = new Callout_ClickToCall.Resultado();

		aux.dato1 = String.valueOf(wo.WorkOrderNumber);
		
		Callout_ClickToCall llamada = new Callout_ClickToCall();
		if(Test.isRunningTest()){
			res.code = 'PRS-001';
		}else{
			res =  Callout_ClickToCall.sendDatos(aux);			
		}
		system.debug(aux);
		system.debug(res);*/
		
		if(res!= null && res.code =='PRS-001'){
			validarNumeroLLamadas();
			update wo;
			deshabilitarCampo = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.C2C_OK));
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.C2C_KO));
		}
		

	}

	
}