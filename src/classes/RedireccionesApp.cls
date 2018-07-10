/**
 * Clase controladora de la Visualforce "RedireccionesApp" que se encarga de redireccionar a B2B_Gremio para crear una solicitud de servicio B2C
 * con el mismo cliente del caso de la página actual.
 * 
 * @author EVERIS
 */
public without sharing class RedireccionesApp {
	public Case caso {get; set;}
	public WorkOrder wo {get; set;}
	public String tipo {get; set;}
	
	public RedireccionesApp(ApexPages.standardController stdCtr){
		PageReference paginaActual = ApexPages.currentPage();

		if (paginaActual.getParameters().containsKey('id')){
			List<Case> listaCasos = Util_Caso.getCaseById(new Set <Id>{(Id)paginaActual.getParameters().get('id')} ).values();
			if (!listaCasos.isEmpty()){
				caso = listaCasos.get(0);
			}
			else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
			}
		}
		if (paginaActual.getParameters().containsKey('tipo')){
			tipo = (String)paginaActual.getParameters().get('tipo');
		}
	}

	/**
	 * Método que llama al método correspondiente para cada redirección
	 * 
	 * @return PageReference devuelto para la redirección a B2B_Gremios.
	 * @author EVERIS
	 */
	public PageReference redireccion(){
		PageReference paginaRedireccion;
		if(tipo == 'APERTURAB2C'){
			paginaRedireccion = casoNuevo();
		}else if (tipo == 'TRAMITACION'){
			paginaRedireccion = redireccionTramitacion();
		}
		return paginaRedireccion;
	}


	/**
	 * Método que redirige a la visual de tramitación en función del tipo de caso.
	 * 
	 * @return PageReference devuelto para la redirección a B2B_Reparable.
	 * @author EVERIS
	 */
	public PageReference redireccionTramitacion(){
		PageReference paginaRedireccion;
		if(caso.recordtype.name == 'Siniestro' || caso.recordtype.name == 'Siniestro Membership'|| caso.recordtype.name == 'Solicitud de Siniestro'){
			paginaRedireccion = new PageReference ('/apex/' + 'Sini_Reparable');
			paginaRedireccion.getParameters().put('inline', '1');
		}
		else {
			paginaRedireccion = new PageReference ('/apex/' + 'B2B_Reparable');
		}   
		paginaRedireccion.getParameters().put('id', caso.id);
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}  


	/**
	 * Método que crea un caso nuevo copiando la cuenta, dirección, código postal, población, provincia y país del caso de la página actual
	 * y que redirecciona a B2B_Gremios llamando a redireccionB2BGremios.
	 * 
	 * @return PageReference devuelto para la redirección a B2B_Gremios.
	 * @author EVERIS
	 */
	public PageReference casoNuevo(){
		PageReference paginaRedireccion;
		if(caso.recordtype.name == 'Reclamación' || caso.recordtype.name == 'Solicitud de Reclamación'){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No es posible solicitar la apertura de un Servicio B2C desde una Reclamación'));
		}
		else {
			if (caso != null){
				Case nuevoCaso = new Case();
				nuevoCaso.AccountId = caso.AccountId;															// Seteamos la cuenta
				nuevoCaso.CAS_TXT_Direccion__c = caso.CAS_TXT_Direccion__c;										// Seteamos la direccción
				nuevoCaso.CAS_TXT_DirRiesgo_CP__c = caso.CAS_TXT_DirRiesgo_CP__c;  								// Seteamos el código postal
				nuevoCaso.CAS_TXT_DirRiesgo_Poblacion__c = caso.CAS_TXT_DirRiesgo_Poblacion__c;  				// Seteamos la población
				nuevoCaso.CAS_SEL_DirRiesgo_Estado_Provincia__c = caso.CAS_SEL_DirRiesgo_Estado_Provincia__c;	// Seteamos la provincia
				nuevoCaso.CAS_TXT_DirRiesgo_Pais__c = caso.CAS_TXT_DirRiesgo_Pais__c;							// Seteamos el pais
				nuevoCaso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2C);	// Seteamos el record type
				try {
					insert nuevoCaso;
					paginaRedireccion = redireccionB2BGremios(nuevoCaso.Id);  // Redireccionamos a B2B_Gremios
				}
				catch (Exception e){
					system.debug(e.getMessage());
				}
			}
		}
		return paginaRedireccion;
	}

	/**
	 * Método que realiza la redirección a B2B_Gremios pasando los parámetros fase = 'APERTURA' e id = <el id pasado por parámetro>.
	 * 
	 * @param id Es el id pasado como parámetro en la redirección a B2B_Gremios.
	 * @return PageReference devuelto para la redirección a B2B_Gremios.
	 * @author EVERIS
	 */
	public PageReference redireccionB2BGremios(Id id){
		PageReference paginaRedireccion = new PageReference ('/apex/' + Label.VF_B2B_GREMIOS);
		paginaRedireccion.getParameters().put('id', id);
		paginaRedireccion.getParameters().put('fase', 'APERTURA');
		paginaRedireccion.setRedirect(true);

		return paginaRedireccion;
	}
}