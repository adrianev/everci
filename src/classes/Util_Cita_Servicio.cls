/**
 * Clase de funciones auxiliares relativas a las Citas de Servicio.
 * 
 * @author EVERIS
 */
public without sharing class Util_Cita_Servicio {

	public static final Set<String> SET_ESTADOS_ANULADOS = new Set<String>{
		Label.CIT_ESTADO_ANULADA,
		Label.CIT_ESTADO_ANULADA_POR_CAMBIO
	};

	public static final Set<String> SET_ESTADOS_CERRADOS = new Set<String>{
		Label.CIT_ESTADO_ANULADA,
		Label.CIT_ESTADO_ANULADA_POR_CAMBIO,
		Label.CIT_ESTADO_COMPLETADA
	};
	
	public static Boolean citaCreadaDesdeApp = false;

	// Control de ejecución del trigger de Cita de Servicio
	public static Integer ejecutaTrigger = 0;

	// Control para permitir o no eliminar una Cita de Servicio
	public static Boolean permiteELiminar = false;


	private static String getSelectFields(){
		return	'Id,' +
				'Account.CUE_CAS_Ola_calor__c,' +
				'Account.Name,' +
				'Account.ShippingPostalCode,' +
				'ActualEndTime,' +
				'ActualStartTime,' +
				'AppointmentNumber,' +
				'ArrivalWindowEndTime,' +
				'ArrivalWindowStartTime,' +
				'City,' +
				'Country,' +
				'CreatedDate,' +
				'CSE_CAS_Asignada__c,' +
				'CSE_CAS_Asignar_Como_Franquiciado__c,' +
				'CSE_CAS_Asignar_como_Urgencias__c,' +
				'CSE_CAS_Asignar_Mizad__c,' +
				'CSE_CAS_Asignar_territorio_prim_no_franq__c,' +
				'CSE_CAS_Autoasignar__c,' +
				'CSE_CAS_Cambio_de_cita__c,' +
				'CSE_CAS_Urgente__c,' +
				'CSE_DAT_Fecha_Hora_Fin_Nueva_Cita__c,' +
				'CSE_DAT_Fecha_Hora_Inicio_Nueva_Cita__c,' +
				'CSE_DAT_Fecha_para_nueva_cita__c,' +
				'CSE_DAT_Fecha_Proxima_Programacion__c,' +
				'CSE_LKP_Profesional_Programado__c,' +
				'CSE_NUM_Numero_de_Ofrecimientos__c,' +
				'CSE_SEL_Motivo_Desasignacion__c,' +
				'CSE_SEL_Tipo_Red__c,' +
				'CSE_TXT_Estado_Anterior__c,' +
				'CSE_TXT_Identificador__c,' +
				'Description,' +
				'DueDate,' +
				'EarliestStartTime,' +
				'OwnerId,' +
				'ParentRecordId,' +
				'ParentRecordType,' +
				'PostalCode,' +
				'SchedEndTime,' +
				'SchedStartTime,' +
				'ServiceTerritoryId,' +
				'State,' +
				'Status,' +
				'Street,' +
		 		'(SELECT Id, ServiceAppointmentId, ServiceResourceId FROM ServiceResources)';
	}


	/**
	 * Devuelve un mapa de Citas partir de un conjunto de IDs.
	 *
	 * @param setIdCitas: IDs de las Citas a buscar
	 * @return mapa de Citas encontradas
	 */
	public static Map<Id,ServiceAppointment> getMapCitasById(Set<Id> setIdCitas){
		Map<Id,ServiceAppointment> mapa = new Map<Id,ServiceAppointment>();
		if(setIdCitas != null && (!setIdCitas.isEmpty())){
			String soql = 'SELECT ' + getSelectFields() + ' ' +
						  'FROM ServiceAppointment ' +
						  'WHERE Id IN :setIdCitas';
			mapa = new Map<Id,ServiceAppointment>((List<ServiceAppointment>)Database.query(soql));
		}
		return mapa;
	}


	/**
	 * Devuelve un mapa de Citas partir de un conjunto de Números de Cita.
	 *
	 * @param setAppNum: conjunto de Números de Cita
+	 * @return mapa que contiene las Citas encontradas
	 */
	public static Map<Id,ServiceAppointment> getMapCitasByNum(Set<String> setAppNum){
		Map<Id,ServiceAppointment> mapa = new Map<Id,ServiceAppointment>();
		if(setAppNum != null && (!setAppNum.isEmpty())){
			String soql = 'SELECT ' + getSelectFields() + ' ' +
						  'FROM ServiceAppointment ' +
						  'WHERE AppointmentNumber IN :setAppNum';
			mapa = new Map<Id,ServiceAppointment>((List<ServiceAppointment>)Database.query(soql));
		}
		return mapa;
	}


	/**
	 * Devuelve un mapa de Citas a partir de un conjunto de IDs de Ordenes de Trabajo.
	 *
	 * @param setIdOTs: Conjunto de IDs de las OT padre de las Citas a buscar
	 * @return mapa de Citas encontradas
	 */
	public static Map<Id,ServiceAppointment> getMapCitasByOTs(Set<Id> setIdOTs){
		Map<Id,ServiceAppointment> mapa = new Map<Id,ServiceAppointment>();
		if(setIdOTs != null && (!setIdOTs.isEmpty())){
			String soql = 'SELECT ' + getSelectFields() + ' ' +
						  'FROM ServiceAppointment ' +
						  'WHERE ParentRecordId IN :setIdOTs ' +
						  'ORDER BY CreatedDate DESC';
			mapa = new Map<Id,ServiceAppointment>((List<ServiceAppointment>)Database.query(soql));
		}
		return mapa;
	}


	/**
	 * Devuelve un mapa de listas Citas agrupadas por OT a partir de un conjunto de IDs de OT
	 * y de unos estados excluidos.
	 *
	 * @param setIdOTs: Conjunto de IDs de las OT padre de las Citas a buscar
	 * @param estadosExcluidos: Conjunto de estados de Citas a descartar
	 * @return mapa de listas de Citas agrupadas por OT
	 */
	public static Map<Id, List<ServiceAppointment>> getMapCitasOTsNotInStatus(Set<Id> setIdOTs, Set<String> estadosExcluidos){
		Map<Id, List<ServiceAppointment>> mapa = new Map<Id, List<ServiceAppointment>>();
		if(setIdOTs != null && (!setIdOTs.isEmpty()) && estadosExcluidos != null && (!estadosExcluidos.isEmpty())){
			String soql = 'SELECT ' + getSelectFields() + ' ' +
						  'FROM ServiceAppointment ' +
						  'WHERE ParentRecordId IN :setIdOTs ' +
						  'AND Status NOT IN :estadosExcluidos ' +
						  'ORDER BY ParentRecordId, CreatedDate DESC';
			List<ServiceAppointment> lista = (List<ServiceAppointment>)Database.query(soql);
			for(ServiceAppointment registro : lista){
				List<ServiceAppointment> listaAux = mapa.get(registro.ParentRecordId);
				if(listaAux == null){
					listaAux = new List<ServiceAppointment>();
				}
				listaAux.add(registro);
				mapa.put(registro.ParentRecordId, listaAux);
			}
		}
		return mapa;
	}


	/**
	 * Devuelve una lista de Citas de una OT a partir de unos estados excluidos.
	 * 
	 * @param idOrdenTrabajo: Id de la Orden de Trabajo
	 * @param estadosExcluidos: Conjunto de estados de Citas a descartar
	 * @return lista de Citas de la OT que no están en los estado excluidos
	 */
	public static List<ServiceAppointment> getListCitasOTsNotInStatus(Id idOrdenTrabajo, Set<String> estadosExcluidos){
		List<ServiceAppointment> lista = new List<ServiceAppointment>();
		Set<Id> setIds = new Set<Id>();
		if(idOrdenTrabajo != null){
			setIds.add(idOrdenTrabajo);
		}
		Map<Id, List<ServiceAppointment>> mapa = getMapCitasOTsNotInStatus(setIds, estadosExcluidos);
		if(mapa.get(idOrdenTrabajo) != null){
			lista = mapa.get(idOrdenTrabajo);
		}
		return lista;
	}


	/**
	 * Devuelve un mapa de listas Citas agrupadas por OT a partir de un conjunto de IDs de OT
	 * y de unos estados incluidos.
	 *
	 * @param setIdOTs: Conjunto de IDs de las OT padre de las Citas a buscar
	 * @param estadosIncluidos: Conjunto de estados de Citas a devolver
	 * @return mapa de listas de Citas agrupadas por OT
	 */
	public static Map<Id, List<ServiceAppointment>> getMapCitasOTsInStatus(Set<Id> setIdOTs, Set<String> estadosIncluidos){
		Map<Id, List<ServiceAppointment>> mapa = new Map<Id, List<ServiceAppointment>>();
		if(setIdOTs != null && (!setIdOTs.isEmpty()) && estadosIncluidos != null && (!estadosIncluidos.isEmpty())){
			String soql = 'SELECT ' + getSelectFields() + ' ' +
						  'FROM ServiceAppointment ' +
						  'WHERE ParentRecordId IN :setIdOTs ' +
						  'AND Status IN :estadosIncluidos ' +
						  'ORDER BY ParentRecordId, CreatedDate DESC';
			List<ServiceAppointment> lista = (List<ServiceAppointment>)Database.query(soql);
			for(ServiceAppointment registro : lista){
				List<ServiceAppointment> listaAux = mapa.get(registro.ParentRecordId);
				if(listaAux == null){
					listaAux = new List<ServiceAppointment>();
				}
				listaAux.add(registro);
				mapa.put(registro.ParentRecordId, listaAux);
			}
		}
		return mapa;
	}


	/**
	 * Devuelve una lista de Citas de una OT a partir de unos estados incluidos.
	 * 
	 * @param idOrdenTrabajo: Id de la Orden de Trabajo
	 * @param estadosIncluidos: Conjunto de estados de Citas a devolver
	 * @return lista de Citas de la OT que están en los estado incluidos
	 */
	public static List<ServiceAppointment> getListCitasOTsInStatus(Id idOrdenTrabajo, Set<String> estadosIncluidos){
		List<ServiceAppointment> lista = new List<ServiceAppointment>();
		Set<Id> setIds = new Set<Id>();
		if(idOrdenTrabajo != null){
			setIds.add(idOrdenTrabajo);
		}
		Map<Id, List<ServiceAppointment>> mapa = getMapCitasOTsInStatus(setIds, estadosIncluidos);
		if(mapa.get(idOrdenTrabajo) != null){
			lista = mapa.get(idOrdenTrabajo);
		}
		return lista;
	}


	/**
	 * Recoge las ordenes de trabajo asociadas a citas de servicio
	 *
	 * @param	citasServicio	Lista de citas de servicio
	 * @return		Mapa con las ordenes de trabajo asociadas a las citas de servicio
	 * @see		Map, Id, WorkOrder
	 */
	public static Map<Id, WorkOrder> recogerOrdenesTrabajo(List<ServiceAppointment> citasServicio){
		Map<Id, WorkOrder> mapaRetorno = new Map<Id, WorkOrder>();
		Set<Id> idsOrdenesTrabajo = new Set<Id>();
		for(ServiceAppointment sa : citasServicio){
			if(sa.ParentRecordId != null){
				idsOrdenesTrabajo.add(sa.ParentRecordId);
			}
		}
		if(!idsOrdenesTrabajo.isEmpty()){
			mapaRetorno = new Map<Id, WorkOrder>(
				[SELECT Id,
						CreatedDate,
						CaseId,
						Case.Recordtype.Name,
						OTR_CAS_Asignar_Mizad__c,
						OTR_CAS_Urgente__c,
						OTR_LKP_Recurso_Servicio__c,
						OTR_SEL_Gremio__c,
						ServiceTerritoryId
				 FROM WorkOrder
				 WHERE Id IN :idsOrdenesTrabajo]);
		}
		return mapaRetorno;
	}

	/**
	 * Calcula la fecha real de inicio de la cita de servicio en funcion de si la orden de trabajo asociada es urgente
	 *
	 * @param	fechaOT	Fecha de creacion de la orden de trabajo asociada a la cita
	 * @param	urgente	Indica si la orden de trabajo asociada a la cita es urgente
	 * @return		Fecha de inicio real de la cita de servicio
	 * @see		DateTime
	 */
	public static DateTime calcularFechaInicio(DateTime fechaOT, Boolean urgente){
		DateTime fechaInicio;
		if(fechaOT != null){
			system.debug('>>>>fechaOT ' + fechaOT);
			system.debug('>>>>urgente ' + urgente);
			// Si es urgente, se suman 3 horas a la fecha de inicio
			// La fecha deberia haberse calculado anteriormente en el TRG_Orden_de_Trabajo si existia el metadato relacionado
			if(urgente){
				Integer horaUrgente = fechaOT.hour() + 3;
				/*//Si la hora para atender la incidencia está fuera del horario laboral se aplaza al dia siguiente a primera hora
	    		if(horaUrgente < 8 && horaUrgente > 20){
	    			DateTime nuevoDia = fechaOT.addDays(1);
	    			Time hora = Time.newInstance(8, 0, 0, 0);
	    			nuevoDia = nuevoDia.addDays(sumarDiasFinDeSemana(nuevoDia));
	    			fechaInicio = DateTime.newInstance(nuevoDia.date(), hora);
	    		}else{*/
				fechaInicio = fechaOT.addHours(3);
				//}
			}
			//Si no es urgente, se suma 1 dia a la fecha de inicio
			else{

				Time hora = Time.newInstance(8, 0, 0, 0);
				// Si el dia en el que se abre la incidencia es viernes, se aplaza al lunes a primera hora
				// Si el dia en el que se abre la incidencia cae en fin de semana, se aplaza al martes a primera hora
				// Si no, se aplaza al dia siguiente a primera hora
				DateTime nuevoDia = fechaOT.addDays(sumarDias(fechaOT));
				fechaInicio = DateTime.newInstance(nuevoDia.date(), hora);
			}
		}
		system.debug('>>>>fechaInicio ' + fechaInicio);
		return fechaInicio;
	}

	/**
	 * Calcula el dia de la semana de una fecha y, si es fin de semana, devuelve el numero de dias
	 * que se tienen que sumar para que sea lunes
	 *
	 * @param	dia	Fecha/Hora
	 * @return		Numero de dias que se tienen que sumar
	 * @see		Integer
	 */
	public static Integer sumarDias(DateTime dia){
		Integer diasSumar = 0;
		String nombreDia = dia.format('EEEE');
		system.debug('>>>>Dia actual ' + nombreDia);
		if(nombreDia == 'Friday'){
			diasSumar = 3;
		}else if(nombreDia == 'Saturday'){
			diasSumar = 3;
		}else if(nombreDia == 'Sunday'){
			diasSumar = 2;
		}else{
			diasSumar = 1;
		}
		return diasSumar;
	}


	/**
	 * Crea un mapa con el id de la cita de servicio como clave y el del recurso como valor a partir de una lista de Recursos asignados
	 *
	 * @param	arList	Lista de recursos asignados
	 * @return 	Map<Id,Id> Mapa con el id de la cita de servicio como clave y el del recurso como valor
	 * @see		Map, Id, AssignedResource
	 */
	public static map<Id, Id> obtenerMapaCitaServicioRecursoAsignado(List<AssignedResource> arList){
		Map<Id, Id> saSRMap = new Map<Id, Id>();
		for(AssignedResource ar : arList){
			saSRMap.put(ar.ServiceAppointmentId, ar.ServiceResourceId);
		}
		return saSRMap;
	}


	//Si es una cita de reclamación, se cambia el estado de la reclamación a pendiente de tratamiento
	//a menos que sea una reclamacion dormida
	public static void actualizarReclamacionesEstado(List<ServiceAppointment> citas){

		system.debug('-------actualizarReclamacionesEstado');

		Set<Id> woIDs = new Set<Id>();

		for(ServiceAppointment cita: citas){
			woIds.add(cita.ParentRecordID);
		}

		Id reclamacionRTId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);

		Map<Id,WorkOrder> ordenes = new Map<Id,WorkOrder>([Select Id,CaseId from workorder where id in :woIDs]);
		Map<Id,Case> casos = new Map<Id,Case>([Select id,recordtypeId,Status from case where id in (Select CaseId from workorder where id in :woIDs) and recordtypeId = :reclamacionRTId]);

		Map<Id,Case> casoPorWOID = new Map<Id,Case>();

		for(WorkOrder wo:ordenes.values()){
			if(casos.get(wo.CaseId) != null)
				casoPorWOID.put(wo.Id,casos.get(wo.CaseId));
		}

		List<Case> toUpdate = new List<Case>();

		for(ServiceAppointment cita:citas){
			Case caso = casoPorWOID.get(cita.ParentRecordID);
			if(caso != null && caso.Status != Label.CAS_ESTADO_RECLAMACION_DORMIDA){
				caso.Status = Label.CAS_ESTADO_PDTE_TRATAMIENTO;
				toUpdate.add(caso);
			}
		}

		update toUpdate;
	}   

	/**
	  * Devuelve los albaranes de la lista de citas que se pasa como argumento
	  * 
	  * @param citas: lista de ServiceAppointment
	  * 
	  * @return mapa de Id de cita a lista de albaranes
	  */
	public static Map<Id,List<ContentVersion>> getMapaAlbaranesPorCita(List<ServiceAppointment> citas){
		Map<Id, List<ContentVersion>> mapa = new Map<Id, List<ContentVersion>>();
		Set<Id> setIds = new Set<Id>();
		for(ServiceAppointment cita : citas){
			setIds.add(cita.Id);
		}
		if(!setIds.isEmpty()){
			List<ContentVersion> lista = Util_ContentVersion.getCVBYFirstPublishLocationId(setIds).values();
			/*List<ContentVersion> lista = [SELECT Id,
												 CreatedDate,
												 FirstPublishLocationId
									  	  FROM ContentVersion
									  	  WHERE FirstPublishLocationId IN :setIds
									  	  ORDER BY FirstPublishLocationId, CreatedDate DESC];*/
			for(ContentVersion registro : lista){
				List<ContentVersion> listaAux = mapa.get(registro.FirstPublishLocationId);
				if(listaAux == null){
					listaAux = new List<ContentVersion>();
				}
				listaAux.add(registro);
				mapa.put(registro.FirstPublishLocationId,listaAux);
			}
		}
		return mapa;
	}

	/**
	 * Informa si en un territorio de servicio es festivo o no.
	 *
	 * @param territorioServicio: ID del territorio de servicio
	 * @return true si es festivo en dicho territorio de servicio, false en caso contrario
	 */
	public static Boolean esFestivo(Id territorioServicio){
		List<Festivos__c> festivosLista = new List<Festivos__c>();
		if(territorioServicio != null){
			festivosLista = [SELECT FES_SEL_Tipo_de_Festivo__c,FES_DAT_Fecha__c,FES_LKP_Territorio__c 
				 			 FROM Festivos__c
							 WHERE FES_DAT_Fecha__c = :Date.today()
							 AND ((FES_LKP_Territorio__c = :territorioServicio 
							 AND FES_SEL_Tipo_de_Festivo__c = 'Local') 
							 OR FES_SEL_Tipo_de_Festivo__c = 'Nacional')];
		}
		return !festivosLista.isEmpty();
	}

	/**
	 * Devuelve los SchedulingPolicy a partir de un conjunto de nombres.
	 *
	 * @param setName: nombres de la políticas buscadas
	 * @return mapas con las políticas encontradas
	 */
	public static Map<Id,FSL__Scheduling_Policy__c> queryMapSchedulingPolicy(Set<String> setName){
		Map<Id,FSL__Scheduling_Policy__c> mapa = new Map<Id,FSL__Scheduling_Policy__c>();
		for(List<FSL__Scheduling_Policy__c> lista : [select id from FSL__Scheduling_Policy__c where Name IN :setName]){
			mapa.putAll(lista);
		}
		return mapa;
	}
	
	/**
	 * Obtiene a partir de un siniestro, el listado de perjudicados asociados
	 *
	 *
	 * @param setIdOTPadre
	 * @param setIdUser
	 * @param setEstados
	 * @return mapa con el recurso asignado a la OT padre si se corresponde con el usuario actual y la cita de servicio está en curso
	 */
	public static Map<Id, AssignedResource> queryRecursosAsignados(Set<Id> setIdOTPadre, Set<Id> setIdUser, Set<String> setEstados) {
        Map<Id, AssignedResource> mapaRecursos=new Map<Id, AssignedResource>();
		if(!setIdOTPadre.isEmpty() && !setIdUser.isEmpty() && !setEstados.isEmpty()) {
        	for(List<AssignedResource> listaRecursosAux:[SELECT Id FROM AssignedResource 
			                         					WHERE ServiceAppointment.ParentRecordId IN :setIdOTPadre
			                           					AND ServiceResource.RelatedRecordId IN :setIdUser
			                            				AND ServiceAppointment.Status IN :setEstados]) {
         	   mapaRecursos.putAll(listaRecursosAux);
       		}
		}
        return mapaRecursos;
	}

	/**
	 * Obtiene a partir de un siniestro, el listado de perjudicados asociados
	 *
	 * @param setIdRelatedRecords: conjunto de registros relacionados
	 * @return mapa con recursos de servicio
	 */
	public static Map<Id, ServiceResource> queryRecursoByRelatedRecord(Set<Id> setIdRelatedRecords) {
        Map<Id, ServiceResource> mapaRecursos=new Map<Id, ServiceResource>();
		if(!setIdRelatedRecords.isEmpty() && setIdRelatedRecords!=null) {
        	for(List<ServiceResource> listaRecursosAux:[SELECT RelatedRecordId 
					 FROM ServiceResource 
					 WHERE RelatedRecordId IN :setIdRelatedRecords]) {
         	   mapaRecursos.putAll(listaRecursosAux);
       		}
		}
        return mapaRecursos;
	}


	/**
	 * Devuelve el ID de una SchedulingPolicy dado su nombre.
	 *
	 * @param nombre: nombre de la política
	 * @return Id de la política
	 */
	/*public static Id getSchedulingPolicyId(String nombre){
		Id idSP = null;
		List<FSL__Scheduling_Policy__c> lista = [select id from FSL__Scheduling_Policy__c where Name = :nombre limit 1];
		if(!lista.isEmpty()){
			idSP = lista.get(0).Id;
		}
		return idSP;
	}*/
	
	
	/**
	 * Obtiene recursos excluidos,designada o rechazada a los que les ha caducado la cita para poder programarla de nuevo
	 *
	 * @param setIdProgramadasyAct: conjunto de ids de citas programadas y citas actualizadas
	 * @param setEstado: conjunto de estados
	 *
	 * @return mapa con historico de asignaciones
	 */
	public static Map<Id, Historico_de_Asignaciones__c> mapaHistCitaEstado(Set<Id> setIdProgramadasyAct,Set<String> setEstado) {
        Map<Id, Historico_de_Asignaciones__c> mapaRecursos=new Map<Id, Historico_de_Asignaciones__c>();
		if(!setIdProgramadasyAct.isEmpty() && setIdProgramadasyAct!=null && !setEstado.isEmpty() && setEstado!=null) {
        	for(List<Historico_de_Asignaciones__c> listaRecursosAsig: [SELECT HAS_LKP_Profesional__c,
																				 HAS_LKP_Cita_de_Servicio__c,
																				 HAS_LKP_Orden_de_trabajo__c,
																				 HAS_TXT_Estado_Nuevo_Cita__c
																	  FROM Historico_de_Asignaciones__c 
																	  WHERE HAS_LKP_Cita_de_Servicio__c IN :setIdProgramadasyAct
																	  AND HAS_TXT_Estado_Nuevo_Cita__c = :setEstado]) {
         	   mapaRecursos.putAll(listaRecursosAsig);
       		}
		}
        return mapaRecursos;
	}
	
	/**
	 * Obtiene recursos excluidos a los que les ha caducado la cita para poder programarla de nuevo
	 *
	 * @param setIdProgramadasyAct: conjunto de ids de citas programadas y citas actualizadas
	 * @param setEstado: conjunto de estados
	 *
	 * @return mapa con AggregateResult
	 */
	public static Map<Id, AggregateResult> mapaHistCitaEstadoAgg(Set<Id> setIdProgramadasyAct,Set<String> setEstado) {
        Map<Id, AggregateResult> mapaRecursos=new Map<Id, AggregateResult>();
		if(!setIdProgramadasyAct.isEmpty() && setIdProgramadasyAct!=null && !setEstado.isEmpty() && setEstado!=null) {
        	for(List<AggregateResult> listaRecursosAsig: [SELECT HAS_LKP_Cita_de_Servicio__r.ParentRecordId ORDEN,
																	HAS_LKP_Profesional__c PROFESIONAL,
																	count(Id) CONTADOR
														FROM Historico_de_Asignaciones__c
														WHERE HAS_LKP_Cita_de_Servicio__c IN :setIdProgramadasyAct
														AND HAS_TXT_Estado_Nuevo_Cita__c = :setEstado
														GROUP BY HAS_LKP_Cita_de_Servicio__r.ParentRecordId, HAS_LKP_Profesional__c]) {
         	   mapaRecursos.putAll(listaRecursosAsig);
       		}
		}
        return mapaRecursos;
	}
	
	/**
	 * Crea una nueva cita a partir de una cita anterior.
	 * @param citaAnterior: cita a clonar para crear la nueva cita
	 *
	 * @return nueva cita
	 */
	public static ServiceAppointment nuevaCita(ServiceAppointment citaAnterior){
		ServiceAppointment nuevaCita = citaAnterior.clone(false, true, false, false);
		nuevaCita.ActualEndTime = null;
		nuevaCita.ActualStartTime = null;
		nuevaCita.ArrivalWindowEndTime = null;
		nuevaCita.ArrivalWindowStartTime = null;
		nuevaCita.CSE_CAS_Asignada__c = false;
		nuevaCita.CSE_CAS_Autoasignar__c = false;
		nuevaCita.CSE_CAS_Cambio_de_cita__c = false;
		nuevaCita.CSE_DAT_Fecha_Hora_Fin_Nueva_Cita__c = null;
		nuevaCita.CSE_DAT_Fecha_Hora_Inicio_Nueva_Cita__c = null;
		nuevaCita.CSE_DAT_Fecha_para_nueva_cita__c = null;
		nuevaCita.CSE_DAT_Fecha_Proxima_Programacion__c = null;
		nuevaCita.CSE_LKP_Profesional_Programado__c = null;
		nuevaCita.CSE_NUM_Numero_de_Ofrecimientos__c = 0;
		nuevaCita.CSE_SEL_Motivo_Desasignacion__c = null;
		nuevaCita.CSE_SEL_Tipo_Red__c = null;
		nuevaCita.CSE_TXT_Estado_Anterior__c = null;
		nuevaCita.CSE_TXT_Identificador__c = null;
		nuevaCita.Description = null;
		nuevaCita.DueDate = null;
		nuevaCita.EarliestStartTime = null;
		nuevaCita.SchedEndTime = null;
		nuevaCita.SchedStartTime = null;
		nuevaCita.Status = Label.CIT_ESTADO_PTE_ASIGNAR;
		return nuevaCita;
	}
}