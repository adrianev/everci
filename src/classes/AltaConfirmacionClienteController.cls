/**
 * Clase controladora de la Visualforce "AltaConfirmacionCliente" encargada de dar de alta o modificar una Cuenta de Asegurado.
 * 
 * @author EVERIS
 */
public class AltaConfirmacionClienteController {
	public Account cliente{get;set;}
	public Account compania{get;set;}
	public Case caso{get;set;}
	public ServiceContract poliza{get;set;}
	public Version_ContratoServicio__c versionPoliza{get;set;}
	public List<ContactoTelefonicoPoliza> listaDeContactosDeLaPoliza{get;set;}
	public ContactoTelefonicoPoliza contactoTelefonicoPoliza{get;set;}
 
	//Datos de la población del cliente.
	public String poblacion {get; set;}
	public List<SelectOption> listaPoblacionesCliente {get;set;}
	public List<SelectOption> listaTiposRiesgo {get; set;} 

	//Teléfonos 
	public String telefonoSeleccionado {get;set;}
	public List<SelectOption> listaTelefonos {get; set;}
	
	public Boolean esSegurCaixa{get;set;}
	//Lista de Contactos
	public Boolean permitirCrearContacto{get;set;}
	public Boolean esActualizacion{get;set;}

	//Pagina VF.
	public String tituloPagina{get;set;}

	//parámetros navegación.
	private String identificador{get;set;}
	private String codigoVDN{get;set;}

