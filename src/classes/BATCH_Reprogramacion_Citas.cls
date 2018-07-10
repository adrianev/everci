public without sharing class BATCH_Reprogramacion_Citas implements Database.Batchable<sObject>, Database.Stateful{
	
	private Integer minutosQuery;
	private static final String politicaAsignacion = 'Política de Asignación – Geolocalización';
	private static final String politicaGeolocalizacion = 'Política de Asignación – Geolocalización';
	private static Integer horasParaAsignacionManual = 12;
	private static Integer minutosParaAsignacionManual = 10;
	private static final Integer tiempoReprogramacionUrgente = 5;
	private static final Integer tiempoReprogramacionNoUrgente = 20;
	private DateTime fechaHoy = DateTime.now();
	
	
	String query = 'SELECT id, EarliestStartTime, DueDate, ArrivalWindowStartTime, ArrivalWindowEndTime, Status, CreatedDate, '+
						' CSE_CAS_Asignar_Mizad__c, CSE_CAS_Asignar_Como_Franquiciado__c, CSE_CAS_Asignar_territorio_prim_no_franq__c, '+
						' CSE_NUM_Numero_de_Ofrecimientos__c, CSE_CAS_Urgente__c, CSE_DAT_Fecha_Proxima_Programacion__c, ParentRecordId, ServiceTerritoryId'+
						' FROM ServiceAppointment WHERE '+
						' (CSE_DAT_Fecha_Proxima_Programacion__c =: dt AND Status = \''+ Label.CIT_ESTADO_PROGRAMADO +'\') OR (Status = \''+ Label.CIT_ESTADO_PTE_ASIGNAR +'\''+
						' AND ArrivalWindowEndTime >=: fechaHoy) LIMIT 200';
	
	public BATCH_Reprogramacion_Citas(Integer minutos){
		minutosQuery = minutos;
	}

	 /* ---------------------------------------------------------------------------------------------------------------------------------------
		BATCHABLE METHODS
	----------------------------------------------------------------------------------------------------------------------------------------*/
	public Database.QueryLocator start(final Database.BatchableContext BC) {
		
		DateTime dt = DateTime.newInstance(DateTime.now().year(), DateTime.now().month(), DateTime.now().day(), DateTime.now().hour(), minutosQuery, 00);

		System.debug('query '+query);
		return Database.getQueryLocator(query);
	}
  
	public void execute(final Database.BatchableContext BC, final List<sObject> scope) {

		// Obtener la configuración para el número máximo de ofrecimientos
		Integer numMaxOfrecimientos = 1;
		try {
			numMaxOfrecimientos = Integer.valueOf(Label.FSL_NUM_MAX_OFRECIMIENTOS);
		}
		catch(Exception e){
			system.debug('El valor ' + Label.FSL_NUM_MAX_OFRECIMIENTOS + ' de la etiqueta FSL_NUM_MAX_OFRECIMIENTOS no es un número válido.');
			numMaxOfrecimientos = 1;
		}

		// PASO 1: NO ACEPTACIÓN DE LAS CITAS PROGRAMADAS QUE CUMPLEN LAS CONDICIONES DE REPROGRAMACIÓN
		List<ServiceAppointment> saList = new List<ServiceAppointment> ();
		Set<Id> saSet = new Set<Id>();
		Set<Id> woSet = new Set<Id>();
		Set<Id> setTodosTerritorios = new Set<Id>();
		Set<String> setTipoFestivo = new Set<String>();
		for(ServiceAppointment sa:(List<ServiceAppointment>) scope){
			// Se actualiza el estado de las citas que están programadas a no aceptadas
			if(sa.Status == Label.CIT_ESTADO_PROGRAMADO){
				sa.Status = Label.CIT_ESTADO_CADUCADO;
				saList.add(sa);
			}
			saSet.add(sa.Id);
			// Se recogen las OT asociadas a las citas que van a pasar a Pendiente de asignación manual. 
			// Inicialmente todas por la configuración del paso a manual
			woSet.add(sa.ParentRecordId);
			if(!sa.CSE_CAS_Urgente__c){
				setTodosTerritorios.add(sa.ServiceTerritoryId);
			}
		}
		if (!Test.isRunningTest()) update saList;
		
		// Comprobación de si es horario laboral: Fin de semana, fuera de horas, nacional, territorio
		Integer diaDeLaSemana = Date.today().toStartOfWeek().daysBetween(Date.today());
		boolean esFinDeSemana = diaDeLaSemana == 5 || diaDeLaSemana == 6; 

		boolean horaFuera = DateTime.now().time() > Time.newInstance(20, 00, 00, 00) || DateTime.now().time() < Time.newInstance(8, 00, 00, 00) ;
					
		boolean esFestivo = false;
		setTipoFestivo.add('Local');
		setTipoFestivo.add('Nacional');
		/*List<Festivos__c> festivosLista = [
			SELECT 	FES_SEL_Tipo_de_Festivo__c, FES_DAT_Fecha__c, FES_LKP_Territorio__c 
			FROM 	Festivos__c
			WHERE 	FES_DAT_Fecha__c = :Date.today()
					AND ((FES_LKP_Territorio__c IN :setTodosTerritorios 
					AND FES_SEL_Tipo_de_Festivo__c = 'Local') 
					OR FES_SEL_Tipo_de_Festivo__c = 'Nacional')];*/
		List<Festivos__c> festivosLista = Util_Festivos.getFestTerritorios(setTodosTerritorios,setTipoFestivo).values();
		Set<String> festivosSet = new Set<String>();
		for(Festivos__c fest: festivosLista){
			if(fest.FES_SEL_Tipo_de_Festivo__c == 'Nacional'){
	 			esFestivo = true;
			}
			else {
	 			festivosSet.add(fest.FES_LKP_Territorio__c);
			}
		}
		
		// Se fuerza el borrado de los datos de la caché antes de hacer la siguiente iteración
		if (TRG_Handler_Cita_de_Servicio.citaDesasignada!=null)TRG_Handler_Cita_de_Servicio.citaDesasignada.clear();
		if (TRG_Handler_Cita_de_Servicio.citaCompletada!=null)TRG_Handler_Cita_de_Servicio.citaCompletada.clear();
		if (TRG_Handler_Cita_de_Servicio.citaAsignada!=null)TRG_Handler_Cita_de_Servicio.citaAsignada.clear();
		if (TRG_Handler_Cita_de_Servicio.citaNoAceptado!=null)TRG_Handler_Cita_de_Servicio.citaNoAceptado.clear();
		if (TRG_Handler_Cita_de_Servicio.citaRechazado!=null)TRG_Handler_Cita_de_Servicio.citaRechazado.clear();
		
		
		// PASO 2: REPROGRAMACIÓN DE CITAS Y PASO A MANUAL DE LAS QUE ESTÉN A X HORAS DE VENCER
		// Se recuperan las políticas de asignación para poder elegir con cual programamos la cita
		Id schedulingPolicyId=[select id from FSL__Scheduling_Policy__c where Name =: politicaAsignacion limit 1].Id;
		Id schedulingPolicyGeoId=[select id from FSL__Scheduling_Policy__c where Name =: politicaGeolocalizacion limit 1].Id;
		
		// Se recuperan las citas actualizadas en el paso anterior
		/*Map<Id,ServiceAppointment> saMapUpdated1stStep = new Map<Id,ServiceAppointment>([SELECT id, EarliestStartTime, DueDate, ArrivalWindowStartTime, CreatedDate,
															ArrivalWindowEndTime,OwnerId,ParentRecordId, Status, CSE_NUM_Numero_de_Ofrecimientos__c, 
															CSE_CAS_Urgente__c, CSE_DAT_Fecha_Proxima_Programacion__c, CSE_SEL_Tipo_Red__c, ServiceTerritoryId
													  		FROM ServiceAppointment WHERE Id IN: saSet]);*/
		Map<Id,ServiceAppointment> saMapUpdated1stStep = Util_Cita_servicio.getMapCitasById(saSet);
		
		// Se obtienen las OT relacionadas con las citas que pasan a asignación manual										
		/*Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>([SELECT Case.OwnerId, caseId, 
																  Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
																  OTR_SEL_Gremio__c, WorkType.TDT_TXT_Identificador__c,
																  PostalCode, OTR_CAS_Urgente__c 
														  FROM WorkOrder WHERE Id IN: woSet]);*/
		Map<Id, WorkOrder> woMap = Util_Orden_Trabajo.queryMapOTById(woSet);
        system.debug(woMap + ' que pasaaaa');
		
		List<ServiceAppointment> saListUpdate2ndStep = new List<ServiceAppointment>(); 
		Set<Id> saSetIdNoReprogramadaInicial = new Set<Id>();
		Set<Id> saSetIdNoReprogramadaActualizada = new Set<Id>();
		
		// Se recuperan los datos por defecto en caso de que no esté parametrizada la combinación
		Set<String> setNombres = new Set<String>();
		setNombres.add('Defecto_No_Urgencia');
		//List<Cambios_a_Cita_Manual_Motor__mdt> ccmNoUrgente = [SELECT CCM_DEC_Tiempo__c FROM Cambios_a_Cita_Manual_Motor__mdt WHERE DeveloperName ='Defecto_No_Urgencia' LIMIT 1];
		List<Cambios_a_Cita_Manual_Motor__mdt> ccmNoUrgente = Util_Metadatos.getCitMan(setNombres).values();
		//List<Cambios_a_Cita_Manual_Motor__mdt> ccmUrgente = [SELECT CCM_DEC_Tiempo__c FROM Cambios_a_Cita_Manual_Motor__mdt WHERE DeveloperName ='Defecto_Urgencia' LIMIT 1];
		setNombres = new Set<String>();
		setNombres.add('Defecto_Urgencia');
		List<Cambios_a_Cita_Manual_Motor__mdt> ccmUrgente =Util_Metadatos.getCitMan(setNombres).values();
		for(ServiceAppointment sa:saMapUpdated1stStep.values()){
			// Recuperación de datos de parametrización: dependiente de cp, franja horaria, gremio, cia, suceso y urgencia
			// Query en bucle por metadatos: permitido
			/*List<Cambios_a_Cita_Manual_Motor__mdt> ccmList = [SELECT CCM_TXT_CP__c, CCM_SEL_Franja_Horaria__c, CCM_TXT_Gremio__c, 
																	 CCM_TXT_Identificador_CIA__c, CCM_TXT_Suceso__c, CCM_DEC_Tiempo__c,
																	 CCM_CAS_Urgencia__c
															  FROM Cambios_a_Cita_Manual_Motor__mdt
															  WHERE CCM_TXT_CP__c =: woMap.get(sa.ParentRecordId).PostalCode AND
															  		CCM_TXT_Gremio__c =: woMap.get(sa.ParentRecordId).OTR_SEL_Gremio__c AND
															  		CCM_TXT_Identificador_CIA__c  =: woMap.get(sa.ParentRecordId).Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c AND
															  		CCM_TXT_Suceso__c  =: woMap.get(sa.ParentRecordId).WorkType.TDT_TXT_Identificador__c AND
																				CCM_CAS_Urgencia__c =: woMap.get(sa.ParentRecordId).OTR_CAS_Urgente__c];*/
            system.debug(woMap.get(sa.ParentRecordId) + ' PrentRecord iD');
			Set<String> setCodigo = new Set<String>();
			setCodigo.add(woMap.get(sa.ParentRecordId).PostalCode);
			Set<String> setGremio = new Set<String>();
			setGremio.add(woMap.get(sa.ParentRecordId).OTR_SEL_Gremio__c);
			Set<String> setCia = new Set<String>();
			setCia.add(woMap.get(sa.ParentRecordId).Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c);
			Set<String> setSuceso = new Set<String>();
			setSuceso.add(woMap.get(sa.ParentRecordId).WorkType.TDT_TXT_Identificador__c);
			Boolean urgencia =woMap.get(sa.ParentRecordId).OTR_CAS_Urgente__c;
			List<Cambios_a_Cita_Manual_Motor__mdt> ccmList = Util_Metadatos.getCitManExt(setCodigo,setGremio,setCia,setSuceso,urgencia).values();
			
			if(sa.ArrivalWindowStartTime != null && sa.ArrivalWindowEndTime != null){
				DateTime fechaComparar = sa.ArrivalWindowStartTime;
				for(Cambios_a_Cita_Manual_Motor__mdt ccm:ccmList){
					if(ccm.CCM_SEL_Franja_Horaria__c == 'Todas' || ccm.CCM_SEL_Franja_Horaria__c == '' || ccm.CCM_SEL_Franja_Horaria__c == null){
						minutosParaAsignacionManual = woMap.get(sa.ParentRecordId).OTR_CAS_Urgente__c? (Integer)ccm.CCM_DEC_Tiempo__c:minutosParaAsignacionManual;
						horasParaAsignacionManual = !woMap.get(sa.ParentRecordId).OTR_CAS_Urgente__c? (Integer)ccm.CCM_DEC_Tiempo__c:horasParaAsignacionManual;
					}
					else {
						Time horaInicio = Time.newInstance(Integer.valueof(ccm.CCM_SEL_Franja_Horaria__c.split('-').get(0)), 00, 00, 00);
						Time horaFin = Time.newInstance(Integer.valueof(ccm.CCM_SEL_Franja_Horaria__c.split('-').get(1)), 00, 00, 00);
						minutosParaAsignacionManual = woMap.get(sa.ParentRecordId).OTR_CAS_Urgente__c && fechaComparar.time() >= horaInicio && fechaComparar.time() <= horaFin? (Integer)ccm.CCM_DEC_Tiempo__c:minutosParaAsignacionManual;
						horasParaAsignacionManual = !woMap.get(sa.ParentRecordId).OTR_CAS_Urgente__c && fechaComparar.time() >= horaInicio && fechaComparar.time() <= horaFin? (Integer)ccm.CCM_DEC_Tiempo__c:horasParaAsignacionManual;
					}
				}
			}												  		
			minutosParaAsignacionManual = ccmList.isEmpty() && (woMap.get(sa.ParentRecordId).OTR_CAS_Urgente__c && !ccmUrgente.isEmpty())?(Integer)ccmUrgente.get(0).CCM_DEC_Tiempo__c:minutosParaAsignacionManual;
			horasParaAsignacionManual = ccmList.isEmpty() && (woMap.get(sa.ParentRecordId).OTR_CAS_Urgente__c && !ccmUrgente.isEmpty())?(Integer)ccmNoUrgente.get(0).CCM_DEC_Tiempo__c:horasParaAsignacionManual;
			
			boolean motorApagado = !sa.CSE_CAS_Urgente__c && (esFinDeSemana || esFestivo || horaFuera || festivosSet.contains(sa.ServiceTerritoryId));
			// Paso a asignación manual y creación de citas asociadas
			if(!sa.CSE_CAS_Urgente__c && sa.ArrivalWindowStartTime != null && DateTime.now() > sa.ArrivalWindowStartTime.addHours(- horasParaAsignacionManual)){
				sa.Status = Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL;
				saListUpdate2ndStep.add(sa);
				saSetIdNoReprogramadaActualizada.add(sa.Id);
			}
			else if(sa.CSE_CAS_Urgente__c && sa.CreatedDate != null && DateTime.now() > sa.CreatedDate.addMinutes(minutosParaAsignacionManual)){
				sa.Status = Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL;
				saListUpdate2ndStep.add(sa);
				saSetIdNoReprogramadaActualizada.add(sa.Id);
			}
			else if(!motorApagado && sa.ArrivalWindowStartTime != null && sa.ArrivalWindowEndTime != null){
				// Intento de programación inicial de la cita
				Id politica = schedulingPolicyGeoId;
				FSL.ScheduleResult scheduleResult = FSL.ScheduleService.Schedule(politica, sa.Id);
				// Si la cita no se ha podido programar se recuperan los ids de la misma para comprobar su historial de asignación y volver a programar
				// la cita a los profesionales que han pasado a Caducado
				if(scheduleResult == null){
					saSetIdNoReprogramadaInicial.add(sa.Id);
				}
			}
		}
		update saListUpdate2ndStep;
		
		Set<Id> setIdsCitas = new Set<Id>();
		setIdsCitas.addAll(saSetIdNoReprogramadaInicial);
		setIdsCitas.addAll(saSetIdNoReprogramadaActualizada);
		Set<String> setEstados = new Set<String>{Label.CIT_ESTADO_CADUCADO,Label.CIT_ESTADO_DESASIGNADA,Label.CIT_ESTADO_RECHAZADO};
		
		// PASO 3: Se van a eliminar los recursos excluidos a los que les ha caducado la cita para poder programarla de nuevo una vez no hay slots disponibles
		List<Historico_de_Asignaciones__c> hasList = Util_Cita_Servicio.mapaHistCitaEstado(setIdsCitas,setEstados).values();
													/*[SELECT HAS_LKP_Profesional__c,
															 HAS_LKP_Cita_de_Servicio__c,
															 HAS_LKP_Orden_de_trabajo__c,
															 HAS_TXT_Estado_Nuevo_Cita__c
													FROM Historico_de_Asignaciones__c 
													WHERE (HAS_LKP_Cita_de_Servicio__c IN :saSetIdNoReprogramadaInicial
													OR HAS_LKP_Cita_de_Servicio__c IN :saListUpdate2ndStep)
													AND (HAS_TXT_Estado_Nuevo_Cita__c = :Label.CIT_ESTADO_CADUCADO
													OR HAS_TXT_Estado_Nuevo_Cita__c = :Label.CIT_ESTADO_DESASIGNADA
													OR HAS_TXT_Estado_Nuevo_Cita__c = :Label.CIT_ESTADO_RECHAZADO)];*/

		AggregateResult[] ofrecimientosCaduc = Util_Cita_Servicio.mapaHistCitaEstadoAgg(setIdsCitas,new Set<String>{Label.CIT_ESTADO_CADUCADO}).values();
												/*[SELECT HAS_LKP_Cita_de_Servicio__r.ParentRecordId ORDEN,
													HAS_LKP_Profesional__c PROFESIONAL,
													count(Id) CONTADOR
												FROM Historico_de_Asignaciones__c
												WHERE (HAS_LKP_Cita_de_Servicio__c IN :saSetIdNoReprogramadaInicial
												OR HAS_LKP_Cita_de_Servicio__c IN :saListUpdate2ndStep)
												AND HAS_TXT_Estado_Nuevo_Cita__c = :Label.CIT_ESTADO_CADUCADO
												GROUP BY HAS_LKP_Cita_de_Servicio__r.ParentRecordId, HAS_LKP_Profesional__c];*/
		Map<String,Integer> mapaOfrecimientosCaduc = new Map<String,Integer>();
		for(AggregateResult ofrecCaduc : ofrecimientosCaduc){
			// MAPA: (ID-SERVICIO_ID-PROFESIONAL : Nº de Ofrecimientos Caducados)
			mapaOfrecimientosCaduc.put(ofrecCaduc.get('ORDEN') + '_' + ofrecCaduc.get('PROFESIONAL'), Integer.valueOf(ofrecCaduc.get('CONTADOR')));
		}

		Map<Id, Set<Id>> woProfMap = new Map<Id, Set<Id>> ();
		Map<Id, Set<Id>> woRechDesasProfMap = new Map<Id, Set<Id>> ();
		Set<Id> todosProfSet = new Set<Id>();
		for(Historico_de_Asignaciones__c has: hasList){
			if(has.HAS_TXT_Estado_Nuevo_Cita__c == Label.CIT_ESTADO_CADUCADO){
				if(woProfMap.keySet().contains(has.HAS_LKP_Orden_de_trabajo__c)){
					woProfMap.get(has.HAS_LKP_Orden_de_trabajo__c).add(has.HAS_LKP_Profesional__c);
				}else{
					Set<Id> setProfId = new Set<Id>();
					setProfId.add(has.HAS_LKP_Profesional__c);
					woProfMap.put(has.HAS_LKP_Orden_de_trabajo__c, setProfId);
				}
			}else{
				if(woRechDesasProfMap.keySet().contains(has.HAS_LKP_Orden_de_trabajo__c)){
					woRechDesasProfMap.get(has.HAS_LKP_Orden_de_trabajo__c).add(has.HAS_LKP_Profesional__c);
				}else{
					Set<Id> setProfId = new Set<Id>();
					setProfId.add(has.HAS_LKP_Profesional__c);
					woRechDesasProfMap.put(has.HAS_LKP_Orden_de_trabajo__c, setProfId);
				}
			}
			todosProfSet.add(has.HAS_LKP_Profesional__c);
		}
		
		List<ResourcePreference> rpList = Util_Service_Resource.getRPByRelatedRecordAndPreferenceType(woProfMap.keySet(),new Set<String>{'Excluded'}).values();
		//List<ResourcePreference> rpList = [SELECT Id, RelatedRecordId, ServiceResourceId, PreferenceType FROM ResourcePreference WHERE PreferenceType = 'Excluded' and RelatedRecordId IN: woProfMap.keySet()];
		List<ResourcePreference> rpListDelete = new List<ResourcePreference>();
		for(ResourcePreference rp:rpList){
			Integer ofrecCaducWoProf = 0;
			if(mapaOfrecimientosCaduc.get(rp.RelatedRecordId + '_' + rp.ServiceResourceId) != null){
				ofrecCaducWoProf = mapaOfrecimientosCaduc.get(rp.RelatedRecordId + '_' + rp.ServiceResourceId);
			}
			if(woProfMap.containsKey(rp.RelatedRecordId) && woProfMap.get(rp.RelatedRecordId).contains(rp.ServiceResourceId) 
				&& !(woRechDesasProfMap.containsKey(rp.RelatedRecordId) && woRechDesasProfMap.get(rp.RelatedRecordId).contains(rp.ServiceResourceId))
				&& ofrecCaducWoProf <= numMaxOfrecimientos){
				rpListDelete.add(rp);
			}
		}
		delete rpListDelete;
		
		for(Id saId:saSetIdNoReprogramadaInicial){
			Id politica = schedulingPolicyGeoId;
			FSL.ScheduleResult scheduleResult = FSL.ScheduleService.Schedule(politica, saId);
		}
	}
  
	public void finish(final Database.BatchableContext BC){
		//sendErrorEmail(BC.getJobId());
	}   
	
}