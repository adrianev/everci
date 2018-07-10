/**
 * Clase de funciones auxiliares relacionadas con el objeto personalizado Util_Propuesta_de_evento 
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Propuesta_de_evento {
	

public static Map<Id,Propuesta_de_evento__c> queryMap_Propuesta_de_EventoBy_EV_AB_LKP_Caso_Or_Orden_de_Trabajo_r_CaseId_And_PropEvEconomico_null_And_LKPAbono_null_And_EstadoNoAprobado_And_EstadoNoRechazado(set<Id> reclamacionIds){
	
		Map<Id,Propuesta_de_evento__c> mapa = new Map<Id,Propuesta_de_evento__c>();
		
		if(reclamacionIds != null && !reclamacionIds.isEmpty()){
			
			for(List<Propuesta_de_evento__c> lista : 
			[Select Id from Propuesta_de_evento__c where
			 (EV_AB_LKP_Caso__c in :reclamacionIds or EV_AB_LKP_Orden_de_Trabajo__r.CaseId in :reclamacionIds) 
			and EV_AB_LKP_Propuesta_de_Evento_Economico__c = null and EV_AB_LKP_Abono__c = null and EV_AB_SEL_Estado__c != :Label.EV_AB_ESTADO_APROBADO 
			and EV_AB_SEL_Estado__c != :Label.EV_AB_ESTADO_RECHAZADO]){
				
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
public static Map<Id,Propuesta_de_evento__c> getPropuestaEventoByAbono(Set<Id> setAbonosId){
	
		Map<Id,Propuesta_de_evento__c> mapa = new Map<Id,Propuesta_de_evento__c>();
		
		if(setAbonosId != null && !setAbonosId.isEmpty()){
			for(List<Propuesta_de_evento__c> lista : 
			[SELECT Id, EV_AB_LKP_Abono__c FROM Propuesta_de_Evento__c WHERE EV_AB_LKP_Abono__c IN :setAbonosId]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	public static Map<Id,Propuesta_de_evento__c> getPropuestaEventoByIdOrEconomico(Set<Id> setAbonosId, Set<Id> setEconomicoId){
	
		Map<Id,Propuesta_de_evento__c> mapa = new Map<Id,Propuesta_de_evento__c>();
		
		if(setAbonosId != null && !setAbonosId.isEmpty() && setEconomicoId != null && !setEconomicoId.isEmpty()){
			for(List<Propuesta_de_evento__c> lista : 
			[SELECT Id
				,EV_AB_LKP_Abono__c
				,EV_AB_LKP_Caso__r.CAS_LKP_Procedencia__r.PROC_SEL_Canal__c
				,EV_AB_LKP_Caso__r.CAS_LKP_Procedencia__r.PROC_SEL_Subcanal__c
				,EV_AB_LKP_Caso__c
				,EV_AB_LKP_Orden_de_Trabajo__c
				,EV_AB_LKP_Orden_de_Trabajo__r.WorkOrderNumber
				,EV_AB_SEL_Descripcion__c
				,EV_AB_FOR_Direccion_Territorial__c
				,EV_AB_LKP_Caso__r.Type
				,EV_AB_LKP_Caso__r.CAS_SEL_Grupo_Causa__c
				,EV_AB_DIV_Importe_gestor__c
				,EV_AB_LKP_Orden_de_Trabajo__r.OTR_LKP_Recurso_Servicio__c
				,EV_AB_LKP_Caso__r.CAS_LKP_Compania__c
				,EV_AB_SEL_Tipo_de_Evento__c
				,EV_AB_LKP_Caso__r.CAS_LKP_Cliente_contable__c
				,EV_AB_LKP_Caso__r.RecordTypeId
				,EV_AB_LKP_Caso__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c
				,EV_AB_LKP_Caso__r.CaseNumber
				,EV_AB_LKP_Orden_de_Trabajo__r.OTR_LKP_Recurso_Servicio__r.RSE_LKP_Cuenta__c
				,EV_AB_LKP_Imputar_a_profesional__c
				,EV_AB_DIV_Importe_profesional__c
				,EV_AB_LKP_Liquidar_a_prof__c
				,EV_AB_DIV_Importe_a_liquidar_prof__c
				,EV_AB_LKP_Caso__r.CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c	
				FROM Propuesta_de_Evento__c WHERE Id IN :setAbonosId OR EV_AB_LKP_Propuesta_de_Evento_Economico__c IN :setEconomicoId]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Método que te devuelve una lista con los eventos de un caso
	 *
	 * @param casoIds: set de ids de caso
	 * @return eventos por id caso
	 */
	public static Map<Id, List<Propuesta_de_evento__c>> pEventosByCaso(Set<Id> casoIds){
		Map<Id, List<Propuesta_de_evento__c>> resultados = new Map<Id,List<Propuesta_de_evento__c>>();
		if(casoIds != null && !casoIds.isEmpty()){
			List<Propuesta_de_evento__c> propEv = [SELECT id,
													EV_AB_CAS_Evento_Ab_Facturado__c,
													EV_AB_LKP_Orden_de_Trabajo__c,
													EV_AB_SEL_Tipo_de_Evento__c,
													EV_AB_LKP_Caso__c,
													EV_AB_SEL_Descripcion__c,
													EV_AB_LKP_Imputar_a_profesional__c,
													EV_AB_DIV_Importe_profesional__c,
													EV_AB_LKP_Liquidar_a_prof__c,
													EV_AB_DIV_Importe_a_liquidar_prof__c,
													EV_AB_LKP_Cuenta_profesional__c,
													EV_AB_LKP_Propuesta_de_Evento_Economico__c,
													Createddate
													FROM Propuesta_de_evento__c WHERE EV_AB_LKP_Caso__c IN :casoIds];
		
			for(Propuesta_de_evento__c evt: propEv){
				List<Propuesta_de_evento__c> temp = resultados.get(evt.EV_AB_LKP_Caso__c);
				if(temp == null)
					temp = new List<Propuesta_de_Evento__c>();
					
				temp.add(evt);
				resultados.put(evt.EV_AB_LKP_Caso__c,temp);
			}	
		}
		return resultados;
	}

	/** metodo para devolver un mapa con las propuestas de evento a partir de la órden de trabajo
	 * @param setIdWo: set de ids de Wo asociadas a una propuesta de evento
	 * @return devuelve un mapa con propuestas de evento
	 */
	public static Map<Id,Propuesta_de_evento__c> queryPropEvByWoId(Set<Id> setIdWo){
		Map<Id,Propuesta_de_evento__c> mapa = new Map<Id,Propuesta_de_evento__c>();
		if(setIdWo != null && !setIdWo.isEmpty()){
			for(List<Propuesta_de_evento__c> lista:[SELECT id,
													EV_AB_CAS_Evento_Ab_Facturado__c,
													EV_AB_LKP_Orden_de_Trabajo__c, 
													EV_AB_SEL_Tipo_de_Evento__c,
													EV_AB_SEL_Descripcion__c,
													EV_AB_LKP_Imputar_a_profesional__c,
													EV_AB_DIV_Importe_profesional__c,
													EV_AB_LKP_Liquidar_a_prof__c,
													EV_AB_DIV_Importe_a_liquidar_prof__c,
													EV_AB_LKP_Cuenta_profesional__c,
													EV_AB_LKP_Propuesta_de_Evento_Economico__c,
													EV_AB_CAS_Evento_Ab_Liquidado__c,
													Createddate
													FROM Propuesta_de_evento__c WHERE EV_AB_LKP_Orden_de_Trabajo__c IN :setIdWo]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/** metodo para devolver un mapa con las propuestas de evento a partir del profesional
	 * @param setIdCue: set de ids de profesional asociadas a una propuesta de evento
	 * @return devuelve un mapa con propuestas de evento
	 */
	public static Map<Id,Propuesta_de_evento__c> queryPropEvByCueId(Set<Id> setIdCue){
		Map<Id,Propuesta_de_evento__c> mapa = new Map<Id,Propuesta_de_evento__c>();
		if(setIdCue != null && !setIdCue.isEmpty()){
			for(List<Propuesta_de_evento__c> lista:[SELECT Id,
													EV_AB_CAS_Evento_Ab_Facturado__c,
													EV_AB_LKP_Orden_de_Trabajo__c,
													EV_AB_SEL_Tipo_de_Evento__c,
													EV_AB_LKP_Caso__c,
													EV_AB_SEL_Descripcion__c,
													EV_AB_LKP_Imputar_a_profesional__c,
													EV_AB_DIV_Importe_profesional__c,
													EV_AB_LKP_Liquidar_a_prof__c,
													EV_AB_DIV_Importe_a_liquidar_prof__c,
													EV_AB_LKP_Cuenta_profesional__c,
													EV_AB_LKP_Propuesta_de_Evento_Economico__c,
													Createddate
													FROM Propuesta_de_evento__c WHERE EV_AB_LKP_Cuenta_profesional__c IN :setIdCue]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
	
	/** metodo para devolver un mapa con las propuestas de evento a partir de la propuesta de evento economica
	 * @param setIdProvEv: set de ids de propuestas de evento asociadas a una propuesta de evento
	 * @return devuelve un mapa con propuestas de evento
	 */
	public static Map<Id,Propuesta_de_evento__c> queryPropEvByPropEvEconomico(Set<Id> setIdProvEv){
		Map<Id,Propuesta_de_evento__c> mapa = new Map<Id,Propuesta_de_evento__c>();
		if(setIdProvEv != null && !setIdProvEv.isEmpty()){
			for(List<Propuesta_de_evento__c> lista:[SELECT Id,
														   EV_AB_LKP_Propuesta_de_Evento_Economico__c 
														   FROM Propuesta_de_evento__c 
														   WHERE EV_AB_LKP_Propuesta_de_Evento_Economico__c IN : setIdProvEv]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
}