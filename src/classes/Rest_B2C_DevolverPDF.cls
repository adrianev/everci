/**
 * Clase que expone un servicio para la creación y devolución de un PDF con el código de activación.
 * 
 * @author everis
 * @version 1.0
 */

@RestResource(urlMapping='/pdfCodigoActivacion/*')
global without sharing class Rest_B2C_DevolverPDF {

	private static String requestBody;
	private static Integer contParametros;

	/**
	 * Clase de respuesta
	 *
	 */
	global class Resultado{
		public String code = '';
		public String message = '';
		public String pdf = '';
	}

	/**
	 * Método que devuelve el PDF con formato base 64 de un caso indicado
	 *
	 * @param Id : Identificador del caso
	 *
	 * @return código de respuesta, descripción de respuesta y el PDF con formato base 64.
	 *
	 */
	@HttpGet
	global static Resultado doGet() {
		//contParametros se usa para el control de las "," de los JSON
		contParametros = 0;
		String textoPDF = '';

		Resultado respuesta = new Resultado();

		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		String id = RestContext.request.params.get('Id');

		List<Case> caso = Util_Caso.getCasosByIdServicioCodActivac(new Set<Id>{id},true,new Set<String>{Label.IDE_WORTEN}).values();
		/*List<Case> caso = [SELECT Id,
								  CaseNumber,
								  CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
								  CAS_LKP_Compania__r.CUE_CAS_Permite_Servicio_CodActivac__c
						   FROM Case
						   WHERE Id =: id AND (CAS_LKP_Compania__r.CUE_CAS_Permite_Servicio_CodActivac__c=true OR CAS_LKP_Compania__r.CUE_TXT_Identificador__c =: Label.IDE_WORTEN)];*/
		if (caso == null || caso.size() == 0) {
			requestBody = '{' + Util_WS_Error.devolverMensaje('API-007') + '}';
			JSONParser parser = JSON.createParser(requestBody);
			respuesta = analizarRespuesta(parser);
			return respuesta;
		}

		//try{
			ContentVersion cv;
			system.debug('---- SVV. Identificador compañia: ' + caso[0].CAS_LKP_Compania__r.CUE_TXT_Identificador__c);
			if (caso[0].CAS_LKP_Compania__r.CUE_TXT_Identificador__c == Label.IDE_WORTEN) {
				List<ContentVersion> documento = [SELECT Id, VersionData FROM ContentVersion WHERE Title LIKE '%ComprobanteServicio%' AND FirstPublishLocationId =: caso[0].Id];
				system.debug('---- SVV. Documento: ' + documento);
				if (documento == null || documento.size() == 0) {
					cv = Util_Documentacion.crearPDFDesdeVF(caso[0].Id, null, Label.PDF_TIPO_COMPROBANTE,
															Label.IDE_WORTEN, null, caso[0].CaseNumber, null, null);
					textoPDF = EncodingUtil.base64Encode(cv.VersionData);
				}
				else{
					textoPDF = EncodingUtil.base64Encode(documento[0].VersionData);
				}	
			}
			else {
				cv = Util_Documentacion.crearPDFDesdeVF(caso[0].Id, null, Label.PDF_TIPO_COMPROBANTE,
														caso[0].CAS_LKP_Compania__r.CUE_TXT_Identificador__c,
														Label.IDIOMA_POR_DEFECTO, caso[0].CaseNumber, null, null);
				textoPDF = EncodingUtil.base64Encode(cv.VersionData);
			}
		/*}catch(exception e){
			requestBody = '{' + Util_WS_Error.devolverMensaje('API-008') + '}';
			JSONParser parser = JSON.createParser(requestBody);
			respuesta = analizarRespuesta(parser);
			return respuesta;
		}*/
		if (textoPDF.length() >= 6000000){
			requestBody = '{' + Util_WS_Error.devolverMensaje('API-015') + '}';
			JSONParser parser = JSON.createParser(requestBody);
			respuesta = analizarRespuesta(parser);
			return respuesta;
		}

		requestBody = '{';
		requestBody += Util_WS_Error.devolverMensaje('API-001');
		requestBody += ',';
		concatenarParametroJSON('pdf', textoPDF);
		requestBody +='}';
		JSONParser parser = JSON.createParser(requestBody);
		respuesta = analizarRespuesta(parser);
		return respuesta;
	}

	/**
	 * Método que devuelve la respuesta para este servicio.
	 *
	 */
	private static Resultado analizarRespuesta(JSONParser response){
		Resultado res = new Resultado();
		if (response != null)
		{
			while(response.nextToken() != null){
				if('code'.equals(response.getText())){
					response.nextToken();
					res.code = response.getText();
					response.nextToken();
				}
				if('message'.equals(response.getText())){
					response.nextToken();
					res.message = response.getText();
					response.nextToken();
				}
				if('pdf'.equals(response.getText())){
					response.nextToken();
					res.pdf = response.getText();
					response.nextToken();
				}
			}
		}
		return res;
	}

	/**
	 * Método que concatena los parámetros en un JSON
	 *
	 * @param nombreParametro: nombre del parámetro a concatenar
	 * @param valorParametro: valor del parámetro a concatenar
	 *
	 */
	private static void concatenarParametroJSON(String nombreParametro, String valorParametro)
	{
		if (valorParametro != null)
		{
			if (contParametros > 0) {requestBody += ',';}
			requestBody += '"' + nombreParametro + '": "' + valorParametro + '"';
			contParametros++;
		}
	}
}