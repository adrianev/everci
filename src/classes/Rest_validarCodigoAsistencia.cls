/**
 * Clase que se utilizará para validar un código de asistencia de un servicio B2B2C
 * @author everis
 * @version 1.0
 */
@RestResource(urlMapping='/validarCodigoAsistencia/*')  
global without sharing class Rest_validarCodigoAsistencia {

	/**
	 * Devuelve la validación de un código de asistencia de un servicio B2B2C
	 *
	 * @param IdCaso : Identificador del caso
	 *
	 * @return código de la cita con sus franjas horarias disponibles
	 *
	 */
	@HttpGet
	global static Rest_validarCodigoAsistencia_RP doGet() {
		Rest_validarCodigoAsistencia_RP resultado = new Rest_validarCodigoAsistencia_RP();
		List<Rest_Franja_RP> franjas = new List<Rest_Franja_RP>();
		String woID;
		String codigoCita;

		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		String origenWeb = Label.CAS_ORIGEN_LANDING_B2B2C;
		String IdCaso = RestContext.request.params.get('IdCaso');
		
		try {
			List<Case> caso = [SELECT Id,
									  AccountId,
									  CAS_LKP_Compania__c,
									  CAS_LKP_Tipo_Trabajo__r.TDT_TXT_Identificador__c
							   FROM Case
							   WHERE Id =: IdCaso];

			if (caso.isEmpty()) {
				//Códigos para BricoDepot
				caso = [SELECT Id,
							   AccountId,
							   CAS_LKP_Compania__c,
							   CAS_LKP_Tipo_Trabajo__r.TDT_TXT_Identificador__c
						FROM Case
						WHERE CAS_TXT_Codigo_Activacion_Atila__c = :IdCaso];
				if (caso.isEmpty()) {
					resultado.code = 'API-017';
					resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
					return resultado;
				}
			}
	
			List<WorkOrder> ordTrabajo = [SELECT Id
										  FROM WorkOrder
										  WHERE CaseId = :caso[0].Id
										  AND Status = :Label.OTR_ESTADO_INACTIVO];
			if (ordTrabajo.isEmpty()) {
				resultado.code = 'API-018';
				resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				return resultado;
			}
			else {
				//Tengo WO y SA
				woID = ordTrabajo[0].Id;
				List<ServiceAppointment> listSAAux = [SELECT AppointmentNumber
													  FROM ServiceAppointment
													  WHERE ParentRecordId = :woID];
				codigoCita = listSAAux[0].AppointmentNumber;
				franjas = Util_Booking.franjas(codigoCita, origenWeb);
			}
			List<WorkOrderLineItem> DescripcionCPQ = [SELECT PAR_TXT_Baremo_Desc__c FROM WorkOrderLineItem WHERE WorkOrderId =: woID];
	
			resultado.listadoFranjas = franjas;
			resultado.codigoCita = codigoCita;
			if (DescripcionCPQ.size() > 0) {
				resultado.PAR_TXT_Baremo_Desc = DescripcionCPQ[0].PAR_TXT_Baremo_Desc__c;
			}
			resultado.identificadorUnicoOrden = woID;
			resultado.identificadorCuentaPadre = caso[0].CAS_LKP_Compania__c;
			resultado.code = 'API-001';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
		}
		catch (exception e) {
            system.debug('>>>>>>>EXCEPTION: ' + e + ' ' + e.getStackTraceString());
			resultado.code = 'API-014';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
		}
		return resultado;
	}
}