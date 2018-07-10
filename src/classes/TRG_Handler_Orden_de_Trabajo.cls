/**
 * Handler del Trigger TRG_Orden_de_Trabajo.
 * 
 * @author EVERIS
 */
public without sharing class TRG_Handler_Orden_de_Trabajo {
	private static Set<Id> setIdsOTsAnuladas;
	private static Map<Id, Case> mapaCasos;
	private static Map<Id, ServiceResource> mapaProfesionales;
	private static Map<Id, List<Propuesta_de_Evento__c>> todosEventosCaso;
	private static Map<Id, List<Propuesta_de_Abono__c>> todosAbonosCaso;
	private static Map<Id, List<ServiceAppointment>> mapaCitasOTs;

	private static Map<Id, Case> mapaCasosUpdate;
	private static Map<Id, ServiceResource> mapaProfesionalesUpdate;
	private static List<Task> listaTareasInsert;
	private static Map<Id, Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> mapaDLCUpdate;

	private static final Id recordTypeIdReclamacion = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);
	private static final Id recordTypeIdReparable = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA);
	private static final Id recordTypeIdSolicitudB2C = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2C);
	private static final Id recordTypeIdServB2C = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C);
	private static final Id recordTypeIdSolicitudB2B = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOLIC_B2B_B2B2C);
	private static final Id recordTypeIdServB2B = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C);
	private static final Id recordTypeIdEnRevision = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION);

	/**
	  * Tratamiento para el caso before del trigger.
	  * 
	  * @param triggerNewMap: mapa de registros nuevos del objeto WorkOrder a partir del Id
	  * @param triggerNew: lista de registros nuevos del objeto WorkOrder
	  * @param triggerOldMap: mapa de registros antiguos del objeto WorkOrder a partir del Id
	  * @param triggerOld: lista de registros antiguos del objeto WorkOrder
	  */
	public static void tratamientoBefore(Map<Id, WorkOrder> triggerNewMap, List<WorkOrder> triggerNew, 
			Map<Id, WorkOrder> triggerOldMap, List<WorkOrder> triggerOld){
		system.debug('>>>>>>>>>TRATAMIENTO BEFORE');
		// Variables globales de la clase
		setIdsOTsAnuladas = new Set<Id>();
		if(mapaCasosUpdate == null){
			mapaCasosUpdate = new Map<Id, Case>();
		}
		mapaDLCUpdate = new Map<Id, Direcciones_B2B_B2B2C_Lineas_de_Contrato__c>();
		listaTareasInsert = new List<Task>();
		Map<Id,List<WorkorderLineItem>> mapaWOLIFull = new Map<Id,List<WorkorderLineItem>>();
		Map<String,WorkType> mapaGremiosWTTextoManual = new Map<String,WorkType>();
		if(Trigger.isUpdate){
			mapaWOLIFull = Util_Orden_Trabajo.getMapaPartidasOTsFull(triggerNewMap.keySet());
		}
		if(Trigger.isInsert){
			mapaGremiosWTTextoManual = Util_Orden_Trabajo.getMapaGremiosTipoTrabajoTextoManual();
		}

		if(Trigger.isInsert || Trigger.isUpdate){
			// Crear set de Ids de Orden de Trabajo
			Set<Id> setIdsWo = new Set<Id>();
			for(WorkOrder wo: triggerNew){
				if(wo.Id != null){
					setIdsWo.add(wo.Id);
				}
			}
			// Crear Mapa con todas las citas no anuladas de las OTs actualizadas del Trigger
			mapaCitasOTs = Util_Cita_Servicio.getMapCitasOTsNotInStatus(setIdsWo, Util_Cita_Servicio.SET_ESTADOS_ANULADOS);

			Set<Id> setIdsCasos = new Set<Id>();
			Set<Id> setIdsTiposTrabajo = new Set<Id>();
			Set<String> setExtIdsDLC = new Set<String>();
			Set<Id> setIdsOTsCerradas = new Set<Id>();
			Set<Id> setIdsProfesionales = new Set<Id>();

			// Obtener Política de Asignación Mizad y Geolocalizacion - Primario
			FSL__Scheduling_Policy__c politicaAsignMizad;
			FSL__Scheduling_Policy__c politicaGeoPrimario;
			FSL__Scheduling_Policy__c politicaGeo;
			List<FSL__Scheduling_Policy__c> politicas = Util_Orden_Trabajo.getPoliticasFLS();
			if(!politicas.isEmpty()){
				for(FSL__Scheduling_Policy__c pol : politicas){
					/*if(pol.Name == Label.OT_POLITICA_PROGRAMACION_MIZAD_URGENTE){
						politicaAsignMizad = pol;
					}else*/ if(pol.Name == 'Política de Asignación – Geolocalización - Primario'){
						politicaGeoPrimario = pol;
					}else if(pol.Name == 'Política de Asignación – Geolocalización'){
						politicaGeo = pol;
					}
				}
			}

			// Recoge los metadatos que cumplen con esta condición de configuración Mizad
			List<Orden_de_trabajo__mdt> listaMetadatosOt = Util_Orden_Trabajo.getMetadatosOt('Conf_Mizad');

			if(triggerNew != null){
				for(WorkOrder wo : triggerNew){
					WorkOrder woOld;
					if(triggerOldMap != null){
						woOld = triggerOldMap.get(wo.Id);
					}

					// Crear un conjunto con los Ids de Casos de las OTs insertadas/actualizadas
					if(wo.CaseId != null){
						setIdsCasos.add(wo.CaseId);
					}

					// Crear un conjunto con los Ids de Tipos de Trabajo de las OTs insertadas/actualizadas
					if(wo.WorkTypeId != null){
						setIdsTiposTrabajo.add(wo.WorkTypeId);
					}

					// Crear un conjunto con los Ids de las direcciones-líneasContrato nuevas y antiguas
					if(wo.OTR_LKP_Linea_Contrato__c != null){
						setExtIdsDLC.add(wo.AccountId + '_' + wo.OTR_LKP_Linea_Contrato__c);
					}
					if(woOld != null && woOld.OTR_LKP_Linea_Contrato__c != null &&
							woOld.OTR_LKP_Linea_Contrato__c != wo.OTR_LKP_Linea_Contrato__c){
						setExtIdsDLC.add(woOld.AccountId + '_' + woOld.OTR_LKP_Linea_Contrato__c);
					}

					// Crear un conjunto con Ids de las OTs cuyo estado ha sido actualizado a ANULADO o CERRADO
					if(Trigger.isUpdate && woOld != null && woOld.Status != wo.Status){
						if((wo.Status == Label.OTR_ESTADO_ANULADO || wo.Status == Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO)){
							setIdsOTsAnuladas.add(wo.Id);
						}
						else if(wo.Status == Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO){
							setIdsOTsCerradas.add(wo.Id);
						}
					}
					
					if(wo.OTR_LKP_Recurso_Servicio__c != null){
						setIdsProfesionales.add(wo.OTR_LKP_Recurso_Servicio__c);
					}
					if(woOld != null && woOld.OTR_LKP_Recurso_Servicio__c != null){
						setIdsProfesionales.add(woOld.OTR_LKP_Recurso_Servicio__c);
					}
					
					
				} //FIN for(WorkOrder wo : triggerNew)

				system.debug('>>>>>>setIdsProfesionales: ' + setIdsProfesionales);
				//Cargar el mapa de profesionales
				if(!setIdsProfesionales.isEmpty()){
                    mapaProfesionales = Util_Service_Resource.queryMapSRByRsIds(setIdsProfesionales);
                    /*mapaProfesionales = new Map<Id, ServiceResource>(
						[SELECT Id,
								RSE_NUM_Numero_Ordenes_Trabajo_En_Curso__c,
								RSE_NUM_NumOT_Mensual_Con_Sin_Franquicia__c,
								RSE_FOR_Categoria_del_profesional__c,
								RSE_LKP_Cuenta__c,
								RSE_LKP_Cuenta__r.CUE_SEL_Bloqueo_Eventos__c,
								RSE_LKP_Cuenta__r.CUE_CAS_Confianza_en_la_red__c,
                                RSE_LKP_Cuenta__r.CUE_TXT_Aviso_Auditoria__c
								
						 FROM ServiceResource
                         WHERE Id IN :setIdsProfesionales]);*/
				}



				// Crear un mapa con los casos asociados al conjunto con los Ids de Casos
				// de las OTs insertadas/actualizadas
                mapaCasos = Util_Caso.getCaseById(setIdsCasos);
                //mapaCasos = Util_Caso.getMapaCasos(setIdsCasos);


				// Cargar mapa con los Territorios de Servicio
				Set<String> postales = new Set<String>();
				for(WorkOrder wo : triggerNew){
					Case caso = mapaCasos.get(wo.CaseId);
					if(caso != null){
						postales.add(caso.CAS_TXT_DirRiesgo_CP__c);
					}
				}

                //Siniestros- Cambiar el estado de la wo 'En espera de Gestor por Confirmación', 
                //si es límite de tramitación expréss está supertado y el Siniestro este confirmado o no.
                for(WorkOrder wo:triggerNew) {
                    if(wo.OTR_CAS_Lim_Tramitacion_Expres_Superado__c) {
                        Case caso =mapaCasos.get(wo.CaseId);
                        if(caso.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO)) {
                            if(caso.CAS_CAS_Confirmado__c) {
                                wo.Status=Label.OTR_ESTADO_EN_ESPERA_GESTOR_INDICACIONES;
                            } else {
                                wo.Status=Label.OTR_ESTADO_EN_ESPERA_GESTOR_CONFIRMACION;
                            }
                        }
                    }
                }


				Map<String, ServiceTerritory> mapaTerrActPorCP = Util_TerritorioServicio.getMapaTerrActPorCP(postales);


				// Crear un mapa con los tipos de trabajo asociados al conjunto con los Ids de Tipos de Trabajo
				// de las OTs insertadas/actualizadas
				Map<Id, WorkType> mapaTiposTrab = Util_Orden_Trabajo.getMapaTiposTrabajo(setIdsTiposTrabajo);


				// Crear un mapa que contiene los objetos direcciones-líneaContrato de aquellas OTs
				// en las que se ha actualizado la Línea de Contrato
				Map<String, Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> mapaDLC = Util_B2B.getMapaDLC(setExtIdsDLC);


				for(WorkOrder wo : triggerNew){
					WorkOrder woOld = null;
					Case caso = mapaCasos.get(wo.CaseId);
					if(triggerOldMap != null){
						woOld = triggerOldMap.get(wo.Id);
					}

					// Obtener la cita abierta actual de la OT y su recurso asignado
					ServiceAppointment citaActual = null;
					List<ServiceAppointment> citasActuales = mapaCitasOTs.get(wo.Id);
					if(citasActuales != null && !citasActuales.isEmpty()){
						for(ServiceAppointment sa: citasActuales){
							if(sa.Status != Label.CIT_ESTADO_COMPLETADA){
								citaActual = sa;
								break;
							}
						}
					}
					AssignedResource recursoCitaActual = null;
					if(citaActual != null && citaActual.ServiceResources != null && !citaActual.ServiceResources.isEmpty()){
						recursoCitaActual = citaActual.ServiceResources[0];
					}


					// [Before-Update] CONCATENAR EN UN CAMPO LOS CODIGOS DE BAREMO DE LAS PARTIDAS
					system.debug('[Before-Update] CONCATENAR EN UN CAMPO LOS CODIGOS DE BAREMO DE LAS PARTIDAS');
					if(Trigger.isUpdate && mapaWOLIFull != null){
						List<WorkOrderLineItem> wolis = mapaWOLIFull.get(wo.Id);
						wo.OTR_TXT_Codigo_de_baremo__c = '';
						if(wolis != null){
							List<String> codBaremos = new List<String>();
							for(Workorderlineitem woli: wolis){
								if(!codBaremos.contains(woli.PAR_TXT_Baremo_Codigo__c)){
									codBaremos.add(woli.PAR_TXT_Baremo_Codigo__c);
								}
							}
							codBaremos.sort();
							for(String cod: codBaremos)
								wo.OTR_TXT_Codigo_de_baremo__c += cod + ',';
								
							wo.OTR_TXT_Codigo_de_baremo__c = wo.OTR_TXT_Codigo_de_baremo__c.removeEnd(',');
						}
					}//FIN: [Before-Update] CONCATENAR EN UN CAMPO LOS CODIGOS DE BAREMO DE LAS PARTIDAS


					// [Before-InsertUpdate] ACCIONES TRAS CAMBIAR EL RECURSO ASIGNADO A LA OT
					if(Trigger.isInsert || (woOld != null && wo.OTR_LKP_Recurso_Servicio__c != woOld.OTR_LKP_Recurso_Servicio__c)){
						// Si se ha establecido el recurso de forma manual sobre la OT (el cambio no tiene origen en la cita)
						if(wo.OTR_LKP_Recurso_Servicio__c != null &&
						  (recursoCitaActual == null || wo.OTR_LKP_Recurso_Servicio__c != recursoCitaActual.ServiceResourceId)){
							// Control para no reasignar el recurso actual de forma manual
							if(recursoCitaActual != null){
								wo.addError(Label.ERROR_REASIGNAR_PROF_OT);
							}
							// Control para no actualizar el recurso actual de forma manual si la cita no está en estado "Pdte. Asignar Manual"
							else if(!Test.isRunningTest() && (citaActual == null || citaActual.Status != Label.CIT_ESTADO_PTE_ASIGNAR_MANUAL)){
								wo.addError(Label.ERROR_OT_ASIG_MANUAL_PROF);
							}
						}
						if(wo.OTR_LKP_Recurso_Servicio__c == null){
							wo.OTR_SEL_Categoria_del_profesional__c = null;
							wo.OTR_SEL_Bloqueo_Eventos__c = null;
							wo.OTR_SEL_Procedencias_bloqueadas__c = null;
							wo.OTR_SEL_Eventos_bloqueados_Proc__c = null;
							wo.OTR_SEL_Tipo_de_red_prof__c = null;
							wo.OTR_CAS_Confianza_en_la_red__c = false;
							wo.OTR_TXT_Aviso_Auditoria__c = null;
						}
						else {
							ServiceResource profesional = mapaProfesionales.get(wo.OTR_LKP_Recurso_Servicio__c);
							Boolean establecerParametrosPR = false;
							if(profesional != null){
								wo.OTR_SEL_Categoria_del_profesional__c = profesional.RSE_FOR_Categoria_del_profesional__c;
								if(profesional.RSE_LKP_Cuenta__c != null){
									wo.OTR_SEL_Bloqueo_Eventos__c = profesional.RSE_LKP_Cuenta__r.CUE_SEL_Bloqueo_Eventos__c;	
									wo.OTR_SEL_Procedencias_bloqueadas__c = profesional.RSE_LKP_Cuenta__r.CUE_SEL_Procedencias_bloq__c;
									wo.OTR_SEL_Eventos_bloqueados_Proc__c = profesional.RSE_LKP_Cuenta__r.CUE_SEL_Eventos_bloqueados_Proc__c;
									wo.OTR_SEL_Tipo_de_red_prof__c = profesional.RSE_LKP_Cuenta__r.CUE_SEL_Tipo_de_red__c;
									wo.OTR_CAS_Confianza_en_la_red__c = mapaProfesionales.get(wo.OTR_LKP_Recurso_Servicio__c).RSE_LKP_Cuenta__r.CUE_CAS_Confianza_en_la_red__c;
									wo.OTR_TXT_Aviso_Auditoria__c = mapaProfesionales.get(wo.OTR_LKP_Recurso_Servicio__c).RSE_LKP_Cuenta__r.CUE_TXT_Aviso_Auditoria__c;
									establecerParametrosPR = true;
								}
							}
							if(!establecerParametrosPR){
								wo.OTR_SEL_Bloqueo_Eventos__c = null;							
								wo.OTR_SEL_Procedencias_bloqueadas__c = null;
								wo.OTR_SEL_Eventos_bloqueados_Proc__c = null;
								wo.OTR_SEL_Tipo_de_red_prof__c = null;
								wo.OTR_CAS_Confianza_en_la_red__c = false;
								wo.OTR_TXT_Aviso_Auditoria__c = null;
							}
						}
					}//FIN: [Before-InsertUpdate] ACCIONES TRAS CAMBIAR EL RECURSO ASIGNADO A LA OT


					// [Before-InsertUpdate] ESTABLECER TIPOLOGIA DE SERVICIO EN FUNCIÓN DE LA PROCEDENCIA DEL CASO
					system.debug('[Before-Update] ESTABLECER TIPOLOGIA DE SERVICIO EN FUNCIÓN DE LA PROCEDENCIA DEL CASO');
					if(wo.OTR_SEL_Tipologia_de_Servicio__c == null && wo.CaseId != null && caso.CAS_LKP_Procedencia__c != null){
						wo.OTR_SEL_Tipologia_de_Servicio__c = caso.CAS_LKP_Procedencia__r.PROC_SEL_Tipologia_Servicio__c; 
					}//FIN: [Before-InsertUpdate] ESTABLECER TIPOLOGIA DE SERVICIO EN FUNCIÓN DE LA PROCEDENCIA DEL CASO


					// [Before-InsertUpdate] ESTABLECER TIPO DE TRABAJO POR DEFECTO "TEXTO MANUAL" DEL GREMIO
					system.debug('[Before-InsertUpdate] ESTABLECER TIPO DE TRABAJO POR DEFECTO "TEXTO MANUAL" DEL GREMIO');
					// Si el tipo de trabajo es nulo: se asigna un tipo de trabajo por defecto
					if(wo.WorkTypeId == null && mapaGremiosWTTextoManual != null &&
					  !mapaGremiosWTTextoManual.isEmpty()){
						WorkType wt = mapaGremiosWTTextoManual.get(wo.OTR_SEL_Gremio__c);
						if(wt != null){
							wo.WorkTypeId = wt.Id;
							mapaTiposTrab.put(wt.Id, wt);
						}
					}//FIN: [Before-InsertUpdate] ESTABLECER TIPO DE TRABAJO POR DEFECTO "TEXTO MANUAL" DEL GREMIO


					// [Before-Update] ESTABLECER USUARIO DEL CASO
                    /*system.debug('[Before-Update] ESTABLECER USUARIO DEL CASO');
					if(Trigger.isUpdate && caso != null && wo.OwnerId != caso.OwnerId &&
						(!Util_Orden_Trabajo.SET_ESTADOS_CERRADOS.contains(wo.Status)) &&
						((String) caso.OwnerId).startsWith(Schema.SObjectType.User.getKeyPrefix())){
						wo.OwnerId = caso.OwnerId;
                    }*///FIN: [Before-Update] ESTABLECER USUARIO DEL CASO


					// [Before-InsertUpdate] ACCIONES TRAS ESTABLECER/ACTUALIZAR EL CASO PADRE
					system.debug('[Before-InsertUpdate] ACCIONES TRAS ESTABLECER/ACTUALIZAR EL CASO PADRE');
					if(caso != null && ((woOld == null && wo.caseId != null) ||
							(woOld != null && wo.caseId != woOld.caseId))){
						system.debug('>>>>>>>>>>>>ACCIONES TRAS ESTABLECER/ACTUALIZAR EL CASO PADRE');
						wo.AccountId = caso.AccountId;
						wo.Street = caso.CAS_TXT_Direccion__c;
						wo.PostalCode = caso.CAS_TXT_DirRiesgo_CP__c;
						wo.City = caso.CAS_TXT_DirRiesgo_Poblacion__c;
						wo.State = Util_Listas_Seleccion.getLabelDesdeAPI('Case', 'CAS_SEL_DirRiesgo_Estado_Provincia__c').get(caso.CAS_SEL_DirRiesgo_Estado_Provincia__c);
						wo.Country = caso.CAS_TXT_DirRiesgo_Pais__c;
						ServiceTerritory territorio = mapaTerrActPorCP.get(wo.PostalCode);
						if(territorio != null){
							if(territorio.ParentTerritoryId != null){
								wo.ServiceTerritoryId = territorio.ParentTerritoryId;
							}
							else {
								wo.ServiceTerritoryId = territorio.Id;
							}
						}
					}//FIN: [Before-InsertUpdate] ACCIONES TRAS ESTABLECER/ACTUALIZAR EL CASO PADRE


					// [Before-InsertUpdate] ACCIONES TRAS ACTUALIZAR LA LINEA DE CONTRATO EN OTs REPARABLES
					system.debug('[Before-InsertUpdate] ACCIONES TRAS ACTUALIZAR LA LINEA DE CONTRATO EN OTs REPARABLES');
					if((woOld == null && wo.OTR_LKP_Linea_Contrato__c != null) ||
							(woOld != null && wo.OTR_LKP_Linea_Contrato__c != woOld.OTR_LKP_Linea_Contrato__c)){
						system.debug('>>>>>>>>>>>>ACCIONES TRAS ACTUALIZAR LA LINEA DE CONTRATO EN OTs REPARABLES');
						Boolean errorSaldo = false;
						// Si se ha vinculado una Línea de Contrato:
						if(wo.OTR_LKP_Linea_Contrato__c != null){
							String idDLCnew = wo.AccountId + '_' + wo.OTR_LKP_Linea_Contrato__c;
							system.debug('idDLC-->'+idDLCnew);
							Integer restantes = -1;
							if(mapaDLC.get(idDLCnew) != null){
								Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dlcUpdate = mapaDLC.get(idDLCnew);
								if(mapaDLCUpdate.get(dlcUpdate.Id) != null){
									dlcUpdate = mapaDLCUpdate.get(dlcUpdate.Id);
								}
								if(dlcUpdate.DLC_NUM_Servicios_restantes__c != null && dlcUpdate.DLC_FOR_Linea_Contrato_LimServ__c != null){
									restantes = Integer.valueOf(dlcUpdate.DLC_NUM_Servicios_restantes__c);
									System.debug('Restantes-->'+restantes);
								}
								// Si la línea de contrato tiene saldo y el saldo actual es 0: devolvemos el error correspondiente
								if(restantes == 0){
									errorSaldo = true;
									wo.addError(Label.ERROR_SALDO_SERV_AGOTADO);
								}
								// Si la línea de contrato tiene saldo y el saldo actual es > 0: decrementar el saldo y
								// guardar el identificador de la dir-lineaC
								else if(restantes > 0){
									restantes--;
									dlcUpdate.DLC_NUM_Servicios_restantes__c = restantes;
									mapaDLCUpdate.put(dlcUpdate.Id, dlcUpdate);
									wo.OTR_TXT_Identificador_DLC__c = wo.AccountId + '_' + wo.OTR_LKP_Linea_Contrato__c;						
								}
							}
						}
						else {
							wo.OTR_TXT_Identificador_DLC__c = null;
						}
						// Si se ha desvinculado una Línea de Contrato
						if(!errorSaldo && woOld != null && woOld.OTR_LKP_Linea_Contrato__c != null){
							String idDLCold = woOld.AccountId + '_' + woOld.OTR_LKP_Linea_Contrato__c;
							if(mapaDLC.get(idDLCold) != null){
								Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dlcUpdate = mapaDLC.get(idDLCold);
								if(mapaDLCUpdate.get(dlcUpdate.Id) != null){
									dlcUpdate = mapaDLCUpdate.get(dlcUpdate.Id);
								}
								if(dlcUpdate.DLC_NUM_Servicios_restantes__c != null && dlcUpdate.DLC_FOR_Linea_Contrato_LimServ__c != null){
									Integer restantes = Integer.valueOf(dlcUpdate.DLC_NUM_Servicios_restantes__c);
									restantes++;
									// Incrementar el saldo si no supera el límite de la Línea de Contrato
									if(restantes <= Integer.valueOf(dlcUpdate.DLC_FOR_Linea_Contrato_LimServ__c)){
										dlcUpdate.DLC_NUM_Servicios_restantes__c = restantes;
										mapaDLCUpdate.put(dlcUpdate.Id, dlcUpdate);
									}
								}
							}
						}
					}//FIN: [Before-InsertUpdate] ACCIONES TRAS ACTUALIZAR LA LINEA DE CONTRATO EN OTs REPARABLES


					// [Before-Update] ACCIONES TRAS CAMBIO DE ESTADO
					system.debug('[Before-Update] ACCIONES TRAS CAMBIO DE ESTADO');
					if(Trigger.isUpdate && woOld != null && woOld.Status != wo.Status){
						system.debug('>>>>>>>>>>>>ACCIONES TRAS CAMBIO DE ESTADO');
						system.debug('>>>>>>>>>>>>woOld.Status: ' + woOld.Status);
						system.debug('>>>>>>>>>>>>wo.Status: ' + wo.Status);

										
						//Se blanquea la fecha de despertar para anular flujos de trabajo de generación de tareas
						if(wo.OTR_DAT_Fecha_Despertar__c == woOld.OTR_DAT_Fecha_Despertar__c){
							wo.OTR_DAT_Fecha_Despertar__c = null;
						}
						
						// Guardar el estado anterior si el estado anterior no es: EN ESPERA DE GESTOR POR INDICACIONES
						if(woOld.Status != Label.OTR_ESTADO_EN_ESPERA_GESTOR_INDICACIONES){
							wo.OTR_TXT_Estado_Anterior__c = woOld.Status;
						}

						// Si el gestor deshace una anulación por parte de un profesional: blanqueamos el motivo de anulación
						if(woOld.Status == Label.OTR_ESTADO_ANULADO_POR_PROF &&
						   wo.Status != Label.OTR_ESTADO_ANULADO && wo.Status != Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO){
							wo.OTR_SEL_Motivo_Anulacion__c = null;
						}
	
						// Si se ha actualizado el estado a ANULADO: 
						if(wo.Status == Label.OTR_ESTADO_ANULADO || wo.Status == Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO){
							system.debug('>>>>>>>>>>>>Si se ha actualizado el estado a ANULADO');
							wo.OTR_CAS_Servicio_Anulado__c = true;
							wo.OTR_DAT_Fecha_Anulacion__c = Datetime.Now();

							// Blanquear la primera cita
							wo.OTR_DAT_Fecha_Primera_Cita__c = null;
							wo.OTR_TXT_Rango_Primera_Cita__c = null;
							wo.OTR_SEL_Rango_Primera_Cita__c = null;
							wo.OTR_LKP_Primera_Cita__c = null;
							system.debug('>>>>>>>>>>>>Primera cita blanqueada');

							// Incrementar el saldo que previamente se consumió 
							if(wo.OTR_LKP_Linea_Contrato__c != null){
								String idDLC = wo.AccountId + '_' + wo.OTR_LKP_Linea_Contrato__c;
								if(mapaDLC.get(idDLC) != null && mapaDLC.get(idDLC).DLC_NUM_Servicios_restantes__c != null){
									Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dlcUpdate = mapaDLC.get(idDLC);
									if(mapaDLCUpdate.get(dlcUpdate.Id) != null){
										dlcUpdate = mapaDLCUpdate.get(dlcUpdate.Id);
									}
									Integer restantes = Integer.valueOf(dlcUpdate.DLC_NUM_Servicios_restantes__c);
									restantes++;
									// Si no supera el límite de la Línea de Contrato
									if(restantes <= Integer.valueOf(dlcUpdate.DLC_FOR_Linea_Contrato_LimServ__c)){
										dlcUpdate.DLC_NUM_Servicios_restantes__c = restantes;  
										mapaDLCUpdate.put(dlcUpdate.Id, dlcUpdate); 
									}
								}
							}
						}
						// Si se ha actualizado el estado a CERRADO ALBARAN RECIBIDO / CERRADO_PENDIENTE_ALBARAN:
						else if(wo.Status == Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO ||
								wo.Status == Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN){
							if((!wo.OTR_CAS_Cierre_Tecnico__c) || wo.OTR_DAT_Fecha_Cierre_servicio__c == null){
								// Se pone la fecha de cierre de servicio
								wo.OTR_CAS_Cierre_Tecnico__c = true;
								wo.OTR_DAT_Fecha_Cierre_servicio__c = Datetime.Now();
							}
							if(wo.Status == Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO){
								wo.OTR_DAT_Fecha_Recepcion_Albaran__c = Date.today();
							}
						}
						// Si se ha actualizado el estado a REVISADO:
						else if(wo.Status == LABEL.OTR_ESTADO_REVISADO){
							wo.OTR_CAS_Servicio_Revisado__c = true;
							Datetime ahora = Datetime.Now();
							wo.OTR_DAT_Fecha_revision__c = ahora.date();
							wo.OTR_HOR_Hora_de_revision__c = ahora.time();
						}
					}//FIN: [Before-Update] ACCIONES TRAS CAMBIO DE ESTADO


					// [Before-InsertUpdate] ACCIONES TRAS ESTABLECER CHECKS DE ESTADO
					system.debug('[Before-InsertUpdate] ACCIONES TRAS ESTABLECER CHECKS DE ESTADO');
					// Se setean cuando se recibe la información de que se ha facturado a Compañía, a Cliente, o a ambos, y nos lo informa el facturador.
					if(wo.OTR_CAS_Orden_Trabajo_Facturada__c && (woOld == null || !woOld.OTR_CAS_Orden_Trabajo_Facturada__c)){
						wo.OTR_DAT_Fecha_Facturacion__c = Datetime.Now();
					}
					// Se setean cuando se recibe la información de que se ha liquidado al Profesional y nos lo informa el facturador.
					if(wo.OTR_CAS_Orden_Trabajo_Liquidada__c && (woOld == null || !woOld.OTR_CAS_Orden_Trabajo_Liquidada__c)){
						wo.OTR_DAT_Fecha_Liquidacion__c = Datetime.Now();
					}
					//FIN: [Before-InsertUpdate] ACCIONES TRAS ESTABLECER CHECKS DE ESTADO


					// [Before-InsertUpdate] ESTABLECER POLITICA DE ASIGNACIÓN MIZAD
					system.debug('[Before-InsertUpdate] ESTABLECER POLITICA DE ASIGNACIÓN MIZAD');
					// Si se ha insertado el registro o se ha modificado el CP, el Gremio o el Tipo de Trabajo:
					if(Trigger.isInsert || (woOld != null && (
							woOld.PostalCode != wo.PostalCode || 
							woOld.OTR_SEL_Gremio__c != wo.OTR_SEL_Gremio__c ||
							woOld.WorkTypeId != wo.WorkTypeId))){
						// Desactivar por defecto la conf Mizad
						wo.OTR_CAS_Asignar_Mizad__c = false;
						wo.OTR_SEL_Tipo_Red__c = null;
						// Validar si aplica la asignación Mizad
						if(wo.WorkTypeId != null){
							String nombreTipoTrab = '';
							if(mapaTiposTrab.get(wo.WorkTypeId)!=null){
								nombreTipoTrab = mapaTiposTrab.get(wo.WorkTypeId).Name;
								for(Orden_de_trabajo__mdt conf: listaMetadatosOt){
									if(wo.PostalCode == conf.MTD_OTR_TXT_Codigo_Postal__c &&
										wo.OTR_SEL_Gremio__c == conf.MTD_OTR_SEL_Gremio__c &&
										nombreTipoTrab == conf.MTD_OTR_TXT_Suceso__c){
										wo.OTR_CAS_Asignar_Mizad__c = true;
										wo.OTR_SEL_Tipo_Red__c = 'Mizad';
										break;
									}
								}
							}
						}
					}
					// Establecer la política de Asignación Mizad si aplica
					/*if(politicaAsignMizad != null && (wo.OTR_CAS_Urgente__c || wo.OTR_SEL_Tipo_Red__c == 'Mizad')){
						wo.OTR_LKP_Scheduling_Policy__c = politicaAsignMizad.Id;
					}
					// Establecer la política de Geolocalizacion - Primario si aplica
                    else if(politicaGeoPrimario != null && !wo.OTR_CAS_Asignar_Como_Franquiciado__c 
						&& wo.OTR_CAS_Asignar_territorio_prim_no_franq__c){
                        wo.OTR_LKP_Scheduling_Policy__c = politicaGeoPrimario.Id;
					}
					// Establecer politica por defecto
					else if(politicaGeo != null){
						wo.OTR_LKP_Scheduling_Policy__c = politicaGeo.Id;
					}
					else {
						wo.OTR_LKP_Scheduling_Policy__c = null;
					}*/
					
					if(politicaGeo != null && wo.OTR_CAS_Asignar_territorio_prim_no_franq__c){
						wo.OTR_LKP_Scheduling_Policy__c = politicaGeo.Id;
					} else if(politicaGeoPrimario != null){
						wo.OTR_LKP_Scheduling_Policy__c = politicaGeoPrimario.Id;
					} else {
						wo.OTR_LKP_Scheduling_Policy__c = null;
					}
					// [Before-InsertUpdate] ESTABLECER POLITICA DE ASIGNACIÓN MIZAD


					// [Before-InsertUpdate] ACTUALIZAR CAMPOS SEMAFORO ESTADOS
					system.debug('[Before-InsertUpdate] ACTUALIZAR CAMPOS SEMAFORO ESTADOS');
					completarDatosSemaforo(wo, woOld);


					// [Before-InsertUpdate] ESTABLECER RECORDTYPE
					system.debug('[Before-InsertUpdate] ESTABLECER RECORDTYPE');
					String tipoActuacion = null;
					if(caso != null){
						tipoActuacion = caso.Type;
					}
					wo.RecordTypeId = Util_Orden_Trabajo.obtenerIdTipoDeRegistroOT(wo.RecordTypeId, tipoActuacion);
					//FIN: [Before-InsertUpdate] ESTABLECER RECORDTYPE

				}//FIN for(WorkOrder wo : triggerNew)

			}//FIN if(triggerNew != null)

		}//FIN if(Trigger.isInsert || Trigger.isUpdate)
	}//FIN tratamientoBefore()


	private static void completarDatosSemaforo(WorkOrder wo, WorkOrder woOld){
		//Si la orden es nueva o se ha producido un cambio de estado, 
		//se debe consultar en el custom metadata Orden de trabajo tomando como filtro la compañía y el nuevo estado 
		//y se deben completar los campos Dias Amarillo y Dias Verdes en función de los valores recuperados.
		//Si el estado ha cambiado o si la OT es nueva
		String identificadorCIA = Label.IDE_HOMESERVE;
		if(!String.isBlank(wo.OTR_FOR_Identificador_CIA__c)){
			identificadorCIA = wo.OTR_FOR_Identificador_CIA__c;
		}
		Orden_de_trabajo__mdt oTMTMD = Util_Metadatos.mapaOTEstadoCIA.get(wo.Status + '' + identificadorCIA);

		if(oTMTMD == null)
			oTMTMD = Util_Metadatos.mapaOTEstadoCIA.get(wo.Status + '' + Label.IDE_HOMESERVE);

		system.debug('----------key: '+wo.Status + '' + identificadorCIA);
		system.debug('----------oTMTMD: '+oTMTMD);

		if(woOld == null || wo.Status != woOld.Status){
			wo.OTR_DAT_Fecha_cambio_estado__c = Datetime.now();
			if(oTMTMD != null){
				wo.OTR_NUM_Horas_amarillo__c = oTMTMD.MTD_OTR_NUM_Horas_amarillo__c;
				wo.OTR_NUM_Horas_verde__c = oTMTMD.MTD_OTR_NUM_Horas_verde__c; 
				if(wo.OTR_NUM_Horas_amarillo__c != 0 || wo.OTR_NUM_Horas_verde__c != 0){
					wo.OTR_DAT_Generar_Tarea_Semaforo__c = wo.OTR_DAT_Fecha_cambio_estado__c.addMinutes(integer.valueof(wo.OTR_NUM_Horas_verde__c*24*60));
					wo.OTR_DAT_Fecha_Hora_Cambio_semaforo__c =  wo.OTR_DAT_Fecha_cambio_estado__c.addMinutes((oTMTMD.MTD_OTR_NUM_Horas_amarillo__c*24*60).intValue() + (oTMTMD.MTD_OTR_NUM_Horas_verde__c*24*60).intValue());
				} else {
					wo.OTR_DAT_Generar_Tarea_Semaforo__c = datetime.now().addYears(50); // Los 0 ambos interpretamos sin límite
					wo.OTR_DAT_Fecha_Hora_Cambio_semaforo__c = datetime.now().addYears(50); 
				}
			} else {
				wo.OTR_NUM_Horas_amarillo__c = 0;
				wo.OTR_NUM_Horas_verde__c = 0;
				wo.OTR_DAT_Generar_Tarea_Semaforo__c = datetime.now().addYears(50); // Si se pone a nulo saltará una tarea, así que ponemos para que se cumpla la fecha en 50 años
				wo.OTR_DAT_Fecha_Hora_Cambio_semaforo__c = datetime.now().addYears(50); 
			}
		}
	}//FIN completarDatosSemaforo()


	/**
	  * Tratamiento para el caso after del trigger.
	  * 
	  * @param triggerNewMap: mapa de registros nuevos del objeto WorkOrder a partir del Id
	  * @param triggerNew: lista de registros nuevos del objeto WorkOrder
	  * @param triggerOldMap: mapa de registros antiguos del objeto WorkOrder a partir del Id
	  * @param triggerOld: lista de registros antiguos del objeto WorkOrder
	  */
	public static void tratamientoAfter(Map<Id, WorkOrder> triggerNewMap, List<WorkOrder> triggerNew, 
			Map<Id, WorkOrder> triggerOldMap, List<WorkOrder> triggerOld){
		system.debug('>>>>>>>>>TRATAMIENTO AFTER');
		Map<Id,WorkOrderLineItem> mapaPartidasUpdate = new Map<Id,WorkOrderLineItem>();
		Map<Id,ServiceAppointment> mapaCitasUpdate = new Map<Id,ServiceAppointment>();
		List<SkillRequirement> listaSkillsOTinsert = new List<SkillRequirement>();
		List<AssignedResource> recursoAsignadoBorrar = new List<AssignedResource>();
		List<AssignedResource> recursoAsignadoInsertar = new List<AssignedResource>();

		Set<Id> casosShareRecalcular = new Set<Id>();
		
		Set<Id> profesionalIdSetEnCurso = new Set<Id>();
		Set<Id> profesionalIdSetMensual = new Set<Id>();
		mapaProfesionalesUpdate = new Map<Id, ServiceResource>();
		
		List<Workorder> woNoRevision = null;
		List<Workorder> woOldNoRevision = null;
		Map<Id,Workorder> mapaWoNoRevision = null;
		Map<Id,Workorder> mapaWoOldNoRevision = null;
		
		if(triggerNew != null){
			woNoRevision = new List<Workorder>();
			mapaWoNoRevision = new Map<Id,Workorder>();
			for(Workorder wo: triggerNew){
				if(wo.RecordTypeId != recordTypeIdEnRevision){
					woNoRevision.add(wo);
					mapaWoNoRevision.put(wo.Id,wo);
				}
			}
		}
		
		if(triggerOld != null){
			woOldNoRevision = new List<Workorder>();
			mapaWoOldNoRevision = new Map<Id,Workorder>();
			for(Workorder wo: triggerOld){
				if(wo.RecordTypeId != recordTypeIdEnRevision){
					woOldNoRevision.add(wo);
					mapaWoOldNoRevision.put(wo.Id,wo);
				}
			}
		}

		List<Workorder> woParaE21 = new List<Workorder>();
		
		
		if(Trigger.isInsert || Trigger.isUpdate){
			// Crear Mapa con todas las OTs no anuladas de los Casos asociados a las OTs actualizadas del Trigger
            Map<Id, List<WorkOrder>> mapaOTsCaso = Util_Orden_Trabajo.getMapaOTsCasos(mapaCasos.keySet());
			// Crear Mapa con todas las OTs de los Casos asociados a las OTs actualizadas del Trigger
            Map<Id, List<WorkOrder>> mapaOTsCasoFull = Util_Orden_Trabajo.getMapaOTsCasosFull(mapaCasos.keySet());
			// Crear Mapa con todas las partidas no rechazadas de las OTs actualizadas del Trigger
			Map<Id, List<WorkOrderLineItem>> mapaPartidasOTs = Util_Orden_Trabajo.getMapaPartidasOTs(triggerNewMap.keySet());
			// Crear Mapa con todas las citas no anuladas de las OTs actualizadas del Trigger
			mapaCitasOTs = Util_Cita_Servicio.getMapCitasOTsNotInStatus(triggerNewMap.keySet(),Util_Cita_Servicio.SET_ESTADOS_ANULADOS);
			
			//Esto es para que cuando los profesionales creen una wo con
			//propietario el gestor del caso, no pierdan permisos a la mitad del trigger
			Util_Orden_Trabajo.insertShares(triggerNew);


			if(Trigger.isInsert){
				List<Workorder> numeroHSActualizar = new List<Workorder>();

				// [After-Insert] GENERAR MOVIMIENTO IR (asíncrono)
				//TRG_Handler_MovimientoIR trg = new TRG_Handler_MovimientoIR(triggerNew, Label.MIR_Procedimiento);
				if(!woNoRevision.isEmpty()){
					TRG_Handler_MovimientoIR trg = new TRG_Handler_MovimientoIR(woNoRevision, Label.MIR_Procedimiento);
					System.enqueueJob(trg);
				}
				//FIN: [After-Insert] GENERAR MOVIMIENTO IR (asíncrono)


				// [After-Insert] AGREGAR A LA LISTA RELACIONADA EL SKILL CORRESPONDIENTE A LA CIA
				if(!woNoRevision.isEmpty())
					listaSkillsOTinsert.addAll(Util_Orden_Trabajo.insertaCiasEnOrden(woNoRevision));
				//FIN: [After-Insert] AGREGAR A LA LISTA RELACIONADA EL SKILL CORRESPONDIENTE A LA CIA

				Set<Id> setIdCaso = new Set<Id>(); // Nº48 - 07_06_2018 / SMM
				for(Workorder wo:triggerNew){
					setIdCaso.add(wo.CaseId); // Nº48 - 07_06_2018 / SMM
					if(wo.RecordTypeId != recordTypeIdEnRevision){
						if(wo.CaseId != null){
							casosShareRecalcular.add(wo.CaseId);
						}
					}
					// [After-Insert] ESTABLECER AUTONUMBER EN EXTERNAL ID
					if(String.isBlank(wo.OTR_TXT_Num_OrdenTrabajo_HS__c)){
						Workorder woAct = new WorkOrder(Id=wo.Id);
						woAct.OTR_TXT_Num_OrdenTrabajo_HS__c = wo.WorkOrderNumber;
						numeroHSActualizar.add(woAct);
					}//FIN: [After-Insert] ESTABLECER AUTONUMBER EN EXTERNAL ID

				}
				
				// Nº48 - 07_06_2018 / SMM
				List<Case> listaCasosActualizar = Util_Caso.getCaseById(setIdCaso).values();
				for(Case caso : listaCasosActualizar){
					// -- Cuando se cree una OT y el estado del Siniestro del que depende esté en estado "Cerrado", se debe cambiar el estado de dicho Caso a "Reapertura":
					if(caso.Status == Label.CAS_ESTADO_CERRADO && Util_Siniestro.esSiniestro(caso)){
						caso.Status = Label.CAS_ESTADO_REAPERTURADO;
						// -- Si el Siniestro tuviese marcados los check de Facturado y/o Liquidado, se desmarcan, ya que se tiene que volver a facturar y/o liquidar:
						if(caso.CAS_CAS_Siniestro_Facturado__c || caso.CAS_CAS_Liquidado__c){
							caso.CAS_CAS_Siniestro_Facturado__c = false;
							caso.CAS_CAS_Liquidado__c = false;
						}
					}
				}
				update listaCasosActualizar;
				// FIN Nº48

				// [After-Insert] ACTUALIZAR OT AUTONUMBER EN EXTERNAL ID
				if(!numeroHSActualizar.isEmpty()){
					Baipas.establecerVariableControl();
					update numeroHSActualizar;
					Baipas.deshabilitarVariableControl();
				}//FIN: [After-Insert] ACTUALIZAR AUTONUMBER EN EXTERNAL ID
			}


			else if(Trigger.isUpdate){

				// [After-Update] CALLOUTS DE FACTURACIÓN
				//calloutFacturador(triggerNew, triggerOld,label.FAC_Maestro_Clientes,Label.FAC_MAESTRO_CLIENTES_NOMBRE);
				//calloutFacturador(triggerNew, triggerOld,label.FAC_PreFactura, Label.FAC_PREFACTURA_NOMBRE);
				//calloutFacturador(triggerNew, triggerOld,label.FAC_Maestro_Profesionales, Label.FAC_MAESTRO_PROFESIONALES_NOMBRE);
				if(!woNoRevision.isEmpty()){
					calloutFacturador(woNoRevision, woOldNoRevision,label.FAC_Maestro_Profesionales, Label.FAC_MAESTRO_PROFESIONALES_NOMBRE);
					calloutFacturador(woNoRevision, woOldNoRevision,label.FAC_Maestro_Clientes,Label.FAC_MAESTRO_CLIENTES_NOMBRE);
					calloutFacturador(woNoRevision, woOldNoRevision,label.FAC_PreFactura, Label.FAC_PREFACTURA_NOMBRE);
				}
				//FIN: [After-Update] CALLOUTS DE FACTURACIÓN


				//Guarda las wo para las que hay que fabricar una propuesta de evento
				List<WorkOrder> listaOrdenesEvento = new List<WorkOrder>();
				//Guarda las WO para las que hay que fabricar una propuesta de abono;
				List<WorkOrder> listaOrdenesAbono = new List<WorkOrder>();
				List<WorkOrder> listaOrdenesAnuladas = new List<WorkOrder>();
				
                //List<Workorder> reclamacionesFacturar = new List<Workorder>();
                List<Workorder> woFacturar = new List<Workorder>();
                //List<Workorder> noReclamacionesFacturar = new List<Workorder>();
				for(WorkOrder wo : woNoRevision){
				//for(WorkOrder wo : triggerNew){
					WorkOrder woOld = null;
					if(triggerOldMap != null){
						woOld = triggerOldMap.get(wo.Id);
					}
					//Rellena los sets de Ids de profesionales
					boolean cambioProfesional = wo.OTR_LKP_Recurso_Servicio__c != triggerOldMap.get(wo.Id).OTR_LKP_Recurso_Servicio__c;
					boolean cambioStatus = wo.Status != triggerOldMap.get(wo.Id).Status;
					boolean estadoNuevoEnCurso = !Util_Orden_Trabajo.SET_ESTADOS_NO_ENCURSO.contains(wo.Status);
					boolean estadoViejoEnCurso = !Util_Orden_Trabajo.SET_ESTADOS_NO_ENCURSO.contains(triggerOldMap.get(wo.Id).Status);
					//El set de profesionales En Curso se rellena con los profesionales cuyo estado ha cambiado en el update y antes o después estaba en curso
					if(cambioProfesional || (cambioStatus && (estadoNuevoEnCurso || estadoViejoEnCurso) && wo.OTR_LKP_Recurso_Servicio__c!=null)){
						if(wo.OTR_LKP_Recurso_Servicio__c != null){
							profesionalIdSetEnCurso.add(wo.OTR_LKP_Recurso_Servicio__c);
						}
						if(triggerOldMap.get(wo.Id).OTR_LKP_Recurso_Servicio__c != null){
							profesionalIdSetEnCurso.add(triggerOldMap.get(wo.Id).OTR_LKP_Recurso_Servicio__c);
						}
					}
					//El set de profesionales Mensual se rellena con los profesionales cuyo cambio de estado se ha producido en el mes en curso
					if(cambioProfesional && wo.CreatedDate.month() == DateTime.now().month() && wo.CreatedDate.year() == DateTime.now().year()){
						if(wo.OTR_LKP_Recurso_Servicio__c != null){
							profesionalIdSetMensual.add(wo.OTR_LKP_Recurso_Servicio__c);
						}
						if(triggerOldMap.get(wo.Id).OTR_LKP_Recurso_Servicio__c != null){
							profesionalIdSetMensual.add(triggerOldMap.get(wo.Id).OTR_LKP_Recurso_Servicio__c);
						}
					}

					//si se anula una wo que esta en estado revisado o cerrado se crean dos abonos
					system.debug('<<<<<<<<<<<<sera wo.Status ' + wo.Status + '<<<<<<<<<<<<<<woOld.Status ' +woOld.Status);
					if(wo.Status == Label.OTR_ESTADO_ANULADO && wo.OTR_CAS_Orden_Trabajo_Facturada__c && (woOld.Status == Label.OTR_ESTADO_REVISADO || woOld.Status == Label.OTR_ESTADO_CERRADO)){
						listaOrdenesAnuladas.add(wo);
					}
					

					// Obtener la cita abierta actual de la OT y su recurso asignado
					ServiceAppointment citaActual = null;
					List<ServiceAppointment> citasActuales = mapaCitasOTs.get(wo.Id);
					if(citasActuales != null && !citasActuales.isEmpty()){
						for(ServiceAppointment sa: citasActuales){
							if(sa.Status != Label.CIT_ESTADO_COMPLETADA){
								citaActual = sa;
								break;
							}
						}
					}
					AssignedResource recursoCitaActual = null;
					if(citaActual != null && citaActual.ServiceResources != null && !citaActual.ServiceResources.isEmpty()){
						recursoCitaActual = citaActual.ServiceResources[0];
					}

					if(wo.OTR_LKP_Recurso_Servicio__c != woOld.OTR_LKP_Recurso_Servicio__c && wo.CaseId != null){
						casosShareRecalcular.add(wo.CaseId);
					}

					if(wo.CaseId != null && mapaCasos.get(wo.CaseId) != null){
						Case caso = mapaCasos.get(wo.CaseId);
						Case casoUpdate = mapaCasosUpdate.get(wo.CaseId);
						if(casoUpdate == null){
							//casoUpdate = new Case(Id=wo.CaseId);
							// Se debe inicializar completo (todos los campos, no solo el Id)
							// porque luego se evalúan condiciones sobre casoUpdate
							casoUpdate = caso;
						}

						List<WorkOrder> listaOTsCaso = mapaOTsCaso.get(wo.CaseId);

						system.debug('----------listaOTsCaso: '+listaOTsCaso);
						system.debug('----------mapaOTsCaso: '+mapaOTsCaso);
						system.debug('----------mapaCasos: '+mapaCasos);
						Boolean actualizarCaso = false;
						Boolean esReclamacion = (casoUpdate.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION) ||
								casoUpdate.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SOL_RECLAMACION));
						String identificadorCIA = Label.IDE_HOMESERVE;
						if(!String.isBlank(wo.OTR_FOR_Identificador_CIA__c)){
							identificadorCIA = wo.OTR_FOR_Identificador_CIA__c;
						}
						Orden_de_trabajo__mdt oTMTMD = Util_Metadatos.mapaOTEstadoCIA.get(wo.Status + '' + identificadorCIA);
						if(oTMTMD == null){
							oTMTMD = Util_Metadatos.mapaOTEstadoCIA.get(wo.Status + '' + Label.IDE_HOMESERVE);
						}

						// [After-Update] ACCIONES TRAS CAMBIOS DE ESTADO EN LA OT
						if(woOld != null && wo.Status != woOld.Status){
							system.debug('-------Antes de');
							system.debug('-------casoUpdate.CAS_FOR_RTDevName__c: ' +casoUpdate.CAS_FOR_RTDevName__c);
							system.debug('-------LABEL.RT_CAS_RECLAMACION.replace(): '+LABEL.RT_CAS_RECLAMACION.replace('Case:',''));
							system.debug('-------casoUpdate.Status: ' +casoUpdate.Status);
							system.debug('-------LABEL.CAS_ESTADO_PDTE_TRATAMIENTO: '+LABEL.CAS_ESTADO_PDTE_TRATAMIENTO);
							system.debug('-------wo.Status: ' + wo.Status);
							system.debug('-------LABEL.OTR_ESTADO_REVISADO: '+LABEL.OTR_ESTADO_REVISADO);
							system.debug('-------wo.OTR_SEL_Subestado__c: ' +wo.OTR_SEL_Subestado__c);
							system.debug('-------LABEL.OTR_SUBESTADO_REVISADO_CON_ALBARAN: '+LABEL.OTR_SUBESTADO_REVISADO_CON_ALBARAN);
							system.debug('-------triggerOldMap.get(wo.Id).Status: ' +triggerOldMap.get(wo.Id).Status);
							system.debug('-------oTMTMD: ' + oTMTMD);
							system.debug('-------casoUpdate.CAS_TXT_Subestado_Codigo__c: ' + casoUpdate.CAS_TXT_Subestado_Codigo__c);
							
							// se crea el evento E21 cuando el semaforo esta en rojo
							system.debug('<<<<<<<<<sera llega if>>>>>>>');
							//if(woOld.OTR_DAT_Fecha_cambio_estado__c != null){
							if(Util_Orden_trabajo.SET_ESTADOS_PDTE_PROFESIONAL.contains(woOld.Status) && system.now() > woOld.OTR_DAT_Fecha_Hora_Cambio_semaforo__c){
								/*system.debug('<<<<<<<<<sera entra if>>>>>>>');
								//Datetime fCambioSemaforo = wo.OTR_DAT_Fecha_cambio_estado__c.addHours(wo.OTR_NUM_Horas_verde__c.intValue() + wo.OTR_NUM_Horas_amarillo__c.intValue());
								Datetime fCambioSemaforo = woOld.OTR_DAT_Fecha_cambio_estado__c.addMinutes((woOld.OTR_NUM_Horas_verde__c*24*60).intValue() + (woOld.OTR_NUM_Horas_amarillo__c*24*60).intValue());
								system.debug(wo.Status + 'comprobacion1');
								system.debug(Util_Orden_trabajo.SET_ESTADOS_NO_ENCURSO + 'comprobacion2');
								system.debug(fCambioSemaforo + 'comprobacion3');
								system.debug(woOld.Status+ 'comprobacion4');
		
								
								
								if(Util_Orden_trabajo.SET_ESTADOS_PDTE_PROFESIONAL.contains(woOld.Status) && system.now() > fCambioSemaforo
									&& wo.Status != woOld.Status){*/
									system.debug('<<<<<<<<<sera entra if2>>>>>>>');
									woParaE21.add(wo);
										system.debug(woParaE21 + 'WOOOOOOOOOOO');
								//}
							}

							//Si es Reclamacion, En funcion del estado del caso, del estado de la WO y del subestado de la WO,
							//Se agrega o no la OT a listaOrdenesEvento
							if(esReclamacion &&
									(wo.Status == LABEL.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO 
									|| wo.Status == LABEL.OTR_ESTADO_CERRADO_PDTE_ALBARAN) && 
									(woOld.Status != LABEL.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO 
									&& woOld.Status != LABEL.OTR_ESTADO_CERRADO_PDTE_ALBARAN)){
								Task tarea = Util_tarea.crearTarea(Label.RT_TAR_COMUN,'Indicar si la reclamación es o no fundada consultando el reporte del profesional',Label.TAR_ESTADO_EN_CURSO,null,caso.OwnerId,caso.Id,null);
								listaTareasInsert.add(tarea);
							}
							
							//Si es una Reclamación y el nuevo estado es INACTIVO EN ESPERA DE CLIENTE:
							//cambiar el estado del Caso a RECLAMACIÓN DORMIDA si el resto de sus servicios hijos están es estado distinto de ABIERTO
							if(esReclamacion && wo.Status == Label.OTR_ESTADO_INACTIVO_CLIENTE){
								List <WorkOrder> listaOTsHijasCaso = mapaOTsCasoFull.get(casoUpdate.Id);
								//Boolean reclamacionDormida = false;
								Boolean reclamacionDormida = true;
								for (WorkOrder wohija :listaOTsHijasCaso){
									if(wohija.Status != Label.OTR_ESTADO_INACTIVO_CLIENTE)
										reclamacionDormida = false;
									//if(wohija != wo && wohija.Status != Label.OTR_ESTADO_CERRADO && wohija.Status != Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO && wohija.Status != Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN){
									//	reclamacionDormida = true;
									//}
								}
								if(reclamacionDormida == true){
									casoUpdate.Status = Label.CAS_ESTADO_RECLAMACION_DORMIDA;
									casoUpdate.CAS_TXT_Estado_Anterior__c = caso.Status;
									actualizarCaso = true;
								}
							}
							
							//Si es una reclamación en estado RECLAMACIÓN DORMID y el nuevo estado del servicio es INACTIVO desde INACTIVO EN ESPERA DE CLIENTE
							//cambiar el estado del Caso al anterior
							if(esReclamacion && caso.Status == Label.CAS_ESTADO_RECLAMACION_DORMIDA){
								if(woOld.Status == Label.OTR_ESTADO_INACTIVO_CLIENTE && wo.Status == Label.OTR_ESTADO_INACTIVO){
									casoUpdate.Status = caso.CAS_TXT_Estado_Anterior__c;
									casoUpdate.CAS_TXT_Estado_Anterior__c = null;
									actualizarCaso = true;
								}
							}

							// Si el nuevo estado es EN ESPERA DE CONFIRMACION... (solo disponible en SINIESTROS):
							// copiar dicho estado en el estado del Caso
							else if(wo.Status == Label.OTR_ESTADO_EN_ESPERA_CONF_PROF ||
									wo.Status == Label.OTR_ESTADO_EN_ESPERA_CONF_GEST){
								casoUpdate.Status = wo.Status;
								casoUpdate.CAS_TXT_Subestado_Codigo__c = null;
								actualizarCaso = true;
							}

							// Si No es una Reclamación y el nuevo estado es ANULADO:
							else if(!esReclamacion && (wo.Status == Label.OTR_ESTADO_ANULADO ||
									wo.Status == Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO)){
								system.debug('>>>>>>>>>>>>AFTER. Si se ha actualizado el estado a ANULADO');
								// Si es la OT principal del Caso: blanquear dicha referencia en el Caso
								system.debug('>>>>>>>>>>>>AFTER. Blanquear OT principal del caso (caso.CAS_LKP_Orden_Trabajo_Principal__c): ' + caso.CAS_LKP_Orden_Trabajo_Principal__c);
								system.debug('>>>>>>>>>>>>AFTER. Blanquear OT principal del caso (wo.Id): ' + wo.Id);
								if(casoUpdate.CAS_LKP_Orden_Trabajo_Principal__c == wo.Id){
									system.debug('>>>>>>>>>>>>AFTER. Blanquear OT principal del caso (caso.CAS_LKP_Orden_Trabajo_Principal__c): ' + caso.CAS_LKP_Orden_Trabajo_Principal__c);
									system.debug('>>>>>>>>>>>>AFTER. Blanquear OT principal del caso (wo.Id): ' + wo.Id);
									casoUpdate.CAS_LKP_Orden_Trabajo_Principal__c = null;
									casoUpdate.CAS_SEL_Gremio_Principal__c = null;
									casoUpdate.CAS_LKP_Tipo_Trabajo__c = null;
									actualizarCaso = true;
								}

								//se marca el check de todas las partidas de la OT anulada o rechazada
								if(mapaPartidasOTs.get(wo.id) != null){
									for(WorkOrderLineItem partida : mapaPartidasOTs.get(wo.Id)){
										WorkOrderLineItem partidaUpdate = mapaPartidasUpdate.get(partida.Id);
										if(partidaUpdate == null){
											partidaUpdate = new WorkOrderLineItem(Id=partida.Id,Status=partida.Status);
										}
										partidaUpdate.PAR_CAS_Orden_Trabajo_Anulada__c = true;
										mapaPartidasUpdate.put(partida.Id, partidaUpdate);
									}
								}
								// Anular todas las Citas de la OT no anuladas ni completadas
								if(mapaCitasOTs.get(wo.Id) != null){
									for(ServiceAppointment cita : mapaCitasOTs.get(wo.Id)){
										ServiceAppointment citaUpdate = mapaCitasUpdate.get(cita.Id);
										if(citaUpdate == null){
											// Se debe inicializar completo (todos los campos, no solo el Id)
											// porque luego se evalúan condiciones sobre citaUpdate
											citaUpdate = cita;
										}
										if (citaUpdate.Status!=Label.CIT_ESTADO_COMPLETADA){
											citaUpdate.Status = Label.CIT_ESTADO_ANULADA;
											if(!Test.isRunningTest()){
												mapaCitasUpdate.put(citaUpdate.Id, citaUpdate);
											}
										}
									}
								}
							}

/*
                            // Si No es una Reclamación y el nuevo estado es CERRADO_ALBARAN_RECIBIDO:
                            // validar si se puede realizar el cierre técnico del Caso
                            else if(wo.Status == Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO ||
                                    wo.Status == Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN){
                                // Si todas las OTs del Caso están en estado CERRADO: cerrar Caso ***SE TRASLADA A LA VISUALFORCE DE CAMBIO DE ESTADO
                                Boolean todoCerrado = true;
                                for(WorkOrder woAux : listaOTsCaso){
                                    if(!Util_Orden_Trabajo.SET_ESTADOS_CERRADOS.contains(woAux.Status)){
                                        todoCerrado = false;
                                        break;
                                    }
                                }
                                if(todoCerrado){
                                    actualizarCaso = true;

                                    if(!esReclamacion){
                                        casoUpdate.Status = Label.CAS_ESTADO_CERRADO;
                                        casoUpdate.CAS_TXT_Subestado_Codigo__c = null;
                                        if(Util_Siniestro.esSiniestro(caso)){
                                            Util_Movimientos.compruebaEnviable(caso.Id, caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c, '24');
                                        }
                                    }
                                }
                            }
*/

							else if(wo.Status == Label.OTR_ESTADO_CERRADO){
								TRG_Handler_MovimientoIR trg = new TRG_Handler_MovimientoIR(triggerNew, Label.MIR_Procedimiento);
								System.enqueueJob(trg);
								// La OT está cerrada, por lo tanto, sus partidas en estado pendiente deben pasar a estado rechazado:
								if(!mapaPartidasOTs.isEmpty()){
									for(WorkOrderLineItem partida : mapaPartidasOTs.get(wo.Id)){
										WorkOrderLineItem partidaUpdate = mapaPartidasUpdate.get(partida.Id);
										if(partidaUpdate == null){
											// Se debe inicializar completo (todos los campos, no solo el Id)
											// porque luego se evalúan condiciones sobre partidaUpdate
											partidaUpdate = partida;
										}
										if((partidaUpdate.Status == Label.PAR_ESTADO_PENDIENTE)
												|| (partidaUpdate.Status == Label.PAR_ESTADO_PDTE_CLIENTE)
												|| (partidaUpdate.Status == Label.PAR_ESTADO_PDTE_PERITO)
												|| (partidaUpdate.Status == Label.PAR_ESTADO_PDTE_GESTOR)
												|| (partidaUpdate.Status == Label.PAR_ESTADO_PDTE_CIA)){
											partidaUpdate.Status = Label.PAR_ESTADO_RECHAZADA;
											mapaPartidasUpdate.put(partidaUpdate.Id, partidaUpdate);
										}
									}
								}
							}


							// Si el nuevo estado se ha configurado para bloquear el semáforo:
							// copiar en el subestado del Caso
							if(oTMTMD != null && oTMTMD.MTD_OTR_CAS_Bloquea_Semaforo__c){
								system.debug('>>>>>>>>>>>>>>>>>>Estado Nuevo Bloquea Semaforo wo.Id: ' + wo.Id);
								system.debug('>>>>>>>>>>>>>>>>>>Estado Nuevo Bloquea Semaforo wo.Status: ' + wo.Status);
								casoUpdate.CAS_TXT_Subestado_Codigo__c = wo.Status;
								actualizarCaso = true;
							}
							// Si el nuevo estado no se ha configurado para bloquear el semáforo:
							else if((oTMTMD == null || (!oTMTMD.MTD_OTR_CAS_Bloquea_Semaforo__c)) && caso.CAS_TXT_Subestado_Codigo__c != null){
								system.debug('>>>>>>>>>>>>>>>>>>Estado Nuevo NO Bloquea Semaforo wo.Id: ' + wo.Id);
								system.debug('>>>>>>>>>>>>>>>>>>Estado Nuevo NO Bloquea Semaforo wo.Status: ' + wo.Status);
								// Validar si alguna de las Ordenes de Trabajo bloquea el semáforo del Caso
								Boolean blanquearSubestado = true;
								if(listaOTsCaso != null && !listaOTsCaso.isEmpty()){
									for(WorkOrder otCaso : listaOTsCaso){
										if(otCaso.Id != wo.Id){
											Orden_de_trabajo__mdt oTMTMDaux = Util_Metadatos.mapaOTEstadoCIA.get(otCaso.Status + '' + identificadorCIA);
											if(oTMTMDaux == null){
												oTMTMDaux = Util_Metadatos.mapaOTEstadoCIA.get(wo.Status + '' + Label.IDE_HOMESERVE);
											}
											if(oTMTMDaux == null || oTMTMDaux.MTD_OTR_CAS_Bloquea_Semaforo__c){
												system.debug('>>>>>>>>>>>>>>>>>>Otra OT sí Bloquea Semaforo otCaso.Id: ' + otCaso.Id);
												system.debug('>>>>>>>>>>>>>>>>>>Otra OT sí Bloquea Semaforo otCaso.Status: ' + otCaso.Status);
												blanquearSubestado = false;
												break;
											}
										}
									}
								}
								// Si ninguna Orden de Trabajo bloquea el semáforo del Caso: se debe blanquear el subestado
								if(blanquearSubestado){
									system.debug('>>>>>>>>>>>>>>>>>>blanquearSubestado');
									casoUpdate.CAS_TXT_Subestado_Codigo__c = null;
									actualizarCaso = true;
								}
							}
						}//FIN: [After-Update] ACCIONES TRAS CAMBIOS DE ESTADO EN LA OT


						if((!woOld.OTR_CAS_Orden_Trabajo_Facturada__c && wo.OTR_CAS_Orden_Trabajo_Facturada__c)
							|| (!woOld.OTR_CAS_Orden_Trabajo_Liquidada__c && wo.OTR_CAS_Orden_Trabajo_Liquidada__c)){
						
                            woFacturar.add(wo);
                            /*if(esReclamacion)
								reclamacionesFacturar.add(wo);
							else
                                noReclamacionesFacturar.add(wo);*/
                        }

                        // [After-Update] GENERAR TAREA DE CIERRE DE RECLAMACIÓN
                        //Si es una reclamación y la orden de trabajo está facturada, comprobamos si hay que
                        //generar una tarea al gestor para que la cierre
                        /*if(esReclamacion && wo.OTR_CAS_Orden_Trabajo_Facturada__c && !woOld.OTR_CAS_Orden_Trabajo_Facturada__c){
                            
                            
                            
                            Boolean generarTarea = true;
                            for(WorkOrder woCaso: listaOTsCaso){
                                if(!woCaso.OTR_CAS_Orden_Trabajo_Facturada__c){
                                    generarTarea = false;
                                    break;
                                }
                            }
                            if(generarTarea){
                                Task tarea = Util_Tarea.crearTarea(Label.RT_TAR_COMUN, 'Se puede cerrar la reclamación',Label.TAR_ESTADO_EN_CURSO, null , caso.OwnerId, caso.Id, caso.CAS_LKP_Compania__c);
                                listaTareasInsert.add(tarea);
						}
                        }*///FIN: [After-Update] GENERAR TAREA DE CIERRE DE RECLAMACIÓN

						if(casoUpdate != null){
							// [After-Update] ACCIONES TRAS CAMBIOS EN EL IMPORTE DE LAS PARTIDAS
							Boolean recalcularImpTotalCaso = false;
							Decimal importeTotalCaso = casoUpdate.CAS_FOR_Importe_Total__c;
							Decimal importeTotalCIA = casoUpdate.CAS_DIV_Total_Facturar_CIA_AI__c;
							Decimal limiteActuacionCIA = casoUpdate.CAS_FOR_Limite_Actuacion__c;
							Boolean importesVacios = (wo.OTR_RES_Facturar_Cliente_AI__c == 0 &&
													  wo.OTR_RES_Subtotal_Partidas__c == 0);
							system.debug('>>>>>>>>>>>>>>>ACCIONES TRAS CAMBIOS EN EL IMPORTE DE LAS PARTIDAS');
							system.debug('>>>>>>>>>>>>>>>importeTotalCaso: ' + importeTotalCaso);
							system.debug('>>>>>>>>>>>>>>>importeTotalCIA: ' + importeTotalCIA);
							system.debug('>>>>>>>>>>>>>>>limiteActuacionCIA: ' + limiteActuacionCIA);

							// Si ha cambiado el importe de las partidas correspondiente al Cliente
							system.debug('>>>>>>>>>>>>>>>>>>>>>>>wo.OTR_RES_Facturar_Cliente_AI__c ' + wo.OTR_RES_Facturar_Cliente_AI__c);
							if(woOld != null && (wo.OTR_RES_Facturar_Cliente_AI__c != woOld.OTR_RES_Facturar_Cliente_AI__c
									|| casoUpdate.CAS_DIV_Total_Facturar_Cliente_AI__c == null)){
								system.debug('>>>>>>>>>>>>>>>>>>>>>>>woOld.OTR_RES_Facturar_Cliente_AI__c ' + woOld.OTR_RES_Facturar_Cliente_AI__c);
								casoUpdate.CAS_DIV_Total_Facturar_Cliente_AI__c = Util_Caso.calcularTotalFacturarCliente(listaOTsCaso);
								casoUpdate.CAS_CAS_Generar_Presupuesto__c = (wo.OTR_RES_Facturar_Cliente_AI__c != woOld.OTR_RES_Facturar_Cliente_AI__c);
								recalcularImpTotalCaso = true;
								actualizarCaso = true;
							}

							// Si ha cambiado el importe de las partidas correspondiente a la Compañía
							system.debug('>>>>>>>>>>>>>>>>>>>>>>>wo.OTR_RES_Subtotal_Partidas__c ' + wo.OTR_RES_Subtotal_Partidas__c);
							if(woOld != null && (wo.OTR_RES_Subtotal_Partidas__c != woOld.OTR_RES_Subtotal_Partidas__c
									|| casoUpdate.CAS_DIV_Total_Facturar_CIA_AI__c == null)){
								system.debug('>>>>>>>>>>>>>>>>>>>>>>>woOld.OTR_RES_Subtotal_Partidas__c ' + woOld.OTR_RES_Subtotal_Partidas__c);
								casoUpdate.CAS_DIV_Total_Facturar_CIA_AI__c = Util_Caso.calcularTotalFacturarCIA(listaOTsCaso);
								casoUpdate.CAS_CAS_Generar_Presupuesto__c = (wo.OTR_RES_Subtotal_Partidas__c != woOld.OTR_RES_Subtotal_Partidas__c);
								recalcularImpTotalCaso = true;
								actualizarCaso = true;
							}

							// Si ha cambiado el importe de las partidas correspondiente al Profesional
							system.debug('>>>>>>>>>>>>>>>>>>>>>>>wo.OTR_RES_Liquidar_prof_AI__c ' + wo.OTR_RES_Liquidar_prof_AI__c);
							if(woOld != null && (wo.OTR_RES_Liquidar_prof_AI__c != woOld.OTR_RES_Liquidar_prof_AI__c
									|| casoUpdate.CAS_DIV_Total_Facturar_Profesional__c == null)){
								system.debug('>>>>>>>>>>>>>>>>>>>>>>>woOld.OTR_RES_Liquidar_prof_AI__c ' + woOld.OTR_RES_Liquidar_prof_AI__c);
								casoUpdate.CAS_DIV_Total_Facturar_Profesional__c = Util_Caso.calcularTotalFacturarProfesional(listaOTsCaso);
								actualizarCaso = true;
							}

							// Si se ha cambiado el importe total: validar si supera el límite de actuación de la CIA
							if(recalcularImpTotalCaso){
								Decimal nuevoImporteTotalCaso = casoUpdate.CAS_DIV_Total_Facturar_Cliente_AI__c + casoUpdate.CAS_DIV_Total_Facturar_CIA_AI__c;
								system.debug('>>>>>>>>>>>>>>>>>>>>>>>nuevoImporteTotalCaso ' + nuevoImporteTotalCaso);

								// ACCIONES SI SE HA MODIFICADO EL IMPORTE TOTAL DE LA CIA
								if(casoUpdate.CAS_DIV_Total_Facturar_CIA_AI__c != importeTotalCIA){
									// Si se ha superado el límite de actuación
									Boolean superaLimiteActuacion = (limiteActuacionCIA != null &&
										casoUpdate.CAS_DIV_Total_Facturar_CIA_AI__c > limiteActuacionCIA && !esReclamacion);
									casoUpdate.CAS_CAS_Supera_Limite_Actuacion__c = superaLimiteActuacion;
									if(superaLimiteActuacion){
										//actualiza las partidas una vez superado el limite de actuacion
										List<WorkOrderlineItem> partidas = mapaPartidasOTs.get(wo.Id);
										if(partidas != null){
											for(WorkOrderLineItem partida: partidas){
												WorkOrderLineItem partidaUpdate = mapaPartidasUpdate.get(partida.Id);
												if(partidaUpdate == null){
													partidaUpdate = partida;
												}
												if(partidaUpdate.Status != Label.PAR_ESTADO_ESTIMADA &&
												   partidaUpdate.Status != Label.PAR_ESTADO_INDEMNIZABLE &&
												   !Util_Partida.SET_ESTADOS_RECHAZADOS.contains(partidaUpdate.Status)){
													partidaUpdate.Status = Label.PAR_ESTADO_PENDIENTE;
													mapaPartidasUpdate.put(partidaUpdate.Id, partidaUpdate);
												}
											}
										}
									}
								}
								system.debug('>>>>>>>>>>>>>>>>>>>>>>>caso.CAS_CAS_Supera_Limite_Actuacion__c ' + caso.CAS_CAS_Supera_Limite_Actuacion__c);
							}
							//FIN: [After-Update] ACCIONES TRAS CAMBIOS EN EL IMPORTE DE LAS PARTIDAS
							

							system.debug('>>>>>>>>>>>>actualizarCaso: ' + actualizarCaso);
							if(actualizarCaso){
								system.debug('>>>>>>>>>>>>actualizarCaso casoUpdate.Id: ' + casoUpdate.Id);
								mapaCasosUpdate.put(casoUpdate.Id, casoUpdate);
							}
						}
					}

					// [After-Update] ACCIONES TRAS CAMBIAR EL RECURSO ASIGNADO A LA OT
					if(woOld != null && citaActual != null &&
					  (wo.OTR_LKP_Recurso_Servicio__c != woOld.OTR_LKP_Recurso_Servicio__c)){
						system.debug('[After-Update] ACCIONES TRAS CAMBIAR EL RECURSO ASIGNADO A LA OT');
						system.debug('>>>>>>citaActual: ' + citaActual);
						system.debug('>>>>>>recursoCitaActual: ' + recursoCitaActual);
						system.debug('>>>>>>wo.OTR_LKP_Recurso_Servicio__c: ' + wo.OTR_LKP_Recurso_Servicio__c);
						if(recursoCitaActual == null || wo.OTR_LKP_Recurso_Servicio__c != recursoCitaActual.ServiceResourceId){
							// Desasignación manual del recurso asignado
							if(wo.OTR_LKP_Recurso_Servicio__c == null && recursoCitaActual != null){
								ServiceAppointment citaUpdate = mapaCitasUpdate.get(citaActual.Id);
								if(citaUpdate == null){
									citaUpdate = citaActual;
								}
								citaUpdate.Status = Label.CIT_ESTADO_DESASIGNADA;
								mapaCitasUpdate.put(citaUpdate.Id, citaUpdate);
							}
						}
					}//FIN: [After-Update] ACCIONES TRAS CAMBIAR EL RECURSO ASIGNADO A LA OT


					system.debug('<<<<<<<<<<<sera listaOrdenesAnuladas>>>>>>>>>>> ' + listaOrdenesAnuladas);
					if(!listaOrdenesAnuladas.isEmpty()){
						system.debug('<<<<<<sera entra crearAbonoWoAnulada');
						crearAbonoWoAnulada(listaOrdenesAnuladas);
					}
				}//FIN for(WorkOrder wo : triggerNew)

				// Crear a nivel de caso los check de facturado y liquidado
				// cuando tenga dicho check marcado todas las Ordenes de Trabajo no anuladas de ese caso.
				//casosLiquidadosOFacturados(triggerNew);
				//casosLiquidadosOFacturados(triggerNew,mapaOTsCaso);
				//casosLiquidadosOFacturados(woNoRevision,mapaOTsCaso);
				
                //if(!noReclamacionesFacturar.isEmpty())
                if(!woFacturar.isEmpty())
                    casosLiquidadosOFacturados(woFacturar,mapaOTsCaso);
				
                /*if(!reclamacionesFacturar.isEmpty()){
                    Set<Id> casoFacturar = new Set<Id>();
					for(Workorder wo: reclamacionesFacturar){
						casoFacturar.add(wo.CaseId);
					}
                    Map<Id,List<Propuesta_de_evento__c>> eventosDeCaso = Util_Propuesta_de_evento.pEventosByCaso(casoFacturar);
                    Map<Id,List<Propuesta_de_abono__c>> abonosDeCaso = Util_Propuesta_de_abono.pAbonosByCaso(casoFacturar);
                    
                    mapaCasosUpdate = Util_Caso.facturarCasoEventosAbonos(casoFacturar,eventosDeCaso,abonosDeCaso,mapaOTsCaso,mapaCasosUpdate);
                }*/

                // Se comprueba si todas las ordenes de trabajo estan en el estado "En Espera de confirmación por el Gestor"
                // Y si es asi se actualiza el estado del caso, tambien
                //Util_Siniestro.comprobarPendienteGestor(triggerNew, mapaCasos, mapaCasosUpdate);
                Util_Siniestro.comprobarPendienteGestor(woNoRevision, mapaCasos, mapaCasosUpdate);

                
                //Invocación del servicio de Actualización en Vesta de forma asíncrona
                //for(WorkOrder wo : triggerNew){
                for(WorkOrder wo : woNoRevision){
                    Case caso = mapaCasos.get(wo.CaseId);
                    if(Util_Siniestro.esSiniestro(caso)
                            && wo.Status != Label.OTR_ESTADO_ANULADO
                            && wo.Status != Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO
                            && wo.Status != Label.OTR_ESTADO_CERRADO
                            && wo.Status != triggerOldMap.get(wo.Id).Status){
                        System.debug('******Actualizacion en Vesta de forma asincrona (OT)');
                        Integer act = Integer.valueOf(caso.CAS_NUM_Id_Actuacion_SondeoExt__c);
                        Integer casoAct;
                        String tipoSiniWS;
                        String cia;
                        if(Util_Compania.CIA_BY_IDSF.get(caso.CAS_LKP_Compania__c) != null){
                            cia = Util_Compania.CIA_BY_IDSF.get(caso.CAS_LKP_Compania__c).CUE_TXT_Identificador__c; 
                        }
                        system.debug('242243');
                        if(caso.Type == label.CAS_TIPO_REPARABLE || caso.Type == label.CAS_TIPO_MIXTO){
                            casoAct = 3;
                            tipoSiniWS = '1';
                        }
                        else if(caso.Type == label.CAS_TIPO_INDEMNIZABLE){
                            casoAct = 4;
                            tipoSiniWS = caso.Type;
                        }
                        else if(caso.Type == label.CAS_TIPO_COBERTURA_ADICIONAL){
                            casoAct = 5;
                            tipoSiniWS = caso.Type;
                        }
					
                        if(act != null && tipoSiniWS != null && cia == label.IDE_MEMBERSHIP){
                            Callout_ActualizaSiniestroVesta_RQ datos = new Callout_ActualizaSiniestroVesta_RQ(act,casoAct,null,null,tipoSiniWS,null,null,null,'1','2');
                            //Serializa los datos para poder enviarlos en un String al método @future
                            String datosSerializados = JSON.serialize(datos);
                            //Llamada al callout de forma asíncrona
                            system.debug('00000000');
                            Callout_ActualizaSiniestroVesta.updateDatosAsync(datosSerializados);
						}
				
                    }
				}//Fin invocación del servicio de Actualización en Vesta de forma asíncrona 
				

			}//FIN TRIGGER  isUPDATE
			system.debug('<<<<<<<<<sera lista>>>>>>>' + woParaE21);
			if(!woParaE21.isEmpty()){
				crearEventoE21(woParaE21,triggerOldMap);
			}
			
			mapaCitasUpdate = Util_Orden_Trabajo.heredarDatosOTCita(mapaWoNoRevision, mapaCitasOTs, mapaCitasUpdate);

			// Se actualizan las fechas de las citas de servicio, si fuera necesario
			//mapaCitasUpdate = actualizarCitas(triggerNewMap, triggerOldMap, mapaCitasUpdate);
			mapaCitasUpdate = actualizarCitas(mapaWoNoRevision, mapaWoOldNoRevision, mapaCitasUpdate);

			//cambiosSemaforo(triggerNew, triggerOldMap);
			cambiosSemaforo(woNoRevision, triggerOldMap);
			
			// Notificaciones FSL
			//if(!Test.isRunningTest())
			//notificacionesFSL(triggerNew, triggerOldMap);
			notificacionesFSL(woNoRevision, triggerOldMap);
			
			//Calcular límites servicios
			//CalcularLimiteOrdenEnCurso(TriggerNew, TriggerOldMap, profesionalIdSetEnCurso);
			//CalcularLimiteOrdenMensual(TriggerNew, TriggerOldMap, profesionalIdSetMensual);

			CalcularLimiteOrdenEnCurso(woNoRevision, TriggerOldMap, profesionalIdSetEnCurso);
			CalcularLimiteOrdenMensual(woNoRevision, TriggerOldMap, profesionalIdSetMensual);
			generaMovs(triggerNew,TriggerOldMap,mapaCasos);
			if(!MapaProfesionalesUpdate.isEmpty()){
				update MapaProfesionalesUpdate.values();
			}
		}


		else if(Trigger.isDelete){
			Set<Id> setIdCasos = new Set<Id>();
			Set<String> setExtIdsDLC = new Set<String>();
			//for(WorkOrder wo : triggerOldMap.values()){
			for(WorkOrder wo : woOldNoRevision){
				if(wo.CaseId != null)
					casosShareRecalcular.add(wo.CaseId);
				setIdCasos.add(wo.caseId);
				if(wo.OTR_TXT_Identificador_DLC__c != null){
					setExtIdsDLC.add(wo.OTR_TXT_Identificador_DLC__c);
				}				
			}

            mapaCasos = Util_Caso.getCaseById(setIdCasos);
            //mapaCasos = Util_Caso.getMapaCasos(setIdCasos);
            Map<Id, List<WorkOrder>> mapaOTsCaso = Util_Orden_Trabajo.getMapaOTsCasos(setIdCasos);
			Map<String, Direcciones_B2B_B2B2C_Lineas_de_Contrato__c> mapaDLC = Util_B2B.getMapaDLC(setExtIdsDLC);

			//for(WorkOrder wo : triggerOldMap.values()){
			for(WorkOrder wo : woOldNoRevision){
				if(wo.CaseId != null){
					Case caso = mapaCasos.get(wo.CaseId);
					List<WorkOrder> listaOTsCaso = mapaOTsCaso.get(wo.CaseId);
					// Si se elimina una Orden de Trabajo reparable y no estaba en estado ANULADO:
					if(wo.Status != Label.OTR_ESTADO_ANULADO &&
					   wo.Status != Label.OTR_ESTADO_ANULADO_DESDE_INACTIVO){
						// Recalcular el importe total del Caso
						Case casoUpdate = mapaCasosUpdate.get(caso.Id);
						if(casoUpdate == null){
							// Se debe inicializar completo (todos los campos, no solo el Id)
							// porque luego se evalúan condiciones sobre casoUpdate
							casoUpdate = caso;
						}

						casoUpdate.CAS_DIV_Total_Facturar_CIA_AI__c = Util_Caso.calcularTotalFacturarCIA(listaOTsCaso);
						casoUpdate.CAS_DIV_Total_Facturar_Cliente_AI__c = Util_Caso.calcularTotalFacturarCliente(listaOTsCaso);
						casoUpdate.CAS_DIV_Total_Facturar_Profesional__c = Util_Caso.calcularTotalFacturarProfesional(listaOTsCaso);
						casoUpdate.CAS_CAS_Generar_Presupuesto__c = true;
						mapaCasosUpdate.put(casoUpdate.Id, casoUpdate);

						// Incrementar el saldo de la Línea de Contrato si aplica
						String idDLCold = wo.OTR_TXT_Identificador_DLC__c;
						if(idDLCold != null && mapaDLC.get(idDLCold).DLC_NUM_Servicios_restantes__c != null){
							Integer restantes = Integer.valueOf(mapaDLC.get(idDLCold).DLC_NUM_Servicios_restantes__c);
							restantes++;
							// Incrementar el saldo si no supera el límite de la Línea de Contrato
							if(restantes <= Integer.valueOf(mapaDLC.get(idDLCold).DLC_FOR_Linea_Contrato_LimServ__c)){
								Id dlcId = mapaDLC.get(idDLCold).Id;
								Direcciones_B2B_B2B2C_Lineas_de_Contrato__c dlcUpdate = mapaDLCUpdate.get(dlcId);
								if(dlcUpdate == null){
									dlcUpdate = new Direcciones_B2B_B2B2C_Lineas_de_Contrato__c(Id=dlcId);
								}
								dlcUpdate.DLC_NUM_Servicios_restantes__c = restantes;  
								mapaDLCUpdate.put(dlcId, dlcUpdate); 
							}
						}
					}
				}
			}
		}


		// Actualizar shares de los casos y las wo
		if(!casosShareRecalcular.isEmpty()){
			system.debug('------casosShareRecalcular: '+casosShareRecalcular);
			Util_caso.recalcularShares(casosShareRecalcular);
		}


		// INSERTAR TAREAS NUEVAS
		if(listaTareasInsert != null && !listaTareasInsert.isEmpty()){
			insert listaTareasInsert;
		}

		// ACTUALIZAR OBJETOS DIR-LINEACONTRATO ACTUALIZADOS
		system.debug('>>>>mapaDLCUpdate antes de update ' + mapaDLCUpdate);
		if(mapaDLCUpdate != null && (!mapaDLCUpdate.isEmpty())){
			update mapaDLCUpdate.values();
		}


		// INSERTAR OBJETOS SKILLS DE LA ORDEN DE TRABAJO
		system.debug('>>>>listaSkillsOTinsert antes de insert ' + listaSkillsOTinsert);
		if(listaSkillsOTinsert != null && (!listaSkillsOTinsert.isEmpty())){
			insert listaSkillsOTinsert;
		}


		// BORRAR E INSERTAR RECURSOS ASIGNADOS
		if(recursoAsignadoBorrar != null && !recursoAsignadoBorrar.isEmpty()){
			delete recursoAsignadoBorrar;
		}
		if(recursoAsignadoInsertar != null && !recursoAsignadoInsertar.isEmpty()){
			insert recursoAsignadoInsertar;
		}


		// ACTUALIZAR OBJETOS PARTIDA
		system.debug('>>>>mapaPartidasUpdate antes de update ' + mapaPartidasUpdate);
		if(mapaPartidasUpdate != null && (!mapaPartidasUpdate.isEmpty())){
			update mapaPartidasUpdate.values();
		}


		// ACTUALIZAR OBJETOS CITA
		system.debug('>>>>mapaCitasUpdate antes de update ' + mapaCitasUpdate);
		if(mapaCitasUpdate != null && (!mapaCitasUpdate.isEmpty())){
			update mapaCitasUpdate.values();
		}


		// ACTUALIZAR OBJETOS CASO
		system.debug('>>>>mapaCasosUpdate antes de update ' + mapaCasosUpdate);
		if(mapaCasosUpdate != null && (!mapaCasosUpdate.isEmpty())){
			update mapaCasosUpdate.values();
		}

		// Tratamiento Objeto Servicio (MKT):
		if(Trigger.isInsert || Trigger.isUpdate){
			Util_SincronizacionMKT.sincronizarOTs(triggerNewMap, triggerOldMap);
		}
	}


	/**
	  * [PENDIENTE]
	  * 
	  * @param listaNuevasOT: [PENDIENTE]
	  * @param mapaViejasOT: [PENDIENTE]
	  * 
	  */
	private static void cambiosSemaforo(List<WorkOrder> listaNuevasOT, Map<Id,WorkOrder> mapaViejasOT){
		//Si se ha producido un cambio de estado, 
		//se debe consultar en el custom metadata 'Orden de trabajo' tomando como filtro la compañía y el nuevo estado 
		//y se debe crear una tarea asociada a esta orden de trabajo
		//List<WorkOrder> crearEventos = new List<WorkOrder>();
		for(WorkOrder wo : listaNuevasOT){
			String identificadorCIA = Label.IDE_HOMESERVE;
			if(!String.isBlank(wo.OTR_FOR_Identificador_CIA__c)){
				identificadorCIA = wo.OTR_FOR_Identificador_CIA__c;
			}
			Orden_de_trabajo__mdt oTMTMD = Util_Metadatos.mapaOTEstadoCIA.get(wo.Status + '' + identificadorCIA);

			if(oTMTMD == null)
				oTMTMD = Util_Metadatos.mapaOTEstadoCIA.get(wo.Status + '' + Label.IDE_HOMESERVE);

			//Si el estado ha cambiado o si la OT es nueva
			if(mapaViejasOT != null){
				if(wo.OTR_NUM_Horas_verde__c != null && wo.OTR_NUM_Horas_amarillo__c != null){

					if(wo.OTR_DAT_Generar_Tarea_Semaforo__c == null && mapaViejasOT.get(wo.Id).OTR_DAT_Generar_Tarea_Semaforo__c != null){
						//se creará una lista de tareas asociadas a la orden de trabajo, 
						//con usuario dueño el mismo que la orden de trabajo, 
						//la prioridad requerida y 
						//la fecha de vencimiento igual a la fecha actual más la duración estimada
						if(oTMTMD != null){
							/*if(oTMTMD.MTD_OTR_CAS_Evento__c == true){
								crearEventos.add(wo);
							}*/
							Case caso = mapaCasos.get(wo.CaseId);
							Task tarea = Util_Tarea.crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_CAMBIO_ESTADO_OT, Label.TAR_ESTADO_EN_CURSO, 
								oTMTMD.MTD_OTR_TXT_Tipo_Tarea__c, caso.OwnerId, wo.Id, caso.CAS_LKP_Compania__c);
							tarea.Description = oTMTMD.MTD_OTR_TXT_Descripcion_Tarea__c;
							//system.debug('***** oTMTMD.MTD_OTR_NUM_Duracion_estimada__c : ' + oTMTMD.MTD_OTR_NUM_Duracion_estimada__c);
							if(oTMTMD.MTD_OTR_NUM_Duracion_estimada__c != null){
								tarea.ActivityDate = Date.today().addDays((Integer)oTMTMD.MTD_OTR_NUM_Duracion_estimada__c);
							}
							listaTareasInsert.add(tarea);
						}
					}   
				}	   
			}
		}
	}//FIN cambiosSemaforo



	/**
	  * [PENDIENTE]
	  * 
	  * @param triggerNewMap: [PENDIENTE]
	  * @param triggerOldMap: [PENDIENTE]
	  * @param mapaCitasUpdate: [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */
	private static Map<Id,ServiceAppointment> actualizarCitas(Map<Id, WorkOrder> triggerNewMap, Map<Id, WorkOrder> triggerOldMap, Map<Id,ServiceAppointment> mapaCitasUpdate){
		system.debug('<<<<Dentro de actualizarCitas');

		if(mapaCitasUpdate == null)
			mapaCitasUpdate = new Map<Id,ServiceAppointment>();

		List<ServiceAppointment> listaCitas = new List<ServiceAppointment>();
		Map<Id, List<ServiceAppointment>> mapaCitasDeOT = new Map<Id, List<ServiceAppointment>>();
		Set<Id> idsOT = new Set<Id>();
		Set<Id> idsOTsFranq = new Set<Id>();
		Map<Id, Integer> mapaHorasUrgentOt;
		for(WorkOrder ot: triggerNewMap.values()){
			// Mizad
			if((triggerOldMap == null 
					|| ot.OTR_DAT_Fecha_Primera_Cita__c != triggerOldMap.get(ot.Id).OTR_DAT_Fecha_Primera_Cita__c
					|| ot.OTR_SEL_Rango_Primera_Cita__c != triggerOldMap.get(ot.Id).OTR_SEL_Rango_Primera_Cita__c
					|| ot.OTR_SEL_Tipo_Red__c != triggerOldMap.get(ot.Id).OTR_SEL_Tipo_Red__c
					|| ot.OTR_CAS_Asignar_Mizad__c != triggerOldMap.get(ot.Id).OTR_CAS_Asignar_Mizad__c)){
				idsOT.add(ot.Id);
			}

			// Franquiciado
			if(triggerOldMap == null
					||ot.OTR_CAS_Asignar_Como_Franquiciado__c != triggerOldMap.get(ot.Id).OTR_CAS_Asignar_Como_Franquiciado__c
					||ot.OTR_CAS_Asignar_territorio_prim_no_franq__c != triggerOldMap.get(ot.Id).OTR_CAS_Asignar_territorio_prim_no_franq__c){
				idsOTsFranq.add(ot.Id);
			}
		}

		if(!idsOT.isEmpty() || !idsOtsFranq.isEmpty()){
            Set<Id> setIdOTJuntado = new Set<Id>();
            setIdOTJuntado.addAll(idsOT);
            setIdOTJuntado.addAll(idsOTsFranq);
            listaCitas = Util_Cita_Servicio.getMapCitasByOTs(setIdOTJuntado).values();
			mapaHorasUrgentOt = recogerConfProgCita(idsOT);
		}
		for(ServiceAppointment cita : listaCitas){
			List<ServiceAppointment> citasOT;
			if(mapaCitasDeOT.containsKey(cita.ParentRecordId)){
				citasOT = mapaCitasDeOT.get(cita.ParentRecordId);
			}else{
				citasOT = new List<ServiceAppointment>();
			}
			citasOT.add(cita);
			mapaCitasDeOT.put(cita.ParentRecordId, citasOT);
		}

		for(WorkOrder ot: triggerNewMap.values()){
			List<ServiceAppointment> citasOT = mapaCitasDeOT.get(ot.Id);
			system.debug('<<<<citasOT ' + citasOt);
			if(citasOT != null){
				// Si se ha cambiado la fecha o el rango de la primera cita se actualiza el plazo de la cita de servicio asociada
				// Si se han cambiado las variables Mizad, se propagan a las citas de servicio
				String horaIni;
				String horaFin;
				if(ot.OTR_SEL_Rango_Primera_Cita__c != null
						&& ot.OTR_SEL_Rango_Primera_Cita__c != null){
					String labelRango = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'OTR_SEL_Rango_Primera_Cita__c').get(ot.OTR_SEL_Rango_Primera_Cita__c);
					system.debug('>>>>labelRango ' + labelRango);
					List<String> listaHoras = labelRango.split(' - ');
					horaIni = listaHoras.get(0).split(':').get(0);
					horaFin = listaHoras.get(1).split(':').get(0);
				}
				Integer aplazamiento = mapaHorasUrgentOt.get(ot.Id);
				system.debug('>>>>aplazamiento recogido ' + aplazamiento);
				for(ServiceAppointment cita : citasOT){
					ServiceAppointment citaUpdate = mapaCitasUpdate.get(cita.Id);
					if(citaUpdate == null){
						// Se debe inicializar completo (todos los campos, no solo el Id)
						// porque luego se evalúan condiciones sobre citaUpdate
						citaUpdate = cita;
					}
					Boolean actualizada = false;
					if(aplazamiento != null){
						// La fecha de inicio mas temprana se corresponderia con el aplazamiento obtenido
						citaUpdate.EarliestStartTime = DateTime.now().addHours(aplazamiento);
						actualizada = true;
						system.debug('>>>>Cita empiece temprano ' + citaUpdate.EarliestStartTime);
					}
					else if(ot.OTR_DAT_Fecha_Primera_Cita__c != null && horaIni != null && horaFin != null){
						citaUpdate.ArrivalWindowStartTime = DateTime.newInstance(ot.OTR_DAT_Fecha_Primera_Cita__c.year(), ot.OTR_DAT_Fecha_Primera_Cita__c.month(), 
								ot.OTR_DAT_Fecha_Primera_Cita__c.day(), Integer.valueOf(horaIni), 0, 0);
						citaUpdate.ArrivalWindowEndTime =  DateTime.newInstance(ot.OTR_DAT_Fecha_Primera_Cita__c.year(), ot.OTR_DAT_Fecha_Primera_Cita__c.month(), 
								ot.OTR_DAT_Fecha_Primera_Cita__c.day(), Integer.valueOf(horaFin), 0, 0); 
						actualizada = true;
					}

					system.debug('<<<<citaUpdate + ' + citaUpdate);
					// Mizad
					if(idsOT.contains(ot.Id)){
						if(ot.OTR_SEL_Tipo_Red__c != citaUpdate.CSE_SEL_Tipo_Red__c){
							citaUpdate.CSE_SEL_Tipo_Red__c = ot.OTR_SEL_Tipo_Red__c;
							actualizada = true;
						}
						if(ot.OTR_CAS_Asignar_Mizad__c != citaUpdate.CSE_CAS_Asignar_Mizad__c){
							citaUpdate.CSE_CAS_Asignar_Mizad__c = ot.OTR_CAS_Asignar_Mizad__c;
							actualizada = true;
						}
					}
					// Franquiciado
					if(idsOTsFranq.contains(ot.Id)){
						if(ot.OTR_CAS_Asignar_Como_Franquiciado__c != citaUpdate.CSE_CAS_Asignar_Como_Franquiciado__c){
							citaUpdate.CSE_CAS_Asignar_Como_Franquiciado__c = ot.OTR_CAS_Asignar_Como_Franquiciado__c;
							actualizada = true;
						}
						if(ot.OTR_CAS_Asignar_territorio_prim_no_franq__c != citaUpdate.CSE_CAS_Asignar_territorio_prim_no_franq__c){
							citaUpdate.CSE_CAS_Asignar_territorio_prim_no_franq__c = ot.OTR_CAS_Asignar_territorio_prim_no_franq__c;
							actualizada = true;
						}
						system.debug('<<<<franquiciado' + ot.OTR_CAS_Asignar_Como_Franquiciado__c);
					}
					if(actualizada)
						mapaCitasUpdate.put(citaUpdate.Id,citaUpdate);
				}
			}   
		}

		system.debug('>>>>mapaCitasUpdate: ' + mapaCitasUpdate);
		return mapaCitasUpdate;
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param idsOTs: [PENDIENTE]
	  * 
	  * @return [PENDIENTE]
	  */
	private static Map<Id, Integer> recogerConfProgCita(Set<Id> idsOTs){
		Map<Id, Integer> mapaHorasUrgentOt = new Map<Id, Integer>();
		// Recoger Ots
        List<WorkOrder> listaOts = Util_Orden_Trabajo.getOTByIdConCodPostalYCompania(idsOTs).values();
        /*List<WorkOrder> listaOts = new List<WorkOrder>([
                                                        SELECT  Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c, ServiceTerritory.PostalCode, OTR_CAS_Urgente__c
														FROM	WorkOrder
														WHERE   Id IN: idsOTs
														AND Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c != null

                                                        AND ServiceTerritory.PostalCode != null]);*/

		Set<String> codigosCia = new Set<String>();
		Set<String> segmentaciones = new Set<String>();
		for(WorkOrder ot : listaOts){
			String idCuenta = ot.Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c;
            String segmentacion = '';/* ot.Account.CUE_FOR_Segmentacion__c;*/
			codigosCia.add(idCuenta);
			segmentaciones.add(segmentacion);
		}

		// Recoger Conf Prog
        List<Programacion_cita__mdt> listaConfs = Util_Metadatos.getProgCitaByIdCIAAndSegment(codigosCia,segmentaciones).values();
        /*List<Programacion_cita__mdt> listaConfs = new List<Programacion_cita__mdt>([
																					SELECT  PRC_TXT_Identificador_CIA__c, PRC_TXT_Segmentacion__c, PRC_CAS_Capital_Provincia__c, PRC_NUM_Plazo__c
																					FROM	Programacion_cita__mdt
																					WHERE   PRC_TXT_Identificador_CIA__c IN :codigosCia
																					AND PRC_TXT_Segmentacion__c IN :segmentaciones
                                                                                    AND PRC_NUM_Plazo__c != null]);*/

		// Se ordenan las confs en un mapa
		Map<String, Integer> mapaConfs = new Map<String, Integer>();
		for(Programacion_cita__mdt conf : listaConfs){
			String clave = conf.PRC_TXT_Identificador_CIA__c + '_' + conf.PRC_TXT_Segmentacion__c + '_' + conf.PRC_CAS_Capital_Provincia__c;
			if(!mapaConfs.containsKey(clave)){
				mapaConfs.put(clave, Integer.valueOf(conf.PRC_NUM_Plazo__c));
				system.debug('>>>>mapaConfs.put ' + clave + ' - ' + conf.PRC_NUM_Plazo__c);
			}
		}

		// Se recoge el aplazamiento de la cita para cada wo
		for(WorkOrder ot : listaOts){
			if(ot.OTR_CAS_Urgente__c){
				String idCuenta = ot.Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c;
                String segmentacion = ''; /*ot.Account.CUE_FOR_Segmentacion__c;*/
				Boolean capitalProvincia = ot.ServiceTerritory.PostalCode.subString(2,3) == '0';
				String claveMapa = idCuenta + '_' + segmentacion + '_' + capitalProvincia;
				system.debug('>>>>claveMapa ' + claveMapa);
				Integer aplazamiento = mapaConfs.get(claveMapa);
				system.debug('>>>>aplazamiento ' + aplazamiento);
				if(aplazamiento != null){
					mapaHorasUrgentOt.put(ot.Id, aplazamiento);
				}
			}
		}

		return mapaHorasUrgentOt;
	}


	/**
	  * [PENDIENTE]
	  * 
	  * @param woNewList: [PENDIENTE]
	  * @param woOldMap: [PENDIENTE]
	  * 
	  */
	public static void calcularLimiteOrdenEnCurso (List<WorkOrder> woNewList, Map<Id, WorkOrder> woOldMap, Set<Id> profesionalIdSet){		

		if(!profesionalIdSet.isEmpty()){
			//Sacamos el número de servicios en curso por cada profesional
            List<AggregateResult> numeroWOProfesionalEnCurso = Util_Orden_Trabajo.getOTCountIdByProfesionalAndNotInStatus(profesionalIdSet,Util_Orden_Trabajo.SET_ESTADOS_NO_ENCURSO).values();
            /*List<AggregateResult> numeroWOProfesionalEnCurso = [Select count(Id)numWO, OTR_LKP_Recurso_Servicio__c  from WorkOrder 
																where OTR_LKP_Recurso_Servicio__c IN: profesionalIdSet and Status not in :Util_Orden_Trabajo.SET_ESTADOS_NO_ENCURSO
                                                                group by OTR_LKP_Recurso_Servicio__c];*/
	
			//Rellenamos el campo con el valor obtenido para todos los profesionales que se han encontrado en la query y borramos sus Ids del set
			for(AggregateResult ar: numeroWOProfesionalEnCurso){
				if((Decimal)ar.get('numWO') != mapaProfesionales.get((Id)ar.get('OTR_LKP_Recurso_Servicio__c')).RSE_NUM_Numero_Ordenes_Trabajo_En_Curso__c){
					ServiceResource prof = mapaProfesionales.get((Id)ar.get('OTR_LKP_Recurso_Servicio__c'));
					prof.RSE_NUM_Numero_Ordenes_Trabajo_En_Curso__c = (Decimal)ar.get('numWO');
					mapaProfesionalesUpdate.put(prof.Id, prof);
				}
				profesionalIdSet.remove((Id)ar.get('OTR_LKP_Recurso_Servicio__c'));
			}
			//Tras la acción anterior, el set se queda solo con los profesionales no encontrados en la query y, por tanto, sin servicios en curso. Para estos casos el campo se rellena a 0.
			for(ServiceResource sr: mapaProfesionales.values()){
				if(profesionalIdSet.contains(sr.Id)){
					sr.RSE_NUM_Numero_Ordenes_Trabajo_En_Curso__c = 0;
					mapaProfesionalesUpdate.put(sr.Id, sr);
				}
			}
		}
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param woNewList: [PENDIENTE]
	  * @param woOldMap: [PENDIENTE]
	  * 
	  */
	public static void calcularLimiteOrdenMensual (List<WorkOrder> woNewList, Map<Id, WorkOrder> woOldMap, Set<Id> profesionalIdSet){
		
		if(!profesionalIdSet.isEmpty()){
			//Sacamos el número de servicios creados el mes en curso por cada profesional
            List<AggregateResult> numeroWOProfesionalMensual = Util_Orden_Trabajo.getOTCountIdByProfesionalEsteMes(profesionalIdSet).values();
            /*List<AggregateResult> numeroWOProfesionalMensual = [Select count(Id)numWO, OTR_LKP_Recurso_Servicio__c  from WorkOrder 
																where OTR_LKP_Recurso_Servicio__c IN: profesionalIdSet and CreatedDate = THIS_MONTH
                                                                group by OTR_LKP_Recurso_Servicio__c];*/
	
			//Rellenamos el campo con el valor obtenido para todos los profesionales que se han encontrado en la query y borramos sus Ids del set
			for(AggregateResult ar: numeroWOProfesionalMensual){
				if((Decimal)ar.get('numWO') != mapaProfesionales.get((Id)ar.get('OTR_LKP_Recurso_Servicio__c')).RSE_NUM_NumOT_Mensual_Con_Sin_Franquicia__c){
					ServiceResource prof = mapaProfesionales.get((Id)ar.get('OTR_LKP_Recurso_Servicio__c'));
					prof.RSE_NUM_NumOT_Mensual_Con_Sin_Franquicia__c = (Decimal)ar.get('numWO');
					mapaProfesionalesUpdate.put(prof.Id, prof);
				}
				profesionalIdSet.remove((Id)ar.get('OTR_LKP_Recurso_Servicio__c'));
			}
			//Tras la acción anterior, el set se queda solo con los profesionales no encontrados en la query y, por tanto, sin servicios creados el mes en curso. Para estos casos el campo se rellena a 0.
			for(ServiceResource sr: mapaProfesionales.values()){
				if(profesionalIdSet.contains(sr.Id)){
					sr.RSE_NUM_NumOT_Mensual_Con_Sin_Franquicia__c = 0;
					mapaProfesionalesUpdate.put(sr.Id, sr);
				}
			}
		}
	}

	/**
	  * [Metodo usado para encolar los callouts del facturador]
	  * 
	  * @param wo: [Lista con la información nueva de la WO]
	  * @param woOld: [Lista con la información anterior a modificar la WO]
	  * @param service: [Servicio que se va a facturar]
	  * 
	  */
	public static void calloutFacturador (List<WorkOrder> wo,List<WorkOrder> woOld, String service, String nombreIntegracion){
		for(WorkOrder woOldId:woOld){
		for(WorkOrder woId:wo){
				comparoYencolo(woOldId, woId,service,nombreIntegracion);
			}
		}
	}
	
	private static void comparoYencolo(WorkOrder woOldId, WorkOrder woId,String service, String nombreIntegracion){
		system.debug('>>>>>DentroComparoYEncolo');
		String idBitacora = '';
		if(woOldId.Id == woId.Id){
            if((woId.Status == Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN || woId.Status == Label.OTR_ESTADO_REVISADO || woId.Status == Label.OTR_ESTADO_ANULADO || (woId.Status == Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO && woOldId.Status != Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN)) && (woOldId.Status != woId.Status) && (woId.OTR_CAS_Orden_Trabajo_Facturada__c == false)){
				String idCaso = woId.CaseId;
                List<Case> ListaCasos = Util_Caso.getCaseById(new Set<Id>{idCaso}).values();
                //List<Case> ListaCasos = new List<Case>([SELECT Id, RecordTypeId FROM case WHERE id= :idCaso]);
				if(listaCasos!= null &&  !listaCasos.isEmpty()){
					Case caso = new Case();
					caso = listaCasos.get(0);
					if(caso.RecordTypeId  == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO) || caso.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C) || caso.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C)){
						Map<Id, String> mapaOTR = new Map<Id, String>();
						idBitacora = '';
						mapaOTR.put(woId.Id, 'WorkOrder');
						Util_Llamada_Externa n = new Util_Llamada_Externa(mapaOTR,'Facturador',service,'');
						System.enqueueJob(n);
					}
				}
			}
		}
	}

	/**
	  * [Metodo usado por el trigger TRG_Orden_de_Trabajo]
	  * 
	  * @param wo: [Lista de WorkOrder que se tocan en el trigger TRG_Orden_de_Trabajo]
	  * 
	  */
	/* METODO COMENTADO PORQUE NO SE ESTÁ USANDO EN NINGUN LADO
	 * 
	public static void maestroClientesTRG (List<WorkOrder> wo){
		for(WorkOrder woId:wo){
			if(woId.Status == '501' || woId.Status == '997' || woId.Status == '402' || woId.Status == '994'){
				Map<Id, String> mapaOTR = new Map<Id, String>();
				mapaOTR.put(woId.Id, 'WorkOrder');
				String idBitacora = Util_Llamada_Externa.insertarBitacora(Label.FAC_Facturador,'','01','02',	label.FAC_Maestro_Clientes,'','',
														'','','','',woId.Id,'',0,'',0,Label.Callout_PUT);
				Util_Llamada_Externa n = new Util_Llamada_Externa(mapaOTR,'Facturador',label.FAC_Maestro_Clientes,idBitacora);
				System.enqueueJob(n);
			}
		}
	}
	
	*/
	/**
	  * [Metodo usado por el trigger TRG_Orden_de_Trabajo]
	  * 
	  * @param listaServicios: [Lista de WorkOrder que se tocan en el trigger TRG_Orden_de_Trabajo]
	  * @param mapaServiciosOld: [Mapa de WorkOrder antiguas que se tocan en el trigger TRG_Orden_de_Trabajo] 
	  *
	  */
	private static void notificacionesFSL(List<WorkOrder> listaServicios, Map<Id,WorkOrder> mapaServiciosOld){
		// Si los parametros no son nulos
		if(listaServicios != null && mapaServiciosOld != null
		 && !listaServicios.isEmpty() && !mapaServiciosOld.isEmpty()){
			// Obtencion de los profesionales asociados a los servicios
			Set<Id> setIdsProfesionales = new Set<Id>();
			for(WorkOrder servicio : listaServicios){
				if(servicio.OTR_LKP_Recurso_Servicio__c != null
				 && !setIdsProfesionales.contains(servicio.OTR_LKP_Recurso_Servicio__c)){
					setIdsProfesionales.add(servicio.OTR_LKP_Recurso_Servicio__c);
				}
			}
			if(!setIdsProfesionales.isEmpty()){
                Map<Id,ServiceResource> mapaProfesionales = Util_Service_Resource.getSRByIdAndRelatedRecordNotNull(setIdsProfesionales);
                /*Map<Id,ServiceResource> mapaProfesionales = new Map<Id,ServiceResource>(
					[SELECT RelatedRecordId
					 FROM ServiceResource
					 WHERE Id IN :setIdsProfesionales
                     AND RelatedRecordId != null]);*/
				// Se generan notificaciones para las ordenes de trabajo correspondientes
				for(WorkOrder servicio : listaServicios){
					WorkOrder servicioOld = mapaServiciosOld.get(servicio.Id);
					// Si el estado del Servicio ha cambiado
					if(servicioOld != null && servicio.Status != servicioOld.Status){
						ServiceResource profesional = mapaProfesionales.get(servicio.OTR_LKP_Recurso_Servicio__c);
						if(profesional != null){
							ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
							ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
							ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
							ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
							
							messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
							
							mentionSegmentInput.id = profesional.RelatedRecordId;
							messageBodyInput.messageSegments.add(mentionSegmentInput);
							// ¿Texto provisional?
							textSegmentInput.text = ' El estado del servicio ' + servicio.WorkOrderNumber 
								+ ' ha cambiado a ' + Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder', 'Status').get(servicio.Status);
							messageBodyInput.messageSegments.add(textSegmentInput);
							
							feedItemInput.body = messageBodyInput;
							feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
							feedItemInput.subjectId = servicio.Id;
							if(!Test.isRunningTest())
								ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
						}
					}
				}
			}
		}
	}

	/**
	 * Método para actualizar los casos con todas sus órdenes de trabajo facturadas/liquidadas.
	 *
	 * @param triggerNew: órdenes de trabajo actualizadas
	 */
	private static void casosLiquidadosOFacturados(List<WorkOrder> triggerNew, Map<Id,List<WorkOrder>> mapCasosOT){
		Set<Id> setIdCasos = new Set<Id>();
		Boolean liquidado;
		Boolean facturado;
		Boolean actualizar;
		for(WorkOrder wo : triggerNew){
			setIdCasos.add(wo.CaseId);
		}
		//Map<Id,List<WorkOrder>> mapCasosOT = Util_Orden_Trabajo.getMapCasosOTRelacionadas(setIdCasos);
		//Map<Id,Case> mapaCasosActualizar = Util_Caso.getMapaCasos(setIdCasos);
		if(!mapCasosOT.isEmpty()){
			for(Id casoId: setIdCasos){
			//for(Case casoActualizar : mapaCasosActualizar.values()){
				Case casoOrig = mapaCasos.get(casoId);
				List<WorkOrder> ordenes = mapCasosOt.get(casoId);
				
				if(casoOrig != null && ordenes != null && !ordenes.isEmpty() && (!casoOrig.CAS_CAS_Siniestro_Facturado__c || !casoOrig.CAS_CAS_Liquidado__c)) {
					Case casoActualizar = mapaCasosUpdate.get(casoId);
					if(casoActualizar == null){
						//casoActualizar = new Case(Id=casoId);
						// Se debe inicializar completo (todos los campos, no solo el Id)
						// porque luego se evalúan condiciones sobre casoActualizar
						casoActualizar = casoOrig;
					}
					actualizar = false;
					system.debug('[AMC] este caso puede ser actualizado');
					facturado = true;
					liquidado = true;
					for(WorkOrder wo : ordenes){
												
						system.debug('--------wo: '+wo);
						if(!wo.OTR_CAS_Orden_Trabajo_Facturada__c){
							facturado = false;
						}
						if(!wo.OTR_CAS_Orden_Trabajo_Liquidada__c){
							liquidado = false;
						}
					}
					if (facturado && !casoOrig.CAS_CAS_Siniestro_Facturado__c) {
						system.debug('[AMC] caso facturado');
						casoActualizar.CAS_CAS_Siniestro_Facturado__c = true;
						actualizar = true;
					}
					if (liquidado && !casoOrig.CAS_CAS_Liquidado__c) {
						system.debug('[AMC] caso liquidado');
						casoActualizar.CAS_CAS_Liquidado__c = true;
						actualizar = true;
					}
					if(actualizar) {
						mapaCasosUpdate.put(casoActualizar.Id,casoActualizar);
					}
					
				}
			}
		}
	}

	private static void crearAbonoWoAnulada(List<WorkOrder> woList){

		Propuesta_de_Abono__c abonoCom = new Propuesta_de_Abono__c();
		Propuesta_de_Abono__c abonoCli = new Propuesta_de_Abono__c();
		List<Propuesta_de_Abono__c> abonoList = new List<Propuesta_de_Abono__c>();
		List<Id> idList = new List<Id>();

		for(WorkOrder work: woList){
			idList.add(work.CaseId);
		}

		Map<ID, Case> mapaCasos = Util_Caso.getCaseById(new Set<Id>(idList));
        //Map<ID, Case> mapaCasos = new Map<ID, Case>([SELECT Id, CAS_LKP_Cliente_contable_cliente__c, CAS_LKP_Cliente_contable__c FROM Case WHERE Id IN :idList]);

		for(Workorder wo: woList){

			abonoCom.AB_LKP_Ingresar_a__c = mapaCasos.get(wo.CaseId).CAS_LKP_Cliente_contable_cliente__c;
			abonoCom.AB_SEL_Departamento_Solicitante__c = '4';
			abonoCom.AB_CAS_Abono_Automatico__c = true;
			abonoCom.AB_LKP_Caso__c = wo.CaseId;
			abonoCom.AB_SEL_Estado__c = '02';
			abonoCom.AB_CAS_Abono_Automatico__c = true;
			abonoCom.AB_LKP_Orden_de_Trabajo__c = wo.id;
			abonoCom.AB_LKP_Cuenta__c = wo.AccountId;
			abonoCom.AB_DIV_Importe_a_ingresar__c = wo.OTR_RES_Facturar_Cliente_DI__c;
			abonoCom.AB_DIV_Importe_a_Imputar4__c = wo.OTR_RES_Facturar_Cliente_DI__c;
			abonoCom.AB_LKP_Imputar_a4__c = wo.OTR_LKP_Recurso_Servicio__c;
			abonoList.add(abonoCom);

			abonoCli.AB_LKP_Ingresar_a__c = mapaCasos.get(wo.CaseId).CAS_LKP_Cliente_contable__c;
			abonoCli.AB_SEL_Departamento_Solicitante__c = '4';
			abonoCli.AB_CAS_Abono_Automatico__c = true;
			abonoCli.AB_LKP_Caso__c = wo.CaseId;
			abonoCli.AB_LKP_Cuenta__c = wo.AccountId;
			abonoCli.AB_LKP_Orden_de_Trabajo__c = wo.id;
			abonoCli.AB_SEL_Estado__c = '02';
			abonoCli.AB_CAS_Abono_Automatico__c = true;
			abonoCli.AB_DIV_Importe_a_ingresar__c = wo.OTR_RES_Facturar_Compania_DI__c;
			abonoCli.AB_DIV_Importe_a_Imputar4__c = wo.OTR_RES_Facturar_Compania_DI__c;
			abonoCli.AB_LKP_Imputar_a4__c = wo.OTR_LKP_Recurso_Servicio__c;
			abonoList.add(abonoCli);
		}

		if(!abonoList.isEmpty()){
			insert abonoList;
		}
	}

	private static void crearEventoE21(List<Workorder> woList,Map<Id,Workorder> woMapOld){
		system.debug('<<<<<<<<<sera E21>>>>>');
		Datetime fCambioSemaforo;
		Propuesta_de_Evento__c evento = new Propuesta_de_Evento__c();
		Decimal importe;
		integer dias;
		Decimal diferencia;
		for(Workorder wo: woList){
			Workorder woOld = woMapOld.get(wo.Id);

			importe = decimal.valueOf(Label.IMPORTE_EVENTO_E21_INICIAL);
			//fCambioSemaforo = wo.OTR_DAT_Fecha_cambio_estado__c.addMinutes((wo.OTR_NUM_Horas_verde__c*24*60).intValue() + (wo.OTR_NUM_Horas_amarillo__c*24*60).intValue());
			//fCambioSemaforo = woOld.OTR_DAT_Fecha_cambio_estado__c.addMinutes((woOld.OTR_NUM_Horas_verde__c*24*60).intValue() + (woOld.OTR_NUM_Horas_amarillo__c*24*60).intValue());
			fCambioSemaforo = woOld.OTR_DAT_Fecha_Hora_Cambio_semaforo__c;
			diferencia = (system.now().getTime() - fCambioSemaforo.getTime())/(24 * 60 * 60 * 1000);
			dias = diferencia.intValue();

			if(dias > 1){
				importe += (dias-1) * decimal.valueOf(Label.IMPORTE_EVENTO_E21_SUCESIVO);
			}
			system.debug('<<<<<<<<<sera E21 importe>>>>>' + importe);
			//evento.EV_AB_LKP_Imputar_a_profesional__c = wo.OTR_LKP_Recurso_Servicio__c;
			evento.EV_AB_LKP_Imputar_a_profesional__c = woOld.OTR_LKP_Recurso_Servicio__c;
			if(evento.EV_AB_LKP_Imputar_a_profesional__c == null)
				continue;
				
			evento.EV_AB_DIV_Importe_profesional__c = importe;
			evento.EV_AB_SEL_Tipo_de_Evento__c = Label.TIPO_EVENTO_COBRO;
			evento.EV_AB_SEL_Descripcion__c = Label.AB_DESCRIPCION_EVENTO_E21;
			evento.EV_AB_LKP_Orden_de_Trabajo__c = wo.Id;
			evento.EV_AB_SEL_Departamento_Solicitante__c = Label.PAB_DEPT_AUDITORIA_GESTION;
			evento.EV_AB_SEL_Estado__c = Label.EV_AB_ESTADO_APROBADO;
			evento.EV_AB_LKP_Caso__c = wo.CaseId;
			evento.EV_AB_SEL_Departamento_Solicitante__c = Label.PAB_DEPT_AUDITORIA_GESTION;
			evento.EV_AB_CAS_Evento_Automatico__c = true;
			//Temporal
			evento.EV_AB_CAS_Evento_Bloqueado__c = true;
	
			insert evento;
			system.debug(evento + 'eventoooooo');
		}
	}
	
	
	private static void generaMovs(List<Workorder> woList,Map<Id,Workorder> woMapOld,Map<Id,Case> mapaCasos){
		for(Workorder wo:woList){
			if(Util_Siniestro.esSiniestro(mapaCasos.get(wo.CaseId))){
				if(wo.Status==Label.OTR_ESTADO_ANULADO && (woMapOld.get(wo.Id).Status == Label.OTR_ESTADO_PDTE_ATENCION_PROF||woMapOld.get(wo.Id).Status== Label.OTR_ESTADO_PDTE_ASIGNAR_NORMAL)){
					Util_Movimientos.compruebaEnviable(mapaCasos.get(wo.CaseId).Id, mapaCasos.get(wo.CaseId).CAS_LKP_Compania__r.CUE_TXT_Identificador__c, '20');
				}
			}
			
		}
	}
}