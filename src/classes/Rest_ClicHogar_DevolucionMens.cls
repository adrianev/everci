/**
 * Clase que se utilizará para exponer a SF una devolucion de mensajes asigandos a un caso.
 *
 * @author EVERIS
 * 
 */

@RestResource(urlMapping='/devolverMensaje/*')  
global without sharing class Rest_ClicHogar_DevolucionMens {

	/**
	 * Devuelve la información de los mensajes de ClicHogar que tenga el caso indicado
	 *
	 * @param MCH_LKP_Caso__c : identificador único del caso
	 *
	 * @return listado de los mensajes de ClicHogar asociados al caso indicado.
	 *
	 */

	@HttpGet
	global static Rest_ClicHogar_DevolucionMens_RP doGet() {

		Rest_ClicHogar_DevolucionMens_RP resultado = new Rest_ClicHogar_DevolucionMens_RP();
		List<Rest_ClicHogar_DevolucionMens_RP.mensajes> listaMensajes = new List<Rest_ClicHogar_DevolucionMens_RP.mensajes>();

		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		// Recuperamos el numero de caso de la URL
		String casoId = RestContext.request.params.get('MCH_LKP_Caso__c');

		system.debug('---- SVV. Caso mandado en la RQ: ' + casoId);

		// Query para saber si el numero de caso que recibimos se encuentra en el SF
		List<Case> caso = [SELECT Id FROM Case WHERE Id =: casoId];

		if (caso == null || caso.size() == 0) {
			resultado.code = 'API-007';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
			system.debug(resultado);
			return resultado;
		}

		try{

			//Recuperamos una lista de mensajes asociados al caso solicitado en la URL
			List<Mensaje_Clic_Hogar__c> listadoMensajes = [SELECT Id, MCH_TXT_asunto__c, MCH_TXT_consulta__c, MCH_DAT_fecha_alta_consulta__c,
			                                               MCH_DAT_fecha_respuesta__c, MCH_CAS_estado__c, MCH_TXT_respuesta__c FROM Mensaje_Clic_Hogar__c WHERE MCH_LKP_Caso__c =: casoId];

			if (listadoMensajes == null || listadoMensajes.size() == 0) {
				resultado.code = 'API-007';
				resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				system.debug(resultado);
				return resultado;
			}

			// Recorremos la lista
			for (Mensaje_Clic_Hogar__c mensaje:listadoMensajes){

				Rest_ClicHogar_DevolucionMens_RP.mensajes mens = new Rest_ClicHogar_DevolucionMens_RP.mensajes();

				// Seteamos los valores con los recibidos
				mens.Id = mensaje.Id;
				mens.MCH_TXT_asunto = mensaje.MCH_TXT_asunto__c;
				mens.MCH_TXT_consulta = mensaje.MCH_TXT_consulta__c;
				mens.MCH_DAT_fecha_alta_consulta = mensaje.MCH_DAT_fecha_alta_consulta__c;
				mens.MCH_DAT_fecha_respuesta = mensaje.MCH_DAT_fecha_respuesta__c;
				mens.MCH_CAS_estado = mensaje.MCH_CAS_estado__c;
				mens.MCH_TXT_respuesta = mensaje.MCH_TXT_respuesta__c;

				listaMensajes.add(mens);

			}

			resultado.code = 'API-001';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
			resultado.listadoMensajes = listaMensajes;
			system.debug(resultado);
			return resultado;

		}catch(Exception e){
			resultado.code = 'API-014';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
			system.debug(resultado);
			return resultado;
		}

	}

}