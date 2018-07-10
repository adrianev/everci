/**
 * Clase de funciones relacionadas con la sincronización con Marketing Cloud.
 * 
 * @author EVERIS
 */
public without sharing class Util_SincronizacionMKT {
	public static void sincronizarOTs(Map<Id,WorkOrder> triggerNewMap, Map<Id,WorkOrder> triggerOldMap){
		// 1. Inicializar mapas de consultas
		// Mapa de Profesionales vinculados a las OTs del trigger
		Map<Id,ServiceResource> mapaSRs = new Map<Id,ServiceResource>();		
		Set<Id> setIdsSRs = new Set<Id>();
		for(WorkOrder wo : triggerNewMap.values()){
			if(wo.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)){
				/*if(wo.OTR_LKP_Recurso_Servicio__c != null){
					setIdsSRs.add(wo.OTR_LKP_Recurso_Servicio__c);
				}*/
				if(wo.OTR_LKP_Profesional_Programado__c != null){
					setIdsSRs.add(wo.OTR_LKP_Profesional_Programado__c);
				}
			}   
		}
		if(!setIdsSRs.isEmpty()){
			mapaSRs = Util_Service_Resource.queryMapSRByRsIds(setIdsSRs);
			/*mapaSRs = new Map<Id,ServiceResource>(
				[SELECT RSE_LKP_Cuenta__r.CUE_LKP_contacto_principal__r.Id
				 FROM ServiceResource
				 WHERE Id IN :setIdsSRs]);*/
		}
		// Mapa de objetos MKT vinculados a las OTs del trigger
		Map<Id, List<Work_Order_MKT__c>> mapaWOsServiciosMKT = new Map<Id, List<Work_Order_MKT__c>>();
		if(!triggerNewMap.keySet().isEmpty()){
			List<Work_Order_MKT__c> lista = Util_Orden_Trabajo.queryWorkOrderMKT(triggerNewMap.keySet()).values();
			/*List<Work_Order_MKT__c> lista = new List<Work_Order_MKT__c>(
				[SELECT Id,
						OTR_LKP_OrdenTrabajo__c,
						OTR_MKT_LKP_Contacto__c
				 FROM Work_Order_MKT__c
				 WHERE OTR_LKP_OrdenTrabajo__c IN :triggerNewMap.keySet()
				 ORDER BY OTR_LKP_OrdenTrabajo__c]);*/
			for(Work_Order_MKT__c registro : lista){
				List<Work_Order_MKT__c> listaAux = mapaWOsServiciosMKT.get(registro.OTR_LKP_OrdenTrabajo__c);
				if(listaAux == null){
					listaAux = new List<Work_Order_MKT__c>();
				}
				listaAux.add(registro);
				mapaWOsServiciosMKT.put(registro.OTR_LKP_OrdenTrabajo__c, listaAux);
			}
		}

		// 2. Tratamiento según las operaciones del trigger:
		List<Work_Order_MKT__c> crearServiciosMKT = new List<Work_Order_MKT__c>();
		List<Work_Order_MKT__c> eliminarServiciosMKT = new List<Work_Order_MKT__c>();
		for(WorkOrder wo : triggerNewMap.values()){
			if(wo.RecordTypeId == Util_mapasTiposDeRegistro.RTIDBYDEVNAME.get(Label.RT_OT_REPA)&& wo.OTR_LKP_Profesional_Programado__c != null){
				WorkOrder woOld =(triggerOldMap != null)? triggerOldMap.get(wo.Id):null;
				/*if(triggerOldMap != null){
					woOld = triggerOldMap.get(wo.Id);
				}*/
				List<Work_Order_MKT__c> listaServiciosMKT = mapaWOsServiciosMKT.get(wo.Id); 
				Boolean insertarMKT = false;
				// Si se ha actualizado y se ha cambiado el estado a CERRADO: se eliminan los registros de MKT
				if(/*woOld != null && */wo.Status == Label.OTR_ESTADO_CERRADO && listaServiciosMKT != null /* && wo.Status != woOld.Status && (!listaServiciosMKT.isEmpty())*/){
					eliminarServiciosMKT.addAll(listaServiciosMKT);
				}
				else/* if(wo.Status != Label.OTR_ESTADO_CERRADO)*/ {
					//Id idContactoProf = null;
					//Id idProfesional = null;
					String etiquetaGremio = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder','OTR_SEL_Gremio__c').get(wo.OTR_SEL_Gremio__c);
					String etiquetaTipoRed = Util_Listas_Seleccion.getLabelDesdeAPI('WorkOrder','OTR_SEL_Tipo_Red__c').get(wo.OTR_SEL_Tipo_Red__c);
					
					/*if(woOld == null){
						// Si la OT es nueva y tiene profesional asignado: se crea un nuevo registro de MKT
						if(wo.OTR_LKP_Recurso_Servicio__c != null &&
						   mapaSRs.get(wo.OTR_LKP_Recurso_Servicio__c) != null){
							idProfesional = wo.OTR_LKP_Recurso_Servicio__c;
							idContactoProf = mapaSRs.get(wo.OTR_LKP_Recurso_Servicio__c).RSE_LKP_Cuenta__r.CUE_LKP_contacto_principal__r.Id;
							insertarMKT = true;
						}
						// Si la OT es nueva y solo tiene profesional programado: se crea un nuevo registro de MKT
						else
						if(wo.OTR_LKP_Recurso_Servicio__c == null && wo.OTR_LKP_Profesional_Programado__c != null &&
								mapaSRs.get(wo.OTR_LKP_Profesional_Programado__c) != null){
							idProfesional = wo.OTR_LKP_Profesional_Programado__c;
							idContactoProf = mapaSRs.get(wo.OTR_LKP_Profesional_Programado__c).RSE_LKP_Cuenta__r.CUE_LKP_contacto_principal__r.Id;
							insertarMKT = true;
						}
					}
					else {
						// Si la OT es existente y se ha cambiado el profesional asignado: se crea un nuevo registro de MKT
						if(wo.OTR_LKP_Recurso_Servicio__c != woOld.OTR_LKP_Recurso_Servicio__c){
							if(wo.OTR_LKP_Recurso_Servicio__c != null && mapaSRs.get(wo.OTR_LKP_Recurso_Servicio__c) != null){
								idProfesional = wo.OTR_LKP_Recurso_Servicio__c;
								idContactoProf = mapaSRs.get(wo.OTR_LKP_Recurso_Servicio__c).RSE_LKP_Cuenta__r.CUE_LKP_contacto_principal__r.Id;
								insertarMKT = true;
							}
						}
						// Si la OT es existente, el profesional asignado es nulo y se ha modificado el profesional programado: se crea un nuevo registro de MKT
						if(wo.OTR_LKP_Recurso_Servicio__c == null && wo.OTR_LKP_Profesional_Programado__c != woOld.OTR_LKP_Profesional_Programado__c){
							if(wo.OTR_LKP_Profesional_Programado__c != null && mapaSRs.get(wo.OTR_LKP_Profesional_Programado__c) != null){
								idProfesional = wo.OTR_LKP_Profesional_Programado__c;
								idContactoProf = mapaSRs.get(wo.OTR_LKP_Profesional_Programado__c).RSE_LKP_Cuenta__r.CUE_LKP_contacto_principal__r.Id;
								insertarMKT = true;
							}
						}
					}*/
					//ICA
					//Si es inserción con un profesional asignado o es un update y el profesional ha cambiado
					if((woOld==null && wo.OTR_LKP_Profesional_Programado__c != null && mapaSRs.get(wo.OTR_LKP_Profesional_Programado__c) != null)
							|| (woOld!=null && wo.OTR_LKP_Profesional_Programado__c != null && wo.OTR_LKP_Profesional_Programado__c != woOld.OTR_LKP_Profesional_Programado__c && mapaSRs.get(wo.OTR_LKP_Profesional_Programado__c) != null)
							|| (woOld!=null && wo.OTR_LKP_Recurso_Servicio__c != woOld.OTR_LKP_Recurso_Servicio__c)){
					//ICA
						// Insertar registro para forzar el disparador del Journey de MKT Cloud
						Work_Order_MKT__c servicioMKT = new Work_Order_MKT__c(OTR_LKP_OrdenTrabajo__c=wo.Id,
																			  Name=wo.WorkOrderNumber,
																			  OTR_MKT_LKP_Profesional__c=wo.OTR_LKP_Profesional_Programado__c,
																			  OTR_MKT_LKP_Contacto__c=mapaSRs.get(wo.OTR_LKP_Profesional_Programado__c).RSE_LKP_Cuenta__r.CUE_LKP_contacto_principal__r.Id,
																			  OTR_TXT_Gremio__c=etiquetaGremio,
																			  OTR_TXT_Tipo_Red__c=etiquetaTipoRed);
						crearServiciosMKT.add(servicioMKT);
					}
				}
			}
		}
		// 3.1 Eliminación de registros Servicio MKT:
		if(!eliminarServiciosMKT.isEmpty()){
			delete eliminarServiciosMKT;
		}
		// 3.2 Creación de registros Servicio MKT:
		if(!crearServiciosMKT.isEmpty()){
			insert crearServiciosMKT;
		}
	}
}