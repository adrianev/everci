/**
 * Clase que se utilizará para actualizar telefonos del tomador de contrato Membership. 
		La configuración de la conectividad de la clase se encuentra en el metadato "Callout_ActualizaTelefono".
 * @author everis
 * @version 1.0
 */

public without sharing class Callout_ActualizaTelefono {

	private static HttpResponse resultMock;	
	private static String body;
	private static Integer contParametros;
	public static Integer simulationVal ;

	
	/**
	 * Clase de respuesta.
	 *
	 */
	public without sharing class Resultado{
		public String code = '';
		public String message = '';
	}


	/*
	* Método que implementa el la realización del callout para informar a Ensura sobre la modificación de un teléfono de uno de los contactos asociados a una cuenta con una póliza de Membership
	* @param bodyInsert:String que contiene el body de la request a realizar en formato JSON
	* @param nombreIntegracion: identificador del callout, SRV-PSI-058
	* @param idBitacora: identificador de la bitácora sobre la que se escribe el estado del callout
	* @param idContacto: identificador en Salesforece del Contacto sobre el que se ha modificado un campo de teléfono
	* @param identificadorCompania: identificador de la cuenta en el sistema de Ensura
	* @param anteriorValorTelefono: teléfono anterior a la modificación
	* @param nuevoValorTelefono: valor actualziado del teléfono
	* @param usuario: usuario de salesforce que modificó el contacto por última vez
	* @param tipoCorreccion: tipo de operación por la que se ejecuta el callout (1 nuevo contacto, 2 actualización de teléfono de un contacto)
	*
	* @return void;
	*/
	@future(callout=true)
	public static void updateDatos(String bodyInsert, String nombreIntegracion, String idBitacora, String idContacto,String identificadorCompania, String nuevoValorTelefono, String anteriorValorTelefono, String usuario, Integer tipoCorreccion) {

		Callout_ActualizaTelefono_RQ rq = new Callout_ActualizaTelefono_RQ();
		
		rq.identificadorCompania = identificadorCompania ;
		rq.nuevoValorTelefono = nuevoValorTelefono;
		rq.anteriorValorTelefono = anteriorValorTelefono;
		rq.usuario =usuario ;
 		rq.tipoCorreccion = tipoCorreccion;

		Resultado res = new Resultado();
    	Http http = new Http();
    	HttpRequest request = new HttpRequest();
    	INT_Bitacora__c bitacora;
		
		WS_Info__mdt ws_AT = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_ActualizaTelefono'][0];
		try{
			request.setHeader('content-type',ws_AT.Content_Type__c);
			request.setEndPoint(ws_AT.EndPoint__c+'/'+rq.identificadorCompania+'/telefono'); 
			request.setMethod(ws_AT.Method__c);
			request.setTimeout(Integer.valueOf(ws_AT.TimeOut__c));
			request.setBody(bodyInsert);
			//system.debug('>>>>>>verBody: '+bodyInsert);
			HttpResponse response;
	

			//system.debug('testIsTest'+testIsTest);
		
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
         			Util_Llamada_Externa.insertarBitacora('', res.code + ' ' + res.message, '03', '02', 'ENSURA - ' + nombreIntegracion + ' - Actualizar check Robinson', bodyInsert, 
						ws_AT.EndPoint__c+'/'+rq.identificadorCompania+'/telefono','',idContacto,'','','','',0,idBitacora,bitacora.BIT_NUM_Reintentos__c,Label.Callout_PUT);
         
         			return; 
    			}
				response = http.send(request);
				
			}else{
				setResponseMock(rq);
				response = resultMock;	
			}
			//system.debug('>>>>>imprimeRes ' + response.getBody());
			JSONParser parser = JSON.createParser(response.getBody());	
			res = analizarRespuesta(parser);
			
			if (res.code != '000') {
				bitacora = [SELECT BIT_NUM_Reintentos__c,BIT_TXT_Error__c,BIT_SEL_Estado__c,BIT_TXT_Nombre_Integracion__c FROM INT_Bitacora__c WHERE id=:idBitacora];
				if(bitacora.BIT_NUM_Reintentos__c != null){
					bitacora.BIT_NUM_Reintentos__c = bitacora.BIT_NUM_Reintentos__c+1;
				}else{
					bitacora.BIT_NUM_Reintentos__c = 1;
				}
				Util_Llamada_Externa.insertarBitacora('', res.code + ' ' + res.message, '03', '02', 'ENSURA - ' + nombreIntegracion + ' - Actualizar check Robinson', bodyInsert, 
					ws_AT.EndPoint__c+'/'+rq.identificadorCompania+'/telefono','',idContacto,'','','','',0,idBitacora,bitacora.BIT_NUM_Reintentos__c,Label.Callout_PUT);
					system.debug('//1->Bitácora insertada correctamente! idBitacora: '+bitacora.Id + ' '+idBitacora);
			}
			else {
				bitacora = [SELECT Id,BIT_SEL_Estado__c,BIT_TXT_Json__c FROM INT_Bitacora__c WHERE id=:idBitacora];
				bitacora.BIT_SEL_Estado__c = '06';
				bitacora.BIT_TXT_Json__c = bodyInsert;
				bitacora.BIT_TXT_Nombre_Integracion__c = 'ENSURA - ' + nombreIntegracion + ' - Actualizar Telefono';
				system.debug('//2/->Bitácora insertada correctamente! idBitacora: '+bitacora.Id + ' '+idBitacora);
				upsert bitacora;
			}
    	}
    	catch (Exception e){
    		List<INT_Bitacora__c> bitacoraAux =[SELECT BIT_NUM_Reintentos__c FROM INT_Bitacora__c WHERE id=:idBitacora];
			if(!bitacoraAux.isEmpty()){
				if(bitacoraAux.get(0).BIT_NUM_Reintentos__c != null){
					bitacoraAux.get(0).BIT_NUM_Reintentos__c = bitacoraAux.get(0).BIT_NUM_Reintentos__c+1;
				}else{
					bitacoraAux.get(0).BIT_NUM_Reintentos__c = 1;
				}				
				Util_Llamada_Externa.insertarBitacora('', res.code + ' ' + res.message, '03', '02', 'ENSURA - ' + nombreIntegracion + ' - Actualizar Telefono', bodyInsert, 
					ws_AT.EndPoint__c+'/'+rq.identificadorCompania+'/telefono','',idContacto,'','','','',0,idBitacora,bitacoraAux.get(0).BIT_NUM_Reintentos__c,Label.Callout_PUT);
					system.debug('//3/->Bitácora insertada correctamente! idBitacora: '+bitacora.Id + ' '+idBitacora);
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
	 * Método encargado de simular el mensaje de respuesta en los test; se simula 
	 * el mensaje a recibir mediente la inicialización de un valor que se provee al constructor
	 * @param datos: instancia de clase que contiene todos los datos necesarios para la construcción de la request al sistema tercero.
	 *
	 */
	public static void setResponseMock(Callout_ActualizaTelefono_RQ datos){
		if(simulationVal == null){
			simulationVal = 0;
		
		}
		else{
			simulationVal = simulationVal +1 ;
		}
		
		//Integer simulationVal = 0;
		String body = '';
		if(simulationVal == 0){
			body = '{'+
				'"code" : "000",'+
				'"message" : "SUCCESS –  Telephone ' + datos.nuevoValorTelefono + ' added to Customer with id ' + datos.identificadorCompania + '\"' +
				'}';
			system.debug('VALOR SIMULACION : 000');
		}
		else if(simulationVal == 1){
			body = '{'+
				'"code" : "102",'+
				'"message" : "ERROR – Field nuevoValorTelefono is Empty \"' +
				'}';
			system.debug('VALOR SIMULACION : 102');
		}
		else{
			body = '{'+
				'"code" : "202",'+
				'"message" : "ERROR – Customer with id '+ datos.identificadorCompania + ' not found' + '\"' +
				'}';
			system.debug('VALOR SIMULACION : 202');
		}
		
		resultMock = new HttpResponse();
		resultMock.setBody(body);
	}
	
	
	
	/**
    * Clase que construye el body de la request.
    * @param datos:  instancia de clase que contiene todos los datos necesarios para la construcción de la request al sistema tercero.
    *
    */
    public static String construirBody(Callout_ActualizaTelefono_RQ  datos) {
    	contParametros = 0;
    	body = '{';
		concatenarParametroJSON('nuevoValorTelefono', datos.nuevoValorTelefono);
        concatenarParametroJSON('anteriorValorTelefono', datos.anteriorValorTelefono);
        concatenarParametroJSON('usuario', datos.usuario);
         concatenarParametroJSON('tipoCorreccion', datos.tipoCorreccion);
        body += '}' ;
        return body;
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
			if (contParametros > 0) {body += ',';}
			body += '"' + nombreParametro + '" : ' + valorParametro;
			contParametros++;
		}
	}

	private static void concatenarParametroJSON(String nombreParametro, String valorParametro)
	{
		if (valorParametro != null)
		{
			if (contParametros > 0) {body += ',';}
			body += '"' + nombreParametro + '" : "' + valorParametro + '"';
			contParametros++;
		}
	}



}