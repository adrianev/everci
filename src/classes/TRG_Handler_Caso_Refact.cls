/**
  * Handler del Trigger TRG_Caso_Refact.
  * 
  * @author EVERIS
  * 
  */
public without sharing class TRG_Handler_Caso_Refact {
	// RecordTypeId de los tipos de registro utilizados
	private static final Id recordTypeIdReclamacion = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
	private static final Id recordTypeIdSolReclamacion = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOL_RECLAMACION);
	private static final Id recordTypeIdSolB2B_B2B2C = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2B_B2B2C);
	private static final Id recordTypeIdSolicitudB2C = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2C);
	private static final Id recordTypeIdServB2C = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C);
	private static final Id recordTypeIdServB2B = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C);
	private static final Id recordTypeIdSolSini = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_SINIESTRO);
	private static final Id recordTypeIdSini = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO);
	
	// Se instancian todos los mapas que se van a utilizar
	private static Map<Id, Contact> mapaContactos;
	private static Map<Id, Account> mapaCuentas;
	private static Map<String, Account> mapaCuentasPorIdent;
	private static Map<Id, WorkOrder> mapaOTs;
	private static Map<Id, List<WorkOrder>> mapaOTsPorCaso;
	private static Map<Id, WorkOrderLineItem> mapaPartidasOTs;
	private static Map<Id, ServiceContract> mapaPolizas;
	private static Map<Id, Procedencia__c> mapaProcedencias;
	private static Map<Id, List<Task>> mapaTareasCaso;
	private static List<Task> listaTareasACerrar;
	//private static Id idSucesoGrave;
	private static Map<Id,Perito__c> mapaPeritos;
	private static Map<Id, Buzon_CIA__c> mapaBuzones;
	/**
	  * [PENDIENTE]
	  * 
	  * @param triggerNew: [PENDIENTE]
	  * @param triggerNewMap: [PENDIENTE]
	  */
	private static void inicializarVariables(List<Case> triggerNew, Map<Id, Case> triggerNewMap){
		// Se inicializan todos los mapas que se van a utilizar
		mapaContactos = new Map<Id, Contact>();
		mapaCuentas = new Map<Id, Account>();
		mapaCuentasPorIdent = new Map<String, Account>();
		mapaOTs = new Map<Id, WorkOrder>();
		mapaOTsPorCaso = new Map<Id, List<WorkOrder>>();
		mapaPartidasOTs = new Map<Id, WorkOrderLineItem>();
		mapaPolizas = new Map<Id, ServiceContract>();
		mapaProcedencias = new Map<Id, Procedencia__c>();
		mapaTareasCaso = new Map<Id, List<Task>>();
		mapaPeritos = new Map<Id,Perito__c>();
		mapaBuzones = new Map<Id, Buzon_CIA__c>();
		
		// Se crean sets para filtrar las queries a los distintos objetos
		Set<Id> setIdCue = new Set<Id>();
		Set<Id> setIdCont = new Set<Id>();
		// Se crea un set que va a contener los ID de las polizas que tienen vinculadas los casos
		Set<Id> setIdsPolizas = new Set<Id>();
		Set<Id> setIdsOTPadresRecl = new Set<Id>();
		// Emails para identificar los buzones
		Set<String> setEmail = new Set<String>();

		Set<Id> setOwner = new Set<Id>();
		Set<ID> setPeritos = new Set<Id>();
		//Set con la Id de peritos asociada a los casos.
		for(Case caso :triggerNew){
			if(caso.CAS_LKP_Compania__c != null){
				setIdCue.add(caso.CAS_LKP_Compania__c);
			}
			if(caso.AccountId != null){
				setIdCue.add(caso.AccountId);
			}
			if(caso.ContactId != null){
				setIdCont.add(caso.ContactId);
			}
			if (caso.CAS_LKP_PolizaContrato__c != null){
				setIdsPolizas.add(caso.CAS_LKP_PolizaContrato__c);
			}

			if (caso.RecordtypeId == recordTypeIdReclamacion
					&& caso.CAS_LKP_Recl_Orden_Trabajo__c != null){
				setIdsOTPadresRecl.add(caso.CAS_LKP_Recl_Orden_Trabajo__c);
			}
			if(caso.Origin == 'Email'
					&& caso.CAS_LKP_Compania__c == null
					&& caso.SourceId != null){
				setEmail.add(caso.SourceId);
			}
			
			if(caso.OwnerId != null)
				setOwner.add(caso.OwnerId);
			if(caso.CAS_LKP_Perito__c!=null)
				setPeritos.add(caso.CAS_LKP_Perito__c);
		}

		// Se recogen los correos electronicos de los casos abiertos via email
		Map<Id, EmailMessage> mapaEmail;
		if(!setEmail.isEmpty()){
			/*PREV:
			mapaEmail = new Map<Id, EmailMessage>([
												   SELECT  ToAddress
												   FROM EmailMessage
												   WHERE   Id IN :setEmail]);*/
			//NEW:
			mapaEmail = Util_Correo_Electronico.getEmailMessageById(setEmail);
			//END_NEW
		}
		if(!setPeritos.isEmpty()){
			mapaPeritos = Util_Perito.getPeritoById(setPeritos);
		}
		recogerRegistrosRelacionados(setIdCue, setIdCont, setIdsPolizas, setIdsOTPadresRecl,setOwner, mapaEmail, triggerNewMap);
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param triggerNew: [PENDIENTE]
	  * @param triggerNewMap: [PENDIENTE]
	  * @param triggerOldMap: [PENDIENTE]
	  * 
	  */
	private static void updateTaskOwner(List<Case> triggerNew, Map<Id, Case> triggerNewMap, Map<Id, Case>  triggerOldMap){
		String userType = Schema.SObjectType.User.getKeyPrefix();
		Set<Id> setIds = new Set<Id>();
		Map<Id, Set<Id>> mapaSetIdsWOporCaso = new Map<Id, Set<Id>>();
		for (Case caso : triggerNew){
			Case casoOld = triggerOldMap.get(caso.Id);
			// Si se ha modificado el propietario y éste es un usuario (no es una cola)
			if (casoOld.OwnerId != caso.OwnerId && ((String) caso.OwnerId).startsWith(userType)) {
				setIds.add(caso.Id);
				//También rellenamos el set de servicios con las wo cuyos casos padre han cambiado de propietario 
				//para que cambien también los propietarios de las tareas asociados a los mismos
				if(mapaOTsPorCaso.get(caso.Id)!=null && !mapaOTsPorCaso.get(caso.Id).isEmpty()){
					Set<Id> setIdsWO = new Set<Id>();
					for(WorkOrder wo: mapaOTsPorCaso.get(caso.Id)){
						setIdsWO.add(wo.Id);
					}
					mapaSetIdsWOporCaso.put(caso.Id,setIdsWO);
				}
			}
		}
		if(!setIds.isEmpty()){
			Map<Id, List<Task>> mapTask = Util_Tarea.getMapaTareasCaso(setIds);
			List<Task> taskUpdate = new List<Task>();
			for (Id entry : mapTask.keySet()) {
				List<Task> auxListTask = mapTask.get(entry);
				for (Task t: auxListTask){
					t.OwnerId = triggerNewMap.get(entry).OwnerId;
					taskUpdate.add(t);
				}
				if(mapaSetIdsWOporCaso.get(entry) != null && !mapaSetIdsWOporCaso.get(entry).isEmpty()){
					Map<Id, List<Task>> mapTaskWO = Util_Tarea.getMapaTareasCaso(mapaSetIdsWOporCaso.get(entry));
					for (Id woId : mapTaskWO.keySet()) {
						List<Task> auxListTaskWO = mapTaskWO.get(woId);
						for (Task t: auxListTaskWO){
							t.OwnerId = triggerNewMap.get(entry).OwnerId;
							taskUpdate.add(t);
						}
					}
				}
			}
			update taskUpdate;
		}
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param setIdCue: [PENDIENTE]
	  * @param setIdCont: [PENDIENTE]
	  * @param setIdsPolizas: [PENDIENTE]
	  * @param setIdsOTPadresRecl: [PENDIENTE]
	 * @param setOwner: [PENDIENTE]
	  * @param mapaEmail: [PENDIENTE]
	  * @param triggerNewMap: [PENDIENTE]
	  */
	private static void recogerRegistrosRelacionados(Set<Id> setIdCue, Set<Id> setIdCont, 
			Set<Id> setIdsPolizas, Set<Id> setIdsOTPadresRecl, Set<Id> setOwner,Map<Id, EmailMessage> mapaEmail, Map<Id, Case> triggerNewMap){

		if(!setIdCue.isEmpty()){
			// Cargar en un mapa los clientes, companias de cada Caso y las companias de los buzones (Email2Case)
			/* PREV: mapaCuentas = new Map<Id,Account>(
				[SELECT CUE_CAS_No_Interviene_Perito__c,
						CUE_DIV_Limite_Actuacion__c,
						CUE_LKP_Cliente_contable__c,
						CUE_LKP_contacto_principal__c,
						CUE_LKP_contacto_principal__r.Email,
						CUE_LKP_contacto_principal__r.FirstName,
						CUE_LKP_contacto_principal__r.LastName,
						CUE_LKP_contacto_principal__r.MobilePhone,
						CUE_LKP_contacto_principal__r.Phone,
						CUE_LKP_Cuenta_principal__c,
						CUE_LKP_Cuenta_Principal__r.CUE_TXT_Identificador__c,
						CUE_SEL_GestionIndemnizable__c,
						CUE_SEL_Provincia__c,
						CUE_TXT_Identificador__c,
						RecordTypeId,
						ShippingCity,
						ShippingPostalCode,
						ShippingStreet,
						ShippingCountry,
						Type
				 FROM Account 
				 WHERE Id IN :setIdCue]);
				 */
				//NEW:
				mapaCuentas = Util_Cuentas.getMapCuentasById(setIdCue);
				//END_NEW
				
			for(Account cuenta : mapaCuentas.values()){
				if(cuenta.CUE_TXT_Identificador__c != null
						&& !mapaCuentasPorIdent.containsKey(cuenta.CUE_TXT_Identificador__c)){
					mapaCuentasPorIdent.put(cuenta.CUE_TXT_Identificador__c, cuenta);
				}
			}
		}

		if(!setIdCont.isEmpty()){
			// Cargar en un mapa los contactos de cada Caso
			/*PREVIOUS: mapaContactos = new Map<Id,Contact>(
				[SELECT Email,
						FirstName,
						LastName,
						MobilePhone,
						Phone,
						AccountId,
						Account.RecordTypeId
				 FROM Contact 
				 WHERE Id IN :setIdCont]);
				 */
			//NEW:
			mapaContactos = Util_Contacto.getContactById(setIdCont);
			//END_NEW
		}

		if(!setIdsPolizas.isEmpty()){
			// Cargar en un mapa los registros de Póliza de cada Caso
			mapaPolizas = Util_Poliza_Contrato.queryPolizaById(setIdsPolizas);
			//END_NEW
		}

		// Cargar en un mapa todas las procedencias activas
		if(Trigger.IsInsert){
			
			Boolean error = true;
			Integer intentos = 5;
			
			while(error){
				try{
					/*PREV
					mapaProcedencias = new Map<Id, Procedencia__c>(
						[SELECT Name,
								PROC_SEL_Tipos_Caso__c,
								PROC_LKP_Cuenta__c,
								PROC_LKP_Cuenta__r.CUE_TXT_Identificador__c,
								PROC_TXT_Identificador__c
						 FROM Procedencia__c
						 FOR UPDATE]);
						 */
					//NEW:
					mapaProcedencias = Util_Procedencia.queryProcedenciasForUpdate();
						 
					error = false;
				} catch(QueryException e){
					intentos--;
					system.debug('-------EXCEPTION: '+e.getMessage());
					if(intentos <= 0 || !e.getMessage().contains('Registro no disponible en estos momentos: Otro usuario está modificando en estos momentos el registro que intenta modificar o uno de sus registros relacionados. Inténtelo de nuevo.')){
						throw e;
					}
				}
			}
		}
		else {
			/*
			mapaProcedencias = new Map<Id, Procedencia__c>(
				[SELECT Name,
						PROC_SEL_Tipos_Caso__c,
						PROC_LKP_Cuenta__c,
						PROC_LKP_Cuenta__r.CUE_TXT_Identificador__c,
						PROC_TXT_Identificador__c
				 FROM Procedencia__c]);
				 */
			mapaProcedencias = Util_Procedencia.queryProcedenciasNoWhere();
				 
		}
		if(triggerNewMap != null){
			// Cargar en un mapa todas las tareas de los casos
			mapaTareasCaso = Util_Tarea.tareasDeCasos(triggerNewMap.keySet());
		}

		if(triggerNewMap == null){
			//PREV:mapaOTs = Util_Orden_Trabajo.queryOTBySet(setIdsOTPadresRecl, new Set<ID>(), 'RecordTypeId != \'' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION) + '\'');
			//NEW:
			system.debug('----------setIDSOTS: '+setIdsOTPadresRecl);
			mapaOTs = Util_Orden_Trabajo.queryMapOTById(setIdsOTPadresRecl);
		}
		else {
			//PREV: mapaOTs = Util_Orden_Trabajo.queryOTBySet(setIdsOTPadresRecl, triggerNewMap.keySet(), 'RecordTypeId != \'' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION) + '\'');
			//NEW:
			mapaOTs = Util_Orden_Trabajo.queryMapOTByIdOrCaseId(setIdsOTPadresRecl,triggerNewMap.keySet());
			//mapaOTs = Util_Orden_Trabajo.queryMapOTById(setIdsOTPadresRecl);
			//END_NEW
			
			system.debug('#########mapaOTs: ' + mapaOTs);
			for(WorkOrder ordTbjo : mapaOTs.values()){ 
				if(ordTbjo.CaseId != null){
					List<WorkOrder> listaOTs;
					if(mapaOTsPorCaso.containsKey(ordTbjo.CaseId)){
						listaOTs = mapaOTsPorCaso.get(ordTbjo.CaseId);
					}
					else {
						listaOTs = new List<WorkOrder>();
					}
					listaOTs.add(ordTbjo);
					mapaOTsPorCaso.put(ordTbjo.CaseId, listaOTs);
				}
			}
		}
		if(!mapaOTs.isEmpty()){
			/*PREV:
				mapaPartidasOTs = new Map<Id, WorkOrderLineItem>(
				[SELECT Id,
						Description,
						PAR_DIV_Cargar_Cliente_AI__c,
						PAR_DIV_Cargar_Comp_AI__c,
						PAR_DIV_Liquidar_Prof_DI__c,
						PAR_NUM_Altura__c,
						PAR_NUM_Ancho__c,
						PAR_NUM_Unidades__c,
						PAR_TXT_Baremo_Codigo__c,
						PAR_TXT_Baremo_Desc__c,
						PAR_TXT_Detalle_WOLI__c,
						Status,
						WorkOrderId,
						WorkOrder.CaseId
				 FROM WorkOrderLineItem
				 WHERE WorkOrderId IN :mapaOTs.keySet()]);*/
				//NEW:
				mapaPartidasOTs = Util_Orden_Trabajo.getMapaPartidasOTByWorkOrderId(mapaOTs.keySet());
		}
		if(mapaEmail != null){
			// Guardar las direcciones en un set
			Set<String> direccionesEmail = new Set<String>();
			for(EmailMessage email : mapaEmail.values()){
				if(email.ToAddress != null
						&& !direccionesEmail.contains(email.ToAddress)){
					direccionesEmail.add(email.ToAddress);
				}
			}
			// Recoger los buzones a partir de las direcciones
			if(!direccionesEmail.isEmpty()){
				/* PREV:
				List<Buzon_CIA__c> listaBuzones = new List<Buzon_CIA__c>(
					[SELECT BUZ_LKP_Cuenta__c,
							BUZ_EMA_Direccion__c
					 FROM Buzon_CIA__c
					 WHERE BUZ_EMA_Direccion__c IN :direccionesEmail]);

				*/
				//NEW:
				List<Buzon_CIA__c> listaBuzones = Util_Correo_Electronico.getBuzonCIAByDireccionEmail(direccionesEmail).values();
				//END_NEW
				
				// Recorrer buzones para ordenarlos por direccion
				Map<String, Buzon_CIA__c> mapaDireccionesBuzon = new Map<String, Buzon_CIA__c>();
				for(Buzon_CIA__c buzon : listaBuzones){
					mapaDireccionesBuzon.put(buzon.BUZ_EMA_Direccion__c, buzon);
				}

				// Rellenar el mapaBuzones con el Id del email (SourceId del caso) y el buzon de su direccion
				for(EmailMessage email : mapaEmail.values()){
					Buzon_CIA__c buzonCorreo = mapaDireccionesBuzon.get(email.ToAddress);
					if(buzonCorreo != null){
						mapaBuzones.put(email.Id, buzonCorreo);
					}
				}
			}
		}
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param triggerNewMap: [PENDIENTE]
	  * @param triggerNew: [PENDIENTE]
	  * @param triggerOldMap: [PENDIENTE]
	  * @param triggerOld: [PENDIENTE]
	  */
	public static void tratamientoBefore(Map<Id, Case> triggerNewMap, List<Case> triggerNew, 
			Map<Id, Case> triggerOldMap, List<Case> triggerOld){
		// 1. ACCIONES ANTES DE GUARDAR UN REGISTRO EXISTENTE
		if (Trigger.isInsert || Trigger.isUpdate) {

			// Se inicializan los mapas anteriores
			inicializarVariables(triggerNew, triggerNewMap);
			String contadorSt;
			// 1.1. ACCIONES ANTES DE GUARDAR UN REGISTRO NUEVO
			if (Trigger.isInsert){
				List<Case> reclamacionesMail = new List<Case>();
				List<Case> reclamaciones = new List<Case>();
				for (Case caso : triggerNew){
					// Setear el campo CAS_LKP_Cliente_contable_cliente__c con el AccountId del caso:
					caso.CAS_LKP_Cliente_contable_cliente__c = caso.AccountId;

					// 1.1.1. Establecer el RecordType correspondiente
					caso.RecordTypeId = Util_Caso.getIdTipoDeRegistro(caso.RecordTypeId, caso.Type, 
							mapaCuentas.get(caso.CAS_LKP_Compania__c), caso.Status);
					
					// 1.1.2. Si llega un caso via email, resolver el lookup a Compañía del Caso consultando la dirección 
					// destino en el campo BUZ_EMA_Direccion__c en el objeto Buzón_CIA__c
					system.debug('TRG_Handler_Caso_Refact: tratamientoBefore: caso' + caso);
					system.debug('TRG_Handler_Caso_Refact: tratamientoBefore: caso.Source' + caso.Source);
          			system.debug('TRG_Handler_Caso_Refact: tratamientoBefore: caso.SourceId' + caso.SourceId);
          			system.debug('TRG_Handler_Caso_Refact: tratamientoBefore: caso.Owner' + caso.Owner);
					if(caso.Origin == 'Email'
							&& caso.CAS_LKP_Compania__c == null
							&& caso.SourceId != null){
						Buzon_CIA__c buzon = mapaBuzones.get(caso.SourceId);
						//Si el contacto pertenece a la cuenta principal lo borramos
						//y ademas el accountId se vacia 
						Contact contactoAux;
						if(caso.ContactId != null){
							contactoAux = mapaContactos.get(caso.ContactId);
							if(contactoAux.Account.recordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CUE_CLIENTEB2B_1)){
								caso.ContactId = null;
								caso.AccountId = null;
								
							}
						}
						if(buzon != null){
							caso.CAS_LKP_Compania__c = buzon.BUZ_LKP_Cuenta__c;
						}
						system.debug('TRG_Handler_Caso_Refact: tratamientoBefore: buzon' + buzon);
            			system.debug('TRG_Handler_Caso_Refact: tratamientoBefore: caso.CAS_LKP_Compania__c' + caso.CAS_LKP_Compania__c);
					}


					// Si el caso es un siniestro
					if(Util_Siniestro.esSiniestro(caso)){
						//system.debug('************* ACCIONES ANTES DE GUARDAR UN REGISTRO NUEVO: ' + caso);
						/* 
						 * 1.1.5. Existen listas en las que no se restringen los valores que se pueden insertar
						 * En estos casos se busca si el valor introducido coincide con uno de los nombres API de los valores de la lista 
						 * de seleccion y, si no existe, se busca si coincide con las etiquetas
						 * Si coincide con alguna de las etiquetas, se actualiza el campo del objeto poniendo el valor correcto, el API
						 */
						Util_Listas_Seleccion.corregirListasSeleccion(caso, new List<String> { 
							'CAS_SEL_Detalle_Averia__c' , 
							'CAS_SEL_Tipo_Averia__c' , 
							'CAS_SEL_Otros_Danos__c', 
							'CAS_SEL_Situacion_Danos_Propios__c'
						});

						if(caso.CAS_LKP_PolizaContrato__c != null 
								&& mapaPolizas != null){
							// 1.1.3. Heredar Dirección de Riesgo de la Póliza 
							caso = Util_Siniestro.heredarDireccionRiesgoPoliza(caso, mapaPolizas.get(caso.CAS_LKP_PolizaContrato__c));
						}
						system.debug(triggerOldMap + ' triggerOldMap');
						// 1.1.4. Logica peritos
						listaTareasACerrar = Util_Perito.controlInformesPerito(caso, triggerOldMap, mapaTareasCaso);

						// 1.1.5. Generacion de tareas
						//Util_Tarea.generarTareas(caso, triggerOldMap, mapaCuentas, mapaTareasCaso, mapaOTs, mapaPartidasOTs);
					}

					// 1.1.6. Si es una Solicitud B2B/B2B2C o B2C: Actualizamos la Compañía y la Dirección de Riesgo a partir de la Cuenta
					else if (caso.RecordTypeId == recordTypeIdSolB2B_B2B2C 
							|| caso.RecordTypeId == recordTypeIdSolicitudB2C
							|| caso.RecordTypeId == recordTypeIdServB2C 
							|| caso.RecordTypeId == recordTypeIdServB2B){
						// Establecer datos de la cuenta seleccionada en la creación
						Account cuentaCaso = mapaCuentas.get(caso.AccountId);
						Util_B2B.setDatosCuenta(caso, cuentaCaso);
						Contact contactoCaso = null;
						if(caso.ContactId != null){
							// Establecer datos del contacto seleccionado en la creación
							contactoCaso = mapaContactos.get(caso.ContactId);
						}
						else if(cuentaCaso != null && cuentaCaso.CUE_LKP_Contacto_principal__c != null){
							// Si no se ha seleccionado ningún contacto en la creación:
							// establecer el contacto principal de la cuenta
							caso.ContactId = cuentaCaso.CUE_LKP_Contacto_principal__c;
							contactoCaso = new Contact(Id=cuentaCaso.CUE_LKP_Contacto_principal__c,
													   FirstName=cuentaCaso.CUE_LKP_Contacto_principal__r.FirstName,
													   LastName=cuentaCaso.CUE_LKP_Contacto_principal__r.LastName,
													   Phone=cuentaCaso.CUE_LKP_Contacto_principal__r.Phone,
													   MobilePhone=cuentaCaso.CUE_LKP_Contacto_principal__r.MobilePhone,
													   Email=cuentaCaso.CUE_LKP_Contacto_principal__r.Email);
						}
						Util_B2B.setDatosContacto(caso, contactoCaso);
						// Establecer el Tipo "Correctivo"
						if (caso.RecordTypeId == recordTypeIdSolB2B_B2B2C) {
							caso.Type = Label.B2B_TIPO_CORRECTIVO;
						}
					}

					// 1.1.7. Si es una Reclamacion
					else if (caso.RecordtypeId == recordTypeIdReclamacion){
						reclamaciones.add(caso);
						caso.CAS_DAT_Fecha_Modificacion_Estado__c = system.now();
						if(caso.Status == Label.CAS_ESTADO_PDTE_ANALISIS){
							caso.CAS_DAT_Fecha_Activacion_Contador__c = system.now();
						}
					}

					// 1.1.8. Si se modifica el Tipo de Registro o la CIA: Recalculamos la procedencia
					if (caso.RecordtypeId != recordTypeIdReclamacion){
						caso.CAS_LKP_Procedencia__c = Util_Procedencia.getProcedencia(caso.RecordTypeId, caso.CAS_LKP_Compania__c, mapaProcedencias);
					}
					//Se setea la Direccion Territorial que le pertenece al caso en funcion de la provincia de la direccion de riesgo
					caso.CAS_SEL_Direccion_Territorial__c = Util_Caso.devolverDireccionTerritorial (caso);
	  
				}

				// 1.1.9. Se completan las direcciones de las reclamaciones
				Util_Reclamacion.completarDireccionesReclamaciones(reclamaciones, mapaOTs);

				// 1.1.10. Se mapean las reclamaciones abiertas por correo electronico
				//Util_Reclamacion.configurarReclamacionesCorreo(reclamacionesMail);
																		  
				// 1.1.11. Se rellenan los datos de los semaforos por compania
				Util_Caso.completarDatosSemaforo(triggerNew, mapaCuentas);
			}   // Fin trigger.isInsert

			// 1.2. ACCIONES ANTES DE ACTUALIZAR UN REGISTRO EXISTENTE
			else if (trigger.isUpdate){
				for (Case caso : triggerNew){
					Case casoOld = triggerOldMap.get(caso.Id);

					// 1.2.1. Establecemos el RecordType correspondiente
					if (caso.Type != casoOld.Type ||
							caso.CAS_LKP_Compania__c != casoOld.CAS_LKP_Compania__c ||
							caso.Status != casoOld.Status) {
						caso.RecordTypeId = Util_Caso.getIdTipoDeRegistro(caso.RecordTypeId, caso.Type, 
								mapaCuentas.get(caso.CAS_LKP_Compania__c), caso.Status);
					}

					//se crea abono cuando CAS_LKP_Cliente_contable__c o CAS_LKP_Cliente_contable_cliente__c cambian
					List<String> statusList = new List<String>();
					statusList.add(Label.OTR_ESTADO_REVISADO);
					statusList.add(Label.OTR_ESTADO_CERRADO);
					
					List<WorkOrder> listaTemp;
					if(mapaOTsPorCaso.containsKey(caso.Id)){
						listaTemp = mapaOTsPorCaso.get(caso.Id);
					}
					List<Workorder> otList = new List<WorkOrder>();
					if(listaTemp != null && !listaTemp.isEmpty()){
						for(Workorder wo: listaTemp){
							if(statusList.Contains(wo.Status)){
								otList.add(wo);
							}
						}
					}
					
					if(!otList.isEmpty() && (caso.CAS_LKP_Cliente_contable__c != casoOld.CAS_LKP_Cliente_contable__c ||
						caso.CAS_LKP_Cliente_contable_cliente__c != casoOld.CAS_LKP_Cliente_contable_cliente__c)){
						crearAbono(caso, casoOld, otList);
					}

					// 1.2.2. Establecer el texto del subestado
					if (caso.CAS_TXT_Subestado_Codigo__c != casoOld.CAS_TXT_Subestado_Codigo__c) {
						if (caso.CAS_TXT_Subestado_Codigo__c == null) {
							caso.CAS_TXT_Subestado_Caso__c = null; 
						}
						else {
							caso.CAS_TXT_Subestado_Caso__c = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'Status').get(caso.CAS_TXT_Subestado_Codigo__c);
						}
					}
					// Si llega un caso via email, resolver el lookup a Compañía del Caso consultando la dirección 
					// destino en el campo BUZ_EMA_Direccion__c en el objeto Buzón_CIA__c
					system.debug('TRG_Handler_Caso_Refact: tratamientoBefore: caso' + caso);
					system.debug('TRG_Handler_Caso_Refact: tratamientoBefore: caso.SourceId' + caso.SourceId);
					if(caso.Origin == 'Email' && caso.CAS_LKP_Compania__c == null && caso.SourceId != null){
						// Deshacer la funcionalidad automática del Email-to-Case
						// de identificación del Contacto a partir del correo electrónico del "De"
						if(caso.ContactId != null){
							caso.ContactId = null;
							caso.AccountId = null;
						}
						// Establecer CIA a partir del correo electrónico del "Para"
						Buzon_CIA__c buzon = mapaBuzones.get(caso.SourceId);
						if(buzon != null){
							caso.CAS_LKP_Compania__c = buzon.BUZ_LKP_Cuenta__c;
						}
						system.debug('TRG_Handler_Caso_Refact: tratamientoBefore: buzon' + buzon);
						system.debug('TRG_Handler_Caso_Refact: tratamientoBefore: caso.CAS_LKP_Compania__c' + caso.CAS_LKP_Compania__c);
					}
					System.debug('@@@@TRG_Handler_Caso: tratamientoBefore: antes de esSiniestro: ' + caso.recordTypeId);
					// 1.2.4. Acciones si el caso es un siniestro 
					if (Util_Siniestro.esSiniestro(caso)) {
						/* 
						 * 1.2.2. Existen listas en las que no se restringen los valores que se pueden insertar
						 * En estos casos se busca si el valor introducido coincide con uno de los nombres API de los valores de la lista 
						 * de seleccion y, si no existe, se busca si coincide con las etiquetas
						 * Si coincide con alguna de las etiquetas, se actualiza el campo del caso poniendo el valor correcto, el API
						 */
						Util_Listas_Seleccion.corregirListasSeleccion(caso, new List<String> { 
							'CAS_SEL_Detalle_Averia__c' , 
							'CAS_SEL_Tipo_Averia__c' , 
							'CAS_SEL_Otros_Danos__c', 
							'CAS_SEL_Situacion_Danos_Propios__c'
						});

						// 1.2.4.1. Si está marcado el check de solicitar perito y el campo fecha está vacío
						System.debug('@@@@TRG_Handler_Caso: tratamientoBefore: antes de fechaSolicitudPerito: ' + caso);
						System.debug('@@@@ TRG_Handler_Caso: mapaProcedencias' + mapaProcedencias);
						caso = Util_Perito.fechaSolicitudPerito(caso, triggerOldMap.get(caso.Id),mapaPeritos.get(caso.CAS_LKP_Perito__c), mapaProcedencias.get(caso.CAS_LKP_Procedencia__c));

						// 1.2.4.2. Si se marcan los check de Informes Recibidos o Tramitados, los Importes de Reserva y Minuta y el Motivo de Retirada. Ademas sus respectivas fechas son nulas
						// actualizarFechasPerito(caso);

						// 1.2.4.3. Si la póliza se ha actualizado: Informar la direccion del caso con la direccion de la poliza
						if (caso.CAS_LKP_PolizaContrato__c != casoOld.CAS_LKP_PolizaContrato__c){
							caso = Util_Siniestro.heredarDireccionRiesgoPoliza(caso, mapaPolizas.get(caso.CAS_LKP_PolizaContrato__c));
						}

						// 1.2.4.4. Si la CIA no es ni RGA (tramita documentos), Nationale ni Previsora y es indemnizable, se cierra y se marca el check de transferido,
						// lo cual generará, mediante un process builder, un email de salida a la cia
						Util_Compania.comprobacionCiaTramita(caso, mapaCuentas);

						// 1.2.4.5. Si se ha realizado el sondeo de una Solicitud de Siniestro (APERTURA) o de un Siniestro (CONFIRMACIÓN)
						Util_Siniestro.comprobacionSondeo(caso);

						// 1.2.4.6. Establecemos el Identificador único a partir de la CIA y del Nº de Siniestro
						//Util_Siniestro.generarIdentificador(caso, mapaPolizas); 

						// 1.2.4.7. Si el tipo de actuacion es Rechazo Parcial, se marca la casilla Rechazo Parcial
						if(caso.Type == Label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_PARCIAL){
							caso.CAS_CAS_Rechazo_Parcial__c = true;
						}

						// 1.2.4.8. Logica peritos
						listaTareasACerrar = Util_Perito.controlInformesPerito(caso, triggerOldMap, mapaTareasCaso);

						// 1.2.4.9. Si el estado de un caso se ha cambiado a "En Espera de confirmación por Gestor"
						if (caso.Status != casoOld.Status && caso.Status == Label.CAS_ESTADO_ESPERA_GESTOR_CONFIRMACION){
							// Se marca el check de "Requiere perito"
							caso.CAS_CAS_Requiere_Perito__c = true;
						}

						// 1.2.4.10. Generacion de tareas
						Util_Tarea.generarTareas(caso, triggerOldMap, mapaCuentas, mapaTareasCaso, mapaOTs, mapaPartidasOTs);
					}

					// 1.2.5. Si es una Solicitud B2B/B2B2C o B2C: Actualizamos la Compañía y la Dirección de Riesgo a partir de la Cuenta
					else if (caso.RecordTypeId == recordTypeIdSolB2B_B2B2C ||
							caso.RecordTypeId == recordTypeIdSolicitudB2C ||
							caso.RecordTypeId == recordTypeIdServB2C ||
							caso.RecordTypeId == recordTypeIdServB2B) {
						Id idContactoActualizado = caso.ContactId;
						// Si se ha actualizado la cuenta: establecer sus datos y su contacto principal
						if (caso.AccountId != null && caso.AccountId != casoOld.AccountId) {
							Account cuentaCaso = mapaCuentas.get(caso.AccountId);
							Util_B2B.setDatosCuenta(caso, cuentaCaso);
							if(cuentaCaso != null && cuentaCaso.CUE_LKP_Contacto_principal__c != null){
								caso.ContactId = cuentaCaso.CUE_LKP_Contacto_principal__c;
								Contact contactoCaso = new Contact(Id=cuentaCaso.CUE_LKP_Contacto_principal__c,
													   FirstName=cuentaCaso.CUE_LKP_Contacto_principal__r.FirstName,
													   LastName=cuentaCaso.CUE_LKP_Contacto_principal__r.LastName,
													   Phone=cuentaCaso.CUE_LKP_Contacto_principal__r.Phone,
													   MobilePhone=cuentaCaso.CUE_LKP_Contacto_principal__r.MobilePhone,
													   Email=cuentaCaso.CUE_LKP_Contacto_principal__r.Email);
								Util_B2B.setDatosContacto(caso, contactoCaso);
							}
						}
						// Si se ha actualizado el contacto: establecer sus datos
						if (idContactoActualizado != null && idContactoActualizado != casoOld.ContactId) {
							Util_B2B.setDatosContacto(caso, mapaContactos.get(idContactoActualizado));
						}
					}

					// 1.2.6. Si es una Reclamación
					else if (caso.RecordTypeId == recordTypeIdReclamacion) {
						if (caso.Status != casoOld.Status) {
							List<Workorder> listaWO = mapaOTsPorCaso.get(caso.Id);

							//Validar si todas las wo están cerradas antes de cerrar la reclamación
							if (listaWO != null && (caso.Status == Label.CAS_ESTADO_CERRADO_PDTE_LIQUIDAR ||
									caso.Status == Label.CAS_ESTADO_CERRADO_FACTURADO)) {
								Boolean error = false;
								for (WorkOrder wo: listaWO) {
									if (wo.Status != Label.OTR_ESTADO_CERRADO && wo.Status != Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO && wo.Status != Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN)
										error = true;
								}
								if(error)
									caso.addError(Label.ERROR_CERRAR_CASO_OTABIERTA);
							}

							//Recopilar el tiempo que se ha pasado en cada estado de la reclamación (días)
							if(casoOld.Status == Label.CAS_ESTADO_PDTE_ANALISIS)
								caso.CAS_NUM_Contador_Analisis__c += caso.CAS_DAT_Fecha_Modificacion_Estado__c.date().daysBetween(date.today());
							else if(casoOld.Status == Label.CAS_ESTADO_PDTE_TRATAMIENTO)
								caso.CAS_NUM_Contador_Tratamiento__c += caso.CAS_DAT_Fecha_Modificacion_Estado__c.date().daysBetween(date.today());
							else if(casoOld.Status == Label.CAS_ESTADO_PDTE_CIERRE)
								caso.CAS_NUM_Contador_Pdte_Cierre__c += caso.CAS_DAT_Fecha_Modificacion_Estado__c.date().daysBetween(date.today());

							caso.CAS_DAT_Fecha_Modificacion_Estado__c = system.now();

							//Iniciar o parar el contador general de la reclamación
							if(caso.Status == Label.CAS_ESTADO_PDTE_ANALISIS && caso.CAS_DAT_Fecha_Activacion_Contador__c == null){
								caso.CAS_DAT_Fecha_Activacion_Contador__c = system.now();
								if((27 - caso.CAS_NUM_Tiempo_Acumulado__c)>0)//TODO: Label para dias?
									caso.CAS_DAT_Generar_Tarea_Semaforo__c = Datetime.newInstance(System.today().addDays(Integer.valueOf(27 - caso.CAS_NUM_Tiempo_Acumulado__c)),System.now().time()); 
							} else if(caso.Status == Label.CAS_ESTADO_PDTE_CIERRE){
								if(caso.CAS_DAT_Fecha_Activacion_Contador__c != null)
									caso.CAS_NUM_Tiempo_Acumulado__c += caso.CAS_DAT_Fecha_Activacion_Contador__c.date().daysBetween(date.today());
								caso.CAS_DAT_Fecha_Activacion_Contador__c = null;
								caso.CAS_DAT_Generar_Tarea_Semaforo__c = null;
							}  
						}
						
						//Si se ha marcado como no fundada o sin determinar, no tiene que tener partidas aceptadas
						if(caso.CAS_SEL_Reclamacion__c != casoOld.CAS_SEL_Reclamacion__c 
							&& (caso.CAS_SEL_Reclamacion__c == Label.CAS_RECLAMACION_NO_FUNDADA || caso.CAS_SEL_Reclamacion__c == Label.CAS_RECLAMACION_SIN_DETERMINAR)){
								
								Boolean partidaAceptada = false;
								List<Workorder> woCaso = mapaOTsPorCaso.get(caso.Id);
								Set<Id> woIds = new Set<Id>();
								if(!woCaso.isEmpty()){
									Set<Id> woCasoIds = new Set<Id>();
									for(Workorder wo: woCaso){
										if(wo.Id != caso.CAS_LKP_Recl_Orden_Trabajo__c)
											woCasoIds.add(wo.Id);
									}
									if(!woCasoIds.isEmpty()){
										for(WorkorderLineItem woli: mapaPartidasOTs.values()){
											if(woCasoIds.contains(woli.WorkorderId) && Util_Partida.SET_ESTADOS_ACEPTADOS.contains(woli.Status)){
												partidaAceptada = true;
												break;
											}
										}
										
										if(partidaAceptada){
											caso.addError('No se puede poner una reclamación como \'No Fundada\' o \'Sin Determinar\' si tiene partidas aceptadas');
										}
									}
									
								}
							
						}
					}
					// Si se modifica el Tipo de Registro o la CIA: Recalculamos la procedencia
					if (caso.RecordTypeId != casoOld.RecordTypeId || caso.CAS_LKP_Compania__c != casoOld.CAS_LKP_Compania__c) {
						caso.CAS_LKP_Procedencia__c = Util_Procedencia.getProcedencia(caso.RecordTypeId, caso.CAS_LKP_Compania__c,
								mapaProcedencias);
					}

					if (caso.RecordTypeId != recordTypeIdReclamacion) {
						Util_Caso.actualizarFechasParo(caso, triggerOldMap.get(caso.Id));
					}

					if (caso.CAS_SEL_DirRiesgo_Estado_Provincia__c != casoOld.CAS_SEL_DirRiesgo_Estado_Provincia__c) {
						caso.CAS_SEL_Direccion_Territorial__c = Util_Caso.devolverDireccionTerritorial(caso);
					}
					
					if(caso.RecordtypeId == recordTypeIdSini){
						if(Util_Siniestro.asignarClienteContable(Caso.CAS_LKP_Compania__c, caso.Type) != '')
							caso.CAS_LKP_Cliente_Contable__c = Util_Siniestro.asignarClienteContable(Caso.CAS_LKP_Compania__c, caso.Type);
						system.debug('caso.CAS_LKP_Cliente_Contable__c siniRetornoSondeoExterno '+ caso.CAS_LKP_Cliente_Contable__c );
					}
				}
				// Invocamos la función para convertir el siniestro reparable normal en grave
				// Se insertan, actualizan y eliminan OTs - Es necesario sobrescribir el mapaOTsPorCaso y mapaOTs
				// Se actualizan WOLI, pero los cambios se actualizan en el mapaPartidasOTs
				Util_Siniestro.conversionASiniGrave(triggerNewMap, triggerOldMap, mapaOTsPorCaso, mapaPartidasOTs, mapaOTs);
			}
			// Fin trigger.isUpdate
			
			for(Case caso: triggerNew){
				if(caso.RecordtypeId == recordTypeIdSolicitudB2C || caso.RecordtypeId == recordTypeIdServB2C
				|| caso.RecordtypeId == recordTypeIdSolB2B_B2B2C || caso.RecordtypeId == recordTypeIdServB2B){
					caso.CAS_SEL_Canal_Baremo__c = Label.CAS_CANALBAREMO_AS;
				} else if((caso.RecordtypeId == recordTypeIdSolSini || caso.RecordtypeId == recordTypeIdSini) && caso.Type == Label.CAS_TIPO_RECHAZO_EN_APERTURA){
					caso.CAS_SEL_Canal_Baremo__c = Label.CAS_CANALBAREMO_RA;
					caso.Status = Label.CAS_ESTADO_CERRADO;
				} else if((caso.RecordtypeId == recordTypeIdSolSini || caso.RecordtypeId == recordTypeIdSini) && caso.Type == Label.CAS_TIPO_RECHAZO_EN_CONFIRMACION_TOTAL){
					caso.CAS_SEL_Canal_Baremo__c = Label.CAS_CANALBAREMO_RC;
				}
			}
			if(Trigger.isInsert){ //Clic Hogar
				actualizarDatos_ClicHogar(Trigger.new);
			}
		}
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param triggerNewMap: [PENDIENTE]
	  * @param triggerNew: [PENDIENTE]
	  * @param triggerOldMap: [PENDIENTE]
	  * @param triggerOld: [PENDIENTE]
	  */
	public static void tratamientoAfter(Map<Id, Case> triggerNewMap, List<Case> triggerNew, 
			Map<Id, Case> triggerOldMap, List<Case> triggerOld){
		// 2. ACCIONES DESPUÉS DE GUARDAR UN REGISTRO EXISTENTE
		System.debug('tratamientoAfter');
		Map<Id, Workorder> woActualizar = new Map<Id,WOrkorder>();
		Map<Id,Case> casoActualizar = new Map<Id,Case>();
		Map<Id, ServiceContract> mapaPolizasActualizar = new Map<Id, ServiceContract>();
		system.debug('-----------mapaOTs: '+mapaOTs);
		List<ContentVersion> cvInsertar = new List<ContentVersion>();
		if(trigger.isInsert){
		
			// Genero una OT asociada a la reclamación
			// Inserta ordenes de trabajo
			// Actualizar mapaOTs
			Util_Orden_Trabajo.crearOTparaCaso(triggerNew, triggerOldMap, mapaOTs);
			List<Case> mailReclamacion = new List<Case>();
			List<Case> actualizarIdentificadores = new List<Case>();
			
			for (Case caso : triggerNew){
				if(Util_Siniestro.esSiniestro(caso)){
					// 2.1. Logica peritos
					listaTareasACerrar.addAll(Util_Perito.controlInformesPerito(caso, triggerOldMap, mapaTareasCaso));
					if(caso.CAS_CAS_Plazo_Envio_I_D_Superado__c){
						// TODO: 2.2. Enviar correo al perito y al contacto con tipo de programa "Informes" de la CIA del 
						// siniestro cuando se supera el plazo para el envío del Informe Definitivo
					}
				} else if(caso.RecordtypeId == recordTypeIdReclamacion){

					if(caso.CAS_LKP_Recl_Orden_Trabajo__c != null){
						Workorder wo = woActualizar.get(caso.CAS_LKP_Recl_Orden_Trabajo__c);
						if(wo == null)
							wo = new WorkOrder(Id=caso.CAS_LKP_Recl_Orden_Trabajo__c);

						wo.OTR_CAS_Reclamacion_Vinculada__c = true;

						if(caso.CAS_SEL_Estado_Expediente__c == '03') {
							Workorder woOrig = mapaOTs.get(caso.CAS_LKP_Recl_Orden_Trabajo__c);
							Case casoAct = casoActualizar.get(woOrig.CaseId);
						
							if(casoAct == null)
								casoAct = new Case(Id=woOrig.CaseId);

							casoAct.CAS_CAS_Reclamacion_Vinculada__c = true;
							casoActualizar.put(casoAct.Id,casoAct);
						}

						woActualizar.put(wo.Id,wo);
					}
					//si el padre de la reclamación no es una órden de trabajo es un caso
					else if(caso.ParentId != null){
						
						if(caso.CAS_SEL_Estado_Expediente__c == '03') {
							Case casAct = casoActualizar.get(caso.ParentId);
							if(casAct == null)
								casAct = new Case(Id=caso.ParentId);
							casAct.CAS_CAS_Reclamacion_Vinculada__c = true;
							casoActualizar.put(casAct.Id,casAct);
						}
						
					}
					
					//Enviar mail en apertura reclamaciones
					mailReclamacion.add(caso);
				}
				
				
				if(caso.CAS_TXT_Num_Caso_HS__c == null){
					if(caso.RecordtypeId == recordTypeIdServB2C
					|| caso.RecordtypeId == recordTypeIdSolicitudB2C
					|| caso.RecordtypeId == recordTypeIdSolB2B_B2B2C
					|| caso.RecordtypeId == recordTypeIdServB2B){
						Case casoAct = new Case(Id=caso.Id);
						casoAct.CAS_TXT_Num_Caso_HS__c = 'B' + String.valueOf(caso.CaseNumber).leftPad(9, '0');
						casoAct.CAS_TXT_Identificador__c = Util_Identificadores.generarIdExternoCaso(caso.RecordTypeId, null, casoAct.CAS_TXT_Num_Caso_HS__c);
						actualizarIdentificadores.add(casoAct);
						system.debug('----------casoactanhkfls: '+casoAct.CAS_TXT_Num_Caso_HS__c);
					}
					else if(caso.RecordtypeId == recordTypeIdReclamacion
					|| caso.RecordtypeId == recordTypeIdSolReclamacion){
						Case casoAct = new Case(Id=caso.Id);
						casoAct.CAS_TXT_Num_Caso_HS__c = 'R' + String.valueOf(caso.CaseNumber).leftPad(9, '0');
						casoAct.CAS_TXT_Identificador__c = Util_Identificadores.generarIdExternoCaso(caso.RecordTypeId, null, casoAct.CAS_TXT_Num_Caso_HS__c);
						actualizarIdentificadores.add(casoAct);
						system.debug('----------casoactanhkfls: '+casoAct.CAS_TXT_Num_Caso_HS__c);
					}
				}
			}
			
			//Actualizar los identificadores si aplica
			system.debug('----------actualizarIdentificadores: '+actualizarIdentificadores);
			if(!actualizarIdentificadores.isEmpty()){
				Baipas.establecerVariableControl();
				update actualizarIdentificadores;
				Baipas.deshabilitarVariableControl();
			}

			if(!casoActualizar.isEmpty()) {
				system.debug('<<<<<<<<<<<<<<sera llega a casoActualizar');
				Baipas.establecerVariableControl();
				update casoActualizar.values();
				Baipas.deshabilitarVariableControl();
			}
			
			// 2.3. Generar las Órdenes de Trabajo Indemnizables (aplica a APERTURA y a CONFIRMACION) y las Órdenes de Trabajo Reparables (solo aplica a CONFIRMACION)
			List<Indemnizable_Documento__c> docsIndemInsert = Util_Indemnizables.generarDocsIndemnizables(triggerNew);
			if(!docsIndemInsert.isEmpty()){
				insert docsIndemInsert;
			}
			
			//Clic Hogar Email y actualización de Contraseña
			enviarEmail_ClicHogar(Trigger.new);

			//Enviar mail en apertura reclamaciones
			//Util_Correo_Electronico.enviarMailAperturaReclamaciones(mailReclamacion,'Reclamacion_via_email','reclamacioneshs@gmail.com');//TODO labels
		}
		else if(trigger.isUpdate){
			// Genero una OT asociada a la reclamación
			// Inserta ordenes de trabajo
			// Actualizar mapaOTs
			Util_Orden_Trabajo.crearOTparaCaso(triggerNew, triggerOldMap, mapaOTs);
			//Compruebo si se ha activado el caso y genero el siguiente caso preventivo con la fecha calculada
			// Hace query a Linea_Contrato__c
			// Inserta y actualiza casos, ordenes de trabajo, partidas de ordenes de trabajo
			Util_B2B.activacionPreventivo(triggerNew, triggerOldMap, mapaOTsPorCaso, mapaPartidasOTs);

			// Obtener hijos de siniestros mixtos
			Set<Id> setIdsMixtos = new Set<Id>();
			for (Case caso :triggerNew) {
				if (caso.Type != Label.CAS_TIPO_MIXTO) {
					setIdsMixtos.add(caso.Id);
				}
			}
			Map<Id, Case> mapaHijosPorPadre = Util_Siniestro.obtenerHijosSiniestrosMixtos(setIdsMixtos);
			
			// Mapa de casos nuevo
			Map<String, Case> mapaCasosNuevos = new Map<String, Case>();

			// [INI] Lógica cuando reclamación pasa a estado cerrado
			// ============================================================
			List<Case> listaCasosActualizar = new List<Case>();
			// PREV: Map<Id,Case> casosDescendientes = new Map<Id,CAse>([SELECT Id,ParentId,CAS_LKP_Recl_Orden_Trabajo__r.CaseId FROM Case WHERE Id IN :triggerNewMap.keySet()]);
			// NEW:
			Map<Id,Case> casosDescendientes = Util_Caso.getCaseById(triggerNewMap.keySet()) ;
			//END_NEW
			Set<Id> idPadres = new Set<Id>();
			for(Case caso : casosDescendientes.values()){
				if(caso.ParentId != null){
					idPadres.add(caso.ParentId);
				}
				if(caso.CAS_LKP_Recl_Orden_Trabajo__r.CaseId != null){
					idPadres.add(caso.CAS_LKP_Recl_Orden_Trabajo__r.CaseId);
				}
			}
			Map<Id,Case> mapaCasosPadre = new Map<Id,Case>();
			List<Case> casosHijosNoCerrados = new List<Case>();
			if(!idPadres.isEmpty()){
				system.debug('mapas: '+idPadres);
				system.debug(recordTypeIdReclamacion);
				
				//PREV: mapaCasosPadre = new Map<Id,Case>([SELECT Id,CAS_CAS_Reclamacion_Vinculada__c FROM Case WHERE Id IN :idPadres]);
				//NEW:
				//mapaCasosPadre = Util_Caso.getMapaCasosHijosByParentId(idPadres);
				mapaCasosPadre = Util_Caso.getCaseById(idPadres);
				
				casosHijosNoCerrados = Util_Caso.getMapaSiniestrosHijosNoCerrados(idPadres ,new Set<Id> {recordTypeIdReclamacion}).values();
				/* [SELECT Id,ParentId,CAS_LKP_Recl_Orden_Trabajo__r.CaseId
												FROM Case
												WHERE RecordTypeId = :recordTypeIdReclamacion
												AND Status != :Label.CAS_ESTADO_CERRADO_FACTURADO
												AND Status != :Label.CAS_ESTADO_CERRADO_PDTE_LIQUIDAR
												AND Status != :Label.CAS_ESTADO_CERRADO
												AND (ParentId IN :idPadres OR CAS_LKP_Recl_Orden_Trabajo__r.CaseId IN :idPadres)];*/
			}
			// ============================================================
			// [FIN] Lógica cuando reclamación pasa a estado cerrado
			system.debug('Condiciones de hijos:::'+mapaCasosPadre);
			for (Case caso : triggerNew){
				system.debug('Los hijos son'+casosHijosNoCerrados+' con padres '+mapaCasosPadre);
				Case casoOld = triggerOldMap.get(caso.Id);
				if(Util_Siniestro.esSiniestro(caso)){

					// 2.2. Acciones post-sondeo en APERTURA/CONFIRMACIÓN
					// Si se ha realizado el sondeo de una Solicitud de Siniestro (APERTURA) o de un Siniestro (CONFIRMACIÓN)
					// Si la Fecha de Ocurrencia No es Válida: No se genera Siniestro, se actualiza el estado a "No Abierto" desde el WS. Solo aplica en APERTURA
					// Si no: se genera Siniestro (APERTURA)
					Case casoIndemni = Util_Siniestro.postSondeo(caso, triggerOldMap, mapaHijosPorPadre, mapaCuentas);
					if(casoIndemni != null){
						mapaCasosNuevos.put(caso.Id + '_Indemni', casoIndemni);
					}   
					// Logica peritos
					listaTareasACerrar.addAll(Util_Perito.controlInformesPerito(caso, triggerOldMap, mapaTareasCaso));
					if(caso.CAS_CAS_Plazo_Envio_I_D_Superado__c){
						// TODO: Enviar correo al perito y al contacto con tipo de programa "Informes" de la CIA del 
						// siniestro cuando se supera el plazo para el envío del Informe Definitivo
					}
					// Si el estado de un caso se ha cambiado a "En Espera de confirmación por Gestor"
					if(caso.Status == Label.CAS_ESTADO_ESPERA_GESTOR_CONFIRMACION
							&& caso.Status != casoOld.Status){
						// Se genera una tarea al gestor para indicarle que continúe con la confirmación
						//Util_variablesGlobales.listaTareasGeneradas.add(Util_Tarea.crearTareaComun(caso, 'Confirmación bloqueada para el profesional'));
						Util_variablesGlobales.listaTareasGeneradas.add(Util_Tarea.crearTarea(Label.RT_TAR_COMUN, 'Confirmación bloqueada para el profesional', Label.TAR_ESTADO_EN_CURSO, Label.TAR_TIPO_LIMITE_SUPERADO, caso.OwnerId, caso.Id, caso.CAS_LKP_Compania__c));
					}
				}
				if(caso.RecordTypeID == recordTypeIdReclamacion){
					if(caso.Status != casoOld.Status){
						// Si el estado de una reclamación cambia a pendiente de cierre, se genera tarea al gestor
						if(caso.Status == Label.CAS_ESTADO_PDTE_CIERRE){
							// Se genera una tarea al gestor para indicarle que continúe con la confirmación
							//Util_variablesGlobales.listaTareasGeneradas.add(Util_Tarea.crearTarea(Label.RT_TAR_COMUN, 'Se puede confirmar con cliente para cerrar la reclamación', Label.TAR_ESTADO_EN_CURSO, null, caso.OwnerId, caso.Id, caso.CAS_LKP_Compania__c));
						}
					}
					// [INI] Lógica cuando reclamación pasa a estado cerrado
					// ============================================================
					if((caso.Status == Label.CAS_ESTADO_CERRADO_FACTURADO) || (caso.Status == Label.CAS_ESTADO_CERRADO_PDTE_LIQUIDAR)){
						Boolean desactivarCheck = true;
						Case casoDescendiente = casosDescendientes.get(caso.Id);
						for(Case casoHijo : casosHijosNoCerrados){
							if((casoDescendiente.ParentId == casoHijo.ParentId)
									|| (casoDescendiente.ParentId == casoHijo.CAS_LKP_Recl_Orden_Trabajo__r.CaseId)
									|| (casoDescendiente.CAS_LKP_Recl_Orden_Trabajo__r.CaseId == casoHijo.ParentId)
									|| (casoDescendiente.CAS_LKP_Recl_Orden_Trabajo__r.CaseId == casoHijo.CAS_LKP_Recl_Orden_Trabajo__r.CaseId)){
								desactivarCheck = false;
								break;
							}
						}
						if(desactivarCheck && !mapaCasosPadre.isEmpty()){
							Case casoPadre;
							if(mapaCasosPadre.keySet().contains(casoDescendiente.ParentId)){
								casoPadre = mapaCasosPadre.get(casoDescendiente.ParentId);
								casoPadre.CAS_CAS_Reclamacion_Vinculada__c = false;
								listaCasosActualizar.add(casoPadre);
							}
							if(mapaCasosPadre.keySet().contains(casoDescendiente.CAS_LKP_Recl_Orden_Trabajo__r.CaseId)){
								casoPadre = mapaCasosPadre.get(casoDescendiente.CAS_LKP_Recl_Orden_Trabajo__r.CaseId);
								casoPadre.CAS_CAS_Reclamacion_Vinculada__c = false;
								listaCasosActualizar.add(casoPadre);
							}
						}
					}
					// ============================================================
					// [FIN] Lógica cuando reclamación pasa a estado cerrado
					
					//Se genera tarea para el gestor cuando se marcan los checks de facturado y liquidado
					if((caso.CAS_CAS_Siniestro_Facturado__c && !casoOld.CAS_CAS_Siniestro_Facturado__c) 
					|| (caso.CAS_CAS_Liquidado__c && !casoOld.CAS_CAS_Liquidado__c)){
						
						if(caso.CAS_CAS_Siniestro_Facturado__c && caso.CAS_CAS_Liquidado__c){
							Util_variablesGlobales.listaTareasGeneradas.add(Util_tarea.crearTarea(Label.RT_TAR_COMUN, 'Cierre de la Reclamación facturada', Label.TAR_ESTADO_EN_CURSO, null, caso.OwnerId, caso.Id, caso.AccountId));
						}
						
					}
					
					//Para las reclamaciones, si para membership (?) no se encuentra al cliente dos veces al llamarlo, se genera una carta
					if(caso.CAS_SEL_Conformidad_del_Cliente_2__c == 'NO LOCALIZADO' && mapaCuentas.get(caso.CAS_LKP_Compania__c) != null && mapaCuentas.get(caso.CAS_LKP_Compania__c).CUE_TXT_Identificador__c == Label.IDE_MEMBERSHIP){
						//TODO: Esto debería pasar por util_documentacion cuando hayamos definido la carta
						ContentVersion cv = new ContentVersion();
						cv.Title = 'Carta_Membership_No_localizado_'+String.valueOf(DateTime.now().getTime());
						cv.FirstPublishLocationId = caso.Id;
						cv.PathOnClient = cv.Title;
						cv.VersionData = EncodingUtil.base64Decode('VGVzdCBjYXJ0YSBtZW1iZXJzaGlw');
						cvInsertar.add(cv);
						
					}
					
				}

				// [Adter-Update] Si se ha superado el Límite de Actuación: se bloquean las Ordenes de Trabajo
				if(caso.CAS_CAS_Supera_Limite_Actuacion__c &&
					!casoOld.CAS_CAS_Supera_Limite_Actuacion__c){
					List<Workorder> listaWO = mapaOTsPorCaso.get(caso.Id);
					if(listaWO != null){
						for(WorkOrder wo : listaWO){
							if(!Util_Orden_Trabajo.SET_ESTADOS_CERRADOS.contains(wo.Status) &&
									(!wo.OTR_CAS_Urgente__c || wo.OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c)){
								
								Workorder woAct = woActualizar.get(wo.Id);
								if(woAct == null){
									woAct = new WorkOrder(Id=wo.Id);
								}
								if(caso.Recordtypeid == recordTypeIdSini && !caso.CAS_CAS_Confirmado__c){
									woAct.Status=Label.OTR_ESTADO_EN_ESPERA_GESTOR_CONFIRMACION;
								}
								else {
									woAct.Status = Label.OTR_ESTADO_EN_ESPERA_GESTOR_INDICACIONES;
								}
								woActualizar.put(woAct.Id,woAct);
							}
						}
					}
					// Si lo ha superado el profesional se genera además una tarea al gestor:
					if(Util_Perfiles_Usuario.esProfesional(UserInfo.getProfileId())){
						Task tarea;
						if(caso.Recordtypeid == recordTypeIdSini && !caso.CAS_CAS_Confirmado__c){
							tarea = Util_tarea.crearTarea(Label.RT_TAR_COMUN, 'Siniestro en espera de confirmación', Label.TAR_ESTADO_EN_CURSO, Label.TAR_TIPO_LIMITE_SUPERADO, caso.OwnerId, caso.Id, caso.AccountId);
						}
						else {
							tarea = Util_tarea.crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_AUTORIZACION_GESTOR, Label.TAR_ESTADO_EN_CURSO, Label.TAR_TIPO_LIMITE_SUPERADO, caso.OwnerId, caso.Id, caso.AccountId);
						}
						Util_variablesGlobales.listaTareasGeneradas.add(tarea);
					}
				}
			}//FIN FOR
			
			//Actualizar polizas
			if(!mapaPolizasActualizar.isEmpty()){
				Baipas.establecerVariableControl();
				update mapaPolizasActualizar.values();
				Baipas.deshabilitarVariableControl();
			}

			// Si hay algún caso que actualizar, se le hace un update:
			if(!listaCasosActualizar.isEmpty()){
				Baipas.establecerVariableControl();
				update listaCasosActualizar;
				Baipas.deshabilitarVariableControl();
			}

			updateTaskOwner(triggerNew, triggerNewMap, triggerOldMap);

			//Map<Id, WorkOrder> mapaWODirecCambiadas = Util_Caso.heredarDireccionesCaseOT(triggerNewMap, mapaOTs,woActualizar);
			woActualizar = Util_Caso.heredarDatosCaseOT(triggerNewMap, mapaOTs, woActualizar);

			if (mapaCasosNuevos != null && (!mapaCasosNuevos.isEmpty())) {
				insert mapaCasosNuevos.values();
			}

			// 2.3. Generar las Órdenes de Trabajo Indemnizables (aplica a APERTURA y a CONFIRMACION) y las Órdenes de Trabajo Reparables (solo aplica a CONFIRMACION)
			List<Indemnizable_Documento__c> docsIndemInsert = Util_Indemnizables.generarDocsIndemnizables(triggerNew);
			if(!docsIndemInsert.isEmpty()){
				insert docsIndemInsert;
			}
			Util_variablesGlobales.faseVueltaSondeo = null;
			Util_variablesGlobales.estadoVueltaSondeo = null;

			//Invocación del servicio de Actualización en Vesta de forma asíncrona tras la anulación de un siniestro
			for (Case caso : triggerNew){
				String oldStatus = triggerOldMap.get(caso.Id).Status;
				if (Util_Siniestro.esSiniestro(caso) && caso.Status != oldStatus) {
					// Si se cambia el estado a ANULADO
					if (caso.Status == Label.CAS_ESTADO_ANULADO) {
						Integer act = Integer.valueOf(caso.CAS_NUM_Id_Actuacion_SondeoExt__c);
						Integer casoAct;
						String tipoSiniWS;
						//String cia = Util_Compania.CIA_BY_IDSF.get(caso.CAS_LKP_Compania__c).CUE_TXT_Identificador__c ;
						if (caso.Type == label.CAS_TIPO_REPARABLE || caso.Type == label.CAS_TIPO_MIXTO){
							casoAct = 3;
							tipoSiniWS = '1';
						}else if(caso.Type == label.CAS_TIPO_INDEMNIZABLE){
							casoAct = 4;
							tipoSiniWS = caso.Type;
						}else if(caso.Type == label.CAS_TIPO_COBERTURA_ADICIONAL){
							casoAct = 5;
							tipoSiniWS = caso.Type;
						}
						if (act != null && tipoSiniWS != null){
							Callout_ActualizaSiniestroVesta_RQ datos = new Callout_ActualizaSiniestroVesta_RQ(act,casoAct,null,null,tipoSiniWS,null,null,null,'2',null);
							//Serializa los datos para poder enviarlos en un String al método @future
							String datosSerializados = JSON.serialize(datos);
							//Llamada al callout de forma asíncrona
							Callout_ActualizaSiniestroVesta.updateDatosAsync(datosSerializados);
						}
					}
				}
				//Al actualizar un caso se comprueba si se ha modificado el cliente contable, para facturar al nuevo cliente contable en caso de que cambie
				if(caso.CAS_LKP_Cliente_contable__c != null && triggerOldMap.get(caso.Id).CAS_LKP_Cliente_contable__c != null){
					if(caso.CAS_LKP_Cliente_contable__c  != triggerOldMap.get(caso.Id).CAS_LKP_Cliente_contable__c ){
						Util_Facturador.calloutFacturador(mapaOTs,label.FAC_PreFactura);
						Util_Facturador.calloutFacturador(mapaOTs,label.FAC_Maestro_Clientes);
						Util_Facturador.calloutFacturador(mapaOTs,label.FAC_Maestro_Profesionales);
					}
				}
			}//FIN FOR TRIGGERNEW

			/*if (mapaWODirecCambiadas != null && (!mapaWODirecCambiadas.isEmpty())) {
				// Se actualizan las OTs que apliquen
				update mapaWODirecCambiadas.values();
			}*/
		}


		if(!woActualizar.isEmpty())
			update woActualizar.values();


		if(listaTareasACerrar != null){
			// Se cierran las tareas
			update listaTareasACerrar;
		}
		
		
		if(!cvInsertar.isEmpty())
			insert cvInsertar;
		
		// Generacion de nuevas tareas
		Util_variablesGlobales.listaTareasGeneradas.addAll(Util_Tarea.crearTareasParaCaso(triggerNew, triggerOldMap, mapaCuentas));

		// Se insertan las tareas, si se hubiera generado alguna
		insert Util_variablesGlobales.listaTareasGeneradas;

		// Se añaden movimientos
		Util_Movimientos.generaMovimientos(triggerNew, triggerOldMap, mapaCuentas);

		// Se asignan casos
		Util_AsignacionPropCaso.inicializaAsignacion(triggerNew, triggerOldMap);
	}


	public static void tratamientoBeforeDelete(List<Case> triggerOld){
		// Eliminar en cascada las órdenes de trabajo del caso
		Set<Id> setIdsCasos = new Set<Id>();
		for(Case caso : triggerOld){
			setIdsCasos.add(caso.Id);
		}
		if(!setIdsCasos.isEmpty()){
			List<WorkOrder> listaOTsEliminar = new List<WorkOrder>();
			//PREV:Map<Id, WorkOrder> mapaOTsEliminar = Util_Orden_Trabajo.queryOTBySet(new Set<ID>(), setIdsCasos, null);
			Map<Id, WorkOrder> mapaOTsEliminar = Util_Orden_Trabajo.queryMapOTByCase(setIdsCasos);
			listaOTsEliminar = mapaOTsEliminar.values();
			if (!listaOTsEliminar.isEmpty()){
				delete listaOTsEliminar;
			}
		}
	}

	public static void crearAbono(Case caso, Case casoOld, List<Workorder> otList){
		system.debug('<<<<<<<<<<sera llega a crearCaso>>>>>>>>>');
		//si se modifican los dos se hace un abono para cada uno
		//los importes serian OTR_RES_Facturar_Compania_DI__c, OTR_RES_Facturar_Cliente_DI__c
		Propuesta_de_Abono__c abono = new Propuesta_de_Abono__c();
		Propuesta_de_Abono__c abono2 = new Propuesta_de_Abono__c();
		List<Propuesta_de_Abono__c> abonoList = new List<Propuesta_de_Abono__c>();
		Id cliente;
		Decimal importe = 0;
		Decimal importeCompania = 0;
		Decimal importeCliente = 0;
		List<Id> idList = new List<Id>();
		for(WorkOrder ot: otList){
			importe += ot.OTR_RES_Total_Facturar_DI__c;
			importeCompania += ot.OTR_RES_Facturar_Compania_DI__c;
			importeCliente += ot.OTR_RES_Facturar_Cliente_DI__c;
		}
		
		if(caso.CAS_LKP_Cliente_contable_cliente__c != casoOld.CAS_LKP_Cliente_contable_cliente__c
				&& caso.CAS_LKP_Cliente_contable__c == casoOld.CAS_LKP_Cliente_contable__c && casoOld.CAS_LKP_Cliente_contable_cliente__c != null){
			
			abono.AB_LKP_Ingresar_a__c = casoOld.CAS_LKP_Cliente_contable_cliente__c;
			abono.AB_SEL_Departamento_Solicitante__c = '4';
			abono.AB_LKP_Caso__c = caso.Id;
			abono.AB_SEL_Estado__c = '02';
			abono.AB_CAS_Abono_Automatico__c = true;
			abono.AB_DIV_Importe_a_ingresar__c = importe;
			abono.AB_LKP_Cuenta__c = caso.AccountId;
			abonoList.add(abono);
		}else if(caso.CAS_LKP_Cliente_contable_cliente__c == casoOld.CAS_LKP_Cliente_contable_cliente__c
				&& caso.CAS_LKP_Cliente_contable__c != casoOld.CAS_LKP_Cliente_contable__c && casoOld.CAS_LKP_Cliente_contable__c != null){
			
			abono.AB_LKP_Ingresar_a__c = casoOld.CAS_LKP_Cliente_contable__c;
			abono.AB_SEL_Departamento_Solicitante__c = '4';
			abono.AB_LKP_Caso__c = caso.Id;
			abono.AB_SEL_Estado__c = '02';
			abono.AB_CAS_Abono_Automatico__c = true;
			abono.AB_DIV_Importe_a_ingresar__c = importe;
			abono.AB_LKP_Cuenta__c = caso.AccountId;
			abonoList.add(abono);
		}else if(caso.CAS_LKP_Cliente_contable_cliente__c != casoOld.CAS_LKP_Cliente_contable_cliente__c
				&& caso.CAS_LKP_Cliente_contable__c != casoOld.CAS_LKP_Cliente_contable__c){
			if(casoOld.CAS_LKP_Cliente_contable__c != null){
				abono.AB_LKP_Ingresar_a__c = casoOld.CAS_LKP_Cliente_contable__c;
				abono.AB_SEL_Departamento_Solicitante__c = '4';
				abono.AB_LKP_Caso__c = caso.Id;
				abono.AB_SEL_Estado__c = '02';
				abono.AB_CAS_Abono_Automatico__c = true;
				abono.AB_LKP_Cuenta__c = caso.AccountId;
				abono.AB_DIV_Importe_a_ingresar__c = importeCompania;
				abonoList.add(abono);
			}
			
			if(casoOld.CAS_LKP_Cliente_contable_cliente__c != null){
				abono2.AB_LKP_Ingresar_a__c = casoOld.CAS_LKP_Cliente_contable_cliente__c;
				abono2.AB_SEL_Departamento_Solicitante__c = '4';
				abono2.AB_LKP_Caso__c = caso.Id;
				abono2.AB_SEL_Estado__c = '02';
				abono2.AB_LKP_Cuenta__c = caso.AccountId;
				abono2.AB_CAS_Abono_Automatico__c = true;
				abono2.AB_DIV_Importe_a_ingresar__c = importeCliente;
				abonoList.add(abono2);
			}
			
			
		}
		system.debug('>>>>>abonoList: ' + abonoList);
		if(!abonoList.isEmpty()){
			insert abonoList;
			system.debug('>>>>>verListaAbonos: ' + abonoList);
			for(Propuesta_de_Abono__c ab: abonoList){
				idList.add(ab.Id);
			}
			//PREV: List<Propuesta_de_Abono__c> abonoUpList = new List<Propuesta_de_Abono__c>([SELECT Name FROM Propuesta_de_Abono__c WHERE Id IN :idList]);
				List<Propuesta_de_Abono__c> abonoUpList = Util_Abonos_Y_Eventos.getPropuestaAbonoById(new Set<Id>(idList)).values();
			for(Propuesta_de_Abono__c abo: abonoUpList){
				abo.AB_TXT_Identificador__c = abo.Name;
			}

			update abonoUpList;
		}

	}
	
	/**
	  * actualizarDatos_ClicHogar: Inicializa los campos de Usuario y contraseña cuando sucede una apertura de un Caso de ClicHogar
	  * @param triggerNew: datos del caso a actualizar en caso de que sea de Clic Hogar
	  */
	public static void actualizarDatos_ClicHogar (List<Case> triggerNew){
		
		system.debug('actualizar_Datos!  '+triggerNew);
		
		for( Case c : triggerNew) {
			
			try{
				/* PREV:
				Account compania = [ SELECT CUE_TXT_Identificador__c,Id FROM Account WHERE Id=:c.CAS_LKP_Compania__c LIMIT 1];
				*/
				//NEW
				System.debug('c.CAS_LKP_Compania__c: '+c);
				Account compania =new Account();
				for(Account cuentaAuxiliar:Util_Cuentas.getMapCuentasById(new Set<Id>{c.CAS_LKP_Compania__c} ).values()) {
					compania=cuentaAuxiliar;
				}
				
				if(!String.isEmpty(compania.Id)) {
					if(  compania.CUE_TXT_Identificador__c == Label.IDE_SEGURCAIXA || compania.CUE_TXT_Identificador__c == Label.IDE_NATIONALE_NETHERLANDEN  
						|| compania.CUE_TXT_Identificador__c == Label.IDE_PREVISORA_BILBAINA || compania.CUE_TXT_Identificador__c == Label.IDE_ALMUDENA){
			
					
					// PREV: Procedencia__c proc = [SELECT Name,Id FROM Procedencia__c WHERE Id=:c.CAS_LKP_Procedencia__c ];
					//NEW:
					Procedencia__c proc = new Procedencia__c();
					for(Procedencia__c procedenciaAux:Util_Procedencia.queryProcedencia(new Set<Id>{c.CAS_LKP_Procedencia__c}).values()) {
						proc =procedenciaAux;
					}
					
					if(c.CAS_LKP_Compania__c != null && c.CAS_LKP_Procedencia__c != null && c.CAS_TXT_Num_Caso_HS__c != null && c.CAS_EMA_Email__c != null ) {
							
							 
					c.CAS_TXT_Usuario_Clic_Hogar__c = proc.Name + c.CAS_TXT_Num_Caso_HS__c ;
					//c.CAS_TXT_Password_Clic_Hogar__c =  c.Id; 
								
								system.debug('DATOS CLIC HOGAR ACTUALIZADOS!  '+triggerNew);
								
							}
						}
				}
			} //End try
						catch(Exception e){
							system.debug('Fin: error: e!  '+e);
							System.debug(e.getMessage());
							//System.debug('Error en actualizarDatos_ClicHogar');
						}
					}
			system.debug('Fin: actualizar_Datos!  '+triggerNew);
		}
		
	
	
	/**
	  * enviarEmail_ClicHogar: Envía los emails de apertura y credenciales a los clientes de ClicHogar informándoles de cómo acceder al 
	  *	 portal ClicHogar
	  * @param triggerNew: datos del caso a actualizar en caso de que sea de Clic Hogar
	  */
	public static void enviarEmail_ClicHogar (List<Case> triggerNew){
	
		system.debug('se ejecuta enviarEmail_ClicHogar: CaseInfo:'+triggerNew);
		
		
		for( Case c : triggerNew) {
			
			if(c.CAS_TXT_Usuario_Clic_Hogar__c == null ||c.CAS_TXT_Usuario_Clic_Hogar__c == ''/*|| c.CAS_TXT_Password_Clic_Hogar__c==null || c.CAS_TXT_Password_Clic_Hogar__c==''*/){
				system.debug('No es de ClichHogar');
				return ;
			}
			//PREV: Case nuevaInstanciaCaso = [SELECT Id, CAS_TXT_Password_Clic_Hogar__c FROM Case WHERE Id =: c.Id ];
			//NEW:
			Case nuevaInstanciaCaso = Util_Caso.getCaseById(new Set<Id>{c.Id}).values() ;
			//END_NEW
			nuevaInstanciaCaso.CAS_TXT_Password_Clic_Hogar__c =  c.Id;  
			update nuevaInstanciaCaso;
			
			//PREV:
			//Account compania = [ SELECT CUE_TXT_Identificador__c,Id FROM Account WHERE Id=:c.CAS_LKP_Compania__c LIMIT 1];
			//Procedencia__c proc = [SELECT Name,Id FROM Procedencia__c WHERE Id=:c.CAS_LKP_Procedencia__c ];
			//ServiceContract poliza = [SELECT  Id, Account.CUE_EMA_Email__c FROM ServiceContract WHERE Id= :c.CAS_LKP_PolizaContrato__c];
			//NEW:
			Account compania = Util_Cuentas.getMapCuentasById(new Set<Id>{c.CAS_LKP_Compania__c}).values();
			Procedencia__c proc = Util_Procedencia.queryProcedencia(new Set<Id>  {c.CAS_LKP_Procedencia__c}).values();   
			ServiceContract poliza = Util_Poliza_Contrato.queryPolizaById(new Set<Id>{c.CAS_LKP_PolizaContrato__c}).values();
			
			system.debug('EMAIL DESTINO: '+poliza.Account.CUE_EMA_Email__c);
			
			try{
				
			if(c.CAS_LKP_Compania__c != null && c.CAS_LKP_Procedencia__c != null && c.CAS_TXT_Num_Caso_HS__c != null && c.CAS_EMA_Email__c != null 
			 && ( compania.CUE_TXT_Identificador__c == Label.IDE_SEGURCAIXA || compania.CUE_TXT_Identificador__c == Label.IDE_NATIONALE_NETHERLANDEN 
				|| compania.CUE_TXT_Identificador__c == Label.IDE_PREVISORA_BILBAINA || compania.CUE_TXT_Identificador__c == Label.IDE_ALMUDENA)) {
			
			
				String template_Label_Apertura  ;
				String template_label_Credenciales = null;
			
				if(compania.CUE_TXT_Identificador__c == Label.IDE_SEGURCAIXA){
					template_Label_Apertura = 'Apertura_Siniestro_Segurcaixa' ;
					template_label_Credenciales = 'Credenciales_Segurcaixa_ClicHogar';
				}
				else if(compania.CUE_TXT_Identificador__c == Label.IDE_NATIONALE_NETHERLANDEN){
					template_Label_Apertura = 'Apertura_Siniestro_National_Netherlanden' ;
				}
				else if(compania.CUE_TXT_Identificador__c == Label.IDE_PREVISORA_BILBAINA){
					template_Label_Apertura = 'Apertura_Siniestro_Previsora' ;
				}
				else if(compania.CUE_TXT_Identificador__c == Label.IDE_ALMUDENA){
					template_Label_Apertura = 'Apertura_Siniestro_Almudena' ;
				}
		
				//PREV:  EmailTemplate templateApertura = [SELECT Id, Body, Subject FROM EmailTemplate WHERE DeveloperName = :template_Label_Apertura LIMIT 1];
				//NEW:
				EmailTemplate templateApertura = Util_Correo_Electronico.getEmailTemplateByDevName(new Set<String>{template_Label_Apertura}).values();
				
				
				//Obtenemos el correo de origen que qeremos usar
				//PREV: OrgWideEmailAddress sourceEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'homeservecrm@gmail.com' LIMIT 1];
				OrgWideEmailAddress sourceEmail = Util_Correo_Electronico.getOWEmailAddressByAddress(new Set <String> {'homeservecrm@gmail.com'}).values().get(0);
				
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setOrgWideEmailAddressId(sourceEmail.Id);
				
				mail.setTemplateId(templateApertura.Id);//Id de la Template asociada
				mail.setSaveAsActivity(false);
				
				mail.setTargetObjectId(c.ContactId);//Id del contacto o usuario destinatario
				mail.setWhatId(c.Id);  //Id del sObject del que se extraen los campos dinámicos
				
				
				mail.setToAddresses(new list<string>{poliza.Account.CUE_EMA_Email__c});
				
				//Enviamos el email de Apertura
				Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
				
				system.debug('EMAIL APERTURA ENVIADO!  '+triggerNew);   
				
				//Si existe, enviamos el email de credenciales
				if(template_label_Credenciales != null){
					
					//Obtenemos el email de Credenciales
					//PREV: EmailTemplate templateCredenciales = [SELECT Id, Body, Subject FROM EmailTemplate WHERE DeveloperName = :template_label_Credenciales LIMIT 1];
					//NEW: 
					EmailTemplate templateCredenciales = Util_Correo_Electronico.getEmailTemplateByDevName(new Set<String>{template_label_Credenciales}).values(); 
					
					//Creamos el email de credenciales
					mail = new Messaging.SingleEmailMessage();
					mail.setTemplateId(templateCredenciales.Id);
					mail.setOrgWideEmailAddressId(sourceEmail.Id);
					mail.setSaveAsActivity(false);
					
					
					if(c.ContactId!=null){
						mail.setTargetObjectId(c.ContactId);//Contact  c.Contact.Id
					}
					else{
						mail.setTargetObjectId(c.AccountId);//Contact  c.Contact.Id
					}
					
					mail.setWhatId(c.Id);  //Case c.Id
					
					mail.setToAddresses(new list<string>{poliza.Account.CUE_EMA_Email__c});
		
					//Enviamos el email de Apertura
					 resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
				}
				
			}
			
			} //End try
			catch(Exception e){
				System.debug(e.getMessage());
				System.debug('Error en enviarEmail_ClicHogar!');
			}
		}	
	}
}