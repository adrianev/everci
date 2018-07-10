/**
 * Handler del Trigger TRG_Presupuesto.
 * 
 * @author EVERIS
 * 
 */
public without sharing class TRG_Handler_Presupuesto {

	public static void tratamientoBefore(List<Presupuesto__c> triggerNew, Map<Id, Presupuesto__c> triggerOldMap){
		if(Trigger.isUpdate){
			for(Presupuesto__c pre : triggerNew){
				Presupuesto__c preOld;
				if(triggerOldMap != null){
					preOld = triggerOldMap.get(pre.Id);
				}

				// ACCIONES TRAS CAMBIO DE ESTADO
				if(preOld != null && pre.PRE_SEL_Estado__c != preOld.PRE_SEL_Estado__c){
					// Guardar el estado anterior
					pre.PRE_SEL_Estado_Anterior__c = preOld.PRE_SEL_Estado__c;
				}
			}	
		}
	}

	/**
	  * Tratamiento para el caso after del trigger.
	  * 
	  * @param triggerNew: lista de registros nuevos del objeto Presupuesto__c
	  * @param triggerOldMap: mapa de registros antiguos del objeto Presupuesto__c a partir del Id
	  */
	public static void tratamientoAfter(List<Presupuesto__c> triggerNew, Map<Id, Presupuesto__c> triggerOldMap){

		// Mapa de Presupuestos actualizados en el Trigger
		Map<Id,Presupuesto__c> mapaPresupUpdate = new Map<Id,Presupuesto__c>();
		// Mapa de Casos actualizados en el Trigger
		Map<Id,Case> mapaCasosUpdate = new Map<Id,Case>();
		// Mapa de Ordenes de Trabajo actualizadas en el Trigger
		Map<Id,WorkOrder> mapaOTsUpdate = new Map<Id,WorkOrder>();
		// Mapa de Partidas actualizadas en el Trigger.isUpdate
		Map<Id,WorkOrderLineItem> mapaPartidasUpdate = new Map<Id,WorkOrderLineItem>();

		Set<Id> setIdsCasos = new Set<Id>();

		for(Presupuesto__c pre : triggerNew){
			setIdsCasos.add(pre.PRE_LKP_Caso__c);
		}

		Map<Id, Case> mapaCasos = Util_Caso.getCaseById(setIdsCasos);
		//Map<Id, Case> mapaCasos = Util_Caso.getMapaCasos(setIdsCasos);
		// Crear Mapa con todas las OTs no anuladas de los Casos asociados a los Presupuestos actualizados del Trigger
		Map<Id, List<WorkOrder>> mapaOTsCaso = Util_Orden_Trabajo.getMapaOTsCasos(setIdsCasos);
		// Crear Mapa con todas las partidas no rechazadas de los Casos asociados a los Presupuestos actualizados del Trigger
		Map<Id, List<WorkOrderLineItem>> mapaPartidasCaso = Util_Caso.getMapaPartidasCasos(setIdsCasos);

		//Mapa para almacenar los presupuestos con su caso correspondiente para generar los pdf
		//Map<Id,Id> pdfPresACaso = new Map<Id,Id>();

		if(Trigger.isInsert || Trigger.isUpdate){

			if(Trigger.isInsert){
				system.debug('>>>>>>>>>>>TRG_Handler_Presupuesto.tratamientoAfter(): Trigger.isInsert');
				// ESTABLECER EN EL EXTERNAL ID EL AUTONUMERICO DEL CAMPO Name
				system.debug('>>>>>>>>>>>ESTABLECER EN EL EXTERNAL ID EL AUTONUMERICO DEL CAMPO Name');

				for(Presupuesto__c pre : triggerNew){
					if(pre.PRE_TXT_Identificador__c == null
							|| pre.PRE_TXT_Identificador__c != pre.Name){
						Presupuesto__c preUpdate = (Presupuesto__c)recogerObjetoActualizar(mapaPresupUpdate, new Presupuesto__c(Id=pre.Id));
						preUpdate.PRE_TXT_Identificador__c = String.valueof(pre.Name);
						mapaPresupUpdate.put(preUpdate.Id,preUpdate);
						system.debug('>>>>>>>>>>>preUpdate.PRE_TXT_Identificador__c despues: ' + preUpdate.PRE_TXT_Identificador__c);
					}
				}
			}

			system.debug('>>>>>>>>>>>TRG_Handler_Presupuesto.tratamientoAfter(): Trigger.isInsert || Trigger.isUpdate');
			for(Presupuesto__c pre : triggerNew){
				Presupuesto__c preOld;
				if(triggerOldMap != null){
					preOld = triggerOldMap.get(pre.Id);
				}
				Case caso = mapaCasos.get(pre.PRE_LKP_Caso__c);
				Case casoUpdate = (Case)recogerObjetoActualizar(mapaCasosUpdate,caso);

				Boolean actualizarCaso = false;

				// DESMARCAR EL CHECK DE GENERAR PRESUPUESTO EN CASO TRAS INSERTAR PRESUPUESTO
				if(Trigger.isInsert && caso.CAS_CAS_Generar_Presupuesto__c){
					system.debug('>>>>>>>>>>>DESMARCAR EL CHECK DE GENERAR PRESUPUESTO EN CASO TRAS INSERTAR PRESUPUESTO');
					system.debug('>>>>>>>>>>>caso.CAS_CAS_Generar_Presupuesto__c: ' + caso.CAS_CAS_Generar_Presupuesto__c);
					casoUpdate.CAS_CAS_Generar_Presupuesto__c = false;
					actualizarCaso = true;
				}


				// ACCIONES TRAS CAMBIOS DE ESTADO EN EL PRESUPUESTO
				if(preOld == null || pre.PRE_SEL_Estado__c != preOld.PRE_SEL_Estado__c){
					system.debug('>>>>>>>>>>>ACCIONES TRAS CAMBIOS DE ESTADO EN EL PRESUPUESTO');
					system.debug('>>>>>>>>>>>pre.PRE_SEL_Estado__c: ' + pre.PRE_SEL_Estado__c);

					// Si el nuevo estado es PENDIENTE CLIENTE / PENDIENTE CIA:
					if(pre.PRE_SEL_Estado__c == Label.PRESUPUESTO_PENDIENTE ||
							pre.PRE_SEL_Estado__c == Label.PRESUPUESTO_PENDIENTE_CIA){
						system.debug('>>>>>>>>>>>Si el nuevo estado es PENDIENTE CLIENTE / PENDIENTE CIA');
						// Se establece el estado PENDIENTE XXXX de todas las OTs no anuladas ni cerradas
						if(mapaOTsCaso.get(pre.PRE_LKP_Caso__c) != null){
							String nuevoEstadoOT = Label.OTR_ESTADO_PDTE_PRESUP_CLIENTE;
							if(pre.PRE_SEL_Estado__c == Label.PRESUPUESTO_PENDIENTE_CIA){
								nuevoEstadoOT = Label.OTR_ESTADO_PDTE_PRESUP_CIA;
							}
							for(WorkOrder wo : mapaOTsCaso.get(pre.PRE_LKP_Caso__c)){
								WorkOrder woUpdate = (WorkOrder)recogerObjetoActualizar(mapaOTsUpdate,wo);
								if(!Util_Orden_Trabajo.SET_ESTADOS_CERRADOS.contains(woUpdate.Status) &&
										(!woUpdate.OTR_CAS_Urgente__c ||
												pre.PRE_SEL_Estado__c == Label.PRESUPUESTO_PENDIENTE ||
												woUpdate.OTR_FOR_Lim_Actuac_CIA_NoPermiteUrg__c)){
									system.debug('>>>>>>>>>>>woUpdate.Id: ' + woUpdate.Id);
									system.debug('>>>>>>>>>>>woUpdate.Status anterior: ' + woUpdate.Status);
									woUpdate.Status = nuevoEstadoOT;
									system.debug('>>>>>>>>>>>woUpdate.Status nuevo: ' + woUpdate.Status);
									mapaOTsUpdate.put(woUpdate.Id,woUpdate);
								}
							}
						}
						// Se establecen en pendiente las partidas aceptadas o estimadas
						if(mapaPartidasCaso.get(pre.PRE_LKP_Caso__c) != null){
							String nuevoEstadoPartidas = Label.PAR_ESTADO_PDTE_CLIENTE;
							if(pre.PRE_SEL_Estado__c == Label.PRESUPUESTO_PENDIENTE_CIA){
								nuevoEstadoPartidas = Label.PAR_ESTADO_PDTE_CIA;
							}
							Set<String> estadosOrigenValidos = Util_Partida.estadosValidos(nuevoEstadoPartidas);
							for(WorkOrderLineItem woli : mapaPartidasCaso.get(pre.PRE_LKP_Caso__c)){
								WorkOrderLineItem woliUpdate = (WorkOrderLineItem)recogerObjetoActualizar(mapaPartidasUpdate,woli);		  
								if(estadosOrigenValidos.contains(woliUpdate.Status)){
									system.debug('>>>>>>>>>>>woliUpdate.Id: ' + woliUpdate.Id);
									system.debug('>>>>>>>>>>>woliUpdate.Status anterior: ' + woliUpdate.Status);
									woliUpdate.Status = nuevoEstadoPartidas;
									system.debug('>>>>>>>>>>>woliUpdate.Status nuevo: ' + woliUpdate.Status);
									mapaPartidasUpdate.put(woliUpdate.Id,woliUpdate);
								}
							}
						}
						// Si el estado del Caso es NUEVO: se establece el estado del Caso a EN CURSO
						system.debug('>>>>>>>>>>>caso.Status anterior: ' + casoUpdate.Status);
						if(casoUpdate.Status == Label.CAS_ESTADO_NUEVO){
							casoUpdate.Status = Label.CAS_ESTADO_EN_CURSO;
							actualizarCaso = true;
						}
						system.debug('>>>>>>>>>>>casoUpdate.Status nuevo: ' + casoUpdate.Status);
						system.debug('>>>>>>>>>>>actualizarCaso: ' + actualizarCaso);
					}


					// Si es una actualización y el nuevo estado es APROBADO / APROBADO CIA:
					else if(pre.PRE_SEL_Estado__c == Label.PRESUPUESTO_APROBADO ||
							pre.PRE_SEL_Estado__c == Label.PRESUPUESTO_APROBADO_CIA){
						system.debug('>>>>>>>>>>>Si el nuevo estado es APROBADO / APROBADO CIA');
						// Si el estado anterior era PDTE.CLIENTE o PDTE.CIA:
						// Se restaura el estado anterior de todas las OTs en espera
						if((pre.PRE_SEL_Estado_Anterior__c == Label.PRESUPUESTO_PENDIENTE ||
						    pre.PRE_SEL_Estado_Anterior__c == Label.PRESUPUESTO_PENDIENTE_CIA) &&
								mapaOTsCaso.get(pre.PRE_LKP_Caso__c) != null){
							for(WorkOrder wo : mapaOTsCaso.get(pre.PRE_LKP_Caso__c)){
								WorkOrder woUpdate = (WorkOrder)recogerObjetoActualizar(mapaOTsUpdate,wo);
								if(((pre.PRE_SEL_Estado__c == Label.PRESUPUESTO_APROBADO &&
										woUpdate.Status == Label.OTR_ESTADO_PDTE_PRESUP_CLIENTE) ||
										(pre.PRE_SEL_Estado__c == Label.PRESUPUESTO_APROBADO_CIA &&
										woUpdate.Status == Label.OTR_ESTADO_PDTE_PRESUP_CIA)) &&
										woUpdate.OTR_TXT_Estado_Anterior__c != null){
									system.debug('>>>>>>>>>>>woUpdate.Id: ' + woUpdate.Id);
									system.debug('>>>>>>>>>>>woUpdate.Status anterior: ' + woUpdate.Status);
									woUpdate.Status = woUpdate.OTR_TXT_Estado_Anterior__c;
									system.debug('>>>>>>>>>>>woUpdate.Status nuevo: ' + woUpdate.Status);
									mapaOTsUpdate.put(woUpdate.Id,woUpdate);
								}
							}

						}
						// Se aceptan las partidas pendientes
						
						system.debug('--------mapaPartidasCaso: '+mapaPartidasCaso);
						if(mapaPartidasCaso.get(pre.PRE_LKP_Caso__c) != null){
							String nuevoEstadoPartida = Label.PAR_ESTADO_ACEPTADA_CLIENTE;
							if(pre.PRE_SEL_Estado__c == Label.PRESUPUESTO_APROBADO_CIA){
								nuevoEstadoPartida = Label.PAR_ESTADO_ACEPTADA_POR_PERITO_CIA;
							}
							Set<String> estadosOrigenValidos = Util_Partida.estadosValidos(nuevoEstadoPartida);
							system.debug('-------estadosOrigenValidos: '+estadosOrigenValidos);
							for(WorkOrderLineItem woli : mapaPartidasCaso.get(pre.PRE_LKP_Caso__c)){
								WorkOrderLineItem woliUpdate = (WorkOrderLineItem)recogerObjetoActualizar(mapaPartidasUpdate,woli);		  
								if(estadosOrigenValidos.contains(woliUpdate.Status)){
									system.debug('>>>>>>>>>>>woliUpdate.Id: ' + woliUpdate.Id);
									system.debug('>>>>>>>>>>>woliUpdate.Status anterior: ' + woliUpdate.Status);
									woliUpdate.Status = nuevoEstadoPartida;
									system.debug('>>>>>>>>>>>woliUpdate.Status nuevo: ' + woliUpdate.Status);
									mapaPartidasUpdate.put(woliUpdate.Id,woliUpdate);
								}
							}
						}
						// Autorizar límite de actuación
						if(pre.PRE_SEL_Estado__c == Label.PRESUPUESTO_APROBADO_CIA){
							casoUpdate.CAS_CAS_Supera_Limite_Actuacion__c = false;
							actualizarCaso = true;
						}
						system.debug('>>>>>>>>>>>caso.CAS_CAS_Supera_Limite_Actuacion__c: ' + casoUpdate.CAS_CAS_Supera_Limite_Actuacion__c);
						system.debug('>>>>>>>>>>>caso.CAS_CAS_Generar_Presupuesto__c: ' + casoUpdate.CAS_CAS_Generar_Presupuesto__c);
						system.debug('>>>>>>>>>>>actualizarCaso: ' + actualizarCaso);
					}


					// Si el nuevo estado es RECHAZADO (PARCIAL):
					else if(pre.PRE_SEL_Estado__c == Label.PRESU_RECHAZADO_PARCIAL){
						system.debug('>>>>>>>>>>>Si el nuevo estado es RECHAZADO (PARCIAL)');
						// Obligar a generar un nuevo presupuesto
						casoUpdate.CAS_CAS_Generar_Presupuesto__c = true;
						actualizarCaso = true;
						system.debug('>>>>>>>>>>>caso.CAS_CAS_Supera_Limite_Actuacion__c: ' + casoUpdate.CAS_CAS_Supera_Limite_Actuacion__c);
						system.debug('>>>>>>>>>>>caso.CAS_CAS_Generar_Presupuesto__c: ' + casoUpdate.CAS_CAS_Generar_Presupuesto__c);
						system.debug('>>>>>>>>>>>actualizarCaso: ' + actualizarCaso);
					}


					// Si el nuevo estado es RECHAZADO (TOTAL):
					else if(pre.PRE_SEL_Estado__c == Label.PRESUPUESTO_RECHAZADO){
						system.debug('>>>>>>>>>>>Si el nuevo estado es RECHAZADO (TOTAL)');
						// Se anulan todas las OTs no anuladas ni cerradas
						// y ésto rechaza en cascada las partidas correspondientes
						if(mapaOTsCaso.get(pre.PRE_LKP_Caso__c) != null){
							for(WorkOrder wo : mapaOTsCaso.get(pre.PRE_LKP_Caso__c)){
								WorkOrder woUpdate = (WorkOrder)recogerObjetoActualizar(mapaOTsUpdate,wo);
								if(!caso.CAS_FOR_EsB2C__c && caso.CAS_LKP_Compania__r.CUE_TXT_Identificador__c == Label.IDE_ENDESA){
									if(!Util_Orden_Trabajo.SET_ESTADOS_CERRADOS.contains(woUpdate.Status)){
										system.debug('>>>>>>>>>>>woUpdate.Id: ' + woUpdate.Id);
										system.debug('>>>>>>>>>>>woUpdate.Status anterior: ' + woUpdate.Status);
										woUpdate.Status = Label.OTR_ESTADO_PENDIENTE_CIA;
										system.debug('>>>>>>>>>>>woUpdate.Status nuevo: ' + woUpdate.Status);
										mapaOTsUpdate.put(woUpdate.Id,woUpdate);
									}
								}
								else {
									if(!Util_Orden_Trabajo.SET_ESTADOS_CERRADOS.contains(woUpdate.Status)){
										system.debug('>>>>>>>>>>>woUpdate.Id: ' + woUpdate.Id);
										system.debug('>>>>>>>>>>>woUpdate.Status anterior: ' + woUpdate.Status);
										woUpdate.Status = Label.OTR_ESTADO_ANULADO;
										system.debug('>>>>>>>>>>>woUpdate.Status nuevo: ' + woUpdate.Status);
										mapaOTsUpdate.put(woUpdate.Id,woUpdate);
									}
								}
							}
						}
						
						if(mapaPartidasCaso.get(pre.PRE_LKP_Caso__c) != null){
							String nuevoEstadoPartida = Label.PAR_ESTADO_RECHAZADA_GESTOR;
							if(pre.PRE_SEL_Estado_Anterior__c == Label.PRESUPUESTO_PENDIENTE){
								nuevoEstadoPartida = Label.PAR_ESTADO_RECHAZADA_CLIENTE;
							}
							else if(pre.PRE_SEL_Estado_Anterior__c == Label.PRESUPUESTO_PENDIENTE_CIA){
								nuevoEstadoPartida = Label.PAR_ESTADO_RECHAZADA_CIA;
							}
							for(WorkOrderLineItem woli : mapaPartidasCaso.get(pre.PRE_LKP_Caso__c)){
								WorkOrderLineItem woliUpdate = (WorkOrderLineItem)recogerObjetoActualizar(mapaPartidasUpdate,woli);		  
								if(!Util_Partida.SET_ESTADOS_RECHAZADOS.contains(woliUpdate.Status)){
									system.debug('>>>>>>>>>>>woliUpdate.Id: ' + woliUpdate.Id);
									system.debug('>>>>>>>>>>>woliUpdate.Status anterior: ' + woliUpdate.Status);
									woliUpdate.Status = nuevoEstadoPartida;
									system.debug('>>>>>>>>>>>woliUpdate.Status nuevo: ' + woliUpdate.Status);
									mapaPartidasUpdate.put(woliUpdate.Id,woliUpdate);
								}
							}
						}
						// Establecer el motivo de rechazo en el Caso
						casoUpdate.CAS_SEL_Motivo_rechazo_presupuesto__c = pre.PRE_SEL_Motivo_Rechazo__c;
						actualizarCaso = true;
						system.debug('>>>>>>>>>>>caso.CAS_CAS_Supera_Limite_Actuacion__c: ' + casoUpdate.CAS_CAS_Supera_Limite_Actuacion__c);
						system.debug('>>>>>>>>>>>caso.CAS_CAS_Generar_Presupuesto__c: ' + casoUpdate.CAS_CAS_Generar_Presupuesto__c);
						system.debug('>>>>>>>>>>>caso.CAS_SEL_Motivo_rechazo_presupuesto__c: ' + casoUpdate.CAS_SEL_Motivo_rechazo_presupuesto__c);
						system.debug('>>>>>>>>>>>actualizarCaso: ' + actualizarCaso);
					}
				}

				if(actualizarCaso){
					mapaCasosUpdate.put(casoUpdate.Id,casoUpdate);
				}

			} // FIN for(Presupuesto__c pre : triggerNew)
		} //FIN if(Trigger.isInsert || Trigger.isUpdate)


		// ACTUALIZAR OBJETOS PRESUPUESTO
		system.debug('>>>>mapaPresupUpdate antes de update ' + mapaPresupUpdate);
		if(mapaPresupUpdate != null && (!mapaPresupUpdate.isEmpty())){
			Baipas.establecerVariableControl();
			update mapaPresupUpdate.values();
			Baipas.deshabilitarVariableControl();
		}

		// ACTUALIZAR OBJETOS CASO
		system.debug('>>>>mapaCasosUpdate antes de update ' + mapaCasosUpdate);
		if(mapaCasosUpdate != null && (!mapaCasosUpdate.isEmpty())){
			update mapaCasosUpdate.values();
		}

		// ACTUALIZAR OBJETOS PARTIDA
		system.debug('>>>>mapaPartidasUpdate antes de update ' + mapaPartidasUpdate);
		if(mapaPartidasUpdate != null && (!mapaPartidasUpdate.isEmpty())){
			update mapaPartidasUpdate.values();
		}
		
		// ACTUALIZAR OBJETOS ORDEN DE TRABAJO
		system.debug('>>>>mapaOTsUpdate antes de update ' + mapaOTsUpdate);
		if(mapaOTsUpdate != null && (!mapaOTsUpdate.isEmpty())){
			update mapaOTsUpdate.values();
		}
	}


	private static SObject recogerObjetoActualizar(Map<Id,SObject> mapa, SObject sObejctItem){
		SObject SObejctUpdate = mapa.get(sObejctItem.Id);
		if(SObejctUpdate == null){
			SObejctUpdate = sObejctItem; //SObejctItem.getSObjectType().newSObject(sObejctItem.Id);
		}
		return SObejctUpdate;
	}
}