/**
 * Todo: Clase que se utilizará para enviar el abono de facturas de Previsora. 
        La configuración de la conectividad de la clase se encuentra en el metadato "Callout_Previsora".
 * @author everis
 * @version 1.0
 */
public without sharing class Callout_Previsora_Abono{

	private static HttpResponse resultMock;
	private static String body;
	private static Integer contParametros;

	/**
	 * Clase de respuesta.
	 *
	 */
	public without sharing class Resultado{
		public String code = '';
		public String message = '';
	}

	/* 
	 *		Método encargado construir el body;
	 * 
	 *  	@param response: JSON en forma de String
	 *   
	 *		@return Resultado: objeto que encapsula el body de la response obtenida.
	 */
	public static String construirBody(List<Callout_Previsora_Abono_RQ> listDatos){
		contParametros = 0;
		body = '{';
		body += '"InsertarAbono":{';
		body += '"listaAbonos":[';
		
		for(Callout_Previsora_Abono_RQ datosList:listDatos){
			if(contParametros != 0)
				body += ',';
			contParametros = 0;
			body += '{';
			body +='"Abono":{';
			concatenarParametroJSON('ConceptoPago', datosList.ConceptoPago);
			concatenarParametroJSON('FechaAbono', datosList.FechaAbono.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS'));
			concatenarParametroJSON('FechaHoraMovimiento', datosList.FechaHoraMovimiento.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS'));
			concatenarParametroJSON('IdAbonoReparalia', datosList.IdAbonoReparalia);
			concatenarParametroJSON('IdPoliza', datosList.IdPoliza);
			body +=',"ListaGarantias":[';
			contParametros = 0;
			for(Callout_Previsora_Abono_RQ.Garantias garantia : datosList.listaGarantias){
				if(contParametros != 0)
					body += ',';
				contParametros = 0;
				body += '{';
				body +='"Garantia":{';
				concatenarParametroJSON('CodGarantias', garantia.Codigo);
				concatenarParametroJSON('ImporteBaseServicio', garantia.ImporteBaseServicio);
				concatenarParametroJSON('PorcentajeIvaAplicadoServicio', garantia.PorcentajeIvaAplicadoServicio);
				body += '}}';
			}
			body += ']';
			concatenarParametroJSON('NumFactura', datosList.NumFactura);
			concatenarParametroJSON('NumReparacion', datosList.NumReparacion);
			concatenarParametroJSON('NumSiniestroReparalia', datosList.NumSiniestroReparalia);
			concatenarParametroJSON('IdSecuencia', datosList.IdSecuencia);
			body +='}}';
		}

		body +=']}}';
		return body;
	}
	
	/*
	 * Método que implementa la lógica del callout (composición de RQ, envío y recoger la respuesta)
	 *
	 * @param bodyInsert:body del JSON del callout, nombreIntegracion: nombre de la integracion a la que corresponde el callout;
	 * idBitacora: id del objeto bitácora, idOrdenTrabajo: id de la orden de trabajo correspontiente al abono de previsora
	 *
	 */
	@future(callout=true)
	public static void updateDatos(String bodyInsert, String nombreIntegracion, String idBitacora, String idOrdenTrabajo){
		Resultado res = new Resultado();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		INT_Bitacora__c error = new INT_Bitacora__c();
		try{
			WS_Info__mdt ws_CASV = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_Previsora'][0];
			request.setEndPoint(ws_CASV.EndPoint__c);
			request.setHeader('content-type',ws_CASV.Content_Type__c);
			request.setMethod(ws_CASV.Method__c);
			request.setTimeout(Integer.valueOf(ws_CASV.TimeOut__c));
			request.setBody(bodyInsert);
			HttpResponse response;
			if (!test.isRunningTest()) {
				String returnToken = new GetTokenPSI().getToken();
                if(returnToken != ''){
                	request.setHeader('Authorization',returnToken);
                }
				response = http.send(request);
			}else{
				setResponseMock();
				response = resultMock;	
			}
			JSONParser parser = JSON.createParser(response.getBody());	
			res = analizarRespuesta(parser);

			system.debug('>>>>>ver res.code: ' + res.code);
			system.debug('>>>>>ver res.message: ' + res.message);
			if(res.code == '001' && res.message == 'Validación correcta'){
				INT_Bitacora__c bitacora =[SELECT BIT_NUM_Reintentos__c FROM INT_Bitacora__c WHERE id=:idBitacora];
				if(bitacora.BIT_NUM_Reintentos__c != null){
					bitacora.BIT_NUM_Reintentos__c = bitacora.BIT_NUM_Reintentos__c+1;
				}else{
					bitacora.BIT_NUM_Reintentos__c = 1;
				} 
				Util_Llamada_Externa.insertarBitacora(Label.PRE_Previsora,res.code +' '+ res.message,'06','02',Label.PRE_Abono_Nombre,bodyInsert,''+ws_CASV.EndPoint__c,
						'','','','',idOrdenTrabajo,'',0,idBitacora,bitacora.BIT_NUM_Reintentos__c,Label.Callout_PUT);
			}else{
				Util_Llamada_Externa.insertarBitacora(Label.PRE_Previsora,res.code +' '+ res.message,'03','02',Label.PRE_Abono_Nombre,bodyInsert,''+ws_CASV.EndPoint__c,
						'','','','',idOrdenTrabajo,'',0,idBitacora,0,Label.Callout_PUT);	
			}
		}catch(Exception e){
			system.debug('>>>>>ver res.code: ' + res.code);
			system.debug('>>>>>ver res.message: ' + res.message);
			List<INT_Bitacora__c> bitacora =[SELECT BIT_NUM_Reintentos__c FROM INT_Bitacora__c WHERE id=:idBitacora];
			if(!bitacora.isEmpty()){
				if(bitacora.get(0).BIT_NUM_Reintentos__c != null){
					bitacora.get(0).BIT_NUM_Reintentos__c = bitacora.get(0).BIT_NUM_Reintentos__c+1;
				}else{
					bitacora.get(0).BIT_NUM_Reintentos__c = 1;
				}
				WS_Info__mdt ws_CASV = [select EndPoint__c from WS_Info__mdt where MasterLabel = 'Callout_Previsora'][0];
				Util_Llamada_Externa.insertarBitacora(Label.PRE_Previsora,res.code +' '+ res.message,'03','02',Label.PRE_Abono_Nombre,bodyInsert,''+ws_CASV.EndPoint__c,
						'','','','',idOrdenTrabajo,'',0,idBitacora,bitacora.get(0).BIT_NUM_Reintentos__c,Label.Callout_PUT);
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
	 *
	 */
	private static void setResponseMock(){

		String body = '{' +
				'"code": "001",' +
				'"message": "Validación correcta"}';

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
			if (contParametros > 0) {body += ',';}
			body += '"' + nombreParametro + '" : ' + valorParametro;
			contParametros++;
		}
	}

	private static void concatenarParametroJSON(String nombreParametro, Datetime valorParametro)
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

	private static void concatenarParametroJSON(String nombreParametro, Double valorParametro)
	{
		if (valorParametro != null)
		{
			if (contParametros > 0) {body += ',';}
			body += '"' + nombreParametro + '" : ' + valorParametro;
			contParametros++;
		}
	}
}