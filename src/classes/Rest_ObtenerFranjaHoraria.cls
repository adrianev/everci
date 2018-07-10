/**
 * Clase que se utilizará para cambiar la fecha de la primera Cita de Servicio existente para un siniestro.
 * @author everis
 * @version 1.0
 */

@RestResource(urlMapping='/appointment/*')
global without sharing class Rest_ObtenerFranjaHoraria {

	/**
	 * Devuelve las franjas horarias disponibles para la Cita de Servicio
	 *
	 * @param AppointmentNumber : Número de la cita de servicio
	 *
	 * @return franjas horarias disponibles para la Cita de Servicio
	 *
	 */
	@HttpPost
	global static Rest_ObtenerFranjaHoraria_RP getSlots(String AppointmentNumber){
		Rest_ObtenerFranjaHoraria_RP resFranjas = new Rest_ObtenerFranjaHoraria_RP();
		try{

			List<Rest_Franja_RP> listAuxFranjas = new List<Rest_Franja_RP>();

			String CAS_SEL_origen_web = Label.CAS_ORIGEN_CLIENTE_WEB;
			system.debug('SVV. Numero de Cita desde funcion: ' + AppointmentNumber);
			listAuxFranjas = Util_Booking.franjas(AppointmentNumber, CAS_SEL_origen_web);
			if (listAuxFranjas == null || listAuxFranjas.size() == 0) {
				resFranjas.code = 'MEM-010';
				resFranjas.message = Util_WS_Error.devolverMensajeRespuesta(resFranjas.code);
				system.debug(resFranjas);
				return resFranjas;
			}

			resFranjas.listadoFranjas = listAuxFranjas;
			resFranjas.code = 'MEM-001';
			resFranjas.message = Util_WS_Error.devolverMensajeRespuesta(resFranjas.code);

		}catch(Exception e){
			system.debug('----SVV. excepción: ' + e);
			resFranjas.code='MEM-013';
			resFranjas.message = Util_WS_Error.devolverMensajeRespuesta(resFranjas.code);
		}
		system.debug(resFranjas);
		return resFranjas;
	}

	/**
	 * Devuelve el código y el mensaje de si la cita ha sido o no cambiada correctamente.
	 *
	 * @param OTR_DAT_Fecha_Ultima_Cita : Fecha seleccionada
	 * @param OTR_SEL_Rango_Ultima_Cita : Rango horas seleccionado
	 * @param AppointmentNumber : Número de la Cita de Servicio
	 * @param CAS_SEL_origen_web : Origen web
	 *
	 * @return código y mensaje de si la cita de Servicio ha sido o no cambiada con éxito.
	 *
	 */
	@HttpPatch
	global static Rest_B2C_SolicitudCita_RP setAppointment(String OTR_DAT_Fecha_Ultima_Cita, String OTR_SEL_Rango_Ultima_Cita, String AppointmentNumber, String CAS_SEL_origen_web){
		Rest_B2C_SolicitudCita_RP res= new Rest_B2C_SolicitudCita_RP();
		res = Util_Booking.setAppointment(OTR_DAT_Fecha_Ultima_Cita, OTR_SEL_Rango_Ultima_Cita, AppointmentNumber, CAS_SEL_origen_web);
		system.debug(res);
		return res;
	}
}