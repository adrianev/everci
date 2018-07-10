/**
 * Clase de funciones auxiliares relacionadas con el objeto personalizado Util_Propuesta_de_abono 
 * 
 * @author EVERIS
 * 
 */
public without sharing class Util_Propuesta_de_abono {



public static Map<Id,Propuesta_de_abono__c> queryMap_Propuesta_de_AbonoBy_EV_AB_LKP_Caso_Or_Orden_de_Trabajo_r_CaseId_And_PropEvEconomico_null_And_LKPAbono_null_And_EstadoNoAprobado_And_EstadoNoRechazado(set<Id> reclamacionIds){
    
        Map<Id,Propuesta_de_abono__c> mapa = new Map<Id,Propuesta_de_abono__c>();
        
        if(reclamacionIds != null && !reclamacionIds.isEmpty()){
            
            for(List<Propuesta_de_abono__c> lista : 
            [Select id from Propuesta_de_abono__c where (AB_LKP_Caso__c in :reclamacionIds
            or AB_LKP_Orden_de_Trabajo__r.CaseId in :reclamacionIds)
            and AB_SEL_Estado__c != :Label.EV_AB_ESTADO_APROBADO 
            and AB_SEL_Estado__c != :Label.EV_AB_ESTADO_RECHAZADO]) {
                
                mapa.putAll(lista);
            }
        }
        return mapa;
    }

public static Map<Id,Propuesta_de_abono__c> getPropuestaAbonoById(Set<Id> setId){
	
		Map<Id,Propuesta_de_abono__c> mapa = new Map<Id,Propuesta_de_abono__c>();
		
		if(setId != null && !setId.isEmpty()){
			for(List<Propuesta_de_abono__c> lista : 
			[SELECT Id 
				,AB_LKP_Ingresar_a__c//,AB_LKP_Cuenta__c
				,AB_DIV_Importe_a_ingresar__c//,AB_DIV_Importe_a_imputar__c
				,AB_TXT_Descripcion__c
				,AB_LKP_Caso__c
				,AB_LKP_Orden_de_Trabajo__c
				,AB_FOR_Direccion_Territorial__c
				,AB_LKP_Caso__r.CAS_LKP_Procedencia__r.PROC_SEL_Canal__c
				,AB_LKP_Caso__r.CAS_LKP_Procedencia__r.PROC_SEL_Subcanal__c
				,AB_LKP_Orden_de_Trabajo__r.WorkOrderNumber
				,AB_LKP_Caso__r.Type
				,AB_LKP_Caso__r.CAS_SEL_Grupo_Causa__c
				,AB_LKP_Caso__r.RecordTypeId
				,AB_LKP_Caso__r.CAS_LKP_Cliente_contable__c
				,AB_LKP_Orden_de_Trabajo__r.OTR_LKP_Recurso_Servicio__c
				,AB_LKP_Caso__r.CaseNumber
				,AB_LKP_Ingresar_a__r.CUE_TXT_Identificador__c//,AB_LKP_Cuenta__r.CUE_TXT_Identificador__c
				,AB_LKP_Caso__r.CAS_LKP_Compania__r.CUE_TXT_Identificador__c
				,AB_TXT_Observaciones__c
         		,AB_LKP_Factura__r.FAC_TXT_Numero_factura__c
				,AB_LKP_Cuenta__c
				,AB_DIV_Importe_a_Imputar__c
				,AB_LKP_Caso__r.CAS_LKP_Procedencia__r.PROC_TXT_Identificador__c
				FROM Propuesta_de_abono__c WHERE Id IN :setId]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Método que te devuelve una lista con los abonos de un caso
	 *
	 * @param casoIds: set de ids de caso
	 * @return abonos por id caso
	 */
	public static Map<Id, List<Propuesta_de_abono__c>> pAbonosByCaso(Set<Id> casoIds){
		Map<Id, List<Propuesta_de_abono__c>> resultados = new Map<Id,List<Propuesta_de_abono__c>>();
		if(casoIds != null && !casoIds.isEmpty()) {
			List<Propuesta_de_abono__c> propAb = [Select Id,
													AB_CAS_Abono_Liquidado__c,
													AB_LKP_Orden_de_Trabajo__c,
													AB_LKP_Caso__c 
													from Propuesta_de_abono__c where AB_LKP_Caso__c in :casoIds];
			for(Propuesta_de_abono__c ab: propAb){
				List<Propuesta_de_abono__c> temp = resultados.get(ab.AB_LKP_Caso__c);
				if(temp == null)
					temp = new List<Propuesta_de_abono__c>();
					
				temp.add(ab);
				resultados.put(ab.AB_LKP_Caso__c,temp);
			}
		}
		return resultados;
	}

	/**
	 * Devuelve un mapa de propuestas de abono filtrado por un conjunto de ids de Ordenes de trabajo.
	 *
	 * @param setIdWos: ids de las ordenes de trabajo
	 * @return mapa de propuestas de abono filtradas
	 */
	public static Map<Id,Propuesta_de_abono__c> queryPropAbByWo(Set<Id> setIdWos){
		Map<Id,Propuesta_de_abono__c> mapa = new Map<Id,Propuesta_de_abono__c>();
		if(setIdWos != null && !setIdWos.isEmpty()){
			for (List<Propuesta_de_abono__c> lista : [SELECT Id,
													 AB_CAS_Abono_Liquidado__c,
													 AB_LKP_Orden_de_Trabajo__c 
													 FROM Propuesta_de_abono__c WHERE AB_LKP_Orden_de_Trabajo__c IN :setIdWos]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}

	/**
	 * Devuelve un mapa de propuestas de abono filtrado por un conjunto de ids de Abonos.
	 *
	 * @param setIdProp: ids de los abonos
	 * @return mapa de propuestas de abono filtradas
	 */
	public static Map<Id,Propuesta_de_abono__c> getPropAbByAbono(Set<Id> setIdProp){
		Map<Id,Propuesta_de_abono__c> mapa = new Map<Id,Propuesta_de_abono__c>();
		if(setIdProp != null && !setIdProp.isEmpty()){
			for (List<Propuesta_de_abono__c> lista : [SELECT 
                                                      Id, 
                                                      AB_CAS_Abono_Liquidado__c,
                                                      AB_SEL_Descripcion_evento__c,
                                                      AB_LKP_Caso__c,
                                                      AB_LKP_Orden_de_Trabajo__c
                                                      FROM Propuesta_de_Abono__c WHERE Id IN :setIdProp]){
				mapa.putAll(lista);
			}
		}
		return mapa;
	}
}