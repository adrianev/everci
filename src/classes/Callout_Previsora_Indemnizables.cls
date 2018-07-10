/**
 * Todo: Clase que se utilizará para enviar siniestros indemnizables. 
        La configuración de la conectividad de la clase se encuentra en el metadato "Callout_Previsora".
 * @author everis
 * @version 1.0
 */
public without sharing class Callout_Previsora_Indemnizables {

	private static HttpResponse resultMock;
	private static String body;
	private static Integer contParametros;

	/**
	 * Clase de respuesta.
	 *
	 */
	public without sharing class Resultado{
		public String codigo_error = '';
		public String mensaje_error = '';
	}

	/* 
	 *		Método encargado construir el body;
	 * 
	 *  	@param response: JSON en forma de String
	 *   
	 *		@return Resultado: objeto que encapsula el body de la response obtenida.
	 */
	public static String construirBody(List<Callout_Previsora_Indemnizables_RQ> listDatos){
		contParametros = 0;
		body = '{';
		body += '"InsertarFacturacionServicio":{';
		body +='"listaFactura":[';

		for(Callout_Previsora_Indemnizables_RQ indemnizables : listDatos){
			if(contParametros != 0)
				body += ',';
			contParametros = 0;

			body += '{';
			body +='"facturaServicio":{';
			concatenarParametroJSON('beneficiario', indemnizables.beneficiario);
			concatenarParametroJSON('codigoPostalBenef', indemnizables.codigoPostalBenef);
			concatenarParametroJSON('conceptoPago', indemnizables.conceptoPago);
			concatenarParametroJSON('domicilioBenef', indemnizables.domicilioBenef);
			concatenarParametroJSON('estadoSiniestro', indemnizables.estadoSiniestro);
			concatenarParametroJSON('fechaCierre', indemnizables.fechaCierre);
			concatenarParametroJSON('fechaHoraMovimiento', indemnizables.fechaHoraMovimiento);
			concatenarParametroJSON('fechaRecepcionRepFacturaPerito', indemnizables.fechaRecepcionRepFacturaPerito);
			concatenarParametroJSON('idPagoIndemnizableReparalia', indemnizables.idPagoIndemnizableReparalia);
			concatenarParametroJSON('idPoliza', indemnizables.idPoliza);
			concatenarParametroJSON('importeBaseGastosPerito', indemnizables.importeBaseGastosPerito);
			concatenarParametroJSON('importeBaseHonorariosPerito', indemnizables.importeBaseHonorariosPerito);
			body +=',"ListaGarantias":[';
			contParametros = 0;

			for(Callout_Previsora_Indemnizables_RQ.Garantia garantia : indemnizables.listaGarantias){
				if(contParametros != 0)
					body += ',';
				contParametros = 0;
				body += '{';
				body += '"garantia":[{';
				concatenarParametroJSON('codGarantia', garantia.codGarantia);
				concatenarParametroJSON('importeBaseServicio', garantia.importeBaseServicio);
				concatenarParametroJSON('porcenIvaAplicadoServicio', garantia.porcenIvaAplicadoServicio);
				body += '}]}';
			}
			body += ']';
			concatenarParametroJSON('localidadBenef', indemnizables.localidadBenef);
			concatenarParametroJSON('nifBenef', indemnizables.nifBenef);
			concatenarParametroJSON('nifPerito', indemnizables.nifPerito);
			concatenarParametroJSON('nombreApellidosBenef', indemnizables.nombreApellidosBenef);
			concatenarParametroJSON('numFacturaPerito', indemnizables.numFacturaPerito);
			concatenarParametroJSON('numPago', indemnizables.numPago);
			concatenarParametroJSON('numSiniestroPrevisora', indemnizables.numSiniestroPrevisora);
			concatenarParametroJSON('numSiniestroReparalia', indemnizables.numSiniestroReparalia);
			concatenarParametroJSON('personaFisicaJuridicaBenef', indemnizables.personaFisicaJuridicaBenef);
			concatenarParametroJSON('porcentajeIvaIgiPerito', indemnizables.porcentajeIvaIgiPerito);
			concatenarParametroJSON('telefonoFaxBenef', indemnizables.telefonoFaxBenef);
			concatenarParametroJSON('tipoDocumentoBenef', indemnizables.tipoDocumentoBenef);
			concatenarParametroJSON('tipoImpuestoPerito', indemnizables.tipoImpuestoPerito);
			concatenarParametroJSON('tipoRegistro', indemnizables.tipoRegistro);
			concatenarParametroJSON('idSecuencia', indemnizables.idSecuencia);
			body +='}}';

		}

		body +=']}';
		body += '}';
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

			if(res.codigo_error == '0' && res.mensaje_error == 'Ok'){
				INT_Bitacora__c bitacora =[SELECT BIT_NUM_Reintentos__c FROM INT_Bitacora__c WHERE id=:idBitacora];
				if(bitacora.BIT_NUM_Reintentos__c != null){
					bitacora.BIT_NUM_Reintentos__c = bitacora.BIT_NUM_Reintentos__c+1;
				}else{
					bitacora.BIT_NUM_Reintentos__c = 1;
				} 
				Util_Llamada_Externa.insertarBitacora(Label.PRE_Previsora,res.codigo_error +' '+ res.mensaje_error,'06','02',Label.PRE_Indemnizables_Nombre,bodyInsert,''+ws_CASV.EndPoint__c,
						'','','','',idOrdenTrabajo,'',0,idBitacora,bitacora.BIT_NUM_Reintentos__c,Label.Callout_PUT);
			}else{
				Util_Llamada_Externa.insertarBitacora(Label.PRE_Previsora,res.codigo_error +' '+ res.mensaje_error,'03','02',Label.PRE_Indemnizables_Nombre,bodyInsert,''+ws_CASV.EndPoint__c,
						'','','','',idOrdenTrabajo,'',0,idBitacora,0,Label.Callout_PUT);	
			}
		}catch(Exception e){
			List<INT_Bitacora__c> bitacora =[SELECT BIT_NUM_Reintentos__c FROM INT_Bitacora__c WHERE id=:idBitacora];
			if(!bitacora.isEmpty()){
				if(bitacora.get(0).BIT_NUM_Reintentos__c != null){
					bitacora.get(0).BIT_NUM_Reintentos__c = bitacora.get(0).BIT_NUM_Reintentos__c+1;
				}else{
					bitacora.get(0).BIT_NUM_Reintentos__c = 1;
				}
				WS_Info__mdt ws_CASV = [select EndPoint__c from WS_Info__mdt where MasterLabel = 'Callout_Previsora'][0];
				Util_Llamada_Externa.insertarBitacora(Label.PRE_Previsora,res.codigo_error +' '+ res.mensaje_error,'03','02',Label.PRE_Indemnizables_Nombre,bodyInsert,''+ws_CASV.EndPoint__c,
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
				'"code": "0",' +
				'"message": "Ok"}';

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

	private static void concatenarParametroJSON(String nombreParametro, String valorParametro)
	{
		if (valorParametro != null)
		{
			if (contParametros > 0) {body += ',';}
			body += '"' + nombreParametro + '" : "' + valorParametro + '"';
			contParametros++;
		}
	}

	private static void concatenarParametroJSON(String nombreParametro, Date valorParametro)
	{
		if (valorParametro != null)
		{
			if (contParametros > 0) {body += ',';}
			body += '"' + nombreParametro + '" : "' + valorParametro + '"';
			contParametros++;
		}
	}
	
	private static void concatenarParametroJSON(String nombreParametro, DateTime valorParametro)
	{
		if (valorParametro != null)
		{
			if (contParametros > 0) {body += ',';}
			body += '"' + nombreParametro + '" : "' + valorParametro + '"';
			contParametros++;
		}
	}


}