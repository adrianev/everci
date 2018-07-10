/**
 * Clase controladora de la Visualforce "CambioEstadoOT".
 * 
 * @author EVERIS
 */
public without sharing class CambioEstadoOT {
	public Boolean anular {get; set;}
	public Boolean anularReclamacion {get; set;}
	public Boolean cerrar {get; set;}
	public Boolean dormir {get; set;}
	public Boolean esProfesional {get; set;}
	public Case caso {get; set;}
	public Integer tipoCaso {get; set;}
	public Boolean esB2C {get; set;}
	private String solicitudExistente;
	private String fase;
	private String paginaRetorno;
	public String tipoActuacion {get; set;}
	public Account cuenta {get; set;}
	public WorkOrder ordenTrabajo {get; set;}
	public List<SelectOption> listaEstadosOT {get; set;}
	public String estadoNuevoOT {get; set;}
	public Comentario_Orden_de_Trabajo__c nuevoComentario {get; set;}
	private String perfilUsuario;
	public List<SelectOption> motivosAnulacion {get; set;}
	public String motivoAnulacion {get; set;}
	private Boolean todoAnulado;
	private Boolean todoAnuladoReclamacion;
	private Boolean todoCerrado;
	public Date fechaDespertar {get; set;}
	public Boolean reqFechaParaCuando {get; set;}
	public Boolean reqComentario {get; set;}
	private Boolean warningCierrAnul;
	private String idConfirmacion{get;set;}
	private String numeroGremiosArbolSalida{get;set;}

	/**
	 * Constructor de la clase.
	 * 
	 * @param stdCtr: Controlador estándar de la visual
	 * 
	 */
	public CambioEstadoOT(ApexPages.standardController stdCtr){
		perfilUsuario = Util_Perfiles_Usuario.PROFILEBYID.get(UserInfo.getProfileId()).Name;
		esProfesional = (perfilUsuario == Label.PERFIL_PROFESIONAL);
		nuevoComentario = new Comentario_Orden_de_Trabajo__c();
		todoAnulado = false;
		todoCerrado = false;
		warningCierrAnul = false;
		reqFechaParaCuando = false;
		reqComentario = false;
		PageReference paginaActual = ApexPages.currentPage();
		if(paginaActual.getParameters().containsKey('fase')){
			fase = paginaActual.getParameters().get('fase');
		}
		if(paginaActual.getParameters().containsKey('solicitudExistente')){
			solicitudExistente = paginaActual.getParameters().get('solicitudExistente');
		}
		if(paginaActual.getParameters().containsKey('retorno')){
			paginaRetorno = paginaActual.getParameters().get('retorno');
		}
		if(paginaActual.getParameters().containsKey('idConfirmacion')){
			idConfirmacion = paginaActual.getParameters().get('idConfirmacion');
		}
		if(paginaActual.getParameters().containsKey('numeroGremiosArbolSalida')){
			numeroGremiosArbolSalida = paginaActual.getParameters().get('numeroGremiosArbolSalida');
		}

		anular = paginaActual.getParameters().containsKey('anular');
		cerrar = paginaActual.getParameters().containsKey('cerrar');
		dormir = paginaActual.getParameters().containsKey('dormir');
		if(!paginaActual.getParameters().containsKey('id')){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
		}
		else {
			caso = (Case) stdCtr.getRecord();
			List<Case> listaCasosQuery = new List<Case>();
			if(Util_Siniestro.esSiniestro(caso)){
				tipoCaso = 1;
				listaCasosQuery = Util_Caso.getCaseById(new Set<Id>{caso.Id}).values();
				//listaCasosQuery = Util_Caso.queryMapSiniCaso(new Set<Id>{caso.Id},null,1).values();
				//listaCasosQuery = Util_Siniestro.queryCaso(caso.Id, null, 1);
			}
			else {
				tipoCaso = 2;
				listaCasosQuery = Util_Caso.getCaseById(new Set<Id>{caso.Id}).values();
				//listaCasosQuery = Util_Caso.getMapaCasos(new Set<Id>{caso.Id}).values();
				//listaCasosQuery = Util_B2B.queryCaso(caso.Id);
			}
			if(listaCasosQuery.isEmpty()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
			}
			else {
				caso = listaCasosQuery.get(0);
				esB2C = caso.CAS_FOR_EsB2C__c;
				system.debug('<<<<<<<<<<cambioEstadoOT: ' + caso.ParentId);
				tipoActuacion = Util_Siniestro.devolverTipoActuacion(caso.Type, caso.ParentId);
				cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{caso.AccountId}).get(caso.AccountId);

				ordenTrabajo = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{paginaActual.getParameters().get('idOrdenTrabajo')}).get(paginaActual.getParameters().get('idOrdenTrabajo'));
				if(ordenTrabajo == null){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
				}
				else {
					if(dormir){
						reqFechaParaCuando = true;
						reqComentario = true;
					}
					else if(anular){
						rellenarMotivosAnulacion();
						reqComentario = true;
					}
					else if(cerrar){
						reqComentario = (caso.CAS_FOR_RTDevName__c == Label.RT_CAS_RECLAMACION);
					}
					else if(ordenTrabajo.Status == Label.OTR_ESTADO_PDTE_PRESUP_CIA || ordenTrabajo.Status == Label.OTR_ESTADO_PDTE_PRESUP_CLIENTE){
						listaEstadosOT = new List<SelectOption>();
						listaEstadosOT.add(new SelectOption(ordenTrabajo.Status, Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'Status').get(ordenTrabajo.Status)));
						reqFechaParaCuando = true;
						reqComentario = true;
					}
					else if(ordenTrabajo.Status == Label.OTR_ESTADO_EN_ESPERA_GESTOR_INDICACIONES){
						String estadoSel = ordenTrabajo.OTR_TXT_Estado_Anterior__c;
						listaEstadosOT = new List<SelectOption>();
						listaEstadosOT.add(new SelectOption(ordenTrabajo.Status, Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'Status').get(ordenTrabajo.Status)));
						listaEstadosOT.add(new SelectOption(estadoSel, Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'Status').get(estadoSel)));
						reqComentario = true;
					}
					else if(ordenTrabajo.Status == Label.OTR_ESTADO_EN_ESPERA_PROF_DECL_RESP){
						String estadoSel = Label.OTR_ESTADO_PDTE_ATENCION_PROF;
						listaEstadosOT = new List<SelectOption>();
						listaEstadosOT.add(new SelectOption(ordenTrabajo.Status, Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'Status').get(ordenTrabajo.Status)));
						listaEstadosOT.add(new SelectOption(estadoSel, Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'Status').get(estadoSel)));
						reqComentario = true;
					}
					else if(ordenTrabajo.Status == Label.OTR_ESTADO_INACTIVO_CLIENTE){
						String estadoSel = Label.OTR_ESTADO_INACTIVO;
						listaEstadosOT = new List<SelectOption>();
						listaEstadosOT.add(new SelectOption(ordenTrabajo.Status, Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'Status').get(ordenTrabajo.Status)));
						listaEstadosOT.add(new SelectOption(estadoSel, Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'Status').get(estadoSel)));
						reqComentario = false;
					}
					else {
						String codigoCIA = null;
						// Para los B2C se utilizan los estados de HomeServe (codigoCIA es nulo)
						if(!esB2C){
							codigoCIA = ordenTrabajo.OTR_FOR_Identificador_CIA__c;
						}
						listaEstadosOT = Util_Orden_Trabajo.cargarListaEstadosSel(ordenTrabajo.Status, perfilUsuario, codigoCIA);
						reqFechaParaCuando = true;
						reqComentario = true;
					}
				}
			}
		}
	}//FIN constructor


	public void seleccionarNuevoEstado(){
		if(ordenTrabajo.Status == Label.OTR_ESTADO_INACTIVO_CLIENTE){
			reqFechaParaCuando = (estadoNuevoOT != Label.OTR_ESTADO_INACTIVO);
		}
	}


	/**
      * Inserta el comentario y establece en la Orden de Trabajo el estado seleccionado por el usuario.
      * 
      * @return navegación a la página de retorno en caso de éxito
      */
	public PageReference cambiarEstadoOT(){
		PageReference paginaRetorno = null;
		if(anular){
			List<WorkOrder> listaOTsCaso = Util_Caso.getListaOTsCaso(caso.Id);
			if(listaOTsCaso.size() > 1){
				// Si hay más OTs: comprobar si están todas cerradas para cerrar el caso al anular la OT actual
				todoCerrado = todoCerradoCaso(listaOTsCaso) && !Util_Orden_Trabajo.SET_ESTADOS_CERRADOS.contains(ordenTrabajo.Status); //Ahora se pueden anular desde cerrado, así que para que no cierre de nuevo
			}
			else {
				// Si no hay más OTs: se anula el caso al anular la OT actual 
				todoAnulado = true;
			}
		}

		if((reqComentario && nuevoComentario.COT_TXT_Comentario__c == '') ||
		   (anular && motivoAnulacion == null) || (!anular && !dormir && estadoNuevoOT == null) ||
		   (reqFechaParaCuando && ordenTrabajo.OTR_DAT_Fecha_Despertar__c == null)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_FALTAN_CAMPOS_OBLIGATORIOS));
		}
		else {
			system.Savepoint puntoGuardado = Database.setSavepoint();
			try {
				insertarComentario();
				if(dormir){
					ServiceAppointment cita = Util_Cita_Servicio.getMapCitasById(new Set<Id>{ordenTrabajo.OTR_LKP_Primera_Cita__c}).get(ordenTrabajo.OTR_LKP_Primera_Cita__c);
					if(cita != null){
						cita.Status = Label.CIT_ESTADO_ANULADA;
						update cita;
					}
					ordenTrabajo.Status = Label.OTR_ESTADO_INACTIVO_CLIENTE;
					update ordenTrabajo;
					paginaRetorno = volver();
				}
				else if(anular){
					if((todoAnulado || todoCerrado) && (!warningCierrAnul)){							
						warningCierrAnul = true;
						if(todoAnulado){
							if(caso.CAS_FOR_RTDevName__c == Label.RT_CAS_RECLAMACION){
								ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Está anulando el último servicio de la reclamación. ¿Desea anular también la reclamación?'));
								anularReclamacion = true;
							}else{
								ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.OTR_CONFIRM_ANULAR));
							}
						}else if(todoCerrado)
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.OTR_CONFIRM_CERRAR));	 
					}
					
					else {
						if(esProfesional){
							if(fase == Label.SINI_FASE_CONFIRMACION){
								ordenTrabajo.Status = Label.OTR_ESTADO_ANULADO;
							}
							else {
								ordenTrabajo.Status = Label.OTR_ESTADO_ANULADO_POR_PROF;
							}
							ordenTrabajo.OTR_SEL_Motivo_Anulacion__c = motivoAnulacion;
							update ordenTrabajo;
							// Generar Tarea al Gestor de Anulado por Profesional
							Task tarea = Util_tarea.crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_ANULADO_PROF, Label.TAR_ESTADO_EN_CURSO, Label.TAR_TIPO_ANULADO_PROF, caso.OwnerId, ordenTrabajo.Id, caso.AccountId);
							insert tarea;
							paginaRetorno = volver();
						}
						else {
							if(ordenTrabajo.Status == Label.OTR_ESTADO_INACTIVO){
								ordenTrabajo.Status = Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO;
							}
							else {
								ordenTrabajo.Status = Label.OTR_ESTADO_ANULADO;
							}
							ordenTrabajo.OTR_SEL_Motivo_Anulacion__c = motivoAnulacion;
							//ordenTrabajo.EndDate = Datetime.now();
							update ordenTrabajo;
							if(todoAnulado){
								if(caso.CAS_FOR_RTDevName__c == Label.RT_CAS_RECLAMACION){
									if(todoAnuladoReclamacion)
										cerrarAnularReclamacion(caso, Label.CAS_ESTADO_ANULADO, Label.CAS_MOTIVO_DE_ANULACION_RECLAMACION);
								}
								else {
									cerrarAnularCaso(caso, Label.CAS_ESTADO_ANULADO);
								}
							}
							else if(todoCerrado){
								cerrarAnularCaso(caso, Label.CAS_ESTADO_CERRADO);
							}
							paginaRetorno = volver();
						}
						
						//Tenemos que eliminar todas las wo en revision cuando se anule la wo
						Id RTIDRevision = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION);
						List<Workorder> woBorrar = Util_Orden_Trabajo.getWorkOrderByParentWorkorderAndRT(new Set<Id>{ordenTrabajo.Id},new Set<Id>{RTIDRevision}).values();
						//List<Workorder> woBorrar = [Select id from workorder where ParentWorkorderId = :ordenTrabajo.Id and RecordTypeId = :RTIDRevision];
						
						if(!woBorrar.isEmpty()){
							Baipas.establecerVariableControl();
							delete woBorrar;
							Baipas.deshabilitarVariableControl();
						}
					}
				}
				else {
					Date maxFecha = getFechaLimite();
					if(maxFecha != null && ordenTrabajo.OTR_DAT_Fecha_Despertar__c > maxFecha){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La fecha de desbloqueo no puede superar la fecha estimada para el estado elegido: ' + maxFecha));
					}
					else {
						ordenTrabajo.Status = estadoNuevoOT;
						update ordenTrabajo;
						paginaRetorno = volver();
					}
				}
			}
			catch(DmlException e){
				Database.rollback(puntoGuardado);
				system.debug(e.getStackTraceString());
			   	//if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
				   	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			   	//}
		 	}
			catch (Exception e){
				Database.rollback(puntoGuardado);
				system.debug(e.getStackTraceString());
				if(!e.getMessage().contains('[COT_TXT_Comentario__c]')){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
				}
			}
		}
		return paginaRetorno;
	}//FIN cambiarEstadoOT()
	
	public PageReference anularReclamacion(){
		todoAnuladoReclamacion = true;
		return cambiarEstadoOT();
	}
	
	public PageReference anularServicioReclamacion(){
		todoAnuladoReclamacion = false;
		return cambiarEstadoOT();
	}

	
	private Date getFechaLimite(){
		Date fechaLimite = null;
		Orden_de_trabajo__mdt metadato = Util_Metadatos.mapaOTEstadoCIA.get(estadoNuevoOT + '' + caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c);
		if(metadato == null){
			metadato = Util_Metadatos.mapaOTEstadoCIA.get(estadoNuevoOT + '' + Label.IDE_HOMESERVE);
		}
		if(metadato != null && metadato.MTD_OTR_NUM_Duracion_estimada__c != null){
			fechaLimite = system.today().addDays(Integer.valueOf(metadato.MTD_OTR_NUM_Duracion_estimada__c));
		}
		return fechaLimite;
	}//FIN getFechaLimite()
	
	
	/**
	 * Inserta un nuevo comentario en el Objeto Comentario_Orden_de_Trabajo__c
	 */
	private void insertarComentario(){
		if(nuevoComentario.COT_TXT_Comentario__c != null && nuevoComentario.COT_TXT_Comentario__c != ''){
			Comentario_Orden_de_Trabajo__c comentarioInsertar = Util_Orden_Trabajo.crearComentarioOrdenTrabajo(ordenTrabajo.Id, nuevoComentario.COT_TXT_Comentario__c);
			if(comentarioInsertar != null){
				insert comentarioInsertar;
			}
		}
	}//FIN insertarComentario()


	/**
      * Navega a la página de retorno.
      * 
      * @return navegación a la página de retorno
      */ 
	public PageReference volver(){
		PageReference paginaRedireccion = new PageReference('/' + caso.Id);
		Case casoActualizado = (Util_Caso.getCaseById(new Set<Id>{caso.Id}).values()).get(0);
		//Case casoActualizado = (Util_Caso.getMapaCasos(new Set<Id>{caso.Id}).values()).get(0);
		//Case casoActualizado = (Util_B2B.queryCaso(caso.Id)).get(0);
		if(casoActualizado.Status != Label.CAS_ESTADO_CERRADO && casoActualizado.Status != Label.CAS_ESTADO_ANULADO){
			paginaRedireccion = new PageReference(paginaRetorno);
			paginaRedireccion.getParameters().put('id', caso.Id);
			paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
			paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
			paginaRedireccion.getParameters().put('idConfirmacion', idConfirmacion);
			paginaRedireccion.getParameters().put('numeroGremiosArbolSalida', numeroGremiosArbolSalida);
		}
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}//FIN volver()


	public PageReference cerrarOrdenDeTrabajo(){
		PageReference paginaRetorno = null;
		// Si la OT a cerrar no pertenece a una Reclamación:
		if(caso.CAS_FOR_RTDevName__c != Label.RT_CAS_RECLAMACION){
			// Si hay más OTs: comprobar si están todas cerradas para cerrar el caso al cerrar la OT actual
			todoCerrado = todoCerradoCaso(Util_Caso.getListaOTsCaso(caso.Id));
		}
		system.Savepoint puntoGuardado = Database.setSavepoint();
		try {
			if(reqComentario && nuevoComentario.COT_TXT_Comentario__c == ''){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_FALTAN_CAMPOS_OBLIGATORIOS));
			}
			else {
				ContentVersion ultimoAlbaran = Util_Orden_Trabajo.getUltimoAlbaranOT(ordenTrabajo.Id);
				String errorCerrarOT = Util_Orden_Trabajo.permiteCerrarOrdenTrabajo(ordenTrabajo, esProfesional, ultimoAlbaran, todoCerrado);
				if(errorCerrarOT != null){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorCerrarOT));					
				}
				else {
					if((todoAnulado || todoCerrado) && (!warningCierrAnul)){
						warningCierrAnul = true;
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.OTR_CONFIRM_CERRAR));
					}
					else {
						insertarComentario();
						if(ultimoAlbaran == null){
							ordenTrabajo.Status = Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN;					
						}
						else {
							ordenTrabajo.Status = Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO;
						}
						//ordenTrabajo.EndDate = Datetime.now();
						update ordenTrabajo;
						if(todoCerrado){
							cerrarAnularCaso(caso, Label.CAS_ESTADO_CERRADO);
						}
						paginaRetorno = volver();
					}
				}
			}
		}
		catch(DmlException e){
			Database.rollback(puntoGuardado);
			system.debug(e.getStackTraceString());
			//if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			//}
	 	}
		catch(Exception e){
			Database.rollback(puntoGuardado);
			system.debug(e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
		}
		return paginaRetorno;
	}//FIN cerrarOrdenDeTrabajo()


	/**
     * Rellena la lista de Motivos.
     */ 
	private void rellenarMotivosAnulacion(){
		System.debug('Estoy en rellenarMotivosAnulacion');
		motivosAnulacion = new List<SelectOption>();
		if(caso.CAS_LKP_Procedencia__r.PROC_SEL_Motivos_Anulacion__c != null){
			String textoMotivosAnulacion = ';' + caso.CAS_LKP_Procedencia__r.PROC_SEL_Motivos_Anulacion__c + ';';
			DescribeSObjectResult obj = Schema.getGlobalDescribe().get('Procedencia__c').getDescribe();
			DescribeFieldResult campoMotivoAnulacion = obj.fields.getMap().get('PROC_SEL_Motivos_Anulacion__c').getDescribe();
			List<Schema.PicklistEntry> listaPicklistProcedencias = campoMotivoAnulacion.getPicklistValues();
			String motivoAnulacionValor = '';
			String motivoAnulacionEtiqueta = '---SELECCIONE UNA OPCIÓN---';
			motivosAnulacion.add(new SelectOption(motivoAnulacionValor, motivoAnulacionEtiqueta));
			for(Schema.PicklistEntry valorCampoAnulacion : listaPicklistProcedencias){
				motivoAnulacionValor = valorCampoAnulacion.getValue();
				motivoAnulacionEtiqueta = valorCampoAnulacion.getLabel();
				if(textoMotivosAnulacion.contains(';' + motivoAnulacionValor + ';')){
					motivosAnulacion.add(new SelectOption(motivoAnulacionValor, motivoAnulacionEtiqueta));
				}
			}
		}
	}//FIN rellenarMotivosAnulacion()


	private Boolean todoCerradoCaso(List<WorkOrder> listaOTsCaso){
		Boolean todoCerrado = true;
		for(WorkOrder ot : listaOTsCaso){
			if(ot.Id != ordenTrabajo.Id && (!Util_Orden_Trabajo.SET_ESTADOS_CERRADOS.contains(ot.Status))){
				todoCerrado = false;
				break;
			}
		}
		return todoCerrado;
	}//FIN todoCerradoCaso()

	
	private void cerrarAnularCaso(Case caso, String estadoCierreAnul){
		caso.Status = estadoCierreAnul;
		caso.CAS_TXT_Subestado_Codigo__c = null;
		update caso;
	}//FIN cerrarAnularCaso()
	
	private void cerrarAnularReclamacion(Case caso, String estadoCierreAnul, String motivoAnulacion){
		caso.Status = estadoCierreAnul;
		caso.CAS_SEL_Motivo_anulacion_reclamacion__c = motivoAnulacion;
		caso.CAS_TXT_Subestado_Codigo__c = null;
		update caso;
	}//FIN cerrarAnularReclamacion()
}