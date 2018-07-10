/**
 * Clase controladora de la Visualforce "B2B_Reparable" encargada de gestionar los gremios de un Servicio B2B/B2B2C.
 * 
 * @author EVERIS
 */
public without sharing class B2B_Reparable {
	private String solicitudExistente;
	public String fase {get; set;}
	public Case caso {get; set;}
	public Boolean esB2C {get; set;}
	public List<ComentarioFormateado> listaComentsCaso {get; set;}
	public ComentarioFormateado nuevoComentCaso {get; set;}
	public List<WorkOrder> listaItems {get; set;}
	public WorkOrder nuevoItem {get; set;}
	public Presupuesto__c presupuesto {get; set;}
	public Integer indiceListaItems {get; set;}
	public Id idOrdenTrabajo {get; set;}
	public Map<Id, List<ComentarioFormateado>> mapaComentsOT {get; set;}
	public Map<Id, Boolean> mapaPacksDisp {get; set;}
	public Map<Id, ComentarioFormateado> mapaNuevoComentsOT {get; set;}
	public String tipoServicio {get; set;}
	public Boolean otUrgente {get; set;}
	public Account cuenta {get; set;}
	public Boolean superaLimiteActuacion {get; set;}
	public Boolean generarPresupuesto {get; set;}
	public Boolean esProfesional {get; set;}
	public Boolean esProfesionalSec {get; set;}
	public Boolean esReclamacion {get; set;}
	public String fechaCitaUrgenteReservada {get; set;}
	public Boolean existeGremioPrincipal {get; set;}
	private String codigoCIA;
	public Boolean B2BNuevoPresupuesto{get;set;}
	private Boolean warningHabilidades;
	public Boolean ciaEndesa {get;set;}
	public Boolean ciaWorten {get;set;}
	public Boolean ciaBricoDepot {get;set;}
	public List<Contact> contactosPresupuestoCIA {get;set;}
	public String correoRemitente {get;set;}
	private String errorMessage;

	/**
	 * Constructor de la Clase.
     */
	public B2B_Reparable(ApexPages.standardController stdCtr){
		Id recordTypeIdReclamacion = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
		superaLimiteActuacion = false;
		warningHabilidades = true;
		contactosPresupuestoCIA = null;
		errorMessage = '';
		if (!Test.isRunningTest()) esProfesional = Util_Perfiles_Usuario.esProfesional(UserInfo.getProfileId());
		else esProfesional = true;
		esProfesionalSec = (esProfesional && (!Util_Perfiles_Usuario.esRecursoPrincipal(UserInfo.getUserId())));

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
			mapaPacksDisp = new Map<Id, Boolean>();
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
					// Obtener la lista de contactos de la CIA para el tipo de programa 'Presupuesto'
					contactosPresupuestoCIA = Util_Correo_Electronico.getListaContactos(null, codigoCIA, Label.CON_TIPO_PROGRAMA_AUTORIZA_PRESUPUESTO);
					if(contactosPresupuestoCIA != null && contactosPresupuestoCIA.isEmpty()){
						contactosPresupuestoCIA = null;
					}
				}
				cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{caso.AccountId}).get(caso.AccountId);

				esB2C = caso.CAS_FOR_EsB2C__c;

				List<Comentario_caso__c> listaComentsCasoAux = Util_Caso.getMapComentariosCaso(new Set<Id>{caso.Id}).get(caso.Id);
				for(Comentario_caso__c com : listaComentsCasoAux){
					listaComentsCaso.add(new ComentarioFormateado(com));
				}

				// Se carga la lista de Ordenes de Trabajo del Caso
				actualizarListaOTs();
				system.debug('<<<< listaItemls'+ listaItems);
				// Después de cargar las OTs y el caso buscamos si hay algún gremio que sea principal
				existeGremioPrincipal = (caso.RecordTypeId == recordTypeIdReclamacion || caso.CAS_LKP_Orden_Trabajo_Principal__c != null);
				
				esReclamacion = (caso.RecordTypeId == recordTypeIdReclamacion);
				
				if(paginaActual.getParameters().containsKey('guardadoOK')){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_GUARDADO));
				}
				//Se recoge el tipo de servicio
				tipoServicio = Util_mapasTiposDeRegistro.RTNAMEBYID.get(caso.RecordTypeId);

				superaLimiteActuacion = ((!esB2C) && caso.Type == Label.B2B_TIPO_CORRECTIVO && caso.CAS_CAS_Supera_Limite_Actuacion__c);

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

				generarPresupuesto = (esB2C && caso.CAS_CAS_Generar_Presupuesto__c);
				B2BNuevoPresupuesto = (!esB2C && caso.CAS_FOR_Importe_Total__c > 0);
			}
			if(paginaActual.getParameters().containsKey('presuAceptado')){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.INFO_PRESU_ACEPTADO));	 
			}
		}
		ciaEndesa = (codigoCIA == Label.IDE_ENDESA);
		ciaWorten = (codigoCIA == Label.IDE_WORTEN);
		ciaBricoDepot = (codigoCIA == Label.IDE_BRICO_DEPOT);
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
			if(wo.OTR_LKP_Linea_Contrato__c == null){
				// Si no existe un pack vinculado: obtener si hay packs disponibles con saldo de servicios > 0
				mapaPacksDisp.put(wo.Id, !Util_Direcciones_B2B_B2B2C_Lineas.getLCsCorrectDisponiblesPorSaldoAndPorUrgente(new Set<Id>{caso.AccountId},true,new Set<String>{Label.RT_LIN_CON_CORRECTIVO},new Set<String>{wo.OTR_SEL_Gremio__c},0,true).isEmpty());
				//mapaPacksDisp.put(wo.Id, !Util_B2B.getLCsCorrectDisponibles(wo, caso.AccountId, false, true, true).isEmpty());
			}
			else {
				// Si ya existe un pack vinculado
				mapaPacksDisp.put(wo.Id,false);
			}
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
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_B2B_REPARABLE);
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
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_B2B_REPARABLE);
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
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_B2B_REPARABLE);
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
			Boolean continuarUrgencias = (otSeleccionada.OTR_CAS_Urgente__c && (esB2C || (!otSeleccionada.OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c)));
			if(Test.isRunningTest()) continuarUrgencias = true;
			if(superaLimiteActuacion && (!continuarUrgencias)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.WARNING_PRESUPUESTO_CIA));
			}
			else if(generarPresupuesto && (!continuarUrgencias)){
				// Si no es una urgencia solo se permite reservar cita si no es necesario generar o aprobar un presupuesto
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_PARTIDAS_SIN_PRESUP));
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
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_B2B_REPARABLE);
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
			if(generarPresupuesto){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_PARTIDAS_SIN_PRESUP));
			}
			else {
				paginaRedireccion = new PageReference('/apex/' + Label.VF_CAMBIO_ESTADO_OT);
				paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_B2B_REPARABLE);
				paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
				paginaRedireccion.getParameters().put('cerrar', 'Y');
				paginaRedireccion.setRedirect(true);
			}
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
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_B2B_REPARABLE);
			paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
			paginaRedireccion.getParameters().put('dormir', 'Y');
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN dormirOrdenDeTrabajo()


	/**
	 * Finaliza la apertura del caso y navega al detalle del mismo.
     * 
     * @return navegación a la página de detalle del caso
     */
	public PageReference finalizarApertura(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso)){
			List<WorkOrder> listaOTsSinReserva = Util_Orden_Trabajo.getWorkOrderByCaseAndRecordTypeAndStatus(new Set<Id>{caso.Id},new Set<Id>{Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)},new Set<String>{Label.OTR_ESTADO_ANULADO,Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO},new Set<String>{Label.OTR_ESTADO_INACTIVO_CLIENTE}).values();
			//String filtro = 'RecordTypeId = \''+Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)+'\' AND ((Status != \''+Label.OTR_ESTADO_ANULADO+'\' AND Status != \''+Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO+'\' AND OTR_DAT_Fecha_Primera_Cita__c != null) OR Status = \''+Label.OTR_ESTADO_INACTIVO_CLIENTE+'\')';
			//List<WorkOrder> listaOTsSinReserva = Util_Orden_Trabajo.queryOT(null,caso.Id,filtro);
			/*List<WorkOrder> listaOTsSinReserva = new List<WorkOrder>(
					[SELECT Id
					 FROM WorkOrder
					 WHERE CaseId = :caso.Id
					 AND RecordTypeId = :Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA) 
					 AND ((Status != :Label.OTR_ESTADO_ANULADO
					 AND Status != :Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO
					 AND OTR_DAT_Fecha_Primera_Cita__c != null)
					 OR Status = :Label.OTR_ESTADO_INACTIVO_CLIENTE)]);*/
			if(generarPresupuesto){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_PARTIDAS_SIN_PRESUP));
			}
			else if((!esB2C) && ciaWorten && caso.CAS_LKP_Baremo__c == null){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_BAREMO_PARTIDAS));
			}
			else if(listaOTsSinReserva.isEmpty()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_FINALIZAR_APERTURA_B2B_FALTA));
			}
			else {
				System.Savepoint puntoGuardado = Database.setSavepoint();
				try {
					Id idRT = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C);
					if(esB2C){
						idRT = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C);
					}

					// Para la CIA WORTEN se genera el PDF de Comprobante y se envía a los contactos del punto de venta
					if((!esB2C) && ciaWorten && caso.CAS_LKP_Punto_de_Venta__c != null){
						String correoRemitente = Util_Correo_Electronico.getBuzonCIA(Label.IDE_HOMESERVE, Label.CON_TIPO_PROGRAMA_NO_REPLY);
						ContentVersion cv = Util_Documentacion.crearPDFDesdeVF(caso.Id, null, Label.PDF_TIPO_COMPROBANTE,
																				codigoCIA, Label.IDIOMA_POR_DEFECTO, caso.CaseNumber, null, null);
						List<Contact> listaContactosPtoVenta = Util_Correo_Electronico.getListaContactos(caso.CAS_LKP_Punto_de_venta__c, null, null);
						system.debug('finalizarApertura.correoRemitente: ' + correoRemitente);
						system.debug('finalizarApertura.listaContactosPtoVenta: ' + listaContactosPtoVenta);
						if(!listaContactosPtoVenta.isEmpty() && correoRemitente != null){
							Util_Correo_Electronico.envioMasivoTemplate(caso.Id, caso.CAS_LKP_Compania__c, Label.CON_TIPO_PROGRAMA_COMPROBANTE_SERVICIO, null, listaContactosPtoVenta, correoRemitente, cv, null, null);
						}
					}
					
					caso.CAS_DAT_Fecha_Apertura__c = datetime.now();
					caso.Status = Label.CAS_ESTADO_EN_CURSO;
					caso.recordTypeId = idRT;
					update caso; 

					paginaRedireccion = new PageReference('/' + caso.Id);
					paginaRedireccion.setRedirect(true);
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
		return paginaRedireccion;
	}//FIN finalizarApertura()


	/**
	 * Navega a la página de habilidades requeridas.
     * 
     * @return navegación a la página de habilidades requeridas
     */
	public PageReference habilidadesRequeridas(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso) && idOrdenTrabajo != null){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_HABILIDADES_REQUERIDAS_OT);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_B2B_REPARABLE);
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
					paginaRedireccion = new PageReference('/apex/' + Label.VF_B2B_REPARABLE);
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
						
						if(esProfesional && esReclamacion){
							Task tarea = Util_tarea.crearTarea(Label.RT_TAR_COMUN, 'Comentario del profesional a la reclamación', Label.TAR_ESTADO_EN_CURSO, null, laOt.OwnerId, laOt.Id, laOt.AccountId);
							tarea.Priority = '4';
							insert tarea;
						}
						
						
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
			paginaRedireccion = new PageReference('/apex/' + Label.VF_B2B_GREMIOS);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_B2B_REPARABLE);
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN nuevoGremio()


	/**
	 * Navega a la página de presupuestos para generar uno nuevo.
     * 
     * @return navegación a la página de presupuestos
     */
	public PageReference nuevoPresupuesto(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso)){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_PRESUPUESTO);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_B2B_REPARABLE);
			paginaRedireccion.getParameters().put('nuevoPresupuesto', 'Y');
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN nuevoPresupuesto()


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
			Boolean continuarUrgencias = (otSeleccionada.OTR_CAS_Urgente__c && (esB2C || (!otSeleccionada.OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c)));
			if(Test.isRunningTest()) continuarUrgencias = true;
			if(superaLimiteActuacion && (!continuarUrgencias)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.WARNING_PRESUPUESTO_CIA));
			}
			else if(generarPresupuesto && (!continuarUrgencias)){
				// Si no es una urgencia solo se permite reservar cita si no es necesario generar o aprobar un presupuesto
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_PARTIDAS_SIN_PRESUP));
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
						paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_B2B_REPARABLE);
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
		PageReference paginaRedireccion = null;
		// Si estamos abriendo un nuevo Servicio y no partimos de una solicitud previa
		if(fase == Label.SINI_FASE_APERTURA && solicitudExistente == 'N'){
			// Eliminamos el caso generado
			if(caso.Id != null){
				delete caso;
			}
			// Navegamos al detalle de la cuenta
			paginaRedireccion = new PageReference('/' + cuenta.Id);
			paginaRedireccion.setRedirect(true);
		}
		else {
			if(generarPresupuesto){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_PARTIDAS_SIN_PRESUP));
			}
			else {
				paginaRedireccion = new PageReference('/' + caso.Id);
				paginaRedireccion.setRedirect(true);			
			}
		}
		return paginaRedireccion;
	}//FIN salir()


	/**
	 * Si el gestor ejecuta esta acción, bloquea la Orden de Trabajo
     * y el caso, y envía el prespuesto a la CIA para que autorice.
     * 
     * @return navegación al detalle del caso
     */
	public void solicitarAutorizacionCIA(){
		errorMessage = '';
		if(contactosPresupuestoCIA != null){
			// Si existen contactos en la CIA a los que enviar el Presupuesto:
			// obtener el buzón remitente de la CIA para el tipo de programa 'Presupuesto'
			correoRemitente = Util_Correo_Electronico.getBuzonCIA(codigoCIA, Label.CON_TIPO_PROGRAMA_AUTORIZA_PRESUPUESTO);
			if(correoRemitente == null){
				errorMessage = Label.ERROR_BUZON_TIPOPROGRAMA;
			}
		}

		if(contactosPresupuestoCIA == null || correoRemitente != null){
			if(fase == Label.SINI_FASE_APERTURA){
				caso.CAS_DAT_Fecha_Apertura__c = datetime.now();
				caso.Status = Label.CAS_ESTADO_EN_CURSO;
				caso.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C);
			}

			if(Util_Caso.guardarCaso(caso)){
				system.Savepoint puntoGuardado = Database.setSavepoint();
				try {
					Presupuesto__c anterior = Util_Presupuesto.getPresupuestosActuales(new Set<Id>{caso.Id}).get(caso.Id);
					Presupuesto__c presupuestoCIA = Util_Presupuesto.insertarPresupuesto(caso, null, Label.PRESUPUESTO_PENDIENTE_CIA, anterior);
				}
				catch(DmlException e){
					Database.rollback(puntoGuardado);
					system.debug('***** EXCEPTION e :' + e.getStackTraceString());
		        	if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
		            	errorMessage = Label.ERROR_GUARDAR + e.getMessage();
		         	}
		 		}
				catch(Exception e){
					Database.rollback(puntoGuardado);
					system.debug(e.getStackTraceString());
	            	errorMessage = Label.ERROR_GUARDAR + e.getMessage();
				}
			}
		}
	}//FIN solicitarAutorizacionCIA()
	
	
	public PageReference generarPDFyEnviar(){
		PageReference paginaRedireccion = null;
		if(!String.isEmpty(errorMessage)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
		}
		else {
			Presupuesto__c presupuestoCIA = Util_Presupuesto.getPresupuestosActuales(new Set<Id>{caso.Id}).get(caso.Id);
			if(presupuestoCIA != null){
				Id idCIA = caso.CAS_LKP_Compania__c;
				ContentVersion cv = Util_Documentacion.crearPDFDesdeVF(caso.Id, presupuestoCIA.Id, Label.PDF_TIPO_PRESUPUESTO, codigoCIA, Label.IDIOMA_POR_DEFECTO,
																	   caso.CaseNumber + 'v' + presupuestoCIA.PRE_NUM_Version__c, '' + DateTime.now().getTime(),Label.TIPO_CONTACTO_DEST_COMPANIA);
				if(contactosPresupuestoCIA != null && correoRemitente != null){
					Util_Correo_Electronico.envioMasivoTemplate(caso.Id, idCIA, Label.CON_TIPO_PROGRAMA_AUTORIZA_PRESUPUESTO, Label.IDIOMA_POR_DEFECTO, contactosPresupuestoCIA, correoRemitente, cv, null, Label.TIPO_CONTACTO_DEST_COMPANIA);
				}
				paginaRedireccion = new PageReference('/' + caso.Id);
				paginaRedireccion.setRedirect(true);
			}
		}
		return paginaRedireccion;
	}//FIN generarPDFyEnviar()


	/**
	 * Navega a la página de presupuestos para ver el último presupuesto.
     * 
     * @return navegación a la página de presupuestos
     */
	public PageReference verUltimoPresupuesto(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso)){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_PRESUPUESTO);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_B2B_REPARABLE);
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN verUltimoPresupuesto()


	/**
	 * Navega a la página de búsqueda de clientes particulares para vincular un cliente.
     * 
     * @return navegación a la página de búsqueda de clientes particulares
     */
	public PageReference vincularCliente(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso)){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_B2B_BUSQ_CLIENTES);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, null);
			paginaRedireccion.getParameters().put('vincularCliB2BRep','Y');
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN vincularCliente()


	/**
	 * Navega a la página de vinculación de líneas de contrato.
     * 
     * @return navegación a la página de vinculación de líneas de contrato
     */
	public PageReference vincularLCaOT(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso) && idOrdenTrabajo != null){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_VINCULARLCOT);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, '/apex/' + Label.VF_B2B_REPARABLE);
			paginaRedireccion.getParameters().put('idOrdenTrabajo', idOrdenTrabajo);
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}//FIN vincularLCaOT()


	/**
	 * Clase encargada de mostrar con el formato correcto los comentarios del Caso y de la Orden de Trabajo.
     */
	public class ComentarioFormateado {
		public Comentario_caso__c comentarioCaso {get; set;}
		public Comentario_Orden_de_Trabajo__c comentarioOT {get; set;}
		public String cuerpoFormateado {get; set;}
		public comentarioFormateado(Comentario_caso__c comentarioCaso){
			this.comentarioCaso = comentarioCaso;
			this.cuerpoFormateado = formatearComentario(comentarioCaso.CMC_TXT_Comentario__c);
		}
		public comentarioFormateado(Comentario_Orden_de_Trabajo__c comentarioOT){
			this.comentarioOT = comentarioOT;
			this.cuerpoFormateado = formatearComentario(comentarioOT.COT_TXT_Comentario__c);
		}
		public String formatearComentario(String comentario){
			String comentarioRetorno;
			if(comentario != null){
				comentarioRetorno = comentario.replace('\r\n', '<br>');
			}
			return comentarioRetorno;
		}
	}


	/**
	 * Método provisional solo disponible para perfil Administrador para validar plantillas PDF.
     */
	public void generarPDFPresupuestoActual(){
		if(presupuesto != null){
			Util_Documentacion.crearPDFDesdeVF(caso.Id, presupuesto.Id, Label.PDF_TIPO_PRESUPUESTO, null, Label.IDIOMA_POR_DEFECTO,
					presupuesto.Name + 'v' + presupuesto.PRE_NUM_Version__c, '' + DateTime.now().getTime(),Label.TIPO_CONTACTO_DEST_COMPANIA);
		}
	}

	
	/**
	 * Guarda el caso y recarga la pantalla.
     *
     * @return navegación de recarga de la página actual	 
     */
	public PageReference guardarCambios(){
		PageReference paginaRedireccion = null;
		if(Util_Caso.guardarCaso(caso)){
			paginaRedireccion = new PageReference('/apex/' + Label.VF_B2B_REPARABLE);
			paginaRedireccion = agregarParametrosURL(paginaRedireccion, caso.Id, null);
			paginaRedireccion.getParameters().put('guardadoOK', 'Y');
			paginaRedireccion.setRedirect(true);
		}
		return paginaRedireccion;
	}
}