	/*  
	* Puedo Recibir:
	* - idPoliza/idCopmania/idCaso/idCLiente/nuevaPoliza. Existe la póliza, pero es nueva Versión y el cliente en base de datos. (Email)
	* - idPoliza/idCompania/idCliente/nuevaPoliza. Existe la póliza, pero es nueva versión y el cliente en base de datos.
	* - idPoliza/idCopmania/idCaso/idCLiente. Existe la póliza y el cliente en base de datos. (Email)
	* - idPoliza/idCompania/idCliente. Existe la póliza y el cliente en base de datos.
	* - idPoliza/idCopmania/idCaso/DatosContacto. No existe el cliente en base de datos. (Email)
	* - idPoliza/idCompania/DatosContacto.
	*/
	public AltaConfirmacionClienteController(ApexPages.standardController stdCtr) {
		cliente=new Account();
		compania=new Account();
		caso=new Case();
		contactoTelefonicoPoliza=new ContactoTelefonicoPoliza(new Contact(), new Contacto_telefonico__c());
		listaDeContactosDeLaPoliza=new List<ContactoTelefonicoPoliza>();
		poliza=new ServiceContract();
		versionPoliza=new Version_ContratoServicio__c();
		esSegurCaixa=false;
		permitirCrearContacto=false;
		esActualizacion=false;
		Boolean esNuevaPoliza=false;

		String telefono1='', idCliente='', telefono2='', telefono3='',telefono4='',nombreCliente='', apellido1='',apellido2='', numeroDocumento='',idPoliza='',idCompania='',idCaso='',nuevaPoliza='';
	   
		
		Map<String, String> mapParameters=ApexPages.currentPage().getParameters();
		for(String parameterAux:mapParameters.keySet()) {
			System.debug('AltaConfirmacionClienteController: Constructor: paramétro: '+parameterAux+ 'valor: '+mapParameters.get(parameterAux));
			if('identificador'.equalsIgnoreCase(parameterAux)) {
				identificador=mapParameters.get(parameterAux);
			}
			if('VDN'.equalsIgnoreCase(parameterAux)) {
				codigoVDN=mapParameters.get(parameterAux);
			}
			if('id'.equalsIgnoreCase(parameterAux)) {
				idCliente=mapParameters.get(parameterAux);
			}
			if('idPoliza'.equalsIgnoreCase(parameterAux)) {
				idPoliza=mapParameters.get(parameterAux);
			}
			if('idCompania'.equalsIgnoreCase(parameterAux)) {
				idCompania=mapParameters.get(parameterAux);
			}
			if('idCaso'.equalsIgnoreCase(parameterAux)) {
				idCaso=mapParameters.get(parameterAux);
			}
			if('numeroDocumento'.equalsIgnoreCase(parameterAux)) {
				numeroDocumento=mapParameters.get(parameterAux);
			}
			if('telefono1'.equalsIgnoreCase(parameterAux)) {
				telefono1=mapParameters.get(parameterAux);
			}
			if('telefono2'.equalsIgnoreCase(parameterAux)) {
				telefono2=mapParameters.get(parameterAux);
			}
			if('telefono3'.equalsIgnoreCase(parameterAux)) {
				telefono3=mapParameters.get(parameterAux);
			}
			if('telefono4'.equalsIgnoreCase(parameterAux)) {
				telefono4=mapParameters.get(parameterAux);
			}
			if('nombreCliente'.equalsIgnoreCase(parameterAux)) {
				nombreCliente=mapParameters.get(parameterAux);
			}
			if('apellido1'.equalsIgnoreCase(parameterAux)) {
				apellido1=mapParameters.get(parameterAux);
			}
			if('apellido2'.equalsIgnoreCase(parameterAux)) {
				apellido2=mapParameters.get(parameterAux);
			}
			if('nuevaPoliza'.equalsIgnoreCase(parameterAux)) {
				if(mapParameters.get(parameterAux).equalsIgnoreCase('true')) {
					esNuevaPoliza=true;
				}
			}
			System.debug('AltaConfirmacionCliente: constructor: parameterAux'+parameterAux);
		}
		//Rellenar el título de la VF.
		if(String.isEmpty(idCliente)) {
			tituloPagina='Alta de Cliente y Póliza';
		} else  {
			cliente = Util_Cuentas.getMapCuentasById(new Set<Id>{idCliente}).get(idCliente);
			if(!esNuevaPoliza) {
				 tituloPagina='Confirmación de Datos de Cliente y Póliza';   
			} else {
				tituloPagina='Confirmación de Datos de Cliente y Alta de Póliza';
			}
		}


		 if(!String.isEmpty(idPoliza) && !String.isEmpty(idCaso) && !String.isEmpty(numeroDocumento) && !String.isEmpty(idCompania)) {
			//Sin cliente desde EmailToCase
			populatePoliza(idPoliza);
			populateCase(idCaso);
			populateClienteFromParameters(numeroDocumento,nombreCliente,apellido1,apellido2);
			populateContactFromParameters(telefono1,telefono2,telefono3,telefono4);
			populateCompania(idCompania);
			consultarContactosPoliza();
			listaTelefonos = Util_Telef_TransferCIA.buscarTelefonos(idCompania);
		} else if(!String.isEmpty(idPoliza) && !String.isEmpty(numeroDocumento) && !String.isEmpty(idCompania)) {
			//Sin cliente desde Llamada.
			populatePoliza(idPoliza);
			populateClienteFromParameters(numeroDocumento,nombreCliente,apellido1,apellido2);
			populateContactFromParameters(telefono1,telefono2,telefono3,telefono4);			
			populateCompania(idCompania);
			consultarContactosPoliza();
			listaTelefonos = Util_Telef_TransferCIA.buscarTelefonos(idCompania);
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error al recibir los parámetros'));
		}
			System.debug('AltaConfirmacionCliente: constructor: compania: '+compania);
			System.debug('AltaConfirmacionCliente: constructor: Label.IDE_SEGURCAIXA: '+Label.IDE_SEGURCAIXA);
		if((compania.CUE_TXT_Identificador__c == Label.IDE_SEGURCAIXA)) {
			esSegurCaixa=true;
		}

		listaPoblacionesCliente=Util_Poblacion.inicializarListaPoblaciones();
		listaTiposRiesgo = Util_Poliza_Contrato.cargarSelectorTipoRiesgo(poliza,'');
		cargarUbicacion();
		if(listaDeContactosDeLaPoliza.isEmpty()) {
			permitirCrearContacto=true;
		} else {
			permitirCrearContacto=false;
		}

		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.MSG_DATOS_ERRONEOS));

	}

	private void consultarContactosPoliza() {
		//Se recogen los contactos telefonicos de la poliza
		List<Contacto_telefonico__c> listaContactosTPoliza = Util_Contacto_Telefonico.queryContactoTelefonicoByPolizaId(new Set<Id>{poliza.Id}).values();
		Set<Id> idsContactosAsociados = new Set<Id>();
		if(!listaContactosTPoliza.isEmpty()) {
			for(Contacto_telefonico__c contactoT : listaContactosTPoliza)  {
				if(!idsContactosAsociados.contains(contactoT.CTF_LKP_Contacto__c))  {
					idsContactosAsociados.add(contactoT.CTF_LKP_Contacto__c);
				}
			}
			//Se recogen los contactos asociados a los contactos telefonicos de la poliza
			Map<Id, Contact> mapaContactos = new Map<Id, Contact>(Util_Contacto.getContactById(idsContactosAsociados));
			//Se rellena la lista de contactos que se muestra por pantalla
			for(Contacto_telefonico__c contactoT : listaContactosTPoliza) {
				if(contactoT.CTF_LKP_Contacto__c != null) {
					listaDeContactosDeLaPoliza.add(new ContactoTelefonicoPoliza( mapaContactos.get(contactoT.CTF_LKP_Contacto__c), contactoT));
				}
			}
		}
	}

	private void populateClienteFromParameters(String numeroDocumento, String nombreCliente, String apellido1, String apellido2) {
		cliente.CUE_TXT_Nombre__c=nombreCliente;
		cliente.CUE_TXT_PrimerApellido__c=apellido1;
		cliente.CUE_TXT_SegundoApellido__c=apellido2;
		cliente.Name=nombreCliente+ ' '+apellido1+ ' '+apellido2;
		cliente.CUE_TXT_Numero_Documento__c=numeroDocumento;
		contactoTelefonicoPoliza.contactoTelefonico.CTF_SEL_Tipo_Relacion__c='Asegurado';//TODO:API Name como Codigo y LABEL
		contactoTelefonicoPoliza.contacto.FirstName=nombreCliente;
		contactoTelefonicoPoliza.contacto.LastName=apellido1+ ' '+apellido2;
	}

	private void populateContactFromParameters(String telefono1, String telefono2, String telefono3, String telefono4) {
		contactoTelefonicoPoliza.contacto.Phone=telefono1;
		contactoTelefonicoPoliza.contacto.MobilePhone=telefono2;
		contactoTelefonicoPoliza.contacto.HomePhone=telefono3;
		contactoTelefonicoPoliza.contacto.Fax=telefono4;
	}

	private void populateCase(String idCaso) {
		//queryCasoById.
		for(Case casoAux:Util_Caso.getCaseById(new Set<Id>{idCaso}).values()) {
			caso=casoAux;
		}
	}

	/*private void populateCliente(String idCliente) {
		//queryClienteById.
		for(Account clienteAux:Util_Compania.queryAccountById(new Set<String>{idCliente}).values()) {
				cliente=clienteAux;
		}
	}*/

	private void populateCompania(String idCompania) {
		//QueryCompaniaById
		for(Account cuentaAux:Util_Compania.queryAccountById(new Set<String>{idCompania}).values()) {
			compania=cuentaAux;
		}
	}

	private void populatePoliza(String idPoliza) {
		//queryPolizaById
		for(ServiceContract polizaAux:Util_Poliza_Contrato.queryPolizaById(new Set<Id>{idPoliza}).values()) {
			poliza=polizaAux;
		}
		if(poliza != null){
			populateVersionPoliza(poliza.POL_LKP_Version_Actual__c);
		}
	}

	private void populateVersionPoliza(String idVersionPoliza) {
		for(Version_ContratoServicio__c versionPolizaAux:Util_Poliza_Contrato.queryVersionPoliza(new Set<Id>{idVersionPoliza}).values()) {
			versionPoliza=versionPolizaAux;
		}
	}

	public without sharing class ContactoTelefonicoPoliza {
		public Contact contacto {get; set;}
		public Contacto_telefonico__c contactoTelefonico {get; set;}
		public ContactoTelefonicoPoliza(Contact contacto, Contacto_telefonico__c contactoTelefonico)
		{
			this.contacto = contacto;
			this.contactoTelefonico = contactoTelefonico;
		}
	}


	public void mostrarAyudaTelefonoCompania(){
		if(!String.isEmpty(telefonoSeleccionado)){
			Util_Telef_TransferCIA.mostrarAyudaTelefonoCompania(telefonoSeleccionado);
		}
	}

	public void addContactoDePoliza() {
		if(!erroresAlGuardarContacto()) {
			if(!esActualizacion) {
				listaDeContactosDeLaPoliza.add(new ContactoTelefonicoPoliza(contactoTelefonicoPoliza.contacto,contactoTelefonicoPoliza.contactoTelefonico));
			}
			contactoTelefonicoPoliza.contacto=new Contact();
			contactoTelefonicoPoliza.contactoTelefonico=new Contacto_telefonico__c();
			permitirCrearContacto=false;
			esActualizacion=false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
		}
	}

	private Boolean erroresAlGuardarContacto() {
		Boolean existenErrores=false;
		if(String.isEmpty(contactoTelefonicoPoliza.contacto.FirstName)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rellene todos los campos obligatorios.'));
			existenErrores=true;
		} else if(String.isEmpty(contactoTelefonicoPoliza.contacto.LastName)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rellene todos los campos obligatorios.'));
			existenErrores=true;
		} else if(String.isEmpty(contactoTelefonicoPoliza.contacto.Phone)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rellene todos los campos obligatorios.'));
			existenErrores=true;
		} else if(String.isEmpty(contactoTelefonicoPoliza.contactoTelefonico.CTF_SEL_Tipo_Relacion__c)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rellene todos los campos obligatorios.'));
			existenErrores=true;
		} else if(String.isEmpty(contactoTelefonicoPoliza.contactoTelefonico.CTF_SEL_Hora_desde__c)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rellene todos los campos obligatorios.'));
			existenErrores=true;
		} else if(String.isEmpty(contactoTelefonicoPoliza.contactoTelefonico.CTF_SEL_Hora_hasta__c)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rellene todos los campos obligatorios.'));
			existenErrores=true;
		} else if(validarTelefono()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'El formato del teléfono no es correcto.'));
			existenErrores=true;
		} else if(validarHora()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'El campo "Hora desde" del contacto, debe ser menor al valor del campo "Hora hasta".'));
			existenErrores=true;
		}
		return existenErrores;
	}

	private Boolean validarHora() {
		Boolean existenErrores=false;
		Integer horaDesde=Integer.valueOf(contactoTelefonicoPoliza.contactoTelefonico.CTF_SEL_Hora_desde__c.subStringBefore(':'));
		Integer horaHasta=Integer.valueOf(contactoTelefonicoPoliza.contactoTelefonico.CTF_SEL_Hora_hasta__c.subStringBefore(':'));
		if(horaDesde >= horaHasta) {
			existenErrores=true;
		}
		return existenErrores;
	}

	private boolean validarTelefono() {
		Boolean existenErrores=false;
		Pattern patternFijos = Pattern.compile('^(\\+34|0034|34)?[89]\\d{8}$');
		Pattern patternMoviles = Pattern.compile('^(\\+34|0034|34)?[67]\\d{8}$');
		Matcher macheaFijo = patternFijos.matcher(contactoTelefonicoPoliza.contacto.Phone);
		Matcher macheaMovil = patternMoviles.matcher(contactoTelefonicoPoliza.contacto.Phone);
		if(!macheaFijo.matches() && !macheaMovil.matches()) {
			existenErrores=true;
		}
		return existenErrores;
	}

	public void eliminarContacto() {
		Integer indice=Integer.valueOf(Apexpages.currentPage().getParameters().get('indiceResultado'));
		//Si el contacto Existe en Base de datos borro el Contacto y en cascada el Contacto_Telefonico.
		ContactoTelefonicoPoliza contactoTelefonicoRecuperado = listaDeContactosDeLaPoliza.get(indice - 1);
		Contact contactoEliminar = contactoTelefonicoRecuperado.contacto;
		if(!validaEliminarContacto(indice)) {
			if(!String.isEmpty(contactoEliminar.Id)) {
				delete contactoEliminar;
			}
			listaDeContactosDeLaPoliza.remove(indice-1);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error, debe existir al menos un cliente Asegurado'));
		}
	}

	public Boolean validaEliminarContacto(Integer indice) {
		Boolean erroresAlEliminar=false;
		Integer contadorClientesAsegurados=0;
		for(ContactoTelefonicoPoliza contactos:listaDeContactosDeLaPoliza) {
			if(contactos.contactoTelefonico.CTF_SEL_Tipo_Relacion__c == 'Asegurado') {
				contadorClientesAsegurados++;
			}
		}
		System.debug(contadorClientesAsegurados);
		if(contadorClientesAsegurados == 1 && listaDeContactosDeLaPoliza.get(indice-1).contactoTelefonico.CTF_SEL_Tipo_Relacion__c == 'Asegurado') {
			erroresAlEliminar = true;
		}
		return erroresAlEliminar;
	}

	public void nuevoContacto() {
		esActualizacion=false;
		permitirCrearContacto=true; 
	}

	public void cancelarContacto() {
		esActualizacion=false;
		permitirCrearContacto=false;
	}

	public void seleccionarResultado() {
		Integer indice=Integer.valueOf(Apexpages.currentPage().getParameters().get('indiceResultado'));
		ContactoTelefonicoPoliza contactoRecuperado=listaDeContactosDeLaPoliza.get(indice);
		contactoTelefonicoPoliza.contacto=contactoRecuperado.contacto;
		contactoTelefonicoPoliza.contactoTelefonico=contactoRecuperado.contactoTelefonico;
		esActualizacion=true;
		permitirCrearContacto=true;
	}

	public PageReference volverBusquedaPoliza() {
		
		String idParaVueltaPage ;
		//String VDN = compania.CUE_LKP_VDN_principal__r.VDN_TXT_Identificador__c;
		
		PageReference paginaDestino=Page.BusquedaClientesPoliza;

		if(!String.isEmpty(codigoVDN)) {
			paginaDestino.getParameters().put('VDN',codigoVDN);
		} else 	if(!String.isEmpty(caso.Id)){
			paginaDestino.getParameters().put('caseId',caso.Id);
		} else if(!String.isEmpty(compania.Id)) {
			paginaDestino.getParameters().put('idCompania',compania.Id);
		}
			
		if(!String.isEmpty(identificador)) {
			paginaDestino.getParameters().put('identificador',identificador);	
		}
		return paginaDestino;
	}

	public PageReference navegarDetallePoliza() {
		comprobarPolizaTieneContacto();
		PageReference paginaDestino=null;
		guardar();
		System.debug('>>>>carlos MENSAJES ERROR:'+ApexPages.getMessages());
		if(ApexPages.getMessages().isEmpty()) {
			paginaDestino=new PageReference('/' + poliza.Id);
			paginaDestino.setRedirect(true);
		}
		return paginaDestino;
	}

	public PageReference navegarSiniTipoInterlocutor() {
		// [INI] Comprobar si la Versión de Póliza está activa : 10/07/2018 : SMM
		PageReference paginaDestino = null;
		Ayuda__c ayuda = new Ayuda__c();
		if(!versionPoliza.POLV_CAS_Activa__c){
			ayuda = Util_Ayuda.getMapaAyudaByTipo(new Set<String> {Label.AYUDA_POLIZA_BAJA}).values().get(0);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ayuda.AYU_TXT_Descripcion__c));
		}
		else{
			comprobarPolizaTieneContacto();
			guardar();
		}
		// [FIN] Comprobar si la Versión de Póliza está activa
		if(ApexPages.getMessages().isEmpty()){
			paginaDestino = Page.Sini_TipoInterlocutor;
			if(!String.isEmpty(caso.Id)) {
				paginaDestino.getParameters().put('id',caso.Id);
			}
			paginaDestino.getParameters().put('idPoliza',poliza.Id);
			paginaDestino.setRedirect(true);
		}
		return paginaDestino;
	}

	public PageReference navegarB2BGremios() {
		comprobarPolizaTieneContacto();
		PageReference paginaDestino=null;
		guardar();
		if(ApexPages.getMessages().isEmpty())
		{
			paginaDestino=Page.B2B_Gremios;
			if(!String.isEmpty(caso.Id)) {
				paginaDestino.getParameters().put('id',caso.Id);
			}
			paginaDestino.getParameters().put('idPoliza',poliza.Id);
			paginaDestino.setRedirect(true);
		}
		return paginaDestino;
	}

	public void guardar() {
		SavePoint puntoGuardado= Database.setSavepoint();

		//Validaciones. TODO
		if(!validacionesGuardar()) {
			try {
				//Guardo el cliente, si existe, se le ha pasado el id en el constructor.
				cliente.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTE_ASEGURADO);
				cliente.CUE_LKP_Cuenta_principal__c=compania.Id;
				upsert cliente;
				//Actualizo la póliza, con el AccounId del cliente y la población.
				poliza.AccountId = cliente.Id;
				upsert poliza;
				versionPoliza.POLV_TXT_Poblacion__c = Util_TerritorioServicio.obtenerPoblacionSel(poblacion);
				upsert versionPoliza;
				//Actualizo los contactos de la póliza.
				List<Contact> contactosUpsert = new List<Contact>();
				for(ContactoTelefonicoPoliza ctPoliza : listaDeContactosDeLaPoliza) {
					ctPoliza.contacto.AccountId = cliente.Id;
					contactosUpsert.add(ctPoliza.contacto);
				}
				upsert contactosUpsert;
				//Actualizo los contactos telefónicos de la póliza.
				List<Contacto_telefonico__c> contactosTUpsert = new List<Contacto_telefonico__c>();
				for(ContactoTelefonicoPoliza ctPoliza : listaDeContactosDeLaPoliza) {
					ctPoliza.contactoTelefonico.CTF_LKP_Poliza_Contrato__c = poliza.Id;
					ctPoliza.contactoTelefonico.CTF_LKP_Contacto__c = ctPoliza.contacto.Id;
					contactosTUpsert.add(ctPoliza.contactoTelefonico);
				}
				upsert contactosTUpsert;
			} catch (Exception e) {
				Database.rollback(puntoGuardado);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			}
		}
		System.debug('AltaConfirmacionClienteController: guardar: caso.ID: '+caso.Id);
	}
	private boolean validacionesGuardar() {
		Boolean existenErrores=false;
		if(String.isEmpty(cliente.CUE_SEL_Tipo_Documento__c)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Selecciona un tipo de documento.'));
			existenErrores=true;
		} else if(String.isEmpty(versionPoliza.POLV_TXT_Codigo_Postal__c)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Selecciona un código postal'));
			existenErrores=true;
		} else if(String.isEmpty(versionPoliza.POLV_SEL_Tipo_Riesgo__c)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Selecciona un tipo de Riesgo'));
			existenErrores=true; 
		} else if(String.isEmpty(poblacion) && esSegurCaixa) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La población no puede estar vacía.'));
			existenErrores=true; 
		}
		return existenErrores;
	}

	public void cargarUbicacion(){
		if(!String.isEmpty(versionPoliza.POLV_TXT_Codigo_Postal__c)){
			Map<String, Poblacion_CP__c> mapPoblacion=new Map<String, Poblacion_CP__c>([SELECT PCP_LKP_Poblacion__r.POB_SEL_Provincia__c, PCP_LKP_Poblacion__r.Name FROM Poblacion_CP__c WHERE PCP_LKP_TerritorioServicio__r.TDS_TXT_Identificador__c = :versionPoliza.POLV_TXT_Codigo_Postal__c]);
			System.debug(mapPoblacion);
			if(!mapPoblacion.isEmpty()){
				for(Poblacion_CP__c poblacionAux:mapPoblacion.values()){
					listaPoblacionesCliente=new List<SelectOption>();
					versionPoliza.POLV_SEL_Estado_Provincia__c=poblacionAux.PCP_LKP_Poblacion__r.POB_SEL_Provincia__c;
					listaPoblacionesCliente.add(new SelectOption(versionPoliza.POLV_SEL_Estado_Provincia__c + '#' + poblacionAux.PCP_LKP_Poblacion__r.Name, poblacionAux.PCP_LKP_Poblacion__r.Name));
				}
			}
			else {
				versionPoliza.POLV_SEL_Estado_Provincia__c='';
				listaPoblacionesCliente=Util_Poblacion.inicializarListaPoblaciones();
			}
		}
		else {
			versionPoliza.POLV_SEL_Estado_Provincia__c='';
			listaPoblacionesCliente=Util_Poblacion.inicializarListaPoblaciones();
		}
	} 

	public void comprobarPolizaTieneContacto(){
		if(listaDeContactosDeLaPoliza.isEmpty()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error, debe existir al menos un contacto vinculado a la póliza'));
	}

}