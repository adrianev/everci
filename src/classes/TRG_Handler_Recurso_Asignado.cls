/**
 * Clase handler del trigger del Trigger TRG_Recurso_Asignado.
 * 
 * @author EVERIS
 */
public without sharing class TRG_Handler_Recurso_Asignado {

	private static final Integer tiempoReprogramacionUrgente = 5;
	private static final Integer tiempoReprogramacionNoUrgente = 20;
	private static final Integer tiempoBatch = 5;

	public static void tratamientoBefore(Map<Id, AssignedResource> triggerNewMap, List<AssignedResource> triggerNew){
		if(trigger.isInsert || trigger.isUpdate){
			//Manu DVG 09/07/2018 (Cambio de asignación de citas en el Dispatcher)
			Map<Id, Id> saSRMap = Util_Cita_Servicio.obtenerMapaCitaServicioRecursoAsignado(triggerNew);
			//Obtener todas las citas de servicio cuyo recurso asignado ha cambiado
			Map<Id, ServiceAppointment> saMap = Util_Cita_servicio.getMapCitasById(new Set<Id>(saSRMap.keySet()));
			Set<Id> setIdSR = new Set<Id>();
			setIdSR.addAll(saSRMap.values());
			//Nos traemos todos los recursos de servicio correspondientes a los recursos asignados modificados
			Map<Id, ServiceResource> srMap = Util_Service_Resource.getServiceResById(setIdSR);
			Map<Id, WorkOrder> mapaOTs = new Map<Id, WorkOrder>();
			Set<Id> setIdsOTs = new Set<Id>();
			for(ServiceAppointment cita : saMap.values()){
				if(cita.ParentRecordId != null){
					setIdsOTs.add(cita.ParentRecordId);
				}
			}
			//Nos traemos todas las ordenes de trabajo padre de las Citas de Servicio de la lista anterior
			if(!setIdsOTs.isEmpty()){
				mapaOTs = Util_Orden_Trabajo.queryMapOTById(setIdsOTs);
			}
			//Para cada recurso asignado modificado, nos traemos su nueva cita, la workorder correspondiente y comparamos si el recurso de servicio tiene el mismo gremio que la workorder
			for(AssignedResource ar : triggerNew){
				ServiceAppointment cita = saMap.get(ar.ServiceAppointmentId);
				if(cita.ParentRecordId != null){
					WorkOrder ot = mapaOTs.get(cita.ParentRecordId);
					if(saSRMap.get(cita.Id) != null){
						if(srMap.get(saSRMap.get(cita.Id))!= null){
							System.debug('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< gremio del recurso: ' + srMap.get(saSRMap.get(cita.Id)).RSE_SEL_Gremio__c);
							if(srMap.get(saSRMap.get(cita.Id)).RSE_SEL_Gremio__c != ot.OTR_SEL_Gremio__c){
								ar.addError(Label.CIT_ERROR_PROF_DISTINTO_GREMIO);
							}
						}
					}
				}
			}
			//FIN Manu DVG 09/07/2018
		}
	}

	/**
	 * Actualiza el estado de la cita de servicio cuando sea asignación directa
	 *
	 * @param arList  Lista de recursos asignados
	 * @see Map, Id, AssignedResource
	 */
	public static void actualizarCitaServicioAsignacionDirecta(List<AssignedResource> arList){
		Map<Id, Id> saSRMap = Util_Cita_Servicio.obtenerMapaCitaServicioRecursoAsignado(arList);
		List<ServiceAppointment> saList = Util_Cita_servicio.getMapCitasById(new Set<Id>(saSRMap.keySet())).values();
		Map<Id, ServiceResource> srMap = new Map<Id, ServiceResource>(
			[SELECT Id,
					RSE_CAS_Asignacion_Directa__c,
					RSE_TXT_Codigo_Recurso__c
			 FROM ServiceResource
			 WHERE Id IN :saSRMap.values()]);

		Boolean esProfesional = Util_Perfiles_Usuario.esProfesional(UserInfo.getProfileId());

		Set<Id> citaProgramada = new Set<Id>();
		TRG_Handler_Cita_de_Servicio.citaAsignada = new Set<Id>();
		Set<Id> citaAsignada = TRG_Handler_Cita_de_Servicio.citaAsignada;
		List<Historico_de_Asignaciones__c> listHAS = new List<Historico_de_Asignaciones__c>();
		for(ServiceAppointment sa : saList){
			Id idRecurso = saSRMap.get(sa.Id);
			Boolean asignacionDirecta = srMap.get(idRecurso).RSE_CAS_Asignacion_Directa__c;
			String estadoAnterior = (sa.CSE_TXT_Estado_Anterior__c != null ? sa.CSE_TXT_Estado_Anterior__c : Label.CIT_ESTADO_PTE_ASIGNAR);
			sa.CSE_LKP_Profesional_Programado__c = srMap.get(saSRMap.get(sa.Id)).Id;
			// Si el profesional programado tiene Asignación Directa o se ha establecido el profesional de forma manual o se ha realizado la asignado al mismo profesional actual
			if(sa.status == Label.CIT_ESTADO_PROGRAMADO &&
			  (asignacionDirecta || sa.CSE_TXT_Estado_Anterior__c == Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL || esProfesional)){
				if(!Test.isRunningTest()){
					sa.status = Label.CIT_ESTADO_ASIGNADA;
					listHAS.add(TRG_Handler_Cita_de_Servicio.crearRegistroHistoricoAsignacion(sa, Label.CIT_ESTADO_ASIGNADA, estadoAnterior, idRecurso, asignacionDirecta));
					citaAsignada.add(sa.Id);
				}
			}
			else {
				Integer tiempoReprogramacion = sa.CSE_CAS_Urgente__c ? tiempoReprogramacionUrgente: tiempoReprogramacionNoUrgente;
				Integer aux = (Integer) Math.ceil((Decimal)(DateTime.now().minute())/tiempoBatch)*tiempoBatch;
				Integer auxFloor = (Integer) Math.floor((Decimal)(DateTime.now().minute())/tiempoBatch)*tiempoBatch;
				Integer minutesAux = sa.CSE_NUM_Numero_de_Ofrecimientos__c == 0 ? aux + tiempoReprogramacion: auxFloor + tiempoReprogramacion;

				Integer minutes = Math.mod(minutesAux, 60);
				Integer hours = minutesAux >= 60? DateTime.now().hour()+1:DateTime.now().hour();

				sa.CSE_DAT_Fecha_Proxima_Programacion__c = DateTime.newInstance(DateTime.now().year(), DateTime.now().month(), DateTime.now().day(), hours, minutes, 00);
				sa.CSE_DAT_Fecha_Ultima_Programacion__c = DateTime.now();

				listHAS.add(TRG_Handler_Cita_de_Servicio.crearRegistroHistoricoAsignacion(sa, Label.CIT_ESTADO_PROGRAMADO, estadoAnterior, idRecurso, asignacionDirecta));
			}
			sa.CSE_NUM_Numero_de_Ofrecimientos__c += 1;
		}
		system.debug('saList '+saList);
		if(!Test.isRunningTest()){
			sharePartner(arList);
			if(!saList.isEmpty()){
				Util_Cita_Servicio.ejecutaTrigger = 0;
				update saList;
			}
			if(!listHAS.isEmpty()){
				insert listHAS;
			}
		}
	}


	public static void sharePartner(List<AssignedResource> listaRecursos){
		
		Set<Id> idRecurso = new Set<Id>();
		
		for(AssignedResource ar:listaRecursos)
			idRecurso.add(ar.ServiceResourceId);
		
		//Map<Id,ServiceResource> recursos = new Map<Id,ServiceResource>([Select id, RelatedRecordId from serviceResource where id in :idRecurso]);
		Map<Id,ServiceResource> recursos = Util_Service_Resource.getServiceResById(idRecurso);
		Set<Id> userId = new Set<Id>();
		for(ServiceResource sr: recursos.values())
			userId.add(sr.RelatedRecordId);
			
		Map<Id,User> usuarios = Util_Perfiles_Usuario.queryMapUsuario(userId);
		
		Set<Id> roleId = new Set<Id>();
		Map<Id,Id> roleToParent = new Map<Id,Id>();
		for(User u: usuarios.values()){
			roleId.add(u.userRole.ParentRoleId);
			roleToParent.put(u.UserRoleId,u.UserRole.ParentRoleId);
		}
		
		Map<Id,User> usuariosP = Util_Perfiles_Usuario.getUsuarioByRole(roleID);
		
		
		List<ServiceAppointmentShare> saShare = new List<ServiceAppointmentShare>();
		for(AssignedResource rec: listaRecursos){
			User ut = usuarios.get(recursos.get(rec.ServiceResourceId).RelatedRecordId);
			Id func = ut.UserRole.ParentRoleId;
			if(func != null){
				for(User up: usuariosP.Values()){
					if(func == up.UserRoleId){
						saShare.add(new ServiceAppointmentShare(ParentId=rec.ServiceAppointmentId,UserOrGroupId=up.Id,RowCause='Manual',AccessLevel='Edit'));
					}
				}
			}
		}
		
		if(!saShare.isEmpty()){
			Util_Orden_Trabajo.insertShares(saShare);
		}		
	}
}