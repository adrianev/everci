/**
 * Clase controladora de la Visualforce "SiniReparableConfirmación" encargada de gestionar los gremios de un Siniestro durante la Confirmación.
 * 
 * @author EVERIS
 */
public class SiniReparableConfirmacionController {
	public Case intervencion{get;set;}
	public Confirmacion__c confirmacion {get;set;}
	public ComentarioFormateado comentarioFormateadoPerito{get; set;}
	public List<ComentarioFormateado> listaComentariosPerito {get; set;}
	public ComentarioFormateado comentarioFormateado {get; set;}
	public List<ComentarioFormateado> listaComentariosIntervencion {get; set;}
	public List<WorkOrder> listaOrdenesTrabajo {get; set;}
	public Map<Id, List<ComentarioFormateado>> mapaComentariosPorOrdenTrabajo {get; set;}
	public Map<Id, ComentarioFormateado> mapaNuevoComentarioOrdenTrabajo {get; set;}
	private Boolean mensajeHabilidades;
	//Mensajes del botón Finalizar apertura. 
	private Boolean finalizarAperturaSaleforceMostradoMensajePartidas;
	public Boolean aperturaFinalizadaSalesforceCorrectamente {get;set;}
	public String mensajeManitas{get;set;}
	private String mensajesErrorfinalizarAperturaSalesforce;
	//Mensaje de Error del botón Salir.
	private String mensajeErrorSalir;
	//Grave - Perito - Urgente
	private Boolean convertidoAGrave;
	private String idPerito;
	public String fechaCitaUrgenteReservada{get;set;}
	public String nombrePerfilUsuario{get;set;}
	public Integer columnasPorPerfil{get;set;}
	public Integer numeroGremiosArbolSalida;
	public Boolean propietario {get; set;}
	public Boolean esProfesional {get; set;}
	public Boolean esAdministrador {get; set;} // [INI] Nº35 : No permitir anular el gremio principal en Confirmación ni Tramitación para Gestor y Profesional : 09/07/2018 : SMM
	public Boolean asignado {get; set;}
	private List<Task> listaTareas {get; set;}
	private Boolean peritoAsignado;						
	//Booleana para mostrar error en las reglas de buzón web.
	private String mensajeReglasBuzonWeb{get;set;}
	public Boolean reglasBuzonWebEvaluadas{get;set;}
	private Boolean actualizarConfirmacion{get;set;}
	//Se rellena una lista con todas las reglas de buzón web que se estén incumpliendo
	private List<String> listaReglasBuzonWebIncumplidas{get;set;}
	private String enumeracionErrores{get;set;}
	private Comentario_caso__c newComentarioCaso{get;set;}
	
	public SiniReparableConfirmacionController(ApexPages.standardController standarController) { 															
		PageReference paginaActual = ApexPages.currentPage();								   
		comentarioFormateadoPerito = new ComentarioFormateado('perito');
		listaComentariosPerito = new List<ComentarioFormateado>();
		peritoAsignado = false;
		newComentarioCaso=new Comentario_caso__c();
		comentarioFormateado= new ComentarioFormateado();
		listaTareas = new List<Task>();
		listaComentariosIntervencion=new List<ComentarioFormateado>();
		intervencion=new Case();
		listaOrdenesTrabajo=new List<WorkOrder>();
		mapaComentariosPorOrdenTrabajo=new Map<Id, List<ComentarioFormateado>>();
		mapaNuevoComentarioOrdenTrabajo=new Map<Id, ComentarioFormateado>();
		mensajeHabilidades=false;
		finalizarAperturaSaleforceMostradoMensajePartidas = false;
		convertidoAGrave=false;
		propietario = false;
		actualizarConfirmacion=false;
		reglasBuzonWebEvaluadas=false;
		idPerito = '';				 
		mensajeErrorSalir='';
		listaReglasBuzonWebIncumplidas=new List<String>();
		mensajeManitas='';
		mensajesErrorfinalizarAperturaSalesforce='';
		nombrePerfilUsuario='';
		mensajeReglasBuzonWeb='';
		enumeracionErrores='';
		esProfesional = Util_Perfiles_Usuario.esProfesional(UserInfo.getProfileId());
		// [INI] Nº35 : No permitir anular el gremio principal en Confirmación ni Tramitación para Gestor y Profesional : 09/07/2018 : SMM
		esAdministrador = Util_Perfiles_Usuario.esAdministrador(UserInfo.getProfileId());
		// [FIN] Nº35 : No permitir anular el gremio principal en Confirmación ni Tramitación para Gestor y Profesional

        for(Profile perfil:Util_Perfiles_Usuario.queryProfileById(new Set<Id>{UserInfo.getProfileId()}).values()) {
            if(UserInfo.getProfileId().equalsIgnoreCase(perfil.Id)) {
                nombrePerfilUsuario=perfil.Name;
            }
        }
        
        List<Confirmacion__c> listaConfirmaciones = Util_Siniestro.queryConfirmacionesPorId(new Set<Id>{paginaActual.getParameters().get('idConfirmacion')}).values();
        confirmacion = new Confirmacion__c(); 
        
        if(listaConfirmaciones != null && !listaConfirmaciones.isEmpty()){
			confirmacion = listaConfirmaciones.get(0);
        }
        
        numeroGremiosArbolSalida = Integer.ValueOf(paginaActual.getParameters().get('numeroGremiosArbolSalida'));

		columnasPorPerfil=2;
		if(Label.PERFIL_PROFESIONAL.equalsIgnoreCase(nombrePerfilUsuario)) {
			columnasPorPerfil=1;
		}
		//Recupero la intervención.
	   for(Case casoAux: Util_Caso.getCaseById(new Set<Id>{standarController.getRecord().Id}).values()) {
		   intervencion=casoAux;
	   }
	   System.debug('SiniReparableConfirmacionController: constructor: intervencion : '+intervencion); 
	  //Relleno los Comentarios de la intervención
	  List<Comentario_caso__c> listaComentariosIntervencionAux = Util_Caso.getMapComentariosCaso(new Set<Id>{intervencion.Id}).get(intervencion.Id);
		for(Comentario_caso__c comentarioIntervencion : listaComentariosIntervencionAux){
			if(comentarioIntervencion.CMC_SEL_Tipo__c=='08'){//Es comentario de tipo perito
				listaComentariosPerito.add(new ComentarioFormateado(comentarioIntervencion,'Perito'));
				System.debug('@@@@@SiniReparableApertura: insertarComentarioCaso: Estoy añadiendo un comentario de tipo perito a la lista');
			}else{
				listaComentariosIntervencion.add(new ComentarioFormateado(comentarioIntervencion));
			}
		}
		if(UserInfo.getUserId() == intervencion.OwnerId) { //no se si el propietario es a nivel de cuenta o de perfil, tendria que mirarlo y sacar la cuenta asociada al perfil
			propietario = true;
		}
		listaTareas = new List <Task>([SELECT Id 
		                         FROM Task 
		                         WHERE RecordTypeId =: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_TAR_PRESOLICITUD_PERITO) AND 
		                         WhatId =: intervencion.Id]);
		
