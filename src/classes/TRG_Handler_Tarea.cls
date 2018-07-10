/**
 * Handler del Trigger TRG_Tarea.
 * 
 * @author EVERIS
 * 
 */
public without sharing class TRG_Handler_Tarea {
	
	private static Map<Id,Case> mapaCasos;
	private static Map<Id,WorkOrder> mapaOTs;
	/**
	  * Tratamiento para el caso before del trigger.
	  * 
	  * @param triggerNewMap: mapa de registros nuevos del objeto Task a partir del Id
	  * @param triggerNew: lista de registros nuevos del objeto Task
	  * @param triggerOldMap: mapa de registros antiguos del objeto Task a partir del Id
	  * @param triggerOld: lista de registros antiguos del objeto Task
	  */
	public static void tratamientoBefore(Map<Id,Task> triggerNewMap, List<Task> triggerNew, Map<Id,Task> triggerOldMap, List<Task> triggerOld){
		Util_variablesGlobales.listaCasosActualizar = new List<Case>();
		Util_variablesGlobales.listaTareasGeneradas = new List<Task>();
		if(Trigger.isInsert){
			// Obtener los valores de WhatId de las Tasks:
			Set<Id> idsWhat = new Set<Id>();
			for(Task t : triggerNew){
				if(t.WhatId != null){
					idsWhat.add(t.WhatId);
				}
			}
			// Usar los valores de WhatId para obtener los Casos y las Órdenes de Trabajo:
			/* PREV: Map<Id,Case> mapaCasos = new Map<Id,Case>(
				[SELECT Id,
						CAS_LKP_Compania__c
				 FROM Case
				 WHERE Id IN :idsWhat]);
				 */
			//NEW:
			mapaCasos = Util_Caso.getCaseById(idsWhat);
			
			
			//PREV: Map<Id,WorkOrder> mapaOTs = Util_Orden_Trabajo.queryOTBySet(idsWhat, new Set<Id>(), null);
			//NEW:
			mapaOTs = Util_Orden_Trabajo.queryMapOTById(idsWhat);
			//END_NEW
			
			// Para cada Task setear su compañía con el Id de la Cuenta del Caso o la Órden de Trabajo según el prefijo del Id de WhatId:
			for(Task t : triggerNew){
				if(t.WhatId != null){
					String prefijo = t.WhatId.getSObjectType().getDescribe().getKeyPrefix();
					// Si el prefijo del Id es '500' entonces es un Case (Caso)
					// Sino, si el prefijo del Id es '0WO' entonces es un WorkOrder (Orden de Trabajo)
					if(prefijo.equals(Case.sObjectType.getDescribe().getKeyPrefix())){
						Case caso = mapaCasos.get(t.WhatId);
						if(caso != null){
							t.TAR_LKP_Compania__c = caso.CAS_LKP_Compania__c;
						}
					}
					else if(prefijo.equals(WorkOrder.sObjectType.getDescribe().getKeyPrefix())){
						WorkOrder ot = mapaOTs.get(t.WhatId);
						if(ot != null){
							t.TAR_LKP_Compania__c = ot.Case.CAS_LKP_Compania__c;
						}
					}
				}
			}
			//Seteo de prioridad en función de metadatos
			setPrioridadesTarea(triggerNew);

			procesoPeritoBefore(triggerNew);

			registroLlamadaBefore(triggerNew);
		}
	}


	private static void procesoPeritoBefore(List<Task> triggerNew){
		Set<Id> idsCasosAsociadosIP = new Set<Id>();
		Map<Id,String> idsCasoAsunto = new Map<Id,String>();
		for(Task tarea : triggerNew){
			system.debug('>>>>tarea ' + tarea);
			if(Util_mapasTiposDeRegistro.RTDEVNAMEBYID.get(tarea.RecordTypeId) != 'TAR_Registro_Llamada'
					&& tarea.description != null
					&& tarea.description.contains(Label.EMAIL_TO_SALESFORCE)
					&& tarea.Subject != null
					&& tarea.Subject.contains('RE:')
					&& (tarea.Subject.contains(Label.TAR_ASUNTO_RECORDATORIO_IP)
							|| tarea.Subject.contains(Label.TAR_ASUNTO_RECORDATORIO_ID)
							|| tarea.Subject.contains(Label.TAR_ASUNTO_RECORDATORIO_RES)
							|| tarea.Subject.contains(Label.TAR_ASUNTO_RECORDATORIO_MINUTA))){
				//tarea.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_TAR_APROBACION);
				tarea.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_TAR_COMUN);
				tarea.Status = 'En Curso';
				if(mapaCasos.containsKey(tarea.WhatId)){
					tarea.OwnerId = mapaCasos.get(tarea.WhatId).OwnerId;//ÑAPA-->Buscar algo definitivo
				}else if(mapaOTs.containsKey(tarea.WhatId)){
					tarea.OwnerId = mapaCasos.get(mapaOTs.get(tarea.WhatId).CaseId).OwnerId;
				}
				//if(!idsCasosAsociadosIP.contains(tarea.WhatId)){-->SOBRA
					idsCasosAsociadosIP.add(tarea.WhatId);
				//}
				idsCasoAsunto.put(tarea.WhatId,tarea.Subject);
			}
		}

		// Se recogen los casos asociados a las tareas de envio de correo de perito para actualizar el estado perito
		// y los checks correspondientes
		/*PREV: Util_variablesGlobales.listaCasosActualizar = new List<Case>([
		                                                              SELECT 	Id, CAS_SEL_Estado_Perito__c, CAS_CAS_Informe_Preliminar_Recibido__c, CAS_CAS_Informe_Definitivo_Recibido__c
		                                                              FROM 	Case 
		                                                              WHERE 	Id IN :idsCasosAsociadosIP]);
		*/
		//NEW:
		Util_variablesGlobales.listaCasosActualizar = Util_Caso.getCaseById(idsCasosAsociadosIP).values();
		//END_NEW
		for(Case caso : Util_variablesGlobales.listaCasosActualizar){
			caso.CAS_SEL_Estado_Perito__c = Label.PER_ESTADO_PDTE_REV_RESP_PER;
			String asunto = idsCasoAsunto.get(caso.Id);
			/*if(asunto != null){
				if(asunto.contains(Label.TAR_ASUNTO_RECORDATORIO_IP))
					caso.CAS_CAS_Informe_Preliminar_Recibido__c = true;
				else if(asunto.contains(Label.TAR_ASUNTO_RECORDATORIO_ID))
					caso.CAS_CAS_Informe_Definitivo_Recibido__c = true;
			}*/

		}
		/* PREV: Util_variablesGlobales.listaTareasGeneradas = new List<Task>([
		                                                              SELECT 	Status 
		                                                              FROM 	Task 
		                                                              WHERE 	WhatId IN: idsCasosAsociadosIP 
		                                                              AND (Subject = :Label.TAR_ASUNTO_RECORDATORIO_IP 
		                                                              OR Subject = :Label.TAR_ASUNTO_RECORDATORIO_ID 
		                                                              OR Subject = :Label.TAR_ASUNTO_RECORDATORIO_RES
		                                                              OR Subject = :Label.TAR_ASUNTO_RECORDATORIO_MINUTA)]);
		*/
		//NEW:
		Util_variablesGlobales.listaTareasGeneradas = Util_Tarea.getTareaByWhatAndInStatus(idsCasosAsociadosIP,new Set<String>{Label.TAR_ASUNTO_RECORDATORIO_IP,Label.TAR_ASUNTO_RECORDATORIO_ID,Label.TAR_ASUNTO_RECORDATORIO_RES,Label.TAR_ASUNTO_RECORDATORIO_MINUTA }).values();
		//NEW_END
		
		for(Task tarea : Util_variablesGlobales.listaTareasGeneradas){
			tarea.Status = 'Finalizado';
		}
	}


	private static void registroLlamadaBefore(List<Task> triggerNew){
		// ¿Es una tarea de registro de llamada? = No insercion masiva
		Task tareaLlamada = triggerNew.get(0);
		/*if(Util_mapasTiposDeRegistro.RTDEVNAMEBYID.get(tareaLlamada.RecordTypeId) == 'TAR_Registro_Llamada'){
			// Cambios sobre la llamada antes de guardar
			if(tareaLlamada.ActivityDate != null
			 && tareaLlamada.TAR_DAT_Fin_Llamada__c != null){
				tareaLlamada.ActivityDate = Date.newinstance(	
					tareaLlamada.TAR_DAT_Fin_Llamada__c.year(), 
					tareaLlamada.TAR_DAT_Fin_Llamada__c.month(), 
					tareaLlamada.TAR_DAT_Fin_Llamada__c.day()
				);
			}
		}*/
		if (tareaLlamada.TAR_DAT_Inicio_Llamada__c != null) {
			tareaLlamada.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_TAR_REGISTRO_LLAMADA);
			// Cambios sobre la llamada antes de guardar
			/*if(tareaLlamada.ActivityDate != null
					&& tareaLlamada.TAR_DAT_Fin_Llamada__c != null){
				tareaLlamada.ActivityDate = Date.newinstance(	
						tareaLlamada.TAR_DAT_Fin_Llamada__c.year(), 
						tareaLlamada.TAR_DAT_Fin_Llamada__c.month(), 
						tareaLlamada.TAR_DAT_Fin_Llamada__c.day()
						);
			}*/
		}
	}

	/**
	  * Tratamiento para el caso after del trigger.
	  * 
	  * @param triggerNewMap: mapa de registros nuevos del objeto Task a partir del Id
	  * @param triggerNew: lista de registros nuevos del objeto Task
	  * @param triggerOldMap: mapa de registros antiguos del objeto Task a partir del Id
	  * @param triggerOld: lista de registros antiguos del objeto Task
	  */
	public static void tratamientoAfter(Map<Id, Task>triggerNewMap, List<Task> triggerNew, Map<Id, Task>triggerOldMap, List<Task> triggerOld){
		if(Trigger.isInsert){

			registroLlamadaAfter(triggerNew);

			procesoPeritoAfter(triggerNew);
		}
	}


	private static void registroLlamadaAfter(List<Task> triggerNew){
		// ¿Es una tarea de registro de llamada? = No insercion masiva
		Task tareaLlamada = triggerNew.get(0);
		if(Util_mapasTiposDeRegistro.RTDEVNAMEBYID.get(tareaLlamada.RecordTypeId) == 'TAR_Registro_Llamada'){
			// Generar tareas para todos los casos modificados durante la llamada

			// Se revisa que no se haya hecho ya el proceso anteriormente, para ello, ya tiene que haber creada alguna tarea con el mismo id de sesion
			/*PREV: 
				List<Task> listaTareasExistentes = new List<Task>([	SELECT 	Id 	
			                                                   	FROM 	Task 
			                                                   	WHERE 	Id != :tareaLlamada.Id AND TAR_TXT_Id_Sesion__c = :tareaLlamada.TAR_TXT_Id_Sesion__c]);
			*/
			//NEW
			List<Task> listaTareasExistentes = Util_Tarea.getTareaByNotIdAndIdSession(new Set<Id>{tareaLlamada.Id}, new Set<String>{tareaLlamada.TAR_TXT_Id_Sesion__c}).values();
			//END_NEW
			if(listaTareasExistentes.isEmpty()|| Test.isRunningTest()){
				// Si la lista esta vacia, es necesario insertar tareas
				/*PREV:
				List<CaseHistory> casosModificados = new List<CaseHistory>([
				                                                            SELECT 	Case.CaseNumber, CaseId, Field, isDeleted, NewValue, OldValue 
				                                                            FROM 	CaseHistory
				                                                            WHERE	CreatedById = :tareaLlamada.OwnerId
				                                                            AND CreatedDate >= :tareaLlamada.TAR_DAT_Inicio_Llamada__c
				                                                            AND CreatedDate <= :tareaLlamada.TAR_DAT_Fin_Llamada__c]);
				*/
				//NEW:
				List<CaseHistory> casosModificados = Util_Historico.getMapaHistoricoCaso(new Set<Id>{tareaLlamada.OwnerId},tareaLlamada.TAR_DAT_Inicio_Llamada__c,tareaLlamada.TAR_DAT_Fin_Llamada__c ).values();
				//END_NEW
				List<Task> tareasInsertar = new List<Task>();
				for(CaseHistory cHis : casosModificados){
					if(tareaLlamada.WhatId != cHis.CaseId){
						tareasInsertar.add(Registro_Llamada.crearTareaLlamada(tareaLlamada.OwnerId, cHis.CaseId, tareaLlamada.WhoId, 
								tareaLlamada.TAR_DAT_Inicio_Llamada__c, tareaLlamada.TAR_DAT_Fin_Llamada__c, tareaLlamada.CallDurationInSeconds, 
								tareaLlamada.TAR_TXT_Id_Sesion__c, false));
					}
				}
				insert tareasInsertar;
			}
		}
	}


	private static void procesoPeritoAfter(List<Task> triggerNew){
		Set<Id> idsCasos = new Set<Id>();
		for(Task tarea : triggerNew){
			if(Util_mapasTiposDeRegistro.RTDEVNAMEBYID.get(tarea.RecordTypeId) != 'TAR_Registro_Llamada'
					&& tarea.WhatId != null
					&& tarea.WhatId.getSObjectType() == Schema.Case.SObjectType){
					//&& !idsCasos.contains(tarea.WhatId)){-->SOBRA
				idsCasos.add(tarea.WhatId);
			}
		}
		/*PREV
		Map<Id, Case> mapaCasos = new Map<Id, Case>([
		                                             SELECT	CAS_LKP_Perito__c
		                                             FROM	Case
		                                             WHERE	Id IN :idsCasos]);
		                                             */
		//NEW:
		Map<Id, Case> mapaCasos = Util_Caso.getCaseById(idsCasos);
		//END_NEW
		Set<Id> idsPeritos = new Set<Id>();
		for(Case caso : mapaCasos.values()){
			//if(!idsPeritos.contains(caso.CAS_LKP_Perito__c)){-->SOBRA
				idsPeritos.add(caso.CAS_LKP_Perito__c);
			//}
		}
		
		/*PREV: Map<Id, Perito__c> mapaPeritos = new Map<Id, Perito__c>([
		                                                         SELECT	PER_EMA_Email__c
		                                                         FROM	Perito__c
		                                                         WHERE	Id IN :idsPeritos]);
		                                                         */
		//NEW:
		Map<Id, Perito__c> mapaPeritos = Util_Perito.getPeritoById(idsPeritos);
		//END_NEW
	
		for(Task tarea : triggerNew){
			if(Util_mapasTiposDeRegistro.RTDEVNAMEBYID.get(tarea.RecordTypeId) != 'TAR_Registro_Llamada'){
				if(tarea.Subject == Label.TAR_ASUNTO_RECORDATORIO_IP
						|| tarea.Subject == Label.TAR_ASUNTO_RECORDATORIO_ID
						|| tarea.Subject == Label.TAR_ASUNTO_RECORDATORIO_RES
						|| tarea.Subject == Label.TAR_ASUNTO_RECORDATORIO_MINUTA){
					Case casoAsociado = mapaCasos.get(tarea.WhatId);
					if(casoAsociado != null
							&& casoAsociado.CAS_LKP_Perito__c != null){
						Perito__c peritoAsociado = mapaPeritos.get(casoAsociado.CAS_LKP_Perito__c);
						if(peritoAsociado != null){
							if(tarea.Subject == Label.TAR_ASUNTO_RECORDATORIO_IP){
								// Mandar correo al perito Recordatorio de envio de Informe Preliminar
								Util_Perito.correoPerito(casoAsociado, peritoAsociado, Label.PLANTILLA_EMAIL_PERITO_IP);
							}
							else if(tarea.Subject == Label.TAR_ASUNTO_RECORDATORIO_ID){
								// Mandar correo al perito Recordatorio de envio de Informe Definitivo
								Util_Perito.correoPerito(casoAsociado, peritoAsociado, Label.PLANTILLA_EMAIL_PERITO_ID);
							}
							else if(tarea.Subject == Label.TAR_ASUNTO_RECORDATORIO_RES){
								// Mandar correo al perito Recordatorio de envio de Informe Definitivo
								Util_Perito.correoResPerito(casoAsociado, peritoAsociado);//Hacer Plantilla para este correo
							}
							else if(tarea.Subject == Label.TAR_ASUNTO_RECORDATORIO_MINUTA){
								// Mandar correo al perito Recordatorio de envio de la minuta
								Util_Perito.correoMinutaPerito(casoAsociado, peritoAsociado);//Hacer Plantilla para este correo
							}
						}
					}
				}
			}
		}

		update Util_variablesGlobales.listaTareasGeneradas;
		update Util_variablesGlobales.listaCasosActualizar;
	}


	private static void setPrioridadesTarea(List<Task> tareas){

		for(Task tarea: tareas){
			if(String.isBlank(tarea.TAR_SEL_Prioridad__c))
				tarea.TAR_SEL_Prioridad__c = Util_Tarea.setPrioridadTarea(tarea.Type);
			//tarea.Priority = Util_Tarea.setPrioridadTarea(tarea.Type);
		}
	}
}