/**
 * Todo: Clase que se utilizará para Pre Factura de Facturador. 
		La configuración de la conectividad de la clase se encuentra en el metadato "Callout_Facturador".
 * @author everis
 * @version 1.0
 */
public without sharing class Callout_Fac_PreFactura {

	private static HttpResponse resultMock;
	private static String body;
	private static Integer contParametros;	
	public without sharing class Resultado{
		public String codigo_error = '';
		public String mensaje_error = '';
	}		

	public static String construirBody(Callout_Fac_PreFactura_RQ datos){
		contParametros = 0;
		body = '{';
		concatenarParametroJSON('origenDatos', Label.FAC_Origen_Datos);
		concatenarParametroJSON('identificadorCompania', Label.FAC_Identificador_Compania);
		concatenarParametroJSON('unidadNegocio', Label.FAC_Unidad_Negocio);
		concatenarParametroJSON('lineaDeNegocio', datos.lineaDeNegocio);
		concatenarParametroJSON('segmento', datos.segmento);
		concatenarParametroJSON('numCaso', datos.numCaso);
		concatenarParametroJSON('identificadorUnicoCaso', datos.identificadorUnicoCaso);
		concatenarParametroJSON('estado', datos.estado);
		concatenarParametroJSON('vetadoOrdenDeTrabajo', datos.vetadoOrdenDeTrabajo);
		concatenarParametroJSON('fechaCierreCaso', datos.fechaCierreCaso);
		concatenarParametroJSON('tipoCaso', datos.tipoCaso);
		concatenarParametroJSON('identificadorUnicoOrdenTrabajo', datos.identificadorUnicoOrdenTrabajo);
		concatenarParametroJSON('numOrdenTrabajo', datos.numOrdenTrabajo);
		concatenarParametroJSON('lineaOrdenTrabajo', datos.lineaOrdenTrabajo);
		concatenarParametroJSON('estadoCierreOrdenTrabajo', datos.estadoCierreOrdenTrabajo);
		concatenarParametroJSON('fechaCierreOrdenTrabajo', datos.fechaCierreOrdenTrabajo);
		concatenarParametroJSON('pedido', datos.pedido);
		concatenarParametroJSON('numeroPoliza', datos.numeroPoliza);
		concatenarParametroJSON('identificadorUnicoCuenta', datos.identificadorUnicoCuenta);
		concatenarParametroJSON('importeVentaLineaOrdenTrabajo', datos.importeVentaLineaOrdenTrabajo);
		concatenarParametroJSON('codigoImpuestoVenta', datos.codigoImpuestoVenta);
		concatenarParametroJSON('monedaVenta', datos.monedaVenta);
		concatenarParametroJSON('detalleVenta', datos.detalleVenta);
		concatenarParametroJSON('cantidadVenta', datos.cantidadVenta);
		concatenarParametroJSON('precioUnitarioVenta', datos.precioUnitarioVenta);
		concatenarParametroJSON('unidadMedidaVenta', datos.unidadesDeMedida);
		concatenarParametroJSON('identificadorUnicoProfesional', datos.identificadorUnicoProfesional);
		concatenarParametroJSON('cantidadGastos', datos.cantidadGastos);
		concatenarParametroJSON('unidadMedidaGastos', datos.unidadMedidadGastos);
		concatenarParametroJSON('precioUnitarioGastos', datos.precioUnitarioGastos);
		concatenarParametroJSON('codigoImpuestoGasto', datos.codigoImpuestoGasto);
		concatenarParametroJSON('detalleLineaOrdenDeTrabajo', datos.detalleLineaOrdenDeTrabajo);
		concatenarParametroJSON('actividad', datos.actividad);
		concatenarParametroJSON('direccionTerritorial', datos.direccionTerritorial);
		concatenarParametroJSON('tipoIntervencion', datos.tipoIntervencion);
		concatenarParametroJSON('grupoCausa', datos.grupoCausa);
		concatenarParametroJSON('servicio', datos.servicio);
		concatenarParametroJSON('siniestrosGraves', datos.siniestrosGraves);
		concatenarParametroJSON('facturaAbonar', datos.facturaAbonar);
		concatenarParametroJSON('numeroReferenciaCliente', datos.numeroReferenciaCliente);
		concatenarParametroJSON('numeroReferenciaActivo', datos.numeroReferenciaActivo);
		concatenarParametroJSON('importeBaseImponible', datos.importeBaseImponible);
		concatenarParametroJSON('importeTotal', datos.importeTotal);
		concatenarParametroJSON('impuestoIva', datos.impuestoIva);
		concatenarParametroJSON('impuestoIpsi', datos.impuestoIpsi);
		concatenarParametroJSON('ImpuestoIgic', datos.impuestoIgic);
		concatenarParametroJSON('descuento', datos.descuento);
		concatenarParametroJSON('codigoBaremo', datos.codigoBaremo);
		concatenarParametroJSON('ancho', datos.ancho);
		concatenarParametroJSON('alto', datos.alto);
		concatenarParametroJSON('porcentajeProf', datos.porcentajeProf);
		concatenarParametroJSON('porcentajeCli', datos.porcentajeCli);
		concatenarParametroJSON('daniosDel', datos.daniosDel);
		concatenarParametroJSON('daniosEsteticos', datos.daniosEsteticos);
		concatenarParametroJSON('descripcionBaremo', datos.descripcionBaremo);
		concatenarParametroJSON('numeroExpediente', datos.numeroExpediente);
		concatenarParametroJSON('fechaOcurrencia', datos.fechaOcurrencia);
		concatenarParametroJSON('referencia', datos.referencia);
		concatenarParametroJSON('itemProducto', datos.itemProducto);
		concatenarParametroJSON('porcentajeMateriales', datos.porcentajeMateriales);
		concatenarParametroJSON('gremio', datos.gremio);
		concatenarParametroJSON('codigoUsuario', datos.codigoUsuario);
		concatenarParametroJSON('sREF', datos.sREF);
		concatenarParametroJSON('direccionRealizacionTrabajo', datos.direccionRealizacionTrabajo);
		concatenarParametroJSON('localidadRealizacionTrabajo', datos.localidadRealizacionTrabajo);
		concatenarParametroJSON('provinciaRealizacionTrabajo', datos.provinciaRealizacionTrabajo);
		concatenarParametroJSON('delegacion', datos.delegacion);
		concatenarParametroJSON('codigoGestorNombre', datos.codigoGestorNombre);
		concatenarParametroJSON('numeroEstablecimiento', datos.numeroEstablecimiento);
		concatenarParametroJSON('direccionEstablecimiento', datos.direccionEstablecimiento);
		concatenarParametroJSON('pagoDeMinuta', datos.pagoDeMinuta);
		concatenarParametroJSON('idDireccion', datos.idDireccion);
		concatenarParametroJSON('observaciones', datos.observaciones);
		body += '}';

		return body;  	
	}

	@future(callout=true)
	public static void updateDatos(String bodyInsert, String nombreIntegracion, String idBitacora, String idOrdenTrabajo){
		Resultado res = new Resultado();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		INT_Bitacora__c error = new INT_Bitacora__c();
		try{
			System.debug('+++ Req Callout_Fac_PreFactura');
			WS_Info__mdt ws_CASV = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_Facturador_Prefactura'][0];
			request.setEndPoint(ws_CASV.EndPoint__c);
			system.debug('>>>>>verEndPoint: ' + ws_CASV.EndPoint__c);
			request.setHeader('content-type',ws_CASV.Content_Type__c);
			request.setMethod(ws_CASV.Method__c);
			request.setTimeout(Integer.valueOf(ws_CASV.TimeOut__c));
			request.setBody(bodyInsert);
			system.debug('>>>>>verBody: '+bodyInsert);

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

			if(res.codigo_error != '001' && res.mensaje_error != 'Validación correcta'){
				system.debug('>>>>>DentroDeIf');
				INT_Bitacora__c bitacora =[SELECT BIT_NUM_Reintentos__c FROM INT_Bitacora__c WHERE id=:idBitacora];
				if(bitacora.BIT_NUM_Reintentos__c != null){
					bitacora.BIT_NUM_Reintentos__c = bitacora.BIT_NUM_Reintentos__c+1;
				}else{
					bitacora.BIT_NUM_Reintentos__c = 1;
				} 
				Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,res.codigo_error +' '+ res.mensaje_error,'03','02',Label.FAC_PREFACTURA_NOMBRE,bodyInsert,'',
						'','','','',idOrdenTrabajo,'',0,idBitacora,bitacora.BIT_NUM_Reintentos__c,Label.Callout_PUT);
			}else{
				system.debug('>>>>>DentroDeElse');
				system.debug('>>>>>endPointElse: ' + ws_CASV.EndPoint__c);
				Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','06','02',Label.FAC_PREFACTURA_NOMBRE,bodyInsert,''+ws_CASV.EndPoint__c,
						'','','','',idOrdenTrabajo,'',0,idBitacora,0,Label.Callout_PUT);	
			}	
		}catch(Exception e){
			system.debug('>>>>>DentroDeCatch');
			List<INT_Bitacora__c> bitacora =[SELECT BIT_NUM_Reintentos__c FROM INT_Bitacora__c WHERE id=:idBitacora];
			if(!bitacora.isEmpty()){
				if(bitacora.get(0).BIT_NUM_Reintentos__c != null){
					bitacora.get(0).BIT_NUM_Reintentos__c = bitacora.get(0).BIT_NUM_Reintentos__c+1;
				}else{
					bitacora.get(0).BIT_NUM_Reintentos__c = 1;
				}
				WS_Info__mdt ws_CASV = [select EndPoint__c from WS_Info__mdt where MasterLabel = 'Callout_Facturador_Prefactura'][0];
				Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,res.codigo_error +' '+ res.mensaje_error,'03','02',Label.FAC_PREFACTURA_NOMBRE,bodyInsert,''+ws_CASV.EndPoint__c,
						'','','','',idOrdenTrabajo,'',0,idBitacora,bitacora.get(0).BIT_NUM_Reintentos__c,Label.Callout_PUT);
			}
		}
	}

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

	private static void setResponseMock(){

		String body = '{' +
				'"code": "001",' +
				'"message": "Validación correcta"}';

		resultMock = new HttpResponse();
		resultMock.setBody(body);

	}

	private static void concatenarParametroJSON(String nombreParametro, Integer valorParametro)
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

	private static void concatenarParametroJSON(String nombreParametro, Date valorParametro)
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