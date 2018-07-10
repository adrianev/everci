/**
 * Handler del Trigger TRG_Propuesta_de_Evento.
 * 
 * @author EVERIS
 * 
 */
public without sharing class TRG_Handler_Propuesta_de_Evento {

	private static Map<Id,WorkOrder> woRelacionadas;
	private static Map<Id,Case> casosRelacionados;
	private static Map<Id,ServiceResource> recursosRelacionados;
	//private static Map<Id,Linea_de_Evento__c> lineasRelacionadas;
	private static Map<Id,Propuesta_de_Abono__c> abonoPorIDEvento;
	private static Map<Id,Propuesta_de_Abono__c> abonosRelacionados;

	private static Map<Id,WorkOrder> woUpdate;
	private static Map<Id,Case> casoUpdate;
	private static List<Task> tareasInsert;


	/**
	  * Tratamiento para el caso before del trigger.
	  * 
	  * @param triggerNewMap: mapa de registros nuevos del objeto Propuesta_de_Evento__c a partir del Id
	  * @param triggerNew: lista de registros nuevos del objeto Propuesta_de_Evento__c
	  * @param triggerOldMap: mapa de registros antiguos del objeto Propuesta_de_Evento__c a partir del Id
	  * @param triggerOld: lista de registros antiguos del objeto Propuesta_de_Evento__c
	  */
	public static void tratamientoBefore(Map<Id, Propuesta_de_Evento__c> triggerNewMap, List<Propuesta_de_Evento__c> triggerNew, 
			Map<Id, Propuesta_de_Evento__c> triggerOldMap, List<Propuesta_de_Evento__c> triggerOld){

		//Control de maximos Abonos y Eventos --> Tengo que mirar si el Evento padre tiene un LKP a evento
		rellenarWoRelacionadas(triggerNew);
		rellenarCasosRelacionados(triggerNew);
		rellenarRecursosRelacionados(triggerNew);
		if(abonosRelacionados == null){
			rellenarAbonosRelacionados(triggerNew);
		}

		for(Propuesta_de_Evento__c evt : triggerNew){
			Propuesta_de_Abono__c abonoAux = abonosRelacionados.get(evt.EV_AB_LKP_Abono__c);
			if(abonoAux != null && String.isBlank(evt.EV_AB_SEL_Descripcion__c)){
				evt.EV_AB_SEL_Descripcion__c = abonoAux.AB_SEL_Descripcion_evento__c;
			}
			Workorder woPadre = woRelacionadas.get(evt.EV_AB_LKP_Orden_de_Trabajo__c);
			Case casoPadre = casosRelacionados.get(evt.EV_AB_LKP_Caso__c);

			/*if(woPadre != null){
				evt.EV_AB_SEL_Procedencias_bloqueadas__c = woPadre.Account.CUE_SEL_Procedencias_bloq__c;
				evt.EV_AB_SEL_Tipo_de_red__c = woPadre.Account.CUE_SEL_Tipo_de_red__c;
			} else if(casoPadre != null) {
				evt.EV_AB_SEL_Procedencias_bloqueadas__c = casoPadre.Account.CUE_SEL_Procedencias_bloq__c;
				evt.EV_AB_SEL_Tipo_de_red__c = casoPadre.Account.CUE_SEL_Tipo_de_red__c;
			}*/
			
			
			if(evt.EV_AB_LKP_Imputar_a_profesional__c != null){
				
				//NEW
				if(Trigger.isInsert || (Trigger.isUpdate  && evt.EV_AB_LKP_Imputar_a_profesional__c != triggerOldMap.get(evt.Id).EV_AB_LKP_Imputar_a_profesional__c )){
					
					ServiceResource imputado = recursosRelacionados.get(evt.EV_AB_LKP_Imputar_a_profesional__c);
					
					if(woPadre != null && woPadre.OTR_LKP_Recurso_Servicio__c == evt.EV_AB_LKP_Imputar_a_profesional__c){
						
						evt.EV_AB_SEL_Procedencias_bloqueadas__c = woPadre.OTR_SEL_Procedencias_bloqueadas__c;
						evt.EV_AB_SEL_Tipo_de_red__c = woPadre.OTR_SEL_Tipo_de_red_prof__c;
						evt.EV_AB_CAS_Confianza_en_la_red__c = woPadre.OTR_CAS_Confianza_en_la_red__c;
						
						Set<String> procedencias = new Set<String>{};
						Set<String> codigosEventos = new Set<String>{};
						
						evt.EV_AB_CAS_Evento_Bloqueado__c = false;
						
						if(!String.isBlank(woPadre.OTR_SEL_Procedencias_bloqueadas__c))
							procedencias = new Set<String>(woPadre.OTR_SEL_Procedencias_bloqueadas__c.split(';'));
							
						if(!String.isBlank(woPadre.OTR_SEL_Eventos_bloqueados_Proc__c))
							codigosEventos = new Set<String>(woPadre.OTR_SEL_Eventos_bloqueados_Proc__c.split(';'));
						
						if(procedencias.contains(evt.EV_AB_FOR_Procedencia__c) && codigosEventos.contains(evt.EV_AB_SEL_Descripcion__c) )
							evt.EV_AB_CAS_Evento_Bloqueado__c = true;

						if(!String.isBlank(woPadre.OTR_SEL_Bloqueo_Eventos__c)){
							Set<String> codigos = new Set<String>(woPadre.OTR_SEL_Bloqueo_Eventos__c.split(';'));
							if(codigos.contains(evt.EV_AB_SEL_Descripcion__c))
								evt.EV_AB_CAS_Evento_Bloqueado__c = true;
						}
					} else {

						evt.EV_AB_SEL_Procedencias_bloqueadas__c = imputado.RSE_LKP_Cuenta__r.CUE_SEL_Procedencias_bloq__c ;//evt.EV_AB_LKP_Imputar_a_profesional__r.RSE_LKP_Cuenta__r.CUE_SEL_Procedencias_bloq__c;
						evt.EV_AB_SEL_Tipo_de_red__c = imputado.RSE_LKP_Cuenta__r.CUE_SEL_Tipo_de_red__c ;//evt.EV_AB_LKP_Imputar_a_profesional__r.RSE_LKP_Cuenta__r.CUE_SEL_Tipo_de_red__c ;
						evt.EV_AB_CAS_Confianza_en_la_red__c = imputado.RSE_LKP_Cuenta__r.CUE_CAS_Confianza_en_la_red__c ;// evt.EV_AB_LKP_Imputar_a_profesional__r.RSE_LKP_Cuenta__r.CUE_CAS_Confianza_en_la_red__c ;
						
						Set<String> procedencias = new Set<String>{};
						Set<String> codigosEventos = new Set<String>{};
						
						evt.EV_AB_CAS_Evento_Bloqueado__c = false;

						
						if(!String.isBlank(imputado.RSE_LKP_Cuenta__r.CUE_SEL_Procedencias_bloq__c))
							procedencias = new Set<String>(imputado.RSE_LKP_Cuenta__r.CUE_SEL_Procedencias_bloq__c.split(';'));
							
						if(!String.isBlank(imputado.RSE_LKP_Cuenta__r.CUE_SEL_Eventos_bloqueados_Proc__c))
							codigosEventos = new Set<String>(imputado.RSE_LKP_Cuenta__r.CUE_SEL_Eventos_bloqueados_Proc__c.split(';'));
						
						if(procedencias.contains(evt.EV_AB_FOR_Procedencia__c) && codigosEventos.contains(evt.EV_AB_SEL_Descripcion__c) )
							evt.EV_AB_CAS_Evento_Bloqueado__c = true;
						
						if(imputado != null && imputado.RSE_LKP_Cuenta__c != null && !String.isBlank(imputado.RSE_LKP_Cuenta__r.CUE_SEL_Bloqueo_Eventos__c)){
							Set<String> codigos = new Set<String>(imputado.RSE_LKP_Cuenta__r.CUE_SEL_Bloqueo_Eventos__c.split(';'));
							if(codigos.contains(evt.EV_AB_SEL_Descripcion__c))
								evt.EV_AB_CAS_Evento_Bloqueado__c = true;
						}
					}

				}

			} else {
				evt.EV_AB_SEL_Procedencias_bloqueadas__c = null;
				evt.EV_AB_SEL_Tipo_de_red__c = null;
				evt.EV_AB_CAS_Confianza_en_la_red__c = false;
				evt.EV_AB_CAS_Evento_Bloqueado__c = false;
			}
		}
	}

	/**
	  * Tratamiento para el caso after del trigger.
	  * 
	  * @param triggerNewMap: mapa de registros nuevos del objeto Propuesta_de_Evento__c a partir del Id
	  * @param triggerNew: lista de registros nuevos del objeto Propuesta_de_Evento__c
	  * @param triggerOldMap: mapa de registros antiguos del objeto Propuesta_de_Evento__c a partir del Id
	  * @param triggerOld: lista de registros antiguos del objeto Propuesta_de_Evento__c
	  */
	public static void tratamientoAfter(Map<Id, Propuesta_de_Evento__c> triggerNewMap, List<Propuesta_de_Evento__c> triggerNew, 
			Map<Id, Propuesta_de_Evento__c> triggerOldMap, List<Propuesta_de_Evento__c> triggerOld){
				
		system.debug('triggerNew '+triggerNew );
		system.debug('triggerNewMap '+triggerNewMap );
		List<String> idEvento = new List<String>();
		List<Propuesta_de_Evento__c> actualizarIdentificadores = new List<Propuesta_de_evento__c>();
		Set<Id> woIds = new Set<Id>();
		Set<Id> casoIds = new Set<Id>();
		Set<Id> cuentaIds = new Set<Id>();
		for(Propuesta_de_Evento__c trg : triggerNew){
			
			/*En este if else, depende del lkp a profesional que esté relleno, rellenamos la lista con un valor u otro, para la consulta realizada posteriormente*/
			if(trg.EV_AB_LKP_Liquidar_a_prof__c != null){
				idEvento.add(trg.EV_AB_LKP_Liquidar_a_prof__c);
			} else if (trg.EV_AB_LKP_Imputar_a_profesional__c != null){
				idEvento.add(trg.EV_AB_LKP_Imputar_a_profesional__c);
			}
			//idEvento.add(trg.EV_AB_LKP_Liquidar_a_prof__c);
			woIds.add(trg.EV_AB_LKP_Orden_de_Trabajo__c);
			casoIds.add(trg.EV_AB_LKP_Caso__c);
			cuentaIds.add(trg.EV_AB_LKP_Cuenta_profesional__c);
			
			if(String.isEmpty(trg.EV_AB_TXT_Identificador__c)){
				Propuesta_de_Evento__c nuevo = new Propuesta_de_Evento__c(Id=trg.Id,EV_AB_TXT_Identificador__c=trg.Name);
				actualizarIdentificadores.add(nuevo);
			}
				
		}
		
		if(!actualizarIdentificadores.isEmpty()){
			Baipas.establecerVariableControl();
			update actualizarIdentificadores;
			Baipas.deshabilitarVariableControl();			
		}
		
		Map<Id,ServiceResource> idProfesionalesCuenta = new Map<Id,ServiceResource>([SELECT Id,RSE_LKP_Cuenta__c FROM ServiceResource WHERE Id IN: idEvento]);
		//List<ServiceResource> idProfesionalesCuenta = [SELECT RSE_LKP_Cuenta__c FROM ServiceResource WHERE Id IN: idEvento];
		//Propuesta_de_Evento__c aa = [Select EV_AB_LKP_ImputarProfesional__c from Propuesta_de_Evento__c limit 1][0];
		
		Map<Id,List<Propuesta_de_evento__c>> eventosDeWo = Util_Orden_Trabajo.pEventosByWO(woIds);
		Map<Id,List<Propuesta_de_abono__c>> abonosDeWo = Util_Orden_Trabajo.pAbonosByWO(woIds);
		
		Map<Id,List<Propuesta_de_evento__c>> eventosDeCaso = Util_Propuesta_de_evento.pEventosByCaso(casoIds);
		Map<Id,List<Propuesta_de_abono__c>> abonosDeCaso = Util_Propuesta_de_abono.pAbonosByCaso(casoIds);
		
		Map<Id,List<Propuesta_de_evento__c>> eventosDeProfesional = Util_Cuentas.pEventosByCuenta(cuentaIds);
		
		if(woUpdate == null){
			woUpdate = new Map<Id,Workorder>();
		}
		if(casoUpdate == null){
			casoUpdate= new Map<Id,Case>();
		}
		if(tareasInsert == null){
			tareasInsert = new List<Task>();
		}
			
		Id recordTypeReclamacion = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION);

		/*rellenarAbonosRelacionados(triggerNew);*/
		if(woRelacionadas == null)
			rellenarWoRelacionadas(triggerNew);
		if(casosRelacionados == null)
			rellenarCasosRelacionados(triggerNew);
		/*rellenarabonoPorIDEvento(triggerNew);*/
		
		Set<Id> woFacturar = new Set<Id>();
		Set<Id> casoFacturar = new Set<Id>();
		Map<Id,String> eventosCambioEstado = new Map<Id,String>();

		if(Trigger.isInsert || Trigger.isUpdate){

			Set<Id> conError = validacionesEventos(triggerNew, eventosDeWo, eventosDeCaso, eventosDeProfesional);

			system.debug('>>>>>AntesBucle');
			for(Propuesta_de_Evento__c ea: triggerNew){

				if(conError.contains(ea.Id))
					continue;

				WorkOrder wo = woRelacionadas.get(ea.EV_AB_LKP_Orden_de_Trabajo__c);
				if(wo == null && abonosRelacionados.get(ea.EV_AB_LKP_Abono__c) != null){
					wo = woRelacionadas.get(abonosRelacionados.get(ea.EV_AB_LKP_Abono__c).AB_LKP_Orden_de_Trabajo__c);
				}
				system.debug('>>>>>PCA');
				Case caso = casosRelacionados.get(ea.EV_AB_LKP_Caso__c);
				if(caso == null && abonosRelacionados.get(ea.EV_AB_LKP_Abono__c) != null){
					caso = casosRelacionados.get(abonosRelacionados.get(ea.EV_AB_LKP_Abono__c).AB_LKP_Caso__c);
				}

				Boolean esReclamacion = ((wo != null && wo.CaseId != null && wo.Case.RecordTypeId == recordTypeReclamacion) || (caso != null && caso.RecordTypeId == recordTypeReclamacion));
				system.debug('>>>>>PCB');

				if(esReclamacion){

					if(ea.EV_AB_CAS_Evento_Ab_Facturado__c && (triggerOldMap == null || !triggerOldMap.get(ea.Id).EV_AB_CAS_Evento_Ab_Facturado__c)){
						if(wo != null){
							woFacturar.add(wo.Id);
						}/*else if(caso != null){
							casoFacturar.add(caso.Id);
						}*/
					}

				}
				
				Propuesta_de_evento__c evOld = null;
				if(Trigger.isUpdate)
					 evOld = triggerOldMap.get(ea.Id);
				system.debug('>>>>>PCc');
				//Al actualizar una propuesta de evento, se comprueba si se ha modificado el estado, y si este es igual a "Aprobado";
				Boolean facturarEventos = false;
				/*Cuando un evento cambie su estado a “Aprobado”, y el código sea distinto a “E111”, se enviará al Facturador el Evento. Además, este debe tener sin marcar el check de evento 
				bloqueado (EV_AB_CAS_Evento_Bloqueado__c = false)*/
				if(ea.EV_AB_SEL_Estado__c == Label.EV_AB_ESTADO_APROBADO && ea.EV_AB_CAS_Evento_Bloqueado__c == false && (evOld == null || evOld.EV_AB_SEL_Estado__c != Label.EV_AB_ESTADO_APROBADO && ea.EV_AB_SEL_Descripcion__c != Label.AB_DESCRIPCION_IMP_GESTOR)){
					eventosCambioEstado.put(ea.Id,ea.EV_AB_SEL_Estado__c);
					system.debug('>>>>>DentroIfFacEv');
					Id id = null;
					//Util_Facturador.calloutFacturadorEvento(triggerNewMap,'SRV-PSI-097a');
					//for (ServiceResource fieldName : idProfesionalesCuenta){
						//id = fieldName.RSE_LKP_Cuenta__c;
					//	System.debug('idProfesionalesCuenta ' + fieldName);
					//}
					if(idProfesionalesCuenta.get(ea.EV_AB_LKP_Liquidar_a_prof__c) != null && ea.EV_AB_DIV_Importe_a_liquidar_prof__c != null){
						id = idProfesionalesCuenta.get(ea.EV_AB_LKP_Liquidar_a_prof__c).RSE_LKP_Cuenta__c;
					} else if (idProfesionalesCuenta.get(ea.EV_AB_LKP_Imputar_a_profesional__c) != null && ea.EV_AB_DIV_Importe_profesional__c != null){
						id = idProfesionalesCuenta.get(ea.EV_AB_LKP_Imputar_a_profesional__c).RSE_LKP_Cuenta__c;
					}
					//Esta parte de código se prueba con el Trigger de WO
					if(!Test.isRunningTest()){
						system.debug('>>>>>mostrarId: '+id);
					}
					if(id != null){
						//Util_Facturador.facturarProfesional(id,label.FAC_Maestro_Profesionales);
					}
					facturarEventos = true;
					}
				
				if(facturarEventos){
					if((ea.EV_AB_LKP_Imputar_a_profesional__c != null && ea.EV_AB_DIV_Importe_profesional__c != null) || (ea.EV_AB_LKP_Liquidar_a_prof__c != null && ea.EV_AB_DIV_Importe_a_liquidar_prof__c != null)){
						Util_Facturador.calloutFacturadorEvento(triggerNewMap,'SRV-PSI-097a');
					}
					//Util_Facturador.calloutFacturadorEvento(triggerNewMap,'SRV-PSI-097a');
				}
				
				if(ea.EV_AB_SEL_Estado__c == Label.EV_AB_ESTADO_RECHAZADO && (evOld == null || evOld.EV_AB_SEL_Estado__c != Label.EV_AB_ESTADO_RECHAZADO)){
					eventosCambioEstado.put(ea.Id,ea.EV_AB_SEL_Estado__c);
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
	
		if(!woUpdate.isEmpty()){
			update woUpdate.values();
		}
		if(!casoUpdate.isEmpty()){
			update casoUpdate.values();
		}
		if(!tareasInsert.isEmpty()){
			insert tareasInsert;
		}
		
		if(!eventosCambioEstado.isEmpty()){
			
			List<Propuesta_de_Evento__c> eventosAprobar = new List<Propuesta_de_evento__c>();
			List<Propuesta_de_Evento__c> eventosHijo = Util_Propuesta_de_evento.queryPropEvByPropEvEconomico(eventosCambioEstado.keySet()).values();
			//List<Propuesta_de_Evento__c> eventosHijo = [Select id,EV_AB_LKP_Propuesta_de_Evento_Economico__c from Propuesta_de_evento__c where EV_AB_LKP_Propuesta_de_Evento_Economico__c in : eventosCambioEstado.keySet()];
			
			if(!eventosHijo.isEmpty()){
				for(Propuesta_de_evento__c ev: eventosHijo){
					eventosAprobar.add(new Propuesta_de_evento__c(Id=ev.Id,EV_AB_SEL_Estado__c=eventosCambioEstado.get(ev.EV_AB_LKP_Propuesta_de_Evento_Economico__c)));
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
	private static void rellenarWoRelacionadas(List<Propuesta_de_Evento__c> propuestas){
		Set<Id> woIds = new Set<Id>();

		for(Propuesta_de_Evento__c ea: propuestas){
			woIds.add(ea.EV_AB_LKP_Orden_de_Trabajo__c);
		}

		if(abonosRelacionados == null){
			rellenarAbonosRelacionados(propuestas);
		}

		for(Propuesta_de_Abono__c ab: abonosRelacionados.values()){
			woIds.add(ab.AB_LKP_Orden_de_Trabajo__c);
		}
		woRelacionadas = Util_Orden_Trabajo.queryMapOTById(woIds);
		//woRelacionadas = Util_Orden_Trabajo.queryOTBySet(woIds, new Set<Id>(), 'RecordTypeId != \'' + Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION) + '\'');
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param propuestas: [PENDIENTE]
	  * 
	  */
	private static void rellenarCasosRelacionados(List<Propuesta_de_Evento__c> propuestas){
		Set<Id> casoIds = new Set<Id>();

		for(Propuesta_de_Evento__c ea: propuestas){
			casoIds.add(ea.EV_AB_LKP_Caso__c);
		}

		if(abonosRelacionados == null){
			rellenarAbonosRelacionados(propuestas);
		}

		for(Propuesta_de_Abono__c ab: abonosRelacionados.values()){
			casoIds.add(ab.AB_LKP_Caso__c);
		}

		casosRelacionados = Util_Caso.getCaseById(casoIds);
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param propuestas: [PENDIENTE]
	  * 
	  */
	/*private static void rellenarabonoPorIDEvento(List<Propuesta_de_Evento__c> propuestas){
		Set<Id> eventoIds = new Set<Id>();

		for(Propuesta_de_Evento__c ea: propuestas)
			eventoIds.add(ea.Id);

		List<Propuesta_de_Abono__c> abonos = [Select 
		                                      Id, 
		                                      AB_CAS_Abono_Facturado__c,
		                                      AB_LKP_Evento_Relacionado__c,
		                                      AB_LKP_Caso__c,
		                                      AB_LKP_Orden_de_Trabajo__c
		                                      from Propuesta_de_Abono__c where AB_LKP_Evento_Relacionado__c in :eventoIds];

		abonoPorIDEvento = new Map<Id,Propuesta_de_Abono__c>();

		for(Propuesta_de_Abono__c ab: abonos)
			abonoPorIDEvento.put(ab.AB_LKP_Evento_Relacionado__c,ab);
	}*/

	/**
	  * [PENDIENTE]
	  * 
	  * @param eventos: [PENDIENTE]
	  * 
	  */
	private static void rellenarAbonosRelacionados(List<Propuesta_de_Evento__c> eventos){ //Recoge al Abono padre
		Set<Id> abonoIds = new Set<Id>();

		for(Propuesta_de_Evento__c ab: eventos){
			abonoIds.add(ab.EV_AB_LKP_Abono__c);
		}

		abonosRelacionados = Util_Propuesta_de_abono.getPropAbByAbono(abonoIds);
	}
	
	/**
	  * [PENDIENTE]
	  * 
	  * @param eventos: [PENDIENTE]
	  * 
	  */
	private static void rellenarRecursosRelacionados(List<Propuesta_de_Evento__c> eventos){ //Recoge a los recursos relacionados
		Set<Id> resId = new Set<Id>();

		for(Propuesta_de_Evento__c ab: eventos){
			resId.add(ab.EV_AB_LKP_Imputar_a_profesional__c);
			resId.add(ab.EV_AB_LKP_Liquidar_a_prof__c);
		}

		recursosRelacionados = Util_Service_Resource.getServiceResById(resId);
	}


	/**
	  * [PENDIENTE]
	  * 
	  * @param propuestas: [PENDIENTE]
	  * 
	  */
	/*private static void facturaWorkOrder(List<Propuesta_de_Evento__c> propuestas){

		Map<Id,Boolean> woFacturar = new Map<Id,Boolean>();
		for(Propuesta_de_Evento__c ea: propuestas){
			WorkOrder wo = woRelacionadas.get(ea.EV_AB_LKP_Orden_de_Trabajo__c);
			if(wo == null)
				wo = woRelacionadas.get(abonosRelacionados.get(ea.EV_AB_LKP_Abono__c).AB_LKP_Orden_de_Trabajo__c);
			woFacturar.put(wo.Id,true);
		}


		Map<Id,Propuesta_de_Evento__c> todosEventos = new Map<Id,Propuesta_de_Evento__c>([Select id, EV_AB_CAS_Evento_Ab_Facturado__c, EV_AB_LKP_Orden_de_Trabajo__c,EV_AB_LKP_Abono__r.AB_LKP_Orden_de_Trabajo__c from Propuesta_de_Evento__c where EV_AB_LKP_Orden_de_Trabajo__c in: woFacturar.keySet() or EV_AB_LKP_Abono__r.AB_LKP_Orden_de_Trabajo__c in: woFacturar.keySet()]);
		Map<Id,Propuesta_de_Abono__c> todosAbonos = new Map<Id,Propuesta_de_Abono__c>([Select id, AB_CAS_Abono_Facturado__c, AB_LKP_Orden_de_Trabajo__c,AB_LKP_Evento_Relacionado__r.EV_AB_LKP_Orden_de_Trabajo__c from Propuesta_de_Abono__c where AB_LKP_Orden_de_Trabajo__c in: woFacturar.keySet() or AB_LKP_Evento_Relacionado__r.EV_AB_LKP_Orden_de_Trabajo__c in:  woFacturar.keySet()]);

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
	  * @param propuestas: [PENDIENTE]
	  * 
	  */
	/*private static void facturaCaso(List<Propuesta_de_Evento__c> propuestas){

		Map<Id,Boolean> casoFacturar = new Map<Id,Boolean>();
		for(Propuesta_de_Evento__c ea: propuestas){
			Case caso = casosRelacionados.get(ea.EV_AB_LKP_Caso__c);
			if(caso == null)
				caso = casosRelacionados.get(abonosRelacionados.get(ea.EV_AB_LKP_Abono__c).AB_LKP_Caso__c);
			casoFacturar.put(caso.Id,true);
		}

		Map<Id,Propuesta_de_Evento__c> todosEventos = new Map<Id,Propuesta_de_Evento__c>([Select id, EV_AB_CAS_Evento_Ab_Facturado__c, EV_AB_LKP_Caso__c,EV_AB_LKP_Abono__r.AB_LKP_Caso__c from Propuesta_de_Evento__c where EV_AB_LKP_Caso__c in: casoFacturar.keySet() or EV_AB_LKP_Abono__r.AB_LKP_Caso__c in: casoFacturar.keySet()]);
		Map<Id,Propuesta_de_Abono__c> todosAbonos = new Map<Id,Propuesta_de_Abono__c>([Select id, AB_CAS_Abono_Facturado__c, AB_LKP_Caso__c,AB_LKP_Evento_Relacionado__r.EV_AB_LKP_Caso__c from Propuesta_de_Abono__c where AB_LKP_Caso__c in: casoFacturar.keySet() or AB_LKP_Evento_Relacionado__r.EV_AB_LKP_Caso__c in: casoFacturar.keySet()]);
		Map<Id,WorkOrder> todasWO = new Map<Id,WorkOrder>([Select id, OTR_CAS_Orden_Trabajo_Facturada__c, CaseId from WorkOrder where CaseId in: casoFacturar.keySet()]);

		for(Propuesta_de_Evento__c ea: todosEventos.values()){
			if(!ea.EV_AB_CAS_Evento_Ab_Facturado__c){
				system.debug('----------evt no fact: '+ea);
				Id casoId = ea.EV_AB_LKP_Caso__c;
				if(casoId == null)
					casoId = ea.EV_AB_LKP_Abono__r.AB_LKP_Caso__c;  
				casoFacturar.put(casoId,false);
			}
		}

		for(Propuesta_de_Abono__c ab: todosAbonos.values()){
			if(!ab.AB_CAS_Abono_Facturado__c){
				system.debug('----------ab no fact: '+ab);
				Id casoId = ab.AB_LKP_Caso__c;
				if(casoId == null)
					casoId = ab.AB_LKP_Evento_Relacionado__r.EV_AB_LKP_Caso__c;
				casoFacturar.put(ab.AB_LKP_Caso__c,false);
			}
		}

		for(WorkOrder wo: todasWO.values()){
			if(!wo.OTR_CAS_Orden_Trabajo_Facturada__c)
				system.debug('----------wo no fact: '+wo);
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
	
/*	public static void calloutFacturador (List<Propuesta_de_Evento__c> Evento, String service,Map<Id, Propuesta_de_Evento__c> triggerOldMap) {
		List<String> partidasId = new List<String>();
		for(Propuesta_de_Evento__c eventoNew: Evento){
			if(eventoNew.EV_AB_SEL_Estado__c == '02' && triggerOldMap.get(eventoNew.Id).EV_AB_SEL_Estado__c == '02'){
				if(eventoNew.EV_AB_SEL_Estado__c != triggerOldMap.get(eventoNew.Id).EV_AB_SEL_Estado__c ){
					/*List<WorkOrder> woIds = new List<WorkOrder>([SELECT Id, EV_AB_SEL_Estado__c FROM Propuesta_de_Evento__c WHERE Id IN:Evento]);
					for(WorkOrder woId:woIds){
						if(woId.Status == '501' || woId.Status == '997'){
							Map<Id, String> mapaOTR = new Map<Id, String>();
							mapaOTR.put(woId.Id, 'WorkOrder');
							String idBitacora = Util_Llamada_Externa.insertarBitacora('','','03','02',service,'','',
									'','','',woId.Id,'',0,'',0);
							Util_Llamada_Externa n = new Util_Llamada_Externa(mapaOTR,'Facturador',service,idBitacora);
							System.enqueueJob(n);
						}
					}
				}
			}	
		}	
	}*/

	/*public static void cambiarEstado(List<Propuesta_de_Evento__c> Evento){
		Set<String> ids = new Set<String>();
		for(Propuesta_de_Evento__c prop: Evento){
			ids.add(prop.Id);
		}
		List<Propuesta_de_Evento__c> propCambiarEstado = new List<Propuesta_de_Evento__c>([SELECT Id, EV_AB_SEL_Estado__c FROM Propuesta_de_Evento__c
															WHERE EV_AB_LKP_Propuesta_de_Evento_Economico__c IN :ids]);
		for(Propuesta_de_Evento__c cambio: propCambiarEstado){
			cambio.EV_AB_SEL_Estado__c = '02';
		}

		update propCambiarEstado;
	}*/
	
	public static Set<Id> validacionesEventos(List<Propuesta_de_Evento__c> triggerNew, Map<Id,List<Propuesta_de_evento__c>> eventosDeWo, Map<Id,List<Propuesta_de_evento__c>> eventosDeCaso,Map<Id,List<Propuesta_de_evento__c>> eventosDeProfesional){
		
		Set<Id> conError = new Set<Id>();
		Set<Id> errorDup = new Set<Id>();
		
		Map<String,String> eventosPrevio = new Map<String,String>{'E02'=>'E01',
																'E20'=>'E19',
																'E22'=>'E21',
																'E26'=>'E25',
																'E37'=>'E29',
																'E34'=>'E31',
																'E35'=>'E28'};
		Set<String> comprobarPR = new Set<String>{'E20','E22','E26','E37','E34','E35','E39'};
		Set<String> comprobarImporte = new Set<String>{'E22','E26','E37','E34'};
		
		for(Propuesta_de_evento__c ev: triggerNew){
			List<Propuesta_de_evento__c> existentes = new List<Propuesta_de_Evento__c>();
			String msgError = '';
			if(ev.EV_AB_LKP_Cuenta_profesional__c != null){
				if(eventosDeProfesional.get(ev.EV_AB_LKP_Cuenta_profesional__c) != null){
					existentes.addAll(eventosDeProfesional.get(ev.EV_AB_LKP_Cuenta_profesional__c));
				}
				msgError = ' en esta cuenta.';
			}else if(ev.EV_AB_LKP_Orden_de_Trabajo__c != null){
				if(eventosDeWo.get(ev.EV_AB_LKP_Orden_de_Trabajo__c) != null){
					existentes.addAll(eventosDeWo.get(ev.EV_AB_LKP_Orden_de_Trabajo__c));
				}
				msgError = ' en este servicio.';
			} else if(ev.EV_AB_LKP_Caso__c != null){
				if(eventosDeCaso.get(ev.EV_AB_LKP_Caso__c) != null){
					for(Propuesta_De_evento__c evCaso: eventosDeCaso.get(ev.EV_AB_LKP_Caso__c)){
						if(evCaso.EV_AB_LKP_Orden_de_Trabajo__c == null){
							existentes.add(evCaso);
						}
					}
				}
				msgError = ' en esta intervención.';
			}
			
			if(eventosPrevio.keySet().contains(ev.EV_AB_SEL_Descripcion__c)){
				Boolean existe = false;
				Boolean mismoProf = false;
				Boolean mismoImporte = false;
				for(Propuesta_de_evento__c evEx: existentes){
					if(evEx.EV_AB_SEL_Descripcion__c == eventosPrevio.get(ev.EV_AB_SEL_Descripcion__c)){
						existe = true;
						if(comprobarPr.contains(ev.EV_AB_SEL_Descripcion__c) && evEx.EV_AB_LKP_Imputar_a_profesional__c == ev.EV_AB_LKP_Liquidar_a_prof__c){
							mismoProf = true;
						}
						if(comprobarImporte.contains(ev.EV_AB_SEL_Descripcion__c) && evEx.EV_AB_DIV_Importe_profesional__c == ev.EV_AB_DIV_Importe_a_liquidar_prof__c){
							mismoImporte = true;
						}
					}
				}
				
				if(!existe){
					ev.addError('Debe existir un '+eventosPrevio.get(ev.EV_AB_SEL_Descripcion__c)+msgError);
					conError.add(ev.Id);
				} else if(comprobarPr.contains(ev.EV_AB_SEL_Descripcion__c) && comprobarImporte.contains(ev.EV_AB_SEL_Descripcion__c) && !mismoProf && !mismoImporte){
					ev.addError('El PR y el importe introducido no coinciden con el PR y el importe del evento '+eventosPrevio.get(ev.EV_AB_SEL_Descripcion__c)+'.');
					conError.add(ev.Id);
				} else if(comprobarPr.contains(ev.EV_AB_SEL_Descripcion__c) && !mismoProf){
					ev.addError('El PR introducido no coincide con el PR del Evento '+eventosPrevio.get(ev.EV_AB_SEL_Descripcion__c)+'.');
					conError.add(ev.Id);
				} else if(comprobarImporte.contains(ev.EV_AB_SEL_Descripcion__c) && !mismoImporte){
					ev.addError('El importe introducido no coincide con el importe del Evento '+eventosPrevio.get(ev.EV_AB_SEL_Descripcion__c)+'.');
					conError.add(ev.Id);
				}
			}
			
			if(!conError.contains(ev.Id)){
				if(ev.EV_AB_SEL_Descripcion__c == 'E39'){
					if(ev.EV_AB_LKP_Propuesta_de_Evento_Economico__c == null){
						ev.addError('No se ha asociado ningún evento');
						conError.add(ev.Id);
					} else {
						Boolean hayEvento = false;
						Boolean errorImporte = false;
						Boolean errorProfesional = false;
						Boolean errorDuplicado = false;
						Boolean errorNoE23 = false;
						Double importeE23 = 0;
						Double importeE39 = 0;
						for(Propuesta_de_evento__c evEx: existentes){
							if(evEx.Id == ev.EV_AB_LKP_Propuesta_de_Evento_Economico__c){
								hayEvento = true;
								if(evEx.EV_AB_SEL_Descripcion__c == 'E23'){
									if(evEx.EV_AB_LKP_Imputar_a_profesional__c == ev.EV_AB_LKP_Liquidar_a_prof__c){
										importeE23 = evEx.EV_AB_DIV_Importe_profesional__c;
										/*if(evEx.EV_AB_DIV_Importe_profesional__c < ev.EV_AB_DIV_Importe_a_liquidar_prof__c){
											errorImporte = true;
										}*/
									} else {
										errorProfesional = true;
									}
								} else {
									errorNoE23 = true;
								}
							}
							
							if(evEx.EV_AB_SEL_Descripcion__c == 'E39' && evEx.EV_AB_LKP_Propuesta_de_Evento_Economico__c == ev.EV_AB_LKP_Propuesta_de_Evento_Economico__c){
								importeE39 += evEx.EV_AB_DIV_Importe_a_liquidar_prof__c;
								//errorDuplicado = true;
							}
						}
						
						if(!hayEvento){
							ev.addError('El evento asociado no está en la misma cuenta de profesional');
							conError.add(ev.Id);
						} else if(errorNoE23){
							ev.addError('El evento asociado no es un E23');
							conError.add(ev.Id);
						} /*else if(errorDuplicado){
							ev.addError('Ya existe un evento E39 para el evento E23 asociado');
							conError.add(ev.Id);
						}*/ else if(errorProfesional){
							ev.addError('No se ha introducido el mismo PR que en el evento E23 asociado');
							conError.add(ev.Id);
						} else if(importeE39 > importeE23){
							ev.addError('El importe de los E39 es superior al importe del evento E23 asociado');
							conError.add(ev.Id);
						}
					}
				}

				if(ev.EV_AB_SEL_Descripcion__c == 'E35'){
					Double importeE28 = 0;
					Double importeE35 = 0;
					Date fechaInicio = null;
					Date fechaFin = null;
					if(System.today() < Date.newInstance(System.today().year(),6,29)){
						fechaInicio = Date.newInstance(System.today().year()-1,6,30);
						fechaFin = Date.newInstance(System.today().year(),6,29);
					} else if(System.today() >= Date.newInstance(System.today().year(),6,30)){
						fechaInicio = Date.newInstance(System.today().year(),6,30);
						fechaFin = Date.newInstance(System.today().year()+1,6,29);
					}
					
					if(fechaInicio != null && fechaFin != null){
						for(Propuesta_de_evento__c evEx: existentes){
							if(evEx.EV_AB_SEL_Descripcion__c == 'E35' && evEx.Createddate >= fechaInicio && evEx.Createddate < fechaFin && evEx.EV_AB_LKP_Liquidar_a_prof__c == ev.EV_AB_LKP_Liquidar_a_prof__c){
								importeE35 += evEx.EV_AB_DIV_Importe_a_liquidar_prof__c;
							} else if(evEx.EV_AB_SEL_Descripcion__c == 'E28' && evEx.Createddate >= fechaInicio && evEx.Createddate < fechaFin && evEx.EV_AB_LKP_Imputar_a_profesional__c == ev.EV_AB_LKP_Liquidar_a_prof__c){
								importeE28 += evEx.EV_AB_DIV_Importe_profesional__c;
							}
						}
					}
					if(importeE35 > importeE28){
						ev.addError('El importe de los E35 para el PR introducido supera el importe de los E28 para el periodo de tiempo definido');
						conError.add(ev.Id);
					}
				}
			}
		}
			
		for(Propuesta_de_evento__c ev: triggerNew){
			
			List<Propuesta_de_evento__c> existentes = new List<Propuesta_de_Evento__c>();
			if(ev.EV_AB_LKP_Orden_de_Trabajo__c != null){
				if(eventosDeWo.get(ev.EV_AB_LKP_Orden_de_Trabajo__c) != null){
					existentes.addAll(eventosDeWo.get(ev.EV_AB_LKP_Orden_de_Trabajo__c));
				}
			} else if(ev.EV_AB_LKP_Caso__c != null){
				if(eventosDeCaso.get(ev.EV_AB_LKP_Caso__c) != null){
					for(Propuesta_De_evento__c evCaso: eventosDeCaso.get(ev.EV_AB_LKP_Caso__c)){
						if(evCaso.EV_AB_LKP_Orden_de_Trabajo__c == null){
							existentes.add(evCaso);
						}
					}
				}
			}
			
			if(ev.EV_AB_SEL_Descripcion__c == 'E03' 
			|| ev.EV_AB_SEL_Descripcion__c == 'E18' 
			|| ev.EV_AB_SEL_Descripcion__c == 'E19' 
			|| ev.EV_AB_SEL_Descripcion__c == 'E20' 
			|| ev.EV_AB_SEL_Descripcion__c == 'E37'
			|| ev.EV_AB_SEL_Descripcion__c == 'E02'
			|| ev.EV_AB_SEL_Descripcion__c == 'E22'
			|| ev.EV_AB_SEL_Descripcion__c == 'E34'
			|| ev.EV_AB_SEL_Descripcion__c == 'E26'){
				for(Propuesta_de_evento__c evEx: existentes){
					if(ev.Id != evEx.Id && evEx.EV_AB_SEL_Descripcion__c == ev.EV_AB_SEL_Descripcion__c  && !conError.contains(evEx.Id)){
						ev.addError('Ya existe un '+ev.EV_AB_SEL_Descripcion__c+' en este servicio/intervención.');
						errorDup.add(ev.Id);
						break;
					}
				}
			}
			
		}
		conError.addAll(errorDup);
		return conError;
	}
	
	
}