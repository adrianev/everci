public without sharing class Callout_Reintento_Llamada {
	private static HttpResponse resultMock;	
	
	/**
	 * Clase de respuesta.
	 *
	 */
	public class Resultado{
		public String codigo_error = '';
		public String mensaje_error = '';
	}		
	/**
	 * método que ejecuta el Callout contra el servicio externo
	 *
	 */
	public static Resultado sendDatos(Controller_Reintento_Llamada_RQ datos){

		Resultado res = new Resultado();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		INT_Bitacora__c aux = new INT_Bitacora__c();
		try{
			system.debug('datos.identificador'+datos.identificador);
			request.setEndPoint(datos.endPoint);
			request.setHeader('content-type','application/json;charset=UTF-8');
			request.setTimeout(15000);
			String returnToken = new GetTokenPSI().getToken();
			if(returnToken != ''){
				request.setHeader('Authorization',returnToken);
			}
			request.setBody(datos.body);
			system.debug('Request: '+request.getBody());
			HttpResponse response;
			if (!test.isRunningTest()) {
				aux = [SELECT BIT_NUM_Reintentos__c, id,BIT_TXT_Method__c FROM INT_Bitacora__c WHERE Name =: datos.identificador];
				//TODOS los callouts deben incluir un verbo para el envio, ponemos "PUT" como método por defecto en caso de que venga vacio.
				if(aux.BIT_TXT_Method__c != null)
					request.setMethod(aux.BIT_TXT_Method__c);
				else
					request.setMethod(Label.Callout_PUT);
				response = http.send(request);	
				system.debug('Response' + response);
			}else{
				setResponseMock();
				aux.BIT_SEL_Estado__c = '06';
				response = resultMock;  
			}

			JSONParser parser = JSON.createParser(response.getBody());  
			res = analizarRespuesta(parser);
			system.debug('res' + res);
			if(res.codigo_error != 'FAC-001' && res.codigo_error != 'PRS-001' && res.codigo_error != '001'){
				//Si el reintento no ha ido bien, se suma 1 intento más
				aux.BIT_TXT_Error__c = res.codigo_error + ' '+res.mensaje_error;
				aux.BIT_NUM_Reintentos__c = aux.BIT_NUM_Reintentos__c+1;
			}else{
				//Si el reintento ha ido bien, lo cambiamos a estado "Resuelto"
				aux.BIT_TXT_Error__c = '';
				aux.BIT_SEL_Estado__c = '06';
			}
			upsert aux;
			return res;

		}catch(Exception e){
			system.debug(e.getStackTraceString());
			//Si el reintento no ha ido bien, se suma 1 intento más
			aux.BIT_TXT_Error__c = res.codigo_error + ' '+res.mensaje_error;
			if(!test.isRunningTest())
				aux.BIT_NUM_Reintentos__c = aux.BIT_NUM_Reintentos__c+1;
			return null;
		}
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
				if('code'.equals(response.getText())){
					response.nextToken();
					res.codigo_error = response.getText();
				}
				if('message'.equals(response.getText())){
					response.nextToken();
					res.mensaje_error = response.getText();
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
				'"code": "PRS-001",' +
				'"message": "Operación ejecutada correctamente"}';

		resultMock = new HttpResponse();
		resultMock.setBody(body);

	}	
}