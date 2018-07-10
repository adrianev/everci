/**
 * Clase controladora de la Visualforce "SiniContactosController" encargada de agregar nuevos contactos a un Siniestro.
 * 
 * @author EVERIS
 */ 
public without sharing class SiniContactosController {

	public String fase {get; set;}
	private String codigoVDN;
	public Case caso {get; set;}
	public Contacto_telefonico__c nuevoContactoT {get; set;}
	public Contact nuevoContacto {get; set;}
	public Boolean creacionContacto {get; set;}
	public Boolean actualizacionContacto {get;set;}
	public List<Contacto_telefonico__c> listaContactosCaso {get; set;}
	public List<Contacto_telefonico__c> listaContactosPoliza {get; set;}
	public Integer indiceListaContactos {get; set;}
	public Integer indiceResultado {get; set;}
	public Boolean contactoDePoliza {get; set;}
	public Boolean casoSinPoliza{get; set;}
	public String tituloFormularioEdicion {get; set;}
	public List<ServiceContract> listaPolizaActiva;
	private String paginaRetorno;
	public String mensajeAsignarPerito;

	private Boolean finalizarAperturaSaleforceMostradoMensajePartidas;
	public Boolean aperturaFinalizadaSalesforceCorrectamente {get;set;}
	private String mensajesInfofinalizarAperturaSalesforce;
	private String mensajesErrorfinalizarAperturaSalesforce;
	//Mensaje de Error del botón Salir.
	private String mensajeErrorSalir;
	//Grave - Perito - Urgente
	private Boolean convertidoAGrave;
		private String idPerito;
	private String idConfirmacion{get;set;}
	private String numeroGremiosArbolSalida{get;set;}
	public Boolean finalizarApertura {get; set;}

	/**
	 * Constructor de la clase.
	 * 
	 * @param objeto Case principal del controlador
	 */
	public SiniContactosController(ApexPages.standardController stdCtr){
		finalizarApertura = false;
		idPerito = '';
		mensajeErrorSalir='';
		mensajesInfofinalizarAperturaSalesforce='';
		mensajesErrorfinalizarAperturaSalesforce='';
		finalizarAperturaSaleforceMostradoMensajePartidas = false;
		convertidoAGrave=false;
		aperturaFinalizadaSalesforceCorrectamente=false;
		casoSinPoliza = true;
		mensajeAsignarPerito = '';
		PageReference paginaActual = ApexPages.currentPage();

		if(paginaActual.getParameters().containsKey('fase')){
			fase = paginaActual.getParameters().get('fase');
		}
		if(paginaActual.getParameters().containsKey('numeroGremiosArbolSalida')){
			numeroGremiosArbolSalida=paginaActual.getParameters().get('numeroGremiosArbolSalida');
		}
		if(paginaActual.getParameters().containsKey('idConfirmacion')) {
			idConfirmacion=paginaActual.getParameters().get('idConfirmacion');
		}
		if(paginaActual.getParameters().containsKey('VDN')){
			codigoVDN = paginaActual.getParameters().get('VDN');
		}

		if(paginaActual.getParameters().containsKey('retorno')){
			paginaRetorno = paginaActual.getParameters().get('retorno');
		}
		// Comprobar parámetros de entrada
		if(!paginaActual.getParameters().containsKey('id')){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
		}
		else {
			
			List<String> fields = new List<String> {'Account.Name', 'CAS_CAS_Siniestro_Grave__c','CAS_LKP_VersionPolizaContrato__r.POLV_FOR_Segmentacion__c' , 'CAS_LKP_VersionPolizaContrato__r.POLV_SEL_Tipo_Riesgo__c', 'CAS_LKP_PolizaContrato__r.POL_LKP_Producto_Cia__r.Name', 'ParentId','CAS_LKP_PolizaContrato__c', 'CAS_LKP_PolizaContrato__r.Name', 
				'CaseNumber', 'Type', 'Status','CAS_TXT_Num_Caso_CIA__c','CAS_TXT_Num_Caso_HS__c','CAS_LKP_PolizaContrato__c', 'CAS_LKP_PolizaContrato__r.Name', 'Parent', 'Parent.Type', 
				'CAS_LKP_Compania__r.Name', 'CAS_FOR_Direccion_Riesgo__c','CAS_LKP_Procedencia__c','CAS_TXT_Subestado_Caso__c','CAS_FOR_Limite_Actuacion__c','CAS_LKP_Compania__r.CUE_TXT_Identificador__c','CAS_DIV_Importe_Total__c','RecordType.Name','CAS_CAS_Requiere_Perito__c','CAS_LKP_Perito__c','Account.CUE_TXT_Identificador__c','Account.CUE_TXT_Identificador__c'};
				if (!Test.isRunningTest()) stdCtr.addFields(fields);
				caso = (Case)stdCtr.getRecord();
				for(Case casoAux:Util_Caso.getCaseById(new Set<Id>{caso.Id}).values()) {
					caso=casoAux;
				}
				system.debug('***************** caso.CAS_LKP_PolizaContrato__c: ' + caso.CAS_LKP_PolizaContrato__c);
				
				
				if(caso.CAS_LKP_PolizaContrato__c != null){//SI EL CASO TIENE UNA PÓLIZA VINCULADA
					// RECOJO LA ÚLTIMA VERSIÓN DE LA PÓLIZA (HAGO UNA SELECT QUE RECOJA EL ID DE LA PÓLIZA QUE TIENE LA última version y ese mismo nombre)
					//PREV
					//listaPolizaActiva = Util_Poliza_Contrato.queryMapPoliza('POL_CAS_Activo__c = true AND Name = \''+caso.CAS_LKP_PolizaContrato__r.Name+'\'').values();
					//NEW
					listaPolizaActiva = Util_Poliza_Contrato.queryPolizaById(new Set<Id>{caso.CAS_LKP_PolizaContrato__c}).values();
					
					// EN EL WHERE PONGO EL ID DE LA PÓLIZA QUE HA DEVUELTO LA SELECT DE LA ULTIMA VERSION DE LA PÓLIZA
					//PREV: listaContactosPoliza = Util_Contacto_Telefonico.queryContactoTelefonico(null,listaPolizaActiva.get(0).Id,null,null);
					//NEW:
					listaContactosPoliza = Util_Contacto_Telefonico.queryContactoTelefonicoByPolizaId(new Set<Id>{listaPolizaActiva.get(0).Id}).values();
			

					system.debug('*********************** listaContactosPoliza : ' + listaContactosPoliza);
					//Comprobación listaContactosPoliza
					
					//PREV: listaContactosCaso = Util_Contacto_Telefonico.queryContactoTelefonico(null,null,caso.Id,null);
					//NEW:
					listaContactosCaso = Util_Contacto_Telefonico.queryMapCTByCaseId(new Set <Id> {caso.Id}).values();


					system.debug('**************** listaContactosCaso : ' + listaContactosCaso);
					
					

					if (paginaActual.getParameters().containsKey('guardadoOK')){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
					}
				}
				//SI NO TIENE PÓLIZA VINCULADA
				else {
					casoSinPoliza = false;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_CASO_SIN_POLIZA));
				}
				idPerito=caso.CAS_LKP_Perito__c;
		}
		creacionContacto = false;
		actualizacionContacto = false;

	}//FIN CONSTRUCTOR

	/**
	 * Método asociado al botón "Nuevo Contacto".
	 */
	public void crearContacto()
	{
		creacionContacto = true;
		actualizacionContacto = false;
		nuevoContactoT = new Contacto_telefonico__c();
		nuevoContacto = new Contact();
		tituloFormularioEdicion = 'Datos de nuevo contacto';
	}//FIN crearContacto()

	/**
	 * Método asociado al botón "Guardar Contacto" mientras se edita un contacto.
	 * @return redirección a la página actual
	 */
	public PageReference guardarContacto(){   
		PageReference paginaRedireccion = null;
		Boolean errorTelefono = false;
		system.Savepoint puntoGuardado = Database.setSavepoint();
		try
		{
			nuevoContacto.AccountId = caso.AccountId;
			if (creacionContacto)
			{
				system.debug('********************** guardarContacto_crear: nuevoContacto: ' + nuevoContacto);
				if( !validarTelefono(nuevoContacto.Phone)&& !validarTelefono(nuevoContacto.HomePhone) && !validarTelefono(nuevoContacto.MobilePhone) ){
					insert nuevoContacto;
					nuevoContactoT.CTF_LKP_Contacto__c = nuevoContacto.Id;
					nuevoContactoT.CTF_LKP_Caso__c = caso.Id;
					nuevoContactoT.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CTF_CASO);
					insert nuevoContactoT;
					marcarContactoPoliza(nuevoContactoT.CTF_CAS_Contacto_Poliza__c);
				}
				else{
					errorTelefono =true;
				}
			}
			else if (actualizacionContacto)
			{
				system.debug('********************** guardarContacto_actualizar: nuevoContacto: ' + nuevoContacto);
				system.debug('********************** guardarContacto_actualizar: nuevoContactoT: ' + nuevoContactoT);
				if( !validarTelefono(nuevoContacto.Phone) &&  !validarTelefono(nuevoContacto.HomePhone) && !validarTelefono(nuevoContacto.MobilePhone)){
					update nuevoContacto;
					update nuevoContactoT;
					marcarContactoPoliza(nuevoContactoT.CTF_CAS_Contacto_Poliza__c);
				}
				else{
					errorTelefono =true;
				}
			
			}
			if(errorTelefono){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error de Validación de teléfonos.'));
			}
			else{
			paginaRedireccion = new PageReference('/apex/' + Label.VF_SINI_CONTACTOS);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, paginaRetorno);
			paginaRedireccion.getParameters().put('guardadoOK', 'Y');
			paginaRedireccion.setRedirect(true);
			}
		}
		catch(DmlException e)
		{
			Database.rollback(puntoGuardado);
			system.debug(e.getStackTraceString());
           	if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
            }
     	}
		catch(Exception e)
		{
			Database.rollback(puntoGuardado);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			system.debug(e.getStackTraceString());
		}
		return paginaRedireccion;
	}//Fin guardarContacto


	/**
	 * Crea un ContactoPóliza a partir del ContactoCaso editado.
	 * @param checkContactoPoliza Indica si está marcado el check de ContactoPoliza en el ContactoCaso
	 */
	private void marcarContactoPoliza(Boolean checkContactoPoliza){
		// Si el check está marcado y no hay contacto póliza: lo creamos
		if (checkContactoPoliza){
			List<Contacto_telefonico__c> contactoPolizaExistente = Util_Contacto_Telefonico.getContTelByContactoyPoliza(new Set<Id>{nuevoContacto.Id},new Set<Id>{caso.CAS_LKP_PolizaContrato__c}).values();
			//List<Contacto_telefonico__c> contactoPolizaExistente = Util_Contacto_Telefonico.queryContactoTelefonico(null,caso.CAS_LKP_PolizaContrato__c,null,nuevoContacto.Id);
			/*List<Contacto_telefonico__c> contactoPolizaExistente = new List<Contacto_telefonico__c> ([
			                                                                                          SELECT Id 
			                                                                                          FROM Contacto_telefonico__c
			                                                                                          WHERE CTF_LKP_Contacto__c = :nuevoContacto.Id
			                                                                                          AND CTF_LKP_Poliza_Contrato__c = :caso.CAS_LKP_PolizaContrato__c]);*/
			if(contactoPolizaExistente.isEmpty()){
				Contacto_telefonico__c cTP = new Contacto_telefonico__c();
				cTP = nuevoContactoT.clone(false, true);
				cTP.CTF_LKP_Poliza_Contrato__c = listaPolizaActiva.get(0).Id;
				CTP.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CTF_POLIZA);
				cTP.CTF_LKP_Caso__c = null;
				system.debug('************************* cTP : ' + cTP);
				insert cTP;
			}
		}
	}

	/**
	 * Método asociado al botón "Cancelar" mientras se edita un contacto.
	 */
	public void cancelarCreacionContacto()
	{
		nuevoContacto = null;
		nuevoContactoT = null;
		creacionContacto = false;
		actualizacionContacto = false;
	}

	/**
	 * Método asociado a la acción de doble-clic uno de los listados.
	 */
	public void seleccionarResultado()
	{
		// Si se hace doble-clic sobre el listado de Contactos de la Póliza: vinculamos el contacto al Siniestro
		if (contactoDePoliza)
		{
			system.Savepoint puntoGuardado = Database.setSavepoint();
			try
			{
				Contacto_telefonico__c contactoSelec = listaContactosPoliza.get(indiceResultado);
				//PREV: List<Contacto_telefonico__c> contactosExistentes = Util_Contacto_Telefonico.queryContactoTelefonico(null,null,caso.Id,contactoSelec.CTF_LKP_Contacto__c);
				//NEW:
				List<Contacto_telefonico__c> contactosExistentes = Util_Contacto_Telefonico.queryMapCTByCaseIdAndContact(new Set<Id> {caso.Id} ,new Set<Id> {(Id)contactoSelec.CTF_LKP_Contacto__c}).values();
				/*List<Contacto_telefonico__c> contactosExistentes = new List<Contacto_telefonico__c> ([
				                                                                                      SELECT Id 
				                                                                                      FROM Contacto_telefonico__c
				                                                                                      WHERE CTF_LKP_Contacto__c = :contactoSelec.CTF_LKP_Contacto__c AND CTF_LKP_Caso__c = :caso.Id]);*/
				system.debug('************** contactosExistentes : ' + contactosExistentes);
				if (contactosExistentes.isEmpty())
				{ 
					Contacto_telefonico__c cTC = new Contacto_telefonico__c();
					cTC = contactoSelec.clone(false, true);
					cTC.CTF_LKP_Poliza_Contrato__c = null;
					cTC.CTF_LKP_Caso__c = caso.Id;
					cTC.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CTF_CASO);
					cTC.CTF_CAS_Contacto_Poliza__c = true;
					system.debug('************************* cTC : ' + cTC);
					insert cTC;

					//PREV: Contacto_telefonico__c nuevoContactoCaso = Util_Contacto_Telefonico.queryContactoTelefonico(cTC.Id);
					//NEW
					Contacto_telefonico__c nuevoContactoCaso = Util_Contacto_Telefonico.queryMapCT(new Set<Id>{cTC.Id}).values()[0];
					/*Contacto_telefonico__c nuevoContactoCaso = [SELECT CTF_LKP_Caso__c, 
					                                            CTF_LKP_Contacto__c, 
					                                            CTF_CAS_Contacto_Poliza__c, 
					                                            CTF_FOR_Email__c, 
					                                            CTF_FOR_Apellidos__c, 
					                                            CTF_SEL_Hora_desde__c, 
					                                            CTF_SEL_Hora_hasta__c, 
					                                            CTF_FOR_Nombre__c, 
					                                            CTF_TXT_Observaciones__c, 
					                                            CTF_FOR_Poliza_Contrato__c,
					                                            CTF_LKP_Poliza_Contrato__c, 
					                                            CTF_CAS_SMS__c, 
					                                            CTF_FOR_Telefono__c,
					                                            CTF_FOR_TelefonoAdicional__c,
					                                            CTF_FOR_TelefonoMovil__c,
					                                            CTF_SEL_Tipo_Relacion__c,
					                                            RecordTypeId
					                                            FROM Contacto_telefonico__c
					                                            WHERE Id = :cTC.Id];*/

					listaContactosCaso.add(nuevoContactoCaso);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
				}
				else
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.ERROR_CONT_CASO_EXISTENTE));
				}
			}
			catch(DmlException e)
			{
				Database.rollback(puntoGuardado);
				system.debug(e.getStackTraceString());
           		if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
            	}
     		}
			catch(Exception e)
			{
				Database.rollback(puntoGuardado);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
				system.debug(e.getStackTraceString());
			}
		}
		// Si se hace doble-clic sobre el listado de Contactos del Siniestro: se abre en modo edición el contacto
		else
		{
			system.debug('SiniContactosController : seleccionarResultado : indiceResultado : '+indiceResultado);
			system.debug('SiniContactosController : seleccionarResultado : listaContactosCaso : '+listaContactosCaso);
			if(listaContactosCaso != null){
				nuevoContactoT = listaContactosCaso.get(indiceResultado);
			}
			if(nuevoContactoT != null){
				//PREV:List<Contact> listaContactos = Util_Contacto.queryContacto(nuevoContactoT.CTF_LKP_Contacto__c,null);
				//NEW:
				List<Contact> listaContactos = Util_Contacto.getContactById(new Set<Id>{nuevoContactoT.CTF_LKP_Contacto__c}).values();
				/*List<Contact> listaContactos = new List<Contact> ([SELECT Id,
				                                                   FirstName, LastName, Phone, MobilePhone, HomePhone, email 
				                                                   FROM Contact
				                                                   WHERE Id = :nuevoContactoT.CTF_LKP_Contacto__c]);*/
				if (!listaContactos.isEmpty())
				{
					nuevoContacto = listaContactos.get(0);
					creacionContacto = false;
					actualizacionContacto = true;
					tituloFormularioEdicion = 'Datos de actualización de contacto';
				}
				else
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
				}
			}
		}   
	}// FIN seleccionarResultado

	/**
	 * Método asociado al botón "Eliminar" del listado de contactos del Siniestro.
	 */
	public void eliminarContacto()
	{
		Contacto_telefonico__c contactoTelEliminar = listaContactosCaso.get(indiceListaContactos-1);
		//PREV:	List<Contact> contactoEliminar = Util_Contacto.queryContacto(contactoTelEliminar.CTF_LKP_Contacto__c,null);
		//NEW:
		List<Contact> contactoEliminar=new List<Contact>();
		if(!String.isEmpty(contactoTelEliminar.CTF_LKP_Contacto__c)) {
			contactoEliminar.add(new Contact(Id=contactoTelEliminar.CTF_LKP_Contacto__c));
		}
		//List<Contact> contactoEliminar = Util_Contacto.getContactById(new Set<Id>{contactoTelEliminar.CTF_LKP_Contacto__c}).values();
		/*List<Contact> contactoEliminar = new List<Contact> ([
		                                                     SELECT Id 
		                                                     FROM Contact
		                                                     WHERE Id = :contactoTelEliminar.CTF_LKP_Contacto__c]);*/
		system.debug('******************* contactoTelEliminar: ' + contactoTelEliminar);
		system.debug('******************* contactoEliminar: ' + contactoEliminar);
		system.Savepoint puntoGuardado = Database.setSavepoint();
		try
		{
			// Si el contacto solo está vinculado al Siniestro:
			if ((!contactoTelEliminar.CTF_CAS_Contacto_Poliza__c) && (!contactoEliminar.isEmpty()))
			{
				// eliminamos el objeto Contact (eliminación en cascada Master-Detail)
				delete contactoEliminar.get(0);
			}
			// Si el contacto también está vinculado a la Póliza:
			else
			{
				// eliminamos solo el objeto Contacto del Caso
				delete contactoTelEliminar;
			}
			listaContactosCaso.remove(indiceListaContactos-1);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
		}
		catch(DmlException e)
		{
			Database.rollback(puntoGuardado);
			system.debug(e.getStackTraceString());
           	if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
            }
     	}
		catch(Exception e)
		{
			Database.rollback(puntoGuardado);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			system.debug(e.getStackTraceString());
		}
	}//FIN eliminarContacto 

	public PageReference volver()
	{
		PageReference paginaRedireccion = new PageReference('/' + caso.Id);
		if (paginaRetorno != null)
		{
			paginaRedireccion = new PageReference(paginaRetorno);
			paginaRedireccion.getParameters().put('numeroGremiosArbolSalida',numeroGremiosArbolSalida);
			paginaRedireccion.getParameters().put('idConfirmacion',idConfirmacion);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, null); 
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN volver()

	private PageReference agregarParametrosURL(PageReference paginaRedireccion, Id idCaso, String retorno)
	{
		paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
		if (idCaso != null)
		{
			paginaRedireccion.getParameters().put('id', idCaso);
		}
		if(!String.isEmpty(idConfirmacion)) {
			paginaRedireccion.getParameters().put('idConfirmacion',idConfirmacion);
		}
		if (retorno != null)
		{
			paginaRedireccion.getParameters().put('retorno', retorno);
		}
		if (codigoVDN != null)
		{
			paginaRedireccion.getParameters().put('VDN', codigoVDN);
		}
		if(!String.isEmpty(String.valueOf(numeroGremiosArbolSalida))) {
			paginaRedireccion.getParameters().put('numeroGremiosArbolSalida',numeroGremiosArbolSalida);
		}
		return paginaRedireccion;
	}//FIN agregarParametrosURL()

	private  boolean validarTelefono(String tfno) {
		Boolean existenErrores=false;
		if(tfno !=null && tfno != '' ){
			Pattern patternFijos = Pattern.compile('^(\\+34|0034|34)?[89]\\d{8}$');
			Pattern patternMoviles = Pattern.compile('^(\\+34|0034|34)?[67]\\d{8}$');
			Matcher macheaFijo = patternFijos.matcher(tfno);
			Matcher macheaMovil = patternMoviles.matcher(tfno);
			if(!macheaFijo.matches() && !macheaMovil.matches()) {
				existenErrores=true;
			}
		}
		
		return existenErrores;
	}
	
	
		private void generaMovimientos(){
		if (Util_Siniestro.esSiniestro(caso)){
			if(caso.CAS_LKP_Perito__c != null && idPerito != caso.CAS_LKP_Perito__c){
				Util_Movimientos.compruebaEnviable(caso.Id,caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'39');
				idPerito = caso.CAS_LKP_Perito__c;
			}
		}
	}
	
	
	
	private void convertirAGrave()
	{
		system.Savepoint puntoGuardado = Database.setSavepoint();
		try
		{
			caso.CAS_CAS_Siniestro_Grave__c = true;
			update caso;
			generaMovimientos();
		}
		catch(DmlException e){
			Database.rollback(puntoGuardado);
			system.debug(e.getStackTraceString());
			if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			}
		}
		catch(Exception e)
		{
			Database.rollback(puntoGuardado);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			system.debug(e.getStackTraceString());
		}
	}
	
	public void finalizarAperturaSalesforce() {
		System.debug('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<finalizarApertura: ' + finalizarApertura);
		System.debug('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<caso.CAS_CAS_Requiere_Perito__c: ' + caso.CAS_CAS_Requiere_Perito__c);
		if(!finalizarApertura) {
			System.debug('SiniReparableAperturaController: finalizarAperturaSalesforce: finalizarAperturaSaleforceMostradoMensajePartidas: '+finalizarAperturaSaleforceMostradoMensajePartidas);
			//Si no está marcado el check: comprobamos los límites
			caso.CAS_LKP_Gestor_Apertura__c = UserInfo.getUserId();
			if (!caso.CAS_CAS_Siniestro_Grave__c) {
				//SE COMPRUEBA SI CUMPLE LAS CONDICIONES PARA SER GRAVE
				if (Util_Siniestro.validarCondicionesSiniGrave(caso)) {
					convertirAGrave();
					convertidoAGrave = true;
				}
			}
			if(caso.CAS_CAS_Requiere_Perito__c){
				asignarPerito();
			}
			//Si ya era grave o no se ha convertido: continuamos.
			if (!convertidoAGrave) {
				try {
					caso.Status = Label.CAS_ESTADO_EN_CURSO;
					Util_Siniestro.finalizarAperturaSiniestro(caso);
					//Si se ha finalizado correctamente en SF, muestro el botón que avisa a Vesta.
					aperturaFinalizadaSalesforceCorrectamente=true;
					mensajesErrorfinalizarAperturaSalesforce='';
					mensajesInfofinalizarAperturaSalesforce=''; 
				} catch(DmlException e){
					System.debug('SiniReparableAperturaController: finalizarAperturaSalesforce:  e.getStackTraceString: ' + e.getStackTraceString());
					mensajesErrorfinalizarAperturaSalesforce=Label.ERROR_GUARDAR + ' : ' + e.getMessage();
				} catch(Exception e) {
						mensajesErrorfinalizarAperturaSalesforce=Label.ERROR_GUARDAR + ' : ' + e.getMessage();
						System.debug('SiniReparableAperturaController: finalizarAperturaSalesforce:  e.getStackTraceString: ' + e.getStackTraceString());
				}
			}
			System.debug('SiniReparableAperturaController: finalizarAperturaSalesforce: FIN'); 
		
		}
	}//FIN finalizarApertura_paso1

	public PageReference finalizarAperturaVesta(){
		PageReference paginaNavegar = null;
		if(!finalizarApertura) {
			if(!String.isEmpty(mensajeAsignarPerito)){
				if(mensajeAsignarPerito == Label.INFO_PERITO_ASIGNADO){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, mensajeAsignarPerito));
				}
				else {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, mensajeAsignarPerito));
				}
			}
			System.debug('SiniReparableAperturaController: finalizarAperturaVesta: INICIO'); 
			System.debug('SiniReparableAperturaController: finalizarAperturaVesta: finalizarAperturaSaleforceMostradoMensajePartidas: '+finalizarAperturaSaleforceMostradoMensajePartidas); 
			Callout_ActualizaSiniestroVesta.Resultado resultadoUpdVesta;
				if (!String.isEmpty(mensajesErrorfinalizarAperturaSalesforce)) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,mensajesErrorfinalizarAperturaSalesforce));
				} else if (!String.isEmpty(mensajesInfofinalizarAperturaSalesforce)) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,mensajesInfofinalizarAperturaSalesforce));
				} else {
					try {
						if (convertidoAGrave) {
							paginaNavegar = new PageReference('/apex/' + Label.VF_SINI_REPARABLE);
							paginaNavegar = agregarParametrosURL(paginaNavegar, caso.Id, null);
							paginaNavegar.getParameters().put('conversionAGrave', 'Y');
							paginaNavegar.setRedirect(true);
						} else {
							if (caso.CAS_NUM_Id_Actuacion_SondeoExt__c != null) {
	
								// Conversion tipo caso membership
								String tipoCasoReal = caso.Type;
								if(caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c == Label.IDE_MEMBERSHIP){
									if(caso.Type == Label.CAS_TIPO_MIXTO){
										tipoCasoReal = Label.CAS_TIPO_INDEMNIZABLE;
									}else if(caso.Type == Label.CAS_TIPO_INDEMNIZABLE){
										tipoCasoReal = Label.CAS_TIPO_MIXTO;
									}
							}
	
						/*
							// CASO ACTUALIZACION 1 - Generacion n_siniestro hs y n_siniestro CIA - ¿CORRECTO?
							resultadoUpdVesta = Fachada.actualizaSiniestroVesta(Integer.valueOf(caso.CAS_NUM_Id_Actuacion_SondeoExt__c), 1, null, null, null, null, caso.CAS_TXT_Num_Caso_HS__c, caso.CAS_TXT_Num_Caso_CIA__c, null, null);
							if (resultadoUpdVesta.resultado != 'OK'){
								throw new Callout_ActualizaSiniestroVesta.ActualizaSiniVestaException('[' + resultadoUpdVesta.codigo_error + ']: ' + resultadoUpdVesta.mensaje_error);
							}
							// CASO ACTUALIZACION 3 - Cambio de situación en una reparación si es un Siniestro Reparable o Mixto - ¿CORRECTO?
							if (tipoCasoReal == Label.CAS_TIPO_REPARABLE
									|| tipoCasoReal == Label.CAS_TIPO_MIXTO)
							{
								resultadoUpdVesta = Fachada.actualizaSiniestroVesta(Integer.valueOf(caso.CAS_NUM_Id_Actuacion_SondeoExt__c), 3, null, null, tipoCasoReal, null, null, null, '1', null);
								if (resultadoUpdVesta.resultado != 'OK'){
									throw new Callout_ActualizaSiniestroVesta.ActualizaSiniVestaException('[' + resultadoUpdVesta.codigo_error + ']: ' + resultadoUpdVesta.mensaje_error);
								}
							}
							// CASO ACTUALIZACION 5 - Cambio de situación en una reparación si es Cobertura Adicional que aplica a Nationale Nederlanden - ¿CORRECTO?
							else if (tipoCasoReal == Label.CAS_TIPO_COBERTURA_ADICIONAL)
							{
								resultadoUpdVesta = Fachada.actualizaSiniestroVesta(Integer.valueOf(caso.CAS_NUM_Id_Actuacion_SondeoExt__c), 5, null, null, tipoCasoReal, null, null, null, '1', null);
								if (resultadoUpdVesta.resultado != 'OK'){
									throw new Callout_ActualizaSiniestroVesta.ActualizaSiniVestaException('[' + resultadoUpdVesta.codigo_error + ']: ' + resultadoUpdVesta.mensaje_error);
								}
							}
							// CASO ACTUALIZACION 6 - Cambio de situación en una reparacion si es la 
							// Compañía Asegurador Membership con el estado de la Orden de Trabajo principal Abierto - ¿CORRECTO?
							else if (tipoCasoReal == Label.CAS_TIPO_REPARABLE && caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c == Label.IDE_MEMBERSHIP)
							{
								resultadoUpdVesta = Fachada.actualizaSiniestroVesta(Integer.valueOf(caso.CAS_NUM_Id_Actuacion_SondeoExt__c), 6, null, null, tipoCasoReal, null, null, null, '1', '1');
								if (resultadoUpdVesta.resultado != 'OK'){
									throw new Callout_ActualizaSiniestroVesta.ActualizaSiniVestaException('[' + resultadoUpdVesta.codigo_error + ']: ' + resultadoUpdVesta.mensaje_error);
								}
							}*/
							} 
						}
					} catch(DmlException e){
						system.debug(e.getStackTraceString());
						if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error al actualizar VESTA. ' + e.getMessage()));
						}
					} catch(Exception e) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error al actualizar VESTA. ' + e.getMessage()));
						system.debug(e.getStackTraceString());
					}
				}
				finalizarApertura = true;
		}else {
			paginaNavegar = navegarDetalleCaso(caso);
		}
		
	
		return paginaNavegar;
	}
	
	public PageReference navegarDetalleCaso(Case cas) {
		PageReference paginaNavegar = new PageReference('/' + cas.Id);
		paginaNavegar.setRedirect(true);
		return paginaNavegar;
	}
	
	public void asignarPerito(){
		caso = Util_Perito.procesoAsignacion(caso);
		if (caso.CAS_LKP_Perito__c != null){ 
			update caso;
			//comentarioFormateadoPerito.comentarioCaso.CMC_LKP_Caso__c = intervencion.id;
			mensajeAsignarPerito = Label.INFO_PERITO_ASIGNADO;
		} else{
			mensajeAsignarPerito = Label.ERROR_ASIGNAR_PERITO;
		}
	}

}