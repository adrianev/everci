/**
  * Clase encargada de realizar las reservas de cita urgentes
  *
  * @author EVERIS
  */
public without sharing class ReservarCitaUrgente {

	private static final String politicaGeolocalizacion = 'Política de Asignación – Geolocalización';

	/**
 	 * Método encargado de reservar la cita en cuestión
	 *
	 * @param woId: Id de la OT padre de la cita
	 * 
 	 */  
	public static void reservaCita(Id woId){

		Integer plazoTiempo = 3;
		/*WorkOrder worecuperada = [SELECT Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
										 Account.CUE_FOR_Segmentacion__c,
										 PostalCode,
										 OTR_CAS_Urgente__c,
										 CreatedDate
								  FROM WorkOrder
								  WHERE Id =: woId];*/
        system.debug(woId + ' woId');
		WorkOrder worecuperada = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{woId}).get(woId);
        
        system.debug(worecuperada + 'workORDER');
        system.debug(worecuperada.PostalCode + ' codigoPostal');

		/*List<Programacion_cita__mdt> listaConfs = new List<Programacion_cita__mdt>([
			SELECT PRC_TXT_Identificador_CIA__c,
				   PRC_TXT_Segmentacion__c,
				   PRC_CAS_Capital_Provincia__c,
				   PRC_NUM_Plazo__c
			FROM Programacion_cita__mdt
			WHERE PRC_TXT_Identificador_CIA__c = :worecuperada.Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c
			AND PRC_TXT_Segmentacion__c = :worecuperada.Account.CUE_FOR_Segmentacion__c
			AND PRC_NUM_Plazo__c != null
			AND PRC_CAS_Capital_Provincia__c = : Util_TerritorioServicio.esCapitalDeProvincia(worecuperada.PostalCode)]);*/	
		
		List<Programacion_cita__mdt> listaConfs = Util_Metadatos.getProgCitaByIdCIAAndSegmentAndCapitalProv(new Set<String>{worecuperada.Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c},new Set<String>{/*worecuperada.Account.CUE_FOR_Segmentacion__c*/},Util_TerritorioServicio.esCapitalDeProvincia(worecuperada.PostalCode)).values();
		
		if(!listaConfs.isEmpty() && listaConfs.get(0).PRC_NUM_Plazo__c != null){
			plazoTiempo = (Integer)listaConfs.get(0).PRC_NUM_Plazo__c;
		}

		List<ServiceAppointment> listaSAs = Util_Cita_Servicio.getListCitasOTsInStatus(woId, new Set<String>{Label.CIT_ESTADO_PTE_ASIGNAR});
		if(!listaSAs.isEmpty()){
			ServiceAppointment sa = listaSAs.get(0);
			sa.ArrivalWindowStartTime = worecuperada.CreatedDate;
			sa.ArrivalWindowEndTime = worecuperada.CreatedDate.addHours(plazoTiempo);
			update sa;

			Boolean esProfesional = Util_Perfiles_Usuario.esProfesional(UserInfo.getProfileId());

			if(!esProfesional){
				Id schedulingPolicyGeoId= Util_FSL.getFSLSchedPol(new Set<String>{politicaGeolocalizacion}).values().Id;
				//[select id from FSL__Scheduling_Policy__c where Name =: politicaGeolocalizacion limit 1].Id;
				FSL.ScheduleResult scheduleResult;
				if(!Test.isRunningTest()){
					scheduleResult = FSL.ScheduleService.Schedule(schedulingPolicyGeoId, sa.Id);
				}
				
				FSL.ScheduleResult scheduleResult2;
				if(scheduleResult!=null && sa.CSE_CAS_Asignar_Mizad__c){
					sa.CSE_CAS_Asignar_Mizad__c = false;
					Baipas.establecerVariableControl();
					update sa;
					Baipas.deshabilitarVariableControl();
					scheduleResult2 = FSL.ScheduleService.Schedule(schedulingPolicyGeoId, sa.Id);
				}
			}

		}
	}
}