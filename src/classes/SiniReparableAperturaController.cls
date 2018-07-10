/**
 * Clase controladora de la Visualforce "SiniReparableApertura" encargada de gestionar los gremios de un Siniestro durante la Apertura.
 * 
 * @author EVERIS
 */
public without sharing class SiniReparableAperturaController {
	public Case intervencion{get;set;}
	public ComentarioFormateado comentarioFormateado {get; set;}
	public List<ComentarioFormateado> listaComentariosIntervencion {get; set;}
	public List<WorkOrder> listaOrdenesTrabajo {get; set;}
	public Map<Id, List<ComentarioFormateado>> mapaComentariosPorOrdenTrabajo {get; set;}
	public Map<Id, ComentarioFormateado> mapaNuevoComentarioOrdenTrabajo {get; set;}
	private Boolean mensajeHabilidades;
	//Mensajes del botón Finalizar apertura.
	private Boolean finalizarAperturaSaleforceMostradoMensajePartidas;
	public Boolean aperturaFinalizadaSalesforceCorrectamente {get;set;}
	private String mensajesInfofinalizarAperturaSalesforce;
	private String mensajesErrorfinalizarAperturaSalesforce;
	private String mensajeInfoComentarioPerito;
	//Mensaje de Error del botón Salir.
	private String mensajeErrorSalir;
	//Grave - Perito - Urgente
	private Boolean convertidoAGrave;
	private String idPerito;
	public String fechaCitaUrgenteReservada{get;set;}
	//ICA
	public Boolean propietario {get; set;}
	private Boolean peritoAsignado;
	public ComentarioFormateado comentarioFormateadoPerito{get; set;}
	public List<ComentarioFormateado> listaComentariosPerito {get; set;}


	public SiniReparableAperturaController(ApexPages.standardController standarController) {
		comentarioFormateadoPerito = new ComentarioFormateado('perito');
		listaComentariosPerito = new List<ComentarioFormateado>();
		comentarioFormateado= new ComentarioFormateado();
		listaComentariosIntervencion=new List<ComentarioFormateado>();
		intervencion=new Case();
		listaOrdenesTrabajo=new List<WorkOrder>();
		mapaComentariosPorOrdenTrabajo=new Map<Id, List<ComentarioFormateado>>();
		mapaNuevoComentarioOrdenTrabajo=new Map<Id, ComentarioFormateado>();
		mensajeHabilidades=false;
		peritoAsignado = false;
		finalizarAperturaSaleforceMostradoMensajePartidas = false;
		convertidoAGrave=false;
		aperturaFinalizadaSalesforceCorrectamente=false;
		idPerito = '';
		mensajeErrorSalir='';
		mensajesInfofinalizarAperturaSalesforce='';
		mensajesErrorfinalizarAperturaSalesforce='';
		mensajeInfoComentarioPerito = '';
		//Recupero la intervención.
	   for(Case casoAux: Util_Caso.getCaseById(new Set<Id>{standarController.getRecord().Id}).values()) {
		   intervencion=casoAux;
	   }
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

		//Actualizo las Ordenes de trabajo y sus Comentarios.
		actualizarOrdenesTrabajoYComentariosDeOrdenesTrabjao();
		//Al entrar, inicio el perito. Si cambia, se generará movimiento. 
		idPerito=intervencion.CAS_LKP_Perito__c;
		//ICA
		propietario = (UserInfo.getUserId() == intervencion.OwnerId);
	}
	
	public PageReference insertarComentarioPerito() {
		if(comentarioFormateadoPerito.comentarioCaso != null){
			intervencion.CAS_TXT_Comentario_Perito__c = comentarioFormateadoPerito.comentarioCaso.CMC_TXT_Comentario__c;
			update intervencion;
		}
		comentarioFormateadoPerito.comentarioCaso.CMC_LKP_Caso__c = intervencion.id;
		comentarioFormateado = comentarioFormateadoPerito;
		return insertarComentarioCaso();
	}

	public PageReference insertarComentarioCaso() {
		PageReference paginaRedireccion;
		if (!String.isEmpty(comentarioFormateado.comentarioCaso.CMC_TXT_Comentario__c)) {
			comentarioFormateado.comentarioCaso.CMC_LKP_Caso__c=intervencion.Id;
			System.Savepoint puntoGuardado = Database.setSavepoint();
			try {
				insert  comentarioFormateado.comentarioCaso;
				paginaRedireccion = Page.SiniReparableApertura;
				paginaRedireccion.getParameters().put('guardadoOK', 'Y');
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
		PageReference paginaRedireccion = null;
		/*if(!peritoAsignado && intervencion.CAS_CAS_Requiere_Perito__c){
			asignarPerito();
		}*/
		//Siempre antes de finalizar muestro el mensaje de Partidas.
		List<WorkOrder> listaOTsSinReserva = Util_Orden_Trabajo.getWorkOrderByCaseAndRecordTypeAndStatus(new Set<Id>{intervencion.Id},new Set<Id>{Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)},new Set<String>{Label.OTR_ESTADO_ANULADO,Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO},new Set<String>{Label.OTR_ESTADO_INACTIVO_CLIENTE}).values();
		if(listaOTsSinReserva.isEmpty()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_FINALIZAR_APERTURA_B2B_FALTA));
			mensajesErrorfinalizarAperturaSalesforce=Label.ERROR_FINALIZAR_APERTURA_B2B_FALTA;
		} else if (String.isEmpty(mensajesInfofinalizarAperturaSalesforce) || String.isEmpty(mensajeInfoComentarioPerito)) {
			if(String.isEmpty(mensajesInfofinalizarAperturaSalesforce)){
				mensajesInfofinalizarAperturaSalesforce=Label.WARNING_ACTUALIZAR_PARTIDAS;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.WARNING_ACTUALIZAR_PARTIDAS));
			}
			if(String.isEmpty(mensajeInfoComentarioPerito)) {
				mensajeInfoComentarioPerito=Label.WARNING_COMENTARIO_PERITO;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.WARNING_COMENTARIO_PERITO));
			}
		} 
		else {
			paginaRedireccion = new PageReference('/apex/' + Label.VF_SINI_CONTACTOS);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, intervencion.Id, '/apex/'+Label.VF_SINI_REPARABLE_APERTURA); 
			paginaRedireccion.setRedirect(true);
		}
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

	public PageReference salirInformarVesta(){
		PageReference paginaRedireccion = null;
		Callout_ActualizaSiniestroVesta.Resultado resultadoUpdVesta;
		System.debug('SiniReparableAperturaController: salirInformarVesta: mensajeErrorSalir: '+mensajeErrorSalir);
		if(!String.isEmpty(mensajeErrorSalir)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, mensajeErrorSalir));
		}
		else {
			try {
				if(intervencion.CAS_NUM_Id_Actuacion_SondeoExt__c != null){
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
			catch(Exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Se ha producido un error al actualizar VESTA. ' + e.getMessage()));
				system.debug(e.getStackTraceString());
			}
		}
		return paginaRedireccion;
	}

	public PageReference nuevoGremio() {
		PageReference paginaRedireccion = Page.Sini_Gremios;
		paginaRedireccion.getParameters().put('id', intervencion.Id);
		paginaRedireccion.getParameters().put('fase', Label.SINI_FASE_APERTURA);
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
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, intervencion.Id, '/apex/'+Label.VF_SINI_REPARABLE_APERTURA); 
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
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, intervencion.Id, '/apex/'+Label.VF_SINI_REPARABLE_APERTURA);
			paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
			paginaRedireccion.getParameters().put('anular', 'Y');
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN.


	private PageReference agregarParametrosURL(PageReference paginaRedireccion, Id idCaso, String retorno)
	{
		paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, Label.SINI_FASE_APERTURA);
		if (!String.isEmpty(idCaso)) {
			paginaRedireccion.getParameters().put('id',idCaso);
		}
		if (retorno != null)
		{
			paginaRedireccion.getParameters().put('retorno', retorno);
		}
		return paginaRedireccion;
	}//FIN agregarParametrosURL()

	public PageReference habilidadesRequeridas(){
		String idOrdenTrabajo=ApexPages.currentPage().getParameters().get('idOrdenTrabajo');
		PageReference paginaRedireccion = new PageReference('/apex/' + Label.VF_HABILIDADES_REQUERIDAS_OT);
		paginaRedireccion = agregarParametrosURL(paginaRedireccion, intervencion.Id,'/apex/'+Label.VF_SINI_REPARABLE_APERTURA);
		paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}

	public PageReference reservarCita(){
		String idOrdenTrabajo=ApexPages.currentPage().getParameters().get('idOrdenTrabajo');
		PageReference paginaRedireccion = null;
		System.debug('SiniReparableController:  reservarCita: idOrdenTrabajo: '+idOrdenTrabajo);
		if(!mensajeHabilidades){
			mensajeHabilidades = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_HABILIDADES_REQUERIDAS));
		}
		else {
			List<WorkOrder> listaOT = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{idOrdenTrabajo}).values();
			//List<WorkOrder> listaOT = Util_Orden_Trabajo.queryOT(idOrdenTrabajo, null, null);
			if(!listaOT.isEmpty()){
				WorkOrder otSeleccionada = listaOT.get(0);
				String errorReservaCita = Util_Orden_Trabajo.permiteReservaPrimeraCita(otSeleccionada);
				String errorSiniestrosConsumidos = 'Siniestros Manitas Consumidos = 2, NO se permite Abrir el Siniestro porque se ha consumido ya el número permitido por vigencia de la póliza';
				if(errorReservaCita != null){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorReservaCita));
				}
				else {
					if(otSeleccionada.OTR_CAS_Urgente__c){
						try {
							ReservarCitaUrgente.reservaCita(idOrdenTrabajo);
							Date fechaCreacion = otSeleccionada.CreatedDate.date();
							Time horaCreacion = otSeleccionada.CreatedDate.time();
							fechaCitaUrgenteReservada = String.valueOf(fechaCreacion) + ' a las ' + horaCreacion.hour() + ':' + horaCreacion.minute();
						}
						catch(DMLException e) {
							System.debug('SiniReparableController:  reservarCita: e.getMessage: '+e.getMessage());
						}
					}
					else {
						paginaRedireccion = new PageReference('/apex/' + Label.VF_RESERVARCITA);
						paginaRedireccion = agregarParametrosURL(paginaRedireccion, intervencion.Id, '/apex/'+Label.VF_SINI_REPARABLE_APERTURA);
						paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
						paginaRedireccion.setRedirect(true);
					}
				}
			}
		}
		return paginaRedireccion;
	}


	public PageReference cambiarCita() {
		PageReference paginaRedireccion = null;
		Integer indice=Integer.valueOf(ApexPages.currentPage().getParameters().get('indice'));
		WorkOrder wo = listaOrdenesTrabajo.get(indice-1);
		ServiceAppointment cita = Util_Cita_Servicio.getMapCitasById(new Set<Id>{wo.OTR_LKP_Primera_Cita__c}).get(wo.OTR_LKP_Primera_Cita__c);
		if(cita != null){
			system.Savepoint puntoGuardado = Database.setSavepoint();
			try {
				cita.Status = null;

				// Clonar la primera cita actual
				ServiceAppointment nuevaCita = Util_Cita_Servicio.nuevaCita(cita);

				// Establecer en estado ANULADO POR CAMBIO la primera cita actual
				cita.Status = Label.CIT_ESTADO_ANULADA_POR_CAMBIO;
				cita.CSE_CAS_Cambio_de_cita__c = true;

				// En los test no se carga la configuración FSL y salta error en la transición de estado de la cita
				if(!Test.isRunningTest()) update cita;
				// Insertar la nueva cita clonada
				insert nuevacita;
				// Refrescar datos de la nueva primera cita en la orden de tabajo actual
				listaOrdenesTrabajo.add(indice-1, Util_Orden_Trabajo.queryMapOTById(new Set<Id>{wo.Id}).values().get(0));
				// Acceder al asistente para reservar cita parala nueva primera cita
				mensajeHabilidades = true;
				paginaRedireccion = reservarCita();
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
				system.debug(e.getStackTraceString());
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			}
		}
		return paginaRedireccion;
	}


	public PageReference actualizarPartidas() {
		String idOrdenTrabajo=ApexPages.currentPage().getParameters().get('idOrdenTrabajo');
		PageReference paginaRedireccion = new PageReference('/apex/' + Label.VF_SIMULACION_CPQ);
		paginaRedireccion = agregarParametrosURL(paginaRedireccion, intervencion.Id, '/apex/'+Label.VF_SINI_REPARABLE_APERTURA);
		paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion; 
	}//FIN actualizarPartidas()

	

	private void convertirAGrave()
	{
		system.Savepoint puntoGuardado = Database.setSavepoint();
		try
		{
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
		catch(Exception e)
		{
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
			intervencion.CAS_CAS_Requiere_Perito__c = true;
			update intervencion;
			
			peritoAsignado = true;
		}
	}
		
		//comentarioFormateadoPerito.comentarioCaso
		/*
			if (Util_Perito.procesoAsignacion(intervencion)){ 
				update intervencion;
				peritoAsignado = true;
				comentarioFormateadoPerito.comentarioCaso.CMC_LKP_Caso__c = intervencion.id;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Se ha realizado con éxito la asignación del perito'));
			} else{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ha fallado el proceso de asignación de perito')); 
			}
		}*/
}