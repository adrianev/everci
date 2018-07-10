/**
 * Clase controladora de la Visualforce "GenerarAlbaran" encargada de generar/gestionar un albarán.
 * 
 * @author EVERIS
 */
public without sharing class GenerarAlbaranController {
	public Case caso {get; set;}
	public Integer tipoCaso {get; set;}
	public Boolean esB2C {get; set;}
	public Account cuenta {get; set;}
	public ServiceAppointment cita {get; set;}
	public WorkOrder ordenTrabajo {get; set;}
	public List<WorkOrderLineItem> listaPartidas {get; set;}
	public Boolean bloquearAcciones {get; set;}
	public String idioma {get; set;}
	public String tipoFirma;
	public Boolean visibleGuardar {get; set;}
	private String codigoCIA;
	private String errorMessage;
	public Boolean esProfesional {get; set;}
	public Boolean firmadoCliente {get; set;}
	public Boolean firmadoProfesional {get; set;}
	private Boolean enviarMail;
	public Decimal impuesto {get; set;}
	public Boolean esReclamacion {get; set;}

	public GenerarAlbaranController(ApexPages.standardController stdCtr) {
		bloquearAcciones = false;
		PageReference paginaActual = ApexPages.currentPage();
		System.debug('*********paginaActual.getParameters(): ' + paginaActual.getParameters());
		errorMessage = null;
		idioma = Label.IDIOMA_POR_DEFECTO;
		tipoFirma = '';
		firmadoCliente = false;
		firmadoProfesional = false;
		visibleGuardar = false;
		enviarMail = false;
		esReclamacion = false;

		String perfilUsuario = Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name;
		if(!Test.isRunningTest()) esProfesional = (perfilUsuario == Label.PERFIL_PROFESIONAL);
		else esProfesional = true;

		if(!paginaActual.getParameters().containsKey('id')){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
			bloquearAcciones = true;
		}
		else {
			//Recojo la cita de servicio que me pasan por parámetro
			cita = Util_Cita_Servicio.getMapCitasById(new Set<Id>{paginaActual.getParameters().get('id')}).get(paginaActual.getParameters().get('id'));
			if(cita != null){
				//recoge la orden de trabajo a partir de la cita de servicio
				List<WorkOrder> ordenesTrabajo = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{cita.ParentRecordId}).values();
				if(ordenesTrabajo.isEmpty()){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
					bloquearAcciones = true;
				}
				else {
					ordenTrabajo = ordenesTrabajo.get(0);
					listaPartidas = Util_Orden_Trabajo.getListaPartidasOT(ordenTrabajo.Id, true);
					if(!listaPartidas.isEmpty()){
						impuesto = listaPartidas.get(0).PAR_POR_Porcentaje_Imp_Cia_Cliente__c;
					}
					tipoCaso = 2;
					List<Case> listaCasos = Util_Caso.getCaseById(new Set<Id>{ordenTrabajo.CaseId}).values();
					//List<Case> listaCasos = Util_Caso.getMapaCasos(new Set<Id>{ordenTrabajo.CaseId}).values();
					//List<Case> listaCasos = Util_B2B.queryCaso(ordenTrabajo.CaseId);
					if (!listaCasos.isEmpty()) {
						if(Util_Siniestro.esSiniestro(listaCasos.get(0))){
							tipoCaso = 1;
							listaCasos = Util_Caso.getCaseById(new Set<Id>{listaCasos.get(0).Id}).values();
							//listaCasos = Util_Caso.queryMapSiniCaso(new Set<Id>{listaCasos.get(0).Id},null,1).values();
							//listaCasos = Util_Siniestro.queryCaso(listaCasos.get(0).Id, null, 1);
						}
						caso = listaCasos.get(0);
						if(caso.CAS_LKP_Compania__c != null){
							codigoCIA = caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c;
						}
						esB2C = caso.CAS_FOR_EsB2C__c;
						esReclamacion = (caso.CAS_FOR_RTDevName__c == Label.RT_CAS_RECLAMACION);
						system.debug('>>>>> CASO : ' + caso);
						cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{caso.AccountId}).get(caso.AccountId);
					}
					if(cita.status != label.CIT_ESTADO_EN_CURSO && cita.status != label.CIT_ESTADO_COMPLETADA){
						String etiquetaEstado = Util_Listas_Seleccion.getLabelDesdeAPI('ServiceAppointment','Status').get(cita.Status);
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_ACCION_NO_DISP_ESTADO_CS + ' ' + etiquetaEstado));
						bloquearAcciones = true;
					}
					else if(ordenTrabajo.Status != Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN && ordenTrabajo.Status != Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO &&
							codigoCIA == Label.IDE_ENDESA && (!Util_Orden_Trabajo.getConfigEstadosManualesCIA(perfilUsuario, codigoCIA).contains(';' + ordenTrabajo.Status + ';'))){
						String etiquetaEstado = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder','Status').get(ordenTrabajo.Status);
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_ACCION_NO_DISP_ESTADO_OT + ' ' + etiquetaEstado));
						bloquearAcciones = true;
					}
					else {
						String firmaCliente = cita.AppointmentNumber + Label.IMG_SUFIJO_FIRMA_CLIENTE;
						List <Attachment> firmasCliente = Util_Attachment.queryMapAttachment(new set<String>{firmaCliente}).values();
						firmadoCliente = !firmasCliente.isEmpty();
						String firmaProfesional = cita.AppointmentNumber + Label.IMG_SUFIJO_FIRMA_PROFESIONAL;
						List <Attachment> firmasProfesional = Util_Attachment.queryMapAttachment(new set<String>{firmaProfesional}).values();
						firmadoProfesional = !firmasProfesional.isEmpty();
						visibleGuardar = (!bloquearAcciones && (!esProfesional || (firmadoCliente && firmadoProfesional)));
					}
				}
			}
		}
	}//FIN CONSTRUCTOR


	public PageReference guardarYEnviarAlbaran(){
		enviarMail = true;
		return guardarAlbaran();
	}//FIN guardarYEnviarAlbaran()


	public PageReference guardarAlbaran(){
		system.debug('>>>>>>>>>>>guardarAlbaran.enviarMail: ' + enviarMail);
		PageReference paginaRedireccion = null;
		system.Savepoint puntoGuardado = Database.setSavepoint();
		try {
			// Idioma por defecto "Castellano" si el cliente no tiene establecido
			if(cuenta.CUE_SEL_Idioma__c != null){
				idioma = cuenta.CUE_SEL_Idioma__c;
			}
			// Generación de PDF
			ContentVersion cv = Util_Documentacion.crearPDFDesdeVF(cita.Id, null, Label.PDF_TIPO_ALBARAN, codigoCIA, idioma,
																   cita.AppointmentNumber, '' + DateTime.now().getTime(), null);
			if(cv != null){
				// Actualizar Orden de Trabajo si estaba Cerrada Pendiente de Albarán
				if(ordenTrabajo.Status == Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN){
					ContentVersion ultimoAlbaran = Util_Orden_Trabajo.getUltimoAlbaranOT(ordenTrabajo.Id);
					if(ultimoAlbaran != null){
						ordenTrabajo.Status = Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO;
						update ordenTrabajo;
					}
				}

				if(enviarMail){
					// Validar parámetros necesarios para el envío del email
					Contact contactoCliente = null;
					// Validar si existe un contacto y/o una dirección de email informada
					if((caso.CAS_EMA_Solicitud_Email__c == null && caso.ContactEmail == null) ||
						caso.CAS_TXT_Nombre__c == null || caso.CAS_TXT_Apellidos__c == null){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_NO_ENVIO_ALBARAN));
					}
					else {
						String correoRemitente = Util_Correo_Electronico.getBuzonCIA(Label.IDE_HOMESERVE, Label.CON_TIPO_PROGRAMA_NO_REPLY);
						if(correoRemitente == null){
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_BUZON_TIPOPROGRAMA));
						}
						else {
							if(caso.ContactEmail == caso.CAS_EMA_Solicitud_Email__c){
								contactoCliente = caso.Contact;
							}
							if(contactoCliente == null){
								String apellidos = caso.CAS_TXT_Apellidos__c;
								if(caso.CAS_TXT_Apellidos_2__c != null){
									apellidos += ' ' + caso.CAS_TXT_Apellidos_2__c;
								}
								contactoCliente = Util_Correo_Electronico.generarDummyContact(caso.CAS_TXT_Nombre__c, apellidos, caso.CAS_EMA_Solicitud_Email__c, caso.CAS_TFN_Solicitud_Telefono__c, null);
							}
							Util_Correo_Electronico.enviarSingleEmailMessage(JSON.serialize(caso), Label.CON_TIPO_PROGRAMA_ALBARAN, Label.IDIOMA_POR_DEFECTO, contactoCliente, correoRemitente, cv, null, null);
	
							// Actualizar el email del caso si se ha modificado en la pantalla
							update caso;
							// Volver al detalle de la Cita de Servicio
							paginaRedireccion = volver();
						}
					}
				}
				else {
					// Actualizar el email del caso si se ha modificado en la pantalla
					update caso;
					// Volver al detalle de la Cita de Servicio
					paginaRedireccion = volver();
				}
			}
		}
		catch(DmlException e){
			Database.rollback(puntoGuardado);
			system.debug('***** EXCEPTION e :' + e.getStackTraceString());
			//if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
			//}
		}
		catch(Exception e){
			Database.rollback(puntoGuardado);
			system.debug('***** EXCEPTION e :' + e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
		}
		enviarMail = false;
		return paginaRedireccion;
	}//FIN guardarAlbaran()


	public PageReference volver(){
		system.debug('volver()');
		PageReference paginaRedireccion = new PageReference('/' + cita.Id);
		paginaRedireccion.setRedirect(true);
		system.debug('--pagina volver: '+paginaRedireccion.getUrl());
		return paginaRedireccion;
	}//FIN volver()
	
	
	/**
     * Entra en la página CaptureSignature para realizar la firma del cliente
     * 
     * @return página a navegar tras ejecutar firmaCliente()
     */
	public PageReference firmaCliente(){
		system.debug('firmaCliente()');
		PageReference paginaRedireccion = null;
		// Actualizar el email del caso si se ha modificado en la pantalla
		if(Util_Caso.guardarCaso(caso)){
			tipoFirma = 'cliente';
			paginaRedireccion = new PageReference('/apex/' + Label.VF_CAPTURE_SIGNATURE);
			paginaRedireccion.getParameters().put('tipoFirma', tipoFirma);
			paginaRedireccion.getParameters().put('idCita', cita.Id);
			paginaRedireccion.getParameters().put('idOrdenTrabajo', ordenTrabajo.Id);
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN firmaCliente()

	
	/**
     * Entra en la página CaptureSignature para realizar la firma del profesional
     * 
     * @return página a navegar tras ejecutar firmaProfesional()
     */
	public PageReference firmaProfesional(){
		system.debug('firmaProfesional()');
		PageReference paginaRedireccion = null;
		// Actualizar el email del caso si se ha modificado en la pantalla
		system.debug('---------CAS_EMA_Solicitud_Email__c: '+caso.CAS_EMA_Solicitud_Email__c);
		if(Util_Caso.guardarCaso(caso)){
			tipoFirma = 'profesional';
			paginaRedireccion = new PageReference('/apex/' + Label.VF_CAPTURE_SIGNATURE);
			paginaRedireccion.getParameters().put('tipoFirma', tipoFirma);
			paginaRedireccion.getParameters().put('idCita', cita.Id);
			paginaRedireccion.getParameters().put('idOrdenTrabajo', ordenTrabajo.Id);
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN firmaProfesional()
}