/**
* Clase que se utilizará para sincronizar check Robinson de un cliente Membership, tras la actualización del mismo en Salesforce.
* @author everis
* @version 1.0
* 
*/

public without sharing class Callout_Actualizar_Check_Robin {

    private static HttpResponse resultMock;
    private static String body;
    private static Integer contParametros;
    public static Integer simulationVal;
    
    /*
    * Clase que encapsula el cuerpo del HttpResponse a recibir cuando se realiza el callout
    */
    public without sharing class Resultado{
        public String code = '';
        public String message = '';
    }
   
    /**
    * Clase que construye el body de la request.
    * Clase de uso auxiliar que encapsula la respuesta del sistema tercero  en dos atributos,
	* el código de error y el mensaje de error
    *
    */
    public static String construirBody(Callout_Actualizar_Check_Robin_RQ  datos) {
    	contParametros = 0;
    	body = '{';
		concatenarParametroJSON('tomadorNumeroDocumentoCliente', datos.tomadorNumeroDocumentoCliente);
        concatenarParametroJSON('checkRobinson', datos.checkRobinson);
        concatenarParametroJSON('usuario', datos.usuario);
        body += '}' ;
        return body;
    }

    /*
    * Método auxiliar que realiza comprobación de los parámetros que se pasan al callout desde la clase de utilidad 
    * @param bodyInsert: String que contiene la request ya construida de acuerdo a la interfaz en formato JSON
    * @param nombreIntegracion: identificador del callout (SRV-PSI-057)
    * @param idBitacora: id para localizar y realizar operaciones sobre la entrada de bitacora asignada a este callout, para monitorizar el estado del callout
    * @param idCuenta:  id de Salesforce correspondiente a una cuenta con una póliza de Membership que tiene el campo Robinson a FALSE
    * @param documentoCliente: número de dni o nif correspondiente a la cuenta.
    *
    * @return void
    */
    
    @future(callout=true)
    public static void updateDatos(String bodyInsert, String nombreIntegracion, String idBitacora, String idCuenta, String documentoCliente) {
    	Resultado res = new Resultado();
    	Http http = new Http();
    	HttpRequest request = new HttpRequest();
    	INT_Bitacora__c bitacora;
    	WS_Info__mdt ws_CR = Util_Metadatos.getWSInfoMetadataByMasterLabel(new Set<String>{'Callout_Robinson'}).values().get(0);
    	//WS_Info__mdt ws_CR = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_Robinson'][0];
    	try {
    		//System.debug('---------- Req Callout_Robinson');
        	request.setEndPoint(ws_CR.EndPoint__c+'/'+documentoCliente+'/robinson');
            request.setHeader('content-type',ws_CR.Content_Type__c);
            request.setMethod(ws_CR.Method__c);
            request.setTimeout(Integer.valueOf(ws_CR.TimeOut__c));
            request.setBody(bodyInsert);
			//system.debug('>>>>>>verBody: '+bodyInsert);
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
         			Util_Llamada_Externa.insertarBitacora('', res.code + ' ' + res.message, '03', '02', 'ENSURA - ' + nombreIntegracion + ' - Actualizar check Robinson', bodyInsert, 
						ws_CR.EndPoint__c+'/'+documentoCliente+'/robinson','','',idCuenta,'','','',0,idBitacora,bitacora.BIT_NUM_Reintentos__c,Label.Callout_PUT);
         
         			return; 
    			}
				response = http.send(request);
				
			}else{
				setResponseMock(documentoCliente);
				response = resultMock;	
			}
			system.debug('>>>>>imprimeRes ' + response.getBody());
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
					ws_CR.EndPoint__c+'/'+documentoCliente+'/robinson','','',idCuenta,'','','',0,idBitacora,bitacora.BIT_NUM_Reintentos__c,Label.Callout_PUT);
			}
			else {
				bitacora = [SELECT Id,BIT_SEL_Estado__c,BIT_TXT_Json__c FROM INT_Bitacora__c WHERE id=:idBitacora];
				bitacora.BIT_SEL_Estado__c = '06';
				bitacora.BIT_TXT_Json__c = bodyInsert;
				bitacora.BIT_TXT_Nombre_Integracion__c = 'ENSURA - ' + nombreIntegracion + ' - Actualizar check Robinson';
				system.debug('idBitacora: '+bitacora.Id + ' '+idBitacora);
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
				Util_Llamada_Externa.insertarBitacora('', res.code + ' ' + res.message, '03', '02', 'ENSURA - ' + nombreIntegracion + ' - Actualizar check Robinson', bodyInsert, 
					ws_CR.EndPoint__c+'/'+documentoCliente+'/robinson','','',idCuenta,'','','',0,idBitacora,bitacoraAux.get(0).BIT_NUM_Reintentos__c,Label.Callout_PUT);
			}
    	}
    }
    

    /*
    * Metodo encargado de simular el mensaje de respuesta en los test
    * @parameter documentoCliente: DNI para insertar en la response simulada.
    * 
    * @return void
    */
    private static void setResponseMock(String documentoCliente){
        
        if(simulationVal == null){
			simulationVal = 0;
		}
		else{
			simulationVal = simulationVal +1 ;
		}
        String body = '';
        
        if(simulationVal == 0){
			body = '{' +
            	'"code": "000",' +
           		'"message": "SUCCESS - Customer with document: '+ documentoCliente + ' updated to YES' +
            	'"}';
		}
		else if(simulationVal == 1){
			body = '{'+
				'"code" : "102",'+
				'"message" : "ERROR - Customer with document: '+ documentoCliente + ' not found\"' +
				'}';
		}
		else{
			body = '{'+
				'"code" : "202",'+
				'"message" : "ERROR - General error updating customer with document: '+ documentoCliente + 
				'}';
		}

        resultMock = new HttpResponse();
        resultMock.setBody(body);
        
	}


    /*
    * Método auxiliar para formatear como JSON un booleano
    * @parameter nombreParametro: Nombre del parámetro a insertar en el body de la request
    * @parameter valorParametro: valor del campo a pasar a String
    *
    * @return void
    */
    private static void concatenarParametroJSON(String nombreParametro, Boolean valorParametro)
	{
		if (contParametros > 0) {body += ',';}
		body += '"' + nombreParametro + '" : "' + valorParametro + '"';
		contParametros++;
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
		if (valorParametro != null)
		{
			if (contParametros > 0) {body += ',';}
			body += '"' + nombreParametro + '" : "' + valorParametro + '"';
			contParametros++;
		}else{
			if (contParametros > 0) {body += ',';}
			body += '"' + nombreParametro + '" : ""';
			contParametros++;
		}
	}



    /*
    * Método encargado de extraer los datos de la respuesta
    * @param reponse: Objeto JSON parser utilizado inicializado con el cuerpo de la respuesta obtenida y cuyos datos se quieren parsear
    *
    * @return objeto de clase Resultado; encapsula la información obtenida en la respuesta del sistemea tercero
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
}