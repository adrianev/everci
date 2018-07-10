/**
 *   Clase que se utilizará para actualizar el email del tomador de contrato Membership. 
 *		La configuración de la conectividad de la clase se encuentra en el metadato "Callout_ActualizaEmail".
 *
 * @author everis
 * @version 1.0
 */

public without sharing class Callout_ActualizaEmail {

	private static HttpResponse resultMock;
	private static String body;
	private static Integer contParametros;
    public static Integer simulationVal;


	/*
	* Resultado :
	* Clase de uso auxiliar que encapsula la respuesta del sistema tercero  en dos atributos,
	* el código de error y el mensaje de error
	*/
	public without sharing class Resultado{
		public String code;
		public String message;
	}

	/*
	 * Método que implementa el core de la llamada a Ensura, informando de novedades con respecto a los emails de un cliente No Robinson 
	 *
	 * @param bodyInsert : String que contiene la request a Ensura en formato JSON.
	 * @param nombreIntegracion: código asociado con la integración (en este caso concreto el valor es 'SRV-PSI-71').
	 * @param idBitácora: identificador unívoco de la entrada en la tabla de bitácora que monitoriza el estado del callout
	 * @param idContacto: identificador del contacto asociado a una cuenta NO Robinson y el cual ha sido insertado o se ha actualizado algún campo de email. 
	 * @param usuario: identificador de usuario(número de documento), que se se incluye como parte de la request. Se utiliza para la construcción de una response simulada.
	 * @param emailCompania: email del cliente que se envía al sistema tercero
	 * @param idCompania: identificador de la cuenta asociada al contacto modificado en el sistema de Ensura
	 * @return void; no se devuelve nada
	 */
	  @future(callout=true)
	public static void updateDatos(String bodyInsert, String nombreIntegracion, String idBitacora, String idContacto, String usuario, String emailCompania,String idCompania) {


		Callout_ActualizaEmail_RQ rq = new Callout_ActualizaEmail_RQ();
		rq.usuario =usuario;
		rq.emailCompania =emailCompania;
		rq.identificadorCompania = idCompania ;
		INT_Bitacora__c bitacora ;
		Resultado res = new Resultado();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		//1. Obtenemos los parámetros de configuración del header desde un metadato que hemos creado
		WS_Info__mdt ws_AE = Util_Metadatos.getWSInfoMetadataByMasterLabel(new Set<String>{'Callout_ActualizaEmail'}).values().get(0);
		//WS_Info__mdt ws_AE = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_ActualizaEmail'][0];

		try{
			System.debug('---------- Req Callout Actualiza Email');
			request.setHeader('content-type',ws_AE.Content_Type__c);
			request.setEndPoint(ws_AE.EndPoint__c+'/'+rq.identificadorCompania+'/email'); 
			request.setMethod(ws_AE.Method__c);
			request.setTimeout(Integer.valueOf(ws_AE.TimeOut__c));
			request.setBody(bodyInsert);
			system.debug('>>>>>>verBody: '+bodyInsert);
			HttpResponse response;
	
			if (!test.isRunningTest()) {
			//if (test.isRunningTest()) {
				//1.Obtenemos el token para conectarnos a PSI
                String returnToken = new GetTokenPSI().getToken();
                if(returnToken != ''){
                	request.setHeader('Authorization',returnToken);
                }
                else{
					res.code = '04';
   					res.message = 'Error al pedir el token';
         
 					system.debug('Error al pedir token PSI');
         			bitacora = [SELECT BIT_NUM_Reintentos__c,BIT_TXT_Error__c,BIT_SEL_Estado__c,BIT_TXT_Nombre_Integracion__c FROM INT_Bitacora__c WHERE id=:idBitacora];
					if(bitacora.BIT_NUM_Reintentos__c != null){
						bitacora.BIT_NUM_Reintentos__c = bitacora.BIT_NUM_Reintentos__c+1;
					}else{
						bitacora.BIT_NUM_Reintentos__c = 1;
					}
         			Util_Llamada_Externa.insertarBitacora('', res.code + ' ' + res.message, '03', '02', 'ENSURA - ' + nombreIntegracion + ' - Actualizar Email', bodyInsert, 
						ws_AE.EndPoint__c+rq.identificadorCompania+'/email','',idContacto,'','','','',0,idBitacora,bitacora.BIT_NUM_Reintentos__c,Label.Callout_PUT);
         
         			return; 
    			}
				response = http.send(request);
				
			}else{
				setResponseMock(rq);
				response = resultMock;	
			}
			system.debug('>>>>>imprimeRes ' + response.getBody());
            
			JSONParser parser = JSON.createParser(response.getBody());	
			res = analizarRespuesta(parser);
            system.debug(res + 'respuestaaaa');
			
			if (res.code != '000') {
				bitacora = [SELECT BIT_NUM_Reintentos__c,BIT_TXT_Error__c,BIT_SEL_Estado__c,BIT_TXT_Nombre_Integracion__c FROM INT_Bitacora__c WHERE id=:idBitacora];
				if(bitacora.BIT_NUM_Reintentos__c != null){
					bitacora.BIT_NUM_Reintentos__c = bitacora.BIT_NUM_Reintentos__c+1;
				}else{
					bitacora.BIT_NUM_Reintentos__c = 1;
				}
				Util_Llamada_Externa.insertarBitacora('', res.code + ' ' + res.message, '03', '02', 'ENSURA - ' + nombreIntegracion + ' - Actualizar Email', bodyInsert, 
					ws_AE.EndPoint__c+rq.identificadorCompania+'/email','',idContacto,'','','','',0,idBitacora,bitacora.BIT_NUM_Reintentos__c,Label.Callout_PUT);
			}
			else {
				system.debug('ENTRA EN 000');
				bitacora = [SELECT Id,BIT_SEL_Estado__c,BIT_TXT_Json__c FROM INT_Bitacora__c WHERE id=:idBitacora];
				bitacora.BIT_SEL_Estado__c = '06';
				bitacora.BIT_TXT_Json__c = bodyInsert;
				bitacora.BIT_TXT_Nombre_Integracion__c = 'ENSURA - ' + nombreIntegracion + ' - Actualizar Email';
				bitacora.BIT_TXT_EndPoint__c = ws_AE.EndPoint__c+'/'+rq.identificadorCompania+'/email' ;
				system.debug('idBitacora: '+bitacora.Id + ' '+idBitacora);
				upsert bitacora;
			}
    	}
    	catch (Exception e){
    		system.debug('---- Excepcion: ' + e);
    		List<INT_Bitacora__c> bitacoraAux =[SELECT BIT_NUM_Reintentos__c FROM INT_Bitacora__c WHERE id=:idBitacora];
			if(!bitacoraAux.isEmpty()){
				if(bitacoraAux.get(0).BIT_NUM_Reintentos__c != null){
					bitacoraAux.get(0).BIT_NUM_Reintentos__c = bitacoraAux.get(0).BIT_NUM_Reintentos__c+1;
				}else{
					bitacoraAux.get(0).BIT_NUM_Reintentos__c = 1;
				}				
				Util_Llamada_Externa.insertarBitacora('', res.code + ' ' + res.message, '03', '02', 'ENSURA - ' + nombreIntegracion + ' - Actualizar Email', bodyInsert, 
					ws_AE.EndPoint__c+rq.identificadorCompania+'/email','',idContacto,'','','','',0,idBitacora,bitacoraAux.get(0).BIT_NUM_Reintentos__c,Label.Callout_PUT);
			}
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
					res.code = response.getText();
				}
				if('message'.equals(response.getText())){
					response.nextToken();
					res.message = response.getText();
				}
			}
		}
		return res;
	}

	/*
	 * 	Método encargado de simular el mensaje de respuesta en los test; se simula 
	 * 	el mensaje a recibir mediente la inicialización de un valor que se provee al constructor
	 *
	 * @param datos: Detalles para insertar en la request.
	 *
	 * @return void 
	 */
	public static void setResponseMock(Callout_ActualizaEmail_RQ datos){
        if(simulationVal == null){
			simulationVal = 0;
		}
		else{
			simulationVal = simulationVal +1 ;
		}
        
		String body = '';
		
		if(simulationVal == 0){
			body = '{'+
				'"code" : "000",'+
				'"message" : "SUCCESS – Email of customer with id' + datos.usuario + ' updated the email to ' + datos.emailCompania + '\"' +
				'}';
			system.debug('VALOR SIMULACION : 000');
		}
		else if(simulationVal == 1){
			body = '{'+
				'"code" : "102",'+
				'"message" : "ERROR – Field datosUsuario is Empty \"' +
				'}';
			system.debug('VALOR SIMULACION : 102'); 
		}
		else{
			body = '{'+
				'"code" : "202",'+
				'"message" : "ERROR – Customer with id '+datos.usuario+ ' not found\"' +
				'}';
			system.debug('VALOR SIMULACION : 202');
		}
		
		resultMock = new HttpResponse();
		resultMock.setBody(body);
	}


  /*
    * Método auxiliar para formatear como JSON una String
    * @parameter nombreParametro: Nombre del parámetro a insertar en el body de la request
    * @parameter valorParametro: valor del campo a pasar a incluir en la request
    *
    * @return void
    */
    private static void concatenarParametroJSON(String nombreParametro, String valorParametro)
	{
		if (contParametros > 0) {body += ',';}
		body += '"' + nombreParametro + '" : "' + valorParametro + '"';
		contParametros++;
	}
	
 	/**
    * Clase que construye el body de la request para este callout.
    * @param datos: recibe una instancia de la clase Callout_ActualizaEmail_RQ, que contiene como atributos todos los campos necesarios para realizar el callout correctamente.
    * @return String: body de la request en formato JSON
    */
    public static String construirBody(Callout_ActualizaEmail_RQ  datos) {
    	contParametros = 0;
    	body = '{';
        concatenarParametroJSON('usuario', datos.usuario);
        concatenarParametroJSON('emailCompania', datos.emailCompania);
        body += '}' ;
        return body;
    }
}