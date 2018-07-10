/**
 * Clase controladora de la Visualforce "ReservarCita" encargada de reservar la primera cita de servicio para una WorkOrder
 * 
 * @author EVERIS
 */
public without sharing class ReservarCita {
	public Case caso {get; set;}
	public Boolean esB2C {get; set;}
	public Boolean esReclamacion {get; set;}
	private String solicitudExistente;
	public String fase {get; set;}
	private String paginaRetorno;
	public WorkOrder ot {get; set;}
	public WorkOrder otInputManual {get; set;}
	public String tipoActuacion {get; set;}
	public String gremio {get; set;}
	public Integer tipoCaso {get; set;}//Almacena 1 si es un caso y un 2 si es un servicio B2B/B2B2C
	public Account cuenta {get; set;}
	public Boolean bookAppoinment {get; set;}
	public Boolean citaReservada {get; set;}
	public Boolean asignarUrgencia {get; set;}
	public Boolean horarioFuera {get; set;}
	public Boolean automatico {get; set;}
	public Boolean esProfesional {get; set;}
	public Boolean autoasignar {get; set;}
	public Boolean mostrarAutoasignar {get; set;}
	public Boolean buscarCitaReservada {get; set;}
	private Date primeraFechaDisponible;

	/**
 	 * 
 	 * Constructor de la clase
 	 * 
  	 */	  
	public ReservarCita(ApexPages.standardController stdCtr){
		Id recordTypeIdReclamacion = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
		citaReservada = false;
		mostrarBookAppoinment();
		esProfesional = Util_Perfiles_Usuario.esProfesional(UserInfo.getProfileId());
		esB2C = false;
		esReclamacion = false;

		if(esProfesional){
			automatico = false;
		}else{
			automatico = true;
		}

		autoasignar = false;
		mostrarAutoasignar = false;
		otInputManual = new WorkOrder();

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
		if(paginaActual.getParameters().containsKey('buscarCita')){
			buscarCitaReservada = paginaActual.getParameters().get('buscarCita') == 'N'? false:true;
		}
		else {
			buscarCitaReservada = true;
		}

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
				esReclamacion = (caso.RecordTypeId == recordTypeIdReclamacion);
				tipoActuacion = Util_Siniestro.devolverTipoActuacion(caso.Type, caso.ParentId);
				cuenta = Util_Cuentas.getMapCuentasById(new Set<Id>{caso.AccountId}).get(caso.AccountId);

				List<WorkOrder> listaOT = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{paginaActual.getParameters().get('idOrdenTrabajo')}).values();
				//List<WorkOrder> listaOT = Util_Orden_Trabajo.queryOT(paginaActual.getParameters().get('idOrdenTrabajo'), null, null);
				if(listaOT.isEmpty()){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.SINI_ERROR_USUARIO));
				}
				else {
					ot = listaOT.get(0);
					asignarUrgencia = ot.OTR_CAS_Urgente__c;
					Datetime fechaPosible = Util_Cita_Servicio.calcularFechaInicio(Date.today(), ot.OTR_CAS_Urgente__c);
					if(fechaPosible != null){
						primeraFechaDisponible = fechaPosible.date();
						otInputManual.OTR_DAT_Fecha_Primera_Cita__c = primeraFechaDisponible;
					}
					if(esProfesional){
						mostrarAutoasignar = Util_Orden_Trabajo.profesionalTieneGremio(UserInfo.getUserId(), ot.OTR_SEL_Gremio__c);
					}
				}
                if(ot != null){
                    horarioFuera = metHorarioFuera(ot.ServiceTerritoryId);
                }
				

			}
		}
	}//FIN CONSTRUCTOR

	/**
 	 * Método que se encarga de volver a la página anterior al proceso actual
 	 * 
   	 * @return página a navegar tras la acción de 'volver'
  	 */
	public PageReference volver(){
		PageReference paginaRedireccion = new PageReference(paginaRetorno);
		paginaRedireccion.getParameters().put('id', caso.Id);
		paginaRedireccion.getParameters().put(Label.SINI_PARAMETRO_FASE, fase);
		paginaRedireccion.getParameters().put('solicitudExistente', solicitudExistente);
		if(citaReservada){
			paginaRedireccion.getParameters().put('citaReservadaOK', 'Y');
		}
		paginaRedireccion.setRedirect(true);
		return paginaRedireccion;
	}//FIN volver()

	/**
 	 * Método encargado de moostrar el book apointment
  	 */
	public void mostrarBookAppoinment(){
		bookAppoinment = true;
	}

	/*public void ocultarBookAppoinment()
	{
		bookAppoinment = false;
	}*/

	/**
 	 * Método encargado de navegar a la siguiente pantalla del proceso
 	 * 
   	 * @return página a navegar tras la acción de 'continuar'
  	 */   	
	public PageReference continuar(){
		PageReference retorno = null;
		if(otInputManual.OTR_DAT_Fecha_Primera_Cita__c == null 
				|| otInputManual.OTR_SEL_Rango_Primera_Cita__c == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_RESERVACITA_REQ));
		}
		else if(otInputManual.OTR_DAT_Fecha_Primera_Cita__c < primeraFechaDisponible){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No se puede reservar una cita antes del ' + primeraFechaDisponible.format()));
		}
		else {
			system.Savepoint puntoGuardado = Database.setSavepoint();
			try {
				programarCita();
				retorno = volver();
			}
			catch(DmlException e){
				Database.rollback(puntoGuardado);
				if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
	                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR));
	             }
			}
			catch(Exception e){
				system.debug(e.getStackTraceString());
				Database.rollback(puntoGuardado);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			}
		}
		return retorno;
	}

	/**
 	 * Método encargado de comprobar todas las citas de la orden de trabajo y verificar si tienen cita reservada
  	 */   	
	public void verificarCitaReservada(){
		if(automatico){
			WorkOrder otAux = (Util_Orden_Trabajo.queryMapOTById(new Set<Id>{ot.Id})).get(ot.Id);
			//WorkOrder otAux = (Util_Orden_Trabajo.queryOT(ot.Id, null, null)).get(0);
			//para todas las Citas de la OT mirar las que no están en estado final y verificar que no tienen la cita reservada
			//verificar que no se ha reservado la cita.
			List<ServiceAppointment> listaCitas = Util_Cita_Servicio.getListCitasOTsNotInStatus(ot.Id, Util_Cita_Servicio.SET_ESTADOS_CERRADOS);
			if(!listaCitas.isEmpty()){
				for(ServiceAppointment cita :listaCitas){
					if(cita.SchedStartTime != null){
						citaReservada = true;
					}
				}
			}
			automatico = true;
		}
		else {
			automatico = false;
		}
	}

	/**
 	 * Método encargado de actualizar el campo 'Asignar como Mizad' en la orden de trabajo
  	 */	  
	public void asignacionMizad(){
		// Actualizar el campo Asignar como Mizad de la Orden de trabajo seleccionada (en el trigger se actualiza el campo en las citas de servicio asociadas)
		system.Savepoint puntoGuardado = Database.setSavepoint();
		try {
			/*if(ot.OTR_CAS_Asignar_Mizad__c){
				ot.OTR_SEL_Tipo_Red__c = 'Mizad';
			}else{
				ot.OTR_SEL_Tipo_Red__c = null;
			}*/
			update ot;
		}
		catch(DmlException e){
			Database.rollback(puntoGuardado);
			system.debug('>>>>>>>>>>>>>EXCEPTION: ' + e.getStackTraceString());
			if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR));
			}
		}
		catch(Exception e){
			Database.rollback(puntoGuardado);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			system.debug(e.getStackTraceString());
		}			
	}

	// ¿Pasarlo al trigger?
	/**
 	 * Método encargado de comprobar si una cita ha sido aplazada anteriormente o no
 	 * 
   	 * @return true si la cita ha sido aplazada anteriormente, si no false
  	 */   
	public Boolean aplazamientoAplicado(){
		Boolean aplazamiento = false;
		// Se mira que no se haya calculado la fecha de inicio mas temprano previamente
		if(caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c != null
				
				&& ot.ServiceTerritory.PostalCode != null
				&& ot.OTR_CAS_Urgente__c){
			List<Programacion_cita__mdt> listaConfsAplazamiento = Util_Metadatos.getProgCitaByIdCIAAndSegmentAndCapitalProv(new Set<String>{caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c},new Set<String>{/*ot.Account.CUE_FOR_Segmentacion__c*/},ot.ServiceTerritory.PostalCode.subString(2,3) == '0').values();
			/*List<Programacion_cita__mdt> listaConfsAplazamiento = new List<Programacion_cita__mdt>([
			                                                                                        SELECT	PRC_TXT_Identificador_CIA__c, PRC_TXT_Segmentacion__c, PRC_CAS_Capital_Provincia__c, PRC_NUM_Plazo__c
			                                                                                        FROM	Programacion_cita__mdt
			                                                                                        WHERE	PRC_TXT_Identificador_CIA__c = :caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c
			                                                                                        AND PRC_TXT_Segmentacion__c = :ot.Account.CUE_FOR_Segmentacion__c
			                                                                                        AND PRC_CAS_Capital_Provincia__c = :ot.ServiceTerritory.PostalCode.subString(2,3) == '0'
			                                                                                        AND PRC_NUM_Plazo__c != null]);*/
			if(!listaConfsAplazamiento.isEmpty()){	// Si no se ha encontrado nada es porque no se ha aplazado la cita anteriormente
				aplazamiento = true;
			}
		}
		return aplazamiento;
	}

	// ¿Pasarlo al trigger?
	/**
 	 * Método encargado de mostrar el check de 'Programar cita para hoy' si es posible
 	 * 
   	 * @return true si se muestra el check, si no false
  	 */   
	public Boolean necesarioProgramarHoy(){
		// Busqueda del metadato personalizado para mostrar el check de Programar cita para hoy
		Boolean retorno = esReclamacion;
		if(!retorno){
			String gremioFiltro = '%;' + ot.OTR_SEL_Gremio__c + ';%';
			List<Programacion_cita__mdt> listaConfProgramacion = Util_Metadatos.queryProgramacionCitaByIdCIAAndLikeGremio(new Set<String>{caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c},gremioFiltro).values();
			/*List<Programacion_cita__mdt> listaConfProgramacion = new List<Programacion_cita__mdt>([	
		                                                                                       SELECT 	Id 
		                                                                                       FROM 	Programacion_cita__mdt 
		                                                                                       WHERE 	PRC_TXT_Identificador_CIA__c = :caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c
		                                                                                       AND PRC_TXT_Gremios__c LIKE :gremioFiltro]);*/
			if(!listaConfProgramacion.isEmpty()){
				retorno = true;
			}
		}
		return retorno;
	}

	// ¿Pasarlo al trigger?
	/**
 	 * Método encargado de iniciar el proceso para programar una cita en el mismo día de creación de la OT
  	 */   
	public void programarHoy(){
		if(!aplazamientoAplicado()){
			// Busqueda del metadato personalizado para Programar cita para hoy
			Boolean necesarioProgHoy = necesarioProgramarHoy();
			system.Savepoint puntoGuardado = Database.setSavepoint();
			// Actualizar la cita de servicio asociada a la OT, estableciendo el Inicio mas temprano permitido a la fecha de creacion de la OT mas 3 horas
			try {
				List<ServiceAppointment> listaCitasActualizadas = new List<ServiceAppointment>();
				List<ServiceAppointment> listaCitas = Util_Cita_Servicio.getListCitasOTsNotInStatus(ot.Id, Util_Cita_Servicio.SET_ESTADOS_CERRADOS);
				if(!listaCitas.isEmpty()){
					for(ServiceAppointment cita :listaCitas){
						if(necesarioProgHoy){
							cita.EarliestStartTime = ot.CreatedDate.addHours(3);
						}
						else {
							cita.EarliestStartTime = Util_Cita_Servicio.calcularFechaInicio(ot.CreatedDate, ot.OTR_CAS_Urgente__c);
						}
						listaCitasActualizadas.add(cita);
					} 
				}
				update listaCitasActualizadas;
			}
			catch(DmlException e){
				Database.rollback(puntoGuardado);
				system.debug('>>>>>>>>>>>>>EXCEPTION DML: ' + e.getStackTraceString());
				if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR));
				}
			}
			catch(Exception e){
				system.debug('>>>>>>>>>>>>>EXCEPTION: ' + e.getStackTraceString());
				Database.rollback(puntoGuardado);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
			}
		}			
	}

	/**
 	 * Método encargado de actualizar las citas de la OT según deban ser asignadas de urgencia o no
  	 */   	
	public void asignarComoUrgencia(){
		List<ServiceAppointment> listaCitasUpdt = new List<ServiceAppointment>();
		List<ServiceAppointment> listaCitas = Util_Cita_Servicio.getListCitasOTsNotInStatus(ot.Id, Util_Cita_Servicio.SET_ESTADOS_CERRADOS);
		try {
			for(ServiceAppointment cita : listaCitas){
				cita.CSE_CAS_Asignar_como_Urgencias__c = asignarUrgencia;
				listaCitasUpdt.add(cita);
			}
			update listaCitasupdt;
		}
		catch(DmlException e){
			system.debug(e.getStackTraceString());
           	if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
              	 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
            }
     	}
		catch(Exception e){
			system.debug(e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
		}			
	}

	/**
 	 * Método encargado de actualizar las citas de la OT según deban ser asignadas de urgencia o no
  	 */   	
	public void autoasignarCitas(){
		List<ServiceAppointment> listaCitasUpdt = new List<ServiceAppointment>();
		List<ServiceAppointment> listaCitas = Util_Cita_Servicio.getListCitasOTsNotInStatus(ot.Id, Util_Cita_Servicio.SET_ESTADOS_CERRADOS);
		try {
			for(ServiceAppointment cita : listaCitas){
				cita.CSE_CAS_Autoasignar__c = autoasignar;
				listaCitasUpdt.add(cita);
			}
			update listaCitasupdt;
		}
		catch(DmlException e){
			system.debug(e.getStackTraceString());
           	if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
              	 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
            }
     	}
		catch(Exception e){
			system.debug(e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
		}			
	}

	/**
 	 * Método encargado de lanzar los métodos relativos a la programación de la cita y asignación de urgencias
  	 */   
	public void asignarUrgYProg(){
		programarHoy();
		asignarComoUrgencia();
	}

	/**
 	 * Método encargado de comprobar si se encuentra en día no festivo/fin de semana y dentro de horario
 	 * @param territorioServicio: territorio en el que se contemplan festivos
 	 * 
   	 * @return true si es fin de semana, festivo o fuera de horario; si no false
  	 */   
	private Boolean metHorarioFuera (Id territorioServicio){
		Integer diaDeLaSemana = Date.today().toStartOfWeek().daysBetween(Date.today());
		boolean esFinDeSemana = false;//diaDeLaSemana == 5 || diaDeLaSemana == 6; 
		boolean horaFuera = DateTime.now().time() > Time.newInstance(20, 00, 00, 00) || DateTime.now().time() < Time.newInstance(8, 00, 00, 00) ;
		return (esFinDeSemana || Util_Cita_Servicio.esFestivo(territorioServicio) || horaFuera);
	}

	/**
 	 * Método encargado de programar una cita de servicio por política de geolocalización
  	 */   
	private void programarCita(){
		List<ServiceAppointment> listaCitas = Util_Cita_Servicio.getListCitasOTsInStatus(ot.Id, new Set<String>{Label.CIT_ESTADO_PTE_ASIGNAR});
		if(!listaCitas.isEmpty()){
			ServiceAppointment sa = listaCitas.get(0);
			String labelRango = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'OTR_SEL_Rango_Primera_Cita__c').get(otInputManual.OTR_SEL_Rango_Primera_Cita__c);
			List<String> listaHoras = labelRango.split(' - ');
			String horaIni = listaHoras.get(0).split(':').get(0);
			String horaFin = listaHoras.get(1).split(':').get(0);
			String politicaGeolocalizacion;
			/*if(!ot.OTR_CAS_Asignar_Como_Franquiciado__c && ot.OTR_CAS_Asignar_territorio_prim_no_franq__c){
				politicaGeolocalizacion = 'Política de Asignación – Geolocalización - Primario';
			}else{
				politicaGeolocalizacion = 'Política de Asignación – Geolocalización';
			}*/
			if(ot.OTR_CAS_Asignar_territorio_prim_no_franq__c){
				politicaGeolocalizacion = 'Política de Asignación – Geolocalización';
			}else{
				politicaGeolocalizacion = 'Política de Asignación – Geolocalización - Primario';
			}
			if(horaIni != null && horaFin != null){
				sa.ArrivalWindowStartTime = DateTime.newInstance(otInputManual.OTR_DAT_Fecha_Primera_Cita__c.year(), otInputManual.OTR_DAT_Fecha_Primera_Cita__c.month(), 
						otInputManual.OTR_DAT_Fecha_Primera_Cita__c.day(), Integer.valueOf(horaIni), 0, 0);
				sa.ArrivalWindowEndTime =  DateTime.newInstance(otInputManual.OTR_DAT_Fecha_Primera_Cita__c.year(), otInputManual.OTR_DAT_Fecha_Primera_Cita__c.month(), 
				 otInputManual.OTR_DAT_Fecha_Primera_Cita__c.day(), Integer.valueOf(horaFin), 0, 0); 
				update sa;
			}
			if(metHorarioFuera(listaCitas.get(0).ServiceTerritoryId)){
				Id schedulingPolicyGeoId = Util_Cita_Servicio.queryMapSchedulingPolicy(new Set<String>{politicaGeolocalizacion}).values().get(0).Id;
				//Id schedulingPolicyGeoId = Util_Cita_Servicio.getSchedulingPolicyId(politicaGeolocalizacion);//[select id from FSL__Scheduling_Policy__c where Name =: politicaGeolocalizacion limit 1].Id;
				FSL.ScheduleResult scheduleResult = FSL.ScheduleService.Schedule(schedulingPolicyGeoId, sa.Id);
				if(scheduleResult != null ){
					citaReservada = true;
				}
				else {
					if(sa.ArrivalWindowStartTime.date() == Date.Today()){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Hubo un problema al programar la cita del servicio'));
					}
					else {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'La cita entrará en el motor de asignación Pulse <Confirmar Cita> para continuar'));
					}
				}
			}
		}
	}

	/**
 	 * Método encargado de cambiar de modo de reserva de cita manual a automático y viceversa
  	 */   
	public void manualAutomatico(){
		automatico = !automatico;
	}
	
	/**
	 * Método encargado de marcar el check de 'Asignar territorio prim no franquiciado' cuando se marca 'Asignar como franquiciado'
	 */
	public void asignarFranquiciado(){
		//if(ot.OTR_CAS_Asignar_Como_Franquiciado__c){
			//ot.OTR_CAS_Asignar_territorio_prim_no_franq__c = true;
		//}
		// Actualizar el campo Asignar como franquiciado de la Orden de trabajo seleccionada (en el trigger se actualiza el campo en las citas de servicio asociadas)
		system.Savepoint puntoGuardado = Database.setSavepoint();
		try {
			update ot;
		}
		catch(DmlException e){
			Database.rollback(puntoGuardado);
			system.debug('>>>>>>>>>>>>>EXCEPTION DML: ' + e.getStackTraceString());
			if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR));
			}
		}
		catch(Exception e){
			system.debug('>>>>>>>>>>>>>EXCEPTION: ' + e.getStackTraceString());
			Database.rollback(puntoGuardado);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
		}		
	}
	
	/**
	 * Método encargado de marcar el check de actualizar la OT cuando se cambia el campo 'Asignar territorio prim no franquiciado'
	 */
	public void asignarTerritorioPrimNoFranq(){
		// Actualizar el campo Asignar territorio prim no franquiciado de la Orden de trabajo seleccionada (en el trigger se actualiza el campo en las citas de servicio asociadas)

		system.Savepoint puntoGuardado = Database.setSavepoint();
		try {
			update ot;
		}
		catch(DmlException e){
			Database.rollback(puntoGuardado);
			system.debug('>>>>>>>>>>>>>EXCEPTION DML: ' + e.getStackTraceString());
			if(e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR));
            }
		}
		catch(Exception e){
			Database.rollback(puntoGuardado);
			system.debug('>>>>>>>>>>>>>EXCEPTION: ' + e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_GUARDAR + ' : ' + e.getMessage()));
		}		
	}

	/**
	 * Devuelve el filtro de los estados en forma de String a partir del conjunto pasado por parámetro.
	 *
	 * @param estados: conjunto de estados del filtro
	 * @param String para query en la que Status no coincida con ninguno de los estados pasados por parámetro
	 */
	private static String getFiltroWhereEstados(Set<String> estados){
		String filtro = '';
		if(estados != null){
			for(String estado : estados){
				filtro += ' AND Status != \''+estado+'\'';
			}
		}
		return filtro;
	}
}