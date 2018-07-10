/**
 * Clase controladora de la Visualforce "SiniTipoInterlocutorController" encargada de realizar
 * la validación del Tipo de Interlocutor correspondiente al proceso de apertura de un Siniestro.
 *  
 * @author EVERIS
 */
public without sharing class SiniTipoInterlocutorController {
	public Case caso {get; set;}
	public String codigoVDN {get; set;}
	public ServiceContract poliza {get; set;}
	public List<SelectOption> listaTiposInt {get; set;}
	public String tipoInterlocutor {get; set;}
	public String urlSondeoExterno {get; set;}   
	public String urlRetornoOK {get; set;}
	public String urlRetornoKO {get; set;}
	public Boolean interlocutorAutorizado {get; set;}
	private String idPoliza;

	/**
	 * Constructor de la clase.
	 * 
	 * @param objeto Case principal del controlador
	 */
	public SiniTipoInterlocutorController(ApexPages.standardController stdCtr){
		urlSondeoExterno = label.URL_SINI_SONDEO_EXT;
		PageReference paginaActual = ApexPages.currentPage();
		// Comprobar parámetros de entrada
		if(paginaActual.getParameters().containsKey('VDN')){
			codigoVDN = paginaActual.getParameters().get('VDN');
		}
		if((!paginaActual.getParameters().containsKey('id')) && (!paginaActual.getParameters().containsKey('idPoliza'))){
			System.debug('Sini_TipoInterlocutor: contrucstor: idPoliza: '+idPoliza);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
		}
		else {
			System.debug('Sini_TipoInterlocutor: contrucstor: parametros: '+paginaActual.getParameters());
			System.debug('Sini_TipoInterlocutor: contrucstor: stdCtr.getRecord().Id: '+stdCtr.getRecord().Id);
			
			List<Case> listaCasosQuery = Util_Caso.getCaseById(new Set<Id>{stdCtr.getRecord().Id}).values();
			System.debug('Sini_TipoInterlocutor: contrucstor: listaCasosQuery: '+listaCasosQuery);
			if(!listaCasosQuery.isEmpty()){
				caso = listaCasosQuery.get(0);
			}
			else {
				caso = new Case();
			}
			if(paginaActual.getParameters().containsKey('id') && caso.CAS_LKP_PolizaContrato__c != null){
				// Si existe un caso de Solicitud de Siniestro: obtenemos la póliza asociada al mismo
				idPoliza = caso.CAS_LKP_PolizaContrato__c;
			}
			else {
				// Si no existe un caso de Solicitud de Siniestro: obtenemos la póliza seleccionada a partir del parámetro de entrada
				idPoliza = paginaActual.getParameters().get('idPoliza'); 
			}
			// Si se localiza la póliza correspondiente
			System.debug('Sini_TipoInterlocutor: contrucstor: idPoliza: '+idPoliza);
			List<ServiceContract> listaPolizas = Util_Poliza_Contrato.queryPolizaById(new Set<Id>{idPoliza}).values();
			if(listaPolizas.isEmpty()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
			}
			else {
				poliza = listaPolizas.get(0);

				// Actualizamos la información de la Solicitud por si no viniera informada
				caso.CAS_LKP_PolizaContrato__c = poliza.Id;
				caso.CAS_LKP_VersionPolizaContrato__c = poliza.POL_LKP_Version_Actual__c;
				caso.AccountId = poliza.AccountId;
				caso.CAS_LKP_Compania__c = poliza.POL_LKP_Compania__c;

				if(codigoVDN != null){
					caso.Origin = Label.SINI_ORIGEN_TELEFONO;
				}

				// Cargamos los valores del desplegable filtrados por Compañía
				listaTiposInt = Util_Poliza_Contrato.cargarSelectorTipoInterlocutor(poliza);

				interlocutorAutorizado = false;
			}
		}
	}

	/**
	 * Si el interlocutor seleccionado es Otro u Otros familiares, se deba rellenar el campo "Persona que llama".
	 * 
	 */
	public void campoOtros(){
		if(tipoInterlocutor == 'Otros' || tipoInterlocutor == 'Otros familiares'){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.ERROR_TIPO_INTER_NOMBRE));
		}
	}

	/**
	 * valida si el interlocutor está autorizado comparando con el producto relacionado con la poliza del cliente.
	 * 
	 * @return página destino tras validación
	 */
	public PageReference validarTipoInterlocutor(){ 
		system.debug('>>>>Caso: ' + caso); 
		system.debug('>>>>tipoInterlocutor: ' + tipoInterlocutor); 
		PageReference paginaRedireccion;
		if((tipoInterlocutor == 'Otros' || tipoInterlocutor == 'Otros familiares') && caso.CAS_TXT_Persona_que_llama__c == null){
			caso.CAS_TXT_Persona_que_llama__c.addError(Label.ERROR_TIPO_INTER_NOMBRE);
		}
		else {
			caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_SINIESTRO);
			system.debug('***** >>>>Caso : ' + caso);
			String interlocutoresAutorizados = poliza.POL_LKP_Producto_Cia__r.PRD_LKP_Tipo_Producto_CIA__r.TPR_SEL_Interlocutores_Autorizados__c;
			if(tipoInterlocutor != null && !(';' + interlocutoresAutorizados + ';').contains(';' + tipoInterlocutor + ';')){
				// Si el Tipo de Interlocutor no está autorizado en el Tipo de Producto para la CIA: establecemos la Solicitud de Siniestro como "No Abierta"
				caso.status = label.CAS_ESTADO_CERRADO; //SINI_ESTADO_NO_ABIERTO;
				caso.Type = Label.CAS_TIPO_NOABIERTO ;
				
				
				caso.CAS_SEL_Motivo_No_Apertura__c = Label.SINI_MOTIVO_INTERNOLOC;
				caso.CAS_SEL_Tipo_Interlocutor__c = tipoInterlocutor;
				system.debug('***** >>>>Caso to Upsert: ' + caso);
				upsert caso;

				// Agregamos al Caso un comentario con los interlocutores que sí están autorizados
				String comentario = Label.SINI_ERROR_INTERNOAUT + ' ' + interlocutoresAutorizados;
				insert Util_Caso.crearComentarioCaso(caso.Id, comentario);

				// Redireccionamos al detalle del caso No Abierto
				interlocutorAutorizado = false;
				paginaRedireccion = new PageReference('/' + caso.Id);
				paginaRedireccion.setRedirect(true);
			}
			else {
				// Si el Tipo de Interlocutor está autorizado en el Tipo de Producto para la CIA: establecemos la Solicitud de Siniestro como "Pdte de Sondeo"
				caso.status = Label.SINI_ESTADO_PDTESONDEO;
				caso.CAS_SEL_Tipo_Interlocutor__c = tipoInterlocutor;
				system.debug('***** >>>>Caso to Upsert: ' + caso);
				upsert caso;
				system.debug('>>>>Caso: ' + caso);

				String urlContexto = 'https://' + ApexPages.currentPage().getHeaders().get('Host');
				urlRetornoOK = urlContexto + (new PageReference('/apex/' + label.VF_SINI_RETSONDEOEXT)).getUrl() + '?id=' + caso.Id;
				urlRetornoKO = urlContexto + (new PageReference('/apex/' + label.VF_SINI_RETSONDEOEXT)).getUrl() + '?id=' + caso.Id + '&errorCode=#errorCode#&errorMessage=#errorMessage#';
				if(codigoVDN != null){
					urlRetornoOK += '&VDN=' + codigoVDN;
					urlRetornoKO += '&VDN=' + codigoVDN;
				}

				// Refrescamos la página para actualizar el formulario de envío al Sondeo Externo
				interlocutorAutorizado = true;
				paginaRedireccion = null;
			}
		}
		System.debug('SiniTipoInterlocutorController: validarTipoInterlocutor: caso: '+caso);
		system.debug('>>>>interlocutorAutorizado: ' + interlocutorAutorizado);
		system.debug('>>>>paginaRedireccion: ' + paginaRedireccion);
		return paginaRedireccion;
	}

	/**
	 * Marca la Solicitud como No Abierta y redirecciona a la página correspondiente.
	 * 
	 * @return página destino
	 */
	public PageReference cancelar(){
		Util_Siniestro.cancelarAperturaSiniestro(caso);
		system.debug('********* CANCELADO caso: ' + caso);
		PageReference paginaRedireccion = new PageReference('/apex/' + label.VF_BUSQ_CLIENTES);
		if(codigoVDN != null){
			paginaRedireccion.getParameters().put('VDN', codigoVDN);
		}
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}
}