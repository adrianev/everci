/**
 * Todo: Clase que se utilizará para validar el alta de un cliente Membership que desea registrarse en el área de clientes
 * @author everis
 * @version 1.0
 */

@RestResource(urlMapping='/validarCliente/*')
global without sharing class Rest_ValidaClienteMember {

	/**
	 * Devuelve la validación de un cliente de Membership
	 *
	 * @param CUE_TXT_Numero_Documento : número de documento vinculado a la cuenta
	 * @param WorkOrderNumber : número de orden de trabajo
	 * @param CaseNumber : número de servicio/siniestro
	 * @param CAS_SEL_origen_web :  código de origen web
	 *
	 * @return codigo y mensaje de respuesta, dependiendo si el cliente ha sido o no validado
	 *
	 */
	@HttpGet
	global static Rest_ValidaClienteMember_RP doGet() {
		Rest_ValidaClienteMember_RP resultado = new Rest_ValidaClienteMember_RP();

		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		String numeroCliente = RestContext.request.params.get('CUE_TXT_Numero_Documento');
		String numOrdenTrabajo = RestContext.request.params.get('WorkOrderNumber');
		String numCaso = RestContext.request.params.get('CaseNumber');
		String procedenciaCliente = RestContext.request.params.get('CAS_SEL_origen_web');

		List<Account> cuenta;

		//Ambos campos están vacios
		if (numOrdenTrabajo.length() == 0 && numCaso.length() == 0) {
			resultado.code = 'MEM-005';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
			system.debug(resultado);
			return resultado;
		}

		//Se comprueba que existe la wo o el caso
		List<WorkOrder> OrdTra = [SELECT CaseId,AccountId FROM WorkOrder WHERE WorkOrderNumber =: numOrdenTrabajo];
		List<Case> Caso = [SELECT Id,AccountId,CAS_LKP_Compania__r.CUE_TXT_Identificador__c FROM Case WHERE CaseNumber =: numCaso];


		//Solo han proporcionado el número de caso
		if (numOrdenTrabajo.length() == 0 && numCaso.length() != 0) {
			if (Caso == null || Caso.size() == 0) {
				resultado.code = 'MEM-005';
				resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				system.debug(resultado);
				return resultado;
			}
			//Se comprueba que sea de Membership
			if (Caso[0].CAS_LKP_Compania__r.CUE_TXT_Identificador__c != Label.IDE_MEMBERSHIP) {
				resultado.code = 'MEM-005';
				resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				system.debug(resultado);
				return resultado;
			}
			cuenta = [SELECT CUE_TXT_Numero_Documento__c FROM Account WHERE Id =: Caso[0].AccountId];
		}
		//Solo han proporcionado el número de la orden de trabajo
		if (numOrdenTrabajo.length() != 0 && numCaso.length() == 0) {

			if (OrdTra == null || OrdTra.size() == 0) {
				resultado.code = 'MEM-005';
				resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				system.debug(resultado);
				return resultado;
			}
			//Se comprueba que sea de membership
			List<Case> IdentCompania = [SELECT CAS_LKP_Compania__r.CUE_TXT_Identificador__c FROM Case WHERE Id =: OrdTra[0].CaseId];
			if (IdentCompania[0].CAS_LKP_Compania__r.CUE_TXT_Identificador__c != Label.IDE_MEMBERSHIP) {
				resultado.code = 'MEM-005';
				resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				system.debug(resultado);
				return resultado;
			}
			cuenta = [SELECT CUE_TXT_Numero_Documento__c FROM Account WHERE Id =: OrdTra[0].AccountId];
		}
		//Hay información de los dos campos (número de orden de trabajo y número de caso)
		if (numOrdenTrabajo.length() != 0 && numCaso.length() != 0) {
			//Se analiza si estan o no relacionados los campos
			if (OrdTra == null || OrdTra.size() == 0 || Caso == null || Caso.size() == 0) {
				resultado.code = 'MEM-005';
				resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				system.debug(resultado);
				return resultado;
			}

			if (OrdTra[0].CaseId != Caso[0].Id) {
				resultado.code = 'MEM-005';
				resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				system.debug(resultado);
				return resultado;
			}

			if (Caso[0].CAS_LKP_Compania__r.CUE_TXT_Identificador__c != Label.IDE_MEMBERSHIP) {
				resultado.code = 'MEM-005';
				resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
				system.debug(resultado);
				return resultado;
			}
			cuenta = [SELECT CUE_TXT_Numero_Documento__c FROM Account WHERE Id =: Caso[0].AccountId];

		}

		if (cuenta == null || cuenta.size() == 0 || cuenta[0].CUE_TXT_Numero_Documento__c != numeroCliente) {
			resultado.code = 'MEM-006';
			resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
			system.debug(resultado);
			return resultado;
		}

		resultado.code = 'MEM-001';
		resultado.message = Util_WS_Error.devolverMensajeRespuesta(resultado.code);
		system.debug(resultado);
		return resultado;
	}
}