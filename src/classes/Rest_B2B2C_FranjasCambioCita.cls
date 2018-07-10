/**
 * Clase utilizada para la obtención de las franjas en el cambio de cita
 *
 * @author EVERIS
 *
 */
@RestResource(urlMapping='/franjasCambioCitaB2B2C')
global without sharing class Rest_B2B2C_FranjasCambioCita {
	
	/**
	 * Clase de respuesta.
	 *
	 */

	global class Resultado{
		public String code = '';
		public String message = '';
		public List<Rest_Franja_RP> listadoFranjas;
	}

	/**
	 * Devuelve las franjas disponibles cuando realizas un cambio de cita
	 *
	 * @param CAS_DAT_Recepcion_Producto_b2b2c : Fecha de entrega del producto
	 * @param codigoCita : Identificador de la cita
	 *
	 * @return franjas disponibles
	 *
	 */

	@HttpPost
	global static Resultado doPost(String CAS_DAT_Recepcion_Producto_b2b2c, String codigoCita){
		
		Resultado resultado = new Resultado();
		String fechaProv;
		List<Rest_Franja_RP> auxFranjasList = new List<Rest_Franja_RP>();
		String[] arrRango = new String[]{};
		
		if (String.isEmpty(CAS_DAT_Recepcion_Producto_b2b2c) || String.isEmpty(codigoCita) || CAS_DAT_Recepcion_Producto_b2b2c.length() > 10 || codigoCita.length() > 10) {
			resultado.code = 'API-004';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
			system.debug('>>>> Respuesta: ' + resultado);
			return resultado;
		}

		try{ 
			List<ServiceAppointment> citaServicio = [SELECT Id, ParentRecordId, Account.CUE_CAS_Ola_calor__c, EarliestStartTime, DueDate, CSE_SEL_Gremio__c, Account.ShippingPostalCode
				FROM ServiceAppointment WHERE AppointmentNumber =: codigoCita];
				
			if (citaServicio == null || citaServicio.size() == 0) {
				resultado.code = 'API-020'; 
				resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				system.debug('>>>> Respuesta: ' + resultado);
				return resultado;
			}
			
			ServiceAppointment sa = citaServicio.get(0);
			
			List<WorkOrder> ordenTrabajo = [SELECT Id, Case.CAS_CAS_Urgente__c, Case.CAS_TXT_DirRiesgo_CP__c FROM WorkOrder WHERE Id =: sa.ParentRecordId];
			
			system.debug('---- SVV. Urgente: ' + ordenTrabajo[0].Case.CAS_CAS_Urgente__c);
			system.debug('---- SVV. Ola de calor: ' + sa.Account.CUE_CAS_Ola_calor__c);
			
			//Analizar si es urgente o no, y si es ola de calor
			if (sa.CSE_SEL_Gremio__c == '21') {
				//Si es urgente
				if (ordenTrabajo[0].Case.CAS_CAS_Urgente__c == true) {
					sa.EarliestStartTime = Date.valueOf(CAS_DAT_Recepcion_Producto_b2b2c);
					if (Util_TerritorioServicio.esCapitalDeProvincia(sa.Account.ShippingPostalCode) == true) {
						sa.DueDate = sa.EarliestStartTime.addDays(Integer.valueOf(Label.SLA_Worten_UrgenteCapital));
					}
					else {
						sa.DueDate = sa.EarliestStartTime.addDays(Integer.valueOf(Label.SLA_Worten_Urgente));
					}
				}
				//Si no es urgente pero está en ola de calor
				else if (sa.Account.CUE_CAS_Ola_calor__c == true) {
					sa.EarliestStartTime = Date.valueOf(CAS_DAT_Recepcion_Producto_b2b2c).addDays(Integer.valueOf(Label.SLA_Worten));
					sa.DueDate = sa.EarliestStartTime.addDays(Integer.valueOf(Label.SLA_Worten_olaCalor));
				}
				//Cuando no es urgente
				else {
					sa.EarliestStartTime = Date.valueOf(CAS_DAT_Recepcion_Producto_b2b2c).addDays(Integer.valueOf(Label.SLA_Worten));
					sa.DueDate = sa.EarliestStartTime.addDays(Integer.valueOf(Label.SLA_Worten_noUrgente));
				}
			}
			else {
				sa.EarliestStartTime = Date.valueOf(CAS_DAT_Recepcion_Producto_b2b2c).addDays(2);
				sa.DueDate = sa.EarliestStartTime.addDays(Integer.valueOf(Label.SLA_Worten1));
			}
			
			system.debug('---- SVV. EarliestStartTime: ' + sa.EarliestStartTime);
			system.debug('---- SVV. DueDate: ' + sa.DueDate);
			
			auxFranjasList = Util_Booking.calendarioFake(auxFranjasList, sa.EarliestStartTime, sa.DueDate, ordenTrabajo[0], fechaProv, arrRango);
			
			resultado.code = 'API-001';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
			resultado.listadoFranjas = auxFranjasList;
		}
		catch(Exception e){
			system.debug('>>>>>>>EXCEPTION: ' + e + ' ' + e.getStackTraceString());
			resultado.code = 'API-014';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
		}
		system.debug('>>>> Respuesta: ' + resultado);
		return resultado;
	}

}