/**
 * Clase que expone un servicio para la generación de un caso correspondiente a un código de activación.
 *
 * @author EVERIS
 *
 */
@RestResource(urlMapping='/creacionCodigoActivacion')
global without sharing class Rest_B2C_CodigoActivacion {

	private static String requestBody;
	private static Integer contParametros;

	/**
	 * Clase de respuesta.
	 *
	 */

	global class Resultado{
		public String code = '';
		public String message = '';
		public String id = '';
		public String identificadorUnicoOrden = '';
	}

	/**
	 * Devuelve el resutado de crear el código de activación.
	 *
	 * @param CAS_LKP_Punto_de_venta : identificador de la compañía que solicita el servicio
	 * @param CAS_SEL_Gremio_Principal : gremio al que pertenece
	 * @param CAS_SEL_origen_web : origen web
	 * @param CAS_TXT_Codigo_Postal : código postal del cliente particular
	 * @param Description : descripción
	 *
	 * @return código de respuesta, descripción de respuesta, identificador del caso abierto y identificador de la orden de trabajo abierta
	 *
	 */

	@HttpPost
	global static Resultado doPost(String CAS_LKP_Punto_de_venta, String CAS_SEL_Gremio_Principal, String CAS_SEL_origen_web, String CAS_TXT_Codigo_Postal,
			String Description, String CAS_LKP_Baremo) {
		Resultado res = new Resultado();
		//contParametros se usa para el control de las "," de los JSON
		contParametros = 0;

		List<Account> puntoDeVenta = [SELECT Id, CUE_LKP_Cuenta_principal__c  FROM Account WHERE Id = :CAS_LKP_Punto_de_venta AND CUE_LKP_Cuenta_principal__r.CUE_CAS_Permite_Servicio_CodActivac__c = true];
		if (puntoDeVenta.isEmpty()) {
			requestBody = '{' + Util_WS_Error.devolverMensaje('API-002') + '}';
			JSONParser parser = JSON.createParser(requestBody);
			res = analizarRespuesta(parser);
			return res;
		}
		
		try {
			//Creación del caso, con los valores seteados
			Case caso = new Case();
			caso.CAS_TXT_DirRiesgo_CP__c = CAS_TXT_Codigo_Postal;
			caso.Origin = Label.CAS_ORIGIN_WEB;
			caso.CAS_SEL_origen_web__c = CAS_SEL_origen_web;
			caso.CAS_SEL_Gremio_Principal__c = CAS_SEL_Gremio_Principal;
			caso.Description = Description;
			caso.Type = Label.CAS_TIPO_CORRECTIVO;
			caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2B_B2B2C);
			caso.CAS_LKP_Compania__c = puntoDeVenta[0].CUE_LKP_Cuenta_principal__c;
			caso.CAS_LKP_Punto_de_venta__c = CAS_LKP_Punto_de_venta;
			
			List<Baremo__c> baremoAsoc =  [SELECT Id FROM Baremo__c WHERE BAR_TXT_Identificador__c =: CAS_LKP_Baremo LIMIT 1]; 
			if (baremoAsoc.isEmpty()) {
				requestBody = '{' + Util_WS_Error.devolverMensaje('API-019') + '}';
				JSONParser parser = JSON.createParser(requestBody);
				res = analizarRespuesta(parser);
				return res;
			}
			caso.CAS_LKP_Baremo__c = baremoAsoc[0].Id ;
			insert caso;
			
			//Crear un wo con una cita de servicio
			WorkOrder ordenTrabajo = new WorkOrder();
			ordenTrabajo.CaseId = caso.Id;
			ordenTrabajo.OTR_SEL_Gremio__c = CAS_SEL_Gremio_Principal;
			insert ordenTrabajo;

			requestBody = '{' + Util_WS_Error.devolverMensaje('API-001') + ',';
			concatenarParametroJSON('id', caso.Id);
			concatenarParametroJSON('identificadorUnicoOrden', ordenTrabajo.Id);
			requestBody +='}';

		}catch (Exception e){
			requestBody = '{'+ Util_WS_Error.devolverMensaje('API-004') +'}';
			JSONParser parser = JSON.createParser(requestBody);
			res = analizarRespuesta(parser);
			return res;
		}

		JSONParser parser = JSON.createParser(requestBody);
		res = analizarRespuesta(parser);
		return res;
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
				String gett = response.getText();
				if('code'.equals(response.getText())){
					response.nextToken();
					res.code = response.getText();
				}
				if('message'.equals(response.getText())){
					response.nextToken();
					res.message = response.getText();
				}
				if('id'.equals(response.getText())){
					response.nextToken();
					res.id = response.getText();
				}
				if('identificadorUnicoOrden'.equals(response.getText())){
					response.nextToken();
					res.identificadorUnicoOrden = response.getText();
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
		}else{
			if (contParametros > 0) {requestBody += ',';}
			requestBody += '"' + nombreParametro + '": ""';
			contParametros++;
		}
	}

}