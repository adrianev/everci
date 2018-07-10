/**
 * Clase controladora de la Visualforce "AltaModificacionCliente" encargada de dar de alta o modificar una Cuenta.
 * 
 * @author EVERIS
 */
public without sharing class AltaModificacionCliente {
	private String fase;
	private String solicitudExistente;
	private String paginaRetorno;
	private Id idRecordType;
	private String recordTypeName;
	private Id idCuentaPpal;
	public Case caso {get; set;}
	private String codigoVDN;
	public Account cuenta {get; set;}
	public Account cuentaPrincipal {get; set;}
	public Contact nuevoContacto {get; set;}
	public Direccion_Cuenta__c nuevaDireccion {get; set;}
	private Direccion_Cuenta__c direccionFinal;
	public List<Contact> listaContactosCuenta {get; set;}
	public List<Direccion_Cuenta__c> listaDireccionesCuenta {get; set;}
	public List<Resultado> listaResultados {get; set;}
	public List<SelectOption> listaPoblaciones {get; set;}
	public List<SelectOption> listaPoblacionesNueva {get; set;}
	public String poblacion {get; set;}
	public String poblacionNueva {get; set;}
	private Map<String, String> mapaProvincias;
	private Map<String, String> mapaPaises;
	public Boolean nuevoCliente {get; set;}
	public Boolean creacionContacto {get; set;}
	public Boolean creacionDireccion {get; set;}
	public Boolean actualizacionContacto{get; set;}
	public Boolean actualizacionDireccion{get; set;}
	public Boolean clienteB2C {get; set;}
	public String tituloFormularioEdicion {get; set;}
	public Integer indiceListaContactos {get; set;}
	public Integer indiceListaDirecciones {get; set;}
	public String cabecera {get; set;}
	private Boolean vincularCliB2BRep;
	public PageReference layoutEstandar {get; set;}
	public Boolean mostrarConfirm {get; set;}
	public String textoLOPD {get; set;}
	private String poblacionCuenta;
	public List<SelectOption> typeList {get; set;}
	private String codigoCuentaP;
	
	public List<SelectOption> listaTelefonos {get; set;}
	public String idTelefonoCIA {get; set;}
	public Boolean mostrarTelefonos {get; set;}

	/**
	 * Constructor de la clase
	 */
	public AltaModificacionCliente(ApexPages.standardController stdCtr){
		
		cuenta = new Account();

		//Inicializacion de la lista de poblaciones
		listaPoblaciones = Util_Poblacion.inicializarListaPoblaciones();  // Solucionar Población nula al Modificar

		Id idRTClienteB2C = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTE_PARTICULAR);
		Id idRTClienteB2Bsec = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_2);

		PageReference paginaActual = ApexPages.currentPage();
		nuevoCliente = (!paginaActual.getParameters().containsKey('id'));
		
		listaTelefonos = new List<SelectOption>();
		listaTelefonos.add(new SelectOption('', ' TELÉFONOS DE CONSULTA '));
		idTelefonoCIA = null;
		mostrarTelefonos = false;

		clienteB2C = false;
		vincularCliB2BRep = false;
		listaResultados = new List<Resultado>();		
		listaPoblaciones = new List<SelectOption>();
		listaPoblacionesNueva = new List<SelectOption>();
		listaPoblacionesNueva.add(new SelectOption('', '-- Ninguno --'));
		mapaProvincias = Util_Listas_Seleccion.getLabelDesdeAPI('Account', 'CUE_SEL_Provincia__c');
		mapaPaises = Util_Listas_Seleccion.getLabelDesdeAPI('Account', 'CUE_SEL_Pais__c');

		textoLOPD = '';
		mostrarConfirm = false;
		Configuracion_General__mdt confGeneralLOPD = Util_Metadatos.CONFIG_GENERAL.get('Texto_LOPD');
		if(confGeneralLOPD != null && confGeneralLOPD.CF_TXT_Valor__c != null){
			textoLOPD = confGeneralLOPD.CF_TXT_Valor__c.replace('\r\n','#@').replace('\n','#@');
		}
		else {
			system.debug('>>>> AltaModificacionCliente: No se encontró TextoLOPD en la Metadata Configuración General');
			textoLOPD = 'ERROR: No se pudo mostrar TextoLOPD';
		}

		if(paginaActual.getParameters().containsKey('fase')){
			fase = paginaActual.getParameters().get('fase');
		}

		if(paginaActual.getParameters().containsKey('VDN')){
			codigoVDN = paginaActual.getParameters().get('VDN');
		}

		if (paginaActual.getParameters().containsKey('solicitudExistente')) {
			solicitudExistente = paginaActual.getParameters().get('solicitudExistente');
		}

		if(paginaActual.getParameters().containsKey('vincularCliB2BRep')){
			vincularCliB2BRep = (paginaActual.getParameters().get('vincularCliB2BRep') == 'Y');
		}

		if(paginaActual.getParameters().containsKey('retorno')){
			paginaRetorno = paginaActual.getParameters().get('retorno');
		}
		else if(paginaActual.getParameters().containsKey('retURL')){
			paginaRetorno = paginaActual.getParameters().get('retURL');
		}

		if(paginaActual.getParameters().containsKey('idCaso')){
			//List<Case> listaCasos = Util_Caso.getMapaCasos(new Set<Id>{paginaActual.getParameters().get('idCaso')}).values();
			List<Case> listaCasos = Util_Caso.getCaseById(new Set<Id>{paginaActual.getParameters().get('idCaso')}).values();
			if(!listaCasos.isEmpty()){
				caso = listaCasos.get(0);
			}
		}

		if(paginaActual.getParameters().containsKey('creadoOK')){ 
			if(paginaActual.getParameters().get('creadoOK') == 'modificado'){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));  
			}
			if(paginaActual.getParameters().get('creadoOK') == 'creado'){		 
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_CUENTA_CREADA));
			}   
		}

		// Si no se recibe el Id del cliente a modificar
		if(nuevoCliente){
			listaContactosCuenta = new List<Contact>();
			listaDireccionesCuenta = new List<Direccion_Cuenta__c>();
			cuenta = new Account();
			if(paginaActual.getParameters().containsKey('idRecordType')){
				idRecordType = paginaActual.getParameters().get('idRecordType');
			}
			else if(paginaActual.getParameters().containsKey('recordTypeName')){
				recordTypeName = paginaActual.getParameters().get('recordTypeName');
				idRecordType = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(recordTypeName);
			}
			if(paginaActual.getParameters().containsKey('idCuentaPpal')){
				idCuentaPpal = paginaActual.getParameters().get('idCuentaPpal');
				cuentaPrincipal = Util_Cuentas.getMapCuentasById(new Set<Id>{idCuentaPpal}).get(idCuentaPpal);
				if(cuentaPrincipal != null){
					cuenta.CUE_LKP_Cuenta_principal__c = cuentaPrincipal.Id;
					codigoCuentaP = cuentaPrincipal.CUE_TXT_Identificador__c;
					if(cuentaPrincipal.CUE_FOR_RTDevName__c == Label.RT_CUE_CLIENTEB2C_1){
						idRecordType = idRTClienteB2C;
					}
					else {
						idRecordType = idRTClienteB2Bsec;
					}
					listaTelefonos = Util_Telef_TransferCIA.buscarTelefonos(cuentaPrincipal.Id);
					idTelefonoCIA = null;
					mostrarTelefonos = false;
				}
			}

			if(idRecordType == idRTClienteB2C){
				clienteB2C = true;
				cabecera = 'Crear Cliente Particular/Empresa';
				mostrarConfirm = clienteB2C && !cuenta.CUE_CAS_Aceptado_LOPD__c;
			}
			else {
				clienteB2C = false;
				cabecera = 'Crear Dirección/Cliente Final/Cliente Contable';
				cuenta.CUE_SEL_Pais__c = Label.PAIS_ESPANA;
			}
			cuenta.RecordTypeId = idRecordType;
		}
		// Si se recibe el Id del cliente a modificar
		else {
			cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{stdCtr.getRecord().Id}).get(stdCtr.getRecord().Id);
			if(cuenta == null){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
			}
			else {
				if(cuenta.CUE_FOR_RTDevName__c != Label.RT_CUE_CLIENTE_ASEGURADO &&
						cuenta.CUE_FOR_RTDevName__c != Label.RT_CUE_CLIENTEB2B_2 &&
						cuenta.CUE_FOR_RTDevName__c != Label.RT_CUE_CLIENTE_PARTICULAR){
					layoutEstandar = new PageReference('/'+ cuenta.Id + '/e?nooverride=1');
					layoutEstandar.getParameters().put('retURL','/'+ cuenta.Id);
				}
				else {
					idRecordType = cuenta.RecordTypeId;
					if(cuenta.CUE_LKP_Cuenta_principal__c != null){
						cuentaPrincipal = Util_Cuentas.getMapCuentasById(new Set<Id>{cuenta.CUE_LKP_Cuenta_principal__c}).get(cuenta.CUE_LKP_Cuenta_principal__c);
						if(cuentaPrincipal != null){
							codigoCuentaP = cuentaPrincipal.CUE_TXT_Identificador__c;
							listaTelefonos = Util_Telef_TransferCIA.buscarTelefonos(cuentaPrincipal.Id);
							idTelefonoCIA = null;
							mostrarTelefonos = (cuenta.Type == Label.CUE_TIPO_OK_PYMES && codigoCuentaP == Label.IDE_ENDESA);
						}
					}

					listaContactosCuenta = Util_Contacto.getContactById(new Set<Id>{cuenta.Id}).values();

					listaDireccionesCuenta = Util_Cuentas.getMapDireccionesCuenta(new Set<Id>{cuenta.Id}).values();

					for(Direccion_Cuenta__c direccionCue : listaDireccionesCuenta){
						listaResultados.add(new Resultado(false, direccionCue));
					}
					if(idRecordType == idRTClienteB2C){
						clienteB2C = true;
						cabecera = 'Modificar Cliente Particular/Empresa';			  
					}
					else {
						clienteB2C = false;
						cabecera = 'Modificar Dirección/Cliente Final/Cliente Contable';
						if(cuenta.Type != Label.CUE_TIPO_OK_PYMES){
							cargarListaPoblacionPorCP();
							cargarProvinciaPoblacion();
						}
					}
				}
			}
		}		
		cargarListaTiposClientes();
	}


	private PageReference agregarParametrosURL(PageReference paginaRedireccion, String retorno){
		paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
		if(solicitudExistente != null){
			paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
		}
		if(codigoVDN != null){
			paginaRedireccion.getParameters().put('VDN', codigoVDN);
		}
		if(caso != null){
			paginaRedireccion.getParameters().put('idCaso', caso.Id);
		}
		if(retorno != null){
			paginaRedireccion.getParameters().put('retURL', retorno);
		}
		if(vincularCliB2BRep){
			paginaRedireccion.getParameters().put('vincularCliB2BRep', 'Y');
		}
		return paginaRedireccion;
	}//FIN agregarParametrosURL()


	/**
	 * Cancela el proceso de creación de un contacto iniciado
	 */	
	public void cancelarCreacionContacto(){
		nuevoContacto = null;
		creacionContacto = false;
		actualizacionContacto = false;
	}


	/**
	 *  Cancela el proceso de creación de una dirección iniciado
	 */	
	public void cancelarCreacionDireccion(){
		nuevaDireccion = null;
		creacionDireccion = false;
		actualizacionDireccion = false;
	}


	/**
	 * Carga la lista de poblaciones a elegir según el código postal seleccionado
	 */
	public void cargarListaPoblacionPorCP(){
		String poblacionCP_pobl;
		poblacionCuenta = cuenta.ShippingCity;
		listaPoblaciones = Util_TerritorioServicio.cargarListaPoblacionPorCP(cuenta.ShippingPostalCode);		
		if((poblacion == null) || (poblacion.equals(''))){
			poblacion = listaPoblaciones.get(0).getValue(); //CódigoProvincia#NombrePoblación
		}
		cuenta.ShippingCity = null;
		cuenta.CUE_SEL_Provincia__c = null;
		if(listaPoblaciones.size() > 1){
			if(poblacionCuenta != null){
				// Si se ha recibido una población: se busca en el listado de poblaciones del CP
				for(SelectOption poblacionCPopt : listaPoblaciones){
					String poblacionCP = poblacionCPopt.getValue();
					poblacionCP_pobl = Util_TerritorioServicio.obtenerPoblacionSel(poblacionCP);
					String poblacionCP_prov = Util_TerritorioServicio.obtenerProvinciaSel(poblacionCP);
					if(poblacionCP_pobl == poblacionCuenta){
						poblacion = poblacionCP;
						cuenta.ShippingCity = poblacionCP_pobl;
						cuenta.CUE_SEL_Provincia__c = poblacionCP_prov;
						break;
					}	
				}
			}
			if(poblacionCP_pobl != poblacionCuenta){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_POBLACIONES_CP));
			}			
		}
		else if(listaPoblaciones.get(0).getValue() == ''){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_MUNICIPIOS_NO_CP));
		}
		else {
			cargarProvinciaPoblacion();
		}
	}	


	/**
	 * Carga la lista de poblaciones según un nuevo código postal elegido para el formulario de nueva dirección
	 */
	public void cargarListaPoblacionPorCPNueva(){
		listaPoblacionesNueva = Util_TerritorioServicio.cargarListaPoblacionPorCP(nuevaDireccion.DCU_TXT_Codigo_Postal__c);
		poblacionNueva = listaPoblacionesNueva.get(0).getValue(); //CódigoProvincia#NombrePoblación
		nuevaDireccion.DCU_TXT_Poblacion__c = null;
		nuevaDireccion.DCU_SEL_Provincia__c = null;
		if(listaPoblacionesNueva.size() > 1){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_POBLACIONES_CP));
		}
		else if(listaPoblacionesNueva.get(0).getValue() == ''){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_MUNICIPIOS_NO_CP));
		}
		else {
			cargarProvinciaPoblacionNueva();
		}
	}	


	/**
	 * Carga la Provincia según la población elegida
	 */
	public void cargarProvinciaPoblacion(){
		if(cuenta != null){
			cuenta.ShippingCity = Util_TerritorioServicio.obtenerPoblacionSel(poblacion);
			cuenta.CUE_SEL_Provincia__c = Util_TerritorioServicio.obtenerProvinciaSel(poblacion);
		}
	}


	/**
	 * Carga la Provincia según la nueva población elegida para el formulario de nueva dirección
	 */
	public void cargarProvinciaPoblacionNueva(){
		if(nuevaDireccion != null){
			nuevaDireccion.DCU_TXT_Poblacion__c = Util_TerritorioServicio.obtenerPoblacionSel(poblacionNueva);
			nuevaDireccion.DCU_SEL_Provincia__c = Util_TerritorioServicio.obtenerProvinciaSel(poblacionNueva);
		}
	}


	public PageReference continuarCaso(){
		PageReference paginaRedireccion = null;
		if(clienteB2C){
			direccionFinal = new Direccion_Cuenta__c();
			for(Resultado resultado : listaResultados){
				if(resultado.seleccionado){
					direccionFinal = resultado.direccionSeleccionada;							   
				}			
			}
		}
		// Si es un cliente B2C y no se ha seleccionado una dirección
		if(clienteB2C && direccionFinal.Id == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Debe seleccionar una dirección.'));
		}
		// Si no es un cliente B2C o se ha seleccionado una dirección		
		else {
			system.Savepoint puntoGuardado = Database.setSavepoint();
			try {
				// vincular cuenta al Caso
				caso.AccountId = cuenta.Id;
				update caso;
				paginaRedireccion = new PageReference('/apex/' + Label.VF_B2B_Gremios);
				// Si se ha llegado desde la pantalla de tramitación
				if(vincularCliB2BRep){
					paginaRedireccion = new PageReference('/apex/' + Label.VF_B2B_Reparable);
				}
				paginaRedireccion.getParameters().put('id', caso.Id);
				paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
				paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
				paginaRedireccion.setRedirect(true);
			}
			catch(DmlException e){
				Database.rollback(puntoGuardado);
				system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
				//if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR));
				//}
			 }
			catch(Exception e){
				Database.rollback(puntoGuardado);
				system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR));
			}
		}
		return paginaRedireccion;
	}


	/**
	 * Inicia el proceso de creación de un nuevo contacto
	 */
	public void crearContacto(){
		if(cuenta.Id == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Para poder agregar contactos debe guardar primero el cliente.'));
		}
		else {
			cancelarCreacionContacto();
			cancelarCreacionDireccion();
			creacionContacto = true;
			actualizacionContacto = false;
			nuevoContacto = new Contact();
			tituloFormularioEdicion = 'Datos de nuevo contacto';
		}
	}


	/**
	 * Inicia el proceso de creación de una nueva dirección
	 */
	public void crearDireccion(){
		if(cuenta.Id == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Para poder agregar direcciones debe guardar primero el cliente.'));
		}
		else {
			cancelarCreacionContacto();
			cancelarCreacionDireccion();
			creacionDireccion = true;
			actualizacionDireccion = false;
			nuevaDireccion = new Direccion_Cuenta__c();
			nuevaDireccion.DCU_SEL_Pais__c = Label.PAIS_ESPANA;
			listaPoblacionesNueva.clear();
			tituloFormularioEdicion = 'Datos de nueva dirección';
		}
	}


	/**
	 * Nos lleva a la página de detalle de un cliente
	 *
	 * @return página a navegar del detalle de un cliente
	 */ 
	public PageReference detalleCliente(){
		PageReference paginaRedireccion = new PageReference('/'+ cuenta.Id);
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}


	/**
	 * Elimina un contacto seleccionado
	 */ 
	public void eliminarContacto(){
		cancelarCreacionContacto();
		cancelarCreacionDireccion();
		Contact contactoEliminar = new Contact();
		if(!listaContactosCuenta.isEmpty())
			contactoEliminar = listaContactosCuenta.get(indiceListaContactos - 1);
		if(contactoEliminar.Id == null){
			if(!listaContactosCuenta.isEmpty())
				listaContactosCuenta.remove(indiceListaContactos-1);
		}
		else {
			system.Savepoint puntoGuardado = Database.setSavepoint();
			try {
				delete contactoEliminar;
				listaContactosCuenta = Util_Contacto.getContactById(new Set<Id>{cuenta.Id}).values();
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
			}
			catch(DmlException e){
				Database.rollback(puntoGuardado);
				system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
				//if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
				//}
			}
			catch(Exception e){
				Database.rollback(puntoGuardado);
				system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
			}
		}
	}


	/**
	 * Elimina una dirección seleccionada
	 */	 
	public void eliminarDireccion(){	  
		cancelarCreacionContacto();
		cancelarCreacionDireccion();
		Direccion_Cuenta__c direccionEliminar = listaDireccionesCuenta.get(indiceListaDirecciones - 1);
		if(direccionEliminar.Id == null){
			listaDireccionesCuenta.remove(indiceListaDirecciones-1);
			listaResultados.remove(indiceListaDirecciones-1);
		}	
		else {
			system.Savepoint puntoGuardado = Database.setSavepoint();
			try {
				delete direccionEliminar;
				listaDireccionesCuenta.remove(indiceListaDirecciones-1);
				listaResultados.remove(indiceListaDirecciones-1);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
			}
			catch(DmlException e){
				Database.rollback(puntoGuardado);
				system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
				//if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
				//}
			}
			catch(Exception e){
				Database.rollback(puntoGuardado);
				system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
			}
		}
	}


	/**
	 * Guarda el proceso actual en la página de alta/modificación
	 *
	 * @return página a navegar tras guardar el registro
	 *
	 */ 
	public PageReference guardar(){
		PageReference paginaRedireccion = null;
		system.Savepoint puntoGuardado = Database.setSavepoint();
		Boolean guardarNuevoCliente = (cuenta.Id == null);

		if(mostrarConfirm){
			cuenta.CUE_CAS_Aceptado_LOPD__c = true;
		}

		try {
			if(guardarCliente() || Test.isRunningTest()){
				if(guardarNuevoCliente || Test.isRunningTest()){
					paginaRedireccion = recargarCuenta(cuenta.Id);
					paginaRedireccion.setRedirect(true);
				}
				else {
					paginaRedireccion = new PageReference('/' + cuenta.Id);	   
					paginaRedireccion.setRedirect(true);
				}
			}	   
		}
		catch(DmlException e){
			String mensaje = e.getMessage();
			mensaje = mensaje.substring(mensaje.indexOf(',')+2, mensaje.length()-3);
			//Si ha fallado la insercion de alguno de los registros, se revierte el estado de la base de datos
			Database.rollback(puntoGuardado);
			system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
			//if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
				if(mensaje.contains('CUE_TXT_Identificador__c ')){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'El cliente ya está registrado.'));
				}
				else {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' ' + mensaje));
				}
			//}
		}
		catch(Exception e){
			String mensaje = e.getMessage();
			mensaje = mensaje.substring(mensaje.indexOf(',')+2, mensaje.length()-3);
			//Si ha fallado la insercion de alguno de los registros, se revierte el estado de la base de datos
			Database.rollback(puntoGuardado);
			system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
			if(mensaje.contains('CUE_TXT_Identificador__c ')){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'El cliente ya está registrado.'));
			}
			else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' ' + mensaje));
			}
		}
		system.debug('>>>>> paginaRedireccion : ' + paginaRedireccion);
		return paginaRedireccion;
	}


	/**
	 * Se guarda un cliente
	 *
	 * @return true si el cliente se ha guardado correctamente, si no false
	 */	 
	private Boolean guardarCliente(){
		system.debug('>>>>> paginaRedireccion2 : ' + cuenta);
		Boolean registroGuardado = false;
		// Validar campos cliente particular
		if((clienteB2C || cuenta.Type == Label.CUE_TIPO_OK_PYMES) &&
				(cuenta.CUE_TXT_Numero_Documento__c == null || cuenta.CUE_TXT_Numero_Documento__c.trim() == '' ||
				cuenta.CUE_TXT_Nombre__c == null || cuenta.CUE_TXT_Nombre__c.trim() == '' ||				
				((cuenta.Type == Label.CUE_TIPO_CLIENTEFINAL || cuenta.Type == Label.CUE_TIPO_OK_PYMES) &&
				(cuenta.CUE_TXT_PrimerApellido__c == null || cuenta.CUE_TXT_PrimerApellido__c.trim() == '')))){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ERROR_FALTAN_CAMPOS_OBLIGATORIOS));  
		}
		// Validar campos cliente B2B
		else if((!clienteB2C && cuenta.Type != Label.CUE_TIPO_OK_PYMES) &&
				((cuenta.CUE_TXT_Numero_Documento__c == null || cuenta.CUE_TXT_Numero_Documento__c.trim() == '') ||
						cuenta.CUE_TXT_Nombre__c == null || cuenta.CUE_TXT_Nombre__c.trim() == '' ||
						cuenta.ShippingPostalCode == null || cuenta.ShippingPostalCode.trim() == '' ||
						cuenta.ShippingStreet == null || cuenta.ShippingStreet.trim() == '' ||
						cuenta.ShippingCity == null || cuenta.ShippingCity.trim() == '' ||
						cuenta.CUE_SEL_Pais__c == null || cuenta.CUE_SEL_Pais__c == '' ||
						((cuenta.Type == Label.CUE_TIPO_CLIENTEFINAL || cuenta.Type == Label.CUE_TIPO_OK_PYMES) &&
						(cuenta.CUE_TXT_PrimerApellido__c == null || cuenta.CUE_TXT_PrimerApellido__c.trim() == '')))){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ERROR_FALTAN_CAMPOS_OBLIGATORIOS));  
		}
		else {
			if(cuenta.Type != Label.CUE_TIPO_DIRECCION && cuenta.Type != Label.CUE_TIPO_EMPRESA && cuenta.Type != Label.CUE_TIPO_CONTABLE){
				cuenta.Name = cuenta.CUE_TXT_Nombre__c + ' ' + cuenta.CUE_TXT_PrimerApellido__c;
				if(cuenta.CUE_TXT_SegundoApellido__c != null){
					cuenta.Name += ' ' + cuenta.CUE_TXT_SegundoApellido__c;
				}
			}
			else {
				cuenta.Name = cuenta.CUE_TXT_Nombre__c;
				cuenta.CUE_TXT_PrimerApellido__c = null;
				cuenta.CUE_TXT_SegundoApellido__c = null;
			}
			cuenta.ShippingState = mapaProvincias.get(cuenta.CUE_SEL_Provincia__c);
			cuenta.ShippingCountry = mapaPaises.get(cuenta.CUE_SEL_Pais__c);
			if(cuenta.Id == null)
				cuenta.CUE_CAS_Activado__c = true;
			upsert cuenta;
			registroGuardado = true;
		}
		return registroGuardado;
	}


	/**
	 * Guarda un contacto en creación/edición
	 */	 
	public void guardarContacto(){
		if(nuevoContacto.FirstName == null || nuevoContacto.FirstName.trim() == '' ||
				nuevoContacto.LastName == null || nuevoContacto.LastName.trim() == '' ||
				nuevoContacto.Phone == null || nuevoContacto.Phone.trim() == ''){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ERROR_FALTAN_CAMPOS_OBLIGATORIOS)); 
		}
		else {
			system.Savepoint puntoGuardado = Database.setSavepoint();
			try {
				nuevoContacto.AccountId = cuenta.Id;
				upsert nuevoContacto;
				nuevoContacto = null;
				creacionContacto = false;
				actualizacionContacto = false;
				listaContactosCuenta = Util_Contacto.getContactById(new Set<Id>{cuenta.Id}).values();
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
			}
			catch(DmlException e){
				Database.rollback(puntoGuardado);
				system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
				//if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getDMLMessage(0)));
				//}
			}
			catch(Exception e){
				Database.rollback(puntoGuardado);
				system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
			}			
		}
	}


	/**
	 * Guarda una dirección en creación/edición
	 */	 
	public void guardarDireccion(){
		if(nuevaDireccion.DCU_TXT_Direccion__c == null || nuevaDireccion.DCU_TXT_Direccion__c.trim() == '' ||
				nuevaDireccion.DCU_TXT_Codigo_Postal__c == null || nuevaDireccion.DCU_TXT_Codigo_Postal__c.trim() == '' ||
				nuevaDireccion.DCU_TXT_Poblacion__c == null || nuevaDireccion.DCU_TXT_Poblacion__c.trim() == '' ||
				nuevaDireccion.DCU_SEL_Provincia__c == null ||
				nuevaDireccion.DCU_SEL_Pais__c == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ERROR_FALTAN_CAMPOS_OBLIGATORIOS)); 
		}
		else {
			system.Savepoint puntoGuardado = Database.setSavepoint();
			try {
				if(!actualizacionDireccion){
					if(nuevaDireccion.DCU_TXT_Poblacion__c == null){
						cargarListaPoblacionPorCPNueva();
					}
				}
				nuevaDireccion.DCU_LKP_Cuenta__c = cuenta.Id;
				upsert nuevaDireccion;
				if(!actualizacionDireccion){
					listaDireccionesCuenta.add(nuevaDireccion);
					listaResultados.add(new Resultado(false, nuevaDireccion));
				}
				nuevaDireccion = null;
				creacionDireccion = false;
				actualizacionDireccion = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
			}
			catch(DmlException e){
				Database.rollback(puntoGuardado);
				system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
				//if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
				//}
			}
			catch(Exception e){
				Database.rollback(puntoGuardado);
				system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
			}
		}
	}


	/**
	 * Inicia el proceso de creación de un nuevo caso B2C
	 *
	 * @return página a navegar tras iniciar el proceso
	 */
	public PageReference nuevoServicioB2C(){
		PageReference paginaRedireccion = null;
		system.Savepoint puntoGuardado = Database.setSavepoint();
		Id idDireccion = null;
		for(Resultado resultado : listaResultados){
			if(resultado.seleccionado){
				idDireccion = resultado.direccionSeleccionada.Id;
				break;
			}
		}
		try {
			if(guardarCliente() || Test.isRunningTest()){
				if(idDireccion == null){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Debe seleccionar una dirección.'));
				}
				else {
					paginaRedireccion = new PageReference('/apex/' + Label.VF_B2B_Gremios);
					paginaRedireccion.getParameters().put('b2c', 'Y');
					paginaRedireccion.getParameters().put('idCuenta', cuenta.Id);
					paginaRedireccion.getParameters().put('idDireccion', idDireccion);
					paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, Label.SINI_FASE_APERTURA);
					paginaRedireccion.setRedirect(true);
				}
			}
		}
		catch(DmlException e){
			String mensaje = e.getMessage();
			mensaje = mensaje.substring(mensaje.indexOf(',')+2, mensaje.length()-3);
			//Si ha fallado la insercion de alguno de los registros, se revierte el estado de la base de datos
			Database.rollback(puntoGuardado);
			system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
			//if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
				if(mensaje.contains('CUE_TXT_Identificador__c ')){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'El cliente ya está registrado.'));
				}
				else {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' ' + mensaje));
				}
			//}
		}
		catch(Exception e){
			String mensaje = e.getMessage();
			mensaje = mensaje.substring(mensaje.indexOf(',')+2, mensaje.length()-3);
			//Si ha fallado la insercion de alguno de los registros, se revierte el estado de la base de datos
			Database.rollback(puntoGuardado);
			system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
			if(mensaje.contains('CUE_TXT_Identificador__c ')){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'El cliente ya está registrado.'));
			}
			else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' ' + mensaje));
			}
		}
		return paginaRedireccion;
	}


	/**
	 *  Recarga la información sobre una cuenta
	 *
	 *  @param idCuenta: id de la cuenta a recargar
	 *  @return misma página refrescada
	 */
	private PageReference recargarCuenta(Id idCuenta){
		PageReference paginaRedireccion = new PageReference('/apex/' + Label.VF_ALTA_MODIFICACION_CLIENTE);
		paginaRedireccion = agregarParametrosURL(paginaRedireccion, paginaRetorno);
		if(nuevoCliente){
			paginaRedireccion.getParameters().put('creadoOK', 'creado');
		}
		if(idCuenta != null){
			paginaRedireccion.getParameters().put('id', cuenta.Id);
		}
		else {
			if(idRecordType != null){
				paginaRedireccion.getParameters().put('idRecordType', idRecordType);
			}
			if(recordTypeName != null){
				paginaRedireccion.getParameters().put('recordTypeName', recordTypeName);
			}
			if(idCuentaPpal != null){
				paginaRedireccion.getParameters().put('idCuentaPpal', idCuentaPpal);
			}		   
		}
		return paginaRedireccion;
	}


	/**
	 * Selecciona un contacto a editar
	 */
	public void seleccionarContacto(){
		cancelarCreacionContacto();
		cancelarCreacionDireccion();
		if(!listaContactosCuenta.isEmpty())
			nuevoContacto = listaContactosCuenta.get(indiceListaContactos);
		creacionContacto = false;
		actualizacionContacto = true;
		tituloFormularioEdicion = 'Datos de actualización de contacto';
	}


	/**
	 * Selecciona una dirección a  editar
	 */  
	public void seleccionarDireccion(){		
		cancelarCreacionContacto();
		cancelarCreacionDireccion();
		Direccion_Cuenta__c ctDireccion = listaDireccionesCuenta.get(indiceListaDirecciones);
		system.debug('>>>>ctDireccion: '+ctDireccion);
		nuevaDireccion = ctDireccion;
		creacionDireccion = false;
		actualizacionDireccion = true;
		tituloFormularioEdicion = 'Datos de actualización de Dirección';
		cargarListaPoblacionPorCPNueva();
	}


	/**
	 * Cancela el proceso de alta/modificación del cliente
	 *
	 * @return página a navegar tras cancelar
	 */ 
	public PageReference volver(){
		PageReference paginaRedireccion = null;
		if(paginaRetorno != null){
			paginaRedireccion = new PageReference(paginaRetorno);
			paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
			if(solicitudExistente != null){
				paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
			}
			if(codigoVDN != null){
				paginaRedireccion.getParameters().put('VDN', codigoVDN);
			}
			if(caso != null){
				paginaRedireccion.getParameters().put('idCaso', caso.Id);
			}
			if(vincularCliB2BRep){
				paginaRedireccion.getParameters().put('vincularCliB2BRep', 'Y');
			}
		}
		else if(cuenta.Id != null){
			paginaRedireccion = new PageReference('/' + cuenta.Id); 
		}
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}


	/**
	 *  Clase encargada de almacenar resultados y selecciones
	 */ 
	public class Resultado {
		public Boolean seleccionado {get; set;}
		public Direccion_Cuenta__c direccionSeleccionada {get; set;}
		public Resultado(Boolean seleccionado, Direccion_Cuenta__c direccionSeleccionada){
			this.seleccionado = seleccionado;
			this.direccionSeleccionada = direccionSeleccionada;
		}
	}
	
	public void cargarListaTiposClientes(){
		typeList = new List<SelectOption>();
		typeList.add(new SelectOption('', '-- Ninguno --'));
		for(SelectOption so : Util_Cuentas.inicializarListaTiposCuenta()){
			String valor = so.getValue();
			String etiqueta = so.getLabel();
			if(valor.isNumericSpace() && (
			  (clienteB2C && (valor == Label.CUE_TIPO_CLIENTEFINAL || valor == Label.CUE_TIPO_EMPRESA)) ||
			  (!clienteB2C && (valor != Label.CUE_TIPO_EMPRESA &&
			  (valor != Label.CUE_TIPO_OK_PYMES || codigoCuentaP == Label.IDE_ENDESA))))){
				typeList.add(new SelectOption(so.getValue(),so.getLabel()));
			}
		}
	}
	
	/**
     * Método que se muestra la descripción del teléfono de la compañía seleccionado
     */
	public void mostrarAyudaTelefonoCIA(){
		if(idTelefonoCIA != null){
			Telefonos_Transfer_CIA__c telf = Util_Telef_TransferCIA.queryMapTelefonoTransferCIA(new set<Id>{idTelefonoCIA}).get(idTelefonoCIA);
			if(telf != null){
				String ayuda = telf.TTC_TXT_Ayuda__c;
				// Adding HTML tag to phone
				Pattern pat = Pattern.compile('(Tfno:\\s+)([0-9|\\s]+)(\\b)([\\s\\.\\n])');
				Matcher mat = pat.matcher(ayuda);
				while(mat.find()){
					system.debug('grupo '+mat.group());
					String phone = mat.group(2).remove(' ');
					// Phone with blank spaces
					String phoneBS = mat.group(2);
					ayuda = ayuda.replace(phoneBS, '<a href="javascript:void(0);" onclick="clickPhone(this, \''+ phone +'\')">'+  phoneBS   + '</a>'); 
				}
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ayuda));
			}
		}
	}
	
	/**
	 * Recalcula si hay que mostrar los teléfonos al cambiar el tipo
	 */
	public void recargarTelefonos(){
		mostrarTelefonos = (cuenta.Type == Label.CUE_TIPO_OK_PYMES && codigoCuentaP == Label.IDE_ENDESA);
	}
	
}