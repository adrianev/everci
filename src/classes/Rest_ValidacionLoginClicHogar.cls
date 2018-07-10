/*
    Esta clase implementa la validación de un Usuario de ClicHogar
     @author everis
     @version 1.0
 */
@RestResource(urlMapping='/caso/validacionLogin/*')
global without sharing class Rest_ValidacionLoginClicHogar {

	/**
	 * Devuelve el identificador del caso y de la compañia, si la validación ha sido correcta
	 *
	 * @param CAS_TXT_Usuario_Clic_Hogar : usuario de Clic Hogar asociado al caso
	 * @param CAS_TXT_Password_Clic_Hogar : contraseña de Clic Hogar asociado al caso
	 *
	 * @return codigo y mensaje de respuesta, identificador de caso e identificador de la compañia
	 *
	 */
	@HttpGet
	global static Rest_ValidacionLoginClicHogar_RP doGet() {

		Rest_ValidacionLoginClicHogar_RP resultado = new Rest_ValidacionLoginClicHogar_RP();

		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		String usuarioClicHogar = RestContext.request.params.get('CAS_TXT_Usuario_Clic_Hogar');
		String passwdClicHogar = RestContext.request.params.get('CAS_TXT_Password_Clic_Hogar');

		try {

			List<Case> caso = [SELECT Id, CAS_LKP_Compania__r.CUE_TXT_Identificador__c, CAS_NUM_Contador_Clic_Hogar__c, ClosedDate FROM Case 
			                   WHERE CAS_TXT_Usuario_Clic_Hogar__c =: usuarioClicHogar AND CAS_TXT_Password_Clic_Hogar__c =: passwdClicHogar];
			
			if (caso == null || caso.size() == 0) {
				resultado.code = 'API-012';
				resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				system.debug('>>>>>>>RESULTADO: ' + resultado);
				return resultado;
			}
			
			if (!String.isEmpty(String.valueOf(caso[0].ClosedDate))) {
				Integer mesesPasados = Date.TODAY().addMonths(- caso[0].ClosedDate.MONTH()).month();
				//Ha pasado más de un mes del cierre del siniestro
				if (mesesPasados > 1) {
					resultado.code = 'API-025';
					resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
					system.debug('>>>>>>>RESULTADO: ' + resultado);
					return resultado;
				}
				else if (mesesPasados == 1) {
					if (Date.TODAY().day() > caso[0].ClosedDate.DAY()) {
						resultado.code = 'API-025';
						resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
						system.debug('>>>>>>>RESULTADO: ' + resultado);
						return resultado;
					}
				}
			}
			
			String IdCaso = String.valueOf(caso[0].Id);
			//Usuario valido, pero tiene que cambiar la contraseña
			if (passwdClicHogar == IdCaso || passwdClicHogar == IdCaso.substring(0,15)) {
				resultado.code = 'API-024';
				resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				system.debug('>>>>>>>RESULTADO: ' + resultado);
				return resultado;
			}
			else {
				//Existe el usuario y la contraseña
				if (caso[0].CAS_NUM_Contador_Clic_Hogar__c == 0 || caso[0].CAS_NUM_Contador_Clic_Hogar__c == null) {
					//Primera vez que se accede
					system.debug('>>>>>>>RESULTADO: ' + resultado);
					resultado.code = 'API-010';
					resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				}
				else {
					//No es la primera vez que se accede
					system.debug('>>>>>>>RESULTADO: ' + resultado);
					resultado.code = 'API-009';
					resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code); 
				}
				resultado.Id = caso[0].Id;
				resultado.identificadorCompania = caso[0].CAS_LKP_Compania__r.CUE_TXT_Identificador__c;
	
				if (caso[0].CAS_NUM_Contador_Clic_Hogar__c == null) {
					caso[0].CAS_NUM_Contador_Clic_Hogar__c = 1;
				}
				else {
					caso[0].CAS_NUM_Contador_Clic_Hogar__c = caso[0].CAS_NUM_Contador_Clic_Hogar__c + 1;
				}
				update caso[0];
			}
			system.debug('>>>>>>>RESULTADO: ' + resultado);
			return resultado;
		}
		catch(Exception e){
			system.debug('>>>>>>>EXCEPTION: ' + e + ' ' + e.getStackTraceString());
			resultado.code = 'API-014';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
			return resultado;
		}
	}  
}