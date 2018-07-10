/**
 * Todo: Clase que se utilizará para el Maestro Cliente de Facturador. 
		La configuración de la conectividad de la clase se encuentra en el metadato "Callout_Facturador".
 * @author everis
 * @version 1.0
 */
public without sharing class Callout_Fac_MaestroClientes {

	private static HttpResponse resultMock;
	private static String body;
	private static Integer contParametros;
	/**
	 * Clase de respuesta.
	 *
	 */
	public class Resultado{
		public String codigo_error = '';
		public String mensaje_error = '';
	}	   

	/*
	 * Método que construye el body de la request
	 *
	 * @param datos: recibe los datos necesarios para componer la request al endpoint externo
	 * 
	 * @return Resultado: body de la request
	 */
	public static String construirJsonClientes (Callout_Fac_MaestroClientes_RQ datos){
		contParametros = 0;
		body = '{';
		concatenarParametroJSON('origenDatos', Label.FAC_Origen_Datos);
		concatenarParametroJSON('accion', Label.FAC_Accion);
		concatenarParametroJSON('nombreDelClienteProcedencia', datos.nombreDelClienteProcedencia);
		concatenarParametroJSON('tipoCliente', datos.tipoCliente);
		concatenarParametroJSON('identificadorCompania', datos.identificadorCompania);
		concatenarParametroJSON('identificadorUnicoCliente', datos.identificadorUnicoCliente);
		concatenarParametroJSON('tipoDocumento', datos.tipoDocumento);
		concatenarParametroJSON('tomadorNumeroDocumentoCliente', datos.tomadorNumeroDocumentoCliente);
		concatenarParametroJSON('numeroPoliza', datos.numeroPoliza);
		concatenarParametroJSON('numeroClienteRelacionado', datos.numeroClienteRelacionado);
		concatenarParametroJSON('nombreContacto', datos.nombreContacto);
		concatenarParametroJSON('mailContacto', datos.mailContacto);
		concatenarParametroJSON('telefonoContacto', '');
		concatenarParametroJSON('telefonoCuenta', datos.telefonoCuenta);
		concatenarParametroJSON('condicionPago', datos.condicionPago);
		concatenarParametroJSON('metodoPago', datos.metodoPago);
		concatenarParametroJSON('codigoEntidadBanco', datos.codigoEntidadBanco);
		concatenarParametroJSON('codigoSucursal', datos.codigoSucursal);
		concatenarParametroJSON('digitosControl', datos.digitosControl);
		concatenarParametroJSON('numeroCuenta', datos.numeroCuenta);
		concatenarParametroJSON('numeroIBAN', datos.numeroIBAN);
		concatenarParametroJSON('paisCuentaBancaria', datos.paisCuentaBancaria);
		concatenarParametroJSON('procedencia', datos.procedencia);
		body += ',"listaDirecciones":[';
		body += '{';
		contParametros = 0;
		concatenarParametroJSON('direccionRiesgoDomicilio', datos.direccionRiesgoDomicilio);
		concatenarParametroJSON('direccionRiesgoPoblacion', datos.direccionRiesgoPoblacion);   
		concatenarParametroJSON('direccionRiesgoProvincia', datos.direccionRiesgoProvincia);             
		concatenarParametroJSON('direccionRiesgoCp', datos.direccionRiesgoCp);
		concatenarParametroJSON('paisCliente', datos.paisCliente);
		concatenarParametroJSON('recordType', datos.recordType);
		concatenarParametroJSON('idDireccion', datos.idDireccion);
		body += ' }';
		contParametros = 0;
		if(datos.shippingStreetPadre != null){
			body += ' ,{';
			concatenarParametroJSON('direccionRiesgoDomicilio', datos.shippingStreetPadre);
			concatenarParametroJSON('direccionRiesgoPoblacion', datos.shippingStatePadre);
			concatenarParametroJSON('direccionRiesgoProvincia', datos.shippingCityPadre);
			concatenarParametroJSON('direccionRiesgoCp', datos.shippingPostalCodePadre);	
			concatenarParametroJSON('paisCliente', datos.shippingCountryPadre);
			concatenarParametroJSON('RecordType', datos.recordType);
			concatenarParametroJSON('idDireccion', datos.idDirecPadre);
			body += '}';
		}

		body += ']}';

		return body;	
	}


	@future(callout=true) 
	public static void updateDatos(String bodySend, String nombreIntegracion, String idBitacora, String identificadorUnicoCliente, String idOrdenTrabajo){
		system.debug('>>>>>verBody'+bodySend);
		Resultado res = new Resultado();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		INT_Bitacora__c error = new INT_Bitacora__c();
		system.debug('>>>>>Dentro de Callout_Fac_MaestroClientes.updateDatos');
		try{
			System.debug('+++ Req Callout_Fac_MaestroClientes');
			WS_Info__mdt ws_CASV = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_Facturador_MaestroClientes'][0];
			request.setEndPoint(ws_CASV.EndPoint__c);
			request.setHeader('content-type',ws_CASV.Content_Type__c);
			request.setMethod(ws_CASV.Method__c);
			request.setTimeout(Integer.valueOf(ws_CASV.TimeOut__c));
			request.setHeader('charset', 'utf-8');
			contParametros = 0;
			system.debug('>>>>>verBody: '+bodysend);
			
			request.setBody(bodySend);
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
			system.debug('>>>>>mostrarResponse: '+Response);
			system.debug('>>>>>responseBody' + response.getBody());
			JSONParser parser = JSON.createParser(response.getBody());	
			res = analizarRespuesta(parser);

			if(res.codigo_error != '001' && res.mensaje_error != 'Validación correcta'){
				if(test.isRunningTest()){
					INT_Bitacora__c bitacora = new INT_Bitacora__c();
					bitacora.BIT_SEL_Tipo_Integracion__c = '01';
					insert bitacora;
					idBitacora = bitacora.Id;
				}
				INT_Bitacora__c bitacora =[SELECT BIT_NUM_Reintentos__c FROM INT_Bitacora__c WHERE id=:idBitacora];
				if(bitacora.BIT_NUM_Reintentos__c != null){
					bitacora.BIT_NUM_Reintentos__c = bitacora.BIT_NUM_Reintentos__c+1;
				}else{
					bitacora.BIT_NUM_Reintentos__c = 1;
				}
				Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','06','02',Label.FAC_MAESTRO_CLIENTES_NOMBRE,bodySend,ws_CASV.EndPoint__c,
						'','',identificadorUnicoCliente,'',idOrdenTrabajo,'',0,idBitacora,0,Label.Callout_PUT);
			}else{
				Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','06','02',Label.FAC_MAESTRO_CLIENTES_NOMBRE,bodySend,ws_CASV.EndPoint__c,
						'','',identificadorUnicoCliente,'',idOrdenTrabajo,'',0,idBitacora,0,Label.Callout_PUT);				
			}	
		}catch(Exception e){
			INT_Bitacora__c bitacora =[SELECT BIT_NUM_Reintentos__c FROM INT_Bitacora__c WHERE id=:idBitacora];
			if(bitacora.BIT_NUM_Reintentos__c != null){
				bitacora.BIT_NUM_Reintentos__c = bitacora.BIT_NUM_Reintentos__c+1;
			}else{
				bitacora.BIT_NUM_Reintentos__c = 1;
			}

			WS_Info__mdt ws_CASV = [select EndPoint__c from WS_Info__mdt where MasterLabel = 'Callout_Facturador_MaestroClientes'][0];
			Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,res.codigo_error +' '+ res.mensaje_error,'03','02',Label.FAC_MAESTRO_CLIENTES_NOMBRE,bodySend,ws_CASV.EndPoint__c,
					'','','','',idOrdenTrabajo,'',0,idBitacora,bitacora.BIT_NUM_Reintentos__c,Label.Callout_PUT);
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
}