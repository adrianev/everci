/**
 * Clase controladora de la Visualforce "SiniReparableTramitacion" encargada de gestionar los gremios de un Siniestro.
 * 
 * @author EVERIS
 */
public without sharing class SiniReparableTramitacionController{
	private String solicitudExistente;
	public String fase {get; set;}
	public Case caso {get; set;}
	public ComentarioFormateado comentarioFormateadoPerito{get; set;}
	public List<ComentarioFormateado> listaComentariosPerito {get; set;}
	public List<ComentarioFormateado> listaComentsCaso {get; set;}
	public ComentarioFormateado nuevoComentCaso {get; set;}
	public List<WorkOrder> listaItems {get; set;}
	public WorkOrder nuevoItem {get; set;}
	public Presupuesto__c presupuesto {get; set;}
	public Integer indiceListaItems {get; set;}
	public Id idOrdenTrabajo {get; set;}
	public Map<Id, List<ComentarioFormateado>> mapaComentsOT {get; set;}
	public Map<Id, ComentarioFormateado> mapaNuevoComentsOT {get; set;}
	public String tipoServicio {get; set;}
	public Boolean otUrgente {get; set;}
	public Account cuenta {get; set;}
	public Boolean superaLimiteActuacion {get; set;}
	public Boolean generarPresupuesto {get; set;}
	public Boolean esProfesional {get; set;}
	public Boolean esProfesionalSec {get; set;}
	public Boolean esAdministrador {get; set;} // [INI] Nº35 : No permitir anular el gremio principal en Confirmación ni Tramitación para Gestor y Profesional : 09/07/2018 : SMM
	public String fechaCitaUrgenteReservada {get; set;}
	public Boolean existeGremioPrincipal {get; set;}
	private String codigoCIA;
	private Boolean warningHabilidades;
	public String correoRemitente {get;set;}
	private String errorMessage;
	public Boolean propietario {get; set;}
	private Boolean peritoAsignado;//Indica si se ha asignado perito mediante botón
	
	/**
	 * Constructor de la Clase.
     */
	public SiniReparableTramitacionController(ApexPages.standardController stdCtr){
		comentarioFormateadoPerito = new ComentarioFormateado('perito');
		listaComentariosPerito = new List<ComentarioFormateado>();
		
		propietario =false;
		superaLimiteActuacion = false;
		warningHabilidades = true;
		peritoAsignado = false;
		errorMessage = '';
		if (!Test.isRunningTest()) esProfesional = Util_Perfiles_Usuario.esProfesional(UserInfo.getProfileId());
		else esProfesional = true;
		esProfesionalSec = (esProfesional && (!Util_Perfiles_Usuario.esRecursoPrincipal(UserInfo.getUserId())));
		// [INI] Nº35 : No permitir anular el gremio principal en Confirmación ni Tramitación para Gestor y Profesional : 09/07/2018 : SMM
		esAdministrador = Util_Perfiles_Usuario.esAdministrador(UserInfo.getProfileId());
		system.debug('SiniReparableTramitacionController : Constructor : esAdministrador : '+esAdministrador);
		// [FIN] Nº35 : No permitir anular el gremio principal en Confirmación ni Tramitación para Gestor y Profesional

		PageReference paginaActual = ApexPages.currentPage();
		if(paginaActual.getParameters().containsKey('fase')){
			fase = paginaActual.getParameters().get('fase');
		}
		if(paginaActual.getParameters().containsKey('solicitudExistente')){
			solicitudExistente = paginaActual.getParameters().get('solicitudExistente');
		}
		if(!paginaActual.getParameters().containsKey('id')){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
		}
		else {
			mapaComentsOT = new Map<Id, List<ComentarioFormateado>>();
			mapaNuevoComentsOT = new Map<Id, ComentarioFormateado>();
			listaComentsCaso = new List<ComentarioFormateado>();
			nuevoComentCaso = new ComentarioFormateado(new Comentario_caso__c());

			// Cargamos campos necesarios del Caso
			List<Case> listaCasos = Util_Caso.getCaseById(new Set<Id>{stdCtr.getRecord().Id}).values();
			//List<Case> listaCasos = Util_B2B.queryCaso(stdCtr.getRecord().Id);
			if(listaCasos.isEmpty()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
			}
			else {
				caso = listaCasos.get(0);
				
				if(caso.CAS_LKP_Compania__c != null){
					codigoCIA = caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c;
				}
				List<Account> listaCuentas = Util_Cuentas.getMapCuentasById(new Set<Id>{caso.AccountId}).values();
				//List<Account> listaCuentas = Util_Cuentas.queryCuenta(caso.AccountId);
				if(!listaCuentas.isEmpty()){
					cuenta = listaCuentas.get(0);
				}

				List<Comentario_caso__c> listaComentsCasoAux = Util_Caso.getMapComentariosCaso(new Set<Id>{caso.Id}).get(caso.Id);
				for(Comentario_caso__c com : listaComentsCasoAux){
					listaComentsCaso.add(new ComentarioFormateado(com));
				}
				// Se carga la lista de Ordenes de Trabajo del Caso
				actualizarListaOTs();
				system.debug('<<<< listaItemls'+ listaItems);
				// Después de cargar las OTs y el caso buscamos si hay algún gremio que sea principal
				existeGremioPrincipal = (caso.CAS_LKP_Orden_Trabajo_Principal__c != null);
				
				if(paginaActual.getParameters().containsKey('guardadoOK')){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
				}
				//Se recoge el tipo de servicio
				tipoServicio = Util_mapasTiposDeRegistro.RTNAMEBYID.get(caso.RecordTypeId);

				superaLimiteActuacion = (caso.CAS_CAS_Supera_Limite_Actuacion__c);

				// Mostrar advertencia si es un correctivo y se ha superado el limite de actuación
				if(superaLimiteActuacion){
					if(esProfesional){
						if(caso.CAS_LKP_Compania__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c){
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_BLOQUEO_OT_PROF));
						}
						else {
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_BLOQUEO_OT_PROF_URGENTE));
						}
					}
					else {
						if(caso.CAS_LKP_Compania__r.CUE_CAS_Lim_Actuac_NoPermiteUrg__c){
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_SUPERA_LIMITE));
						}
						else {
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_SUPERA_LIMITE_CONURG));
						}
					}
				}
				presupuesto = Util_Presupuesto.getPresupuestosActuales(new Set<Id>{caso.Id}).get(caso.Id);
			}
		}
		propietario = (UserInfo.getUserId() == Caso.OwnerId);
	}//FIN CONSTRUCTOR


	/**
	 * Carga la lista de órdenes de trabajo mostrada.
     */
	private void actualizarListaOTs(){
		//Refrescar listado de Ordenes de Trabajo
		listaItems = Util_Orden_Trabajo.queryMapOTByCase(new Set<Id>{caso.Id}).values();
		//listaItems = Util_Orden_Trabajo.queryOT(null, caso.Id, null);
		Set<Id> idsOTs = new Set<Id>();
		Set<String> setGremioWO = new Set<String>();
		for(WorkOrder wo : listaItems){
			if(!setGremioWO.contains(wo.OTR_SEL_Gremio__c)){
				setGremioWO.add(wo.OTR_SEL_Gremio__c);
			}
		}

		for(WorkOrder wo : listaItems){
			idsOTs.add(wo.Id);
			mapaNuevoComentsOT.put(wo.Id, new ComentarioFormateado(new Comentario_Orden_de_Trabajo__c()));
			mapaComentsOT.put(wo.Id, new List<ComentarioFormateado>());
		}

		//Refrescar listado de Comentarios de cada Orden de Trabajo
		List<Comentario_Orden_de_Trabajo__c> listaCom = Util_Orden_Trabajo.getComentariosOT(idsOTs);
		/*List<Comentario_Orden_de_Trabajo__c> listaCom = new List<Comentario_Orden_de_Trabajo__c>(
			[SELECT
				COT_LKP_Orden_de_trabajo__c,
				COT_TXT_Comentario__c,
				CreatedDate,
				CreatedBy.Name
			 FROM Comentario_Orden_de_Trabajo__c
			 WHERE COT_LKP_Orden_de_trabajo__c IN :idsOTs
			 ORDER BY COT_LKP_Orden_de_trabajo__c]);*/
		Id woIdAux = null;
		List<ComentarioFormateado> listaComAux = null;
		for(Comentario_Orden_de_Trabajo__c com : listaCom){
			if(com.COT_LKP_Orden_de_trabajo__c != woIdAux){
				if(woIdAux != null){
					mapaComentsOT.put(woIdAux, listaComAux);
				}
				woIdAux = com.COT_LKP_Orden_de_trabajo__c;
				listaComAux = new List<ComentarioFormateado>();
			}
			listaComAux.add(new ComentarioFormateado(com));
		}
		if(woIdAux != null && listaComAux != null){
			mapaComentsOT.put(woIdAux, listaComAux);
		}
	}//FIN actualizarListaOTs()


	/**
	 * Navega a la página de actualización de partidas.
     * 
     * @return navegación a la página con CPQ embebido
     */
	public PageReference actualizarPartidas(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso) && idOrdenTrabajo != null){
			List<BigMachines__Quote__c> quote = Util_B2B.queryMapBigMachinesQuote(new Set<Id>{idOrdenTrabajo}).values();
			//List<BigMachines__Quote__c> quote = Util_B2B.queryBigMachinesQuote(idOrdenTrabajo);
			/*List<BigMachines__Quote__c> quote = new List<BigMachines__Quote__c>(
					[SELECT BigMachines__Transaction_Id__c , OQU_LKP_Work_Order__c, BigMachines__Is_Primary__c  
					 FROM BigMachines__Quote__c 
					 WHERE OQU_LKP_Work_Order__c = :idOrdenTrabajo]);*/
			if(quote.isEmpty()){
				paginaRedireccion = new PageReference('/apex/' + Label.VF_QUOTE_CREATE);
			}
			else {
				paginaRedireccion = new PageReference('/apex/' + Label.VF_QUOTE_EDIT);
			}
			paginaRedireccion.getParameters().put('idWorkO', idOrdenTrabajo);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_SINI_REPARABLE_TRAMI);
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN actualizarPartidas()


	/**
	 * Navega a la página de simulación para actualizar partidas.
     * 
     * @return navegación a la página de simulación de CPQ
     */
	public PageReference actualizarPartidas_CPQSimulado(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso) && idOrdenTrabajo != null){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_SIMULACION_CPQ);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_SINI_REPARABLE_TRAMI);
			paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN actualizarPartidas_CPQSimulado()


	/**
	 * Agrega a la página de navegación destino los parámetros requeridos.
     * @param paginaRedireccion: página de navegación recibida
     * @param idCaso: Id del Caso actual a agregar
     * @param retorno: parámetro URL de retorno a agregar
     * 
     * @return página de navegación recibida con los parámetros requeridos
     */
	private PageReference agregarParametrosURL(PageReference paginaRedireccion, Id idCaso, String retorno){
		paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
		paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
		if(idCaso != null){
			paginaRedireccion.getParameters().put('id', idCaso);
		}
		if(retorno != null){
			paginaRedireccion.getParameters().put('retorno', retorno);
		}
		return paginaRedireccion;
	}//FIN agregarParametrosURL()


	/**
	 * Navega a la página de cambio de estado para anular la Orden de Trabajo.
     * 
     * @return navegación a la página de cambio de estado
     */
	public PageReference anularOrdenDeTrabajo(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso) && idOrdenTrabajo != null){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_CAMBIO_ESTADO_OT);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_SINI_REPARABLE_TRAMI);
			paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
			paginaRedireccion.getParameters().put('anular', 'Y');
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN anularOrdenDeTrabajo()
	

	/**
	 * Anula la primera cita y navega a la página de reserva de cita.
     * 
     * @return navegación a la página de reserva de cita
     */
	public PageReference cambiarCita(){
		PageReference paginaRedireccion = null;
		WorkOrder otSeleccionada = listaItems.get(indiceListaItems-1);
		if(warningHabilidades){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_HABILIDADES_REQUERIDAS));
			warningHabilidades = false;
		}
		else if(Util_Caso.guardarCaso(caso) && otSeleccionada != null){
			// Mostrar errores que se muestran en la reserva de cita
			Boolean continuarUrgencias = (otSeleccionada.OTR_CAS_Urgente__c && ((!otSeleccionada.OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c)));
			if(Test.isRunningTest()) continuarUrgencias = true;
			if(superaLimiteActuacion && (!continuarUrgencias)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.WARNING_PRESUPUESTO_CIA));
			}
			else {
				ServiceAppointment cita = Util_Cita_Servicio.getMapCitasById(new Set<Id>{otSeleccionada.OTR_LKP_Primera_Cita__c}).get(otSeleccionada.OTR_LKP_Primera_Cita__c);
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
						listaItems.add(indiceListaItems-1, Util_Orden_Trabajo.queryMapOTById(new Set<Id>{otSeleccionada.Id}).values().get(0));
						//listaItems.add(indiceListaItems-1, Util_Orden_Trabajo.queryOT(otSeleccionada.Id, null, null).get(0));
						// Acceder al asistente para reservar cita parala nueva primera cita
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
			}
		}
		return paginaRedireccion;
	}//FIN cambiarCita()


	/**
	 * Navega a la página de cambio de estado para la Orden de Trabajo.
     * 
     * @return navegación a la página de cambio de estado
     */
	public PageReference cambiarEstadoOrdenDeTrabajo(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso) && idOrdenTrabajo != null){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_CAMBIO_ESTADO_OT);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_SINI_REPARABLE_TRAMI);
			paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN cambiarOT()


	/**
	 * Navega a la página de cambio de estado para cerrar la Orden de Trabajo.
     * 
     * @return navegación a la página de cambio de estado
     */
	public PageReference cerrarOrdenDeTrabajo(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso) && idOrdenTrabajo != null){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_CAMBIO_ESTADO_OT);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_SINI_REPARABLE_TRAMI);
			paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
			paginaRedireccion.getParameters().put('cerrar', 'Y');
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN cerrarOrdenDeTrabajo()


	/**
	 * Navega a la página de cambio de estado para dormir la Orden de Trabajo.
     * 
     * @return navegación a la página de cambio de estado
     */
	public PageReference dormirOrdenDeTrabajo(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso) && idOrdenTrabajo != null){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_CAMBIO_ESTADO_OT);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_SINI_REPARABLE_TRAMI);
			paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
			paginaRedireccion.getParameters().put('dormir', 'Y');
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN dormirOrdenDeTrabajo()

	/**
	 * Navega a la página de habilidades requeridas.
     * 
     * @return navegación a la página de habilidades requeridas
     */
	public PageReference habilidadesRequeridas(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso) && idOrdenTrabajo != null){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_HABILIDADES_REQUERIDAS_OT);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_SINI_REPARABLE_TRAMI);
			paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN habilidadesRequeridas()


	/**
	 * Establece como principal en el caso la orden de trabajo sobre la que se ejecuta el método.
     */
	public void hacerOrdenTrabajoPrincipal(){
		WorkOrder otSeleccionada = listaItems.get(indiceListaItems-1);
		if(Util_Caso.guardarCaso(caso) && otSeleccionada != null){
			system.Savepoint puntoGuardado = Database.setSavepoint();
			try {
				caso.CAS_LKP_Orden_Trabajo_Principal__c = otSeleccionada.Id;
				caso.CAS_SEL_Gremio_Principal__c = otSeleccionada.OTR_SEL_Gremio__c;
				caso.CAS_LKP_Tipo_Trabajo__c = otSeleccionada.WorkTypeId;
				Baipas.establecerVariableControl();
				update caso;
				Baipas.deshabilitarVariableControl();
				actualizarListaOTs();
				existeGremioPrincipal = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
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
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
				system.debug(e.getStackTraceString());
			}
		}
	}//FIN hacerOrdenTrabajoPrincipal()


	public PageReference insertarComentarioPerito() {
		nuevoComentCaso = comentarioFormateadoPerito;
		System.debug('@@@@@@@@comentarioFormateadoPerito ' + nuevoComentCaso);
		return insertarComentarioCaso();
	}
	
	/**
	 * Inserta un comentario nuevo vinculado al caso.
     * 
     * @return navegación de recarga de la página actual
     */
	public PageReference insertarComentarioCaso(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso) && nuevoComentCaso.comentarioCaso.CMC_TXT_Comentario__c != null && nuevoComentCaso.comentarioCaso.CMC_TXT_Comentario__c != ''){
			Comentario_caso__c comentarioCasoInsertar = Util_Caso.crearComentarioCaso(caso.Id, nuevoComentCaso.comentarioCaso.CMC_TXT_Comentario__c);
			if(comentarioCasoInsertar != null){
				system.Savepoint puntoGuardado = Database.setSavepoint();
				try {
					insert comentarioCasoInsertar;
					paginaRedireccion = new PageReference('/apex/' + Label.VF_SINI_REPARABLE_TRAMI);
					paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, null);
					paginaRedireccion.getParameters().put('guardadoOK', 'Y');
					paginaRedireccion.setRedirect(true);
				}
				catch(DmlException e){
					Database.rollback(puntoGuardado);
					system.debug('***** EXCEPTION e :' + e.getStackTraceString());
					if(!e.getMessage().contains('[CMC_TXT_Comentario__c]')){
		            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
		         	}
		 		}
				catch(Exception e){
					Database.rollback(puntoGuardado);
					system.debug(e.getStackTraceString());
					if(!e.getMessage().contains('[CMC_TXT_Comentario__c]')){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
					}
				}
			}
		}
		else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_COMENTARIO_VACIO));		
		}
		return paginaRedireccion;
	}//FIN insertarComentarioCaso()


	/**
	 * Inserta un comentario nuevo vinculado a una orden de trabajo.
     * 
     * @return navegación de recarga de la página actual
     */
	public void insertarComentarioOT(){
		if(Util_Caso.guardarCaso(caso) && idOrdenTrabajo != null){
			String comentarioOT = (mapaNuevoComentsOT.get(idOrdenTrabajo)).comentarioOT.COT_TXT_Comentario__c;
			if(comentarioOT != null && comentarioOT != ''){
				Comentario_Orden_de_Trabajo__c comentarioOTInsertar = Util_Orden_Trabajo.crearComentarioOrdenTrabajo(idOrdenTrabajo, comentarioOT);
				if(comentarioOTInsertar != null){
					
					Workorder laOt = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{idOrdenTrabajo}).values().get(0);

					system.Savepoint puntoGuardado = Database.setSavepoint();
					try {
						insert comentarioOTInsertar;
						actualizarListaOTs();
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
					}
					catch(DmlException e){
						Database.rollback(puntoGuardado);
						system.debug('***** EXCEPTION e :' + e.getStackTraceString());
						if(!e.getMessage().contains('[CMC_TXT_Comentario__c]')){
			            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + e.getMessage()));
			         	}
			 		}
					catch(Exception e){
						Database.rollback(puntoGuardado);
						system.debug(e.getStackTraceString());
						if(!e.getMessage().contains('[COT_TXT_Comentario__c]')){
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
						}
					}
				}
			}
			else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_COMENTARIO_VACIO));		
			}
		}
	}//FIN insertarComentarioOT()


	/**
	 * Navega a la página de selección de gremios para agregar uno nuevo.
     * 
     * @return navegación a la página de selección de gremios
     */
	public PageReference nuevoGremio(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso)){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_SINI_GREMIOS);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_SINI_REPARABLE_TRAMI);
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN nuevoGremio()


	/**
	 * Navega a la página de presupuestos para generar uno nuevo.
     * 
     * @return navegación a la página de presupuestos
     */
	public PageReference verPresupuesto(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso)){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_PRESUPUESTO);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_SINI_REPARABLE_TRAMI);
			paginaRedireccion.getParameters().put('perito', 'Y');
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}
	/**
	 * Navega a la página de reserva de cita.
     * 
     * @return navegación a la página de reserva de cita
     */
	public PageReference reservarCita(){
		PageReference paginaRedireccion = null;
		WorkOrder otSeleccionada = listaItems.get(indiceListaItems-1);
		if(warningHabilidades){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.WARNING_HABILIDADES_REQUERIDAS));
			warningHabilidades = false;
		}
		else if(Util_Caso.guardarCaso(caso) && otSeleccionada != null){
			Boolean continuarUrgencias = (otSeleccionada.OTR_CAS_Urgente__c && ((!otSeleccionada.OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c)));
			if(Test.isRunningTest()) continuarUrgencias = true;
			if(superaLimiteActuacion && (!continuarUrgencias)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.WARNING_PRESUPUESTO_CIA));
			}
			else {
				String errorReservaCita = Util_Orden_Trabajo.permiteReservaPrimeraCita(otSeleccionada);
				system.debug('<<<< errorReservaCita' + errorReservaCita);
				if(errorReservaCita != null){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorReservaCita));					
				}
				else {
					if(otSeleccionada.OTR_CAS_Urgente__c){
						system.Savepoint puntoGuardado = Database.setSavepoint();
						try {
							system.debug('>>>>>>>>>>>>>>>>>>>>>>> Reserva Urgente');
							ReservarCitaUrgente.reservaCita(otSeleccionada.Id);

							actualizarListaOTs();
							
							otSeleccionada = listaItems.get(indiceListaItems-1);

							if(otSeleccionada.OTR_LKP_Primera_Cita__c != null){
								fechaCitaUrgenteReservada = 'La cita se ha reservado correctamente para el día ' + String.valueOf(otSeleccionada.OTR_DAT_Fecha_Primera_Cita__c) + ' en la franja de ' + otSeleccionada.OTR_TXT_Rango_Primera_Cita__c;
								ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, fechaCitaUrgenteReservada));
							}
							else {
								ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_RESERVACITAURG));
							}
						}
						catch(DMLException e){
							Database.rollback(puntoGuardado);
							system.debug(e.getStackTraceString());
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
						}
					}
					else {
						paginaRedireccion = new PageReference('/apex/' + Label.VF_RESERVARCITA);
						paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_SINI_REPARABLE_TRAMI);
						paginaRedireccion.getParameters().put('idOrdenTrabajo', otSeleccionada.Id);
						paginaRedireccion.setRedirect(true);
					}
				}
			}
		}
		return paginaRedireccion;
	}//FIN reservarCita()


	/**
	 * Navega a la página correspondiente al abandonar la pantalla actual.
     * 
     * @return navegación correspondiente al abandonar la pantalla actual
     */
	public PageReference salir(){
		//ICA 22/06/2018
		if(!peritoAsignado && caso.CAS_CAS_Requiere_Perito__c){
			asignarPerito();
		}
		PageReference paginaRedireccion = new PageReference('/' + caso.Id);
		paginaRedireccion.setRedirect(true);			
		return paginaRedireccion;
	}//FIN salir()


	/**
	 * Clase encargada de mostrar con el formato correcto los comentarios del Caso y de la Orden de Trabajo.
     */
	public class ComentarioFormateado {
		public Comentario_caso__c comentarioCaso {get; set;}
		public Comentario_Orden_de_Trabajo__c comentarioOT {get; set;}
		public String cuerpoFormateado {get; set;}
		public String tipo;
		public comentarioFormateado(Comentario_caso__c comentarioCaso){
			this.comentarioCaso = comentarioCaso;
			this.cuerpoFormateado = formatearComentario(comentarioCaso.CMC_TXT_Comentario__c);
		}
		public comentarioFormateado(Comentario_Orden_de_Trabajo__c comentarioOT){
			this.comentarioOT = comentarioOT;
			this.cuerpoFormateado = formatearComentario(comentarioOT.COT_TXT_Comentario__c);
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
	
	public PageReference vincularContactos() {
		//ICA 22/02/2018 tareaPeritos
		if(!peritoAsignado && caso.CAS_CAS_Requiere_Perito__c){
			asignarPerito();
		}
		//FIN ICA
		PageReference paginaRedireccion = new PageReference('/apex/' + Label.VF_SINI_CONTACTOS);
		paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/'+Label.VF_SINI_REPARABLE_TRAMI); 
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}
	
	public void generarPresupuesto() {
		if(Util_Caso.guardarCaso(caso)){
			correoRemitente = Util_Correo_Electronico.getBuzonCIA(codigoCIA, Label.CON_TIPO_PROGRAMA_AUTORIZA_PRESUPUESTO);
			if(correoRemitente == null){
				errorMessage = Label.ERROR_BUZON_TIPOPROGRAMA;
			}
			else if(caso.CAS_LKP_Perito__c == null || caso.CAS_LKP_Perito__r.PER_EMA_Email__c == null) {
				errorMessage = 'No hay dirección de correo electrónico del Perito.';
			}
			else {
				system.Savepoint puntoGuardado = Database.setSavepoint();
				try {
					List<WorkOrderLineItem> listaPartidas = Util_Partida.getWorkOrderLineItemByCaseAndStatus(new Set<Id>{caso.Id}, new Set<String>{Label.PAR_ESTADO_PDTE_PERITO}).values();
					Presupuesto__c presupuestoPerito = Util_Presupuesto.insertarPresupuesto(caso, listaPartidas, Label.PRESUPUESTO_ENVIADOPERITO, null);
				}
				catch(DmlException e){
					Database.rollback(puntoGuardado);
					system.debug('***** EXCEPTION e :' + e.getStackTraceString());
	//	        	if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
		            	errorMessage = Label.ERROR_GUARDAR + e.getMessage();
	//	         	}
		 		}
				catch(Exception e){
					Database.rollback(puntoGuardado);
					system.debug(e.getStackTraceString());
	            	errorMessage = Label.ERROR_GUARDAR + e.getMessage();
				}
			}
		}
	
	}
	
	public void enviarPresupuesto(){
		if(errorMessage != null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));			
		}
		else {
			system.Savepoint puntoGuardado = Database.setSavepoint();
			try {
				Presupuesto__c presupuestoPER = Util_Presupuesto.getPresupuestosActuales(new Set<Id>{caso.Id}).get(caso.Id);
				if(presupuestoPER != null){
					Contact contactoPerito = Util_Correo_Electronico.generarDummyContact(caso.CAS_LKP_Perito__r.Name, caso.CAS_LKP_Perito__r.Name, caso.CAS_LKP_Perito__r.PER_EMA_Email__c, caso.CAS_LKP_Perito__r.PER_TLF_Telefono__c, null);
					ContentVersion cv = Util_Documentacion.crearPDFDesdeVF(caso.Id, presupuestoPER.Id, Label.PDF_TIPO_PRESUPUESTO, codigoCIA, Label.IDIOMA_POR_DEFECTO,
																		   caso.CaseNumber + 'v' + presupuestoPER.PRE_NUM_Version__c, '' + DateTime.now().getTime(),Label.TIPO_CONTACTO_DEST_PERITO);
					Util_Correo_Electronico.enviarSingleEmailMessage(JSON.serialize(caso), null, null, contactoPerito, correoRemitente, cv, Label.PLANTILLA_EMAIL_PERITO_V, null);
				}
			}
			catch(Exception e){
				Database.rollback(puntoGuardado);
				system.debug(e.getStackTraceString());
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			}
		}
	}
	
	public void asignarPerito(){
		if(propietario){
			caso.CAS_CAS_Requiere_Perito__c = true;
			caso.CAS_TXT_Comentario_Perito__c = comentarioFormateadoPerito.comentarioCaso.CMC_TXT_Comentario__c;
			caso = Util_Perito.procesoAsignacion(caso);
			if(caso.CAS_LKP_Perito__c != null){
				peritoAsignado = true;
				update caso;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Se ha realizado con éxito la asignación del perito'));
			}
			else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ha fallado el proceso de asignación de perito'));
				caso.CAS_CAS_Requiere_Perito__c = false;
			}
		}
		else {
			if(esProfesional && [SELECT Id FROM Task WHERE RecordTypeId =: Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_TAR_PRESOLICITUD_PERITO) AND WhatId =: caso.Id].isEmpty()){
				caso.CAS_CAS_Presolicitud_Perito__c = true;
				update caso;
				insert Util_tarea.crearTarea(Label.RT_TAR_PRESOLICITUD_PERITO,Label.TAR_ASUNTO_SOLICITAR_PERITO, Label.TAR_ESTADO_EN_CURSO, null,caso.OwnerId,caso.Id,caso.CAS_LKP_Compania__c);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Se ha solicitado la asignación del perito al propietario del caso'));
			}
			else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'El propietario del caso ya ha rechazado anteriormente la solicitud de perito'));
				caso.CAS_CAS_Presolicitud_Perito__c = true;
			}
		}
	}
}