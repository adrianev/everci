/**
 * Clase que se utilizará para consultar desde el área de clicHogar información de un servicio.
 *
 * @author EVERIS
 * 
 */

@RestResource(urlMapping='/consultaCaso/*')
global without sharing class Rest_ClicHogar_ConsultaCaso {

	public static final Map<String, String> mapaTraduccionCaso = Util_Metadatos.getMapaTraduccion(new Set<String>{'Case'});
	public static final Map<String, String> mapaTraduccionWO = Util_Metadatos.getMapaTraduccion(new Set<String>{'WorkOrder'});
	
	private static String requestBody;
	private static Integer contParametros;
	
	/**
	 * Devuelve información referente al caso y un listado de órdenes de trabajo
	 *
	 * @param Id : Identificador interno del caso
	 *
	 * @return información referente al caso y un listado de las órdenes de trabajo que pertenecen a ese caso.
	 *
	 */

	@HttpGet
	global static void doGet() {

		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		String IdCaso = RestContext.request.params.get('Id');
		
		system.debug('---- SVV. Id del caso: ' + IdCaso);
		
		List<Case> caso = [SELECT AccountId, CAS_LKP_PolizaContrato__c, CAS_TXT_Num_Caso_HS__c, Type, CAS_SEL_Grupo_Causa__c, CAS_SEL_Causa_Averia__c, 
		                   CAS_FOR_Rango_Cita_Reservada__c, CAS_FOR_Fecha_Cita_Reservada__c, CAS_CAS_Requiere_Perito__c, CAS_CAS_Siniestro_Encuestado__c, 
		                   CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Idioma__c, Status, Id FROM Case WHERE Id =: IdCaso];
		if (caso == null || caso.size() == 0) {
			requestBody = '{'+ Util_WS_Error.devolverMensaje('API-007') +'}';
			system.debug(requestBody);
		}
		else {
			try {
			
				//Aquí tengo que meter todas las queries necesarias para la respuesta
				List<Garantia_Siniestro__c> garantia = [SELECT GSIN_FOR_Descripcion_Garantia__c FROM Garantia_Siniestro__c WHERE GSIN_LKP_Caso__c  =: IdCaso];
				List<Case> identificadorProducto = [SELECT CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Identificador__c FROM Case WHERE Id =: IdCaso];
				List<VDN_Compania__c> listaVDN = new List<VDN_Compania__c>();
				List<Configuracion_VDN__mdt> listaVDNmdt = new List<Configuracion_VDN__mdt>();
				
				listaVDN = [SELECT VDN_SEL_Idioma__c,VDN_TXT_Identificador__c, VDN_TLF_Telefono__c FROM VDN_Compania__c WHERE VDN_LKP_Compania__c =: caso[0].AccountId];
				if (listaVDN != null && listaVDN.size() > 0) {
					listaVDNmdt = [SELECT LoadId__c,ServiceId__c FROM Configuracion_VDN__mdt WHERE VDN_Number__c =: listaVDN[0].VDN_TXT_Identificador__c];
				}
				
				List<WorkOrder> ordenTrabajo = [SELECT OTR_SEL_Gremio__c, OTR_DAT_Fecha_Cierre_servicio__c, OTR_CAS_Servicio_Encuestado__c, CreatedDate, Status 
												FROM WorkOrder WHERE CaseId =: IdCaso AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)];
				List<String> listaIdWO = new List<String>();
				for (WorkOrder listaIdWOAux: ordenTrabajo) {
					listaIdWO.add(listaIdWOAux.Id);
				}
				
				List<ServiceAppointment> listaCitaServicio = [SELECT ArrivalWindowStartTime, ParentRecordId  FROM ServiceAppointment WHERE ParentRecordId IN : listaIdWO];
				List<WorkOrderHistory> listaHistoricoEstados = [SELECT NewValue, CreatedDate, WorkOrderId FROM WorkOrderHistory WHERE Field = 'Status' AND WorkOrderId IN : listaIdWO];
				List<WorkOrderLineItem> listaPartidas = [SELECT Description, WorkOrderId FROM WorkOrderLineItem WHERE WorkOrderId IN : listaIdWO];
				
				//contParametros se usa para el control de las "," de los JSON
				contParametros = 0;
				
				requestBody = '{';
				requestBody += Util_WS_Error.devolverMensaje('API-001')+',';
				concatenarParametroJSON('CAS_LKP_PolizaContrato',  caso[0].CAS_LKP_PolizaContrato__c);
				concatenarParametroJSON('CAS_TXT_Num_Caso_HS',  caso[0].CAS_TXT_Num_Caso_HS__c);
				concatenarParametroJSON('Type',  caso[0].Type);
				requestBody += ',"literalTipo" : [';
				requestBody += '{"ES" : "' + Util_Listas_Seleccion.getLabelDesdeAPI('Case', 'Type').get(caso[0].Type) + '"}';
				requestBody += ',{"CT" : "' + mapaTraduccionCaso.get('1'+'0000'+'Type'+caso[0].Type) + '"}]';
				concatenarParametroJSON('CAS_SEL_Grupo_Causa', caso[0].CAS_SEL_Grupo_Causa__c);
				requestBody += ',"literalGrupoCausa" : [';
				requestBody += '{"ES" : "' + Util_Listas_Seleccion.getLabelDesdeAPI('Case', 'CAS_SEL_Grupo_Causa__c').get(caso[0].CAS_SEL_Grupo_Causa__c) + '"}';
				requestBody += ',{"CT" : "' + mapaTraduccionCaso.get('1'+'0000'+'CAS_SEL_Grupo_Causa__c'+caso[0].CAS_SEL_Grupo_Causa__c) + '"}]';
				requestBody += ',"causaAveria" : [';
				requestBody += '{"ES" : "' + caso[0].CAS_SEL_Causa_Averia__c + '"}';
				requestBody += ',{"CT" : "' + mapaTraduccionCaso.get('1'+'0000'+'CAS_SEL_Causa_Averia__c'+caso[0].CAS_SEL_Causa_Averia__c) + '"}]';
				if (!String.isEmpty(String.valueOf(garantia))) {
					concatenarParametroJSON('GSIN_FOR_Descripcion_Garantia', garantia[0].GSIN_FOR_Descripcion_Garantia__c);
				}
				else {
					concatenarParametroJSON('GSIN_FOR_Descripcion_Garantia', '');
				}
				if (!String.isEmpty(String.valueOf(caso[0].CAS_FOR_Rango_Cita_Reservada__c))) {
					concatenarParametroJSON('CAS_FOR_Rango_Cita_Reservada', caso[0].CAS_FOR_Rango_Cita_Reservada__c);
				}
				else {
					concatenarParametroJSON('CAS_FOR_Rango_Cita_Reservada', '');
				}
				if (!String.isEmpty(String.valueOf(caso[0].CAS_FOR_Fecha_Cita_Reservada__c))) {
					concatenarParametroJSON('CAS_FOR_Fecha_Cita_Reservada', FechaSlice(string.valueOf(caso[0].CAS_FOR_Fecha_Cita_Reservada__c)));
				}
				else {
					concatenarParametroJSON('CAS_FOR_Fecha_Cita_Reservada', '');
				}
				if (caso[0].Type != Label.CAS_TIPO_RECHAZO_EN_APERTURA) {
					concatenarParametroJSON('averiaCubierta', 1);
					concatenarParametroJSON('siniestroAceptado', 1);
				}
				else {
					concatenarParametroJSON('averiaCubierta', 0);
					concatenarParametroJSON('siniestroAceptado', 0);
				}
				if (caso[0].CAS_CAS_Requiere_Perito__c == true) {
					concatenarParametroJSON('CAS_CAS_Requiere_Perito', 1);
				}
				else {
					concatenarParametroJSON('CAS_CAS_Requiere_Perito', 0);
				}
				concatenarParametroJSON('PRD_TXT_Identificador', identificadorProducto[0].CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.PRD_TXT_Identificador__c);
				concatenarParametroJSON('Status', caso[0].Status);
				concatenarParametroJSON('CAS_CAS_Siniestro_Encuestado', caso[0].CAS_CAS_Siniestro_Encuestado__c);
				concatenarParametroJSON('POL_SEL_Idioma', caso[0].CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Idioma__c);
				anadirVDN(listaVDN, listaVDNmdt);
				anadirWO(ordenTrabajo, listaIdWO, listaCitaServicio, listaHistoricoEstados, listaPartidas);
				
				requestBody += '}';
				system.debug('---- SVV. RequestBody: ' + requestBody);
			}
			catch (Exception e) {
				system.debug('---- EXCEPTION: ' + e + ' ' + e.getStackTraceString());
				requestBody = '{'+ Util_WS_Error.devolverMensaje('API-014') +'}';
				if (!test.isRunningTest()) {
					RestContext.response.addHeader('Content-Type', 'application/json');
					RestContext.response.responseBody = Blob.valueOf(requestBody);
				}
			}
		}
		
		
		
		if (!test.isRunningTest()) {
				RestContext.response.addHeader('Content-Type', 'application/json');
				RestContext.response.responseBody = Blob.valueOf(requestBody);
		}
		
	}
	
	
	/**
	 * Métodos para concatenar los parámetros en formato JSON, dependiendo si el valor del parámetro es: String, Boolean o Decimal
	 *
	 * @param nombreParametro: nombre del parámetro a concatenar
	 * @param valorParametro: valor del parámetro a concatenar
	 *
	 */
	//Concatenadores para el body del response
	private static void concatenarParametroJSON(String nombreParametro, String valorParametro)
	{
		if (valorParametro != null)
		{
			if (contParametros > 0) {requestBody += ',';}
			requestBody += '"' + nombreParametro + '" : "' + valorParametro + '"';
			contParametros++;
		}else{
			if (contParametros > 0) {requestBody += ',';}
			requestBody += '"' + nombreParametro + '" : ""';
			contParametros++;
		}
	}	
	
	private static void concatenarParametroJSON(String nombreParametroInt, Integer valorParaInt)
	{
		if (contParametros > 0) {requestBody += ',';}
		requestBody += '"' + nombreParametroInt + '" : ' + valorParaInt + '';
		contParametros++;
	}
	
	private static void concatenarParametroJSON(String nombreParametroBool, Boolean valorParaBoolean)
	{
		if (contParametros > 0) {requestBody += ',';}
		requestBody += '"' + nombreParametroBool + '" : "' + valorParaBoolean + '"';
		contParametros++;
	}
	
	/**
	 * Método que construye la parte del body correspondiente a VDNs
	 *
	 * @param listaContratos: lista de VDNs
	 *
	 */
	private static void anadirVDN(List<VDN_Compania__c> listaVDN, List<Configuracion_VDN__mdt> listaVDNmdt){
        requestBody +=',"datosTelefonia":[';
		contParametros = 0;
		if(listaVDN != null && listaVDN.size() > 0){
			for (VDN_Compania__c VDN: listaVDN) {
				if(contParametros != 0){
					requestBody += ',';
				}
				contParametros =0;
				requestBody +='{';
				concatenarParametroJSON('VDN_TLF_Telefono', VDN.VDN_TLF_Telefono__c);
				concatenarParametroJSON('VDN_SEL_Idioma', VDN.VDN_SEL_Idioma__c);
				requestBody +=',"datosLlamadaEntrante":[';
				if (listaVDNmdt != null && listaVDNmdt.size() > 0) {
					for (Configuracion_VDN__mdt VDNmdt: listaVDNmdt) {
						if(contParametros != 0){
							requestBody += ',';
						}
						contParametros = 0;
						requestBody +='{';
						concatenarParametroJSON('ServiceId', VDNmdt.ServiceId__c);
						concatenarParametroJSON('LoadId', VDNmdt.LoadId__c);
						requestBody +='}';
					}
					requestBody +=']';
				}
				else {
					requestBody +=']';
				}
				requestBody +='}';
			}
			requestBody +=']';
		}
		else {
			requestBody +=']';
		}
		contParametros = 0;
	}
	
	/**
	 * Método que construye la parte del body correspondiente a WO
	 *
	 * @param listaWO: lista de WorkOrders
	 *
	 */
	private static void anadirWO(List<WorkOrder> ordenTrabajo, List<String> listaWO, List<ServiceAppointment> listaCitaServicio, List<WorkOrderHistory> listaHistoricoEstados, List<WorkOrderLineItem> listaPartidas){
        requestBody +=',"listadoOrdenesTrabajo":[';
		contParametros = 0;
		Integer resultWO;
		Integer resultWOH;
		Integer resultFecha;
		if (ordenTrabajo.size() > 0) {
			for (WorkOrder wo: ordenTrabajo) {
				if(contParametros != 0){
					requestBody += ',';
				}
				contParametros = 0;
				requestBody +='{';	
				concatenarParametroJSON('OTR_CAS_Servicio_Encuestado', wo.OTR_CAS_Servicio_Encuestado__c);
				concatenarParametroJSON('OTR_SEL_Gremio', wo.OTR_SEL_Gremio__c);
				requestBody += ',"literalGremio" : [';
				requestBody += '{"ES" : "' + Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'OTR_SEL_Gremio__c').get(wo.OTR_SEL_Gremio__c) + '"}';
				requestBody += ',{"CT" : "' + mapaTraduccionWO.get('1'+'0000'+'OTR_SEL_Gremio__c'+wo.OTR_SEL_Gremio__c) + '"}]';
				resultWO = String.valueof(wo.CreatedDate).indexof('T');
				if (resultWO == -1) {
					concatenarParametroJSON('CreatedDate', FechaSlice(String.valueOf(wo.CreatedDate).split(' ').get(0)));
				}
				else {
					concatenarParametroJSON('CreatedDate', FechaSlice(String.valueOf(wo.CreatedDate).split('T').get(0)));
				}
				concatenarParametroJSON('Status', wo.Status);
				requestBody += ',"literalEstado" : [';
				requestBody += '{"ES" : "' + Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'Status').get(wo.Status) + '"}';
				requestBody += ',{"CT" : "' + mapaTraduccionWO.get('1'+'0000'+'Status'+wo.Status) + '"}]';
				if (wo.OTR_DAT_Fecha_Cierre_servicio__c != null) {
					resultFecha = String.valueof(wo.OTR_DAT_Fecha_Cierre_servicio__c).indexof('T');
					if (resultFecha == -1) {
						concatenarParametroJSON('fechaTerminacion', FechaSlice(String.valueof(wo.OTR_DAT_Fecha_Cierre_servicio__c).split(' ').get(0)));
					}
					else {
						concatenarParametroJSON('fechaTerminacion', FechaSlice(String.valueof(wo.OTR_DAT_Fecha_Cierre_servicio__c).split('T').get(0)));
					}
				}
				else {
					concatenarParametroJSON('fechaTerminacion', '');
				}
				for (ServiceAppointment sa: listaCitaServicio) {
					if (wo.Id == sa.ParentRecordId && !String.isEmpty(String.valueof(sa.ArrivalWindowStartTime))) {
						concatenarParametroJSON('fechaProximaAccion', FechaSlice(String.valueof(sa.ArrivalWindowStartTime).split(' ').get(0)));
					}
					else {
						concatenarParametroJSON('fechaProximaAccion', '');
					}
				}
				
				//Añadir lista de historicos
				requestBody +=',"listadoHistoricoEstados":[';
				contParametros = 0;
				if (!String.isEmpty(String.valueOf(listaHistoricoEstados))) {
					for (WorkOrderHistory woHistory: listaHistoricoEstados) {
						if (wo.Id == woHistory.WorkOrderId) {
							if(contParametros != 0){
									requestBody += ',';
							}
							contParametros = 0;
							requestBody +='{';
							concatenarParametroJSON('NewValue', String.valueof(woHistory.NewValue));
							requestBody += ',"literalNuevoEstado" : [';
							requestBody += '{"ES" : "' + Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'Status').get(String.valueOf(woHistory.NewValue)) + '"}';
							requestBody += ',{"CT" : "' + mapaTraduccionWO.get('1'+'0000'+'Status'+String.valueOf(woHistory.NewValue)) + '"}]';
							resultWOH = String.valueof(woHistory.CreatedDate).indexof('T');
							if (resultWOH == -1) {
								concatenarParametroJSON('fechaCambioEstado', FechaSlice(String.valueof(woHistory.CreatedDate).split(' ').get(0)));
								concatenarParametroJSON('horaCambioEstado', String.valueof(woHistory.CreatedDate).split(' ').get(1));
							}
							else {
								concatenarParametroJSON('fechaCambioEstado', FechaSlice(String.valueof(woHistory.CreatedDate).split('T').get(0)));
								concatenarParametroJSON('horaCambioEstado', String.valueof(woHistory.CreatedDate).split('T').get(1));
							}
							
							requestBody +='}';
						}
					}
					requestBody +=']';
					contParametros++;
				}
				else {
					requestBody +=']';
				}
				
				//añadir el listado de partidas
				requestBody +=',"listadoPartidas":[';
				contParametros = 0;
				if (!String.isEmpty(String.valueOf(listaPartidas))) {
					for (WorkOrderLineItem woLineItemAux: listaPartidas) {
						if (wo.Id == woLineItemAux.WorkOrderId) {
							if(contParametros != 0){
									requestBody += ',';
							}
							contParametros = 0;
							requestBody +='{';
							concatenarParametroJSON('Description', woLineItemAux.Description);
							requestBody +='}';
						}
					}
					requestBody +=']';
					contParametros++;
				}
				else {
					requestBody +=']';
				}
				
				//Aqui termina lista partidas
				requestBody +='}';
				system.debug('---- SVV. concatenar parametros: ' + contParametros);
				
			}
			requestBody +=']';
		}
		else {
			contParametros = 0;
			requestBody +=']';	
		}
		
	}
	

	/**
	 * Devuelve la fecha en formato: día/mes/año
	 *
	 * @param fechaConvertir : fecha que se quiere convertir en formato año-mes-día
	 *
	 * @return String con la fecha en formato: día/mes/año
	 *
	 */
	public static String FechaSlice(String fechaConvertir) {
		String dia = fechaConvertir.split('-').get(2);
		String mes = fechaConvertir.split('-').get(1);
		String anio = fechaConvertir.split('-').get(0);
		String resultado = dia + '/' + mes + '/' + anio;
		return resultado;
	}
}