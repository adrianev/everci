/**
 * Todo: Clase que se utilizará para actualizar siniestros de Vesta. 
		La configuración de la conectividad de la clase se encuentra en el metadato "Callout_ActualizaSiniestroVesta".
 * @author everis
 * @version 1.0
 */
public without sharing class Callout_ActualizaSiniestroVesta {

	private static HttpResponse resultMock; 
	private static String requestBody;
	private static Integer contParametros;

	/**
	 * Clase de respuesta.
	 *
	 */
	public without sharing class Resultado{
		public String resultado = 'OK';
		public String codigo_error = '';
		public String mensaje_error = '';
	}

	public without sharing class ActualizaSiniVestaException extends Exception {}

	// Include callout=true when making callouts
	@future(callout=true)
	public static void updateDatosAsync(String datosSerializados) {
		//Desserialize the data
		Callout_ActualizaSiniestroVesta_RQ datos = (Callout_ActualizaSiniestroVesta_RQ)JSON.deserialize(datosSerializados, Callout_ActualizaSiniestroVesta_RQ.class);
		// Call a method which contains the code to do the actual callout
		String response = JSON.serialize(updateDatos(datos));

		// log the response to a custom Object Resultado
		System.debug(response);
	}

	/*
	 * Método que implementa la lógica del callout (composición de RQ, envío y recoger la respuesta)
	 *
	 * @param datos: recibe los datos necesarios para componer la request al endpoint externo
	 * 
	 * @return Resultado: objeto que encapsula el body de la response obtenida.
	 */
	public static Resultado updateDatos(Callout_ActualizaSiniestroVesta_RQ datos){
		Resultado res = new Resultado();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		WS_Info__mdt ws_CASV = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_ActualizaSiniestroVesta'][0];
		request.setEndPoint(ws_CASV.EndPoint__c);
		request.setHeader('content-type',ws_CASV.Content_Type__c);
		request.setMethod(ws_CASV.Method__c);
		request.setTimeout(Integer.valueOf(ws_CASV.TimeOut__c));
		String returnToken = new GetTokenPSI().getToken();
		if(returnToken != ''){
			request.setHeader('Authorization',returnToken);

			if (datos.fechaCambio == null || datos.fechaCambio == '')
			{
				datos.fechaCambio = String.valueOf(system.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
			}

			contParametros = 0;
			requestBody = '{';
			concatenarParametroJSON('actuacion', datos.actuacion);
			concatenarParametroJSON('casoActualizacion', datos.casoActualizacion);
			concatenarParametroJSON('fechaCambio', datos.fechaCambio);
			concatenarParametroJSON('descripcionNoAbierto', datos.descripcionNoAbierto);
			concatenarParametroJSON('tipoSiniestro', datos.tipoSiniestro);
			concatenarParametroJSON('gremio', datos.gremio);
			concatenarParametroJSON('numeroSiniestroHS', datos.numeroSiniestroHS);
			concatenarParametroJSON('numeroSiniestroCia', datos.numeroSiniestroCia);
			concatenarParametroJSON('tipoSituacion', datos.tipoSituacion);
			concatenarParametroJSON('tipoSituacionReparacion', datos.tipoSituacionReparacion);
			requestBody += '}';

			request.setBody(requestBody);

			HttpResponse response;
			if (!test.isRunningTest()) {
				response = http.send(request);
			}else{
				setResponseMock();
				response = resultMock;  
			}

			JSONParser parser = JSON.createParser(response.getBody());
			res = analizarRespuesta(parser);

		}else{
			res = new Resultado();
			res.codigo_error = '4';
			res.mensaje_error = 'Error al pedir el token';
			res.resultado = 'KO';       	
		}
		return res;
	}

	/* 
	 *	Método encargado de analizar la respuesta del sistema tercero y transformarla en un objeto Resultado;
	 * 	que encapsula el body de la response.
	 *  	@param response: instancia de JSON parser inicializada con la response en forma de String
	 *   
	 */
	private static Resultado analizarRespuesta(JSONParser response){
		Resultado res = new Resultado();
		if (response != null)
		{
			while(response.nextToken() != null){
				if('CODIGO_ERROR'.equals(response.getText())){
					response.nextToken();
					res.codigo_error = response.getText();
					response.nextToken();
				}
				if('MENSAJE_ERROR'.equals(response.getText())){
					response.nextToken();
					res.mensaje_error = response.getText();
					response.nextToken();
				}
				if('RESULTADO'.equals(response.getText())){
					response.nextToken();
					res.resultado = response.getText();
					response.nextToken();
				}
			}
		}
		return res;
	}

	/*
	 * Método encargado de simular el mensaje de respuesta en los test; se simula 
	 * el mensaje a recibir mediente la inicialización de un valor que se provee al constructor
	 *
	 */
	private static void setResponseMock(){
		String body = '{' +
				'"CODIGO_ERROR": "0",' +
				'"MENSAJE_ERROR": "OK ",' +
				'"RESULTADO": "OK"}';

		resultMock = new HttpResponse();
		resultMock.setBody(body);
	}

	/*
	 * Métodos auxiliares para formatear como JSON una String
	 *
	 * @parameter nombreParametro: Nombre del parámetro a insertar en el body de la request
	 * @parameter valorParametro: valor del campo a pasar a incluir en la request
	 *
	 */

	private static void concatenarParametroJSON(String nombreParametro, Integer valorParametro)
	{
		if (valorParametro != null)
		{
			if (contParametros > 0) {requestBody += ',';}
			requestBody += '"' + nombreParametro + '" : ' + valorParametro;
			contParametros++;
		}
	}

	private static void concatenarParametroJSON(String nombreParametro, String valorParametro)
	{
		if (valorParametro != null)
		{
			if (contParametros > 0) {requestBody += ',';}
			requestBody += '"' + nombreParametro + '" : "' + valorParametro + '"';
			contParametros++;
		}
	}
}