/**
 * Clase controladora de la Visualforce "B2B_BusquedaClientes" encargada de buscar clientes B2B/B2B2C.
 * 
 * @author EVERIS
 */
public without sharing class B2B_BusquedaClientes {
	private String fase;
	private String solicitudExistente;
	public Boolean busquedaServicios {get; set;}
	public Id idCaso {get; set;}
	public String codigoVDN {get; set;}
	public String presentacion {get; set;}
	public String observaciones {get; set;}
	public String valorN_Servicio {get; set;}
	public String valorN_Documento {get; set;}
	public String valorTelefono {get; set;}
	public String valorNombre {get; set;}
	public String valorApellido_1 {get; set;}
	public String valorApellido_2 {get; set;}
	public String valorDomicilio {get; set;}
	public String valorCodigoPostal {get; set;}
	public String valorProvincia {get; set;}
	public String valorPoblacion {get; set;}
	public List<SelectOption> listaProvincias {get; set;}
	public List<SelectOption> listaPoblaciones {get; set;}
	public String poblacion {get; set;}
	public String telefono {get; set;}
	public List<Account> listaClientes {get; set;}
	public List<Account> listaClientesFinal {get; set;}
	public List<Case> listaCasos {get; set;}
	public List<Case> listaCasosFinal {get; set;}
	public Account clienteFiltros {get; set;}
	public List<SelectOption> typeList {get; set;}
	public Integer indiceResultado {get; set;}
	public String nombreCuentaP {get; set;}
	private String codigoCuentaP;
	public Boolean cuentaPpalEsB2C {get; set;}
	private Id idRTServicio;
	private Id idRTSolServicio;
	private Id idRTAsistencia;
	private Id idRTSolAsistencia;
	public Map <Id,List<Direccion_Cuenta__c>> mapaDirecc {get; set;}	
	private Boolean vincularCliB2BRep {get; set;}
	private Integer limiteBusqueda;

	//paginacion
	public Integer recPerPage {get; 
		set{
			recPerPage = Integer.valueOf(value);
		}
	}
	public List<SelectOption> recPerPageOptions {get; set;}
	public Integer page {get;
		set{
			if(value > lastPage){
				page = lastPage;
			}
			else if(value <= 0){
				page = 1;
			}
			else{
				page = Integer.valueOf(value);
			}
		}
	}
	public Integer lastPage {get; set;}

	/**
	 * Constructor de la clase.
	 */
	public B2B_BusquedaClientes(){
		Boolean errorVDN = false;
		//Inicialización de variables
		idRTSolServicio = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2B_B2B2C);
		idRTServicio = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C);
		idRTSolAsistencia = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2C);
		idRTAsistencia = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C);
		cuentaPpalEsB2C = false;
		busquedaServicios = false;
		clienteFiltros = new Account();
		listaPoblaciones = Util_Poblacion.inicializarListaPoblaciones();
		listaProvincias = Util_Poblacion.inicializarListaProvincias();
		vincularCliB2BRep = false;

		//paginacion
		// Predetermined number of results
		recPerPage = 25;
		// Get records per page possible options
		recPerPageOptions = getRPPO();
		// Predetermined number of page
		page = 1;
		
		limiteBusqueda = 999;

		PageReference paginaActual = ApexPages.currentPage();
		if(paginaActual.getParameters().containsKey('fase')){
			fase = paginaActual.getParameters().get('fase');
		}

		if (paginaActual.getParameters().containsKey('solicitudExistente')) {
			solicitudExistente = paginaActual.getParameters().get('solicitudExistente');
		}

		if(paginaActual.getParameters().containsKey('vincularCliB2BRep')){
			vincularCliB2BRep = (paginaActual.getParameters().get('vincularCliB2BRep') == 'Y');
		}

		if(paginaActual.getParameters().containsKey('idCaso')){
			idCaso = (Id) paginaActual.getParameters().get('idCaso');
			system.debug('<<<<idCaso' + idCaso);
			List<Case> listaCasosAux = Util_Caso.getCaseById(new Set<Id>{idCaso}).values();
			//List<Case> listaCasosAux = Util_Caso.getMapaCasos(new Set<Id>{idCaso}).values();
			if(!listaCasosAux.isEmpty()){
				system.debug('<<<<listaCasosAux.get(0).CAS_LKP_Compania__c' + listaCasosAux.get(0).CAS_LKP_Compania__c);
				clienteFiltros.CUE_LKP_Cuenta_principal__c = listaCasosAux.get(0).CAS_LKP_Compania__c;
				nombreCuentaP = listaCasosAux.get(0).CAS_LKP_Compania__r.Name;
				codigoCuentaP = listaCasosAux.get(0).CAS_LKP_Compania__r.CUE_TXT_Identificador__c;
				if(codigoCuentaP == Label.IDE_ENDESA){
					clienteFiltros.Type = Label.CUE_TIPO_CLIENTEFINAL;
				}
				//Sustituye nombre y apellidos por el usuario Logeado y actualiza el saludo segun la hora actual.
				presentacion = Util_Compania.reemplazarTokensPresentacion(listaCasosAux.get(0).CAS_LKP_Compania__r.CUE_TXT_Presentacion__c);
				observaciones = listaCasosAux.get(0).CAS_LKP_Compania__r.CUE_TXT_Ayuda_Busqueda__c;
				cuentaPpalEsB2C = (listaCasosAux.get(0).CAS_LKP_Compania__r.CUE_FOR_RTDevName__c == Label.RT_CUE_CLIENTEB2C_1);
				cargarListaTiposClientes();
				busqueda();			 
			}
		}
		//Recogida de la presentacion de la empresa a partir de la cuenta principal asociada al VDN
		else if(paginaActual.getParameters().containsKey('VDN')){
			codigoVDN = paginaActual.getParameters().get('VDN');
			List<VDN_Compania__c> listaVDNN = Util_CTI.queryMapVDN(new Set<String>{codigoVDN}).values();
			/*List<VDN_Compania__c> listaVDNN = new List<VDN_Compania__c>(
				[SELECT VDN_TXT_Ayuda_Busqueda__c,
						Name,
						VDN_LKP_Compania__c,
						VDN_LKP_Compania__r.Name,
						VDN_LKP_Compania__r.CUE_FOR_RTDevName__c,
						VDN_LKP_Compania__r.CUE_TXT_Identificador__c,
						VDN_TXT_Presentacion__c
				 FROM VDN_Compania__c
				 WHERE Name = :codigoVDN]);*/
			//Vinculado a CIA --> Busqueda de clientes asegurados
			if(!listaVDNN.isEmpty()){
				VDN_Compania__c vdnCIA = listaVDNN.get(0);
				clienteFiltros.CUE_LKP_Cuenta_principal__c = vdnCIA.VDN_LKP_Compania__c;  
				nombreCuentaP = vdnCIA.VDN_LKP_Compania__r.Name;
				codigoCuentaP = vdnCIA.VDN_LKP_Compania__r.CUE_TXT_Identificador__c;
				//Sustituye nombre y apellidos por el usuario Logeado y actualiza el saludo segun la hora actual.
				presentacion = Util_Compania.reemplazarTokensPresentacion(vdnCIA.VDN_TXT_Presentacion__c);
				observaciones = vdnCIA.VDN_TXT_Ayuda_Busqueda__c;
				cuentaPpalEsB2C = (vdnCIA.VDN_LKP_Compania__r.CUE_FOR_RTDevName__c == Label.RT_CUE_CLIENTEB2C_1);
				cargarListaTiposClientes();
				busqueda();
			}
			else {
				errorVDN = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ERROR_VDN));
			}
		}  

		//Si recibo el teléfono por URL, relleno el campo telefono y realizo la busqueda
		if((!errorVDN) && paginaActual.getParameters().containsKey('telefono')){
			valorTelefono = paginaActual.getParameters().get('telefono');
			busqueda();
		}
	}


	private PageReference agregarParametrosURL(PageReference paginaRedireccion, String retorno){
		paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
		if(solicitudExistente != null){
			paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
		}
		if(codigoVDN != null){
			paginaRedireccion.getParameters().put('VDN', codigoVDN);
		}
		if(idCaso != null){
			paginaRedireccion.getParameters().put('idCaso', idCaso);
		}
		if(retorno != null){
			paginaRedireccion.getParameters().put('retURL', retorno);
		}
		return paginaRedireccion;
	}//FIN agregarParametrosURL()


	public void seleccionarCIA(){
		if(clienteFiltros.CUE_LKP_Cuenta_principal__c == null){
			nombreCuentaP = null;
			codigoCuentaP = null;
			presentacion = null;
			observaciones = null;
			cuentaPpalEsB2C = false;		
		}
		else {
			List<Account> listaCuentas = Util_Cuentas.getMapCuentasById(new Set<Id>{clienteFiltros.CUE_LKP_Cuenta_principal__c}).values();
			if(!listaCuentas.isEmpty()){
				nombreCuentaP = listaCuentas.get(0).Name;
				codigoCuentaP = listaCuentas.get(0).CUE_TXT_Identificador__c;
				//Sustituye nombre y apellidos por el usuario Logeado y actualiza el saludo segun la hora actual.
				presentacion = Util_Compania.reemplazarTokensPresentacion(listaCuentas.get(0).CUE_TXT_Presentacion__c);
				observaciones = listaCuentas.get(0).CUE_TXT_Ayuda_Busqueda__c;
				cuentaPpalEsB2C = (listaCuentas.get(0).CUE_FOR_RTDevName__c == Label.RT_CUE_CLIENTEB2C_1);
			}
		}
		if(!busquedaServicios){
			busquedaClientes();
		}
		else {
			busquedaServicios();
		}
	}


	/**
     * Método que se encarga de realizar la búsqueda de cuentas y servicios
     */
	public void busqueda(){
		if(!busquedaServicios && clienteFiltros.CUE_LKP_Cuenta_principal__c == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_CUENTA_PRINCIPAL));
		}
		else {
			String filtroRTCasos = 'RecordTypeId IN (\'' + idRTSolServicio + '\',\'' + idRTServicio + '\',\'' + idRTSolAsistencia + '\',\'' + idRTAsistencia + '\')';
			// A) Búsqueda sobre casos
			if(busquedaServicios){
				if((valorTelefono == null || valorTelefono.trim() == '') &&
				   (valorN_Servicio == null || valorN_Servicio.trim() == '') &&
				   (valorCodigoPostal == null || valorCodigoPostal.trim() == '')){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_BUSQUEDA_FILTRO));
				}
				else {
					String query = 'SELECT CaseNumber, CAS_LKP_Compania__r.Name, CAS_FOR_Tipo_Caso__c, CAS_TFN_Solicitud_Telefono__c,';
					query += ' CAS_TXT_Nombre__c, CAS_TXT_Apellidos__c, Account.Name, Origin, Type FROM Case';
					String filtro = ' WHERE ' + filtroRTCasos;
					if(clienteFiltros.CUE_LKP_Cuenta_principal__c != null){
						filtro += ' AND CAS_LKP_Compania__c = \'' + clienteFiltros.CUE_LKP_Cuenta_principal__c + '\'';					
					}
					if(valorN_Servicio != '' && valorN_Servicio.trim() != ''){
						String vServicio = valorN_Servicio.trim();
						vServicio = vServicio.leftPad(8, '0');
						String idCasoPresupuesto = null;
						String queryPresu = 'SELECT PRE_LKP_Caso__c FROM Presupuesto__c WHERE Name = \'' + vServicio + '\'';
						List<Presupuesto__c> listaPresupuestos = Database.query(queryPresu);
						if(!listaPresupuestos.isEmpty()){
							filtro += ' AND Id = \'' + listaPresupuestos.get(0).PRE_LKP_Caso__c + '\'';
						}
						else {
							Id tempId = null;
							try {
								tempId = Id.valueOf(valorN_Servicio.trim());
							}catch(Exception e){
								system.debug(e.getMessage());
							}
							if(tempId != null){
								filtro += ' AND (CAS_TXT_Num_Caso_HS__c = \'' + vServicio + '\' OR Id = \'' + tempId + '\' OR CAS_TXT_Codigo_Activacion_Atila__c = \'' + vServicio + '\' OR CaseNumber = \'' + vServicio + '\')';
							} else{
								filtro += ' AND (CAS_TXT_Num_Caso_HS__c = \'' + vServicio + '\' OR CAS_TXT_Codigo_Activacion_Atila__c = \'' + vServicio + '\' OR CaseNumber = \'' + vServicio + '\')';
							}
						}
					}
					if(valorTelefono != null && valorTelefono != '' && valorTelefono.trim() != ''){								
						filtro += ' AND CAS_TFN_Solicitud_Telefono__c = \'' + valorTelefono.trim() + '\'';
					}
					if(valorCodigoPostal != null && valorCodigoPostal != '' && valorCodigoPostal.trim() != ''){								
						filtro += ' AND (CAS_TXT_DirRiesgo_CP__c = \'' + valorCodigoPostal.trim() + '\' OR CAS_TXT_Codigo_Postal__c = \'' + valorCodigoPostal.trim() + '\')'; 
					}
					query += filtro + 'LIMIT ' + limiteBusqueda;
					system.debug('>>>>busqueda.query CASOS: ' + query);
					system.debug('<<<<ListaCaso1: ' + listaCasos);
					listaCasos = Database.query(query);
					system.debug('<<<<ListaCaso2: ' + listaCasos);
					if(listaCasos.size() == limiteBusqueda){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'La búsqueda ha devuelto demasiados resultados, modifique los filtros introducidos'));
					}
					page = 1;
					calculateResultsShown();
				}
			}
			// B) Búsqueda sobre cuentas
			else {
				if(valorCodigoPostal != null && valorCodigoPostal != ''){
					cargarListaPoblacionPorCP();
				}
				mapaDirecc = new Map <Id, List<Direccion_Cuenta__c>>();
				String query = 'SELECT Name, CUE_TXT_Numero_Documento__c, CUE_FOR_DireccionEnvio__c, CUE_CAS_Activado__c, Type FROM Account';
				String filtro = ' WHERE CUE_LKP_Cuenta_principal__c = \'' + clienteFiltros.CUE_LKP_Cuenta_principal__c + '\' AND CUE_CAS_Dada_de_Baja__c = false';
				filtro += ' AND Type != \'' + Label.CUE_TIPO_CONTABLE + '\'';

				//Numero de servicio
				if(valorN_Servicio != null && valorN_Servicio.trim() != ''){
					String vServicio = valorN_Servicio.trim();
					vServicio = vServicio.leftPad(8, '0');
					filtro += ' AND Id IN (SELECT AccountId FROM Case WHERE (CAS_TXT_Num_Caso_HS__c = \'' + vServicio + '\' OR CaseNumber LIKE \'' + vServicio + '\'';
					Id tempId = null;
					try {
						tempId = Id.valueOf(valorN_Servicio.trim());
					} catch(Exception e){
						system.debug(e.getMessage());
					}
					if(tempId != null){
						filtro += ' OR Id = \'' + tempId + '\')';
					}
					else {
						filtro += ')';
					}
					filtro += ' AND ' + filtroRTCasos + ')';
				}
				//Numero de documento
				if(valorN_Documento != null && valorN_Documento.trim() != ''){
					filtro += ' AND CUE_TXT_Numero_Documento__c = \'' + valorN_Documento.trim() + '\'';
				}
				//Tipo
				if(clienteFiltros.Type != null){
					filtro += ' AND Type = \'' + clienteFiltros.Type + '\'';
				}
				//Nombre
				if(valorNombre != null && valorNombre.trim() != ''){
					filtro += ' AND CUE_TXT_Nombre__c LIKE \'%' + valorNombre.trim() + '%\'';
				}
				//Apellido 1
				if(valorApellido_1 != null && valorApellido_1.trim() != ''){
					filtro += ' AND CUE_TXT_PrimerApellido__c LIKE \'%' + valorApellido_1.trim() + '%\'';
				}
				//Apellido 2
				if(valorApellido_2 != null && valorApellido_2.trim() != ''){
					filtro += ' AND CUE_TXT_SegundoApellido__c LIKE \'%' + valorApellido_2.trim() + '%\'';
				}
				//Teléfono
				if(valorTelefono != null && valorTelefono.trim() != ''){
					filtro += ' AND Id IN (SELECT AccountId FROM Contact WHERE MobilePhone = \'' + valorTelefono.trim() + '\' OR Phone = \'' + valorTelefono.trim() + '\' OR HomePhone = \'' + valorTelefono.trim() + '\')';
				}

				if(cuentaPpalEsB2C){
					String queryDir = '';
					//Domicilio
					if(valorDomicilio != null && valorDomicilio.trim() != ''){
						if(queryDir == ''){
							queryDir += ' AND Id IN (SELECT DCU_LKP_Cuenta__c FROM Direccion_Cuenta__c ';
							queryDir += ' WHERE DCU_TXT_Direccion__c LIKE \'%' + valorDomicilio.trim() + '%\'';
						}else{
							queryDir += ' AND DCU_TXT_Direccion__c LIKE \'%' + valorDomicilio.trim() + '%\'';
						}
					}
					//C.P.
					if(valorCodigoPostal != null && valorCodigoPostal.trim() != ''){
						if(queryDir == ''){
							queryDir += ' AND Id IN (SELECT DCU_LKP_Cuenta__c FROM Direccion_Cuenta__c ';
							queryDir += ' WHERE DCU_TXT_Codigo_Postal__c = \'' + valorCodigoPostal.trim() + '\'';
						}else{
							queryDir += ' AND DCU_TXT_Codigo_Postal__c = \'' + valorCodigoPostal.trim() + '\'';
						}
					}
					//Poblacion
					if(valorPoblacion != null && valorPoblacion.trim() != ''){
						if(queryDir == ''){
							queryDir += ' AND Id IN (SELECT DCU_LKP_Cuenta__c FROM Direccion_Cuenta__c ';
							queryDir += ' WHERE DCU_TXT_Poblacion__c LIKE \'%' + valorPoblacion + '%\'';
						}else{
							queryDir += ' AND DCU_TXT_Poblacion__c LIKE \'%' + valorPoblacion + '%\'';
						}
					}
					//Provincia
					if(valorProvincia != null && valorProvincia.trim() != ''){
						if(queryDir == ''){
							queryDir += ' AND Id IN (SELECT DCU_LKP_Cuenta__c FROM Direccion_Cuenta__c ';
							queryDir += ' WHERE DCU_SEL_Provincia__c = \'' + valorProvincia + '\'';
						}
						else {
							queryDir += ' AND DCU_SEL_Provincia__c = \'' + valorProvincia + '\'';
						}
					}
					if(queryDir != ''){
						filtro += queryDir + ')';
					}
				}
				else {
					//Domicilio
					if(valorDomicilio != null && valorDomicilio.trim() != ''){
						filtro += ' AND ShippingStreet LIKE \'%' + valorDomicilio.trim() + '%\'';
					}
					//C.P.
					if(valorCodigoPostal != null && valorCodigoPostal.trim() != ''){
						filtro += ' AND ShippingPostalCode = \'' + valorCodigoPostal.trim() + '\'';
					}
					//Poblacion
					if(valorPoblacion != null && valorPoblacion.trim() != ''){
						filtro += ' AND ShippingCity LIKE \'%' + valorPoblacion.trim() + '%\'';
					}
					//Provincia
					if(valorProvincia != null){
						filtro += ' AND CUE_SEL_Provincia__c = \'' + valorProvincia + '\'';
					}
				}

				query += filtro + ' LIMIT ' + limiteBusqueda;
				system.debug('>>>>busqueda.query CUENTAS: ' + query);
				listaClientes = Database.query(query);
				system.debug('>>>>busqueda.listaClientes: ' + listaClientes);
				if(!listaClientes.isEmpty()){
					if(listaClientes.size() == limiteBusqueda){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'La búsqueda ha devuelto demasiados resultados, modifique los filtros introducidos'));
					}
					if(cuentaPpalEsB2C){
						Set<ID> setIdDirecciones = new Set<Id>();
						for(Account cli : listaClientes){
							setIdDirecciones.add(cli.Id);
						}
						//Se traen todas las direcciones que usen alguna de las cuentas
						List<Direccion_Cuenta__c> listaDirecc = Util_Cuentas.getMapDireccionesCuenta(setIdDirecciones).values();
						/*List<Direccion_Cuenta__c> listaDirecc = new List<Direccion_Cuenta__c>(
								[SELECT DCU_TXT_Codigo_Postal__c,
								 DCU_TXT_Direccion__c,
								 DCU_TXT_Poblacion__c,
								 DCU_SEL_Provincia__c,
								 DCU_FOR_DireccionCompleta__c,
								 DCU_LKP_Cuenta__c												
								 FROM Direccion_Cuenta__c
								 WHERE DCU_LKP_Cuenta__c IN :setIdDirecciones]);*/
						//Se filtran las direcciones según la cuenta a la que corresponden y se mapea
						for(Direccion_Cuenta__c dir : listaDirecc){
							List<Direccion_Cuenta__c> listaFiltrar;
							if(mapaDirecc.containsKey(dir.DCU_LKP_Cuenta__c)){
								listaFiltrar = mapaDirecc.get(dir.DCU_LKP_Cuenta__c);
							}else{
								listaFiltrar = new List<Direccion_Cuenta__c>();
							}
							listaFiltrar.add(dir);
							mapaDirecc.put(dir.DCU_LKP_Cuenta__c, listaFiltrar);
						}
						// La cuenta tiene que estar en el mapa, si no no funciona la visual
						for(Account cuentaSinDirecciones : listaClientes){
							if(!mapaDirecc.containsKey(cuentaSinDirecciones.Id)){
								mapaDirecc.put(cuentaSinDirecciones.Id, new List<Direccion_Cuenta__c>());
							}
						}
					}
				}
				page = 1;
				calculateResultsShown();
			}
		}
	}


	/**
	 * Inicializa la pantalla para la búsqueda de clientes.
	 */
	public void busquedaClientes(){
		busquedaServicios = false;
		valorN_Servicio = null;
		valorN_Documento = null;
		valorNombre = null;
		valorApellido_1 = null;
		valorApellido_2 = null;
		valorTelefono = null;
		valorDomicilio = null;
		valorCodigoPostal = null;
		poblacion = null;
		listaPoblaciones = Util_Poblacion.inicializarListaPoblaciones();
		listaProvincias = Util_Poblacion.inicializarListaProvincias();
		listaClientes = null;
		valorPoblacion = null;
		valorProvincia = null;
		clienteFiltros.Type = null;
		cargarListaTiposClientes();
	}


	/**
	 * Inicializa la pantalla para la búsqueda de servicios.
	 */
	public void busquedaServicios(){
		busquedaServicios = true;
		valorN_Servicio = null;
		valorCodigoPostal = null;
		valorTelefono = null;
		listaCasos = null;
	}


	/**
	 * Carga la lista de poblaciones a elegir según el código postal seleccionado
	 */
	public void cargarListaPoblacionPorCP(){
		listaPoblaciones = Util_TerritorioServicio.cargarListaPoblacionPorCP(valorCodigoPostal);
		poblacion = listaPoblaciones.get(0).getValue(); //CódigoProvincia#NombrePoblación
		valorProvincia = null;
		valorPoblacion = null;
		if(listaPoblaciones.size() > 1){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_POBLACIONES_CP));
		}
		else if(listaPoblaciones.get(0).getValue() == ''){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_MUNICIPIOS_NO_CP));
		}
		else {
			cargarProvinciaPoblacion();
		}
	}


	/**
	 * Carga la Provincia según la población elegida
	 */
	public void cargarProvinciaPoblacion(){
		valorPoblacion = Util_TerritorioServicio.obtenerPoblacionSel(poblacion);
		valorProvincia = Util_TerritorioServicio.obtenerProvinciaSel(poblacion);
	}


	/**
     * Método que se encarga de gestionar los casos B2C sin cliente
     * 
     * @return página a navegar tras indicar cliente no existente en B2C
     */
	public PageReference noExistenteB2C (){
		system.debug('B2B_BusquedaClientes : noExistenteB2C : Entrando al método');
		PageReference paginaRedireccion = null;
		if(clienteFiltros.CUE_LKP_Cuenta_principal__c == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_CUENTA_PRINCIPAL));
		}
		else {
			system.debug('B2B_BusquedaClientes : noExistenteB2C : Navegar a Argumentario');
			paginaRedireccion = new PageReference('/apex/' + label.VF_B2C_ARGUMENTARIO);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, '/apex/' + Label.VF_B2B_BUSQ_CLIENTES);
			paginaRedireccion.getParameters().put('idCIA', clienteFiltros.CUE_LKP_Cuenta_principal__c);
			paginaRedireccion.getParameters().put('b2cSinCliente', 'Y');
			paginaRedireccion.setRedirect(true);
		}
		system.debug('B2B_BusquedaClientes : noExistenteB2C : paginaRedireccion.getUrl() : '+paginaRedireccion.getUrl());
		return paginaRedireccion;
	}


	/**
	 * Crea una nueva cuenta secundaria
	 *
	 * @return página a navegar tras crear la cuenta secundaria
	 */
	public PageReference nuevaCuenta(){
		PageReference paginaRedireccion = null;
		if(clienteFiltros.CUE_LKP_Cuenta_principal__c == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_CUENTA_PRINCIPAL));
		}
		else {
			paginaRedireccion = new PageReference('/apex/' + Label.VF_ALTA_MODIFICACION_CLIENTE);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, '/apex/' + Label.VF_B2B_BUSQ_CLIENTES);
			paginaRedireccion.getParameters().put('idCuentaPpal', clienteFiltros.CUE_LKP_Cuenta_principal__c);
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}


	/**
	 * Selecciona un caso a editar
	 *
	 * @return página a navegar tras seleccionar el caso
	 */
	public PageReference seleccionarCaso(){
		Id idCasoSeleccionado = listaCasos.get(indiceResultado + (page-1)*recPerPage).Id;
		PageReference paginaRedireccion = new PageReference ('/' + idCasoSeleccionado);
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}


	/**
	 * Selecciona un resultado a editar
	 *
	 * @return página a navegar tras seleccionar el resultado
	 */
	public PageReference seleccionarResultado(){
		Id idCuentaSeleccionada = listaClientes.get(indiceResultado + (page-1)*recPerPage).Id;
		String tipoCuentaSeleccionada = listaClientes.get(indiceResultado + (page-1)*recPerPage).Type;
		Boolean cuentaAceptada = tipoCuentaSeleccionada == Label.CUE_TIPO_CONTABLE || tipoCuentaSeleccionada == Label.CUE_TIPO_OK_PYMES 
									|| tipoCuentaSeleccionada == Label.CUE_TIPO_DIRECCION;
		PageReference paginaRedireccion = null;
		if(idCaso != null && (tipoCuentaSeleccionada == Label.CUE_TIPO_OK_PYMES || tipoCuentaSeleccionada == Label.CUE_TIPO_CONTABLE)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_Cliente_NUEVO_SERVICIO_B2B_TIPO_CONTABLE));
		}
		else if(idCaso != null || (cuentaPpalEsB2C && !cuentaAceptada)){
			paginaRedireccion = new PageReference('/apex/'+ Label.VF_ALTA_MODIFICACION_CLIENTE);
			paginaRedireccion.getParameters().put('id', idCuentaSeleccionada);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, '/apex/' + Label.VF_B2B_BUSQ_CLIENTES);
			paginaRedireccion.setRedirect(true);
		}
		else {
			paginaRedireccion = new PageReference('/'+ idCuentaSeleccionada);
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}


	/**
     * Método que se encarga de volver a la página anterior
     * 
     * @return página a navegar tras la acción 'volver'
     */
	public PageReference volver(){
		PageReference paginaRedireccion = new PageReference('/' + idCaso);
		if(vincularCliB2BRep){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_B2B_Reparable);
			paginaRedireccion.getParameters().put('id', idCaso);
			paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
			paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
		}
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}


	private void cargarListaTiposClientes(){
		typeList = new List<SelectOption>();
		typeList.add(new SelectOption('', '-- Ninguno --'));
		for(SelectOption so : Util_Cuentas.inicializarListaTiposCuenta()){
			String valor = so.getValue();
			String etiqueta = so.getLabel();
			if(valor.isNumericSpace() && valor != Label.CUE_TIPO_CONTABLE && (
			  (cuentaPpalEsB2C && (valor == Label.CUE_TIPO_CLIENTEFINAL || valor == Label.CUE_TIPO_EMPRESA)) ||
			  (!cuentaPpalEsB2C && (valor != Label.CUE_TIPO_EMPRESA &&
			  (valor != Label.CUE_TIPO_OK_PYMES || codigoCuentaP == Label.IDE_ENDESA))))){
				typeList.add(new SelectOption(so.getValue(),so.getLabel()));
			}
		}
	}


	/**
	 * This method initialize the search when a new option of records per page is selected
   	 */
	public void recPerPageChange(){
		page = 1;
		calculateResultsShown();
	}
	
	/**
	* This method shows the next page of the results
   	*/
	public void nextPage(){
		page++;
		calculateResultsShown();
	}
	
	/**
	* This method shows the previous page of the results
   	*/
	public void previousPage(){
		page--;
		calculateResultsShown();
	}
	
	/**
	* This method shows the first page of the results
   	*/
	public void firstPage(){
		page = 1;
		calculateResultsShown();
	}
	
	/**
	* This method shows the last page of the results
   	*/
	public void lastPage(){
		page = lastPage;
		calculateResultsShown();
	}


	/**
	* This method is used to initialize the records per page select list.
   	* @return String Returns the records per page select list.
   	*/
	public List<SelectOption> getRPPO(){
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('10', '10'));
		options.add(new SelectOption('25', '25'));
		options.add(new SelectOption('50', '50'));
		options.add(new SelectOption('100', '100'));
		return options;
	}
	

	private void calculateResultsShown(){
		Integer offSet = (page-1)*recPerPage;
		Integer index = 0;
		Integer size = 0;
		if(busquedaServicios){
			listaCasosFinal = new List<Case>();
			for(Case cas : listaCasos){
				if(index >= offSet && index < recPerPage+offSet){
					listaCasosFinal.add(cas);
				}
				index++;
			}
			size = Integer.valueOf(listaCasos.size());			
		}
		else {
			listaClientesFinal = new List<Account>();
			for(Account acc : listaClientes){
				if(index >= offSet && index < recPerPage+offSet){
					listaClientesFinal.add(acc);
				}
				index++;
			}
			size = Integer.valueOf(listaClientes.size());			
		}
		system.debug('listaClientesFinal: ' + listaClientesFinal);
		
		// The Math.ceil() function returns the smallest integer greater than or equal to a given number
		lastPage = Integer.valueOf(Math.ceil(size / Decimal.valueOf(recPerPage)));
		if(lastPage == 0){
			lastPage = 1;
		}
	}
}