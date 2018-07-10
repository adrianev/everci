/**
 * Clase que se utilizará para cambiar la contraseña de un usuario de ClicHogar
 *
 * @author EVERIS
 * 
 */

@RestResource(urlMapping='/caso/cambioContrasenya')
global without sharing class Rest_CambioContrasenyaClicHogar {

	/**
	 * Devuelve un código y una descripción, dependiendo si la contraseña ha sido o no cambiada.
	 *
	 * @param CAS_TXT_Usuario_Clic_Hogar : usuario de clic hogar asociado al caso
	 * @param CAS_TXT_Password_Clic_Hogar : contraseña de usuario de clic hogar asociado al caso
	 * @param passwordAnterior : contraseña anterior
	 *
	 * @return código y descripción de la respuesta.
	 *
	 */

	@HttpPatch
	global static Rest_CambioContrasenyaClicHogar_RP doPatch(String CAS_TXT_Usuario_Clic_Hogar, String CAS_TXT_Password_Clic_Hogar, String passwordAnterior) {
		Rest_CambioContrasenyaClicHogar_RP resultado = new Rest_CambioContrasenyaClicHogar_RP();

		try {

			//Si se va a CAMBIAR CONTRASEÑA,  password anterior vendrá en la request
			if (passwordAnterior != null && passwordAnterior != '' ){
				
				List<Case> caso = [SELECT Id, CAS_TXT_Password_Clic_Hogar__c, CAS_TXT_Usuario_Clic_Hogar__c FROM Case 
			                   WHERE CAS_TXT_Usuario_Clic_Hogar__c =: CAS_TXT_Usuario_Clic_Hogar AND CAS_TXT_Password_Clic_Hogar__c =: passwordAnterior];
			          
			    if (caso == null || caso.size() == 0) {
					resultado.code = 'API-013';
					resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
					system.debug(resultado);
					return resultado;
				}	
			    //Existe ese usuario con esa password, se hace el cambio de contraseña      
				caso[0].CAS_TXT_Password_Clic_Hogar__c = CAS_TXT_Password_Clic_Hogar;
				update caso[0];
				
				resultado.code = 'API-001';
				resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);

			}

			//Si es un RESETEO, ninguno de los campos de contraseña vendrán rellenos
			else if (passwordAnterior == null || passwordAnterior == '' || CAS_TXT_Password_Clic_Hogar == null || CAS_TXT_Password_Clic_Hogar == '' ){
				
				if (String.isEmpty(CAS_TXT_Usuario_Clic_Hogar)) {
					resultado.code = 'API-014';
					resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				}
				else {
					List<Case> caso = [SELECT Id, CAS_TXT_Password_Clic_Hogar__c, CAS_TXT_Usuario_Clic_Hogar__c FROM Case 
			                   WHERE CAS_TXT_Usuario_Clic_Hogar__c =: CAS_TXT_Usuario_Clic_Hogar ];
				
					caso[0].CAS_TXT_Password_Clic_Hogar__c =  caso[0].Id;
					update caso[0];
					
					resultado.code = 'API-001';
					resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				}
				
			}
			system.debug(resultado);
			return resultado;

		}
		catch (Exception e) {
			resultado.code = 'API-014';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
			return resultado ;
		}   
	}
}