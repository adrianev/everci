/**
* Todo: Clase que se utilizará para Eventos.
		La configuración de la conectividad de la clase se encuentra en el metadato "Callout_Eventos".
* @author everis
* @version 1.0
*/

public without sharing class Callout_Fac_Eventos {
	
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
	* Método que implementa la lógica del callout (composición de RQ, envío y recoger la respuesta)
	*
	* @param datos: recibe los datos necesarios para componer la request al endpoint externo
	* 
	* @return Resultado: objeto que encapsula el body de la response obtenida.
	*/
	public static String construirBodyEventos(Callout_Fac_Eventos_RQ datos){
		contParametros = 0;

		body = '{';
		concatenarParametroJSON('origenDatos', Label.FAC_Origen_Datos);
		concatenarParametroJSON('identificadorUnicoEvento', datos.identificadorUnicoEvento);
		concatenarParametroJSON('identificadorUnicoAbono', datos.identificadorUnicoAbono);
		concatenarParametroJSON('unidadNegocio', datos.unidadNegocio);
		concatenarParametroJSON('lineaDeNegocio', datos.lineaDeNegocio);
		concatenarParametroJSON('identificadorUnicoCaso', datos.identificadorUnicoCaso);
		concatenarParametroJSON('identificadorUnicoOrdenTrabajo', datos.identificadorUnicoOrdenTrabajo);
		concatenarParametroJSON('numOrdenTrabajo', datos.numOrdenTrabajo);
		//concatenarParametroJSON('lineaOrdenTrabajo', datos.lineaOrdenTrabajo);
		concatenarParametroJSON('descripcion', datos.descripcion);
		concatenarParametroJSON('moneda', datos.moneda);
		concatenarParametroJSON('direccionTerritorial', datos.direccionTerritorial);
		concatenarParametroJSON('tipoIntervencion', datos.tipoIntervencion);	
		concatenarParametroJSON('grupoCausa', datos.grupoCausa);
		concatenarParametroJSON('tipoRegistroCaso', datos.tipoRegistroCaso);
		concatenarParametroJSON('facturaAbonar', datos.facturaAbonar);
		concatenarParametroJSON('impuesto', datos.impuesto);
		concatenarParametroJSON('retencion', datos.retencion);
		concatenarParametroJSON('id_DireccionCliente', datos.id_DireccionCliente);
		concatenarParametroJSON('identificadorUnicoProfesional', datos.identificadorUnicoProfesional);
		concatenarParametroJSON('importe', datos.importe);
		concatenarParametroJSON('identificadorUnicoCuenta', datos.identificadorUnicoCuenta);
		concatenarParametroJSON('tipoEvento', datos.tipoEvento);
		body += '}';

		return body;
	}
	
	public static String construirBodyAbonos(Callout_Fac_EventosAbonos_RQ datos){
		contParametros = 0;
		
		body = '{';
		concatenarParametroJSON('origenDatos', 'Salesforce');
		concatenarParametroJSON('identificadorUnicoEvento', datos.identificadorUnicoEvento);
		concatenarParametroJSON('identificadorUnicoAbono', datos.identificadorUnicoAbono);
		concatenarParametroJSON('unidadNegocio', datos.unidadNegocio);
		concatenarParametroJSON('lineaDeNegocio', datos.lineaDeNegocio);
		concatenarParametroJSON('identificadorUnicoCaso', datos.identificadorUnicoCaso);
		concatenarParametroJSON('identificadorUnicoOrdenTrabajo', datos.identificadorUnicoOrdenTrabajo);
		concatenarParametroJSON('numOrdenTrabajo', datos.numOrdenTrabajo);
		//concatenarParametroJSON('lineaOrdenTrabajo', datos.lineaOrdenTrabajo);
		concatenarParametroJSON('descripcion', datos.descripcion);
		concatenarParametroJSON('moneda', datos.moneda);
		concatenarParametroJSON('direccionTerritorial', datos.direccionTerritorial);
		concatenarParametroJSON('tipoIntervencion', datos.tipoIntervencion);	
		concatenarParametroJSON('grupoCausa', datos.grupoCausa);
		concatenarParametroJSON('tipoRegistroCaso', datos.tipoRegistroCaso);
		concatenarParametroJSON('facturaAbonar', datos.facturaAbonar);
		concatenarParametroJSON('impuesto', datos.impuesto);
		concatenarParametroJSON('retencion', datos.retencion);
		concatenarParametroJSON('id_DireccionCliente', datos.id_DireccionCliente);
		concatenarParametroJSON('identificadorUnicoProfesional', datos.identificadorUnicoProfesional);
		concatenarParametroJSON('importe', datos.importe);
		concatenarParametroJSON('identificadorUnicoCuenta', datos.identificadorUnicoCuenta);
		concatenarParametroJSON('tipoEvento', datos.tipoEvento);
		body += '}';
		/*
		body = '{';
		concatenarParametroJSON('origenDatos', 'Salesforce');
		concatenarParametroJSON('identificadorUnicoAbono', datos.identificadorUnicoAbono);
		concatenarParametroJSON('identificadorUnicoCuenta', datos.identificadorUnicoCuenta);
		concatenarParametroJSON('importe', datos.importe);
		concatenarParametroJSON('descripcion', datos.descripcion);
		concatenarParametroJSON('identificadorUnicoCaso', datos.identificadorUnicoCaso);
		concatenarParametroJSON('identificadorUnicoOrdenTrabajo', datos.identificadorUnicoOrdenTrabajo);
		concatenarParametroJSON('direccionTerritorial', datos.direccionTerritorial);
		concatenarParametroJSON('unidadNegocio', datos.unidadNegocio);
		concatenarParametroJSON('lineaNegocio', datos.lineaDeNegocio);
		concatenarParametroJSON('numOrdenTrabajo', datos.numOrdenTrabajo);
		concatenarParametroJSON('lineaOrdenTrabajo', datos.lineaOrdenTrabajo);
		concatenarParametroJSON('tipoIntervencion', datos.tipoIntervencion); 
		concatenarParametroJSON('grupoCausa', datos.grupoCausa);
		concatenarParametroJSON('tipoRegistroCaso', datos.tipoRegistroCaso);
		body += '}';*/

		return body;
	}
	
	/*public static Resultado updateDatos(Callout_Fac_Eventos_RQ datos){//Borrar después, pero primero terminar el try catch del metodo siguiente, sino peta
		Resultado res = new Resultado();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		try{
			//WS_Info__mdt ws_CASV = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_Eventos'][0];
			//request.setEndPoint('/homeserve/facturador/eventos');
			//request.setHeader('content-type',ws_CASV.Content_Type__c);
			//request.setMethod(ws_CASV.Method__c);
			//request.setTimeout(Integer.valueOf(ws_CASV.TimeOut__c));
			contParametros = 0;
			
			body = '{';
			concatenarParametroJSON('origenDatos', 'Salesforce');
			concatenarParametroJSON('identificadorUnicoEvento', datos.identificadorUnicoEvento);
			concatenarParametroJSON('identificadorUnicoAbono', datos.identificadorUnicoAbono);
			concatenarParametroJSON('unidadNegocio', datos.unidadNegocio);
			concatenarParametroJSON('lineaDeNegocio', datos.lineaDeNegocio);
			concatenarParametroJSON('identificadorUnicoCaso', datos.identificadorUnicoCaso);
			concatenarParametroJSON('identificadorUnicoOrdenTrabajo', datos.identificadorUnicoOrdenTrabajo);
			concatenarParametroJSON('numOrdenTrabajo', datos.numOrdenTrabajo);
			//concatenarParametroJSON('lineaOrdenTrabajo', datos.lineaOrdenTrabajo);
			concatenarParametroJSON('descripcion', datos.descripcion);
			concatenarParametroJSON('moneda', datos.moneda);
			concatenarParametroJSON('direccionTerritorial', datos.direccionTerritorial);
			concatenarParametroJSON('tipoIntervencion', datos.tipoIntervencion);	
			concatenarParametroJSON('grupoCausa', datos.grupoCausa);
			concatenarParametroJSON('tipoRegistroCaso', datos.tipoRegistroCaso);
			concatenarParametroJSON('facturaAbonar', datos.facturaAbonar);										  
			concatenarParametroJSON('impuesto', datos.impuesto);
			concatenarParametroJSON('retencion', datos.retencion);
			concatenarParametroJSON('id_DireccionCliente', datos.id_DireccionCliente);
			concatenarParametroJSON('identificadorUnicoProfesional', datos.identificadorUnicoProfesional);
			concatenarParametroJSON('importe', datos.importe);
			concatenarParametroJSON('identificadorUnicoCuenta', datos.identificadorUnicoCuenta);
			concatenarParametroJSON('tipoEvento', datos.tipoEvento);
			body += '}';
			
			actualizaFacturado(datos.identificadorUnicoEvento,datos.identificadorUnicoAbono);
			
			system.debug('>>>>>verBody: ' + body);	
			 
			request.setBody(body);
			HttpResponse response;
			if (!test.isRunningTest()) {
				response = http.send(request);
			}else{
				setResponseMock();
				response = resultMock;  
			}
			
			JSONParser parser = JSON.createParser(response.getBody());  
			res = analizarRespuesta(parser);
	
			return res;
		
		}catch(Exception e){
			res.codigo_error = 'FAC-002';
			res.mensaje_error = Util_WS_Error.devolverMensajeRespuesta(res.codigo_error);
			return res;
		}
		
	}*/
	
	
	@future(callout=true)
	public static void updateDatos(String bodyInsert, String nombreIntegracion, String idBitacora, String idOrdenTrabajo){
		Resultado res = new Resultado();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		INT_Bitacora__c error = new INT_Bitacora__c();
		try{
			System.debug('+++ Req Callout_Fac_Eventos');
			WS_Info__mdt ws_CASV = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_Facturador_Eventos'][0];
			request.setEndPoint(ws_CASV.EndPoint__c);
			request.setHeader('content-type',ws_CASV.Content_Type__c);
			request.setMethod(ws_CASV.Method__c);
			request.setTimeout(Integer.valueOf(ws_CASV.TimeOut__c));

			request.setBody(bodyInsert);
			system.debug('>>>>>>verBody: '+bodyInsert);
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
			system.debug('>>>>>imprimeRes ' + response.getBody());
			JSONParser parser = JSON.createParser(response.getBody());	
			res = analizarRespuesta(parser);
			
			system.debug('>>>>>res.codigo_error: ' + res.codigo_error);
			system.debug('>>>>>res.mensaje_error: ' + res.mensaje_error);
			
			if(res.codigo_error != '001' && res.mensaje_error != 'Validación correcta'){
				system.debug('dentroIfError');
				INT_Bitacora__c bitacora =[SELECT BIT_NUM_Reintentos__c FROM INT_Bitacora__c WHERE id=:idBitacora];
				system.debug('>>>>>bitacora: '+bitacora);
				if(bitacora.BIT_NUM_Reintentos__c != null){
					bitacora.BIT_NUM_Reintentos__c = bitacora.BIT_NUM_Reintentos__c+1;
				}else{
					bitacora.BIT_NUM_Reintentos__c = 1;
				}				
				Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,res.codigo_error +'02'+ res.mensaje_error,'03','02',nombreIntegracion,bodyInsert,ws_CASV.EndPoint__c,
						'','','','','','',0,idBitacora,bitacora.BIT_NUM_Reintentos__c,Label.Callout_PUT);
			}else{
				INT_Bitacora__c aux = new INT_Bitacora__c();
				aux.Id = idBitacora;
				system.debug('idbitacora: '+aux.Id + ' '+idBitacora);
				delete aux;
			}	
		}catch(Exception e){
			system.debug('>>>>>DentroDeCatch');
			List<INT_Bitacora__c> bitacora =[SELECT BIT_NUM_Reintentos__c FROM INT_Bitacora__c WHERE id=:idBitacora];
			system.debug('>>>>>bitacora: ' + bitacora);
			
			if(!bitacora.isEmpty()){
				if(bitacora.get(0).BIT_NUM_Reintentos__c != null){
					bitacora.get(0).BIT_NUM_Reintentos__c = bitacora.get(0).BIT_NUM_Reintentos__c+1;
				}else{
					bitacora.get(0).BIT_NUM_Reintentos__c = 1;
				}
				WS_Info__mdt ws_CASV = [select EndPoint__c from WS_Info__mdt where MasterLabel = 'Callout_Facturador_Eventos'][0];
				Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,res.codigo_error +' '+ res.mensaje_error,'03','02',nombreIntegracion,bodyInsert,ws_CASV.EndPoint__c,
						'','','','','','',0,idBitacora,bitacora.get(0).BIT_NUM_Reintentos__c,Label.Callout_PUT);
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
			'"code": "002",' +
			'"message": "Validación correcta2"}';
			
		resultMock = new HttpResponse();
		resultMock.setBody(body);
		
	}
	
	/*
	* Método auxiliar para marcar como "true" la casilla de "Evento Facturado", cuando la propuesta de evento es insertada en el facturador.
	*
	* @parameter idEvento: id de la Propuesta de Evento que se ha insertado en el facturador;
	*
	*/
	
	//Pendiente de eliminar porque no se utiliza (No se llama desde ningún lado);
	/*private static void actualizaAbonoFacturado(String idEvento){
		if(idEvento != null){
			List<Propuesta_de_Evento__c> propEvento = new List<Propuesta_de_Evento__c>([SELECT Id, EV_AB_CAS_Evento_Ab_Facturado__c FROM Propuesta_de_Evento__c WHERE id =: idEvento]);
			Propuesta_de_Evento__c evento = new Propuesta_de_Evento__c();
			evento = propEvento.get(0);
			if(evento.EV_AB_CAS_Evento_Ab_Facturado__c == false){
				evento.EV_AB_CAS_Evento_Ab_Facturado__c = true;
				update evento;
			}
		}
	}
	/*
	* Método auxiliar para marcar como "true" la casilla de "Evento Facturado", cuando la propuesta de abono es insertada en el facturador.
	*
	* @parameter idAbono: id de la Propuesta de Abono que se ha insertado en el facturador;
	*
	*/
	
	//Pendiente de eliminar porque no se utiliza (No se llama desde ningún lado);
	/*private static void actualizaEventoFacturado(String idAbono){
		if(idAbono != null){
			List<Propuesta_de_Abono__c> propAbono = new List<Propuesta_de_Abono__c>([SELECT Id, AB_CAS_Abono_Facturado__c FROM Propuesta_de_Abono__c WHERE id =: idAbono]);
			Propuesta_de_Abono__c abono = new Propuesta_de_Abono__c();
			abono = propAbono.get(0);
			if(abono.AB_CAS_Abono_Facturado__c == false){
				abono.AB_CAS_Abono_Facturado__c = true;
				update abono;
			}
		}
	}
	/*
	private static void actualizaFacturado(String idEvento, String idAbono){
		if(idEvento != null){
			List<Propuesta_de_Evento__c> propEvento = new List<Propuesta_de_Evento__c>([SELECT Id, EV_AB_CAS_Evento_Ab_Facturado__c FROM Propuesta_de_Evento__c WHERE id =: idEvento]);
			Propuesta_de_Evento__c evento = new Propuesta_de_Evento__c();
			evento = propEvento.get(0);
			if(evento.EV_AB_CAS_Evento_Ab_Facturado__c == false){
				evento.EV_AB_CAS_Evento_Ab_Facturado__c = true;
				update evento;
			}
		}
		
		if(idAbono != null){
			List<Propuesta_de_Abono__c> propAbono = new List<Propuesta_de_Abono__c>([SELECT Id, AB_CAS_Abono_Facturado__c FROM Propuesta_de_Abono__c WHERE id =: idAbono]);
			Propuesta_de_Abono__c abono = new Propuesta_de_Abono__c();
			abono = propAbono.get(0);
			if(abono.AB_CAS_Abono_Facturado__c == false){
				abono.AB_CAS_Abono_Facturado__c = true;
				update abono;
			}
		}
		
	}*/
	
	
	
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