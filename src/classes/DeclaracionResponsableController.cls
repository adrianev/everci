/**
 * Clase controladora de la Visualforce "DeclaracionResponsable" encargada de generar un documento de Declaración de Responsabilidad.
 * 
 * @author EVERIS
 */
public with sharing class DeclaracionResponsableController {
	
	public Boolean bloquearAcciones {get; set;}
	public Workorder ordenTrabajo {get;set;}
	
	public PDF_DeclaracionResponsable.DatosDeclaracion datos {get;set;}
	
	private String errorFirma;
	
	/**
	 * Constructor de la clase.
	 */
	public DeclaracionResponsableController(ApexPages.standardController stdCtr){
		bloquearAcciones = false;
		PageReference paginaActual = ApexPages.currentPage();
		datos = new PDF_DeclaracionResponsable.DatosDeclaracion();
		
		if(!paginaActual.getParameters().containsKey('id')){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
			bloquearAcciones = true;
		}
		else {
			ordenTrabajo = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{paginaActual.getParameters().get('id')}).get(paginaActual.getParameters().get('id'));
			if(ordenTrabajo == null){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
				bloquearAcciones = true;
			}
			else if(ordenTrabajo.status != Label.OTR_ESTADO_EN_ESPERA_PROF_DECL_RESP){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ERROR_GENERAR_DECLARACION_RESPONSABLE));
				bloquearAcciones = true;
			}
			else {
				datos.sociedadContratante = ordenTrabajo.Case.CAS_LKP_Compania__r.Name;
				datos.centroTrabajoCliente = ordenTrabajo.Case.Account.Name;
			}
		}
	}


	public PageReference volver(){
		system.debug('volver()');
		PageReference paginaRedireccion = new PageReference('/' + ordenTrabajo.Id);
		paginaRedireccion.setRedirect(true);
		system.debug('--pagina volver: '+paginaRedireccion.getUrl());
		return paginaRedireccion;
	}


	public void guardarFirma(){
		system.debug('>>>>>>>>>>>>>>>>>guardarFirma');
		errorFirma = null;
		try {
			String laImagen = ApexPages.currentPage().getParameters().get('imgString');
			system.debug('>>>>>>>>>>>>>>>>>guardarFirma.laImagen: ' + laImagen);
			if(String.isEmpty(laImagen)){
				errorFirma = Label.ERROR_FALTA_FIRMA;
			}
			else {				
				Attachment a = new Attachment();
				a.ParentId = ordenTrabajo.Id;
				a.Body = EncodingUtil.base64Decode(laImagen);
				a.ContentType = 'image/png';
				a.Name = ordenTrabajo.WorkorderNumber + '_firma_declaracionResponsable' + '.png';
				List <Attachment> adjuntos = Util_Attachment.queryMapAttachment(new set<String>{a.Name}).values();
				if(!adjuntos.isEmpty()){
					a.Id = adjuntos.get(0).Id;
				}
				upsert a;
			}
		}
		catch(Exception e){
			system.debug('***** EXCEPTION e :' + e.getStackTraceString());
			errorFirma = Label.ERROR_GUARDAR + e.getMessage();
		}
		system.debug('>>>>>>>>>>>>>>>>>guardarFirma.errorFirma: ' + errorFirma);
	}

	
	public PageReference guardarArchivo(){
		system.debug('>>>>>>>>>>>>>>>>>guardarArchivo');
		PageReference paginaRedireccion = null;
		if(errorFirma != null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorFirma));
		}
		else {
			system.Savepoint puntoGuardado = Database.setSavepoint();
			try {
				Map<String,String> argumentos = new Map<String,String>{'datos'=>JSON.serialize(datos)};
				ContentVersion cv = Util_Documentacion.crearPDFDesdeVF(ordenTrabajo.Id, null, Label.PDF_TIPO_DECLARACION_RESPONSABLE,
					ordenTrabajo.Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c, Label.IDIOMA_POR_DEFECTO, ordenTrabajo.WorkOrderNumber,
					String.valueOf(DateTime.now().getTime()), null, argumentos);
				insert Util_tarea.crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_DECLARACION_RESPONSABLE,
											 Label.TAR_ESTADO_EN_CURSO, '', ordenTrabajo.Case.OwnerId, ordenTrabajo.Id, ordenTrabajo.Case.CAS_LKP_Compania__c);
				paginaRedireccion = volver();
			}
			catch(Exception e){
				Database.rollback(puntoGuardado);
				system.debug('***** EXCEPTION e :' + e.getStackTraceString());
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
			}
		}
		return paginaRedireccion;
	}
}