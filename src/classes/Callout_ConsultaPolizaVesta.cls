/**
 * Todo: RQ para buscar, tendrá 3 tipos de búsquedas:
 *	 BUSQUEDA 1 (SIMPLE): identificadorCompania + localizador + infoFee=False
	 BUSQUEDA 2 (AVANZADA): identificadorCompania + numeroPoliza + numeroDocumento + numeroSiniestroHS + numeroSiniestroCIA
	 + nombre + apellido1 + apellido2 + direccionRiesgoDomicilio + direccionRiesgoCp + poblacion + provincia + infoFee=False
	 BUSQUEDA 3 (FACTURADOR): identificadorCompania + infoFee=True
 * @author everis
 * @version 1.0
 */ 
public without sharing class Callout_ConsultaPolizaVesta {

	/*
	 * Método que implementa la lógica del callout (composición de RQ, envío y recoger la respuesta)
	 *
	 * @param url: recibe los datos necesarios para componer la request al endpoint externo
	 * 
	 * @return Resultado: objeto que encapsula el body de la response obtenida.
	 */
	public static List<Callout_ConsultaPolizaVesta_RP> getDatos(String url){   
		List<Callout_ConsultaPolizaVesta_RP> resultado;

		http http = new Http();
		HttpRequest request = new HttpRequest(); 


		WS_Info__mdt ws_CCPV = [select Content_Type__c, EndPoint__c, Method__c, TimeOut__c from WS_Info__mdt where MasterLabel = 'Callout_ConsultaPolizaVesta'][0];
		request.setEndPoint(ws_CCPV.EndPoint__c+url);
		system.debug('>>>>>VerRequest: '+ws_CCPV.EndPoint__c+url);
		request.setHeader('content-type',ws_CCPV.Content_Type__c);
		request.setMethod(ws_CCPV.Method__c);
		request.setTimeout(Integer.valueOf(ws_CCPV.TimeOut__c));
        System.debug(Integer.valueOf(ws_CCPV.TimeOut__c));
		/*String returnToken = new GetTokenPSI().getToken();
	    if(returnToken != ''){
        request.setHeader('Authorization',returnToken);
            }*/ 
                //Borrar
        //request.setHeader('Authorization','Bearer 21af2ad7-1a46-4a7a-86f0-c13f729659f7');
	   
		//request.setBody('');
		
		 
		try{
			HttpResponse response;
			//if (!test.isRunningTest()) {
			System.debug('REQUEST: '+request);
			response = http.send(request);
			//}else{
			//	setResponseMock();
			//resultado = mockListaPolizas();
			//response = resultMock; 	
			//}  
			System.debug('>>>>>>>Callout_ConsultaPolizaVesta.Response: ' + response.getBody());
			JSONParser parser = JSON.createParser(response.getBody());		
			System.debug('Callout_ConsultaPolizaVesta: getDatos: parser: '+parser);
			resultado = analizarRespuesta(parser);
			System.debug('Callout_ConsultaPolizaVesta: getDatos: resultado: '+resultado);
		}
		catch(Exception e){
			System.debug('CAllout_ConsultaPolizaVesta: getDatos: e: '+e);
			resultado = new List<Callout_ConsultaPolizaVesta_RP>();
			Callout_ConsultaPolizaVesta_RP resError = new Callout_ConsultaPolizaVesta_RP();
			resError.errorCode = '00';
			resError.errorMessage = e.getMessage();
			resultado.add(resError);
		}
		System.debug('Callout_ConsultaPolizaVesta: getDatos: resultado: '+resultado); 
		return resultado;
	}

	/* 
	 *	Método encargado de analizar la respuesta del sistema tercero y transformarla en un objeto Resultado;
	 * 	que encapsula el body de la response.
	 *  	@param response: instancia de JSON parser inicializada con la response en forma de String
	 *   
	 */
	private static List<Callout_ConsultaPolizaVesta_RP> analizarRespuesta(JSONParser response){
		System.debug('Callout_ConsultaPolizaVesta: analizarRespuesta: response: '+response);
		List<Callout_ConsultaPolizaVesta_RP> lista = new List<Callout_ConsultaPolizaVesta_RP>();
		Callout_ConsultaPolizaVesta_RP res =new Callout_ConsultaPolizaVesta_RP();
		integer i = 0;
		List<Producto_CIA__c> listaProd = new List<Producto_CIA__c>([SELECT
		                                                             Name, PRD_FOR_CompaniaIdSF__c, PRD_TXT_Cod_Producto__c, PRD_TXT_Descripcion__c FROM Producto_CIA__c]);
		Date fechaAlmudena = Date.newInstance(2017, 05, 08);
		while(response.nextToken() != null){
			String gett = response.getText(); 
			if(gett == '}')
			{			
				if(res.errorCode != null){
					List<Callout_ConsultaPolizaVesta_RP> listResError =new List<Callout_ConsultaPolizaVesta_RP>();
					Callout_ConsultaPolizaVesta_RP resError =new Callout_ConsultaPolizaVesta_RP();	   
					resError.errorMessage = res.errorMessage;
					resError.errorCode = res.errorCode;
					listResError.add(resError);
					return listResError;	
				}
				else if(res.numeroPoliza != null){ //Cuando recibimos más de una póliza se crea una lista, aquí identificamos el final del objeto JSON

					// Concatenar nombre del cliente
					res.nombreCompleto = Util_Cuentas.nombreCompleto(res.nombre, res.apellido1, res.apellido2);

					// Concatenar dirección
					res.direccionCompleta = '';
					if(res.direccionRiesgoDomicilio != null){res.direccionCompleta += res.direccionRiesgoDomicilio;}
					if(res.direccionRiesgoCp != null){
						if(res.direccionCompleta != ''){res.direccionCompleta += ', ';}
						res.direccionCompleta += res.direccionRiesgoCp;
					}
					if(res.direccionRiesgoPoblacion != null){
						if(res.direccionCompleta != ''){res.direccionCompleta += ', ';}
						res.direccionCompleta += res.direccionRiesgoPoblacion;
					}
					if(res.direccionRiesgoProvincia != null){
						if(res.direccionCompleta != ''){res.direccionCompleta += ', ';}
						res.direccionCompleta += res.direccionRiesgoProvincia;
					}

					// Resolver producto en Salesforce
					if (res.producto != null){
						for(Producto_CIA__c producto : listaProd){
							if(res.producto == producto.PRD_TXT_Cod_Producto__c
									&& res.idSFCompania == producto.PRD_FOR_CompaniaIdSF__c){
								res.descProdAux = producto.PRD_TXT_Descripcion__c;
								res.nombreProducto = producto.Name;
								res.idSFProducto = producto.Id;
								break;
							}
						}
						if(res.idSFProducto == null){
							res.nombreProducto = '*ERROR*';
							res.descProdAux = 'ERROR: El producto con código "' + res.producto + '" no está registrado en el sistema para la Compañía "' + res.nombreCompania + '".';
						}
					}

					// Resolver si la póliza pertenece a HomeServe
					if(res.identificadorCompania == Label.IDE_SEGURCAIXA){
						if(res.controlDigitoSegurcaixa == Integer.valueOf('1')){
							res.perteneceHSMsg = Label.POL_NOGEST_SC1;
						}
						else if(res.controlDigitoSegurcaixa == Integer.valueOf('2')){
							res.perteneceHSMsg = Label.POL_NOGEST_SC2;
						}
					}
					else if(res.identificadorCompania == Label.IDE_ALMUDENA && res.fechaInicioCobertura != null
							&& res.fechaInicioCobertura > fechaAlmudena && Math.mod((res.fechaInicioCobertura).day(), 2) == 0){
						res.perteneceHSMsg = Label.POL_NOGEST_ALM;
					}
					res.perteneceHS = (res.perteneceHSMsg == null || res.perteneceHSMsg == '');

					lista.add(res);
					System.debug('Callout_ConsultaPolizaVesta: analizarRespuesta: añado1: '+ res);
					res = new Callout_ConsultaPolizaVesta_RP();
				}
			}
			//Si han preguntado por el número de pólizas activas.
			if(gett == 'numeroPolizasActivas'){
				response.nextToken();	
				System.debug('Callout_ConsultaPolizaVesta: analizarRespuesta: response.getText(): '+ response.getText());
				if(!String.isEmpty(response.getText())) {
					res.numeroPolizasActivas = response.getText();
					lista.add(res);
					System.debug('Callout_ConsultaPolizaVesta: analizarRespuesta: añado2: '+ res);
				}
				break;
			}
			if(gett == 'identificadorCompania'){
				response.nextToken();
				res.identificadorCompania = response.getText();
				if(res.identificadorCompania != null){
					Account compania = Util_Compania.CIA_BY_IDHS.get(res.identificadorCompania);
					if(compania != null)
					{
						res.nombreCompania = compania.Name;
						res.idSFCompania = compania.Id;
					}
				}	  
			}
			if(gett== 'VIP_COMPANY') {
				response.nextToken();
				res.VIPCompany=response.getText();
			}
			if(gett == 'producto'){
				response.nextToken();
				res.producto = response.getText();
			}
			if(gett== 'numeroPoliza'){
				response.nextToken();
				res.numeroPoliza = response.getText();
			}
			if(gett== 'listaTelefono'){
				response.nextToken();
				res.listaTelefono = response.getText();
				res =new Callout_ConsultaPolizaVesta_RP();
			}
			if(gett == 'identificadorVersion'){
				response.nextToken();
				res.identificadorVersion = response.getText();
			}
			if(gett == 'fechaInicioCobertura'){
				response.nextToken();

				String fecha = response.getText();
				fecha = fecha.replaceAll('T', '-');
				fecha = fecha.replaceAll(':', '-');

				String[] fechaSplit = fecha.split('-');

				if(fechaSplit != null && fechaSplit.size() > 0){
					res.fechaInicioCobertura = DateTime.newInstance(Integer.valueOf(fechaSplit[0]), Integer.valueOf(fechaSplit[1]), Integer.valueOf(fechaSplit[2]), 
							Integer.valueOf(fechaSplit[3]), Integer.valueOf(fechaSplit[4]), 
							Integer.valueOf(fechaSplit[5].substringBefore('.')));
				}
			}
			if(gett== 'fechaFinCobertura'){
				response.nextToken();

				String fecha = response.getText();
				fecha = fecha.replaceAll('T', '-');
				fecha = fecha.replaceAll(':', '-');

				String[] fechaSplit = fecha.split('-');

				if(fechaSplit != null && fechaSplit.size() > 0){
					res.fechaFinCobertura = DateTime.newInstance(Integer.valueOf(fechaSplit[0]), Integer.valueOf(fechaSplit[1]), Integer.valueOf(fechaSplit[2]), 
							Integer.valueOf(fechaSplit[3]), Integer.valueOf(fechaSplit[4]), 
							Integer.valueOf(fechaSplit[5].substringBefore('.')));
				} 
				if(datetime.now()>res.fechaFinCobertura){
					res.estado = Label.POL_ESTADO_BAJA;
				}else{
					res.estado = Label.POL_ESTADO_ACTIVA;
				}
			} else {
				res.estado= Label.POL_ESTADO_ACTIVA;
			}
			if(gett == 'tomadorNumeroDocumentoCliente'){
				response.nextToken();
				res.numeroDocumento = response.getText();	
			}
			if(gett == 'nombre'){
				response.nextToken();
				res.nombre = response.getText();
			}
			if(gett == 'apellido1'){
				response.nextToken();
				res.apellido1 = response.getText();
			}
			if(gett == 'apellido2'){
				response.nextToken();
				res.apellido2 = response.getText();
			}
			if(gett== 'email'){
				response.nextToken();
				res.email = response.getText();
			}
			if(gett == 'idioma'){
				response.nextToken();
				res.idioma = response.getText();
			}
			if(gett == 'direccionRiesgoDomicilio'){
				response.nextToken();
				res.direccionRiesgoDomicilio = response.getText();	
			}
			if(gett == 'direccionRiesgoPoblacion'){
				response.nextToken();
				res.direccionRiesgoPoblacion = Util_Listas_Seleccion.limpiarAcentos(response.getText());
			}   
			if(gett == 'direccionRiesgoProvincia'){
				response.nextToken();
				res.direccionRiesgoCodProvincia = Util_Listas_Seleccion.limpiarAcentos(response.getText());
				res.direccionRiesgoProvincia = Util_Listas_Seleccion.getLabelDesdeAPI('Version_ContratoServicio__c', 'POLV_SEL_Estado_Provincia__c').get(res.direccionRiesgoCodProvincia);
			}
			if(gett == 'direccionRiesgoCp'){
				response.nextToken();
				res.direccionRiesgoCp = response.getText();
			}
			if(gett == 'capitalContenido'){
				response.nextToken();
				res.capitalContenido = double.valueOf(response.getText());
			}
			if(gett == 'capitalContinente'){
				response.nextToken();
				res.capitalContinente = double.valueOf(response.getText());
			}
			if(gett == 'capitalObjetos'){
				response.nextToken();
				res.capitalObjetos = double.valueOf(response.getText());
			}
			if(gett == 'certificado'){
				response.nextToken();
				res.certificado = response.getText();
			}
			if(gett == 'codigoDelegacion'){
				response.nextToken();
				res.codigoDelegacion = response.getText();
			}     
			if(gett == 'codigoSucursal'){
				response.nextToken();
				res.codigoSucursal = response.getText();
			}
			if(gett== 'controlDigitoSegurcaixa'){
				response.nextToken();
				res.controlDigitoSegurcaixa = integer.valueOf(response.getText());
			}
			if(gett == 'datosVivienda'){
				response.nextToken();
				res.datosVivienda = response.getText();
			}
			if(gett == 'fechaAltaCompania'){
				response.nextToken();

				String fecha = response.getText();
				fecha = fecha.replaceAll('T', '-');
				fecha = fecha.replaceAll(':', '-');

				String[] fechaSplit = fecha.split('-');

				if(fechaSplit != null && fechaSplit.size() > 0){
					res.fechaAltaCompania = DateTime.newInstance(Integer.valueOf(fechaSplit[0]), Integer.valueOf(fechaSplit[1]), Integer.valueOf(fechaSplit[2]), 
							Integer.valueOf(fechaSplit[3]), Integer.valueOf(fechaSplit[4]), 
							Integer.valueOf(fechaSplit[5].substringBefore('.')));
				}
			}
			if(gett == 'isGold'){
				response.nextToken();
				if (response.getText()=='true'){
					res.isGold = true;
				}else{
					res.isGold = false;
				}
			}
			if(gett == 'isVip'){
				response.nextToken();
				if (response.getText()=='true'){
					res.isVip = true;
				}else{
					res.isVip = false;
				}
			}
			if(gett == 'superficieGaraje'){
				response.nextToken();
				res.superficieGaraje = integer.valueOF(response.getText());
			}
			if(gett == 'superficieTrastero'){
				response.nextToken();
				res.superficieTrastero = integer.valueOf(response.getText());
			}
			if(gett == 'superficieVivienda'){
				response.nextToken();
				res.superficieVivienda = integer.valueOf(response.getText());
			}
			if(gett == 'suplemento'){
				response.nextToken();
				res.suplemento = response.getText();
			}
			if(gett == 'tipoDivisa'){
				response.nextToken();
				res.tipoDivisa = response.getText();
			}
			if(gett == 'tipoRegimenVivienda'){
				response.nextToken();
				res.tipoRegimenVivienda = response.getText();
			}   
			if(gett == 'tipoTransferencia'){
				response.nextToken();
				res.tipoTransferencia = integer.valueOf(response.getText());
			}
			if(gett == 'polizaComplementaria'){
				response.nextToken();
				res.polizaComplementaria = response.getText();
			}
			if(gett == 'codigoGestor'){
				response.nextToken();
				res.codigoGestor = response.getText();
			}
			if(gett == 'codigoCliente'){
				response.nextToken();
				res.codigoCliente = response.getText();
			}
			if(gett == 'telefono1'){
				response.nextToken();
				res.telefono1 = response.getText();
			}
			if(gett == 'telefono2'){
				response.nextToken();
				res.telefono2 = response.getText();
			}
			if(gett == 'telefono3'){
				response.nextToken();
				res.telefono3 = response.getText();
			}
			if(gett == 'telefono4'){
				response.nextToken();
				res.telefono4 = response.getText();
			}
			if(gett == 'codigoMunicipio'){
				response.nextToken();
				res.codigoMunicipio = response.getText();
			}
			if(gett == 'rolAsegurado'){
				response.nextToken();
				res.rolAsegurado = response.getText();
			}
			if(gett == 'idClienteEnsura'){
				response.nextToken();
				res.idClienteEnsura = response.getText();
			}
			if(gett == 'errorCode'){
				response.nextToken();
				res.errorCode = response.getText();
			}
			if(gett == 'errorMessage' && res.errorCode != null){
				response.nextToken();
				res.errorMessage = response.getText();
			}
			if(gett == 'codigoError'){
				response.nextToken();
				res.errorCode = response.getText();
			}
			if(gett == 'descripcion' && res.errorCode != null){
				response.nextToken();
				res.errorMessage = response.getText();
			}
		}
		system.debug('Callout_ConsultaPolizaVesta: analizarRespuesta: lista: '+lista);
		return lista;
	}


	//BORRAR
	
	/*public static List<Callout_ConsultaPolizaVesta_RP> mockListaPolizas() {
		return analizarRespuesta(JSON.createParser('{"listadoPoliza": {"poliza":[{"apellido2":"COLLADO","apellido1":"ARRABAL","identificadorCompania":"1008","direccionRiesgoDomicilio":"MAYOR,44-BAJO","isGold":false,"producto":"292","controlDigitoSegurcaixa":"0","fechaFinCobertura":"2010-11-18T00:00:00","tomadorNumeroDocumentoCliente":"12694835P","nombre":"ANTONIO","isVip":false,"fechaInicioCobertura":"2008-05-16T00:00:00","direccionRiesgoPoblacion":"PALENCIA","identificadorVersion":"536081","fechaAltaCompania":"1900-01-01T00:00:00","numeroPoliza":"417649001","direccionRiesgoCp":"34001","direccionRiesgoProvincia":"34","email":"email8367708@homeserve.es"},{"apellido2":"PEREZ","apellido1":"LOPEZ","identificadorCompania":"1008","direccionRiesgoDomicilio":"CALLE MAYOR 44 BAJO","isGold":false,"producto":"294","controlDigitoSegurcaixa":"0","fechaFinCobertura":"2011-11-29T00:00:00","tomadorNumeroDocumentoCliente":"12694835P","nombre":"ANTONIO","isVip":false,"fechaInicioCobertura":"2010-11-18T00:00:00","direccionRiesgoPoblacion":"PALENCIA","identificadorVersion":"601513","fechaAltaCompania":"1900-01-01T00:00:00","numeroPoliza":"427422001","direccionRiesgoCp":"34001","direccionRiesgoProvincia":"34","email":"email89513556@homeserve.es"},{"apellido2":"VILLALTA MARTINEZ","apellido1":"TORRES","identificadorCompania":"1008","direccionRiesgoDomicilio":"MAYOR,56-5-IZQDA.","isGold":false,"producto":"281","controlDigitoSegurcaixa":"0","fechaFinCobertura":"2010-09-01T00:00:00","tomadorNumeroDocumentoCliente":"12694835P","nombre":"DOLORES","isVip":false,"fechaInicioCobertura":"2003-10-17T00:00:00","direccionRiesgoPoblacion":"PALENCIA","identificadorVersion":"666100","fechaAltaCompania":"1900-01-01T00:00:00","numeroPoliza":"838622001","direccionRiesgoCp":"34001","direccionRiesgoProvincia":"34","email":"email3861095@homeserve.es"},{"apellido2":"CHAHBOUN EL","apellido1":"PEREZ","identificadorCompania":"1008","direccionRiesgoDomicilio":"CL BECERRO DE BENGOA,5","isGold":false,"producto":"294","controlDigitoSegurcaixa":"0","fechaFinCobertura":"2012-04-02T00:00:00","tomadorNumeroDocumentoCliente":"12694835P","nombre":"INMACULADA","isVip":false,"fechaInicioCobertura":"2011-03-16T00:00:00","direccionRiesgoPoblacion":"PALENCIA","identificadorVersion":"611115","fechaAltaCompania":"1900-01-01T00:00:00","numeroPoliza":"427933001","direccionRiesgoCp":"34001","direccionRiesgoProvincia":"34","email":"email12315647@homeserve.es"},{"apellido2":"MARTINEZ","apellido1":"HARO REYES","identificadorCompania":"1008","direccionRiesgoDomicilio":"MAYOR,44-BAJO","isGold":false,"producto":"292","controlDigitoSegurcaixa":"0","fechaFinCobertura":"2010-11-18T00:00:00","tomadorNumeroDocumentoCliente":"12694835P","nombre":"MARIA DEL CARMEN","isVip":false,"fechaInicioCobertura":"2008-05-16T00:00:00","direccionRiesgoPoblacion":"PALENCIA","identificadorVersion":"522149","fechaAltaCompania":"1900-01-01T00:00:00","numeroPoliza":"00417649001","direccionRiesgoCp":"34001","direccionRiesgoProvincia":"34","email":"email31925338@homeserve.es"}]}, "code": "0",	"message": "","numeroPolizasActivas": "" }'));
	} */
	
	public static List<Callout_ConsultaPolizaVesta_RP> mockListaPolizas() {
		return analizarRespuesta(JSON.createParser('{"listadoPoliza": {"poliza":[{"apellido2":"REY","apellido1":"ALEJANDRO","identificadorCompania":"1008","direccionRiesgoDomicilio":"MAYOR,44-BAJO","isGold":true,"producto":"292","controlDigitoSegurcaixa":"0","fechaFinCobertura":"2010-11-15T00:00:00","tomadorNumeroDocumentoCliente":"04626393N","nombre":"Alejandro","isVip":false,"fechaInicioCobertura":"2008-05-16T00:00:00","direccionRiesgoPoblacion":"PALENCIA","identificadorVersion":"5400000","fechaAltaCompania":"1900-01-01T00:00:00","numeroPoliza":"417649001","direccionRiesgoCp":"34001","direccionRiesgoProvincia":"34","email":"email8367708@homeserve.es"},{"apellido2":"PEREZ","apellido1":"LOPEZ","identificadorCompania":"1008","direccionRiesgoDomicilio":"CALLE MAYOR 44 BAJO","isGold":false,"producto":"294","controlDigitoSegurcaixa":"0","fechaFinCobertura":"2011-11-29T00:00:00","tomadorNumeroDocumentoCliente":"12694835P","nombre":"ANTONIO","isVip":false,"fechaInicioCobertura":"2010-11-18T00:00:00","direccionRiesgoPoblacion":"PALENCIA","identificadorVersion":"60101513","fechaAltaCompania":"1900-01-01T00:00:00","numeroPoliza":"4327422001","direccionRiesgoCp":"34001","direccionRiesgoProvincia":"34","email":"email89513556@homeserve.es"},{"apellido2":"VILLALTA MARTINEZ","apellido1":"TORRES","identificadorCompania":"1008","direccionRiesgoDomicilio":"MAYOR,56-5-IZQDA.","isGold":false,"producto":"281","controlDigitoSegurcaixa":"0","fechaFinCobertura":"2010-09-01T00:00:00","tomadorNumeroDocumentoCliente":"12694835P","nombre":"DOLORES","isVip":false,"fechaInicioCobertura":"2003-10-17T00:00:00","direccionRiesgoPoblacion":"PALENCIA","identificadorVersion":"667100","fechaAltaCompania":"1900-01-01T00:00:00","numeroPoliza":"838622001","direccionRiesgoCp":"34001","direccionRiesgoProvincia":"34","email":"email3861095@homeserve.es"},{"apellido2":"CHAHBOUN EL","apellido1":"PEREZ","identificadorCompania":"1008","direccionRiesgoDomicilio":"CL BECERRO DE BENGOA,5","isGold":false,"producto":"294","controlDigitoSegurcaixa":"0","fechaFinCobertura":"2012-04-02T00:00:00","tomadorNumeroDocumentoCliente":"12694835P","nombre":"INMACULADA","isVip":false,"fechaInicioCobertura":"2011-03-16T00:00:00","direccionRiesgoPoblacion":"PALENCIA","identificadorVersion":"611115","fechaAltaCompania":"1900-01-01T00:00:00","numeroPoliza":"427933001","direccionRiesgoCp":"34001","direccionRiesgoProvincia":"34","email":"email12315647@homeserve.es"},{"apellido2":"MARTINEZ","apellido1":"HARO REYES","identificadorCompania":"1008","direccionRiesgoDomicilio":"MAYOR,44-BAJO","isGold":false,"producto":"292","controlDigitoSegurcaixa":"0","fechaFinCobertura":"2010-11-18T00:00:00","tomadorNumeroDocumentoCliente":"12694835P","nombre":"MARIA DEL CARMEN","isVip":false,"fechaInicioCobertura":"2008-05-16T00:00:00","direccionRiesgoPoblacion":"PALENCIA","identificadorVersion":"522149","fechaAltaCompania":"1900-01-01T00:00:00","numeroPoliza":"00417649001","direccionRiesgoCp":"34001","direccionRiesgoProvincia":"34","email":"email31925338@homeserve.es"}]}, "code": "0",	"message": "","numeroPolizasActivas": "" }'));
	} 
	
}