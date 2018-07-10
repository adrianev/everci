/**
 * Handler del Trigger TRG_Propuesta_de_Abono.
 * 
 * @author EVERIS
 * 
 */
public without sharing class TRG_Handler_Propuesta_de_Abono {

	private static Map<Id,WorkOrder> woRelacionadas;
	private static Map<Id,Case> casosRelacionados;
	private static Map<Id,Propuesta_de_Evento__c> eventosRelacionados;
	private static Map<Id,Case> mapaCaso;

	private static Map<Id,WorkOrder> woUpdate;
	private static Map<Id,Case> casoUpdate;
	private static List<Task> tareasInsert;
	
	private static String body;
	public static Integer contParametros;

	/**
	  * Tratamiento para el caso before del trigger.
	  * 
	  * @param triggerNewMap: mapa de registros nuevos del objeto Propuesta_de_Abono__c a partir del Id
	  * @param triggerNew: lista de registros nuevos del objeto Propuesta_de_Abono__c
	  * @param triggerOldMap: mapa de registros antiguos del objeto Propuesta_de_Abono__c a partir del Id
	  * @param triggerOld: lista de registros antiguos del objeto Propuesta_de_Abono__c
	  */
	/*public static void tratamientoBefore(Map<Id, Propuesta_de_Abono__c> triggerNewMap, List<Propuesta_de_Abono__c> triggerNew, 
			Map<Id, Propuesta_de_Abono__c> triggerOldMap, List<Propuesta_de_Abono__c> triggerOld){

		if(eventosRelacionados == null)
			rellenarEventosRelacionados(triggerNew); 
		if(woRelacionadas == null)
			rellenarWoRelacionadas(triggerNew);
		if(casosRelacionados == null)
			rellenarCasosRelacionados(triggerNew);

		//mirar dentro de propuesto de abono si su LKP a cuenta esta vacio
		//sino esta vacio tengo que sacar la cuenta del caso y en esa misma cuenta
		//añadirsela a la propuesta de abono que se esta creando
		for(Propuesta_de_Abono__c pro : triggerNew){
			if(pro.AB_LKP_Cuenta__c == null){
				if(pro.AB_LKP_Caso__c != null){
					pro.AB_LKP_Cuenta__c = casosRelacionados.get(pro.AB_LKP_Caso__c).AccountId;
				} else if(pro.AB_LKP_Orden_de_Trabajo__c != null){
					pro.AB_LKP_Cuenta__c = woRelacionadas.get(pro.AB_LKP_Orden_de_Trabajo__c).Case.AccountId;
				} else if(pro.AB_LKP_Evento_Relacionado__c != null) {
					Propuesta_de_evento__c evt = eventosRelacionados.get(pro.AB_LKP_Evento_Relacionado__c);
					if(evt.EV_AB_LKP_Caso__c != null){
						pro.AB_LKP_Cuenta__c = casosRelacionados.get(evt.EV_AB_LKP_Caso__c).AccountId;
					} else if(evt.EV_AB_LKP_Orden_de_Trabajo__c != null){
						pro.AB_LKP_Cuenta__c = woRelacionadas.get(evt.EV_AB_LKP_Orden_de_Trabajo__c).Case.AccountId;
					}
				}

			} 
		}

		//Control de maximos Abonos y Eventos --> Tengo que mirar si el Evento padre tiene un LKP a Abono

		if(eventosRelacionados == null)
			rellenarEventosRelacionados(triggerNew);

		for(Propuesta_de_Abono__c controlMax : triggerNew){
			Propuesta_de_Evento__c eventoAux = eventosRelacionados.get(controlMax.AB_LKP_Evento_Relacionado__c);
			if(eventoAux != null && eventoAux.EV_AB_LKP_Abono__c !=null){
				controlMax.addError('No se puede crear un Abono bajo un evento automático');
			}
		}

	}*/

	/**
	  * Tratamiento para el caso after del trigger.
	  * 
	  * @param triggerNewMap: mapa de registros nuevos del objeto Propuesta_de_Abono__c a partir del Id
	  * @param triggerNew: lista de registros nuevos del objeto Propuesta_de_Abono__c
	  * @param triggerOldMap: mapa de registros antiguos del objeto Propuesta_de_Abono__c a partir del Id
	  * @param triggerOld: lista de registros antiguos del objeto Propuesta_de_Abono__c
	  */
	public static void tratamientoAfter(Map<Id, Propuesta_de_Abono__c> triggerNewMap, List<Propuesta_de_Abono__c> triggerNew, 
			Map<Id, Propuesta_de_Abono__c> triggerOldMap, List<Propuesta_de_Abono__c> triggerOld){
			
			/*Id casoId = triggerNew.get(0).AB_LKP_Caso__c ;
					system.debug('<<<<<<<<<<<sera caso>>>>>>>>>>>>>' + casoId);
			Case cas = [SELECT RecordTypeId FROM Case WHERE Id =  :casoId];
					system.debug('<<<<<<<<<<<sera record>>>>>>>>>>>>>' + cas.RecordTypeId);*/
			/*if(cas.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION)){
				crearPropuestaEvento(triggerNew);
			}*/

		Set<Id> woIds = new Set<Id>();
		Set<Id> casoIds = new Set<Id>();
		for(Propuesta_de_Abono__c trg : triggerNew){
			woIds.add(trg.AB_LKP_Orden_de_Trabajo__c);
			casoIds.add(trg.AB_LKP_Caso__c);
		}


		Map<Id,List<Propuesta_de_evento__c>> eventosDeWo = Util_Orden_Trabajo.pEventosByWO(woIds);
		Map<Id,List<Propuesta_de_abono__c>> abonosDeWo = Util_Orden_Trabajo.pAbonosByWO(woIds);
		
		Map<Id,List<Propuesta_de_evento__c>> eventosDeCaso = Util_Propuesta_de_evento.pEventosByCaso(casoIds);
		Map<Id,List<Propuesta_de_abono__c>> abonosDeCaso = Util_Propuesta_de_abono.pAbonosByCaso(casoIds);

		Id recordTypeReclamacion = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);

		/*if(eventosRelacionados == null)
		rellenarEventosRelacionados(triggerNew);*/
		if(woRelacionadas == null)
			rellenarWoRelacionadas(triggerNew);
		if(casosRelacionados == null)
			rellenarCasosRelacionados(triggerNew);

		/*if(eventosRelacionados == null)
			rellenarEventosRelacionados(triggerNew);*/

		if(woUpdate == null)
			woUpdate = new Map<Id,Workorder>();
		if(casoUpdate == null)
			casoUpdate= new Map<Id,Case>();
		if(tareasInsert == null)
			tareasInsert = new List<Task>();
		
		
		List<Propuesta_de_Abono__c> abonoFacturadoWO = new List<Propuesta_de_Abono__c>();
		List<Propuesta_de_Abono__c> abonoFacturadoCaso = new List<Propuesta_de_Abono__c>();
		
		Set<Id> woFacturar = new Set<Id>();
		Set<Id> casoFacturar = new Set<Id>();
		List<Propuesta_de_abono__c> eventosCrear = new List<Propuesta_de_abono__c>();
		Map<Id,String> abonosCambioEstado = new Map<Id,String>();

		List<String> listaIds = new List<String>();
		for(Propuesta_de_Abono__c abono: triggerNew){
			listaIds.add('' + abono.AB_LKP_Orden_de_Trabajo__c);
		}
		List<WorkOrder> listaWO = new List<WorkOrder>([SELECT Id, Status, Case.RecordTypeId FROM WorkOrder WHERE Id IN :listaIds]);

		if(Trigger.isInsert || Trigger.isUpdate){
		
			for(Propuesta_de_Abono__c abono: triggerNew){
				WorkOrder wo = woRelacionadas.get(abono.AB_LKP_Orden_de_Trabajo__c);
				/*if(wo == null && eventosRelacionados.get(abono.AB_LKP_Evento_Relacionado__c) != null)
					wo = woRelacionadas.get(eventosRelacionados.get(abono.AB_LKP_Evento_Relacionado__c).EV_AB_LKP_Orden_de_Trabajo__c);*/

				Case caso = casosRelacionados.get(abono.AB_LKP_Caso__c);
				/*if(caso == null && eventosRelacionados.get(abono.AB_LKP_Evento_Relacionado__c) != null)
					caso = casosRelacionados.get(eventosRelacionados.get(abono.AB_LKP_Evento_Relacionado__c).EV_AB_LKP_Caso__c);*/

				Boolean esReclamacion = ((wo != null && wo.CaseId != null && wo.Case.RecordTypeId == recordTypeReclamacion) || (caso != null && caso.RecordTypeId == recordTypeReclamacion));

				system.debug('------esReclamacion: '+esReclamacion);

				
				Propuesta_de_abono__c abOld = null;
				if(Trigger.isUpdate)
					 abOld = triggerOldMap.get(abono.Id);

				//if(esReclamacion){
				if(trigger.isInsert
					|| abono.AB_LKP_Imputar_a4__c != abOld.AB_LKP_Imputar_a4__c
					|| abono.AB_LKP_Imputar_a5__c != abOld.AB_LKP_Imputar_a5__c
					|| abono.AB_LKP_Imputar_a6__c != abOld.AB_LKP_Imputar_a6__c
					|| abono.AB_LKP_Imputar_a__c != abOld.AB_LKP_Imputar_a__c
					|| abono.AB_LKP_Imputar_a2__c != abOld.AB_LKP_Imputar_a2__c
					|| abono.AB_LKP_Imputar_a3__c != abOld.AB_LKP_Imputar_a3__c
					|| abono.AB_DIV_Importe_a_Imputar4__c != abOld.AB_DIV_Importe_a_Imputar4__c
					|| abono.AB_DIV_Importe_a_Imputar5__c != abOld.AB_DIV_Importe_a_Imputar5__c
					|| abono.AB_DIV_Importe_a_Imputar6__c != abOld.AB_DIV_Importe_a_Imputar6__c
					|| abono.AB_DIV_Importe_a_Imputar__c != abOld.AB_DIV_Importe_a_Imputar__c
					|| abono.AB_DIV_Importe_a_Imputar2__c != abOld.AB_DIV_Importe_a_Imputar2__c
					|| abono.AB_DIV_Importe_a_Imputar3__c != abOld.AB_DIV_Importe_a_Imputar3__c
					|| abono.AB_LKP_Penalizar_a_Prof__c != abOld.AB_LKP_Penalizar_a_Prof__c
					|| abono.AB_DIV_Importe_penalizacion__c != abOld.AB_DIV_Importe_penalizacion__c
					|| abono.AB_SEL_Departamento_Imputacion__c != abOld.AB_SEL_Departamento_Imputacion__c
					|| abono.AB_DIV_Importe_a_imputar_Departamento__c != abOld.AB_DIV_Importe_a_imputar_Departamento__c){
						
					eventosCrear.add(abono);
				}
				//}

				if(abono.AB_CAS_Abono_Liquidado__c && (triggerOldMap == null || !triggerOldMap.get(abono.Id).AB_CAS_Abono_Liquidado__c)){
					if(wo != null && esReclamacion){
						woFacturar.add(wo.Id);
					}/* else if(caso != null){
						casoFacturar.add(caso.Id);
					}*/
				}
			
				//Al actualizar una propuesta de evento, se comprueba si se ha modificado el estado, y si este es igual a "Aprobado";
				//Boolean facturarAbonos = false;
				/*Cuando un abono cambie su estado a “Aprobado” y NO tenga marcado el check de Abono Automático (AB_CAS_Abono_Automatico__c), se enviará al Facturador la información del Abono*/
				if(abono.AB_SEL_Estado__c == Label.EV_AB_ESTADO_APROBADO && (abOld == null || abOld.AB_SEL_Estado__c != Label.EV_AB_ESTADO_APROBADO) && !abono.AB_CAS_Abono_Automatico__c){/*Desencadenante abono aprobado no automático*/
					
					abonosCambioEstado.put(abono.Id,abono.AB_SEL_Estado__c);
					
					Id id;
					for (String fieldName : triggerNewMap.keySet()){
						id = fieldName;
						System.debug('field name is prof ' + fieldName);
					}
					system.debug('MAPA '+triggerNewMap);
					//Facturar a clientes se ha prueba en otros Test
					if (!test.isRunningTest() && triggerNew[0].AB_LKP_Cuenta__c!=null){
						//Util_Facturador.facturarCliente(triggerNew[0].AB_LKP_Cuenta__c,label.FAC_Maestro_Clientes,'');
					}
					//Comentado para la subida a Producción
					if(abono.AB_CAS_Abono_Automatico__c == false){
						Util_Facturador.calloutFacturadorAbono(triggerNewMap,Label.FAC_Eventos_b);
					}
				} else if(abono.AB_CAS_Abono_Automatico__c == true && abono.AB_SEL_Estado__c == Label.EV_AB_ESTADO_APROBADO){/*Desencadenante abono aprobado automático*/
					
					/*Cuando un abono cambie su estado a “Aprobado” y SI tenga marcado el check de Abono Automático (AB_CAS_Abono_Automatico__c), se enviará al Facturador la información del Abono junto con la
					información del Cliente, el Profesional y la Prefactura. Salvo cuando el abono automático se haya creado por anulación de servicio. En ese caso hay que comprobar cuando el abono esté aprobado si
					Abono. AB_LKP_Orden_de_Trabajo__r.Status = ‘06’ entonces en ese caso no se envía la prefactura, sólo se envía la información del abono*/
					if(abono.AB_LKP_Orden_de_Trabajo__r.Status == Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN || abono.AB_LKP_Orden_de_Trabajo__r.Status == Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO || abono.AB_LKP_Orden_de_Trabajo__r.Status == Label.OTR_ESTADO_REVISADO){
						system.debug('>>>>>PuntoControl1');
						

						if(wo.Id == abono.AB_LKP_Orden_de_Trabajo__c){
							if(wo.Case.RecordTypeId  == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO) || wo.Case.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C) || wo.Case.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C)){
								Util_Facturador.calloutFacturadorAbono(triggerNewMap,Label.FAC_Eventos_b);
								Map<Id, String> mapaOTR = new Map<Id, String>();
								mapaOTR.put(abono.AB_LKP_Orden_de_Trabajo__c, 'WorkOrder');
								Util_Llamada_Externa cliente = new Util_Llamada_Externa(mapaOTR,Label.FAC_Facturador,Label.FAC_Maestro_Clientes,'');
								Util_Llamada_Externa prefactura = new Util_Llamada_Externa(mapaOTR,Label.FAC_Facturador,Label.FAC_PreFactura,'');
								Util_Llamada_Externa profesional = new Util_Llamada_Externa(mapaOTR,Label.FAC_Facturador,Label.FAC_Maestro_Profesionales,'');
								System.enqueueJob(cliente);
								System.enqueueJob(prefactura);
								System.enqueueJob(profesional);
							}
						}

					} else if(abono.AB_CAS_Abono_Automatico__c == true && abono.AB_LKP_Orden_de_Trabajo__r.Status == Label.OTR_ESTADO_ANULADO){/*Desencadenante abono aprobado automático*/
						/*Cuando se crea un abono por anulación de servicio(abono.AB_LKP_Orden_de_Trabajo__r.Status = ‘06’), se envía la información del abono.*/
						Util_Facturador.calloutFacturadorAbono(triggerNewMap,Label.FAC_Eventos_b);
					}
				}


				if(abono.AB_SEL_Estado__c == Label.EV_AB_ESTADO_RECHAZADO && (abOld == null || abOld.AB_SEL_Estado__c != Label.EV_AB_ESTADO_RECHAZADO)){
					abonosCambioEstado.put(abono.Id,abono.AB_SEL_Estado__c);
				}
			}
		}
		
		if(!woFacturar.isEmpty()){
			woUpdate = Util_Orden_Trabajo.facturarWOEventosAbonos(woFacturar,eventosDeWo,abonosDeWo,woUpdate);
		}
		
		/*if(!casoFacturar.isEmpty()){
			Map<Id,List<Workorder>> woPorcaso = Util_Orden_Trabajo.getMapCasosOTRelacionadas(casoFacturar);
			casoUpdate = Util_Caso.facturarCasoEventosAbonos(casoFacturar,eventosDeCaso,abonosDeCaso,woPorcaso,casoUpdate);
		}*/
		
		/*if(!abonoFacturadoWO.isEmpty()){
			facturaWorkOrder(abonoFacturadoWO);
		}

		if(!abonoFacturadoCaso.isEmpty()){
			facturaCaso(abonoFacturadoCaso);
		}*/

		if(!woUpdate.isEmpty())
			update woUpdate.values();
		if(!casoUpdate.isEmpty())
			update casoUpdate.values();
		if(!tareasInsert.isEmpty())
			insert tareasInsert;
		
		if(!eventosCrear.isEmpty()){
			
			Set<Id> evCrearId = new Set<Id>();
			for(Propuesta_de_Abono__c pro: eventosCrear)
				evCrearId.add(pro.Id);
				
			//List<Propuesta_de_evento__c> eventosBorrar = [Select id from Propuesta_de_evento__c where EV_AB_LKP_Abono__c in : evCrearId];
			List<Propuesta_de_Evento__c> eventosBorrar = Util_Propuesta_de_evento.getPropuestaEventoByAbono(evCrearId).values();
			delete eventosBorrar ;
			
			crearPropuestaEvento(eventosCrear);
		}
		
		if(!abonosCambioEstado.isEmpty()){
			
			List<Propuesta_de_Evento__c> eventosAprobar = new List<Propuesta_de_evento__c>();
			List<Propuesta_de_Evento__c> eventosHijo = Util_Propuesta_de_evento.getPropuestaEventoByAbono(abonosCambioEstado.keySet()).values();
			//List<Propuesta_de_Evento__c> eventosHijo = [Select id,EV_AB_LKP_Abono__c from Propuesta_de_evento__c where EV_AB_LKP_Abono__c in : abonosCambioEstado.keySet()];
			
			if(!eventosHijo.isEmpty()){
				for(Propuesta_de_evento__c ev: eventosHijo){
					eventosAprobar.add(new Propuesta_de_evento__c(Id=ev.Id,EV_AB_SEL_Estado__c=abonosCambioEstado.get(ev.EV_AB_LKP_Abono__c)));
				}
			}
			
			if(!eventosAprobar.isEmpty()){
				update eventosAprobar;
			}
			
		}
		
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param propuestas: [PENDIENTE]
	  * 
	  */
	private static void rellenarWoRelacionadas(List<Propuesta_de_Abono__c> propuestas){
		Set<Id> woIds = new Set<Id>();

		for(Propuesta_de_Abono__c ab: propuestas){
			woIds.add(ab.AB_LKP_Orden_de_Trabajo__c);
		}

		/*if(eventosRelacionados == null)
			rellenarEventosRelacionados(propuestas);*/
		system.debug('PROPUESTAS:'+woIds);
		/*for(Propuesta_de_Evento__c ev: eventosRelacionados.values())
			woIds.add(ev.EV_AB_LKP_Orden_de_Trabajo__c);*/
		woRelacionadas = Util_Orden_Trabajo.queryMapOTById(woIds);
		//woRelacionadas = Util_Orden_Trabajo.queryOTBySet(woIds, new Set<Id>(), 'RecordTypeId != \'' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION) + '\'');
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param propuestas: [PENDIENTE]
	  * 
	  */
	private static void rellenarCasosRelacionados(List<Propuesta_de_Abono__c> propuestas){
		Set<Id> casoIds = new Set<Id>();

		for(Propuesta_de_Abono__c ab: propuestas)
			casoIds.add(ab.AB_LKP_Caso__c);

		/*if(eventosRelacionados == null)
			rellenarEventosRelacionados(propuestas);*/

		/*for(Propuesta_de_Evento__c ea: eventosRelacionados.values())
			casoIds.add(ea.EV_AB_LKP_Caso__c);*/

		/*casosRelacionados = new Map<Id,Case>([Select 
		                                      Id, 
		                                      Status,
		                                      RecordTypeId,
		                                      AccountId,
		                                      OwnerId
		                                      from Case where id in :casoIds]);*/
		casosRelacionados = Util_Caso.getCaseById(casoIds);                                      
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param abonos: [PENDIENTE]
	  * 
	  */
	/*private static void rellenarEventosRelacionados(List<Propuesta_de_Abono__c> abonos){ //Recoge al Evento padre
		Set<Id> eventoIds = new Set<Id>();

		for(Propuesta_de_Abono__c ab: abonos)
			//eventoIds.add(ab.AB_LKP_Evento_Relacionado__c);

		eventosRelacionados = new Map<Id,Propuesta_de_Evento__c>([Select 
																  Id, 
																  EV_AB_LKP_Caso__c,
																  EV_AB_SEL_Departamento_Imputacion__c,
																  EV_AB_SEL_Departamento_Solicitante__c,
																  //EV_AB_TXT_Descripcion__c,
																  EV_AB_SEL_Estado__c,
																  EV_AB_CAS_Evento_Ab_Facturado__c,
																  EV_AB_SEL_Motivo_devolucion__c,
																  EV_AB_LKP_Orden_de_Trabajo__c,
																  EV_AB_LKP_Abono__c
																  from Propuesta_de_Evento__c where id in :eventoIds]);
	}*/

	/**
	  * [PENDIENTE]
	  * 
	  * @param abonos: [PENDIENTE]
	  * 
	  */
	/*private static void facturaWorkOrder(List<Propuesta_de_Abono__c> abonos){

		Map<Id,Boolean> woFacturar = new Map<Id,Boolean>();

		for(Propuesta_de_Abono__c abono: abonos){
			WorkOrder wo = woRelacionadas.get(abono.AB_LKP_Orden_de_Trabajo__c);
			if(wo == null)
				wo = woRelacionadas.get(eventosRelacionados.get(abono.AB_LKP_Evento_Relacionado__c).EV_AB_LKP_Orden_de_Trabajo__c);
			woFacturar.put(wo.Id,true);
		}

		Map<Id,Propuesta_de_Evento__c> todosEventos = new Map<Id,Propuesta_de_Evento__c>([Select id, EV_AB_CAS_Evento_Ab_Facturado__c, EV_AB_LKP_Orden_de_Trabajo__c,EV_AB_LKP_Abono__r.AB_LKP_Orden_de_Trabajo__c from Propuesta_de_Evento__c where EV_AB_LKP_Orden_de_Trabajo__c in: woFacturar.keySet() OR EV_AB_LKP_Abono__r.AB_LKP_Orden_de_Trabajo__c in: woFacturar.keySet()]);
		Map<Id,Propuesta_de_Abono__c> todosAbonos = new Map<Id,Propuesta_de_Abono__c>([Select id, AB_CAS_Abono_Facturado__c, AB_LKP_Orden_de_Trabajo__c,AB_LKP_Evento_Relacionado__r.EV_AB_LKP_Orden_de_Trabajo__c from Propuesta_de_Abono__c where AB_LKP_Orden_de_Trabajo__c in: woFacturar.keySet() OR AB_LKP_Evento_Relacionado__r.EV_AB_LKP_Orden_de_Trabajo__c in:  woFacturar.keySet()]);

		for(Propuesta_de_Evento__c ea: todosEventos.values()){
			if(!ea.EV_AB_CAS_Evento_Ab_Facturado__c){
				Id woId = ea.EV_AB_LKP_Orden_de_Trabajo__c;
				if(woId == null)
					woId = ea.EV_AB_LKP_Abono__r.AB_LKP_Orden_de_Trabajo__c;
				woFacturar.put(woId,false);
			}
		}

		for(Propuesta_de_Abono__c ab: todosAbonos.values()){
			if(!ab.AB_CAS_Abono_Facturado__c){
				Id woId = ab.AB_LKP_Orden_de_Trabajo__c;
				if(woId == null)
					woId = ab.AB_LKP_Evento_Relacionado__r.EV_AB_LKP_Orden_de_Trabajo__c;
				woFacturar.put(woId,false);
			}
		}



		for(Id woId: woFacturar.keySet()){
			if(woFacturar.get(woId)){
				WorkOrder wo = woUpdate.get(woId);
				if(wo == null)
					wo = new WorkOrder();
				wo.Id = woId;
				wo.OTR_CAS_Orden_Trabajo_Facturada__c = true;
				wo.Status = LABEL.OTR_ESTADO_CERRADO;
				woUpdate.put(wo.Id,wo);
			}
		}
	}*/

	/**
	  * [PENDIENTE]
	  * 
	  * @param abonos: [PENDIENTE]
	  * 
	  */
	/*private static void facturaCaso(List<Propuesta_de_Abono__c> abonos){

		Map<Id,Boolean> casoFacturar = new Map<Id,Boolean>();
		for(Propuesta_de_Abono__c abono: abonos){
			Case caso = casosRelacionados.get(abono.AB_LKP_Caso__c);
			if(caso == null)
				caso = casosRelacionados.get(eventosRelacionados.get(abono.AB_LKP_Evento_Relacionado__c).EV_AB_LKP_Caso__c);
			casoFacturar.put(caso.Id,true);
		}

		Map<Id,Propuesta_de_Evento__c> todosEventos = new Map<Id,Propuesta_de_Evento__c>([Select id, EV_AB_CAS_Evento_Ab_Facturado__c, EV_AB_LKP_Caso__c,EV_AB_LKP_Abono__r.AB_LKP_Caso__c from Propuesta_de_Evento__c where EV_AB_LKP_Caso__c in: casoFacturar.keySet() or EV_AB_LKP_Abono__r.AB_LKP_Caso__c in: casoFacturar.keySet()]);
		Map<Id,Propuesta_de_Abono__c> todosAbonos = new Map<Id,Propuesta_de_Abono__c>([Select id, AB_CAS_Abono_Facturado__c, AB_LKP_Caso__c,AB_LKP_Evento_Relacionado__r.EV_AB_LKP_Caso__c from Propuesta_de_Abono__c where AB_LKP_Caso__c in: casoFacturar.keySet() or AB_LKP_Evento_Relacionado__r.EV_AB_LKP_Caso__c in: casoFacturar.keySet()]);
		Map<Id,WorkOrder> todasWO = new Map<Id,WorkOrder>([Select id, OTR_CAS_Orden_Trabajo_Facturada__c, CaseId from WorkOrder where CaseId in: casoFacturar.keySet()]);

		for(Propuesta_de_Evento__c ea: todosEventos.values()){
			if(!ea.EV_AB_CAS_Evento_Ab_Facturado__c){
				Id casoId = ea.EV_AB_LKP_Caso__c;
				if(casoId == null)
					casoId = ea.EV_AB_LKP_Abono__r.AB_LKP_Caso__c;   
				casoFacturar.put(casoId,false);
			}
		}

		for(Propuesta_de_Abono__c ab: todosAbonos.values()){
			if(!ab.AB_CAS_Abono_Facturado__c){
				Id casoId = ab.AB_LKP_Caso__c;
				if(casoId == null)
					casoId = ab.AB_LKP_Evento_Relacionado__r.EV_AB_LKP_Caso__c;
				casoFacturar.put(ab.AB_LKP_Caso__c,false);
			}
		}

		for(WorkOrder wo: todasWO.values()){
			if(!wo.OTR_CAS_Orden_Trabajo_Facturada__c)
				casoFacturar.put(wo.CaseId,false);
		}



		for(Id casoId: casoFacturar.keySet()){
			if(casoFacturar.get(casoId)){
				Case caso = casosRelacionados.get(casoId);
				Task tarea = Util_Tarea.crearTarea(Label.RT_TAR_COMUN, 'Se puede cerrar la reclamación',Label.TAR_ESTADO_SIN_INICIAR, null , caso.OwnerId, caso.Id, null);
				tareasInsert.add(tarea);
				/*Case caso = casoUpdate.get(casoId);
				if(caso == null)
				caso = new Case();
				caso.Id = casoId;
				caso.Status = Label.CAS_ESTADO_CERRADO_FACTURADO;
				casoUpdate.put(caso.Id,caso);*/
//			}

		//}
	//}
	
	
	public static List<String> facturarAbono(List<Propuesta_de_Abono__c> abonos){
		List<String> listaBody = new List<String>();
		Set<Id> idAbonos = new Set<Id>();
		for(Propuesta_de_Abono__c ab :abonos){
			idAbonos.add(ab.Id);
		}
	/*	List<Propuesta_de_Abono__c> listaConsulta = new List<Propuesta_de_Abono__c>(
		[SELECT AB_LKP_Caso__r.CAS_LKP_Procedencia__r.PROC_SEL_Canal__c
				,AB_LKP_Cuenta__c
				,AB_DIV_Importe_a_Imputar__c
				,AB_TXT_Descripcion__c
				,AB_LKP_Caso__c
				,AB_LKP_Caso__r.CAS_LKP_Procedencia__r.PROC_SEL_Subcanal__c
				,AB_LKP_Orden_de_Trabajo__r.WorkOrderNumber
				,AB_LKP_Caso__r.Type
				,AB_LKP_Caso__r.CAS_SEL_Grupo_Causa__c
				FROM Propuesta_de_Abono__c WHERE Id IN :abonos]);*/
		List<Propuesta_de_Abono__c> listaConsulta = Util_Propuesta_de_abono.getPropuestaAbonoById(idAbonos).values();

		for(Propuesta_de_Abono__c abono:abonos){
			contParametros = 0;
			body = '{';
			concatenarParametroJSON('identificadorUnicoAbono', abono.Id);
			concatenarParametroJSON('identificadorUnicoCuenta', abono.AB_LKP_Cuenta__c);
			concatenarParametroJSON('importe', abono.AB_DIV_Importe_a_imputar__c);
			concatenarParametroJSON('descripcion', abono.AB_TXT_Descripcion__c);
			concatenarParametroJSON('identificadorUnicoCaso', abono.AB_LKP_Caso__c);
			concatenarParametroJSON('identificadorUnicoOrdenTrabajo', abono.AB_LKP_Orden_de_Trabajo__c);
			concatenarParametroJSON('direccionTerritorial', abono.AB_FOR_Direccion_Territorial__c);
			concatenarParametroJSON('unidadNegocio', abono.AB_LKP_Caso__r.CAS_LKP_Procedencia__r.PROC_SEL_Canal__c);
			concatenarParametroJSON('lineaNegocio', abono.AB_LKP_Caso__r.CAS_LKP_Procedencia__r.PROC_SEL_Subcanal__c);
			concatenarParametroJSON('numOrdenTrabajo', abono.AB_LKP_Orden_de_Trabajo__r.WorkOrderNumber);
			concatenarParametroJSON('lineaOrdenTrabajo', abono.AB_LKP_Orden_de_Trabajo__r.WorkOrderNumber);
			concatenarParametroJSON('tipoIntervencion', abono.AB_LKP_Caso__r.Type);
			concatenarParametroJSON('grupoCausa', abono.AB_LKP_Caso__r.CAS_SEL_Grupo_Causa__c);
			concatenarParametroJSON('tipoRegistroCaso', abono.AB_LKP_Caso__r.RecordType);
			body += '}';
			
			listaBody.add(body);
		}
		
		return listaBody;
	}
	
	private static void concatenarParametroJSON(String nombreParametro, String valorParametro)
    {
        if (valorParametro != null)
        {
            if (contParametros > 0) {body += ',';}
            body += '"' + nombreParametro + '" : "' + valorParametro + '"';
            contParametros++;
        }else{
            if (contParametros > 0) {body += ',';}
            body += '"' + nombreParametro + '" : ""';
            contParametros++;        	
        }
    }
    
    private static void concatenarParametroJSON(String nombreParametro, Decimal valorParametro)
    {
        if (valorParametro != null)
        {
            if (contParametros > 0) {body += ',';}
            body += '"' + nombreParametro + '" :' + valorParametro;
            contParametros++;
        }else{
            if (contParametros > 0) {body += ',';}
            body += '"' + nombreParametro + '" : ""';
            contParametros++;        	
        }
    }
    
    private static void concatenarParametroJSON(String nombreParametro, RecordType valorParametro)
    {
        if (valorParametro != null)
        {
            if (contParametros > 0) {body += ',';}
            body += '"' + nombreParametro + '" : "' + valorParametro + '"';
            contParametros++;
        }else{
            if (contParametros > 0) {body += ',';}
            body += '"' + nombreParametro + '" : ""';
            contParametros++;        	
        }
    }
    /**
	  * [PENDIENTE]
	  * 
	  * @param triggerNew: [WorkOrderLineItem]
	  * @param caseId
	  * @param profesional
	  * 
	  */
	private static void crearPropuestaEvento(List<Propuesta_de_abono__c> triggerNew){
		
		system.debug('----------------listawos: '+triggerNew);
		
		List<Propuesta_de_Evento__c> evntList = new List<Propuesta_de_Evento__c>();
		
		
		
		for(Propuesta_de_abono__c ab: triggerNew){
			
			Map<Id,Double> profesionalesImporte = new Map<Id,Double>();
			Map<Id,Double> gestoresImporte = new Map<Id,Double>();
			Map<Id,Double> penalizacionesImporte = new Map<Id,Double>();
			
			if(ab.AB_LKP_Imputar_a4__c != null){
				Double importeTemp = profesionalesImporte.get(ab.AB_LKP_Imputar_a4__c);
				if(importeTemp == null)
					importeTemp = 0;
				importeTemp += ab.AB_DIV_Importe_a_Imputar4__c;
				profesionalesImporte.put(ab.AB_LKP_Imputar_a4__c,importeTemp);
			}
			if(ab.AB_LKP_Imputar_a5__c != null){
				Double importeTemp = profesionalesImporte.get(ab.AB_LKP_Imputar_a5__c);
				if(importeTemp == null)
					importeTemp = 0;
				importeTemp += ab.AB_DIV_Importe_a_Imputar5__c	;
				profesionalesImporte.put(ab.AB_LKP_Imputar_a5__c,importeTemp);
			}
			if(ab.AB_LKP_Imputar_a6__c != null){
				Double importeTemp = profesionalesImporte.get(ab.AB_LKP_Imputar_a6__c);
				if(importeTemp == null)
					importeTemp = 0;
				importeTemp += ab.AB_DIV_Importe_a_Imputar6__c;
				profesionalesImporte.put(ab.AB_LKP_Imputar_a6__c,importeTemp);
			}
			if(ab.AB_LKP_Imputar_a__c != null){
				Double importeTemp = gestoresImporte.get(ab.AB_LKP_Imputar_a__c);
				if(importeTemp == null)
					importeTemp = 0;
				importeTemp += ab.AB_DIV_Importe_a_Imputar__c;
				gestoresImporte.put(ab.AB_LKP_Imputar_a__c,importeTemp);
			}
			if(ab.AB_LKP_Imputar_a2__c != null){
				Double importeTemp = gestoresImporte.get(ab.AB_LKP_Imputar_a2__c);
				if(importeTemp == null)
					importeTemp = 0;
				importeTemp += ab.AB_DIV_Importe_a_Imputar2__c;
				gestoresImporte.put(ab.AB_LKP_Imputar_a2__c,importeTemp);
			}
			if(ab.AB_LKP_Imputar_a3__c != null){
				Double importeTemp = gestoresImporte.get(ab.AB_LKP_Imputar_a3__c);
				if(importeTemp == null)
					importeTemp = 0;
				importeTemp += ab.AB_DIV_Importe_a_Imputar3__c;
				gestoresImporte.put(ab.AB_LKP_Imputar_a3__c,importeTemp);
			}
			if(ab.AB_LKP_Penalizar_a_Prof__c != null){
				Double importeTemp = penalizacionesImporte.get(ab.AB_LKP_Penalizar_a_Prof__c);
				if(importeTemp == null)
					importeTemp = 0;
				importeTemp += ab.AB_DIV_Importe_penalizacion__c;
				penalizacionesImporte.put(ab.AB_LKP_Penalizar_a_Prof__c,importeTemp);
			}
			
			if(ab.AB_SEL_Departamento_Imputacion__c != null) {
				Propuesta_de_Evento__c propEvnt = new Propuesta_de_Evento__c();
				propEvnt.EV_AB_SEL_Descripcion__c = Label.AB_DESCRIPCION_IMP_GESTOR;
				propEvnt.EV_AB_CAS_Evento_Automatico__c = true;
				propEvnt.EV_AB_LKP_Caso__c = ab.AB_LKP_Caso__c;
				propEvnt.EV_AB_LKP_Orden_de_Trabajo__c = ab.AB_LKP_Orden_de_Trabajo__c;
				propEvnt.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
				propEvnt.EV_DIV_Importe_a_imputar_Departamento__c  = ab.AB_DIV_Importe_a_imputar_Departamento__c;
				propEvnt.EV_AB_SEL_Departamento_Imputacion__c = ab.AB_SEL_Departamento_Imputacion__c;
				propEvnt.EV_AB_LKP_Abono__c = ab.Id;
				propEvnt.EV_AB_SEL_Estado__c = Label.EV_AB_ESTADO_NUEVO;
				propEvnt.EV_AB_SEL_Departamento_Solicitante__c = ab.AB_SEL_Departamento_Solicitante__c;
				evntList.add(propEvnt);
			}

			if(!profesionalesImporte.isEmpty() || !gestoresImporte.isEmpty() || !penalizacionesImporte.isEmpty()){
				
				for(Id prof: profesionalesImporte.keySet()){
					Propuesta_de_Evento__c propEvntProf1 = new Propuesta_de_Evento__c();
					propEvntProf1.EV_AB_SEL_Descripcion__c = Label.AB_DESCRIPCION_COBRO_RECLAM;
					propEvntProf1.EV_AB_CAS_Evento_Automatico__c = true;
					propEvntProf1.EV_AB_LKP_Caso__c = ab.AB_LKP_Caso__c;
					propEvntProf1.EV_AB_LKP_Orden_de_Trabajo__c = ab.AB_LKP_Orden_de_Trabajo__c;
					propEvntProf1.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
					propEvntProf1.EV_AB_DIV_Importe_profesional__c  = profesionalesImporte.get(prof);
					propEvntProf1.EV_AB_LKP_Imputar_a_profesional__c = prof;
					propEvntProf1.EV_AB_LKP_Abono__c = ab.Id;
					propEvntProf1.EV_AB_SEL_Estado__c = Label.EV_AB_ESTADO_NUEVO;
					propEvntProf1.EV_AB_SEL_Departamento_Solicitante__c = ab.AB_SEL_Departamento_Solicitante__c;
					evntList.add(propEvntProf1);
				}
				
				for(Id gest: gestoresImporte.keySet()){
					Propuesta_de_Evento__c propEvntGes1 = new Propuesta_de_Evento__c();
					propEvntGes1.EV_AB_SEL_Descripcion__c = Label.AB_DESCRIPCION_IMP_GESTOR;
					propEvntGes1.EV_AB_CAS_Evento_Automatico__c = true;
					propEvntGes1.EV_AB_LKP_Caso__c = ab.AB_LKP_Caso__c;
					propEvntGes1.EV_AB_LKP_Orden_de_Trabajo__c = ab.AB_LKP_Orden_de_Trabajo__c;
					propEvntGes1.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
					propEvntGes1.EV_AB_DIV_Importe_gestor__c = gestoresImporte.get(gest);
					propEvntGes1.EV_AB_LKP_Imputar_a_gestor__c = gest;
					propEvntGes1.EV_AB_LKP_Abono__c = ab.Id;
					propEvntGes1.EV_AB_SEL_Estado__c = Label.EV_AB_ESTADO_NUEVO;
					propEvntGes1.EV_AB_SEL_Departamento_Solicitante__c = ab.AB_SEL_Departamento_Solicitante__c;
					evntList.add(propEvntGes1);
				}
				
				for(Id prof: penalizacionesImporte.keySet()){
					Propuesta_de_Evento__c propEvntPen1 = new Propuesta_de_Evento__c();
					propEvntPen1.EV_AB_SEL_Descripcion__c = 'E19';
					propEvntPen1.EV_AB_CAS_Evento_Automatico__c = true;
					propEvntPen1.EV_AB_LKP_Caso__c = ab.AB_LKP_Caso__c;
					propEvntPen1.EV_AB_LKP_Orden_de_Trabajo__c = ab.AB_LKP_Orden_de_Trabajo__c;
					propEvntPen1.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
					propEvntPen1.EV_AB_DIV_Importe_profesional__c  = penalizacionesImporte.get(prof);
					propEvntPen1.EV_AB_LKP_Imputar_a_profesional__c = prof;
					propEvntPen1.EV_AB_LKP_Abono__c = ab.Id;
					propEvntPen1.EV_AB_SEL_Estado__c = Label.EV_AB_ESTADO_NUEVO;
					propEvntPen1.EV_AB_SEL_Departamento_Solicitante__c = ab.AB_SEL_Departamento_Solicitante__c;
					evntList.add(propEvntPen1);
				}
			}
		}
				
		system.debug('----------evntList: '+evntList);
		
		if(!evntList.isEmpty()){
			insert evntList;
		}
		
	}
	
	public static void calloutFacturador(List<WorkOrder> listaWO, Propuesta_de_Abono__c abono){
		for(WorkOrder wOrder:listaWO){
			if(wOrder.Id == abono.AB_LKP_Orden_de_Trabajo__c){
				if(wOrder.Status == Label.OTR_ESTADO_CERRADO_PDTE_ALBARAN || wOrder.Status == Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO || wOrder.Status == Label.OTR_ESTADO_CERRADO ||wOrder.Status == Label.OTR_ESTADO_REVISADO){
					if(wOrder.Case.RecordTypeId  == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO) || wOrder.Case.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C) || wOrder.Case.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C)){
						Map<Id, String> mapaOTR = new Map<Id, String>();
						mapaOTR.put(abono.AB_LKP_Orden_de_Trabajo__c, 'WorkOrder');
						Util_Llamada_Externa cliente = new Util_Llamada_Externa(mapaOTR,'Facturador',Label.FAC_Maestro_Clientes,'');
						Util_Llamada_Externa prefactura = new Util_Llamada_Externa(mapaOTR,'Facturador',Label.FAC_PreFactura,'');
						Util_Llamada_Externa profesional = new Util_Llamada_Externa(mapaOTR,'Facturador',Label.FAC_Maestro_Profesionales,'');
						System.enqueueJob(cliente);
						System.enqueueJob(prefactura);
						System.enqueueJob(profesional);
					}
				}
			}
		}
	}
	
	/*private static void crearPropuestaEvento(List<Propuesta_de_Abono__c> triggerNew){
		
		Double importeEventoProf1 = 0;
		Double importeEventoProf2 = 0;
		Double importeEventoProf3 = 0;
		Double importeEventoGest1 = 0;
		Double importeEventoGest2 = 0;
		Double importeEventoGest3 = 0;
		Id prof1;
		Id prof2;
		Id prof3;
		Id ges1;
		Id ges2;
		Id ges3;
		List<Propuesta_de_Evento__c> evntList = new List<Propuesta_de_Evento__c>();
		system.debug('<<<<<<<<<<<sera caso>>>>>>>>>>>>>' + triggerNew.get(0).AB_LKP_Caso__c);
		if(!triggerNew.isEmpty()){
			List<Propuesta_de_Evento__c> evntToDeleteList = new List<Propuesta_de_Evento__c>([SELECT Id FROM Propuesta_de_Evento__c
				WHERE EV_AB_LKP_Orden_de_Trabajo__c = :triggerNew.get(0).AB_LKP_Caso__c]);

			delete evntToDeleteList;
		}
		

			for(Propuesta_de_Abono__c propuesta: triggerNew){
				system.debug('>>>>>propuesta: ' + propuesta);
				//comprobamos si las partidas estan asignadas al mismo profesional.
				if(propuesta.AB_LKP_Imputar_a4__c != null){
					importeEventoProf1 = propuesta.AB_DIV_Importe_a_Imputar4__c;
					prof1 = propuesta.AB_LKP_Imputar_a4__c;
				}
				if(propuesta.AB_LKP_Imputar_a5__c  != null && 
					propuesta.AB_LKP_Imputar_a5__c  == propuesta.AB_LKP_Imputar_a4__c){
					importeEventoProf1 = importeEventoProf1 + propuesta.AB_DIV_Importe_a_Imputar5__c;
				}
				if(propuesta.AB_LKP_Imputar_a6__c != null && 
					propuesta.AB_LKP_Imputar_a6__c == propuesta.AB_LKP_Imputar_a4__c){
					importeEventoProf1 = importeEventoProf1 + propuesta.AB_DIV_Importe_a_Imputar6__c;
				}
				if(propuesta.AB_LKP_Imputar_a5__c != null && propuesta.AB_LKP_Imputar_a5__c != propuesta.AB_LKP_Imputar_a4__c){
					prof2 = propuesta.AB_LKP_Imputar_a5__c;
					importeEventoProf2 = propuesta.AB_DIV_Importe_a_Imputar5__c;
				}
				if(propuesta.AB_LKP_Imputar_a5__c != null && 
					propuesta.AB_LKP_Imputar_a5__c == propuesta.AB_LKP_Imputar_a6__c
					&& propuesta.AB_LKP_Imputar_a5__c != propuesta.AB_LKP_Imputar_a4__c){
					importeEventoProf2 = importeEventoProf2 + propuesta.AB_DIV_Importe_a_Imputar6__c;
				}
				if(propuesta.AB_LKP_Imputar_a6__c != null && propuesta.AB_LKP_Imputar_a6__c != propuesta.AB_LKP_Imputar_a4__c
					&& propuesta.AB_LKP_Imputar_a6__c != propuesta.AB_LKP_Imputar_a5__c){
					prof3 = propuesta.AB_LKP_Imputar_a6__c ;
					importeEventoProf3 = propuesta.AB_DIV_Importe_a_Imputar6__c;
				}
				//comprobamos si las partidas estan asignadas al mismo gestor.
				if(propuesta.AB_LKP_Imputar_a__c != null){
					ges1 = propuesta.AB_LKP_Imputar_a__c;
					importeEventoGest1 = propuesta.AB_DIV_Importe_a_Imputar__c;
				}
				if(propuesta.AB_LKP_Imputar_a2__c != null && 
					propuesta.AB_LKP_Imputar_a2__c == propuesta.AB_LKP_Imputar_a__c){
					importeEventoGest1 = importeEventoGest1 + propuesta.AB_DIV_Importe_a_Imputar2__c;
				}
				if(propuesta.AB_LKP_Imputar_a3__c != null && 
					propuesta.AB_LKP_Imputar_a3__c == propuesta.AB_LKP_Imputar_a__c){
					importeEventoGest1 = importeEventoGest1 + propuesta.AB_DIV_Importe_a_Imputar3__c;
				}
				if(propuesta.AB_LKP_Imputar_a2__c != null && propuesta.AB_LKP_Imputar_a2__c != propuesta.AB_LKP_Imputar_a__c){
					ges2 = propuesta.AB_LKP_Imputar_a2__c;
					importeEventoGest2 = propuesta.AB_DIV_Importe_a_Imputar5__c;
				}
				if(propuesta.AB_LKP_Imputar_a2__c != null && 
					propuesta.AB_LKP_Imputar_a2__c == propuesta.AB_LKP_Imputar_a3__c
					&& propuesta.AB_LKP_Imputar_a3__c != propuesta.AB_LKP_Imputar_a__c){
					importeEventoGest2 = importeEventoGest2 + propuesta.AB_DIV_Importe_a_Imputar2__c;
				}
				if(propuesta.AB_LKP_Imputar_a3__c != null && propuesta.AB_LKP_Imputar_a3__c != propuesta.AB_LKP_Imputar_a__c
					&& propuesta.AB_LKP_Imputar_a3__c != propuesta.AB_LKP_Imputar_a2__c){
					ges3 = propuesta.AB_LKP_Imputar_a3__c;
					importeEventoGest3 = propuesta.AB_DIV_Importe_a_Imputar3__c;
				}
			}

			if(importeEventoProf1!=null || importeEventoProf2 != null || importeEventoProf3!=null
				||importeEventoGest1 !=null || importeEventoGest2 != null || importeEventoGest3 != null){

				if(importeEventoProf1 > 0){
					Propuesta_de_Evento__c propEvntProf1 = new Propuesta_de_Evento__c();
					propEvntProf1.EV_AB_SEL_Descripcion__c = Label.AB_DESCRIPCION_COBRO_RECLAM;
					propEvntProf1.EV_AB_LKP_Caso__c = triggerNew.get(0).AB_LKP_Caso__c ;
					propEvntProf1.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
					propEvntProf1.EV_AB_DIV_Importe_profesional__c  = importeEventoProf1;
					propEvntProf1.EV_AB_LKP_Imputar_a_profesional__c = prof1;
					propEvntProf1.EV_AB_SEL_Estado__c = Label.AB_ESTADO_NUEVO;
					evntList.add(propEvntProf1);
				}
				if(importeEventoProf2 > 0){
					Propuesta_de_Evento__c propEvntProf2 = new Propuesta_de_Evento__c();
					propEvntProf2.EV_AB_SEL_Descripcion__c = Label.AB_DESCRIPCION_COBRO_RECLAM;
					propEvntProf2.EV_AB_LKP_Caso__c = triggerNew.get(0).AB_LKP_Caso__c ;
					propEvntProf2.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
					propEvntProf2.EV_AB_DIV_Importe_profesional__c  = importeEventoProf2;
					propEvntProf2.EV_AB_LKP_Imputar_a_profesional__c  = prof2;
					propEvntProf2.EV_AB_SEL_Estado__c = Label.AB_ESTADO_NUEVO;
					evntList.add(propEvntProf2);
				}
				if(importeEventoProf3 > 0){
					Propuesta_de_Evento__c propEvntProf3 = new Propuesta_de_Evento__c();
					propEvntProf3.EV_AB_SEL_Descripcion__c = Label.AB_DESCRIPCION_COBRO_RECLAM;
					propEvntProf3.EV_AB_LKP_Caso__c = triggerNew.get(0).AB_LKP_Caso__c;
					propEvntProf3.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
					propEvntProf3.EV_AB_DIV_Importe_profesional__c  = importeEventoProf3;
					propEvntProf3.EV_AB_LKP_Imputar_a_profesional__c = prof3;
					propEvntProf3.EV_AB_SEL_Estado__c = Label.AB_ESTADO_NUEVO;
					evntList.add(propEvntProf3);
				}
				if(importeEventoGest1 > 0){
					Propuesta_de_Evento__c propEvntGes1 = new Propuesta_de_Evento__c();
					propEvntGes1.EV_AB_SEL_Descripcion__c = Label.AB_DESCRIPCION_IMP_GESTOR;
					propEvntGes1.EV_AB_LKP_Caso__c = triggerNew.get(0).AB_LKP_Caso__c;
					propEvntGes1.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
					propEvntGes1.EV_AB_DIV_Importe_gestor__c  = importeEventoGest1;
					propEvntGes1.EV_AB_LKP_Imputar_a_gestor__c = ges1;
					propEvntGes1.EV_AB_SEL_Estado__c = Label.AB_ESTADO_NUEVO;
					evntList.add(propEvntGes1);
				}
				if(importeEventoGest2 > 0){
					Propuesta_de_Evento__c propEvntGes2 = new Propuesta_de_Evento__c();
					propEvntGes2.EV_AB_SEL_Descripcion__c = Label.AB_DESCRIPCION_IMP_GESTOR;
					propEvntGes2.EV_AB_LKP_Caso__c = triggerNew.get(0).AB_LKP_Caso__c;
					propEvntGes2.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
					propEvntGes2.EV_AB_DIV_Importe_gestor__c  = importeEventoGest2;
					propEvntGes2.EV_AB_LKP_Imputar_a_gestor__c = ges2;
					propEvntGes2.EV_AB_SEL_Estado__c = Label.AB_ESTADO_NUEVO;
					evntList.add(propEvntGes2);
				}
				if(importeEventoGest3 > 0){
					Propuesta_de_Evento__c propEvntGes3 = new Propuesta_de_Evento__c();
					propEvntGes3.EV_AB_SEL_Descripcion__c = Label.AB_DESCRIPCION_IMP_GESTOR;
					propEvntGes3.EV_AB_LKP_Caso__c = triggerNew.get(0).AB_LKP_Caso__c ;
					propEvntGes3.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
					propEvntGes3.EV_AB_DIV_Importe_gestor__c  = importeEventoGest3;
					propEvntGes3.EV_AB_LKP_Imputar_a_gestor__c = ges3;
					propEvntGes3.EV_AB_SEL_Estado__c = Label.AB_ESTADO_NUEVO;
					evntList.add(propEvntGes3);
				}
				system.debug('<<<<<<<<<<<sera caso' + triggerNew.get(0).AB_LKP_Caso__c);
				if(!evntList.isEmpty()){
					insert evntList;
					for(Propuesta_de_Evento__c prop: evntList){
						prop.EV_AB_TXT_Identificador__c = prop.Name;
					}
					update evntList;
				}



			}
	}*/
}