/**
 * Clase que se utilizará para consultar, desde el área de clientes Membership, información de las Reclamaciones
	para un cliente Membership relativas con sus servicios Membership
 * @author everis
 * @version 1.0
 */

@RestResource(urlMapping='/consultarReclamacion/*')
global without sharing class Rest_ConsultaReclamacionMembership {

	/**
	 * Método que consulta la información de los siniestros de tipo Reclamación, devolviendo la información de ese siniestro
	 *
	 * @param CAS_SEL_origen_web : procedencia
	 * @param CUE_TXT_Numero_Documento : Número de documento del cliente
	 *
	 * @return información de siniestros de tipo 'Reclamación'
	 *
	 */

	@HttpGet
	global static Rest_ConsultaReclamacionMembership_RP doGet(){

		Rest_ConsultaReclamacionMembership_RP respuesta = new Rest_ConsultaReclamacionMembership_RP();
		List<Rest_CaseReclamacion_RP> auxReclamacionList = new List<Rest_CaseReclamacion_RP>();

		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		String origenWeb = RestContext.request.params.get('CAS_SEL_origen_web');
		String numeroDocumento = RestContext.request.params.get('CUE_TXT_Numero_Documento');

		List<Account> cuenta = [SELECT Id,CUE_TXT_Numero_Documento__c FROM Account 
		                        WHERE CUE_TXT_Numero_Documento__c =: numeroDocumento];

		if (cuenta == null || cuenta.size() == 0) {
			respuesta.code = 'MEM-007';
			respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
			system.debug(respuesta);
			return respuesta;
		}

		String cuentaId = cuenta[0].Id;

		List<Case> reclamacion = [SELECT CaseNumber,CAS_SEL_Comunicador_Recl__c,CAS_SEL_Naturaleza__c,
		                          CAS_TXT_Sondeo_Tipo_de_Carta__c,ClosedDate,CreatedDate,ParentId,RecordType.Name,Status 
		                          FROM Case WHERE AccountId =: cuentaId AND CAS_LKP_Compania__r.CUE_TXT_Identificador__c =: Label.IDE_MEMBERSHIP 
		                          AND RecordType.DeveloperName =: Label.RT_CAS_RECLAMACION.split(':').get(1)];

		for(Case recl : reclamacion) {

			Rest_CaseReclamacion_RP reclamacionAux = new Rest_CaseReclamacion_RP();
			reclamacionAux.caseNumber = recl.CaseNumber;
			reclamacionAux.Parent = recl.ParentId;
			reclamacionAux.RecordType = recl.RecordType.Name;
			reclamacionAux.CreatedDate = recl.CreatedDate;
			reclamacionAux.Status = recl.Status;
			reclamacionAux.estadoLiteral = Util_Listas_Seleccion.getLabelDesdeAPI('Case', 'Status').get(recl.Status);
			reclamacionAux.CAS_SEL_Naturaleza = recl.CAS_SEL_Naturaleza__c;
			reclamacionAux.naturalezaLiteral = Util_Listas_Seleccion.getLabelDesdeAPI('Case', 'CAS_SEL_Naturaleza__c').get(recl.CAS_SEL_Naturaleza__c);
			reclamacionAux.ClosedDate = recl.ClosedDate;
			reclamacionAux.CAS_SEL_Comunicador_Recl = recl.CAS_SEL_Comunicador_Recl__c;
			reclamacionAux.CAS_TXT_Sondeo_Tipo_de_Carta = recl.CAS_TXT_Sondeo_Tipo_de_Carta__c;

			auxReclamacionList.add(reclamacionAux);
		}

		respuesta.listadoCaso = auxReclamacionList; 
		respuesta.code = 'MEM-001';
		respuesta.message = Util_WS_Error.devolverMensajeRespuesta(respuesta.code);
		system.debug(respuesta);
		return respuesta; 

	}
}