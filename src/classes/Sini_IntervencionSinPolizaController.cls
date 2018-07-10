/**
 * Clase controladora de la Visualforce "Sini_IntervencionSinPoliza" encargada de buscar/crear un cliente y crear una Asistencia para dicho cuenta.
 * 
 * @author EVERIS
 */
public class Sini_IntervencionSinPolizaController {
	public Account compania {get; set;}
	public Account cuenta {get; set;}
	public Case caso {get; set;}
	public String dniCliente {get; set;}
	public Boolean busqueda {get; set;}
	public Boolean existeCliente {get; set;}
	public String solicitudExistente {get; set;}
	private String codigoVDN{get;set;}
	public List<SelectOption> listaPoblaciones {get; set;}
	public String poblacion {get; set;}
	private Map<String, String> mapaProvincias;
	private Map<String, String> mapaPaises;

	/**
	 * Constructor de la clase
	 */
	public Sini_IntervencionSinPolizaController(){
		solicitudExistente = 'N';
		cuenta = new Account();
		existeCliente = false;
		busqueda = false;
		PageReference paginaActual = ApexPages.currentPage();
		if(paginaActual.getParameters().containsKey('idCompania')){
			compania = Util_Cuentas.getMapCuentasById(new Set<Id>{paginaActual.getParameters().get('idCompania')}).get(paginaActual.getParameters().get('idCompania'));
		}
		if(paginaActual.getParameters().containsKey('VDN')) {
			codigoVDN = paginaActual.getParameters().get('VDN');
		}
		if(paginaActual.getParameters().containsKey('idCaso')){
			caso = Util_Caso.getCaseById(new Set<Id>{paginaActual.getParameters().get('idCaso')}).get(paginaActual.getParameters().get('idCaso'));
			if(caso == null){
				caso = new Case();
			}
			else {
				solicitudExistente = 'Y';
			}
		}
		else {
			caso = new Case();
		}
		mapaProvincias = Util_Listas_Seleccion.getLabelDesdeAPI('Account', 'CUE_SEL_Provincia__c');
		mapaPaises = Util_Listas_Seleccion.getLabelDesdeAPI('Account', 'CUE_SEL_Pais__c');
	}

