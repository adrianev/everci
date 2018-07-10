global without sharing class Util_Botones_Personalizados {
	webservice static String actSiniestroVestaBoton(Integer actuacion, Integer casoActualizacion, String fechaCambio, String descripcionNoAbierto,
			String tipoSiniestro, String gremio, String numeroSiniestroHS, String numeroSiniestroCia, String tipoSituacion, String tipoSituacionReparacion){
		Callout_ActualizaSiniestroVesta_RQ datos = new Callout_ActualizaSiniestroVesta_RQ(actuacion, casoActualizacion, fechaCambio, descripcionNoAbierto,
				tipoSiniestro, gremio, numeroSiniestroHS, numeroSiniestroCia, tipoSituacion, tipoSituacionReparacion);
		return Callout_ActualizaSiniestroVesta.updateDatos(datos).mensaje_error;
	}

	webservice static String asignacionPeritoBoton(Id propietario){
		String result = '';
		system.Savepoint puntoGuardado = Database.setSavepoint();
		try {
			List<Case> listaCasos = Util_Caso.getCaseById(new Set<Id>{propietario}).values();
			if(!listaCasos.isEmpty()){
				Case caso = listaCasos.get(0);
				if(caso.CAS_CAS_Presolicitud_Perito__c){
					caso.CAS_CAS_Requiere_Perito__c = true;
					caso = Util_Perito.procesoAsignacion(caso);
					if(caso.CAS_LKP_Perito__c != null){
						update caso;
					}
				}	
				else {
					result = 'El siniestro no requiere perito';
				}
			}
		}
		catch(Exception e){
			Database.rollback(puntoGuardado);
			system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
			result = Label.ERROR_GUARDAR + e.getMessage();
		}
		return result;
	}

	webservice static Id cogerRevision(Workorder wo){

		Id revisionRTID = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION);

		List<Workorder> enRevision = Util_Orden_Trabajo.getWorkOrderByParentWorkorderAndRT(new Set<Id>{wo.Id},new Set<Id>{revisionRTID}).values();
		//List<Workorder> enRevision = [Select id from Workorder where ParentWorkOrderId = :wo.Id and RecordTypeId = :revisionRTID order by createddate desc];
		if(!enRevision.isEmpty()){
			return enRevision.get(0).Id;
		} else {
			return clonarOT(wo);
		}

	}

	webservice static String clonarCita(Id woId){//Botón Nueva_Cita (WorkOrder)
		String result = '';
		List<ServiceAppointment> listaCita = Util_Cita_Servicio.getMapCitasByOTs(new Set<Id>{woId}).values();
		if(!listaCita.isEmpty()){
			system.Savepoint puntoGuardado = Database.setSavepoint();
			try {
				insert Util_Cita_Servicio.nuevaCita(listaCita.get(0));
			}
			catch(Exception e){
				Database.rollback(puntoGuardado);
				system.debug('>>>>>>>>>>>>>EXCEPTION:' + e.getStackTraceString());
				result = e.getMessage();
			}
		}
		return result;
	}

	webservice static Id clonarOT(WorkOrder wo){//Botón Revisar (WorkOrder 'En Revisión')
		Util_variablesGlobales.noCrearClonOT = true;
		WorkOrder woClon = new WorkOrder();
		WorkOrder woBackup = new WorkOrder();
		wo.OTR_SEL_Subestado__c = LABEL.OTR_SUBESTADO_EN_REVISION;

		List<WorkOrder> listaClonarOT = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{wo.Id}).values();
		/*List<WorkOrder> listaClonarOT = new List<WorkOrder>([SELECT Id, 
		                                                     AccountId,
		                                                     
		                                                     CaseId,
		                                                     City,
		                                                     Country,
		                                                     Account.CUE_DIV_Limite_Actuacion__c,            
		                                                     CreatedDate,
		                                                     Description,
		                                                     OTR_RES_Importe_partidas__c,
		                                                     OTR_CAS_Asignar_Mizad__c,
		                                                     OTR_CAS_Urgente__c,
		                                                     OTR_DAT_Fecha_Primera_Cita__c,
		                                                     OTR_DAT_Fecha_Recepcion_Albaran__c,
		                                                     OTR_DAT_Fecha_Cierre_servicio__c,
		                                                     OTR_LKP_Linea_Contrato__c,
		                                                     OTR_LKP_Recurso_Servicio__c,
		                                                     OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,
		                                                     OTR_SEL_Gremio__c,
		                                                     OTR_SEL_Rango_Primera_Cita__c,
		                                                     OTR_SEL_Tipo_Red__c,
		                                                     OTR_SEL_Tipologia_de_Servicio__c,
		                                                     OTR_SEL_Categoria_del_profesional__c,
		                                                     OwnerId,
		                                                     PostalCode,
		                                                     RecordType.Name,
		                                                     RecordTypeId,
		                                                     ServiceTerritory.Name,
		                                                     ServiceTerritoryId,
		                                                     ServiceTerritory.PostalCode,
		                                                     State,
		                                                     Status,
		                                                     OTR_SEL_Subestado__c,
		                                                     Street,														            
		                                                     WorkOrderNumber,
		                                                     WorkType.Name,
		                                                     WorkTypeId
		                                                     FROM WorkOrder
		                                                     WHERE Id = :wo.Id]);*/
		Baipas.establecerVariableControl();
		update wo;
		Baipas.deshabilitarVariableControl();
		
		system.debug('*********CLON WO BOTON LISTA: '+listaClonarOT);
		if(!listaClonarOT.isEmpty()){

			wo = listaClonarOT.get(0);
			List<WorkOrderLineItem> listaWoliClon = new List<WorkOrderLineItem>();
			List <WorkOrderLineItem> listaItems = Util_Partida.queryMapPartidasOTByWorkOrder(new Set<Id>{wo.Id}).values();
			/*List <WorkOrderLineItem> listaItems = new List<WorkOrderLineItem>([SELECT
			                                                                   Description,
			                                                                   PAR_NUM_Altura__c,
			                                                                   PAR_NUM_Ancho__c,
			                                                                   PAR_TXT_Ceco__c,
			                                                                   PAR_TXT_Baremo_Codigo__c,
			                                                                   PAR_TXT_Baremo_Desc__c,
			                                                                   PAR_CAS_Orden_Trabajo_Anulada__c,
			                                                                   PAR_TXT_Detalle_Venta__c,
			                                                                   PAR_POR_Materiales__c,
			                                                                   PAR_DIV_Precio_Unitario_Venta__c,
			                                                                   PAR_FOR_Precio_Unitario_Venta_Cli__c,
			                                                                   PAR_DIV_Cantidad_Venta__c,
			                                                                   PAR_TXT_Unidades_Medida_Gastos__c,
			                                                                   PAR_SEL_Unidades_Medida__c,
			                                                                   PAR_POR_Descuento__c,
			                                                                   Discount,
			                                                                   PAR_SEL_Codigo_Impuesto_Venta__c,
			                                                                   PAR_CAS_Danos_Esteticos__c,
			                                                                   PAR_DIV_Liquidar_Prof_AI__c,
			                                                                   PAR_DIV_Liquidar_Prof_DI__c,
			                                                                   PAR_POR_Impuesto_Prof__c,
			                                                                   PAR_DIV_Cargar_Cliente_AI__c,
			                                                                   PAR_DIV_Cargar_Comp_AI__c,
			                                                                   PAR_POR_Porcentaje_Imp_Cia_Cliente__c,
			                                                                   PAR_DIV_ListPrice__c,
			                                                                   PAR_DIV_UnitPrice__c,
			                                                                   PAR_DIV_Facturacion_Total_AI__c,
			                                                                   PAR_DIV_Facturacion_Total_DI__c,
																			   PAR_TXT_Detalle_WOLI__c,
																			   PAR_NUM_Unidades__c,
																			   PAR_TXT_Identificador__c,
			                                                                   Status,
			                                                                   PAR_SEL_Danios_Del__c,
			                                                                   WorkOrderId 
			                                                                   FROM WorkOrderLineItem 
			                                                                   WHERE WorkOrderId = :wo.Id]);*/
			system.debug('*********CLON WOLI LISTA ORIGINAL: '+listaItems);                		
			woClon = wo.clone(false, true);
			woBackup = wo.clone(false, true);
			woBackup.caseId = null;
			woBackup.OTR_CAS_Copia_de_Seguridad__c = true;
			
			system.debug('*********CLON WO ANTES UPSERT: '+woClon); 
			woClon.RecordTypeId = Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OTR_EN_REVISION);
			woClon.ParentWorkOrderId = wo.Id; 
			try{
				Baipas.establecerVariableControl();
				upsert woClon;
				woBackup.ParentWorkorderId = woClon.Id;
				//insert woBackup;
				Baipas.deshabilitarVariableControl();
			}catch(Exception e){
				system.debug('Excepción al insertar el clon de la WO: ' + e.getMessage());
			} 

			if(!listaItems.isEmpty()){
				for(WorkOrderLineItem it:listaItems){
					WorkOrderLineItem woliClon = it.clone(false,true);
					WorkOrderLineItem woliBackup = it.clone(false,true);
					woliClon.WorkOrderId = woClon.Id;
					woliBackup.WorkOrderId = woBackup.Id;
					if(woliClon.PAR_TXT_Identificador__c == null)
						woliClon.PAR_TXT_Identificador__c = '';
					woliClon.PAR_TXT_Identificador__c += '_c';
					woliClon.WOLI_Ultima_modificacion__c = it.CreatedBy.Name;
					listaWoliClon.add(woliClon); 
					listaWoliClon.add(woliBackup); 
				} 
				system.debug('*********CLON WOLI : '+woClon);                  
				try{
					Baipas.establecerVariableControl();
					upsert listaWoliClon;  
					Baipas.deshabilitarVariableControl();	                					
				}catch(Exception e){
					system.debug('Excepción al insertar las líneas del clon de la WO: ' + e.getMessage());
				}
				system.debug('*********CLON WO DESPUES UPSERT: '+woClon);                			
			}

			if(woClon.id != null){
				Baipas.establecerVariableControl();
				cloneAttachments(woClon);
				if(!Test.isRunningTest()){
					cloneContentVersion(woClon);
				}
				cloneComentarios(woClon);
				cloneActivityHistory(wo,woClon);
				
				//Hay que borrar la cita de servicio que se crea automáticamente al crear la wo, porque no sirve para nada
				List<ServiceAppointment> sas = Util_Cita_Servicio.getMapCitasByOTs(new Set<Id>{woClon.Id,woBackup.Id}).values();
				//List<ServiceAppointment> sas = [Select id from serviceappointment where ParentRecordId = :woClon.Id or ParentRecordId = :woBackup.Id];
				if(!sas.isEmpty())
					delete(sas);
				Baipas.deshabilitarVariableControl();
				
			}
			
			if(!String.isBlank(wo.OTR_TXT_IdQuote__c)){
				List<BigMachines__Quote__c> qList = [Select id,External_id__c,OQU_LKP_Work_Order__c from BigMachines__Quote__c where id = :wo.OTR_TXT_IdQuote__c];
				if(!qList.isEmpty()){
					qList[0].External_id__c = woClon.Id;
					qList[0].OQU_LKP_Work_Order__c = woClon.Id;
					
					update qList;
				}
			}
			
			
		}
		system.debug('*********CLON RETURN: '+woClon.Id); 
		return woClon.Id;               		
	}//FIN botón revisar

	webservice static Id eliminarOT(WorkOrder wo){//Botón eliminar (WorkOrder 'En Revisión')
		Id idPadre = wo.ParentWorkOrderId;
		List<WorkOrder> listaActualizarOT = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{idPadre}).values();
		/*List<WorkOrder> listaActualizarOT = new List<WorkOrder>([SELECT Id,
		                                                         Status,
		                                                         OTR_SEL_Subestado__c,
		                                                         WorkType.Name,
		                                                         WorkTypeId
		                                                         FROM WorkOrder
		                                                         WHERE Id = :idPadre]);*/
		if(!listaActualizarOT.isEmpty()){
			WorkOrder woAct = listaActualizarOT.get(0);
			woAct.OTR_SEL_Subestado__c = null;
			update woAct;
		}
		delete wo;
		system.debug('*********CLON ID PADRE: '+idPadre);
		system.debug('*********CLON WO Eliminar: '+wo);
		return idPadre; 
	} //FIN botón eliminar

	webservice static Id aceptarOT(WorkOrder wo){		//Botón Aceptar (WorkOrder 'En Revisión')
		Id idPadre = wo.ParentWorkOrderId;


		WorkOrder woHija = new WorkOrder();
		WorkOrder woPadre = new WorkOrder();
		WorkOrder woPadreOrig = new WorkOrder();
		/* PREGUNTAR COMO ACTUALIZAR TODOS LOS CAMPOS DE LA HIJA A LA PADRE. ¿DELET E INSERT? */ 
		List<WorkOrder> listaWOHija = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{wo.Id}).values();
		/*List<WorkOrder> listaWOHija = new List<WorkOrder>([SELECT Id, 
		                                                   AccountId,
		                                                  
		                                                   City,
		                                                   Country,
		                                                   Account.CUE_DIV_Limite_Actuacion__c,            
		                                                   CreatedDate,
		                                                   Description,
		                                                   OTR_RES_Importe_partidas__c,
		                                                   OTR_CAS_Asignar_Mizad__c,
		                                                   OTR_CAS_Urgente__c,
		                                                   OTR_DAT_Fecha_Primera_Cita__c,
		                                                   OTR_LKP_Linea_Contrato__c,
		                                                   OTR_LKP_Recurso_Servicio__c,
		                                                   OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,
		                                                   OTR_SEL_Gremio__c,
		                                                   OTR_SEL_Rango_Primera_Cita__c,
		                                                   OTR_SEL_Subestado__c,
		                                                   OTR_SEL_Tipo_Red__c,
		                                                   OTR_SEL_Motivo_de_rectificacion__c,
		                                                   OTR_SEL_Penalizacion__c,
		                                                   OTR_TXT_rectificacion__c,
		                                                   OTR_CAS_AplicaRevision__c,
		                                                   OTR_SEL_Categoria_del_profesional__c,
		                                                   OTR_DIV_Importe_original__c,
		                                                   OTR_DIV_Importe_nuevo__c,
		                                                   OTR_DIV_Importe_diferencia__c,
		                                                   OwnerId,
		                                                   PostalCode,
		                                                   ParentWorkOrderId,
		                                                   ServiceTerritory.Name,
		                                                   ServiceTerritoryId,
		                                                   ServiceTerritory.PostalCode,
		                                                   State,
		                                                   Status,
		                                                   Street,
		                                                   WorkType.Name,
		                                                   WorkTypeId
		                                                   FROM WorkOrder
		                                                   WHERE Id = :wo.Id]);*/
		List<WorkOrder> listaWOPadre = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{idPadre}).values();
		/*List<WorkOrder> listaWOPadre = new List<WorkOrder>([SELECT Id,
															OTR_LKP_Recurso_Servicio__c,
		                                                    OTR_RES_Facturar_Cliente_AI__c,
		                                                    OTR_RES_Subtotal_Partidas__c,
		                                                    OTR_RES_Liquidar_prof_AI__c,
		                                                    ParentWorkOrderId,
		                                                    RecordTypeId,
		                                                    OTR_TXT_Num_OrdenTrabajo_HS__c,
		                                                    OTR_CAS_Partidas_Modificadas_Revision__c,
		                                                    CaseId
		                                                    FROM WorkOrder
		                                                    WHERE Id = :idPadre]);*/



		if(!listaWOHija.isEmpty()){
			woHija = listaWOHija.get(0);
		}

		woPadre = woHija.clone(false,true);
		woPadre.id = idPadre;
		if(!listaWOPadre.isEmpty()){
			woPadre.ParentWorkOrderId = listaWOPadre.get(0).ParentWorkOrderId;
			woPadre.RecordTypeId = listaWOPadre.get(0).RecordtypeId;
			//woPadre.OTR_TXT_Num_OrdenTrabajo_HS__c = listaWOPadre.get(0).OTR_TXT_Num_OrdenTrabajo_HS__c;
			woPadreOrig = listaWOPadre.get(0);
		}

		woPadre.OTR_TXT_Estado_Anterior__c = woPadre.Status;
		woHija.OTR_TXT_Estado_Anterior__c = woHija.Status;
		woPadre.Status = LABEL.OTR_ESTADO_REVISADO;
		woHija.Status = LABEL.OTR_ESTADO_REVISADO;
		woPadre.OTR_SEL_Subestado__c = Label.OTR_SUBESTADO_REVISADO_CON_ALBARAN;
		woHija.OTR_SEL_Subestado__c = Label.OTR_SUBESTADO_REVISADO_CON_ALBARAN;
		woPadre.OTR_LKP_Gestor_revision__c = UserInfo.getUserId();
		woHija.OTR_LKP_Gestor_revision__c = UserInfo.getUserId();

		system.debug('---------------------woPadre.OTR_TXT_Num_OrdenTrabajo_HS__c: '+woPadre.OTR_TXT_Num_OrdenTrabajo_HS__c);
		system.debug('---------------------woHija.OTR_TXT_Num_OrdenTrabajo_HS__c: '+woHija.OTR_TXT_Num_OrdenTrabajo_HS__c);
		system.debug('---------------------woHija.OTR_SEL_Categoria_del_profesional__c: '+woHija.OTR_SEL_Categoria_del_profesional__c);
		system.debug('---------------------woHija.OTR_CAS_AplicaRevision__c: '+woHija.OTR_CAS_AplicaRevision__c);
		system.debug('---------------------woHija.OTR_SEL_Categoria_del_profesional__c != Franquiciado || woHija.OTR_CAS_AplicaRevision__c: '+woHija.OTR_SEL_Categoria_del_profesional__c != 'Franquiciado' || woHija.OTR_CAS_AplicaRevision__c);
		
		//if(woHija.OTR_SEL_Categoria_del_profesional__c != 'Franquiciado' || woHija.OTR_CAS_AplicaRevision__c){
		if(!woHija.OTR_CAS_Confianza_en_la_red__c || woHija.OTR_CAS_AplicaRevision__c){
			clonePartidas(woHija, woPadreOrig, false);
		} else {
			woPadre.OTR_SEL_Motivo_de_rectificacion__c = '';
			woPadre.OTR_SEL_Penalizacion__c = '';
			woPadre.OTR_TXT_rectificacion__c = '';
			woPadre.OTR_TXT_Comentario_Auditoria__c = '';
			woPadre.OTR_DIV_Importe_original__c = null;
			woPadre.OTR_DIV_Importe_nuevo__c = null;
			woPadre.OTR_DIV_Importe_diferencia__c = null;
		}
		//copiarUltimoAlbaran(woHija,woPadreOrig);
		system.debug('---------------------woPadre.OTR_CAS_Partidas_Modificadas_Revision__c: '+woPadre.OTR_CAS_Partidas_Modificadas_Revision__c);
		system.debug('---------------------woPadreOrig.OTR_CAS_Partidas_Modificadas_Revision__c: '+woPadreOrig.OTR_CAS_Partidas_Modificadas_Revision__c);


		woPadre.OTR_CAS_Partidas_Modificadas_Revision__c = woPadreOrig.OTR_CAS_Partidas_Modificadas_Revision__c;
		woPadre.OTR_CAS_Servicio_Revisado__c = true;
		woPadre.OTR_DAT_Fecha_revision__c = Datetime.Now().date();
		woPadre.OTR_HOR_Hora_de_revision__c = Datetime.Now().time();
		woHija.OTR_CAS_Servicio_Revisado__c = true;
		woHija.OTR_DAT_Fecha_revision__c = Datetime.Now().date();
		woHija.OTR_HOR_Hora_de_revision__c = Datetime.Now().time();
		
		List<BigMachines__Quote__c> qList = [Select id,External_id__c,OQU_LKP_Work_Order__c from BigMachines__Quote__c where External_id__c = :woHija.Id or OQU_LKP_Work_Order__c = :woHija.Id];
		if(!qList.isEmpty()){
			woPadre.OTR_TXT_IdQuote__c = qList[0].Id;
		}
		
		
		Baipas.establecerVariableControl();
		
		update(new List<WorkOrder>{woHija,woPadre});
		
		if(!woHija.OTR_CAS_Confianza_en_la_red__c || woHija.OTR_CAS_AplicaRevision__c)
			delete woHija;

		Baipas.deshabilitarVariableControl();

		//update woHija;
		//update woPadre;
		
		/*if(woPadre.OTR_CAS_Partidas_Modificadas_Revision__c){
			generarAlbaran(woPadre);
			Util_Orden_Trabajo.avisoModificacionPartidas(new Set<Id>{woPadre.Id});//TODO: Descapar cuando los emails esten definidos
		}*/
		

		system.debug('*********CLON ID REDIRECCION: '+idPadre);
		return idPadre; 
	} // FIN botón aceptar

	webservice static Id eliminarRevision(Workorder wo){
		List<Workorder> listaWO = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{wo.Id}).values();
		//List<Workorder> listaWO = Util_Orden_Trabajo.queryOT(wo.Id,null,null);
		List<Workorder> listaWORevision = Util_Orden_Trabajo.getWorkOrderByParentWorkorder(new Set<Id>{wo.Id}).values();
		//List<Workorder> listaWORevision = [Select Id, Status,OTR_TXT_Estado_Anterior__c from Workorder where ParentWorkorderId = :wo.Id];
		if(!listaWO.isEmpty()){
			Workorder woAct = listaWO[0];
			woAct.Status = woAct.OTR_TXT_Estado_Anterior__c;
			woAct.OTR_SEL_Subestado__c = null;
			
			List<Workorder> actualizar = new List<Workorder>{woAct};
			
			if(!listaWORevision.isEmpty()){
				Workorder woRev = listaWORevision[0];
				woRev.Status = woRev.OTR_TXT_Estado_Anterior__c;
				actualizar.add(woRev);
			}
			
			update actualizar;
			
			return wo.Id;
		} else {
			return null;
		} 
		
	}


	webservice static Id restaurarCopiaOT(Workorder wo){
		List<WorkOrder> listaClonarOT = Util_Orden_Trabajo.getWorkOrderByParentWOOrParentParentWO(new Set<Id>{wo.Id},new Set<Id>{wo.Id}).values(); 
		/*List<WorkOrder> listaClonarOT = new List<WorkOrder>([SELECT Id, 
		                                                     AccountId,
		                                                    
		                                                     City,
		                                                     Country,
		                                                     Account.CUE_DIV_Limite_Actuacion__c,            
		                                                     CreatedDate,
		                                                     Description,
		                                                     OTR_RES_Importe_partidas__c,
		                                                     OTR_CAS_AplicaRevision__c,
		                                                     OTR_CAS_Asignar_Mizad__c,
		                                                     OTR_CAS_Servicio_Revisado__c,
		                                                     OTR_CAS_Urgente__c,
		                                                     OTR_CAS_Partidas_Modificadas_Revision__c,
		                                                     OTR_DAT_Fecha_Primera_Cita__c,
		                                                     OTR_DAT_Fecha_Recepcion_Albaran__c,
		                                                     OTR_DAT_Fecha_Cierre_servicio__c,
		                                                     OTR_DAT_Fecha_revision__c,
		                                                     OTR_LKP_Linea_Contrato__c,
		                                                     OTR_LKP_Recurso_Servicio__c,
		                                                     OTR_LKP_Recurso_Servicio__r.RSE_TXT_Codigo_Recurso__c,
		                                                     OTR_SEL_Gremio__c,
		                                                     OTR_SEL_Rango_Primera_Cita__c,
		                                                     OTR_SEL_Tipo_Red__c,
		                                                     OTR_SEL_Tipologia_de_Servicio__c,
		                                                     OTR_SEL_Categoria_del_profesional__c,
		                                                     OTR_LKP_Gestor_revision__c,
		                                                     OTR_SEL_Motivo_de_rectificacion__c,
		                                                     OTR_SEL_Penalizacion__c,
		                                                     OTR_TXT_rectificacion__c,
		                                                     OTR_TXT_Comentario_Auditoria__c,
		                                                     OwnerId,
		                                                     ParentWorkorderId,
		                                                     ParentWorkorder.ParentWorkorderId,
		                                                     PostalCode,
		                                                     RecordType.Name,
		                                                     RecordTypeId,
		                                                     ServiceTerritory.Name,
		                                                     ServiceTerritoryId,
		                                                     ServiceTerritory.PostalCode,
		                                                     State,
		                                                     Status,
		                                                     OTR_SEL_Subestado__c,
		                                                     Street,														            
		                                                     WorkOrderNumber,
		                                                     WorkType.Name,
		                                                     WorkTypeId
		                                                     FROM WorkOrder
		                                                     WHERE ParentWorkorderId = :wo.Id
		                                                     OR ParentWorkorder.ParentWorkorderId = :wo.Id]);*/
		                                                     
		Workorder woBackup = null;
		if(!listaClonarOT.isEmpty()){
			
			for(Workorder ot: listaClonarOT){
				if(ot.ParentWorkorder.ParentWorkorderId == wo.Id){
					woBackup = ot;
				}
			}
			
			if(woBackup != null){
				Workorder woCopia = woBackup.clone(false,true);
				woCopia.Id = wo.Id;
				woCopia.ParentWorkorderId = null;
				
				clonePartidas(woBackup, woCopia, true);
				
				Baipas.establecerVariableControl();
				update woCopia;
				
				delete listaClonarOT;
				Baipas.deshabilitarVariableControl();
				
			}
			
			return wo.Id;
		} else {
			return null;
		} 
		
	}

	webservice static Id getRTIdbyDevNameBoton(String nombreRT){
		return Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(nombreRT);
	}

	webservice static Boolean partidasModificadas(Id woHija){
		
		Boolean retValue = false;
		
		List<Workorder> woLista = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{woHija}).values();
		/*List<Workorder> woLista = [Select Id, 
									ParentWorkOrderId,
									OTR_RES_Facturar_Cliente_AI__c,
									OTR_RES_Subtotal_Partidas__c,
									OTR_RES_Liquidar_prof_AI__c,
									ParentWorkorder.OTR_RES_Facturar_Cliente_AI__c,
									ParentWorkorder.OTR_RES_Subtotal_Partidas__c,
									ParentWorkorder.OTR_RES_Liquidar_prof_AI__c
									From workorder where id = :woHija];*/
									
		if(!woLista.isEmpty()){
			Workorder wo = woLista.get(0);
			
			if(wo.OTR_RES_Facturar_Cliente_AI__c != wo.ParentWorkorder.OTR_RES_Facturar_Cliente_AI__c ||
				wo.OTR_RES_Subtotal_Partidas__c != wo.ParentWorkorder.OTR_RES_Subtotal_Partidas__c ||
				wo.OTR_RES_Liquidar_prof_AI__c != wo.ParentWorkorder.OTR_RES_Liquidar_prof_AI__c){
					retValue = true;
			} 
		}
		
		return retValue;
	}
	
	
	webservice static Boolean generarYEnviarAlbaran(Id woId){
		generarAlbaran(new Workorder(Id=woId));
		Util_Orden_Trabajo.avisoModificacionPartidas(new Set<Id>{woId});//TODO: Descapar cuando los emails esten definidos
		return true;
	}
	

	webservice static Boolean asignarPreferencias(Id woId, Id woNewId, Boolean noMismoProfesional){

		Workorder wo = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{woId}).get(woId);
		//Workorder wo = [Select id,OTR_LKP_Recurso_Servicio__c,OTR_SEL_Gremio__c from Workorder where Id = :woId];


		ServiceResource recProfesional = null;

		if(wo.OTR_LKP_Recurso_Servicio__c == null){

			List<ServiceResource> recList = Util_Service_Resource.queryMapSRByWoIds(new Set<Id>{woId}).values();
			//List<ServiceResource> recList = [select id, RelatedRecordId from ServiceResource where Id in (Select ServiceResourceId from AssignedResource where ServiceAppointment.ParentRecordId = :woId)];
			if(!recList.isEmpty())
				recProfesional = recList[0];

		} else {
			List<ServiceResource> recList = Util_Service_Resource.queryMapSRByRsIds(new Set<Id>{wo.OTR_LKP_Recurso_Servicio__c}).values();
			//List<ServiceResource> recList = [Select id, RelatedRecordId from ServiceResource where id = :wo.OTR_LKP_Recurso_Servicio__c];
			if(!recList.isEmpty())
				recProfesional = recList[0];
		}

		Boolean error = false;
		if(recProfesional != null){
			ResourcePreference rp = new ResourcePreference();

			rp.ServiceResourceId = recProfesional.Id;
			if(!noMismoProfesional)
				rp.PreferenceType = 'Required';
			else
				rp.PreferenceType = 'Excluded';

			rp.RelatedRecordId = woNewId;

			try{
				insert rp;
			} catch(Exception e){
				error = true;
				System.debug('Error: '+e.getMessage());

			}
		}

		return error;

	}



	private static void cloneAttachments(WorkOrder wo){

		List<Attachment> listAtt = Util_Attachment.queryMapAttachmentByParent(new Set<Id>{wo.ParentWorkOrderId}).values();
		List<Attachment> listAttClone = new List<Attachment>();

		system.debug(wo);

		for(Attachment att: listAtt){

			Attachment aClone = new Attachment(Name = att.Name, body = att.body, ParentId = wo.Id, OwnerId = att.OwnerId);
			listAttClone.add(aClone);
		}

		if(listAttClone.size() > 0)
			insert listAttClone;
	}

	private static void cloneContentVersion(WorkOrder wo){
		List<ContentDocumentLink> archivos = Util_Documentacion.queryCDLByLinkedEntity(new Set<Id>{wo.ParentWorkOrderId}).values();
		//List<ContentDocumentLink> archivos = [Select Id, ContentDocumentId from ContentDocumentLink where LinkedEntityId = :wo.ParentWorkOrderId];
		
		List<ContentDocumentLink> copiasArchivos = new List<ContentDocumentLink>();
		
		for(ContentDocumentLink cdl: archivos){
			copiasArchivos.add(new ContentDocumentLink(ContentDocumentId=cdl.ContentDocumentId,LinkedEntityId=wo.Id,ShareType='V'));
		}
				
		insert copiasArchivos;

		/*List<ServiceAppointment> citasServicio = [Select id from ServiceAppointment where ParentRecordId = :wo.ParentWorkOrderId];
		Set<Id> citasId = new Set<Id>();
		for(ServiceAppointment cita: citasServicio){
			citasId.add(cita.Id);
		}
		List<ContentVersion> albaranes = [SELECT ContentDocumentId,ContentBodyId,FileType,Title,Id,FirstPublishLocationId,VersionNumber 
		                                 FROM ContentVersion 
		                                 where FirstPublishLocationId = :wo.ParentWorkOrderId 
		                                 or FirstPublishLocationId in :citasId];
		List<ContentVersion> listaClones = new List<ContentVersion>();

		system.debug(wo);

		for(ContentVersion alb: albaranes){

			ContentVersion aClone = alb.clone();
			aClone.FirstPublishLocationId = wo.Id;
			listaClones.add(aClone);
		}

		if(listaClones.size() > 0)
			insert listaClones;*/
	}

	private static void cloneComentarios(WorkOrder wo){

		List<Comentario_Orden_de_Trabajo__c> comentarios = Util_Orden_Trabajo.getComentariosOT(new Set<Id>{wo.ParentWorkOrderId});
		//List<Comentario_Orden_de_Trabajo__c> comentarios = [SELECT COT_LKP_Orden_de_trabajo__c,COT_SEL_Tipo__c,COT_TXT_Comentario__c,Id,Name FROM Comentario_Orden_de_Trabajo__c where COT_LKP_Orden_de_trabajo__c = :wo.ParentWorkOrderId];
		List<Comentario_Orden_de_Trabajo__c> listaClones = new List<Comentario_Orden_de_Trabajo__c>();

		system.debug(wo);

		for(Comentario_Orden_de_Trabajo__c com: comentarios){

			Comentario_Orden_de_Trabajo__c cClone = com.clone();
			cClone.COT_LKP_Orden_de_trabajo__c = wo.Id;
			listaClones.add(cClone);
		}

		if(listaClones.size() > 0)
			insert listaClones;
	}


	private static void clonePartidas(WorkOrder wo, WorkOrder woPadre, Boolean ignoraModificacion){
		List <WorkOrderLineItem> listaItemsHija = Util_Partida.queryMapPartidasOTByWorkOrder(new Set<Id>{wo.Id}).values();
		/*List <WorkOrderLineItem> listaItemsHija = new List<WorkOrderLineItem>([SELECT
		                                                                       Id,
			                                                                   PAR_NUM_Altura__c,
			                                                                   PAR_NUM_Ancho__c,
			                                                                   PAR_TXT_Ceco__c,
			                                                                   PAR_TXT_Baremo_Desc__c,
			                                                                   PAR_CAS_Orden_Trabajo_Anulada__c,
			                                                                   PAR_TXT_Detalle_Venta__c,
			                                                                   PAR_POR_Materiales__c,
			                                                                   PAR_DIV_Precio_Unitario_Venta__c,
			                                                                   PAR_FOR_Precio_Unitario_Venta_Cli__c,
			                                                                   PAR_DIV_Cantidad_Venta__c,
			                                                                   PAR_TXT_Unidades_Medida_Gastos__c,
			                                                                   PAR_SEL_Unidades_Medida__c,
			                                                                   PAR_POR_Descuento__c,
			                                                                   Discount,
			                                                                   PAR_SEL_Codigo_Impuesto_Venta__c,
			                                                                   PAR_CAS_Danos_Esteticos__c,
			                                                                   PAR_POR_Impuesto_Prof__c,
			                                                                   PAR_POR_Porcentaje_Imp_Cia_Cliente__c,
			                                                                   PAR_DIV_ListPrice__c,
			                                                                   PAR_DIV_UnitPrice__c,
			                                                                   PAR_DIV_Facturacion_Total_AI__c,
			                                                                   PAR_DIV_Facturacion_Total_DI__c,
		                                                                       Description,
		                                                                       PAR_TXT_Baremo_Codigo__c,
		                                                                       PAR_DIV_Liquidar_Prof_DI__c,
		                                                                       PAR_DIV_Cargar_Cliente_AI__c,
		                                                                       PAR_DIV_Cargar_Comp_AI__c,
		                                                                       PAR_DIV_Liquidar_Prof_AI__c,
																			   PAR_TXT_Detalle_WOLI__c,
																			   PAR_NUM_Unidades__c,
		                                                                       Status,
		                                                                       PAR_SEL_Danios_Del__c,
		                                                                       WorkOrderId,
		                                                                       WorkOrder.OTR_RES_Facturar_Cliente_AI__c,
		                                                                       Workorder.OTR_RES_Subtotal_Partidas__c,
		                                                                       Workorder.OTR_RES_Liquidar_prof_AI__c
		                                                                       FROM WorkOrderLineItem 
		                                                                       WHERE WorkOrderId = :wo.Id]);*/
		List <WorkOrderLineItem> listaItemsPadre = Util_Partida.queryMapPartidasOTByWorkOrder(new Set<Id>{woPadre.Id}).values();
		/*List <WorkOrderLineItem> listaItemsPadre = new List<WorkOrderLineItem>([SELECT
		                                                                        Id
		                                                                        FROM WorkOrderLineItem 
		                                                                        WHERE WorkOrderId = :woPadre.Id]);*/

		List <WorkOrderLineItem> newItemsPadre = new List<WorkOrderLineItem>();

		Boolean hayModificacion = false;

		if(!listaItemsHija.isEmpty()){
			for(WorkOrderLineItem it:listaItemsHija){
				WorkOrderLineItem woliClon = it.clone(false,true);
				woliClon.WorkOrderId = woPadre.Id;
				if(!listaItemsPadre.isEmpty()){
					woliClon.WOLI_Ultima_modificacion__c = listaItemsPadre[0].Createdby.Name;
				}
				newItemsPadre.add(woliClon);
				
				if(it.WorkOrder.OTR_RES_Facturar_Cliente_AI__c != woPadre.OTR_RES_Facturar_Cliente_AI__c ||
						it.WorkOrder.OTR_RES_Subtotal_Partidas__c != woPadre.OTR_RES_Subtotal_Partidas__c ||
						it.WorkOrder.OTR_RES_Liquidar_prof_AI__c != woPadre.OTR_RES_Liquidar_prof_AI__c){
					hayModificacion = true;
				} 
			} 
             				   
            Baipas.establecerVariableControl();
			insert newItemsPadre;
			Baipas.deshabilitarVariableControl();            			                					
			
			delete listaItemsPadre;
			
			if(hayModificacion && !ignoraModificacion){
				woPadre.OTR_CAS_Partidas_Modificadas_Revision__c = true;
				system.debug('---------wo.OTR_SEL_Penalizacion__c: '+wo.OTR_SEL_Penalizacion__c);
				if(wo.OTR_SEL_Penalizacion__c != 'No procede') {
					woPadre.OTR_SEL_Penalizacion__c = wo.OTR_SEL_Penalizacion__c;
					crearPropuestaEvento(woPadre);
				}
				system.debug('------------hayModificacion');
			}    			
		}
		
		system.debug('----------o----------woPadre.OTR_CAS_Partidas_Modificadas_Revision__c: '+woPadre.OTR_CAS_Partidas_Modificadas_Revision__c);

	}
	
	private static void cloneActivityHistory(WorkOrder woOrigen, WorkOrder woDestino){
		List<Task> tareas = Util_Tarea.getTareaByWhatAndInStatus(new Set<Id>{woOrigen.Id},new Set<String>{'Completed','Finalizado'}).values();
		/*List<Task> tareas = [Select id,
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
									from task where (Status = 'Completed' or Status = 'Finalizado') and WhatId = :woOrigen.Id];*/
									
		
		
		List<Task> tareasInsertar = new List<Task>();
		
		for(Task tarea: tareas){
			Task clonTarea = tarea.clone();
			clonTarea.WhatId = woDestino.Id;
			clonTarea.Status = 'Completed';
			tareasInsertar.add(clonTarea);
		}			
		
		if(!tareasInsertar.isEmpty()){
			insert tareasInsertar;		
		}	
 		
		
	}
	
	/*private static void copiarUltimoAlbaran(WorkOrder wo, WorkOrder woPadre){
		
		List<ContentVersion> albaranesHija = [SELECT ContentDocumentId,ContentBodyId,FileType,Title,Id,FirstPublishLocationId,VersionNumber,Template 
		                                 		FROM ContentVersion 
		                                 		where FirstPublishLocationId = :wo.Id];
												
		if(!albaranesHija.isEmpty()){
			ContentVersion aClone = albaranesHija.get(0).clone();
			aClone.ParentId = woPadre.Id;
			insert aClone;
		}
		
	}*/
	
	webService static void crearPropuestaEvento(WorkOrder ot) {
		system.debug(ot);
		String importe = ot.OTR_SEL_Penalizacion__c.replaceAll('€', '');
		Propuesta_de_Evento__c evento = new Propuesta_de_Evento__c();
        evento.EV_AB_LKP_Imputar_a_profesional__c = ot.OTR_LKP_Recurso_Servicio__c;
		evento.EV_AB_DIV_Importe_profesional__c = decimal.valueOf(importe.replaceAll(',', '.'));
		evento.EV_AB_SEL_Tipo_de_Evento__c = 'Cobro';
		evento.EV_AB_SEL_Descripcion__c = 'E19';
		evento.EV_AB_LKP_Orden_de_Trabajo__c = ot.Id;
		evento.EV_AB_SEL_Departamento_Solicitante__c = '2';
		evento.EV_AB_SEL_Estado__c = '02';
		evento.EV_AB_LKP_Caso__c = ot.CaseId;
		insert evento;
	}
	
	private static void generarAlbaran(Workorder ot){
		
		Workorder wo = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{ot.Id}).get(ot.Id);
		//Workorder wo = [Select id, Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c,Case.Account.CUE_SEL_Idioma__c from workorder where id =:ot.Id limit 1];
		List<ServiceAppointment> citasWO = Util_Cita_Servicio.getMapCitasByOTs(new Set<Id>{ot.Id}).values();
		//List<ServiceAppointment> citasWO = [Select id,AppointmentNumber from serviceappointment where ParentRecordId = :ot.Id order by createddate desc];
		
		if(!citasWO.isEmpty()){
			ContentVersion cv = Util_Documentacion.crearPDFDesdeVF(citasWO[0].Id, null, Label.PDF_TIPO_ALBARAN, wo.Case.CAS_LKP_Compania__r.CUE_TXT_Identificador__c, wo.Case.Account.CUE_SEL_Idioma__c, 							
																   citasWO[0].AppointmentNumber, '' + DateTime.now().getTime(), null);
																   
			cv = Util_ContentVersion.queryCVById(new Set<Id>{cv.Id}).get(cv.Id);
			//cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Id = :cv.Id];
			ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = wo.Id,
															  ContentDocumentId=cv.ContentDocumentId,
															  ShareType = 'V',
															  Visibility = 'AllUsers');
			insert cdl;
		}
	}

	/**
	 * Cambia una cita de servicio desde el botón de Citas de Servicio "Cambiar Cita". Se ejecuta siempre que la cita actual no esté "En curso", "Anulada" o "Completada".
	 *
	 * @param idCita: id de la cita actual
	 *
	 * @return lista de String que contiene la redirección de la página al cambiar la cita y un mensaje que se mostrará en caso de error o si la cita que se crea es urgente
	 */	
	webService static List<String> cambiarCita (Id idCita){
		List<String> resultado = new List<String>();
		ServiceAppointment cita = Util_Cita_Servicio.getMapCitasById(new Set<Id>{idCita}).get(idCita);
		List<WorkOrder> listaWo = Util_Orden_Trabajo.queryMapOTById(new Set<Id>{cita.ParentRecordId}).values();
		if(listaWo != null && !listaWo.isEmpty()){
			WorkOrder wo = listaWo.get(0);
			if(cita != null){
				//Rellenamos la paginaRedireccion con la URL a la que queremos que nos redirija al pulsar el botón
				String paginaRedireccion = '/apex/' + Label.VF_RESERVARCITA + '?';
				if(wo.CaseId != null){
					paginaRedireccion += 'id=' + wo.CaseId + '&inline=1&';
				}
				paginaRedireccion += 'idOrdenTrabajo=' + wo.Id;
				resultado.add(paginaRedireccion);
				system.Savepoint puntoGuardado = Database.setSavepoint();
				try {
					if(cita.Status == Label.CIT_ESTADO_PTE_ASIGNAR && cita.ArrivalWindowStartTime == null){
						//Mantiene la cita actual para que se reprograme (Se reutilice)
						resultado.remove(0);
						paginaRedireccion += '&' + 'retorno=' + '/' + cita.Id;
						resultado.add(paginaRedireccion);
					}
					else{
						cita.Status = null;
						// Clonar la primera cita actual
						ServiceAppointment nuevaCita = Util_Cita_Servicio.nuevaCita(cita);
						// Establecer en estado ANULADO POR CAMBIO la primera cita actual
						cita.Status = Label.CIT_ESTADO_ANULADA_POR_CAMBIO;
						cita.CSE_CAS_Cambio_de_cita__c = true;
						// En los test no se carga la configuración FSL y salta error en la transición de estado de la cita
						if(!Test.isRunningTest()) update cita;
						// Insertar la nueva cita clonada
						insert nuevaCita;
						resultado.remove(0);
						paginaRedireccion += '&' + 'retorno=' + '/' + nuevaCita.Id;
						resultado.add(paginaRedireccion);
					}
					//Si es cita urgente se debe mostrar un mensaje en vez de hacer un redireccionamiento a la página de reservar cita
					if(wo.OTR_CAS_Urgente__c){
	                    system.Savepoint puntoGuardado2 = Database.setSavepoint();
	                    try {
							system.debug('>>>>>>>>>>>>>>>>>>>>>>> Reserva Urgente');
							ReservarCitaUrgente.reservaCita(cita.ParentRecordId);
							// Tras reservar la cita hay que validar si se han establecido las fechas y pintarlas
							if(cita.ArrivalWindowStartTime != null && cita.ArrivalWindowEndTime != null){
								String fechaCitaUrgenteReservada = 'La cita se ha reservado correctamente para el día ' + String.valueOf(cita.ArrivalWindowStartTime.date()) + ' en la franja de ' + string.valueOf(cita.ArrivalWindowStartTime.time()).left(5)+'-'+ string.valueOf(cita.ArrivalWindowEndTime.time()).left(5);
								resultado.add(fechaCitaUrgenteReservada);
							}
							else {
								resultado.add('Error: ' + Label.ERROR_RESERVACITAURG);
							}
	                    }
						catch(DMLException e){
							Database.rollback(puntoGuardado2);
							system.debug(e.getStackTraceString());
							resultado.add('Error: ' + Label.ERROR_GUARDAR + ' : ' + e.getMessage());
						}
					}
				}
				catch(DMLException e){
					Database.rollback(puntoGuardado);
					system.debug(e.getStackTraceString());
					resultado.add('Error: ' + Label.ERROR_GUARDAR + ' : ' + e.getMessage());
				}
			}
		}
		return resultado;
	}
}