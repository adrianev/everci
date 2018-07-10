/**
 * Clase que se utilizará para consultar desde el área de clientes Membership, para un cliente
	específico, información de los siniestros de Membership
 *
 * @author EVERIS
 * 
 */
@RestResource(urlMapping='/consultarCaso/*')
global without sharing class Rest_ConsultaCaso {

	/**
	 * Devuelve la información correspondiente cuando se consulta un siniestro desde el área de clientes de Membership
	 *
	 * @param CAS_SEL_origen_web : origen solicitud de consulta caso
	 *
	 * Si es de Membership:
	 * 	@param CUE_TXT_Numero_Documento : Número de documento del cliente
	 * 	@param CaseNumber : Código de caso
	 *
	 * Si es de Ensura:
	 * @param POL_TXT_Id_Version_Poliza : Identificador de versión de la póliza
	 *
	 * @return información correspondiente a un siniestro
	 *
	 */
	@HttpGet
	global static Rest_ConsultaCaso_RP doGet() {
		Rest_ConsultaCaso_RP resultado = new Rest_ConsultaCaso_RP();

		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		String origenWeb = RestContext.request.params.get('CAS_SEL_origen_web');

		if (origenWeb == Label.CAS_ORIGEN_CLIENTE_WEB) {
			String numeroDocumento = RestContext.request.params.get('CUE_TXT_Numero_Documento');
			String numCaso = RestContext.request.params.get('CaseNumber');
			resultado = revisarRequestMembership(numeroDocumento, numCaso);
		}
		if (origenWeb == Label.CAS_ORIGEN_ENSURA) {
			String versionPoliza = RestContext.request.params.get('POL_TXT_Id_Version_Poliza');
			resultado = revisarRequestEnsura(versionPoliza);
		}
		system.debug(resultado);
		return resultado;
	}

	/**
	 * Método que comprueba que la RQ en caso de que sea de Ensura es correcto
	 *
	 * @param POL_TXT_Id_Version_Poliza: Identificador de versión de la póliza
	 *
	 * @return la información correspondiente referida al caso al que pertenece esa póliza
	 *
	 */
	public static Rest_ConsultaCaso_RP revisarRequestEnsura(String POL_TXT_Id_Version_Poliza) {
		Rest_ConsultaCaso_RP respuesta = new Rest_ConsultaCaso_RP();
		List<Case> listCasos;
		//Se valida que existe el número de póliza
		List<Version_ContratoServicio__c> poliza = validaPoliza(POL_TXT_Id_Version_Poliza);
		if (poliza == null || poliza.size() == 0) {
			respuesta.code = 'MEM-008';
			respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
			system.debug(respuesta);
			return respuesta;
		}
		//Si existe el número de póliza, tengo el Id de la cuenta, asique a partir de ahi saco todos los casos
		listCasos = [SELECT CaseNumber,CAS_DIV_Importe_Total__c,CAS_LKP_VersionPolizaContrato__r.Name,CAS_TXT_DirRiesgo_Pais__c,
		             CAS_SEL_DirRiesgo_Estado_Provincia__c,CAS_TXT_Direccion__c,CAS_TXT_DirRiesgo_CP__c,CAS_TXT_DirRiesgo_Poblacion__c,
		             CAS_TXT_Num_Caso_CIA__c,CAS_TXT_Num_Caso_HS__c,ClosedDate,CreatedDate,Id,ParentId,RecordType.Name,Status,Type FROM Case
		             WHERE AccountId =: poliza[0].POLV_LKP_PolizaContrato__r.AccountId];

		respuesta = getResponse(listCasos);
		respuesta = allResponse(poliza[0].POLV_LKP_PolizaContrato__r.AccountId, respuesta);
		system.debug(respuesta);
		return respuesta;
	}

	/**
	 * Método que comprueba si la póliza existe
	 *
	 * @param POL_TXT_Id_Version_Poliza: Identificador de versión de la póliza
	 *
	 * @return la información correspondiente a la pólizas
	 *
	 */
	public static List<Version_ContratoServicio__c> validaPoliza(String POL_TXT_Id_Version_Poliza){
		List<Version_ContratoServicio__c> poliza = [SELECT POLV_LKP_PolizaContrato__r.AccountId FROM Version_ContratoServicio__c WHERE Name =: POL_TXT_Id_Version_Poliza];
		return poliza;
	}

	/**
	 * Método que comprueba que la RQ en caso de que sea de Membership es correcto
	 *
	 * @param CUE_TXT_Numero_Documento: Número de documento del cliente
	 * @param CaseNumber: Código de caso
	 *
	 * @return la información correspondiente referida al caso al que pertenece ese número de caso
	 *
	 */
	public static Rest_ConsultaCaso_RP revisarRequestMembership(String CUE_TXT_Numero_Documento, String CaseNumber){
		Rest_ConsultaCaso_RP respuesta = new Rest_ConsultaCaso_RP();
		List<Case> validaCaso;
		List<Case> listCasos;

		//Se comprueba si existe el número de documento
		List<Account> validaCuenta = validarClienteByDNI(CUE_TXT_Numero_Documento);
		if (validaCuenta == null || validaCuenta.size() == 0) {
			validaCaso = validarClienteCasoByDNI(CUE_TXT_Numero_Documento);
			if (validaCaso == null || validaCaso.size() == 0) {
				respuesta.code = 'MEM-007';
				respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
				system.debug(respuesta);
				return respuesta;
			}
		}
		//Comprobar si me dan número de caso
		if (CaseNumber == null || CaseNumber.length() == 0) {
			//Tengo el DNI pero no el número de caso. Quiero todos los casos asociados a esa cuenta
			listCasos = [SELECT CaseNumber,CAS_DIV_Importe_Total__c,CAS_LKP_VersionPolizaContrato__r.Name,CAS_SEL_DirRiesgo_Estado_Provincia__c,CAS_TXT_Direccion__c,CAS_TXT_DirRiesgo_Pais__c,
			             CAS_TXT_DirRiesgo_CP__c,CAS_TXT_DirRiesgo_Poblacion__c,CAS_TXT_Num_Caso_CIA__c,CAS_TXT_Num_Caso_HS__c,ClosedDate,CreatedDate,Id,ParentId,RecordType.Name,Status,Type FROM Case
			             WHERE AccountId =: validaCuenta[0].Id AND CAS_LKP_Compania__r.CUE_TXT_Identificador__c =: Label.IDE_MEMBERSHIP];

			respuesta = getResponse(listCasos);
			respuesta = allResponse(validaCuenta[0].Id, respuesta);

		}
		else {
			//Tengo el DNI y el número de caso
			listCasos = [SELECT CaseNumber,CAS_DIV_Importe_Total__c,CAS_LKP_VersionPolizaContrato__r.Name,CAS_SEL_DirRiesgo_Estado_Provincia__c,CAS_TXT_Direccion__c,CAS_TXT_DirRiesgo_Pais__c,
			             CAS_TXT_DirRiesgo_CP__c,CAS_TXT_DirRiesgo_Poblacion__c,CAS_TXT_Num_Caso_CIA__c,CAS_TXT_Num_Caso_HS__c,ClosedDate,CreatedDate,Id,ParentId,RecordType.Name,Status,Type FROM Case
			             WHERE AccountId =: validaCuenta[0].Id AND CaseNumber =: CaseNumber AND CAS_LKP_Compania__r.CUE_TXT_Identificador__c =: Label.IDE_MEMBERSHIP];
			if (listCasos == null || listCasos.size() == 0) {
				respuesta.code = 'MEM-005';
				respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
				system.debug(respuesta);
				return respuesta;
			}
			respuesta = getResponse(listCasos);
			respuesta = allResponse(validaCuenta[0].Id, respuesta);

		}
		system.debug(respuesta);
		return respuesta;
	}

	/**
	 * Método para validar si existe el cliente a través del número de documento (Account)
	 *
	 * @param CUE_TXT_Numero_Documento: Número de documento del cliente
	 *
	 * @return información del cliente correspondiente a ese número de documento
	 *
	 */
	public static List<Account> validarClienteByDNI(String CUE_TXT_Numero_Documento) {
		List<Account> cuenta = [SELECT Id,CUE_TXT_PrimerApellido__c,CUE_TXT_SegundoApellido__c,Name FROM Account 
		                        WHERE CUE_TXT_Numero_Documento__c =: CUE_TXT_Numero_Documento];
		return cuenta;
	}

	/**
	 * Método para validar si existe el cliente a través del número de documento (Caso)
	 *
	 * @param CUE_TXT_Numero_Documento: Número de documento del cliente
	 *
	 * @return la información del caso correspondiente a ese número de documento
	 *
	 */
	public static List<Case> validarClienteCasoByDNI(String CUE_TXT_Numero_Documento) {
		List<Case> caso = [SELECT Id FROM Case WHERE CAS_TXT_Numero_Documento__c =: CUE_TXT_Numero_Documento];
		return caso;
	}

	/**
	 * Método para obtener la respuesta
	 *
	 * @param listCasos: listado de casos
	 *
	 * @return la información correspondiente al caso
	 *
	 */
	public static Rest_ConsultaCaso_RP getResponse(List<Case> listCasos) {
		Rest_ConsultaCaso_RP respuesta = new Rest_ConsultaCaso_RP();
		List<Rest_Case_RP> auxCasoList = new List<Rest_Case_RP>();
		for(Case caso : listCasos) {
			Rest_Case_RP casoAux = new Rest_Case_RP();

			casoAux.caseNumber = caso.CaseNumber;
			casoAux.IdCaso = caso.Id;
			casoAux.CAS_TXT_Num_Caso_CIA = caso.CAS_TXT_Num_Caso_CIA__c;
			casoAux.CAS_TXT_Num_Caso_HS = caso.CAS_TXT_Num_Caso_HS__c;
			casoAux.RecordType = caso.RecordType.Name;
			casoAux.CAS_TXT_Direccion = caso.CAS_TXT_Direccion__c;
			casoAux.CAS_TXT_DirRiesgo_CP = caso.CAS_TXT_DirRiesgo_CP__c;
			casoAux.Name = caso.CAS_TXT_DirRiesgo_Poblacion__c;
			casoAux.CAS_SEL_DirRiesgo_Estado_Provincia = caso.CAS_SEL_DirRiesgo_Estado_Provincia__c;
			casoAux.provinciaLiteral = Util_Listas_Seleccion.getLabelDesdeAPI('Case', 'CAS_SEL_DirRiesgo_Estado_Provincia__c').get(caso.CAS_SEL_DirRiesgo_Estado_Provincia__c);
			casoAux.Type = caso.Type;
			casoAux.tipoLiteral = Util_Listas_Seleccion.getLabelDesdeAPI('Case', 'Type').get(caso.Type);
			casoAux.CreatedDate = caso.CreatedDate;
			casoAux.Status = caso.Status;
			casoAux.estadoLiteral = Util_Listas_Seleccion.getLabelDesdeAPI('Case', 'Status').get(caso.Status);
			casoAux.ClosedDate = caso.ClosedDate;
			casoAux.POL_TXT_Id_Version_Poliza = caso.CAS_LKP_VersionPolizaContrato__r.Name;
			casoAux.CAS_DIV_Importe_Total = caso.CAS_DIV_Importe_Total__c ;
			casoAux.Parent = caso.ParentId ;

			//Llamada al método para recorrerme los WorkOrder y los presupuestos
			casoAux.listadoOrdenesTrabajo = completaWO(casoAux.IdCaso);
			casoAux.listadoPresupuesto = completaPres(casoAux.IdCaso);

			auxCasoList.add(casoAux);
		}
		respuesta.listadoCaso = auxCasoList;
		respuesta.code = 'MEM-001';
		respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
		system.debug(respuesta);
		return respuesta;
	}

	/**
	 * Método para obtener la respuesta
	 *
	 * @param cuentaId : identificador de cliente
	 * @param respuesta : respuesta con la información del caso
	 *
	 * @return la información correspondiente al caso y a la cuenta
	 *
	 */
	public static Rest_ConsultaCaso_RP allResponse (Id cuentaId, Rest_ConsultaCaso_RP respuesta) {
		List<Account> cuenta = [SELECT CUE_TXT_Numero_Documento__c,CUE_TXT_PrimerApellido__c,CUE_TXT_SegundoApellido__c,Name FROM Account 
		                        WHERE Id =: cuentaId];
		respuesta.CUE_TXT_Numero_Documento = cuenta[0].CUE_TXT_Numero_Documento__c;
		respuesta.Name = cuenta[0].Name;
		respuesta.CUE_TXT_PrimerApellido = cuenta[0].CUE_TXT_PrimerApellido__c;
		respuesta.CUE_TXT_SegundoApellido = cuenta[0].CUE_TXT_SegundoApellido__c;
		system.debug(respuesta);
		return respuesta;
	}

	/**
	 * Método para recorrer las órdenes de trabajo de un caso
	 *
	 * @param identCaso: identificador de un caso
	 *
	 * @return lista de órdenes de trabajo, con información correspondiente a cada una de ellas
	 *
	 */
	public static List<Rest_WorkOrder_RP> completaWO (Id identCaso) {
		List<String> listaIdWO = new List<String>();
		List<WorkOrder> listOrdTrabajo = [SELECT Id,OTR_DAT_Fecha_cambio_estado__c,OTR_DAT_Fecha_Primera_Cita__c,OTR_DAT_Fecha_Ultima_Cita__c,
		                                  OTR_LKP_Primera_Cita__r.AppointmentNumber,OTR_RES_Importe_partidas__c,OTR_SEL_Gremio__c,OTR_SEL_Rango_Primera_Cita__c,
		                                  OTR_SEL_Rango_Ultima_Cita__c,StartDate,Status,StopStartDate,WorkOrderNumber FROM WorkOrder WHERE CaseId =: identCaso 
		                                  AND RecordTypeId !=: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)];

		for (WorkOrder listaIdWOAux: listOrdTrabajo) {
			listaIdWO.add(listaIdWOAux.Id);
		}
		List<Factura__c> listaFactura = [SELECT Id, FAC_TXT_Numero_factura__c, FAC_LKP_WorkOrkder__c FROM Factura__c WHERE FAC_LKP_WorkOrkder__c IN : listaIdWO];
		List<Rest_WorkOrder_RP> auxWOList = new List<Rest_WorkOrder_RP>();
		for (WorkOrder wo: listOrdTrabajo) {
			Rest_WorkOrder_RP woAux = new Rest_WorkOrder_RP();
			woAux.WorkOrderNumber = wo.WorkOrderNumber;
			woAux.Status = wo.Status;
			woAux.estadoServicioLiteral = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'Status').get(wo.Status);
			woAux.IdOrdenTrabajo = wo.Id;
			woAux.OTR_DAT_Fecha_cambio_estado = wo.OTR_DAT_Fecha_cambio_estado__c;
			woAux.OTR_SEL_Gremio = wo.OTR_SEL_Gremio__c;
			woAux.gremioLiteral = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'OTR_SEL_Gremio__c').get(wo.OTR_SEL_Gremio__c);
			woAux.StartDate = wo.StartDate;
			woAux.StopStartDate = wo.StopStartDate;
			woAux.OTR_DAT_Fecha_Primera_Cita = wo.OTR_DAT_Fecha_Primera_Cita__c;
			woAux.OTR_SEL_Rango_Primera_Cita = wo.OTR_SEL_Rango_Primera_Cita__c;
			woAux.OTR_DAT_Fecha_Ultima_Cita = wo.OTR_DAT_Fecha_Ultima_Cita__c;
			woAux.OTR_SEL_Rango_Ultima_Cita = wo.OTR_SEL_Rango_Ultima_Cita__c;
			woAux.AppointmentNumber = wo.OTR_LKP_Primera_Cita__r.AppointmentNumber;
			woAux.OTR_RES_Importe_partidas = wo.OTR_RES_Importe_partidas__c ;
			//Bucle para añadir factura en caso de que tenga factura, ya que todos los wo no tienen fatura.
			for (Factura__c FacturaList: listaFactura) {
				if (wo.Id == FacturaList.FAC_LKP_WorkOrkder__c) {
					woAux.IdFactura = FacturaList.Id;
					woAux.FAC_TXT_Numero_factura = FacturaList.FAC_TXT_Numero_factura__c;
				}
			}
			auxWOList.add(woAux);
		}
		return auxWOList;
	}

	/**
	 * Método para recorrer los presupuestos de un caso
	 *
	 * @param identCaso: identificador de un caso
	 *
	 * @return lista de presupuestos de un caso
	 *
	 */
	/*Método para recorrer los presupuestos de un caso*/
	public static List<Rest_Presupuesto_RP> completaPres (Id identCaso) {
		List<Presupuesto__c> listPresupuesto = [SELECT Id,Name,PRE_SEL_Estado__c FROM Presupuesto__c WHERE PRE_LKP_Caso__c =: identCaso];

		List<Rest_Presupuesto_RP> auxPresList = new List<Rest_Presupuesto_RP>();
		for(Presupuesto__c presupuesto : listPresupuesto) {
			Rest_Presupuesto_RP presAux = new Rest_Presupuesto_RP();

			presAux.IdPresupuesto = presupuesto.Id;
			presAux.Name = presupuesto.Name;
			presAux.PRE_SEL_Estado = presupuesto.PRE_SEL_Estado__c;

			auxPresList.add(presAux);
		}
		return auxPresList;
	}	
}