		//Actualizo las Ordenes de trabajo y sus Comentarios.
		actualizarOrdenesTrabajoYComentariosDeOrdenesTrabjao();
		//Al entrar, inicio el perito. Si cambia, se generará movimiento. 
		idPerito=intervencion.CAS_LKP_Perito__c;
	}
	
	public PageReference insertarComentarioPerito() {
		comentarioFormateado = comentarioFormateadoPerito;
		System.debug('@@@@@@@@comentarioFormateadoPerito ' + comentarioFormateado);
		return insertarComentarioCaso();
	}

	public PageReference insertarComentarioCaso() {																   
		PageReference paginaRedireccion;
		if (!String.isEmpty(comentarioFormateado.comentarioCaso.CMC_TXT_Comentario__c)) {
			comentarioFormateado.comentarioCaso.CMC_LKP_Caso__c=intervencion.Id;
			System.Savepoint puntoGuardado = Database.setSavepoint();
			try {
				insert  comentarioFormateado.comentarioCaso;
				paginaRedireccion = Page.SiniReparableConfirmacion; 
				paginaRedireccion.getParameters().put('guardadoOK', 'Y');
				paginaRedireccion.getParameters().put('idConfirmacion',confirmacion.Id);
				paginaRedireccion.getParameters().put('numeroGremiosArbolSalida',String.valueOf(numeroGremiosArbolSalida));
				paginaRedireccion = agregarParametrosURL(paginaRedireccion, intervencion.Id, null);
				paginaRedireccion.setRedirect(true); 
			}
			catch(DmlException e){
				Database.rollback(puntoGuardado);
				System.debug('SiniReparableApertura: insertarComentarioCaso: e.getStackTraceString; '+e.getStackTraceString());
				if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
				}
			}
			catch(Exception e) {
				Database.rollback(puntoGuardado);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
				 System.debug('SiniReparableApertura: insertarComentarioCaso: e.getStackTraceString; '+e.getStackTraceString());
			}
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_COMENTARIO_VACIO));
		}
		return paginaRedireccion;
	}

	public without sharing class ComentarioFormateado{
		public Comentario_caso__c comentarioCaso {get; set;}
		public Comentario_Orden_de_Trabajo__c comentarioOrdenTrabajo {get; set;}
		public String cuerpoFormateado {get; set;}
		public String tipo;

		public comentarioFormateado(){																						
			comentarioCaso = new Comentario_caso__c();
			comentarioOrdenTrabajo=new Comentario_Orden_de_Trabajo__c();
		}

		public comentarioFormateado(Comentario_caso__c comentarioCaso){
			this.comentarioCaso = comentarioCaso;
			this.cuerpoFormateado = formatearComentario(comentarioCaso.CMC_TXT_Comentario__c);
		}
		public comentarioFormateado(Comentario_Orden_de_Trabajo__c comentarioOrdenTrabajo){
			this.comentarioOrdenTrabajo = comentarioOrdenTrabajo;
			this.cuerpoFormateado = formatearComentario(comentarioOrdenTrabajo.COT_TXT_Comentario__c);
		}
		
		//Costructor para los comentarios de perito
		public comentarioFormateado(String tipo){
			comentarioCaso = new Comentario_caso__c();
			comentarioCaso.CMC_SEL_Tipo__c = '08';//Seteo a tipo comentario perito
			this.tipo = tipo;
		}

		public comentarioFormateado(Comentario_caso__c comentarioCaso,String tipo){
			this.comentarioCaso = comentarioCaso;
			this.cuerpoFormateado = formatearComentario(comentarioCaso.CMC_TXT_Comentario__c);
			this.comentarioCaso.CMC_SEL_Tipo__c = '08';
			this.tipo = tipo;
		}

		public String formatearComentario(String comentario){
			String comentarioRetorno;
			if(comentario != null){
				comentarioRetorno = comentario.replace('\r\n', '<br>');
			}
			return comentarioRetorno;
		}
	}

	public void actualizarOrdenesTrabajoYComentariosDeOrdenesTrabjao() {																									 
		Map<Id, WorkOrder> mapWorkOrdersAux=new Map<Id, WorkOrder>();
		//Recupero las WorkOrders.
		mapWorkOrdersAux=Util_Orden_Trabajo.queryMapOTByCase(new Set<Id>{intervencion.Id});
		System.debug('SiniReparableAperturaController: actualizarOrdenesTrabajoYComentariosDeOrdenesTrabjao: mapWorkOrdersAux: '+mapWorkOrdersAux);
		//Actualizo la lista de órdenes de trabajo.
		listaOrdenesTrabajo=mapWorkOrdersAux.values();
		for(WorkOrder ordenTrabajoAux: mapWorkOrdersAux.values()) {
			mapaNuevoComentarioOrdenTrabajo.put(ordenTrabajoAux.Id, new ComentarioFormateado(new Comentario_Orden_de_Trabajo__c()));
			mapaComentariosPorOrdenTrabajo.put(ordenTrabajoAux.Id, new List<ComentarioFormateado>());
		}
		System.debug('SiniReparableAperturaController: actualizarbtnOrdenesTrabajoYComentariosDeOrdenesTrabjao: mapWorkOrdersAux: '+mapWorkOrdersAux);
		
		//Refresco los comentarios de las órdenes de trabajo. 
		List<Comentario_Orden_de_Trabajo__c> listaComentariosOrdenesTrabajo =  Util_Orden_Trabajo.getComentariosOT(mapWorkOrdersAux.keySet());
		System.debug('SiniReparableAperturaController: actualizarOrdenesTrabajoYComentariosDeOrdenesTrabjao: listaComentariosOrdenesTrabajo: '+listaComentariosOrdenesTrabajo);
		//Para cada Work Order, recorro sus comentarios y los meto en el mapa.
		List<ComentarioFormateado> listaComentariosFormateadosAux = new List<ComentarioFormateado>();
		for(WorkOrder ordenTrabajoAux:mapWorkOrdersAux.values()) {
			listaComentariosFormateadosAux = new List<ComentarioFormateado>();
			for (Comentario_Orden_de_Trabajo__c comentarioOrdenTrabajoAux : listaComentariosOrdenesTrabajo) {
				if (String.valueOf(ordenTrabajoAux.Id).equalsIgnoreCase(comentarioOrdenTrabajoAux.COT_LKP_Orden_de_trabajo__c)) {
					listaComentariosFormateadosAux.add(new ComentarioFormateado(comentarioORdenTrabajoAux));
				}
			}
			System.debug('SiniReparableAperturaController: actualizarOrdenesTrabajoYComentariosDeOrdenesTrabjao: listaComentariosOrdenesTrabajo: '+listaComentariosOrdenesTrabajo);
			mapaComentariosPorOrdenTrabajo.put(ordenTrabajoAux.Id, listaComentariosFormateadosAux);
		}
	}

	public void insertarComentarioOrdenTrabajo() {																					   
		Id idOrdenTrabajo=ApexPages.currentPage().getParameters().get('idOrdenTrabajo');
		System.debug('SiniReparableAperturaController: insertarComentarioOrdenTrabajo: idOrdenTrabajo: '+idOrdenTrabajo);
		if (!String.isEmpty(idOrdenTrabajo)) {
			String comentarioOrdenTrabajo = (mapaNuevoComentarioOrdenTrabajo.get(idOrdenTrabajo)).comentarioOrdenTrabajo.COT_TXT_Comentario__c; 
			System.debug('SiniReparableAperturaController: insertarComentarioOrdenTrabajo: comentarioOrdenTrabajo: '+comentarioOrdenTrabajo);
			if (!String.isEmpty(comentarioOrdenTrabajo)) {
				Comentario_Orden_de_Trabajo__c comentarioOrdenTrabajoToInsert = Util_Orden_Trabajo.crearComentarioOrdenTrabajo(idOrdenTrabajo, comentarioOrdenTrabajo);
				if (comentarioOrdenTrabajoToInsert != null) {
					system.Savepoint puntoGuardado = Database.setSavepoint();
					try {
						insert comentarioOrdenTrabajoToInsert;
						System.debug('SiniReparableAperturaController: insertarComentarioOrdenTrabajo: comentarioOrdenTrabajoToInsert: '+comentarioOrdenTrabajoToInsert);
						actualizarOrdenesTrabajoYComentariosDeOrdenesTrabjao();
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
					} catch(DmlException e) {
						Database.rollback(puntoGuardado);
						System.debug('SiniReparableAperturaController: insertarComentarioOrdenTrabajo: e.getStackTraceString:'+e.getStackTraceString());
						if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
						}
					} catch(Exception e) {
						Database.rollback(puntoGuardado);
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
						System.debug('SiniReparableAperturaController: insertarComentarioOrdenTrabajo: e.getStackTraceString:'+e.getStackTraceString());
					}
				}
			}
			else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_COMENTARIO_VACIO));		
			}
		}
	}

	public PageReference vincularContactos() {																	  
		PageReference paginaRedireccion = new PageReference('/apex/' + Label.VF_SINI_CONTACTOS);
		
		paginaRedireccion = agregarParametrosURL(paginaRedireccion, intervencion.Id, '/apex/'+Label.VF_SINI_REPARABLE_CONFIRMACION); 
		paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, Label.SINI_FASE_CONFIRMACION);
		paginaRedireccion.getParameters().put('numeroGremiosArbolSalida',String.valueOf(numeroGremiosArbolSalida));
		paginaRedireccion.getParameters().put('idConfirmacion',confirmacion.Id);
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}

	public void salirBorrarDatosSaleforce() {																  
		try {
			Util_Siniestro.cancelarAperturaSiniestro(intervencion);
			mensajeErrorSalir='';
		} catch(DmlException e){
			System.debug('SiniReparableAperturaController: salirBorrarDatosSaleforce: e.getStackTraceString:'+e.getStackTraceString());
			mensajeErrorSalir=Label.ERROR_GUARDAR + ' : ' + e.getMessage();
		} catch(Exception e) {
		   	mensajeErrorSalir=Label.ERROR_GUARDAR + ' : ' + e.getMessage();
			System.debug('SiniReparableAperturaController: salirBorrarDatosSaleforce: e.getStackTraceString:'+e.getStackTraceString());
		}
	} 

	public PageReference salirInformarVesta() {																   
		PageReference paginaRedireccion = null;
		Callout_ActualizaSiniestroVesta.Resultado resultadoUpdVesta;
		System.debug('SiniReparableAperturaController: salirInformarVesta: mensajeErrorSalir: '+mensajeErrorSalir);
		if (!String.isEmpty(mensajeErrorSalir)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, mensajeErrorSalir));
		} else 	{
				try {
					if (intervencion.CAS_NUM_Id_Actuacion_SondeoExt__c != null)
					{
						resultadoUpdVesta = Fachada.actualizaSiniestroVesta(Integer.valueOf(intervencion.CAS_NUM_Id_Actuacion_SondeoExt__c), 7, null, Label.SINI_COMENTARIO_CANCELACION, null, null, null, null, null, null);
						if (resultadoUpdVesta.resultado != 'OK'){
							throw new Callout_ActualizaSiniestroVesta.ActualizaSiniVestaException('[' + resultadoUpdVesta.codigo_error + ']: ' + resultadoUpdVesta.mensaje_error);
						}
					}
					paginaRedireccion = new PageReference('/' + intervencion.Id);
					paginaRedireccion.setRedirect(true);
				}
				catch(DmlException e){
					system.debug(e.getStackTraceString());
					if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error al actualizar VESTA. ' + e.getMessage()));
					}
				}
				catch(Exception e)
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error al actualizar VESTA. ' + e.getMessage()));
					system.debug(e.getStackTraceString());
				}
		}
		return paginaRedireccion;
	}

	public PageReference nuevoGremio() {																
		PageReference paginaRedireccion = Page.Sini_Gremios;
		paginaRedireccion.getParameters().put('numeroGremiosArbolSalida',String.valueOf(numeroGremiosArbolSalida));
		paginaRedireccion.getParameters().put('idConfirmacion',confirmacion.Id);
		paginaRedireccion.getParameters().put('id', intervencion.Id);
		paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, Label.SINI_FASE_CONFIRMACION);
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}

	public void hacerOrdenTrabajoPrincipal() {																			   
		Integer indice=Integer.valueOf(ApexPages.currentPage().getParameters().get('indice'));
		System.debug('SiniReparableAperturaController: hacerOrdenTrabajoPrincipal: indice: '+indice);
		WorkOrder ordenTrabajoSeleccionada=listaOrdenesTrabajo.get(indice-1);
		System.debug('SiniReparableAperturaController: hacerOrdenTrabajoPrincipal: ordenTrabajoSeleccionada: '+ordenTrabajoSeleccionada);
		if(Util_Caso.guardarCaso(intervencion) && !String.isEmpty(ordenTrabajoSeleccionada.Id)){
			system.Savepoint puntoGuardado = Database.setSavepoint();
			try {
				intervencion.CAS_LKP_Orden_Trabajo_Principal__c = ordenTrabajoSeleccionada.Id;
				intervencion.CAS_SEL_Gremio_Principal__c = ordenTrabajoSeleccionada.OTR_SEL_Gremio__c;
				update intervencion;
				actualizarOrdenesTrabajoYComentariosDeOrdenesTrabjao();
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
			}
			catch(DmlException e){
				Database.rollback(puntoGuardado);
				System.debug('SiniReparableAperturaController: hacerOrdenTrabajoPrincipal: e.getStackTraceString: '+ e.getStackTraceString());
				if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
				}
			}
			catch(Exception e){
				Database.rollback(puntoGuardado);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
				System.debug('SiniReparableAperturaController: hacerOrdenTrabajoPrincipal: e.getStackTraceString: '+e.getStackTraceString());
			}
		}
	}
 
	public PageReference dormirOrdenDeTrabajo(){																		 
		String idOrdenTrabajo=ApexPages.currentPage().getParameters().get('idOrdenTrabajo');

		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(intervencion) && !String.isEmpty(idOrdenTrabajo)){
			paginaRedireccion = Page.CambioEstadoOT;
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, intervencion.Id, '/apex/'+Label.VF_SINI_REPARABLE_CONFIRMACION); 
			paginaRedireccion.getParameters().put('idConfirmacion',confirmacion.Id);
			paginaRedireccion.getParameters().put('id', intervencion.Id);
			paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
			paginaRedireccion.getParameters().put('dormir', 'Y');
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}

	public PageReference anularOrdenDeTrabajo() { 																 
		PageReference paginaRedireccion = null;
		String idOrdenTrabajo=ApexPages.currentPage().getParameters().get('idOrdenTrabajo');

	   if(Util_Caso.guardarCaso(intervencion) && !String.isEmpty(idOrdenTrabajo)){
			paginaRedireccion = Page.CambioEstadoOT;
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, intervencion.Id, '/apex/'+Label.VF_SINI_REPARABLE_CONFIRMACION);
			paginaRedireccion.getParameters().put('idConfirmacion',confirmacion.Id);
			paginaRedireccion.getParameters().put('numeroGremiosArbolSalida',String.valueOf(numeroGremiosArbolSalida));
			paginaRedireccion.getParameters().put('id', intervencion.Id);
			paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
			paginaRedireccion.getParameters().put('anular', 'Y');
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN.


	private PageReference agregarParametrosURL(PageReference paginaRedireccion, Id idCaso, String retorno)
	{
		paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, Label.SINI_FASE_CONFIRMACION);
		if (!String.isEmpty(idCaso)) {
			paginaRedireccion.getParameters().put('id',idCaso);
		}
		if(!String.isEmpty(String.valueOf(numeroGremiosArbolSalida))) {
			paginaRedireccion.getParameters().put('numeroGremiosArbolSalida',String.valueOf(numeroGremiosArbolSalida));
		}
		if(!String.isEmpty(String.valueOf(confirmacion.Id))) {
			paginaRedireccion.getParameters().put('idConfirmacion',confirmacion.Id);
		}
		if (retorno != null)
		{
			paginaRedireccion.getParameters().put('retorno', retorno);
		}
		return paginaRedireccion;
	}//FIN agregarParametrosURL()

	public PageReference habilidadesRequeridas() {
		String idOrdenTrabajo=ApexPages.currentPage().getParameters().get('idOrdenTrabajo');
		PageReference paginaRedireccion = new PageReference('/apex/' + Label.VF_HABILIDADES_REQUERIDAS_OT);
		paginaRedireccion = agregarParametrosURL(paginaRedireccion, intervencion.Id,'/apex/'+Label.VF_SINI_REPARABLE_CONFIRMACION);
		paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}

	public PageReference reservarCita() { 
		String idOrdenTrabajo=ApexPages.currentPage().getParameters().get('idOrdenTrabajo');
		PageReference paginaRedireccion = null;
		System.debug('SiniReparableController:  reservarCita: idOrdenTrabajo: '+idOrdenTrabajo);
		if (!mensajeHabilidades)
		{
			mensajeHabilidades = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_HABILIDADES_REQUERIDAS));
		}
		else
		{
			List<WorkOrder> listaOT = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{idOrdenTrabajo}).values();
			//List<WorkOrder> listaOT = Util_Orden_Trabajo.queryOT(idOrdenTrabajo, null, null);
			if(!listaOT.isEmpty())
			{
				WorkOrder otSeleccionada = listaOT.get(0);
				String errorReservaCita = Util_Orden_Trabajo.permiteReservaPrimeraCita(otSeleccionada);
				String errorSiniestrosConsumidos = 'Siniestros Manitas Consumidos = 2, NO se permite Abrir el Siniestro porque se ha consumido ya el número permitido por vigencia de la póliza';
				if (errorReservaCita != null)
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorReservaCita));		
				}
				else 
				{
					if(otSeleccionada.OTR_CAS_Urgente__c){
						try{
							ReservarCitaUrgente.reservaCita(idOrdenTrabajo);
							Date fechaCreacion = otSeleccionada.CreatedDate.date();
							Time horaCreacion = otSeleccionada.CreatedDate.time();
							fechaCitaUrgenteReservada = String.valueOf(fechaCreacion) + ' a las ' + horaCreacion.hour() + ':' + horaCreacion.minute();
						} catch(DMLException e) {
							System.debug('SiniReparableController:  reservarCita: e.getMessage: '+e.getMessage());
						}
					} else{
						paginaRedireccion = new PageReference('/apex/' + Label.VF_RESERVARCITA);
						paginaRedireccion.getParameters().put('numeroGremiosArbolSalida',String.valueOf(numeroGremiosArbolSalida));
						paginaRedireccion.getParameters().put('idConfirmacion',confirmacion.Id);
                        paginaRedireccion = agregarParametrosURL(paginaRedireccion, intervencion.Id, '/apex/'+Label.VF_SINI_REPARABLE_CONFIRMACION);
						paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
						paginaRedireccion.setRedirect(true);
					}
				}
			}
		}
		return paginaRedireccion;
	}

    //Estaba en Develop ¿Se usa este método?
	public PageReference cambiarCita() {
		PageReference paginaRedireccion = null;
		Integer indice=Integer.valueOf(ApexPages.currentPage().getParameters().get('indice'));
		WorkOrder wo = listaOrdenesTrabajo.get(indice-1); 
		ServiceAppointment cita = new ServiceAppointment();
		system.debug('SiniReparableConfirmacionController : cambiarCita : wo : '+wo);
		system.debug('SiniReparableConfirmacionController : cambiarCita : Util_Cita_Servicio.SET_ESTADOS_CERRADOS : '+Util_Cita_Servicio.SET_ESTADOS_CERRADOS);
		List<ServiceAppointment> listaCitas= Util_Cita_Servicio.getListCitasOTsNotInStatus(wo.Id, Util_Cita_Servicio.SET_ESTADOS_CERRADOS);
		if(!listaCitas.isEmpty()){
			try {
				cita = listaCitas.get(0);
				cita.Status = Label.CIT_ESTADO_PTE_ASIGNAR;
				update cita;
				ServiceAppointment nuevaCita = cita.clone(false, true, false, false);
				nuevaCita.SchedStartTime = null;
				nuevaCita.SchedEndTime = null;
				nuevaCita.ArrivalWindowStartTime = null;
				nuevaCita.ArrivalWindowEndTime = null;
				nuevaCita.Status = Label.CIT_ESTADO_PTE_ASIGNAR;
				insert nuevacita;
			} catch(Exception e) {
				System.debug('SiniReparableAperturaController: cambiarCita: e.getStackTraceString: '+e.getStackTraceString());
			}
			mensajeHabilidades = true;
			paginaRedireccion = reservarCita();
		}
		return paginaRedireccion;
	}								 
	
	public PageReference actualizarPartidas() {
		String idOrdenTrabajo=ApexPages.currentPage().getParameters().get('idOrdenTrabajo');
		PageReference paginaRedireccion=null;
		List<BigMachines__Quote__c> quote = new List<BigMachines__Quote__c>(
					[SELECT BigMachines__Transaction_Id__c , OQU_LKP_Work_Order__c, BigMachines__Is_Primary__c  
					 FROM BigMachines__Quote__c 
					 WHERE OQU_LKP_Work_Order__c = :idOrdenTrabajo]);
			if(quote.isEmpty()){
				paginaRedireccion = new PageReference('/apex/' + Label.VF_QUOTE_CREATE);
			}
			else {
				paginaRedireccion = new PageReference('/apex/' + Label.VF_QUOTE_EDIT);
			}
		paginaRedireccion = agregarParametrosURL(paginaRedireccion, intervencion.Id, '/apex/'+Label.VF_SINI_REPARABLE_CONFIRMACION);
		//paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
		paginaRedireccion.getParameters().put('idWorkO', idOrdenTrabajo);
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion; 
	}//FIN actualizarPartidas()

	
	public void finalizarConfirmacionSalesforce() {

		System.debug('SiniReparableAperturaController: finalizarAperturaSalesforce: finalizarAperturaSaleforceMostradoMensajePartidas: '+finalizarAperturaSaleforceMostradoMensajePartidas);
		//Siempre antes de finalizar muestro el mensaje de Partidas.
		if (String.isEmpty(mensajeManitas)) {
			mensajeManitas=Label.WARNING_ACTUALIZAR_PARTIDAS;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.WARNING_ACTUALIZAR_PARTIDAS));
		
			//Reglas de buzón web
			Set<String> setGremios = new Set<String>();
			//Comprobamos que no se ha cambiado el tipo de actuación respecto al siniestro
			if(confirmacion.CNF_SEL_Tipo__c != intervencion.Type){
				System.debug('SiniReparableAperturaController: finalizarAperturaSalesforce: confirmacion.CNF_SEL_Tipo__c: '+confirmacion.CNF_SEL_Tipo__c);
				System.debug('SiniReparableAperturaController: finalizarAperturaSalesforce: intervencion.Type: '+intervencion.Type);
				listaReglasBuzonWebIncumplidas.add(Label.CNF_REGLA_TIPO_ACTUACION);
			}
		
			//Comprobamos que no se ha cambiado el check requiere perito respecto al siniestro
			if(confirmacion.CNF_CAS_Requiere_Perito__c != intervencion.CAS_CAS_Requiere_Perito__c){
				listaReglasBuzonWebIncumplidas.add(Label.CNF_REGLA_REQUIERE_PERITO);
			}
			//Comprobamos que no se ha marcado el check de grave en la confirmación
			//En caso afirmativo se marca el check de requiere perito de la comfirmación
			if(intervencion.CAS_CAS_Siniestro_Grave__c!=confirmacion.CNF_CAS_Siniestro_Grave__c){
				//SE COMPRUEBA SI CUMPLE LAS CONDICIONES PARA SER GRAVE
				if (Util_Siniestro.validarCondicionesSiniGrave(intervencion)) {
					convertirAGrave();
					convertidoAGrave = true;
					listaReglasBuzonWebIncumplidas.add(Label.CNF_REGLA_GRAVE);
					confirmacion.CNF_CAS_Requiere_Perito__c = true;
					//update confirmacion;
					actualizarConfirmacion = true;
				}
			}

			//Rellenamos un set con todos los gremios seleccionados en el siniestro a la vez que comprobamos si en algún servicio se ha superado el límite de tramitación exprés
			for(WorkOrder wo: listaOrdenesTrabajo){
				if(wo.OTR_CAS_Lim_Tramitacion_Expres_Superado__c && !listaReglasBuzonWebIncumplidas.contains(Label.CNF_REGLA_TRAMITACION_EXPRES)){
					listaReglasBuzonWebIncumplidas.add(Label.CNF_REGLA_TRAMITACION_EXPRES);
				}
				setGremios.add(wo.OTR_SEL_Gremio__c);
			}
			//Comprobamos que no se han seleccionado más gremios que los proporcionados por el árbol de salida
			if(!setGremios.isEmpty()){
				System.debug('SiniReparableAperturaController: finalizarAperturaSalesforce: setGremios.size(): '+setGremios.size());
				System.debug('SiniReparableAperturaController: finalizarAperturaSalesforce: numeroGremiosArbolSalida: '+numeroGremiosArbolSalida);
				if(setGremios.size() > numeroGremiosArbolSalida){
					listaReglasBuzonWebIncumplidas.add(Label.CNF_REGLA_GREMIO);
				}
			}
			//Comprobamos que el total de la facturaciuón de todas las partidas de todos los servicios del siniestro no supera el límite de actuación de la compañía
			Decimal importeTotal = Util_Caso.calcularTotalFacturarCIA(listaOrdenesTrabajo);
			if(intervencion.CAS_LKP_Compania__r.CUE_DIV_Limite_Actuacion__c != null){
				if(importeTotal > intervencion.CAS_LKP_Compania__r.CUE_DIV_Limite_Actuacion__c){
					listaReglasBuzonWebIncumplidas.add(Label.CNF_REGLA_LIMITE_ACTUACION);
					confirmacion.CNF_CAS_Requiere_Perito__c = true;
					//update confirmacion;
					actualizarConfirmacion = true;
				}
			}
	
		} /*	if(!reglasBuzonWebEvaluadas) {
				//Reglas de buzón web
				Set<String> setGremios = new Set<String>();
				//Comprobamos que no se ha cambiado el tipo de actuación respecto al siniestro
				if(confirmacion.CNF_SEL_Tipo__c != intervencion.Type){
					listaReglasBuzonWebIncumplidas.add(Label.CNF_REGLA_TIPO_ACTUACION);
				}
			
				//Comprobamos que no se ha cambiado el check requiere perito respecto al siniestro
				if(confirmacion.CNF_CAS_Requiere_Perito__c != intervencion.CAS_CAS_Requiere_Perito__c){
					listaReglasBuzonWebIncumplidas.add(Label.CNF_REGLA_REQUIERE_PERITO);
				}
				//Comprobamos que no se ha marcado el check de grave en la confirmación
				//En caso afirmativo se marca el check de requiere perito de la comfirmación
				if(intervencion.CAS_CAS_Siniestro_Grave__c!=confirmacion.CNF_CAS_Siniestro_Grave__c){
					//SE COMPRUEBA SI CUMPLE LAS CONDICIONES PARA SER GRAVE
					if (Util_Siniestro.validarCondicionesSiniGrave(intervencion)) {
						convertirAGrave();
						convertidoAGrave = true;
						listaReglasBuzonWebIncumplidas.add(Label.CNF_REGLA_GRAVE);
						confirmacion.CNF_CAS_Requiere_Perito__c = true;
						actualizarConfirmacion = true;
					}
				}

				//Rellenamos un set con todos los gremios seleccionados en el siniestro a la vez que comprobamos si en algún servicio se ha superado el límite de tramitación exprés
				for(WorkOrder wo: listaOrdenesTrabajo){
					if(wo.OTR_CAS_Lim_Tramitacion_Expres_Superado__c && !listaReglasBuzonWebIncumplidas.contains(Label.CNF_REGLA_TRAMITACION_EXPRES)){
						listaReglasBuzonWebIncumplidas.add(Label.CNF_REGLA_TRAMITACION_EXPRES);
					}
					setGremios.add(wo.OTR_SEL_Gremio__c);
				}
				//Comprobamos que no se han seleccionado más gremios que los proporcionados por el árbol de salida
				if(!setGremios.isEmpty()){
					if(setGremios.size() > numeroGremiosArbolSalida){
						listaReglasBuzonWebIncumplidas.add(Label.CNF_REGLA_GREMIO);
					}
				}
				//Comprobamos que el total de la facturaciuón de todas las partidas de todos los servicios del siniestro no supera el límite de actuación de la compañía
				Decimal importeTotal = Util_Caso.calcularTotalFacturarCIA(listaOrdenesTrabajo);
				if(intervencion.CAS_LKP_Compania__r.CUE_DIV_Limite_Actuacion__c != null){
					if(importeTotal > intervencion.CAS_LKP_Compania__r.CUE_DIV_Limite_Actuacion__c){
						listaReglasBuzonWebIncumplidas.add(Label.CNF_REGLA_LIMITE_ACTUACION);
						confirmacion.CNF_CAS_Requiere_Perito__c = true;
						actualizarConfirmacion = true;
					}
				}

				System.debug('SiniReparableConfirmacionController: finalizarApertura: numero Reglas incumplidas: '+listaReglasBuzonWebIncumplidas.size());
					if(!listaReglasBuzonWebIncumplidas.isEmpty()) {
						enumeracionErrores = '';
						for(String regla: listaReglasBuzonWebIncumplidas){
							if(regla == listaReglasBuzonWebIncumplidas.get(0)){
								enumeracionErrores += regla;
							}
							else{
								enumeracionErrores += '. \n' + regla;
							}					
						}

						if(nombrePerfilUsuario.equalsIgnoreCase(Label.PERFIL_GESTOR_FRONT_TRAMITACION)) {
							String mensaje = 'Se han incumplido las siguiente reglas de buzón web: \n' + enumeracionErrores;
							mensajeReglasBuzonWeb=mensaje;
						}
						//Si se ha incumplido alguna regla y el usuario un profesional, al gestor asignado al siniestro le saltará una tarea indicando las reglas que se están incumpliendo
						//Al profesional le saltará un error indicando que se le ha bloqueado la confirmación y solo le dejará volver
						else if (nombrePerfilUsuario.equalsIgnoreCase(Label.PERFIL_PROFESIONAL)){
							mensajeReglasBuzonWeb=Label.ERROR_CONFIRMACION_BLOQUEADA;
						}
					} 
				reglasBuzonWebEvaluadas=true;
			}else if(reglasBuzonWebEvaluadas) {	
				try {
						if(nombrePerfilUsuario.equalsIgnoreCase(Label.PERFIL_PROFESIONAL)){
							
							if(listaReglasBuzonWebIncumplidas.isEmpty()) {
								confirmacion.CNF_SEL_Estado_Confirmacion__c=Label.CNF_ESTADO_BLOQUEADA_PROF;
							} else {
								confirmacion.CNF_SEL_Estado_Confirmacion__c='03';
								actualizarSiniestro();
								intervencion.Status = Label.CAS_ESTADO_EN_CURSO; 
								intervencion.CAS_CAS_Confirmado__c=true;
							}
						} else {
							System.debug('Reparable');
							actualizarSiniestro();
							intervencion.Status = Label.CAS_ESTADO_EN_CURSO;
							intervencion.CAS_CAS_Confirmado__c=true;
							actualizarSiniestro();
							confirmacion.CNF_SEL_Estado_Confirmacion__c='06';
						}
						/*if(intervencion.CAS_CAS_Presolicitud_Perito__c && intervencion.CAS_LKP_Perito__c == null) {
							System.debug('Si entra por aquí está MAL. sólo se actualiza 1 vez la intervención por VF. Y el método asignarPerito lo actualiza.');
							asignarPerito();
						}	
					
						confirmacion.CNF_CAS_Confirmado__c=true;
						update confirmacion;
					
						update intervencion;
					} catch(DmlException e){
						System.debug('SiniReparableAperturaController: finalizarAperturaSalesforce:  e.getStackTraceString: ' + e.getStackTraceString());
						mensajesErrorfinalizarAperturaSalesforce=Label.ERROR_GUARDAR + ' : ' + e.getMessage();
					} catch(Exception e) {
							mensajesErrorfinalizarAperturaSalesforce=Label.ERROR_GUARDAR + ' : ' + e.getMessage();
							System.debug('SiniReparableAperturaController: finalizarAperturaSalesforce:  e.getStackTraceString: ' + e.getStackTraceString());
					}
				}
			
		System.debug('SiniReparableAperturaController: finalizarAperturaSalesforce: FIN');  
		}//FIN finalizarApertura_paso1 */
	}

	public void guardarConfirmacion() {
		system.Savepoint puntoGuardado;								
		Task tareaAlGestor=new Task();
		List<Garantia_Siniestro__c> listaGarantiasCasoToDelete=Util_Siniestro.queryGarantiasExistentes(new set<Id>{intervencion.Id}).values();
        List<Garantia_Siniestro__c> listaGarantiasCasoToUpsert=Util_Siniestro.queryGarantiasExistentes(new set<Id>{confirmacion.Id}).values();
                
        Set<Id> setIdWo = new Set<Id>();								 
		for(WorkOrder wo: listaOrdenesTrabajo){
			setIdWo.add(wo.Id);							   
		}

		Map<Id,List<WorkOrderLineItem>> mapaWoli = Util_Orden_Trabajo.getMapaPartidasOTs(setIdWo);
		for(WorkOrder wo: listaOrdenesTrabajo){
			Integer numPartidas = 0;
			if(mapaWoli.get(wo.Id) != null && !mapaWoli.get(wo.Id).isEmpty()){
				numPartidas = mapaWoli.get(wo.Id).size();
			}
			if(wo.Status != Label.OTR_ESTADO_ANULADO && wo.Status != Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO && wo.Status != Label.OTR_ESTADO_ANULADO_POR_PROF && numPartidas == 0){
				mensajesErrorfinalizarAperturaSalesforce = 'No puede continuar si existen Servicios no anulados sin valorar';
			}
		}
		System.debug('SiniReparableConfirmacionController: guardarConfirmacion: listaReglasBuzonWebIncumplidas: '+listaReglasBuzonWebIncumplidas);
		if(String.isEmpty(mensajesErrorfinalizarAperturaSalesforce)){
			try {
				puntoGuardado = Database.setSavepoint();
				if(nombrePerfilUsuario.equalsIgnoreCase(Label.PERFIL_PROFESIONAL)){
					if(listaReglasBuzonWebIncumplidas.isEmpty()) {
						System.debug('SiniReparableConfirmacionController: guardarConfirmacion: No incumplidas: ');
						actualizarSiniestro();
						confirmacion.CNF_SEL_Estado_Confirmacion__c='03'; //Confirmado
						confirmacion.CNF_CAS_Confirmado__c=true; 
						intervencion.Status='001'; //En curso.
						//Borro las garantías del caso y actualizo con las de la confirmación.
						if(!listaGarantiasCasoToDelete.isEmpty()) {
							Database.delete(listaGarantiasCasoToDelete);
						}
						if(!listaGarantiasCasoToUpsert.isEmpty()) {
							for(Garantia_Siniestro__c garantia:listaGarantiasCasoToUpsert) {
								garantia.GSIN_LKP_Caso__c=intervencion.Id;
							}
							Database.upsert(listaGarantiasCasoToUpsert);
						}
					}
					else {
						System.debug('SiniReparableConfirmacionController: guardarConfirmacion: incumplidas: ');
						//Enviamos tarea al Gestor.
						tareaAlGestor = Util_tarea.crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_CONFIRMAR_SINIESTRO,Label.TAR_ESTADO_EN_CURSO, '', intervencion.OwnerId, intervencion.Id, intervencion.CAS_LKP_Compania__c);
						tareaAlGestor.Description = 'Se ha bloqueado la Confirmación al Profesional por el incumplimiento de las siguientes reglas: \n';
						for(String reglaInclumplida:listaReglasBuzonWebIncumplidas) {
							tareaAlGestor.Description += reglaInclumplida + '\n';
						}
						insert tareaAlGestor;
						intervencion.Status='995';	//En Espera de Gestor.
						confirmacion.CNF_SEL_Estado_Confirmacion__c='04';
						confirmacion.CNF_CAS_Confirmado__c=true; 																			   
					}  
				} else {
					if(listaReglasBuzonWebIncumplidas.isEmpty()) {
						System.debug('SiniReparableConfirmacionController: guardarConfirmacion: incumplidas: ');
						actualizarSiniestro();
						intervencion.Status='001'; //EN curso.
						intervencion.CAS_CAS_Confirmado__c=true;
						confirmacion.CNF_CAS_Confirmado__c=true; 
						confirmacion.CNF_SEL_Estado_Confirmacion__c='06';
						//Borro las garantías del caso y actualizo con las de la confirmación.
						if(!listaGarantiasCasoToDelete.isEmpty()) {
							Database.delete(listaGarantiasCasoToDelete);
						}
						if(!listaGarantiasCasoToUpsert.isEmpty()) {
							for(Garantia_Siniestro__c garantia:listaGarantiasCasoToUpsert) {
								garantia.GSIN_LKP_Caso__c=intervencion.Id;
							}
							Database.upsert(listaGarantiasCasoToUpsert);
						}
					}
					else {
						System.debug('SiniReparableConfirmacionController: guardarConfirmacion: incumplidas: ');
						actualizarSiniestro();
						intervencion.Status='001'; //EN curso.
						intervencion.CAS_CAS_Confirmado__c=true;
						confirmacion.CNF_CAS_Confirmado__c=true; 
						confirmacion.CNF_SEL_Estado_Confirmacion__c='06';
						//Borro las garantías del caso y actualizo con las de la confirmación.
						if(!listaGarantiasCasoToDelete.isEmpty()) {
							Database.delete(listaGarantiasCasoToDelete);
						}
						if(!listaGarantiasCasoToUpsert.isEmpty()) {
							for(Garantia_Siniestro__c garantia:listaGarantiasCasoToUpsert) {
								garantia.GSIN_LKP_Caso__c=intervencion.Id;
							}
							Database.upsert(listaGarantiasCasoToUpsert);
						}
					}
				}
											
				//Se genera el movimiento de cambio de garantías si no son iguales las listas
				if(!(sonIguales(listaGarantiasCasoToUpsert, listaGarantiasCasoToDelete))){
        			Util_Movimientos.compruebaEnviable(intervencion.Id,intervencion.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'9');
        		}
				
				if(intervencion.CAS_CAS_Confirmado__c) {
					insert newComentarioCaso;
				}
				upsert intervencion;
				upsert confirmacion;
				//Borrar las Garantías del caso.
				
				//Insertarle las que tenga la Confirmación.
	
			}
			catch(DmlException e){
				Database.rollback(puntoGuardado);
				System.debug('SiniReparableAperturaController: finalizarAperturaSalesforce:  e.getStackTraceString: ' + e.getStackTraceString());
				mensajesErrorfinalizarAperturaSalesforce=Label.ERROR_GUARDAR + ' : ' + e.getMessage();
			}
			catch(Exception e) {
				Database.rollback(puntoGuardado);
				mensajesErrorfinalizarAperturaSalesforce=Label.ERROR_GUARDAR + ' : ' + e.getMessage();
				System.debug('SiniReparableAperturaController: finalizarAperturaSalesforce:  e.getStackTraceString: ' + e.getStackTraceString());
			}
		}
	}
	
	//Compara las listas de garantías y devuelve un booleano que indica si ambas son iguales
	public Boolean sonIguales(List<Garantia_Siniestro__c> listaGarantiasCasoToUpsert, List<Garantia_Siniestro__c> listaGarantiasCasoToDelete){
		Boolean iguales=true;
		Boolean salida;
		for(Garantia_Siniestro__c g : listaGarantiasCasoToUpsert){
			if(!listaGarantiasCasoToDelete.contains(g)){
				iguales = false;
			}
		}
		if(iguales == true && listaGarantiasCasoToUpsert.size() == listaGarantiasCasoToDelete.size()){
			salida = true;
		}else{
			salida = false;
		}
		return salida;
	}


	public PageReference navegarConfirmacionFinalizada() {
		PageReference paginaDestino;
		if(!String.isEmpty(mensajesErrorfinalizarAperturaSalesforce)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, mensajesErrorfinalizarAperturaSalesforce));
		}
		else {
			paginaDestino=Page.SiniConfirmacionFinalizada;
			paginaDestino.getParameters().put('inline','1');
			if(listaReglasBuzonWebIncumplidas.isEmpty()) {
				paginaDestino.getParameters().put('Id',intervencion.Id);
				paginaDestino.getParameters().put('0','La confirmación se ha realizado con éxito.');
			}
			else {
				paginaDestino.getParameters().put('Id',intervencion.Id);
				if(Label.PERFIL_PROFESIONAL.equalsIgnoreCase(nombrePerfilUsuario)) {
					paginaDestino.getParameters().put('0','La confirmación ha sido bloqueada.');
				}
				else {
					Integer contador=0;
					for(String reglaIncumplida:listaReglasBuzonWebIncumplidas) {
						//La primera vez, que ponga:
						if(contador==0){
							paginaDestino.getParameters().put(String.valueOf(contador),'Se han incumplido la siguientes reglas de buzón web: \n');
							contador++;
						}
						paginaDestino.getParameters().put(String.valueOf(contador),reglaIncumplida);
						contador++;
					}
				}
			}
		}
		System.debug('SiniReparableConfirmacionController: navegarConfirmacionFinalizada: paginaDestino: '+paginaDestino);
		return paginaDestino;
	}
	
	private void actualizarSiniestro() {
		//Marcamos el siniestro como confirmado
		intervencion.CAS_CAS_Confirmado__c = true;
		//Actualizamos el siniestro con los valores de la confirmación
        intervencion.CAS_SEL_Causa_Averia__c = confirmacion.CNF_SEL_Causa_Averia__c;
        intervencion.CAS_SEL_Situacion_Danos_Propios__c = confirmacion.CNF_SEL_Situacion_Danos_Propios__c;
		intervencion.CAS_SEL_Detalle_Averia__c = confirmacion.CNF_SEL_Detalle_averia__c;                                                                             
		intervencion.CAS_SEL_Grupo_Causa__c = confirmacion.CNF_SEL_Grupo_Causa__c;                                                                             
		intervencion.CAS_SEL_Otros_Danos__c = confirmacion.CNF_SEL_Otros_Danos__c;                                                                     
		intervencion.CAS_CAS_Tercero_Causante__c = confirmacion.CNF_CAS_Tercero_Causante__c;                                                                
		intervencion.CAS_SEL_Tipo_Averia__c = confirmacion.CNF_SEL_Tipo_Averia__c;                                                                     
		intervencion.Type = confirmacion.CNF_SEL_Tipo__c;                                                                            
		intervencion.CAS_SEL_Causante_Responsable__c = confirmacion.CNF_SEL_Causante_Responsable__c;                                                            
		intervencion.CAS_TXT_Nombre__c = confirmacion.CNF_TXT_Nombre__c;                                                                          
		intervencion.CAS_TXT_Apellidos__c = confirmacion.CNF_TXT_Apellidos__c;                                                                       
		intervencion.CAS_TXT_Apellidos_2__c = confirmacion.CNF_TXT_Apellidos2__c;                                                                      
		intervencion.CAS_SEL_Causante_Tipo_Documento__c = confirmacion.CNF_SEL_Causante_Tipo_Documento__c;                                                         
		intervencion.CAS_TXT_Causante_N_Documento__c = confirmacion.CNF_TXT_Causante_N_Documento__c;                                                            
		intervencion.CAS_TXT_Causante_Direccion__c = confirmacion.CNF_TXT_Causante_Direccion__c;                                                              
		intervencion.CAS_TXT_Codigo_Postal__c = confirmacion.CNF_TXT_Codigo_Postal__c;                                                                   
		intervencion.CAS_TXT_Causante_Poblacion__c = confirmacion.CNF_TXT_Causante_Poblacion__c;                                                              
		intervencion.CAS_SEL_Causante_Provincia__c = confirmacion.CNF_SEL_Causante_Provincia__c;                                                              
		intervencion.CAS_TFN_Telefono_1__c = confirmacion.CNF_TFN_Telefono_1__c;                                                                      
		intervencion.CAS_TFN_Telefono_2__c = confirmacion.CNF_TFN_Telefono_2__c;                                                                      
		intervencion.CAS_EMA_Email__c = confirmacion.CNF_EMA_Email__c;                                                                           
		intervencion.CAS_SEL_Causante_Compania__c = confirmacion.CNF_SEL_Causante_Compania__c;                                                               
		intervencion.CAS_TXT_Causante_Poliza_R_C__c = confirmacion.CNF_TXT_Causante_Poliza_R_C__c;                                                             
		intervencion.CAS_TXT_Causante_N_exp_Stro__c = confirmacion.CNF_TXT_Causante_N_exp_Stro__c;                                                             
		intervencion.CAS_CAS_Danos_Propios__c = confirmacion.CNF_CAS_Danos_Propios__c;                                                                   
		intervencion.CAS_CAS_Danos_Perjudicado__c = confirmacion.CNF_CAS_Danos_Perjudicado__c;   

		if(!String.isEmpty(confirmacion.CNF_TXT_Comentario__c)) {
			newComentarioCaso=new Comentario_caso__c(CMC_LKP_Caso__c=intervencion.Id,CMC_SEL_Tipo__c='05',CMC_TXT_Comentario__c=confirmacion.CNF_TXT_Comentario__c);
		}   
    }
	
	private void convertirAGrave(){																	
		system.Savepoint puntoGuardado = Database.setSavepoint();
		try {
			intervencion.CAS_CAS_Siniestro_Grave__c = true;
			update intervencion;
			generaMovimientos();
		}
		catch(DmlException e){
			Database.rollback(puntoGuardado);
			system.debug(e.getStackTraceString());
			if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			}
		}
		catch(Exception e){
			Database.rollback(puntoGuardado);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			system.debug(e.getStackTraceString());
		}
	}


	private void generaMovimientos(){
		if (Util_Siniestro.esSiniestro(intervencion)){
			if(intervencion.CAS_LKP_Perito__c != null && idPerito != intervencion.CAS_LKP_Perito__c){
				Util_Movimientos.compruebaEnviable(intervencion.Id,intervencion.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,'39');
				idPerito = intervencion.CAS_LKP_Perito__c;
			}
		}
	}


	public PageReference navegarDetalleCaso(Case cas) {
		PageReference paginaNavegar = new PageReference('/' + cas.Id);
		paginaNavegar.setRedirect(true);
		return paginaNavegar;
	}


	public void asignarPerito(){
		if(!peritoAsignado){
			peritoAsignado=true;
			if(propietario) {
				intervencion.CAS_CAS_Requiere_Perito__c = true;
													 
														  
				intervencion.CAS_TXT_Comentario_Perito__c = comentarioFormateadoPerito.comentarioCaso.CMC_TXT_Comentario__c;
				intervencion = Util_Perito.procesoAsignacion(intervencion);
				if (intervencion.CAS_LKP_Perito__c!=null){
					update intervencion;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Se ha realizado con éxito la asignación del perito'));
				} else{
		 
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ha fallado el proceso de asignación de perito')); 
				} 
			}else{
		
				if(esProfesional || listaTareas.isEmpty()){
					intervencion.CAS_CAS_Presolicitud_Perito__c = true;
					update intervencion;
					insert Util_tarea.crearTarea(Label.RT_TAR_PRESOLICITUD_PERITO,Label.TAR_ASUNTO_SOLICITAR_PERITO, Label.TAR_ESTADO_EN_CURSO, null,intervencion.OwnerId,intervencion.Id,intervencion.CAS_LKP_Compania__c);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Se ha solicitado la asignación del perito al propietario del caso'));
				} else{
		 
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'El propietario del caso ya ha rechazado anteriormente la solicitud de perito'));
				}
			}
		}
	}

	public PageReference navegarFinalizadaConfirmacion() {
		PageReference paginaDestino = null;
		System.debug(mensajeManitas);
		System.debug(mensajeReglasBuzonWeb+' : ' +reglasBuzonWebEvaluadas);
		System.debug(mensajeManitas);
		if(String.isEmpty(mensajeManitas)){
			mensajeManitas=Label.WARNING_ACTUALIZAR_PARTIDAS;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.WARNING_ACTUALIZAR_PARTIDAS));
		}
		if(reglasBuzonWebEvaluadas && !String.isEmpty(mensajeManitas) && !String.isEmpty(mensajeReglasBuzonWeb)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, mensajeReglasBuzonWeb));
			mensajeReglasBuzonWeb='';
		}
		else if(reglasBuzonWebEvaluadas &&  !String.isEmpty(mensajeManitas) && String.isEmpty(mensajeReglasBuzonWeb)) {
			paginaDestino=new PageReference('/'+intervencion.Id);
		}
		System.debug('paginaDestino: '+paginaDestino);
		return paginaDestino;
	}
}