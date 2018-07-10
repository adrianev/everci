/**
 * Clase para metodos refractorizados de Tareas
 *
 * @author EVERIS
 */
public without sharing class Util_Tarea {
	public static Task recordatorioEnvioIP(Case caso){
		Task tarea = crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_RECORDATORIO_IP, Label.TAR_ESTADO_EN_CURSO, 
				null, caso.OwnerId, caso.Id, caso.CAS_LKP_Compania__c);
		return tarea;
	}

	/**
	 * [PENDIENTE]
	 * 
	 */
	public static Task recordatorioEnvioID(Case caso){
		Task tarea = crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_RECORDATORIO_ID, Label.TAR_ESTADO_EN_CURSO, 
				null, caso.OwnerId, caso.Id, caso.CAS_LKP_Compania__c);
		return tarea;
	}

	/**
	 * [PENDIENTE]
	 * 
	 */
	public static Task recordatorioEnvioRes(Case caso){
		Task tarea = crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_RECORDATORIO_RES, Label.TAR_ESTADO_EN_CURSO, 
				null, caso.OwnerId, caso.Id, caso.CAS_LKP_Compania__c);
		return tarea;
	}

	/**
	 * [PENDIENTE]
	 * 
	 */
	public static Task recordatorioEnvioMinuta(Case caso){
		Task tarea = crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_RECORDATORIO_MINUTA, Label.TAR_ESTADO_EN_CURSO, 
				null, caso.OwnerId, caso.Id, caso.CAS_LKP_Compania__c);
		return tarea;
	}

	/**
	 * [PENDIENTE]
	 * 
	 */
	private static Task revisionIP(Case caso){
		Task tarea = crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_REVISION_IP, Label.TAR_ESTADO_EN_CURSO, 
				null, caso.OwnerId, caso.Id, caso.CAS_LKP_Compania__c);
		return tarea;
	}

	/**
	 * [PENDIENTE]
	 * 
	 */
	private static Task revisionID(Case caso){
		Task tarea = crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_REVISION_ID, Label.TAR_ESTADO_EN_CURSO, 
				null, caso.OwnerId, caso.Id, caso.CAS_LKP_Compania__c);
		return tarea;
	}

	/**
	 * [PENDIENTE]
	 * 
	 */
	public static Task crearTareaComun(Case caso, String asunto){
		Task tarea = crearTarea(Label.RT_TAR_COMUN, asunto, Label.TAR_ESTADO_EN_CURSO, 
				null, caso.OwnerId, caso.Id, caso.CAS_LKP_Compania__c);
		return tarea;
	}

	/**
	 * [PENDIENTE]
	 * 
	 */
	public static String setPrioridadTarea(String tipoTarea){
		String prioridad = '5';
		if(tipoTarea != null){
			Tareas__mdt metadato = Util_Metadatos.mapaTareaTipo.get(tipoTarea);
			if(metadato != null)
				prioridad = metadato.MTD_TAR_SEL_Prioridad__c;
		}
		return prioridad;
	}



	/*
	 * 
	 *   Crea una nueva tarea a partir de los argumentos
	 *
	 *	 @param String labelRecordType   - Etiqueta del tipo de registro asociado a la tarea
	 *   @param String asunto			- Asunto de la tarea
	 *   @param String estado			- Estado de la tarea
	 *   @param String tipo			  - Tipo de la tarea
	 *   @param Id owner				 - Id del propietario de la tarea
	 *   @param Id vincularA			 - Id del objeto que tiene vinculada la tarea
	 *   @param Id compania		  	 - Id de la Compañía vinculada a la tarea
	 *
	 *   @return tarea				   - Devuelve la tarea que se ha generado
	 **/
	public static Task crearTarea(String labelRecordType, String asunto, String estado, String tipo, Id owner, Id vincularA, Id compania){
		Task tarea;
		Id recordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(labelRecordType);
		if(recordTypeId != null){
			tarea = new Task(
					RecordTypeId = recordTypeId,
					OwnerId = owner,
					Subject = asunto,
					Status = estado,
					Type = tipo,
					WhatId = vincularA,
					TAR_LKP_Compania__c = compania
			);
		}
		system.debug('***** tarea : ' + tarea);
		return tarea;
	}

	/**
	 * [PENDIENTE]
	 * 
	 */
	public static Map<Id, List<Task>> tareasDeCasos(Set<Id> idsCasos){
		Map<Id, List<Task>> mapaTareas = new Map<Id, List<Task>>();
		List<Task> listaTareas = new List<Task>(
			[SELECT	RecordType.DeveloperName,
			   		Subject,
					WhatId
			 FROM Task
			 WHERE 	WhatId IN :idsCasos
			 AND Status = :Label.TAR_ESTADO_EN_CURSO
			 ORDER BY WhatId]);
		for(Task tarea : listaTareas){
			List<Task> listaTareasAux;
			if(mapaTareas.containsKey(tarea.WhatId)){
				listaTareasAux = mapaTareas.get(tarea.WhatId);
			}
			else {
				listaTareasAux = new List<Task>();
			}
			listaTareasAux.add(tarea);
			mapaTareas.put(tarea.WhatId, listaTareasAux);
		}
		return mapaTareas;
	}

	/**
       * [PENDIENTE]
       * 
        * @param idGrupo: [PENDIENTE]
       * 
        * @return [PENDIENTE]
       */  

	public static List<Task> cerrarTareasCaso(Case caso, String asunto, Map<Id, List<Task>> mapaTareasCaso){
		List<Task> listaTareasACerrar = new List<Task>();
		if(mapaTareasCaso != null){
			List<Task> listaTareasCaso = mapaTareasCaso.get(caso.Id);
			if(listaTareasCaso != null){
				for(Task tarea : listaTareasCaso){
					if(tarea.Subject.contains(asunto)){
						if(listaTareasACerrar == null){
							listaTareasACerrar = new List<Task>();
						}
						tarea.Status = 'Finalizado';
						listaTareasACerrar.add(tarea);
					}
				}
			}
		}
		return listaTareasACerrar;
	}

	/**
       * [PENDIENTE]
       * 
        * @param idGrupo: [PENDIENTE]
       * 
        * @return [PENDIENTE]
       */  

	public static void generarTareas(Case caso, Map<Id, Case> triggerOldMap, Map <Id, Account> mapaCIAs, 
			Map<Id, List<Task>> mapaTareas, Map<Id, WorkOrder> mapaOTs, Map<Id, WorkOrderLineItem> mapaPartidasOTs){
		if(caso != null){
			Boolean existeTareaSolPerito = false;
			List<Task> listaTareas;
			if(mapaTareas != null
					&& mapaTareas.get(caso.Id) != null){
				listaTareas = mapaTareas.get(caso.Id);
				// Se recorre la lista de tareas del caso para evitar crear tareas que ya esten creadas y en curso
				if(listaTareas != null){
					for(Task tarea : listaTareas){
						if(tarea.RecordType.DeveloperName == Label.RT_TAR_COMUN){
							existeTareaSolPerito = true;
						}
					}
				}
			}
			if(!existeTareaSolPerito
					&& caso.CAS_LKP_Perito__c == null){
				Boolean tareaSolPerito = false;
				Account cuenta = mapaCIAs.get(caso.CAS_LKP_Compania__c);
				Boolean superaLimite = false;
				if(caso.CAS_DIV_Importe_Total__c != null
						&& cuenta != null
						&& cuenta.CUE_DIV_Limite_Actuacion__c != null){
					superaLimite = caso.CAS_DIV_Importe_Total__c > cuenta.CUE_DIV_Limite_Actuacion__c;
				}
				system.debug('>>>>caso.CAS_CAS_Requiere_Perito__c ' + caso.CAS_CAS_Requiere_Perito__c);
				system.debug('>>>>faseVueltaSondeo ' + Util_variablesGlobales.faseVueltaSondeo);
				// 1. Si el check de Perito Requerido se ha marcado: generamos la Tarea de presolicitud (Estado y prioridad pendiente)
				if(caso.CAS_CAS_Requiere_Perito__c 
						&& Util_variablesGlobales.faseVueltaSondeo == null
						&& (triggerOldMap == null
						|| !triggerOldMap.get(caso.Id).CAS_CAS_Requiere_Perito__c)){
					tareaSolPerito = true;
				}
				// 2. Cuando el valor del Importe Total supera el valor del campo Límite de actuación de la cuenta
				else if(superaLimite){
					if(cuenta.CUE_CAS_No_Interviene_Perito__c){
						// 2.1. Cuando la cuenta tiene marcado el check de No Autoriza Perito, se genera un presupuesto
						//Util_Presupuesto.insertarPresupuesto(caso, mapaPartidasOTs, null);

					}else{
						// 2.2. Si la cuenta no tiene marcado el check No Autoriza Perito, genera tarea (Estado y prioridad pendiente)
						tareaSolPerito = true;
					}
				}
				//  Se crea la tarea de solicitud de perito y se actualiza el estado perito
				if(tareaSolPerito){
					//Task tarea = Util_Siniestro.crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_SOLICITAR_PERITO, 
					// Label.TAR_ESTADO_EN_CURSO, Label.TAR_PRIORIDAD_NORMAL, caso.OwnerId, caso.Id, caso.CAS_LKP_Compania__c);
					Task tarea = crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_SOLICITAR_PERITO, 
							Label.TAR_ESTADO_EN_CURSO, null, caso.OwnerId, caso.Id, caso.CAS_LKP_Compania__c);
					if(tarea != null){
						Util_variablesGlobales.listaTareasGeneradas.add(tarea);
						caso.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_PDTE_PETICION_PERITO;
					}
				} 
			}
			generarTareasRecordatorios(caso, triggerOldMap, mapaTareas);
		}
	}

	/**
	 * [PENDIENTE]
	 * 
	 * @param idGrupo: [PENDIENTE]
	 * 
	 * @return [PENDIENTE]
	 */  
	private static void generarTareasRecordatorios(Case caso, Map<Id, Case> triggerOldMap, Map<Id, List<Task>> mapaTareas){
		Boolean existeTareaRecordIP = false;
		Boolean existeTareaRecordID = false;
		Boolean existeTareaRecordRes = false;
		Boolean existeTareaRevisionIP = false;
		Boolean existeTareaRevisionID = false;

		List<Task> listaTareas;
		if(mapaTareas != null
				&& mapaTareas.get(caso.Id) != null){
			listaTareas = mapaTareas.get(caso.Id);	
			// Se recorre la lista de tareas del caso para evitar crear tareas que ya esten creadas y en curso
			if(listaTareas != null){
				for(Task tarea : listaTareas){
					if(tarea.RecordType.DeveloperName == Label.RT_TAR_COMUN.split(':').get(1)){
						if(tarea.Subject == Label.TAR_ASUNTO_RECORDATORIO_IP){
							existeTareaRecordIP = true;
						}else if(tarea.Subject == Label.TAR_ASUNTO_RECORDATORIO_ID){
							existeTareaRecordID = true;
						}else if(tarea.Subject == Label.TAR_ASUNTO_RECORDATORIO_RES){
							existeTareaRecordRes = true;
						}else if(tarea.Subject == Label.TAR_ASUNTO_REVISION_IP){
							existeTareaRevisionIP = true;
						}else if(tarea.Subject == Label.TAR_ASUNTO_REVISION_ID){
							existeTareaRevisionID = true;
						}
					}
				}
			}
		}

		if(caso.CAS_SEL_Estado_Perito__c == Label.PER_ESTADO_PDTE_VAL_PER){
			if(caso.CAS_CAS_Informe_Definitivo_Recibido__c){
				if(caso.CAS_DIV_Pago_de_Minuta__c == null){
					//PENDIENTE DEFINIR
					// Se genera una tarea de Recordatorio de envio de Minuta y se inicia un contador de X horas
					/*Util_variablesGlobales.listaTareasGeneradas.add(Util_Tarea.recordatorioEnvioMinuta(caso));
					if(caso.CAS_NUM_Recordatorios_Envio_Minuta__c == null){
						caso.CAS_NUM_Recordatorios_Envio_Minuta__c = 1;
					}else{
						caso.CAS_NUM_Recordatorios_Envio_Minuta__c++;
					}
					caso.CAS_DAT_Fecha_Recordatorio_Envio_Minuta__c = DateTime.Now();
					*/
				}
			}
			else if(caso.CAS_CAS_Informe_Preliminar_Recibido__c){
				if(!existeTareaRecordID){
					// Se genera una tarea de Recordatorio de envio de Informe Definitivo y se inicia un contador de 240 horas
					Util_variablesGlobales.listaTareasGeneradas.add(Util_Tarea.recordatorioEnvioID(caso));
					if(caso.CAS_NUM_Recordatorios_Envio_I_D__c == null){
						caso.CAS_NUM_Recordatorios_Envio_I_D__c = 1;
					}else{
						caso.CAS_NUM_Recordatorios_Envio_I_D__c++;
					}
					caso.CAS_DAT_Fecha_Recordatorio_Envio_I_D__c = DateTime.Now();
				}
				if(!existeTareaRecordRes){
					// Se genera una tarea de Recordatorio de envio de Reserva y se inicia un contador de 72 horas
					Util_variablesGlobales.listaTareasGeneradas.add(Util_Tarea.recordatorioEnvioRes(caso));
					if(caso.CAS_NUM_Recordatorios_Envio_Reserva__c == null){
						caso.CAS_NUM_Recordatorios_Envio_Reserva__c = 1;
					}else{
						caso.CAS_NUM_Recordatorios_Envio_Reserva__c++;
					}
					caso.CAS_DAT_Fecha_Recordatorio_Envio_Reserva__c = DateTime.Now();
				}
			}
			else if(!existeTareaRecordIP){
				// Se genera una tarea de Recordatorio de envio de Informe Preliminar y se inicia un contador de 48 horas
				Util_variablesGlobales.listaTareasGeneradas.add(Util_Tarea.recordatorioEnvioIP(caso));
				if(caso.CAS_NUM_Recordatorios_Envio_I_P__c == null){
					caso.CAS_NUM_Recordatorios_Envio_I_P__c = 1;
				}else{
					caso.CAS_NUM_Recordatorios_Envio_I_P__c++;
				}
				caso.CAS_DAT_Fecha_Recordatorio_Envio_I_P__c = DateTime.Now();
			}
			else if(caso.CAS_NUM_Recordatorios_Envio_Minuta__c > 1 
					&& caso.CAS_NUM_Recordatorios_Envio_Minuta__c != triggerOldMap.get(caso.Id).CAS_NUM_Recordatorios_Envio_Minuta__c){
				caso.CAS_DAT_Fecha_Recordatorio_Envio_Minuta__c = DateTime.Now();
			}
			else if(caso.CAS_NUM_Recordatorios_Envio_I_D__c > 1 
					&& caso.CAS_NUM_Recordatorios_Envio_I_D__c != triggerOldMap.get(caso.Id).CAS_NUM_Recordatorios_Envio_I_D__c){
				caso.CAS_DAT_Fecha_Recordatorio_Envio_I_D__c = DateTime.Now();
			}
			else if(caso.CAS_NUM_Recordatorios_Envio_Reserva__c > 1 
					&& caso.CAS_NUM_Recordatorios_Envio_Reserva__c != triggerOldMap.get(caso.Id).CAS_NUM_Recordatorios_Envio_Reserva__c){
				caso.CAS_DAT_Fecha_Recordatorio_Envio_Reserva__c = DateTime.Now();
			}
			else if(caso.CAS_NUM_Recordatorios_Envio_I_P__c > 1 
					&& caso.CAS_NUM_Recordatorios_Envio_I_P__c != triggerOldMap.get(caso.Id).CAS_NUM_Recordatorios_Envio_I_P__c){
				caso.CAS_DAT_Fecha_Recordatorio_Envio_I_P__c = DateTime.Now();
			}
		} else if(caso.CAS_SEL_Estado_Perito__c == Label.PER_ESTADO_PDTE_REV_RESP_PER){
			if(caso.CAS_CAS_Informe_Preliminar_Recibido__c && !existeTareaRevisionIP){
				Util_variablesGlobales.listaTareasGeneradas.add(revisionIP(caso));
			} else if(caso.CAS_CAS_Informe_Definitivo_Recibido__c && !existeTareaRevisionID){
				Util_variablesGlobales.listaTareasGeneradas.add(revisionID(caso));
			}
		} else if(caso.CAS_SEL_Estado_Perito__c == Label.PER_ESTADO_PDTE_INFORME_PRELIMINAR && !existeTareaRecordIP){
			Util_variablesGlobales.listaTareasGeneradas.add(Util_Tarea.recordatorioEnvioIP(caso));
		}
	}

	/**
       * [PENDIENTE]
       * 
        * @param idGrupo: [PENDIENTE]
       * 
        * @return [PENDIENTE]
       */  

	public static List<Task> crearTareasParaCaso(List<Case> listaNuevosCaso, Map<Id,Case> mapaViejosCaso, Map<Id, Account> mapaCuentas){
		//SE LLAMA A ESTA FUNCION DESDE EL AFTER UPDATE/INSERT
		List<Task> listaTareasNuevas = new List<Task>();
		if(mapaViejosCaso != null){
			//Si la orden es nueva o se ha producido un cambio de estado, 
			//se debe consultar en el custom metadata 'Orden de trabajo' tomando como filtro la compañía y el nuevo estado 
			//y se debe crear una tarea asociada a esta orden de trabajo
			for(Case caso : listaNuevosCaso){
				//system.debug('***** caso : ' + caso);
				Account cia = mapaCuentas.get(caso.CAS_LKP_Compania__c);
				Case casoOld = mapaViejosCaso.get(caso.Id);

				//Las reclamaciones generan tareas por su cuenta, sin metadatos
				if(caso.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION)){
					//Si debido a un workflow dependiente del tiempo se blanquea la fecha de semáforo rojo
					//la fecha de activación del contador no se toca. Se genera tarea en esa situación
					if(caso.CAS_DAT_Generar_Tarea_Semaforo__c == null && casoOld.CAS_DAT_Generar_Tarea_Semaforo__c != null && caso.CAS_DAT_Fecha_Activacion_Contador__c != null){
						Task tarea = crearTarea(Label.RT_TAR_COMUN,Label.TAR_ASUNTO,Label.TAR_ESTADO_EN_CURSO,Label.TAR_TIPO_CAMBIO_DE_ESTADO,caso.OwnerId,caso.Id,caso.CAS_LKP_Compania__c);//TODO: Cambiar el asunto //Antes compania==null
						//tarea.Description = casoMDT.MTD_CAS_TXT_Descripcion_Tarea__c;
						//tarea.Priority = casoMDT.MTD_CAS_SEL_Prioridad__c;
						//tarea.ActivityDate = Date.today().addDays((Integer)casoMDT.MTD_CAS_NUM_Duracion_estimada__c);
						listaTareasNuevas.add(tarea);
					}

				} else if(cia != null){//TODO: REHACER
					Casos__mdt casoMDT = Util_Metadatos.mapaCasosEstadoCIA.get(String.valueOf(caso.Status) + String.valueOf(cia.CUE_TXT_Identificador__c));
					//system.debug('>>>>casoMDT ' + casoMDT);
					if(caso.CAS_NUM_Dias_Verde__c != null
							&& caso.CAS_NUM_Dias_Amarillo__c != null){
						if(caso.CAS_DAT_Generar_Tarea_Semaforo__c == null && casoOld.CAS_DAT_Generar_Tarea_Semaforo__c != null && caso.CAS_DAT_Fecha_Activacion_Contador__c != null){
							// Se creará una lista de tareas asociadas a la orden de trabajo, 
							// con usuario dueño el mismo que la orden de trabajo, 
							// la prioridad requerida y 
							// la fecha de vencimiento igual a la fecha actual más la duración estimada
							if(casoMDT != null){
								Task tarea = crearTarea(Label.RT_TAR_COMUN, Label.TAR_ASUNTO_CAMBIO_ESTADO_CASO, Label.TAR_ESTADO_EN_CURSO,
									Label.TAR_TIPO_CAMBIO_DE_ESTADO_CASO, caso.OwnerId, caso.Id, caso.CAS_LKP_Compania__c);
								tarea.Description = casoMDT.MTD_CAS_TXT_Descripcion_Tarea__c;
								//tarea.Priority = casoMDT.MTD_CAS_SEL_Prioridad__c;
								if(casoMDT.MTD_CAS_NUM_Duracion_estimada__c != null){
									tarea.ActivityDate = Date.today().addDays((Integer)casoMDT.MTD_CAS_NUM_Duracion_estimada__c);
								}
								listaTareasNuevas.add(tarea);
							}
						}	
					}		
				}
			}
		}
		return listaTareasNuevas;
	}

	/**
	 * Devuelve las tareas encontradas según un filtro de búsqueda.
	 *
	 * @param filtro: filtro de búsqueda para las tareas
	 *
	 * @return lista de tareas encontradas que coinciden con el filtro de búsqueda
	 */
	/*public static List<Task> queryTarea(String filtro){
		List<Task> registros = new List<Task>();
		if(filtro != null){
			String query = 'SELECT Id,';
			query += ' ActivityDate,';
			query += ' CallDisposition,';
			query += ' CallDurationInSeconds,';
			query += ' CallObject,';
			query += ' CallType,';
			query += ' CreatedDate,';
			query += ' Description,';
			query += ' FSL__Count_of_Events__c,';
			query += ' FSL__Count_of_Tasks__c,';
			query += ' FSL__Event_Type__c,';
			query += ' IsArchived,';
			query += ' IsClosed,';
			query += ' IsDeleted,';
			query += ' IsRecurrence,';
			query += ' IsReminderSet,';
			query += ' IsVisibleInSelfService,';
			query += ' LastModifiedDate,';
			query += ' OwnerId,';
			query += ' Priority,';
			query += ' RecordType.DeveloperName,';
			query += ' RecordTypeId,';
			query += ' RecurrenceInterval,';
			query += ' RecurrenceRegeneratedType,';
			query += ' Status,';
			query += ' Subject,';
			query += ' TAR_DAT_Fin_Llamada__c,';
			query += ' TAR_DAT_Inicio_Llamada__c,';
			query += ' TAR_LKP_Compania__c,';
			query += ' TAR_LKP_Orden_Trabajo__c,';
			query += ' TAR_LKP_Perito__c,';
			query += ' TAR_SEL_Prioridad__c,';
			query += ' TAR_TIM_duration__c,';
			query += ' TAR_TXT_Id_Sesion__c,';
			query += ' TaskSubtype,';
			query += ' thinkConnect__ANI__c,';
			query += ' thinkConnect__DNIS__c,';
			query += ' thinkConnect__UCID__c,';
			query += ' thinkConnect__ucidURL__c,';
			query += ' thinkConnect__UUI__c,';
			query += ' Type,';
			query += ' WhatId,';
			query += ' Who.Phone,';
			query += ' WhoId';
			query += ' FROM Task WHERE '+filtro;
			system.debug('>>>> Util_Tarea.queryTarea.query: '+query);
			registros = database.query(query);
		}
		return registros;
	}*/

	/**
	 * Obtiene las Tareas devueltss por la query filtrando por los WhoId's.
	 *
	 * @param setWho: conjunto de WhoId's
	 *
	 * @return mapa que contiene las Tareas encontrados
	 */
	public static Map<Id,Task> getTareaByWhoId(Set<Id> setWho){
		Map<Id,Task> mapa = new Map<Id,Task>();
		if(setWho != null && !setWho.isEmpty()){
			for(List<Task> lista:[SELECT id,ActivityDate,CallDisposition,CallDurationInSeconds,CallObject,CallType,CreatedDate,Description,FSL__Count_of_Events__c,FSL__Count_of_Tasks__c,FSL__Event_Type__c,IsArchived,IsClosed,IsDeleted,IsRecurrence,IsReminderSet,IsVisibleInSelfService,LastModifiedDate,OwnerId,Priority,RecordTypeId,RecurrenceInterval,RecurrenceRegeneratedType,Status,Subject,TAR_DAT_Fin_Llamada__c,TAR_DAT_Inicio_Llamada__c,TAR_LKP_Compania__c,TAR_LKP_Orden_Trabajo__c,TAR_LKP_Perito__c,TAR_SEL_Prioridad__c,TAR_TIM_duration__c,TAR_TXT_Id_Sesion__c,TaskSubtype,thinkConnect__ANI__c,thinkConnect__DNIS__c,thinkConnect__UCID__c,thinkConnect__ucidURL__c,thinkConnect__UUI__c,Type,WhatId,Who.Phone,WhoId
									FROM Task
									where WhoId IN :setWho]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Obtiene las Tareas devueltss por la query filtrando por los IDs.
	 *
	 * @param setIdTarea: conjunto de IDs de Orden de Trabajo
	 *
	 * @return mapa que contiene las Tareas encontrados
	 */
	public static Map<Id,Task> getTareaById(Set<Id> setIdTarea){
		Map<Id,Task> mapa = new Map<Id,Task>();
		if(setIdTarea != null && !setIdTarea.isEmpty()){
			for(List<Task> lista:[SELECT id,ActivityDate,CallDisposition,CallDurationInSeconds,CallObject,CallType,CreatedDate,Description,FSL__Count_of_Events__c,FSL__Count_of_Tasks__c,FSL__Event_Type__c,IsArchived,IsClosed,IsDeleted,IsRecurrence,IsReminderSet,IsVisibleInSelfService,LastModifiedDate,OwnerId,Priority,RecordTypeId,RecurrenceInterval,RecurrenceRegeneratedType,Status,Subject,TAR_DAT_Fin_Llamada__c,TAR_DAT_Inicio_Llamada__c,TAR_LKP_Compania__c,TAR_LKP_Orden_Trabajo__c,TAR_LKP_Perito__c,TAR_SEL_Prioridad__c,TAR_TIM_duration__c,TAR_TXT_Id_Sesion__c,TaskSubtype,thinkConnect__ANI__c,thinkConnect__DNIS__c,thinkConnect__UCID__c,thinkConnect__ucidURL__c,thinkConnect__UUI__c,Type,WhatId,Who.Phone,WhoId
									FROM Task
									where Id IN :setIdTarea]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Obtiene las Tareas devueltas por la query filtrando por los IDs (que no se quieren) y por ID de sesión
	 *
	 * @param setIdTarea: conjunto de IDs de Orden de Trabajo
	 * @param setTXTIdSesion
	 *
	 * @return mapa que contiene las Tareas encontrados
	 */
	public static Map<Id,Task> getTareaByNotIdAndIdSession(Set<Id> setIdTarea, Set<String> setTXTIdSesion){
		Map<Id,Task> mapa = new Map<Id,Task>();
		if(setIdTarea != null && !setIdTarea.isEmpty() && !setTXTIdSesion.isEmpty() && setTXTIdSesion!=null){
			for(List<Task> lista:[SELECT id,ActivityDate,CallDisposition,CallDurationInSeconds,CallObject,CallType,CreatedDate,Description,FSL__Count_of_Events__c,FSL__Count_of_Tasks__c,FSL__Event_Type__c,IsArchived,IsClosed,IsDeleted,IsRecurrence,IsReminderSet,IsVisibleInSelfService,LastModifiedDate,OwnerId,Priority,RecordTypeId,RecurrenceInterval,RecurrenceRegeneratedType,Status,Subject,TAR_DAT_Fin_Llamada__c,TAR_DAT_Inicio_Llamada__c,TAR_LKP_Compania__c,TAR_LKP_Orden_Trabajo__c,TAR_LKP_Perito__c,TAR_SEL_Prioridad__c,TAR_TIM_duration__c,TAR_TXT_Id_Sesion__c,TaskSubtype,thinkConnect__ANI__c,thinkConnect__DNIS__c,thinkConnect__UCID__c,thinkConnect__ucidURL__c,thinkConnect__UUI__c,Type,WhatId,Who.Phone,WhoId
									FROM Task
									where Id NOT IN :setIdTarea AND TAR_TXT_Id_Sesion__c IN :setTXTIdSesion]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}


	/**
	 * Obtiene las Tareas devueltss por la query filtrando por Status y WhatId.
	 *
	 * @param setWhat: conjunto de whatId's del filtro
	 * @param setStatus: conjunto de campos del filtro
	 *
	 * @return mapa que contiene las Tareas encontradas
	 */
	public static Map<Id,Task> getTareaByWhatAndInStatus(Set<Id> setWhat, Set<String> setStatus){
		Map<Id,Task> mapa = new Map<Id,Task>();
		if(setWhat != null && !setWhat.isEmpty() && setStatus != null && !setStatus.isEmpty()){
			for(List<Task> lista:[SELECT id,ActivityDate,CallDisposition,CallDurationInSeconds,CallObject,CallType,CreatedDate,Description,FSL__Count_of_Events__c,FSL__Count_of_Tasks__c,FSL__Event_Type__c,IsArchived,IsClosed,IsDeleted,IsRecurrence,IsReminderSet,IsVisibleInSelfService,LastModifiedDate,OwnerId,Priority,RecordTypeId,RecurrenceInterval,RecurrenceRegeneratedType,Status,Subject,TAR_DAT_Fin_Llamada__c,TAR_DAT_Inicio_Llamada__c,TAR_LKP_Compania__c,TAR_LKP_Orden_Trabajo__c,TAR_LKP_Perito__c,TAR_SEL_Prioridad__c,TAR_TIM_duration__c,TAR_TXT_Id_Sesion__c,TaskSubtype,thinkConnect__ANI__c,thinkConnect__DNIS__c,thinkConnect__UCID__c,thinkConnect__ucidURL__c,thinkConnect__UUI__c,Type,WhatId,Who.Phone,WhoId
									FROM Task
									WHERE WhatId IN :setWhat AND Status IN :setStatus]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	public static Map<Id,Task> getTareaByIdAndInStatusOrStatus(Set<Id> setWhat, Set<String> setStatus){
		Map<Id,Task> mapa = new Map<Id,Task>();
		if(setWhat != null && !setWhat.isEmpty() && setStatus != null && !setStatus.isEmpty()){
			for(List<Task> lista:[Select id,
									Priority,
									Subject,
									OwnerId,
									Description,
									IsRecurrence,
									CallDurationInSeconds,
									ActivityDate,
									CallObject,
									RecurrenceInterval,
									WhoId,
									IsVisibleInSelfService,
									IsReminderSet,
									WhatId,
									RecurrenceRegeneratedType,
									CallDisposition,
									TaskSubtype,
									Type,
									CallType,
									RecordTypeId,
									TAR_LKP_Compania__c,
									TAR_SEL_Prioridad__c,
									TAR_LKP_Orden_Trabajo__c
									from task 
									where (Status IN :setStatus OR Status IN :setStatus) and WhatId =:setWhat order by createddate desc]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/**
	 * Devuelve un mapa de Casos con sus Partidas no rechazadas.
	 * 
	 * @param setIds: Conjunto de Ids de Casos
	 * @return mapa de Casos con sus Partidas no rechazadas
	 */
	public static Map<Id, List<Task>> getMapaTareasCaso(Set<Id> setIds){
		Map<Id, List<Task>> mapa = new Map<Id, List<Task>>();
		if(setIds != null && (!setIds.isEmpty())){
			List<Task> lista = new List<Task>(
				[SELECT Id,
						Status,
						WhatId,
						ownerId
				 FROM Task WHERE whatId IN :setIds
				 AND Status = :Label.TAR_ESTADO_EN_CURSO
				 ORDER BY whatId ASC]);
			for(Task registro : lista){
				List<Task> listaAux = mapa.get(registro.whatId);
				if(listaAux == null){
					listaAux = new List<Task>();
				}
				listaAux.add(registro);
				mapa.put(registro.whatId, listaAux);
			}
		}
		return mapa;
	}
}