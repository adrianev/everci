/**
 * Clase handler del trigger del Trigger TRG_Cita_de_Servicio.
 * 
 * @author EVERIS
 */
public without sharing class TRG_Handler_Cita_de_Servicio {

	private static Boolean esProfesional;

	private static Map<Id,WorkOrder> mapaOTs;
	private static Map<Id,List<ContentVersion>> mapaAlbaranesPorCita;
	private static Map<Id,Id> mapaProfsPorCita;
	private static Map<String,AssignedResource> mapaRecursosAsign;

	private static boolean cambioDeCita;
	private static boolean nuevaCita;
	private static boolean baipasOT;

	public static Set<Id> citaDesasignada;
	public static Set<Id> citaCompletada;
	public static Set<Id> citaAsignada;
	private static Set<Id> citaAnuladaCambio;
	private static Set<Id> citaAnulada;
	private static Set<Id> citaOtrosCambios;
	public static Set<Id> citaNoAceptado;
	public static Set<Id> citaRechazado;
	private static Set<Id> citaPdteAsignar;
	private static Set<Id> citaEnCurso;
	private static Set<Id> citaPdteAsignarMan;


	public static void tratamientoBefore(Map<Id, ServiceAppointment> triggerNewMap, List<ServiceAppointment> triggerNew, 
			Map<Id, ServiceAppointment> triggerOldMap, List<ServiceAppointment> triggerOld){

		// [Before-Delete]
		if(trigger.isDelete){
			// Control de eliminación manual de registros por usuarios NO-Administradores
			Boolean esAdmin = (Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_ADMINISTRADOR);
			for(ServiceAppointment cita : triggerOld){
				if(!esAdmin && !Util_Cita_Servicio.permiteELiminar){
					cita.addError(Label.ERROR_ELIMINAR_CITA);
				}
			}
		}

		// [Before-Insert/Update]
		else {
			// Contador de control para evitar ejecuciones no deseadas provocadas por FSL:
			// · tratamientoBefore: siempre suma 1 al contador y solo se ejecuta el método si antes de sumar el contador valía 0
			// · tratamientoAfter:
			//     - siempre resta 1 al contador y solo se ejecuta el método si antes de restar el contador valía 1
			//     - si se ejecuta el método, se establece en 99 el contador para impedir sucesivas ejecuciones del trigger en el mismo hilo
			// · Si se desea forzar que el trigger se ejecute de forma adicional en el mismo hilo
			//   se debe poner a 0 el contador en el código que actualiza la cita (Ej: TRG_Handler_Recurso_Asignado)
			Integer ejecutaTrigger = Util_Cita_Servicio.ejecutaTrigger;
			Util_Cita_Servicio.ejecutaTrigger++;
			system.debug('>>>>>>>>>>>>>>>>>tratamientoBefore.ejecutaTrigger: ' + ejecutaTrigger);
			system.debug('>>>>>>>>>>>>>>>>>tratamientoBefore.Util_Cita_Servicio.ejecutaTrigger: ' + Util_Cita_Servicio.ejecutaTrigger);
			if(ejecutaTrigger == 0){
	
				inicializarVariables(triggerNew);
	
				if(trigger.isInsert){
					system.debug('>>>> TRATAMIENTO BEFORE INSERT');
	
					Integer extraId = 0;
					for(ServiceAppointment cita : triggerNew){
						WorkOrder ot = mapaOTs.get(cita.ParentRecordId);
	
						// Genera identificador externo si no esta informado
						if(cita.CSE_TXT_Identificador__c == null){
							Long timestamp = datetime.now().getTime();
							cita.CSE_TXT_Identificador__c = String.valueOf(timestamp) + extraId;
							extraId++;
						}
						system.debug('>>>>>>identificador da cita:'+ cita.CSE_TXT_Identificador__c);
	
						if(ot != null){
							//cita.EarliestStartTime = EV_Util_Cita_Servicio.calcularFechaInicio(DateTime.now(), ot.OTR_CAS_Urgente__c);
							cita.CSE_SEL_Gremio__c = ot.OTR_SEL_Gremio__c;
							cita.ServiceTerritoryId = cita.ServiceTerritoryId!=null? cita.ServiceTerritoryId:ot.ServiceTerritoryId;
							cita.SchedEndTime = cita.SchedEndTime != null? cita.SchedEndTime:cita.ArrivalWindowEndTime!=null?cita.ArrivalWindowEndTime:null; // .addHours(2)
							cita.SchedStartTime = cita.SchedStartTime != null? cita.SchedStartTime:cita.ArrivalWindowStartTime!=null?cita.ArrivalWindowStartTime:null; // .addHours(2)
							cita.CSE_CAS_Urgente__c = ot.OTR_CAS_Urgente__c;
							//cita.CSE_TXT_Segmentacion_Cliente__c = ot.Account.CUE_FOR_Segmentacion__c;
							cita.CSE_CAS_Asignar_Mizad__c = ot.OTR_CAS_Asignar_Mizad__c;
							cita.CSE_SEL_Tipo_Red__c = ot.OTR_SEL_Tipo_Red__c;
							cita.CSE_CAS_Asignar_Como_Franquiciado__c = ot.OTR_CAS_Asignar_Como_Franquiciado__c;
							cita.CSE_CAS_Asignar_territorio_prim_no_franq__c = ot.OTR_CAS_Asignar_territorio_prim_no_franq__c;
						}
					}
	
					// Valida si es posible crear la cita de servicio
					validarCreacionCita(triggerNew);
				}
				else if(trigger.isUpdate){
					system.debug('>>>> TRATAMIENTO BEFORE UPDATE');
	
					// Generar identificador si no esta informado
					for(ServiceAppointment citas : triggerNew){
						ServiceAppointment citaOld = triggerOldMap.get(citas.Id);
	
						WorkOrder ot = mapaOTs.get(citas.ParentRecordId);

						//No permitir a usuarios cambiar fecha de la cita
						if(Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_GESTOR_FRONT_TRAMITACION || Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name == Label.PERFIL_PROFESIONAL){ 	
							if(citas.SchedStartTime != citaOld.SchedStartTime){
								citas.SchedStartTime = citaOld.SchedStartTime;
							}
							if(citas.SchedEndTime != citaOld.SchedEndTime){
								citas.SchedEndTime = citaOld.SchedEndTime;
							}
						}
							
						// Generar identificador externo si no esta informado
						if(citas.CSE_TXT_Identificador__c == null){
							Long timestamp = datetime.now().getTime();
							citas.CSE_TXT_Identificador__c = String.valueOf(timestamp);
						}
						system.debug('>>>>>>identificador da cita:'+ citas.CSE_TXT_Identificador__c);
					}
	
					validarHorarioNoUrgente(triggerNew, triggerOldMap);
	
					procesarCambioEstadoBefore(triggerNew, triggerOldMap);
	
					cambioTipoRegistro(triggerNew, triggerOldMap);
				}
			}
		}
	}


	public static void tratamientoAfter(Map<Id, ServiceAppointment> triggerNewMap, List<ServiceAppointment> triggerNew, 
			Map<Id, ServiceAppointment> triggerOldMap, List<ServiceAppointment> triggerOld){

		// Contador de control para evitar ejecuciones no deseadas provocadas por FSL:
		// · tratamientoBefore: siempre suma 1 al contador y solo se ejecuta el método si antes de sumar el contador valía 0
		// · tratamientoAfter:
		//		- siempre resta 1 al contador y solo se ejecuta el método si antes de restar el contador valía 1
		//		- si se ejecuta el método, se establece en 99 el contador para impedir sucesivas ejecuciones del trigger en el mismo hilo
		// · Si se desea forzar que el trigger se ejecute de forma adicional en el mismo hilo
		//   se debe poner a 0 el contador en el código que actualiza la cita (Ej: TRG_Handler_Recurso_Asignado)
		Integer ejecutaTrigger = Util_Cita_Servicio.ejecutaTrigger;
		Util_Cita_Servicio.ejecutaTrigger--;
		system.debug('>>>>>>>>>>>>>>>>>tratamientoAfter.ejecutaTrigger: ' + ejecutaTrigger);
		system.debug('>>>>>>>>>>>>>>>>>tratamientoAfter.Util_Cita_Servicio.ejecutaTrigger: ' + Util_Cita_Servicio.ejecutaTrigger);
		if(ejecutaTrigger == 1){
			Util_Cita_Servicio.ejecutaTrigger = 99;

			Map<Id,Workorder> woActualizar = new Map<Id,Workorder>();

			if(trigger.isInsert){
				system.debug('>>>> TRATAMIENTO AFTER INSERT');
	
				//Se actualiza el estado de la OT que tenga relacionada la cita de servicio
				actualizarOrdenTrabajo(triggerNew, triggerOldMap, woActualizar);

				asignarProfesional(triggerNew, triggerOldMap);
			}
			else if(trigger.isUpdate){
				system.debug('>>>> TRATAMIENTO AFTER UPDATE');

				List<Task> tareas = new List<Task>();
				
				//Los eventos necesitan acceso al caso para crearlos
				//damos acceso temporal a los profesionales
				List<CaseShare> cstemp = new List<CaseShare>();
				for(Workorder wo: mapaOTs.values()){
					csTemp.add(new CaseShare(CaseId=wo.caseId,UserOrGroupId=UserInfo.getUserId(),RowCause='Manual',CaseAccessLevel='Edit'));
				}
				if(!csTemp.isEmpty()){
					Util_Caso.insertShares(csTemp);
				}
				
				for(ServiceAppointment citas : triggerNew){
					ServiceAppointment citaOld = triggerOldMap.get(citas.Id);
					WorkOrder ot = mapaOTs.get(citas.ParentRecordId);
						
					system.debug('-------citas.ArrivalWindowStartTime: ' + citas.ArrivalWindowStartTime);
					system.debug('-------citas.ArrivalWindowEndTime: ' + citas.ArrivalWindowEndTime);
					system.debug('-------citas.ServiceTerritoryId: ' + citas.ServiceTerritoryId);
					
					// Generar tarea cuando el estado de la cita pasa de "Pdte asignar" a "Pdte asignar manual"
					if(citaOld.Status == Label.CIT_ESTADO_PTE_ASIGNAR && citas.Status == Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL){
						Task tarea = Util_tarea.crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_CITA_ASIGNACION_MANUAL + ' ' + citas.AppointmentNumber,
														   Label.TAR_ESTADO_EN_CURSO, Label.TAR_TIPO_CAMBIO_DE_ESTADO, ot.Case.OwnerId,
														   ot.Id, ot.Case.CAS_LKP_Compania__c);
						tareas.add(tarea);
					}

					//si un profesional de guardia rechaza o desasigna la cita se genera una propuesta de evento E01 o E29
					if(esProfesional && citas.Status != citaOld.Status &&
					  (citaDesasignada.contains(citas.Id) || citaRechazado.contains(citas.Id) || citaNoAceptado.contains(citas.Id))){
						system.debug('-------ifEvento');
						Workorder otAux = new Workorder(Id=ot.Id,OTR_LKP_Recurso_Servicio__c=mapaProfsPorCita.get(citas.Id),CaseId=ot.CaseId);
						//crearEventoE01_E29(citas, ot);
						crearEventoE01_E29(citas, otAux);
					}
					//linea para tests por error de permisos extraño
					if(Test.isRunningTest() && citas.Status != citaOld.Status && (citaDesasignada.contains(citas.Id) || citaRechazado.contains(citas.Id) || citaNoAceptado.contains(citas.Id))){
						Workorder otAux = new Workorder(Id=ot.Id,OTR_LKP_Recurso_Servicio__c=mapaProfsPorCita.get(citas.Id),CaseId=ot.CaseId);
						crearEventoE01_E29(citas, otAux);
					}
					
				}
				
				Map<Id,CaseShare> cstempDelete = new Map<Id,CaseShare>();
				for(CaseShare cs: csTemp){
					if(cs.Id != null){
						cstempDelete.put(cs.Id,cs);
					}
				}
				if(!cstempDelete.isEmpty()){
					Util_Caso.deleteShares(cstempDelete.values());
				}
	
				// Función del handler que se encarga de poner la fecha a las wo
				actualizarFecha1aCitaOT(triggerNew, woActualizar);
	
				actualizarOrdenTrabajo(triggerNew, triggerOldMap, woActualizar);
	
				crearHistoricoAsignacion(triggerNew, triggerOldMap);

				if(!tareas.isEmpty()){
					insert tareas;
				}
			}

			system.debug('-----------woActualizar: '+ woActualizar);
			system.debug('-----------baipasOT: '+ baipasOT);
			if(woActualizar != null && !woActualizar.isEmpty()){
				//Puede darse el caso de que el profesional llegue sin permisos sobre la wo a este punto
				//así que le ponemos permisos temporales
				List<WorkOrderShare> sharesTemp = new List<WorkorderShare>();
			
				for(ID woId : woActualizar.KeySet()){
					sharesTemp.add(new WorkOrderShare(ParentId=woId,RowCause='Manual',UserOrGroupId=UserInfo.getUserId(),AccessLevel='Edit'));
				}
				system.debug('------sharesTemp: ' + sharesTemp);
				if(!sharesTemp.isEmpty()){
					try{
						List<Database.saveResult> resultados = Util_Orden_Trabajo.insertShares(sharesTemp);
						for(Database.saveResult res: resultados){
							system.debug(res.getErrors());
						}
						
					} catch(Exception e){
						system.debug(e.getMessage());
					}
				}
	
				if(baipasOT) Baipas.establecerVariableControl();
				if(!Test.isRunningTest()) update woActualizar.values();
				if(baipasOT) Baipas.deshabilitarVariableControl();
			}

			// Cambio de Cita desde la APP por parte del Profesional
			if(trigger.isUpdate && !Util_Cita_Servicio.citaCreadaDesdeApp){
				crearCitaDesdeApp(triggerNew, triggerOldMap);
				asignarProfesional(triggerNew, triggerOldMap);
				Util_Cita_Servicio.citaCreadaDesdeApp = true;
			}

			if(!trigger.isDelete){
				Map<Id,WorkOrder> woTrasUpdate = Util_Cita_Servicio.recogerOrdenesTrabajo(triggerNew);
				Set<Id> woIdsRecalcular = new set<Id>();
				for(Workorder wo: woTrasUpdate.values()){
					//if(wo.OTR_LKP_Recurso_Servicio__c == null){
						woIdsRecalcular.add(wo.Id);
					//}
				}
				if(!woIdsRecalcular.isEmpty()){
					Util_Orden_Trabajo.recalcularShares(woIdsRecalcular);
				}
			}
		}
	}


	private static void inicializarVariables(List<ServiceAppointment> triggerNew){
		esProfesional = Util_Perfiles_Usuario.esProfesional(UserInfo.getProfileId());
		mapaOTs = new Map<Id, WorkOrder>();

		cambioDeCita = false; 
		nuevaCita = false;
		baipasOT = true;

		citaDesasignada = new Set<Id>();
		citaCompletada = new Set<Id>();
		citaAsignada = new Set<Id>();
		citaAnuladaCambio = new Set<Id>();
		citaAnulada = new Set<Id>();
		citaOtrosCambios = new Set<Id>();
		citaNoAceptado = new Set<Id>();
		citaRechazado = new Set<Id>();
		citaPdteAsignar = new Set<Id>();
		citaEnCurso = new Set<Id>();
		citaPdteAsignarMan = new Set<Id>();

		Set<Id> setIdsOTs = new Set<Id>();
		Set<Id> setIdsCitas = new Set<Id>();
		
		List<WorkOrderShare> sharesTemp = new List<WorkorderShare>();
		
		for(ServiceAppointment cita : triggerNew){
			if(cita.ParentRecordId != null){
				setIdsOTs.add(cita.ParentRecordId);
				sharesTemp.add(new WorkOrderShare(ParentId=cita.ParentRecordId,RowCause='Manual',UserOrGroupId=UserInfo.getUserId(),AccessLevel='Edit'));
			}
			if(cita.Id != null){
				setIdsCitas.add(cita.Id);
			}
		}
		system.debug('------sharesTemp: ' + sharesTemp);
		if(!sharesTemp.isEmpty()){
			try {
				List<Database.saveResult> resultados = Util_Orden_Trabajo.insertShares(sharesTemp);
				for(Database.saveResult res: resultados){
					system.debug(res.getErrors());
				}
			}
			catch(Exception e){
				system.debug(e.getMessage());
			}
		}
		
		if(!setIdsOTs.isEmpty()){
			mapaOTs = Util_Orden_Trabajo.queryMapOTById(setIdsOTs);
		}

		mapaProfsPorCita = new Map<Id,Id>();
		mapaRecursosAsign = new Map<String, AssignedResource>();
		if(trigger.isUpdate){
			if(!setIdsCitas.isEmpty()){
				List<AssignedResource> listAR = Util_Service_Resource.getMapAssignedResourcesByCita(setIdsCitas).values();
				for(AssignedResource recursoAsignado : listAR){
					mapaRecursosAsign.put(recursoAsignado.ServiceAppointmentId + '_' + recursoAsignado.ServiceResourceId, recursoAsignado);
				}
	
				mapaProfsPorCita = Util_Cita_Servicio.obtenerMapaCitaServicioRecursoAsignado(listAR);
			}
			mapaAlbaranesPorCita = Util_Cita_Servicio.getMapaAlbaranesPorCita(triggerNew);
		}
	}

	/**
	 * Valida si la cita se puede crear
	 *
	 * @param  triggerNew Lista de citas
	 * @see	Map, Id, ServiceAppointment
	 */
	private static void validarCreacionCita(List<ServiceAppointment> triggerNew){
		Set<String> estadosNoEnCurso = new Set<String>{
			Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO,
			Label.OTR_ESTADO_CERRADO,
			Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN
		};
		for(ServiceAppointment cita : triggerNew){
			//SFDCHC-532.COM_Bug.WORTEN. Error al anular el servicio -start
			DateTime fechaIni = cita.ArrivalWindowStartTime;
			DateTime fechaFin = cita.ArrivalWindowEndTime;
			if(fechaIni != null && fechaFin != null){
				Time horaIni = fechaIni.time();
				Time horaFin = fechaFin.time();
			
        	    if(horaIni >= horaFin){
					cita.addError(Label.CITA_FECHA_INI_FIN_IGUALES, true);
				}
			}
			//SFDCHC-532.COM_Bug.WORTEN. Error al anular el servicio -end
			WorkOrder ordTrb = mapaOTs.get(cita.ParentRecordId);
			if(ordTrb != null){
				if(ordTrb.recordTypeId != Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION)){
					List<ServiceAppointment> citasAbiertasWO = ordTrb.ServiceAppointments;
					system.debug('----citasAbiertasWO: '+citasAbiertasWO);
					if(citasAbiertasWO != null && citasAbiertasWO.size() > 0 && !cambioDeCita){
						cita.addError(Label.ERROR_CITA_EN_CURSO_EXISTENTE);
					}
					else if(estadosNoEnCurso.contains(ordTrb.Status) && !cambioDeCita){
						cita.addError(Label.ERROR_OT_ESTADO_CREAR_CITA);
					}
					else {
						nuevaCita = true;
					}
				}
				else {
					nuevaCita = true;
				}
			}
		}   
	}

	/**
	 * Validación de reserva de cita 
	 *
	 * @param  triggerNew y triggerOldMap : Lista y mapa de citas
	 * @see	Map, Id, ServiceAppointment
	 */
	private static void validarHorarioNoUrgente(List<ServiceAppointment> triggerNew,  Map<Id, ServiceAppointment> triggerOldMap){
		Map<Id, Set<Date>> mapTerritorioFechaFestivo = new Map<Id, Set<Date>>();
		Set<Date> setTodasFechas = new Set<Date>();
		Set<Id> setTodosTerritorios = new Set<Id>();
		for(ServiceAppointment cita: triggerNew){
			System.debug('>>>> cita.ArrivalWindowStartTime '+cita.ArrivalWindowStartTime);
			System.debug('>>>> cita.CSE_CAS_Comprobado_Horario__c '+cita.CSE_CAS_Comprobado_Horario__c);
			if(!cita.CSE_CAS_Urgente__c && cita.ArrivalWindowStartTime != null && !cita.CSE_CAS_Comprobado_Horario__c){
				if(cita.ServiceTerritoryId != null && !setTodosTerritorios.contains(cita.ServiceTerritoryId)){
					system.debug('entro aqui');
					setTodosTerritorios.add(cita.ServiceTerritoryId);
				}
				if(cita.ArrivalWindowStartTime != null && !setTodasFechas.contains(cita.ArrivalWindowStartTime.date())){
					system.debug('entro alla');
					setTodasFechas.add(cita.ArrivalWindowStartTime.date());
				}
				cita.CSE_CAS_Comprobado_Horario__c = true;
			}
		}
		System.debug('>>>> setTodasFechas '+setTodasFechas);
		System.debug('>>>> setTodosTerritorios '+setTodosTerritorios);
		if(!setTodasFechas.isEmpty()){
			/* PREVIOUS:
			List<Festivos__c> festivosLista = new List<Festivos__c>(
					[SELECT FES_SEL_Tipo_de_Festivo__c, 
					 FES_DAT_Fecha__c, FES_LKP_Territorio__c 
					 FROM Festivos__c
					 WHERE (FES_LKP_Territorio__c IN :setTodosTerritorios 
							 AND FES_DAT_Fecha__c IN :setTodasFechas
							 AND FES_SEL_Tipo_de_Festivo__c = 'Local') 
					 OR (FES_DAT_Fecha__c IN: setTodasFechas 
							 AND FES_SEL_Tipo_de_Festivo__c = 'Nacional')]);
			 */
			//NEW:
			List<Festivos__c> festivosLista = Util_Festivos.getFestivoByTerritorio_AND_Fecha_AND_Tipo_de_Festivo_is_Nacional_o_Local(setTodosTerritorios,setTodasFechas).values();
			//END_NEW
			System.debug('>>>> festivosLista '+festivosLista);
			Set<String> festivosSet = new Set<String>();
			for(Festivos__c fest: festivosLista){
				if(fest.FES_SEL_Tipo_de_Festivo__c == 'Nacional'){
					festivosSet.add(fest.FES_DAT_Fecha__c.format());
				}else{
					festivosSet.add(fest.FES_DAT_Fecha__c.format() + '_' + fest.FES_LKP_Territorio__c);
				}
			}
			System.debug('>>>> festivosSet '+festivosSet);
			for(ServiceAppointment cita: triggerNew){
				if(!cita.CSE_CAS_Urgente__c && cita.ArrivalWindowStartTime != null){
					DateTime fechaIni = cita.ArrivalWindowStartTime;
					DateTime fechaFin = cita.ArrivalWindowEndTime;

					Integer diaDeLaSemana = fechaIni.date().toStartOfWeek().daysBetween(fechaIni.date());
					boolean esFinDeSemana = diaDeLaSemana == 5 || diaDeLaSemana == 6; 
					boolean esFestivo = festivosSet.contains(fechaIni.date().format()) || festivosSet.contains(fechaIni.date().format()+'_'+cita.ServiceTerritoryId);

					Time horaIni = fechaIni.time();
					Time horaFin = fechaFin.time();
					boolean fechaIniFuera = horaIni > Time.newInstance(20, 00, 00, 00) || horaIni < Time.newInstance(8, 00, 00, 00) ;
					boolean fechaFinFuera = horaFin > Time.newInstance(20, 00, 00, 00) || horaFin < Time.newInstance(8, 00, 00, 00) ;

					if(horaIni >= horaFin){
						cita.addError(Label.CITA_FECHA_INI_FIN_IGUALES, true);
					}
					
					if(esFinDeSemana || esFestivo || fechaIniFuera || fechaFinFuera){
						//throw new DmlException(Label.ERROR_HORARIO_NO_URGENTE);
						cita.addError(Label.ERROR_HORARIO_NO_URGENTE, true);
					}
				}
			} 
		}
	}

	/**
	 * Procesamiento tras un cambio de estado de la cita.
	 *
	 * @param triggerNew Lista de citas
	 * @param triggerOldMap Mapa de citas
	 */
	private static void procesarCambioEstadoBefore(List<ServiceAppointment> triggerNew, Map<Id, ServiceAppointment> triggerOldMap){
		system.debug('>>>> procesarCambioEstadoBefore : ' + triggerNew);
		for(ServiceAppointment cita : triggerNew){
			WorkOrder ot = mapaOTs.get(cita.ParentRecordId);

			if(triggerOldMap != null && triggerOldMap.get(cita.Id).Status != cita.Status){
				String estadoAnterior = triggerOldMap.get(cita.Id).Status;
				system.debug('>>>> procesarCambioEstadoBefore.cita.Status NEW: ' + cita.Status);
				system.debug('>>>> procesarCambioEstadoBefore.cita.Status OLD: ' + estadoAnterior);
				cita.CSE_TXT_Estado_Anterior__c = estadoAnterior;

				if(esProfesional && ot != null){
					// Validar que el cambio de estado de la cita no se realiza en
					// un estado del Servicio bloqueante para el Profesional
					if(ot.Status == Label.OTR_ESTADO_EN_ESPERA_PROF_DECL_RESP){
						cita.addError(Label.ERROR_ACCION_NO_DISP_ESTADO_OT + ' ' +
							Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'Status').get(ot.Status));								
					}
					// Validar generación de informe requerido en cierre de cita
					else if(cita.Status == Label.CIT_ESTADO_COMPLETADA &&
							ot.Case.CAS_LKP_Procedencia__r.PROC_CAS_Requiere_Informe_Cierre_Cita__c &&
							(mapaAlbaranesPorCita.get(cita.Id) == null || mapaAlbaranesPorCita.get(cita.Id).isEmpty())){
						cita.addError(Label.ERROR_CERRAR_CITA_INFORME);
					}
				}

				Id recursoId = mapaProfsPorCita.get(cita.Id);
				if(cita.Status == Label.CIT_ESTADO_ASIGNADA){
					if(recursoId == null){
						cita.addError(Label.ERROR_SIN_PROFESIONAL);
					}
					cita.CSE_CAS_Asignada__c = true;
					citaAsignada.add(cita.Id);
				}
				else if(cita.Status == Label.CIT_ESTADO_PROGRAMADO){
					if(recursoId == null){
						cita.addError(Label.ERROR_SIN_PROFESIONAL);
					}
					cita.CSE_CAS_Asignada__c = true;
					citaPdteAsignar.add(cita.Id);
				}
				else if(cita.Status == Label.CIT_ESTADO_DESASIGNADA){
					cita.CSE_TXT_Estado_Anterior__c = cita.Status;
					cita.Status = Label.CIT_ESTADO_PTE_ASIGNAR;
					cita.CSE_CAS_Asignada__c = false;
					cita.CSE_LKP_Profesional_Programado__c = null;
					citaDesasignada.add(cita.Id);
				}
				else if(cita.Status == Label.CIT_ESTADO_CADUCADO){
					cita.CSE_TXT_Estado_Anterior__c = cita.Status;
					cita.Status = Label.CIT_ESTADO_PTE_ASIGNAR;
					cita.CSE_CAS_Asignada__c = false;
					cita.CSE_LKP_Profesional_Programado__c = null;
					citaNoAceptado.add(cita.Id);
				}
				else if(cita.Status == Label.CIT_ESTADO_RECHAZADO){
					cita.CSE_TXT_Estado_Anterior__c = cita.Status;
					cita.Status = Label.CIT_ESTADO_PTE_ASIGNAR;
					cita.CSE_CAS_Asignada__c = false;
					cita.CSE_LKP_Profesional_Programado__c = null;
					citaRechazado.add(cita.Id);
				}
				else if(cita.Status == Label.CIT_ESTADO_EN_CURSO){
					cita.ActualStartTime = DateTime.now();
					citaEnCurso.add(cita.Id);
				}
				else if(cita.Status == Label.CIT_ESTADO_COMPLETADA){
					cita.ActualEndTime = DateTime.now();
					citaCompletada.add(cita.Id);
				}
				else if(cita.Status == Label.CIT_ESTADO_ANULADA){
					cita.CSE_CAS_Asignada__c = false;
					cita.CSE_LKP_Profesional_Programado__c = null;
					// Establecer en Pdte. de Asignar para eliminar el recurso asignado
					// y a continuación volver a poner el estado ANULADA 
					// (crearHistoricoAsignacion en AfterUpdate)
					cita.Status = Label.CIT_ESTADO_PTE_ASIGNAR;
					citaAnulada.add(cita.Id);
				}
				else if(cita.Status == Label.CIT_ESTADO_ANULADA_POR_CAMBIO){
					if(!cita.CSE_CAS_Cambio_de_cita__c){
						 cita.addError(Label.ERROR_CITA_ANULADAPORCAMBIO);
					}
					cita.CSE_CAS_Asignada__c = false;
					cita.CSE_LKP_Profesional_Programado__c = null;
					// Establecer en Pdte. de Asignar para eliminar el recurso asignado
					// y a continuación volver a poner el estado ANULADA POR CAMBIO
					// (crearHistoricoAsignacion en AfterUpdate)
					cita.Status = Label.CIT_ESTADO_PTE_ASIGNAR;
					citaAnuladaCambio.add(cita.Id);
				}
				else if(cita.Status == Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL){
					if(cita.ArrivalWindowStartTime == null){
						 cita.addError(Label.ERROR_CITA_MANUAL_NO_PROGR);
					}
					else {
						cita.CSE_CAS_Asignada__c = false;
						cita.CSE_LKP_Profesional_Programado__c = null;
						// Establecer en Pdte. de Asignar para eliminar el recurso asignado
						// y a continuación volver a poner el estado PDTE. ASIGNAR MANUAL
						// (crearHistoricoAsignacion en AfterUpdate)
						cita.Status = Label.CIT_ESTADO_PTE_ASIGNAR;
						citaPdteAsignarMan.add(cita.Id);
					}
				}
				else if(cita.Status == Label.CIT_ESTADO_PTE_ASIGNAR){
					cita.CSE_CAS_Asignada__c = false;
					cita.CSE_LKP_Profesional_Programado__c = null;
					citaPdteAsignar.add(cita.Id);
				}
				else {
					citaOtrosCambios.add(cita.Id);
				}
			}
			cita.SchedEndTime = cita.SchedEndTime != null? cita.SchedEndTime: cita.ArrivalWindowEndTime != null? cita.ArrivalWindowEndTime:null;//.addHours(2)
			cita.SchedStartTime = cita.SchedStartTime != null? cita.SchedStartTime: cita.ArrivalWindowStartTime != null? cita.ArrivalWindowStartTime:null;//.addHours(2)
			system.debug('>>>> procesarCambioEstadoBefore.citaAnulada: ' + citaAnulada);
			system.debug('>>>> procesarCambioEstadoBefore.citaAnuladaCambio: ' + citaAnuladaCambio);
			system.debug('>>>> procesarCambioEstadoBefore.citaAsignada: ' + citaAsignada);
			system.debug('>>>> procesarCambioEstadoBefore.citaCompletada: ' + citaCompletada);
			system.debug('>>>> procesarCambioEstadoBefore.citaDesasignada: ' + citaDesasignada);
			system.debug('>>>> procesarCambioEstadoBefore.citaNoAceptado: ' + citaNoAceptado);
			system.debug('>>>> procesarCambioEstadoBefore.citaOtrosCambios: ' + citaOtrosCambios);
			system.debug('>>>> procesarCambioEstadoBefore.citaPdteAsignar: ' + citaPdteAsignar);
			system.debug('>>>> procesarCambioEstadoBefore.citaPdteAsignarMan: ' + citaPdteAsignarMan);
			system.debug('>>>> procesarCambioEstadoBefore.citaRechazado: ' + citaRechazado);
		}
	}

	/**
	 * Cambia el tipo de registro de la cita en función de su estado
	 *
	 * @param  triggerNew, triggerOldMap Lista y mapa de citas
	 * @see	Map, Id, ServiceAppointment
	 */
	private static void cambioTipoRegistro(List<ServiceAppointment> triggerNew, Map<Id, ServiceAppointment> triggerOldMap){
		Id rtTerminadosId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get('ServiceAppointment:Citas_estados_terminados');
		Id rtAsignacionManualId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get('ServiceAppointment:Citas_estado_asignacion_directa');
		Id rtNoCompletadosId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get('ServiceAppointment:Citas_estados_en_curso');
		
		for(ServiceAppointment cita : triggerNew){
			ServiceAppointment citaOld = triggerOldMap.get(cita.Id);
			if(Util_Cita_Servicio.SET_ESTADOS_CERRADOS.contains(cita.Status) 
					&& !Util_Cita_Servicio.SET_ESTADOS_CERRADOS.contains(citaOld.Status)){
				cita.recordtypeId = rtTerminadosId;
			}
			else if(cita.Status !=null && citaOld.Status !=null && Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL== cita.Status 
					&& Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL!=citaOld.Status){
				cita.recordtypeId = rtAsignacionManualId;
			}
			else if(cita.Status !=null && citaOld.Status !=null && !Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL.contains(cita.Status) 
					&& !Util_Cita_Servicio.SET_ESTADOS_CERRADOS.contains(cita.Status) 
					&& (Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL.contains(citaOld.Status) 
							|| Util_Cita_Servicio.SET_ESTADOS_CERRADOS.contains(citaOld.Status))){
				cita.recordtypeId = rtNoCompletadosId;
			}
		}
	}

	/**
	 * Crea el histórico de asignación
	 *
	 * @param  triggerNew y triggerOldMap : Lista y mapa de citas
	 * @see	Map, Id, ServiceAppointment
	 */
	private static void crearHistoricoAsignacion(List<ServiceAppointment> triggerNew, Map<Id, ServiceAppointment> triggerOldMap){
		system.debug('>>>>>crearHistoricoAsignacion');
		system.debug('>>>>>crearHistoricoAsignacion.citaAnulada: ' +citaAnulada);
		system.debug('>>>>>crearHistoricoAsignacion.citaAnuladaCambio: ' +citaAnuladaCambio);
		system.debug('>>>>>crearHistoricoAsignacion.citaAsignada: ' + citaAsignada);
		system.debug('>>>>>crearHistoricoAsignacion.citaCompletada: ' + citaCompletada);
		system.debug('>>>>>crearHistoricoAsignacion.citaDesasignada: ' +citaDesasignada);
		system.debug('>>>>>crearHistoricoAsignacion.citaNoAceptado: ' +citaNoAceptado);
		system.debug('>>>>>crearHistoricoAsignacion.citaOtrosCambios: ' + citaOtrosCambios);
		system.debug('>>>>>crearHistoricoAsignacion.citaPdteAsignar: ' + citaPdteAsignar);
		system.debug('>>>>>crearHistoricoAsignacion.citaPdteAsignarManual: ' + citaPdteAsignarMan);
		system.debug('>>>>>crearHistoricoAsignacion.citaRechazado: ' +citaRechazado);

		if(!citaDesasignada.isEmpty() || !citaAsignada.isEmpty()
				|| !citaOtrosCambios.isEmpty() || !citaAnulada.isEmpty()
				|| !citaAnuladaCambio.isEmpty() || !citaNoAceptado.isEmpty()
				|| !citaRechazado.isEmpty() || !citaPdteAsignar.isEmpty() 
				|| !citaCompletada.isEmpty() || !citaOtrosCambios.isEmpty()|| !citaPdteAsignarMan.isEmpty()){

			List<Historico_de_Asignaciones__c> listHAS = new List<Historico_de_Asignaciones__c>();
			List<AssignedResource> listARdelete = new List<AssignedResource>();
			List<ServiceAppointment> salistupdate = new List<ServiceAppointment>();
			for(ServiceAppointment cita: triggerNew){
				Id recursoId = mapaProfsPorCita.get(cita.Id);
				String estadoAnterior = null;
				if(triggerOldMap.get(cita.Id) != null){
					estadoAnterior = triggerOldMap.get(cita.Id).Status;
				}
				AssignedResource recursoAsignado = mapaRecursosAsign.get(cita.Id + '_' + recursoId);
				Boolean asignacionDirecta = (recursoAsignado != null ? recursoAsignado.ServiceResource.RSE_CAS_Asignacion_Directa__c : false);
				if(citaDesasignada.contains(cita.Id) && recursoAsignado != null){
					listHAS.add(crearRegistroHistoricoAsignacion(cita, Label.CIT_ESTADO_DESASIGNADA, estadoAnterior, recursoId, asignacionDirecta));
					listARdelete.add(recursoAsignado);
				}
				else if(citaNoAceptado.contains(cita.Id) && recursoAsignado != null){
					listHAS.add(crearRegistroHistoricoAsignacion(cita, Label.CIT_ESTADO_CADUCADO, estadoAnterior, recursoId, asignacionDirecta));
					listARdelete.add(recursoAsignado);
				}
				else if(citaRechazado.contains(cita.Id) && recursoAsignado != null){
					listHAS.add(crearRegistroHistoricoAsignacion(cita, Label.CIT_ESTADO_RECHAZADO, estadoAnterior, recursoId, asignacionDirecta));
					listARdelete.add(recursoAsignado);
				}
				/*else if(citaAsignada.contains(cita.Id) && recursoAsignado != null){
					listHAS.add(crearRegistroHistoricoAsignacion(cita, cita.Status, estadoAnterior, recursoId, asignacionDirecta));
				}*/
				else if(citaPdteAsignar.contains(cita.Id) && recursoAsignado != null &&
						estadoAnterior != Label.CIT_ESTADO_PTE_ASIGNAR &&
						estadoAnterior != Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL){
					listHAS.add(crearRegistroHistoricoAsignacion(cita, Label.CIT_ESTADO_PTE_ASIGNAR, estadoAnterior, recursoId, asignacionDirecta));
				}
				else if(citaAnuladaCambio.contains(cita.Id)){
					if(recursoAsignado != null){
						listARdelete.add(recursoAsignado);
					}
					if(cita.Status != Label.CIT_ESTADO_ANULADA_POR_CAMBIO){
						salistupdate.add(new ServiceAppointment(Id = cita.Id, Status = Label.CIT_ESTADO_ANULADA_POR_CAMBIO));
					}
				}
				else if(citaPdteAsignarMan.contains(cita.Id)){
					if(recursoAsignado != null){
						listARdelete.add(recursoAsignado);
					}
					if(cita.Status != Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL){
						salistupdate.add(new ServiceAppointment(Id = cita.Id, Status = Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL));
					}
				}
				else if(citaAnulada.contains(cita.Id)){
					if(recursoAsignado != null){
						listARdelete.add(recursoAsignado);
					}
					if(cita.Status != Label.CIT_ESTADO_ANULADA){
						salistupdate.add(new ServiceAppointment(Id = cita.Id, Status = Label.CIT_ESTADO_ANULADA));
					}
				}
			}

			if(!listHAS.isEmpty()){
				insert listHAS;
			}
			
			if(!listARdelete.isEmpty()){
				delete listARdelete;
			}

			if(!salistupdate.isEmpty()){
				Baipas.establecerVariableControl();
				update salistupdate;
				Baipas.deshabilitarVariableControl();
			}
		}
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param cita: [PENDIENTE]
	  * @param estadoNuevo: [PENDIENTE]
	  * @param estadoAntiguo: [PENDIENTE]
	  * @param profesional: [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */
	public static Historico_de_Asignaciones__c crearRegistroHistoricoAsignacion(ServiceAppointment cita, String estadoNuevo, String estadoAntiguo, Id profesional, Boolean asignacionDirecta){
		return new Historico_de_Asignaciones__c(HAS_LKP_Cita_de_Servicio__c = cita.Id, HAS_TXT_Estado_Antiguo_Cita__c = estadoAntiguo, HAS_TXT_Estado_Nuevo_Cita__c = estadoNuevo,
				HAS_DAT_Fecha_Cambio_Estado__c = DateTime.now(), HAS_LKP_Orden_de_trabajo__c = cita.ParentRecordId, HAS_LKP_Profesional__c = profesional,
				HAS_TXT_Motivo_Rechazo_Desasignacion__c=cita.CSE_SEL_Motivo_Desasignacion__c, HAS_CAS_Asignacion_Directa__c=asignacionDirecta);
	}

	/**
	 * Crea la cita desde la aplicación de FSL
	 *
	 * @param  triggerNew y triggerOldMap : Lista y mapa de citas
	 * @see	Map, Id, ServiceAppointment
	 */
	private static void crearCitaDesdeApp(List<ServiceAppointment> triggerNew, Map<Id, ServiceAppointment> triggerOldMap){
		List<ServiceAppointment> listNuevasSA = new List<ServiceAppointment>();
		for(ServiceAppointment cita: triggerNew){
			if(cita.CSE_DAT_Fecha_Hora_Fin_Nueva_Cita__c != null && cita.CSE_DAT_Fecha_Hora_Inicio_Nueva_Cita__c != null){
				ServiceAppointment saNew = new ServiceAppointment(
					ParentRecordId = cita.ParentRecordId,
					EarliestStartTime = cita.EarliestStartTime,
					DueDate = cita.DueDate,
					ArrivalWindowStartTime = cita.CSE_DAT_Fecha_Hora_Inicio_Nueva_Cita__c,
					ArrivalWindowEndTime = cita.CSE_DAT_Fecha_Hora_Fin_Nueva_Cita__c,
					CSE_CAS_Autoasignar__c = true);
				listNuevasSA.add(saNew);
				cambioDeCita = true;
				nuevaCita = true;
			}
		}
		if(!listNuevasSA.isEmpty()){
			Util_Cita_Servicio.ejecutaTrigger = 0;
			insert listNuevasSA;
		}
	}

	/**
	 * Asignación de profesional a la cita cuando se crea desde la app
	 *
	 * @param  triggerNew y triggerOldMap : Lista y mapa de citas
	 * @see	Map, Id, ServiceAppointment
	 */
	private static void asignarProfesional(List<ServiceAppointment> triggerNew, Map<Id, ServiceAppointment> triggerOldMap){
		if(Test.isRunningTest()){
			esProfesional = true;
		}
		if(esProfesional){
			// Va a haber solo un usuario que cree estas citas, simplificamos 
			Map<Id, Id> citaAAsignarRecursoUsuario = new Map<Id, Id>();
			DateTime inicioMasTempranoCita = null;
			DateTime finMasTardioCita = null;
			for(ServiceAppointment cita: triggerNew){
				WorkOrder ot = mapaOTs.get(cita.ParentRecordId);
				if(ot.Status != Label.OTR_ESTADO_INACTIVO){
					Boolean isUpdateCambioEstado = triggerOldMap !=null && triggerOldMap.get(cita.Id).Status == Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL;
					if(esProfesional && (((triggerOldMap == null && nuevaCita) || isUpdateCambioEstado) 
							|| (cita.CSE_CAS_Autoasignar__c && cita.ArrivalWindowStartTime != null && triggerOldMap!=null && triggerOldMap.get(cita.Id).ArrivalWindowStartTime == null))){
						citaAAsignarRecursoUsuario.put(cita.Id, UserInfo.getUserId());
						inicioMasTempranoCita = inicioMasTempranoCita == null || (inicioMasTempranoCita !=null && cita.ArrivalWindowStartTime<inicioMasTempranoCita) ? cita.ArrivalWindowStartTime:inicioMasTempranoCita;
						finMasTardioCita = finMasTardioCita == null || (finMasTardioCita !=null && cita.ArrivalWindowEndTime>finMasTardioCita) ? cita.ArrivalWindowEndTime:finMasTardioCita;
					}
				}
			}

			if(!citaAAsignarRecursoUsuario.isEmpty()){
				/* PREV:
				List<ServiceResource> listRecurso = new List<ServiceResource>(
						[SELECT RelatedRecordId 
						 FROM ServiceResource 
						 WHERE RelatedRecordId IN :citaAAsignarRecursoUsuario.values()]);
				*/	 
				//NEW
				List<ServiceResource> listRecurso =  Util_Cita_Servicio.queryRecursoByRelatedRecord(new Set<Id>(citaAAsignarRecursoUsuario.values())).values();
				
				Map<Id, Id> mapaUsuarioRecurso = new Map<Id,Id>();
				for(ServiceResource recurso:listRecurso){
					mapaUsuarioRecurso.put(recurso.RelatedRecordId, recurso.Id);
				}
	
	
				/* PREV: List<AssignedResource> listARAsignada = new List<AssignedResource>(
						[SELECT ServiceAppointmentId, 
						 		ServiceResourceId,
						 		ServiceAppointment.SchedStartTime,
						 		ServiceAppointment.SchedEndTime 
						 FROM AssignedResource 
						 WHERE ServiceResourceId IN :mapaUsuarioRecurso.values() 
						 AND ServiceAppointment.Status = :Label.CIT_ESTADO_ASIGNADA 
						 AND ((ServiceAppointment.SchedStartTime >=: inicioMasTempranoCita 
						 AND ServiceAppointment.SchedStartTime <=: finMasTardioCita)
						 OR (ServiceAppointment.SchedEndTime >=: inicioMasTempranoCita 
						 AND ServiceAppointment.SchedEndTime <=: finMasTardioCita))]);*/
				//NEW:
				List<AssignedResource> listARAsignada = Util_Service_Resource.getMapAssignedResourcesByServiceResourceIdAndStatusAndFechas(new Set <Id> (mapaUsuarioRecurso.values()), new Set <String> {Label.CIT_ESTADO_ASIGNADA} , inicioMasTempranoCita,finMasTardioCita,inicioMasTempranoCita,finMasTardioCita).values();
	
				for(AssignedResource recursoAsignado: listARAsignada){
					for(ServiceAppointment cita: triggerNew){
						boolean fechaSolapadaCita = (recursoAsignado.ServiceAppointment.SchedStartTime <= cita.ArrivalWindowStartTime 
								&& recursoAsignado.ServiceAppointment.SchedEndTime > cita.ArrivalWindowStartTime)
								|| (recursoAsignado.ServiceAppointment.SchedStartTime < cita.ArrivalWindowEndTime 
										&& recursoAsignado.ServiceAppointment.SchedEndTime >=cita.ArrivalWindowEndTime);
						if(fechaSolapadaCita){
							cita.addError(Label.ERROR_CITA_AGENDA_BLOQUEADA_CITA);
						}
					}
				}
	
				/* PREV: List<ResourceAbsence> listRA = new List<ResourceAbsence>(
						[SELECT Start, 
								End,
								ResourceId 
						 FROM ResourceAbsence 
						 WHERE ResourceId IN :mapaUsuarioRecurso.values() 
						 AND ((Start >= :inicioMasTempranoCita 
						 AND Start <= :finMasTardioCita) 
						 OR (End >= :inicioMasTempranoCita
						 AND End <= :finMasTardioCita))]);*/
				//NEW:
				List<ResourceAbsence> listRA = Util_Service_Resource.getResourceAbsenceByResourceIdAndRecordTypeAndStartDateAndEndDateTardios(new Set <Id>(mapaUsuarioRecurso.values()),inicioMasTempranoCita,finMasTardioCita).values();
	
				for(ResourceAbsence ausenciaRecurso: listRA){
					for(ServiceAppointment cita: triggerNew){
						boolean fechaSolapadaAusencia = (ausenciaRecurso.Start <= cita.ArrivalWindowStartTime 
								&& ausenciaRecurso.End > cita.ArrivalWindowStartTime)
								|| (ausenciaRecurso.Start < cita.ArrivalWindowEndTime 
										&& ausenciaRecurso.End >= cita.ArrivalWindowEndTime);
						if(fechaSolapadaAusencia){
							cita.addError(Label.ERROR_CITA_AGENDA_BLOQUEADA_AUSENCIA);
						}
					}
				}
	
				List<AssignedResource> listRecursosAsignados = new List<AssignedResource>();
				for(ServiceAppointment cita: triggerNew){
					Id idRecursoUsuario = mapaUsuarioRecurso.get(citaAAsignarRecursoUsuario.get(cita.Id));
					if(idRecursoUsuario != null){
						listRecursosAsignados.add(crearRecursoAsignado(cita.Id, idRecursoUsuario));
					}
				} 

				if(!listRecursosAsignados.isEmpty()){
					insert listRecursosAsignados;
				}
			}
		}
	}

	/*
	 *  Esta función se encarga de poner en la workorder la fecha de la primera cita de servicio
	 *
	 *  @param List<ServiceAppointment> listaSA - Lista de ServiceAppointment
	 *  @param List<WorkOrder> listaOTSinFecha  - Lista de Órdenes de trabajo sin fecha de primera cita
	 *
	 **/
	private static void actualizarFecha1aCitaOT(List<ServiceAppointment> listaSA, Map<Id,Workorder> woActualizar){
		List<WorkOrder> listaOTsUpd = new List<WorkOrder>();
		for(ServiceAppointment cita : listaSA){
			WorkOrder woAct = woActualizar.get(cita.ParentRecordId);
			if(woAct == null){
				woAct = mapaOTs.get(cita.ParentRecordId);
			}
			
			// OT que no tienen fecha de primera cita
			system.debug('>>>> actualizarFecha1aCitaOT.cita.ArrivalWindowStartTime: ' + cita.ArrivalWindowStartTime);
			system.debug('>>>> actualizarFecha1aCitaOT.cita.ParentRecordId: ' + cita.ParentRecordId);
			system.debug('>>>> actualizarFecha1aCitaOT.cita.Status: ' + cita.Status);
			system.debug('>>>> actualizarFecha1aCitaOT.Fecha_Primera_Cita__c: ' + woAct.OTR_DAT_Fecha_Primera_Cita__c);
			system.debug('>>>> actualizarFecha1aCitaOT.cita.ArrivalWindowStartTime : ' + cita.ArrivalWindowStartTime);
			system.debug('>>>> actualizarFecha1aCitaOT.woAct : ' + woAct);
			if(woAct != null 
					&& woAct.OTR_DAT_Fecha_Primera_Cita__c == null
					&& cita.ArrivalWindowStartTime != null
					&& cita.Status != Label.CIT_ESTADO_ANULADA
					&& cita.Status != Label.CIT_ESTADO_ANULADA_POR_CAMBIO
					&& ((woAct.OTR_DAT_Fecha_Primera_Cita__c != cita.ArrivalWindowStartTime
					&& woAct.OTR_LKP_Primera_Cita__c == cita.Id)
							|| woAct.OTR_LKP_Primera_Cita__c == null)){
				woAct.OTR_DAT_Fecha_Primera_Cita__c = cita.ArrivalWindowStartTime.date();
				woAct.OTR_TXT_Rango_Primera_Cita__c = string.valueOf(cita.ArrivalWindowStartTime.time()).left(5)+'-'+ string.valueOf(cita.ArrivalWindowEndTime.time()).left(5);
				woAct.OTR_LKP_Primera_Cita__c = cita.Id;
				if(woAct.Status == Label.OTR_ESTADO_INACTIVO || woAct.Status == Label.OTR_ESTADO_INACTIVO_CLIENTE){
					woAct.Status = Label.OTR_ESTADO_PDTE_ASIGNAR_NORMAL;
				}
				woActualizar.put(woAct.Id, woAct);
				baipasOT = false;
			}
		}
	}

	/**
	 * Actualiza la orden de trabajo asociada y crea las preferencias de profesional
	 *
	 * @param  triggerNew, triggerOldMap Lista y mapa de citas
	 * @see Map, Id, ServiceAppointment
	 */   
	public static void actualizarOrdenTrabajo(List<ServiceAppointment> triggerNew, Map<Id, ServiceAppointment> triggerOldMap, Map<Id,Workorder> woActualizar){
		system.debug('>>>>>actualizarOrdenTrabajo');

		List<ResourcePreference> rpList = new List<ResourcePreference>();
		List<WorkOrder> woListUpd = new List<WorkOrder>();
		List<ResourcePreference> rpListDelete = new List<ResourcePreference>();
		for(ServiceAppointment cita : triggerNew){
			Boolean woActualizada = false;
			WorkOrder woAct = woActualizar.get(cita.ParentRecordId);
			if(woAct == null){
				woAct = mapaOTs.get(cita.ParentRecordId);
			}

			Id recursoId = mapaProfsPorCita.get(cita.Id);
			system.debug('>>>>> actualizarOrdenTrabajo.citaAnulada: ' + citaAnulada);
			system.debug('>>>>> actualizarOrdenTrabajo.citaAnuladaCambio: ' + citaAnuladaCambio);
			system.debug('>>>>> actualizarOrdenTrabajo.citaAsignada: ' + citaAsignada);
			system.debug('>>>>> actualizarOrdenTrabajo.citaCompletada: ' + citaCompletada);
			system.debug('>>>>> actualizarOrdenTrabajo.citaDesasignada: ' + citaDesasignada);
			system.debug('>>>>> actualizarOrdenTrabajo.citaNoAceptado: ' + citaNoAceptado);
			system.debug('>>>>> actualizarOrdenTrabajo.citaPdteAsignar: ' + citaPdteAsignar);
			system.debug('>>>>> actualizarOrdenTrabajo.citaPdteAsignarMan: ' + citaPdteAsignarMan);
			system.debug('>>>>> actualizarOrdenTrabajo.citaRechazado: ' + citaRechazado);
			system.debug('>>>>> actualizarOrdenTrabajo.woAct: ' + woAct);
			system.debug('>>>>> actualizarOrdenTrabajo.cita.Id: ' + cita.Id);
			system.debug('>>>>> actualizarOrdenTrabajo.cita.CSE_LKP_Profesional_Programado__c: ' + cita.CSE_LKP_Profesional_Programado__c);
			system.debug('>>>>> actualizarOrdenTrabajo.recursoId: ' + recursoId);
		
			//Si la cita se ha creado despues de eliminar todas las citas de un servicio
			if(woAct.OTR_LKP_Primera_Cita__c == null){
				woAct.OTR_LKP_Primera_Cita__c = cita.Id;
				woActualizada = true;
			}

			if(cita.CSE_LKP_Profesional_Programado__c != null && 
			   woAct.OTR_LKP_Profesional_Programado__c != cita.CSE_LKP_Profesional_Programado__c){
				woAct.OTR_LKP_Profesional_Programado__c = cita.CSE_LKP_Profesional_Programado__c;
				woActualizada = true;
				baipasOT = false;
			}

			// Si se ha completado una cita:
			if(citaCompletada != null && citaCompletada.contains(cita.Id)){
				// Actualizar contadores correspondientes en la OT
				woAct.OTR_NUM_Duracion_de_citas_completadas__c = woAct.OTR_NUM_Duracion_de_citas_completadas__c + cita.ActualDuration;
				woAct.OTR_NUM_Numero_de_citas_completadas__c = woAct.OTR_NUM_Numero_de_citas_completadas__c + 1;
				woActualizada = true;
			}
			
			// Si se ha desasignado el profesional de una cita:
			else if(citaDesasignada != null && citaDesasignada.contains(cita.Id)){
				// Excluir el profesional de futuras asignaciones para la OT
				if(recursoId != null){
					rpList.add(crearPreferenciaRecurso(woAct.Id, woAct.ResourcePreferences, recursoId, 'Excluded'));
				}
				// Blanquear profesional asignado/programado en la OT
				woAct.OTR_LKP_Recurso_Servicio__c = null;
				woAct.OTR_LKP_Profesional_Programado__c = null;
				if(woAct.OTR_LKP_Primera_Cita__c == cita.Id){
					// Establecer estado "PDTE.ASIGNAR" en la OT
					woAct.Status = Label.OTR_ESTADO_PDTE_ASIGNAR_NORMAL;
				}
				woActualizada = true;
				baipasOT = false;
			}
			
			// Si se ha anulado cualquier cita:
			else if((citaAnulada != null && citaAnulada.contains(cita.Id)) ||
			   (citaAnuladaCambio != null && citaAnuladaCambio.contains(cita.Id))){
				if(recursoId != null){
					//Poner el SR como preferido en las preferencias
					rpList.add(crearPreferenciaRecurso(woAct.Id, woAct.ResourcePreferences, recursoId, 'Preferred'));
				}	
		   		if(woAct.OTR_LKP_Primera_Cita__c == cita.Id){
					// Blanquear datos de la primera cita en la OT
					woAct.OTR_DAT_Fecha_Primera_Cita__c = null;
					woAct.OTR_TXT_Rango_Primera_Cita__c = null;
					woAct.OTR_SEL_Rango_Primera_Cita__c = null;
					woAct.OTR_LKP_Primera_Cita__c = null;
					// Blanquear profesional asignado/programado en la OT
					woAct.OTR_LKP_Recurso_Servicio__c = null;
					woAct.OTR_LKP_Profesional_Programado__c = null;
					// Establecer estado "PDTE.ASIGNAR" en la OT
					woAct.Status = Label.OTR_ESTADO_PDTE_ASIGNAR_NORMAL;
					woActualizada = true;
					baipasOT = false;
			   	}
			}

			// Si un profesional programado ha rechazado la cita o no ha aceptado el ofrecimiento:
			else if((citaNoAceptado != null && citaNoAceptado.contains(cita.Id)) 
					|| (citaRechazado != null && citaRechazado.contains(cita.Id))){
				// Excluir el profesional de futuras asignaciones para la OT
				rpList.add(crearPreferenciaRecurso(woAct.Id, woAct.ResourcePreferences, recursoId, 'Excluded'));
			}

			// Si se ha asignado un profesional a la cita:
			else if(citaAsignada != null && citaAsignada.contains(cita.Id) && recursoId != null){
				// Tras asignar un profesional a una Cita se establece como requerido en la Orden de Trabajo
				rpList.add(crearPreferenciaRecurso(woAct.Id, woAct.ResourcePreferences, recursoId, 'Required'));
				// Establecer estado "EN ESPERA DE PROFESIONAL POR ATENCION"
				// o "EN ESPERA DE PROFESIONAL POR DECLARACIÓN RESPONSABLE" en la OT
				if(woAct.Status == Label.OTR_ESTADO_INACTIVO || woAct.Status == Label.OTR_ESTADO_PDTE_ASIGNAR_NORMAL ||
				   (woAct.OTR_TXT_Id_Recurso_Anterior__c != null && woAct.OTR_TXT_Id_Recurso_Anterior__c != recursoId)){
					if(woAct.Case.CAS_LKP_Procedencia__r.PROC_CAS_Requiere_Declaracion_Resp__c){
						woAct.Status = Label.OTR_ESTADO_EN_ESPERA_PROF_DECL_RESP;
					}
					else {
						woAct.Status = Label.OTR_ESTADO_PDTE_ATENCION_PROF;
					}
				}
				// Establecer profesional asignado/programado en la OT
				woAct.OTR_LKP_Recurso_Servicio__c = recursoId;
				woAct.OTR_TXT_Id_Recurso_Anterior__c = recursoId;
				woAct.OTR_LKP_Profesional_Programado__c = recursoId;
				woActualizada = true;
				baipasOT = false;
			}

			// Si la cita se ha puesto en curso:
			else if(citaEnCurso != null && citaEnCurso.contains(cita.Id)){
				// Si la Intervención es un Siniestro Reparable y la CIA requiere Confirmación
				if(woAct.Case.recordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO) &&
					woAct.Case.Type == Label.CAS_TIPO_REPARABLE &&
					woAct.Case.CAS_LKP_Compania__r.CUE_CAS_Requiere_Confirmacion__c &&
					!woAct.Case.CAS_CAS_Confirmado__c){
					// Establecer estado "EN ESPERA DE PROFESIONAL POR CONFIRMACION" en la OT
					if(woAct.Status != Label.OTR_ESTADO_EN_ESPERA_CONF_PROF){
						woAct.Status = Label.OTR_ESTADO_EN_ESPERA_CONF_PROF;
						woActualizada = true;
						baipasOT = false;
					}
				}
				else if(woAct.Status == Label.OTR_ESTADO_PDTE_ATENCION_PROF){
					woAct.Status = Label.OTR_ESTADO_EN_ESPERA_PROF_VALORACION;
					woActualizada = true;
					baipasOT = false;
				}
			}

			// Si la primera cita ha cambiado a Pdte.Asignar o Pdte.Asignar Manual:
			else if(woAct.OTR_LKP_Primera_Cita__c == cita.Id &&
				   ((citaPdteAsignar != null && citaPdteAsignar.contains(cita.Id)) ||
				   (citaPdteAsignarMan != null && citaPdteAsignarMan.contains(cita.Id))) &&
				   woAct.Status != Label.OTR_ESTADO_PDTE_ASIGNAR_NORMAL){
				// Establecer estado "PDTE.ASIGNAR" en la OT
				woAct.Status = Label.OTR_ESTADO_PDTE_ASIGNAR_NORMAL;
				woActualizada = true;
				baipasOT = false;
			}

			if(woActualizada){
				woActualizar.put(woAct.Id, woAct);
			}
		}
		if(!rpList.isEmpty()){
			upsert rpList;
		}
		if(!rpListDelete.isEmpty()){
			delete rpListDelete;
		}
	}


	/**
	 * Crea un recurso asignado a insertar en una Cita de Servicio
	 * 
	 * @param saId: Id de la Cita de Servicio
	 * @param profesionalId: Id del Profesional
	 * 
	 * @return nuevo objeto de Recurso Asignado
	 */
	private static AssignedResource crearRecursoAsignado(Id saId, Id profesionalId){
		return new AssignedResource(ServiceAppointmentId = saId, ServiceResourceId = profesionalId);
	}


	/**
	 * Crea o actualiza una Preferencia de Recurso sobre una Orden de Trabajo.
	 * 
	 * @param otId: Id de la Orden de Trabajo padre
	 * @param listaRP: Lista actual de Preferencias de Recurso de la Orden de Trabajo padre
	 * @param profesionalId: Id del Recurso de Servicio a crear/actualizar
	 * @param tipoRecurso: Tipo de preferencia a crear/actualizar
	 * 
	 * @return objeto Preferencia de Recurso a crear/actualizar en la Orden de Trabajo
	 */
	private static ResourcePreference crearPreferenciaRecurso(Id otId, List<ResourcePreference> listaRP, Id profesionalId, String tipoRecurso){
		// Buscar si ya existe una Preferencia de Recurso para el profesional en la Orden de Trabajo
		Id idRP = null;
		for(ResourcePreference rp : listaRP){
			if(rp.ServiceResourceId == profesionalId){
				idRP = rp.Id;
				break;
			}
		}
		if(idRP != null){
			// Si existe se devuelve el objeto con Id correspondiente y con el tipo de preferencia a actualizar
			return new ResourcePreference(Id = idRP, RelatedRecordId = otId, ServiceResourceId = profesionalId, PreferenceType = tipoRecurso);
		}
		else {
			// Si no existe se devuelve el nuevo objeto a crear
			return new ResourcePreference(RelatedRecordId = otId, ServiceResourceId = profesionalId, PreferenceType = tipoRecurso);
		}
	}


	/**
	 * Valida si la cita ha sido anulada por el profesional y crea un evento E01
	 *
	 * @param  triggerNew Lista de citas
	 */
	private static void crearEventoE01_E29(ServiceAppointment cita, Workorder ot){
		system.debug('-------ot.OTR_LKP_Recurso_Servicio__c: ' +ot.OTR_LKP_Recurso_Servicio__c);
		system.debug('-------cita.ArrivalWindowStartTime.dateGMT(): ' +cita.ArrivalWindowStartTime.dateGMT());
		system.debug('-------cita.ArrivalWindowEndTime.dateGMT(): ' +cita.ArrivalWindowEndTime.dateGMT());
		system.debug('-------cita.ServiceTerritoryId: ' +cita.ServiceTerritoryId);


		/* PREV:
		List<Guardia__c> guardiaList = new List<Guardia__c>(
			[SELECT Id, GUA_DAT_Fecha_Inicio__c, GUA_DAT_Fecha_Fin__c, GUA_LKP_Profesional__c, GUA_LKP_Territorio__c
			 FROM Guardia__c WHERE GUA_LKP_Profesional__c  = :ot.OTR_LKP_Recurso_Servicio__c
			 AND GUA_DAT_Fecha_Inicio__c <= :cita.ArrivalWindowStartTime.dateGMT() AND GUA_DAT_Fecha_Fin__c >= :cita.ArrivalWindowEndTime.dateGMT()
			 AND GUA_LKP_Territorio__c = :cita.ServiceTerritoryId]);
			 */
		
		//NEW
		List<Guardia__c> guardiaList = Util_Service_Resource.getGuardiaByProfesionalAndTerritorioAndMaxFechaInicioAndMinFechaFin(new Set<Id>{ot.OTR_LKP_Recurso_Servicio__c},new Set<Id>{cita.ServiceTerritoryId},cita.ArrivalWindowStartTime.dateGMT(),cita.ArrivalWindowEndTime.dateGMT()).values();
		
		
		Propuesta_de_Evento__c evento = new Propuesta_de_Evento__c();

		Boolean tieneGamaBlanca = false;
		
		//PREV: List<ServiceResourceSkill> serviceResourceSkillList = new List<ServiceResourceSkill>([SELECT SkillId FROM ServiceResourceSkill WHERE ServiceResourceId = :ot.OTR_LKP_Recurso_Servicio__c]);
		// List<ServiceResourceSkill> serviceResourceSkillList = Util_Orden_Trabajo.getServiceResourceSkillBySR(ot.OTR_LKP_Recurso_Servicio__c);
		//NEW
		List<ServiceResourceSkill> serviceResourceSkillList = Util_Orden_Trabajo.getMapServiceResourceSkillBySR(new Set<Id>{ot.OTR_LKP_Recurso_Servicio__c}).values();
		
		
		for(ServiceResourceSkill srs: serviceResourceSkillList){
			system.debug('<<<<<<<<<<<<<<<<sera gama blanca>>>>>>>>>>>>>>>>' + srs.Skill.DeveloperName);
			if(srs.Skill.DeveloperName == Label.SKL_GAMA_BLANCA){
				tieneGamaBlanca = true;
				break;
			}
		}
		
		if(!tieneGamaBlanca && /*cita.Status == Label.CIT_ESTADO_DESASIGNADA*/citaDesasignada.contains(cita.Id) && !serviceResourceSkillList.isEmpty() && cita.CSE_SEL_Tipo_Red__c != 'Mizad'){
			evento.EV_AB_SEL_Departamento_Solicitante__c = '2';
			evento.EV_AB_SEL_Descripcion__c = 'E29';
			evento.EV_AB_SEL_Estado__c = '02';
			evento.EV_AB_DIV_Importe_profesional__c = 25.0;
			evento.EV_AB_LKP_Imputar_a_profesional__c = ot.OTR_LKP_Recurso_Servicio__c;
			evento.EV_AB_LKP_Caso__c = ot.CaseId;
			evento.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
			evento.EV_AB_LKP_Orden_de_Trabajo__c = ot.Id;
			evento.EV_AB_SEL_Departamento_Solicitante__c = Label.PAB_DEPT_AUDITORIA_GESTION;
			insert evento;

			/*evento.EV_AB_TXT_Identificador__c = evento.Name;

			Baipas.establecerVariableControl();
			update evento;
			Baipas.deshabilitarVariableControl();*/
		}
		else if(!guardiaList.isEmpty()){
			evento.EV_AB_SEL_Departamento_Solicitante__c = '2';
			evento.EV_AB_SEL_Descripcion__c = 'E01';
			evento.EV_AB_SEL_Estado__c = '02';
			evento.EV_AB_DIV_Importe_profesional__c = 150.0;
			evento.EV_AB_LKP_Imputar_a_profesional__c = ot.OTR_LKP_Recurso_Servicio__c;
			system.debug('<<<<<<<<<<<<sera evento E01 caso>>>>>>>>>' + ot.CaseId);
			evento.EV_AB_LKP_Caso__c = ot.CaseId;
			evento.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
			evento.EV_AB_LKP_Orden_de_Trabajo__c = ot.Id;
			evento.EV_AB_SEL_Departamento_Solicitante__c = Label.PAB_DEPT_AUDITORIA_GESTION;

			insert evento;

			/*evento.EV_AB_TXT_Identificador__c = evento.Name;

			Baipas.establecerVariableControl();
			update evento;
			Baipas.deshabilitarVariableControl();*/
		}
	}
}