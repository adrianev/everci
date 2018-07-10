/**
  * Handler del Trigger TRG_Recurso_Servicio.
  * 
  * @author EVERIS
  * 
  */
public without sharing class TRG_Handler_Recurso_Servicio{

	private static List<ServiceResourceSkill> listaSRS = new List<ServiceResourceSkill>();
	
	public static void tratamientoBefore(Map<Id,ServiceResource> triggerNewMap, List<ServiceResource>triggerNew, Map<Id,ServiceResource> triggerOldMap, List<ServiceResource>triggerOld){
		if(trigger.isInsert || trigger.isUpdate){
			Set<Id> cuentasId = new Set<Id>();
			for (ServiceResource recurso: triggerNew){
				cuentasId.add(recurso.RSE_LKP_Cuenta__c);
			}
			
			Map<Id,Account> cuentas = new Map<Id,Account>([Select Id, CUE_SEL_Tipo_de_red__c from Account where Id in :cuentasId]);
			
			for (ServiceResource recurso: triggerNew){
				ServiceResource recursoOld;
				if(triggerOldMap != null){
					recursoOld = triggerOldMap.get(recurso.Id);
				}
				
				// Generamos el identificador en la inserción con el valor del Name
				if(trigger.isInsert && recurso.RSE_TXT_Codigo_Recurso__c == null){
					recurso.RSE_TXT_Codigo_Recurso__c = recurso.Name;
				}
				
				// Para los profesionales Contrato, cuando se crean tienen por defecto el estado Preactivado por lo que el check de activo debe estar a false
				if(recurso.isActive == true && (recursoOld == null || !recursoOld.isActive)) {
					recurso.RSE_DAT_Fecha_activacion__c = datetime.now();
					if(recurso.RSE_DAT_Fecha_Baja__c != null){
						recurso.RSE_DAT_Fecha_Baja__c = null;
					}
					if(recurso.RSE_DAT_Fecha_BajaTemp_Venc__c != null){
						recurso.RSE_DAT_Fecha_BajaTemp_Venc__c = null;
					}
					if(recurso.RSE_SEL_Motivo_Baja_Def__c != null){
						recurso.RSE_SEL_Motivo_Baja_Def__c = null;
					}
					if(recurso.RSE_SEL_Motivo_Baja_Temp__c != null){
						recurso.RSE_SEL_Motivo_Baja_Temp__c = null;
					}
					if(recurso.RSE_TXT_Observaciones_BajaDef__c != null){
						recurso.RSE_TXT_Observaciones_BajaDef__c = null;
					}
					if(recurso.RSE_TXT_Observaciones_BajaTemp__c != null){
						recurso.RSE_TXT_Observaciones_BajaTemp__c = null;
					}
				}
				else if(recurso.RSE_DAT_Fecha_activacion__c != null){
					recurso.RSE_DAT_Fecha_activacion__c = null;
				}
				
				if(recurso.isActive){
					Account cuentaProf = cuentas.get(recurso.RSE_LKP_Cuenta__c);
					if(cuentaProf != null && recurso.RSE_SEL_Tipo_de_red__c != cuentaProf.CUE_SEL_Tipo_de_red__c){
						recurso.RSE_SEL_Tipo_de_red__c = cuentaProf.CUE_SEL_Tipo_de_red__c;
					}
				}
			}
		}
		if(trigger.isInsert){
			String nameProfesionalGremio;
			//Creamos un set con los profesionales
			set<Id> setIdProfesionales = new set<Id>();
			for(ServiceResource recurso: triggerNew){
				if(recurso.RSE_LKP_Cuenta__c != null){
					setIdProfesionales.add(recurso.RSE_LKP_Cuenta__c);
				}
			}
			//Nos traemos un mapa con todos los profesionales implicados
			Map<Id, Account> mapProfesionales  = new Map<Id, Account>();
			if(setIdProfesionales != null && !setIdProfesionales.isEmpty()){
				mapProfesionales = Util_Service_Resource.queryMapProfesionales(setIdProfesionales);
			}
			//Nos traemos un mapa con todos los Profesionales Gremio implicados
			Map<String,Id> mapProfesionalGremio = new Map<String,Id>();
			if(setIdProfesionales != null && !setIdProfesionales.isEmpty()){
				mapProfesionalGremio = Util_Service_Resource.queryMapProfesionalesGremio(setIdProfesionales);
			}
			for(ServiceResource recurso: triggerNew){
				//Asignamos el Profesional Gremio relacionado
				nameProfesionalGremio = mapProfesionales.get(recurso.RSE_LKP_Cuenta__c).CUE_TXT_Identificador__c + '_' + recurso.RSE_SEL_Gremio__c;
				recurso.RSE_LKP_Profesional_Gremio__c = mapProfesionalGremio.get(nameProfesionalGremio);
				if(recurso.RSE_LKP_Profesional_Gremio__c == null){
					recurso.addError(label.SR_ERROR_PROFESIONAL_GREMIO);
				}
			}
		}
	}

	public static void tratamientoAfter(Map<Id,ServiceResource> triggerNewMap, List<ServiceResource> triggerNew, Map<Id,ServiceResource> triggerOldMap, List<ServiceResource> triggerOld){
		Map<String, String> mapaMotivoBajaTempo = Util_Listas_Seleccion.getLabelDesdeAPI('ServiceResource', 'RSE_SEL_Motivo_Baja_Temp__c');
		Map<String, String> mapaMotivoBajaDef = Util_Listas_Seleccion.getLabelDesdeAPI('ServiceResource', 'RSE_SEL_Motivo_Baja_Def__c');
		List<Historico_Estados_Profesional__c> historicoAActualizar = new List<Historico_Estados_Profesional__c>();
		List<Profesional_Gremio__c> gremioProfesionalAActualizar = new List<Profesional_Gremio__c>();
		Historico_Estados_Profesional__c historico;
		List<Skill> listaHabilidadesCIAs = Util_FSL.getSkillByDevName('CIA_').values();
		//Si se inserta un nuevo recurso de servicio con el profesional activado, tiene que actualizarse la documentacion del profesional
		if(trigger.isInsert){
			//Creamos un set con los profesionales
			set<Id> setIdProfesionales = new set<Id>();
			for(ServiceResource recurso: triggerNew){
				if(recurso.RSE_LKP_Cuenta__c != null){
					setIdProfesionales.add(recurso.RSE_LKP_Cuenta__c);
				}
			}
			//Nos traemos un mapa con todos los documentos de todos los profesionales implicados
			Map<Id, List<Documentos_Profesionales_Contrato__c>> mapaDocumentosProfesionales = new Map<Id, List<Documentos_Profesionales_Contrato__c>>();
			if(setIdProfesionales != null && !setIdProfesionales.isEmpty()){
				mapaDocumentosProfesionales = Util_Service_Resource.getMapaDocumentosPR(setIdProfesionales);
			}
			List<Documentos_Profesionales_Contrato__c> documentosAActualizar = new List<Documentos_Profesionales_Contrato__c>();
			for(ServiceResource recurso: triggerNew){
				//Actualizamos los documentos del profesional del recurso de servicio
				if(mapaDocumentosProfesionales.get(recurso.RSE_LKP_Cuenta__c) != null && !mapaDocumentosProfesionales.get(recurso.RSE_LKP_Cuenta__c).isEmpty()){
					documentosAActualizar.addAll(mapaDocumentosProfesionales.get(recurso.RSE_LKP_Cuenta__c));
				}
			}
			update documentosAActualizar;
		}

		if(trigger.isInsert || trigger.isUpdate){
			List<ServiceResource> actualizarSRActivos = new List<ServiceResource>();
			for (ServiceResource recurso: triggerNew){
				ServiceResource recursoOld;
				if(triggerOldMap != null){
					recursoOld = triggerOldMap.get(recurso.Id);
				}
				//Si el recurso está activo, tiene informada la relación con el profesional_gremio y se trata de una inserción o actualización del isActive, se actualiza el número de recursos activos. (Suma)
				//Si el recurso está inactivo, tiene informada la relación con el profesional_gremio y se trata de una actualización del isActive, se actualiza el número de recursos activos. (Resta)
				if(recurso.RSE_LKP_Profesional_Gremio__c != null && 
						((recurso.isActive && (recursoOld == null || !recursoOld.isActive)) ||
						(!recurso.isActive && recursoOld != null && recursoOld.isActive) ||
						(recursoOld != null && recurso.RSE_LKP_Profesional_Gremio__c != recursoOld.RSE_LKP_Profesional_Gremio__c))) {
					actualizarSRActivos.add(recurso);
					
				}
			}
			//Si se ha modificado el IsActive o es una inserción, se actualiza el número de recursos activos para un determinado profesional_gremio
			if(!actualizarSRActivos.isEmpty()){
				gremioProfesionalAActualizar = Util_Service_Resource.actualizarRecursosActivos(actualizarSRActivos);
			}
			
			for(ServiceResource recurso: triggerNew){
				// si es una inserción le añadimos todas las CIAs como habilidad de recurso de servicio
				listaSRS = Util_Service_Resource.anyadirCIAs(recurso,listaHabilidadesCIAs);
				
				ServiceResource recursoOld;
					if(triggerOldMap != null){
						recursoOld = triggerOldMap.get(recurso.Id);
					}
								
				if(recurso.isActive == true && (recursoOld == null || !recursoOld.isActive)) {
					//Creamos un registro en el objeto historico de Estados Profesionales
					historico = new Historico_Estados_Profesional__c();
					historico.HEP_CAS_Activo__c = true;
					historico.HEP_DAT_Fecha__c = datetime.now();
					historico.HEP_LKP_Recurso_Servicio__c = recurso.Id;
					historicoAActualizar.add(historico);
				}
				else {
					if(recurso.RSE_DAT_Fecha_BajaTemp_Venc__c != null && recurso.RSE_DAT_Fecha_Baja__c == null){
						//Creamos un registro en el objeto historico de Estados Profesionales
						historico = new Historico_Estados_Profesional__c();
						historico.HEP_CAS_Activo__c = false;
						historico.HEP_DAT_Fecha__c = datetime.now();
						historico.HEP_LKP_Recurso_Servicio__c = recurso.Id;
						if(recurso.RSE_SEL_Motivo_Baja_Temp__c !=null){
							historico.HEP_TXT_Motivo_Baja__c = mapaMotivoBajaTempo.get(recurso.RSE_SEL_Motivo_Baja_Temp__c);
						}
						if(recurso.RSE_TXT_Observaciones_BajaTemp__c !=null){
							historico.HEP_TXT_Observaciones__c = recurso.RSE_TXT_Observaciones_BajaTemp__c;
						}
						historicoAActualizar.add(historico);	
					}
					else if((recurso.RSE_DAT_Fecha_BajaTemp_Venc__c != null && recurso.RSE_DAT_Fecha_Baja__c != null)||(recurso.RSE_DAT_Fecha_BajaTemp_Venc__c == null && recurso.RSE_DAT_Fecha_Baja__c != null)){
						//Creamos un registro en el objeto historico de Estados Profesionales
						historico = new Historico_Estados_Profesional__c();
						historico.HEP_CAS_Activo__c = false;
						historico.HEP_DAT_Fecha__c = datetime.now();
						historico.HEP_LKP_Recurso_Servicio__c = recurso.Id;
						if(recurso.RSE_SEL_Motivo_Baja_Def__c !=null){
							historico.HEP_TXT_Motivo_Baja__c = mapaMotivoBajaTempo.get(recurso.RSE_SEL_Motivo_Baja_Def__c);
						}
						if(recurso.RSE_TXT_Observaciones_BajaDef__c !=null){
							historico.HEP_TXT_Observaciones__c = recurso.RSE_TXT_Observaciones_BajaDef__c;
						}
						historicoAActualizar.add(historico);
					}
				}
			}
		}
		if(!listaSRS.isEmpty()){
			// Le añadimos todas las CIAs como habilidad de recurso de servicio
			insert listaSRS;
			// Restablecemos la lista para los update
			listaSRS = new List<ServiceResourceSkill>();
		}
		if(!historicoAActualizar.isEmpty()){
			// Se actualiza el historico de estados del profesional
			insert historicoAActualizar;
		}
		if(!gremioProfesionalAActualizar.isEmpty()){
			//Se actualizan los recursos de servicios activos de los Gremio_Profesional
			update gremioProfesionalAActualizar;
		}
	}
}