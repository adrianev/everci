//TO-DO ELIMINAR LINEAS COMENTADAS QUE NO APLICAN
/**
 * Handler del Trigger TRG_Partidas_OT.
 * 
 * @author EVERIS
 * 
 */
public without sharing class TRG_Handler_Partidas_OT {
	private static final Id recordTypeIdRevision = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION);

	private static Map<Id, WorkOrder> mapaOrdenesTrabajo;
	private static Map<Id, Case> mapaCasos;
	private static Map<String, Baremo__c> mapaBaremosPorClave;
	private static Map<Id,List<WorkOrderLineItem>> mapaPartidasWO;

	public static void tratamientoBefore(Map<Id, WorkOrderLineItem> triggerNewMap, List<WorkOrderLineItem> triggerNew, 
			Map<Id, WorkOrderLineItem> triggerOldMap, List<WorkOrderLineItem> triggerOld){
		
		// ************* Eliminar cuando lo controle CPQ *************
		//convertirEstadoPartida(triggerNew);
		// ************* Eliminar cuando lo controle CID *************
		Map<Id,WorkOrderLineItem> ordenesId = new Map<Id, WorkOrderLineItem>();
		Map<Id,Id> idRecursos = new Map<Id,Id>();
		if(Trigger.isInsert){
			for(WorkOrderLineItem woli : triggerNew){
				ordenesId.put(woli.WorkOrderId,woli);
				if(woli.Status == Label.PAR_ESTADO_EN_CURSO_PROF){
					woli.Status = Label.PAR_ESTADO_ACEPTADA;
				}
			}
			
			/*Map<Id,WorkOrder> ordenes = new Map<Id,WorkOrder>([SELECT Id, 
			                                                   CaseId, 
			                                                   OTR_LKP_Recurso_Servicio__c 
			                                                   FROM WorkOrder 
			                                                   WHERE Id IN :ordenesId.keyset()]);*/
			Map<Id,WorkOrder> ordenes = Util_Orden_Trabajo.queryMapOTById(ordenesId.KeySet());
			
			/*List<ResourcePreference> prefRecurso = Util_Service_Resource.getRPByRelatedRecordAndPreferenceType(ordenesId.keySet(),new Set<String>{'Excluded'}).values();
			//List<ResourcePreference> prefRecurso = [Select id,ServiceResourceId,RelatedRecordId,ServiceResource.RelatedRecordId from ResourcePreference where RelatedRecordId in :ordenesId.keySet() and PreferenceType = 'Excluded'];
			Map<Id,Set<Id>> prefUserbyWo = new Map<Id,Set<Id>>();
			for(ResourcePreference rPref: prefRecurso){
				Set<Id> temp = prefUserbyWo.get(rPref.RelatedRecordId);
				if(temp == null)
					temp = new Set<Id>();
				temp.add(rPref.ServiceResource.RelatedRecordId);
				prefUserbyWo.put(rPref.RelatedRecordId,temp);
			}*/
			
			for(WorkOrderLineItem woli : triggerNew){
				Workorder wo = ordenes.get(woli.WorkorderId);
				if(wo != null && wo.Case.RecordtypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION)){
					if(wo.Case.ParentId != null){
						woli.Status = Label.PAR_ESTADO_PDTE_GESTOR;
					} else {
						if(wo.Case.CAS_LKP_Recl_Orden_Trabajo__r.OTR_LKP_Recurso_Servicio__r.Relatedrecordid != UserInfo.getUserId())
							woli.Status = Label.PAR_ESTADO_PDTE_GESTOR;
					}
				}
			}
			
			
			/*Map<Id,Id>otsDeCasos = new Map<Id,Id>();
			if(!ordenes.isEmpty()) {
				for (WorkOrder ot :ordenes.values()) {
					idRecursos.put(ot.Id, ot.OTR_LKP_Recurso_Servicio__c);
					otsDeCasos.put(ot.CaseId,ot.Id);
				}
				Map<Id,ServiceResource> mapaRecursos = new Map<Id, ServiceResource>([SELECT Id, Name FROM ServiceResource WHERE Id IN :idRecursos.values()]);
				List<ResourcePreference> listaPreference = new List<ResourcePreference>([SELECT Id, RelatedRecordId, ServiceResourceId FROM ResourcePreference WHERE RelatedRecordId IN :ordenes.keySet()]);
				//List<Case> listCasos = new List<Case>([SELECT Id, CAS_FOR_Profesional_responsable__c FROM Case WHERE Id IN :otsDeCasos.keySet() AND RecordType.Name = 'Reclamacion']);
				List<Case> listCasos = Util_caso.getCaseById(otsDeCasos.keySet());
				if(!listCasos.isEmpty()) {
					
					for(Case caso :listCasos) {
						Id idOt = otsDeCasos.get(caso.Id);
						ServiceResource prof = mapaRecursos.get(idRecursos.get(idOt));
						if(caso.CAS_LKP_Recl_Orden_Trabajo__c != null) {
							if(caso.CAS_FOR_Profesional_responsable__c != prof.Name) {
								ordenesId.get(idOt).Status = Label.PAR_ESTADO_PDTE_GESTOR;
							}
						}else if(caso.ParentId != null) {
						 	if(!listaPreference.isEmpty()) {
						 		for(ResourcePreference rp :listaPreference) {
						 			if(rp.ServiceResourceId != prof.Id && rp.RelatedRecordId == idOt) {
						 				ordenesId.get(idOt).Status = Label.PAR_ESTADO_PDTE_GESTOR;
						 			}
						 		}
						 	}
						}
					}
				}
			}*/
		}
	}
		
	/*public static void calloutFacturador (List<WorkOrderLineItem> woPartida, String service) {
		List<String> partidasId = new List<String>();
		List<WorkOrderLineItem> partidasIds = new List<WorkOrderLineItem>([SELECT WorkOrder.Id, WorkOrder.Status FROM WorkOrderLineItem WHERE Id IN:woPartida]);
		system.debug('partidasIds'+partidasIds);
		for(WorkOrderLineItem woId:partidasIds){
			if(woId.WorkOrder.Status == Label.OTR_ESTADO_REVISADO || woId.WorkOrder.Status == Label.OTR_ESTADO_CERRADO){
				Map<Id, String> mapaOTR = new Map<Id, String>();
				mapaOTR.put(woId.WorkOrder.Id, 'WorkOrder');
				String idBitacora = Util_Llamada_Externa.insertarBitacora('','','03','02',service,'','',
						'','','','',woId.WorkOrder.Id,'',0,'',0,Label.Callout_PUT);
				Util_Llamada_Externa n = new Util_Llamada_Externa(mapaOTR,'Facturador',service,idBitacora);
				System.enqueueJob(n);
			}
		}
	}*/
	/**
	  * Tratamiento para el caso after del trigger.
	  * 
	  * @param triggerNewMap: mapa de registros nuevos del objeto WorkOrderLineItem a partir del Id
	  * @param triggerNew: lista de registros nuevos del objeto WorkOrderLineItem
	  * @param triggerOldMap: mapa de registros antiguos del objeto WorkOrderLineItem a partir del Id
	  * @param triggerOld: lista de registros antiguos del objeto WorkOrderLineItem
	  */
	public static void tratamientoAfter(Map<Id, WorkOrderLineItem> triggerNewMap, List<WorkOrderLineItem> triggerNew, 
			Map<Id, WorkOrderLineItem> triggerOldMap, List<WorkOrderLineItem> triggerOld){

		Map<Id,Case> casosUpdate = new Map<Id,Case>();
		
		inicializarMapas(triggerNew, triggerOld);
		Set<WorkOrderLineItem> partidas = new Set<WorkOrderLineItem>();
		if(Trigger.isInsert || Trigger.isUpdate){
			
			Set<Id> woBorrarEventos = new Set<Id>();			
			Map<Id,List<WorkOrderLineItem>> mapaPartidasWOAfter = Util_Orden_Trabajo.getMapaPartidasOTs(mapaOrdenesTrabajo.keySet());
			system.debug('---------mapaPartidasWOAfter: '+mapaPartidasWOAfter);
			for(Id woId: mapaPartidasWOAfter.keySet()){
				Workorder wo = mapaOrdenesTrabajo.get(woId);
				if(wo.Case.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION) && wo.OTR_LKP_Recurso_Servicio__c != null){
					woBorrarEventos.add(woId);
				}
			}
			
			
			if(Trigger.isUpdate){
				for(Id woId: mapaPartidasWOAfter.keySet()){
					Workorder wo = mapaOrdenesTrabajo.get(woId);
					system.debug('<<<<<<<<<<<sera wo.Case.RecordTypeId>>>>>>>>>>>' + wo.Case.RecordTypeId + ' ;' + wo.OTR_LKP_Recurso_Servicio__c );
					if(wo.Case.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION) && wo.OTR_LKP_Recurso_Servicio__c != null){
						system.debug('<<<<<<<<<<<sera entra if>>>>>>>>>>>>');
						if(!woBorrarEventos.isEmpty()){
							List<Propuesta_de_Evento__c> evntToDeleteList = Util_Abonos_Y_Eventos.getPropuestaEventoByWorkOrder(woBorrarEventos).values();
							/*List<Propuesta_de_Evento__c> evntToDeleteList = new List<Propuesta_de_Evento__c>([SELECT Id FROM Propuesta_de_Evento__c
								WHERE EV_AB_LKP_Orden_de_Trabajo__c in :woBorrarEventos]);*/
				
							delete evntToDeleteList;
						}
						crearPropuestaEvento(mapaPartidasWOAfter.get(woId), wo.CaseId, wo.OTR_LKP_Recurso_Servicio__c);
					}
				}
			}
			
			
			// Establecer en el Caso el primer Baremo insertado en las partidas
			if(Trigger.isInsert){
				for(WorkorderLineItem woli: triggerNew){
					Workorder wo = mapaOrdenesTrabajo.get(woli.WorkorderId);
					
					if(wo != null && wo.RecordtypeId != recordTypeIdRevision && wo.CaseId != null){
						Case casoUpdate = casosUpdate.get(wo.CaseId);
						if(casoUpdate == null){
							casoUpdate = new Case(Id=wo.CaseId, CAS_LKP_Baremo__c=null);
						}
						Case caso = mapaCasos.get(wo.CaseId);
						
						if(Trigger.isInsert && caso != null && caso.CAS_LKP_Baremo__c == null && casoUpdate.CAS_LKP_Baremo__c == null){
							Baremo__c baremo = mapaBaremosPorClave.get(wo.OTR_SEL_Gremio__c + '_' + woli.PAR_TXT_Baremo_Codigo__c + '_' + wo.Case.CAS_LKP_Compania__c);
							if(baremo != null){
								casoUpdate.CAS_LKP_Baremo__c = baremo.Id;
								casosUpdate.put(casoUpdate.Id,casoUpdate);
							}
						}
					}	
				}
			}
			
			if(!casosUpdate.isEmpty()){
				Baipas.establecerVariableControl();
				update casosUpdate.values();
				Baipas.deshabilitarVariableControl();
			}
			
			/*for(WorkOrderLineItem wOl: triggerNew){
				Id work = wOl.WorkOrderId;
				Workorder works = [SELECT Case.RecordTypeId, OTR_LKP_Recurso_Servicio__c, OTR_FOR_Codigo_Profesional__c FROM Workorder WHERE Id =  :work];
				if(works.Case.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_RECLAMACION) && works.OTR_LKP_Recurso_Servicio__c != null){
					crearPropuestaEvento(triggerNew, works.CaseId, works.OTR_LKP_Recurso_Servicio__c);
				}
			}*/
			
		}
		if(Trigger.isUpdate){
			//calloutFacturador(Trigger.New, label.FAC_PreFactura);
			
			for(WorkOrderLineItem woli : triggerNew){
				Workorder wo = mapaOrdenesTrabajo.get(woli.WorkorderId);
				//Se genera el movimiento 44 para el envío a CIAs				
				if(woli.Status==label.PAR_ESTADO_ACEPTADA_POR_PERITO_CIA 
						&& triggerOldMap.get(woli.Id).Status != label.PAR_ESTADO_ACEPTADA_POR_PERITO_CIA && wo.RecordtypeId != recordTypeIdRevision){
					partidas.add(woli);
				}
				
			}

			if(!partidas.isEmpty()){
				guardaMovimientosOnInsert();
			}
			
		}

		if(Trigger.isDelete){
			//actualizarBusquedaBaremo(triggerOldMap, true);
			system.debug('<<<<<<<<<<<sera entra por isdelete>>>>>>>');
			List<WorkOrderLineItem> partidasGenerarAbono = new List<WorkOrderLineItem>();
			List<Workorder> woCambioIva = new List<WorkOrder>();
			Workorder wor = new WorkOrder();
			for(WorkOrderLineItem woli : triggerOld){
				wor = mapaOrdenesTrabajo.get(woli.WorkorderId);
				system.debug('-----------------here');
				system.debug('-----------------WorkOrderId: '+woli.WorkOrderId);
				system.debug('-----------------mapaOrdenesTrabajo.get(woli.Id): '+mapaOrdenesTrabajo.get(woli.WorkOrderId));
				//Si se ha modificado la woli y el estado de la wo es cerrado, se genera linea de abono
				//con los datos de la woli antigua
				if(mapaOrdenesTrabajo.get(woli.WorkOrderId) != null 
						&& (mapaOrdenesTrabajo.get(woli.WorkOrderId).Status == Label.OTR_ESTADO_CERRADO 
						|| mapaOrdenesTrabajo.get(woli.WorkOrderId).Status == Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO
						|| mapaOrdenesTrabajo.get(woli.WorkOrderId).Status == Label.OTR_ESTADO_REVISADO)){
					partidasGenerarAbono.add(woli);
				}

				//si la workorder esta en estado revisado o cerrado y se modifican sus partidas se crean dos abonos
				if(wor != null &&
				 (wor.Status == Label.OTR_ESTADO_REVISADO 
				 || wor.Status == Label.OTR_ESTADO_CERRADO 
				 || wor.Status == Label.OTR_ESTADO_CERRADO_ALBARAN_RECIBIDO)
				 && wor.RecordtypeId != recordTypeIdRevision
				 && wor.OTR_CAS_Orden_Trabajo_Facturada__c){
					woCambioIva.add(wor);
				}

			}

			//Crea una propuesta de abono
			//con una línea por partida antigua.
			/*if(!partidasGenerarAbono.isEmpty())
				generarAbonos(partidasGenerarAbono,'Pago',Label.PAB_DEPT_FINANCIERO);*/

			if(!woCambioIva.isEmpty()){
				system.debug('<<<<<<<<<<entra a crearPartidaCambioIva>>>>>>');
				crearPartidaCambioIva(woCambioIva);
			}


		}
		// ************* Eliminar cuando lo controle CPQ *************
		//else{
		// ************* Eliminar cuando lo controle CPQ *************
		//actualizarPartidas(triggerNewMap,triggerOldMap);
		// ************* Eliminar cuando lo controle CPQ *************
		//actualizarOrdenesTrabajo(triggerNewMap, triggerOldMap);
		//}

		
		//Facturaremos cuando cambien los importes de las partidas de OT;
		if(Trigger.isUpdate){
			List<Id> listaId = new List<Id>();
			for(WorkOrderLineItem par : TriggerNew){
				listaId.add(par.WorkOrderId);
			}
			List<WorkOrder> listaWO = new List<WorkOrder>();
			Map<Id, WorkOrder> mapaWO = new Map<Id, WorkOrder>();
			if(!listaId.isEmpty()){
				listaWO = Util_Orden_Trabajo.queryMapOTById(new Set<Id>(listaId)).values();
				//listaWO = ([SELECT Id, Status, OTR_CAS_Orden_Trabajo_Facturada__c, CaseId, Case.RecordTypeId FROM WorkOrder WHERE Id IN :listaId]);
				if(!listaWO.isEmpty()){
					for(WorkOrder wo : listaWO){
						mapaWO.put(wo.Id,wo);
					}
				}
			}
			for(WorkOrderLineItem par : TriggerNew){
				WorkOrderLineItem parOld = triggerOldMap.get(par.Id);
				WorkOrder wo = mapaWO.get(par.WorkOrderId);
				if((par.PAR_DIV_Cargar_Cliente_AI__c != parOld.PAR_DIV_Cargar_Cliente_AI__c || par.PAR_DIV_Cargar_Comp_AI__c != parOld.PAR_DIV_Cargar_Comp_AI__c || 
				par.PAR_DIV_Facturacion_Total_AI__c != parOld.PAR_DIV_Facturacion_Total_AI__c || par.PAR_DIV_Facturacion_Total_DI__c != parOld.PAR_DIV_Facturacion_Total_DI__c || 
				par.PAR_FOR_Cargar_Cliente_DI__c != parOld.PAR_FOR_Cargar_Cliente_DI__c || par.PAR_FOR_Cargar_Comp_DI__c != parOld.PAR_FOR_Cargar_Comp_DI__c) 
				&& (wo!=null && wo.Status == Label.OTR_ESTADO_REVISADO && wo.OTR_CAS_Orden_Trabajo_Facturada__c == false)){
					String idCaso = wo.CaseId;
					List<Case> ListaCasos = Util_Caso.getCaseById(new Set<Id>{idCaso}).values();
					//List<Case> ListaCasos = new List<Case>([SELECT Id, RecordTypeId FROM case WHERE id= :idCaso]);
					if(listaCasos!= null &&  !listaCasos.isEmpty()){
						Case caso = new Case();
						caso = listaCasos.get(0);
						if(caso.RecordTypeId  == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_SINIESTRO) || caso.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2B_B2B2C) || caso.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_CAS_B2C)){
							Map<Id, String> mapaOTR = new Map<Id, String>();
							mapaOTR.put(wo.Id, 'WorkOrder');
							
							Util_Llamada_Externa client = new Util_Llamada_Externa(mapaOTR,'Facturador',label.FAC_Maestro_Clientes,'');
							Util_Llamada_Externa prefac = new Util_Llamada_Externa(mapaOTR,'Facturador',label.FAC_PreFactura,'');
							Util_Llamada_Externa prof = new Util_Llamada_Externa(mapaOTR,'Facturador',label.FAC_Maestro_Profesionales,'');
							System.enqueueJob(client);
							System.enqueueJob(prefac);
							System.enqueueJob(prof);
						}
					}
				}
			}
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
	private static void crearPropuestaEvento(List<WorkOrderLineItem> triggerNew, Id casoId, Id profesional){
		
		system.debug('----------------listawos: '+triggerNew);
		
		List<Propuesta_de_Evento__c> evntList = new List<Propuesta_de_Evento__c>();
		
		Map<Id,Double> profesionalesImporte = new Map<Id,Double>();
		Map<Id,Double> gestoresImporte = new Map<Id,Double>();
		Map<String,Double> departamentos = new Map<String,Double>();
		Double totalImporte = 0;
		
		for(WorkorderLineItem woli: triggerNew){
			if(woli.PAR_SEL_Departamento_Imputacion__c != null) {
				Double importeTemp = departamentos.get(woli.PAR_SEL_Departamento_Imputacion__c);
				if(importeTemp == null)
					importeTemp = 0;
				importeTemp += woli.PAR_DIV_Importe_a_imputar_Departamento__c;
				departamentos.put(woli.PAR_SEL_Departamento_Imputacion__c,importeTemp);
			}
			if(woli.PAR_LKP_Imputar_a_prof1__c != null){
				Double importeTemp = profesionalesImporte.get(woli.PAR_LKP_Imputar_a_prof1__c);
				if(importeTemp == null)
					importeTemp = 0;
				importeTemp += woli.PAR_DIV_Importe_a_Imputar_prof1__c;
				profesionalesImporte.put(woli.PAR_LKP_Imputar_a_prof1__c,importeTemp);
			}
			if(woli.PAR_LKP_Imputar_a_prof2__c != null){
				Double importeTemp = profesionalesImporte.get(woli.PAR_LKP_Imputar_a_prof2__c);
				if(importeTemp == null)
					importeTemp = 0;
				importeTemp += woli.PAR_DIV_Importe_a_Imputar_prof2__c;
				profesionalesImporte.put(woli.PAR_LKP_Imputar_a_prof2__c,importeTemp);
			}
			if(woli.PAR_LKP_Imputar_a_prof3__c != null){
				Double importeTemp = profesionalesImporte.get(woli.PAR_LKP_Imputar_a_prof3__c);
				if(importeTemp == null)
					importeTemp = 0;
				importeTemp += woli.PAR_DIV_Importe_a_Imputar_prof3__c;
				profesionalesImporte.put(woli.PAR_LKP_Imputar_a_prof3__c,importeTemp);
			}
			if(woli.PAR_LKP_Imputar_a_gestor1__c != null){
				Double importeTemp = gestoresImporte.get(woli.PAR_LKP_Imputar_a_gestor1__c);
				if(importeTemp == null)
					importeTemp = 0;
				importeTemp += woli.PAR_DIV_Importe_a_Imputar_gestor1__c;
				gestoresImporte.put(woli.PAR_LKP_Imputar_a_gestor1__c,importeTemp);
			}
			if(woli.PAR_LKP_Imputar_a_gestor2__c != null){
				Double importeTemp = gestoresImporte.get(woli.PAR_LKP_Imputar_a_gestor2__c);
				if(importeTemp == null)
					importeTemp = 0;
				importeTemp += woli.PAR_DIV_Importe_a_Imputar_gestor2__c;
				gestoresImporte.put(woli.PAR_LKP_Imputar_a_gestor2__c,importeTemp);
			}
			if(woli.PAR_LKP_Imputar_a_gestor3__c != null){
				Double importeTemp = gestoresImporte.get(woli.PAR_LKP_Imputar_a_gestor3__c);
				if(importeTemp == null)
					importeTemp = 0;
				importeTemp += woli.PAR_DIV_Importe_a_Imputar_gestor3__c;
				gestoresImporte.put(woli.PAR_LKP_Imputar_a_gestor3__c,importeTemp);
			}
			
			if(woli.PAR_DIV_Liquidar_Prof_DI__c != null){
				totalImporte += woli.PAR_DIV_Liquidar_Prof_DI__c;
			}
			
		}
		
		
		if(!profesionalesImporte.isEmpty() || !gestoresImporte.isEmpty() || !departamentos.isEmpty()){
			
			/*Double totalImporte = 0;
			
			for(Double importe :profesionalesImporte.values())
				totalImporte += importe;
			
			for(Double importe :gestoresImporte.values())
				totalImporte += importe;*/
			
			//Double totalImporte = importeEventoProf1 + importeEventoProf2 + importeEventoProf3 + importeEventoGest3
			//							+ importeEventoGest2 + importeEventoGest1;
			Propuesta_de_Evento__c propEvnt12 = new Propuesta_de_Evento__c();
			propEvnt12.EV_AB_SEL_Descripcion__c = 'E12';
			propEvnt12.EV_AB_CAS_Evento_Automatico__c = true;
			propEvnt12.EV_AB_LKP_Caso__c = casoId;
			propEvnt12.EV_AB_SEL_Tipo_de_Evento__c = 'Pago';
			propEvnt12.EV_AB_LKP_Orden_de_Trabajo__c = triggerNew.get(0).WorkorderId;
			propEvnt12.EV_AB_DIV_Importe_a_liquidar_prof__c  = totalImporte;
			propEvnt12.EV_AB_LKP_Liquidar_a_prof__c = profesional;
			propEvnt12.EV_AB_SEL_Departamento_Solicitante__c = Label.PAB_DEPT_RECLAMACIONES;
			//propEvnt12.EV_AB_LKP_Imputar_a_profesional__c = profesional;
			system.debug('<<<<<<<<<<<<<<sera profesionalesImporte.size()>>>>>>>' + profesionalesImporte.size());
			system.debug('<<<<<<<<<<<<<<sera profesionalesImporte>>>>>>>' + profesionalesImporte);
			system.debug('<<<<<<<<<<<<<<sera profesional>>>>>>>' + profesional);
			if(profesionalesImporte.size() == 1 && profesionalesImporte.containsKey(profesional)){
				propEvnt12.EV_AB_SEL_Estado__c = '02';
			} else {
				propEvnt12.EV_AB_SEL_Estado__c = '04';
			}
			system.debug('<<<<<<<<<<<sera e12 antes insert>>>>>>>>>>>' + propEvnt12.EV_AB_SEL_Estado__c);
			insert propEvnt12;
			
			system.debug('<<<<<<<<<<<sera e12>>>>>>>>>>>' + propEvnt12.EV_AB_SEL_Estado__c);
			
			for(Id prof: profesionalesImporte.keySet()){
				Propuesta_de_Evento__c propEvntProf1 = new Propuesta_de_Evento__c();
				propEvntProf1.EV_AB_SEL_Descripcion__c = Label.AB_DESCRIPCION_COBRO_RECLAM;
				propEvntProf1.EV_AB_LKP_Caso__c = casoId;
				propEvntProf1.EV_AB_CAS_Evento_Automatico__c = true;
				propEvntProf1.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
				propEvntProf1.EV_AB_LKP_Orden_de_Trabajo__c = triggerNew.get(0).WorkorderId;
				propEvntProf1.EV_AB_DIV_Importe_profesional__c  = profesionalesImporte.get(prof);
				propEvntProf1.EV_AB_LKP_Imputar_a_profesional__c = prof;
				propEvntProf1.EV_AB_LKP_Propuesta_de_Evento_Economico__c = propEvnt12.Id;
				propEvntProf1.EV_AB_SEL_Estado__c = propEvnt12.EV_AB_SEL_Estado__c;
				propEvntProf1.EV_AB_SEL_Departamento_Solicitante__c = Label.PAB_DEPT_RECLAMACIONES;
				evntList.add(propEvntProf1);
			}
			
			for(Id gest: gestoresImporte.keySet()){
				Propuesta_de_Evento__c propEvntGes1 = new Propuesta_de_Evento__c();
				propEvntGes1.EV_AB_SEL_Descripcion__c = Label.AB_DESCRIPCION_IMP_GESTOR;
				propEvntGes1.EV_AB_LKP_Caso__c = casoId;
				propEvntGes1.EV_AB_CAS_Evento_Automatico__c = true;
				propEvntGes1.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
				propEvntGes1.EV_AB_LKP_Orden_de_Trabajo__c = triggerNew.get(0).WorkorderId;
				propEvntGes1.EV_AB_DIV_Importe_gestor__c  = gestoresImporte.get(gest);
				propEvntGes1.EV_AB_LKP_Imputar_a_gestor__c = gest;
				propEvntGes1.EV_AB_LKP_Propuesta_de_Evento_Economico__c = propEvnt12.Id;
				propEvntGes1.EV_AB_SEL_Estado__c = propEvnt12.EV_AB_SEL_Estado__c;
				propEvntGes1.EV_AB_SEL_Departamento_Solicitante__c = Label.PAB_DEPT_RECLAMACIONES;
				evntList.add(propEvntGes1);
			}
			
			for(String dep :departamentos.keySet()) {
				Propuesta_de_Evento__c propEvnt = new Propuesta_de_Evento__c();
				propEvnt.EV_AB_SEL_Descripcion__c = Label.AB_DESCRIPCION_IMP_GESTOR;
				propEvnt.EV_AB_CAS_Evento_Automatico__c = true;
				propEvnt.EV_AB_LKP_Caso__c = casoId;
				propEvnt.EV_AB_LKP_Orden_de_Trabajo__c = triggerNew.get(0).WorkorderId;
				propEvnt.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
				propEvnt.EV_DIV_Importe_a_imputar_Departamento__c  = departamentos.get(dep);
				propEvnt.EV_AB_LKP_Propuesta_de_Evento_Economico__c = propEvnt12.Id;
				propEvnt.EV_AB_SEL_Departamento_Imputacion__c = dep;
				propEvnt.EV_AB_SEL_Estado__c = propEvnt12.EV_AB_SEL_Estado__c;
				propEvnt.EV_AB_SEL_Departamento_Solicitante__c = Label.PAB_DEPT_RECLAMACIONES;
				evntList.add(propEvnt);
			}
			system.debug('----------evntList: '+evntList);
			
			if(!evntList.isEmpty()){
				insert evntList;
				for(Propuesta_de_Evento__c prop: evntList){
					prop.EV_AB_TXT_Identificador__c = prop.Name;
				}
				update evntList;
			}
		}
	}

	/**
	  * [PENDIENTE]
	  * 
	  * @param triggerNew: [PENDIENTE]
	  * @param triggerOld: [PENDIENTE]
	  * 
	  */
	private static void inicializarMapas(List<WorkOrderLineItem> triggerNew, List<WorkOrderLineItem> triggerOld){
		if(trigger.isDelete){
			mapaOrdenesTrabajo = Util_Orden_Trabajo.ordenesTrabajoDePartidas(triggerOld);
			mapaCasos = Util_Caso.casosDeOT(mapaOrdenesTrabajo.values());
			mapaPartidasWO = Util_Orden_Trabajo.getMapaPartidasOTs(mapaOrdenesTrabajo.keySet());
		}
		else {
			mapaOrdenesTrabajo = Util_Orden_Trabajo.ordenesTrabajoDePartidas(triggerNew);
			mapaCasos = Util_Caso.casosDeOT(mapaOrdenesTrabajo.values());
			mapaPartidasWO = Util_Orden_Trabajo.getMapaPartidasOTs(mapaOrdenesTrabajo.keySet());

			if(trigger.isInsert){
				Set<String> codBaremos = new Set<String>();
				Set<String> codCompania = new Set<String>();
				for(WorkorderLineitem woli:triggerNew){
					Workorder wo = mapaOrdenesTrabajo.get(woli.WorkorderId);
					if(wo != null){
						codBaremos.add(wo.OTR_SEL_Gremio__c + '_' + woli.PAR_TXT_Baremo_Codigo__c);
						codCompania.add(wo.Case.CAS_LKP_Compania__c);
					}
				}
				Set<Id> setCompaniaId = new Set<Id>();
				for(String strId:new List<String>(codCompania)){
					setCompaniaId.add(Id.valueOf(strId));
				}
				List<Baremo__c> baremosTemp = Util_Baremos.getBaremoByCompaniaAndCodigoBaremo(setCompaniaId,codBaremos).values();
				/*List<Baremo__c> baremosTemp = [SELECT Id,
													  BAR_TXT_Identificador_Unico__c,
													  BAR_LKP_Compania__c
											   FROM Baremo__c
											   WHERE BAR_TXT_Identificador_Unico__c IN :codBaremos
											   AND BAR_LKP_Compania__c IN: codCompania];*/
				
				mapaBaremosPorClave = new Map<String,Baremo__c>();
				for(Baremo__c bar: baremosTemp){
					 mapaBaremosPorClave.put(bar.BAR_TXT_Identificador_Unico__c + '_' + String.valueOf(bar.BAR_LKP_Compania__c), bar);
				}
			}
		}
	}

	/**
	  * [PENDIENTE]
	  * 
	  */
	private static void guardaMovimientosOnInsert(){
		for (Case caso : mapaCasos.values()){
			if(Util_Siniestro.esSiniestro(caso)){
				//Registro movimiento para acción 44
				Util_Movimientos.compruebaEnviable(caso.Id, caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c, '44');
			}
		}
	}

		
	private static void actualizarBusquedaBaremo(Map<Id,WorkOrderLineItem> partidas, Boolean borrado){
		Map<Id,WorkOrder> actualizar = new Map<Id,WorkOrder>();
	 	for(WorkOrderLineItem woli: partidas.values()){
	 		WorkOrder wo = mapaOrdenesTrabajo.get(woli.WorkorderId);
	 		WorkOrder woUpdate = actualizar.get(wo.Id);
	 		system.debug('--wo.OTR_TXT_Codigo_de_baremo__c: '+wo.OTR_TXT_Codigo_de_baremo__c);
	 		if(woUpdate == null){
	 			woUpdate = new WorkOrder(Id=wo.Id);
	 			woUpdate.OTR_TXT_Codigo_de_baremo__c = wo.OTR_TXT_Codigo_de_baremo__c;
	 		}
	 		if(woUpdate.OTR_TXT_Codigo_de_baremo__c == null){
	 			woUpdate.OTR_TXT_Codigo_de_baremo__c = '';
	 		}
	 		if(borrado){
	 			system.debug('--borrado');
	 			if(woUpdate.OTR_TXT_Codigo_de_baremo__c.contains(','+woli.PAR_TXT_Baremo_Codigo__c+',')){
		 			woUpdate.OTR_TXT_Codigo_de_baremo__c = woUpdate.OTR_TXT_Codigo_de_baremo__c.replace(','+woli.PAR_TXT_Baremo_Codigo__c+',','').replace(',,',',');
		 			actualizar.put(woUpdate.Id,woUpdate);
	 			}
	 		}else{
	 			system.debug('--no borrado');
	 			if(!woUpdate.OTR_TXT_Codigo_de_baremo__c.contains(','+woli.PAR_TXT_Baremo_Codigo__c+',')){
	 				woUpdate.OTR_TXT_Codigo_de_baremo__c = (woUpdate.OTR_TXT_Codigo_de_baremo__c +','+woli.PAR_TXT_Baremo_Codigo__c+',').replace(',,',',');
	 				actualizar.put(woUpdate.Id,woUpdate);
	 			}
	 		}
		}
		system.debug('--updates baremo: '+actualizar);
		update(actualizar.values());
	}
		
	// ************* Eliminar cuando lo controle CPQ *************
	/*private static void convertirEstadoPartida(List<WorkOrderLineItem> triggerNew){
 		if (Trigger.isInsert
	 	 || Trigger.isUpdate){
	 		system.debug('<<<<dentroConvertirEstado');
	 		// Se recoge el gremio del profesional asociado al usuario (si tuviera)
	 		ServiceResource profAsociado;
	 		List<ServiceResource> listaProfAsociados = new List<ServiceResource>([
	 			SELECT 	RSE_SEL_Gremio__c 
 				FROM 	ServiceResource 
 				WHERE 	RelatedRecordId = :UserInfo.getUserId()]);
 			if(!listaProfAsociados.isEmpty()){
 				profAsociado = listaProfAsociados.get(0);
 			}
		 	for (WorkOrderLineItem partida : triggerNew){
		 		if (partida.PAR_DIV_Cargar_Comp_AI__c != null 
		 		 && partida.Status != Label.PAR_ESTADO_RECHAZADA){
		 		 	WorkOrder wo = mapaOrdenesTrabajo.get(partida.WorkOrderId);
		 		 	Case caso = mapaCasos.get(wo.CaseId);
		 		 	// Solo si el caso asociado a la partida es un siniestro
		 		 	if(Util_Siniestro.esSiniestro(caso)){
			 			Double limite = wo.OTR_RES_Subtotal_Partidas__c + partida.PAR_DIV_Cargar_Comp_AI__c;
			 			system.debug('<<<<limite' + limite);
			 			system.debug('<<<<limiteActuacion' + wo.OTR_FOR_Limite_Actuacion_CIA__c);
			 			if(wo.OTR_FOR_Limite_Actuacion_CIA__c < limite 
			 			 || wo.OTR_FOR_Limite_Graves_CIA__c < limite){
			 				partida.Status = Label.PAR_ESTADO_PENDIENTE;
			 			}else{
			 				// Si es una partida del gremio del profesional
			 				if(profAsociado != null
			 				 && wo.OTR_SEL_Gremio__c == profAsociado.RSE_SEL_Gremio__c){
			 					partida.Status = Label.PAR_ESTADO_ACEPTADA;
			 				}else{
			 					partida.Status = Label.PAR_ESTADO_ESTIMADA;
			 				}
			 			}
		 		 	}
		 		}
		 	}
	 	}
	}*/

	// ************* Eliminar cuando lo controle CPQ *************
	/*private static void actualizarPartidas(Map<Id, WorkOrderLineItem> triggerNewMap, Map<Id, WorkOrderLineItem> triggerOldMap){
	 	// Si la partida se ha insertado como PENDIENTE, el resto de partidas asociadas a todas las órdenes de trabajo del caso
	 	// también se tienen que actualizar a PENDIENTES
	 	List<WorkOrder> listaOTPartidas = new List<WorkOrder>();
	 	List<WorkOrderLineItem> partidasParaActualizar = new List<WorkOrderLineItem>();
	 	// Se recorren las partidas buscando las que se han insertado como PENDIENTES
	 	for(WorkOrderLineItem partida :triggerNewMap.values()){
	 		if(partida.Status == Label.PAR_ESTADO_PENDIENTE
	 		 && (triggerOldMap == null 
	 		  || triggerOldMap.get(partida.Id).Status != Label.PAR_ESTADO_PENDIENTE)){
	 			listaOTPartidas.add(mapaOrdenesTrabajo.get(partida.WorkOrderId));
	 		}
	 	}

	 	// Se recogen todas las ordenes de trabajo asociadas a los casos de las partidas de OT que han llegado al trigger
	 	// Y que se han insertado como PENDIENTES
	 	Map<Id, WorkOrder> mapaOtsCaso = Util_Orden_Trabajo.ordenesTrabajoDeCaso(listaOTPartidas);

 		// Se recogen todas las partidas de OT de todas las ordenes de trabajo obtenidas
	 	List<WorkOrderLineItem> partidasAct = new List<WorkOrderLineItem>([
	 		SELECT 	Status
 			FROM 	WorkOrderLineItem
 			WHERE 	WorkOrderId IN :mapaOtsCaso.keySet()
 					AND Status != :Label.PAR_ESTADO_PENDIENTE 
 					AND Status != :Label.PAR_ESTADO_RECHAZADA]);

 		// Para cada una de estas partidas se actualiza su estado a PENDIENTE	
	 	for(WorkOrderLineItem partida :partidasAct){
	 		partida.Status = Label.PAR_ESTADO_PENDIENTE;
	 		partidasParaActualizar.add(partida);
	 	}

	 	// Se actualizan las partidas de la orden de trabajo
		try{
			update partidasParaActualizar;
		}catch(Exception e){
			system.debug('***** EXCEPTION : '+ e);
		}
	}*/

	// ************* Eliminar cuando lo controle CPQ *************
	/*private static void actualizarOrdenesTrabajo(Map<Id, WorkOrderLineItem> triggerNewMap, Map<Id, WorkOrderLineItem> triggerOldMap){
	 	// En el caso de que se supere el límite de actuación (Estado = PENDIENTE), el estado de las órdenes de trabajo 
	 	// pasa a "En Espera de confirmación por el Gestor".
	 	Map<Id, Case> mapaCasosQueAplican = new Map<Id, Case>();
	 	// Se recorren las partidas buscando las que se han insertado como PENDIENTES
	 	for(WorkOrderLineItem partida :triggerNewMap.values()){
	 		if(partida.Status == Label.PAR_ESTADO_PENDIENTE
	 		 && (triggerOldMap == null 
	 		  || triggerOldMap.get(partida.Id).Status != Label.PAR_ESTADO_PENDIENTE)){
	 			WorkOrder ot = mapaOrdenesTrabajo.get(partida.WorkOrderId);
	 			Case caso = mapaCasos.get(ot.CaseId);
	 			if(caso != null
	 			 && !mapaCasosQueAplican.containsKey(caso.Id)){
	 			 	// Se recogen los casos de las partidas que aplican
	 				mapaCasosQueAplican.put(caso.Id, caso);
	 			}
	 		}
	 	}
	 	// Se actualiza el estado de las ordenes de trabajo de los casos que aplican
	 	Util_Orden_Trabajo.cambiarEstadoOTsCaso(mapaCasosQueAplican.values(), Label.OTR_ESTADO_EN_ESPERA_CONF_GEST);
	}*/

	/**
	  * [PENDIENTE]
	  * 
	  * @param partidas: [PENDIENTE]
	  * @param tipo: [PENDIENTE]
	  * @param departamento: [PENDIENTE]
	  * 
	  */
	/*private static void generarAbonos(List<WorkOrderLineItem> partidas, String tipo, String departamento){

		system.debug('---------------------partidas: '+partidas);

		Set<Id> woIds = new Set<Id>();
		for(WorkOrderLineItem woli: partidas){
			woIds.add(woli.WorkOrderId);
		}

		//Se crea una nueva propuesta de abono por cada wo
		Map<Id,Propuesta_de_abono__c> abonoPorWOID = new Map<Id,Propuesta_de_abono__c>();

		List<Propuesta_de_abono__c> nuevosAbonos = new List<Propuesta_de_abono__c>();

		List<WorkOrderLineItem> todasWolis = new List<WorkOrderLineItem>();

		for(Id woId: woIds){
			todasWolis.addAll(mapaPartidasWO.get(woId));

			Propuesta_de_abono__c ab = abonoPorWOID.get(woId);
			if(ab == null){

				//TODO: Aclarar campos
				ab = new Propuesta_de_abono__c();

				ab.AB_LKP_Orden_de_Trabajo__c = woId;
				ab.AB_SEL_Departamento_Solicitante__c = departamento;


				nuevosAbonos.add(ab);

				abonoPorWOID.put(ab.AB_LKP_Orden_de_Trabajo__c,ab);
			}

		}
		if(!nuevosAbonos.isEmpty()){
			insert(nuevosAbonos);
		}

		//List<Linea_de_abono__c> nuevasLineas = new List<Linea_de_abono__c>();

		//Una nueva línea de abono por cada partida
		//for(WorkOrderLineItem woli: partidas){
		/*for(WorkOrderLineItem woli: todasWolis){

			Propuesta_de_abono__c ab = abonoPorWOID.get(woli.WorkOrderId);
			if(ab != null && ab.Id != null){

				Linea_de_abono__c lab = new Linea_de_abono__c();
				//TODO: Aclarar campos
				lab.LAB_DIV_Importe_a_ingresar__c = woli.PAR_DIV_Liquidar_Prof_DI__c;
				lab.LAB_LKP_Cuenta_Cl__c = mapaCasos.get(mapaOrdenesTrabajo.get(woli.WorkOrderId).CaseId).AccountId;
				lab.LAB_DIV_Importe_Total__c = woli.PAR_DIV_Liquidar_Prof_DI__c;
				lab.LAB_LKP_Abono__c = ab.Id; 
				lab.LAB_SEL_Tipo_de_Abono__c = tipo;

				nuevasLineas.add(lab);
			}
		}

		insert(nuevasLineas);
	} */

	// NO SE UTILIZA
	/*public static void avisoModificacionPartidas(List<WorkOrderLineItem> partidasNew, Map<Id,WorkOrderLineitem> partidasOld){

	 	Set<Id> profesionalRecurso = new Set<Id>();
	 	Set<Id> woSinProfesional = new Set<Id>();
	 	Map<Id,Id> profesionalPorWo = new Map<Id,Id>();
	 	for(WorkOrderLineItem partida: partidasNew){
	 		Workorder wo = mapaOrdenesTrabajo.get(partida.WorkOrderId);
	 		if(wo != null){
	 			if(wo.OTR_LKP_Recurso_Servicio__c != null){
	 				profesionalRecurso.add(wo.OTR_LKP_Recurso_Servicio__c);
	 				profesionalPorWo.put(wo.Id,wo.OTR_LKP_Recurso_Servicio__c);
	 			}else
	 				woSinProfesional.add(wo.Id);
	 		}
	 	}

	 	if(!woSinProfesional.isEmpty()){
	 		List<AssignedResource> recursos = [Select ServiceResourceId, ServiceAppointment.ParentRecordId from AssignedResource where ServiceAppointment.ParentRecordId in :woSinProfesional];
	 		for(AssignedResource res: recursos){
	 			profesionalRecurso.add(res.ServiceResourceId);
	 			profesionalPorWo.put(res.ServiceAppointment.ParentRecordId,res.ServiceResourceId);
	 		}
	 	}


	 	List<ServiceResource> recList = [Select id, RelatedRecordId from ServiceResource where id in :profesionalRecurso];
	 	Map<Id,Id> profPorRecurso = new Map<Id,Id>();
	 	for(ServiceResource rec: recList){
	 		profPorRecurso.put(rec.Id,rec.RelatedRecordId);	
	 	}


	 	Map<Id,String> cuerpoCorreoPorProfesional = new Map<Id,String>();
	 	for(WorkOrderLineItem woli: partidasNew){
	 		Id profesional = profPorRecurso.get(profesionalPorWo.get(woli.WorkOrderId));
	 		String cuerpoCorreo = cuerpoCorreoPorProfesional.get(profesional);

	 		if(cuerpoCorreo == null)
	 			cuerpoCorreo = '<p>Su albarán ha sido modificado, consulte en su aplicativo.</p><p>Ordenes de trabajo modificadas:</p><ul>';

	 		cuerpoCorreo += '<li>'+mapaOrdenesTrabajo.get(woli.Id).WorkOrderNumber+'</li>';
	 	}

	 	for(String cuerpo: cuerpoCorreoPorProfesional.values())
	 		cuerpo += '</ul>';

	 	for(Id prof: cuerpoCorreoPorProfesional.keySet()){
	 		Util_Correo_Electronico.enviarMail(prof,'Aviso modificación albarán',cuerpoCorreoPorProfesional.get(prof));
	 	}

	}*/

	private static void crearPartidaCambioIva(List<WorkOrder> woList){
		system.debug('<<<<<<<<<<<sera crearPartidaCambioIva woList>>>>>>>>' +woList);
		
		List<Propuesta_de_Abono__c> abonoList = new List<Propuesta_de_Abono__c>();
		List<Id> idList = new List<Id>();

		for(WorkOrder work: woList){
			idList.add(work.CaseId);
		}

		Map<ID, Case> mapaCasos = Util_Caso.getCaseById(new Set<Id>(idList));
		//Map<ID, Case> mapaCasos = new Map<ID, Case>([SELECT Id, CAS_LKP_Cliente_contable_cliente__c, CAS_LKP_Cliente_contable__c, AccountId FROM Case WHERE Id IN :idList]);
		
		for(WorkOrder wo: woList){
			Propuesta_de_Abono__c abonoCom = new Propuesta_de_Abono__c();
			Propuesta_de_Abono__c abonoCli = new Propuesta_de_Abono__c();
			abonoCom.AB_LKP_Ingresar_a__c = mapaCasos.get(wo.CaseId).CAS_LKP_Cliente_contable_cliente__c;
			abonoCom.AB_SEL_Departamento_Solicitante__c = '4';
			abonoCom.AB_LKP_Caso__c = wo.CaseId;
			abonoCom.AB_SEL_Estado__c = '02';
			abonoCom.AB_CAS_Abono_Automatico__c = true;
			abonoCom.AB_LKP_Cuenta__c = mapaCasos.get(wo.CaseId).AccountId;
			abonoCom.AB_DIV_Importe_a_ingresar__c = wo.OTR_RES_Facturar_Cliente_DI__c;
			abonoCom.AB_LKP_Orden_de_Trabajo__c = wo.Id;
			abonoList.add(abonoCom);

			abonoCli.AB_LKP_Ingresar_a__c = mapaCasos.get(wo.CaseId).CAS_LKP_Cliente_contable__c;
			abonoCli.AB_SEL_Departamento_Solicitante__c = '4';
			abonoCli.AB_LKP_Caso__c = wo.CaseId;
			abonoCli.AB_SEL_Estado__c = '02';
			abonoCli.AB_CAS_Abono_Automatico__c = true;
			abonoCli.AB_LKP_Cuenta__c = mapaCasos.get(wo.CaseId).AccountId;
			abonoCli.AB_LKP_Orden_de_Trabajo__c = wo.Id;
			abonoCli.AB_DIV_Importe_a_ingresar__c =wo.OTR_RES_Facturar_Compania_DI__c;
			abonoList.add(abonoCli);

		}

		if(!abonoList.isEmpty()){
			system.debug('<<<<<<<<<<sera abonoList>>>>>>>>>>>>>');
			insert abonoList;
		}
		

	}
	
}