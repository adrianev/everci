/**
 * Clase controladora de la Visualforce "GenerarPresupuesto" encargada de generar/gestionar un presupuesto.
 * 
 * @author EVERIS
 */
public without sharing class GenerarPresupuestoController {
	public Case caso {get; set;}
	public Boolean esB2C {get; set;}
	private String solicitudExistente;
	public String fase {get; set;}
	private String paginaRetorno;
	private Boolean presupuestoAceptado;
	public Account cuenta {get; set;}
	public Presupuesto__c presupuesto {get; set;}
	public List<Linea_Presupuesto__c> listaLineasPresu {get; set;}
	public String fechaEmision {get; set;}
	public Decimal baseImponible {get; set;}
	public Decimal importeTotal {get; set;}
	public Decimal impuesto {get; set;}
	public List<SelectOption> motivosRechazo {get; set;}
	public Boolean esRechazoTotal {get; set;}
	public String motivo {get; set;}
	private String codigoCIA;
	private Boolean mandarMail;
	private PageReference paginaRedireccion;
	private Boolean esAprobacion {get; set;}
	private Boolean esRechazoParcial {get; set;}
	public List<SelectOption> listaSelTiposDestino {get; set;}
	public String tipoDestino {get; set;}
	private String idioma;
	private String errorMessage;
	private String correoRemitente;
	private Contact contactoCliente;
	public Boolean esProfesional {get; set;}
	public Boolean esProfesionalSec {get; set;}
	public Boolean verPeritos {get; set;}

	public GenerarPresupuestoController(ApexPages.standardController stdCtr){
		presupuestoAceptado = false;
		verPeritos = false;
		PageReference paginaActual = ApexPages.currentPage();
		esAprobacion = false;
		esRechazoTotal = false;
		mandarMail = false;
		errorMessage = null;
		idioma = Label.IDIOMA_POR_DEFECTO;

		if (!Test.isRunningTest()) esProfesional = Util_Perfiles_Usuario.esProfesional(UserInfo.getProfileId());
		else esProfesional = true;
		esProfesionalSec = (esProfesional && (!Util_Perfiles_Usuario.esRecursoPrincipal(UserInfo.getUserId())));

		listaSelTiposDestino = new List<SelectOption>();

		if(paginaActual.getParameters().containsKey('fase')){
			fase = paginaActual.getParameters().get('fase');
			System.debug('*********getFase');
		}
		if(paginaActual.getParameters().containsKey('solicitudExistente')){
			solicitudExistente = paginaActual.getParameters().get('solicitudExistente');
			System.debug('*********solicitudExistente');
		}
		if(paginaActual.getParameters().containsKey('retorno')){
			paginaRetorno = paginaActual.getParameters().get('retorno');
			System.debug('*********retorno');
		}
		if(!paginaActual.getParameters().containsKey('id')){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
			System.debug('*********id');
		}
		else {
			//Recojo el caso que me pasan por parámetro
			System.debug('*********else');
			List<Case> listaCasos = Util_Caso.getCaseById(new Set<Id>{stdCtr.getRecord().Id}).values();
			//List<Case> listaCasos = Util_Caso.getMapaCasos(new Set<Id>{stdCtr.getRecord().Id}).values();
			//List<Case> listaCasos = Util_B2B.queryCaso(stdCtr.getRecord().Id);
			if(!listaCasos.isEmpty()){
				caso = listaCasos.get(0);
				if(caso.CAS_LKP_Compania__c != null){
					codigoCIA = caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c;
				}
				system.debug('>>>>> CASO : ' + caso);
				esB2C = caso.CAS_FOR_EsB2C__c;
				cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{caso.AccountId}).get(caso.AccountId);
				if(cuenta == null){
					cuenta = new Account();
					cuenta.Name = caso.CAS_FOR_Nombre_Solicitud__c;
				}
				if(paginaActual.getParameters().containsKey('perito')) {
					listaSelTiposDestino.add(new SelectOption(Label.TIPO_CONTACTO_DEST_COMPANIA, 'Perito'));
					tipoDestino = Label.TIPO_CONTACTO_DEST_PERITO;
				}else {
					if(!esB2C && !esProfesional){
						listaSelTiposDestino.add(new SelectOption(Label.TIPO_CONTACTO_DEST_COMPANIA, 'Compañía'));
						tipoDestino = Label.TIPO_CONTACTO_DEST_COMPANIA;
					}
					listaSelTiposDestino.add(new SelectOption(Label.TIPO_CONTACTO_DEST_CLIENTE, 'Cliente'));
					if(esB2C){
						tipoDestino = Label.TIPO_CONTACTO_DEST_CLIENTE;
					}
				}
				
				// Si se accede para generar un nuevo presupuesto:
				if(paginaActual.getParameters().containsKey('nuevoPresupuesto')){
					System.debug('**********Es nuevo presupuesto');
					Presupuesto__c presupuestoAnterior = Util_Presupuesto.getPresupuestosActuales(new Set<Id>{caso.Id}).get(caso.Id);
					presupuesto = Util_Presupuesto.generarPresupuesto(caso, presupuestoAnterior);
					listaLineasPresu = Util_Presupuesto.generarLineasPresupuesto(caso);

					// Si existe un presupuesto anterior rechazado de forma parcial:
					if(presupuestoAnterior != null &&
							presupuestoAnterior.PRE_SEL_Estado__c == Label.PRESU_RECHAZADO_PARCIAL){
						// el nuevo presupuesto nace con el estado anterior al rechazo
						presupuesto.PRE_SEL_Estado__c = presupuestoAnterior.PRE_SEL_Estado_Anterior__c;
					}

					fechaEmision = String.valueOf(System.Now().Day()).leftPad(2,'0') + '-' 
							+ String.valueOf(System.Now().Month()).leftPad(2,'0') + '-'
							+ System.Now().Year();

					actualizarImportesMostrados();
				}
				// Si no se accede para generar un nuevo presupuesto: se obtiene el último generado
				else {
					System.debug('**********No es nuevo presupuesto');
					presupuesto = Util_Presupuesto.getPresupuestosActuales(new Set<Id>{caso.Id}).get(caso.Id);
					if(presupuesto == null){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
					}
					else {
						fechaEmision = String.valueOf(presupuesto.CreatedDate.Day()).leftPad(2,'0') + '-' 
								+ String.valueOf(presupuesto.CreatedDate.Month()).leftPad(2,'0') + '-'
								+ presupuesto.CreatedDate.Year();
						//Recojo las líneas del presupuesto
						listaLineasPresu = Util_Presupuesto.getLineaPresupuestoByPresupuesto(new Set<Id>{presupuesto.Id}).values();
						//listaLineasPresu = Util_Presupuesto.queryLineasPresupuesto(presupuesto.Id);
						System.debug(listaLineasPresu);
						motivo = presupuesto.PRE_SEL_Motivo_Rechazo__c;

						actualizarImportesMostrados();
					}
				}
				if(presupuesto != null && (esProfesional ||
				   caso.CAS_TXT_Subestado_Codigo__c == Label.OTR_ESTADO_PDTE_PRESUP_CLIENTE ||
				   presupuesto.PRE_SEL_Estado__c == Label.PRESUPUESTO_PENDIENTE)){
					tipoDestino = Label.TIPO_CONTACTO_DEST_CLIENTE;
					actualizarImportesMostrados();
				}
			}
		}
	}//FIN CONSTRUCTOR B2B_Presupuesto


	public void actualizarImportesMostrados(){
		if(presupuesto.Id == null){
			baseImponible = 0;
			importeTotal = 0;
			for(Linea_Presupuesto__c lp: listaLineasPresu){
				if(tipoDestino == Label.TIPO_CONTACTO_DEST_CLIENTE){
					if(lp.PREL_DIV_Cargar_Cliente_AI__c != null){
						baseImponible += lp.PREL_DIV_Cargar_Cliente_AI__c;
					}
					if(lp.PREL_DIV_Cargar_Cliente_DI__c != null){
						importeTotal += lp.PREL_DIV_Cargar_Cliente_DI__c;
					}
				}
				else {
					if(lp.PREL_DIV_Facturacion_Total_AI__c != null){
						baseImponible += lp.PREL_DIV_Facturacion_Total_AI__c;
					}
					if(lp.PREL_DIV_Facturacion_Total_DI__c != null){
						importeTotal += lp.PREL_DIV_Facturacion_Total_DI__c;
					}
				}
			}
			for(Linea_Presupuesto__c lp: listaLineasPresu){
				if(lp.PREL_POR_Impuesto_Cliente__c != null){
					impuesto = lp.PREL_POR_Impuesto_Cliente__c;
					break;
				}
			}
		}
		else {
			impuesto = presupuesto.PRE_RES_Porcentaje_Imp_Cia_Cliente__c;
			if(tipoDestino == Label.TIPO_CONTACTO_DEST_CLIENTE){
				baseImponible = presupuesto.PRE_RES_Importe_Total_Cliente_AI__c;
				importeTotal = presupuesto.PRE_RES_Importe_Total_Cliente_DI__c;
			}
			else {
				baseImponible = presupuesto.PRE_RES_Importe_total__c;
				importeTotal = presupuesto.PRE_RES_Importe_Total_DI__c;
			}
		}
	}//FIN actualizarImportesMostrados()


	public void aceptarPresupuesto(){
		esAprobacion = true;
		continuarConPresupuesto();
	}//FIN aceptarPresupuesto()


	public void rechazarPresupuestoParcial(){
		esRechazoParcial = true;	
		continuarConPresupuesto();
	}//FIN rechazarPresupuestoParcial()

			
	public void guardarPresupuesto(){
		esAprobacion = false;
		esRechazoParcial = false;
		continuarConPresupuesto();
	}//FIN guardarPresupuesto()

	
	private void continuarConPresupuesto(){
		paginaRedireccion = null;
		system.debug('continuarConPresupuesto().esAprobacion: ' + esAprobacion);
		system.debug('continuarConPresupuesto().esRechazoParcial: ' + esRechazoParcial);
		esRechazoTotal = false;
		motivo = null;
		system.Savepoint puntoGuardado = Database.setSavepoint();
		try {
			if(presupuesto.Id == null){
				presupuesto.PRE_SEL_Estado_Anterior__c = presupuesto.PRE_SEL_Estado__c;
			}

			if(esAprobacion){
				// Si se acepta un Presupuesto PENDIENTE DE CIA:
				// cambiar estado presupuesto y autorizar límite actuación
				if(presupuesto.PRE_SEL_Estado__c == Label.PRESUPUESTO_PENDIENTE_CIA){
					presupuesto.PRE_SEL_Estado__c = Label.PRESUPUESTO_APROBADO_CIA;
				}
				// Si se acepta un Presupuesto NO APROBADO ó PENDIENTE DE CLIENTE: cambiar estado presupuesto
				else {
					presupuesto.PRE_SEL_Estado__c = Label.PRESUPUESTO_APROBADO;
				}
			}
			else if(esRechazoParcial){
				presupuesto.PRE_SEL_Estado__c = Label.PRESU_RECHAZADO_PARCIAL;
			}

			// Tras el cambio de estado del Presupuesto, en el trigger del objeto Presupuesto__c
			// se realiza la actualización de las Partidas y/o Órdenes de Trabajo y/o Casos correspondientes
			if(presupuesto.Id != null){
				update presupuesto;
			}
			else {
				presupuesto = Util_Presupuesto.insertarPresupuestoYLineas(presupuesto,listaLineasPresu);
			}
			//presupuesto = (Util_Presupuesto.queryPresupuesto(presupuesto.Id, null)).get(0);
			presupuesto = (Util_Presupuesto.getPresupuestoById(new Set<Id>{presupuesto.Id}).values()).get(0);
			system.debug('>>>>>>>>>>>presupuesto: ' + presupuesto);

			if(esAprobacion){
				presupuestoAceptado = true;
				if(caso.CAS_FOR_RTDevName__c == Label.RT_CAS_SOLIC_B2C){
					Case casoAux = new Case(Id=caso.Id,RecordtypeId=Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C));
					update casoAux;
				}
				else if(caso.CAS_FOR_RTDevName__c == Label.RT_CAS_SOLIC_B2B_B2B2C){
					Case casoAux = new Case(Id=caso.Id,RecordtypeId=Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C));
					update casoAux;
				}
			}

			if(paginaRetorno == null){
				paginaRetorno = '/apex/' + Label.VF_B2B_REPARABLE;
			}
			// Navegar a la pantalla de tramitación para continuar
			paginaRedireccion = volver();
			mandarMail = false;
		}
		catch(DmlException e){
			Database.rollback(puntoGuardado);
			system.debug('***** EXCEPTION e :' + e.getStackTraceString());
			if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
			}
		}
		catch(Exception e){
			Database.rollback(puntoGuardado);
			system.debug('***** EXCEPTION e :' + e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
		}
	}//FIN continuarConPresupuesto()


	public void pensarPresupuesto(){
		paginaRedireccion = null;
		System.debug('pensarPresupuesto()');
		esRechazoTotal = false;
		motivo = null;
		// Validar si existe un contacto y/o una dirección de email informada
		if(caso.CAS_EMA_Solicitud_Email__c == null && caso.contactEmail == null){
			errorMessage = Label.ERROR_FALTA_EMAIL_CLIENTE;
		}
		else {
			if(caso.ContactEmail == caso.CAS_EMA_Solicitud_Email__c){
				contactoCliente = caso.Contact;
			}
			// Validar si existe configurado un buzón email2case para la CIA
			//PREV:correoRemitente = Util_Correo_Electronico.getBuzonCIA(caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c, Label.CON_TIPO_PROGRAMA_AUTORIZA_PRESUPUESTO);
			//NEW
			List<Buzon_CIA__c> listaBuzon = Util_Correo_Electronico.getBuzonCIABy_TXTIdCuenta_AND_TipoPrograma(new Set<String>{caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c}, new Set<String>{Label.CON_TIPO_PROGRAMA_AUTORIZA_PRESUPUESTO} ).values();
			if(!listaBuzon.isEmpty()){
				correoRemitente = listaBuzon[0].BUZ_EMA_Direccion__c;
			}

			//END_NEW
			if(correoRemitente == null){
				errorMessage = Label.ERROR_BUZON_TIPOPROGRAMA;
			}
			else {
				if(presupuesto.Id == null){
					presupuesto.PRE_SEL_Estado_Anterior__c = presupuesto.PRE_SEL_Estado__c;
				}
				system.Savepoint puntoGuardado = Database.setSavepoint();
				try {
					// Cambiar el estado del presupuesto a PENDIENTE CLIENTE
					presupuesto.PRE_SEL_Estado__c = Label.PRESUPUESTO_PENDIENTE;
					// Tras el cambio de estado del Presupuesto, en el trigger del objeto Presupuesto__c
					// se realiza la actualización de las Partidas y/o Órdenes de Trabajo y/o Casos correspondientes
					if(presupuesto.Id != null){
						system.debug('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Presupuesto: ' + presupuesto);
						update presupuesto;
					}
					else {
						presupuesto = Util_Presupuesto.insertarPresupuestoYLineas(presupuesto,listaLineasPresu);
					}
					//presupuesto = (Util_Presupuesto.queryPresupuesto(presupuesto.Id, null)).get(0);
					presupuesto = (Util_Presupuesto.getPresupuestoById(new Set<Id>{presupuesto.Id}).values()).get(0);
					system.debug('>>>>>>>>>>>presupuesto: ' + presupuesto);
					mandarMail = true;
					paginaRedireccion = volver();
				}
				catch(DmlException e){
					Database.rollback(puntoGuardado);
					system.debug('***** EXCEPTION e :' + e.getStackTraceString());
					if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
					}
				}
				catch(Exception e){
					Database.rollback(puntoGuardado);
					system.debug('***** EXCEPTION e :' + e.getStackTraceString());
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
				}
			}
		}
	}//FIN pensarPresupuesto()


	public PageReference generarPDF(){
		system.debug('>>>>>>>>>>>generarPDF');
		if(errorMessage != null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
			errorMessage = null;
		}
		else {
			try {
				if(tipoDestino == Label.TIPO_CONTACTO_DEST_CLIENTE && cuenta.CUE_SEL_Idioma__c != null){
					idioma = cuenta.CUE_SEL_Idioma__c;
				} 
				ContentVersion cv = Util_Documentacion.crearPDFDesdeVF(caso.Id, presupuesto.Id, Label.PDF_TIPO_PRESUPUESTO, codigoCIA, idioma,
						caso.CaseNumber + 'v' + presupuesto.PRE_NUM_Version__c, '' + DateTime.now().getTime(), tipoDestino);

				if(mandarMail){
					// Generar Contacto Dummy si es necesario
					if(contactoCliente == null){
						String apellidos = caso.CAS_TXT_Apellidos__c;
						if(caso.CAS_TXT_Apellidos_2__c != null){
							apellidos += ' ' + caso.CAS_TXT_Apellidos_2__c;
						}
						contactoCliente = Util_Correo_Electronico.generarDummyContact(caso.CAS_TXT_Nombre__c, apellidos, caso.CAS_EMA_Solicitud_Email__c, caso.CAS_TFN_Solicitud_Telefono__c, null);
					}
					// Enviar correo electrónico
					Util_Correo_Electronico.enviarSingleEmailMessage(JSON.serialize(caso), Label.CON_TIPO_PROGRAMA_AUTORIZA_PRESUPUESTO, idioma, contactoCliente, correoRemitente, cv, null, tipoDestino);
					mandarMail = false;
				}
				paginaRetorno = null;
			}
			catch(DmlException e){
				if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
					system.debug('***** EXCEPTION e :' + e.getStackTraceString());
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
					paginaRedireccion = null;
				}
			}
			catch(Exception e){
				//Database.rollback(puntoGuardadoPensarPres);
				system.debug('***** EXCEPTION e :' + e.getStackTraceString());
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
				paginaRedireccion = null;
			}
		}
		return paginaRedireccion;
	}//FIN generarPDF()


	public void rechazarPresupuesto(){
		system.debug('Pasa por rechazo total');
		// Mostrar lista de selección de motivos de rechazo
		if(motivosRechazo == null){
			inicializarMotivosRechazoPresupuesto();
			System.debug(motivosRechazo);
		}
		esRechazoTotal = true;
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_MOTIVO_RECHAZO_PRESUP));
	}//FIN rechazarPresupuesto()


	public void motivoSeleccionado(){
		system.debug('************MOTIVO' + motivo);
		system.Savepoint puntoGuardado = Database.setSavepoint();
		paginaRedireccion = null;
		try {
			if(presupuesto.Id == null){
				presupuesto.PRE_SEL_Estado_Anterior__c = presupuesto.PRE_SEL_Estado__c;
			}
			presupuesto.PRE_SEL_Estado__c = Label.PRESUPUESTO_RECHAZADO;
			paginaRedireccion = new PageReference('/' + caso.Id);
			presupuesto.PRE_SEL_Motivo_Rechazo__c = motivo;
			// Tras el cambio de estado del Presupuesto, en el trigger del objeto Presupuesto__c
			// se realiza la actualización de las Partidas y/o Órdenes de Trabajo y/o Casos correspondientes
			if(presupuesto.Id != null){
				update presupuesto;
			}
			else {
				presupuesto = Util_Presupuesto.insertarPresupuestoYLineas(presupuesto,listaLineasPresu);
			}
			//presupuesto = (Util_Presupuesto.queryPresupuesto(presupuesto.Id, null)).get(0);
			presupuesto = (Util_Presupuesto.getPresupuestoById(new Set<Id>{presupuesto.Id}).values()).get(0);
			system.debug('>>>>>>>>>>>presupuesto: ' + presupuesto);
			mandarMail = false;
		}
		catch(DmlException e){
			Database.rollback(puntoGuardado);
			system.debug('***** EXCEPTION e :' + e.getStackTraceString());
			if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
			}
		}
		catch(Exception e){
			Database.rollback(puntoGuardado);
			system.debug('***** EXCEPTION e :' + e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
		}
	}//FIN motivoSeleccionado()


	/**
     * Vuelve del proceso actual en la página B2B_Presupuesto
     * 
     * @return página a navegar tras volver
     */
	public PageReference volver(){
		system.debug('volver()');
		paginaRedireccion = new PageReference('/' + caso.Id);
		if(paginaRetorno != null){
			paginaRedireccion = new PageReference(paginaRetorno);
			paginaRedireccion.getParameters().put('id', caso.Id);
			paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
			paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
			if(presupuestoAceptado){
				paginaRedireccion.getParameters().put('presuAceptado', 'Y');
			}
		}
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}//FIN volver()


	public PageReference actualizarPartidas(){
		if(paginaRetorno == null){
			paginaRetorno = '/apex/' + Label.VF_B2B_REPARABLE;
		}
		return volver();
	}//FIN actualizarPartidas()


	private void inicializarMotivosRechazoPresupuesto(){
		System.debug('Estoy en inicializarMotivosPresupuesto');
		motivosRechazo = new List<SelectOption>();
		if(caso.CAS_LKP_Procedencia__r.PROC_SEL_Motivos_rechazo_presupuesto__c != null){
			String textoMotivosRechazo = ';' + caso.CAS_LKP_Procedencia__r.PROC_SEL_Motivos_rechazo_presupuesto__c + ';';
			DescribeSObjectResult obj = Schema.getGlobalDescribe().get('Procedencia__c').getDescribe();
			DescribeFieldResult campoMotivoRechazo = obj.fields.getMap().get('PROC_SEL_Motivos_rechazo_presupuesto__c').getDescribe();
			List<Schema.PicklistEntry> listaPicklistProcedencias = campoMotivoRechazo.getPicklistValues();
			String motivoRechazoValor = '';
			String motivoRechazoEtiqueta = '---SELECCIONE UNA OPCIÓN---';
			motivosRechazo.add(new SelectOption(motivoRechazoValor, motivoRechazoEtiqueta));		   
			for(Schema.PicklistEntry valorCampoRechazo : listaPicklistProcedencias){
				motivoRechazoValor = valorCampoRechazo.getValue();
				motivoRechazoEtiqueta = valorCampoRechazo.getLabel();
				if(textoMotivosRechazo.contains(';' + motivoRechazoValor + ';')){
					motivosRechazo.add(new SelectOption(motivoRechazoValor, motivoRechazoEtiqueta));
				}
			}
		}
	}//FIN inicializarMotivosRechazoPresupuesto()
}