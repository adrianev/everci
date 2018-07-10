/**
 * Clase controladora de la Visualforce "BusquedaClientesPoliza" encargada de localizar pólizas de clientes asegurados.
 * 
 * @author EVERIS
 */
public class BusquedaClientesPolizaController { 
	private final String VDN='VDN';
	private final String TELFONOS_DE_CONSULTA=' TELÉFONOS DE CONSULTA ';
	private final String CASE_ID='caseId';


	public Account compania {get;set;}
	public Account cuentaFiltro {get;set;}
	public Boolean esBusquedaAvanzada{get;set;}
	public List<SelectOption> listaTelefonos {get; set;}
	public String vdnName{get;set;}
	public String identificador{get;set;}
	public List<Callout_ConsultaPolizaVesta_RP> listaPolizas{get;set;}
	public WrapperBusquedaAvanzada busquedaAvanzadaWrapper{get;set;} 
	public String telefonoSeleccionado {get;set;}
	public Boolean renderizarBotonCancelar {get;set;}
	public Boolean renderizarCompaniaSoloLectura{get;set;}
	private String codigoVDN{get;set;}
	public Boolean existenErroresAvisoCia{get;set;}
	public String idCaso{get;set;}

	/**
	* Esta vf se puede acceder desde:
	* - Ficha 'BusquedaPolizas'
	* - Contacto telefónico: 'VDN-Identificador'.
	* - Contacto Email2Case: 'CaseId'.
	* - Volver de Intervención sin póliza: 'idCompania'
	* - Volver de AltaConfirmacionCliente: 'idCompania-identificador'.
	*/
	public BusquedaClientesPolizaController(){
		//Inicialización de las variables
		compania=new Account();
		cuentaFiltro=new Account();
		esBusquedaAvanzada=false;
		listaTelefonos=new List<SelectOption>();
		listaTelefonos.add(new SelectOption('',TELFONOS_DE_CONSULTA));
		busquedaAvanzadaWrapper=new WrapperBusquedaAvanzada();
		renderizarBotonCancelar=false;
		renderizarCompaniaSoloLectura=false;

		//Posibles entradas a la página, por telefonía (VDN) - Identificador/ por Email2CAse (caseId) 
		Map<String, String> mapParameters=ApexPages.currentPage().getParameters();
		for(String parameterAux:mapParameters.keySet()){
			System.debug('BusquedaClientesPoliza: Constructor: paramétro: '+parameterAux+ 'valor: '+mapParameters.get(parameterAux));
			if(VDN.equalsIgnoreCase(parameterAux)){
				Set<String> setVdn=new Set<String>{mapParameters.get(parameterAux)};
				for(VDN_Compania__c companyVdn:Util_CTI.getVDNByName(setVdn).values()){
					populateSectionCompaniaFromVDN(companyVdn);
				}
				codigoVDN=mapParameters.get(parameterAux);
				renderizarCompaniaSoloLectura=true;
			} else if(CASE_ID.equalsIgnoreCase(parameterAux)){
				Set<Id> setCaso=new Set<Id>{mapParameters.get(parameterAux)};
				for(Case comingCase:Util_Caso.getCaseById(setCaso).values()){
					populateSectionCompaniaFromCase(comingCase);
				}
				idCaso=mapParameters.get(parameterAux);
				renderizarBotonCancelar=true;
				renderizarCompaniaSoloLectura=true;
			} else if('idCompania'.equalsIgnoreCase(parameterAux)) {
				populateSectionCompaniaFromIdCompania(mapParameters.get(parameterAux));
			}
			if('identificador'.equalsIgnoreCase(parameterAux)){
				identificador=mapParameters.get(parameterAux);
			}
			
		}
		//Si el identificador viene relleno, lanzo la búsqueda de pólizas.
		if(!String.isEmpty(identificador)){
			buscarPolizas();
		}
	}
	
	/*
	* Método que cambiar el tipo de Búsqueda.
	*/
	public void setBusqueda(){
		if(esBusquedaAvanzada){
			esBusquedaAvanzada=false;
		} else {
			esBusquedaAvanzada=true;
		}
	}