	/**
	 *	Método para buscar por Número de Documento un cliente en la BD
	 */
	public void clientesEncontrados(){
		listaPoblaciones = null;
		poblacion = null;
		if(dniCliente == null || dniCliente.trim() == ''){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Es necesario introducir un valor de Nº de Documento.'));
		}
		else {
			busqueda = true;
			List<Account> resultados = Util_Cuentas.queryCuentasByNumeroDocumento(new Set<String>{dniCliente}, new Set<String>{compania.Id}).values();
			if(resultados.isEmpty()) {
				existeCliente = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No existe ningún Cliente Asegurado de ' + compania.Name + ' con Nº de Documento ' + dniCliente + ' registrado en el sistema. Informe los datos del nuevo Cliente.'));
				cuenta = new Account();
				cuenta.CUE_TXT_Numero_Documento__c = dniCliente;
				cuenta.CUE_LKP_Cuenta_Principal__c = compania.Id;
				cuenta.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTE_ASEGURADO);
			}
			else {
				existeCliente = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'El Cliente Asegurado de ' + compania.Name + ' con Nº de Documento ' + dniCliente + ' está registrado en el sistema. Verifique los datos del Cliente.'));
				cuenta = resultados.get(0);
				cargarListaPoblacionPorCP();
			}
			dniCliente = null;
		}
	}

	/*
	*	Método para obtener la/s población/es a partir del CP
	*/
	public void cargarListaPoblacionPorCP(){
		listaPoblaciones = Util_TerritorioServicio.cargarListaPoblacionPorCP(cuenta.ShippingPostalCode);
		if((poblacion == null) || (poblacion.equals(''))){
			poblacion = listaPoblaciones.get(0).getValue(); //CódigoProvincia#NombrePoblación
		}
		cuenta.ShippingCity = null;
		cuenta.CUE_SEL_Provincia__c = null;
		if(listaPoblaciones.size() > 1){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_POBLACIONES_CP));
		}
		else if(listaPoblaciones.get(0).getValue() == '' && listaPoblaciones.size() == 1){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_MUNICIPIOS_NO_CP));
		}
		else {
			cargarProvinciaPoblacion();
		}
	}

	/*
	 *	Método para obtener la/s provincia/es a partir del CP
	 */
	public void cargarProvinciaPoblacion(){
		cuenta.ShippingCity = Util_TerritorioServicio.obtenerPoblacionSel(poblacion);
		cuenta.CUE_SEL_Provincia__c = Util_TerritorioServicio.obtenerProvinciaSel(poblacion);
	}

	/**
	 *	Método para volver a la Página Busqueda Polizas
	 */
	public PageReference volver(){ 
		PageReference paginaRedireccion = Page.BusquedaClientesPoliza;
		if(!String.isEmpty(caso.ID)){
			paginaRedireccion.getParameters().put('caseId',caso.Id);
		}
		else if(!String.isEmpty(codigoVDN)){
			paginaRedireccion.getParameters().put('VDN',codigoVDN);
		}
		else {
			paginaRedireccion.getParameters().put('idCompania',compania.Id);
		}
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}

	public PageReference continuar(){
		PageReference paginaRedireccion = null;
		// Validación de campos requeridos
		if(cuenta.CUE_TXT_Numero_Documento__c == null || cuenta.CUE_TXT_Numero_Documento__c.trim() == '' ||
			cuenta.CUE_TXT_Nombre__c == null || cuenta.CUE_TXT_Nombre__c.trim() == '' ||
			cuenta.CUE_TXT_PrimerApellido__c == null || cuenta.CUE_TXT_PrimerApellido__c.trim() == '' ||
			cuenta.ShippingPostalCode == null || cuenta.ShippingPostalCode.trim() == '' ||
			cuenta.ShippingStreet == null || cuenta.ShippingStreet.trim() == '' ||
			cuenta.ShippingCity == null || cuenta.ShippingCity.trim() == '' ||
			cuenta.CUE_SEL_Pais__c == null || cuenta.CUE_SEL_Pais__c == '' ||
			caso.CAS_TFN_Solicitud_Telefono__c == null || caso.CAS_TFN_Solicitud_Telefono__c.trim() == ''){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_FALTAN_CAMPOS_OBLIGATORIOS));
		}
		else {
			// Si se ha modificado el Nº de Documento respecto al que se buscó inicialmente
			List<Account> resultados = Util_Cuentas.queryCuentasByNumeroDocumento(new Set<String>{cuenta.CUE_TXT_Numero_Documento__c}, new Set<String>{compania.Id}).values();
			if(!resultados.isEmpty() && resultados.get(0).Id != cuenta.Id){
				// Si existe otro Cliente Asegurado que no es el actual:
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Existe otro Cliente Asegurado de ' + compania.Name + ' con Nº de Documento ' + cuenta.CUE_TXT_Numero_Documento__c + '. Modifique el Nº de Documento o localice de nuevo al Cliente para cargar los datos correspondientes al nuevo Nº de Documento informado.'));
			}
			else {
				system.Savepoint puntoGuardado = Database.setSavepoint();
				try {
					// Insertar/Actualizar Cliente Asegurado
					cuenta.Name = cuenta.CUE_TXT_Nombre__c + ' ' + cuenta.CUE_TXT_PrimerApellido__c;
					if(cuenta.CUE_TXT_SegundoApellido__c != null){
						cuenta.Name += ' ' + cuenta.CUE_TXT_SegundoApellido__c;
					}
					cuenta.ShippingState = mapaProvincias.get(cuenta.CUE_SEL_Provincia__c);
					cuenta.ShippingCountry = mapaPaises.get(cuenta.CUE_SEL_Pais__c);
					if(cuenta.Id == null){
						cuenta.CUE_CAS_Activado__c = true;				
					}
					upsert cuenta;
	
					// Insertar/Actualizar Solcitud de Asistencia
					caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2C);
					caso.CAS_LKP_Compania__c = compania.Id;
					caso.AccountId = cuenta.Id;
					caso.CAS_TXT_Direccion__c = cuenta.ShippingStreet;
					caso.CAS_TXT_DirRiesgo_Poblacion__c = cuenta.ShippingCity;
					caso.CAS_TXT_DirRiesgo_CP__c = cuenta.ShippingPostalCode;
					caso.CAS_TXT_DirRiesgo_Pais__c = cuenta.ShippingCountry;
					caso.CAS_SEL_DirRiesgo_Estado_Provincia__c = cuenta.CUE_SEL_Provincia__c;
					caso.CAS_LKP_Cliente_contable_cliente__c = cuenta.Id;
					caso.CAS_TXT_Nombre__c = cuenta.CUE_TXT_Nombre__c;
					caso.CAS_TXT_Apellidos__c = cuenta.CUE_TXT_PrimerApellido__c;
					upsert caso;
	
					// Redirigir a la Selección de Gremios
					paginaRedireccion = new PageReference('/apex/' + Label.VF_B2B_GREMIOS);
					paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, Label.SINI_FASE_APERTURA);
					paginaRedireccion.getParameters().put('id', caso.Id);
					paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
					paginaRedireccion.getParameters().put('inline', '1');
					paginaRedireccion.setRedirect(true);
				}
				catch(DmlException e){
					Database.rollback(puntoGuardado);
					system.debug('>>>>>>>>>>>>>EXCEPTION: 1' + e.getStackTraceString());
					system.debug('>>>>>>>>>>>>>EXCEPTION: 2' + e.getDmlType(0));
					system.debug('>>>>>>>>>>>>>EXCEPTION: 3' + StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
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
		return paginaRedireccion;
	}
}