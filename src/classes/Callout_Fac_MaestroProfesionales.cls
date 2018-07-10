/**
 * Todo: Clase que se utilizará para el Maestro Profesionales de Facturador. 
		La configuración de la conectividad de la clase se encuentra en el metadato "Callout_Facturador".
 * @author everis
 * @version 1.0
 */
public without sharing class Callout_Fac_MaestroProfesionales {

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

	public static String construirBody (Callout_Fac_MaestroProfesionales_RQ datos){
		contParametros = 0;
		body = '{';
		concatenarParametroJSON('origenDatos', Label.FAC_Origen_Datos);
		concatenarParametroJSON('accionRealizada', datos.accionRealizada);
		concatenarParametroJSON('nombreProfesional', datos.nombreProfesional);
		concatenarParametroJSON('identificadorUnicoProfesional', datos.identificadorUnicoProfesional);
		concatenarParametroJSON('numeroProfesional', datos.numeroProfesional);
		concatenarParametroJSON('tipoDocumento', datos.tipoDocumento);
		concatenarParametroJSON('tomadorNumeroDocumentoCliente', datos.tomadorNumeroDocumentoCliente);
		concatenarParametroJSON('nombreContacto', datos.nombreContacto);
		concatenarParametroJSON('mailContacto', datos.mailContacto);
		concatenarParametroJSON('telefonoContacto', datos.telefonoContacto);
		concatenarParametroJSON('direccionContacto', '');
		concatenarParametroJSON('direccionDelProfesional', datos.direccionDelProfesional);
		concatenarParametroJSON('codigoPostalProfesional', datos.codigoPostalProfesional);
		concatenarParametroJSON('ciudadProfesional', datos.ciudadProfesional);
		concatenarParametroJSON('paisProfesional', datos.paisProfesional);
		concatenarParametroJSON('importeFianzaMaxima', datos.importeFianzaMaxima);
		concatenarParametroJSON('condicionPago', datos.condicionPago);
		concatenarParametroJSON('codigoRetencionFiscal', datos.codigoRetencionFiscal);
		concatenarParametroJSON('profesionalFianza', datos.profesionaFianza);
		concatenarParametroJSON('porcentajeFianza', datos.porcentajeFianza);
		concatenarParametroJSON('importeTotalFianza', datos.importeTotalFianza);
		concatenarParametroJSON('importeFianzadevuelta', datos.importeFianzadevuelta);
		concatenarParametroJSON('fechaBajaDefinitiva', datos.fechaBajaDefinitiva);
		concatenarParametroJSON('profesionalFranquicia', datos.profesionalFranquicia);
		concatenarParametroJSON('importeFranquicia', datos.importeFranquicia);
		concatenarParametroJSON('fechaFranquicia', datos.fechaFranquicia);
		concatenarParametroJSON('vencimientosFranquicia', datos.vencimientosFranquicia);
		concatenarParametroJSON('tipoProfesional', datos.tipoProfesional);
		concatenarParametroJSON('metodoPago', datos.metodoPago);
		concatenarParametroJSON('codigoEntidadBanco', datos.codigoEntidadBanco);
		concatenarParametroJSON('codigoSucursal', datos.codigoSucursal);
		concatenarParametroJSON('digitosControl', datos.digitosControl);
		concatenarParametroJSON('numeroCuenta', datos.numeroCuenta);
		concatenarParametroJSON('numeroIban', datos.numeroIban);
		concatenarParametroJSON('paisCuentaBancaria', datos.paisCuentaBancaria);
		concatenarParametroJSON('profesionalRappel', datos.profesionalRappel);
		concatenarParametroJSON('tipologiaRappel', datos.tipologiaRappel);
		concatenarParametroJSON('embargado', datos.embargado);
		concatenarParametroJSON('vetado', datos.vetado);
		concatenarParametroJSON('profesionalPerito', datos.profesionalPerito);
		body += '}';

		return body;
	}

	@future(callout=true) 
	public static void updateDatos(String bodySend, String nombreIntegracion, String idBitacora, String identificadorUnicoProfesional, String idOrdenTrabajo){
		Resultado res = new Resultado();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		INT_Bitacora__c error = new INT_Bitacora__c();

		try{
			System.debug('+++ Req Callout_Fac_MaestroProfesionales');
			WS_Info__mdt ws_CASV = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_Facturador_MaestroProfesionales'][0];
			request.setEndPoint(ws_CASV.EndPoint__c);
			request.setHeader('content-type',ws_CASV.Content_Type__c);
			request.setMethod(ws_CASV.Method__c);
			request.setTimeout(Integer.valueOf(ws_CASV.TimeOut__c));
			request.setHeader('Content-Type','text/html; charset=UTF-8');
			request.setBody(bodySend); //request.setBody(body);

			system.debug('++++++ Request: ' +bodySend);
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
			system.debug('>>>>>pasaPorAqui');
			system.debug('>>>>>mostrarResponse: '+Response);
			system.debug('>>>>>responseBody'+ response.getBody());
			JSONParser parser = JSON.createParser(response.getBody());	
			res = analizarRespuesta(parser);
			system.debug('+++++++respuesta: '+res);
			if(res.codigo_error != '001' && res.mensaje_error != 'Validación correcta'){	
				INT_Bitacora__c bitacora =[SELECT BIT_NUM_Reintentos__c FROM INT_Bitacora__c WHERE id=:idBitacora];
				if(bitacora.BIT_NUM_Reintentos__c != null){
					bitacora.BIT_NUM_Reintentos__c = bitacora.BIT_NUM_Reintentos__c+1;
				}else{
					bitacora.BIT_NUM_Reintentos__c = 1;
				}
				if(!Test.isrunningTest()){
					Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,res.codigo_error +' '+ res.mensaje_error,'03','02',Label.FAC_MAESTRO_PROFESIONALES_NOMBRE,bodySend,ws_CASV.EndPoint__c,
							'','','','',idOrdenTrabajo,'',0,idBitacora,bitacora.BIT_NUM_Reintentos__c,Label.Callout_PUT);	
				}
			}else{
				system.debug('>>>>>entraElse');
				system.debug('>>>>>idOrdenTrabajo: ' + idOrdenTrabajo);
				Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','06','02',Label.FAC_MAESTRO_PROFESIONALES_NOMBRE,bodySend,ws_CASV.EndPoint__c,
						'','', identificadorUnicoProfesional,'',idOrdenTrabajo,'',0,idBitacora,0,Label.Callout_PUT);			
				
			}	
		}catch(Exception e){
			system.debug('>>>>>idBitacora: ' + idBitacora);
			INT_Bitacora__c bitacora =[SELECT BIT_NUM_Reintentos__c FROM INT_Bitacora__c WHERE id=:idBitacora];
			if(bitacora.BIT_NUM_Reintentos__c != null){
				bitacora.BIT_NUM_Reintentos__c = bitacora.BIT_NUM_Reintentos__c+1;
			}else{
				bitacora.BIT_NUM_Reintentos__c = 1;
			}
			WS_Info__mdt ws_CASV = [select EndPoint__c from WS_Info__mdt where MasterLabel = 'Callout_Facturador_MaestroProfesionales'][0];
			Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,res.codigo_error +' '+ res.mensaje_error,'03','02',Label.FAC_MAESTRO_PROFESIONALES_NOMBRE,bodySend,ws_CASV.Endpoint__c,
					'','',identificadorUnicoProfesional,'',idOrdenTrabajo,'',0,idBitacora,bitacora.BIT_NUM_Reintentos__c,Label.Callout_PUT);
		}}

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


	private static void concatenarParametroJSON(String nombreParametro, Boolean valorParametro)
	{
		if (valorParametro != null)
		{
			if (contParametros > 0) {body += ',';}
			body += '"' + nombreParametro + '" : ' + valorParametro;
			contParametros++;
		}else{
			if (contParametros > 0) {body += ',';}
			body += '"' + nombreParametro + '" : ""';
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
		}else{
			if (contParametros > 0) {body += ',';}
			body += '"' + nombreParametro + '" : ""';
			contParametros++;
		}
	}

	private static void concatenarParametroJSON(String nombreParametro, Datetime valorParametro)
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

	private static void concatenarParametroJSON(String nombreParametro, Double valorParametro)
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
	private static void concatenarParametroJSON(String nombreParametro, Decimal valorParametro)
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
}