	/*
	* Método que permite buscar pólizas en función de si es Avanzada o Simple.
	*/
	public void buscarPolizas(){
		if(esBusquedaAvanzada){
			buscarPolizasAvanzada();
		} else {
			buscarPolizasSimple();
		}
	}

	private void buscarPolizasSimple(){
		listaPolizas=null;
		if(!String.isEmpty(cuentaFiltro.CUE_LKP_Cuenta_Principal__c)){
			if(!String.isEmpty(identificador)){
				listaPolizas=Fachada.consultaPolizaVestaSimple(cuentaFiltro.CUE_LKP_Cuenta_Principal__c,identificador);
				if(!listaPolizas.isEmpty()){
					if(!String.isEmpty(listaPolizas.get(0).errorCode)){
						String errorBusqueda = '[' + listaPolizas.get(0).errorCode + '] ' + listaPolizas.get(0).errorMessage;
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error. ' + errorBusqueda));						
						listaPolizas=null;
					}
				}
				else {
					Map <Id,Ayuda__c> mapaAyuda = Util_Ayuda.getMapaAyudaCompania(new Set<Id>{cuentaFiltro.CUE_LKP_Cuenta_Principal__c});
					if(mapaAyuda.isEmpty()) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No existen pólizas, y la ayuda no está configurada'));
					}else {
						Ayuda__c ayuda = mapaAyuda.values().get(0);
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ayuda.AYU_TXT_Descripcion__c));
					}
				}
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Es necesario introducir un valor de filtro'));
			}
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,  Label.ERROR_FALTA_COMPANIA));
		}
	}
	
	/*
	* Método para buscar Pólizas avanzadas.
	*/
	private void buscarPolizasAvanzada(){
		listaPolizas=null;
		if(!String.isEmpty(cuentaFiltro.CUE_LKP_Cuenta_Principal__c)){
			if(!validacionesBusquedaAvanzada()){
				listaPolizas = Fachada.consultaPolizaVestaAdvance(cuentaFiltro.CUE_LKP_Cuenta_Principal__c, busquedaAvanzadaWrapper.numeroPoliza,busquedaAvanzadaWrapper.numeroDocumento,busquedaAvanzadaWrapper.numeroSiniestroHS, busquedaAvanzadaWrapper.numeroSiniestroCia,modifcarEspaciosEnBlanco(busquedaAvanzadaWrapper.nombre), modifcarEspaciosEnBlanco(busquedaAvanzadaWrapper.primerApellido), modifcarEspaciosEnBlanco(busquedaAvanzadaWrapper.segundoApellido),modifcarEspaciosEnBlanco(busquedaAvanzadaWrapper.viaDomicilio), busquedaAvanzadaWrapper.codigoPostal, busquedaAvanzadaWrapper.poblacion, busquedaAvanzadaWrapper.provincia);				
				if(!listaPolizas.isEmpty()){
					if(!String.isEmpty(listaPolizas.get(0).errorCode)){
						String errorBusqueda = '[' + listaPolizas.get(0).errorCode + '] ' + listaPolizas.get(0).errorMessage;
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error. ' + errorBusqueda));						
						listaPolizas = null;
					}
				}
				else {
					Map <Id,Ayuda__c> mapaAyuda = Util_Ayuda.getMapaAyudaCompania(new Set<Id>{cuentaFiltro.CUE_LKP_Cuenta_Principal__c});
					if(mapaAyuda.isEmpty()) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No existen pólizas, y la ayuda no está configurada'));
					}else {
						Ayuda__c ayuda = mapaAyuda.values().get(0);
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ayuda.AYU_TXT_Descripcion__c));
					}
				}
			}
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,  Label.ERROR_FALTA_COMPANIA));
		}
	}
 
	private String modifcarEspaciosEnBlanco(String stringToRemoveSpaces){
		return stringToRemoveSpaces.replace(' ','+');
	}

	/*
	* Validaciones de Búsqueda Avanzada.
	*/
	private Boolean validacionesBusquedaAvanzada(){
		Boolean existenErrores=false;
		if(numeroDeCamposRellenos()==0){
			existenErrores=true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No se puede realizar la búsqueda sólo por el campo compañía. Por favor, introduzca algún filtro más.'));
		}
		if(rellenarProvinciaPoblacionCodigoPostalYDireccion()){
			existenErrores=true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No se pueden realizar búsquedas sólo por el campo CP, Población y Provincia. Por favor, incluya el domicilio del cliente'));
		}
		if(nombreRellenoYApellidoEnBlanco()){
			existenErrores=true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Para realizar búsquedas por el nombre del cliente, debe introducir un valor para el nombre y, al menos, el primer apellido'));
		}
		if(provinciaRellenoYPoblacionVacioYCPCacioRellenarNombreApellido()){
			existenErrores=true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No se pueden realizar búsquedas por el campo provincia. Por favor, añada el nombre y los apellidos del cliente a la búsqueda'));
		}
		if(numeroDeCamposRellenos()==1){
			existenErrores=true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Es necesario realizar la búsqueda por más de un campo. Por favor, introduzca otro campo para la búsqueda.'));
		}
		return existenErrores;
	}
	
	private Boolean provinciaRellenoYPoblacionVacioYCPCacioRellenarNombreApellido(){
		Boolean validacionProvinca=false;
		if(!String.isEmpty(busquedaAvanzadaWrapper.provincia) 
			&& String.isEmpty(busquedaAvanzadaWrapper.poblacion) 
			&& String.isEmpty(busquedaAvanzadaWrapper.codigoPostal)
			&& (String.isEmpty(busquedaAvanzadaWrapper.nombre) || String.isEmpty(busquedaAvanzadaWrapper.primerApellido))){
			validacionProvinca=true;
		}
		return validacionProvinca;
	}


	private Integer numeroDeCamposRellenos(){
		Integer contadorCamposRellenos=0;
		if(!String.isEmpty(busquedaAvanzadaWrapper.numeroSiniestroHS)){
			contadorCamposRellenos++;
		}
		if(!String.isEmpty(busquedaAvanzadaWrapper.numeroPoliza)){
			contadorCamposRellenos++;
		}
		if(!String.isEmpty(busquedaAvanzadaWrapper.numeroDocumento)){
			contadorCamposRellenos++;
		}
		if(!String.isEmpty(busquedaAvanzadaWrapper.nombre)){
			contadorCamposRellenos++;
		}
		if(!String.isEmpty(busquedaAvanzadaWrapper.primerApellido)){
			contadorCamposRellenos++;
		}
		if(!String.isEmpty(busquedaAvanzadaWrapper.segundoApellido)){
			contadorCamposRellenos++;
		}
		if(!String.isEmpty(busquedaAvanzadaWrapper.viaDomicilio)){
			contadorCamposRellenos++;
		}
		if(!String.isEmpty(busquedaAvanzadaWrapper.numeroSiniestroCia)){
			contadorCamposRellenos++;
		}
		if(!String.isEmpty(busquedaAvanzadaWrapper.poblacion)){
			contadorCamposRellenos++;
		}
		if(!String.isEmpty(busquedaAvanzadaWrapper.provincia)){
			contadorCamposRellenos++;
		}
		if(!String.isEmpty(busquedaAvanzadaWrapper.codigoPostal)){
			contadorCamposRellenos++;
		}
		return contadorCamposRellenos;
	}

	private Boolean rellenarProvinciaPoblacionCodigoPostalYDireccion(){
		Boolean provinciaPoblacionCpRellenoSolamente=false;
		if(!String.isEmpty(busquedaAvanzadaWrapper.provincia) 
			&& !String.isEmpty(busquedaAvanzadaWrapper.poblacion) 
			&& !String.isEmpty(busquedaAvanzadaWrapper.codigoPostal) 
			&& String.isEmpty(busquedaAvanzadaWrapper.viaDomicilio)){
				provinciaPoblacionCpRellenoSolamente=true;
				}
		return provinciaPoblacionCpRellenoSolamente;
	}

	private Boolean nombreRellenoYApellidoEnBlanco(){
		Boolean nombreRellenoYApellidoEnBlanco=false;
		if(!String.isEmpty(busquedaAvanzadaWrapper.nombre) && String.isEmpty(busquedaAvanzadaWrapper.primerApellido)){
			nombreRellenoYApellidoEnBlanco=true;
		}
		return nombreRellenoYApellidoEnBlanco;
	}

	public class WrapperBusquedaAvanzada {
		public String numeroSiniestroHS {get;set;}
		public String numeroPoliza {get;set;}
		public String numeroDocumento {get;set;}
		public String nombre {get;set;}
		public String primerApellido {get;set;}
		public String segundoApellido {get;set;}
		public String viaDomicilio {get;set;}
		public String codigoPostal {get;set;}
		public String poblacion {get;set;}
		public String provincia {get;set;}
		public List<SelectOption> listaPoblaciones {get;set;}
		public List<SelectOption> listaProvincias {get;set;}
		public String numeroSiniestroCia {get;set;}

		public WrapperBusquedaAvanzada(){
			listaProvincias=Util_Poblacion.inicializarListaProvincias();
			listaPoblaciones=Util_Poblacion.inicializarListaPoblaciones();
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
					listaPoblacionesAux.add(new SelectOption(identificadorPoblacionAux.Id, identificadorPoblacionAux.POB_TXT_Identificador__c.substringAfter('#')));
				} 
				listaPoblaciones=listaPoblacionesAux;
			}
			//reinicio el Código Postal
			codigoPostal='';
		}

		public void cargarUbicacion(){
			if(!String.isEmpty(codigoPostal)){
				//Map<String, Poblacion_CP__c> mapPoblacion=new Map<String, Poblacion_CP__c>([SELECT PCP_LKP_Poblacion__r.POB_SEL_Provincia__c, PCP_LKP_Poblacion__r.Name FROM Poblacion_CP__c WHERE PCP_LKP_TerritorioServicio__r.TDS_TXT_Identificador__c = :codigoPostal]);
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

	}

	private void populateSectionCompaniaFromVDN(VDN_Compania__c companyVdn){
		compania=Util_Cuentas.getMapCuentasById(new Set<Id>{companyVDN.VDN_LKP_Compania__c}).get(companyVDN.VDN_LKP_Compania__c);
		cuentaFiltro.CUE_LKP_Cuenta_principal__r=compania; 
		cuentaFiltro.CUE_LKP_Cuenta_Principal__c=compania.Id;
		compania.CUE_TXT_Presentacion__c=Util_Compania.reemplazarTokensPresentacion(companyVdn.VDN_TXT_Presentacion__c);
		compania.CUE_TXT_Ayuda_Busqueda__c=companyVdn.VDN_TXT_Ayuda_Busqueda__c;
		vdnName=companyVdn.Name;
		listaTelefonos = Util_Telef_TransferCIA.buscarTelefonos(compania.CUE_LKP_Cuenta_Principal__c);
	}

	private void populateSectionCompaniaFromCase(Case comingCase){
		compania=Util_Cuentas.getMapCuentasById(new Set<Id>{comingCase.CAS_LKP_Compania__c}).get(comingCase.CAS_LKP_Compania__c);
		cuentaFiltro.CUE_LKP_Cuenta_principal__r=compania; 
		cuentaFiltro.CUE_LKP_Cuenta_Principal__c=compania.Id;
		compania.CUE_TXT_Presentacion__c=Util_Compania.reemplazarTokensPresentacion(compania.CUE_TXT_Presentacion__c);
		listaTelefonos = Util_Telef_TransferCIA.buscarTelefonos(compania.Id);
	}

	private void populateSEctionCompaniaFromIdCompania(String idCompania) {
		compania=Util_Cuentas.getMapCuentasById(new Set<Id>{idCompania}).get(idCompania);
		cuentaFiltro.CUE_LKP_Cuenta_principal__r=compania; 
		cuentaFiltro.CUE_LKP_Cuenta_Principal__c=compania.Id;
		compania.CUE_TXT_Presentacion__c=Util_Compania.reemplazarTokensPresentacion(compania.CUE_TXT_Presentacion__c);
		listaTelefonos = Util_Telef_TransferCIA.buscarTelefonos(compania.Id);
	}

	public void populateSectionCompaniaFromVisual(){
		System.debug('BusquedaClientesPoliza: populateSectionCompaniaFromVisual');
		if(!String.isEmpty(cuentaFiltro.CUE_LKP_Cuenta_Principal__c)){
			compania=Util_Cuentas.getMapCuentasById(new Set<Id>{cuentaFiltro.CUE_LKP_Cuenta_Principal__c}).get(cuentaFiltro.CUE_LKP_Cuenta_Principal__c);
			compania.CUE_TXT_Presentacion__c=Util_Compania.reemplazarTokensPresentacion(compania.CUE_TXT_Presentacion__c);
			compania.Id = cuentaFiltro.CUE_LKP_Cuenta_Principal__c;
		}
		listaTelefonos = Util_Telef_TransferCIA.buscarTelefonos(compania.Id);
		listaPolizas=null;
	}
	
	/**
	* Método que se ejecuta al seleccionar una póliza.
	*/
	public PageReference seleccionarPoliza(){
		PageReference paginaRedireccion=null;
		Account cuentaDelaPoliza=new Account();
		Callout_ConsultaPolizaVesta_RP polizaSeleccionada=recuperarPolizaSeleccionada();
		List<ServiceContract> listaPolizasToUpsert=new List<ServiceContract>();
		Map<Id,ServiceContract> mapaPolizasExistentes=new Map<Id,ServiceContract>();
		Boolean esNuevaPoliza=false;
		Boolean existeNuevaVersion=false;

		ServiceContract poliza=new ServiceContract();
		Version_ContratoServicio__c versionDePoliza=new Version_ContratoServicio__c();
		
		/*MEMBERSHIP
			if(listaPolizas[indiceResultado].idClienteEnsura != null){
				listaPolizasExistentes[0].POL_TXT_Cliente_Ensura__c = listaPolizas[indiceResultado].idClienteEnsura;
			}
			if(listaPolizas[indiceResultado].rolAsegurado != null){
				listaPolizasExistentes[0].POL_TXT_Rol_Asegurado__c= listaPolizas[indiceResultado].rolAsegurado;
			}
			if(listaPolizas[indiceResultado].codigoMunicipio != null){
				listaPolizasExistentes[0].POL_TXT_Codigo_Municipio__c = listaPolizas[indiceResultado].codigoMunicipio;
			}
		*/
 
		if(!validacionesPolizaSeleccionada(polizaSeleccionada)){
			//Consultamos las pólizas
			mapaPolizasExistentes=Util_Poliza_Contrato.queryPolizaByNameAndCompania(new Set<String>{polizaSeleccionada.numeroPoliza}, new Set<Id>{polizaSeleccionada.idSFCompania});
			//Recupero la Póliza, si existe.
			for(ServiceContract polizaAux:mapaPolizasExistentes.values()) {
				poliza=polizaAux;
			}
			System.debug('BusquedaPolizaController: seleccionarPoliza: existePóliza: '+!String.isEmpty(poliza.Id));
			// Consultamos las cuentas. (Cliente).
			for(Account cuentaAux:Util_Cuentas.queryCuentasByNumeroDocumento(new Set<String>{polizaSeleccionada.numeroDocumento},new Set<String>{polizaSeleccionada.idSFCompania}).values()){
				cuentaDelaPoliza=cuentaAux;
			} 
			System.debug('BusquedaPolizaController: seleccionarPoliza: existeCuenta: '+!String.isEmpty(cuentaDelaPoliza.Id));
			//Sólo se pone: 'Confirmación de Cliente y Alta de Póliza', en caso de que exista el cliente y No la póliza.
			if(!String.isEmpty(cuentaDelaPoliza.Id) && String.isEmpty(poliza.Id)) {
				esNuevaPoliza=true;
			}
			System.debug('BusquedaPolizaController: seleccionarPoliza: esNuevaPoliza: '+esNuevaPoliza);
			//Si no existe la poliza, la creo. Y creo una nueva versión.
			if(String.isEmpty(poliza.Id)) {
				poliza=Util_Poliza_Contrato.nuevaPoliza(polizaSeleccionada, cuentaDelaPoliza.Id);
				versionDePoliza=Util_Poliza_Contrato.nuevaVersion(polizaSeleccionada);
				existeNuevaVersion=true;
				System.debug('BusquedaPolizaController: seleccionarPoliza: poliza: '+poliza);
				System.debug('BusquedaPolizaController: seleccionarPoliza: versionDePoliza: '+versionDePoliza);
			} 
			//Si existe la póliza, comprobamos si existenueva versión.
			else if(!String.isEmpty(poliza.Id)) {
				if(Integer.valueOf(poliza.POL_LKP_Version_Actual__r.Name)!=Integer.valueOf(polizaSeleccionada.identificadorVersion)) {
					existeNuevaVersion=true;
					versionDePoliza=Util_Poliza_Contrato.nuevaVersion(polizaSeleccionada);
				}
				System.debug('BusquedaPolizaController: seleccionarPoliza: poliza: '+poliza);
				System.debug('BusquedaPolizaController: seleccionarPoliza: versionDePoliza: '+versionDePoliza);
			}
			System.debug('BusquedaPolizaController: seleccionarPoliza: existeNuevaVersión: '+existeNuevaVersion);

			Savepoint sp = Database.setSavepoint();
			try {
				//Sólo la primera vez. Cuando no existe la póliza.
				poliza.AccountId=cuentaDelaPoliza.Id;
				System.debug('BusquedaPolizaController: seleccionarPoliza: poliza: '+poliza);
				if(String.isEmpty(poliza.Id)) {
					Database.upsert(poliza);
				}
				System.debug('BusquedaPolizaController: seleccionarPoliza: poliza: '+poliza);
				//Si existe nueva versión, la inserto y actualizo la póliza.
				if(existeNuevaVersion) {
					versionDePoliza.POLV_LKP_PolizaContrato__c=poliza.Id;
					Database.upsert(versionDePoliza);
					
					System.debug('BusquedaPolizaController: seleccionarPoliza: versionDePoliza: '+versionDePoliza);
	
					poliza.POL_LKP_Version_Actual__c=versionDePoliza.Id;
					Database.update(poliza);
				}
				System.debug('BusquedaPolizaController: seleccionarPoliza: poliza: '+poliza);
				System.debug('BusquedaPolizaController: seleccionarPoliza: versionDePoliza: '+versionDePoliza);
	
				paginaRedireccion=obtenerURLDestino(poliza.Id,cuentaDelaPoliza.Id,polizaSeleccionada,esNuevaPoliza);
			   
			} catch(DmlException e){
				paginaRedireccion = null;
				if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO + ': ' + e.getMessage()));
				}
				Database.rollback(sp);
			} catch(Exception e){
				paginaRedireccion = null;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO + ': ' + e.getMessage()));
				Database.rollback(sp);
			}
		}
		system.debug(paginaRedireccion + ' paginaRedireccion');
		return paginaRedireccion;
	}
 
	private Boolean validacionesPolizaSeleccionada(Callout_ConsultaPolizaVesta_RP polizaSeleccionada){
		Boolean existenErrores=false;
		Ayuda__c ayuda = new Ayuda__c();
		if(!'Activa'.equalsIgnoreCase(polizaSeleccionada.estado)){
			//sino está activa tipo = 04,
			ayuda = Util_Ayuda.getMapaAyudaByTipo(new Set<String> {Label.AYUDA_POLIZA_BAJA}).values().get(0);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ayuda.AYU_TXT_Descripcion__c));
			existenErrores=true;
		} else if(String.isEmpty(polizaSeleccionada.idSFProducto)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, polizaSeleccionada.descProdAux));
			existenErrores=true;
		} else if(!polizaSeleccionada.perteneceHS){
			//digitoControl polizaSeleccionada, 01 then tipoAyuda = 02 else 03
			if(polizaSeleccionada.controlDigitoSegurcaixa == 1) {
				ayuda = Util_Ayuda.getMapaAyudaByTipo(new Set<String> {Label.AYUDA_MULTIASISTENCIAS}).values().get(0);
				
			}else {
				ayuda = Util_Ayuda.getMapaAyudaByTipo(new Set<String> {Label.AYUDA_POLIZA_PERTENECE}).values().get(0);
				
			}
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, polizaSeleccionada.perteneceHSMsg + ayuda.AYU_TXT_Descripcion__c));
			existenErrores=true;
		} else if(String.isEmpty(compania.Id)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_FALTA_COMPANIA));
			existenErrores=true;
		}
		return existenErrores;
	}

	public Callout_ConsultaPolizaVesta_RP recuperarPolizaSeleccionada(){
		Callout_ConsultaPolizaVesta_RP polizaSeleccionada=new Callout_ConsultaPolizaVesta_RP();
		String polizaSeleccionadaText = Apexpages.currentPage().getParameters().get('polizaSeleccionada');
		if(!String.isEmpty(polizaSeleccionadaText)){
			polizaSeleccionada=listaPolizas.get(Integer.valueOf(polizaSeleccionadaText));
		}
		return polizaSeleccionada;
	}
	public void mostrarAyudaTelefonoCompania(){
		if(!String.isEmpty(telefonoSeleccionado)){
			Util_Telef_TransferCIA.mostrarAyudaTelefonoCompania(telefonoSeleccionado);
		}
	}

	public PageReference cancelar(){
		PageReference paginaDestino = new PageReference('/' +idCaso);
		paginaDestino.setRedirect(true);
		return paginaDestino;
	}

	public PageReference navegarSiniIntervencionSinPoliza(){
		PageReference paginaDestino=null;
		if(!String.isEmpty(cuentaFiltro.CUE_LKP_Cuenta_Principal__c)){
			if(compania.CUE_CAS_Permite_Apertura_Sin_Poliza__c){
				paginaDestino = Page.Sini_IntervencionSinPoliza;
				paginaDestino.getParameters().put('idCompania',cuentaFiltro.CUE_LKP_Cuenta_Principal__c);
				paginaDestino.getParameters().put('idCaso',idCaso); 
				paginaDestino.getParameters().put(VDN,codigoVDN);
				paginaDestino.setRedirect(true);
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La compañía seleccionada no permite abrir Siniestro sin póliza.'));
			}
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_FALTA_COMPANIA));
		}
		return paginaDestino;
	}

	public void validarAvisoACia(){ 
		existenErroresAvisoCia=false;
		if(String.isEmpty(cuentaFiltro.CUE_LKP_Cuenta_principal__c) || String.isEmpty(compania.Id)){
			existenErroresAvisoCia=true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_FALTA_COMPANIA));	
		}
	}

	private PageReference obtenerURLDestino(String idPoliza,String idCliente, Callout_ConsultaPolizaVesta_RP polizaSeleccionada, Boolean esNuevaPoliza){
		PageReference paginaDestino=Page.AltaConfirmacionCliente;
		paginaDestino.getParameters().put('identificador', identificador);
		paginaDestino.getParameters().put('idPoliza',idPoliza);
		paginaDestino.getParameters().put('id',idCliente);
		paginaDestino.getParameters().put('nuevaPoliza',String.valueOf(esNuevaPoliza));
		paginaDestino.getParameters().put('idCaso',idCaso);
		paginaDestino.getParameters().put('idCompania',compania.Id);
		paginaDestino.getParameters().put(VDN, codigoVDN);
		//Datos de la póliza seleccionada.
		paginaDestino.getParameters().put('telefono1',polizaSeleccionada.telefono1);
		paginaDestino.getParameters().put('telfono2',polizaSeleccionada.telefono2);
		paginaDestino.getParameters().put('telefono3',polizaSeleccionada.telefono3);
		paginaDestino.getParameters().put('telefono4',polizaSeleccionada.telefono4);
		paginaDestino.getParameters().put('nombreCliente', polizaSeleccionada.nombre);
		paginaDestino.getParameters().put('apellido1', polizaSeleccionada.apellido1);
		paginaDestino.getParameters().put('apellido2', polizaSeleccionada.apellido2);
		paginaDestino.getParameters().put('numeroDocumento', polizaSeleccionada.numeroDocumento);
		system.debug('BusquedaClientesPolizaController: obtenerURLDestino: paginaDestino: '+paginaDestino);
		return paginaDestino;
	}

}