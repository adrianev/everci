public without sharing class AvisoACompaniaController {
	//Datos configuración Inicial. 
	private final String COMPANIA_ID='idCompania';
	private final String POLIZA_ID='idPoliza';
	private final String NOMBRE_CLIENTE='nombreCliente';
	private final String NUMERO_DOCUMENTO_CLIENTE='numeroDocumento';
	public String tituloSeccionCompaniaVF{get;set;}
	public String subtituloVF{get;set;}
	public Integer numeroDeColumnasVF{get;set;} 
	public Boolean emailEnviadoConExito{get;set;}
	//Datos en Sección de póliza
	public ServiceContract poliza{get;set;}
	public Version_ContratoServicio__c versionPoliza{get;set;}
	public String nombreClientePoliza{get;set;}
	public String numeroDocumentoClientePoliza{get;set;}
	public String provinciaPoliza{get;set;}
	//Datos en Sección compañia.
	public Account compania{get;set;}
	public String codigoPostal {get;set;}
	public String poblacion {get;set;}
	public String provincia {get;set;}
	public List<SelectOption> listaPoblaciones {get;set;}
	public List<SelectOption> listaProvincias {get;set;}
	public String numeroPolizaModificado{get;set;}
	public String nombreCompletoModificado{get;set;}
	public String domicilioModificado{get;set;}
	public String comentarios{get;set;}
	//Envío de Email
	private Contact contactFrom {get;set;}
	public Contact contactTo {get;set;}

	/**
	* Esta página recibe por parámetro idCompania o IdPoliza / nombreCliente / numeroDocumentoCliente.
	*/
	public AvisoACompaniaController(){
		poliza=new ServiceContract();
		versionPoliza=new Version_ContratoServicio__c();
		compania=new Account();
		String idCompania='';
		String idPoliza='';
		nombreClientePoliza='';
		numeroDocumentoClientePoliza='';
		tituloSeccionCompaniaVF='';
		subtituloVF='';
		numeroDeColumnasVF=0;
		listaProvincias=Util_Poblacion.inicializarListaProvincias();
		listaPoblaciones=Util_Poblacion.inicializarListaPoblaciones();
		contactFrom=new Contact();
		contactTo=new Contact();
		emailEnviadoConExito=false;

		Map<String, String> mapParameters=ApexPages.currentPage().getParameters();
		for(String parameterAux:mapParameters.keySet()){
			if(COMPANIA_ID.equalsIgnoreCase(parameterAux)){
				idCompania=mapParameters.get(parameterAux);
				tituloSeccionCompaniaVF='Datos cliente desconocido';
				subtituloVF='Cliente Desconocido';
				numeroDeColumnasVF=1;
			} 
			if(POLIZA_ID.equalsIgnoreCase(parameterAux)){
				idPoliza=mapParameters.get(parameterAux);
				tituloSeccionCompaniaVF='Datos modificados'; 
				subtituloVF='Cambio en Situación de Riesgo';
				numeroDeColumnasVF=2;
			}
			if(NOMBRE_CLIENTE.equalsIgnoreCase(parameterAux)){
				nombreClientePoliza=mapParameters.get(parameterAux);
			}
			if(NUMERO_DOCUMENTO_CLIENTE.equalsIgnoreCase(parameterAux)){
				numeroDocumentoClientePoliza=mapParameters.get(parameterAux);
			}
		}

		

		if(!String.isEmpty(idCompania)){
			compania = Util_Cuentas.getMapCuentasById(new Set<Id>{idCompania}).get(idCompania);
		}
		else if(!String.isEmpty(idPoliza)){
			//Recuperamos la póliza
			for(ServiceContract polizaAux:Util_Poliza_Contrato.queryPolizaById(new Set<Id>{idPoliza}).values()){
				poliza=polizaAux;
			}
			//Recuperamos la version de la poliza
			for(Version_ContratoServicio__c versionPolizaAux:Util_Poliza_Contrato.queryVersionPoliza(new Set<Id>{poliza.POL_LKP_Version_Actual__c}).values()){
				versionPoliza=versionPolizaAux;
			}
			//Recuperamos la compañía
			compania = Util_Cuentas.getMapCuentasById(new Set<Id>{poliza.POL_LKP_Compania__c}).get(poliza.POL_LKP_Compania__c);

			//Rellenamos la provincia de la póliza.
			if(!String.isEmpty(versionPoliza.POLV_SEL_Estado_Provincia__c)){
				provincia = Util_Listas_Seleccion.getLabelDesdeAPI('Version_ContratoServicio__c', 'POLV_SEL_Estado_Provincia__c').get(versionPoliza.POLV_SEL_Estado_Provincia__c);
				provinciaPoliza=provincia;
			}
			//Copiamos datos a la sección de la Compañía.
			numeroPolizaModificado=poliza.Name;
			nombreCompletoModificado=nombreClientePoliza;
			domicilioModificado=versionPoliza.POLV_TXT_Calle__c;
			codigoPostal=versionPoliza.POLV_TXT_Codigo_Postal__c;
			cargarUbicacion();
		}
		else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No se ha recibido ni una compañía ni una póliza'));
		}

		Set<String> setProgramTypes=new Set<String>();
		setProgramTypes.add(Label.CON_TIPO_PROGRAMA_COORDINADOR_CUENTA); //Coordinador de Cuenta
		setProgramTypes.add(Label.CON_TIPO_PROGRAMA_AVISO_CIA); //Aviso a Cia
		Map<Id,Contact> mapContactFrom=new Map<Id, Contact>();
		mapContactFrom=Util_Contacto.queryContactoByAccountIdAndProgramType(new Set<Id>{compania.Id},setProgramTypes);
		for(Contact contact:mapContactFrom.values()){
			if(Label.CON_TIPO_PROGRAMA_COORDINADOR_CUENTA.equalsIgnoreCase(contact.CON_SEL_Tipo_Programa__c)){
				contactFrom=contact;
			}
			if(Label.CON_TIPO_PROGRAMA_AVISO_CIA.equalsIgnoreCase(contact.CON_SEL_Tipo_Programa__c)){
				contactTo=contact;
			}
		}
	}

	public void cargarCodigoPostal(){
		if(poblacion!=null){
			for(Poblacion_CP__c codigoPostalAux: Util_Poblacion.getCpPoblacion(new Set<String>{poblacion}).values()){
				codigoPostal=codigoPostalAux.PCP_TXT_Identificador__c.substringBefore('#');
			}
		}
	}

	public void cargarPoblacion(){
		//Poblacion
		if(provincia!=null){
			List<SelectOption> listaPoblacionesAux=new List<SelectOption>();
			listaPoblacionesAux.add(new SelectOption('','-- Ninguno --'));
		  	for(Poblacion__c identificadorPoblacionAux:Util_Poblacion.getPoblacionProv(provincia).values()){
				listaPoblacionesAux.add(new SelectOption(identificadorPoblacionAux.Id   ,identificadorPoblacionAux.POB_TXT_Identificador__c.substringAfter('#')));
			} 
			listaPoblaciones=listaPoblacionesAux;
		}
		//reinicio el Código Postal
		codigoPostal='';
	}

	public void cargarUbicacion(){
		if(!String.isEmpty(codigoPostal)){
			Map<Id, Poblacion_CP__c> mapPoblacion=Util_Poblacion.queryPoblacion_CPByPCP_LKP_TerritorioServicio_r_TDS_TXT_Identificador(new Set<String>{codigoPostal});
			if(!mapPoblacion.isEmpty()){
				for(Poblacion_CP__c poblacionAux:mapPoblacion.values()){
					listaPoblaciones=new List<SelectOption>();
					provincia=poblacionAux.PCP_LKP_Poblacion__r.POB_SEL_Provincia__c;
					listaPoblaciones.add(new SelectOption(provincia + '#' + poblacionAux.PCP_LKP_Poblacion__r.Name, poblacionAux.PCP_LKP_Poblacion__r.Name));
				}
			} else {
				provincia='';
				listaProvincias=Util_Poblacion.inicializarListaProvincias();
				listaPoblaciones=Util_Poblacion.inicializarListaPoblaciones();
			}
		} else {
			provincia='';
			listaProvincias=Util_Poblacion.inicializarListaProvincias();
			listaPoblaciones=Util_Poblacion.inicializarListaPoblaciones();
		}
	}
 
	//TODO: Añadir validaciones?
	public void enviarEmail(){
		String asunto='';
		String cuerpo='';
												   
		if(!validacionesEnviarEmail()){
			if(!String.isEmpty(poliza.Id)){
				asunto = Label.ASUNTO_CAMBIO_SIT_RIESGO;
				cuerpo = cuerpoCambioSituacionRiesgo();
			} else {
				asunto = Label.ASUNTO_CLIENTE_DESCONOCIDO;
				cuerpo = cuerpoClienteDesconocido();
			}
			try {
				//String correoRemitente = Util_Correo_Electronico.getBuzonCIA(Label.IDE_HOMESERVE, Label.CON_TIPO_PROGRAMA_NO_REPLY);
				Util_Correo_Electronico.enviarSingleEmailSinPlantilla(null,asunto,cuerpo,'HTML',contactTo.Id,null,null,null,contactFrom.email);
				emailEnviadoConExito=true;
				ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Correo electrónico enviado con éxito.'));
			} catch (Exception e){
				emailEnviadoConExito=false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ERROR_EMAIL_NO_ENVIADO));
			}
		}
	}

	public String cuerpoCambioSituacionRiesgo(){
		//subtituloVF = subtitulo(); // Nº6 Subtítulo de Email - 25_06_2018 - SMM
		String html2=formarCabeceraEmail();
		String provinciaToSend=Util_Listas_Seleccion.getLabelDesdeAPI('Version_ContratoServicio__c', 'POLV_SEL_Estado_Provincia__c').get(provincia);
		String poblacionToSend='';
		if(!String.isEmpty(poblacion)){
			poblacionToSend=poblacion.substringAfter('#');
		}

		// [INI] Nº7 Marcar en Rojo datos Incorrectos de Email - 25_06_2018 - SMM
		// Cabeceras:
		// -------------------------------------------------------------
		String html = '<p class="mail-subtitle">'+subtituloVF+'</p>' + html2 +'\n'+'<table><tr><td style="width: 450"><p><h1>Datos originales</h1></p></td>'; // Nº6 Subtítulo de Email - 25_06_2018 - SMM
		html += '<td style="width: 750"><p><h1>Datos modificados</h1></p></td></tr>';

		// Compañías:
		html += '<tr><td style="width: 450"><p><b>Compañía:</b> ' + poliza.POL_LKP_Compania__r.Name + '</p></td>';
		html += '<td style="width: 750"><p><b>Compañía:</b> ' + poliza.POL_LKP_Compania__r.Name + '</p></td></tr>';

		// Pólizas:
		// -------------------------------------------------------------
		html += '<tr><td style="width: 450"><p><b>Póliza:</b> ' + poliza.Name + '</p></td>';
		html += '<td style="width: 750"><p><b>Póliza:</b> ' + poliza.Name + '</p></td></tr>';

		// Nombre y Apellidos;
		// -------------------------------------------------------------
		if(nombreClientePoliza != nombreCompletoModificado){
			html += '<tr><td style="width: 450"><p><b>Nombre y Apellidos:</b> <span style="color: red;">' + nombreClientePoliza + '</span></p></td>';
		}
		else{
			html += '<tr><td style="width: 450"><p><b>Nombre y Apellidos:</b> ' + nombreClientePoliza + '</p></td>';
		}

		if(nombreClientePoliza != nombreCompletoModificado){
			html += '<td style="width: 750"><p><b>Nombre y Apellidos:</b> <span style="color: red;">' + nombreCompletoModificado + '</span></p></td></tr>';
		}
		else{
			html += '<td style="width: 750"><p><b>Nombre y Apellidos:</b> ' + nombreCompletoModificado + '</p></td></tr>';
		}

		// Nº Documento:
		// -------------------------------------------------------------
		html += '<tr><td style="width: 450"><p><b>Nº de Documento:</b> ' + numeroDocumentoClientePoliza + '</p></td>';
		html += '<td style="width: 750"><p><b>Nº de Documento:</b> ' + numeroDocumentoClientePoliza + '</p></td></tr>';

		// Dirección:
		// -------------------------------------------------------------
		if(versionPoliza.POLV_TXT_Calle__c != domicilioModificado){
			html += '<tr><td style="width: 450"><p><b>Dirección:</b> <span style="color: red;">' + versionPoliza.POLV_TXT_Calle__c + '</span></p></td>';
		}
		else{
			html += '<tr><td style="width: 450"><p><b>Dirección:</b> ' + versionPoliza.POLV_TXT_Calle__c + '</p></td>';
		}

		if(versionPoliza.POLV_TXT_Calle__c != domicilioModificado){
			html += '<td style="width: 750"><p><b>Dirección:</b> <span style="color: red;">' + domicilioModificado + '</span></p></td></tr>';
		}
		else{
			html += '<td style="width: 750"><p><b>Dirección:</b> ' + domicilioModificado + '</p></td></tr>';	
		}

		// Población:
		// -------------------------------------------------------------
		if(versionPoliza.POLV_TXT_Poblacion__c != poblacionToSend){
			html += '<tr><td style="width: 450"><p><b>Población:</b> <span style="color: red;">' + versionPoliza.POLV_TXT_Poblacion__c + '</span></p></td>';
		}
		else{
			html += '<tr><td style="width: 450"><p><b>Población:</b> ' + versionPoliza.POLV_TXT_Poblacion__c + '</p></td>';
		}

		if(versionPoliza.POLV_TXT_Poblacion__c != poblacionToSend){
			html += '<td style="width: 750"><p><b>Población:</b> <span style="color: red;">' + poblacionToSend + '</span></p></td></tr>';
		}
		else{
			html += '<td style="width: 750"><p><b>Población:</b> ' + poblacionToSend + '</p></td></tr>';
		}

		// Provincia:
		// -------------------------------------------------------------
		if(provinciaPoliza != provinciaToSend){
			html += '<tr><td style="width: 450"><p><b>Provincia:</b> <span style="color: red;">' + provinciaPoliza + '</span></p></td>';
		}
		else{
			html += '<tr><td style="width: 450"><p><b>Provincia:</b> ' + provinciaPoliza + '</p></td>';
		}

		if(provinciaPoliza != provinciaToSend){
			html += '<td style="width: 750"><p><b>Provincia:</b> <span style="color: red;">' + provinciaToSend + '</span></p></td></tr>';
		}
		else{
			html += '<td style="width: 750"><p><b>Provincia:</b> ' + provinciaToSend + '</p></td></tr>';
		}

		// Código Postal:
		// -------------------------------------------------------------
		if(versionPoliza.POLV_TXT_Codigo_Postal__c != codigoPostal){
			html += '<tr><td style="width: 450"><p><b>Código Postal:</b> <span style="color: red;">' + versionPoliza.POLV_TXT_Codigo_Postal__c + '</span></p></td>';
		}
		else{
			html += '<tr><td style="width: 450"><p><b>Código Postal:</b> ' + versionPoliza.POLV_TXT_Codigo_Postal__c + '</p></td>';
		}

		if(versionPoliza.POLV_TXT_Codigo_Postal__c != codigoPostal){
			html += '<td style="width: 750"><p><b>Código Postal:</b> <span style="color: red;">' +codigoPostal + '</span></p></td></tr>';
		}
		else{
			html += '<td style="width: 750"><p><b>Código Postal:</b> ' +codigoPostal + '</p></td></tr>';
		}

		// Últimas celdas:
		// -------------------------------------------------------------
		html += '<tr><td style="width: 450"></td>';
		html += '<td style="width: 750"><p><b>Comentarios:</b> ' + comentarios + '</p></td></tr></table>';
		// [FIN] Nº7 Marcar en Rojo datos Incorrectos de Email

		return html;
	}
	
	public String formarCabeceraEmail(){
		// Nº7 Marcar en Rojo datos Incorrectos de Email - 25_06_2018 - SMM: En la línea siguiente se modifica el 'width' subiéndolo de 600 a 1200
		String html2='<table border="0" cellpadding="30" cellspacing="0" height="100%" width="1200" style="background-color: #fff; width:600px; padding: 0; margin: 0 auto; font-family: Arial, Helvetica; -webkit-text-size-adjust:none !important;">';
		html2 +='<tr><td align="center" valign="top">';
		html2 +='<table style="width:100%; background-color:white; border-bottom:1px solid #e7342c; border-top:1px solid #e7342c; margin: 0;" cellpadding="20" cellspacing="0">';
		html2 += '<tr style="">';
		html2 += '<td style="width:25%; text-align: left;">';
		html2 += '<img style="width:120px;" alt="HomeServe" src="https://www.homeserve.es/img/logo-homeserve.png" />';
		html2 +='</td>';
		html2 +='<td style="color: #e7342c;width: 50%; text-align: right;padding: 0 12px 0 0;font-size: 12px;font-weight: normal;">';
		html2 += 'Asistencias HomeServe';
		html2 +='</td>';
		html2 +='<td  style="width:25%; text-align:right; white-space: nowrap;">';
		html2 +='</td>';
		html2 +='</tr>';
		html2 +='</table>';
		return html2;
	}
	
	public String cuerpoClienteDesconocido()
	{
		//subtituloVF = subtitulo(); // Nº6 Subtítulo de Email - 25_06_2018 - SMM
		String html2=formarCabeceraEmail();
		String provinciaToSend=Util_Listas_Seleccion.getLabelDesdeAPI('Version_ContratoServicio__c', 'POLV_SEL_Estado_Provincia__c').get(provincia);
		String poblacionToSend='';
		if(!String.isEmpty(poblacion)){
			poblacionToSend=poblacion.substringAfter('#');
		}
		String html = '<p class="mail-subtitle">'+subtitulo()+'</p>' + html2 + '<p><h1>Datos cliente desconocido</h1></p>'; // Nº6 Subtítulo de Email - 25_06_2018 - SMM
		html += '<p><b>Compañía:</b> ' + compania.Name + '</p>';
		html += '<p><b>Póliza:</b> ' + numeroPolizaModificado + '</p>';
		html += '<p><b>Nombre y Apellidos:</b> ' + nombreCompletoModificado + '</p>';
		html += '<p><b>Nº de Documento:</b> ' + numeroDocumentoClientePoliza + '</p>';
		html += '<p><b>Dirección:</b> ' + domicilioModificado + '</p>';
		html += '<p><b>Población:</b> ' + poblacionToSend + '</p>';
		html += '<p><b>Provincia:</b> ' + provinciaToSend + '</p>';
		html += '<p><b>Código Postal:</b> ' + codigoPostal + '</p>';
		html += '<p><b>Comentarios:</b> ' + comentarios + '</p>';
		return html;
	}


	/**
	 * Devuelve el mensaje del subtítulo indicando que se debe responder al mismo correo electrónico.
	 *
	 * @return String con el mensaje del subtítulo
	 */
	public String subtitulo(){
		return 'ES NECESARIO RESPONDER SOBRE ESTE CORREO PARA PODER VINCULAR LA RESPUESTA AL MISMO HILO DE CORREO ELECTRÓNICO';
	}

	private Boolean validacionesEnviarEmail(){
		Boolean existenErrores=false;
		System.debug('@Laura: domicilioModificado ------>' + domicilioModificado);

		if(String.isEmpty(nombreCompletoModificado)){
			existenErrores=true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rellene todos los campos Obligatorios'));
		} else if(String.isEmpty(numeroDocumentoClientePoliza)){
			existenErrores=true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rellene todos los campos Obligatorios'));
		} else if(String.isEmpty(domicilioModificado)){
			existenErrores=true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rellene todos los campos Obligatorios'));
		} else if(String.isEmpty(poblacion)){
			existenErrores=true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rellene todos los campos Obligatorios'));
		} else if(String.isEmpty(provincia)){
			existenErrores=true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rellene todos los campos Obligatorios'));
		} else if(String.isEmpty(codigoPostal)){
			existenErrores=true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rellene todos los campos Obligatorios'));
		} else if(String.isEmpty(comentarios)){
			existenErrores=true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rellene todos los campos Obligatorios'));
		} else if(String.isEmpty(contactFrom.email) || String.isEmpty(contactTo.email)){
			existenErrores=true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ERROR_EMAIL_CIA));
		}
		return existenErrores;
	}
}