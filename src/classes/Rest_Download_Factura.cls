/**
 * Clase que expone un servicio para devolver el documento asociado a una factura
 * @author everis
 * @version 1.0
 */

@RestResource(urlMapping='/descargaFactura/*')
global without sharing class Rest_Download_Factura {

	private static String requestBody;
	private static Integer contParametros;

	/**
	 * Clase de respuesta
	 *
	 */
	global without sharing class Resultado{
		public String code = '';
		public String message = '';
		public String pdfFactura = '';
		public String FAC_TXT_Numero_factura = '';
	}

	/**
	 * Método que devuelve el documento de una factura
	 *
	 * @param Id : Identificador de la factura
	 *
	 * @return documento de una factura
	 *
	 */
	@HttpGet
	global static Resultado doGet() {
		//contParametros se usa para el control de las "," de los JSON
		Resultado respuesta = new Resultado();
		contParametros = 0;

		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		String id = RestContext.request.params.get('Id');

		if (!(id.length() == 15 || id.length() == 18)){
			requestBody = '{' + Util_WS_Error.devolverMensaje('MEM-004') + '}';
			JSONParser parser = JSON.createParser(requestBody);
			respuesta = analizarRespuesta(parser);
			system.debug(respuesta);
			return respuesta;
		}

		List<Factura__c> factura = new List<Factura__c>([SELECT Id, FAC_TXT_Numero_factura__c FROM Factura__c WHERE Id =: id]);
		try{
			Id idFactura = factura[0].Id;
			List<ContentDocumentLink> link = new List<ContentDocumentLink>([SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: idFactura]);
			List<ContentDocument> doc = new List<ContentDocument>([SELECT LatestPublishedVersionId FROM ContentDocument WHERE Id =: link[0].ContentDocumentId]);
			List<ContentVersion> cv = new List<ContentVersion>([SELECT VersionData FROM ContentVersion WHERE Id =: doc[0].LatestPublishedVersionId]);
			requestBody = '{';
			requestBody += Util_WS_Error.devolverMensaje('MEM-001');
			requestBody += ',';
			concatenarParametroJSON('pdfFactura', EncodingUtil.base64Encode(cv[0].VersionData));
			concatenarParametroJSON('FAC_TXT_Numero_factura', factura[0].FAC_TXT_Numero_factura__c);
			requestBody += '}';
		}catch(exception e){

			requestBody = '{' + Util_WS_Error.devolverMensaje('MEM-012') + '}';
			JSONParser parser = JSON.createParser(requestBody);
			respuesta = analizarRespuesta(parser);
			system.debug(respuesta);
			return respuesta;
		}
		JSONParser parser = JSON.createParser(requestBody);
		respuesta = analizarRespuesta(parser);
		system.debug(respuesta);
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
				if('pdfFactura'.equals(response.getText())){
					response.nextToken();
					res.pdfFactura = response.getText();
					response.nextToken();
				}
				if('FAC_TXT_Numero_factura'.equals(response.getText())){
					response.nextToken();
					res.FAC_TXT_Numero_factura = response.getText();
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